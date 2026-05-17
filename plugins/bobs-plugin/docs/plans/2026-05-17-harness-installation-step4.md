# Harness Installation — Step 4 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 신규 `evaluation-loop-design` skill 을 `skill-creator` 로 작성. 본 스킬은 *자체 작성* 패턴 (creator dispatch 없음 — `context-map-architecture` 와 동일 계열) 으로 `docs/agent/` 검증 인프라 (`roles.md` body / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md`) 를 설계 + 작성한다. workflow doc §3.3 placeholder 채우고, 5 sibling skill 의 cross-reference 갱신.

**Architecture:** skill-creator 가 새 skill 의 SKILL.md 와 GAP 사이클을 처리. references/ 4개 (각 `docs/agent/*.md` 파일 작성 절차) 는 main session 이 §2 SKILL.md draft 직후 mini-gate 거쳐 직접 작성. workflow doc §3.3 갱신 후 5 sibling skill cross-ref 일괄 정리. 본 Step 은 *흡수 대상 자산이 없는 신규 작성* 이므로 deprecation 작업 없음.

**Tech Stack:** skill-creator skill (메타 스킬, interactive), Edit/Write tools, agent-skill-auditor (참고 자산 — §8 Asset Disposition)

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §4.3 (evaluation-loop-design 책임) + §7 Step 4 + §8 Asset Disposition (agent-skill-auditor — evaluation-loop-design 의 reference)

**전체 migration 중 위치:** Step 4 of 7. Step 1 (doc split) + Step 2 (context-map-architecture) + Step 3 (resource-design) 완료된 상태에서 진행. Step 5-7 은 후속 별도 plan.

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md` | Create (skill-creator §2) | 검증 인프라 설계 + 작성 (3-phase: Inventory & Inspect / Verification Plan / Apply) |
| `plugins/bobs-plugin/skills/evaluation-loop-design/references/roles-write.md` | Create (main session) | `docs/agent/roles.md` body 작성 절차 (role inventory / 책임 한 줄 / 페어 매핑) |
| `plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md` | Create (main session) | `docs/agent/evaluation-loop.md` 작성 절차 (loop 구조 / 진입·종료 조건 / 라우팅 결정 표) |
| `plugins/bobs-plugin/skills/evaluation-loop-design/references/golden-set-write.md` | Create (main session) | `docs/agent/golden-set.md` 작성 절차 (작업 유형 후보 / case 선정 기준 / no-op·blocked 표면 정의) |
| `plugins/bobs-plugin/skills/evaluation-loop-design/references/task-log-template-write.md` | Create (main session) | `docs/agent/task-log-template.md` 작성 절차 (entry schema / 필드별 의미 / 보존 정책) |
| `plugins/bobs-plugin/skills/evaluation-loop-design-workspace/gaps/skill-evaluation-loop-design.GAP.md` | Create (skill-creator §3) | GAP report |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (§3.3 채움) | "TBD per Step 4" → 실제 내용 |
| `plugins/bobs-plugin/.claude-plugin/plugin.json` | Edit (description) | evaluation-loop-design 추가 |
| `.claude-plugin/marketplace.json` | Edit (description) | 동일 |
| `README.md` | Edit (file tree + skill 표 + namespace) | evaluation-loop-design 추가 |
| `plugins/bobs-plugin/agents/agent-skill-auditor.md` | Edit (1곳 추가 — description Do NOT) | evaluation-loop-design 라우팅 명시 (정적 감사 vs 평가 인프라 설계 분리). plan 작성 시점 grep: 0 곳 |
| `plugins/bobs-plugin/skills/resource-design/SKILL.md` | 검증만 (5곳 이미 존재 — line 3 / 21 / 70 / 152 / 158) | placeholder 표기 (`(예정)` 등) 없음 확인. Edit 0 곳 예상 |
| `plugins/bobs-plugin/skills/resource-design/references/intent-capture.md` | 검증만 (1곳 이미 존재 — line 23 escape hatch) | placeholder 표기 없음 확인. Edit 0 곳 예상 |
| `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` | Edit (1곳 — line 27 `(예정)` 표기 제거) | line 4 (description) + line 27 (When NOT) 이미 존재. line 4 routing 자체는 그대로, line 27 의 `(예정)` placeholder 만 제거 |
| `plugins/bobs-plugin/skills/skill-creator/SKILL.md` | Edit (1곳 추가 — When NOT) | evaluation-loop-design 라우팅 명시. plan 작성 시점 grep: 0 곳 |
| `plugins/bobs-plugin/skills/agent-creator/SKILL.md` | Edit (1곳 추가 — When NOT) | evaluation-loop-design 라우팅 명시. plan 작성 시점 grep: 0 곳 |
| `plugins/bobs-plugin/skills/hook-creator/SKILL.md` | Edit (1곳 추가 — When NOT) | evaluation-loop-design 라우팅 명시. plan 작성 시점 grep: 0 곳 |

**유지** (변경 없음):
- `plugins/bobs-plugin/agents/agent-skill-auditor.md` — 본 Step 의 신규 skill 의 *reference asset* (§8 Asset Disposition). 본문은 그대로, When NOT 한 줄 routing 추가만.
- `plugins/bobs-plugin/skills/claude-automation-recommender/` — vendored Apache-2.0. 본 Step 과 무관.
- `plugins/bobs-plugin/third_party_licenses/` 모든 LICENSE 파일 — 변경 없음.

**deprecation 없음**: 본 Step 의 신규 skill 은 흡수 대상 기존 자산이 없다. v1/v2 archive (`references/v1/`, `references/v2/`) 에 evaluation-loop 관련 historical artifact 가 있으나 *snapshot* 이며 활성 자산이 아님.

---

## Note on TDD for skill creation

skill-creator 자체가 GAP-driven (draft → 분석 → 수정 → 재분석) 사이클이므로 본 plan 의 Task 2 는 *외부* TDD 가 아닌 *skill-creator 내부* GAP loop 에 의존한다. Task 3 (workflow doc) 와 Task 4 (cross-ref 갱신) 는 doc 작업이라 *verify-baseline → change → verify-result → commit* 패턴.

## Note on "묻지 말고 진행" 모드 (mini-gate 약화)

본 plan 의 mini-gate (Task 2 Step 2 `(0)` 항목) 는 CONSTITUTION §3.3 Effects Require Gates 의 *approval* 을 요구하는 강한 형태가 default. 다만 사용자가 *묻지 말고 진행* (pre-approved batch) 모드를 사전 합의한 경우 mini-gate 는 *disclosure-only* (5 항목을 응답에 기록하되 확인 없이 진행) 로 약화된다. 본 plan 은 그 약화를 plan 단위로 합의한 것으로 간주한다 — Task 2 의 references 5개 write 가 silent execution 으로 보여도 의도된 동작이다.

호출자가 강한 gate 를 원하면 본 plan 실행 *전* `묻지 말고 진행` 합의를 철회하면 된다. mini-gate 5 항목은 양 모드 모두에서 응답에 기록되어 사후 audit 가능.

---

### Task 1: skill-creator 호출 준비 — intent brief

**Files:**
- (편집 없음 — preparation only)

skill-creator §0 Capture Intent 가 사용자에게 묻기 전, main session 이 intent 를 사전 정리해 한 번에 제공한다. 본 Task 는 정보 추출만 — commit 없음.

- [ ] **Step 1: 기존 자료 확인 (흡수 대상 없음, 참조 source 식별)**

본 skill 은 흡수 대상이 *없다* (Step 3 의 `harness-resource-design` 같은 deprecated 자산 부재). 대신 다음 normative source 를 참조 자료로 정리:

| 참조 source | 사용 위치 |
|---|---|
| `plugins/bobs-plugin/references/harness-principles.md` (§4.1 docs 책임 / §4.5 context-map / §4.7 자산 선택) | references 작성 시 검증 인프라 정의 기준 |
| `plugins/bobs-plugin/references/harness-principles.md` (line 294 task-log-capture / line 381 evaluation-loop.md 인용) | task-log-template-write.md / evaluation-loop-write.md 가이드 |
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §4.3 | 본 skill 책임 정의 (`docs/agent/` 검증 인프라 작성) |
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §4.4 (`evaluation-loop-runner`) | 본 skill 산출물 (`evaluation-loop.md` / `task-log-template.md`) 이 runtime 에서 어떻게 소비되는지 |
| `plugins/bobs-plugin/agents/agent-skill-auditor.md` | 정적 감사 vs 평가 인프라 설계 분리 — references 의 cross-ref |
| `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` + `references/agents-md-write.md` 등 4 references | *자체 작성 스킬* 의 references 패턴 (각 파일별 write 절차) precedent |

본 skill 의 *자체 작성* 패턴은 `context-map-architecture` 와 동일 — 4개 *write* references 가 각 산출 파일 절차를 정의한다.

- [ ] **Step 2: skill-creator §0 답안 정리 (메모리만)**

| # | skill-creator §0 질문 | 답 |
|---|---|---|
| 1 | 재사용 책임 (한 문장) | `docs/agent/` 검증 인프라 (`roles.md` body / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md`) 를 *설계 + 작성* — 현재 docs/agent 인벤토리 진단 후 누락 인프라를 묶어 Verification Plan 으로 산출하고 사용자 승인 후 직접 파일 write |
| 2 | 트리거 (1-3개) | "검증 인프라", "task log", "golden-set", "evaluation loop", "평가 사이클 셋업", "역할 정의 (`docs/agent/roles.md`)" |
| 3 | Negative trigger (≥1) | 정적 rule 감사 (P0/P1/P2 + rule ID + confidence — `agent-skill-auditor`), 자원 타입 결정 (`resource-design`), docs-tree 인덱스/라우팅 (`context-map-architecture`), 자원 본문 작성 (creator skills), runtime task log 캡처·라우팅 (`evaluation-loop-runner` — Step 5), 코드/PR 리뷰 |
| 4 | 호출자가 산출물로 무엇을 하나 | Verification Plan 검토 → 승인 → 본 스킬이 `docs/agent/` 4개 파일을 직접 write. main session 은 `Applied Changes` 목록 + follow-ups (예: 역할 정의에 필요한 자원 부재 → resource-design / context-map 갱신 필요 → context-map-architecture) 로 후속 design skill dispatch |
| 5 | 부수 효과 | 파일 작성 *있음* — `docs/agent/roles.md` (body) / `docs/agent/evaluation-loop.md` / `docs/agent/golden-set.md` / `docs/agent/task-log-template.md`. workspace 디렉토리 (GAP report 저장) 도 생성. Effect gate 이중 — 1단계 (design): Verification Plan 사용자 승인 / 2단계 (apply): 각 파일 write 직전 경로·종류·요약 1회 확인 (CONSTITUTION §3.3) |
| 6 | scope | plugin (`plugins/bobs-plugin/skills/evaluation-loop-design/`) |

