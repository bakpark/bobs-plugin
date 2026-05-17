# GAP Report — skill `evaluation-loop-design`

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2.1
검토자: GAP 분석 에이전트 (cwd=plugins/bobs-plugin/references/)
asset_type: skill (+ 4 bundled references)
source_path:
  - plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md
  - plugins/bobs-plugin/skills/evaluation-loop-design/references/roles-write.md
  - plugins/bobs-plugin/skills/evaluation-loop-design/references/evaluation-loop-write.md
  - plugins/bobs-plugin/skills/evaluation-loop-design/references/golden-set-write.md
  - plugins/bobs-plugin/skills/evaluation-loop-design/references/task-log-template-write.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, harness-principles.md, harness-installation-workflow.md
final_decision: PASS_WITH_NOTES
```

## 2. Executive Summary

`evaluation-loop-design` 스킬은 `harness-installation-workflow.md §3.3` 의 design-skill 슬롯 (TBD per Step 4) 을 채우는 메타 디자인 스킬이다. 본문은 design phase 3개 (Inventory → Verification Plan → Apply) + Output Contract + Common Failures + Verification 을 갖추고, 4개 reference 가 각각 동일한 5섹션 (Phase 1/2/3 + Verify + Common Failures) 구조로 산출물 (`docs/agent/{roles,evaluation-loop,golden-set,task-log-template}.md`) 작성 절차를 정의한다.

평가 결과:

- Activation signal, near-miss (sibling 5종 모두 명시), output contract, double effect gate (design + apply), apply 순서 의존성, 무한 사이클 종료 조건 (4종) — 모두 명확.
- 4개 references 가 동일한 phase shape 를 따르고, Phase 3 effect gate disclosure 가 일관된 6필드 테이블로 표준화됨.
- evaluation 인프라 고유 검증축 (golden-set 5종 표면 / task log schema 일관성 / 사이클 종료 조건 4종) 이 본문과 references 양쪽에 명시되어 있음.

영향 있는 GAP 없음. 다만 P2/P3 수준의 정밀화 여지 4건 — (1) skill 본문의 `disable-model-invocation` 부재로 `user-invocable: true` 와 자동 활성화 의도 사이 트레이드오프 명시 부재, (2) golden-set-write 의 case 수 `3-10 권장` 이 hard verify 로 사용됨, (3) `evaluation-loop-runner` 가 *planned* 상태인데 reference 가 contract 인용함 — freshness 표기 부재, (4) `agent-skill-auditor` 와의 overlap 설명이 description 끝 단 한 번 — Routing Decision 표 4 sibling 중 본 스킬이 다루는 자산 (`docs/agent/*.md`) 과 auditor 가 다루는 자산 (`SKILL.md`/`agent.md`) 의 경계가 본문 어디에도 표로 정리되어 있지 않음.

## 3. Asset Snapshot

### 3.1 SKILL.md

```text
name: evaluation-loop-design
description_words: 115 (long, but trigger phrase list — not workflow shortcut)
body_words: ~1690 (after stripping description)
body_lines: 182
tools: omitted (model inherits default — frontmatter intentional)
invocation_controls: user-invocable: true (frontmatter)
has_references: yes (4 file bundle under references/)
has_scripts_or_assets: no
has_effect_gate: yes (double — Phase 2 design + Phase 3 reference-level)
has_output_contract: yes (Output Contract section + mode taxonomy)
```

### 3.2 references/roles-write.md

```text
length: 115 lines / 962 words
sections: Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures
template_usability: full template (role schema with 6 fields)
mini_gate: 6-row disclosure table (path / type / role count / pair / resource / impact)
common_failures: 6 entries
blocked_case: yes (skeleton absent → needs_input category: inventory)
```

### 3.3 references/evaluation-loop-write.md

```text
length: 175 lines / 1461 words
sections: Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures
template_usability: full template (entry conditions / cycle steps / Routing Decision / exit conditions / golden-set comparison procedure / contract)
mini_gate: 7-row disclosure table (path / type / entry count / cycle steps / exit conditions / routing rows / cited assets)
common_failures: 8 entries
blocked_case: yes (dependency assets missing → needs_input)
```

### 3.4 references/golden-set-write.md

```text
length: 141 lines / 1224 words
sections: Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures
template_usability: full schema (case schema 9 fields)
mini_gate: 6-row disclosure table (path / type / case count / toy ratio / 5-surface coverage / cited source)
common_failures: 8 entries
blocked_case: yes (roles.md body missing → needs_input)
five_surface_explicit: yes (PASS / no-op / blocked / needs_input / FAIL — repeatedly stated)
```

### 3.5 references/task-log-template-write.md

```text
length: 176 lines / 1405 words
sections: Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures
template_usability: full schema (frontmatter 5 fields + 7 body sections + append fields for cycle steps)
mini_gate: 6-row disclosure table (path / type / frontmatter fields / body sections / retention policy / golden-set link)
common_failures: 8 entries
blocked_case: n/a (root of dependency tree — runtime lazy-creates logs/)
```

## 4. Applicable Criteria

| Document | Heading | Applied to |
|---|---|---|
| `CONSTITUTION.md` | §3.1 Activation Must Be Explicit | SKILL.md description / When to Use |
| `CONSTITUTION.md` | §3.2 Scope Controls Quality | SKILL.md scope + Phase 2 plan-only / no-op |
| `CONSTITUTION.md` | §3.3 Effects Require Gates | SKILL.md Phase 2/3 + each reference Phase 3 |
| `CONSTITUTION.md` | §3.4 Output Is A Contract | SKILL.md Output Contract section |
| `CONSTITUTION.md` | §3.5 Capability Surface Must Match Responsibility | SKILL.md tools (omitted) + user-invocable: true |
| `CONSTITUTION.md` | §3.6 Reusable Knowledge And Local Memory Must Stay Separate | SKILL.md normative source citation + body content |
| `CONSTITUTION.md` | §3.7 Progressive Disclosure | SKILL.md → references bundle |
| `CONSTITUTION.md` | §3.8 Strong Language Belongs To Real Gates | SKILL.md Common Failures + Verify |
| `CONSTITUTION.md` | §3.9 Behavior Must Be Verifiable | SKILL.md Verification + each ref Verify |
| `CONSTITUTION.md` | §3.10 Overlap Must Be Intentional | description NOT clauses + Routing Decision table 4-sibling |
| `CONSTITUTION.md` | §3.11 User-Initiated Workflows Need Commands | SKILL.md user-invocable: true with /evaluate command pattern |
| `CONSTITUTION.md` | §3.13 Freshness Requires Evidence | references citing `evaluation-loop-runner` (planned) |
| `CONSTITUTION.md` | §3.14-3.16 Docs Source of Truth | references vs `docs/agent/*.md` ownership |
| `SKILL-GUIDE.md` | §5 Description | description does not lead with workflow steps |
| `SKILL-GUIDE.md` | §6 Body design | Phase 1/2/3 + Output Contract + Common Failures + Verification |
| `SKILL-GUIDE.md` | §7 Effects And Gates | double gate (design + apply) |
| `SKILL-GUIDE.md` | §8 Progressive Disclosure | SKILL.md selector + 4 references |
| `SKILL-GUIDE.md` | §10 Verification | self-reference avoidance noted |
| `SKILL-GUIDE.md` | §13 Anti-Patterns | references' own Common Failures + SKILL.md Common Failures |

## 5. Checks

### 5.1 SKILL.md Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | 6 trigger phrases + Routing 표 §2 행 references both Korean/English |
| Description avoids workflow shortcut | pass | trigger phrase list + NOT clauses (sibling 5종 모두) — workflow steps 없음 |
| Skill is an automatic external/domain capability, not a user workflow | partial | `user-invocable: true` + Verification 섹션이 `/evaluate` command 패턴 언급 — §3.11 의 "사용자가 명시 호출하는 workflow 는 command" 와 경계 모호 (intentional? — *meta design skill* 카테고리) |
| Scope or near-miss is clear when needed | pass | When NOT to use 6항 + sibling 5종 모두 disambiguate |
| Capability procedure is actionable | pass | Phase 1 표 (5 columns) + reference 4종 매핑 + Phase 3 dependency-ordered write 절차 |
| Effect gate exists when mutation is possible | pass | double gate (Phase 2 design + Phase 3 reference-level) + "묻지 말고 진행" 모드 명시 |
| Output contract exists | pass | Output Contract 섹션 + mode 4종 + needs_input category 분기 |
| Progressive disclosure is appropriate | pass | SKILL.md 182줄 (meta design skill 적정) + 4 reference 분리 + spec 본문은 spec_path 만 안내 |
| Reusable vs project memory is separated | pass | normative source 마지막 단락 — 본문 표준 규칙 복사 안 함 |
| Behavior can be verified | partial | Verification 섹션이 *self-reference 회피* 라며 description trigger phrase + NOT clauses + Common Failures 를 "가벼운 검증 표면" 으로 부름 — should-trigger/should-not-trigger eval 절차는 명시 없음 |
| Overlap is intentional | pass | description NOT clauses + 본문 Common Failures 의 "roles.md ownership 위반" + sibling 5종 (context-map-architecture / resource-design / skill-creator / agent-creator / hook-creator + agent-skill-auditor) 모두 거명 |

### 5.2 references/*.md Checks (4 파일 공통)

| Check | Status | Notes |
|---|---|---|
| Phase 1/2/3 + Effect Gate + Common Failures 모두 포함 | pass | 4 references 모두 동일 5섹션 헤더 (Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures) — `grep` 결과 일치 |
| Length budget | pass | 115-176줄 / 962-1461 words — reference 적정 |
| Phase 3 mini-gate disclosure format 일관성 | pass | 4 references 모두 동일 6-7 행 disclosure 표 (작성 경로 / 작업 종류 / 핵심 수량 / 핵심 매핑 / 변경 영향) |
| Template 실제 사용 가능성 (placeholder only 아님) | pass | 모든 reference 가 full template (schema + 가이드 1-N항) — `<...>` 만 두지 않음 |
| Common Failures 항목 수 | pass | 6/8/8/8 — 모두 의미 있는 안티패턴 (template 안티패턴 + ownership 안티패턴 + verification 안티패턴) |

### 5.3 평가 인프라 고유 검증축

| 축 | Status | Notes |
|---|---|---|
| golden-set 의 no-op/blocked 표면 정의 | pass | golden-set-write Phase 2 / Verify / Common Failures 모두 "PASS + no-op + blocked + needs_input + FAIL 5종" 강제 — PASS-only 안티패턴 명시 |
| task log schema 일관성 | pass | task-log-template-write 가 frontmatter 5필드 + 본문 7섹션 + append 분리를 한 schema 로 명시. Common Failures 의 "Schema 일관성 부재" + Verify 의 "schema drift 검사" 양면 강제 |
| evaluation-loop 의 종료 조건 명확성 (무한 루프 방지) | pass | evaluation-loop-write Phase 2 가 종료 조건 4종 (no-op / 명시 종료 / 같은 design skill 2회 / 누적 5회) 명시 — `harness-installation-workflow.md §6` 와 일치. Common Failures 의 "무한 사이클" 항이 *같은 design skill 2회* 누락을 핵심 안티로 지목 |

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | AMBIGUITY | P2 | `CONSTITUTION.md §3.11` + `SKILL-GUIDE.md §4` | `user-invocable: true` 와 자동 활성화 의도 경계 모호 | SKILL.md frontmatter / 본문에 user-invocable 의도 + `/evaluate` command 와의 분담 1줄 추가 |
| GAP-002 | ASSET_GAP | P2 | `CONSTITUTION.md §3.13` | `evaluation-loop-runner` 가 planned 상태인데 contract / runtime hand-off 인용 — freshness 근거 부재 | references 가 runner 인용 시 `(planned, Step 5)` 표기는 있으나 *언제 verified* 인지 일자 미표기. references 에 `runner status: planned as of 2026-05-17` 1줄 추가 |
| GAP-003 | ASSET_GAP | P3 | `SKILL-GUIDE.md §10 Verification` + `SKILL-GUIDE.md §11` | Verify 단계의 case 수 `3-10` 을 hard verify 조건처럼 작성 — heuristic 을 hard rule 화 | `golden-set-write.md` Verify 의 "case 수 3-10 (범위 밖 시 경고)" → "경고 (hard fail 아님)" 또는 heuristic 명시 |
| GAP-004 | ASSET_GAP | P3 | `CONSTITUTION.md §3.10` + `SKILL-GUIDE.md §13 Overlap` | `agent-skill-auditor` 와의 경계가 description 1줄 + Verification 1줄만 — 본문 내 명시적 분담 표 부재 | SKILL.md `When NOT to use` 또는 별도 표에 "본 스킬: `docs/agent/*.md` 작성 / auditor: 자원 (SKILL.md, agent.md) 정적 감사" 의 *대상 자산 차이* 추가 |
| GAP-005 | GUIDE_GAP | P3 | Guide target: `SKILL-GUIDE.md §6 Body 설계` 또는 §7 | reference 4종이 *동일한 Phase shape 표준화* (Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures) 패턴이 다른 design skill 의 references 에도 반복될 가능성. SKILL-GUIDE 에 "bundle reference Phase 표준화" 권장 패턴 없음 | SKILL-GUIDE.md §7 또는 §8 에 *write 절차형 reference 의 권장 phase 골격* 추가 검토 |

### GAP-001: `user-invocable: true` 와 자동 활성화 의도 경계

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.11 User-Initiated Workflows Need Commands` + `SKILL-GUIDE.md §4 Frontmatter` |

**Expected**

skill 은 모델 자동 활성화가 기본. 사용자가 명시 호출하는 workflow 는 command. `user-invocable: true` 는 §4 에 "예외적 편의" 로 명시.

**Actual**

SKILL.md frontmatter 가 `user-invocable: true` (line 5) — 동시에 본문 §Verification 이 "evaluation-loop-runner 가 자동 chain" 과 "/evaluate" command 패턴을 함께 언급 (line 53 의 `evaluation-loop-write.md` Phase 2 진입 조건 #1). 본 스킬이 (a) 사용자 명시 호출용인지, (b) 자동 활성화용인지, (c) 양쪽 모두인지 본문 어디에도 1줄 disambiguation 없음.

**Evidence**

- `SKILL.md:5` — `user-invocable: true`
- `SKILL.md:14-22` — `When to Use` Trigger 4항 모두 *사용자 발화* 기반 — 자동 활성화 신호 부재
- `evaluation-loop-write.md:51-55` — Routing Decision 표가 `/evaluate command` 진입 + automatic chain + hook trigger 3종 모두 가능하다고 명시

**Impact**

라우팅 혼선. 호출자 (메인 세션) 가 `/evaluation-loop-design` slash 로 부를지, 모델 자동 활성화에 맡길지, command 로 wrapping 할지 의도가 불명확. v2.1 `§3.11` "스킬이 사용자 질문, plan gate, 단계 진행을 맡기 시작하면 command 로 승격하거나 command + skill 로 분리한다" 규칙에 비추면 본 스킬은 plan gate + 단계 진행을 모두 가짐 → command 분리 검토 후보. 다만 design-meta skill 카테고리 (`harness-installation-workflow.md §3`) 는 명시적으로 spec 산출 메타 절차로 정의되어 있어 *의도된 예외* 일 가능성도 있음.

**Recommendation**

ASSET — SKILL.md 상단 1-2 줄로 "본 스킬은 design-meta skill 카테고리 (workflow doc §3.3) — `user-invocable: true` 는 사용자가 `/evaluation-loop-design` 으로 명시 호출하거나, `evaluation-loop-runner` 가 자동 chain 으로 진입 모두 허용. plan-only 모드와 사용자 승인 effect gate 가 command 책임을 흡수하지 않게 한다" 식의 의도 disambiguation 추가.

### GAP-002: `evaluation-loop-runner` 인용에 freshness 근거 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.13 Freshness Requires Evidence` |

**Expected**

verison-sensitive 또는 *future asset* 가정에는 확인 일자 / source / 재검증 조건을 남긴다.

**Actual**

`evaluation-loop-write.md:46` 및 `task-log-template-write.md:38` 등 4 references 가 `evaluation-loop-runner` (planned, separate skill) 을 contract 진입점·hand-off 대상으로 다수 인용. "planned" 표기는 있으나 *언제 확인된 plan* 인지 (Step 5 작성 예정 — workflow doc §5.2) 일자 / source 없음. 만약 Step 5 가 미진행으로 무기한 연기되면 본 스킬이 작성한 evaluation-loop.md 의 runtime hand-off contract 가 ghost reference 가 됨.

**Evidence**

- `evaluation-loop-write.md:4` — `Normative source: harness-principles §4.5 + docs/specs/2026-05-17-harness-installation-design.md §4.4` (spec 인용은 있으나 runner skill 자체 status 미표기)
- `evaluation-loop-write.md:160` — Verify 의 "runtime 자원 (`evaluation-loop-runner`) 은 *planned* 로 표기 — 존재하지 않아도 ok (Step 5 작성 예정)"
- `task-log-template-write.md:7-9` — runtime executor 가 본 template 을 따라 logs/ 에 entry write 한다는 contract — runner 부재 시 contract 가 dead

**Impact**

산출물 신뢰성. 본 스킬이 작성한 `docs/agent/evaluation-loop.md` 는 *runner 가 본 spec 을 따라 실행한다* 는 가정에 의존. runner 가 작성되지 않으면 evaluation-loop.md 가 *실행 불가 명세* 가 되어 docs 신뢰가 떨어짐. v2.1 §3.13 의 *재검증해야 하는 조건* 미표기.

**Recommendation**

ASSET — references 의 runner 인용 부분에 "runner status: planned, target Step 5 of `harness-installation-workflow.md`, verified 2026-05-17. 본 reference 적용 시 runner 자산 존재 여부 재확인 필요" 식 1줄 freshness 표기 추가. SKILL.md Verification 섹션에도 동일 노트.

### GAP-003: golden-set case 수 `3-10` 을 hard verify 로 사용

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §10 Verification` + `SKILL-GUIDE.md §11 Quantitative Heuristics` |

**Expected**

수치는 hard rule 이 아니라 검토 신호. heuristic 을 verify 단계의 fail 조건처럼 작성하지 않는다.

**Actual**

`golden-set-write.md:62` Phase 2 — "총 case 수는 **3-10 권장**. 10건 초과 시 maintenance 부담 — 우선순위로 압축."
`golden-set-write.md:122` Verify — "case 수 3-10 (범위 밖 시 경고)"
`golden-set-write.md:138-139` Common Failures — "Case 과다 ... 10건 초과 → maintenance 부담", "Case 부족 ... 1-2건만 정의 → 회귀 표면 부족 ... 최소 3건 권장"

"권장" 단어가 있어 hard rule 표기는 아니지만, Verify 단계가 *조건 검사* 형식 (다른 항목과 동일 bullet shape) 으로 두면 자동화 시 fail-fast 로 처리될 위험. case 의 *질* (자주 발생 + 비싼 실패) 이 *양* 보다 본질이라는 §10 의 의도와 약한 충돌.

**Evidence**

- `golden-set-write.md:62` — "총 case 수는 **3-10 권장**"
- `golden-set-write.md:122` — Verify 의 "case 수 3-10 (범위 밖 시 경고)"

**Impact**

품질 저하 가능성. 초기 프로젝트에서 *실제 발생한 작업 유형이 2개* 면 case 2건이 정확한 baseline 인데 본 reference 의 verify 가 "회귀 표면 부족" 경고를 띄움 → toy case 추가 압력 → toy golden-set 안티패턴 (본 reference 의 Common Failures 1번) 자기 재생산.

**Recommendation**

ASSET — Verify 항목을 "case 수 (heuristic: 3-10. 1-2 건 시 작업 유형 다양성 부족 가능성 경고. 10건 초과 시 maintenance 비용 검토. hard fail 아님)" 로 명시. Common Failures 의 *Case 부족* 행을 *초기 프로젝트 예외 (실제 발생 작업 유형이 적으면 N=실제 수)* 로 보강.

### GAP-004: `agent-skill-auditor` 와의 overlap 경계 표 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.10 Overlap Must Be Intentional` + `SKILL-GUIDE.md §13 Overlap` |

**Expected**

비슷한 자산은 trigger / scope / output / capability surface 차이가 본문에 설명됨.

**Actual**

본 스킬과 `agent-skill-auditor` 는 모두 "검증" 단어를 다루지만 *대상 자산이 완전히 다르다*:
- 본 스킬: `docs/agent/roles.md` / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md` *작성*
- auditor: `SKILL.md` / `agent.md` / `settings.json` *정적 감사* (read-only)

이 차이가 description 끝 단 한 줄 (`Do NOT use for static rule audit ... — agent-skill-auditor`) 만으로 설명. 본문 `When NOT to use:5번째 bullet` 에 한 줄 더 있음 — 그러나 *대상 자산 차이* (write vs audit, docs/agent/_*_ vs SKILL.md/agent.md) 의 핵심을 *표로 정리한 곳* 없음. evaluation-loop-write.md 의 Routing Decision 표가 4 sibling 을 정리하긴 하지만 거기서는 auditor 가 "정적 감사" 행으로만 등장.

**Evidence**

- `SKILL.md:4` description — "Do NOT use for static rule audit (P0/P1/P2 + rule ID + confidence) — `agent-skill-auditor`"
- `SKILL.md:25` When NOT to use — "정적 rule 감사 → `agent-skill-auditor` (본 스킬의 reference subagent — Routing Decision 표에서 호출)"
- `SKILL.md:169` Verification — "자세한 평가가 필요하면 `agent-skill-auditor` 가 정적 rule 감사 ... 를 별도 수행"
- `evaluation-loop-write.md:72` — Routing Decision 표의 auditor 행: "기존 자원의 정적 rule 위반 (P0/P1/P2 + rule ID) ... 정적 감사 (read-only)"

**Impact**

라우팅 모호. 사용자가 "검증 인프라 audit" 라고 말하면 auditor 와 본 스킬 중 어느 쪽으로 라우팅될지 description trigger phrase 만으로 모델이 분기. 본 스킬의 description trigger 6 phrase 중 "검증 인프라 셋업" / "evaluation loop 설계" 는 *작성/설계* 신호이나 "audit" 어휘가 어느 쪽에도 명시되지 않음. 본 스킬에 "audit" 신호 없으면 라우팅 안정성은 ok — 그러나 작성 흐름 중 본 스킬이 작성한 docs/agent/*.md 의 *내용 audit* 가 필요할 때 auditor 가 해당 자산을 감사 대상으로 받는지 본문에 한 줄 없음.

**Recommendation**

ASSET — SKILL.md `Overlap` 섹션 (신설) 또는 When NOT to use 끝에 "auditor 와의 차이: 본 스킬 = `docs/agent/*.md` *작성·갱신* (mutation). auditor = `SKILL.md` / `agent.md` / `settings.json` *정적 감사* (read-only). auditor 가 본 스킬이 작성한 docs/agent/*.md 를 감사 대상으로 받지 않음 — docs audit 은 본 스킬의 self-verify 가 담당" 식 1-2 행 추가.

### GAP-005: write 절차형 reference 의 phase 표준화 패턴 — SKILL-GUIDE 부재

| Field | Value |
|---|---|
| Type | GUIDE_GAP |
| Severity | P3 |
| Guide ref | Guide target: `SKILL-GUIDE.md §6 Body 설계` 또는 §7 Effects And Gates |

**Expected**

여러 reference 가 동일한 phase shape 를 반복할 때 권장 골격이 SKILL-GUIDE 에 있어 다른 design skill 도 참고 가능.

**Actual**

본 스킬의 4 references (`roles-write.md` / `evaluation-loop-write.md` / `golden-set-write.md` / `task-log-template-write.md`) 가 모두 동일한 5섹션 구조 (Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures) 를 따라 일관성이 매우 높음. `context-map-architecture` 의 references 도 유사 패턴을 따른다고 본 스킬이 인용 (예: `evaluation-loop-design/SKILL.md:101` — "각 reference 는 자체 effect gate (write 직전 경로·종류·요약 1회 확인) 를 가진다"). 이 패턴이 design-meta skill 카테고리에 *반복되는 좋은 패턴* 이나 SKILL-GUIDE §6/§7 에 명시 없음 — 새 design skill 작성자가 이 골격을 재발견해야 함.

**Evidence**

- `grep -nE "^## (Phase|Verify|Common Failures)" references/*.md` 결과 — 4 references 모두 5섹션 헤더 동일
- `roles-write.md:80-115`, `evaluation-loop-write.md:137-176`, `golden-set-write.md:103-141`, `task-log-template-write.md:138-176` — Phase 3 Effect Gate 가 모두 6-7행 disclosure 표 형식

**Impact**

가이드 보완 가치. design-meta skill 이 늘어날 경우 (예: 추후 security-policy-design / runtime-policy-design 등) 이 phase 골격이 반복될 가능성 — SKILL-GUIDE 에 *write-procedure reference* 권장 골격 (Phase 1 Inspect / Phase 2 Draft / Phase 3 Effect Gate / Verify / Common Failures) 1단락 추가하면 일관성이 향상.

**Recommendation**

GUIDE — `SKILL-GUIDE.md §7 Effects And Gates` 끝 또는 §8 Progressive Disclosure 에 "write-procedure 형 reference 의 권장 골격: Inspect → Draft → Effect Gate (disclosure 표) → Verify (post-write check) → Common Failures. 본 골격은 동일 design-meta skill 의 references 간 일관성을 만들고 effect gate 위치를 표준화한다" 추가 검토.

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| description 115 words (SKILL-GUIDE §11 의 "보통 15-60 words") 초과 | trigger phrase 다국어 (한·영) + sibling 5종 모두 disambiguate 가 필요한 design-meta skill — 라우팅 정확도가 더 중요 |
| `tools` 생략 (SKILL-GUIDE §4 의 "capability surface 줄이는 의미 있을 때 명시") | 본 스킬은 docs/agent/*.md 작성을 위해 Read/Write/Bash 모두 필요 — 좁히는 의미 없음. omit 이 적절 |
| SKILL.md 본문 1690 words (§11 "일반 스킬 본문 핵심 중심 유지") | meta design skill — Phase 절차 + Output Contract + Common Failures 10항 + Verification 모두 필요 |
| `user-invocable: true` | meta design skill 카테고리 — 사용자가 `/evaluation-loop-design` 으로 명시 호출 가능해야 plan-only 모드가 의미 — *intentional* (GAP-001 은 의도 명시 부족만 지적) |
| reference 본문 길이 (115-176줄) | full template + 가이드 + Verify + Common Failures 의 reference 자체로서 적정 길이 |
| Verification 섹션이 *self-reference 회피* 라며 정식 should-trigger/should-not-trigger eval 제시 안 함 | 본 스킬이 표준화하는 golden-set 자산에 본 스킬 자신을 case 로 등록하는 순환 회피 — auditor 위임 명시. intentional |
| SKILL.md 가 references 절차를 본문에 복제하지 않음 | §3.7 progressive disclosure + 마지막 단락 "본 스킬은 본문에 표준 규칙을 복사하지 않는다" 명시 |

## 8. Suggested Changes

### Asset Changes

- [ ] (GAP-001) SKILL.md 상단에 `user-invocable: true` 의도 disambiguation 1-2 줄 추가 — design-meta skill 카테고리이며 사용자 명시 호출과 runner 자동 chain 모두 허용함을 명시.
- [ ] (GAP-002) 4 references 의 `evaluation-loop-runner` 인용 부분에 freshness 표기 (`runner status: planned as of 2026-05-17, target Step 5 of harness-installation-workflow.md`) 1줄 추가. SKILL.md Verification 섹션에도 노트.
- [ ] (GAP-003) `golden-set-write.md` Phase 2 / Verify / Common Failures 의 case 수 `3-10` 를 *heuristic* 으로 명시 — Verify 는 hard fail 아닌 경고임을 분명히. 초기 프로젝트 (실제 발생 유형 2건 이하) 예외 보강.
- [ ] (GAP-004) SKILL.md `Overlap` 섹션 신설 또는 When NOT to use 끝에 auditor 와 본 스킬의 *대상 자산 차이* (docs/agent/_*_ write vs SKILL.md/agent.md audit) 한 줄 명시.

### Guide Changes

- [ ] (GAP-005) `SKILL-GUIDE.md §7` 또는 §8 에 write-procedure 형 reference 의 권장 phase 골격 (Inspect → Draft → Effect Gate → Verify → Common Failures) 1단락 추가 검토.

### Constitution Review

- None. 본 보고서의 GAP 은 모두 SKILL/GUIDE 레벨에서 해결 가능.

## 9. Follow-up Questions

1. `evaluation-loop-runner` (Step 5) 의 작성 일정이 확정되어 있는가? 확정되어 있으면 references 의 freshness 표기 (GAP-002) 에 target date 포함 가능.
2. design-meta skill 카테고리 (workflow doc §3.3) 의 `user-invocable: true` 패턴이 4 sibling skill 모두 동일한가? 동일하면 SKILL-GUIDE §4 frontmatter 의 `user-invocable` 설명에 *design-meta skill 의 의도된 사용* 추가 검토.
3. `docs/specs/2026-05-17-harness-installation-design.md §4.4` 가 외부에서 cross-check 가능한가? `evaluation-loop-write.md:4` 가 spec 본문을 normative source 로 인용하나 본 GAP 분석 환경에서는 cwd `references/` 밖 — spec 본문은 직접 검증 안 함.

## 10. Final Decision

**PASS_WITH_NOTES**

근거:

- 영향 있는 (P0/P1) GAP 없음.
- SKILL.md 와 4 references 모두 활성화 / scope / effect gate / output contract / verification / overlap 의 핵심 v2.1 기준 충족.
- 4 references 가 동일한 5섹션 phase shape 로 *evaluation 인프라 design-meta skill* 의 의도된 일관성 달성 — 이는 본 스킬의 가장 큰 강점.
- 평가 인프라 고유 검증축 (5종 표면 / schema 일관성 / 종료 조건 4종) 모두 본문과 references 양쪽에 명시.
- 발견된 GAP 4건 (ASSET 3 + AMBIGUITY 1) 은 모두 P2/P3 — 라우팅 모호 약화 (GAP-001), freshness 보강 (GAP-002), heuristic 표기 정밀화 (GAP-003), overlap 표 명시 (GAP-004). 자산 목적과 충돌하지 않고, 모두 *문서 보강 1-2 줄* 수준의 수정.
- GUIDE_GAP 1건 (GAP-005) 은 가이드 측 반영하면 향후 design-meta skill 확장 시 일관성 향상.
