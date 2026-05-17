# Harness Installation — Step 3 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 신규 `resource-design` skill 을 `skill-creator` 로 작성하고, `harness-resource-design` SKILL.md + 4 references + `agent-skill-designer` subagent 본문을 references 로 흡수한 후 두 자산을 deprecate. workflow doc §3.1 도 함께 채우고, 5 sibling skill (`agent-skill-auditor` / `skill-creator` / `agent-creator` / `hook-creator` / `context-map-architecture`) 의 cross-reference 도 갱신.

**Architecture:** skill-creator 가 새 skill 의 SKILL.md 와 GAP 사이클을 처리. references/ 의 흡수 본문 5개는 main session 이 기존 자산에서 추출·압축해 직접 작성 (skill-creator §2 가 SKILL.md 작성 후, §3 GAP 분석 이전, mini-gate 거침). 워크플로우 §3.1 갱신 후 deprecated 2 자산 + 메타 파일 (plugin.json / marketplace.json / README.md / THIRD_PARTY_NOTICES.md) + 5 sibling skill cross-ref 일괄 정리.

**Tech Stack:** skill-creator skill (메타 스킬, interactive), Edit/Write tools, git rm -r

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §7 Step 3 (+ §4.1 책임, §8 Asset Disposition, §10 Decision 1 agent-skill-designer deprecate, Decision 4 GAP 깊이, Decision 6 commit 전략)

**전체 migration 중 위치:** Step 3 of 7. Step 1 (doc split) + Step 2 (context-map-architecture) 완료된 상태에서 진행. Step 4-7 은 후속 별도 plan.

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/skills/resource-design/SKILL.md` | Create (skill-creator §2) | 자원 타입 결정 + 책임 분리 (3-phase: Inspect / Decision / Spec Output) |
| `plugins/bobs-plugin/skills/resource-design/references/decision-rules.md` | Create (main session) | guide-rule-map.md 흡수 — rule ID 인덱스 + 임계값 + 안티패턴 (MIT) |
| `plugins/bobs-plugin/skills/resource-design/references/skill-patterns.md` | Create (main session) | harness-resource-design/skill-patterns.md 흡수 (MIT) |
| `plugins/bobs-plugin/skills/resource-design/references/agent-patterns.md` | Create (main session) | harness-resource-design/agent-patterns.md + agent-skill-designer §0-§3 절차 흡수 (MIT) |
| `plugins/bobs-plugin/skills/resource-design/references/hook-patterns.md` | Create (main session) | harness-resource-design/hook-patterns.md 흡수 (MIT) |
| `plugins/bobs-plugin/skills/resource-design/references/design-output-contract.md` | Create (main session) | agent-skill-designer §4 output 템플릿 (DESIGN_SUMMARY / PROPOSED_RESOURCES / CONTRACTS / IMPLEMENTATION_ORDER / RISKS / REFERENCE_NOTES) 흡수 + spec §4.1 의 Inventory/Required Resources/Resource Decisions/Execution Plan 형식 통합 (MIT) |
| `plugins/bobs-plugin/skills/resource-design-workspace/gaps/skill-resource-design.GAP.md` | Create (skill-creator §3) | GAP report |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (§3.1 채움) | "TBD per Step 3" → 실제 내용 |
| `plugins/bobs-plugin/skills/harness-resource-design/` | Delete (`git rm -r`) | deprecate (본문·refs 흡수, MIT in-house) |
| `plugins/bobs-plugin/skills/harness-resource-design-workspace/` | Delete (if exists) | deprecate |
| `plugins/bobs-plugin/agents/agent-skill-designer.md` | Delete | deprecate (§10 Decision 1 — subagent 격리가 메인 세션 일상 결정에 정당화되지 않음, 책임 흡수) |
| `plugins/bobs-plugin/.claude-plugin/plugin.json` | Edit (description) | agent-skill-designer + harness-resource-design 제거, resource-design 추가 |
| `.claude-plugin/marketplace.json` | Edit (description) | 동일 |
| `README.md` | Edit (file tree + agents 표 + skill 표 + namespace + migration notes + licensing) | resource-design 추가, agent-skill-designer / harness-resource-design 제거 |
| `THIRD_PARTY_NOTICES.md` | Edit (LICENSE 단락의 in-house 자산 목록) | harness-resource-design → resource-design |
| `plugins/bobs-plugin/agents/agent-skill-auditor.md` | Edit (3곳) | guide-rule-map 경로 + agent-skill-designer 라우팅 → resource-design 으로 |
| `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` | Edit (2곳) | description + Phase 1 routing 의 `harness-resource-design / agent-skill-designer` → `resource-design` |
| `plugins/bobs-plugin/skills/skill-creator/SKILL.md` | Edit (6곳) | description, 관련 자산, escape hatch 표, in-flight 전환 표 |
| `plugins/bobs-plugin/skills/agent-creator/SKILL.md` | Edit (6곳) | description, 관련 자산, escape hatch 표 |
| `plugins/bobs-plugin/skills/hook-creator/SKILL.md` | Edit (3곳) | description, 관련 자산, escape hatch 표 |

**유지** (변경 없음):
- `plugins/bobs-plugin/skills/claude-automation-recommender/` — vendored Apache-2.0, resource-design 의 reference (§8 Asset Disposition). THIRD_PARTY_NOTICES.md 의 vendored 표 행은 그대로.
- `plugins/bobs-plugin/agents/agent-skill-auditor.md` — 유지하되 cross-ref 만 갱신 (§8 Asset Disposition: evaluation-loop-design 의 reference).
- `plugins/bobs-plugin/third_party_licenses/` 모든 LICENSE 파일 — 변경 없음 (claude-md-management-LICENSE 는 Step 2 흡수 reference 의 보존 의무로 이미 유지 중).

---

## Note on TDD for skill creation

skill-creator 자체가 GAP-driven (draft → 분석 → 수정 → 재분석) 사이클이므로 본 plan 의 Task 2 는 *외부* TDD 가 아닌 *skill-creator 내부* GAP loop 에 의존한다. Task 3 (workflow doc) 와 Task 4 (deprecation + cross-ref) 는 doc 작업이라 *verify-baseline → change → verify-result → commit* 패턴.

---

### Task 1: skill-creator 호출 준비 — intent brief

**Files:**
- (편집 없음 — preparation only)

skill-creator §0 Capture Intent 가 사용자에게 묻기 전, main session 이 intent 를 사전 정리해 한 번에 제공한다. 본 Task 는 정보 추출만 — commit 없음.

- [ ] **Step 1: 기존 자산 본문·references 읽기 (흡수 대상 식별)**

다음 파일을 모두 Read 한다:

- `plugins/bobs-plugin/skills/harness-resource-design/SKILL.md` (69 lines — Quick Decision + Routing + Workflow + When NOT + References + Output + Boundaries)
- `plugins/bobs-plugin/skills/harness-resource-design/references/guide-rule-map.md` (139 lines — rule ID 인덱스 + 임계값 + 안티패턴, 6개 GUIDE 압축)
- `plugins/bobs-plugin/skills/harness-resource-design/references/skill-patterns.md` (73 lines)
- `plugins/bobs-plugin/skills/harness-resource-design/references/agent-patterns.md` (85 lines)
- `plugins/bobs-plugin/skills/harness-resource-design/references/hook-patterns.md` (72 lines)
- `plugins/bobs-plugin/agents/agent-skill-designer.md` (115 lines — §0 트리거 / §1 입력 / §2 설계 기준 로드 / §3 결정 절차 / §4 출력 형식 / §5 금지)

harness-resource-design 총: 69 + 139 + 73 + 85 + 72 = **438 lines**
agent-skill-designer: **115 lines**
합계 흡수 source: **553 lines** (모두 MIT in-house — Apache-2.0 attribution 불요)

각 파일의 *흡수 대상 영역* 을 식별:

| 출처 | 흡수 위치 | 흡수 깊이 |
|---|---|---|
| harness-resource-design SKILL.md (Quick Decision / Routing / Workflow / Output Expectations / Boundaries) | 신규 `resource-design/SKILL.md` 본문 | full — 본 스킬의 phase 골격으로 재구성 |
| harness-resource-design/references/guide-rule-map.md (139 lines) | `references/decision-rules.md` | full (or 압축 — guide-rule-map 은 이미 압축본이라 그대로 가능) |
| harness-resource-design/references/skill-patterns.md (73 lines) | `references/skill-patterns.md` | full — 거의 그대로 |
| harness-resource-design/references/agent-patterns.md (85 lines) | `references/agent-patterns.md` 본문 | full — agent-skill-designer §0-§3 의 결정 절차 추가 통합 |
| harness-resource-design/references/hook-patterns.md (72 lines) | `references/hook-patterns.md` | full — 거의 그대로 |
| agent-skill-designer §4 (output template — DESIGN_SUMMARY / PROPOSED_RESOURCES / CONTRACTS / IMPLEMENTATION_ORDER / RISKS / REFERENCE_NOTES) + spec §4.1 (Inventory / Required Resources / Resource Decisions / Execution Plan) | `references/design-output-contract.md` | 두 형식 통합 — 본 plan 의 신규 design |

- [ ] **Step 2: skill-creator §0 답안 정리 (메모리만)**

| # | skill-creator §0 질문 | 답 |
|---|---|---|
| 1 | 재사용 책임 (한 문장) | 사용자 요청에 대해 *어떤 자원 (command / skill / agent / hook / runtime settings / plugin) 이 필요한지* 결정 + 기존 자원과의 책임 분리 + Execution Plan 산출 |
| 2 | 트리거 (1-3개) | "새 스킬·에이전트·훅·커맨드 만들어줘", "자원 타입 결정", "책임 분리", "harness 자원 설계", "migration plan" |
| 3 | Negative trigger (≥1) | 자원 작성 (creator skills — skill-creator / agent-creator / hook-creator), docs 설계 (context-map-architecture), 검증 인프라 (evaluation-loop-design), 정적 rule 감사 (agent-skill-auditor), 코드/PR 리뷰 |
| 4 | 호출자가 산출물로 무엇을 하나 | spec (Inventory / Required Resources / Resource Decisions / Execution Plan) 검토 → 승인 → Execution Plan 의 target creator skill 로 main session 이 순차 dispatch |
| 5 | 부수 효과 | 파일 작성 없음 — markdown spec 출력만 (Effect gate: spec 사용자 승인 후 main session 이 Execution dispatch 결정). 단, workspace 디렉토리 (GAP report 저장) 는 생성 |
| 6 | scope | plugin (`plugins/bobs-plugin/skills/resource-design/`) |

- [ ] **Step 3: skill-creator 첫 메시지 한 줄 brief 작성**

skill-creator 호출 시 사용자 첫 메시지로 전달할 single-shot brief (의도 캡처 비용 절감):

```
name: resource-design
scope: plugin (plugins/bobs-plugin/skills/resource-design/)
책임: 사용자 요청에 대해 어떤 자원 (command / skill / agent / hook / runtime settings / plugin)
  이 필요한지 결정 + 기존 자원과의 책임 분리 + Execution Plan 산출. 자원 자체는 만들지 않고
  spec markdown 만 출력.