- [ ] **Step 3: skill-creator 첫 메시지 한 줄 brief 작성**

skill-creator 호출 시 사용자 첫 메시지로 전달할 single-shot brief (의도 캡처 비용 절감):

```
name: evaluation-loop-design
scope: plugin (plugins/bobs-plugin/skills/evaluation-loop-design/)
책임: docs/agent/ 검증 인프라 (roles.md body / evaluation-loop.md / golden-set.md /
  task-log-template.md) 의 *설계 + 작성*. 자체 작성 스킬 (context-map-architecture
  와 동일 계열) — creator dispatch 없이 본 스킬이 직접 파일 write.
트리거: "검증 인프라", "task log", "golden-set", "evaluation loop",
  "평가 사이클 셋업", "역할 정의 (docs/agent/roles.md)"
negative: 정적 rule 감사 (P0/P1/P2 + rule ID — agent-skill-auditor),
  자원 타입 결정 (resource-design), docs-tree 인덱스/라우팅 (context-map-architecture),
  자원 본문 작성 (creator skills), runtime task log 캡처·라우팅 (evaluation-loop-runner
  — Step 5 별도), 코드/PR 리뷰
spec format: Inventory + Gaps + Verification Plan + Applied Changes (spec_version v1,
  workflow doc §4 표준 인터페이스 — Plan + Execution Plan 자체 작성 패턴 변형)
effect gate: 이중 — 1단계 (design) Verification Plan 사용자 승인 + 2단계 (apply)
  각 파일 write 직전 경로·종류·요약 1회 확인 (CONSTITUTION §3.3). 본 스킬이 직접
  파일 write 하므로 spec dispatch 가 아닌 자체 작성 패턴.
references 4개 (main session 이 §2 SKILL.md draft 직후 mini-gate 거쳐 직접 작성,
  context-map-architecture references 4개와 동일 패턴):
  - references/roles-write.md (~100-150 lines)
  - references/evaluation-loop-write.md (~120-180 lines)
  - references/golden-set-write.md (~100-150 lines)
  - references/task-log-template-write.md (~100-150 lines)
참고 자산 (변경 없음): agent-skill-auditor (§8 Asset Disposition — 정적 감사 도구,
  본 스킬의 평가 인프라가 호출하는 reference subagent)
관련 normative source (직접 참조, 본문 재생산 금지):
  - ${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md §4.1 / §4.5 / §4.7
  - ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md §3 (10개 design principle)
  - ${CLAUDE_PLUGIN_ROOT}/references/GAP-FORMAT.md (golden-set 의 평가 형식 기준)
```

본 brief 는 Task 2 Step 1 에서 skill-creator 호출 시 입력.

---

### Task 2: skill-creator 로 신규 skill 작성 + references 직접 작성 (Step 4a/4b)

**Files:**
- Create (skill-creator §2): `plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/evaluation-loop-design/references/roles-write.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/evaluation-loop-design/references/golden-set-write.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/evaluation-loop-design/references/task-log-template-write.md`
- Create (skill-creator §3a): `plugins/bobs-plugin/skills/evaluation-loop-design-workspace/gaps/skill-evaluation-loop-design.GAP.md`

- [ ] **Step 1: skill-creator 호출 (intent 사전 제공)**

호출:

```
/skill-creator
```

첫 메시지: Task 1 Step 3 의 brief block 그대로 붙여넣기.

skill-creator §0 → §1 → §2 자체 흐름 진행. §2 시점 A gate (첫 파일 작성 전, SKILL.md 경로 + frontmatter + 본문 골격 + workspace 경로 제시) 에서 사용자 명시 승인.

예상 SKILL.md 구조 (skill-creator §2 가 SKILL-GUIDE.md 표준 골격 적용 + `context-map-architecture` 의 자체 작성 패턴 차용):

