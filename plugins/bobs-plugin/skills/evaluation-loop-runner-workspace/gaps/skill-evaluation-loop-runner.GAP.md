# GAP Report — skill `evaluation-loop-runner`

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2 (CONSTITUTION.md + SKILL-GUIDE.md + GAP-FORMAT.md)
검토자: cold-start reviewer (이전 대화 컨텍스트 무시, 대상 3 파일 + cwd 기준 문서만)
asset_type: skill
source_path:
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/evaluation-loop-runner/references/runtime-protocol.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/evaluation-loop-runner/references/log-entry-write.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md
보조 참조 (cwd 외 — 책임 경계 확인용만): docs/specs/2026-05-17-harness-installation-design.md §4.4/§9.2/§9.6/§10 Decision 5; sibling skill evaluation-loop-design 의 references (Routing Decision 표 정의 source / 5종 표면 정의 source / 보존 정책 정의 source)
final_decision: PASS_WITH_NOTES
```

## 2. Executive Summary

`evaluation-loop-runner` 는 design skill (`evaluation-loop-design`) 가 만든 명세를 *실행 시점* 에 적용하는 stateless runtime skill 이다. 한 호출당 Phase 1 (entry write) → Phase 2 (gap 분류) → Phase 3 (Routing Decision + Next Action) 한 묶음을 산출하고, 자동 chain·라운드 카운트·종료 조건 4종 enforce 는 main session 으로 외주한다.

핵심 강점:
- *명세 실행자 / 명세 작성자* 책임 분리가 SKILL.md 본문, references, Common Failures 표에 일관되게 명시됨 (CONSTITUTION §3.2 / §3.10 OK).
- Output Contract 가 YAML 4 섹션 + `mode` enum 4종 + `next_action.target` 빈 값 규약까지 mechanically 파싱 가능 (§3.4 OK).
- *Routing Decision 표 본문 재생산 금지* 가 본문 + Common Failures + References 의 `Normative source` 블록 3 곳에서 반복 강조 (drift 방지 / §3.14 docs source of truth OK).
- 종료 조건 4종, hook vs runner 경계, self-application 보완 (§5) 등 무한 사이클 위험 완화가 runtime-protocol.md 에 행 단위로 구조화 (§3.7 / §3.9 OK).

주요 finding: **P0/P1 없음.** 다만 다음 P2/P3 가 잔류한다.
- `tools` 미선언 (`Read`/`Write`/`Bash` 만 쓴다고 Limits 마지막에 자기 선언이 있으나 frontmatter 에는 없음) — capability surface 강제력 약함 (P2).
- description 65 단어, near-miss 7종 나열 — 라우팅 정확도는 높지만 description heuristic 상한 (15-60 words, SKILL-GUIDE §9) 살짝 초과 (P3).
- `references/log-entry-write.md` §6 의 effect-gate 본문이 `Phase 1` 의 disclosure 항목 7종을 *full literal* 로 명시하고 있어 부분적으로 design skill 산출 (`task-log-template.md` schema 5+7 필드) 과 *형식 재생산* 경계에 있음 — 명시적 drift 위험은 낮지만 §3.14 정신과 약한 충돌 (P3).
- `mode` 4종 중 `needs_input` 과 `blocked` 의 분기 우선순위가 SKILL.md `Output Contract` 의 표 한 칸 ("자원 부재는 blocked 우선") 에서만 나타남 — 본문 Phase 2/3 인스펙트 절차에는 명시되지 않아 구현 모호성 (P2).

Final Decision: **PASS_WITH_NOTES** — 의도된 책임 분리·산출 contract 가 v2 원칙에 부합. 잔류 finding 은 모두 후속 iteration 옵션.

## 3. Asset Snapshot

```text
name: evaluation-loop-runner
description: "Use when 작업 종료 후 사이클 진입 / task log 캡처 / 골든셋 비교 / 라우팅 결정이 필요할 때. 이전 design skill 산출 후 자동 chain 또는 사용자 `/evaluation-loop-runner` 명시 호출. `evaluation-loop-design` 가 작성한 `docs/agent/{evaluation-loop,golden-set,task-log-template}.md` 명세를 *실행*. Do NOT use for 명세 작성 (`evaluation-loop-design`), 자원 작성 (creator skills), 자원 타입 결정 (`resource-design`), docs 인덱싱 (`context-map-architecture`), 정적 rule 감사 (`agent-skill-auditor`), creation-time GAP 적용 (`creator-gap-eval`), 코드/PR 리뷰."
description_words: 65
body_words: ~1700 (frontmatter + 본문)
body_lines: 179 (SKILL.md), references 143 + 146 lines
tools: omitted (frontmatter 에 없음 — Limits 마지막 줄에서 Read/Write/Bash 만 자기 선언)
invocation_controls: user-invocable: true (모델 자동 호출 + 사용자 명시 호출 모두 허용)
has_references: true (2 files — runtime-protocol.md, log-entry-write.md)
has_scripts_or_assets: false (코드/asset 없음 — markdown 만)
has_effect_gate: true (이중 gate — 1단계 호출 자체, 2단계 entry write 직전 disclosure)
has_output_contract: true (YAML 4 섹션 + mode enum 4종 + main session 후속 동작 표)
```

추가 구조 메모:
- 본문 섹션 8개: When to Use / When NOT to Use / Capability Procedure (Phase 1/2/3) / Output Contract / Common Failures / References / Limits
- Common Failures 표 11 행 — 안티패턴 별 증상/수정 명시
- References: 2 internal + 3 normative source (`spec §4.4` / `harness-principles.md` / `CONSTITUTION.md`) + 3 project-side runtime read
- Limits: 5 항목 (한 사이클 / 명세 부재 / stateless / self-application / capability surface)

## 4. Applicable Criteria

| 원칙 | 강도 | 본 리뷰에서 적용 |
|---|---|---|
| §3.1 Activation Explicit | Hard | description 의 trigger / when NOT / overlap 명시 — 평가 대상 |
| §3.2 Scope Quality | Hard | 단일 책임 (한 사이클 실행) 명확. Limits 으로 stateless / chain 외부화 확인 |
| §3.3 Effects Gates | Hard | entry write 가 mutation → 이중 gate 명시 (호출 자체 + write 직전 disclosure) |
| §3.4 Output Contract | Hard | YAML 4 섹션 + mode 4종 + main session 후속 동작 표 — 평가 대상 |
| §3.5 Capability Surface | Hard | tools frontmatter 없음 / Limits 마지막에 자기 선언 — 평가 대상 |
| §3.6 Reusable vs Local | Design | 본 skill 은 plugin scope, project-side 자원 (`docs/agent/*.md`) 은 *런타임 read*. 프로젝트 고유 규칙 본문 하드코딩 없음 |
| §3.7 Progressive Disclosure | Design | 본문 ≤ 200 lines + 2 references 분리 |
| §3.8 Strong Language | Design | "must / NEVER / 금지" 가 effect gate, 책임 분리, drift 방지에 한정되는지 검사 |
| §3.9 Verifiable | Design | should-trigger / should-not-trigger / no-op / 종료 조건 검증 절차 |
| §3.10 Overlap Intentional | Design | sibling 6 skill (design / creator / context-map / agent-creator 등) 와의 경계 명시 |
| §3.13 Freshness (추가 축) | Heuristic | runtime behavior 확인 시점 / version 표기 |
| §3.14 Docs Source of Truth (추가 축) | Hard | Routing Decision 표 본문 재생산 금지 / 5종 표면 정의 source / 보존 정책 source |

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | `Use when` 5종 trigger + `Do NOT use for` 7종 negative trigger 모두 명시. `When to Use` / `When NOT to Use` 본문 섹션 추가 보강 |
| Description avoids workflow shortcut | partial | description 이 trigger + scope + NOT 7종 모두 담아 65 단어 — workflow 절차 자체는 나열 안 함, 다만 SKILL-GUIDE §9 의 15-60 words 권장 초과 (heuristic) |
| Scope or near-miss is clear when needed | pass | 7개 인접 skill (`evaluation-loop-design` / creator skills / `resource-design` / `context-map-architecture` / `agent-skill-auditor` / `creator-gap-eval` / `pr-review-toolkit`) 와의 경계 명시 |
| Workflow is actionable | pass | Phase 1/2/3 각각 입력/산출/inspect/effect gate 명시. 절차 4-단계 + 분기 조건 명시 |
| Effect gate exists when mutation is possible | pass | 이중 gate (호출 자체 + write 직전 disclosure) + User mode "묻지 말고 진행" 분기 |
| Output contract exists | pass | YAML 4 섹션 + mode 4종 enum + main session 후속 동작 표 + `next_action.target` 빈 값 규약 |
| Progressive disclosure is appropriate | pass | 본문 179 lines, 2 references 로 절차 위임 (`runtime-protocol.md` = main session 책임, `log-entry-write.md` = Phase 1 wrapper). 본문에 절차 핵심만 남음 |
| Reusable vs project memory is separated | pass | plugin scope skill, project-side 자원 (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md`) 은 *runtime read* 로 처리, 본문에 하드코딩 없음 |
| Behavior can be verified | partial | should-trigger / should-not-trigger 명시 가능. 종료 조건 4종 검증 절차 `runtime-protocol.md §2` 에 행 단위 검출 방법. 다만 should-not-trigger 의 *near-miss 실제 케이스* (예: "사용자가 'task log 보여줘' 라고 했을 때 runner 호출 X — read-only 조회") 같은 예시 부재 |
| Overlap is intentional | pass | `evaluation-loop-design` 와의 경계 — runner = 실행자 / design = 작성자 — SKILL.md / runtime-protocol.md / log-entry-write.md 3 곳에 일관 명시. hook vs runner 경계는 spec §9.2 + §10 Decision 5 references 로 명시 |
| Capability surface matches responsibility (§3.5) | partial | frontmatter `tools:` 없음. Limits 마지막에 "Read, Write, Bash. Web/MCP/외부 모델/자동 commit/push 미사용" 자기 선언 — capability 제한이 *문서 수준* 만, frontmatter 강제 없음 |
| Strong language belongs to real gates (§3.8) | pass | "금지 / NEVER / must" 가 — (a) 명세 read 강제, (b) 본문 재생산 금지, (c) entry write 비밀 redaction, (d) stateful 시도 금지 — 모두 실제 gate. 일반 권장에 강한 표현 없음 |
| Docs source of truth (§3.14) | partial | Routing Decision 표 본문 재생산 금지가 본문 + Common Failures + Normative source 3 곳 강조 — 강함. 다만 `log-entry-write.md §3` 의 frontmatter 5 fields + body 7 sections + `§4` append 필드, `§6` disclosure 7 항목이 *task-log-template-write.md (design skill 산출)* 의 schema 를 본문 안에 재생산 — 약한 drift 위험 |
| Freshness (§3.13) | partial | SKILL.md 본문에 작성일 / runtime behavior 확인일 / version 표기 없음. runtime-protocol.md 와 log-entry-write.md 도 동일. normative source 만 `2026-05-17` 날짜 명시 |

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `CONSTITUTION.md §3.5` / `SKILL-GUIDE.md §2` | frontmatter `tools:` 미선언 — capability surface 강제력 약함 | asset 수정 (frontmatter 에 `tools: Read, Write, Bash` 명시) |
| GAP-002 | ASSET_GAP | P2 | `CONSTITUTION.md §3.4` / `SKILL-GUIDE.md §7` | `mode: needs_input` vs `mode: blocked` 분기 우선순위가 Output Contract 표 한 줄에만 — Phase 2/3 본문 절차에 누락 | asset 수정 (Phase 2 의 inspect 단계 + Phase 3 절차에 우선순위 명시) |
| GAP-003 | ASSET_GAP | P3 | `SKILL-GUIDE.md §3` / §9 | description 65 단어 — heuristic 15-60 words 초과 (라우팅 혼선 증거 없음) | asset 수정 (옵션) — `Do NOT use for` 7항목을 `When NOT to Use` 본문으로 이동, description 은 trigger 중심 ~ 40 단어로 압축 |
| GAP-004 | ASSET_GAP | P3 | `CONSTITUTION.md §3.14` / `SKILL-GUIDE.md §11` Reference dump | `log-entry-write.md §3/§4/§6` 가 design skill (`task-log-template-write.md`) 의 schema (frontmatter 5 fields + body 7 sections + 보존 정책) 를 본문 안에 재생산 — drift 위험 | asset 수정 (frontmatter/body schema 본문 인용 대신 *fetch then apply* 패턴 — "매 entry write 마다 template read" 강제만 남기고 본문 schema 인용은 1줄 yaml 예시로 축소) |
| GAP-005 | ASSET_GAP | P3 | `SKILL-GUIDE.md §8` | should-not-trigger near-miss 실제 케이스 부재 — 검증 루프 약함 | asset 수정 (옵션) — `Common Failures` 하단 또는 `When NOT to Use` 옆에 "사용자가 'task log 보여줘'/'골든셋 뭐 있어' 같은 *read-only 조회* 발화 시 호출 X" 같은 1-2개 명시 |
| GAP-006 | ASSET_GAP | P3 | `CONSTITUTION.md §3.13` | runtime behavior 확인 시점 / version 표기 부재 (SKILL.md / 2 references 모두) | asset 수정 (옵션) — frontmatter 또는 본문 첫 줄에 `verified-on: 2026-05-17` 또는 동등 표기 |
| GAP-007 | GUIDE_GAP | P3 | Guide target: `SKILL-GUIDE.md §2` | frontmatter `tools:` 미선언이 *advisory* skill (no mutation) 에선 OK 지만, *mutation 가능 skill* (entry write) 의 경우 `tools:` 명시 권장 — 가이드 §2 의 "tools 명시는 필수 필드가 아니다" 문구가 mutation 가능 skill 의 강제력 신호를 흐림 | guide 수정 follow-up — `SKILL-GUIDE.md §2` 에 "mutation 가능 skill 은 capability surface 명시 권장" 1줄 보강 |
| GAP-008 | AMBIGUITY | P2 | `CONSTITUTION.md §3.4` | `runtime-protocol.md §4` 의 *hook 트리거 시 phase: 1-only 옵션 필요* 문구 — SKILL.md 본문 Output Contract 에는 `phase` 필드 부재 → hook 가 호출했을 때 runner 가 실제로 어떻게 Phase 1 만 실행하는지 구현 모호 | 사용자 확인 후 결정 — (a) `phase` 필드 추가, (b) hook 가 runner 호출하지 않고 raw script (예: `task-log-capture.sh`) 만 직접 실행하는 패턴으로 변경 (spec §9.2 권장), (c) 본 부분은 *향후 옵션* 으로 명시 후 현재는 spec §10 Decision 5 의 "명시 호출만" 정책으로 차단 |

상세 finding:

### GAP-001: frontmatter `tools:` 미선언

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.5 Capability Surface` / `SKILL-GUIDE.md §2 Frontmatter` |

**Expected**

mutation 가능한 skill (entry write + `mkdir -p`) 은 capability surface 를 frontmatter 에 명시. SKILL-GUIDE §2: "read-only 나 mutation 제한이 중요하면 명시하는 편이 낫다."

**Actual**

frontmatter:
```yaml
---
name: evaluation-loop-runner
description: Use when ...
user-invocable: true
---
```
`tools:` 누락. capability 제한은 본문 마지막 `Limits` 의 한 줄 — "Capability surface: `Read` (명세 + entry source), `Write` (`docs/agent/logs/YYYY-MM-DD-<slug>.md` entry), `Bash` (`mkdir -p docs/agent/logs/` lazy create). Web / MCP / 외부 모델 / 자동 commit / 자동 push 미사용" — 자기 *기술* 만, frontmatter 강제 아님.

**Evidence**

`SKILL.md:1-5` (frontmatter), `SKILL.md:179` (Limits 마지막 줄).

**Impact**

본 skill 이 명세에 어긋나는 도구 호출 (예: `WebFetch`, `Edit` 으로 entry 본문 *수정*) 을 시도해도 harness 가 차단 안 함. 본문이 mutation 범위를 `docs/agent/logs/*.md` 로 한정하지만 *문서 수준* — runtime guardrail 없음. Common Failures #4 (append 영역 본문 침범) 가 실제로 일어났을 때 frontmatter 가 잡지 못함.

**Recommendation**

asset 수정:
```yaml
tools: Read, Write, Bash
```
추가. 본문 Limits 의 자기 선언과 일치하며, harness 가 capability surface 를 강제하게 됨.

---

### GAP-002: `needs_input` vs `blocked` 분기 우선순위 본문 누락

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.4 Output Contract` / `SKILL-GUIDE.md §7` |

**Expected**

Output Contract 가 mode 4종을 정의했다면, 각 mode 진입 조건이 본문 절차 (Phase 1/2/3 inspect 단계) 에서 결정적이어야 함 — runtime 이 동일 상황에서 동일 mode 산출.

**Actual**

`SKILL.md Output Contract` 의 표:
```text
| needs_input | Phase 2 의 5종 표면 중 needs_input 또는 inspect 단계 의존 자원 부재 (자원 부재는 blocked 우선) |
```
의 *"자원 부재는 blocked 우선"* 만 분기 우선순위 명시. Phase 1 inspect (`SKILL.md:45-46`) 와 Phase 2 inspect (`SKILL.md:72`), Phase 3 inspect (`SKILL.md:101`) 각각의 *부재 시 동작* 은 "`mode: blocked` + needs_input" 라는 표현 일관 — 하지만 만약 *case 정의에 의해 needs_input 이 발생하면서 동시에 의존 자원도 부재* 한 경우 어떻게 분기하는지 본문에 명시되지 않음.

**Evidence**

`SKILL.md:45-46`, `SKILL.md:72`, `SKILL.md:101`, `SKILL.md:127` (Output Contract 표 needs_input 행).

**Impact**

runtime 이 두 신호가 겹치는 상황에서 임의로 mode 선택 → main session 후속 동작 (단계 5 의 사용자 안내 내용) 도 임의 변동. Output Contract 의 *결정적 산출* 원칙 약화.

**Recommendation**

asset 수정 — Phase 2 inspect 또는 Output Contract 의 `mode` 표 옆에 한 줄: "복수 신호 동시 발생 시 우선순위: `blocked` > `needs_input` > `no-op` > `cycled` (자원 부재가 가장 강한 신호)" 추가.

---

### GAP-003: description 65 단어 — heuristic 초과

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §3 Description` / §9 |

**Expected**

description 보통 15-60 words (heuristic — 초과 자체가 실패는 아니지만 라우팅 혼선이나 context 비용이 있을 때 GAP).

**Actual**

description = 65 단어. Use when (4종) + 핵심 책임 + `Do NOT use for` (7종) 모두 포함.

**Evidence**

`SKILL.md:3` — 한 줄 description.

**Impact**

본 description 은 항상 노출되는 metadata. workflow shortcut 은 아니지만 *7종 negative trigger* 가 description 안에 늘어서 context 비용 약간 증가. 라우팅 정확도는 오히려 높음 — 실제 운영 영향 작음.

**Recommendation**

asset 수정 (옵션) — `Do NOT use for ...` 7항목을 description 에서 제거, `When NOT to Use` 본문 섹션 (이미 있음) 으로 위임. description 은 trigger 중심 ~ 40 단어로 압축. 다만 현재 형태가 라우팅 혼선을 만들지 않으면 그대로 둬도 무방.

---

### GAP-004: `log-entry-write.md` 가 design skill 산출 schema 재생산

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.14 Docs Source of Truth` (추가 축) / `SKILL-GUIDE.md §11 Reference dump 안티패턴` |

**Expected**

본 skill 은 *명세 실행자*. design skill (`evaluation-loop-design`) 가 작성한 `docs/agent/task-log-template.md` 가 *frontmatter 5 fields + body 7 sections + 보존 정책 4종* 의 source of truth. runner reference 는 *적용 절차* 만 정의해야 함 — schema 자체 본문 재생산은 drift 위험.

**Actual**

`log-entry-write.md`:
- §3 (lines 39-75) 가 `frontmatter 5 fields` 와 `body 7 sections` 전체를 *literal* 로 본문에 포함
- §4 (lines 84-94) 가 append 필드 형식 literal 로 포함
- §5 (lines 102-105) 가 *보존 정책 4종* literal 로 포함 (`task-log-template-write.md §보존 정책` 가 진실 source)
- §6 (lines 113-122) 가 disclosure 7 항목 literal 로 포함

§3 마지막 줄 "`docs/agent/task-log-template.md` 의 schema 매 호출 read" 라고 적혀있긴 하지만, 그 다음 줄에 schema 본문 literal 이 있으면 *runtime 이 본문 literal 을 신뢰* 할 가능성 (template read 생략 — 본 skill 의 Common Failures #6 와 정확히 동일한 안티패턴).

**Evidence**

`log-entry-write.md:39-75` (frontmatter + body literal), `:84-94` (append literal), `:102-105` (보존 정책 literal), `:113-122` (disclosure literal).

**Impact**

`docs/agent/task-log-template.md` 가 갱신되면 (예: 필드 추가 / 보존 정책 변경) `log-entry-write.md` 본문이 drift. SKILL.md 의 Common Failures #10 (명세 read 생략) 이 *runner 본문* 에 대해 강조됨에도 references 가 design skill 산출의 schema 를 재생산하는 모순.

**Recommendation**

asset 수정 — `log-entry-write.md` 의 §3/§4/§6 본문 literal 을:
- "매 entry write 마다 `docs/agent/task-log-template.md` read → schema 그대로 적용" 절차 1줄
- 그 위에 *minimal yaml 1줄 예시* (예: "frontmatter 는 yaml frontmatter, body 는 markdown") 까지만 남기고
- 5 fields / 7 sections / 보존 정책 4종의 *enumeration* 은 design skill 의 reference 가 진실 source 임을 명시 + 본문 인용 제거

이로써 runner reference 가 *적용 절차* 만 정의, schema 는 design skill 의 진실 source 가 됨.

---

### GAP-005: should-not-trigger near-miss 실제 케이스 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §8 Verification` |

**Expected**

verification 절차: should-trigger / should-not-trigger / near-miss / pressure scenario / no-op case. 본 skill 은 *negative trigger 목록* (7종) 은 명시했지만 *near-miss 발화 예시* 는 부재.

**Actual**

`SKILL.md When NOT to Use` 가 7개 인접 skill 이름만 나열. 사용자 발화 예시 (예: "task log 좀 보여줘" → 본 runner 호출 X, *read-only 조회* 임 — 단순 `Read`) 같은 *near-miss 발화* 없음.

**Evidence**

`SKILL.md:23-30`.

**Impact**

모델이 인접 skill 이름은 알아도, 사용자가 *동등 의미 다른 발화* 를 했을 때 (예: "지금까지 작업 정리해줘" — session-report skill 의 trigger 와 겹침) 라우팅 혼선 가능. 실제 영향은 작음 — 인접 skill 이름이 충분히 분리적임.

**Recommendation**

asset 수정 (옵션) — `When NOT to Use` 하단에 1-2개 발화 예시 (`"task log 보여줘"` → `Read`, `"지금까지 뭐 했지"` → session-report skill).

---

### GAP-006: runtime behavior 확인 시점 / version 표기 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.13 Freshness` (추가 축) |

**Expected**

runtime skill 은 *project-side 자원* (`docs/agent/{evaluation-loop,golden-set,task-log-template}.md`) 의 schema/형식이 갱신되면 영향. 본 skill 의 *작성 시점에 인지한 schema 가정* 이 명시되어야 후속 검증 가능.

**Actual**

SKILL.md 본문 / 2 references 모두 작성일 / 검증일 / version 표기 부재. normative source (`spec §4.4` 등) 만 `2026-05-17` 날짜 명시.

**Evidence**

`SKILL.md` 전체, `references/runtime-protocol.md` 전체, `references/log-entry-write.md` 전체.

**Impact**

design skill 의 schema 가 갱신됐을 때 본 runner 가 *재검증 필요* 한지 트래킹 어려움. CI 가 없으면 silent drift 위험.

**Recommendation**

asset 수정 (옵션) — frontmatter 또는 본문 첫 줄에 `verified-on: 2026-05-17` 또는 동등 메모. drift 발생 시 freshness 비교 base 가 됨.

---

### GAP-007: GUIDE_GAP — frontmatter `tools:` 권장 강도

| Field | Value |
|---|---|
| Type | GUIDE_GAP |
| Severity | P3 |
| Guide ref | Guide target: `SKILL-GUIDE.md §2 Frontmatter` |

**Expected**

`SKILL-GUIDE.md §2` 가 `tools` 명시를 권장: "read-only 나 mutation 제한이 중요하면 명시하는 편이 낫다." — 일반론적 안내.

**Actual**

본 runner skill 처럼 *mutation 가능 (entry write + mkdir)* 이면서 *advisory 책임 (라우팅 결정 반환)* 인 경우, frontmatter `tools:` 미선언이 capability surface 강제력을 약화. SKILL-GUIDE §2 의 권장이 "important if read-only" 정도로 읽혀 mutation skill 의 강제 신호가 약함.

**Impact**

본 runner 같은 mutation+advisory hybrid skill 이 capability surface 명시 없이도 가이드 통과 가능 — false positive 위험.

**Recommendation**

guide 수정 follow-up — `SKILL-GUIDE.md §2` 에 1줄 보강: "mutation 가능 skill 은 capability surface 명시 권장 (frontmatter `tools:`). 본문 자기 선언은 *문서 수준* 강제력만." 본 자산 자체는 GAP-001 의 asset 수정으로 해결.

---

### GAP-008: AMBIGUITY — hook 트리거 시 runner 의 `phase: 1-only` 옵션

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.4 Output Contract` |

**Expected**

`runtime-protocol.md §4` 의 표:
```text
| Hook (PostCommit / Stop / 등) | *raw task log 캡처* 까지 — Phase 1 만 실행 가능 | gap 분석 + 라우팅은 명시 호출 (사용자 또는 자동 chain) |
```

만약 hook 가 runner 를 자동 호출하는 경우 (현재 spec §10 Decision 5 는 *권장하지 않음*), runner 가 어떻게 Phase 1 만 실행하는지 본문에 정의 필요.

**Actual**

`runtime-protocol.md §4` 본문에 *해결 방안 2개 제시*:
- "runner 의 `mode: blocked` 또는 `phase: 1-only` 같은 옵션 필요"
- 또는 "hook 등록 시 명시 호출 패턴 권장: hook 이 runner 자체를 자동 호출하지 않고 *사용자에게 알림* 만 보냄"

→ 현재 SKILL.md Output Contract 에 `phase` 필드 없음. 둘 중 어느 해결책이 *현재* 채택됐는지 본문에 단정되지 않음. spec §10 Decision 5 은 *명시 호출 우선* 이라 두 번째 패턴이 채택된 것으로 보이나, runtime-protocol.md §4 본문은 *옵션 양쪽* 을 남겨두는 modality.

**Evidence**

`runtime-protocol.md:70-72` ("hook 자체가 `Phase 1` 만 실행하려면 runner 의 `mode: blocked` 또는 `phase: 1-only` 같은 옵션 필요. 현재 runner 는 *3 phase 한 묶음* — hook 트리거 시 의미 부여까지 진행됨. 본 분리는 *명시 호출 우선* 정책 (spec §10 Decision 5) 으로 해결").

**Impact**

hook 등록자/구현자가 spec §10 Decision 5 까지 따라가서야 채택 결론 확인 가능. *명시 호출만 허용* 이라는 결정이 본문에 단정되지 않으면, 구현자가 임의로 hook→runner 자동 호출 패턴 채택 가능 → 무한 사이클 위험 증가.

**Recommendation**

사용자 확인 후 결정 — 다음 중 택1:
- (a) `runtime-protocol.md §4` 본문에서 `phase: 1-only` 옵션 제안 부분 제거, "현재는 명시 호출만 허용, hook 은 사용자 알림 패턴 권장" 으로 단정. spec §10 Decision 5 와 일치
- (b) `phase: 1-only` 옵션을 Output Contract 에 정식 추가 + Phase 1/2/3 진입 분기 본문화
- (c) 본 양상을 *향후 옵션* 으로 명시 후 현재는 명시 호출만 허용

권장: (a) — spec §10 Decision 5 와 정합.

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| SKILL.md 본문 179 lines (SKILL-GUIDE §9 "가능하면 핵심 workflow 중심") | runtime skill 은 *Phase 3 + Output Contract + Common Failures 11종 + Limits 5종* 모두 필요. 11종 Common Failures 는 모두 *실제 안티패턴* (책임 누수 / drift / stateful 시도 / silent fail) — 압축 시 정보 손실. references 2 분리도 적절 |
| description 65 단어 (heuristic 15-60 초과) | GAP-003 으로 P3 기록. negative trigger 7종이 라우팅 혼선 방지에 직접 기여 — finding 으로 인정하되 권장 옵션 |
| `user-invocable: true` 명시 | spec §10 Decision 5 *명시 호출 우선* 정책에 맞춤 — 사용자 / 자동 chain 양쪽 진입 모두 의도 |
| `Output Contract` 가 `Output Format` 제목 아님 + YAML 형식 (markdown 표 아님) | GAP-FORMAT §5 "형식 차이는 GAP 아님". mechanically 파싱 가능한 YAML 4 섹션 — output contract 기능 충족 |
| `Capability Procedure` 라는 비표준 섹션명 (SKILL-GUIDE §4 권장은 `Workflow`) | 기능적으로 동일 (Phase 1/2/3) — 형식 차이로 GAP 아님 |
| Common Failures 표 11 행 (긴 표) | 실행 시점 안티패턴 11종이 *책임 분리* 라는 단일 원칙의 instantiation — 압축 시 안티패턴 식별력 손실 |
| `references/runtime-protocol.md` 가 *main session 코드 패턴* 명시 (runner 외부 책임) | runtime skill 의 책임 분리 정당화 핵심 — main session 책임을 명시하지 않으면 chain 책임 누수. design principle (§3.10 / §3.4) 충족 |
| `self-application 처리 (§5)` 가 종료 조건 #4 + #3 외 *추가 안전장치* | 본 추가가 #3 (같은 design skill 2회) 가 잡지 못하는 *서로 다른 design skill 순환 self-application* 보완 — 정당화 본문에 명시. acceptable |

## 8. Suggested Changes

### Asset Changes

- [ ] **P2 GAP-001** — SKILL.md frontmatter 에 `tools: Read, Write, Bash` 추가 (Limits 마지막 줄 자기 선언과 일치)
- [ ] **P2 GAP-002** — Phase 2 또는 Output Contract 의 `mode` 표에 mode 우선순위 1줄 추가 ("blocked > needs_input > no-op > cycled")
- [ ] **P2 GAP-008** — `runtime-protocol.md §4` 의 `phase: 1-only` 옵션 본문 제거 + "현재는 명시 호출만, hook 은 사용자 알림 패턴" 으로 단정 (spec §10 Decision 5 정합)
- [ ] **P3 GAP-003** (옵션) — description 의 `Do NOT use for ...` 7항목을 본문 `When NOT to Use` 로 이동, description ~40 단어로 압축
- [ ] **P3 GAP-004** (옵션) — `log-entry-write.md §3/§4/§6` 의 schema/policy/disclosure literal 을 design skill 의 진실 source 인용으로 축소 (drift 위험 완화)
- [ ] **P3 GAP-005** (옵션) — `When NOT to Use` 하단에 사용자 발화 near-miss 1-2개 ("task log 보여줘" → `Read`)
- [ ] **P3 GAP-006** (옵션) — SKILL.md 또는 references 첫 줄에 `verified-on: 2026-05-17` 표기

### Guide Changes

- [ ] **P3 GAP-007** — `SKILL-GUIDE.md §2 Frontmatter` 에 1줄 보강 — "mutation 가능 skill 은 capability surface 명시 권장" (mutation+advisory hybrid skill 의 강제 신호 명확화)

### Constitution Review

- [ ] None — 본 리뷰는 헌법 수정 사유 없음. `§3.13 Freshness` / `§3.14 Docs Source of Truth` 가 사용자 prompt 의 *추가 점검 축* 이지 본문 헌법 자체에 명시 부재일 가능성 — 별도 헌법 리뷰 follow-up 으로 분리 (본 GAP 리포트의 권한 밖)

## 9. Follow-up Questions

1. **GAP-008 결정** — hook 가 runner 자동 호출하는 경로를 *명시적으로 차단* 하는가, 아니면 `phase: 1-only` 옵션을 정식 채택하는가? spec §10 Decision 5 와 정합하려면 (a) 권장.
2. **GAP-004 결정** — design skill (`evaluation-loop-design`) 의 reference (`task-log-template-write.md`) 가 *진실 source* 임을 runner 의 reference 본문에서 어떻게 강제? 가능 옵션: (i) source path 만 명시 + literal 제거, (ii) literal 유지하되 `last-verified-against: <design skill commit hash>` 메타 추가.
3. **CONSTITUTION 의 §3.13 / §3.14 위치** — 사용자 prompt 의 *추가 점검 축* 으로 본 리뷰가 적용했지만, `CONSTITUTION.md` 본문에는 §3.1-§3.10 만 명시. 두 축의 정식 채택 / 별도 가이드 분리 여부 결정 필요. 본 결정 후 향후 GAP 리포트 격이 결정됨.

## 10. Final Decision

**PASS_WITH_NOTES**

근거:
- Hard rule 위반 0 (Activation Explicit / Effects Gates / Output Contract / Capability Surface / Scope / Reusable vs Local — 모두 PASS)
- P0/P1 = 0
- P2 = 3 (GAP-001 / GAP-002 / GAP-008 — 모두 *옵션 적용으로 강화 가능*, 자산 목적 (runtime 명세 실행자, stateless, 명시 호출 우선) 과 충돌 없음)
- P3 = 5 (GAP-003 / GAP-004 / GAP-005 / GAP-006 + GUIDE_GAP GAP-007)
- 책임 분리 (design vs runner, runner vs main session, hook vs runner) 가 3 곳 일관 명시
- Output Contract 가 mechanically 파싱 가능한 YAML 4 섹션 + mode enum 4종
- Routing Decision 표 본문 재생산 금지가 drift-avoidance 의 핵심 원칙으로 정착
- 무한 사이클 완화 (종료 조건 4종 + self-application 보완) 가 main session 책임 외주로 명확
