# 훅 작성 가이드

생성: 2026-05-16
상위 원칙: `CONSTITUTION.md`
근거 자료: `SIGNALS.md`, `GUIDE.md` 의 훅 섹션, `skills/claude-automation-recommender/references/hooks-patterns.md`, `agent-configuration`

이 문서는 Claude Code 훅을 설계하고 등록할 때 쓰는 실무 가이드다. 훅은 스킬이나 에이전트와 달리 모델의 판단이 아니라 runtime event 에 의해 자동 실행된다.

---

## 1. 훅을 만들 때

훅은 판단보다 보장에 적합하다.

만들어도 좋은 경우:
- 특정 tool event 마다 자동으로 실행되어야 한다.
- formatter, linter, typechecker 처럼 결과가 결정론적이다.
- 민감 파일, lockfile, destructive command 를 차단해야 한다.
- 사용자 prompt 나 session 시작 시 짧은 routing context 를 주입해야 한다.
- notification, logging, audit 처럼 사용자가 직접 매번 요청하지 않아도 되는 작업이다.

만들지 말아야 하는 경우:
- 자연어 판단, trade-off, 설계 선택이 필요하다. 이 경우 스킬이나 에이전트가 낫다.
- 오래 걸리는 분석을 매 tool call 마다 실행해야 한다.
- 사용자 몰래 외부로 데이터를 보내야 한다.
- hook 하나가 여러 책임을 동시에 가진다.
- 실패가 사용자의 작업 흐름을 불필요하게 막는다.

---

## 2. Hook vs Skill vs Agent

| 필요 | 선택 |
|---|---|
| 매 이벤트마다 자동 실행 | 훅 |
| 파일 수정 전 차단 | PreToolUse 훅 |
| 파일 수정 후 포맷·검증 | PostToolUse 훅 |
| 반복 가능한 판단 절차 | 스킬 |
| 별도 컨텍스트 specialist 분석 | 에이전트 |
| 프로젝트 고유 규칙 | CLAUDE.md |

간단한 기준:
- **보장**이 필요하면 훅.
- **방법론**이 필요하면 스킬.
- **역할 분리**가 필요하면 에이전트.

---

## 3. 배치와 등록

훅은 `settings.json` 의 `hooks` 절에 등록되어야 실행된다. 스크립트 파일만 만들어두면 작동하지 않는다.

일반 위치:

```text
~/.claude/settings.json          # 유저 스코프
<project>/.claude/settings.json  # 프로젝트 스코프
~/.claude/hooks/*.sh             # 유저 스코프 스크립트 예시
<project>/.claude/hooks/*.sh     # 프로젝트 스코프 스크립트 예시
```

원칙:
- 개인 workflow 는 유저 스코프에 둔다.
- 팀이 공유해야 하는 guardrail 은 프로젝트 스코프에 둔다.
- 스크립트는 설정 파일에서 직접 inline 으로 길게 쓰기보다 별도 파일로 둔다.
- hook script 는 실행 가능해야 한다.
- settings 와 script 둘 다 review 대상이다.

---

## 4. 이벤트 선택

이 문서에서는 현재 참고 자료에 반복 등장하는 이벤트만 다룬다. 추가 이벤트는 사용 중인 Claude Code 버전의 공식 문서를 확인한 뒤 사용한다.

| 이벤트 | 시점 | 적합한 작업 |
|---|---|---|
| `PreToolUse` | tool 실행 전 | 위험 작업 차단, 민감 파일 보호 |
| `PostToolUse` | tool 실행 후 | formatter, linter, typecheck, logging |
| `UserPromptSubmit` | 사용자 prompt 제출 시 | 짧은 routing hint, context 주입 |
| `SessionStart` | session 시작 시 | cwd/project 요약, 활성 자원 힌트 |
| `Notification` | notification 발생 시 | permission/idle 알림, 외부 알림 |

선택 기준:
- 차단이 목적이면 `PreToolUse`.
- 수정 후 정리나 검증이면 `PostToolUse`.
- prompt 해석을 돕는 1줄 context 면 `UserPromptSubmit`.
- session 전체에 필요한 context 면 `SessionStart`.
- 사람에게 알려야 하는 이벤트면 `Notification`.

