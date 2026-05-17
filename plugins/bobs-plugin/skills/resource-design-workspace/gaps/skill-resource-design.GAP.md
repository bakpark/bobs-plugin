# GAP Report — skill: resource-design

## Metadata

```text
작성일: 2026-05-17
기준 버전: v2.1 (CONSTITUTION/SKILL/AGENT/COMMAND/HOOK/RUNTIME GUIDE 모두 v2.1, 2026-05-17 개정)
검토자: dispatched GAP analyst (no prior context)
asset_type: skill
source_path:
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/resource-design/SKILL.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/resource-design/references/decision-rules.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/resource-design/references/intent-capture.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/resource-design/references/design-output-contract.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, COMMAND-GUIDE.md, AGENT-GUIDE.md, HOOK-GUIDE.md, RUNTIME-GUIDE.md, GAP-FORMAT.md
final_decision: PASS_WITH_NOTES
```

---

## Executive Summary

`resource-design` 은 v2.1 기준 신규 메타 스킬로, 6 카테고리 (command / skill / agent / hook / runtime settings / plugin) 결정 트리를 운영하고 `Harness Installation Spec — resource` markdown 을 산출하며 실제 본문 작성은 creator skill 로 위임한다. 본 스킬은 deprecated `harness-resource-design` + `agent-skill-designer` 를 흡수했다.

전반적으로 v2.1 헌법의 §3.1 (Activation Explicit), §3.3 (Effects Gate, 이중), §3.4 (Output Contract, 4 모드), §3.7 (Progressive Disclosure, references 분리), §3.10 (Overlap Intentional, sibling skill 명시), §3.11 (User-Initiated Workflows Need Commands, escape hatch), §4 (선택 순서) 를 모두 만족한다. references 3 파일은 모두 *resource-design 고유 content* 라는 책임 경계를 헤더에 선언했고, `decision-rules.md` 는 실제로 GUIDE 규칙 본문을 재생산하지 않고 index/주제 매핑만 둔다 (drift 회피 의도가 살아 있음).

영향 있는 ASSET_GAP 은 없다. 다만 (1) description 안의 작은 라우팅 불일치 (P3 — "커맨드로 분리" trigger 가 의도된 6-asset 결정 트리와는 정합하지만 task brief 가 강조한 5-asset taxonomy 와는 어휘 충돌이 적다), (2) Output Contract 의 두 모드 (`blocked` vs `needs_input`) 경계 모호 (P2 — 호출자 파싱이 흔들릴 수 있음), (3) `decision-rules.md` 의 "Severity 빠른 기준" 섹션이 *index only* 선언과 약간 긴장 (P3 — 본문 재생산 가까움) 정도의 design-principle 차이가 있다.

---

## Asset Snapshot

```text
name: resource-design
description: Use when deciding which Claude harness resource type (command / skill / agent / hook / runtime settings / plugin) a new work pattern needs, or separating responsibility between existing resources. Produces a `Harness Installation Spec — resource`. Triggers on "스킬 만들어줘", "agent 필요할까", "hook 으로 자동화", "커맨드로 분리", "자원 설계", "resource decision", "scaffold harness for X". Do NOT use for authoring the actual SKILL.md / agent `.md` / hook script (use the respective creator skill), docs-tree contract (`context-map-architecture`), evaluation infrastructure (`evaluation-loop-design`), or static rule audit (`agent-skill-auditor`).
description_words: 88
body_words: 1309
body_lines: 175 (file 전체)
tools: (omitted — 본문에서 Read/Grep/Glob 위주 read-only 라 명시; intent-capture.md 의 "부수 효과 금지" 절이 Edit/Write/git/dispatch/network 를 명시 금지)
invocation_controls: 명시 escape hatch 4건 (context-map-architecture / evaluation-loop-design / agent-skill-auditor / claude-automation-recommender) + creator skill 위임 3건
has_references: yes (3 files: decision-rules.md, intent-capture.md, design-output-contract.md)
has_scripts_or_assets: no
has_effect_gate: yes (이중 — design gate + creator skill apply gate, SKILL.md §"Phase 3" 끝)
has_output_contract: yes (4 모드: created / no-op / blocked / needs_input, SKILL.md §"Output Contract")
```

