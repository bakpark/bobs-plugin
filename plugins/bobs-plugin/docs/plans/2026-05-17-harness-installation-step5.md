# Harness Installation — Step 5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 신규 `evaluation-loop-runner` *runtime* skill 을 `skill-creator` 로 작성. 본 스킬은 `evaluation-loop-design` 가 작성한 *명세* (`docs/agent/evaluation-loop.md` / `golden-set.md` / `task-log-template.md`) 를 *실행 시점* 에 따라 실행 — task log 캡처 + golden-set 비교 + Routing Decision 결정 + 자동 chain. workflow doc §5.2 placeholder 채우고, 5 sibling skill 의 cross-reference 갱신.

**Architecture:** runner skill 은 *명세 실행자* (executor) — 명세 작성 책임은 `evaluation-loop-design` (Step 4 산출). 본 skill 의 Capability Procedure 3-phase: Phase 1 (task log entry write — `task-log-template.md` schema 따름) → Phase 2 (gap 분석 — `golden-set.md` case 비교) → Phase 3 (Routing Decision — `evaluation-loop.md` Routing Decision 표 행 선택 + Next Action). 자동 chain 은 *main session* 책임 (runner 는 stateless, 한 호출마다 decision 만 반환). references 1-2개 (`runtime-protocol.md` — 자동 chain + 종료 조건 + main session 책임 정의). 본 Step 은 *흡수 대상 자산이 없는 신규 작성* 이므로 deprecation 작업 없음.

**Tech Stack:** skill-creator skill (메타 스킬, interactive — Step 4b 후 §3-§4 는 `creator-gap-eval` 호출 stub), Edit/Write tools, agent-skill-auditor (참고 자산 — runner 의 정적 감사)

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §4.4 (runner 책임 + 산출 4 섹션 + 종료 조건 4종) + §7 Step 5 (`runtime 동작 중심. task log 캡처 + gap 분석 + 라우팅`) + §9.2 (hook vs runner 책임 경계 — *명시 호출* 우선) + §9.6 (무한 사이클 완화 — 종료 조건 4종) + §10 Decision 5 (호출 시점 — 명시 호출 우선) + spec §8 Asset Disposition (runner 추가)

**전체 migration 중 위치:** Step 5 of 7. **Prerequisite: Step 4 (`evaluation-loop-design` skill + 4 references 산출) 완료** — Step 4 의 `references/{evaluation-loop,golden-set,task-log-template,roles}-write.md` 가 본 runner 가 *실행할 명세 형식* 의 source of truth. Step 4b (`creator-gap-eval` 추출) 도 완료 (commit `cd58d13` / `f21bfc1` / `7ddaa35`) — 본 Step 의 skill-creator 호출 시 §3-§4 는 `creator-gap-eval` 호출 stub 으로 동작.

**Step 6/7 와의 책임 경계** (spec §7 Step 5 의 `5c. workflow doc §5.2 / §6 채움` 모호성 해소):

| 작업 | 책임 Step | 근거 |
|---|---|---|
| runner skill 본문 (SKILL.md + references) | Step 5 (본 plan) | spec §4.4 |
| workflow doc §5.2 (runner 인터페이스) | Step 5 (본 plan) | spec §7 Step 5c + Step 6 plan 의 §5.2 본문 책임 위임 |
| workflow doc §6 (chain 절차 + 종료 조건 + 카운터) | Step 6 | Step 6 plan Task 3 (workflow-level chain) |
| workflow doc §7 (anti-patterns) + §8 (verification) | Step 6 | Step 6 plan Task 4 |
| creator §0 args 정렬 + version bump | Step 7 | Step 7 plan |

본 분리는 spec §7 의 `/` 을 alternation 으로 해석. Step 5 = §5.2 만, Step 6 = §6 + §7 + §8 + consistency. Step 6 plan 의 Task 2 §5 채움은 *§5.1 (creator args 표)* 만 본 Step 6 책임 + §5.2 본문은 Step 5 산출 → Step 6 진입 시 *verify only* 로 자연스럽게 처리.

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md` | Create (skill-creator §2) | runtime 실행 절차 (Capability Procedure 3-phase: task log capture / gap compare / routing decision) (~250-350 lines) |
| `plugins/bobs-plugin/skills/evaluation-loop-runner/references/runtime-protocol.md` | Create (main session, §2 직후) | 자동 chain 절차 + main session 책임 (카운터 / 종료 조건 enforce / Next Action dispatch) (~120-180 lines) |
| (선택) `plugins/bobs-plugin/skills/evaluation-loop-runner/references/log-entry-write.md` | Create (main session, §2 직후) | task log entry write 절차 — `task-log-template.md` schema 적용 (Phase 1 wrapper, ~80-120 lines). 단, evaluation-loop-design 의 `task-log-template-write.md` 가 *template 작성 절차* 라 본 reference 와 책임 분리: design = template 정의 / runtime = template 따라 entry write |
| `plugins/bobs-plugin/skills/evaluation-loop-runner-workspace/gaps/skill-evaluation-loop-runner.GAP.md` | Create (skill-creator §3 → creator-gap-eval) | GAP report |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (§5.2 채움) | "TBD per Step 5 + Step 7" 의 §5.2 부분 → 실제 본문 (runner 인터페이스 + 산출 contract) |
| `plugins/bobs-plugin/.claude-plugin/plugin.json` | Edit (description) | evaluation-loop-runner 추가 — 현재 description 끝 `+ evaluation-loop-runner` |
| `.claude-plugin/marketplace.json` | Edit (description) | 동일 |
| `README.md` | Edit (file tree + skill 표 + namespace + intro) | evaluation-loop-runner 추가 |
| `plugins/bobs-plugin/agents/agent-skill-auditor.md` | Edit (description Do NOT 1줄 추가) | evaluation-loop-runner 라우팅 명시 (정적 감사 vs runtime 실행 분리). plan 작성 시점 grep: 0 곳 |
| `plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md` | Edit (1곳 — runner freshness 표기 갱신) | references 의 `planned as of 2026-05-17, target Step 5` 가 *현재 존재* 로 갱신 |
| `plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md` | Edit (line 7 + line 44 freshness 갱신) | "runtime executor: evaluation-loop-runner (planned as of 2026-05-17, target Step 5)" → "runtime executor: evaluation-loop-runner" |
| `plugins/bobs-plugin/skills/evaluation-loop-design/references/task-log-template-write.md` | Edit (line 7 + line 38 freshness 갱신) | 동일 |
| `plugins/bobs-plugin/skills/skill-creator/SKILL.md` | Edit (1곳 추가 — When NOT) | evaluation-loop-runner 라우팅 명시 (runtime 실행은 본 runner 가, 본 creator 는 skill 작성만). plan 작성 시점 grep: 0 곳 |
| `plugins/bobs-plugin/skills/agent-creator/SKILL.md` | Edit (1곳 추가 — When NOT) | 동일 |
| `plugins/bobs-plugin/skills/hook-creator/SKILL.md` | Edit (1곳 추가 — When NOT) | 동일 |
| `plugins/bobs-plugin/skills/resource-design/SKILL.md` | Edit (검증만 / 필요 시 1곳 추가) | 5-asset taxonomy 에 runner 가 *runtime skill* 로 추가 — 단 5-asset taxonomy 자체가 변경되지 않음 (runner 는 일반 skill scope), routing decision 표 인용만 |
| `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` | Edit (검증만 — 변경 0 곳 예상) | 인용 없음 |
| `plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md` | Edit (검증만 — 변경 0 곳 예상) | 본 Step 의 skill-creator 호출 시 §3-§4 stub 으로 본 skill 사용 — 본 skill 본문 변경 없음 |
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` | Edit (§7 Step 5 ✅ + §8 Asset Disposition 행 추가) | Step 5 완료 표기 + runner 추가 |

