#!/bin/bash
 
echo -e "\033[0;32mDeploying updates to GitHub***\033[0m"
 
# 1) content: 브랜치 위에 있고, 커밋·푸시까지 끝났는지 검사만 한다
if [ "$(git -C content branch --show-current)" != "content" ]; then
  echo "content가 content 브랜치 위에 있지 않습니다(분리된 HEAD?). 중단합니다." >&2; exit 1
fi
if [ -n "$(git -C content status --porcelain)" ]; then
  echo "content에 커밋하지 않은 변경이 있습니다. 중단합니다." >&2; exit 1
fi
git -C content fetch origin
if [ "$(git -C content rev-parse HEAD)" != "$(git -C content rev-parse origin/content)" ]; then
  echo "content가 origin/content와 다릅니다(푸시 누락?). 중단합니다." >&2; exit 1
fi

# 2) public: 항상 origin/source 위의 브랜치로 맞춘다
git -C public fetch origin
git -C public checkout -B source origin/source

# 3) 빌드
hugo -t nuno --gc


# `source` 브랜치로 이동
cd public
git add .
 
# 인자가 없을 경우 현재 시간을 커밋 메시지로 등록
msg="rebuild: $(date +"%Y-%m-%dT%H:%M:%S%z")"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg" || echo "public: 변경 없음"
 
# 빌드 결과를 `source` 브랜치에 반영
git push origin source
 
# `main` 브랜치로 이동
cd ..
 
# 현재까지의 변경사항을 `main` 브랜치에 반영
git add .
git commit -m "$msg" || echo "root: 변경 없음"
git push origin main
