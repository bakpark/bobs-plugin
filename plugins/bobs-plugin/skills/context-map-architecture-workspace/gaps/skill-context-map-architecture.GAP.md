# GAP Report — context-map-architecture

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2.1
검토자: GAP-analysis subagent (bakparkbj 위임)
asset_type: skill
source_path:
  - plugins/bobs-plugin/skills/context-map-architecture/SKILL.md
  - plugins/bobs-plugin/skills/context-map-architecture/references/agents-md-write.md
  - plugins/bobs-plugin/skills/context-map-architecture/references/context-map-write.md
  - plugins/bobs-plugin/skills/context-map-architecture/references/claude-md-write.md
  - plugins/bobs-plugin/skills/context-map-architecture/references/docs-tree-write.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, harness-principles.md, harness-installation-workflow.md, GAP-FORMAT.md
final_decision: PASS_WITH_NOTES
```

본 리포트는 외부 경로 5건 (SKILL.md 1 + reference 4) 을 단일 자산 단위로 평가한다 (skill-creator §3b 의 default 1건 제한을 본 plan P1#2 보강으로 확장 — 사용자 지시).

---

## 2. Executive Summary

`context-map-architecture` 는 *문서 트리 설계 + 작성* 메타 스킬로, 4개 reference 를 호출-wrapper 로 묶어 effect gate (Document Plan → Apply) 를 강제한다. CONSTITUTION 의 핵심 원칙 (activation, effect gate, output contract, capability/responsibility match, progressive disclosure) 은 모두 충족하며, 흡수 절차도 원본 (`agents-md-author`, `context-map-builder`, `claude-md-improver`) 의 핵심 단계 대부분이 보존되어 있다.

다만:

- SKILL.md 의 normative reference 가 **존재하지 않는 `harness-principles.md §5.7`** 을 인용 — 라우팅에는 영향 없지만 문서 권위 추적이 깨진다 (P1).
- `docs-tree-write.md` 가 `## Phase 2` 헤더를 **두 번** 쓴다 (`Phase 2 Skeleton write` + `Phase 2 Effect gate`) — 같은 문서 안에서 phase 식별이 모호해 verify 절차 호출 시 혼란 가능 (P2).
- SKILL.md description 이 **약 127 words** — SKILL-GUIDE §10 heuristic (15-60) 보다 길지만, 본문은 trigger / near-miss / "Do NOT use" 라우팅만 다뤄 workflow shortcut 위험은 낮다. heuristic 위반이므로 P3 정리 신호.
- `context-map-builder`, `agents-md-author`, `claude-md-improver` 가 sibling skill 로 **여전히 존재** — overlap 이 의도적이고 SKILL.md 가 어느 정도 설명하지만, 기존 skill 들의 deprecation 또는 차이 문장이 SKILL.md 에 없어 router 가 둘 다 후보로 인식할 가능성 (P2).

reference 4건 자체는 흡수 완전성 / 도구 공통성 / Apache-2.0 attribution / 길이 budget 모두 만족 또는 acceptable deviation 범위.

**결론**: 자산 구조 자체는 건전, 4건의 정정 (인용 오류, phase 헤더 중복, description 압축, sibling overlap 설명) 으로 충분. `PASS_WITH_NOTES`.

---

## 3. Asset Snapshot

### 3.1 Skill Snapshot (SKILL.md)

```text
name: context-map-architecture
description: (multi-line) ~127 words — trigger phrases (KO/EN) + "Do NOT use" 5건 라우팅
description_words: 127 (frontmatter description 전체)
body_words: 1386 - frontmatter ≈ 1260
body_lines: 157
tools: (omitted)
invocation_controls: user-invocable: true
has_references: yes — 4 references (agents-md-write / context-map-write / claude-md-write / docs-tree-write)
has_scripts_or_assets: no
has_effect_gate: yes — Phase 2 Document Plan = gate 1단계, Phase 3 각 reference 의 자체 gate = 2단계
has_output_contract: yes — Output Contract 섹션 + mode (applied / plan-only / no-op / blocked) 명시
```

