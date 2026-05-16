# GAP 리포트: skill-creator

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2
검토자: gap-analysis subagent (general-purpose), round 4
asset_type: skill
source_path: /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator/SKILL.md
references_assessed:
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator/references/red-green-refactor.md
  - /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/skill-creator/references/trigger-eval.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md
round: 4
prior_round_decision: PASS_WITH_NOTES (round 1), PASS_WITH_NOTES (round 2), PASS_WITH_NOTES (round 3)
final_decision: PASS
```

## 2. Executive Summary

`skill-creator` round 3. round 2 에서 식별된 3 건 (GAP-005 mutation gate 시점 확장 · GAP-006 500 lines hard threshold 완화 · GAP-007 cwd resolve 책임) 은 모두 자산 수정으로 해소됐다. 구체 확인:

- **GAP-005 RESOLVED**: §2 의 단일 "첫 Write 전" gate 가 "시점 A — 첫 Write 전 (§2 본문 작성)" + "시점 B — §4 refine Edit 전 (round 2+)" 두 시점 모두 cover 하는 구조로 확장됨. round 2+ Edit 가 동일 confirm gate 안에 들어감.
- **GAP-006 RESOLVED**: §2 핵심 원칙 요약의 "본문 ≤ 500 lines" hard threshold 가 "SKILL-GUIDE §9 의 heuristic 으로 ≤ 500 lines 가 검토 신호. 초과 시 `references/` 분리를 검토 (hard limit 아님 — 메타 스킬은 정당화 가능)" 로 풀어쓰임. heuristic → hard rule 전파 위험 제거.
- **GAP-007 RESOLVED**: §3b 에 "**경로 resolve 책임** — 위임 prompt 의 cwd 필드는 main session 이 *절대 경로* 로 채워서 보낸다 ... subagent 는 resolved path 만 보며, 환경 변수 확장이나 fallback 판단을 하지 않는다." 단락 추가. main / subagent 사이 portability 책임 분리 명시.

round 3 신규 finding 은 2건으로 모두 P2-P3 범위. round 2 fix 자체는 견고하나 부산물:

- §4b "Finding 적용 순서" 가 P1 을 "적용 의무", P2 를 "기본 적용 권장" 으로 표기 — §2 시점 B 의 "명시적 신호를 줄 때만 수정" 과 명목상 긴장. 모델이 §4b 만 따르면 시점 B gate 를 우회할 수 있는 표현 충돌 (P2)
- §3b Claude Code 예시 블록의 prompt cwd 라인이 여전히 `${CLAUDE_PLUGIN_ROOT}/references` 변수 표기 — round 2 추가된 "경로 resolve 책임" 단락은 main session 이 절대 경로로 변환해 보낸다고 명시했으나 예시는 변환 후 형태가 아님. 사용자가 예시 복사 시 변환 누락 위험 (P3)

이전 라운드에서 acceptable 로 분류된 body 길이 (현재 289 lines / ~2331 words), description 길이 (~73 words), 외부 권위 문서 4종 phase 별 로드는 round 3 에서도 동일하게 acceptable.

3 라운드 누적 평가: round 1 → round 2 에서 라우팅·portability·도구 추상화·mutation gate 기초가 잡혔고, round 2 → round 3 에서 mutation gate 가 두 시점으로 확장되고 heuristic 톤이 정리됐다. round 3 신규 finding 은 round 2 fix 의 *마무리 다듬기* 영역으로 자산 목적·원칙 충족 상태에 영향 없음. 다이미닝 리턴이 명확히 보이는 라운드.

### 2.4 Round 4 평가

`skill-creator` round 4. round 3 의 2 finding (GAP-008 §4b "적용 의무" vs 시점 B gate 명목적 긴장, GAP-009 §3b 예시 cwd placeholder) 은 모두 자산 수정으로 해소됐다.

- **GAP-008 RESOLVED**: §4b 머리말 (line 231) 에 "**각 finding 의 적용은 §2 의 시점 B gate (변경 요약 제시 → 사용자 명시 신호 → 수정) 를 거친다.** 아래 순위는 *어떤 finding 을 먼저 처리할지* 의 우선순위이며, gate 자체를 우회하지 않는다 — '적용 의무' 는 *순위가 높다* 는 뜻이지 *gate 생략* 의 뜻이 아니다." 명시. CONSTITUTION §3.3 + §3.8 충돌 해소.
- **GAP-009 RESOLVED**: §3b 예시 헤더 (line 162) 가 "Claude Code 예시 (dispatch 시 `<RESOLVED_REFS_DIR>` 는 main session 이 실제 절대 경로로 치환)" 로 변경되고, 예시 본문 cwd (line 169) 가 `<RESOLVED_REFS_DIR>` placeholder 로 치환됨. 책임 분리 단락 (line 160) 과 예시 일관성 확보.

round 3 이후 적용된 추가 변경 4종의 영향:

- **용어·톤 통일**: GAP analysis → GAP 분석, redirect → 전환, intent 질문 한국어화, "이식성 주의" 단락 분리 등. 본문 표현 정리만으로 라우팅·안전·산출 contract 영향 없음. 단순 품질 개선.
- **외부 의존 내재화 (writing-skills runtime 호출 제거)**: §2 본문 (line 117-121) 에 CSO / Iron Law / 함정 9종 inline 요약. RED-GREEN-REFACTOR 와 trigger eval 절차를 `skill-creator/references/` 아래로 vendor 해 link. 영향: (1) writing-skills 미설치 환경에서도 본 스킬이 self-contained 로 작동, (2) progressive disclosure 강화 (선택 참조), (3) 라이선스 attribution 적절 (MIT 출처 명시). 긍정적.
- **§6 Terminology and tone pass 추가**: 응답 직전 SKILL.md 표현 통일 단계. 신규 mutation 시점이나 §6 본문이 (1) 의미 변경 금지 (line 272), (2) 의미가 바뀌면 §3 GAP 분석으로 escape (line 292) 두 안전망을 둠. 호출자가 명시 호출한 흐름의 마지막 정리 단계로 CONSTITUTION §3.3 "approval or explicit invocation" 안에 cover 됨. 명목적 일관성 영역의 잠재 모호함 있으나 4 라운드 누적 후 다이미닝 리턴 영역이고, §6 자체에 안전망이 닫혀 있어 finding 미생성.
- **description intent 질문 6개 한국어화**: 표 구조 유지. description 자체 (frontmatter line 4) 는 영/한 trigger 다국어 그대로. 라우팅 영향 없음.

round 4 신규 finding 은 **0건**. round 3 의 GAP-008/009 마무리 + 외부 의존 내재화 + §6 표현 통일 pass 까지 적용된 결과, 라우팅·safety·output contract·capability surface·progressive disclosure·overlap 모든 축에서 영향 있는 차이가 보고되지 않음.

4 라운드 누적 수렴: round 1 (4 finding, P2-P3) → round 2 (3 finding, P2-P3) → round 3 (2 finding, P2-P3) → round 4 (0 finding). finding 수 단조 감소 + severity 단조 비증가. P0/P1 단 한 번도 출현하지 않음. 본 자산은 **PASS 동결 상태**.

## 3. Asset Snapshot

```text
name: skill-creator
description: Use when creating, scaffolding, editing, or verifying a Claude Code skill (`SKILL.md` under `skills/<name>/`). Triggers on "create a skill", "스킬 만들어줘", "skill 작성·개선", "/skill-name 만들어줘", "draft a skill for X" — including when the user has not yet chosen a name or scope. Do NOT use for writing subagents (`writing-agents`), agent-vs-skill / merge / migration-order decisions (`agent-skill-designer`), static rule audit of an existing skill (`agent-skill-auditor`), or PR/code edits.
description_words: ~73
description_chars: ~552
body_words: ~2331
body_lines: 289 (frontmatter 5 라인 포함; 본문만 ~284)
tools: omitted
invocation_controls: 없음 (model 은 agent-only 필드라 부재가 정상; disable-model-invocation/user-invocable 부재 — mutation gate 가 본문 시점 A/B 로 대체)
has_references: `${CLAUDE_PLUGIN_ROOT}/references/` (CONSTITUTION / SKILL-GUIDE / GAP-FORMAT / GAP-ANALYSIS-PROMPT) phase 별 로드 + `../../references/` fallback + 둘 다 실패 시 사용자 보고·종료
has_scripts_or_assets: SKILL.md 단일 — 워크스페이스는 호출 시 생성
has_effect_gate: yes (§2 시점 A 첫 Write + 시점 B refine Edit 양쪽 cover)
has_output_contract: yes (§5 Output to caller 7-필드 템플릿)
```

round 2 → round 3 snapshot delta:
- body_lines 278 → 284 (mutation gate 시점 A/B 분기 + 경로 resolve 책임 단락 + heuristic 톤 풀어쓰기 효과).
- has_effect_gate: yes (시점 A 한정) → yes (시점 A + 시점 B 양 시점 cover).
- has_references: portability "이식성 주의" 단락 유지 + §3b 경로 resolve 책임 단락 추가로 main/subagent 비대칭 일부 해소.
- description / frontmatter / tools 변동 없음.

round 3 → round 4 snapshot delta:
- body_lines 284 → 327 (+43 line). 증가분 내역: §6 Terminology and tone pass 신설 (~28 lines, line 268-294) + §2 inline writing-skills 요약 (~5 lines, line 117-121) + 용어·톤 통일에 따른 문장 분리 (~10 lines 정도, 산발).
- body_words ~2331 → ~2886 (+555 words). 주 증가분도 §6 신설과 inline 요약.
- has_references: SKILL.md 단일에서 `skill-creator/references/` 하위에 vendored 2종 추가 — `red-green-refactor.md` (64 lines, writing-skills 의 RED-GREEN-REFACTOR / pressure scenario 절차 self-contained), `trigger-eval.md` (74 lines, CSO 원칙 + trigger eval 4-step 절차 self-contained). 출처 attribution + MIT license 1줄.
- has_effect_gate: yes (시점 A + 시점 B). §6 의 표현 수정은 (1) 의미 변경 금지 + (2) 의미 바뀌면 §3 으로 escape 두 안전망으로 cover. 신규 gate 시점 추가는 아님.
- has_output_contract: 변동 없음 (§5 7-필드 템플릿). §6 자체는 응답 송신 직전 표현 통일이므로 별도 output 없음 — 의도된 설계.
- description / frontmatter / tools 변동 없음.
- 외부 의존 변동: `Skill(writing-skills)` runtime 호출 제거 → writing-skills 미설치 환경에서도 self-contained 로 작동 가능.

## 4. Applicable Criteria

- `CONSTITUTION.md §3.1` Activation Must Be Explicit
- `CONSTITUTION.md §3.3` Effects Require Gates
- `CONSTITUTION.md §3.4` Output Is A Contract
- `CONSTITUTION.md §3.5` Capability Surface Must Match Responsibility
- `CONSTITUTION.md §3.6` Reusable Knowledge And Local Memory Must Stay Separate
- `CONSTITUTION.md §3.7` Progressive Disclosure Protects Context
- `CONSTITUTION.md §3.8` Strong Language Belongs To Real Gates
- `CONSTITUTION.md §3.9` Behavior Must Be Verifiable
- `CONSTITUTION.md §3.10` Overlap Must Be Intentional
- `SKILL-GUIDE.md §2` Frontmatter
- `SKILL-GUIDE.md §3` Description 작성
- `SKILL-GUIDE.md §5` Effects And Gates
- `SKILL-GUIDE.md §7` Output Contract
- `SKILL-GUIDE.md §9` Quantitative Heuristics
- `SKILL-GUIDE.md §11` Anti-Patterns

## 5. Checks

| Check | Status (r3) | Status (r4) | Notes (r4) |
|---|---|---|---|
| Activation signal is clear | pass | pass | trigger 다국어 5종 + sibling redirect 4개 + "When NOT to use" 섹션. 변동 없음 |
| Description avoids workflow shortcut | pass | pass | round 1 fix 유지. description body 절차 요약 없음 |
| Scope or near-miss is clear when needed | pass | pass | frontmatter Do NOT + 본문 "When NOT to use" 이중 명시 |
| Workflow is actionable | pass | pass | §0–§6 phase 별 명령·읽을 문서·산출 경로 + mini example + stall recovery. §6 추가됨 |
| Effect gate exists when mutation is possible | pass (단 §4b 표현 충돌) | pass | round 3 의 GAP-008 fix 로 §4b 머리말에 "각 finding 의 적용은 §2 의 시점 B gate 를 거친다 ... '적용 의무' 는 *순위가 높다* 는 뜻이지 *gate 생략* 의 뜻이 아니다" 명시. §6 표현 수정은 의미 변경 금지 + §3 escape 안전망으로 cover |
| Output contract exists | pass | pass | §5 7-필드 템플릿 + `blocked: needs revision` prefix + GAP report 경로 인용 |
| Progressive disclosure is appropriate | pass | pass | phase 별 Read 지시 + 권위 문서 본문 외부 유지 + fallback. round 4 에서 `references/red-green-refactor.md`, `references/trigger-eval.md` 분리로 §When loop stalls / §Description optimization 의 절차가 선택 참조로 옮겨감 |
| Reusable vs project memory is separated | pass | pass | fallback 유지. plugin 외부 미존재 시 종료 동작 명시. writing-skills 의존 내재화로 reusable 자산성 강화 (외부 패키지 의존 제거) |
| Behavior can be verified | pass | pass | self-feedback loop + §3d self-check 8개 + §4c round limit + mini example trace. round 4 에서 RED-GREEN-REFACTOR 절차가 references 로 self-contained 되어 pressure scenario 검증 절차가 본 스킬 안에서 닫힘 |
| Overlap is intentional | pass | pass | writing-skills / writing-agents / agent-skill-designer / agent-skill-auditor / codex-reviewer / pr-review-toolkit 차이 명시. writing-skills 와의 관계는 runtime 호출이 아닌 *vendored reference* 로 변경되어 overlap 가 더 명확 |

## 6. Findings

### 6.1 Round 1 & Round 2 & Round 3 Findings Status

| ID | Title | Severity | Status (round 4) | Evidence |
|---|---|---|---|---|
| GAP-001 | description workflow shortcut | P2 (r1) | RESOLVED (r2) | description 본문에 phase 시퀀스 없음 |
| GAP-002 | mutation 명시 confirm gate 부재 | P2 (r1) | RESOLVED (r2) → 일반화 RESOLVED (r3) | §2 시점 A (r2) + 시점 B (r3) 모두 유지 |
| GAP-003 | subagent 디스패치 도구명 단정 | P3 (r1) | RESOLVED (r2) | §3b "현재 환경의 *subagent dispatch 도구*..." 추상화 유지 |
| GAP-004 | reference 경로 portability | P3 (r1) | RESOLVED (r2) | "이식성 주의" 단락 + fallback 유지 (round 4 에서 3 문장으로 분리되어 가독성 개선) |
| GAP-005 | re-GAP round mutation gate 미커버 | P2 (r2) | RESOLVED (r3) | §2 시점 A + 시점 B 양 시점 cover. round 4 에서도 유지 |
| GAP-006 | 500 lines hard threshold | P3 (r2) | RESOLVED (r3) | §2 의 heuristic 톤 풀어쓰기 유지 |
| GAP-007 | §3b 위임 prompt portability 비대칭 | P3 (r2) | RESOLVED (r3) | §3b 경로 resolve 책임 단락 유지 |
| GAP-008 | §4b "적용 의무" vs §2 시점 B gate 명목적 긴장 | P2 (r3) | **RESOLVED (r4)** | §4b 머리말 line 231: "**각 finding 의 적용은 §2 의 시점 B gate (변경 요약 제시 → 사용자 명시 신호 → 수정) 를 거친다.** 아래 순위는 *어떤 finding 을 먼저 처리할지* 의 우선순위이며, gate 자체를 우회하지 않는다 — '적용 의무' 는 *순위가 높다* 는 뜻이지 *gate 생략* 의 뜻이 아니다." 명시 |
| GAP-009 | §3b 예시 cwd placeholder 화 | P3 (r3) | **RESOLVED (r4)** | §3b line 162 헤더 "(dispatch 시 `<RESOLVED_REFS_DIR>` 는 main session 이 실제 절대 경로로 치환)" + line 169 cwd 가 `<RESOLVED_REFS_DIR>` placeholder 로 변경됨 |

### 6.2 Round 4 Findings (신규)

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|

신규 finding **없음** (0건). round 3 의 2 finding 이 자산 수정으로 해소됐고, round 3 이후 적용된 4종 추가 변경 (용어·톤 통일 / writing-skills 의존 내재화 / §6 Terminology and tone pass 추가 / description intent 질문 한국어화) 은 모두 다음 중 하나에 해당:

- 라우팅·safety·output contract·capability surface 어떤 축에도 부정 영향 없음
- 또는 영향이 *긍정적* (외부 의존 제거, progressive disclosure 강화)
- 또는 명목적 명확성 영역이지만 본문에 안전망 (§6 의 의미 변경 금지 + §3 escape) 이 닫혀 있어 영향 약함

4 라운드 누적 자기 검증 후 다이미닝 리턴 영역. 추정 영향만으로 finding 을 만들지 않는 GAP-FORMAT §4 의 보수 원칙 적용.

### 6.3 Round 3 Findings (참고용, RESOLVED)

| ID | Type | Severity | Guide Ref | Summary | Recommendation | Round 4 status |
|---|---|---|---|---|---|---|
| GAP-008 | ASSET_GAP | P2 | `CONSTITUTION.md §3.3` + `CONSTITUTION.md §3.8` | §4b Finding 적용 순서에서 P1 "적용 의무", P2 "기본 적용 권장" 표현이 §2 시점 B "사용자가 명시적 신호를 줄 때만 파일을 수정한다" 와 명목적 긴장. 모델이 §4b 만 따르면 시점 B gate 우회 가능 | §4b 머리말 또는 각 항목 끝에 "단 §2 시점 B gate 적용 — 변경 요약 제시 후 명시적 신호 수신 시 적용" 한 줄 명시 | RESOLVED — §4b 머리말 line 231 에 명시. evidence 는 §6.1 표 참조 |
| GAP-009 | ASSET_GAP | P3 | `CONSTITUTION.md §3.7` Progressive Disclosure | §3b 경로 resolve 책임 단락은 main 이 절대 경로로 변환해 보낸다고 명시. 그러나 그 아래 Claude Code 예시 블록의 prompt cwd 는 여전히 `${CLAUDE_PLUGIN_ROOT}/references` 변수 표기 | 예시 블록의 cwd 라인을 placeholder (`<REFERENCES_ABS_PATH>`) 로 바꾸거나 예시 위에 메타 주석 추가 | RESOLVED — §3b 헤더 line 162 + cwd line 169 가 `<RESOLVED_REFS_DIR>` placeholder 로 변경됨 |

상세 형식 (round 3 시점 원본 — round 4 에서 모두 RESOLVED):

### GAP-008: §4b "적용 의무" 와 §2 시점 B confirm gate 사이 명목적 긴장 [RESOLVED in round 4]

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.3 Effects Require Gates` + `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates` |