트리거: "새 스킬·에이전트·훅·커맨드 만들어줘", "자원 타입 결정", "책임 분리",
  "harness 자원 설계", "migration plan"
negative: 자원 작성 (skill-creator / agent-creator / hook-creator), docs 설계
  (context-map-architecture), 검증 인프라 (evaluation-loop-design), 정적 감사
  (agent-skill-auditor), 코드/PR 리뷰
spec format: Inventory + Required Resources + Resource Decisions + Execution Plan
  (spec_version v1, workflow doc §4 표준 인터페이스)
effect gate: spec 사용자 승인 후 main session 이 Execution dispatch 결정 (이중 gate —
  본 스킬은 spec 단계, dispatch 는 호출자)
references 5개 (main session 이 §2 SKILL.md draft 직후 mini-gate 거쳐 직접 작성):
  - references/decision-rules.md (guide-rule-map 흡수, MIT, 100-150 lines)
  - references/skill-patterns.md (harness-resource-design/skill-patterns 흡수, MIT, 70-100 lines)
  - references/agent-patterns.md (harness-resource-design/agent-patterns + agent-skill-designer
    §0-§3 통합, MIT, 130-180 lines)
  - references/hook-patterns.md (harness-resource-design/hook-patterns 흡수, MIT, 70-100 lines)
  - references/design-output-contract.md (agent-skill-designer §4 + spec §4.1 형식 통합,
    MIT, fresh, 80-120 lines)
관련 (변경 없음): claude-automation-recommender (vendored Apache-2.0 reference, 1463 lines
  — 본 스킬은 ecosystem 추천이 필요할 때 한 줄 cite 만)
```

본 brief 는 Task 2 Step 1 에서 skill-creator 호출 시 입력.

---

### Task 2: skill-creator 로 신규 skill 작성 + references 흡수 (Step 3a/3b)

**Files:**
- Create (skill-creator §2): `plugins/bobs-plugin/skills/resource-design/SKILL.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/resource-design/references/decision-rules.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/resource-design/references/skill-patterns.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/resource-design/references/agent-patterns.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/resource-design/references/hook-patterns.md`
- Create (main session, §2 직후, fresh): `plugins/bobs-plugin/skills/resource-design/references/design-output-contract.md`
- Create (skill-creator §3a): `plugins/bobs-plugin/skills/resource-design-workspace/gaps/skill-resource-design.GAP.md`

- [ ] **Step 1: skill-creator 호출 (intent 사전 제공)**

호출:

```
/skill-creator
```

첫 메시지: Task 1 Step 3 의 brief block 그대로 붙여넣기.

skill-creator §0 → §1 → §2 자체 흐름 진행. §2 시점 A gate (첫 파일 작성 전, SKILL.md 경로 + frontmatter + 본문 골격 + workspace 경로 제시) 에서 사용자 명시 승인.

예상 SKILL.md 구조 (skill-creator §2 가 SKILL-GUIDE.md 표준 골격 적용):

- Frontmatter: `name: resource-design`, description (trigger + Do NOT 명시), `user-invocable: true`
- `# Resource Design`
- `## When to Use` + `## When NOT to Use`
- `## Workflow`
  - `### Phase 1: Inspect` — 자원 inventory (skill / agent / hook / command / runtime settings) + 사용자 발화의 작업 컨텍스트
  - `### Phase 2: Decision` — type tree (references/decision-rules.md + per-type patterns 인용) + escape hatches (다른 design skill 로 전환)
  - `### Phase 3: Spec Output (Effect gate)` — Inventory / Required Resources / Resource Decisions / Execution Plan 4 섹션 생성 + 사용자 승인
- `## Output Contract` — spec 형식 + no-op / blocked / NEEDS_INPUT 케이스
- `## Common Failures`
- `## References` — decision-rules.md / skill-patterns.md / agent-patterns.md / hook-patterns.md / design-output-contract.md 인용

- [ ] **Step 2: references 작성 (skill-creator §2 SKILL.md draft 완료 직후, §3 GAP 분석 진입 전)**

skill-creator §2 의 SKILL.md 첫 쓰기가 끝난 시점에서 main session 이 직접 references 를 작성한다. skill-creator 의 시점 A gate 는 SKILL.md 1개 경로만 다루므로 (CONSTITUTION §3.3 effect gate 가 references 에는 적용되지 않는 누수 위험), main session 이 *별도 mini-gate* 를 거친다.

**(0) Mini-gate — references write 직전 사용자 승인** *(Step 2 plan 의 precedent 동일)*

각 references 파일을 쓰기 전에 다음 5가지를 한 묶음으로 사용자에게 제시한다 (CONSTITUTION §3.3 Effects Require Gates 의 본 plan 내 적용):

| 항목 | 내용 |
|---|---|
| 작성 경로 | 5개 절대 경로 (`decision-rules.md` / `skill-patterns.md` / `agent-patterns.md` / `hook-patterns.md` / `design-output-contract.md`) |
| Source 파일 | 각 reference 가 흡수하는 원본 파일 목록 + 줄 수 (Task 1 Step 1 의 흡수 대상 표 인용) |
| Target length | 각 파일 예상 줄 수 (100-150 / 70-100 / 130-180 / 70-100 / 80-120) |
| License / attribution | 모두 MIT in-house — attribution 헤더 없음 (출처 표기는 본문 첫 줄에 한 줄로) |
| 압축 정책 | guide-rule-map 은 그대로 / 3 패턴 ref 는 거의 그대로 / agent-patterns 는 agent-skill-designer §0-§3 추가 통합 / design-output-contract 는 두 형식 통합 신규 |

사용자 명시 승인 (`go` / `proceed` / `진행`) 후 (a)-(e) 의 파일 write 로 진행. 사전 합의된 *묻지 말고 진행* 모드에서는 확인 없이 진행하되 본 mini-gate 의 5 항목은 응답에 기록.

**(a) `references/decision-rules.md` 작성**

