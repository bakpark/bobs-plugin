# Skill GAP Report: brainstorming

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill |
| Skill name | `brainstorming` |
| Source path | `skills/brainstorming/SKILL.md` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` |
| Final decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 부분적 준수. 핵심 workflow 와 gate 구조는 우수하나 description 과 톤에서 심각한 GAP 존재.
- Highest severity: P1 (description-as-runbook, MUST-bombing)
- Main gap: description 이 trigger 조건이 아니라 강제문구+workflow 요약; 본문 전체가 MUST/NEVER 과도 사용
- Recommended next action: description 을 trigger-only 로 재작성; MUST 문구를 이유 기반 설명으로 대체

---

## 3. Skill Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `brainstorming` |
| description | `"You MUST use this before any creative work..."` |
| description words | 32 |
| tools | omitted |
| invocation controls | none |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | 1553 |
| body lines | 164 |
| main sections | Anti-Pattern, Checklist, Process Flow (dot), The Process, After the Design, Key Principles, Visual Companion |
| has When to Use | no |
| has When NOT to Use | no |
| has workflow/checklist | yes |
| has output contract | partial |
| has approval gate | yes |
| has references | yes |
| has scripts/assets | no |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.5 Explain Why; Do Not Must-Bomb`
- `CONSTITUTION.md §2.9 CLAUDE.md Is Project Memory`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 본문 구조`
- `SKILL-GUIDE.md §5 톤과 문체`

---

## 5. Skill-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description is trigger-only | gap | "You MUST use" 명령문+workflow 요약 포함 |
| No workflow summary in description | gap | "Explores user intent, requirements and design before implementation" |
| Keyword coverage exists | pass | "creative work", "features", "components" 등 |
| Has negative case or near-miss | gap | 없음 |
| Workflow/checklist is actionable | pass | 9단계 체크리스트 명확 |
| Output contract is clear | partial | design doc path 명시하지만 format 구체적이지 않음 |
| Approval gate for mutation | pass | HARD-GATE + User Review Gate |
| Progressive disclosure is appropriate | pass | visual-companion 분리 |
| Avoids project-specific leakage | gap | `docs/superpowers/specs/` 하드코딩 |
| Test/trigger eval path is possible | n/a | |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `SKILL-GUIDE.md §3` | description 이 "You MUST use" 명령문으로 시작 | trigger 형식으로 재작성 |
| GAP-002 | ASSET_GAP | P1 | `CONSTITUTION.md §2.5` | 본문 전체에 MUST/NEVER 과다 (10+회) | 이유 기반 설명으로 대체 |
| GAP-003 | ASSET_GAP | P2 | `SKILL-GUIDE.md §4` | When to Use / When NOT to Use 섹션 없음 | 추가 |
| GAP-004 | ASSET_GAP | P2 | `CONSTITUTION.md §2.9` | `docs/superpowers/specs/` 경로 하드코딩 | CLAUDE.md 로 분리 |

### GAP-001: Description Is Not Trigger-Only

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `SKILL-GUIDE.md §3`, `CONSTITUTION.md §2.1` |

**Expected**: description 은 "Use when ..." trigger 조건으로 작성.

**Actual**: `"You MUST use this before any creative work... Explores user intent, requirements and design before implementation."` — 명령문+절차 요약.

**Evidence**: 첫 문장 "You MUST use", 두 번째 절이 절차 요약.

**Impact**: 모델이 description 만 읽고 본문을 우회할 위험. 강제문이 trigger 신호로 작용하지 않음.

**Recommendation**: `"Use when starting creative work such as creating features, building components, adding functionality, or modifying behavior."` 형태로 재작성.

### GAP-002: Must-Bombing Throughout Body

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §2.5` |

**Expected**: 강한 명령은 실제 safety/approval gate 에만 사용.

**Actual**: 10+ 회 MUST/NEVER 사용 ("You MUST create a task", "Do NOT invoke any implementation skill", "This offer MUST be its own message" 등). 대부분 workflow 절차에 대한 것임.

**Impact**: 과도한 MUST 는 실제 gate 와 일반 지침 구분 불가. 모델이 규칙만 나열했을 때보다 왜 중요한지 이해했을 때 더 안정적으로 행동함 (§2.5).

**Recommendation**: MUST/NEVER 를 HARD-GATE 및 User Review Gate 로 제한. 나머지 절차는 이유 기반 설명으로 재작성.

### GAP-003: Missing When to Use / When NOT to Use

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §4` |

**Expected**: 본문에 명시적 When to Use / When NOT to Use 섹션.

**Actual**: Anti-Pattern 섹션은 있으나 공식 When to Use/NOT 구조 없음.

**Impact**: near-miss 케이스에서 다른 스킬과 혼동 가능.

**Recommendation**: 본문 초기에 When to Use / When NOT to Use 섹션 추가.

### GAP-004: Project-Specific Path Leakage

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §2.9` |

**Expected**: 프로젝트 고유 경로는 CLAUDE.md 에 둠.

**Actual**: `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` — `superpowers` 는 특정 프로젝트 디렉토리명.

**Impact**: 다른 프로젝트에서 재사용 시 경로가 의미 없음.

**Recommendation**: 경로를 설정 가능한 변수로 변경하거나 CLAUDE.md 에서 override 할 수 있도록 문서화.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `<HARD-GATE>` 커스텀 태그 사용 | gate 가 명확하고 역할 적절. v1 형식과 다르지만 기능적 유효성 높음 |
| dot flowchart 포함 | 비자명한 결정 지점에 사용 (§9 권장). 복잡한 workflow 에 적합 |

---

## 8. Suggested Changes

### 8.1 Skill Changes

- [ ] description 을 trigger-only 형식으로 재작성 ("You MUST use" 제거)
- [ ] MUST/NEVER 문구를 gate 가 아닌 곳은 이유 기반 설명으로 대체
- [ ] When to Use / When NOT to Use 섹션 추가
- [ ] `docs/superpowers/specs/` 경로를 설정 가능한 변수로 변경

### 8.2 Guide Changes

None.

---

## 9. Follow-up Questions

- `superpowers` 디렉토리명이 특정 프로젝트에서만 쓰이는가? 그렇다면 CLAUDE.md 로 분리해야 함.

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거: description 이 라우팅 계약이 아님 (P1), MUST-bombing 과다 (P1), 프로젝트 특정 경로 누출 (P2). 핵심 workflow/gate 구조는 우수하므로 수정 대상임.
