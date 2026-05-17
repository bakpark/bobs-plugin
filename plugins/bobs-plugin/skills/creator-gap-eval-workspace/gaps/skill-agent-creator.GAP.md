# GAP Report — skill-agent-creator

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2
검토자: GAP 분석 위임 subagent (cwd: bobs-plugin/references)
asset_type: skill
source_path: /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/agent-creator/SKILL.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md
final_decision: PASS_WITH_NOTES
```

분석 대상에는 SKILL.md 본문이 progressive disclosure 로 참조하는 vendored references 포함:

- `skills/agent-creator/references/red-green-refactor.md`
- `skills/agent-creator/references/trigger-eval.md`

Sibling `skill-creator/SKILL.md` 는 형식 정렬 점검용 참고로만 사용. 형식 차이 자체는 finding 근거가 아니다.

---

## 2. Executive Summary

`agent-creator` 는 *agent 작성을 절차로 수행하는 메타 스킬* 이다. 헌법 §3 의 10개 design principle 과 SKILL-GUIDE 의 필수 기능을 대부분 충족한다.

- Activation signal 은 명확하다 — trigger 7개 + negative case 4개 + sibling 이름 명시 (81 단어).
- 부수 효과 (agent `.md` 생성·수정, workspace 디렉토리 생성) 에 대해 §2 의 시점 A/B 두 단계 gate 와 §4b 의 finding 적용 gate 가 명시되어 있다.
- Output contract 는 §5 에 템플릿과 `blocked: needs revision` prefix 규칙으로 정의되어 있다.
- Progressive disclosure 가 작동한다 — 두 vendored reference 가 호출 조건과 함께 path 명시.
- 5 개 sibling 자산과의 overlap 이 명시적으로 분리되어 있다.

영향 있는 ASSET_GAP 은 없다. P3 수준의 정리 후보와 한 건의 AMBIGUITY 가 남는다. 본문 길이 (3688 words / 341 lines) 는 헌법 §3.7 과 SKILL-GUIDE §9 의 "긴 메타/교육형 스킬은 정당화 가능" 에 해당하며 finding 으로 승격하지 않는다.

`Final Decision: PASS_WITH_NOTES`.

---

## 3. Asset Snapshot

```text
name: agent-creator
description: Use when creating, scaffolding, editing, or verifying a Claude Code subagent ... Do NOT use for ... (4 sibling 명시)
description_words: 81
body_words: 3688
body_lines: 341
tools: omitted (frontmatter 에 미명시)
invocation_controls: omitted (disable-model-invocation / user-invocable 미사용)
has_references: yes (red-green-refactor.md, trigger-eval.md)
has_scripts_or_assets: no
has_effect_gate: yes (§2 시점 A/B + §4b)
has_output_contract: yes (§5 템플릿)
```

추가 관찰:

- frontmatter 필드: `name`, `description` 만 사용. agent 전용 필드 (`model`, `color`) 와 skill 전용 invocation control 모두 미사용.
- description 은 multi-language trigger ("create an agent", "에이전트 만들어줘", "draft an agent for X") 포함.
- 본문이 `Read`, `Write`, `Edit`, `Bash` (mkdir, ls), `Agent` (위임) 의 호출을 절차로 지시한다.
- workspace path 는 `<agents_dir>/agent-creator-workspace/gaps/agent-<safe-name>.GAP.md` 로 결정론적으로 정의.

---

## 4. Applicable Criteria

평가 우선순위:

1. `CONSTITUTION.md` §3 (10개 design principle) 및 §2 (원칙 강도)
2. `SKILL-GUIDE.md` §2 (Frontmatter), §3 (Description), §4 (Body), §5 (Effects And Gates), §6 (Progressive Disclosure), §7 (Output Contract), §8 (Verification), §9 (Quantitative Heuristics), §10 (Checklist), §11 (Anti-Patterns)
3. `GAP-FORMAT.md` §11.1 (Skill Snapshot), §12.1 (Skill Checks)

본문이 agent 를 다루지만 자산 자체는 *skill* 이므로 SKILL-GUIDE 만 적용. AGENT-GUIDE 는 평가 기준이 아니다 (본문이 인용하는 reference 일 뿐).

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | trigger 7개 + sibling 4개 negative case + multi-language. |
| Description avoids workflow shortcut | pass | 본문 절차 (Phase 0–6) 를 description 이 요약하지 않음. 81 단어 안에 trigger 와 negative case 만. |
| Scope or near-miss is clear when needed | pass | `When NOT to use` 섹션에 4개 sibling 의 책임 차이 명시. |
| Workflow is actionable | pass | §0–§6 의 phase 가 "먼저 읽는다" `Read` 지시, gate 시점, 산출 path 까지 실행 가능한 형태. |
| Effect gate exists when mutation is possible | pass | §2 시점 A (5 항목 제시 + 명시 신호), 시점 B (변경 요약 제시 + 명시 신호), §4b (finding 적용에도 gate 적용 — gate 우회 금지 명문화). |
| Output contract exists | pass | §5 의 8-line 응답 템플릿 + `blocked: needs revision` prefix + GAP report 경로 회신 정책. |
| Progressive disclosure is appropriate | pass | vendored reference 가 §When the loop stalls (`red-green-refactor.md`) 와 §Description optimization (`trigger-eval.md`) 에서 path + 호출 조건과 함께 명시. SKILL-GUIDE §6 충족. |
| Reusable vs project memory is separated | pass | plugin 배포 자산. 프로젝트 고유 path/명령/규칙 하드코딩 없음. `${CLAUDE_PLUGIN_ROOT}` 와 fallback 으로 환경 종속 분리. |
| Behavior can be verified | partial | §When the loop stalls 와 RED-GREEN-REFACTOR reference 로 verification 경로 제공. 다만 §Limits 에서 "behavior verification 은 본 스킬의 의무가 아니라 선택" 으로 명시 — 메타 스킬의 자가 검증 trigger eval 케이스는 본문에 없음. 자산 목적상 의도된 경계로 판단. |
| Overlap is intentional | pass | 5 개 sibling (`writing-agents`, `writing-skills`, `skill-creator`, `agent-skill-designer`, `agent-skill-auditor`, `codex-reviewer`, `pr-review-toolkit`) 의 책임 차이 명시. sibling `skill-creator` 와의 의도된 형식 정렬도 §본문 두 번째 단락에서 밝힘. |

---

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | AMBIGUITY | P3 | `SKILL-GUIDE.md §2 Frontmatter` | `tools:` 생략 vs 본문이 Write/Edit/Bash/Agent 호출 — capability surface 의 frontmatter 표현 부재 | asset 수정 검토 (선택) |
| GAP-002 | ASSET_GAP | P3 | `SKILL-GUIDE.md §6 Progressive Disclosure` | §3b 위임 prompt 의 verbatim 복사 지시가 placeholder 만으로 표현됨 | asset 수정 검토 (선택) |

### GAP-001: frontmatter `tools` 미명시와 본문 capability 의 표현 차이

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §2 Frontmatter`, `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility` |