---

## 5. Matcher 설계

`matcher` 는 훅이 어떤 tool/event 에 반응할지 제한한다.

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
- 포맷터와 보안 차단을 같은 hook 에 섞지 않는다.
- matcher 없는 전역 훅은 비용과 부작용을 설명할 수 있을 때만 사용한다.

---

## 6. Exit Code 정책

훅은 사용자 workflow 에 직접 영향을 준다. 실패 정책을 먼저 정해야 한다.

| 목적 | 권장 exit |
|---|---|
| 포맷, 로깅, 알림, best-effort 검증 | `exit 0` |
| 위험 작업 차단 | 차단용 non-zero exit. 기존 참고 자료는 `exit 2` 를 사용 |
| 스크립트 내부 오류 | 가능하면 사용자 작업을 막지 말고 `exit 0` + 로그 |

원칙:
- `PostToolUse` 는 기본적으로 사용자 작업을 차단하지 않는다.
- `PreToolUse` 에서 차단이 목적일 때만 non-zero 를 사용한다.
- 차단 시 stderr 에 짧고 구체적인 이유를 출력한다.
- 실패한 formatter 때문에 편집 자체가 실패한 것처럼 보이게 만들지 않는다.

---

## 7. 보안 원칙

훅은 자동 실행되므로 보수적으로 작성한다.

MUST:
- 민감 파일 차단은 정확한 path/pattern 으로 한다.
- 외부 전송은 명시적으로 필요한 경우에만 한다.
- secret, prompt, file content 를 외부로 보내지 않는다.
- destructive command 차단은 defense-in-depth 로 본다.
- hook script 변경도 코드 리뷰 대상이다.

MUST NOT:
- 사용자 몰래 데이터 송신
- `curl | sh`, `wget | bash` 같은 원격 스크립트 실행
- broad `rm`, `sudo`, `chmod 777`, `git reset --hard`, `git clean -f`, `git push --force` 자동 승인
- lockfile, `.git/`, `.env` 류를 광범위하게 직접 수정
- long-running network 작업을 동기 hook 으로 실행

주의:
- pattern 기반 차단은 완전한 보안 경계가 아니다.
- 우회 가능성을 전제로 최소 권한, 코드 리뷰, 명시적 승인과 함께 써야 한다.

---

## 8. 성능 원칙

훅은 자주 실행될 수 있다. 느린 훅은 전체 개발 흐름을 느리게 만든다.

권장:
- 1회 실행은 500 ms 안쪽을 목표로 한다.
- 무거운 검증은 비동기, background, queue 로 분리한다.
- 변경된 파일 하나만 처리한다.
- full test suite 는 직접 실행하지 말고 관련 테스트만 실행한다.
- 중복 실행을 피하기 위해 파일 확장자와 tool name 으로 조기 return 한다.

피해야 할 것:
- 모든 Edit 후 전체 repo typecheck
- 모든 Write 후 full test suite
- 매 prompt 마다 긴 프로젝트 분석
- 네트워크 호출이 필수인 hook

---

## 9. 대표 패턴

### 9.1 Formatter

적합 이벤트: `PostToolUse`

추천 감지 신호:
- Prettier config
- ESLint config
- `pyproject.toml` with ruff/black
- `go.mod`
- `Cargo.toml`

예시 설정:

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

예시 스크립트:

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

### 9.2 Sensitive File Blocker

적합 이벤트: `PreToolUse`

예시 설정:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/block-sensitive.sh" }
        ]
      }
    ]
  }
}
```

예시 스크립트:

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

### 9.3 Lockfile Blocker

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

### 9.4 Routing Hint

적합 이벤트: `UserPromptSubmit`

목적은 짧은 context 를 추가하는 것이다. 긴 분석이나 자원 목록 전체 주입은 피한다.

```bash
#!/usr/bin/env bash
set -u

prompt="$(jq -r '.prompt // empty')"
hint=""

case "$prompt" in
  *review*|*리뷰*)
    hint="Hint: code-review skill or reviewer agent may be relevant." ;;
  *hook*|*훅*)
    hint="Hint: use hook guidance for deterministic event automation." ;;