- Frontmatter: `name: evaluation-loop-design`, description (trigger + Do NOT 명시), `user-invocable: true`
- `# Evaluation Loop Design`
- `## When to Use` + `## When NOT to Use`
- `## Capability Procedure`
  - `### Phase 1: Inventory & Inspect` — 현재 `docs/agent/` 검증 자산 + 프로젝트 작업 유형 (golden-set 채울 후보) + 기존 task log 패턴
  - `### Phase 2: Verification Plan (Effect gate — design 단계)` — Verification Plan 4 섹션 (Inventory / Gaps / Verification Plan / Applied Changes) 생성 + 사용자 승인
  - `### Phase 3: Apply (Effect gate — apply 단계)` — 각 파일 write 직전 경로·종류·요약 1회 확인 → 직접 파일 write → Applied Changes 갱신
- `## Output Contract` — Verification Plan 형식 + `mode: no-op` / `mode: needs_input` 케이스
- `## Common Failures`
- `## References` — roles-write.md / evaluation-loop-write.md / golden-set-write.md / task-log-template-write.md 인용 + normative source 직접 참조 (`${CLAUDE_PLUGIN_ROOT}/references/`)

- [ ] **Step 2: references 작성 (skill-creator §2 SKILL.md draft 완료 직후, §3 GAP 분석 진입 전)**

skill-creator §2 의 SKILL.md 첫 쓰기가 끝난 시점에서 main session 이 직접 references 를 작성한다. skill-creator 의 시점 A gate 는 SKILL.md 1개 경로만 다루므로 (CONSTITUTION §3.3 effect gate 가 references 에는 적용되지 않는 누수 위험), main session 이 *별도 mini-gate* 를 거친다.

**(0) Mini-gate — references write 직전 사용자 승인** *(Step 2 plan + Step 3 plan precedent 동일)*

각 references 파일을 쓰기 전에 다음 5가지를 한 묶음으로 사용자에게 제시한다 (CONSTITUTION §3.3 Effects Require Gates 의 본 plan 내 적용):

| 항목 | 내용 |
|---|---|
| 작성 경로 | 4개 절대 경로 (`roles-write.md` / `evaluation-loop-write.md` / `golden-set-write.md` / `task-log-template-write.md`) |
| Source 자료 | 흡수 대상 없음 (신규 작성). normative source = `harness-principles.md` §4.1 / §4.5 / §4.7 + `CONSTITUTION.md` §3 + `GAP-FORMAT.md` (vocabulary borrow only — Severity 어휘만 재사용, GAP report 본문 형식 재사용 아님) + `docs/specs/2026-05-17-harness-installation-design.md` §4.3 / §4.4 |
| Target length | 각 파일 예상 줄 수 (100-250 / 150-300 / 100-250 / 100-250) — context-map-architecture references 4개 (132 / 276 / 291 / 343) 의 평균 ~260 을 precedent 로 *상한 완화*. 하한은 template + Phase 1/2/3 + Effect gate + Common Failures 최소 묶음 기준. 상한 초과 시 본문 prose drift 검토 권장 — hard limit 아님 |
| License / attribution | 모두 MIT in-house (신규 작성) — attribution 헤더는 *normative source 인용* 만 한 줄 표기 |
| 작성 정책 | 각 reference 는 *해당 docs/agent 파일 작성 절차* (template + 검증 + Effect gate apply 단계 절차) 를 정의. 본문 재생산 금지 — harness-principles / CONSTITUTION 의 규칙은 index 로 인용. 산출물 자체 (`docs/agent/*.md`) 의 template + 채우기 가이드를 정의 |

사용자 명시 승인 (`go` / `proceed` / `진행`) 후 (a)-(d) 의 파일 write 로 진행. 사전 합의된 *묻지 말고 진행* 모드에서는 확인 없이 진행하되 본 mini-gate 의 5 항목은 응답에 기록.

**(a) `references/roles-write.md` 작성**

source: 없음 (신규)
target length: 100-250 lines (상한 완화 — precedent claude-md-write.md = 132, 본 reference 는 page lighter 라 ~150 예상하되 250 까지 허용)
content outline:

1. 헤더 (출처: 본 plan, MIT in-house — normative source 인용: `harness-principles.md` §4.1 docs 책임)
2. Phase 1 Inspect — 현재 자원 인벤토리 (skill / agent / hook / command) 와 작업 유형 매핑
3. Phase 2 Draft — `docs/agent/roles.md` template (role 한 줄 / 페어 / 입력 / 산출 / 실패 표면)
4. Phase 3 Effect gate — 본문 write 직전 mini-gate (path / role 수 / 매핑 표 요약)
5. Common Failures — role inflation / 모든 자원에 role 매핑 강제 / 실제 작업 흐름과 무관한 role 발명

헤더:

```markdown
# Roles Write — docs/agent/roles.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/roles.md` body.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.1 (Docs 책임) + §4.7 (자산 선택 기준). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(b) `references/evaluation-loop-write.md` 작성**

source: 없음 (신규)
target length: 150-300 lines (상한 완화 — precedent docs-tree-write.md = 343, 본 reference 는 Routing Decision 표 + 4 sibling skill 환원 경로 + 종료 조건 4종까지 담아야 해서 300 까지 합리)
content outline:

1. 헤더 (출처: 본 plan, MIT in-house — normative source 인용: `harness-principles.md` §4.5 context-map + spec §4.4 evaluation-loop-runner)
2. Phase 1 Inspect — 기존 `docs/agent/evaluation-loop.md` 가 있는지 + 현재 사이클 패턴 (수동 / 자동 chain)
3. Phase 2 Draft — `docs/agent/evaluation-loop.md` template
   - 진입 조건 (사용자 작업 종료 / 명시 호출 / `evaluation-loop-runner` 자동 chain)
   - 사이클 단계 (task log 캡처 → gap 분석 → 라우팅 결정 → 다음 design skill 진입)
   - 종료 조건 (Routing Decision no-op / 사용자 명시 종료 / 같은 design skill 2회 연속 / 누적 5회 초과)
   - Routing Decision 표 (docs → context-map-architecture / 자원 → resource-design / 평가 인프라 → 본 skill / 정적 감사 → agent-skill-auditor)
4. Phase 3 Effect gate — 본문 write 직전 mini-gate
5. Common Failures — 무한 사이클 / 사용자 명시 종료 무시 / Routing Decision 누락 (어디로 환원해야 할지 모름) / golden-set 미연결 (사이클이 실패 정의 없음)

헤더:

```markdown
# Evaluation Loop Write — docs/agent/evaluation-loop.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/evaluation-loop.md`.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.5 (context-map 라우팅) + `${CLAUDE_PLUGIN_ROOT}/docs/specs/2026-05-17-harness-installation-design.md` §4.4 (`evaluation-loop-runner` runtime 동작). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(c) `references/golden-set-write.md` 작성**

source: 없음 (신규)
target length: 100-250 lines (상한 완화 — precedent context-map-write.md = 276)
content outline:

1. 헤더 (출처: 본 plan, MIT in-house — normative source 인용: `harness-principles.md` §4.7 자산 선택 기준 + `GAP-FORMAT.md` Severity)
2. Phase 1 Inspect — 프로젝트 작업 유형 후보 (이미 발생한 task log + harness-principles §4.7 사례 표) + 기존 golden-set 여부
3. Phase 2 Draft — `docs/agent/golden-set.md` template
   - case 선정 기준 (자주 발생 / 실패가 비싼 / 라우팅 모호 / Severity P0-P1 회귀 위험)
   - case 항목 schema (id / 작업 유형 / 입력 예시 / 기대 산출 / 실패 표면 정의 / 라우팅 정답)
   - no-op / blocked 표면 명시 — golden-set 은 *PASS* 만 정의하지 않음
   - 보존 정책 (각 case 의 source PR / 작업 일시 / 회고)