**Expected**

CONSTITUTION §3.3 의 흐름은 inspect → report/proposal → approval or explicit invocation → mutate → verify. round 2 fix 로 §2 가 "시점 A — 첫 Write 전" + "시점 B — §4 refine Edit 전 (round 2+): 적용할 finding 의 short title 과 변경 요약 ... 명시적 신호를 줄 때만 파일을 ... 수정한다" 양쪽에 confirm gate 를 둔다. 따라서 §4 의 finding 적용 절차도 같은 gate 안에서 작동해야 한다. §3.8 도 강한 표현 ("의무") 은 실제 gate 에 쓰라고 명시 — gate 와 충돌하는 자리에 강한 표현이 오면 우선순위가 흐려진다.

**Actual**

§4b Finding 적용 순서 (line 222-228):

```
1. **P0 first** — 즉시 수정 (안전 / 데이터 / destructive).
2. **P1** — 라우팅 / 권한 / 부수 효과 / 산출 신뢰성. 적용 의무.
3. **P2** — 품질·반복 비용. 사용자 위임 가능 (기본 적용 권장).
4. **P3** — 일반적으로 무시. cleanup 권장만 보고.
```

"적용 의무" / "즉시 수정" / "기본 적용 권장" 은 자동 적용 톤이다. §2 시점 B 의 "명시적 신호를 줄 때만 파일을 ... 수정한다" 와 표현 충돌. §4b 내부에는 시점 B gate 인용이 없고, §4 머리말도 confirm step 을 두지 않는다. line 228 의 "evidence 가 약하거나 `AMBIGUITY` 면 사용자 확인 후 진행" 은 ambiguity 한정 — P1/P2 의 일반 적용은 confirm 없이 진행되는 것으로 읽힐 수 있다.

