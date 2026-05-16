# Skill GAP Report: writing-skills

작성일: 2026-05-16
기준 버전: v1
검토자: Codex agent

---

## 1. Metadata

| Field | Value |
|---|---|
| Asset type | skill |
| Skill name | `writing-skills` |
| Source path | `skills/writing-skills/SKILL.md` |
| Compared against | `CONSTITUTION.md`, `SKILL-GUIDE.md` |
| Final decision | REVISE_ASSET |

---

## 2. Executive Summary

- Overall fit: 부분적 준수. TDD 기반 메타 스킬로서 구조는 우수하나 description 과 톤, 프로젝트 누출에서 GAP 존재.
- Highest severity: P1 (description-as-runbook)
- Main gap: description 이 "Use when creating new skills, editing existing skills, or verifying skills work before deployment" — skill-creator 와 중복 trigger; MUST-bombing 과다; 프로젝트 특정 경로 누출
- Recommended next action: description 을 skill-creator 와 차별화, MUST 문구 대체, 프로젝트 경로 분리

---

## 3. Skill Snapshot

### 3.1 Frontmatter

| Field | Value |
|---|---|
| name | `writing-skills` |
| description | `"Use when creating new skills, editing existing skills, or verifying skills work before deployment"` |
| description words | 16 |
| tools | omitted |
| invocation controls | none |

### 3.2 Body Shape

| Field | Value |
|---|---|
| body words | 3212 |
| body lines | 655 |
| main sections | Overview, What is a Skill, TDD Mapping, When to Create, Skill Types, Directory Structure, SKILL.md Structure, CSO, Flowchart Usage, Code Examples, File Organization, Iron Law, Testing All Skill Types, Rationalizations, Bulletproofing, RED-GREEN-REFACTOR, Anti-Patterns, Checklist |
| has When to Use | partial ("When to Create a Skill") |
| has When NOT to Use | yes ("Don't create for:") |
| has workflow/checklist | yes (TDD cycle + checklist) |
| has output contract | partial |
| has approval gate | not needed |
| has references | yes (references/ mention, .md 파일들) |
| has scripts/assets | yes (render-graphs.js mention) |

---

## 4. Applicable v1 Criteria

- `CONSTITUTION.md §2.1 Description Is The Router`
- `CONSTITUTION.md §2.5 Explain Why; Do Not Must-Bomb`
- `CONSTITUTION.md §2.6 Progressive Disclosure Protects Context`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §4 본문 구조`
- `SKILL-GUIDE.md §9 정량 기준`

---

## 5. Skill-Specific Checks

| Check | Status | Notes |
|---|---|---|
| Description is trigger-only | gap | "creating new skills, editing existing skills" — skill-creator 와 중복 |
| No workflow summary in description | pass | 절차 요약은 아님 |
| Keyword coverage exists | pass | "skills", "TDD", "testing" |
| Has negative case or near-miss | pass | "Don't create for:" 섹션 존재 |
| Workflow/checklist is actionable | pass | TDD cycle 명확 |
| Output contract is clear | partial | |
| Approval gate for mutation | not needed | |
| Progressive disclosure is appropriate | gap | 655 lines 과다 |
| Avoids project-specific leakage | gap | `~/.claude/skills`, `superpowers:test-driven-development` 등 프로젝트 경로 |
| Test/trigger eval path is possible | pass | 자체적으로 testing 구조 포함 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `SKILL-GUIDE.md §3` | description 이 skill-creator 와 중복 trigger ("creating new skills, editing existing skills") | 차별화 필요 |
| GAP-002 | ASSET_GAP | P1 | `CONSTITUTION.md §2.5` | MUST/NEVER 과다 사용 (15+회) | 이유 기반 설명으로 대체 |
| GAP-003 | ASSET_GAP | P2 | `SKILL-GUIDE.md §9` | 655 lines / 3212 words | reference 분리 고려 |
| GAP-004 | ASSET_GAP | P2 | `CONSTITUTION.md §2.9` | 프로젝트 특정 경로 누출 (`~/.claude/skills`, `superpowers:*`) | CLAUDE.md 로 분리 |

### GAP-001: Description Overlaps with skill-creator

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `SKILL-GUIDE.md §3`, `CONSTITUTION.md §2.1` |

**Expected**: description 이 고유한 trigger 조건으로 다른 스킬과 중복되지 않음.

**Actual**: `"Use when creating new skills, editing existing skills, or verifying skills work before deployment"` — skill-creator 의 description 도 `"Create new skills, modify and improve existing skills, and measure skill performance"` 로 거의 동일함.

**Evidence**: 두 스킬의 description 이 "creating skills", "editing skills" 을 모두 포함.

**Impact**: 라우팅 시 두 스킬이 동시에 트리거되어 컨텍스트 중복 로드. 둘 다 메타 스킬이지만 writing-skills 는 TDD 관점, skill-creator 는 eval/iteration 관점 — 이를 description 에서 구분해야 함.

**Recommendation**: writing-skills description 을 `"Use when applying test-driven development to skill creation. Write failing tests first, watch agents fail without the skill, then write minimal documentation that addresses those failures."` 형태로 TDD 중심 trigger 로 차별화.

### GAP-002: Must-Bombing Throughout

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §2.5` |

