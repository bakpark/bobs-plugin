# 런타임 정책 가이드 v2.1

생성: 2026-05-17
상위 원칙: `CONSTITUTION.md`
성격: settings, permissions, MCP, memory, model, session/context 정책을 위한 실무 가이드

이 문서는 `CONSTITUTION.md` 의 공통 원칙을 런타임 설정에 적용하는 방법을 설명한다. 런타임 정책은 agent 가 실제로 무엇을 할 수 있는지 정하는 공유 인프라다.

---

## 1. 런타임 정책의 역할

런타임 정책은 자연어 지침이 아니라 실행 환경의 상한선이다.

런타임 정책에 적합한 것:
- tool permission allow/ask/deny
- model, effort, max turns, budget
- MCP server 등록과 tool loading
- memory scope 와 state lifecycle
- hook 등록과 event schema
- auto mode, background task, sandbox, approval 정책
- session/context 운영 규칙

런타임 정책에 부적합한 것:
- 도메인 지식 전체
- 긴 workflow 설명
- 프로젝트별 coding convention 의 장문 복사
- 자연어 판단이 필요한 리뷰 기준
- 일회성 작업 기록

원칙은 간단하다. **반드시 막아야 하는 일은 프롬프트가 아니라 설정이나 훅으로 막고, 반드시 사람이 알아야 하는 일은 output contract 로 드러낸다.**

---

## 2. Permission Policy

권한 정책은 capability surface 의 최상위 계층이다.

기본 방향:
- `deny` 또는 block 계층이 `allow` 보다 우선한다.
- allow 는 broad family 가 아니라 안전한 subcommand 단위로 좁힌다.
- ask 는 위험하지만 가끔 필요한 작업에 둔다.
- bypass, auto approval, broad wildcard 는 예외로 취급한다.

권장 예:

```json
{
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(npm test *)"
    ],
    "ask": [
      "Bash(npm install *)",
      "Bash(docker *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git reset --hard *)",
      "Bash(git push --force *)"
    ]
  }
}
```

주의:
- `Bash(git *)` 는 `git reset --hard`, `git clean -f`, force push 를 포함할 수 있다.
- `mcp__server__*` 는 서버의 모든 도구를 허용할 수 있다.
- `Write(*)`, `Edit(*)`, `Bash(*)`, broad network 는 project scope 에서 기본값이 되면 안 된다.
- auto approval classifier 는 policy, audit log, fail-closed, user opt-in 없이는 사용하지 않는다.

---

## 3. Settings Scope

설정은 공유성과 민감도에 따라 위치를 나눈다.

| 범위 | 넣을 것 | 넣지 말 것 |
|---|---|---|
| user/global | 개인 선호, 개인 credential, cross-project memory | 팀 공통 guardrail |
| project | 팀이 공유해야 하는 safe defaults, hooks, docs routing | secret, 개인 token, local path |
| local/ignored | 개인 실험, 임시 auto mode, 개인 audit log | 팀 필수 정책 |
| managed/enterprise | 조직 보안 정책 | 프로젝트별 편의 설정 |

원칙:
- 팀이 복제해야 하는 정책만 project scope 에 둔다.
- personal preference 와 credential 은 project scope 에 두지 않는다.
- project settings 에 auto mode 나 broad permission 을 공유하지 않는다.
- 설정 파일 자체도 review 대상이다.

---

## 4. Memory And State

memory 는 지식의 소유자와 수명에 맞춰 둔다.

| 종류 | 용도 | 주의 |
|---|---|---|
| `CLAUDE.md` / `AGENTS.md` | 작업 시 자주 필요한 공통 운영 규칙 | 짧게 유지하고 긴 지식은 docs 로 이동 |
| project docs | 팀 공유 도메인 지식과 결정 근거 | 인덱스와 freshness 필요 |
| agent memory | 특정 agent 역할의 반복 학습 | scope, owner, cleanup 필요 |
| local memory | 개인 작업 선호나 실험 | git ignore |
| plugin data | plugin/skill 의 안정적 mutable data | skill directory 삭제/업데이트와 분리 |

원칙:
- reusable skill/agent body 에 project history 를 하드코딩하지 않는다.
- agent memory 는 agent 의 책임 범위 안에서만 읽고 쓴다.
- shared memory 는 팀이 검토 가능한 형식이어야 한다.
- mutable state 는 위치, key, cleanup trigger, max age 를 정의한다.
- memory 에 secret 을 저장하지 않는다.

---

## 5. MCP And Tool Loading

MCP 와 tool 목록도 context 와 권한 비용을 만든다.

원칙:
- 자주 쓰는 소수 tool 만 항상 노출하고, 드문 tool 은 검색/지연 로딩을 고려한다.
- MCP server 는 출처, 설치 방식, 권한, network/data access 를 문서화한다.
- project scope MCP 는 팀이 재현 가능한 방식으로 설치되어야 한다.
- `npx` 로 매번 원격 package 를 실행하는 방식은 공급망 위험을 검토한다.
- tool 설명이 많아 context 를 압도하면 tool search 또는 role-specific agent 로 분리한다.

MCP 를 추가할 때 기록할 것:
- server name
- source/package
- allowed tools 또는 exposed capability
- credentials 위치
- project/user scope
- failure/no-op behavior

---

## 6. Model, Effort, Budget

모델과 effort 는 품질 선택이면서 비용 선택이다.