4. Phase 3 Effect gate — 본문 write 직전 mini-gate
5. Common Failures — case 와 자원 미연결 / PASS only (no-op / blocked 미정의) / 너무 많은 case (10건 초과 시 maintenance 부담) / case 가 *실제 발생* 작업과 무관한 toy 예제

헤더:

```markdown
# Golden Set Write — docs/agent/golden-set.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/golden-set.md`.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.7 (자산 선택 기준) + `${CLAUDE_PLUGIN_ROOT}/references/GAP-FORMAT.md` §7 (Severity). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(d) `references/task-log-template-write.md` 작성**

source: 없음 (신규)
target length: 100-250 lines (상한 완화 — precedent agents-md-write.md = 291)
content outline:

1. 헤더 (출처: 본 plan, MIT in-house — normative source 인용: `harness-principles.md` line 294 task-log-capture pair)
2. Phase 1 Inspect — 기존 task log (`docs/agent/logs/`) 가 있는지 + 현재 PR / commit / 회고가 어디 기록되는지 (보존 위치 식별)
3. Phase 2 Draft — `docs/agent/task-log-template.md` template
   - entry schema (date / 작업 유형 / 호출 자원 / 참조 문서 / 실행 명령 / 산출 / 실패 원인 / 회고 한 줄)
   - 보존 정책 (`docs/agent/logs/YYYY-MM-DD-*.md` 파일명 규칙)
   - golden-set 과의 연결 (log entry → golden-set case 후보)
4. Phase 3 Effect gate — 본문 write 직전 mini-gate
5. Common Failures — schema 일관성 부재 (필드 누락 / 추가) / 회고 누락 (왜 실패했는지가 가장 중요한 데이터) / golden-set 과 무관한 log (재진입 학습 신호 없음) / 너무 긴 entry (300 줄 초과 시 회고 흡수 어려움)

헤더:

```markdown
# Task Log Template Write — docs/agent/task-log-template.md 작성 절차

> 본 문서는 `evaluation-loop-design` skill 의 reference. 산출물: `docs/agent/task-log-template.md`.
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` line 294 (task-log-capture pair). 본 절차가 우선이며, 원문 규칙이 필요할 때만 normative source 직접 참조.
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

작성 후 각 references verify:

```bash
wc -l plugins/bobs-plugin/skills/evaluation-loop-design/references/*.md
```

Expected:
- roles-write.md ≈ 100-250 lines
- evaluation-loop-write.md ≈ 150-300 lines
- golden-set-write.md ≈ 100-250 lines
- task-log-template-write.md ≈ 100-250 lines

상한 초과 시 hard block 아님 — 본문 prose drift / 중복 정의 / template 과잉 여부 검토 권장. precedent: context-map-architecture references 4개 (132 / 276 / 291 / 343).

- [ ] **Step 3: skill-creator §3 GAP 분석 진행 (interactive) — references 까지 target 확장**

skill-creator 가 §3a 에서 workspace 생성:

```bash
mkdir -p plugins/bobs-plugin/skills/evaluation-loop-design-workspace/gaps
```

§3b (위임 권장) 또는 §3c (인라인) 로 GAP 분석.

**중요: skill-creator §3b 의 default 위임 prompt 는 분석 target 을 `<SKILL_PATH>/SKILL.md` 1개로 제한** (Step 2 plan 의 P1#2 precedent + Step 3 plan 의 동일 적용). 본 plan 의 references 4개는 *각 산출물의 핵심 절차* 이므로 SKILL.md 와 동일 수준의 GAP 적용 대상. main session 은 위임 prompt 의 target 목록을 다음 5개 경로로 *명시 확장* 한다:

```
분석 대상 (확장):
  - <SKILL_PATH>/SKILL.md
  - <SKILL_PATH>/references/roles-write.md
  - <SKILL_PATH>/references/evaluation-loop-write.md
  - <SKILL_PATH>/references/golden-set-write.md
  - <SKILL_PATH>/references/task-log-template-write.md
각 파일을 같은 GAP-FORMAT §9 형식으로 평가하고 finding 의 `evidence` 필드에 어느 파일의 어느 위치인지 명시한다.
```

분석 깊이:

- SKILL.md: 표준 skill GAP (activation / scope / output contract / effect gate / verification / overlap — 특히 sibling design skill 5종 + agent-skill-auditor 와의 차이 명확성)
- references 각각: 절차 완전성 (각 산출물의 Phase 1/2/3 + Common Failures 모두 포함) + length budget + Phase 3 mini-gate 일관성 (4 references 가 동일 형식) + template 의 *실제 사용 가능성* (placeholder 만 두고 끝나지 않음)
- 평가 인프라 *고유* 검증축 — golden-set 의 no-op/blocked 표면 정의 / task log schema 일관성 / evaluation-loop 의 종료 조건 명확성 (무한 루프 방지)

skill-creator §4 Final Decision 분기:

- `PASS` → §5 진행
- `PASS_WITH_NOTES` → 옵션 적용 후 §5
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침 — references 도 mini-gate 거침) 후 §3 재실행 (라운드 카운트 +1)
- 5 라운드 초과 → `NEEDS_REVIEW` 사용자 보고, 본 Task 일시 중단

- [ ] **Step 3b: references 완전성 audit (skill-creator GAP 외 추가 검증)**

skill-creator GAP 가 PASS 라도 *각 산출물의 template 누락* 은 잡지 못할 수 있음. 별도 audit:

```bash
echo "--- roles-write.md 절차 완전성 ---"
for kw in "Phase 1" "Phase 2" "Phase 3" "Effect gate" "Common Failures" "role" "template"; do
  grep -q "$kw" plugins/bobs-plugin/skills/evaluation-loop-design/references/roles-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- evaluation-loop-write.md 절차 완전성 ---"
for kw in "Phase 1" "Phase 2" "Phase 3" "Effect gate" "Common Failures" "진입 조건" "종료 조건" "Routing Decision"; do
  grep -q "$kw" plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- golden-set-write.md 절차 완전성 ---"
for kw in "Phase 1" "Phase 2" "Phase 3" "Effect gate" "Common Failures" "case 선정" "schema" "no-op" "blocked"; do
  grep -q "$kw" plugins/bobs-plugin/skills/evaluation-loop-design/references/golden-set-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- task-log-template-write.md 절차 완전성 ---"
for kw in "Phase 1" "Phase 2" "Phase 3" "Effect gate" "Common Failures" "entry schema" "보존 정책" "golden-set"; do
  grep -q "$kw" plugins/bobs-plugin/skills/evaluation-loop-design/references/task-log-template-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done
```

각 reference 모두 `ok` 만 나와야 한다. `MISSING:` 발견 시 해당 reference 보강 (§2 시점 B gate 거침) 후 audit 재실행.

- [ ] **Step 4: normative source 인용 일관성 audit**

각 reference 가 normative source 를 인용하는 패턴이 일관되어야 한다 (drift 방지):

```bash
echo "--- normative source 인용 (각 reference 헤더) ---"
grep -l "Normative source" plugins/bobs-plugin/skills/evaluation-loop-design/references/*.md
# Expected: 4 files
```

본문 안에서도 GUIDE 규칙을 재생산하지 않고 *index* 로 인용해야 한다 (Step 3 plan 의 `decision-rules.md` index-only 패턴 동일):

