# Agent GAP Report: code-simplifier (root)

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | agent |
| source_path | `agents/code-simplifier.md` |
| compared_against | `CONSTITUTION.md`, `AGENT-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 본문 구조는 비교적 자세하지만 capability surface, output contract, overlap 측면에서 v2 핵심 원칙과 충돌한다.
- Highest severity: P1
- Main gap: advisory 가 아니라 mutation 을 수행하는 역할인데 (1) `tools` 가 생략되어 권한 표면을 알 수 없고, (2) "autonomously and proactively, refining code immediately" 라는 자동 실행 지시가 사용자 승인 gate 없이 mutation 을 권유하며, (3) `pr-review-toolkit/code-simplifier.md` 와 본문이 사실상 동일해 라우팅이 모호하다.
- Recommended next action: REVISE_ASSET — tools 명시, 자동 mutation 표현 완화, output contract 추가, 그리고 toolkit 버전과의 차이를 description 에 명시하거나 한쪽을 통합한다.

---

## 3. Asset Snapshot

| Field | Value |
|---|---|
| name | `code-simplifier` |
| description | `Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.` |
| description_words | ~25 |
| body_words | ~410 |
| body_lines | 53 |
| tools | omitted |
| model | `opus` |
| color | omitted |
| has_scope | partial (Focus Scope #5: "recently modified or touched in the current session") |
| has_output_contract | gap (없음 — "Document only significant changes" 한 줄만) |
| has_quality_gate | partial (Maintain Balance 항목으로 보수 기준 일부 제공) |
| has_project_memory_coupling | gap (CLAUDE.md 참조한다고 명시하지만, 본문에 ES modules / `function` keyword / React Props / try-catch 회피 등 프로젝트 컨벤션을 하드코딩) |

---

## 4. Applicable Criteria

Constitution:

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.2 Scope Controls Quality`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate`
- `CONSTITUTION.md §3.10 Overlap Must Be Intentional`

Agent Guide:

- `AGENT-GUIDE.md §2 Frontmatter`
- `AGENT-GUIDE.md §3 Description 전략`
- `AGENT-GUIDE.md §5 Scope 설계`
- `AGENT-GUIDE.md §6 Capability Surface`
- `AGENT-GUIDE.md §7 Output Contract`
- `AGENT-GUIDE.md §9 CLAUDE.md And Project Memory`
- `AGENT-GUIDE.md §10 Overlap And Reuse`
- `AGENT-GUIDE.md §13 Anti-Patterns` (Hidden mutation, Project convention leak, Unintentional duplicate)

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | partial | "Focuses on recently modified code" 정도. near-miss 없음. 자동 호출(autonomously, proactively)을 본문에서 권유. |
| Specialist role and mission are clear | pass | "code simplification specialist" 명시. |
| Scope and exclusions are clear | partial | 기본 입력(최근 수정 코드)은 있지만 제외 범위·no-op·pre-existing 처리 없음. |
| Capability surface matches responsibility | gap | mutation 역할인데 `tools` 생략. 권한 표면 불명확. |
| Model choice is explicit or justified | partial | `opus` 명시이지만 비용·품질 정당화 설명 없음. |
| Output contract exists | gap | 호출자가 받아갈 산출 형식이 정의되어 있지 않다. |
| Quality gate exists when needed | partial | "Maintain Balance" 가 일부 보수 기준 역할. confidence/severity 기반 gate 없음. |
| Project memory coupling is appropriate | gap | CLAUDE.md 참조한다고 하면서도 특정 프로젝트 스타일(ES modules, `function` keyword 등)을 본문에 하드코딩. |
| Overlap with other agents is intentional | gap | `pr-review-toolkit/code-simplifier.md` 와 본문 동일. 차이 설명 없음. |
| Behavior can be verified | partial | 자동·proactive 실행 지시 + output contract 부재로 반복 검증 어려움. |

---

## 6. Findings

요약 표:

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | AMBIGUITY | P1 | `AGENT-GUIDE.md §6.1`, `CONSTITUTION.md §3.5` | mutation 역할인데 `tools` 가 생략되어 권한 표면을 알 수 없음 | tools 를 역할에 맞게 명시 |
| GAP-002 | ASSET_GAP | P1 | `CONSTITUTION.md §3.3`, `AGENT-GUIDE.md §13 Hidden mutation` | "autonomously and proactively, refining code immediately" 라는 자동 mutation 지시에 gate 없음 | 자동 실행 문구 완화, 사용자 invocation 또는 advisory-only 로 정렬 |
| GAP-003 | ASSET_GAP | P1 | `CONSTITUTION.md §3.10`, `AGENT-GUIDE.md §10` | toolkit 의 동명 에이전트와 본문 동일, 차이 설명 없음 | description/toolkit context 차이 명시 또는 한쪽 deprecate |
| GAP-004 | ASSET_GAP | P2 | `AGENT-GUIDE.md §7`, `CONSTITUTION.md §3.4` | output contract 없음 (호출자가 받을 산출 형식 부재) | 변경 요약/파일 단위 diff/no-op 케이스 등 명시 |
| GAP-005 | ASSET_GAP | P2 | `AGENT-GUIDE.md §9`, `CONSTITUTION.md §3.6` | CLAUDE.md 의 프로젝트 컨벤션이 본문에 하드코딩 | CLAUDE.md 참조로 위임하고 본문은 일반 원칙만 유지 |
| GAP-006 | ASSET_GAP | P3 | `AGENT-GUIDE.md §3` | description 에 near-miss 없음 | "Do not use for general review/architecture decisions" 등 추가 |

### GAP-001: tools 생략으로 권한 표면 불명확

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P1 |
| Guide ref | `AGENT-GUIDE.md §6.1 Tools`, `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility` |

**Expected**

mutation 을 수행하는 에이전트는 `tools` 에 필요한 도구만 명시해 권한 표면을 좁힌다. 적어도 Read/Edit/Write/Grep/Glob 정도가 보이고, 위험 도구(Bash, MultiEdit 등)는 의도적으로 제외/포함된다.

**Actual**

frontmatter 에 `tools` 가 없다. 본문은 "refining code immediately after it's written or modified" 라고 mutation 을 가정한다.

**Evidence**

`agents/code-simplifier.md` frontmatter 5줄: `name`, `description`, `model` 만 존재.

**Impact**

플랫폼 default 가 "전체 권한" 인 경우 위험 도구까지 모두 허용된다. AGENT-GUIDE.md §6.1 는 "tools 생략을 '전체 권한' 으로 단정하지 않는다" 라고 했으므로 본 finding 은 AMBIGUITY 로 둔다. 그러나 mutation 역할에서는 권한 표면 명시가 안전·라우팅 양쪽에 영향을 주므로 P1.

**Recommendation**

Asset 수정. 최소 권한 목록을 명시한다(예: `Read, Edit, Grep, Glob`). Bash 같은 광범위 권한은 별도 정당화가 없다면 제외.

---

### GAP-002: 자동·proactive mutation 지시에 사용자 gate 없음

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §3.3 Effects Require Gates`, `AGENT-GUIDE.md §13 Anti-Patterns (Hidden mutation)` |

