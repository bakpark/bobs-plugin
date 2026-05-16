# Skill GAP Report: frontend-design

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/frontend-design/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: 디자인 철학 + 미적 가이드라인 + 안티패턴 으로 구성된 "교육형 / 패턴" 스킬이다. v2 §3.1 description, §3.7 progressive disclosure 측면에서 가벼운 형태로 잘 작동한다.
- Highest severity: P2
- Main gap: output contract (산출물 형태, 기술 stack, 파일 위치) 가 거의 없다. "implement working code" 외에 어떤 결과물 형식으로 사용자에게 전달할지 contract 가 약하다. 또한 workflow / phase 구조가 없고 "Design Thinking" → "Frontend Aesthetics Guidelines" 의 두 단락이 본문 전부다.
- Recommended next action: 산출물 형태 (단일 파일 vs 컴포넌트 묶음, framework, preview/run 안내) 에 대한 가벼운 output contract 한 단락 추가.

---

## 3. Asset Snapshot

```text
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
description_words: ~30
body_words: ~560
body_lines: 41
tools: omitted
invocation_controls: none (frontmatter 에 `license:` 필드는 표준 외)
has_references: no
has_scripts_or_assets: no (LICENSE.txt 만 디렉토리에 있음)
has_effect_gate: n/a (advisory / 코드 생성형이지만 코드 산출 자체가 본질 책임)
has_output_contract: partial (코드 종류와 attributes 는 있으나 산출 형태/위치 명시 약함)
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`
- `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`

### Skill Guide

- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 Body 설계`
- `SKILL-GUIDE.md §7 Output Contract`
- `SKILL-GUIDE.md §11 Anti-Patterns`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | "Use this skill when the user asks to build web components, pages, or applications" |
| Description avoids workflow shortcut | pass | trigger + 가치 제안 위주, 절차 요약 없음 |
| Scope or near-miss is clear when needed | partial | "web 만" 인 점은 명확하지만 brainstorming / writing-plans 같은 선행 절차와의 관계는 본문에 없다 |
| Workflow is actionable | partial | "Design Thinking → implement" 의 두 단계가 가이드이지 workflow 는 아님. 디자인 가이드 성격이므로 의도된 변형 |
| Effect gate exists when mutation is possible | n/a | 생성형 스킬, gate 가 필수 아님 |
| Output contract exists | partial | "Production-grade and functional / Visually striking / Cohesive / Meticulously refined" 라는 attributes 가 contract 일부를 대체하지만 산출 형태(파일 구조, framework 선택, preview 방법) 부재 |
| Progressive disclosure is appropriate | pass | 본문이 짧고 references 없음 — 길이 자체로 부담 없음 |
| Reusable vs project memory is separated | pass | generic design philosophy |
| Behavior can be verified | partial | 산출 코드의 시각적 / 미적 평가는 본질적으로 주관적이므로 baseline 비교 필요 |
| Overlap is intentional | partial | brainstorming → writing-plans → frontend-design 의 호출 순서가 brainstorming 측에서 한 번 언급되지만 frontend-design 본문에는 없다 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §7` | output contract 가 attributes 수준이며 산출 형태/위치 명시 약함 | 산출 (file 구조 / framework / preview) 한 단락 추가 |
| GAP-002 | ASSET_GAP | P3 | `CONSTITUTION.md §3.8` | "NEVER use generic AI-generated aesthetics" 등 강한 표현이 취향 영역에 쓰임 | hard gate 톤 완화 또는 그대로 두되 reasoning 추가 |