---

## Applicable Criteria

- `CONSTITUTION.md` §2 (원칙 강도), §3.1-§3.13 (공통 원칙), §4 (선택 순서), §5 (하위 문서 역할)
- `SKILL-GUIDE.md` §1-§3 (역할 / 카테고리 / Skill vs Command), §4-§5 (Frontmatter / Description), §6 (Body), §7 (Effects), §8 (Progressive Disclosure), §9 (Output), §10 (Verification), §13 (Anti-Patterns)
- `COMMAND-GUIDE.md` §1-§2 (Command vs Skill 경계 — 본 스킬이 command 후보가 아닌지 검증)
- `GAP-FORMAT.md` §4-§7, §9, §13, §16

---

## Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | description 이 6 자원 타입을 모두 나열하고, 한·영 trigger phrase 7개 + 명시적 `Do NOT use for ...` 4건. SKILL-GUIDE §5 권장 패턴 충족 |
| Description avoids workflow shortcut | pass | description 은 trigger 와 산출물 한 줄 (`Produces a Harness Installation Spec — resource`) 만 — 본문 Phase 1-3 절차를 description 으로 끌어내지 않음 |
| Skill is an automatic external/domain capability, not a user workflow | partial | 메타 스킬 (harness 자원 설계 자체가 도메인) — 자동 활성화가 본문 의도. 다만 본 스킬은 "사용자가 새 자원 설계를 요청" 같은 사용자 주도 흐름 위에 자주 올라간다. 그러나 자체 입력 수집·plan gate·orchestration 을 직접 운영하지 않고 creator skill 에 dispatch 만 하므로 command-as-skill 안티패턴은 회피 |
| Scope or near-miss is clear when needed | pass | `When NOT to Use` 6 항목 + escape hatch 표 4행 (`intent-capture.md` §0) — 5 sibling 자원 간 경계가 모두 명시 |
| Capability procedure is actionable | pass | 3 Phase (Inspect / Decision / Spec Output) + 각 Phase 의 inspect 도메인·결정 트리·산출 형식이 명시. references 가 phase 별 세부 절차 위임 |
| Effect gate exists when mutation is possible | pass | 이중 gate (design gate + creator skill apply gate) SKILL.md §"Phase 3" 끝에 명시. intent-capture.md "부수 효과 금지" 절이 Edit/Write/git/dispatch/network 모두 금지 — read-only 책임과 일치 |
| Output contract exists | partial | 4 모드 (created / no-op / blocked / needs_input) 가 SKILL.md §"Output Contract" 에 정의. 다만 `blocked` (자원 타입 결정 모호) vs `needs_input` (inventory 미완) 경계가 호출자가 파싱할 때 가끔 흔들림 — finding GAP-001 |
| Progressive disclosure is appropriate | pass | SKILL.md 175 lines 안에 핵심 절차 / output / failure / references 가 모두 들어가고, GUIDE 본문은 normative source 직접 참조. references 3 파일 모두 *resource-design 고유* content 라 헤더 선언 |
| Reusable vs project memory is separated | pass | 본문에 프로젝트 고유 경로·convention·작업 기록 없음. inventory 도메인은 path pattern (`<repo>/.claude/...`, `plugins/*/...`) 만 |
| Behavior can be verified | partial | Common Failures 6항이 should-not-trigger / no-op / near-miss 케이스를 사실상 정의하지만 명시적 trigger eval 케이스 목록은 없음 — finding GAP-002 (P3) |
| Overlap is intentional | pass | escape hatch 표 + Common Failures 5번 항목이 5 sibling skill (`context-map-architecture` / `evaluation-loop-design` / `agent-skill-auditor` / `claude-automation-recommender` / creator skills) 와의 책임 차이를 명시 |

---

## Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §9 Output Contract` | `blocked` 와 `needs_input` 모드 경계가 호출자 관점에서 명확히 구분되지 않음 | asset |
| GAP-002 | ASSET_GAP | P3 | `SKILL-GUIDE.md §10 Verification` | 명시적 trigger / no-op / near-miss test case 목록 없음 — Common Failures 가 사실상 대체 중이지만 verification loop 구조 부재 | asset |
| GAP-003 | ASSET_GAP | P3 | `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate` / `SKILL-GUIDE.md §13 Reference dump` | `decision-rules.md` 의 "Severity 빠른 기준" 섹션이 *index only* 선언과 약간 긴장 — GAP-FORMAT §7 본문을 근사 재생산 | asset |
| GAP-004 | AMBIGUITY | P3 | `CONSTITUTION.md §4` / `decision-rules.md` 5-Asset Taxonomy | description 과 SKILL.md 본문은 6 카테고리 (command / skill / agent / hook / runtime settings / plugin) 를 사용하지만 `decision-rules.md` 5-Asset Taxonomy 표는 plugin 을 *자산 분류* 가 아닌 묶음으로 본 헌법 §1 과 정합 — 어휘 차이로 호출자가 "5 vs 6" 혼란 가능 | asset (note) |

---

### GAP-001: `blocked` 와 `needs_input` 모드 경계가 호출자 파싱 시 모호

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §9 Output Contract`, `CONSTITUTION.md §3.4 Output Is A Contract` |

**Expected**

호출자/runtime 이 결과를 해석하고 다음 행동 (사용자 질문 vs inventory 보완 vs spec 검토) 을 결정할 수 있도록 각 mode 가 disjoint 한 트리거 조건과 책임 분기를 가져야 한다 (CONSTITUTION §3.4).

**Actual**

- `blocked`: "자원 타입 결정 모호" — needs_input 으로 질문 (예: "반복 vs 일회성?", "직접 호출 vs 자동 활성화?")
- `needs_input`: "inventory 가 불완전 (접근 불가 디렉토리 / 권한 부족 / 외부 도구 정보 누락)"

두 모드 모두 사용자에게 추가 정보를 요구한다는 점이 같고, `blocked` 가 사실상 *디자인 차원의 needs_input* 이라 호출자가 두 모드를 같은 후처리 (사용자에게 질문) 로 다룰 가능성이 크다. `design-output-contract.md` §1.3 에서도 두 변형 케이스가 같은 frontmatter-style block (`> mode: ...`, `> needs_input:` / `> missing:`) 으로 표현돼 파싱 분기 가치가 약하다.

**Evidence**

- `SKILL.md` lines 130-147 — Output Contract 의 `blocked` / `needs_input` 블록 두 모드 정의.
- `references/design-output-contract.md` lines 88-103 — `mode: blocked` 와 `mode: needs_input` 변형 케이스 두 블록.

**Impact**

호출자 (특히 main session 의 dispatch loop) 가 두 모드를 같은 분기로 합쳐버리면 *왜 blocked 인지* (디자인 입력 부족) 와 *왜 needs_input 인지* (환경 접근 부족) 가 사용자 메시지에서 합쳐져 회복 행동이 달라진다. 반복되면 사용자 경험 품질 저하.

**Recommendation**

asset 수정. 둘 중 하나 선택:

1. 두 모드를 합쳐 `mode: needs_input` 하나로 두고 `category: design | inventory` 같은 sub-field 로 구분 — 호출자가 항상 같은 후처리를 한 뒤 sub-field 로 분기.
2. 두 모드 유지하되 SKILL.md Output Contract 와 `design-output-contract.md` §1.3 양쪽에 "두 mode 의 차이가 호출자 행동에 어떻게 다르게 매핑되는지" 한 줄 분기 표를 명시.

---

### GAP-002: 명시적 trigger / no-op / near-miss test case 목록 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §10 Verification`, `CONSTITUTION.md §3.9 Behavior Must Be Verifiable` |

**Expected**

메타 스킬은 라우팅 안정성이 곧 산출 품질이므로 should-trigger / should-not-trigger / near-miss / no-op 케이스를 본문 또는 references 에 목록화하는 것이 권장된다 (SKILL-GUIDE §10).

