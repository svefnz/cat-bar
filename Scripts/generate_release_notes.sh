#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 || $# -gt 4 ]]; then
  echo "Usage: $0 <tag> <version> [output_path] [previous_tag]" >&2
  exit 1
fi

tag="$1"
version="$2"
output_path="${3:-release.md}"
previous_tag="${4:-}"
changelog_path="CHANGELOG.md"

resolve_previous_tag() {
  local release_tag="$1"
  local release_version="${release_tag#v}"
  local candidate

  while IFS= read -r candidate; do
    if [[ ! "$candidate" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      continue
    fi
    if [[ "${candidate#v}" == "$release_version" ]]; then
      continue
    fi
    echo "$candidate"
    return 0
  done < <(git tag --merged HEAD --sort=-v:refname)

  echo "No stable SemVer baseline tag reachable from HEAD. Cannot generate release notes." >&2
  return 1
}

if [[ ! "$tag" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Release tag '$tag' is not a stable SemVer tag (expected v1.2.3 or 1.2.3)." >&2
  exit 1
fi

if ! git rev-parse --verify --quiet "${tag}^{commit}" >/dev/null; then
  echo "Release tag '$tag' does not resolve to a commit." >&2
  exit 1
fi

if [[ -z "$previous_tag" ]]; then
  previous_tag="$(resolve_previous_tag "$tag")"
else
  if [[ ! "$previous_tag" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Previous tag '$previous_tag' is not a stable SemVer tag." >&2
    exit 1
  fi
  if [[ "${previous_tag#v}" == "${tag#v}" ]]; then
    echo "Previous tag '$previous_tag' has the same version as release tag '$tag'." >&2
    exit 1
  fi
  if ! git rev-parse --verify --quiet "${previous_tag}^{commit}" >/dev/null; then
    echo "Previous tag '$previous_tag' does not resolve to a commit." >&2
    exit 1
  fi
  if ! git merge-base --is-ancestor "${previous_tag}^{commit}" HEAD; then
    echo "Previous tag '$previous_tag' is not reachable from HEAD." >&2
    exit 1
  fi
fi

if [[ ! -f "$changelog_path" ]]; then
  echo "Missing $changelog_path" >&2
  exit 1
fi

changelog_section="$(
  python3 - "$changelog_path" "$version" <<'PY'
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
version = sys.argv[2]
text = path.read_text(encoding="utf-8")
pattern = re.compile(
    rf"^##\s+v?{re.escape(version)}\s*$\n(.*?)(?=^##\s+|\Z)",
    re.MULTILINE | re.DOTALL,
)
match = pattern.search(text)
if not match:
    sys.exit(1)
section = match.group(1).strip()
sys.stdout.write(section)
PY
)" || {
  python3 Scripts/update_changelog.py \
    --version "$version" \
    --from-ref "$previous_tag" \
    --to-ref "$tag" \
    --mode body
}

repo_url="https://github.com/${GITHUB_REPOSITORY}"
download_base="${repo_url}/releases/download/${tag}"

cat >"$output_path" <<EOF
## 更新内容

${changelog_section}

### 📥 下载地址

- 当前发布仅提供无内核安装包。
- 首次启动后，可在 CatBar 设置页打开内核目录并放入 \`mihomo\`。

| 平台架构 | 无内核安装包 |
| :--- | :--- |
| Apple Silicon (arm64) | [CatBar-${version}-apple-silicon-no-core.dmg](${download_base}/CatBar-${version}-apple-silicon-no-core.dmg) |
| Intel (x86_64) | [CatBar-${version}-intel-no-core.dmg](${download_base}/CatBar-${version}-intel-no-core.dmg) |

EOF