source: harness-resource-design/references/guide-rule-map.md (139 lines)
target length: 100-150 lines (이미 압축된 본문이라 그대로 보존 가능, 헤더만 갱신)
content outline:

1. 헤더 (출처: 본 plan, MIT in-house — 원본은 (deprecated) harness-resource-design/references/guide-rule-map.md)
2. 6개 GUIDE 압축 — CONSTITUTION / SKILL-GUIDE / AGENT-GUIDE / COMMAND-GUIDE / HOOK-GUIDE / RUNTIME-GUIDE 의 rule ID 인덱스
3. 임계값 표 (description length / body length / capability surface 등)
4. 안티패턴 목록

헤더:

```markdown
# Design Rule Map

> 본 문서는 `resource-design` skill 의 reference. 원본은 (deprecated) `harness-resource-design/references/guide-rule-map.md` 본문 그대로 보존. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
>
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/{CONSTITUTION,SKILL-GUIDE,AGENT-GUIDE,COMMAND-GUIDE,HOOK-GUIDE,RUNTIME-GUIDE}.md`. 본 인덱스가 우선이며, 원문 규칙이 필요할 때만 GUIDE 직접 참조.
```

**(b) `references/skill-patterns.md` 작성**

source: harness-resource-design/references/skill-patterns.md (73 lines)
target length: 70-100 lines (그대로 보존)
content outline:

1. 헤더 (출처: harness-resource-design 본문 보존, MIT)
2. 본문 그대로 (스킬 설계 / progressive disclosure / references 배치 / invocation control)

헤더:

```markdown
# Skill Design Patterns

> 본 문서는 `resource-design` skill 의 reference. 원본은 (deprecated) `harness-resource-design/references/skill-patterns.md` 본문 그대로 보존. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(c) `references/agent-patterns.md` 작성** *(fresh 통합 — harness-resource-design + agent-skill-designer)*

source A: harness-resource-design/references/agent-patterns.md (85 lines — description / tools / model / output contract / 책임 분리)
source B: agent-skill-designer.md §0 트리거 + §1 입력 + §2 설계 기준 로드 + §3 결정 절차 (~70 lines 발췌)
target length: 130-180 lines
content outline:

1. 헤더 (두 source 표기)
2. Section A: 에이전트 디자인 패턴 (source A 본문 보존)
3. Section B: 에이전트 의도 캡처 + 결정 절차 (source B §0-§3 흡수 — *부수 효과 (파일 수정 등) 금지 책임* 도 포함)
4. 두 source 의 책임 분리: A 는 *어떤 모양* (frontmatter / tools / model), B 는 *어떤 절차* (트리거 판단 / 입력 / 결정 순서)

헤더:

```markdown
# Agent Design Patterns

> 본 문서는 `resource-design` skill 의 reference. 두 원본을 통합:
>
> - (deprecated) `harness-resource-design/references/agent-patterns.md` — 에이전트 모양 (frontmatter / tools / model / output contract)
> - (deprecated) `agents/agent-skill-designer.md` §0-§3 — 에이전트 의도 캡처 + 결정 절차
>
> 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(d) `references/hook-patterns.md` 작성**

source: harness-resource-design/references/hook-patterns.md (72 lines)
target length: 70-100 lines (그대로 보존)
content outline:

1. 헤더 (출처 표기)
2. 본문 그대로 (hook event 선택 / matcher / failure behavior / routing hints)

헤더:

```markdown
# Hook Design Patterns

> 본 문서는 `resource-design` skill 의 reference. 원본은 (deprecated) `harness-resource-design/references/hook-patterns.md` 본문 그대로 보존. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(e) `references/design-output-contract.md` 작성** *(fresh — agent-skill-designer §4 + spec §4.1 통합)*

source A: agent-skill-designer.md §4 (DESIGN_SUMMARY / PROPOSED_RESOURCES / CONTRACTS / IMPLEMENTATION_ORDER / RISKS / REFERENCE_NOTES — agent 의 자유 형식 출력)
source B: spec §4.1 (Inventory / Required Resources / Resource Decisions / Execution Plan — workflow doc §4 표준 4 섹션 호환)
target length: 80-120 lines
content outline:

1. 헤더 (fresh 통합 — spec §4.1 + agent-skill-designer §4)
2. 표준 spec 형식 (workflow doc §4 호환 — 본 reference 의 주 출력)
   - 공통 헤더 (`# Harness Installation Spec — resource` + Generated by + Date + Trigger + spec_version)
   - `## Inventory` — 현재 자원 (skill / agent / hook / command / runtime settings) 인벤토리
   - `## Required Resources` — 작업 유형 → 필요한 자원 결정 표
   - `## Resource Decisions` — 각 자원: name / type / 책임 한 줄 / 우선순위
   - `## Execution Plan` — target creator skill + args + rationale (Phase 2 dispatch 용)
3. 보조 형식: agent-skill-designer §4 의 DESIGN_SUMMARY / RISKS 형태 — 사용자가 *spec 출력 대신 짧은 design brief* 만 원할 때 사용
4. no-op / blocked / NEEDS_INPUT 케이스 (workflow doc §4 의 변형 형식)
5. Execution Plan 파싱 규칙 (workflow doc §4 본문에 이미 정의 — 본 reference 는 한 줄 cite 만)

헤더:

```markdown
# Design Output Contract

> 본 문서는 `resource-design` skill 의 reference. 두 원본을 통합:
>
> - spec §4.1 (workflow doc §4 호환 형식) — Inventory / Required Resources / Resource Decisions / Execution Plan
> - (deprecated) `agents/agent-skill-designer.md` §4 — DESIGN_SUMMARY / PROPOSED_RESOURCES / CONTRACTS / IMPLEMENTATION_ORDER / RISKS (보조 brief 형식)
>
> 본 plan 에서 두 형식을 한 reference 로 통합 작성. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

작성 후 각 references verify:

```bash
wc -l plugins/bobs-plugin/skills/resource-design/references/*.md
```

Expected:
- decision-rules.md ≈ 100-150 lines
- skill-patterns.md ≈ 70-100 lines
- agent-patterns.md ≈ 130-180 lines
- hook-patterns.md ≈ 70-100 lines
- design-output-contract.md ≈ 80-120 lines

- [ ] **Step 3: skill-creator §3 GAP 분석 진행 (interactive) — references 까지 target 확장**

skill-creator 가 §3a 에서 workspace 생성:

```bash
mkdir -p plugins/bobs-plugin/skills/resource-design-workspace/gaps
```

§3b (위임 권장) 또는 §3c (인라인) 로 GAP 분석.

**중요: skill-creator §3b 의 default 위임 prompt 는 분석 target 을 `<SKILL_PATH>/SKILL.md` 1개로 제한** (Step 2 plan 의 P1#2 precedent). 본 plan 의 references 5개는 *흡수된 핵심 본문* 이므로 SKILL.md 와 동일 수준의 GAP 적용 대상. main session 은 위임 prompt 의 target 목록을 다음 6개 경로로 *명시 확장* 한다:

```
분석 대상 (확장):
  - <SKILL_PATH>/SKILL.md
  - <SKILL_PATH>/references/decision-rules.md
  - <SKILL_PATH>/references/skill-patterns.md
  - <SKILL_PATH>/references/agent-patterns.md
  - <SKILL_PATH>/references/hook-patterns.md
  - <SKILL_PATH>/references/design-output-contract.md
각 파일을 같은 GAP-FORMAT §9 형식으로 평가하고 finding 의 `evidence` 필드에 어느 파일의 어느 위치인지 명시한다.
```

분석 깊이:

- SKILL.md: 표준 skill GAP (activation / scope / output contract / effect gate / verification / overlap — 특히 5 sibling skill 과의 차이 명확성)
- references 각각: 흡수 절차 완전성 (원본 핵심이 모두 반영되었나) + length budget + 도구 공통성 + design-output-contract 의 두 형식 통합 일관성

skill-creator §4 Final Decision 분기:

- `PASS` → §5 진행
- `PASS_WITH_NOTES` → 옵션 적용 후 §5
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침 — references 도 mini-gate 거침) 후 §3 재실행 (라운드 카운트 +1)
- 5 라운드 초과 → `NEEDS_REVIEW` 사용자 보고, 본 Task 일시 중단

- [ ] **Step 3b: references 흡수 audit (skill-creator GAP 외 추가 검증)**

skill-creator GAP 가 PASS 라도 *흡수 본문 누락* 은 잡지 못할 수 있음 (원본 비교는 GAP 검증 축이 아님). 별도 audit:

```bash
# 각 reference 의 핵심 섹션이 빠지지 않았는지 keyword 검사
echo "--- decision-rules.md 흡수 검증 ---"
for kw in "CONSTITUTION" "SKILL-GUIDE" "AGENT-GUIDE" "COMMAND-GUIDE" "HOOK-GUIDE" "RUNTIME-GUIDE" "안티패턴"; do
  grep -q "$kw" plugins/bobs-plugin/skills/resource-design/references/decision-rules.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- skill-patterns.md 흡수 검증 ---"
for kw in "progressive disclosure" "references" "invocation"; do
  grep -q "$kw" plugins/bobs-plugin/skills/resource-design/references/skill-patterns.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- agent-patterns.md 흡수 검증 ---"
for kw in "description" "tools" "model" "output contract" "트리거 판단" "결정 절차" "부수 효과"; do
  grep -q "$kw" plugins/bobs-plugin/skills/resource-design/references/agent-patterns.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- hook-patterns.md 흡수 검증 ---"
for kw in "event" "matcher" "PreToolUse\|PostToolUse" "failure"; do
  grep -qE "$kw" plugins/bobs-plugin/skills/resource-design/references/hook-patterns.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- design-output-contract.md 흡수 검증 ---"
for kw in "Inventory" "Required Resources" "Resource Decisions" "Execution Plan" \
          "DESIGN_SUMMARY" "PROPOSED_RESOURCES" "CONTRACTS" "IMPLEMENTATION_ORDER" \
          "RISKS" "spec_version"; do
  grep -q "$kw" plugins/bobs-plugin/skills/resource-design/references/design-output-contract.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done
```

Expected: 모든 항목 `ok`. `MISSING` 가 1건이라도 있으면 해당 reference 를 다시 작성 (Step 2 (a)-(e) 의 outline 점검 → Edit 으로 보완 → Step 3 재실행).

- [ ] **Step 4: GAP 리포트 경로 + Final Decision 검증**

```bash
ls plugins/bobs-plugin/skills/resource-design-workspace/gaps/skill-resource-design.GAP.md
grep -nE "Final Decision|^## 10|^## 16" \
  plugins/bobs-plugin/skills/resource-design-workspace/gaps/skill-resource-design.GAP.md
```

Expected: 파일 존재 + `Final Decision: PASS` 또는 `PASS_WITH_NOTES`. 그 외면 본 Task 미완료 — Step 3 으로 복귀.

- [ ] **Step 5: skill 디렉토리 구조 최종 verify**

```bash
ls plugins/bobs-plugin/skills/resource-design/
ls plugins/bobs-plugin/skills/resource-design/references/
wc -l plugins/bobs-plugin/skills/resource-design/SKILL.md \
      plugins/bobs-plugin/skills/resource-design/references/*.md
```

Expected:
- SKILL.md 존재
- references/ 에 **5개 파일** (decision-rules.md / skill-patterns.md / agent-patterns.md / hook-patterns.md / design-output-contract.md)
- SKILL.md ≈ 150-250 lines
- decision-rules.md ≈ 100-150 lines
- skill-patterns.md / hook-patterns.md ≈ 70-100 lines 각각
- agent-patterns.md ≈ 130-180 lines
- design-output-contract.md ≈ 80-120 lines
- 총 references ≈ 450-700 lines (원본 553 lines + design-output-contract 신규 추가)

- [ ] **Step 6: Commit — 신규 skill + references + GAP report**

```bash
git add plugins/bobs-plugin/skills/resource-design/ \
        plugins/bobs-plugin/skills/resource-design-workspace/

git commit -m "$(cat <<'EOF'
Add resource-design skill (Step 3a/3b)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 3 + §4.1

- skills/resource-design/SKILL.md (Inspect / Decision / Spec Output 3-phase)
- references/decision-rules.md (harness-resource-design/guide-rule-map.md 흡수, MIT in-house)
- references/skill-patterns.md (harness-resource-design 흡수, MIT in-house)
- references/agent-patterns.md (harness-resource-design + agent-skill-designer §0-§3 통합, MIT in-house)
- references/hook-patterns.md (harness-resource-design 흡수, MIT in-house)
- references/design-output-contract.md (agent-skill-designer §4 + spec §4.1 통합, fresh MIT in-house)
- workspace/gaps/ 의 GAP 리포트 — Final Decision PASS / PASS_WITH_NOTES

기존 자산 (harness-resource-design + agent-skill-designer) deprecation 은 Step 3d 별도 commit.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: workflow doc §3.1 채움 (Step 3c)

**Files:**
- Modify: `plugins/bobs-plugin/references/harness-installation-workflow.md`

- [ ] **Step 1: Baseline 확인 — 현재 §3.1 placeholder 위치**

```bash
grep -n "^### 3\.\|^- 3\.\|TBD per Step 3\|## 3\." plugins/bobs-plugin/references/harness-installation-workflow.md
```

Expected: `## 3. Phase 1 Design Skills` 헤더 + line 49 `- 3.1 \`resource-design\` (TBD per Step 3)` + 기 채워진 §3.2 + line 96 `- 3.3 \`evaluation-loop-design\` (TBD per Step 4)`.

- [ ] **Step 2: §3 본문 갱신 — 3.1 하위 섹션 채움**

Edit:

- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/references/harness-installation-workflow.md`
- old_string:

```
- 3.1 `resource-design` (TBD per Step 3)

### 3.2 `context-map-architecture`
```

- new_string:

```
### 3.1 `resource-design`

**Trigger**:

- 사용자가 새 자원 (command / skill / agent / hook / runtime settings / plugin) 작성 요청 — *어떤 타입* 인지 결정 필요
- 기존 자원 (skill / agent / hook) 의 책임 분리 / merge / migration 결정 요청
- 자원 inventory 정리 (어느 작업 유형에 어떤 자원이 매핑되는지)
- Routing 표 §2 행: "커맨드·스킬·에이전트·훅·런타임 설정 만들어줘", 자원 타입 결정

**Inspect 도메인**:

- `<repo>/.claude/skills/`, `<repo>/plugins/*/skills/`, `~/.claude/skills/` (skill inventory)
- `<repo>/.claude/agents/`, `<repo>/plugins/*/agents/` (agent inventory)
- `<repo>/.claude/settings.json` (hook 등록 + runtime settings)
- `<repo>/.claude/commands/`, `<repo>/plugins/*/commands/`, `~/.claude/commands/` (command inventory)
- 사용자 발화의 작업 컨텍스트 (어떤 작업 유형에 필요한 자원인지)
- 참고 자산: `references/decision-rules.md`, `references/skill-patterns.md`, `references/agent-patterns.md`, `references/hook-patterns.md`, vendored `claude-automation-recommender` (ecosystem 추천)

**Spec format** (workflow doc §4 의 공통 인터페이스 적용):

```markdown
# Harness Installation Spec — resource

> Generated by: resource-design
> Date: <iso8601>
> Trigger: <user request>
> spec_version: v1

## Inventory
## Required Resources       — 작업 유형 → 필요한 자원 결정 표
## Resource Decisions       — 각 자원: name / type / 책임 한 줄 / 우선순위
## Execution Plan           — target creator skill + args + rationale (Phase 2 dispatch 용)
```

`Required Resources` + `Resource Decisions` 는 §4 표준 섹션의 `Gaps` + `Plan` 변형, `Execution Plan` 은 표준 그대로 (Phase 2 자동 dispatch 의 진입점).

**Effect gate** (이중):

- 1단계 (design): spec 본문 사용자 검토 + 승인 (CONSTITUTION §3.3 — 본 스킬은 파일 작성 효과는 없지만 *Execution Plan dispatch* 라는 후속 부수 효과의 진입점)
- 2단계 (apply): main session 이 Execution Plan 항목별로 target creator skill (`skill-creator` / `agent-creator` / `hook-creator`) 을 순차 dispatch — 각 creator 의 §2 effect gate 가 실제 파일 write 시 다시 확인

**Handoff**:

- 출력: spec markdown + follow-ups (예: claude-automation-recommender ecosystem 추천이 필요 / 자원 inventory 가 불완전 / 사용자 의도가 모호)
- main session 은 Execution Plan 의 `target` / `args` / `rationale` 를 §4 파싱 규칙으로 처리해 dispatch
- no-op: 기존 자원으로 충분 + 새 자원 불필요 → `mode: no-op` + 사유
- blocked: 자원 타입 결정 모호 (사용자 의도 불명확) → `mode: blocked` + `needs_input` (예: "이 작업이 *반복* 인가 *일회성* 인가? — 답에 따라 skill 또는 ad-hoc 결정")

### 3.2 `context-map-architecture`
```