**Actual**

`Common Failures` 6 항목이 사실상 should-not-trigger / 자주 잘못 활성화되는 패턴을 다루지만, "어떤 prompt 가 들어왔을 때 발동/회피" 형식의 test case 목록은 없다. description 의 trigger phrase 7건이 should-trigger 신호 역할을 일부 하지만 회귀 검증 가능한 형태는 아니다.

**Evidence**

- `SKILL.md` lines 151-159 — Common Failures (6 항목).
- references 3 파일 모두 — verification / eval / pressure scenario 섹션 없음.

**Impact**

description 이나 escape hatch 가 시간이 지나며 표류 (drift) 할 때 회귀를 감지하기 어렵다. P3 인 이유 — Common Failures + escape hatch + When NOT to Use 가 합쳐져 사실상 가벼운 검증 표면을 제공하고, 메타 스킬 특성상 trigger eval 인프라가 다른 sibling skill (`evaluation-loop-design`) 의 책임이라 본 스킬에 둘 필요가 약함.

**Recommendation**

asset 수정 (낮은 우선순위). 1-2 줄 trigger/no-op/near-miss 예시 표를 본문 끝에 추가하거나, `evaluation-loop-design` 가 본 스킬을 검증 대상으로 다룬다는 사실을 `References` 절에 cite. 또는 의도된 omission 이라면 (`evaluation-loop-design` 가 sibling 으로 분리되어 있음) `Acceptable Deviations` 로 명시.

---

### GAP-003: `decision-rules.md` "Severity 빠른 기준" 섹션이 *index only* 선언과 긴장

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §13 (Reference dump)`, `CONSTITUTION.md §3.6 / §5 하위 문서의 역할` |

**Expected**

`decision-rules.md` 는 본문 헤더에서 "v2.1 GUIDE 의 **index map** — 규칙 본문을 재생산하지 않고, 어느 주제가 어느 GUIDE 의 어느 § 에 있는지 라우팅만 한다" 라고 선언했다. 모든 정의·기준은 normative GUIDE (특히 GAP-FORMAT.md §7) 가 권위.

**Actual**

`Severity 빠른 기준` 섹션 (lines 96-103) 이 P0 / P1 / P2 / P3 각 라벨의 *정의*를 4 줄로 풀어 적었다. 헤더 선언("규칙 본문을 재생산하지 않고") 과 *근사 재생산* 사이의 긴장. 같은 페이지 "주제 → GUIDE 위치" 표에 이미 `GAP Severity (P0-P3) | GAP-FORMAT §7` 라는 index 행이 있다.

**Evidence**

- `references/decision-rules.md` lines 1-5 — *index only* 선언.
- `references/decision-rules.md` lines 96-103 — "Severity 빠른 기준" 4-bullet 정의 본문.
- `references/decision-rules.md` line 91 — `GAP-FORMAT §7` index 행이 이미 존재.
- 비교: `GAP-FORMAT.md` §7 (lines 153-168) — Severity 정의의 정식 본문.

**Impact**

GAP-FORMAT.md §7 가 미래에 갱신되면 본 섹션이 drift 한다 — `decision-rules.md` 가 명시적으로 회피하려던 문제. 같은 패턴이 "빈번한 안티패턴" 섹션 (lines 107-117) 에도 있지만 그쪽은 한 줄 요약 + 회피책 형식이라 더 *index-스러움* — 그래도 동일 위험 존재.

**Recommendation**

asset 수정 (낮은 우선순위). `Severity 빠른 기준` 섹션을 한 줄로 압축 ("GAP-FORMAT §7 참조. P0=안전/데이터 위험, P1=라우팅·권한·산출 신뢰성, P2=품질 저하, P3=정리") 하거나 완전히 삭제하고 "GAP Severity → GAP-FORMAT §7" index 행만 유지. 동일 검토를 "빈번한 안티패턴" 섹션에도 적용.

---

### GAP-004: 5 vs 6 카테고리 어휘 비정합 (description / SKILL body vs 5-Asset Taxonomy 표)

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §1 공통 대상` (5 자산: skill / agent / command / hook / runtime settings), `CONSTITUTION.md §4 선택 원칙` (6 행 표 — plugin 포함) |

