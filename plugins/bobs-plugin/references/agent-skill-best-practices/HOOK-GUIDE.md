# 훅 작성 가이드 v2

생성: 2026-05-16
상위 원칙: `CONSTITUTION.md`
성격: 훅 설계와 등록을 위한 타입별 실무 가이드

이 문서는 `CONSTITUTION.md` 의 공통 원칙을 훅에 적용하는 방법을 설명한다. 훅은 runtime event 에 자동 반응하는 deterministic guardrail 이다.

---

## 1. 훅의 역할

훅은 판단보다 보장에 적합하다.

훅에 적합한 것:
- 특정 tool/event 마다 자동 실행되어야 하는 작업
- formatter, linter, typecheck 처럼 결정론적인 작업
- 민감 파일, lockfile, destructive command 차단
- 짧은 routing hint 또는 session context 주입
- notification, logging, audit 처럼 사용자가 매번 요청하지 않아도 되는 작업

훅에 부적합한 것:
- 자연어 판단, trade-off, 설계 선택
- 오래 걸리는 분석
- 사용자 몰래 외부로 데이터를 보내는 작업
- 한 훅이 formatter, blocker, logger 를 모두 수행하는 mixed responsibility
- false positive 가 많아 사용자의 작업 흐름을 자주 막는 작업

---

## 2. Hook vs Skill vs Agent

| 필요 | 선택 |
|---|---|
| 매 이벤트마다 자동 보장 | 훅 |
| 파일 수정 전 차단 | PreToolUse 훅 |
| 파일 수정 후 포맷·검증 | PostToolUse 훅 |
| 반복 가능한 판단 절차 | 스킬 |
| 별도 컨텍스트 specialist 분석 | 에이전트 |
| 프로젝트 고유 규칙 | CLAUDE.md |

간단한 기준:
- 보장이 필요하면 훅.
- 방법론이 필요하면 스킬.
- 역할 분리가 필요하면 에이전트.
- 프로젝트 memory 가 필요하면 CLAUDE.md.

---

## 3. Registration And Placement

훅은 설정에 등록되어야 실행된다. 스크립트 파일만 만들어두면 작동하지 않는다.

일반 위치:

```text
~/.claude/settings.json          # user scope
<project>/.claude/settings.json  # project scope
~/.claude/hooks/*.sh             # user scope scripts
<project>/.claude/hooks/*.sh     # project scope scripts
```

원칙:
- 개인 workflow 는 user scope 에 둔다.
- 팀이 공유해야 하는 guardrail 은 project scope 에 둔다.
- 긴 command 는 settings 에 inline 하기보다 script 파일로 분리한다.
- script 는 review 대상이며 실행 가능해야 한다.
- settings 와 script 를 함께 관리한다.

버전과 runtime 에 따라 설정 schema, event 이름, merge precedence 가 달라질 수 있다. 구현 시점의 로컬 환경 또는 공식 문서를 확인한다.

---

## 4. Event 선택

이 문서는 참고 자료에 반복 등장하는 이벤트를 중심으로 설명한다. 더 구체적인 이벤트는 사용 중인 runtime 문서를 확인한다.

| 이벤트 | 시점 | 적합한 작업 |
|---|---|---|
| `PreToolUse` | tool 실행 전 | 위험 작업 차단, 민감 파일 보호 |
| `PostToolUse` | tool 실행 후 | formatter, linter, related validation, logging |
| `UserPromptSubmit` | 사용자 prompt 제출 시 | 짧은 routing hint, context 주입 |
| `SessionStart` | session 시작 시 | cwd/project summary, 활성 자원 hint |
| `Notification` | notification 발생 시 | permission/idle 알림, 외부 알림 |

선택 기준:
- 차단이 목적이면 `PreToolUse`.
- 수정 후 정리나 best-effort 검증이면 `PostToolUse`.
- prompt 해석을 돕는 짧은 context 면 `UserPromptSubmit`.
- 세션 전체에 필요한 context 면 `SessionStart`.
- 사람에게 알려야 하는 이벤트면 `Notification`.

---

## 5. Matcher 설계

matcher 는 훅이 반응할 tool/event 범위를 제한한다.