**Expected**

SKILL-GUIDE §2 는 `tools` 를 필수 필드로 두지 않는다. 다만 "read-only 나 mutation 제한이 중요하면 명시하는 편이 낫다" 라고 권장한다. 자산이 mutation 을 수행하면 capability surface 가 frontmatter 또는 본문 어딘가에 명시적으로 드러나야 한다.

**Actual**

frontmatter 에는 `name`, `description` 만 있다. 본문 §2, §3a, §3b, §4 에서 `Read`, `Write`, `Edit`, `Bash` (mkdir, ls), `Agent` (general-purpose subagent dispatch) 의 호출이 절차로 지시되어 있다.

**Evidence**

- frontmatter (SKILL.md L1–L5) — `name`, `description` 만.
- 본문 L48 `Read ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md` (반복 등장).
- 본문 L88–L92 `ls ~/.claude/agents/ ...` (Bash).
- 본문 L162–L168 `mkdir -p "$WORKSPACE/gaps"` (Bash).
- 본문 L176 "현재 환경의 *subagent dispatch 도구* 를 사용한다. Claude Code 환경에서는 `Agent` 도구".
- 본문 §2 "본 스킬은 파일 시스템에 agent `.md` 와 workspace 디렉토리를 *생성·수정* 한다."

**Impact**