**Evidence**

- SKILL.md §2 line 105: `**시점 B — §4 refine Edit 전 (round 2+)**: 적용할 finding 의 short title 과 *변경 요약* ... 을 사용자에게 제시한다.`
- SKILL.md §2 line 107: `각 시점에서 사용자가 "진행" / "go" / "proceed" 같은 명시적 신호를 줄 때만 파일을 쓰거나 수정한다.`
- SKILL.md §4b line 224: `**P1** — 라우팅 / 권한 / 부수 효과 / 산출 신뢰성. 적용 의무.`
- §4b 내부에 §2 gate 인용 없음.

**Impact**

mutation 가능 자동 호출 메타 스킬의 round 2+ refine 에서, 모델이 §4b 의 "적용 의무" 표현을 따라 P1 finding 을 confirm 없이 적용할 수 있다. §2 시점 B 가 같은 자산에 명시 confirm 을 요구하므로 두 지시 중 어느 것이 우선인지 불명. 라운드 2 fix 의 핵심 — round 2+ silent edit 방지 — 가 §4b 의 강한 표현에 의해 부분적으로 약화될 위험. 산출 신뢰성과 mutation 사용자 통제력에 직접 영향이므로 P2.

**Recommendation**

자산 수정 (소). 다음 둘 중 하나 또는 병행:

1. §4b 머리말에 1줄 추가: "P0–P3 모두 §2 시점 B gate 를 통과한 뒤 적용. '적용 의무' 는 우선순위 표현이지 confirm 면제가 아니다."
2. 또는 각 항목 끝에 "(§2 시점 B 적용)" 마커.
3. 또는 §2 시점 B 단락에 보조 문장 추가: "§4b 의 P0/P1 '의무' 표현은 우선순위 표현이며, 본 시점 B gate 의 명시 신호 요구를 면제하지 않는다."

(보수적 권장: 1 + 3 병행. 자동 호출 가능 메타 스킬의 mutation gate 일관성은 강한 표현 충돌만으로도 사고를 만든다.)

### GAP-009: §3b Claude Code 예시 블록의 cwd 가 절대 경로 변환 후 형태가 아님 [RESOLVED in round 4]

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context` + `SKILL-GUIDE.md §6` Progressive Disclosure |

**Expected**

round 2 fix 로 §3b 에 "**경로 resolve 책임** — 위임 prompt 의 cwd 필드는 main session 이 *절대 경로* 로 채워서 보낸다 ... subagent 는 resolved path 만 보며, 환경 변수 확장이나 fallback 판단을 하지 않는다." 단락 추가됨 (line 152). 따라서 그 아래 예시 블록도 "변환 후" 형태를 보여야 한다 — placeholder 또는 절대 경로 자리. 예시가 변환 전 변수 표기로 남으면 사용자/모델이 예시를 그대로 복사할 때 main session 의 변환 책임이 누락된다.

**Actual**

§3b Claude Code 예시 (line 161):

```
prompt:
  ---
  현재 작업 디렉토리는 ${CLAUDE_PLUGIN_ROOT}/references 이다.
