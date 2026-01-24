#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Defaults
# =========================================================
REPO_DEFAULT="https://github.com/Luna1506/dotfiles.git"
DEST_DEFAULT="$HOME/dotfiles"
BRANCH_DEFAULT="main"
RUN_FIRST_DEFAULT="true"

MONITOR_DEFAULT="eDP-1"
ZOOM_DEFAULT="1"     # STRING: "1", "1.5", "2.5", ...

# =========================================================
# Usage
# =========================================================
usage() {
  cat <<'EOF'
Usage:
  bootstrap-dotfiles.sh --username <name> [options]

Required:
  --username <name>            New username to set in flake.nix + modules/users.nix + ./home/<user>

Options:
  --fullname "<Full Name>"     Full name for modules/users.nix
  --repo <url>                 Git repo URL
  --dest <path>                Destination directory (default: ~/dotfiles)
  --branch <name>              Git branch (default: main)
  --nvidia-alt <true|false>    Set nvidiaAlternative in flake.nix
  --monitor <name>             Monitor name in flake.nix (default: eDP-1)
  --zoom <string>              Zoom string in flake.nix (default: "1"), e.g. "1.5"
  --no-first-run               Do not run first-run.sh
  -h, --help                   Show this help
EOF
}

die() { echo "Error: $*" >&2; exit 1; }

# =========================================================
# Args
# =========================================================
USERNAME=""
FULLNAME=""
REPO="$REPO_DEFAULT"
DEST="$DEST_DEFAULT"
BRANCH="$BRANCH_DEFAULT"
NVIDIA_ALT=""
RUN_FIRST="$RUN_FIRST_DEFAULT"

MONITOR="$MONITOR_DEFAULT"
ZOOM="$ZOOM_DEFAULT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --username) USERNAME="${2:-}"; shift 2;;
    --fullname) FULLNAME="${2:-}"; shift 2;;
    --repo) REPO="${2:-}"; shift 2;;
    --dest) DEST="${2:-}"; shift 2;;
    --branch) BRANCH="${2:-}"; shift 2;;
    --nvidia-alt) NVIDIA_ALT="${2:-}"; shift 2;;
    --monitor) MONITOR="${2:-}"; shift 2;;
    --zoom) ZOOM="${2:-}"; shift 2;;
    --no-first-run) RUN_FIRST="false"; shift 1;;
    -h|--help) usage; exit 0;;
    *) die "Unknown argument: $1";;
  esac
done

[[ -n "$USERNAME" ]] || { usage; die "--username is required"; }
[[ -z "$NVIDIA_ALT" || "$NVIDIA_ALT" == "true" || "$NVIDIA_ALT" == "false" ]] \
  || die "--nvidia-alt must be true or false"