**Expected**

부수 효과가 있는 자산은 inspect → propose → approval → mutate → verify 흐름을 따른다. 자동 실행 표현은 hard gate 가 동반되어야 한다.

**Actual**

본문 마지막 단락에 "You operate autonomously and proactively, refining code immediately after it's written or modified without requiring explicit requests." 라는 진술이 있다. 사용자 승인이나 advisory 단계 없이 직접 mutation 을 권유한다.

**Evidence**

`agents/code-simplifier.md:52` `"You operate autonomously and proactively, refining code immediately after it's written or modified without requiring explicit requests."`

**Impact**

호출자/사용자가 의도하지 않은 시점에 코드를 변형할 수 있다. 자동 mutation 은 review/architecture 결정과 충돌할 수 있고, pre-existing 코드까지 휩쓸어 정리할 위험이 있다.

**Recommendation**

Asset 수정. 두 가지 중 선택:
- 옵션 A: 자동 실행 문구를 삭제하고 "호출자가 지시할 때만 실행한다" 로 명시.
- 옵션 B: advisory-only 로 전환하여 본문이 변경 제안만 출력하도록 정렬(이 경우 tools 에서 Write/Edit 제거).

---

### GAP-003: toolkit 동명 에이전트와 본문 동일, routing 불명확

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §3.10 Overlap Must Be Intentional`, `AGENT-GUIDE.md §10 Overlap And Reuse` |

**Expected**

비슷한 에이전트가 공존하면 trigger / scope / output / capability / 대상 toolkit / 실행 시점 중 하나 이상이 차별화되고 그 차이가 description 에 보여야 한다.

**Actual**

`agents/code-simplifier.md` 와 `agents/pr-review-toolkit/code-simplifier.md` 의 본문은 사실상 동일하다(persona, 5개 원칙, refinement process, 자동 실행 진술까지 일치). 차이는 description 형식뿐(toolkit 버전은 `<example>` 임베드, frontmatter 에 model 명시 동일).

**Evidence**

- `agents/code-simplifier.md:7-52` 본문
- `agents/pr-review-toolkit/code-simplifier.md:43-88` 본문 — 두 본문이 한 단락도 다르지 않음.

**Impact**

호출자/runtime 이 두 에이전트 중 어느 것을 선택해야 하는지 알 수 없다. 디스커버리 카탈로그에 같은 이름·같은 역할이 노출되면 라우팅 신뢰성이 떨어지고, 한쪽만 업데이트되면 일관성도 깨진다.

**Recommendation**

Asset 수정. 다음 중 하나:
- description 에 "general-purpose simplifier" vs "PR-review toolkit 의 마무리 단계 simplifier" 로 trigger 를 분리.
- toolkit 버전은 PR diff input/Output 에 맞춘 형식(예: PR comment 형식)으로 본문을 차별화.
- 차별점이 만들기 어렵다면 한쪽을 deprecate.

---

### GAP-004: Output contract 부재

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §7 Output Contract`, `CONSTITUTION.md §3.4 Output Is A Contract` |