esac

[[ -z "$hint" ]] && { echo '{}'; exit 0; }

jq -n --arg c "$hint" \
  '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$c}}'
exit 0
```

### 9.5 Notification

적합 이벤트: `Notification`

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Ping.aiff"
          }
        ]
      }
    ]
  }
}
```

주의: notification hook 은 편의 기능이다. 보안 결정을 자동 승인하는 용도로 쓰지 않는다.

---

## 10. Detection → Recommendation

| 감지 신호 | 추천 훅 |
|---|---|
| `.prettierrc`, `prettier.config.js` | `PostToolUse(Edit|Write)` formatter |
| `eslint.config.js`, `.eslintrc` | `PostToolUse(Edit|Write)` lint/fix |
| `ruff.toml`, `[tool.ruff]` | Python format/lint |
| `go.mod` | gofmt |
| `Cargo.toml` | rustfmt |
| `tsconfig.json` | TypeScript typecheck |
| `tests/`, `*.test.*`, `pytest.ini` | related test runner |
| `.env`, `credentials.json`, `.git/` | `PreToolUse(Edit|Write)` sensitive file block |
| lockfiles | `PreToolUse(Edit|Write)` lockfile block |
| multitasking workflow | `Notification` alert |

---

## 11. 체크리스트

작성 전:
- [ ] 이 작업은 자연어 판단이 아니라 결정론적 자동화인가?
- [ ] 스킬이나 에이전트보다 훅이 맞는 이유가 있는가?
- [ ] event 와 matcher 를 좁힐 수 있는가?
- [ ] 실패 시 사용자 작업을 막아야 하는가?

설정:
- [ ] `settings.json` 의 `hooks` 절에 등록했는가?
- [ ] matcher 가 정확한 tool/event 로 한정되어 있는가?
- [ ] script path 가 존재하고 실행 가능한가?
- [ ] user scope 와 project scope 중 올바른 위치에 두었는가?

스크립트:
- [ ] stdin/hook JSON 에서 필요한 필드만 읽는가?
- [ ] 없는 필드는 안전하게 처리하는가?
- [ ] best-effort 작업은 `exit 0` 하는가?
- [ ] 차단 목적이면 stderr 에 이유를 출력하는가?
- [ ] long-running 작업이 없는가?
- [ ] 외부 데이터 송신이 없는가?

운영:
- [ ] hook 변경도 review 대상인가?
- [ ] false positive 발생 시 우회/수정 절차가 있는가?
- [ ] 호출 빈도와 지연을 관찰할 방법이 있는가?
- [ ] 프로젝트별 도구가 없을 때 조용히 no-op 되는가?

---

## 12. 안티패턴

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Script-only hook | 스크립트만 있고 settings 등록 없음 | `settings.json` 에 등록 |
| Broad matcher | 모든 tool 에서 실행 | tool/event matcher 축소 |
| Blocking formatter | 포맷 실패가 작업 차단 | `PostToolUse` 에서는 `exit 0` |
| Long-running hook | 매 edit 마다 오래 걸림 | async/background/related-file 로 분리 |
| Hidden exfiltration | prompt/file 내용 외부 전송 | 제거하거나 명시 승인 |
| Regex as security boundary | pattern 차단만 믿음 | 최소 권한과 review 병행 |
| Hook-as-agent | 복잡한 자연어 분석 수행 | 에이전트로 이동 |
| Hook-as-skill | 판단 workflow 를 shell 로 구현 | 스킬로 이동 |
| Mixed responsibility | formatter, blocker, logger 한 파일에 섞임 | 훅을 역할별로 분리 |

---

## 13. 보류: 더 구체화할 항목

다음 항목은 현재 문서에 원칙만 두고, 실제 구현 시 사용하는 Claude Code 버전과 팀 정책을 확인한다.

- 정확한 hook JSON schema
- event 별 exit code semantics
- async 실행 지원 여부와 설정 형식
- project scope 와 user scope 의 merge precedence
- Notification matcher 전체 목록

버전 영향을 받는 세부사항은 이 문서에 단정적으로 박기보다, 구현 시점의 공식 문서와 로컬 설정으로 확인한다.