### GAP-001: Output contract is weak on artifact shape

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §7 Output Contract`, `CONSTITUTION.md §3.4 Output Is A Contract` |

**Expected**

스킬은 실행 후 무엇을 남기는지 알려야 한다. 코드 생성형 스킬이라면 (1) 어떤 framework 로 산출하는지 결정 방식, (2) 파일 구조, (3) 사용자가 결과를 확인하는 방법, (4) 후속 단계 (preview, install, test) 가 contract 의 핵심.

**Actual**

본문은 "implement working code (HTML/CSS/JS, React, Vue, etc.)" 정도로 framework 선택을 모델에 맡기고, 산출 파일 구조나 결과 확인 방법은 명시되어 있지 않다.

**Evidence**

본문 "Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:" 단락. references 없음.

**Impact**

라우팅에는 영향이 작지만 호출 후 산출물 형식이 매 세션마다 달라질 수 있어 사용자 / 후속 자산이 결과를 일관되게 해석하기 어렵다. brainstorming 이 writing-plans 만 다음 단계로 허용한다는 점과 맞물려, frontend-design 이 어디서 호출되어 어디로 빠지는지가 흐려진다.

**Recommendation**

asset 수정. "## Output" 한 단락 추가:
- framework 결정 기준 (user-provided > project default > HTML/CSS/JS fallback)
- 파일 구조 (단일 file vs 컴포넌트 분리 기준)
- 사용자 검증 방법 (run / open / preview 명령 제공)
- 후속 단계 (test, accessibility check 자산이 있으면 안내)

### GAP-002: Strong "NEVER" language on aesthetic preferences

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`, `SKILL-GUIDE.md §11 Anti-Patterns` (Must-bombing) |

**Expected**

`NEVER`, `MUST` 같은 강한 표현은 안전 / mutation gate / false-positive filtering 같은 실제 gate 에 쓴다. 취향과 권장은 일반 톤으로 쓴다.

**Actual**

- "NEVER use generic AI-generated aesthetics ..."
- "NEVER converge on common choices (Space Grotesk, for example) across generations."
- "CRITICAL: Choose a clear conceptual direction ..."

이들은 미적 권장이지 안전 gate 가 아니다.

**Evidence**

"Frontend Aesthetics Guidelines" 단락.

**Impact**

영향이 작다. 다만 다른 스킬에서 강한 표현이 진짜 gate 에서만 사용되는 컨벤션이 일관될수록 모델이 hard rule 과 권장을 구분하기 쉽다.

**Recommendation**

asset 수정 옵션. "Avoid" 또는 "Prefer ... over ..." 톤으로 완화. INTENTIONAL_EXCEPTION 으로 두는 것도 가능 (의도적으로 모델의 "AI slop" 경향을 강하게 누르기 위한 선택일 가능성).

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| frontmatter 에 `license:` 필드 | v2 SKILL-GUIDE 에 명시 안 됨 (heuristic) — 외부 패키지 라이선스 표시 의도로 보임. asset platform behavior 확인 전 GAP 아님 |
| workflow 섹션 없음 | 디자인 가이드 / 교육형 스킬이며 v2 §4 의 "허용되는 변형: 교육형 스킬" 에 해당 |
| references 없음 | 본문이 짧고 단일 도메인. 추가 reference 부재 자체가 문제 아님 |

---

## 8. Suggested Changes

### Asset Changes

- [ ] 산출물 형식 / framework 결정 / preview 방법에 대한 짧은 Output 섹션 추가 (GAP-001)
- [ ] (선택) "NEVER" 톤 완화 또는 의도 명시 (GAP-002)

### Guide Changes

None

### Constitution Review

None

---

## 9. Follow-up Questions

- frontend-design 이 brainstorming → writing-plans 의 implementation phase 안에서 호출되는 것을 전제로 한 것인지, 단독 호출도 허용되는지. brainstorming SKILL.md 는 "Do NOT invoke frontend-design ... The ONLY skill you invoke after brainstorming is writing-plans" 라고 한다. frontend-design 본문에는 이 호출 순서가 언급되지 않아 일관성 확인 필요.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- description 과 본문이 짧고 교육형 변형으로 정당화 가능하다.
- output contract 가 약한 점이 P2 로 가장 큰 GAP. 안전 / 권한 위험은 없다.
- 강한 표현은 일부 over-use 되어 있지만 P3 수준.