```

`${CLAUDE_PLUGIN_ROOT}/references` 변수 표기. line 152 의 책임 분리 ("subagent 는 resolved path 만 보며") 와 직접 모순. 예시 위에 "main session 이 변환한 뒤 dispatch 한다" 같은 메타 주석도 없다.

**Evidence**

- SKILL.md §3b line 152: `**경로 resolve 책임** — 위임 prompt 의 cwd 필드는 main session 이 *절대 경로* 로 채워서 보낸다 ... subagent 는 resolved path 만 보며, 환경 변수 확장이나 fallback 판단을 하지 않는다.`
- SKILL.md §3b line 161: `현재 작업 디렉토리는 ${CLAUDE_PLUGIN_ROOT}/references 이다.`

**Impact**

문서 일관성 영역. 사고 시나리오: 사용자가 §3b 예시만 보고 prompt 를 복사하면 변수 형태가 그대로 subagent 에 전달되고, subagent 의 환경에서 `${CLAUDE_PLUGIN_ROOT}` 이 expand 되지 않으면 cwd resolve 실패. 단 line 152 의 책임 단락이 main session 의 변환 책임을 명시하므로 모델이 그 단락을 읽으면 변환이 일어난다 — 실제 영향은 약함. P3.

**Recommendation**

자산 수정 (소). 다음 중 하나:

1. 예시의 cwd 라인을 placeholder 로 변경: `현재 작업 디렉토리는 <REFERENCES_ABS_PATH> 이다.` 또는 `현재 작업 디렉토리는 /absolute/path/to/references 이다.`
2. 예시 블록 위에 1줄: "(아래 prompt 의 cwd 는 main session 이 line 152 의 책임에 따라 절대 경로로 치환한 뒤 dispatch 한다.)"
3. 또는 변수 표기 옆에 "// main session 이 절대 경로로 치환" 주석 inline.

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| Body ~2886 words / 327 lines (SKILL-GUIDE §9 의 "150–200 words" heuristic 초과) | procedural meta skill — phase 별 reference loading schedule, escape hatches, GAP loop control, mini example, stall recovery, §6 표현 통일 pass 모두 본문에서 실행 가능해야 함. §9 가 "긴 메타/교육형 스킬은 eval, reference, verification 구조가 있으면 길 수 있다" 로 명시. round 4 에서 §6 추가로 +43 line 늘었으나 외부 의존 내재화 (CSO·Iron Law·함정 9종 inline 요약) 가 portability 를 강화한 trade-off — body 길이 증가가 self-containment 가치에 직접 기여 |
| Description ~73 words / ~552 chars (heuristic 15–60 words 초과) | trigger 다국어 (영/한), 5개 trigger phrase, 4개 sibling redirect 를 한 description 에 압축. round 1 → round 2 에서 phase 골자 제거로 단축 완료. 추가 압축은 trigger / redirect 누락 위험 |
| Output contract 가 별도 `Output Format` 섹션이 아니라 §5 phase 안에 embedded | GAP-FORMAT §11 snapshot 메모 "has_output_contract 는 제목이 아니라 기능 기준" |
| `tools` 필드 미명시 | platform default 단정 회피 + mutation gate 가 본문 시점 A/B 로 cover 되어 frontmatter 보강 필요성 낮음 |
| 외부 권위 문서 4개를 phase 별로 매번 Read | reusable 메타 스킬의 progressive disclosure 자체. §Reference Loading Schedule 의 명시적 설계 의도 |
| description 본문에 "agent-skill-best-practices 기준 문서" 표현 (line 9) | "agent-skill-best-practices" 는 기준 문서 *세트의 통칭* 으로 읽히며 실제 경로는 §Reference Loading Schedule 에서 `${CLAUDE_PLUGIN_ROOT}/references/` 로 명시. 라우팅 영향 없음. round 4 까지 동일 |
| §Reference Loading Schedule fallback 이 `bobs-plugin` 디렉토리 구조 가정 (`../../references/`) | 본 스킬은 bobs-plugin 종속 배포로 명시. 외부 plugin 이식 시 사용자 보고·종료 동작이 따로 정의되어 INTENTIONAL_EXCEPTION |
| 한국어/영어 혼용 본문 | trigger 자체가 다국어이므로 라우팅 일관성. round 4 의 §6 Terminology pass 가 일반 동사·서술어는 한국어로 통일하고 도메인 용어·tool 이름·enum 값만 영어 유지하는 명시 규칙을 둠 — 의도된 혼용 |
| §6 Terminology and tone pass 가 SKILL.md 자체를 수정 (신규 mutation 시점) | §6 본문에 (1) 의미 변경 금지 + (2) 의미가 바뀌면 §3 GAP 분석으로 escape 두 안전망 명시. 호출자가 명시 호출한 흐름의 마지막 정리 단계로 CONSTITUTION §3.3 "approval or explicit invocation" 안에 cover. P3 미만의 명목적 명확성 영역으로 finding 미생성 |
| writing-skills 의 RED-GREEN-REFACTOR / CSO 절차를 `skill-creator/references/` 아래로 vendor | self-contained 가 진다 + MIT license + 출처 attribution 명시. 외부 패키지 의존 제거. progressive disclosure 강화 (선택 참조). round 4 신규 긍정 변경 |
| `Skill(writing-skills)` runtime 호출 제거 | round 3 까지의 외부 runtime 의존이 inline 요약 + vendored references 로 대체됨. portability 향상. round 4 신규 긍정 변경 |

## 8. Suggested Changes

### Asset Changes

Round 3 까지의 모든 권장 변경 사항은 round 4 시점에 적용 완료:

- [x] (P2) GAP-008: §4b 머리말에 시점 B gate 인용 추가됨 (line 231).
- [x] (P3) GAP-009: §3b Claude Code 예시 cwd 가 `<RESOLVED_REFS_DIR>` placeholder 로 변경됨 (line 162, 169).

Round 4 신규 권장 변경: **없음**. 자산이 PASS 상태에 도달.

### Guide Changes

- [ ] None. SKILL-GUIDE / CONSTITUTION 가 round 4 시점에도 round 1-3 의 모든 finding 을 잡아낸다. GUIDE_GAP 없음.

### Constitution Review

- [ ] None.

## 9. Follow-up Questions

Round 3 의 follow-up 3건은 round 4 시점에 모두 해소됨:

1. §4b "적용 의무" 표현의 의도 — round 4 fix 가 *표현을 약화하지 않으면서* 시점 B gate 를 명시 인용하는 형태로 처리 (우선순위 표현 유지 + gate 면제 아님 명시). 의도 보존 + 일관성 확보.
2. 본 스킬 호출 시나리오 비율 — round 4 의 fix 가 자동 활성화·직접 호출 모두에 적용되는 일반 표현이라 더 이상 강도 조정 사유 없음.
3. PASS 동결 여부 — round 4 분석 결과 신규 finding 0건. **PASS 동결 권고**.

Round 4 신규 follow-up: **없음**.

## 10. Final Decision

`PASS`

round 3 의 2 finding (GAP-008/009) 이 모두 자산 수정으로 해소됐고, round 3 이후 적용된 4종 추가 변경 (용어·톤 통일 / 외부 의존 내재화 / §6 Terminology pass / intent 질문 한국어화) 모두 라우팅·safety·output contract·capability surface 어떤 축에도 부정 영향 없음. 외부 의존 제거와 progressive disclosure 강화는 *긍정* 영향. §6 신규 mutation 시점은 본문 내 안전망 (의미 변경 금지 + §3 escape) 으로 cover.

**4 라운드 누적 수렴 평가**:

| Round | Findings | Severity 분포 | 주요 영역 |
|---|---|---|---|
| 1 | 4 | P2-P3 | description shortcut · mutation gate · 도구 추상화 · 경로 portability |
| 2 | 3 | P2-P3 | re-GAP mutation gate · 500 lines hard threshold · portability 비대칭 |
| 3 | 2 | P2-P3 | §4b 표현 vs gate 일관성 · 예시 cwd placeholder |
| 4 | 0 | — | — |

finding 수 단조 감소 (4 → 3 → 2 → 0). P0/P1 단 한 번도 출현 없음. round 1-3 의 P2 finding 은 모두 *mutation gate 적용 범위 확장* 의 동일 원칙이 점진적으로 더 넓은 시점에 침투해온 series 였고, round 4 에서 이 series 가 §4b 까지 닫혀 종료. round 1-3 의 P3 finding 은 모두 portability / progressive disclosure 영역 cleanup 이었고, round 4 의 외부 의존 내재화 + vendored references 가 이 영역을 self-contained 로 전환.

**PASS 동결 권고**:

- 다이미닝 리턴이 명확한 영역. round 5 자동 실행은 noise 가 될 가능성 큼.
- §4c round limit (5 라운드) 도래 전 자산 목적·원칙 충족 확보.
- 후속 변경이 필요해지는 시점은 (1) CONSTITUTION / SKILL-GUIDE 가 v3 으로 개정될 때, (2) 본 스킬을 사용한 실제 case 에서 새 실패 mode 가 관찰될 때, (3) plugin 환경 / runtime 가 변경되어 가정 (CLAUDE_PLUGIN_ROOT 등) 이 무효화될 때.
- 그 외 자발적 round 5 실행은 권장하지 않음.

다음 라운드 우선순위 (필요 시): 없음. 자산이 안정 상태.
