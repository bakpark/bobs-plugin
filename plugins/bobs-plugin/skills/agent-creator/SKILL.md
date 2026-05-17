---
name: agent-creator
description: |-
  Use when creating, scaffolding, editing, or verifying a Claude Code subagent (`.md` under `agents/`). Triggers on "create an agent", "scaffold a subagent", "에이전트 만들어줘", "서브에이전트 추가", "agent 작성·개선·검증", "/agent-name 만들어줘", "draft an agent for X" — including when the user has not yet chosen a name, persona, tools, or model. Do NOT use for writing skills (`skill-creator`), agent-vs-skill / merge / migration-order decisions (`resource-design`), static rule audit of an existing agent (`agent-skill-auditor`), or PR/code edits.
---

# agent-creator

Claude Code 서브에이전트(`agents/<name>.md`) 작성·개선을 위한 절차 메타 스킬. agent-skill-best-practices 기준 문서를 단계별로 읽고, draft → GAP 분석 → 수정 → GAP 재분석을 PASS / PASS_WITH_NOTES 까지 반복한다.

`skill-creator` 의 sibling — 동일한 6 phase 골격, 적용 가이드와 GAP Snapshot/Checks 만 에이전트용으로 다르다.

관련 자산: `skill-creator`(스킬 sibling — 같은 6 phase 구조), `hook-creator`(훅 sibling), `resource-design`(타입·책임 결정), `agent-skill-auditor`(정적 rule 감사).

## Reference Loading Schedule

각 단계에서 *읽어야 할* 권위 문서 — 모든 경로는 `${CLAUDE_PLUGIN_ROOT}/references/` 아래.

**이식성 주의**:

- *배포 전제*: 본 스킬은 `bobs-plugin` references 와 함께 배포될 때 유효하다.
- *Fallback 경로*: `${CLAUDE_PLUGIN_ROOT}` 미설정 환경에서는 현재 SKILL.md 기준 `../../references/` 를 사용한다 (plugin 디렉토리 구조 가정).
- *실패 시*: 두 경로 모두 접근 불가하면 사용자에게 참조 문서 미존재를 보고하고 종료한다. 권위 문서 없이는 GAP 분석 loop 가 작동하지 않는다.

| Phase | 읽는 문서 | 용도 |
|---|---|---|
| §0 Capture intent | `CONSTITUTION.md` §3 (공통 원칙) | 의도·책임·escape hatch 판단 기준 |
| §1 Choose scope | (없음 — 본 스킬 내장 결정 트리) | — |
| §2 Draft | `AGENT-GUIDE.md` §1–§13 (역할·frontmatter·description·body·scope·capability·output·quality gate·anti-patterns) | 스켈레톤 (discipline 요약은 §2 본문에 내재화) |
| §3 GAP 분석 | `GAP-FORMAT.md` (전체) + `GAP-ANALYSIS-PROMPT.md` (위임 프롬프트 verbatim) | 평가 리포트 형식 + 위임 protocol |
| §4 GAP 피드백 반영 | `GAP-FORMAT.md` §13 Findings + §15 Suggested Changes + §16 Final Decision | finding 별 수정 지침 |
| §5 Output to caller | (없음) | — |
| §6 Terminology and tone pass | (작성한 agent `.md` 자체) + CONSTITUTION §3.8 (강한 표현은 실제 gate 에) | 응답 직전 표현 통일 |

본 스킬은 규칙을 본문에 복사하지 않는다 — *언제 어느 문서를 읽고 어떤 산출물을 어디에 저장할지* 만 정의한다.

## When NOT to use

- 스킬(`SKILL.md` under `skills/<name>/`) 작성 → `skill-creator`. 본 스킬은 *에이전트로 정한 뒤* 시작.
- 자원 타입(command / skill / agent / hook / runtime setting) 결정·책임 분리·migration plan → `resource-design`.
- 기존 에이전트의 정적 rule 감사 (P0/P1/P2 + rule ID) → `agent-skill-auditor`. 본 스킬은 §3 에서 GAP 분석을 사용 (영향 기준 평가, rule ID 기반 채점이 아님).
- 검증 인프라 (task log / golden-set / evaluation loop / `docs/agent/roles.md` body) → `evaluation-loop-design`.
- 외부 모델 의견 / PR 리뷰 → `codex-reviewer` / `pr-review-toolkit`.