### 3.2 Reference Snapshots (요약)

| Reference | Lines | Words | Self-contained? | Effect gate | Output contract | Length verdict |
|---|---|---|---|---|---|---|
| agents-md-write.md | 291 | 2073 | yes (template + 섹션 가이드 + 누수 표 + verify) | Phase 3 (4가지 사용자 제시) | yes | acceptable (작성형 reference) |
| context-map-write.md | 279 | 1903 | yes (inventory + 표 골격 + 갱신 diff + 길이 가이드) | Phase 3 (5가지) | yes | acceptable |
| claude-md-write.md | 128 | 976 | yes (6 criteria + 5 phase + checklist) | Phase 4 (diff + Why) | yes | matches "Phase 1-5 압축" target |
| docs-tree-write.md | 305 | 1485 | yes (6 카테고리 skeleton + verify) | "Phase 2 Effect gate" (실제로는 Phase 3 역할) | yes | acceptable (6 카테고리 template 포함) |

---

## 4. Applicable Criteria

본 리포트가 인용한 권위 문서와 heading:

- `CONSTITUTION.md §2 원칙의 강도`
- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`
- `CONSTITUTION.md §3.10 Overlap Must Be Intentional`
- `CONSTITUTION.md §3.13 Freshness Requires Evidence`
- `SKILL-GUIDE.md §4 Description 작성`
- `SKILL-GUIDE.md §5 Body 설계`
- `SKILL-GUIDE.md §6 Effects And Gates`
- `SKILL-GUIDE.md §7 Progressive Disclosure`
- `SKILL-GUIDE.md §8 Output Contract`
- `SKILL-GUIDE.md §10 Quantitative Heuristics`
- `SKILL-GUIDE.md §12 Anti-Patterns`
- `harness-principles.md §4.1 Docs`
- `harness-principles.md §4.5 Context Map`
- `harness-principles.md §4.7 자산 선택 기준`
- `harness-installation-workflow.md §2 Routing` / `§4 Spec Interface`

---

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | partial | trigger 신호는 풍부 (KO/EN + 5 "Do NOT use"), 다만 description 127 words 로 가독성 저하 — 라우팅 자체는 동작 |
| Description avoids workflow shortcut | pass | description 은 trigger + near-miss 만 다루고 내부 phase 절차를 노출하지 않음 |
| Scope or near-miss is clear when needed | pass | "When NOT to use" 5종 명시 (`harness-resource-design`, `skill-creator` 등) |
| Workflow is actionable | pass | Phase 1-3 + 의존성 기반 write 순서 (1→4) + 각 reference 호출 명시 |
| Effect gate exists when mutation is possible | pass | 이중 gate — SKILL Phase 2 Document Plan + 각 reference Phase 3 (또는 Phase 4) |
| Output contract exists | pass | mode (applied / plan-only / no-op / blocked) + spec 형식 + follow_ups |
| Progressive disclosure is appropriate | pass | 본문 157 lines, 4개 reference 로 절차 본문 분리. SKILL.md 는 reference 호출 wrapper 만 |
| Reusable vs project memory is separated | pass | 프로젝트 고유 정보 없음 — 모두 일반 절차 |
| Behavior can be verified | partial | write 후 verify 절차는 각 reference 에 있으나, should-trigger / should-not-trigger 명시적 eval 케이스는 본문에 없음 (메타 스킬이라 SKILL-GUIDE §9 의 verify loop 가 hard rule 은 아님) |
| Overlap is intentional | partial | "When NOT to use" 가 다른 design skill 과의 경계만 다루고, **sibling old skills (`agents-md-author` / `context-map-builder` / `claude-md-improver`) 가 여전히 존재** 한다는 사실은 언급 없음 |

---

## 6. Findings

### 6.1 요약 표

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `CONSTITUTION.md §3.13` | SKILL.md 가 존재하지 않는 `harness-principles.md §5.7` 을 normative 로 인용 | 인용을 §4.1/§4.5/§4.7 만 남기거나, 실제 "1차 MVP 생성 순서" 가 있는 절로 교체 — asset 수정 |
| GAP-002 | ASSET_GAP | P2 | `SKILL-GUIDE.md §5` | `docs-tree-write.md` 가 `## Phase 2` 헤더를 2회 사용 (`Skeleton write` + `Effect gate`) | 두 번째를 `## Phase 3 Effect gate` 로 변경 + Output Contract 와 SKILL.md cross-reference 동기화 — asset 수정 |
| GAP-003 | ASSET_GAP | P2 | `CONSTITUTION.md §3.10` | sibling 구 skill (`agents-md-author`, `context-map-builder`, `claude-md-improver`) 이 plugin 내 여전히 존재하지만 SKILL.md 의 "When NOT to use" 가 이를 다루지 않음 | "When NOT to use" 에 sibling 행 추가하거나, sibling 들을 deprecation/제거 follow-up 으로 보고 — asset 수정 (혹은 sibling 제거) |
| GAP-004 | ASSET_GAP | P3 | `SKILL-GUIDE.md §10` | description 약 127 words (heuristic 15-60 보다 길다) | 트리거 phrase 압축 (영문 5-7개 + 한글 5-7개 + "Do NOT use" bullet list 한 줄씩) — asset 수정 |
| GAP-005 | AMBIGUITY | P3 | `SKILL-GUIDE.md §9` | should-trigger / should-not-trigger / no-op / blocked 의 eval 케이스가 본문에 없음 (메타 스킬이라 hard rule 아님) | 본문에 한 줄 verification note (예: "no-op = inventory 일치, blocked = 자원 0") 추가 또는 workspace 에 eval 파일 보강 |

