---
name: hook-creator
description: |-
  Use when creating, scaffolding, editing, or verifying a Claude Code hook — a registration entry (`settings.json` 또는 `hooks.json` 의 `hooks` 절) 와 그 entry 가 가리키는 script 파일 한 쌍. Triggers on "create a hook", "훅 만들어줘", "PostToolUse for X", "PreToolUse 차단", "format-on-edit 훅", "session-start 컨텍스트 주입", "hook script 작성", "/<hook-name> 만들어줘" — 사용자가 아직 event/matcher 를 정하지 않은 경우 포함. Do NOT use for 스킬 작성(`skill-creator`), 서브에이전트 작성(`agent-creator`), 자원 타입(skill/agent/hook) 결정(`resource-design`), 기존 훅의 정적 rule 감사(`agent-skill-auditor`), PR/code 편집.
---

# hook-creator

Claude Code 훅(registration + script) 작성·개선을 위한 절차 메타 스킬. agent-skill-best-practices 기준 문서를 단계별로 읽고, draft → GAP 분석 → 수정 → GAP 재분석을 PASS / PASS_WITH_NOTES 까지 반복한다.

관련 자산: `skill-creator`(반복 가능한 판단 절차), `agent-creator`(서브에이전트), `resource-design`(타입·책임 결정), `agent-skill-auditor`(정적 rule 감사).

## Reference Loading Schedule

각 단계에서 *읽어야 할* 권위 문서 — 모든 경로는 `${CLAUDE_PLUGIN_ROOT}/references/` 아래.

**이식성 주의**:

- *배포 전제*: 본 스킬은 `bobs-plugin` references 와 함께 배포될 때 유효하다.
- *Fallback 경로*: `${CLAUDE_PLUGIN_ROOT}` 미설정 환경에서는 현재 SKILL.md 기준 `../../references/` 를 사용한다 (plugin 디렉토리 구조 가정).
- *실패 시*: 두 경로 모두 접근 불가하면 사용자에게 참조 문서 미존재를 보고하고 종료한다. 권위 문서 없이는 GAP 분석 loop 가 작동하지 않는다.

| Phase | 읽는 문서 | 용도 |
|---|---|---|
| §0 Capture intent | `CONSTITUTION.md` §3 (10개 design principle) | 의도·책임·escape hatch 판단 기준 |
| §1 Choose scope | (없음 — 본 스킬 내장 결정 트리) | — |
| §2 Draft | `HOOK-GUIDE.md` §1–§14 (event·matcher·input·exit·security·performance·patterns·checklist·anti-patterns·version) | 스켈레톤 (discipline 요약은 §2 본문에 내재화) |
| §3 GAP 분석 | `GAP-FORMAT.md` (전체, 특히 §11.4 Hook Snapshot · §12.4 Hook Checks) + `GAP-ANALYSIS-PROMPT.md` (위임 프롬프트 verbatim). 실제 §3 본문은 `creator-gap-eval` 호출 stub — 자원-타입 분기는 `creator-gap-eval/references/resource-type-matrix.md` 가 흡수 | 평가 리포트 형식 + 위임 protocol |
| §4 GAP 피드백 반영 | `GAP-FORMAT.md` §13 Findings + §15 Suggested Changes + §16 Final Decision | finding 별 수정 지침 |
| §5 Output to caller | (없음) | — |
| §6 Terminology and tone pass | (작성한 script/registration 자체) + CONSTITUTION §3.8 (강한 표현은 실제 gate 에) | 응답 직전 표현·exit policy 일관성 확인 |

본 스킬은 규칙을 본문에 복사하지 않는다 — *언제 어느 문서를 읽고 어떤 산출물을 어디에 저장할지* 만 정의한다.

## When NOT to use

