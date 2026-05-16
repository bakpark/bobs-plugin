# GAP Report — skill `hook-creator`

## 1. Metadata

```text
작성일: 2026-05-17
기준 버전: v2
round: 2
검토자: gap-analysis (subagent, opus-4-7-1m)
asset_type: skill
source_path: plugins/bobs-plugin/skills/hook-creator/SKILL.md
compared_against: CONSTITUTION.md, SKILL-GUIDE.md, GAP-FORMAT.md
  (HOOK-GUIDE.md — 인용 정확성 spot-check 만)
final_decision: PASS
```

## 2. Executive Summary

`hook-creator` 는 hook 작성·개선 절차를 정의하는 procedural 메타 스킬이다.
Round 1 에서 발견된 두 P3 finding 이 모두 해소되었다.

- **GAP-001 (matcher-pressure.md 미존재)**: round 2 에서 파일 실제 작성 (63 lines). 본문 §"When the loop stalls" 의 reference link 가 살아 있다. **resolved**.
- **GAP-002 (§5 Output contract freeform)**: round 2 에서 (a) "한 필드 한 줄 fenced block" 가이드, (b) 10개 필드 Required/Value 형식/빈 값 처리 표, (c) `blocked: needs revision` prefix 위치 명시까지 추가되어 caller 가 mechanical 하게 parse 할 수 있는 schema 가 완성됐다. **resolved**.

Round 2 조치가 도입한 새 finding 은 없다. 표 형식 정형화·reference 파일 작성 모두 SKILL-GUIDE §6 / §7 / CONSTITUTION §3.4 / §3.7 의 기대치에 정확히 부합한다. 자산은 이제 P0–P3 모두 0 이며 acceptable deviation 만 잔류 — `PASS` 로 격상한다.

HOOK-GUIDE 와 GAP-FORMAT 인용은 round 1 spot-check 이후 변경되지 않았으며 추가 검증에서도 모두 실제 heading 과 일치한다.

## 3. Asset Snapshot (Skill)

```text
name: hook-creator
description: |- (multi-line, ~120 words)
  Use when creating, scaffolding, editing, or verifying a Claude Code
  hook — a registration entry ... 와 그 entry 가 가리키는 script 파일 한 쌍.
  Triggers on "create a hook", "훅 만들어줘", "PostToolUse for X", ...
  Do NOT use for 스킬 작성(`skill-creator`), 서브에이전트 작성(`writing-agents`),
  자원 타입 결정(`agent-skill-designer`), 정적 rule 감사(`agent-skill-auditor`),
  PR/code 편집.
description_words: ~120 (heuristic 15-60 초과지만 trigger + near-miss 풍부)
body_words: ~3680 (round 1 대비 §5 표 추가로 ~140 words 증가)
body_lines: 361 (round 1: 344)
tools: omitted (frontmatter 에 명시 없음)
invocation_controls: 없음 (default model invocation 허용)
has_references: yes
  - references/matcher-pressure.md 실재 (63 lines, ~480 words) — round 2 추가
  - 권위 문서는 ${CLAUDE_PLUGIN_ROOT}/references/ 의 4종 (CONSTITUTION, SKILL-GUIDE, HOOK-GUIDE, GAP-FORMAT, GAP-ANALYSIS-PROMPT)
has_scripts_or_assets: false
has_effect_gate: yes
  - §2 시점 A (첫 파일 쓰기 전 5항목 제시)
  - §2 시점 B (수정 라운드 변경 요약 제시)
  - §4b "gate 자체를 우회하지 않는다" 명시
has_output_contract: yes
  - §5 fenced block 형식 + 10 필드 Required/Value/empty 표 (round 2 강화)
  - `blocked: needs revision` prefix 규칙 명시
```

## 4. Applicable Criteria

| 출처 | 적용 단원 |
|---|---|
| CONSTITUTION.md | §3 공통 원칙 전체 (특히 §3.1, §3.3, §3.4, §3.5, §3.7, §3.8, §3.10) |
| SKILL-GUIDE.md | §2 Frontmatter, §3 Description, §4 Body 설계, §5 Effects And Gates, §6 Progressive Disclosure, §7 Output Contract, §8 Verification, §9 Quantitative Heuristics, §10 Checklist, §11 Anti-Patterns |
| GAP-FORMAT.md | §11.1 Skill Snapshot, §12.1 Skill Checks, §16 Final Decision |
| (참고) HOOK-GUIDE.md | 인용 heading 존재 여부 spot-check 만 — 자산 *내용* 평가에는 사용하지 않음 |

