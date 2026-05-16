# Skill GAP Report: claude-md-improver

---

## 1. Metadata

| Field | Value |
|---|---|
| 작성일 | 2026-05-16 |
| 기준 버전 | v2 |
| 검토자 | Claude Opus 4.7 |
| asset_type | skill |
| source_path | `skills/claude-md-improver/SKILL.md` |
| compared_against | `CONSTITUTION.md`, `SKILL-GUIDE.md`, `GAP-FORMAT.md` |
| final_decision | PASS_WITH_NOTES |

---

## 2. Executive Summary

- Overall fit: Phase 3 quality report → Phase 4 propose → Phase 5 apply 순서로 v2 §3.3 (Effects Require Gates) 의 inspect → report → approval → mutate → verify 패턴이 깨끗하게 구현되어 있다. `tools: Read, Glob, Grep, Bash, Edit` 로 capability 가 좁혀져 있다.
- Highest severity: P2
- Main gap: "Phase 4: After outputting the quality report, ask user for confirmation before updating" 와 "Phase 5: After user approval, apply changes using the Edit tool" 가 명시되어 있어 gate 는 작동하지만, description 이 trigger 외 workflow 요약 ("Scans for all CLAUDE.md files, evaluates quality against templates, outputs quality report, then makes targeted updates") 을 일부 포함하고 있다. routing 영향은 작지만 본문 우회 위험이 있다.
- Recommended next action: description 의 workflow 요약 부분 축소.

---

## 3. Asset Snapshot

```text
name: claude-md-improver
description: Audit and improve CLAUDE.md files in repositories. Use when user asks to check, audit, update, improve, or fix CLAUDE.md files. Scans for all CLAUDE.md files, evaluates quality against templates, outputs quality report, then makes targeted updates. Also use when the user mentions "CLAUDE.md maintenance" or "project memory optimization".
description_words: ~55
body_words: ~870
body_lines: 179
tools: Read, Glob, Grep, Bash, Edit
invocation_controls: none
has_references: yes (references/quality-criteria.md, references/templates.md)
has_scripts_or_assets: no
has_effect_gate: yes (Phase 3 report-before-mutation, Phase 4 ask for confirmation, Phase 5 apply after approval)
has_output_contract: yes (quality report template + diff format)
```

---

## 4. Applicable Criteria

### Constitution

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.6 Reusable Knowledge And Local Memory Must Stay Separate`

### Skill Guide

- `SKILL-GUIDE.md §3 Description 작성`
- `SKILL-GUIDE.md §5 Effects And Gates`
- `SKILL-GUIDE.md §7 Output Contract`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | "Use when user asks to check / audit / update / improve / fix CLAUDE.md files" |
| Description avoids workflow shortcut | partial | "Scans for all CLAUDE.md files, evaluates quality against templates, outputs quality report, then makes targeted updates" 한 문장이 본문 workflow 의 요약 |
| Scope or near-miss is clear when needed | pass | 본문에서 "CLAUDE.md improver" 로 대상 파일 범위 명확. |
| Workflow is actionable | pass | Phase 1-5 단계 + diff format + grader rubric |
| Effect gate exists when mutation is possible | pass | Phase 4 의 "ask user for confirmation before updating", Phase 3 "ALWAYS output the quality report BEFORE making any updates" |
| Output contract exists | pass | quality report markdown template + diff template |
| Progressive disclosure is appropriate | pass | quality-criteria, templates 분리 |
| Reusable vs project memory is separated | pass | 평가 rubric 자체는 generic |
| Behavior can be verified | partial | report 출력, gate 준수 여부는 검증 가능. eval 케이스는 본문에 없다. |
| Overlap is intentional | partial | claude-automation-recommender 와 도메인(Claude Code config)이 겹치지만 책임 차이는 자명한 편 |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `SKILL-GUIDE.md §3` | description 이 workflow 를 한 문장으로 요약 | description 후반부 ("Scans for ... targeted updates") 제거 또는 압축 |

### GAP-001: Description summarizes workflow

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §3 Description 작성`, `CONSTITUTION.md §3.1 Activation Must Be Explicit` |

**Expected**

description 은 activation signal 만 담는다. 본문 workflow 요약이 description 에 들어가면 모델이 본문(특히 report-before-mutation gate)을 건너뛰고 description shortcut 만 따를 위험이 있다.

**Actual**

description: "... Scans for all CLAUDE.md files, evaluates quality against templates, outputs quality report, then makes targeted updates. Also use when ..."

이 문장은 Phase 1-4 의 한 줄 요약이다.

**Evidence**

frontmatter line 3.

**Impact**

라우팅에는 큰 문제가 없지만, "outputs quality report, then makes targeted updates" 부분이 본문의 explicit gate (Phase 4 ask for confirmation) 을 약화시킬 수 있다. report 와 update 를 한 호흡으로 인식하면 사용자 승인 없이 Edit 까지 이어질 가능성이 미세하게 높아진다.

**Recommendation**

asset 수정. 예: `Audit and improve CLAUDE.md files in repositories. Use when user asks to check, audit, update, improve, or fix CLAUDE.md files, or mentions "CLAUDE.md maintenance" or "project memory optimization".` workflow summary 문장은 본문 상단으로 옮긴다.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| Edit 권한 보유 | mutation 책임을 지는 자산이며 v2 §3.3 의 gate (report + approval) 가 명확하다 |
| `When NOT to Use` 별도 섹션 없음 | 본문 첫 문단의 "This skill can write to CLAUDE.md files" + Phase 1-5 단계가 scope 를 충분히 좁힌다 |
| body_words ~870 | rubric / report template / diff format / templates 분리 등 실제 산출에 직결 |

---

## 8. Suggested Changes

### Asset Changes

- [ ] description 의 workflow summary 문장 압축 (GAP-001)
- [ ] (선택) Phase 4 의 "ask user for confirmation" 문구를 P0 gate 톤으로 한 줄 강조하면 더 안전 (현재도 충분히 명시되어 있음)

### Guide Changes

None

### Constitution Review

None

---

## 9. Follow-up Questions

- 글로벌 CLAUDE.md (`~/.claude/CLAUDE.md`) 와 같은 user-level 파일을 자동으로 수정할 때 별도 확인 단계가 필요한지에 대한 정책 — Phase 4 의 confirmation 이 글로벌/프로젝트 구분 없이 동일하게 작동하는지 확인.

---

## 10. Final Decision

```text
PASS_WITH_NOTES
```

근거:

- gate 와 output contract 가 v2 §3.3 / §3.4 의 의도와 잘 맞는다.
- 발견된 GAP 은 description shortcut 경향 1건 (P2) 으로 routing 안전성 직접 위험은 없다.
- mutation 권한 보유에도 불구하고 inspect → report → approval → mutate → verify 흐름이 명시되어 있어 P0/P1 위험 없음.