원칙:
- 기본 모델은 작업 복잡도와 latency 에 맞춘다.
- 비싼 모델은 정밀도, 장기 계획, 복잡한 migration 등 이유가 있을 때만 선택한다.
- `inherit` 은 명시적 선택으로 취급한다.
- background task, loop, long-running agent 는 max turns, budget, stop path 를 가져야 한다.
- 예산 제한이나 rate limit 이 사용자 workflow 에 영향을 주면 output 에 드러낸다.

자산 검토 시 model 관련 GAP:
- 모든 agent 가 이유 없이 최고 비용 모델을 쓴다.
- 단순 command 가 과한 effort 를 요구한다.
- long-running workflow 에 cap 이 없다.
- budget 초과 시 failure behavior 가 없다.

---

## 7. Session And Context Lifecycle

세션은 작업 품질에 영향을 주는 runtime 자원이다.

판단표:

| 상황 | 선택 |
|---|---|
| 같은 작업이고 기존 맥락이 여전히 유효 | Continue |
| 잘못된 방향으로 진행했고 그 맥락이 해롭다 | Rewind |
| 같은 작업이지만 context 가 커졌고 핵심 요약이 가능 | Compact with hint |
| 완전히 새로운 작업 | Clear / new session |
| 대량 탐색이나 출력이 필요하고 결론만 필요 | Subagent |

원칙:
- context 가 커졌다는 이유만으로 compact 하지 않는다. 무엇을 보존할지 hint 가 필요하다.
- 실패한 방향을 수정 prompt 로 계속 누적하기보다 rewind 를 고려한다.
- subagent 는 병렬성뿐 아니라 context 격리 장치다.
- main context 에는 결론, 결정, 파일 위치, 다음 행동만 남긴다.

---

## 8. Auto Mode And Background Work

자동 진행은 편리하지만 side effect 누적 위험이 크다.

필수 요건:
- explicit opt-in
- scope 제한
- iteration 또는 turn cap
- budget cap
- visible progress
- stop path
- final verification
- audit trail

다음은 기본 금지 또는 강한 주의다.
- project-shared auto mode 기본 활성화
- broad permission + background loop 조합
- Stop hook 자기 재호출을 숨은 기본값으로 사용
- permission request 자동 승인 classifier 를 감사 없이 적용
- commit/push/deploy 자동화

---

## 9. Version-Sensitive Runtime Claims

런타임 동작은 변한다. 다음 항목은 문서화할 때 검증 정보를 남긴다.

- settings schema
- permission precedence
- hook event 이름과 exit semantics
- skill/agent/command frontmatter 필드
- MCP server loading 과 tool search
- memory scope 와 injection behavior
- auto mode, sandbox, plan mode 동작
- SDK 와 CLI 의 system prompt 차이

권장 표기:

```text
verified: Claude Code <version or date>, checked 2026-05-17, source: <doc/path/url>
recheck when: runtime upgrade, settings schema change, hook failure
```

확인하지 못한 동작은 hard rule 로 쓰지 말고 `unknown` 또는 `implementation-time check required` 로 둔다.

---

## 10. Checklist

권한:
- [ ] allow 가 필요한 subcommand 로만 제한되는가?
- [ ] deny/block 계층이 destructive action 을 막는가?
- [ ] broad wildcard 의 이유와 보완 gate 가 있는가?

설정 범위:
- [ ] 개인 정보와 팀 공유 정책이 분리되는가?
- [ ] project settings 에 secret 이 없는가?
- [ ] auto mode 나 bypass 권한이 공유 기본값이 아닌가?

memory/state:
- [ ] memory scope 와 owner 가 명확한가?
- [ ] mutable state 위치와 cleanup 이 정의되는가?
- [ ] reusable asset 에 project history 가 섞이지 않는가?

MCP/tool:
- [ ] MCP 출처와 권한이 설명되는가?
- [ ] tool catalog 가 context 를 과하게 쓰지 않는가?
- [ ] infrequent tool 은 지연 로딩할 수 있는가?

session:
- [ ] continue/rewind/compact/clear/subagent 판단 기준이 있는가?
- [ ] long-running/background 작업에 cap 과 stop path 가 있는가?

freshness:
- [ ] version-sensitive claim 에 검증일/source 가 있는가?
- [ ] platform behavior 를 확인 없이 단정하지 않는가?

---

## 11. Anti-Patterns

| Anti-pattern | 증상 | 수정 |
|---|---|---|
| Prompt-as-permission | 자연어로 금지했지만 runtime 권한은 열려 있음 | permission/hook 으로 제한 |
| Broad allowlist | `Bash(*)`, `Write(*)`, `mcp__*` 공유 | safe subcommand, role-specific permission |
| Project-shared auto mode | 팀 설정에 자동 권한 상승 포함 | user/local opt-in 으로 이동 |
| Secret in project settings | token, credential, local path commit | user/local scope 로 이동 |
| Runtime drift | 오래된 schema 를 hard rule 로 문서화 | verified date/source 추가 |
| Context hoarding | 모든 docs/tools/memory 를 항상 로드 | index, lazy load, tool search |
| Memory leak | state 파일이 cleanup 없이 누적 | lifecycle 과 max age 정의 |
| Hidden background loop | 사용자 visibility 없이 반복 실행 | cap, progress, stop path |
| MCP trust shortcut | 원격 MCP 를 권한 검토 없이 추가 | source, install, data access 검토 |