예시:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/format-on-edit.sh" }
        ]
      }
    ]
  }
}
```

원칙:
- 가능한 좁게 잡는다.
- `Edit|Write` 처럼 의도된 tool 만 대상으로 한다.
- formatter, blocker, logger 를 한 matcher/script 에 섞지 않는다.
- matcher 없는 전역 훅은 비용과 부작용을 설명할 수 있을 때만 사용한다.
- path filtering 은 script 안에서 한 번 더 한다.

---

## 6. Input Handling

훅은 runtime 이 넘겨주는 JSON 또는 환경 값을 읽는다. schema 는 버전 영향을 받을 수 있으므로 방어적으로 처리한다.

원칙:
- 필요한 field 만 읽는다.
- 없는 field 는 no-op 으로 처리한다.
- file path 는 quote 한다.
- shell interpolation 을 최소화한다.
- JSON 은 가능하면 `jq` 로 파싱한다.
- hook input 전체를 외부로 보내지 않는다.

예시:

```bash
#!/usr/bin/env bash
set -u

file_path="$(jq -r '.tool_input.file_path // empty')"
[[ -z "$file_path" ]] && exit 0

case "$file_path" in
  *.ts|*.tsx) ;; 
  *) exit 0 ;;
esac
```

---

## 7. Exit Behavior

훅은 사용자 workflow 에 직접 영향을 준다. 실패 정책을 먼저 정한다.

| 목적 | 권장 동작 |
|---|---|
| 포맷, 로깅, 알림, best-effort 검증 | 사용자 작업을 막지 않는다 |
| 위험 작업 차단 | 명확한 non-zero 차단과 짧은 stderr 이유 |
| script 내부 오류 | 가능하면 사용자 작업을 막지 않고 로그 |

원칙:
- `PostToolUse` 는 기본적으로 차단하지 않는다.
- `PreToolUse` 에서 차단이 목적일 때만 non-zero 를 사용한다.
- 차단 메시지는 짧고 구체적으로 쓴다.
- formatter 실패 때문에 편집 자체가 실패한 것처럼 보이게 만들지 않는다.

구체적인 exit code semantics 는 runtime 버전에 따라 다를 수 있다. 참고 자료에서 `exit 2` 를 차단용으로 쓰는 패턴이 있지만, 구현 시점의 환경에서 확인한다.

---

## 8. Security

훅은 자동 실행되므로 보수적으로 작성한다.

필수 원칙:
- 민감 파일 차단은 정확한 path/pattern 으로 한다.
- 외부 전송은 명시적으로 필요한 경우에만 한다.
- prompt, secret, file content 를 외부로 보내지 않는다.
- hook script 변경도 code review 대상이다.
- pattern 기반 차단은 defense-in-depth 로만 본다.

금지 또는 강한 주의:
- 사용자 몰래 데이터 송신
- `curl | sh`, `wget | bash` 같은 원격 스크립트 실행
- broad `rm`, `sudo`, `chmod 777`, `git reset --hard`, `git clean -f`, `git push --force` 자동 승인
- `.env`, credentials, `.git/` 직접 수정
- lockfile 직접 편집 허용
- long-running network 작업을 동기 hook 으로 실행

보안 훅은 완전한 보안 경계가 아니다. 최소 권한, code review, 명시적 승인과 함께 써야 한다.

---

## 9. Performance

훅은 자주 실행될 수 있다. 느린 훅은 전체 개발 흐름을 느리게 만든다.

권장:
- 빠른 조기 return 을 둔다.
- 변경된 파일 하나만 처리한다.
- heavy validation 은 비동기, background, queue 로 분리한다.
- full test suite 대신 related test 를 실행한다.
- network 호출은 피하거나 명시적으로 opt-in 한다.

피해야 할 것:
- 모든 Edit 후 전체 repo typecheck
- 모든 Write 후 full test suite
- 매 prompt 마다 긴 프로젝트 분석
- 네트워크 호출이 필수인 동기 hook

성능 수치는 환경마다 다르므로 hard rule 이 아니다. 중요한 것은 빈번한 event 에 걸리는 작업이 사용자 흐름을 방해하지 않는 것이다.

---

## 10. Common Patterns

### 10.1 Formatter

적합 이벤트: `PostToolUse`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/format-on-edit.sh" }
        ]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
set -u

file_path="$(jq -r '.tool_input.file_path // empty')"
[[ -z "$file_path" ]] && exit 0

case "$file_path" in
  *.js|*.jsx|*.ts|*.tsx|*.json)
    npx --yes prettier --write "$file_path" >/dev/null 2>&1 || true ;;
  *.py)
    ruff format "$file_path" >/dev/null 2>&1 || true ;;
  *.go)
    gofmt -w "$file_path" >/dev/null 2>&1 || true ;;
esac

exit 0
```