**Expected**

description / 결정 트리 / Taxonomy 표 가 같은 카테고리 셋을 일관되게 노출하거나, 다르다면 *왜 다른지* 한 줄 명시 (CONSTITUTION 자체가 §1 = 5 자산, §4 = 6 행 표 — plugin 은 *묶음* 으로 별도 카테고리이긴 함).

**Actual**

- `SKILL.md` description (line 3): 6 카테고리 (`command / skill / agent / hook / runtime settings / plugin`) 나열.
- `SKILL.md` 본문 Phase 2 결정 트리 (lines 54-62): 7 행 — plugin 포함.
- `decision-rules.md` "5-Asset Taxonomy" 표 (lines 18-26): 5 행 — plugin 제외. 별도 cross-link 없음.

CONSTITUTION 자체가 §1 (5 자산) 과 §4 (plugin 포함 7 행) 로 어휘를 분리 사용하므로 자산 본문이 헌법과 정합하지 않은 것은 아니다. 다만 `decision-rules.md` 의 표 제목 "5-Asset Taxonomy" 가 SKILL.md 본문의 6 카테고리와 어휘적으로 충돌한다.

**Evidence**

- `SKILL.md` line 3 (description), lines 54-62 (Phase 2 결정 트리).
- `references/decision-rules.md` lines 18-36 (5-Asset Taxonomy 표 + 선택 순서 7 단계).
- `CONSTITUTION.md` lines 22-32 (§1 — 5 자산 표), lines 338-352 (§4 — 7 행 표 포함 plugin).

**Impact**

호출자/리뷰어가 "5 자산이라더니 왜 plugin 도 결정 트리에 있나" 라는 인지적 마찰을 겪을 수 있음. 운영 결과는 동일하지만 문서 명확성 손상. P3.

**Recommendation**

asset 수정 (선택). `decision-rules.md` 의 "5-Asset Taxonomy" 표 제목을 "Core 5-Asset Taxonomy (+ plugin as bundling)" 혹은 표 하단에 "plugin 은 §4 선택 원칙에 따라 *묶음 자산* 으로 별도 분류 — 본 표의 5 자산을 install/share 단위로 묶음" 한 줄 추가. 또는 SKILL.md 의 description / 결정 트리를 "5 자산 + plugin (배포 묶음)" 처럼 명시 분리.

---

## Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| body 1,309 words (SKILL-GUIDE §11 권장: 일반 스킬 핵심 capability procedure 중심) | 메타 스킬 — 3 Phase, 4 mode output, 6-tuple Common Failures, 5 sibling 라우팅. references 분리가 명확하고 본문 자체가 progressive disclosure 의 *항상 노출 metadata 다음 단계* 책임 — SKILL-GUIDE §11 의 "긴 메타/교육형 스킬 — eval / reference / verification 구조가 있으면 길 수 있다" 단서 적용 |
| description 88 words (SKILL-GUIDE §11 권장: 보통 15-60) | 6 카테고리 + 7 trigger phrase + 4 명시적 `Do NOT use for ...` 가 라우팅 안정성에 직접 기여. SKILL-GUIDE §5 의 "near-miss 가 실제로 있다면 드러나는가" 충족 — 본 스킬은 5 sibling design skill 과 routing ambiguity 위험이 높아 description 길이 정당화 |
| `tools` frontmatter 생략 | intent-capture.md "부수 효과 금지" 절이 Edit / Write / git / dispatch / network 모두 명시 금지 + 본문이 inspect 도메인을 Read/Grep/Glob 로 한정. SKILL-GUIDE §4 "tools 명시는 필수 필드가 아니다" 단서 적용. 다만 명시했으면 capability surface 가 더 명확했을 — GAP 으로 승격할 정도는 아님 |
| Common Failures 가 verification loop 를 일부 대체 | 메타 스킬 — `evaluation-loop-design` 가 sibling 으로 분리되어 본 스킬의 검증 인프라 책임을 가짐 (escape hatch 명시). 다만 본 스킬에 한 줄 cite 가 있으면 더 좋음 (→ GAP-002) |
| description trigger phrase 중 "커맨드로 분리" 가 한·영 혼용 | 사용자가 실제 한국어로 raise 하는 phrase — SKILL-GUIDE §5 "검색될 단어가 있는가" 기준. 본 repo 의 다른 design skill description 도 동일 패턴 |