- [ ] **Step 3: Verify**

```bash
grep -c "^### 3\." plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 2 (3.1 + 3.2 채워짐)

grep "^### 3.1\|^### 3.2" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 2 행 모두 존재

grep -c "TBD per Step" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 5 (3.3 / §5 / §6 / §7 / §8 의 잔여 placeholder)
```

- [ ] **Step 4: Commit**

```bash
git add plugins/bobs-plugin/references/harness-installation-workflow.md
git commit -m "$(cat <<'EOF'
Fill harness-installation-workflow §3.1 (resource-design)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 3c

trigger / inspect / spec format / effect gate / handoff 5개 절. spec_version v1 명시.
Required Resources + Resource Decisions 가 §4 표준 섹션 (Gaps + Plan) 의 변형임을 명시.
Execution Plan 은 §4 표준 그대로 — Phase 2 자동 dispatch 의 진입점.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: deprecate 2 자산 + 메타 파일 정리 + 5 sibling cross-ref 갱신 (Step 3d)

**Files:**
- Delete: `plugins/bobs-plugin/skills/harness-resource-design/`
- Delete (if exists): `plugins/bobs-plugin/skills/harness-resource-design-workspace/`
- Delete: `plugins/bobs-plugin/agents/agent-skill-designer.md`
- Modify: `plugins/bobs-plugin/.claude-plugin/plugin.json` (description)
- Modify: `.claude-plugin/marketplace.json` (description)
- Modify: `README.md` (6 곳)
- Modify: `THIRD_PARTY_NOTICES.md` (LICENSE 단락 1 곳)
- Modify: `plugins/bobs-plugin/agents/agent-skill-auditor.md` (3 곳)
- Modify: `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` (2 곳)
- Modify: `plugins/bobs-plugin/skills/skill-creator/SKILL.md` (6 곳)
- Modify: `plugins/bobs-plugin/skills/agent-creator/SKILL.md` (6 곳)
- Modify: `plugins/bobs-plugin/skills/hook-creator/SKILL.md` (3 곳)

- [ ] **Step 1: Baseline 확인 — 활성 참조 위치**

```bash
grep -n "harness-resource-design\|agent-skill-designer" \
  plugins/bobs-plugin/.claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  README.md \
  THIRD_PARTY_NOTICES.md 2>/dev/null

echo "--- agents ---"
grep -n "harness-resource-design\|agent-skill-designer" \
  plugins/bobs-plugin/agents/agent-skill-auditor.md 2>/dev/null

echo "--- sibling skills ---"
grep -n "harness-resource-design\|agent-skill-designer" \
  plugins/bobs-plugin/skills/context-map-architecture/SKILL.md \
  plugins/bobs-plugin/skills/skill-creator/SKILL.md \
  plugins/bobs-plugin/skills/agent-creator/SKILL.md \
  plugins/bobs-plugin/skills/hook-creator/SKILL.md 2>/dev/null
```

Expected (baseline 사전 확인됨):

- plugin.json: 1 line (description)
- marketplace.json: 1 line (description)
- README.md: 6 lines (file tree agent + file tree skill + agents desc + skill 표 행 + namespace + migration notes + licensing)
- THIRD_PARTY_NOTICES.md: 1 line (line 9 LICENSE 단락 in-house 자산 목록)
- agent-skill-auditor.md: 3 lines (description + guide-rule-map 경로 + 라우팅 분리)
- context-map-architecture/SKILL.md: 2 lines (description + Phase 1 routing)
- skill-creator/SKILL.md: 6 lines (description + 관련 자산 + 2 routing + 2 escape hatch 표)
- agent-creator/SKILL.md: 6 lines (description + 관련 자산 + routing + 3 escape hatch 표)
- hook-creator/SKILL.md: 3 lines (description + 관련 자산 + routing)

각 위치는 Step 2-5 에서 개별 처리.

- [ ] **Step 2: `plugin.json` description 갱신**

Read `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/.claude-plugin/plugin.json` line 1-10.

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/.claude-plugin/plugin.json`
- old_string: `"description": "Bob's bundle for Claude harness work: agent-skill-auditor + agent-skill-designer + harness-resource-design + context-map-architecture + skill-creator + agent-creator + hook-creator (with the agent-skill-best-practices GUIDE), plus vendored claude-automation-recommender.",`
- new_string: `"description": "Bob's bundle for Claude harness work: agent-skill-auditor + resource-design + context-map-architecture + skill-creator + agent-creator + hook-creator (with the agent-skill-best-practices GUIDE), plus vendored claude-automation-recommender.",`

주의: `version` 필드 (`0.1.3`) 는 본 Step 에서 bump 하지 않음 (Spec §10 Decision 6 — 모든 Step 완료 후 한 번, 0.2.0).

- [ ] **Step 3: `marketplace.json` description 갱신**

Read `/Users/macpro/dev/bobs-plugin/.claude-plugin/marketplace.json` line 1-15.

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/.claude-plugin/marketplace.json`
- old_string: `"description": "Auditor + designer + harness-resource-design + context-map-architecture + skill-creator + agent-creator + hook-creator, with vendored claude-automation-recommender (Apache-2.0).",`
- new_string: `"description": "Auditor + resource-design + context-map-architecture + skill-creator + agent-creator + hook-creator, with vendored claude-automation-recommender (Apache-2.0).",`

- [ ] **Step 4: `README.md` 갱신 — 6 곳**

Read `/Users/macpro/dev/bobs-plugin/README.md` 전체 (81 lines).

**(a) line 3 description — "two harness agents" → "one harness agent":**

Edit:
- old_string: `A single-plugin Claude Code marketplace shipping `bobs-plugin`. The plugin bundles two harness agents, in-house design + authoring skills (`harness-resource-design`, `context-map-architecture`, `skill-creator`, `agent-creator`, `hook-creator`), and one vendored upstream skill (`claude-automation-recommender`, Apache-2.0) so the whole harness-design / authoring workflow is available from one install.`
- new_string: `A single-plugin Claude Code marketplace shipping `bobs-plugin`. The plugin bundles one harness agent, in-house design + authoring skills (`resource-design`, `context-map-architecture`, `skill-creator`, `agent-creator`, `hook-creator`), and one vendored upstream skill (`claude-automation-recommender`, Apache-2.0) so the whole harness-design / authoring workflow is available from one install.`

**(b) line 15 file tree agent 항목 제거:**

Edit:
- old_string:
```
│       │   ├── agent-skill-auditor.md
│       │   └── agent-skill-designer.md
```
- new_string:
```
│       │   └── agent-skill-auditor.md
```

**(c) line 17 file tree skill `harness-resource-design/` → `resource-design/`:**

Edit:
- old_string: `│       │   ├── harness-resource-design/      (in-house)`
- new_string: `│       │   ├── resource-design/              (in-house)`

**(d) line 37 agents description — agent-skill-designer 행 제거:**

Edit:
- old_string: `- **`agent-skill-designer`** — Design decisions, responsibility boundaries, routing, contracts, migration plans. Reads `harness-resource-design` as its rule reference.`
- new_string: (전체 행 + 직전 빈 줄 제거 — 정확 형식은 Read 결과 확인 후)

**(e) line 43 skill 표 `harness-resource-design` 행 → `resource-design`:**

Edit:
- old_string: `` | `harness-resource-design` | in-house | Reference-only design knowledge base used by `agent-skill-designer` and the main session. | ``
- new_string: `` | `resource-design` | in-house | Decide which resource type (command / skill / agent / hook / runtime settings / plugin) is needed + responsibility split + Execution Plan for downstream creator dispatch. Absorbs the former `harness-resource-design` skill and `agent-skill-designer` subagent. | ``

**(f) line 67 namespace 안내:**

Edit:
- old_string: `- Skills resolve as `/bobs-plugin:harness-resource-design`, `/bobs-plugin:context-map-architecture`, `/bobs-plugin:skill-creator`, `/bobs-plugin:claude-automation-recommender`.`
- new_string: `- Skills resolve as `/bobs-plugin:resource-design`, `/bobs-plugin:context-map-architecture`, `/bobs-plugin:skill-creator`, `/bobs-plugin:claude-automation-recommender`.`

**(g) line 68 agents 안내 (designer 제거):**

Edit:
- old_string: `- Agents `agent-skill-auditor` and `agent-skill-designer` appear in `/agents`.`
- new_string: `- Agent `agent-skill-auditor` appears in `/agents`.`

**(h) line 72 licensing — harness-resource-design → resource-design:**

Edit:
- old_string: `- Root `LICENSE` (MIT) covers original work: manifests, README, the GUIDE snapshot, `harness-resource-design`, and the two agents.`
- new_string: `- Root `LICENSE` (MIT) covers original work: manifests, README, the GUIDE snapshot, `resource-design` / `context-map-architecture` / `skill-creator` / `agent-creator` / `hook-creator` skills, and the `agent-skill-auditor` agent.`

**(i) line 79 migration notes:**

Edit:
- old_string: `- The user-scope copies at `~/.claude/agents/agent-skill-auditor.md`, `~/.claude/agents/agent-skill-designer.md`, and `~/.claude/skills/harness-resource-design/` can be removed.`
- new_string: `- The user-scope copies at `~/.claude/agents/agent-skill-auditor.md` and `~/.claude/skills/harness-resource-design/` (or older copies of `agent-skill-designer`) can be removed.`

주의: 항목 수가 baseline 의 6 보다 많다 (8 edits). baseline 의 정확 수는 Step 1 grep 으로 다시 확인 — 실제 grep 결과로 조정.

- [ ] **Step 5: `THIRD_PARTY_NOTICES.md` 갱신 — LICENSE 단락 1 곳**

Read `/Users/macpro/dev/bobs-plugin/THIRD_PARTY_NOTICES.md` 전체 (~15 lines).

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/THIRD_PARTY_NOTICES.md`
- old_string: `the harness-resource-design / context-map-architecture / skill-creator / agent-creator / hook-creator skill/agents authored by the repo owner`
- new_string: `the resource-design / context-map-architecture / skill-creator / agent-creator / hook-creator skill/agents authored by the repo owner`

