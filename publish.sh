#!/bin/bash
set -e
cd "$(dirname "$0")"

# content가 브랜치 위에 있는지 확인 (분리된 HEAD에서의 커밋 방지)
if [ "$(git -C content branch --show-current)" != "content" ]; then
  echo "content가 content 브랜치 위에 있지 않습니다. 중단합니다." >&2
  exit 1
fi

msg="update: $(date +"%Y-%m-%d %H:%M")"
if [ $# -ge 1 ]; then msg="update: $*"; fi

# 변경이 있을 때만 커밋
git -C content add -A
if git -C content diff --cached --quiet; then
  echo "content: 변경 없음 (커밋 생략)"
else
  git -C content status -s
  git -C content commit -m "$msg"
fi

git -C content push origin content

./deploy.sh "$msg"