라우팅·안전·산출 신뢰성에 *직접* 영향은 없다 — §2 의 시점 A/B gate 가 부수 효과 책임을 짊어진다. 다만 카탈로그 단계에서 호출자가 metadata 만 보고 capability 를 판단할 때 신호가 약하다. 형식 안티 패턴이라기보다 "더 좋으면 좋을" 수준의 정리 후보. sibling `skill-creator` 도 동일 패턴이라 일관성은 유지된다 (양쪽 모두 finding 후보).

**Recommendation**

asset 수정 검토 (선택). 두 가지 방향이 가능:

1. frontmatter 에 `tools: Read, Write, Edit, Bash, Agent` 를 명시 — capability surface 가 metadata 에 노출됨.
2. 본문 상단 ("이 스킬은 …") 에 한 줄로 "본 스킬은 Read, Write, Edit, Bash, Agent (general-purpose dispatch) 를 사용한다" 를 추가 — frontmatter 는 손대지 않고 본문에서 명시.

sibling skill-creator 와의 일관성을 유지한 채 둘 다 같은 방향으로 정리하는 것이 권장된다. 단독 수정 후 sibling 만 미정리 상태로 두면 형식 정렬 의도와 충돌.

---

### GAP-002: GAP-ANALYSIS-PROMPT 의 verbatim 복사 지시가 placeholder 만으로 표현됨

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §6 Progressive Disclosure`, `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context` |

**Expected**

위임 prompt 가 *verbatim* 으로 한 외부 문서 (`GAP-ANALYSIS-PROMPT.md`) 의 8 개 섹션을 복사해야 한다면, 본문은 (a) 그 복사 책임을 명확히 하고 (b) 어떤 섹션을 어떤 순서로 복사하는지 list 하거나, (c) 위임 prompt 의 완전한 sample 을 reference 로 분리해야 한다. progressive disclosure 의 목적은 호출자가 actionable 한 상태를 알게 하는 것이다.

**Actual**

본문 §3b 에서 dispatch prompt 예시 안에 placeholder 만 둠:

```
[이하 GAP-ANALYSIS-PROMPT.md 의 §"판정 원칙" / §"원칙 강도" / §"Finding 유형" /
 §"Severity" / §"Agent 점검 축" / §"Evidence 작성 규칙" / §"리포트 구조" /
 §"최종 결정" / §"완료 보고" 섹션 verbatim 으로 복사]
```

호출 시점에 main session 이 GAP-ANALYSIS-PROMPT.md 를 읽어 9 개 섹션을 직접 복사해 dispatch payload 를 만들어야 한다.

**Evidence**

- SKILL.md L182–L208 의 dispatch 예시.
- `references/GAP-ANALYSIS-PROMPT.md` 가 실제로 위 9 개 heading 을 가짐 (Skill 점검 축 / Agent 점검 축 / Hook 점검 축 별도 — 본 스킬 본문은 "Agent 점검 축" 만 인용).

**Impact**

산출 신뢰성에 약한 영향. 9 개 섹션 verbatim 복사는 의도가 분명하나 main session 의 in-context 작업이 늘고, 누락·순서 변경 가능성이 존재한다. 다만 (a) GAP-FORMAT §17 의 self-check 와 (b) §3d 의 8개 self-check 가 안전망 역할을 하므로 가벼운 정리 신호. sibling `skill-creator` 도 동일 패턴.

**Recommendation**

asset 수정 검토 (선택). 두 가지 방향:

1. 위임 prompt 의 *완전한 sample* 을 vendored reference 로 추가 (예: `skills/agent-creator/references/delegated-prompt-template.md`) — main session 은 그 파일을 그대로 dispatch payload 로 전달.
2. 본문 §3b 의 placeholder 를 "main session 은 `Read references/GAP-ANALYSIS-PROMPT.md` 후 9 개 heading 의 본문을 순서대로 복사해 ` ``` ` 블록에 끼운다" 형식의 한 줄 절차로 명시 — 책임을 main session 에 더 명확히 부여.