### 10.2 Sensitive File Blocker

적합 이벤트: `PreToolUse`

```bash
#!/usr/bin/env bash
set -u

file_path="$(jq -r '.tool_input.file_path // empty')"
[[ -z "$file_path" ]] && exit 0

case "$file_path" in
  */.env|*/.env.*|*/credentials.json|*/secrets.yaml|*/id_rsa|*/*.pem|*/.git/*)
    echo "Blocked: protected file path: $file_path" >&2
    exit 2 ;;
esac

exit 0
```

### 10.3 Lockfile Blocker

적합 이벤트: `PreToolUse`

```bash
#!/usr/bin/env bash
set -u

file_path="$(jq -r '.tool_input.file_path // empty')"
[[ -z "$file_path" ]] && exit 0

case "$file_path" in
  */package-lock.json|*/yarn.lock|*/pnpm-lock.yaml|*/Cargo.lock|*/poetry.lock|*/Pipfile.lock)
    echo "Blocked: lock files should change through the package manager: $file_path" >&2
    exit 2 ;;
esac

exit 0
```

### 10.4 Routing Hint

적합 이벤트: `UserPromptSubmit`

```bash
#!/usr/bin/env bash
set -u

prompt="$(jq -r '.prompt // empty')"
hint=""

case "$prompt" in
  *review*|*리뷰*)
    hint="Hint: a review skill or reviewer agent may be relevant." ;;
  *hook*|*훅*)
    hint="Hint: use hook guidance for deterministic event automation." ;;
esac

[[ -z "$hint" ]] && { echo '{}'; exit 0; }

jq -n --arg c "$hint" \
  '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$c}}'
exit 0
```

주의: routing hint 는 짧아야 한다. 긴 자원 목록 전체를 매 prompt 에 주입하면 context 비용이 커진다.

### 10.5 Auto-Loop Trigger (자기 재호출)

`Stop` 훅이 session 종료를 막고 동일 prompt 를 재주입하는 패턴은 모델 비용, 시간, side-effect 누적이 빠르게 커지므로 위험 카테고리다. 사용하려면 다층 gate 가 필요하다.

필수 안전 요건:

- **Explicit opt-in**: 외부 state file/환경변수가 있어야만 발동. 기본은 no-op exit 0.
- **Iteration cap**: 최대 횟수를 사전 설정하고 도달 시 자동 정리.
- **Completion gate**: 모델이 명시적으로 종료 신호(예: `<promise>` tag)를 낼 때 정리.
- **Visibility**: 매 반복마다 사용자가 진행 상황을 볼 수 있는 system message.
- **Stop path**: 사용자가 한 번에 멈출 수 있는 절차가 README 에 명시되어야 한다.

이 패턴은 권장이 아니라 예외 디자인이다. 위 요건 중 하나라도 빠지면 destructive automation 으로 분류한다.

### 10.6 Session-Scoped State Files

훅이 dedup, rate-limit, iteration count 같은 상태를 디스크에 남길 때 lifecycle 을 결정론적으로 정의한다.

권장:

- 위치는 user scope(`~/.claude/...` 또는 `XDG_STATE_HOME`) 로 한정한다. `/tmp` 공유 경로는 피한다.
- session 별 별도 파일을 만들기보다 단일 store(JSON/SQLite)에 session_id 를 key 로 둔다.
- 확률적 cleanup 대신 SessionEnd 훅, max-age, max-entry 같은 명시적 trigger 를 둔다.
- state 파일 경로는 hook input 의 `cwd` 또는 absolute path 로 도출한다. 현재 작업 디렉토리에 상대 의존하지 않는다.

state 가 누적되면 디스크 비용과 디버깅 비용이 모두 커진다.

---

## 11. Detection To Recommendation

| 감지 신호 | 추천 훅 |
|---|---|
| `.prettierrc`, `prettier.config.js` | `PostToolUse(Edit|Write)` formatter |
| `eslint.config.js`, `.eslintrc` | `PostToolUse(Edit|Write)` lint/fix |
| `ruff.toml`, `[tool.ruff]` | Python format/lint |
| `go.mod` | gofmt |
| `Cargo.toml` | rustfmt |
| `tsconfig.json` | related TypeScript check |
| `tests/`, `*.test.*`, `pytest.ini` | related test runner |
| `.env`, `credentials.json`, `.git/` | `PreToolUse(Edit|Write)` sensitive file block |
| lockfiles | `PreToolUse(Edit|Write)` lockfile block |
| multitasking workflow | `Notification` alert |