주의: vendored 표 (claude-automation-recommender) + Apache-2.0 attribution 단락 (writing-skills, claude-md-improver excerpts) 은 변경 없음.

- [ ] **Step 6: `agent-skill-auditor.md` 갱신 — 3 곳**

Read `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/agents/agent-skill-auditor.md`.

**(a) line 4 description 의 `(agent-skill-designer)` 라우팅 → `(resource-design)`:**

Edit:
- old_string: `Do NOT use for 설계 결정·책임 분리·migration plan·frontmatter/contract 제안(agent-skill-designer)`
- new_string: `Do NOT use for 설계 결정·책임 분리·migration plan·frontmatter/contract 제안(resource-design)`

**(b) line 17 guide-rule-map 경로:**

Edit:
- old_string: `- 빠른 rule-ID 인덱스: `${CLAUDE_PLUGIN_ROOT}/skills/harness-resource-design/references/guide-rule-map.md``
- new_string: `- 빠른 rule-ID 인덱스: `${CLAUDE_PLUGIN_ROOT}/skills/resource-design/references/decision-rules.md``

**(c) line 28 라우팅 분리:**

Edit:
- old_string: `- 설계 결정, 책임 분리, migration plan, frontmatter/contract 제안 → `agent-skill-designer``
- new_string: `- 설계 결정, 책임 분리, migration plan, frontmatter/contract 제안 → `resource-design``

- [ ] **Step 7: `context-map-architecture/SKILL.md` 갱신 — 2 곳**

Read `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/context-map-architecture/SKILL.md`.

**(a) line 4 description 의 routing 부분:**

Edit:
- old_string: `Do NOT use for deciding resource type (skill/agent/hook) — `harness-resource-design` / `agent-skill-designer`.`
- new_string: `Do NOT use for deciding resource type (skill/agent/hook) — `resource-design`.`

**(b) line 25 Phase 1 routing:**

Edit:
- old_string: `- 자원 타입 결정 (skill / agent / hook / docs 중 무엇?) → `harness-resource-design` 또는 `agent-skill-designer`.`
- new_string: `- 자원 타입 결정 (skill / agent / hook / docs 중 무엇?) → `resource-design`.`

- [ ] **Step 8: `skill-creator/SKILL.md` 갱신 — 6 곳**

Read `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator/SKILL.md`.

각 위치를 baseline grep 결과 따라 개별 Edit. 패턴:

- 모든 `agent-skill-designer` → `resource-design`
- 모든 `harness-resource-design` → `resource-design`

주의: skill-creator SKILL.md 의 in-flight escape hatches 표 (line 67-73) 가 `agent-skill-designer (command 트랙)` / `harness-resource-design (hook 트랙)` 처럼 *트랙 명* 으로 인용한다. 새 `resource-design` 는 통합된 skill 이라 모든 트랙을 다룬다 — `resource-design (command 트랙)` / `resource-design (hook 트랙)` 처럼 트랙 명만 보존하고 자산명 통일.

샘플 Edit 들 (실제 실행 시 grep 결과로 정확 string 확인):

**(a) line 4 description**:
- `agent-vs-skill / merge / migration-order decisions (`agent-skill-designer`)` → `agent-vs-skill / merge / migration-order decisions (`resource-design`)`

**(b) line 11 관련 자산**:
- ``agent-skill-designer`(타입·책임 결정)` → ``resource-design`(타입·책임 결정)`

**(c)(d) line 38-39 routing**:
- `자원 타입(command / skill / agent / hook / runtime setting) 결정 → `agent-skill-designer`.` → `... → `resource-design`.`
- `사용자 명시 호출 workflow, 문서 링크/context 주입 라우터 작성 → `agent-skill-designer` 의 command 트랙` → `... → `resource-design` 의 command 트랙`

**(e) line 70 escape hatch (command 트랙)**:
- ``agent-skill-designer` (command 트랙)` → ``resource-design` (command 트랙)`

**(f) line 73 escape hatch (hook 트랙)**:
- ``harness-resource-design` (hook 트랙)` → ``resource-design` (hook 트랙)`

- [ ] **Step 9: `agent-creator/SKILL.md` 갱신 — 6 곳**

Read `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/agent-creator/SKILL.md`.

패턴: skill-creator 와 동일. 6 곳:

- line 4 description
- line 13 관련 자산
- line 40 routing
- line 71 escape hatch (command 트랙)
- line 73 escape hatch (hook 트랙)
- line 75 escape hatch (책임 분리 위임)

샘플:

- ``agent-skill-designer`(타입·책임 결정)` → ``resource-design`(타입·책임 결정)`
- ``agent-skill-designer` (command 트랙)` → ``resource-design` (command 트랙)`
- ``harness-resource-design` (hook 트랙)` → ``resource-design` (hook 트랙)`
- `책임을 둘 이상으로 분리하거나 `agent-skill-designer` 위임` → `책임을 둘 이상으로 분리하거나 `resource-design` 위임`

- [ ] **Step 10: `hook-creator/SKILL.md` 갱신 — 3 곳**

Read `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/hook-creator/SKILL.md`.

3 곳 (description / 관련 자산 / routing):

- ``agent-skill-designer`(타입·책임 결정)` → ``resource-design`(타입·책임 결정)`
- `자원 타입(skill / agent / hook) 결정 → `agent-skill-designer`` → `... → `resource-design``

- [ ] **Step 11: 2 자산 디렉토리/파일 삭제 (`git rm -r` / `git rm`)**

```bash
git rm -r plugins/bobs-plugin/skills/harness-resource-design
# harness-resource-design-workspace 가 존재하면 함께 삭제 (없으면 패스)
[ -d plugins/bobs-plugin/skills/harness-resource-design-workspace ] && \
  git rm -r plugins/bobs-plugin/skills/harness-resource-design-workspace
git rm plugins/bobs-plugin/agents/agent-skill-designer.md
```

주의:

- `agent-skill-auditor.md` 는 *유지* (§8 Asset Disposition — evaluation-loop-design 의 reference).
- workspace 디렉토리의 GAP 리포트는 시점 스냅샷 — 삭제 시 git history 에 보존됨.

Verify:

```bash
ls plugins/bobs-plugin/skills/ | grep -E "harness-resource-design"
# Expected: 빈 결과

ls plugins/bobs-plugin/agents/
# Expected: agent-skill-auditor.md 만 보임. agent-skill-designer.md 사라짐.

ls plugins/bobs-plugin/skills/
# Expected: resource-design 가 새로 보임. harness-resource-design 사라짐.
```

- [ ] **Step 12: 최종 verify — 활성 routing reference 0건 + 허용된 attribution/snapshot 만 잔류**