- 스킬(`SKILL.md` under `skills/`) 작성 → `skill-creator`.
- 서브에이전트(`.md` under `agents/`) 작성 → `agent-creator`.
- 자원 타입(skill / agent / hook) 결정 → `resource-design`. 본 스킬은 *이미 훅으로 정한 뒤* 시작.
- 기존 훅의 정적 rule 감사 (P0/P1/P2 + rule ID) → `agent-skill-auditor`. 본 스킬은 §3 에서 GAP 분석을 사용 (영향 기준 평가, rule ID 기반 채점이 아님).
- 검증 인프라 (task log / golden-set / evaluation loop / `docs/agent/roles.md` body) → `evaluation-loop-design`.
- runtime 사이클 실행 (task log entry write + golden-set 비교 + Routing Decision) → `evaluation-loop-runner`. 본 스킬은 *hook 작성* 만, runtime 실행 아님.
- 외부 모델 의견 / PR 리뷰 → `codex-reviewer` / `pr-review-toolkit`.

## 0. Capture intent

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md
```

§3 의 10개 design principle 을 체크리스트로 사용해 다음 6가지를 확정한다. 대화 맥락에 있으면 추출하고, 없으면 한 번에 묶어서 묻는다.

10개 원칙: Activation Explicit / Scope Quality / Effects Gates / Output Contract / Capability Surface / Reusable vs Local / Progressive Disclosure / Strong Language / Verifiable / Overlap Intentional.

| # | 질문 | 매핑되는 헌법 §3 원칙 |
|---|---|---|
| 1 | 자동 보장할 단일 책임은 무엇인가? (한 문장) | §3.5 Capability Surface · §3.6 Reusable |
| 2 | 어떤 event 에 반응하나? (PreToolUse / PostToolUse / UserPromptSubmit / SessionStart / Notification / Stop / 기타) | §3.1 Activation Explicit |
| 3 | matcher 는 어떤 tool/event 범위인가? near-miss 로 들어오면 안 될 케이스는? | §3.1 · §3.10 Overlap Intentional |
| 4 | exit policy 는? best-effort (exit 0) / blocking (non-zero) / context inject. 차단 시 사용자에게 보이는 stderr 메시지는? | §3.4 Output Contract · §3.3 Effects Require Gates |
| 5 | 부수 효과·외부 IO 가 있나? (파일 mutation / 외부 network / /tmp 또는 ~/.claude state / secret 접근) | §3.3 · §3.5 |
| 6 | 어디에 두나? user / project / plugin | §3.6 Reusable vs Local |

### In-flight escape hatches (헌법 §3 · HOOK-GUIDE §1 위반 패턴별 전환)

의도 캡처 중 자원 타입이 달라 보이면 즉시 다른 자원으로 전환한다.

| 신호 | 위반 | 전환 대상 |
|---|---|---|
| 자연어 판단·trade-off·설계 선택이 필요 | §3.5 + HOOK-GUIDE §1 (훅에 부적합) | `skill-creator` 또는 `agent-creator` |
| 별도 context / tool 권한 / 별도 model 이 필요한 specialist 역할 | §3.5 — 훅은 빠른 deterministic guardrail | `agent-creator` |
| 프로젝트 고유 명령·경로·convention | §3.6 — reusable 자산이 아닌 local convention | `CLAUDE.md` |
| substring 매칭을 보안 차단 근거로 사용 | HOOK-GUIDE §13 Anti-Pattern (Regex/Substring as security boundary) | `code-review` skill / 보안 reviewer agent |
| 매 event 마다 오래 걸리는 분석 | HOOK-GUIDE §9 Performance + §13 Long-running hook | async/background queue 로 분리, 또는 별도 스킬 |
| false positive 가 사용자 작업 흐름을 자주 막을 위험 | HOOK-GUIDE §1 부적합 + §13 Advisory-as-blocker | best-effort 모드로 재설계 또는 reviewer 자산으로 이동 |

사용자에게 한 줄로 전환 사유와 인용한 § 번호를 알리고 종료한다.

## 1. Choose scope

| Scope | Script path | Registration |
|---|---|---|
| user | `~/.claude/hooks/<name>.sh` (또는 `.py`) | `~/.claude/settings.json` 의 `hooks` 절 |
| project | `<repo>/.claude/hooks/<name>.sh` | `<repo>/.claude/settings.json` 의 `hooks` 절 |
| plugin | `plugins/<plugin>/hooks/<name>/<script>` | `plugins/<plugin>/hooks/<name>/hooks.json` |

**플러그인 구조 권장** — 플러그인 스코프 훅은 `hooks/<name>/` 디렉토리 단위로 묶고, 같은 디렉토리에 `hooks.json` 과 script 를 함께 둔다. 한 디렉토리에 여러 책임을 섞지 않는다 (HOOK-GUIDE §13 Mixed responsibility).

**Name collision check**:

```bash
ls ~/.claude/hooks/ <project>/.claude/hooks/ plugins/*/hooks/ 2>/dev/null
```

기존 동명·유사 책임 훅이 있으면 신규 생성보다 *수정·matcher 확장* 우선. 한 책임당 하나의 훅이 원칙 — formatter, blocker, logger 를 한 파일에 섞지 않는다.

**Registration merge precedence** — user/project scope merge 동작은 runtime 버전에 따라 다를 수 있다 (HOOK-GUIDE §14 Version-Sensitive Details). 단정하지 말고 사용자 환경에서 확인한다.

## 2. Draft

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/HOOK-GUIDE.md
```

**파일 쓰기·수정 승인 gate (CONSTITUTION §3.3 Effects Require Gates)** — 훅은 *자동 실행되며* 모든 후속 tool 호출에 영향을 줄 수 있다. 일반 스킬보다 effects 강도가 높다. 동일 gate 가 두 시점에 적용된다.

**시점 A — 첫 파일 쓰기 전 (§2 본문 작성)**: 다음 5가지를 사용자에게 제시한다.

1. script 파일 절대 경로 (§1 에서 결정된 path)
2. registration 변경 — JSON delta. user/project 스코프면 settings.json 의 `hooks` 절에 *추가될 객체*; plugin 스코프면 새 `hooks.json` 전체.
3. event + matcher 값과 그 선택 근거 (HOOK-GUIDE §4–§5)
4. exit policy 결정 (best-effort exit 0 / blocking non-zero / context inject) 와 차단 시 stderr 메시지 한 줄
5. workspace 디렉토리 경로 (§3a 에서 생성될 위치)

**시점 B — §4 수정 반영 전 (round 2+)**: 적용할 finding 의 short title 과 *변경 요약* (registration 또는 script 의 어느 부분이 어떻게 바뀌는지) 을 사용자에게 제시한다. registration 변경은 자동 실행 범위에 직접 영향을 주므로 *항상* gate 를 지킨다.

각 시점에서 사용자가 "진행" / "go" / "proceed" 같은 명시적 신호를 줄 때만 파일을 쓰거나 수정한다.

사용자가 "묻지 말고 진행" 을 명시한 경우에만 확인 없이 진행한다. 첫 파일 쓰기 시 가정은 응답의 `assumptions:` 필드 또는 script 상단 주석 (`# Assumptions:`) 에 기록한다. 수정 반영 시 가정은 GAP report 의 `Acceptable Deviations` 에 기록한다.

**적용할 기준** — HOOK-GUIDE §3 (Registration), §4 (Event 선택), §5 (Matcher), §6 (Input Handling), §7 (Exit Behavior), §8 (Security), §9 (Performance), §10 (Common Patterns — 본보기 6종), §12 (Checklist), §13 (Anti-Patterns), §14 (Version-Sensitive Details) 을 *표준 골격* 으로 삼는다. 자산 목적에 맞게 필요한 섹션만 적용한다 — HOOK-GUIDE 는 형식보다 기능을 중시하므로 §10 의 예시 패턴을 그대로 강제하지 않는다.

**작성 중 자기검열** — 다음 discipline 을 작성 도중 점검 기준으로 사용한다 (HOOK-GUIDE 의 핵심 개념을 본 스킬 본문에 내재화한 요약 — 추가 깊이가 필요하면 HOOK-GUIDE 본문을 직접 참고):

- **Matcher 최소성** — matcher 가 넓을수록 false positive 와 비용이 증가한다 (HOOK-GUIDE §5). 의도된 tool/event 만 잡고, script 안에서 path/확장자 filter 를 한 번 더 적용한다 (defense-in-depth).
- **Exit policy 일관성** — advisory(reminder, formatter, logger) 는 exit 0 + stderr, blocking 은 명확한 non-zero exit + 짧은 stderr 이유. 의도가 advisory 인데 blocking 으로 동작하면 HOOK-GUIDE §13 Anti-Pattern (Advisory hook configured as blocker).
- **Input handling 방어성** — runtime 이 넘기는 JSON schema 는 버전 영향을 받는다 (HOOK-GUIDE §6, §14). 없는 field 는 no-op, path 는 quote, JSON 은 `jq` 로 파싱. schema 가정에는 `# verified against: <runtime> <version>` 주석을 남긴다.
- **부수 효과 → 등록 gate** — registration 자체가 자동 실행을 트리거하는 부수 효과다. settings.json 또는 hooks.json 변경 전에 사용자 확인을 거치고, 변경 내용을 review 가능한 형태(JSON delta)로 제시한다.
- **함정 14종 (HOOK-GUIDE §13)** — Script-only / Broad matcher / Blocking formatter / Long-running / Hidden exfiltration / Regex security / Hook-as-agent / Hook-as-skill / Mixed responsibility / Version lock-in / Advisory-as-blocker / Substring-as-block / Unbounded auto-loop / Scattered state. 작성 후 §13 표로 자기 검열.

표준 골격을 적용한 script + registration 한 쌍이 1차 draft 다. 새 골격을 발명하기 전, 기존 §10 패턴이 자산 목적에 맞지 않는 이유를 먼저 확인한다.

핵심 원칙 요약 (가이드 읽은 뒤 적용):
- script 는 실행 가능 권한이 있어야 한다 (`chmod +x` 또는 `python3 <path>` 호출 형식)
- 1회 실행은 빈번한 event 에서는 짧게 — 무거운 검증은 background 로 분리 (HOOK-GUIDE §9)
- 매칭 없을 때 조용히 exit 0 — best-effort 작업이 사용자 흐름을 방해하지 않게
- 외부 network 호출은 명시 opt-in 또는 제거 (HOOK-GUIDE §8)
- state 가 필요하면 단일 store 에 session_id 를 key 로 — session 별 파일 산재 금지 (HOOK-GUIDE §10.6)
- Stop 훅 자기 재호출은 §10.5 의 5개 안전 요건 (opt-in / iteration cap / completion gate / visibility / stop path) 모두 충족 시에만 가능

## 3. GAP 분석 (creator-gap-eval 호출)

본 절차는 `creator-gap-eval` skill 이 통합 처리한다 (Step 4b 추출 결과). §0-§2 에서 결정된 다음 값으로 호출 — workspace 는 creator-gap-eval 이 자체 결정 (plugin 단위 통합 — `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/`).

```yaml
resource_type: hook
draft_path:                          # 훅은 script + registration 한 쌍 — 2 파일 list
  - <SCRIPT_PATH>                    # §1 에서 결정 (HOOK_DIR/<script>)
  - <REGISTRATION_PATH>              # §2 에서 결정 (hooks.json 또는 settings.json)
asset_name: <name>                   # §1 에서 결정된 kebab-case. report = hook-<name>.GAP.md
delegation_mode: delegate            # 기본 위임 (비용 절감 필요 시 inline)
reentry_count: 0                     # 본 creator 가 호출하는 경로는 항상 0
round_count: 1                       # 1-based. 첫 호출 = 1. REVISE_ASSET 재호출 시 +1 (round 2 = 2 → .round2.md suffix). > 5 시 NEEDS_REVIEW
```

호출 (Claude Code 환경): `Skill` tool 로 `creator-gap-eval` 활성화. 반환 yaml 의 `final_decision` 으로 분기 — 상세는 §4 참조. `report_path` 는 통합 workspace 의 절대 경로 반환.

훅-특화 분기 (GAP-FORMAT §11.4 Hook Snapshot · §12.4 Hook Checks · destructive Bash / 숨은 외부 송신 같은 P0 패턴 / matcher vs advisory 충돌 같은 P1 패턴 / Mixed responsibility 분할 같은 SPLIT_ASSET 신호) 는 `creator-gap-eval/references/resource-type-matrix.md` 의 hook 컬럼이 흡수.

## 4. Self-feedback refine — Final Decision 처리

`creator-gap-eval` 의 반환 yaml 을 받아 다음 분기:

- `PASS` / `PASS_WITH_NOTES` → §5 (Output to caller) 로 진행
- `REVISE_GUIDE` → 사용자 보고 후 §5 (자산은 일단 통과)
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침) 후 `creator-gap-eval` 재호출. 재호출 시 args 의 `round_count` 와 `reentry_count` 모두 *반환된 값* 으로 echo + `round_count` 만 +1 (예: 반환 `round_count: 1, reentry_count: 0` 받았으면 다음 호출 `round_count: 2, reentry_count: 0`). **round_count +1 누락 시 이전 GAP report 덮어쓰기 위험**. **registration 변경은 자동 실행 범위에 직접 영향** — 항상 시점 B gate 지킴
- `SPLIT_ASSET` → §0 으로 복귀, 책임 분리 재설계 (Mixed responsibility — formatter/blocker/logger 분할)
- `DEPRECATE_ASSET` → 사용자 confirm 후 폐기 권고
- `NEEDS_REVIEW` → 사용자 입력 받기 (creator-gap-eval 의 reentry_count 한도 또는 round_count 한도 초과 포함)

라운드 5 초과 시 `creator-gap-eval` 이 `NEEDS_REVIEW` 반환 (round_count 한도). Finding 적용 / Re-run gate / GUIDE_GAP 의 상세 절차는 `creator-gap-eval/SKILL.md` Phase 7-9 와 `references/resource-type-matrix.md` 의 자원별 분기 행 참조.

## 5. Output to caller

호출자가 mechanical 하게 parse 할 수 있도록 *한 필드 한 줄* 형식의 fenced block 으로 출력한다. 값이 여러 개이면 콤마 + 공백으로 구분한다.

```
created/updated: <script path>, <registration path>
scope: user | project | plugin
event: <event name>
matcher: <matcher value>
exit_policy: best-effort | blocking | context-inject
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <absolute path to *.GAP.md>
guide_gaps: <n>
follow-ups: <count>; <one-line summary if count > 0>
```

필드 규약:

| Field | Required | Value 형식 | 빈 값 처리 |
|---|---|---|---|
| `created/updated` | 필수 | 경로 1–N 개, `, ` 구분 | — (수정 없으면 본 스킬 종료 자체가 발생하지 않음) |
| `scope` | 필수 | `user` / `project` / `plugin` 중 하나 | — |
| `event` | 필수 | 단일 event 이름 (예: `PostToolUse`) | — |
| `matcher` | 필수 | matcher 문자열 그대로 | matcher 없는 전역 훅이면 `*` 명시 |
| `exit_policy` | 필수 | `best-effort` / `blocking` / `context-inject` 중 하나 | — |
| `gap` | 필수 | `<Final Decision> (rounds: <N>)` | — |
| `findings` | 필수 | `P0=<n>, P1=<n>, P2=<n>, P3=<n>` 4쌍 모두 | 0 이면 `P?=0` 으로 명시 (필드 생략 금지) |
| `gap_report` | 필수 | 절대 경로 | — |
| `guide_gaps` | 필수 | 정수 (informational, blocker 아님) | 0 이면 `0` |
| `follow-ups` | 필수 | `<count>; <one-line summary>` 또는 `0` | 없으면 `0` |

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 fenced block 전체 *앞에* `blocked: needs revision` 한 줄을 추가한다.

세부 finding 본문을 응답에 풀어 쓰지 말고 `gap_report` 경로로 안내 — main context 절약. 사용자가 원하면 직접 읽는다.

## 6. Terminology and tone pass

§5 응답을 caller 에게 보내기 *직전에* 실행한다. 실행 순서는 §4 (수정 반영) → §6 (용어·톤 정리) → §5 (응답 송신) 이다.

작성한 script 와 registration 을 한 번 더 읽고 표현·exit policy 일관성을 확인한다. 본 pass 는 *표현만* 정리하며 의미 변경이나 새 finding 도입은 §3 GAP 분석에서 처리할 일이다.

### 체크 항목

- **stderr 메시지 일관성** — 차단 시 출력하는 stderr 메시지는 짧고 구체적으로. "Blocked: <이유>: <증거>" 같은 일관된 형식. 사과·이모지·길게 늘어진 설명 회피.
- **주석 톤** — script 안의 주석은 *왜* 그렇게 짰는지 (특히 매칭 범위, version 가정, fallback 의도) 만 남긴다. 무엇을 하는지 (`# read file_path from jq`) 는 잘 명명된 변수가 이미 설명한다.
- **강한 표현은 실제 gate 에** (CONSTITUTION §3.8) — `MUST` / `NEVER` / 강조 표현은 실제 차단·승인·secret 보호 경로에 한정. advisory routing hint 에는 일반 톤.
- **영어 용어 최소화** — 원문 유지가 필요한 경우에만 영어를 남긴다:
  - tool 이름·event 이름 (`Edit`, `Write`, `PreToolUse`, `PostToolUse`)
  - file 이름·path (`settings.json`, `hooks.json`)
  - JSON key (`matcher`, `command`, `type`, `additionalContext`)
  - enum 값 (`PASS`, `REVISE_ASSET`, `P0`)
  - 권위 문서·본 스킬이 정의한 도메인 용어 (`exit policy`, `GAP report`, `defense-in-depth`)

  일반 동사·서술어·연결어는 한국어로 통일한다 (예: `redirect` → 전환, `confirm` → 확인, `prefix` → 앞에 붙임, `procedural` → 절차).
- **구어적 표현 제거** — "막아버리다", "터지다", "잡지 못함" 같은 구어체는 spec 톤의 평서체로 정리한다 (예: "차단하다", "실패하다", "적절히 평가하지 못함").
- **불필요하게 강한 표현 완화** — heuristic 을 hard rule 로 표기하지 않는다. CONSTITUTION §3.8 의 원칙대로 강한 표현은 *실제 gate* 에 한정.
- **긴 조건 종속문 분리** — 한 문장에 조건·이유·예외가 모두 들어가면 2–3 문장으로 나눈다. 한 문장 = 한 주장이 원칙.
- **version 가정 표시** — runtime schema 가정을 코드에 박을 때 `# verified against: <runtime> <version>` 주석이 함께 있는지 확인 (HOOK-GUIDE §14).

### 산출

본 pass 가 완료되면 script/registration 의 표현·exit policy 가 통일된다. 자산 의미는 §4 종료 시점과 동일해야 한다 — 의미가 바뀌었다면 §3 GAP 분석으로 되돌아간다.

본 pass 자체는 응답에 별도 보고하지 않는다. §5 응답의 `gap` 필드가 PASS / PASS_WITH_NOTES 인 한 표현 정리는 *전제 조건* 으로 처리한다.

## Mini example

**요청**: "Edit/Write 후 TypeScript 파일이면 `tsc --noEmit` 으로 빠르게 type check 하는 훅."

- **§0–§2 Draft** — scope: project (팀 공유), `<repo>/.claude/hooks/tsc-check.sh` + `<repo>/.claude/settings.json` 에 `PostToolUse(matcher: "Edit|Write")` 추가. exit policy: best-effort (exit 0 + stderr). script 안 path filter 로 `*.ts|*.tsx` 만 처리, 그 외 조용히 exit 0. background 로 분리하기보다 변경 파일 하나만 동기 check 하는 짧은 형태.
- **§3 GAP 분석 round 1 (위임)** — `REVISE_ASSET`. P1: blocking 의도가 없는데 `tsc` 의 non-zero exit 가 사용자 작업을 차단할 수 있음 (Blocking formatter anti-pattern). P2: full project typecheck 가 매 edit 마다 돌면 §9 Performance.
- **§4 수정** — `tsc --noEmit "$file" >&2 || true` 로 exit 0 강제, `--isolatedModules` 같은 단일 파일 check 옵션 적용. version 주석 추가.
- **§3 GAP 재분석 round 2** — `PASS_WITH_NOTES` (P3 만 잔류 — TypeScript project config 미존재 시 silent no-op 보강 권고). 종료.
- **§5 응답**: `created: …/tsc-check.sh, …/settings.json delta · scope: project · event: PostToolUse · matcher: Edit|Write · exit_policy: best-effort · gap: PASS_WITH_NOTES (rounds: 2) · findings: P0=0, P1=0, P2=0, P3=1 · gap_report: …/gaps/hook-tsc-check.GAP.md`

## When the loop stalls

3 라운드 후에도 PASS 가 안 나오면 GAP-FORMAT §16 의 다른 결정을 고려한다.

1. **책임 모호** → `SPLIT_ASSET`. §0 으로 복귀해 단일 책임을 재정의한다. 한 훅이 formatter + blocker + logger 를 동시에 수행하면 분리한다 (HOOK-GUIDE §13 Mixed responsibility).
2. **자원 타입 오류** → 전환. 자연어 판단·trade-off 가 필요하면 skill, specialist 분리가 필요하면 agent, 프로젝트 고유 규칙이면 CLAUDE.md.
3. **GUIDE_GAP** → 가이드가 좋은 자산을 적절히 평가하지 못함. 사용자에게 보고하고 자산은 통과시킨다. 가이드 보완은 별도 작업.
4. **NEEDS_REVIEW** → 근거가 부족하거나 추정이 많은 경우. 사용자 입력 후 재개.

보조 도구로 **Matcher pressure scenarios** — 매칭 조건이 좁은지 검증하기 위해 자산이 *반응해야 할 case* 와 *반응하지 않아야 할 case* 를 사용자와 함께 2–3개씩 적는다. registration 변경 없이 mental dry-run 으로 분류 결과를 확인하거나, 사용자의 평소 워크플로우에서 false positive 가 의심되는 시나리오를 찾는다. 자세한 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/hook-creator/references/matcher-pressure.md` (있을 경우; 없으면 본 절의 요약만 사용).

## Limits

- 파일 수정은 본 스킬이 직접 한다 (procedural). registration 변경은 §2 시점 A/B gate 를 항상 거친다.
- 외부 모델 호출·네트워크 IO 없음.
- 다른 에이전트 자동 디스패치는 §3b 의 GAP 분석 위임 1건만 — 그 외 orchestration 은 호출자 책임.
- GAP 리포트는 자산과 동급 산출물 — 디버깅·재현·다음 사이클 입력 위해 보존.
- runtime 별 hook schema · exit code semantics · merge precedence 는 본 스킬이 단정하지 않는다. 코드에 가정으로 박을 때는 `# verified against: <runtime> <version>` 주석을 함께 둔다 (HOOK-GUIDE §14).
- 가이드 자체 수정 (`REVISE_GUIDE` / Constitution Review) 은 본 스킬 범위 밖.
- Stop 훅 자기 재호출 (HOOK-GUIDE §10.5) 패턴은 5개 안전 요건 (opt-in / iteration cap / completion gate / visibility / stop path) 모두 충족 시에만 본 스킬로 생성한다 — 하나라도 빠지면 §0 으로 복귀해 책임을 재정의한다.
