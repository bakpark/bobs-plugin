# Skill GAP Report: claude-automation-recommender

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/claude-automation-recommender/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: read-only 자산임을 본문에서 명시하고 `tools: Read, Glob, Grep, Bash` 로 capability surface 를 축소한 점이 v2 §3.3 / §3.5 의 advisory 역할 + 권한 축소 의도와 잘 맞는다. recommendation 산출 contract (Phase 3 template) 도 분명하다.
- Highest severity: P2
- Main gap: description 이 60 words 를 넘기며 trigger 열거가 길고 첫 문장이 workflow 요약 경향(P2). 더해 `Bash` 권한이 codebase 분석 외 수정 작업에 쓰일 여지가 있어 본문 scope note 가 약함(AMBIGUITY, P3).
- Recommended next action: description 압축 및 Bash 사용 범위에 대한 한 줄 scope note 추가.

---

## 3. Asset Snapshot

```text
name: claude-automation-recommender
description: Analyze a codebase and recommend Claude Code automations (hooks, subagents, skills, plugins, MCP servers). Use when user asks for automation recommendations, wants to optimize their Claude Code setup, mentions improving Claude Code workflows, asks how to first set up Claude Code for a project, or wants to know what Claude Code features they should use.
description_words: ~65
body_words: ~1500
body_lines: 288
tools: Read, Glob, Grep, Bash
invocation_controls: none
has_references: yes (references/{mcp-servers,skills-reference,hooks-patterns,subagent-templates,plugins-reference}.md)
has_scripts_or_assets: no
has_effect_gate: yes (skill is read-only by declaration)
has_output_contract: yes (Phase 3 recommendation template)
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`

### Skill Guide

- `SKILL-GUIDE.md §2 Frontmatter`
- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §5 Effects And Gates`
- `SKILL-GUIDE.md §7 Output Contract`
- `SKILL-GUIDE.md §9 Quantitative Heuristics`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | "Use when..." 5가지 trigger 가 열거되어 있다. |
| Description avoids workflow shortcut | partial | trigger 열거 자체는 적절하지만 첫 문장 "Analyze a codebase and recommend ..." 는 가벼운 작업 요약 |
| Scope or near-miss is clear when needed | partial | "read-only" 선언은 있으나 near-miss (예: 자동화를 *구현* 해달라는 요청과의 경계)는 본문 일부에 분산 |
| Workflow is actionable | pass | Phase 1 → Phase 2(A-E) → Phase 3 으로 실행 가능 |
| Effect gate exists when mutation is possible | pass | "This skill is read-only" 선언이 본문 상단에 있다 |
| Output contract exists | pass | Phase 3 의 markdown template 이 곧 contract |
| Progressive disclosure is appropriate | pass | reference 5개를 분리 |
| Reusable vs project memory is separated | pass | generic 한 detection table 위주 |
| Behavior can be verified | partial | output template 준수 여부는 검증 가능, 추천 품질은 별도 평가 필요 |
| Overlap is intentional | partial | claude-md-improver 등 동일 toolkit 자산과의 차이는 본문에 명시되어 있지 않음 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §3` | description 이 65 words 로 trigger 열거가 길고 첫 문장이 workflow 요약 | trigger-only 로 정리, 첫 문장 압축 |
| GAP-002 | AMBIGUITY | P3 | `CONSTITUTION.md §3.5` | `tools` 에 `Bash` 포함, read-only 선언과의 결합 의도 명확화 필요 | 본문에 Bash 사용 범위(`ls`, `cat`, `find` 등 inspect-only) 한 줄 추가 |

### GAP-001: Description over-enumerates triggers

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §3 Description 작성`, `SKILL-GUIDE.md §9 Quantitative Heuristics` |

**Expected**

description 은 15-60 words 범위에서 trigger signal 만 담는다. workflow 요약은 본문에 둔다.

**Actual**

- 첫 문장: "Analyze a codebase and recommend Claude Code automations (hooks, subagents, skills, plugins, MCP servers)" — 산출물 종류를 4종 모두 나열.
- 후속: "Use when ... asks for automation recommendations, wants to optimize ..., mentions improving ..., asks how to first set up Claude Code for a project, or wants to know what Claude Code features they should use" — 5가지 trigger 중 일부는 겹친다.

**Evidence**

frontmatter `description` (~65 words). v2 §9 의 "보통 15-60 words" 진단 신호를 약하게 넘는다.

**Impact**

trigger 열거가 비슷한 표현으로 늘어나면 description 만으로 routing 이 흐려질 수 있다. 직접 안전 위험은 없으나 반복 호출 시 context 비용에 누적된다.

**Recommendation**

asset 수정. 예: `Use when the user asks for Claude Code automation recommendations (hooks, subagents, skills, plugins, MCP servers) or wants to optimize their Claude Code setup for a project`. 첫 문장의 workflow 요약 부분은 본문 상단에 둔다.

### GAP-002: Bash capability and read-only role need clearer scope note

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`, `SKILL-GUIDE.md §5 Effects And Gates` |

**Expected**

advisory / read-only 자산이 Bash 를 갖는다면 inspect-only 의도를 명시한다. 그렇지 않으면 본문 declaration 과 capability surface 가 미세하게 충돌한다.

**Actual**

- 본문: "This skill is read-only. ... It does NOT create or modify any files."
- frontmatter: `tools: Read, Glob, Grep, Bash`
- Phase 1 의 Bash 예시는 `ls`, `cat`, `find` 등 inspect-only 명령으로 한정.

**Evidence**

frontmatter line 4, body line 11, Phase 1 bash block.

**Impact**

본문 declaration 으로 의도는 분명하지만, 모델이 Bash 를 통해 사용자 환경에 부수 효과를 주는 명령 (예: install, write file) 을 실행할 여지가 platform 권한에 따라 열려 있다. 영향이 크진 않으나 v2 §3.5 의 "권한과 책임 일치" 측면에서 한 줄 보강이 도움이 된다.

**Recommendation**

asset 수정 옵션. 본문 read-only 선언 옆에 "Bash usage is limited to inspection commands (ls, cat, grep, find, etc.); this skill never installs, writes, or modifies files." 한 줄 추가. P3 이며 형식 차이 수준.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `When NOT to Use` 별도 섹션 없음 | read-only 선언과 Decision Framework 가 anti-trigger 역할을 일부 한다 |
| 본문 길이 ~1500 words | 5가지 자동화 유형의 detection 표가 본질이며 각 reference 로 분리되어 있다 |
| 본문 안에 plugin 추천 / config snippet 이 함께 | 책임이 "추천" 으로 단일 |

---

## 8. Suggested Changes

### Asset Changes

- [ ] description 압축 + workflow 요약 제거 (GAP-001)
- [ ] (선택) Bash inspect-only scope 한 줄 보강 (GAP-002)
- [ ] (선택) claude-md-improver 등 인접 자산과의 near-miss 한 줄 추가

### Guide Changes

None

### Constitution Review

None

---

## 9. Follow-up Questions

- platform default 에서 `tools: Read, Glob, Grep, Bash` 가 Edit/Write 를 자동 제거하는지 확인 (확정되면 GAP-002 는 NO_GAP 으로 정리 가능)

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- read-only 선언, capability 축소, output contract 가 v2 의 advisory 자산 기대에 부합한다.
- 발견된 GAP 은 description 길이와 capability surface 명료화 수준이며 모두 P2 / P3.
- P0/P1 위험 (mutation 누락, 산출 신뢰성 손상) 없음.