**Expected**: 강한 명령은 실제 safety gate 에만 사용.

**Actual**: "You MUST understand", "NEVER summarize", "NO SKILL WITHOUT A FAILING TEST FIRST", "No exceptions:", "Delete means delete" 등 15+ 회 MUST/NEVER 사용.

**Impact**: TDD 헌법으로서 일부 강조는 의도적일 수 있으나, 과도한 MUST 는 실제 gate 와 일반 지침 구분 불가.

**Recommendation**: "Iron Law" 섹션의 핵심 gate(MUST) 는 유지하되, 나머지 절차는 이유 기반 설명으로 대체.

### GAP-003: Body Too Long

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §9` |

**Expected**: 메타 스킬은 3000+ words 가능하나 eval/iteration/reference 구조가 있을 때만 정당화.

**Actual**: 655 lines, 3212 words. CSO 섹션이 특히 상세함 (keyword coverage, naming, token efficiency).

**Impact**: 컨텍스트 예산 소모.

**Recommendation**: CSO 상세 예시를 references/cso-guide.md 로 분리.

### GAP-004: Project-Specific Path Leakage

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §2.9` |

**Expected**: 프로젝트 고유 경로는 CLAUDE.md 에 둠.

**Actual**:
- `~/.claude/skills`, `~/.agents/skills/` — 특정 도구 경로
- `superpowers:test-driven-development`, `superpowers:systematic-debugging` — 프로젝트 내부 스킬 참조
- `agentskills.io/specification` — 외부 링크

**Impact**: 다른 프로젝트/도구에서 재사용 시 경로가 의미 없음.

**Recommendation**: 도구별 경로를 환경 변수 또는 CLAUDE.md 설정으로 분리. `superpowers:*` 참조를 generic placeholder 로 변경.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| TDD 철학의 강한 톤 | 메타 스킬로서 헌법적 성격이 있음. 일부 MUST 는 Iron Law 의 핵심 gate 로 정당화 가능 |
| Rationalization Table 패턴 | 좋은 패턴. v1 가이드에 명시되지 않았으나 agent rationalization 방지 전략으로 유용 — GUIDE_GAP 후보 |

---

## 8. Suggested Changes

### 8.1 Skill Changes

- [ ] description 을 skill-creator 와 차별화 (TDD 중심 trigger) — P1
- [ ] MUST/NEVER 문구를 Iron Law gate 외에는 이유 기반 설명으로 대체 — P1
- [ ] CSO 상세 예시를 references/ 로 분리 — P2
- [ ] 프로젝트 특정 경로 (`~/.claude/skills`, `superpowers:*`) 분리 — P2

### 8.2 Guide Changes

- [ ] `SKILL-GUIDE.md` 에 Rationalization Table 패턴 추가 고려 (GUIDE_GAP)

---

## 9. Follow-up Questions

- writing-skills 와 skill-creator 의 책임 경계를 어떻게 명확히 할 것인가? 두 스킬이 동시에 로드되면 안 되는가?

---

## 10. Final Decision

```text
REVISE_ASSET
```

근거: description 이 skill-creator 와 중복 trigger (P1), MUST-bombing 과다 (P1), 프로젝트 특정 경로 누출 (P2). TDD 기반 메타 스킬로서 구조와 철학은 우수하나 라우팅과 톤 수정 필요.