**유지** (변경 없음):
- `plugins/bobs-plugin/skills/claude-automation-recommender/` — vendored Apache-2.0
- `plugins/bobs-plugin/third_party_licenses/` 모든 LICENSE 파일
- `plugins/bobs-plugin/references/{harness-principles,CONSTITUTION,SKILL-GUIDE,AGENT-GUIDE,HOOK-GUIDE,COMMAND-GUIDE,RUNTIME-GUIDE,GAP-FORMAT}.md` — normative source, runner 가 직접 인용
- `plugins/bobs-plugin/skills/evaluation-loop-design/references/{roles,golden-set}-write.md` — runner 인용 없음 (Phase 2 가 `docs/agent/golden-set.md` 직접 인용, design references 는 *작성 절차* 라 runtime 무관)

**deprecation 없음**: 본 Step 의 신규 skill 은 흡수 대상 기존 자산이 없다.

---

## Note on TDD for skill creation

skill-creator 자체가 GAP-driven (Step 4b 후 §3-§4 는 `creator-gap-eval` 호출 stub) 사이클이므로 본 plan 의 Task 2 는 *외부* TDD 가 아닌 *creator-gap-eval 내부* GAP loop 에 의존한다. Task 3 (workflow doc §5.2) + Task 4 (cross-ref 갱신) 는 doc 작업이라 *verify-baseline → change → verify-result → commit* 패턴.

## Note on "묻지 말고 진행" 모드 (mini-gate 약화)

본 plan 의 mini-gate (Task 2 Step 2 `(0)` 항목) 는 CONSTITUTION §3.3 Effects Require Gates 의 *approval* 을 요구하는 강한 형태가 default. 사용자 *묻지 말고 진행* (pre-approved batch) 모드 합의 시 *disclosure-only* (5 항목 응답 기록, 확인 없이 진행) 로 약화. 본 plan 은 약화를 plan 단위로 합의한 것으로 간주 — Task 2 의 references write 가 silent execution 으로 보여도 의도된 동작.

## Note on runtime vs design 책임 경계 (drift-avoidance)

runner skill 의 본문이 `docs/agent/evaluation-loop.md` Routing Decision 표 *본문* 을 재생산하면 drift 원인. runner 는 *명세 위치* 만 인용:

- Phase 2 (gap 분석) — `docs/agent/golden-set.md` case 비교 절차 인용 (case 정의 본문 X)
- Phase 3 (Routing Decision) — `docs/agent/evaluation-loop.md` Routing Decision 표 *행* 선택 (표 본문 X)
- Phase 1 (task log) — `docs/agent/task-log-template.md` schema 적용 (schema 본문 X)

본 분리가 runner 의 Common Failures 안티패턴 1번. evaluation-loop-design 의 `evaluation-loop-write.md` 본문 (Routing Decision 표 6 행) 이 진실 source — runner 는 매번 *해당 파일을 read* 해서 행 선택.

---

### Task 1: skill-creator 호출 준비 — intent brief

**Files:**
- (편집 없음 — preparation only)

skill-creator §0 Capture Intent 가 사용자에게 묻기 전, main session 이 intent 를 사전 정리해 한 번에 제공. 본 Task 는 정보 추출만 — commit 없음.

- [ ] **Step 1: 흡수 대상 / 참조 source 정리**

본 skill 은 흡수 대상이 *없다* (신규 작성). 다음 normative source 참조 자료로 정리:

| 참조 source | 사용 위치 |
|---|---|
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §4.4 | runner 책임 + 산출 4 섹션 + 자동 chain + 종료 조건 4종 |
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §9.2 + §9.6 + §10 Decision 5 | hook vs runner 경계 / 무한 사이클 완화 / 명시 호출 우선 |
| `plugins/bobs-plugin/references/harness-principles.md` §4.5 (Context Map 라우팅) + 라인 294 task-log-capture + 라인 381 evaluation-loop.md | runtime 라우팅 + log 캡처 + sibling 호출 |
| `plugins/bobs-plugin/skills/evaluation-loop-design/references/{evaluation-loop,golden-set,task-log-template}-write.md` | *실행할 명세* 의 작성 절차 — runner 는 산출물 (docs/agent/*.md) 을 read 해서 따름 |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` §6 (작성 예정, Step 6) | chain 절차 — runner 가 stateless 한 상태에서 main session 이 chain. 본 Step 5 가 §5.2 채움, §6 은 Step 6 책임 |
| `plugins/bobs-plugin/references/CONSTITUTION.md` §3.1 (Activation Explicit) + §3.4 (Output Contract) + §3.13 (Freshness) | runtime skill 의 활성화 / 산출 contract / freshness 표기 |

- [ ] **Step 2: skill-creator §0 답안 정리 (메모리만)**

| # | skill-creator §0 질문 | 답 |
|---|---|---|
| 1 | 재사용 책임 (한 문장) | `evaluation-loop-design` 가 작성한 명세 (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md`) 를 *실행 시점* 에 적용 — task log entry write + golden-set case 비교 + Routing Decision 행 선택 + Next Action 반환. main session 이 Next Action 따라 design skill chain |
| 2 | 트리거 (1-3개) | "evaluation runner", "사이클 진입", "task log 캡처", "골든셋 비교", "라우팅 결정", "/runner" 명시 호출, 이전 design skill 산출 후 자동 chain |
| 3 | Negative trigger (≥1) | 명세 작성 (`evaluation-loop-design`), 자원 작성 (creator skills), 자원 타입 결정 (`resource-design`), docs 인덱싱 (`context-map-architecture`), 정적 rule 감사 (`agent-skill-auditor`), creation-time GAP 적용 (`creator-gap-eval`), 코드/PR 리뷰 |
| 4 | 호출자가 산출물로 무엇을 하나 | 산출 4 섹션 (Task Log Entry path / Gap Analysis / Routing Decision / Next Action) — main session 이 Next Action 의 design skill 자동 chain (종료 조건 4종 enforce). chain 종료 시 사용자에게 사이클 결과 요약 |
| 5 | 부수 효과 | 파일 작성 *있음* — `docs/agent/logs/YYYY-MM-DD-<slug>.md` entry write. `docs/agent/logs/` 디렉토리 미존재 시 첫 entry write 시 mkdir (design references 의 task-log-template-write.md §1 명시). workspace 디렉토리 (GAP report 저장) 도 생성. Effect gate 이중 — 1단계 (capture intent): runner 호출 자체 (명시 호출 또는 자동 chain 의 첫 entry) / 2단계 (apply): entry write 직전 경로·내용 요약 1회 확인 (CONSTITUTION §3.3) |
| 6 | scope | plugin (`plugins/bobs-plugin/skills/evaluation-loop-runner/`) |

- [ ] **Step 3: skill-creator 첫 메시지 한 줄 brief 작성**

```
name: evaluation-loop-runner
scope: plugin (plugins/bobs-plugin/skills/evaluation-loop-runner/)
책임: runtime 실행자 — evaluation-loop-design 가 작성한 명세
  (docs/agent/{evaluation-loop,golden-set,task-log-template}.md) 를 실행 시점에
  적용. task log entry write + golden-set case 비교 + Routing Decision 행 선택 +
  Next Action 반환. main session 이 Next Action 따라 design skill chain.
트리거: "evaluation runner", "사이클 진입", "task log 캡처", "골든셋 비교",
  "라우팅 결정", "/runner" 명시 호출, 이전 design skill 산출 후 자동 chain
negative: 명세 작성 (evaluation-loop-design), 자원 작성 (creator skills),
  자원 타입 결정 (resource-design), docs 인덱싱 (context-map-architecture),
  정적 rule 감사 (agent-skill-auditor), creation-time GAP 적용 (creator-gap-eval),
  코드/PR 리뷰
spec format: 산출 4 섹션 (Task Log Entry path / Gap Analysis / Routing Decision /
  Next Action) — spec §4.4 본문 정확히 따름. spec_version v1 (workflow doc §4 표준
  인터페이스와 별개 — runner 는 spec 산출자 아닌 *실행자*. spec_version 필드 비적용)
effect gate: 이중 — 1단계 (호출 자체) + 2단계 (entry write 직전 경로·내용 요약)
  CONSTITUTION §3.3 적용.
Capability Procedure 3-phase:
  - Phase 1: task log entry write (task-log-template.md schema 적용)
  - Phase 2: gap 분석 (golden-set.md case 비교, 5종 표면 PASS/FAIL/no-op/blocked/needs_input)
  - Phase 3: Routing Decision (evaluation-loop.md Routing Decision 표 행 선택) +
    Next Action 결정
종료 조건 4종 (spec §4.4 + §9.6): no-op / 사용자 명시 / 같은 design skill 2회 /
  누적 5회 — main session 책임 (runner stateless), runtime-protocol.md 가 enforce 절차.
references 1-2개 (main session 이 §2 SKILL.md draft 직후 mini-gate 거쳐 직접 작성):
  - references/runtime-protocol.md (~120-180 lines) — 자동 chain + main session 책임
  - (선택) references/log-entry-write.md (~80-120 lines) — Phase 1 wrapper, design
    references 의 task-log-template-write.md 가 *template 정의* 라면 본 reference 는
    *runtime 적용 절차* — 책임 분리 확정 후 작성 여부 결정
참고 자산 (변경 없음): evaluation-loop-design (Step 4), agent-skill-auditor
  (§8 Asset Disposition — 정적 감사 대상)
관련 normative source (직접 참조, 본문 재생산 금지):
  - ${CLAUDE_PLUGIN_ROOT}/docs/specs/2026-05-17-harness-installation-design.md §4.4
  - ${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md §4.5 + line 294 + line 381
  - ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md §3.1 / §3.4 / §3.13
  - project-side: docs/agent/{evaluation-loop,golden-set,task-log-template}.md
    (runtime read 대상 — 부재 시 mode: blocked + needs_input "evaluation-loop-design
    먼저 호출")
```

본 brief 는 Task 2 Step 1 에서 skill-creator 호출 시 입력.

- [ ] **Step 4: references 작성 여부 사전 결정**

| Reference | 작성 여부 | 근거 |
|---|---|---|
| `runtime-protocol.md` | **작성** | 자동 chain + 종료 조건 enforce 가 *main session 책임* — SKILL.md 본문은 *runner 의 산출만* 명시, chain 절차 자체는 별도 reference 가 적절. ~120-180 lines |
| `log-entry-write.md` | **작성** (단, 단순 wrapper) | Phase 1 의 *template 따라 entry write* 절차. design 의 `task-log-template-write.md` 는 *template 정의 절차* — runtime 적용은 다른 절차. ~80-120 lines |
| `gap-compare.md` | **작성하지 않음** | Phase 2 는 `golden-set.md` case 의 *5종 표면* (PASS/FAIL/no-op/blocked/needs_input) 비교 — 절차가 단순 (case 별 PASS 조건 check + 결과 분류). SKILL.md 본문에 내장 |
| `routing-decision.md` | **작성하지 않음** | Phase 3 는 `evaluation-loop.md` Routing Decision 표의 *행 선택* — 표 본문은 design references 에 보존, 선택 절차는 단순. SKILL.md 본문에 내장 |

총 references 2개 (`runtime-protocol.md` + `log-entry-write.md`). context-map-architecture / evaluation-loop-design references 4개 패턴과 다름 — runner 는 *명세 실행자* 라 절차가 단순.

---

### Task 2: skill-creator 로 신규 skill 작성 + references 직접 작성 (Step 5a/5b)

**Files:**
- Create (skill-creator §2): `plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/evaluation-loop-runner/references/runtime-protocol.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/evaluation-loop-runner/references/log-entry-write.md`
- Create (creator-gap-eval §3a, Step 4b 후 stub 통해): `plugins/bobs-plugin/skills/evaluation-loop-runner-workspace/gaps/skill-evaluation-loop-runner.GAP.md`

- [ ] **Step 1: skill-creator 호출 (intent 사전 제공)**

호출:
```
/skill-creator
```

첫 메시지: Task 1 Step 3 의 brief block 그대로 붙여넣기.

- [ ] **Step 2: SKILL.md draft + mini-gate disclosure (시점 A)**

skill-creator §2 가 SKILL.md draft. 본문 첫 작성 직전 mini-gate 5 항목 응답에 기록 (disclosure-only):

| 항목 | 내용 |
|---|---|
| 작성 경로 | `plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md` (절대 경로) |
| frontmatter | `name: evaluation-loop-runner`, description (trigger 7 + Do NOT 7), `user-invocable: true` (사용자 `/runner` 호출 허용) |
| 본문 골격 | Capability Procedure 3-phase (Phase 1 Task Log Capture / Phase 2 Gap Analysis / Phase 3 Routing Decision + Next Action) + Output Contract + Common Failures + References (2개) |
| 산출 contract | spec §4.4 의 4 섹션 정확 따름 — Task Log Entry path / Gap Analysis / Routing Decision / Next Action |
| workspace 경로 | `plugins/bobs-plugin/skills/evaluation-loop-runner-workspace/gaps/` (GAP report 저장) |

`(0)` 묻지 말고 진행 모드 — disclosure-only, 즉시 write 진행. SKILL.md 본문 작성.

- [ ] **Step 3: SKILL.md draft 직후 references 2개 직접 작성**

`runtime-protocol.md`:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `plugins/bobs-plugin/skills/evaluation-loop-runner/references/runtime-protocol.md` |
| 길이 목표 | 120-180 lines |
| 내용 골격 | 자동 chain 절차 (main session 책임) / 라운드 카운트 enforce / 종료 조건 4종 enforce / Next Action dispatch 형식 / hook 트리거 vs 명시 호출 경계 (§9.2) / 무한 사이클 완화 (§9.6) |

`log-entry-write.md`:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `plugins/bobs-plugin/skills/evaluation-loop-runner/references/log-entry-write.md` |
| 길이 목표 | 80-120 lines |
| 내용 골격 | `docs/agent/task-log-template.md` schema 적용 절차 (frontmatter 5 fields + body 7 sections) / `docs/agent/logs/` lazy mkdir / 파일명 규칙 (`YYYY-MM-DD-<slug>.md`) / append 필드 (Gap Analysis / Routing Decision) 처리 / 비밀 redaction |

각 reference 작성 직전 mini-gate 5 항목 응답 기록 (disclosure-only). 두 reference 모두 normative source 인용 (본문 재생산 금지) + drift-avoidance 명시.

- [ ] **Step 4: skill-creator §3 → creator-gap-eval (Step 4b 후 stub 호출)**

skill-creator 의 §3 (GAP 분석) 는 Step 4b 후 `creator-gap-eval` 호출 stub 으로 동작. main session 이 `Skill(creator-gap-eval)` 호출 — args:

```yaml
resource_type: skill
draft_path:
  - plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md
asset_name: evaluation-loop-runner
delegation_mode: delegate     # 외부 평가자 독립성 확보 — 본 plan 의 default
reentry_count: 0
```

`creator-gap-eval` 의 §3 (Workspace 결정) 가 통합 workspace (`creator-gap-eval-workspace/gaps/skill-evaluation-loop-runner.GAP.md`) 결정. (또는 자체 workspace — Step 4b 결정 따름)

`delegation_mode: delegate` 진행 시 generic subagent dispatch. attempt 결과 → Final Decision.

- [ ] **Step 5: Final Decision 분기**

| Final Decision | 행동 |
|---|---|
| `PASS` / `PASS_WITH_NOTES` | §5 (Output to caller) + Task 3 진입 |
| `REVISE_ASSET` | P0/P1/P2 적용 → §3 재실행. 라운드 카운트 증가 |
| `SPLIT_ASSET` | §0 으로 복귀, 책임 분리 재설계 (예: Phase 1 entry write 만 별도 skill 분리) |
| `DEPRECATE_ASSET` | 폐기 권고 — 본 plan 의 본질이 깨짐. 사용자 confirm 후 plan rollback |
| `NEEDS_REVIEW` | 사용자 입력 받기 |
| `REVISE_GUIDE` | GUIDE_GAP — 사용자 보고 + 자산 통과 (skill-creator §4d) |

- [ ] **Step 6: Commit (skill + references + workspace)**

```bash
git add plugins/bobs-plugin/skills/evaluation-loop-runner/ \
        plugins/bobs-plugin/skills/evaluation-loop-runner-workspace/
git commit -m "Add evaluation-loop-runner skill (Step 5a/5b)"
```

또는 GAP report 별도 워크스페이스 (creator-gap-eval-workspace 통합) 면 별도 commit 으로 정리.

---

### Task 3: workflow doc §5.2 채움

**Files:**
- Edit: `plugins/bobs-plugin/references/harness-installation-workflow.md` (line 252-258 의 §5.2 부분만)

**책임 명시**: 본 Task 가 `§5.2` 만 채움. `§5.1` (creator args 표) 은 Step 6 책임 / `§6` (chain 절차) 도 Step 6 책임. 본 Task 가 §5.2 만 채우고 §5.1 + §6 의 TBD 는 유지.

- [ ] **Step 1: baseline read**

```bash
sed -n '252,258p' plugins/bobs-plugin/references/harness-installation-workflow.md
```

현재:
```
## 5. Phase 2 Execution Skills

TBD per Step 5 (`evaluation-loop-runner`) + Step 7 (creator skills 호환 확인).

- 5.1 `skill-creator` / `agent-creator` / `hook-creator` (이미 GAP-driven, spec 입력 받음)
- 5.2 `evaluation-loop-runner` (runtime — task log + gap 라우팅)
```

- [ ] **Step 2: §5.2 본문 template 작성**

```markdown
## 5. Phase 2 Execution Skills

TBD per Step 7 (creator skills 호환 확인 — 5.1 본문은 Step 6 채움).

### 5.1 Creator skills — `skill-creator` / `agent-creator` / `hook-creator`

TBD per Step 6 (본 §5.1 본문은 Step 6 plan Task 2 가 채움. 본 Step 5 는 §5.2 만 채움 — 책임 분리).

### 5.2 `evaluation-loop-runner` — runtime cycle

**역할**: Phase 1 design skill 의 산출 (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 명세) 를 *실행 시점* 에 적용. design skill 은 *명세* 만 작성, 본 runner 가 *명세대로 실행*. runner 는 *stateless* — 한 호출마다 task log entry write + gap 분석 + Routing Decision 한 묶음만 반환. 자동 chain 은 *main session 책임* (라운드 카운터 유지 + 종료 조건 enforce).

**입력 trigger** (3종 — spec §10 Decision 5 명시 호출 우선):

1. 사용자 명시 호출 (`/runner` 또는 동등 command)
2. 자동 chain — 이전 사이클의 *Next Action* 이 *다음 design skill* 을 가리키면 main session 이 chain
3. PR / commit 후 hook 트리거 (사전 등록된 PostCommit / Stop hook — spec §9.2 의 *hook = raw 데이터 수집* 경계 따름. hook 은 *runner 호출* 까지만, 사이클 실행은 별도)

**Capability Procedure** (3-phase, `docs/agent/evaluation-loop.md` 명세 따름):

1. Phase 1 — task log capture: `docs/agent/task-log-template.md` schema 따라 `docs/agent/logs/YYYY-MM-DD-<slug>.md` entry write
2. Phase 2 — gap 분석: `docs/agent/golden-set.md` case 와 entry 비교. 5종 표면 (PASS / FAIL / no-op / blocked / needs_input) 분류
3. Phase 3 — Routing Decision: `docs/agent/evaluation-loop.md` Routing Decision 표 행 선택 + Next Action 결정

**산출 contract** (spec §4.4 4 섹션 정확 따름):

```yaml
mode: cycled | no-op | needs_input | blocked
task_log_entry: <abs path to docs/agent/logs/*.md>     # Phase 1 산출
gap_analysis:                                          # Phase 2 산출
  case_id: <golden-set case ID>
  result: PASS | FAIL | no-op | blocked | needs_input
  summary: <한 줄>
routing_decision: <design skill name 또는 no-op>       # Phase 3 산출
next_action:                                           # Phase 3 산출
  target: <design skill name>
  input:
    prior_task_log: <abs path>
    gap_summary: <한 줄>
round: <N>     # main session 이 stateless runner 에 매 호출마다 증가시켜 전달
```

**Effect** (CONSTITUTION §3.3 이중 gate):

- 1단계 (호출 자체) — runner 호출이 명시 호출 또는 자동 chain — main session 이 호출 전 사용자 의도 확인 (자동 chain 중에는 종료 조건 enforce 가 1단계 역할)
- 2단계 (apply) — task log entry write 직전 경로·내용 요약 1회 응답 기록 (disclosure-only 가능)

**docs/agent body 부재 시**: `mode: blocked` + `needs_input` ("`evaluation-loop-design` 먼저 호출해 검증 자산 작성 필요"). runner 는 *명세 실행자* 이지 *명세 작성자* 아님 — 명세가 없으면 실행 불가.

**`docs/agent/logs/` 디렉토리 부재 시**: runner 의 Phase 1 가 lazy mkdir (design 의 `task-log-template-write.md` §1 명시).
```

`§5.1` 도 TBD 표기 유지 — Step 6 책임. 본 Task 는 *§5.2 본문만* 작성. §5 헤더의 "TBD per Step 5 + Step 7" 표기를 "TBD per Step 7 (§5.1 본문은 Step 6 채움)" 로 갱신 — Step 5 작업 완료 명시.

- [ ] **Step 3: Edit 적용**

```
Edit(workflow doc, 
     old_string="## 5. Phase 2 Execution Skills\n\nTBD per Step 5 (`evaluation-loop-runner`) + Step 7 (creator skills 호환 확인).\n\n- 5.1 `skill-creator` / `agent-creator` / `hook-creator` (이미 GAP-driven, spec 입력 받음)\n- 5.2 `evaluation-loop-runner` (runtime — task log + gap 라우팅)",
     new_string=<Step 2 template>)
```

- [ ] **Step 4: Verify**

```bash
# §5 헤더 "TBD per Step 5" 제거 (Step 7 만 남음)
grep -n "TBD per Step 5\|TBD per Step 7\|TBD per Step 6" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 
#   §5 헤더: "TBD per Step 7 (§5.1 본문은 Step 6 채움)"
#   §5.1: "TBD per Step 6"
#   §6: "TBD per Step 5" 제거 → 단, §6 은 Step 6 책임. 본 Step 은 §6 TBD 유지.
# 즉: "TBD per Step 5" 가 §6 에 1 곳 남음 — Step 6 가 처리

# §5.2 본문 작성 확인
grep -nE "^### 5\.2 .evaluation-loop-runner" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 1 line

# 인용 자원 (docs/agent/*.md 4종) ghost-free 검사 불요 — *project-side 산출 path template* 으로 명시 (drift-avoidance Note)

# runner skill 본문 cross-ref
grep -c "evaluation-loop-runner" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: ≥3 (§2 Routing 표는 영향 없음 — runner 는 design skill 아님)
```

**§6 의 "TBD per Step 5" 처리**: 본 Step 5 가 §6 채우지 않음 → §6 의 TBD 표기를 "TBD per Step 6" 으로 *수정* 가능 (Step 책임 명확화). 단, 본 plan 의 책임 분리표 명시했으므로 별도 수정 없이 Step 6 진행 시 자연스러움.

옵션: 본 Step 의 Task 3 Step 2 본문에 `## 6. Cycle ...` 의 "TBD per Step 5" 도 동시 갱신 ("TBD per Step 6") — 1 줄 변경. 작업 범위 자연스러움.

- [ ] **Step 5: §6 TBD 표기 책임 명확화 (1 줄 갱신)**

```bash
sed -n '259,261p' plugins/bobs-plugin/references/harness-installation-workflow.md
# 현재: 
# ## 6. Cycle — Runtime → 재진입
# 
# TBD per Step 5.
```

Edit:
```
Edit(workflow doc, 
     old_string="## 6. Cycle — Runtime → 재진입\n\nTBD per Step 5.",
     new_string="## 6. Cycle — Runtime → 재진입\n\nTBD per Step 6 (§5.2 runner 본문은 Step 5 완료 — Step 6 의 chain 절차 본문이 본 §6 채움).")
```

본 변경은 Step 6 진행 시 ghost 없음 보장 + 책임 분리 명확.

- [ ] **Step 6: Commit §5.2 채움**

```bash
git commit -am "Fill harness-installation-workflow §5.2 (evaluation-loop-runner) + §6 책임 명확화"
```

---

### Task 4: cross-ref 정리 (plugin meta + sibling skill + freshness 갱신 + spec)

**Files:**
- Edit: `plugins/bobs-plugin/.claude-plugin/plugin.json` (description)
- Edit: `.claude-plugin/marketplace.json` (description)
- Edit: `README.md` (file tree + skill 표 + namespace + intro)
- Edit: `plugins/bobs-plugin/agents/agent-skill-auditor.md` (description Do NOT 1줄)
- Edit: `plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md` (freshness 갱신 — line 7 + line 44)
- Edit: `plugins/bobs-plugin/skills/evaluation-loop-design/references/task-log-template-write.md` (freshness 갱신 — line 7 + line 38)
- Edit: `plugins/bobs-plugin/skills/skill-creator/SKILL.md` (When NOT 1줄 추가)
- Edit: `plugins/bobs-plugin/skills/agent-creator/SKILL.md` (When NOT 1줄 추가)
- Edit: `plugins/bobs-plugin/skills/hook-creator/SKILL.md` (When NOT 1줄 추가)
- Edit: `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` (§7 Step 5 ✅ + §8 Asset Disposition 행 추가)

- [ ] **Step 1: plugin.json description**

현재 description (Step 4b 반영):
```
"Bob's bundle for Claude harness work: agent-skill-auditor + resource-design + context-map-architecture + evaluation-loop-design + skill-creator + agent-creator + hook-creator + creator-gap-eval (3 creator §3-§4 통합 GAP 적용 절차, 직접 호출도 가능) (with the agent-skill-best-practices GUIDE)."
```

갱신:
```
"Bob's bundle for Claude harness work: agent-skill-auditor + resource-design + context-map-architecture + evaluation-loop-design + evaluation-loop-runner + skill-creator + agent-creator + hook-creator + creator-gap-eval (3 creator §3-§4 통합 GAP 적용 절차, 직접 호출도 가능) (with the agent-skill-best-practices GUIDE)."
```

`evaluation-loop-runner` 를 `evaluation-loop-design` 직후에 추가 (논리적 인접).

```
Edit(plugin.json, 
     old_string='+ evaluation-loop-design + skill-creator',
     new_string='+ evaluation-loop-design + evaluation-loop-runner + skill-creator')
```

- [ ] **Step 2: marketplace.json description — 동일 갱신**

```
Edit(marketplace.json, 
     old_string='+ evaluation-loop-design + skill-creator',
     new_string='+ evaluation-loop-design + evaluation-loop-runner + skill-creator')
```

- [ ] **Step 3: README.md — 5 곳 갱신**

`grep -n "evaluation-loop-design" README.md` 로 현재 위치 확인. 각 위치 옆에 evaluation-loop-runner 추가:
- intro / file tree / skill 표 / namespace / licensing 또는 동등 위치

각 위치별 1 줄 추가 또는 표 행 1 줄 추가.

- [ ] **Step 4: agent-skill-auditor description Do NOT 한 줄 추가**

현재 description Do NOT 절에 `evaluation-loop-design` 라우팅 명시. 본 Step 에서 `evaluation-loop-runner` 라우팅 추가 — runtime 실행은 본 agent 의 정적 감사가 아닌 runner 책임.

추가 어구 예시:
```
Do NOT use for: ... evaluation-loop-runner (runtime 실행 — task log 캡처 + gap 분석 + 라우팅).
```

`evaluation-loop-design` 어구 직후에 자연스럽게 삽입.

- [ ] **Step 5: evaluation-loop-design references freshness 갱신**

`evaluation-loop-write.md` line 7 + line 44:
```
"runtime executor: evaluation-loop-runner (planned as of 2026-05-17, target Step 5 of harness-installation-workflow.md)"
→
"runtime executor: evaluation-loop-runner (plugins/bobs-plugin/skills/evaluation-loop-runner/)"
```

`task-log-template-write.md` line 7 + line 38: 동일 패턴.

freshness 표기 (CONSTITUTION §3.13) — runner 가 실존하므로 *planned* 표기 제거 + 현재 경로 명시. 확인 날짜 표기 옵션: "확인일: 2026-05-17, runner skill 존재" 한 줄 추가.

- [ ] **Step 6: 3 creator When NOT 한 줄씩 추가**

각 creator §"When NOT to use" 절에 evaluation-loop-runner 라우팅 추가:
```
- runtime 사이클 실행 (task log 캡처 + gap 분석 + 라우팅) → `evaluation-loop-runner`. 본 creator 는 *skill/agent/hook 작성* 만, runtime 실행 아님.
```

3 creator (`skill-creator` / `agent-creator` / `hook-creator`) 각각.

- [ ] **Step 7: resource-design / context-map-architecture / creator-gap-eval 검증만**

각 skill 의 본문에서 evaluation-loop-runner 인용 필요 여부 확인. 일반적으로 *없음* (resource-design 은 5-asset taxonomy 안 runtime skill 카테고리 — runner 가 일반 skill 으로 들어가므로 별도 갱신 불요. context-map-architecture / creator-gap-eval 도 runner 와 직접 의존 없음).

확인 명령:
```bash
for s in resource-design context-map-architecture creator-gap-eval; do
  echo "=== $s ==="
  grep -c "evaluation-loop-runner\|evaluation-loop-design" "plugins/bobs-plugin/skills/$s/SKILL.md"
done
```

evaluation-loop-design 1 곳 이상 있고 runner 0 곳 시 — 인용 필요성 평가. 본 Step 의 cross-ref 정책은 *직접 의존 자원만 cross-ref* — runner 가 5 sibling 의 직접 의존 아니므로 추가 안 함.

- [ ] **Step 8: spec §7 Step 5 ✅ + §8 Asset Disposition 행 추가**

spec line 328 (`### Step 5. evaluation-loop-runner skill 작성`) 갱신:
```
### Step 5. `evaluation-loop-runner` skill 작성 ✅

5a. ✅ runtime 동작 중심. task log 캡처 + gap 분석 + 라우팅.
5b. ✅ GAP 분석 → PASS (`creator-gap-eval` 통한 — Step 4b 후 chain).
5c. ✅ workflow doc §5.2 채움 (§6 은 Step 6 책임 — `5c. workflow doc §5.2 / §6 채움` 의 `/` 모호성 해소: alternation, §5.2 만).
```

§8 Asset Disposition 표에 `evaluation-loop-runner` 행 추가:

```
| `evaluation-loop-runner` (신규) | 유지 — runtime 실행자 (명세는 evaluation-loop-design 산출, 본 runner 가 실행). 자동 chain main session 책임 | Step 5 |
```

- [ ] **Step 9: Commit cross-ref**

```bash
git add plugins/bobs-plugin/.claude-plugin/plugin.json \
        .claude-plugin/marketplace.json \
        README.md \
        plugins/bobs-plugin/agents/agent-skill-auditor.md \
        plugins/bobs-plugin/skills/evaluation-loop-design/references/ \
        plugins/bobs-plugin/skills/skill-creator/SKILL.md \
        plugins/bobs-plugin/skills/agent-creator/SKILL.md \
        plugins/bobs-plugin/skills/hook-creator/SKILL.md \
        plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md
git commit -m "Cross-ref evaluation-loop-runner across plugin meta + 4 sibling skills + spec mark Step 5 (Step 5d)"
```

---

## Done Criteria

본 Step 5 가 완료되면 다음 조건이 모두 충족됨:

- [ ] `evaluation-loop-runner/SKILL.md` 작성 + GAP `PASS` / `PASS_WITH_NOTES` (P0/P1=0):
  ```
  ls plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md
  # GAP report path 확인 — creator-gap-eval-workspace 또는 evaluation-loop-runner-workspace
  ```

- [ ] `references/{runtime-protocol,log-entry-write}.md` 2개 작성:
  ```
  ls plugins/bobs-plugin/skills/evaluation-loop-runner/references/
  # Expected: 2 files
  ```

- [ ] SKILL.md 의 산출 contract 가 spec §4.4 4 섹션 정확 따름 (Task Log Entry path / Gap Analysis / Routing Decision / Next Action) — grep 검증:
  ```
  grep -c "task_log_entry\|gap_analysis\|routing_decision\|next_action" \
    plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md
  # Expected: ≥4
  ```

- [ ] Capability Procedure 3-phase 명시 (Phase 1 task log capture / Phase 2 gap 분석 / Phase 3 Routing Decision):
  ```
  grep -nE "^## Phase [123]|^### Phase [123]" plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md
  # Expected: 3 lines
  ```

- [ ] 종료 조건 4종 명시 (spec §4.4 + §9.6) — runtime-protocol.md 에서:
  ```
  grep -c "no-op\|사용자 명시\|2회 연속\|5회 초과" \
    plugins/bobs-plugin/skills/evaluation-loop-runner/references/runtime-protocol.md
  # Expected: ≥4
  ```

- [ ] drift-avoidance — runner 본문이 Routing Decision 표 / golden-set case / task-log-template schema *본문 재생산* 0:
  ```
  grep -c "^| 신호 | 환원 위치 |\|^### case-" \
    plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md \
    plugins/bobs-plugin/skills/evaluation-loop-runner/references/*.md
  # Expected: 0
  ```

- [ ] workflow doc §5.2 본문화 (TBD `per Step 5` 제거 — §6 의 TBD 는 Step 6 책임):
  ```
  grep -nE "^### 5\.2 .evaluation-loop-runner" plugins/bobs-plugin/references/harness-installation-workflow.md
  # Expected: 1 line
  
  grep -n "TBD per Step 5" plugins/bobs-plugin/references/harness-installation-workflow.md
  # Expected: 0 (§6 도 "TBD per Step 6" 으로 갱신했으므로)
  ```

- [ ] freshness 갱신 — evaluation-loop-design references 2 파일 (4 곳) 의 `planned as of 2026-05-17, target Step 5` 제거:
  ```
  grep -rn "planned as of 2026-05-17, target Step 5" plugins/bobs-plugin/skills/evaluation-loop-design/
  # Expected: 0
  ```

- [ ] plugin.json + marketplace.json + README + agent-skill-auditor description + spec §7 Step 5 ✅ + §8 행 추가 모두 갱신

- [ ] 3 creator When NOT 한 줄씩 추가:
  ```
  for c in skill-creator agent-creator hook-creator; do
    grep -c "evaluation-loop-runner" "plugins/bobs-plugin/skills/$c/SKILL.md"
  done
  # Expected: 1 1 1
  ```

- [ ] 인용 자원 ghost-free — `docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 인용은 *project-side 산출 path template* 으로 명시 (workflow doc + SKILL.md drift-avoidance Note)

- [ ] Commit 3건 (skill+refs / workflow doc §5.2 / cross-ref) — 총 commit 수 +3

---

## Notes for executor

본 plan 은 *runtime skill 신규 작성* — Step 4 와 동일 크기 (~880 lines plan / ~250-350 lines SKILL.md + 2 references). 예상 ~2-3시간.

**Step 6 진입 prereq**: 본 Step 5 완료 → Step 6 plan 의 옵션 (A) 진행 가능. Step 6 plan 의 Task 2 Step 3 (§5.2 본문) 은 본 Step 5 가 채웠으므로 *verify only* (실제 본문 작성 0 곳 — 본 Step 5 산출 검증만). Step 6 plan 본문은 옵션 (A) default 가정이므로 그대로 진행 가능.

**Step 6 plan 본문과의 일관성 issue** (P2 finding 후보 — 본 Step 진입 후 발견 가능):
- Step 6 plan Task 2 §5 본문 작성이 *§5.1 + §5.2 모두* 작성으로 표기 — 본 Step 5 가 §5.2 채웠으므로 Step 6 진입 시 Task 2 Step 3 (§5.2 본문) 은 *skip + verify only* 로 해석. Step 6 plan 본문 보강 (한 줄 — "§5.2 본문은 Step 5 산출, Task 2 Step 3 = verify only") 별도 commit 옵션. 본 plan 의 책임 분리표가 명시했으므로 plan-level 문서로 충분.

**runner 자체의 self-application** (runner 가 자기 자신을 평가) — 본 Step 진행 시 runner 의 첫 사이클이 본 Step 5 의 작업 자체일 가능성 (재진입). 처리:
- runner 의 `task_type` 이 "evaluation-loop-runner 자체 작성" 이면 Phase 2 의 case 비교 시 (자기 자신을 평가하는) 무한 사이클 신호 → main session 이 chain 중단 + 사용자 보고
- 즉 runner 의 첫 사이클은 본 Step 5 작업 *완료 후 별도 cycle* 로 진행 권장 (self-evaluation 분리)

**version bump 의 implications** (Step 7 plan 의 P2#5 review finding):
- 본 Step 5 완료 시 0.1.3 → 0.2.0 bump 가능 신호 (Step 1-5 + 4b 누적 breaking 마무리)
- 단, Step 6 / 7 모두 진행 후 version bump 가 깨끗 — Step 7 가 version bump 책임 (현재 plan)

**다음 plan**:
- Step 6 실행 (workflow doc §5.1 + §6 + §7 + §8 채움 + consistency pass)
- Step 7 실행 (3 creator §0 args 정렬 + version bump 0.1.3 → 0.2.0)
- (선택) GAP-005 GUIDE_GAP follow-up — SKILL-GUIDE §7/§8 에 write-procedure reference 권장 골격 추가