```bash
echo "--- GUIDE 본문 재생산 여부 (heuristic 검사) ---"
for f in plugins/bobs-plugin/skills/evaluation-loop-design/references/*.md; do
  echo "=== $f ==="
  # CONSTITUTION 본문 단어 다수 등장 = drift 위험
  count=$(grep -c "CONSTITUTION §" "$f" 2>/dev/null || echo 0)
  echo "  CONSTITUTION § 참조: $count (정상: 1-3)"
done
```

다수 (4+) 등장 시 본문 재생산 의심 — 해당 reference 검토.

- [ ] **Step 5: 본 skill 의 reference 자산 (agent-skill-auditor) 인용 위치 검증**

evaluation-loop-design 은 정적 감사 도구로 `agent-skill-auditor` 를 reference 로 둔다 (§8 Asset Disposition). SKILL.md / references 안에서 *어디서* 어떻게 인용되는지 명시:

```bash
echo "--- agent-skill-auditor 인용 위치 ---"
grep -n "agent-skill-auditor" \
  plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md \
  plugins/bobs-plugin/skills/evaluation-loop-design/references/*.md 2>/dev/null
```

Expected:
- SKILL.md: 1-2 곳 (When NOT 섹션 — 정적 감사는 본 스킬이 아님 / Common Failures 의 *agent-skill-auditor 결과 무시* 항목)
- references/evaluation-loop-write.md: 1 곳 (Routing Decision 표의 *정적 감사 필요* 행)

`MISSING` 또는 0 등장 시 §2 시점 B gate 거쳐 추가.

- [ ] **Step 6: 길이·구조 verify**

```bash
wc -l plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md \
       plugins/bobs-plugin/skills/evaluation-loop-design/references/*.md
```

Expected:
- SKILL.md ≈ 150-250 lines
- roles-write.md ≈ 100-250 lines
- evaluation-loop-write.md ≈ 150-300 lines
- golden-set-write.md ≈ 100-250 lines
- task-log-template-write.md ≈ 100-250 lines
- 총 references ≈ 450-1050 lines (context-map-architecture references 총합 1042 lines precedent)

- [ ] **Step 7: Commit — 신규 skill + references + GAP report**

```bash
git add plugins/bobs-plugin/skills/evaluation-loop-design/ \
        plugins/bobs-plugin/skills/evaluation-loop-design-workspace/

git commit -m "$(cat <<'EOF'
Add evaluation-loop-design skill (Step 4a/4b)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §4.3 + §7 Step 4

- skills/evaluation-loop-design/SKILL.md (Inventory & Inspect / Verification Plan / Apply 3-phase)
- references/roles-write.md (docs/agent/roles.md 작성 절차, MIT in-house)
- references/evaluation-loop-write.md (docs/agent/evaluation-loop.md 작성 절차, MIT in-house)
- references/golden-set-write.md (docs/agent/golden-set.md 작성 절차, MIT in-house)
- references/task-log-template-write.md (docs/agent/task-log-template.md 작성 절차, MIT in-house)
- workspace/gaps/ 의 GAP 리포트 — Final Decision PASS / PASS_WITH_NOTES

자체 작성 스킬 (context-map-architecture 와 동일 계열) — creator dispatch 없음.
참고 자산: agent-skill-auditor (§8 Asset Disposition — 정적 감사 도구).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: workflow doc §3.3 채움 (Step 4c)

**Files:**
- Modify: `plugins/bobs-plugin/references/harness-installation-workflow.md`

- [ ] **Step 1: Baseline 확인 — 현재 §3.3 placeholder 위치**

```bash
grep -n "^### 3\.\|^- 3\.\|TBD per Step\|^## 3\." plugins/bobs-plugin/references/harness-installation-workflow.md
```

Expected: `## 3. Phase 1 Design Skills` 헤더 + 기 채워진 §3.1 (resource-design) + 기 채워진 §3.2 (context-map-architecture) + line 142 `- 3.3 \`evaluation-loop-design\` (TBD per Step 4)` + §5 / §6 / §7 / §8 의 잔여 placeholder.

- [ ] **Step 2: §3 본문 갱신 — 3.3 하위 섹션 채움**

Edit:

- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/references/harness-installation-workflow.md`
- old_string:

```
- 3.3 `evaluation-loop-design` (TBD per Step 4)
```

- new_string:

```
### 3.3 `evaluation-loop-design`

**Trigger**:

- 사용자가 검증 인프라 (task log / golden-set / evaluation loop) 작성·정리 요청
- `docs/agent/roles.md` body 작성 요청 (context-map-architecture 는 seed 만 두고 본 skill 이 body 채움)
- 평가 사이클 셋업 ("얼마나 잘 동작하는지 측정 인프라 필요")
- Routing 표 §2 행: "검증 인프라", "task log", "golden-set"

**Inspect 도메인**:

- 현재 `docs/agent/` 검증 자산 (`roles.md` / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md` / `logs/`)
- 기존 `docs/agent/roles.md` (`context-map-architecture` 가 skeleton seed 한 상태일 수 있음 — 본 skill 은 *body* 만 채움). seed 가 없으면 first follow-up 으로 `context-map-architecture` 호출 권고. ownership 분리: context-map-architecture = skeleton/seed (파일 생성 + 헤더만), evaluation-loop-design = body (role 페어·책임 한 줄 채움). 같은 파일을 만지지만 단계가 다르다.
- 자원 inventory (`resource-design` 인벤토리 재사용 — role 매핑 source) — skill / agent / hook / command / runtime settings
- 프로젝트 작업 유형 — golden-set 채울 후보 (이미 발생한 task log + 사용자 발화의 작업 패턴)
- 기존 task log 패턴 (있다면 schema 진단)
- 참고 자산: `references/roles-write.md` (role 페어 + 매핑), `references/evaluation-loop-write.md` (loop 진입·종료 + Routing Decision), `references/golden-set-write.md` (case 선정 + no-op/blocked 표면), `references/task-log-template-write.md` (entry schema + 보존), normative source 직접 참조 (`${CLAUDE_PLUGIN_ROOT}/references/{harness-principles,CONSTITUTION,GAP-FORMAT}.md`), `agent-skill-auditor` (정적 감사 reference subagent — Routing Decision 표의 *정적 감사 필요* 행에서 호출)

**Spec format** (workflow doc §4 의 공통 인터페이스 적용 — context-map-architecture 와 동일 계열의 *자체 작성* 변형):

```markdown
# Harness Installation Spec — evaluation-loop

> Generated by: evaluation-loop-design
> Date: <iso8601>
> Trigger: <user request>
> spec_version: v1

## Inventory
## Gaps                     — 없는 검증 자산 + golden-set 누락 작업 유형 + task log schema 부재
## Verification Plan        — 작성/수정 항목 + 각 파일 골격 (roles.md body / evaluation-loop.md / golden-set.md / task-log-template.md)
## Applied Changes          — 실제 작성/수정한 파일 목록 (자체 작성 후 갱신)
```

`Verification Plan` 은 §4 표준 섹션의 `Plan` 변형, `Applied Changes` 는 `Execution Plan` 의 자체 작성 패턴 변형 (context-map-architecture 의 `Document Plan` / `Applied Changes` 와 동일 패턴).

**Effect gate** (이중):

- 1단계 (design): Verification Plan 사용자 검토 + 승인 (CONSTITUTION §3.3)
- 2단계 (apply): 각 파일 write 직전 경로·종류·요약 1회 확인 — `references/roles-write.md` Phase 3, `evaluation-loop-write.md` Phase 3, `golden-set-write.md` Phase 3, `task-log-template-write.md` Phase 3 의 각 절차

**Handoff**:

- 출력: Applied Changes 목록 + follow-ups (예: golden-set case 가 *실제 발생* task log 부재로 toy 예제 → 후속 task log 누적 후 case 갱신 / role 정의에 필요한 자원 부재 → `resource-design` 호출 / `docs/agent/context-map.md` 갱신 필요 → `context-map-architecture`)
- main session 은 follow-up 항목을 후속 design skill 입력으로 활용
- no-op: 기존 검증 인프라가 inventory 와 일치하고 누락 없음 → `mode: no-op`
- needs_input: `category: design | inventory` — design 은 golden-set case 선정 모호 (사용자 의도 캡처 질문), inventory 는 자원 inventory 미완 / 기존 task log 접근 불가 (환경 보완 요청). 호출자는 동일하게 사용자에게 질문하되 category 로 톤 분기

```

- [ ] **Step 3: Verify**

```bash
grep -c "^### 3\." plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 3 (3.1 + 3.2 + 3.3 모두 채워짐)

grep "^### 3.1\|^### 3.2\|^### 3.3" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 3 행 모두 존재

grep -c "TBD per Step" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 4 (§5 / §6 / §7 / §8 의 잔여 placeholder — Step 5/6/7 에서 채움)
```

- [ ] **Step 4: Commit**

```bash
git add plugins/bobs-plugin/references/harness-installation-workflow.md
git commit -m "$(cat <<'EOF'
Fill harness-installation-workflow §3.3 (evaluation-loop-design)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 4c

trigger / inspect / spec format / effect gate / handoff 5개 절. spec_version v1 명시.
Verification Plan + Applied Changes 가 §4 표준 섹션 (Plan + Execution Plan 의 자체 작성
변형) 임을 명시 — context-map-architecture 와 동일 계열의 자체 작성 패턴.
needs_input 의 category: design | inventory 분기 명시.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: 메타 파일 + 5 sibling skill cross-ref 갱신 (Step 4d)

**Files:**
- Modify: `plugins/bobs-plugin/.claude-plugin/plugin.json` (description)
- Modify: `.claude-plugin/marketplace.json` (description)
- Modify: `README.md` (file tree + skill 표 + namespace)
- Modify: `plugins/bobs-plugin/agents/agent-skill-auditor.md` (1 곳 — When NOT)
- Modify: `plugins/bobs-plugin/skills/resource-design/SKILL.md` (0-1 곳 — escape hatch placeholder 검증)
- Modify: `plugins/bobs-plugin/skills/resource-design/references/intent-capture.md` (0-1 곳 — escape hatch placeholder 검증)
- Modify: `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` (0-1 곳 — When NOT placeholder 검증)
- Modify: `plugins/bobs-plugin/skills/skill-creator/SKILL.md` (1 곳 — When NOT)
- Modify: `plugins/bobs-plugin/skills/agent-creator/SKILL.md` (1 곳 — When NOT)
- Modify: `plugins/bobs-plugin/skills/hook-creator/SKILL.md` (1 곳 — When NOT)

본 Task 는 *신규 자산 추가만* — deprecation 없음 (Step 3 의 Task 4 와 달리 흡수 대상 자산이 없음). 대부분의 sibling skill 은 *placeholder 로 이미 evaluation-loop-design 을 routing* 하고 있어 (Step 3 의 in-flight escape hatch 표 + When NOT 라인) baseline 검증 후 실제 자산이 존재함을 한 줄 보강하는 정도.

- [ ] **Step 1: Baseline 확인 — 활성 참조 위치**

```bash
echo "--- plugin meta ---"
grep -n "evaluation-loop-design" \
  plugins/bobs-plugin/.claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  README.md 2>/dev/null

echo "--- agents ---"
grep -n "evaluation-loop-design" \
  plugins/bobs-plugin/agents/agent-skill-auditor.md 2>/dev/null

echo "--- sibling skills (placeholder routing 이미 있을 것) ---"
grep -n "evaluation-loop-design" \
  plugins/bobs-plugin/skills/resource-design/SKILL.md \
  plugins/bobs-plugin/skills/resource-design/references/intent-capture.md \
  plugins/bobs-plugin/skills/context-map-architecture/SKILL.md \
  plugins/bobs-plugin/skills/skill-creator/SKILL.md \
  plugins/bobs-plugin/skills/agent-creator/SKILL.md \
  plugins/bobs-plugin/skills/hook-creator/SKILL.md 2>/dev/null
```

Expected baseline (확정 — plan 작성 시점 grep 결과):

| 파일 | 기존 곳 수 | 위치 (line) | Step 4 작업 |
|---|---|---|---|
| `plugin.json` | 0 | — | description 안에 1 곳 추가 |
| `marketplace.json` | 0 | — | description 안에 1 곳 추가 |
| `README.md` | 0 | — | file tree + skill 표 + namespace 3-4 곳 추가 |
| `agent-skill-auditor.md` | 0 | — | description Do NOT 절에 1 곳 추가 |
| `resource-design/SKILL.md` | **5** | 3 (description) / 21 (When NOT) / 70 (Phase 2 escape hatch) / 152 (Common Failures) / 158 (Verification) | placeholder 검증만 — 모두 실제 자산 가리키므로 Edit 0 곳 예상 |
| `resource-design/references/intent-capture.md` | **1** | 23 (escape hatch 표 `OUT_OF_SCOPE_EVAL`) | placeholder 검증만 — Edit 0 곳 예상 |
| `context-map-architecture/SKILL.md` | **2** | 4 (description) / 27 (When NOT `(예정)` placeholder) | line 27 의 `(예정)` 표기 제거 — Edit 1 곳 |
| `skill-creator/SKILL.md` | 0 | — | When NOT 절에 1 곳 추가 |
| `agent-creator/SKILL.md` | 0 | — | When NOT 절에 1 곳 추가 |
| `hook-creator/SKILL.md` | 0 | — | When NOT 절에 1 곳 추가 |

본 baseline 은 plan 작성 시점의 정확한 grep 결과. 실행 시점에 다른 commit 으로 변경되었을 수 있으므로 Step 1 의 baseline grep 을 재실행해 표 와 일치 여부 확인.

- [ ] **Step 2: `plugin.json` description 갱신**

read 후 description 필드 확인:

```bash
cat plugins/bobs-plugin/.claude-plugin/plugin.json
```

Edit (description 안에 evaluation-loop-design 추가). 기존 resource-design / context-map-architecture / creator skills 와 동일 어법으로 한 행 삽입. 정확한 old/new 는 baseline 결과 확인 후 결정.

- [ ] **Step 3: `marketplace.json` description 동일 갱신**

`.claude-plugin/marketplace.json` 의 description 도 plugin.json 과 동일 어법 (Step 3 의 wording-coordination precedent — 두 메타 파일 동기 유지).

- [ ] **Step 4: `README.md` 4 곳 갱신**

read 후 정확한 행 식별:

```bash
grep -n "context-map-architecture\|resource-design\|skill-creator" README.md | head -30
```

수정 위치:
- file tree (`plugins/bobs-plugin/skills/` 디렉토리 표시) — `evaluation-loop-design` 행 추가
- skill 표 — `evaluation-loop-design` 행 추가 (책임 / scope / 트리거)
- namespace 단락 — evaluation-loop-design 한 줄 설명 추가
- (선택) migration notes — Step 4 신규 추가 명시

Edit 4 곳, 각 변경 후 baseline 재실행해 라인 검증.

- [ ] **Step 5: `agent-skill-auditor.md` 1 곳 갱신 — When NOT 분리**

baseline 에서 확인된 description 안 Do NOT 라인 식별:

```bash
grep -n "Do NOT\|평가 인프라" plugins/bobs-plugin/agents/agent-skill-auditor.md | head -5
```

본 agent 의 description 은 Step 3 에서 이미 갱신됨 (resource-design 라우팅 명시). 본 Step 에서는 `평가 인프라` 작업이 본 agent 책임 밖임을 한 줄 더 명시 — *평가 인프라 설계(evaluation-loop-design)* 라우팅 추가.

Edit:
- old_string: description 의 Do NOT 절 중 `Dead asset 감지(session-report)` 직전
- new_string: 동일 + `, 평가 인프라 설계(evaluation-loop-design)`

또는 description 구조에 따라 별도 위치 — baseline 결과 확인 후 결정.

- [ ] **Step 6: 3 sibling skill (skill-creator / agent-creator / hook-creator) When NOT 갱신**

각 skill 의 `## When NOT to use` 또는 description 의 Do NOT 절에 *검증 인프라 → evaluation-loop-design* 라우팅 추가.

```bash
for f in skill-creator agent-creator hook-creator; do
  echo "=== $f ==="
  grep -n "When NOT\|Do NOT\|검증" "plugins/bobs-plugin/skills/$f/SKILL.md" | head -5
done
```

baseline 확인 후 각 skill 의 1 곳에 한 행 추가 (Step 3 plan 의 routing-edit precedent 와 동일 형식):

```
- 검증 인프라 (task log / golden-set / evaluation loop / docs/agent/roles.md body) → `evaluation-loop-design`.
```

- [ ] **Step 7: `resource-design` + `context-map-architecture` 의 evaluation-loop-design routing placeholder 검증**

resource-design (5 곳 — line 3 / 21 / 70 / 152 / 158) + resource-design/references/intent-capture.md (1 곳 — line 23) + context-map-architecture (2 곳 — line 4 / 27) 는 Step 2 / Step 3 에서 *이미 evaluation-loop-design 을 routing* 하고 있음. 본 Step 에서는 placeholder 표기 (`(예정)` / `(TBD)` / `(planned)`) 만 식별·제거:

```bash
grep -n "evaluation-loop-design.*예정\|evaluation-loop-design.*TBD\|evaluation-loop-design.*planned" \
  plugins/bobs-plugin/skills/resource-design/SKILL.md \
  plugins/bobs-plugin/skills/resource-design/references/intent-capture.md \
  plugins/bobs-plugin/skills/context-map-architecture/SKILL.md 2>/dev/null
```

plan 작성 시점 grep 결과: **`context-map-architecture/SKILL.md:27` 1 곳** — `- 검증 인프라 (task log / golden-set / 사이클) → \`evaluation-loop-design\` (예정).`

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/context-map-architecture/SKILL.md`
- old_string: `- 검증 인프라 (task log / golden-set / 사이클) → \`evaluation-loop-design\` (예정).`
- new_string: `- 검증 인프라 (task log / golden-set / 사이클) → \`evaluation-loop-design\`.`

resource-design / intent-capture 의 6 곳은 placeholder 표기가 없으므로 변경 없음. 다른 commit 으로 placeholder 가 추가되었다면 위 grep 이 그것도 발견하므로 모두 제거.

- [ ] **Step 8: 활성 참조 audit (전체 grep — placeholder 누락 확인)**

```bash
echo "--- evaluation-loop-design 활성 참조 ---"
grep -rn "evaluation-loop-design" \
  plugins/bobs-plugin/ \
  .claude-plugin/marketplace.json \
  README.md 2>/dev/null | grep -v "workspace/gaps\|docs/plans\|docs/specs\|references/v1\|references/v2"

# Expected: 신규 SKILL.md/references + workflow doc §3.3 + agent-skill-auditor + 5 sibling skill
# (workspace/gaps/ + docs/plans + docs/specs + v1/v2 archive 는 historical, 무시)
```

신규 자산 (SKILL.md + 4 references) 외 활성 routing 위치 모두 검증.

- [ ] **Step 9: Commit**

```bash
git add plugins/bobs-plugin/.claude-plugin/plugin.json \
        .claude-plugin/marketplace.json \
        README.md \
        plugins/bobs-plugin/agents/agent-skill-auditor.md \
        plugins/bobs-plugin/skills/resource-design/ \
        plugins/bobs-plugin/skills/context-map-architecture/SKILL.md \
        plugins/bobs-plugin/skills/skill-creator/SKILL.md \
        plugins/bobs-plugin/skills/agent-creator/SKILL.md \
        plugins/bobs-plugin/skills/hook-creator/SKILL.md

git commit -m "$(cat <<'EOF'
Cross-ref evaluation-loop-design across plugin meta + 5 sibling skills (Step 4d)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 4d

- plugin.json / marketplace.json / README.md: evaluation-loop-design 신규 자산 등재
- agent-skill-auditor: When NOT 절에 평가 인프라 설계 라우팅 추가
- skill-creator / agent-creator / hook-creator: When NOT 절에 평가 인프라 라우팅 추가
- resource-design / context-map-architecture: placeholder 표기 (예정 / TBD) 제거 — 실제 자산 존재

deprecation 없음 — 본 Step 의 신규 skill 은 흡수 대상 자산 부재.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Verification (전체 Plan 종료 후)

- [ ] **Step 1: 신규 skill 활성 — sub-agent 호출 가능 여부**

```bash
ls -la plugins/bobs-plugin/skills/evaluation-loop-design/
ls -la plugins/bobs-plugin/skills/evaluation-loop-design/references/
ls -la plugins/bobs-plugin/skills/evaluation-loop-design-workspace/gaps/
```

Expected:
- SKILL.md + references/ (4 파일) + workspace/gaps/skill-evaluation-loop-design.GAP.md 모두 존재
- 디렉토리 권한 ok

- [ ] **Step 2: workflow doc §3 완성도 — §3.3 채움 후**

```bash
grep -n "^### 3\." plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 3 행 (3.1 + 3.2 + 3.3)

grep -c "TBD per Step" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 4 (§5 / §6 / §7 / §8 placeholder — Step 5/6/7 에서 채움)
```

- [ ] **Step 3: 활성 routing 일관성**

```bash
echo "--- evaluation-loop-design 활성 참조 전체 ---"
grep -rln "evaluation-loop-design" \
  plugins/bobs-plugin/ \
  .claude-plugin/ \
  README.md 2>/dev/null | sort -u

# Expected (활성):
#   .claude-plugin/marketplace.json
#   README.md
#   plugins/bobs-plugin/.claude-plugin/plugin.json
#   plugins/bobs-plugin/agents/agent-skill-auditor.md
#   plugins/bobs-plugin/references/harness-installation-workflow.md
#   plugins/bobs-plugin/skills/agent-creator/SKILL.md
#   plugins/bobs-plugin/skills/context-map-architecture/SKILL.md
#   plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md
#   plugins/bobs-plugin/skills/evaluation-loop-design/references/roles-write.md
#   plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md
#   plugins/bobs-plugin/skills/evaluation-loop-design/references/golden-set-write.md
#   plugins/bobs-plugin/skills/evaluation-loop-design/references/task-log-template-write.md
#   plugins/bobs-plugin/skills/evaluation-loop-design-workspace/gaps/*.md
#   plugins/bobs-plugin/skills/hook-creator/SKILL.md
#   plugins/bobs-plugin/skills/resource-design/SKILL.md
#   plugins/bobs-plugin/skills/resource-design/references/intent-capture.md
#   plugins/bobs-plugin/skills/skill-creator/SKILL.md
#   plugins/bobs-plugin/docs/plans/2026-05-17-harness-installation-step4.md
```

placeholder 표기 (`(예정)` / `(TBD)` / `(planned)`) 가 활성 routing 라인에 남아있지 않은지:

```bash
grep -rn "evaluation-loop-design.*예정\|evaluation-loop-design.*TBD\|evaluation-loop-design.*planned" \
  plugins/bobs-plugin/ \
  .claude-plugin/ \
  README.md 2>/dev/null | grep -v "docs/plans/2026-05-17-harness-installation-step\|workspace/gaps\|references/v1\|references/v2"

# Expected: 0 lines (placeholder 모두 제거됨)
```

- [ ] **Step 4: agent-skill-auditor 의 본 skill reference 사용 가능성 검증**

본 skill 이 `agent-skill-auditor` 를 정적 감사 reference 로 사용한다 (§8 Asset Disposition). evaluation-loop-write.md 의 Routing Decision 표 *정적 감사 필요* 행에서 인용:

```bash
grep -A 3 "정적 감사\|agent-skill-auditor" plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md
```

Expected: 1 곳 (Routing Decision 표) — 정적 감사가 필요할 때 본 skill 이 어떻게 `agent-skill-auditor` 를 호출하는지 명시.

- [ ] **Step 5: scope 일관성 — user-scope 자산 가정 없음**

Step 3 의 scope decoupling precedent (commit d41a649) 적용 검증. 본 skill 도 plugin/project scope 만 가정:

```bash
echo "--- evaluation-loop-design 의 user-scope (~/.claude/) 참조 ---"
grep -rn "~/.claude/" plugins/bobs-plugin/skills/evaluation-loop-design/ 2>/dev/null

# Expected: 0 lines (user-scope 자산 가정 없음)
```

발견 시 Step 3 의 plugin/project scope 어법 (`${CLAUDE_PLUGIN_ROOT}` / `<repo>/.claude/`) 으로 수정.

---

## Risks & Mitigations

| 위험 | 영향 | 완화 |
|---|---|---|
| evaluation-loop-design 과 evaluation-loop-runner (Step 5) 의 책임 누수 | runtime task log 캡처가 design skill 에 흡수되면 본 skill 이 무거워짐 + Step 5 가 비어짐 | SKILL.md 의 When NOT 명시 — *runtime task log 캡처·라우팅은 evaluation-loop-runner*. Common Failures 에 *Step 5 책임 흡수* 추가. |
| 신규 references 4개의 Phase 1/2/3 일관성 부재 | 사용자가 4 references 를 따로 따로 읽으면 형식이 달라 학습 cost 증가 | Step 2 Step 3b (절차 완전성 audit) 가 모든 reference 가 동일 Phase 1/2/3 + Effect gate + Common Failures 구조임을 검증. |
| golden-set case 가 *실제 발생* task log 없이 toy 예제로 채워짐 | 평가 사이클이 실제 회귀를 못 잡고 toy 회귀만 잡음 | golden-set-write.md Common Failures 에 *toy 예제 회피* 명시. Verification Plan 의 follow-ups 에 *실제 task log 누적 후 case 갱신* 표기. |
| `docs/agent/roles.md` body 가 *모든 자원에 role 강제* 로 inflation | role 정의가 자원 수만큼 늘어남 → 유지 cost | roles-write.md Common Failures 에 *role inflation 회피* 명시. 페어 + 책임 한 줄만, 자원 ↔ role 매핑은 1:N (한 role 이 여러 자원 호출) 또는 N:1 허용. |
| `evaluation-loop.md` 의 종료 조건 부재 → 무한 사이클 | 자동 chain 이 자원·context 소진 | evaluation-loop-write.md template 에 종료 조건 4종 (no-op / 사용자 명시 종료 / 같은 design skill 2회 / 누적 5회) 명시 — spec §4.4 precedent. |
| Step 4 완료 후 user-scope 참조 누수 | Step 3 의 plugin/project scope decoupling 원칙 위반 | Verification Step 5 가 `grep ~/.claude/` 검사. 0 lines 이어야 통과. |
| placeholder 표기 (`예정` / `TBD`) 잔존 → 사용자 혼선 | sibling skill 라우팅이 *없는 자산* 처럼 보임 | Verification Step 3 의 placeholder grep. 0 lines 이어야 통과. Step 4 Task 4 Step 7 에서 명시적 제거. |

---

## Out of Scope (본 Step 에서 다루지 않음)

- `evaluation-loop-runner` skill (runtime) — Step 5 별도 plan
- workflow doc §5 / §6 / §7 / §8 채움 — Step 6 별도 plan
- creator skill spec 인터페이스 호환성 + version bump (0.1.3 → 0.2.0) — Step 7 별도 plan
- `docs/agent/` 실제 파일 작성 — 본 Step 은 *skill 작성* 만. 실제 `docs/agent/roles.md` / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md` 작성은 본 skill 호출의 *결과* 이지 본 plan 의 commit 대상이 아님
- CONSTITUTION.md §3.14 (Docs Are The Source Of Truth) 사용자 분리 작업 — 사용자 별도 진행

---

## Done Criteria

본 Step 4 plan 의 모든 Task 가 commit 되면 다음이 충족:

1. **신규 `evaluation-loop-design` skill** — `plugins/bobs-plugin/skills/evaluation-loop-design/` 에 SKILL.md + 4 references 존재. workspace/gaps/skill-evaluation-loop-design.GAP.md Final Decision = PASS / PASS_WITH_NOTES.
2. **workflow doc §3.3 채움** — `harness-installation-workflow.md` 의 §3.3 placeholder 가 trigger / inspect / spec format / effect gate / handoff 본문으로 교체. §3.1 + §3.2 + §3.3 모두 완성.
3. **메타 파일 + 5 sibling skill cross-ref 갱신** — plugin.json / marketplace.json / README.md / agent-skill-auditor / 3 creator skills / 2 design skills 의 evaluation-loop-design 라우팅 모두 활성 자산 가리키며 placeholder 표기 제거.
4. **활성 routing 일관성** — Verification Step 3 의 grep 결과가 expected list 와 일치.
5. **user-scope decoupling 유지** — Verification Step 5 의 `~/.claude/` 참조 검사가 0 lines.

위 5개 모두 만족하면 Step 4 종료, Step 5 (`evaluation-loop-runner` runtime) 준비 가능.

---

## Reference: Step 4 의 commit 순서 (예상 4 commits)

1. **Commit A** (Task 2 Step 7) — `Add evaluation-loop-design skill (Step 4a/4b)` — 신규 skill + 4 references + GAP report
2. **Commit B** (Task 3 Step 4) — `Fill harness-installation-workflow §3.3 (evaluation-loop-design)` — §3.3 본문 교체
3. **Commit C** (Task 4 Step 9) — `Cross-ref evaluation-loop-design across plugin meta + 5 sibling skills (Step 4d)` — 메타 파일 + agent + 5 skill 갱신

Step 3 plan 이 4 commit (skill + workflow + deprecation + scope cleanup) 이었던 것과 달리 Step 4 는 deprecation 없으므로 3 commit. Step 3 의 commit d41a649 (scope decoupling) 같은 *post-hoc 작업* 이 발견되면 4번째 commit 추가.