## 0. Capture intent

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md
```

§3 의 공통 원칙을 체크리스트로 사용해 다음 6가지를 확정한다. 대화 맥락에 있으면 추출하고, 없으면 한 번에 묶어서 묻는다.

핵심 원칙: Activation / Scope / Effects Gate / Output Contract / Capability Surface / Reusable vs Local Memory / Progressive Disclosure / Strong Language / Verification / Overlap / Command Boundary / Runtime Policy / Freshness.

| # | 질문 | 매핑되는 헌법 §3 원칙 |
|---|---|---|
| 1 | 한 문장 책임은 무엇인가? (specialist role) | §3.5 Capability Surface · §3.6 Reusable |
| 2 | 언제 dispatch 되어야 하나? (trigger 1–3개) | §3.1 Activation Explicit |
| 3 | 언제 dispatch 되면 안 되나? (≥1 near-miss + sibling 이름) | §3.1 · §3.10 Overlap Intentional |
| 4 | 호출자는 산출물로 무엇을 하는가? (output contract) | §3.4 Output Contract |
| 5 | 어떤 파일·시스템에 접근하나? read-only / +Write / +Bash | §3.3 Effects Require Gates · §3.5 Capability Surface |
| 6 | 어디에 두나? user / project / plugin | §3.6 Reusable vs Local |

### In-flight escape hatches (헌법 §3 위반 패턴별 전환)

의도 캡처 중 자원 타입이 달라 보이면 즉시 다른 자원으로 전환한다.

| 신호 | 위반 | 전환 대상 |
|---|---|---|
| 사용자 명시 workflow / 사용자 질문 / plan gate / 문서 링크 context 주입 / 얕은 orchestration | §3.11 — workflow entrypoint 는 command | `resource-design` (command 트랙) |
| 외부 인프라·API·provider·도메인 capability 이지 specialist role 이 아님 | §3.5 — 에이전트는 별도 context + tool/model 격리 specialist | `skill-creator` |
| 매 이벤트마다 결정론 보장 필요 | §3.1 — 에이전트는 명시 dispatch, hook 은 결정론 | `resource-design` (hook 트랙) |
| 프로젝트 고유 규칙 | §3.6 — reusable 자산이 아닌 local convention | `CLAUDE.md` |
| 한 파일이 분석·수정·commit·deploy 다 수행 (generalist) | §3.5 + §3.3 — single responsibility 위반 | 책임을 둘 이상으로 분리하거나 `resource-design` 위임 |
| 다른 에이전트를 디스패치하는 orchestrator | §3.5 · §3.11 — orchestration 은 command 또는 caller 책임 | command / main session 으로 이동 |

사용자에게 한 줄로 전환 사유와 인용한 헌법 § 번호를 알리고 종료한다.

## 1. Choose scope

| Scope | Path | When |
|---|---|---|
| user | `~/.claude/agents/<name>.md` | 모든 프로젝트에서 쓰임 |
| project | `<repo>/.claude/agents/<name>.md` | 저장소 한정 |
| plugin | `plugins/<plugin>/agents/<name>.md` | 배포 단위 (callers 는 `<plugin>:<name>` 으로 본다) |

**Name collision check**:

```bash
ls ~/.claude/agents/ <project>/.claude/agents/ plugins/*/agents/ 2>/dev/null
```

빌트인 `subagent_type` (`general-purpose`, `Explore`, `Plan`, `statusline-setup`) 와 충돌하면 라우팅 불확실 — 이름 변경. 동명·유사 책임 에이전트가 있으면 신규 생성보다 *수정·차별점 명시* 우선.

**이름 형태**: kebab-case verb-noun. `subagent_type: "<name>"` 으로 자연스럽게 읽혀야 한다 (`code-reviewer`, `silent-failure-hunter`, `pr-comment-reviewer`). 동사 없는 명사형 (`reviewer1`, `helper`) 은 라우팅 혼선의 신호.

## 2. Draft

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/AGENT-GUIDE.md
```

**파일 쓰기·수정 승인 gate (CONSTITUTION §3.3 Effects Require Gates)** — 본 스킬은 파일 시스템에 agent `.md` 와 workspace 디렉토리를 *생성·수정* 한다. 동일 gate 가 두 시점에 적용된다.

**시점 A — 첫 파일 쓰기 전 (§2 본문 작성)**: 다음 5가지를 사용자에게 제시한다.

1. 작성될 파일 절대 경로 (§1 에서 결정된 path)
2. frontmatter 초안 — *agent 지원 필드만* 사용 (`name`, `description`, `tools`, `model`, 선택적 `color`, runtime 이 지원하는 경우 `permissionMode` / `maxTurns` / `skills` / `mcpServers` / `memory` / `background` / `effort` / `isolation`). `disable-model-invocation` / `user-invocable` / `allowed-tools` 는 skill 전용이므로 agent 에 두지 않는다.
3. tool/model/runtime 결정 근거 — read-only vs +Write vs +Bash, sonnet vs opus vs haiku, memory/background/MCP 사용 이유의 한 줄 설명
4. 본문 골격 (persona / Core Process / Output Guidance / 필요 시 When to invoke)
5. workspace 디렉토리 경로 (§3a 에서 생성될 위치)

**시점 B — §4 수정 반영 전 (round 2+)**: 적용할 finding 의 short title 과 *변경 요약* (frontmatter / persona / Output Guidance / tools 중 어디의 무엇이 어떻게 바뀌는지) 을 사용자에게 제시한다.

각 시점에서 사용자가 "진행" / "go" / "proceed" 같은 명시적 신호를 줄 때만 파일을 쓰거나 수정한다.

사용자가 "묻지 말고 진행" 을 명시한 경우에만 확인 없이 진행한다. 첫 파일 쓰기 시 가정은 최종 응답의 `assumptions:` 필드 또는 본문 첫 섹션 (`## Assumptions`) 에 기록한다. agent `.md` 첫 줄은 `---` frontmatter 구분자여야 하므로 가정 텍스트를 그 자리에 두지 않는다. 수정 반영 시 가정은 GAP report 의 `Acceptable Deviations` 에 기록한다.

**적용할 기준** — AGENT-GUIDE §2 (Frontmatter), §3 (Description 전략), §4 (Body 설계 — persona / When to invoke / Scope·Mission / Core Responsibilities / Quality Gate / Output Contract), §5 (Scope 설계), §6.1 (Tools), §6.2 (Model), §6.3 (Runtime Capability Fields), §6.4 (Parent Integration Responsibility), §7 (Output Contract), §8 (Quality Gate), §9 (CLAUDE.md, Agent Memory, And Project Memory), §10 (Overlap and Reuse), §13 (Anti-Patterns) 을 *표준 골격* 으로 삼는다. 자산 목적에 맞게 필요한 섹션만 조정한다 — AGENT-GUIDE 는 형식보다 기능을 중시하므로 모든 섹션명을 그대로 강제하지 않는다.

**작성 중 자기검열** — 다음 discipline 을 작성 도중 점검 기준으로 사용한다 (핵심 개념을 본 스킬 본문에 내재화한 요약):

- **CSO (Claude Search Optimization) for descriptions** — description 은 *언제 dispatch 할지* 만 담는다. 본문 절차를 description 에 요약하면 orchestrator 가 본문을 읽지 않고 description 만 따라 단축 라우팅한다 (Description-as-runbook 안티패턴). 네거티브 케이스에서 sibling 이름을 명시한다.
- **Tool/Model/Runtime boundary IS discipline** — 스킬은 본문 prose 가 discipline 의 큰 부분이지만, 에이전트는 *frontmatter 의 `tools:`, `model:`, runtime capability fields 자체가 discipline 의 절반* 이다. advisory 역할이 `tools: *` 면 본문에 "수정하지 않는다" 라고 써도 압력 상황에서 모델은 도구를 사용한다. tool allowlist 는 safety boundary 이지 documentation 이 아니다.
- **Iron Law (RED before GREEN)** — baseline 실패 없이 작성된 에이전트는 *어떤 drift 를 막는지* 알 수 없다. 작성 전 generic subagent 로 baseline prompt 를 dispatch 해 무엇이 실패하는지 (role drift / tool drift / output drift / dispatch drift) 관찰한다. 자세한 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/agent-creator/references/red-green-refactor.md`, 심화 pressure scenario library 는 `${CLAUDE_PLUGIN_ROOT}/skills/agent-creator/references/pressure-scenarios.md`.
- **AGENT-GUIDE §13 안티패턴** — Generalist agent / All-tools reviewer / No scope / No output contract / Low-confidence spam / Description bloat / Agent as runbook / Hidden mutation / Project convention leak / Unintentional duplicate / Always-opus / Orchestrator agent / Runtime overreach / Background without stop path / Unowned parallel writer. 작성 후 §13 표로 자기 검열.

표준 골격을 적용한 agent `.md` 가 1차 draft 다. 새 골격을 발명하기 전, 기존 골격이 자산 목적에 맞지 않는 이유를 먼저 확인한다.

핵심 원칙 요약 (가이드 읽은 뒤 적용):

- **description**: trigger + ≥1 negative case (sibling 이름 명시). 20–80 단어 정도가 보통 충분. 본문 절차 요약 금지.
- **name**: kebab-case verb-noun. `subagent_type` parameter 로 자연스럽게 읽혀야 한다.
- **tools**: 역할에 맞는 explicit allowlist. read/review/audit 은 `Read, Grep, Glob, LS` 가 기본. generation 은 `+ Write, Edit`. infra/migration 은 `+ Bash`. `tools: *` 는 catch-all 빌트인이 아닌 한 안티패턴 (AGENT-GUIDE §13 *All-tools reviewer*).
- **model**: `sonnet` 기본. `opus` 는 migration / architecture / 복잡 추론 등 정당화 가능할 때만. `haiku` 는 단순 분류. `inherit` 는 caller 와 reasoning profile 을 맞춰야 할 때. 매 에이전트마다 model 선택 사유 1줄 설명 가능해야 한다 (Always-opus 안티패턴 회피).
- **persona**: "You are …" 또는 "너는 …" 1문장 책임. mission/scope/output 을 본문 앞부분에서 빠르게 찾을 수 있어야 한다.
- **output contract**: 호출자가 파싱 가능한 구조 + no-finding / `NEEDS_INPUT` / `OUT_OF_SCOPE` escalation 케이스 명시. severity / confidence 그룹핑이 있으면 gate 까지 명시.
- **quality gate** (review/diagnostic 역할만): confidence ≥ N, Critical/Important 만 보고, advisory-only 선언, factual accuracy 만 보고, pre-existing issue 제외 — 중 하나 이상.
- **본문 길이**: AGENT-GUIDE §11 의 heuristic 으로 250–700 단어가 보통 충분, 1000 단어 초과 시 검토 신호. 초과 시 책임 분리 또는 reference bundle 검토 (hard limit 아님 — meta agent 는 정당화 가능).
- **여러 언어로 본문 작성 금지**. trigger 다국어는 description 에서만 — 본문은 한 언어로 (Multi-language persona 안티패턴).

## 3. GAP 분석 (creator-gap-eval 호출)

본 절차는 `creator-gap-eval` skill 이 통합 처리한다 (Step 4b 추출 결과). §0-§2 에서 결정된 다음 값으로 호출 — workspace 는 creator-gap-eval 이 자체 결정 (plugin 단위 통합 — `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/`).

```yaml
resource_type: agent
draft_path:
  - <AGENT_PATH>                 # §2 에서 결정된 절대 경로 (예: .../agents/<name>.md)
asset_name: <path-safe-name>     # §1 에서 결정. 경로 `/` 는 `-` 치환 (예: pr-review-toolkit/code-reviewer → pr-review-toolkit-code-reviewer)
                                 # report = agent-<asset_name>.GAP.md
delegation_mode: delegate        # 기본 위임 (비용 절감 필요 시 inline)
reentry_count: 0                 # 본 creator 가 호출하는 경로는 항상 0
round_count: 0                   # REVISE_ASSET 재호출 시 +1 (5 초과 시 NEEDS_REVIEW)
```

호출 (Claude Code 환경): `Skill` tool 로 `creator-gap-eval` 활성화. 반환 yaml 의 `final_decision` 으로 분기 — 상세는 §4 참조. `report_path` 는 통합 workspace 의 절대 경로 반환.

에이전트-특화 분기 (GAP-FORMAT §11.2 Agent Snapshot · §12.2 Agent Checks 10 축 · advisory + Write 같은 P1 패턴 / persona drift 같은 SPLIT_ASSET 신호 / sibling 명시 없는 negative case 등) 는 `creator-gap-eval/references/resource-type-matrix.md` 의 agent 컬럼이 흡수.

## 4. Self-feedback refine — Final Decision 처리

`creator-gap-eval` 의 반환 yaml 을 받아 다음 분기:

- `PASS` / `PASS_WITH_NOTES` → §5 (Output to caller) 로 진행
- `REVISE_GUIDE` → 사용자 보고 후 §5 (자산은 일단 통과). 에이전트의 GUIDE_GAP 후보 예: AGENT-GUIDE §10 (Overlap) sibling 명시 / §6.2 (Model) inherit 정당화 — `creator-gap-eval` matrix `guide_gap_candidates` 행 참조
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침) 후 `creator-gap-eval` 재호출 (`round_count + 1`)
- `SPLIT_ASSET` → §0 으로 복귀, 책임 분리 재설계 (에이전트 특화 신호: persona drift / 분석+수정+commit 다 함 / 한 본문 안에 두 역할)
- `DEPRECATE_ASSET` → 사용자 confirm 후 폐기 권고
- `NEEDS_REVIEW` → 사용자 입력 받기 (creator-gap-eval 의 reentry_count 한도 또는 round_count 한도 초과 포함)

라운드 5 초과 시 `creator-gap-eval` 이 `NEEDS_REVIEW` 반환 (round_count 한도). Finding 적용 / Re-run gate / GUIDE_GAP 의 상세 절차는 `creator-gap-eval/SKILL.md` Phase 7-9 와 `references/resource-type-matrix.md` 의 자원별 분기 행 참조.

## 5. Output to caller

```
created/updated: <relative path>
scope: user | project | plugin
tools: <list>
model: <id>
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <path to *.GAP.md>
guide_gaps: <count if any — informational, not blocker>
follow-ups: <Suggested Changes deferred to user — if any>
```

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 `blocked: needs revision` 으로 prefix.

세부 finding 본문을 응답에 풀어 쓰지 말고 GAP report 경로로 안내 — main context 절약. 사용자가 원하면 직접 읽는다.

## 6. Terminology and tone pass

§5 응답을 caller 에게 보내기 *직전에* 실행한다. 실행 순서는 §4 (수정 반영) → §6 (용어·톤 정리) → §5 (응답 송신) 이다.

작성한 agent `.md` 전체를 한 번 더 읽고 용어·톤을 통일한다. 본 pass 는 *표현만* 정리하며 의미 변경이나 새 finding 도입은 §3 GAP 분석에서 처리할 일이다.

### 체크 항목

- **개념 일관성** — 같은 개념을 같은 표현으로 사용한다. 동의어 혼용 (예: "review" / "audit" / "검토" 혼재, "drift" / "deviation" / "벗어남" 혼재) 은 호출자 혼선을 만든다.
- **persona 일관성** — 본문 시작의 persona ("You are …" / "너는 …") 와 이후 섹션의 1인칭/3인칭이 일치하는가? mid-body 에서 persona 가 바뀌면 Persona drift 안티패턴.
- **본문 단일 언어** — trigger 다국어는 description 에서만. 본문은 한 언어로 통일. 도메인 용어·tool 이름·enum 값만 영어 유지 (예: `Read`, `Edit`, `Bash`, `NEEDS_INPUT`, `OUT_OF_SCOPE`, severity `P0`).
- **구어적 표현 제거** — "떨어뜨리다", "부서지다", "잡지 못함" 같은 구어체는 spec 톤의 평서체로 정리한다 (예: "저장하다", "실패하다", "적절히 평가하지 못함").
- **불필요하게 강한 표현 완화** — heuristic 을 hard rule 로 표기하지 않는다. CONSTITUTION §3.8 의 원칙대로 강한 표현은 *실제 gate* 에 한정 (도구 차단, 승인 게이트, escalation contract, 안전).
- **escape contract 명시** — `NEEDS_INPUT: <reason>` / `OUT_OF_SCOPE: <reason>` 같은 escalation 키워드가 일관되게 쓰이는가? 출력 형식과 어긋나면 caller 가 파싱 못 한다.
- **긴 조건 종속문 분리** — 한 문장에 조건·이유·예외가 모두 들어가면 2–3 문장으로 나눈다. 한 문장 = 한 주장이 원칙.

### 산출

본 pass 가 완료되면 agent `.md` 의 표현이 통일된다. 자산 의미는 §4 종료 시점과 동일해야 한다 — 의미가 바뀌었다면 §3 GAP 분석으로 되돌아간다.

본 pass 자체는 응답에 별도 보고하지 않는다. §5 응답의 `gap` 필드가 PASS / PASS_WITH_NOTES 인 한 표현 정리는 *전제 조건* 으로 처리한다.

## Mini example

**요청**: "PR diff 만 보고 한국어 코멘트 리뷰 결과만 내는 에이전트, 자동 수정 안 함."

- **§0–§2 Draft** — scope: project, path `<repo>/.claude/agents/pr-comment-reviewer.md`. responsibility: PR diff 한국어 코멘트 리뷰. triggers: 사용자가 한국어 PR 리뷰 요청. negative: 멀티 에이전트 PR 리뷰 (`pr-review-toolkit:review-pr`) / 외부 모델 (`codex-reviewer`). output: severity + 한 줄 코멘트 + confidence ≥80. tools: `Read, Grep, Glob, Bash`. model: `sonnet`. persona: "너는 한국어 PR 코멘트 리뷰어다" + 명시적 "do not apply fixes, do not provide paste-ready patches".
- **§3 GAP 분석 round 1 (위임)** — `REVISE_ASSET`. P1: scope 의 pre-existing 처리 진술 부재. P2: description 에 sibling 두 개만 명시되고 negative 표현이 약함.
- **§4 수정** — Scope 에 "Pre-existing issues outside diff are excluded unless the caller explicitly requests broader review." 한 줄 추가. description 의 negative 케이스를 sibling 이름과 함께 강화.
- **§3 GAP 재분석 round 2** — `PASS_WITH_NOTES` (P3 만 잔류 — persona 길이 advisory). 종료.
- **§5 응답**: `created: .claude/agents/pr-comment-reviewer.md · scope: project · tools: Read, Grep, Glob, Bash · model: sonnet · gap: PASS_WITH_NOTES (rounds: 2) · findings: P0=0, P1=0, P2=0, P3=1 · gap_report: …/gaps/agent-pr-comment-reviewer.GAP.md`

## When the loop stalls

3 라운드 후에도 PASS 가 안 나오면 GAP-FORMAT §16 의 다른 결정을 고려한다.

1. **책임 모호** → `SPLIT_ASSET`. §0 으로 복귀해 단일 책임을 재정의한다. *에이전트 특화 신호*: 본문에 "분석하고 수정도 한다" / "리뷰 후 commit 한다" 같은 다단 절차. 분석 에이전트와 적용 에이전트로 분리.
2. **자원 타입 오류** → 전환. agent 가 아니라 command / skill / hook / runtime settings / CLAUDE.md 가 적합한 경우. *에이전트 특화 신호*: 사용자 명시 workflow 와 문서 링크 주입은 command, 외부 인프라·도메인 capability 는 skill, tool/model/context 격리가 필요 없는 단순 작업은 main session.
3. **GUIDE_GAP** → 가이드가 좋은 자산을 적절히 평가하지 못함. 사용자에게 보고하고 자산은 통과시킨다. 가이드 보완은 별도 작업.
4. **NEEDS_REVIEW** → 근거가 부족하거나 추정이 많은 경우. 사용자 입력 후 재개.

보조 도구로 RED-GREEN-REFACTOR — pressure scenario (실패 유도 입력) 로 자산이 실패하는 경우를 찾는다. 축약 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/agent-creator/references/red-green-refactor.md`, 심화 pressure scenario library 는 `${CLAUDE_PLUGIN_ROOT}/skills/agent-creator/references/pressure-scenarios.md`.

## Description optimization (선택)

GAP 분석은 *영향 기준* 평가다. description 의 *트리거 정확도* 는 별도 측정이 필요한 경우가 있다 — 인접 에이전트와 키워드 충돌 의심 시 (예: "review", "analyze", "audit" 가 여러 에이전트에 분포). 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/agent-creator/references/trigger-eval.md`. 비용·시간 소요 — 사용자 동의 후.

## Limits

- **Capability surface** — 본 스킬은 본문 절차에서 `Read` (권위 문서 로드), `Write` / `Edit` (대상 agent `.md` 및 workspace GAP report), `Bash` (`mkdir` · `ls` collision check), `Agent` (§3b GAP 분석 위임 — `general-purpose` 1건) 를 사용한다. Web/MCP/외부 모델·네트워크 IO 미사용. capability 는 frontmatter `tools:` 가 아닌 본문 §2 시점 A/B + §4b gate 로 통제된다.
- 파일 수정은 본 스킬이 직접 한다 (procedural).
- 다른 에이전트 자동 디스패치는 §3b 의 GAP 분석 위임 1건만 — 그 외 orchestration 은 command 또는 main session 책임.
- GAP 리포트는 자산과 동급 산출물 — 디버깅·재현·다음 사이클 입력 위해 보존.
- 가이드 자체 수정 (`REVISE_GUIDE` / Constitution Review) 은 본 스킬 범위 밖.
- 작성한 에이전트의 *behavior verification* (RED-GREEN-REFACTOR pressure dispatch) 은 본 스킬의 의무가 아니라 *선택* — 호출자가 명시적으로 요청하거나 §When the loop stalls 의 보조 도구로 사용. `references/red-green-refactor.md` 의 Iron Law 가 강하게 권장하나 본 스킬은 *작성·GAP 통과* 까지 책임.