## 5. Checks (Skill)

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass | description 에 verb trigger ("create/scaffold/edit/verify a hook"), Korean trigger 문구, near-miss (skill / agent / designer / auditor / PR) 명시 |
| Description avoids workflow shortcut | pass | description 은 trigger 와 negation 만 — 본문 phase 절차를 요약하지 않음 |
| Scope or near-miss is clear when needed | pass | "When NOT to use" 섹션, In-flight escape hatches 표 (§0), Limits (§Limits) 모두 존재 |
| Workflow is actionable | pass | §0–§6 phase 가 순차적이고 각 phase 가 "먼저 읽는다 + 산출물" 형식. Mini example 로 dry run 제시 |
| Effect gate exists when mutation is possible | pass | §2 시점 A/B gate, §4b 의 "gate 우회 금지" 명시 강조 |
| Output contract exists | pass | round 2 에서 §5 가 fenced block + 10 필드 Required/Value/empty 처리 표 + prefix 규칙으로 정형화 — caller 가 mechanical 하게 parse 가능 |
| Progressive disclosure is appropriate | pass | Reference Loading Schedule 로 권위 문서 lazy-load, matcher-pressure.md 도 §"When the loop stalls" 에서 lazy-load. body 에 규칙 복사 안 함 |
| Reusable vs project memory is separated | pass | 프로젝트 path/명령 하드코딩 없음 — 모든 path 는 user/project/plugin scope 분기로 일반화 |
| Behavior can be verified | pass | round 카운트 (§4c: 3/5 round 한계), §"When the loop stalls" 의 4 escape 경로, Mini example 로 expected output 검증, matcher-pressure.md 가 should-trigger/should-not-trigger dry-run 절차 제공 |
| Overlap is intentional | pass | 인접 자산 (`skill-creator`, `writing-agents`, `agent-skill-designer`, `agent-skill-auditor`, `codex-reviewer`, `pr-review-toolkit`) 각각 명시적 라우팅 |

## 6. Findings

영향 있는 finding 없음.

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| — | NO_GAP | — | — | round 2 조치로 round 1 P3 두 건 해소, 신규 finding 없음 | — |

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| Description ~120 words (heuristic 15-60 초과) | trigger 와 near-miss 가 풍부 — workflow shortcut 도 아니고 routing 비용 증가 evidence 없음. SKILL-GUIDE §3 "체크" 의 5개 질문 모두 통과 |
| body_lines 361 / body_words ~3680 (긴 본문) | 메타 스킬 + verification loop + escape hatch + decision table 구조. SKILL-GUIDE §9 "긴 메타/교육형 스킬: eval, reference, verification 구조가 있으면 길 수 있다" 에 해당 |
| `tools:` frontmatter 누락 | SKILL-GUIDE §2 에서 `tools` 는 "제한이 의미 있을 때 명시" — mutation gate 가 본문에 명시적이고 capability 충돌이 없으면 누락이 default. 자산은 file write + Read + Bash 모두 필요하므로 제한이 의미 없음 |
| `MUST` / `NEVER` 등 강한 표현 사용 | 사용 위치가 모두 실제 gate (§2 mutation 승인, §4b "gate 우회 금지", §Limits 의 boundary) — CONSTITUTION §3.8 부합 |
| Mini example 이 본문 내장 (외부 분리 안 됨) | 1 case 만 들어 본문 부담이 크지 않고 dry run 검증으로서 실행 가능성을 보임 |
| §4a 의 `REVISE_GUIDE` 행 "자산은 일단 통과" | GUIDE_GAP 은 자산이 좋은데 가이드가 잡지 못한 경우 — GAP-FORMAT §6 정의에 부합 |
| matcher-pressure.md 참조에 `(있을 경우; 없으면 본 절의 요약만 사용)` fallback 잔류 | round 2 에서 파일이 실재하므로 fallback 절은 사실상 dead branch 지만, 자산 이식성(plugin 외 환경 deploy 시 references 폴더가 빠질 수 있음)에 대한 graceful degradation 가이드로 의미가 있음 — 제거 강제할 영향 없음 |

## 8. Resolved in round 2

| ID | Round 1 status | Round 2 evidence | Round 2 status |
|---|---|---|---|
| GAP-001 (matcher-pressure.md 미존재) | AMBIGUITY, P3 | `skills/hook-creator/references/matcher-pressure.md` 실재 (63 lines). When to use / 절차(4 step) / 산출 / 한계 4개 섹션, dry-run 표 예시, 5개 초과 시 `SPLIT_ASSET` 권고까지 포함 | resolved |
| GAP-002 (§5 freeform key:value) | ASSET_GAP, P3 | §5 가 fenced block + 10 필드 Required/Value/empty 처리 표 + `blocked: needs revision` prefix 위치 명시로 정형화. `findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>` 같은 sub-field 형식과 empty 값 처리(`0` 명시, 필드 생략 금지)까지 단정됨 | resolved |

## 9. Suggested Changes

### Asset Changes

- [ ] None.

### Guide Changes

- [ ] None.

### Constitution Review

- [ ] None.

## 10. Follow-up Questions

- (round 1 잔류) 본 스킬이 `skill-creator` / `writing-agents` 와 동일 골격이라면 세 자산의 §5 Output contract 형식을 일관화하면 caller 입장에서 가치가 있다. 단일 스킬 GAP 범위 밖이므로 finding 으로 승격하지 않는다.

## 11. Final Decision

**`PASS`**

영향 있는 GAP 없음. Round 1 의 두 P3 가 round 2 조치로 모두 해소되었고 신규 finding 은 없다. 자산은 SKILL-GUIDE 와 CONSTITUTION 의 핵심 기대 (activation / scope / effect gate / output contract / progressive disclosure / verifiability / overlap) 를 모두 만족한다.