---

## Suggested Changes

### Asset Changes

- [ ] (P2) `SKILL.md` Output Contract 와 `references/design-output-contract.md` §1.3 — `blocked` vs `needs_input` 모드 경계를 호출자 분기 매핑 한 줄로 명시하거나, 두 모드를 `mode: needs_input` + `category` sub-field 로 통합. [GAP-001]
- [ ] (P3) `references/decision-rules.md` "Severity 빠른 기준" 섹션을 한 줄로 압축 또는 index 행만 유지 — drift 회피 의도 유지. 동일 검토를 "빈번한 안티패턴" 섹션에도 적용. [GAP-003]
- [ ] (P3) `SKILL.md` 끝에 trigger / no-op / near-miss 1-2 줄 예시표 추가, 또는 `evaluation-loop-design` 가 본 스킬을 검증 대상으로 다룬다는 사실을 `References` 절에 명시. [GAP-002]
- [ ] (P3) `references/decision-rules.md` "5-Asset Taxonomy" 표 하단에 plugin 의 카테고리 분리 의미 한 줄 추가 — SKILL.md 본문 6 카테고리와의 어휘 일관성 보강. [GAP-004]

### Guide Changes

None — v2.1 GUIDE 들이 본 스킬의 모든 의사결정을 normative 로 잘 커버. `GUIDE_GAP` 후보 없음.

### Constitution Review

None — 본 스킬에서 발견한 차이는 모두 자산-수준 정리에 해당. 헌법 수정 후보 없음.

---

## Follow-up Questions

1. `blocked` 와 `needs_input` 분리 의도 — 호출자 (main session) 가 두 모드에 실제로 다른 후처리를 적용하는가? 동일하면 통합이 안전.
2. `evaluation-loop-design` skill 이 본 스킬의 trigger eval 책임을 가지는가? 그렇다면 본 스킬의 verification omission 은 design intent 로 명문화 가능.
3. "5 sibling design skill" 표현 (SKILL.md line 157 Common Failures 5번) 의 의도된 5 = `context-map-architecture` / `evaluation-loop-design` / `agent-skill-auditor` / `claude-automation-recommender` / creator skills (3개) — 어떻게 5로 묶었는지? 실제 sibling *design* skill 은 3개 (resource-design 포함). 어휘 정확성 보강 권장 (P3 미만).

---

## Final Decision

**PASS_WITH_NOTES**

근거:
- 영향 있는 ASSET_GAP 은 GAP-001 (P2) 한 건 뿐. 나머지는 P3 또는 AMBIGUITY 로 자산 목적·라우팅·안전·산출 신뢰성에 직접 충격 없음.
- v2.1 헌법의 5-asset taxonomy + §4 선택 순서 + 이중 effect gate + escape hatch 분리 + GUIDE index-only 원칙이 모두 자산에 반영되어 있음 (특히 `decision-rules.md` 의 *index only* 선언과 실제 본문이 거의 일치).
- references 가 GUIDE 본문을 재생산하지 않는다는 drift 회피 의도가 살아 있음 — GAP-003 의 한 섹션만 예외.
- description / Phase / Output / Failure / References 모두 SKILL-GUIDE §6 권장 구조의 *기능적 등가물* 을 가지고, sibling skill 과의 책임 경계가 escape hatch + When NOT + Common Failures 3 중으로 보호됨.

다음 iteration 에서 GAP-001 (output mode 경계 명확화) 만 우선 처리 권장. 나머지는 다음 round 의 정기 리뷰에서 동시 정리.