# Zoom validation (string but numeric-looking)
if ! [[ "$ZOOM" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  die "--zoom must look like 1 or 1.5 or 2.5 (dot only), and will be written as a string"
fi

# =========================================================
# Helpers
# =========================================================
set_kv_string_simple() {
  # Replace: key = "..."
  local file="$1" key="$2" value="$3"
  [[ -f "$file" ]] || return 0
  if grep -qE "\b${key}\s*=" "$file"; then
    perl -0777 -i -pe "s/(\\b${key}\\s*=\\s*\")([^\"]*)(\"\\s*;)/\$1${value}\$3/g" "$file"
    echo "✔ ${file}: set ${key} = \"${value}\""
  fi
}

set_kv_bool_simple() {
  # Replace: key = true/false
  local file="$1" key="$2" value="$3"
  [[ -f "$file" ]] || return 0
  if grep -qE "\b${key}\s*=" "$file"; then
    perl -0777 -i -pe "s/(\\b${key}\\s*=\\s*)(true|false)(\\s*;)/\$1${value}\$3/g" "$file"
    echo "✔ ${file}: set ${key} = ${value}"
  fi
}

patch_flake() {
  local f="$1"
  [[ -f "$f" ]] || return 0

  # Patch the let-bindings (works regardless of indentation)
  set_kv_string_simple "$f" "username" "$USERNAME"
  set_kv_string_simple "$f" "monitor" "$MONITOR"
  set_kv_string_simple "$f" "zoom" "$ZOOM"

  if [[ -n "$NVIDIA_ALT" ]]; then
    set_kv_bool_simple "$f" "nvidiaAlternative" "$NVIDIA_ALT"
  fi

  echo "✔ Patched $f (username/monitor/zoom/nvidiaAlternative)"
}

patch_users_module() {
  local f="$1"
  [[ -f "$f" ]] || return 0

  # These are "best effort" — only change if the key exists.
  set_kv_string_simple "$f" "username" "$USERNAME"
  set_kv_string_simple "$f" "name" "$USERNAME"

  if [[ -n "$FULLNAME" ]]; then
    set_kv_string_simple "$f" "fullName" "$FULLNAME"
    set_kv_string_simple "$f" "realName" "$FULLNAME"
    set_kv_string_simple "$f" "description" "$FULLNAME"
  fi
}

rename_home_dir() {
  local homeRoot="$1" newUser="$2"

  [[ -d "$homeRoot" ]] || { echo "ℹ No $homeRoot directory, skipping home folder rename"; return 0; }

  if [[ -d "$homeRoot/$newUser" ]]; then
    echo "✔ Home folder already exists: $homeRoot/$newUser"
    return 0
  fi

  # Prefer ./home/luna if present (your repo convention)
  if [[ -d "$homeRoot/luna" ]]; then
    echo "→ Renaming $homeRoot/luna → $homeRoot/$newUser"
    mv "$homeRoot/luna" "$homeRoot/$newUser"
    return 0
  fi

  # Otherwise, if exactly one directory exists under ./home, rename it
  mapfile -t dirs < <(find "$homeRoot" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)
  if [[ "${#dirs[@]}" -eq 1 ]]; then
    local old="${dirs[0]}"
    echo "→ Renaming $homeRoot/$old → $homeRoot/$newUser"
    mv "$homeRoot/$old" "$homeRoot/$newUser"
    return 0
  fi

  echo "⚠ Could not determine which home folder to rename in $homeRoot (found ${#dirs[@]} dirs). Skipping."
  echo "  Found: ${dirs[*]:-<none>}"
}

# =========================================================
# Main
# =========================================================
echo "→ Repo:    $REPO"
echo "→ Dest:    $DEST"
echo "→ Branch:  $BRANCH"
echo "→ User:    $USERNAME"
[[ -n "$FULLNAME" ]] && echo "→ Name:    $FULLNAME"
[[ -n "$NVIDIA_ALT" ]] && echo "→ NVIDIA:  $NVIDIA_ALT"
echo "→ Monitor: $MONITOR"
echo "→ Zoom:    \"$ZOOM\""
echo

command -v git >/dev/null || die "git not installed"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "→ Cloning repository"
git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMP/repo" >/dev/null

if [[ -e "$DEST" ]]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  BACKUP="${DEST}.bak-${TS}"
  echo "→ Backing up existing $DEST → $BACKUP"
  mv "$DEST" "$BACKUP"
fi

echo "→ Installing dotfiles"
mkdir -p "$(dirname "$DEST")"
mv "$TMP/repo" "$DEST"

# Remove .git (dotfiles should not remain a git repo)
if [[ -d "$DEST/.git" ]]; then
  echo "→ Removing .git directory"
  rm -rf "$DEST/.git"
fi

# Rename ./home/<old> -> ./home/<username>
rename_home_dir "$DEST/home" "$USERNAME"

# Patch configuration files
echo "→ Patching configuration files"
patch_flake "$DEST/flake.nix"
patch_users_module "$DEST/modules/users.nix"

# Run first-run.sh
if [[ "$RUN_FIRST" == "true" ]]; then
  if [[ -f "$DEST/first-run.sh" ]]; then
    echo "→ Running first-run.sh"
    chmod +x "$DEST/first-run.sh"
    (cd "$DEST" && ./first-run.sh)
  else
    echo "⚠ first-run.sh not found, skipping"
  fi
else
  echo "→ Skipping first-run.sh"
fi

echo
echo "✅ Done."
echo "Next:"
echo "  cd $DEST"
echo "  sudo nixos-rebuild switch --flake .#nixos"

