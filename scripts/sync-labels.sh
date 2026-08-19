#!/usr/bin/env bash
#
# Bring the labels of BX Team repositories in line with labels.json.
#
#   scripts/sync-labels.sh                    # dry run, every repository in the manifest
#   scripts/sync-labels.sh irori Nyx          # dry run, just these
#   scripts/sync-labels.sh --apply            # actually write
#   scripts/sync-labels.sh --apply --prune    # also delete labels the manifest does not list
#
# Needs `gh` (authenticated, `repo` scope) and `jq`. Nothing else.
#
# A legacy label is *renamed*, not recreated, so every issue and PR that already
# carries it keeps it. Labels the manifest does not mention are reported and left
# alone unless --prune is passed, because deleting one drops it from every issue.

set -euo pipefail

readonly ORG=BX-Team
readonly MANIFEST="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/labels.json"

apply=false
prune=false
repos=()

for arg in "$@"; do
  case "$arg" in
    --apply) apply=true ;;
    --prune) prune=true ;;
    -h | --help)
      sed -n '2,17p' "${BASH_SOURCE[0]}" | cut -c3-
      exit 0
      ;;
    -*)
      echo "unknown flag: $arg" >&2
      exit 2
      ;;
    *) repos+=("$arg") ;;
  esac
done

for tool in gh jq; do
  command -v "$tool" >/dev/null || {
    echo "$tool is required" >&2
    exit 1
  }
done
[ -f "$MANIFEST" ] || {
  echo "manifest not found: $MANIFEST" >&2
  exit 1
}

if [ ${#repos[@]} -eq 0 ]; then
  mapfile -t repos < <(jq -r '.repositories | keys[]' "$MANIFEST")
fi

# Everything below prints the action it would take; `run` is the only thing that
# turns a printed line into a request.
run() {
  if $apply; then
    "$@" >/dev/null
  fi
}

changes=0
warnings=0

for repo in "${repos[@]}"; do
  echo "── $ORG/$repo"

  sections="$(jq -r --arg r "$repo" '.repositories[$r] // empty | .[]' "$MANIFEST")" || true
  if ! jq -e --arg r "$repo" '.repositories | has($r)' "$MANIFEST" >/dev/null; then
    echo "   !  not in the manifest, skipping"
    warnings=$((warnings + 1))
    continue
  fi

  # The labels this repository should end up with: common + its extra sections.
  desired="$(jq -c --argjson s "$(printf '%s\n' "$sections" | jq -R . | jq -sc 'map(select(. != ""))')" \
    '.common + ([$s[] as $k | .extra[$k][]])' "$MANIFEST")"

  current="$(gh label list -R "$ORG/$repo" --limit 200 --json name,color,description)"

  # 1. Renames first, so the create/update pass below sees the new name.
  while IFS=$'\t' read -r old new; do
    [ -n "$old" ] || continue
    jq -e --arg n "$old" 'any(.[]; .name == $n)' <<<"$current" >/dev/null || continue

    if jq -e --arg n "$new" 'any(.[]; .name == $n)' <<<"$current" >/dev/null; then
      echo "   !  '$old' and '$new' both exist — merge by hand, then delete '$old'"
      warnings=$((warnings + 1))
      continue
    fi

    spec="$(jq -c --arg n "$new" 'map(select(.name == $n)) | .[0]' <<<"$desired")"
    [ "$spec" != "null" ] || continue

    echo "   ~  rename '$old' → '$new'"
    run gh label edit "$old" -R "$ORG/$repo" \
      --name "$new" \
      --color "$(jq -r .color <<<"$spec")" \
      --description "$(jq -r .description <<<"$spec")"
    changes=$((changes + 1))
    current="$(jq -c --arg o "$old" --arg n "$new" 'map(if .name == $o then .name = $n else . end)' <<<"$current")"
  done < <(jq -r '.renames | to_entries[] | "\(.key)\t\(.value)"' "$MANIFEST")

  # 2. Create what is missing, correct the colour and description of what is not.
  while IFS=$'\t' read -r name color description; do
    have="$(jq -c --arg n "$name" 'map(select(.name == $n)) | .[0] // empty' <<<"$current")"

    if [ -z "$have" ]; then
      echo "   +  create '$name'"
      run gh label create "$name" -R "$ORG/$repo" --color "$color" --description "$description"
      changes=$((changes + 1))
      continue
    fi

    have_color="$(jq -r .color <<<"$have")"
    have_desc="$(jq -r '.description // ""' <<<"$have")"
    if [ "${have_color,,}" != "${color,,}" ] || [ "$have_desc" != "$description" ]; then
      echo "   ~  update '$name'"
      run gh label edit "$name" -R "$ORG/$repo" --color "$color" --description "$description"
      changes=$((changes + 1))
    fi
  done < <(jq -r '.[] | "\(.name)\t\(.color)\t\(.description)"' <<<"$desired")

  # 3. Anything left over. Reported always, removed only on request.
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if $prune; then
      echo "   -  delete '$name'"
      run gh label delete "$name" -R "$ORG/$repo" --yes
      changes=$((changes + 1))
    else
      echo "   ?  unmanaged: '$name' (--prune deletes it)"
    fi
  done < <(jq -r --argjson d "$desired" '[.[].name] - [$d[].name] | .[]' <<<"$current")
done

echo
if $apply; then
  echo "applied $changes change(s), $warnings warning(s)"
else
  echo "$changes change(s) pending, $warnings warning(s) — re-run with --apply to write them"
fi