### 6.2 상세

---

#### GAP-001: SKILL.md 가 `harness-principles.md §5.7` 을 인용하나 해당 절이 없음

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §3.13 Freshness Requires Evidence` · `SKILL-GUIDE.md §5 Body 설계` |

**Expected**

normative source 인용은 실제 존재하는 heading 만 사용해야 한다 (CONSTITUTION §3.13: "확인하지 못한 platform behavior 는 hard rule 로 쓰지 않는다 / `unknown` 또는 `needs verification` 으로 표시"). GAP-FORMAT §8 도 "존재하지 않는 section 번호를 만들지 않는다" 를 요구.

**Actual**

`SKILL.md:155`:

> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.1 (Docs 책임 분리), §4.5 (Context Map), §4.7 (자산 선택 기준), **§5.7 (1차 MVP 생성 순서)**.

`harness-principles.md` 의 최상위 절은 §1-§4 뿐 (§5 자체가 없음 — `grep "^##? " harness-principles.md` 로 확인). "1차 MVP 생성 순서" 에 가까운 내용은 §4.9 "1차 적용 원칙".

**Evidence**

- `SKILL.md:155` — `§5.7 (1차 MVP 생성 순서)` 인용
- `harness-principles.md` 절 목록: §1 배경, §2 문제 정의, §3 목표, §4 구성요소 모델 (§4.1-§4.9). §5 없음.

**Impact**

- 라우팅 자체에는 영향 없음 (이미 reference 4개로 분기).
- 문서 권위 추적 시 독자가 §5.7 을 찾으러 가면 발견 실패 → 자산 신뢰도 저하.
- "freshness evidence" 원칙 위반 — 다른 정보의 정확성에 의심이 생긴다.

**Recommendation**

asset 수정. `§5.7 (1차 MVP 생성 순서)` 를 `§4.9 (1차 적용 원칙)` 로 교체, 또는 `harness-installation-workflow.md §3.2` 로 위임 (이미 같은 줄에서 인용 중이므로 §5.7 만 삭제 가능).

---

#### GAP-002: `docs-tree-write.md` 의 `## Phase 2` 헤더 중복

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `SKILL-GUIDE.md §5 Body 설계` (workflow 실행 가능성) |

