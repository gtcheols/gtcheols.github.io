#!/bin/bash
 
echo -e "\033[0;32mDeploying updates to GitHub***\033[0m"
 

# public, content만 최신화한다. 테마는 태그로 고정해 두었으므로 제외
git submodule update --remote -- public content

# public을 분리된 HEAD가 아니라 source 브랜치 위에 올려둔다
git -C public checkout -B source origin/source

 
# `hugo -t <테마명>` 명령어로 Hugo 정적 페이지 렌더링
# `--gc` 옵션은 `garbage collection` 을 의미하며 불필요한 페이지를 삭제
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