sibling 과의 일관성 유지를 위해 양쪽에 동일 수정을 권장.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| 본문 길이 3688 words / 341 lines | SKILL-GUIDE §9 의 "긴 메타/교육형 스킬은 eval, reference, verification 구조가 있으면 길 수 있다" 에 해당. 6 phase (§0–§6) + Reference Loading Schedule + In-flight escape hatches + Mini example + When the loop stalls + Description optimization + Limits 가 모두 메타 스킬의 정당한 구조. 핵심 workflow 가 phase heading 으로 빠르게 찾을 수 있다. |
| Multi-language description (영어 + 한국어 trigger) | SKILL-GUIDE §3 의 "검색될 단어가 있는가?" 충족. trigger 는 사용자가 실제 입력할 발화이므로 다국어가 의도적. 본문은 한국어 단일 언어로 유지됨 (terminology pass §6 가 명시). |
| 본문이 `writing-agents` reference 의 두 섹션을 vendored 형태로 가져옴 (`references/red-green-refactor.md`, `trigger-eval.md`) | 두 reference 의 출처와 vendored 이유가 각 파일 첫 줄에 명시. plugin 배포 시 self-contained 보장. |
| frontmatter 에 `disable-model-invocation` / `user-invocable` 미사용 | 자산이 mutation 을 하지만 §2 의 in-skill gate 로 부수 효과를 통제. 자동 호출 차단까지는 과한 설계. 모델이 호출해도 시점 A 에서 사용자 승인 게이트가 작동. |
| `tools:` 미명시 (GAP-001 참조) | hard rule 아님. sibling 과 일관됨. 본문 gate 로 capability 통제. |

---

## 8. Suggested Changes

### Asset Changes

- [ ] (P3, 선택) GAP-001: frontmatter `tools` 명시 또는 본문 capability surface 한 줄 추가. sibling `skill-creator` 와 동시 정리 권장.
- [ ] (P3, 선택) GAP-002: 위임 prompt 의 verbatim 본문을 vendored reference 로 분리하거나, 복사 책임을 명시한 한 줄 절차로 본문에 추가.

### Guide Changes

None.

### Constitution Review

None.

---

## 9. Follow-up Questions

- None — 두 finding 모두 자산 수정으로 해결 가능하며 추가 사용자 입력 불필요.

---

## 10. Final Decision

**`PASS_WITH_NOTES`**

근거:

- 영향 있는 ASSET_GAP 없음 (P0/P1/P2 = 0).
- P3 수준 정리 후보 2개 + acceptable deviation 5개.
- 헌법 §3 의 10개 design principle 과 SKILL-GUIDE 의 필수 기능을 모두 충족.
- 부수 효과에 대한 gate, output contract, progressive disclosure, overlap 분리가 모두 명시적.
- 메타 스킬의 길이 정당화 가능, sibling `skill-creator` 와 의도적 형식 정렬 유지.
- GAP-001, GAP-002 는 sibling 과 동시 정리 시 잘 정리되는 후보. 단독 수정은 형식 정렬 의도와 충돌하므로 *옵션* 으로 둠.