**Expected**

Phase 헤더는 순차적 식별자다. 같은 reference 안에서 두 phase 가 같은 번호를 가지면 SKILL.md (호출자) 가 "Phase 2 의 effect gate 호출" 같은 cross-reference 를 만들 때 어느 phase 를 가리키는지 모호해진다.

**Actual**

`docs-tree-write.md` line 46: `## Phase 2 Skeleton write` — 실제 write 절차.
`docs-tree-write.md` line 255: `## Phase 2 Effect gate` — write *직전* gate.

두 번째는 의미상 별도 phase (또는 Phase 2 의 sub-step) 이지만 같은 번호.

`SKILL.md:99` 가 이를 다음과 같이 호출한다: "docs-tree-write.md Phase 2" — 어느 Phase 2 인지 명시 안 됨.

**Evidence**

- `docs-tree-write.md:46` `## Phase 2 Skeleton write`
- `docs-tree-write.md:255` `## Phase 2 Effect gate`
- `SKILL.md:99` — Phase 3 의 의존성 순서 3번 항목이 "docs-tree-write.md Phase 2" 만 호출
- 다른 3개 reference 는 Phase 1 → 2 → 3 (또는 4-5) 순차 구조 — 일관성 비교 가능

**Impact**

- 본 reference 호출 시 모델이 "write 절차" 만 보고 effect gate 를 건너뛸 위험 (Phase 2 가 둘 있어 후자를 못 볼 수도).
- SKILL.md 의 의존성 순서 텍스트도 모호 — verify / re-read 부담.

**Recommendation**

asset 수정. line 255 를 `## Phase 3 Effect gate` 로 변경, Output Contract 와 verify 단락 cross-reference 도 동일하게 갱신. SKILL.md `Phase 3` 의 3번 항목도 `docs-tree-write.md Phase 2-3` 로 갱신.

---

#### GAP-003: sibling 구 skill 들이 plugin 에 여전히 존재 — overlap 설명 부족

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.10 Overlap Must Be Intentional` · `SKILL-GUIDE.md §12 Anti-Patterns` (Unscoped workflow) |

**Expected**

비슷한 자산이 공존하면 차이가 설명되어야 한다. router 가 어느 skill 을 골라야 할지 결정할 수 있어야 한다.

**Actual**

`plugins/bobs-plugin/skills/` 에 다음이 동시에 존재:

- `context-map-architecture/` (본 자산 — 메타 wrapper)
- `agents-md-author/` (원본 — AGENTS.md 전용)
- `context-map-builder/` (원본 — context-map.md 전용)
- `claude-md-improver/` (원본 — CLAUDE.md 전용)

각 원본 skill 의 description 은 여전히 "AGENTS.md 만들어줘", "context map 갱신", "CLAUDE.md audit" 같은 trigger 를 잡는다 — 본 자산의 trigger 와 정확히 겹친다.

`SKILL.md` 의 "Do NOT use" 5건 (`harness-resource-design`, `skill-creator`, `evaluation-loop-design`, 본문 prose, `codex-reviewer`) 은 *다른 design domain* 만 다루고 같은 domain 의 원본 skill 들과의 경계는 다루지 않는다.

**Evidence**

- `ls plugins/bobs-plugin/skills/` 결과에 4개 sibling 모두 존재 확인
- `agents-md-author/SKILL.md` description: "Use when authoring, scaffolding, refining, or auditing a project's `AGENTS.md`..."
- `context-map-builder/SKILL.md` description: "Use when authoring, scaffolding, or refreshing a project's `docs/agent/context-map.md`..."
- `claude-md-improver/SKILL.md` description: "Audit and improve CLAUDE.md files..."
- 본 `SKILL.md:4` description 도 동일 trigger (`AGENTS.md 만들어줘`, `context map 갱신`, `CLAUDE.md audit`) 포함

**Impact**

- 라우팅 ambiguity — "AGENTS.md 만들어줘" 발화 시 4개 skill 후보 동시 활성화 가능.
- 같은 trigger 에 서로 다른 결과 (단일 파일 작성 vs 메타 wrapper) — output contract 신뢰도 저하.
- 메타 wrapper 의 effect gate 가 건너뛰어질 위험 (원본 skill 이 단일 파일 작성으로 바로 진입).

**Recommendation**

다음 중 하나:

1. (권장) asset 수정 — `SKILL.md` "When NOT to use" 에 한 줄 추가: "단일 파일만 다루는 sibling (`agents-md-author` / `context-map-builder` / `claude-md-improver`) — 이들은 본 메타 스킬에 흡수됐으므로 제거 follow-up 으로 보고".
2. (더 강한 해결) sibling 3개를 deprecation 또는 plugin 에서 제거 (별도 작업). 단, 본 GAP 의 수정 범위 밖.
3. (대안) 본 자산이 sibling 들을 *호출* 하는 형태로 재구성 — 그러나 reference 흡수 설계와 충돌하므로 비권장.

---

#### GAP-004: SKILL.md description 길이 ~127 words

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §10 Quantitative Heuristics` |