**Expected**

호출자가 결과를 해석하고 다음 행동을 결정할 수 있도록 산출 형식(변경 요약/파일별 diff/no-op 케이스/follow-up)이 정의된다.

**Actual**

본문 refinement process 6번에 "Document only significant changes that affect understanding" 한 줄이 있을 뿐 호출자에게 반환할 fields 가 없다.

**Evidence**

`agents/code-simplifier.md:50` "Document only significant changes that affect understanding"

**Impact**

호출자는 이 에이전트가 무엇을 바꿨는지, 또는 no-op 인지 식별하기 어렵다. 재호출/검증 비용 증가.

**Recommendation**

Asset 수정. 예시: "변경한 파일 목록, 각 파일의 변경 요약(왜/무엇), 변경하지 않은 항목(rationale), no-finding 시 'No simplification needed' 명시" 형식을 본문에 추가.

---

### GAP-005: 프로젝트 컨벤션을 본문에 하드코딩

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `AGENT-GUIDE.md §9 CLAUDE.md And Project Memory`, `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate` |

**Expected**

reusable 에이전트는 일반 원칙만 본문에 두고, 특정 프로젝트 스타일(import 형식, framework pattern, path convention)은 CLAUDE.md 로 위임한다.

**Actual**

본문 #2 "Apply Project Standards" 가 ES modules / `function` keyword / explicit return types / React Props / try-catch 회피 등 프로젝트-특화 스타일을 직접 열거한다.

**Evidence**

`agents/code-simplifier.md:13-20` "Use ES modules ... Prefer `function` keyword ... explicit return type annotations ... React component patterns with explicit Props types ... avoid try/catch when possible".

**Impact**

다른 프로젝트(예: Python, CommonJS, 함수형 스타일 선호 팀)에서 호출하면 적용 불가한 규칙이 강제된다. 재사용성 저하.

**Recommendation**

Asset 수정. 본문은 "CLAUDE.md / project memory 의 명시적 규칙을 따른다" 라고 위임하고, 위의 구체 항목은 예시(optional appendix) 또는 별도 프로젝트 메모리로 이동.

---

### GAP-006: description 에 near-miss 없음

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `AGENT-GUIDE.md §3 Description 전략` |

**Expected**

라우팅 혼선이 가능한 인접 역할(예: code-reviewer, architecture review, comment-analyzer)과 어디서 갈리는지 짧게라도 보인다.

**Actual**

description 한 문장에 "what" 만 있고 negative case 가 없다.

**Evidence**

`agents/code-simplifier.md:3` description 본문.

**Impact**

bug 검출·architectural 변경·문서 검토 같은 인접 역할 호출과 혼동될 수 있음. 영향은 낮음(P3).

**Recommendation**

Asset 수정. "Do not use for bug detection, architectural redesign, or comment-only review" 한 줄 추가.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `color` 미명시 | UI hint 이며 라우팅에 영향이 적어 GAP 으로 승격하지 않음. |

---

## 8. Suggested Changes

### Asset Changes

- [ ] `tools` 를 명시 (mutation 역할이면 최소 `Read, Edit, Grep, Glob`; advisory 로 바꾼다면 Read/Grep/Glob 만).
- [ ] "operate autonomously and proactively" 문구를 제거하거나 "호출자 요청 시" 로 완화.
- [ ] description 에 negative case 추가, 그리고 `pr-review-toolkit/code-simplifier.md` 와의 차이 명시.
- [ ] Output contract 섹션 추가 (변경 파일·요약·no-op 케이스).
- [ ] 본문 "Apply Project Standards" 의 프로젝트-특화 항목을 CLAUDE.md 참조로 위임.

### Guide Changes

- [ ] None.

### Constitution Review

- [ ] None.

---

## 9. Follow-up Questions

- 이 에이전트와 `pr-review-toolkit/code-simplifier.md` 중 어느 것이 canonical 인가? (둘 다 유지할 가치가 있다면 차별점을 분명히 해야 함.)
- 실제 사용 패턴이 mutation 인가 advisory 인가? 운영 정책이 결정되면 tools 와 본문 자동 실행 문구를 일관되게 정렬해야 함.

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거:

- mutation 역할인데 `tools` 미명시(P1 AMBIGUITY)와 자동 실행 지시에 gate 없음(P1 ASSET_GAP).
- toolkit 동명 에이전트와 본문 동일(P1)로 라우팅 ambiguity 발생.
- output contract 부재(P2), 프로젝트 컨벤션 하드코딩(P2)이 누적.
- 다만 본문이 specialist role / scope / quality balance 를 다루고 있어 전체 폐기보다 정렬이 적합. SPLIT 도 검토했으나 본문이 그대로 두면 결국 동일하므로 REVISE 가 우선.