추천은 시작점일 뿐이다. 실제 matcher, script, exit behavior 는 프로젝트 위험도와 runtime 에 맞게 조정한다.

---

## 12. Checklist

작성 전:
- [ ] 자연어 판단이 아니라 deterministic automation 인가?
- [ ] 스킬이나 에이전트보다 훅이 맞는 이유가 있는가?
- [ ] event 와 matcher 를 좁힐 수 있는가?
- [ ] 실패 시 사용자 작업을 막아야 하는가?

설정:
- [ ] settings 의 hooks 절에 등록했는가?
- [ ] matcher 가 정확한 tool/event 로 제한되어 있는가?
- [ ] script path 가 존재하고 실행 가능한가?
- [ ] user scope 와 project scope 중 올바른 위치인가?

스크립트:
- [ ] hook input 에서 필요한 field 만 읽는가?
- [ ] 없는 field 를 안전하게 처리하는가?
- [ ] path 와 shell argument 를 quote 하는가?
- [ ] best-effort 작업은 차단하지 않는가?
- [ ] 차단 목적이면 짧은 이유를 출력하는가?
- [ ] long-running 작업이나 숨은 network 전송이 없는가?

운영:
- [ ] hook 변경도 review 대상인가?
- [ ] false positive 발생 시 수정 절차가 있는가?
- [ ] 호출 빈도와 지연을 관찰할 수 있는가?
- [ ] 프로젝트별 도구가 없을 때 조용히 no-op 되는가?

---

## 13. Anti-Patterns

| Anti-pattern | 증상 | 수정 |
|---|---|---|
| Script-only hook | 스크립트만 있고 settings 등록 없음 | settings 에 등록 |
| Broad matcher | 모든 tool/event 에서 실행 | matcher 축소 |
| Blocking formatter | 포맷 실패가 작업 차단 | best-effort 로 전환 |
| Long-running hook | 매 edit 마다 오래 걸림 | async/background/related-file 로 분리 |
| Hidden exfiltration | prompt/file 내용 외부 전송 | 제거하거나 명시 승인 |
| Regex as security boundary | pattern 차단만 믿음 | 최소 권한과 review 병행 |
| Hook-as-agent | 복잡한 자연어 분석 수행 | 에이전트로 이동 |
| Hook-as-skill | 판단 workflow 를 shell 로 구현 | 스킬로 이동 |
| Mixed responsibility | formatter, blocker, logger 한 파일에 섞임 | 훅을 역할별로 분리 |
| Version lock-in | runtime schema 를 단정 | 구현 시점 문서 확인 |
| Advisory hook configured as blocker | reminder/notice 성격인데 차단 exit 로 사용자 작업을 막음 | 기본은 stderr + exit 0, 차단은 별도 환경변수 opt-in |
| Substring rule as hard block | 단순 substring 매칭을 보안 차단 근거로 사용 | advisory 톤으로 강등하거나 AST/reviewer 자산으로 이동 |
| Unbounded auto-loop | Stop/Notification 훅이 opt-in·cap·completion gate 없이 자기 재호출 | §10.5 안전 요건 모두 충족 또는 제거 |
| Scattered session state | session 별 별도 파일이 cleanup 없이 누적 | 단일 store + 명시적 lifecycle, §10.6 참고 |

---

## 14. Version-Sensitive Details

다음 항목은 이 가이드에서 원칙만 둔다. 구현 시점의 runtime 문서를 확인한다.

- 정확한 hook JSON schema
- event 별 exit code semantics
- async 실행 지원 여부
- user/project scope merge precedence
- Notification matcher 목록
- `hookSpecificOutput` schema 및 `additional_context` vs `additionalContext` 같은 runtime 별 key 명명
- `Stop` 훅의 `decision`/`reason`/`systemMessage` 필드와 block 동작
- `PreToolUse` 차단 exit code 의 정확한 의미

이런 항목을 코드에 가정으로 박을 때는 `# verified against: <runtime> <version>` 같은 주석을 함께 둔다.