**Expected**

description heuristic: 보통 15-60 words. 빈번 호출 스킬은 짧을수록 좋다. 단, heuristic 이므로 hard rule 아님.

**Actual**

frontmatter description 약 127 words. multi-line YAML (`|-`) 로 trigger phrase 5+ 종 + "Do NOT use" 5건 + skeleton 한정 단서까지 포함.

**Evidence**

- `SKILL.md:3-4` — `description: |-` 블록
- word count: ~127 (단어 단위)
- 비교: `claude-md-improver/SKILL.md` description ~55 words; `agents-md-author/SKILL.md` description ~85 words; SKILL-GUIDE 권장 15-60.

**Impact**

- 자주 로드되는 metadata 가 큼 — context 비용 미세 증가.
- workflow shortcut 위험: 현재 본문은 trigger / NOT-use 만 다루어 SHORTCUT 위험 낮음 (실제 phase 절차 노출 안 됨) — 따라서 P3.
- 그러나 길이 자체가 router 가독성을 떨어뜨려 trigger 인식 정확도에 부정적 영향 가능.

**Recommendation**

asset 수정 (낮은 우선순위). trigger 를 5-7 phrase 로 압축, "Do NOT use" 를 1줄씩 short bullet 로, skeleton 한정 단서는 본문 1줄로 이동. 목표: 60-80 words.

---

#### GAP-005: should-trigger / should-not-trigger eval 케이스 부재

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `SKILL-GUIDE.md §9 Verification` · `SKILL-GUIDE.md §11 Checklist` |

**Expected**

스킬 verify 루프 — should-trigger / should-not-trigger / no-op / blocked / missing-config / stale-reference 케이스. 메타 스킬은 모든 케이스가 필수는 아니지만, 적어도 no-op / blocked 의 검증 기준은 본문에 있어야 한다.

**Actual**

- no-op / blocked / plan-only / applied 4 modes 의 *의미* 는 Output Contract 에 명시.
- 그러나 *언제 그 mode 가 발동되는지* 의 케이스 (예: "기존 docs 트리가 6 카테고리 모두 있고 prose 가 채워진 경우 → no-op") 의 verify 절차는 본문에 부분적으로만 (예: `No-op case: 기존 docs 트리가 적절하고 ...`).

**Evidence**

- `SKILL.md:130-134` — No-op / Blocked / Plan-only case 정의 (한 줄씩) 존재
- 그러나 should-trigger / should-not-trigger 의 명시 예 없음
- workspace `context-map-architecture-workspace/gaps/` 가 비어있어 별도 eval 파일도 없음

**Impact**

- 본 자산은 메타 스킬이라 SKILL-GUIDE §9 의 verify loop 가 hard rule 이 아님 — P3 로 강등.
- 호출자가 reuse 시점에 "정상 동작인가" 를 판단할 reference 케이스가 부족.