검증을 두 패스로 분리한다 (Step 2 plan 의 P1#1 precedent).

**(a) 활성 routing 위치 — 0건이어야 함**:

```bash
grep -rln "harness-resource-design\|agent-skill-designer" \
  README.md THIRD_PARTY_NOTICES.md LICENSE \
  .claude-plugin/ \
  plugins/bobs-plugin/.claude-plugin/ \
  plugins/bobs-plugin/agents/ \
  plugins/bobs-plugin/skills/ \
  plugins/bobs-plugin/references/AGENT-GUIDE.md \
  plugins/bobs-plugin/references/CONSTITUTION.md \
  plugins/bobs-plugin/references/GAP-FORMAT.md \
  plugins/bobs-plugin/references/GAP-ANALYSIS-PROMPT.md \
  plugins/bobs-plugin/references/HOOK-GUIDE.md \
  plugins/bobs-plugin/references/SKILL-GUIDE.md \
  plugins/bobs-plugin/references/COMMAND-GUIDE.md \
  plugins/bobs-plugin/references/RUNTIME-GUIDE.md \
  plugins/bobs-plugin/references/harness-principles.md \
  plugins/bobs-plugin/references/harness-installation-workflow.md \
  --include="*.md" --include="*.json" 2>/dev/null
```

Expected: **빈 결과** — 모든 활성 routing 위치에서 두 자산명 잡히지 않음.

활성 routing 위치에서 1건이라도 잡히면 → Task 4 의 어느 Step 이 누락된 것 → 위치 파악 후 Edit 추가.

**(b) 허용된 snapshot — 예상 위치에서 잔류 확인**:

```bash
# GAP report snapshots (historical artifacts, intentional)
grep -n "harness-resource-design\|agent-skill-designer" \
  plugins/bobs-plugin/skills/context-map-architecture-workspace/gaps/skill-context-map-architecture.GAP.md \
  plugins/bobs-plugin/skills/agent-creator-workspace/gaps/skill-agent-creator.GAP.md \
  plugins/bobs-plugin/skills/hook-creator-workspace/gaps/skill-hook-creator.GAP.md \
  2>/dev/null | head -10

# docs/specs/ docs/plans/ 자체 (현재 plan/spec 이 본 자산명 인용 — 시점 스냅샷)
grep -l "harness-resource-design\|agent-skill-designer" \
  plugins/bobs-plugin/docs/specs/ \
  plugins/bobs-plugin/docs/plans/ \
  -r 2>/dev/null
```

Expected:

- GAP report 들 — 시점 스냅샷 (Step 2 plan precedent — historical, 의도된 잔류)
- spec / plan markdown 들 — 본 plan + Step 2 plan + spec 자체 (시점 스냅샷)

각 위치가 *정확히 예상된 자리* 인지 확인. 예상 외의 매치가 있으면 추가 조사.

- [ ] **Step 13: Commit (deprecation + cross-ref)**

```bash
git add plugins/bobs-plugin/.claude-plugin/plugin.json \
        .claude-plugin/marketplace.json \
        README.md \
        THIRD_PARTY_NOTICES.md \
        plugins/bobs-plugin/agents/agent-skill-auditor.md \
        plugins/bobs-plugin/skills/context-map-architecture/SKILL.md \
        plugins/bobs-plugin/skills/skill-creator/SKILL.md \
        plugins/bobs-plugin/skills/agent-creator/SKILL.md \
        plugins/bobs-plugin/skills/hook-creator/SKILL.md

git commit -m "$(cat <<'EOF'
Deprecate harness-resource-design + agent-skill-designer (Step 3d)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 3d
       + §8 Asset Disposition + §10 Decision 1 (agent-skill-designer deprecate)

2 자산 디렉토리/파일 삭제 (git rm):
- skills/harness-resource-design/ (본문 + 4 references 흡수 → resource-design/{SKILL.md,references/}, MIT)
- skills/harness-resource-design-workspace/ (있으면 — GAP 시점 스냅샷 git history 에 보존)
- agents/agent-skill-designer.md (§0-§3 절차는 resource-design/references/agent-patterns.md 로,
  §4 출력 템플릿은 resource-design/references/design-output-contract.md 로 흡수.
  §10 Decision 1 — subagent 격리가 메인 세션 일상 결정에 정당화되지 않음)

메타 파일 갱신:
- plugin.json, marketplace.json: description 에서 agent-skill-designer + harness-resource-design
  제거, resource-design 추가
- README.md: file tree (agent + skill) / agents description / skill 표 / namespace / migration
  notes / licensing 8곳 갱신
- THIRD_PARTY_NOTICES.md: LICENSE 단락의 in-house 자산 목록 갱신 (harness-resource-design →
  resource-design)
- agent-skill-auditor.md: description routing + guide-rule-map 경로 + 라우팅 분리 3곳 갱신

5 sibling skill cross-reference 갱신 (모두 harness-resource-design / agent-skill-designer →
resource-design 로 통합):
- skills/context-map-architecture/SKILL.md: description + Phase 1 routing 2곳
- skills/skill-creator/SKILL.md: description + 관련 자산 + 2 routing + 2 escape hatch 6곳
- skills/agent-creator/SKILL.md: description + 관련 자산 + routing + 3 escape hatch 6곳
- skills/hook-creator/SKILL.md: description + 관련 자산 + routing 3곳

유지:
- agents/agent-skill-auditor.md (§8 Asset Disposition — evaluation-loop-design 의 reference,
  Step 4 처리)
- skills/claude-automation-recommender/ (vendored Apache-2.0, resource-design 의 reference)
- third_party_licenses/ 모든 LICENSE 파일 — 변경 없음
- workspace/gaps/*.GAP.md snapshots — historical artifacts

version bump 은 Step 7 (모든 Step 완료 후, 0.2.0 minor breaking) 에서 일괄.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Verify:

```bash
git log --oneline -3
git diff HEAD~1 HEAD --stat
```

Expected: ~12-15 files changed (4 metadata + 1 NOTICES + 1 agent + 4 sibling skills + 5-6 deleted files). 직전 commit 들 (Task 2 / Task 3) 과 함께 본 Step 3 의 commit 3개가 모두 보임.

---

## Self-Review

### Spec coverage

Spec §7 Step 3 (3a / 3b / 3c / 3d) + §4.1 책임 범위 + §8 Asset Disposition + §10 Decision 1 매핑:

| Spec item | Task |
|---|---|
| 3a 신규 skill draft + harness-resource-design 본문/refs 흡수 + agent-skill-designer 흡수 | Task 1 (preparation) + Task 2 Step 1-2 (skill-creator §2 + main session references write w/ mini-gate) |
| 3b GAP 분석 PASS (SKILL.md + 5 references target 확장) | Task 2 Step 3-4 (skill-creator §3-4 사이클 + references 흡수 audit Step 3b) |
| 3c workflow doc §3.1 채움 (3.1 / 3.2 numeric order) | Task 3 |
| 3d 2 자산 deprecate + plugin.json / NOTICES / README / 5 sibling cross-ref 갱신 | Task 4 |
| §4.1 spec format (Inventory / Required Resources / Resource Decisions / Execution Plan) | `design-output-contract.md` reference (Task 2 Step 2(e)) + SKILL.md Phase 3 |
| §8 Asset Disposition (agent-skill-designer 삭제, claude-automation-recommender 유지) | Task 4 Step 11 (designer 삭제, automation-recommender 변경 없음 명시) |
| §10 Decision 1 (agent-skill-designer subagent deprecate 사유) | Task 4 Step 11 commit msg |
| §10 Decision 4 (skill-creator 와 동일 GAP 사이클) | Task 2 Step 3 명시 사용 |
| §10 Decision 6 (Step 별 separate commit) | Task 2 / Task 3 / Task 4 — 총 3 commit |

추가 작업 (spec §7 에 명시 안 됨이나 일관성·재현성 위해 필수):

- `marketplace.json` description 갱신 (Task 4 Step 3) — plugin.json 과 동기화
- `README.md` 8 곳 갱신 (Task 4 Step 4) — 사용자가 보는 진입 문서
- `THIRD_PARTY_NOTICES.md` LICENSE 단락 in-house 자산 목록 갱신 (Task 4 Step 5)
- `agent-skill-auditor.md` 3 곳 cross-ref 갱신 (Task 4 Step 6) — agent-skill-auditor 는 유지되나 deprecated 자산을 인용
- 5 sibling skill (context-map-architecture / skill-creator / agent-creator / hook-creator 의 cross-ref) 갱신 (Task 4 Step 7-10) — Step 2 보다 큰 범위. *active routing references 0건 강제* 충족 필수
- references mini-gate (Task 2 Step 2(0)) — Step 2 plan P1#3 precedent
- 활성 routing refs 검증 + 허용된 snapshot refs 분리 (Task 4 Step 12 (a)/(b)) — Step 2 plan P1#1 precedent
- 본 Step 3 plan 파일 자체 commit — Step 2 plan review P2#1 precedent. Task 4 Step 13 commit 에 함께 포함하거나 별도 commit (사용자 선호)

### Placeholder scan

- 본 plan 본문에 TBD 없음.
- Task 4 Step 4 (h) 의 line 72 licensing 갱신: 정확 자산 목록은 실제 Read 후 확정 (`agent-skill-auditor` 유지 명시).
- Task 4 Step 8-10 의 sibling cross-ref Edit: 실제 grep 결과로 정확 string 확인 후 Edit (line 번호는 baseline 기준 예상값).

### Type consistency

- skill 이름 일관: `resource-design`
- references 파일명 일관: `decision-rules.md` / `skill-patterns.md` / `agent-patterns.md` / `hook-patterns.md` / `design-output-contract.md` (총 **5개**)
- workspace 경로 일관: `plugins/bobs-plugin/skills/resource-design-workspace/gaps/skill-resource-design.GAP.md`
- deprecated 2 자산 이름 일관 (`harness-resource-design` skill / `agent-skill-designer` subagent)

### Spec §10 Decisions 반영

| Decision | 본 plan 반영 위치 |
|---|---|
| Decision 1 — agent-skill-designer subagent deprecate | Task 4 Step 11 (`git rm agents/agent-skill-designer.md`), commit msg 에 사유 명시 |
| Decision 4 — skill-creator 동일 GAP 사이클 | Task 2 Step 3-4 (skill-creator §3-4 명시 사용) |
| Decision 6 — Step 별 separate commit | Task 2 Step 6 / Task 3 Step 4 / Task 4 Step 13 — 총 3 commit (Step 3 안에서) |
| 사용자 입력: skill 은 skill-creator 로 생성 | Task 2 Step 1 (`/skill-creator` 호출) |

### 잠재 위험

1. **references 작성 시점과 skill-creator §2 effect gate 의 상호작용** *(Step 2 plan 의 P1#3 precedent 적용)*
   - Task 2 Step 2 는 skill-creator §2 SKILL.md 작성 직후, §3 GAP 분석 진입 직전에 끼어든다.
   - skill-creator 의 시점 A gate 는 SKILL.md 1개 경로만 다룸 — references 는 별도 write 가 자연스러우나 effect gate 누수.
   - **완화**: Task 2 Step 2(0) 의 mini-gate (작성 경로 / source / target length / license / 압축 정책 5 항목 사용자 승인) 추가.

2. **GAP 분석 5라운드 초과 → NEEDS_REVIEW**
   - skill-creator §4c 발동 시 본 Step 미완료.
   - **완화**: 사용자 보고 → 책임 재정의 (`SPLIT_ASSET`) 또는 자원 타입 재검토. 본 plan 범위 밖 → 후속 사이클로 이월.

3. **5 sibling skill cross-ref 갱신 누락 위험**
   - 4 sibling skill (skill-creator / agent-creator / hook-creator) + context-map-architecture + agent-skill-auditor agent = 5 자산, 총 20-24 곳의 Edit.
   - 누락 시 *활성 routing reference* 가 잔존 → Task 4 Step 12 (a) verify 에서 잡혀야 함.
   - **완화**: Step 12 (a) 의 grep 이 0건 보장. 1건이라도 잡히면 누락된 Edit 추가.

4. **`harness-resource-design` 본문 (특히 guide-rule-map.md) 의 외부 참조 위험**
   - guide-rule-map.md 는 6 개 GUIDE (CONSTITUTION / SKILL-GUIDE / AGENT-GUIDE / COMMAND-GUIDE / HOOK-GUIDE / RUNTIME-GUIDE) 의 압축 인덱스. 다른 곳에서 이 경로를 hardcode 한 곳이 있으면 깨짐.
   - 확인된 경로 인용: `agent-skill-auditor.md` line 17 (Task 4 Step 6 (b) 에서 갱신).
   - **완화**: Task 4 Step 12 (a) 의 grep 이 `harness-resource-design/references/guide-rule-map.md` 같은 경로도 잡음 — verify 통과 시 안전.

5. **`agent-skill-designer` 잔존 vs `plugin.json` description**
   - Step 2 plan 에서는 designer 유지 (이번 Step 처리 예정). 본 Step 4 Step 2 가 designer 제거.
   - 결과: description 에서 agent-skill-designer 완전히 사라짐. agent-skill-auditor 만 단일 agent 로 남음.

6. **`marketplace.json` 의 `version` 필드**
   - description 만 갱신, `version: "0.1.3"` 은 유지.
   - Spec §10 Decision 6: version bump 는 모든 Step 완료 후 한 번 (0.2.0).
   - **수용**: Step 7 에서 일괄 bump.

7. **Spec §9.4 deprecated stub 권고를 본 Step 이 의도적으로 waive** *(Step 2 plan precedent 동일)*
   - Spec §9.4 는 "첫 1-2 cycle 동안 deprecated skill 의 SKILL.md 만 stub 으로 유지" 완화책을 제시한다.
   - 본 plan 의 Task 4 Step 11 은 stub 없이 `git rm` 즉시 삭제 — §9.4 권고와 충돌.
   - **waiver 근거**: Spec §2 Non-goals 가 "backward compatibility" 를 명시. §9.4 의 stub 완화는 *선택지* 이지 의무가 아니며, Non-goals 가 우선.
   - **수용 트레이드오프**: 사용자가 `/harness-resource-design` 또는 `agent-skill-designer` 옛 이름으로 호출 시 "not found" → main session 의 `/resource-design` 으로 다시 안내 필요.
   - **대안 (선택)**: 운영 우려가 크면 Task 4 Step 11 직전에 stub SKILL.md (frontmatter + 1줄 redirect) 작성 추가 — 본 plan 은 기본 *깨끗한 삭제* 채택.

8. **`agent-creator/SKILL.md` 의 line 75 escape hatch — "책임을 둘 이상으로 분리하거나 `agent-skill-designer` 위임"**
   - 이 escape hatch 는 *책임 분리가 필요할 때 designer 에게 위임* 하라는 의미. designer 가 사라지면 *resource-design* 에 위임하도록 갱신.
   - **완화**: Task 4 Step 9 의 명시 Edit.

9. **claude-automation-recommender 의 description / 표시 변경 없음 명시 필요**
   - Step 3 에서 claude-automation-recommender 는 유지 (§8 Asset Disposition).
   - 본 Step 의 README skill 표 / namespace 안내 등에서 claude-automation-recommender 위치는 그대로 유지.
   - **확인**: Task 4 Step 4 의 Edit 들이 claude-automation-recommender 행을 *수정하지 않음* 을 verify.

10. **Step 2 plan + 본 Step 3 plan 자체의 commit 시점**
    - Step 2 plan 은 review 적용 commit (642efc5) 에 archive 됨.
    - 본 Step 3 plan 은 Task 4 Step 13 commit 에 함께 archive 하거나 별도 commit. 사용자 선호 결정 항목.
    - **권장**: 본 plan 작성 commit 을 별도로 (작업 시작 전), 또는 Task 4 commit 에 포함. Step 2 plan 의 archive 패턴과 동일하게.

---

## Execution Handoff

Plan 완료 (Task 4 / commit 3). Spec §7 의 Step 3 (resource-design skill 작성 + 2 자산 deprecate + workflow doc §3.1 + 5 sibling cross-ref) 이 본 plan 에 담겼다.

후속:

- Step 4 (evaluation-loop-design skill) — 별도 plan
- Step 5 (evaluation-loop-runner skill, runtime)
- Step 6 (workflow doc 최종 정리 — §7 anti-patterns + §8 verification)
- Step 7 (creator skill spec 인터페이스 호환 확인 + version bump 0.2.0)

각 Step 은 본 Step 3 완료 후 새 plan 작성.

다음 단계 결정:

- **A. Subagent-Driven (recommended)** — Task 단위 fresh subagent 가 실행, 사이 검토. `superpowers:subagent-driven-development`
- **B. Inline Execution** — 본 세션에서 batch 실행. `superpowers:executing-plans`
- **C. Pause** — Step 4-7 plan 도 미리 준비 후 일괄 실행
- **D. /codex-review** — 본 plan 을 외부 모델에 1-shot 리뷰 의뢰 (Step 2 plan precedent 동일)