**Recommendation**

다음 중 하나 (낮은 우선순위):

1. 본문 `## Verification` 짧은 단락 추가 — should-trigger / should-not-trigger / no-op / blocked 각 1줄 예시.
2. workspace 에 별도 eval markdown 추가 — 본 plan 의 다른 step 에서 다룰 수 있음.

---

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `tools` 미명시 (frontmatter) | 메타 wrapper 가 reference 호출 + write 까지 책임 — Read/Write/Edit/Bash 등 폭넓은 도구 필요. capability 제한이 의미 있을 만큼 좁지 않음. SKILL-GUIDE §3 "tools 명시는 필수 필드가 아니다" |
| description multi-line (`|-`) 형식 | YAML 멀티라인 자체는 형식 차이일 뿐 (heuristic 위반은 GAP-004 로 별도 기록) |
| reference 별 길이 (128-305 줄) | 작성형 reference 는 template + 섹션 가이드 + 누수 표 + verify 까지 self-contained 필요 — `agents-md-write.md` 291줄, `context-map-write.md` 279줄, `docs-tree-write.md` 305줄 모두 acceptable. SKILL-GUIDE §7 "분리할 것: 긴 reference 문서" 에 부합. |
| `agents-md-write.md` 가 tool 이름 (Claude/Codex/Gemini/Cursor) 다수 언급 | 모든 언급이 *도구 공통성 설명* 또는 *누수 점검 표* 의 anti-pattern context 에서만 등장. SKILL.md 가 "도구 공통" 책임을 명시했고 reference 도 이를 보존. 도구 leak 아님. |
| `claude-md-write.md` 의 Apache-2.0 attribution | `third_party_licenses/claude-md-management-LICENSE` 실파일 존재 확인. attribution 문구도 원본 source + 압축 사실 + LICENSE 경로 모두 명시 — 정합성 양호. |
| `docs-tree-write.md` 의 "흡수 source 없음 — 본 plan (Step 2, P1#4 보강) 에서 새로 작성" | 신규 작성 reference 는 원본 흡수 검증 불필요. 6 카테고리 (architecture / decisions / domain / integrations / workflows / security) 가 `harness-principles.md §4.1` 표와 1:1 대응 — 책임 누락 없음. |
| 본 자산이 user-invocable: true | 사용자 명시 호출 가능한 docs 셋업 workflow — CONSTITUTION §3.11 의 "User-Initiated Workflows" 와 부합. 메타 스킬이 명시 호출 가능한 entrypoint 를 가져도 정상. |
| 의존성 기반 write 순서 (1→4) 강제 | AGENTS.md → CLAUDE.md → docs/* → context-map 순서가 라우팅 정합성에 필수 (context-map 이 다른 자원을 인용하므로 마지막). Common Failures 표의 "Order violation" 으로 자체 검증. |

---

## 8. Suggested Changes

### Asset Changes

- [ ] **GAP-001**: `SKILL.md:155` — `§5.7 (1차 MVP 생성 순서)` 인용 제거 또는 `§4.9 (1차 적용 원칙)` 로 교체
- [ ] **GAP-002**: `docs-tree-write.md:255` — `## Phase 2 Effect gate` → `## Phase 3 Effect gate`. Output Contract / verify cross-reference 동기화. `SKILL.md:99` 의 "docs-tree-write.md Phase 2" → "Phase 2-3"
- [ ] **GAP-003**: `SKILL.md` "When NOT to use" 에 sibling skill (agents-md-author / context-map-builder / claude-md-improver) 한 줄 추가 — 또는 sibling deprecation 별도 작업 (본 GAP 의 범위 밖이나 권장)
- [ ] **GAP-004**: `SKILL.md` description 60-80 words 로 압축 (trigger phrase 정리 + "Do NOT use" bullet 한 줄씩)
- [ ] **GAP-005**: `SKILL.md` 본문에 짧은 `## Verification` 단락 또는 workspace 에 eval 파일 추가 (낮은 우선순위)

### Guide Changes

- [ ] None — 본 분석에서 guide 의 부재나 false-positive 패턴은 발견되지 않음.

### Constitution Review

- [ ] None — 본 분석은 헌법 수정 후보를 식별하지 않음.

---

## 9. Follow-up Questions

1. sibling 3개 skill (`agents-md-author`, `context-map-builder`, `claude-md-improver`) 의 deprecation 정책은 plan 의 어느 step 에서 다루나? GAP-003 의 권장 해결책 (sibling 제거) 이 다른 step 으로 위임되어 있다면 본 finding 의 우선순위가 P2 → P3 로 낮아질 수 있다.
2. `harness-principles.md` 에 "1차 MVP 생성 순서" 절을 추가할 계획이 있는가? 있다면 GAP-001 은 정정 대신 normative source 의 후속 작업으로 정리 가능.
3. `docs-tree-write.md` 의 `docs/agent/roles.md` skeleton 작성을 follow-up 으로 미루는데 (line 21), 본 자산이 작성 책임을 갖지 않는다면 `roles.md` 작성용 별도 reference 또는 skill 이 plan 의 어느 단계에서 다뤄지는가?

---

## 10. Final Decision

**`PASS_WITH_NOTES`**

근거:
- 자산 구조 (activation / effect gate / output contract / capability match / progressive disclosure) 는 모두 충족.
- 4건의 영향 있는 finding 중 P0 없음, P1 1건 (인용 오류 — 라우팅 영향 없음), P2 2건 (phase 헤더 중복, sibling overlap 설명 부족), P3 2건 (description 길이, eval 케이스 부재).
- 모든 finding 이 단순 정정 (1-3 줄 수정 또는 한 단락 추가) 으로 해결 가능 — `REVISE_ASSET` 까지 갈 정도는 아님.
- 흡수 절차 완전성, 도구 공통성, Apache-2.0 attribution, 길이 budget 모두 해당 reference 의 책임 범위에서 acceptable.

---

## 11. Self-Check (GAP-FORMAT §17)

```text
1. 헌법 → 타입별 가이드 → GAP-FORMAT 순서로 적용했는가?
   → yes. CONSTITUTION 핵심 원칙을 먼저 적용, SKILL-GUIDE 의 description/length heuristic 은 P3 로 강등, GAP-FORMAT 의 finding 구조 준수.

2. guide_ref 는 실제 존재하는 heading 인가?
   → yes. 모든 인용은 본 분석에서 직접 읽은 파일의 실제 heading.

3. finding 은 형식 차이가 아니라 실제 영향이 있는가?
   → yes. GAP-001 (문서 권위 추적 실패), GAP-002 (cross-reference 모호), GAP-003 (라우팅 ambiguity), GAP-004 (context 비용 + 가독성), GAP-005 (verify 부담) 모두 구체적 영향 명시.

4. heuristic 을 hard rule 처럼 적용하지 않았는가?
   → yes. description 길이 (GAP-004) 와 eval 케이스 부재 (GAP-005) 는 P3 로 강등. 두 reference 의 줄 수 (291, 305) 는 acceptable deviation 으로 인정.

5. platform default, tools behavior, hook schema 를 확인 없이 단정하지 않았는가?
   → yes. tools 미명시는 capability 제한 의미 없음으로 acceptable deviation 처리. user-invocable: true 도 명시 선택으로 인정.

6. 좋은 예외를 finding 으로 과잉 승격하지 않았는가?
   → yes. Apache-2.0 attribution, multi-line description 형식, 의존성 순서, agents-md-write 의 tool 이름 언급은 모두 Acceptable Deviations 로 분리.

7. recommendation 이 asset 수정인지 guide 수정인지 명확한가?
   → yes. GAP-001~005 모두 asset 수정. Guide Changes / Constitution Review 는 None.

8. Constitution Review 를 너무 쉽게 제안하지 않았는가?
   → yes. Constitution Review = None.
```

