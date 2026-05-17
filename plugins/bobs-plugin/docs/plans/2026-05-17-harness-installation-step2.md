# Harness Installation — Step 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 신규 `context-map-architecture` skill 을 `skill-creator` 로 작성하고, `agents-md-author` / `context-map-builder` / `claude-md-improver` 본문을 references 로 흡수한 후 3 자산을 deprecate. workflow doc §3.2 도 함께 채운다.

**Architecture:** skill-creator 가 새 skill 의 SKILL.md 와 GAP 사이클을 처리. references/ 의 흡수 본문 3개는 main session 이 기존 자산에서 추출·압축해 직접 작성 (skill-creator §2 가 SKILL.md 작성 후, §3 GAP 분석 이전). 워크플로우 §3.2 갱신 후 deprecated 자산 + 메타 파일 (plugin.json / marketplace.json / README.md / THIRD_PARTY_NOTICES.md) 일괄 정리.

**Tech Stack:** skill-creator skill (메타 스킬, interactive), Edit/Write tools, git rm -r

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §7 Step 2 (+ §4.2 책임 경계, §10 Decision 3 claude-md-improver 흡수 정책, Decision 4 GAP 깊이, Decision 6 commit 전략)

**전체 migration 중 위치:** Step 2 of 7. Step 1 (doc split) 완료된 상태에서 진행. Step 3-7 은 후속 별도 plan.

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` | Create (skill-creator §2) | docs 트리 설계 + 작성 라우팅 |
| `plugins/bobs-plugin/skills/context-map-architecture/references/agents-md-write.md` | Create (main session) | AGENTS.md 작성 절차 (agents-md-author 흡수, MIT) |
| `plugins/bobs-plugin/skills/context-map-architecture/references/context-map-write.md` | Create (main session) | context-map.md 작성 절차 (context-map-builder 흡수, MIT) |
| `plugins/bobs-plugin/skills/context-map-architecture/references/claude-md-write.md` | Create (main session) | CLAUDE.md 작성 절차 (claude-md-improver 흡수, Apache-2.0 attribution, ≤200 lines) |
| `plugins/bobs-plugin/skills/context-map-architecture/references/docs-tree-write.md` | Create (main session, fresh) | docs/architecture.md / docs/domain/ / docs/decisions/ / docs/integrations/ / docs/workflows/ / docs/security.md skeleton 작성 절차 (흡수 source 없음, 새로 작성, 150-250 lines) |
| `plugins/bobs-plugin/skills/context-map-architecture-workspace/gaps/skill-context-map-architecture.GAP.md` | Create (skill-creator §3) | GAP report |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (§3.2 갱신) | "TBD per Step 2" → 실제 내용 |
| `plugins/bobs-plugin/skills/agents-md-author/` | Delete (`git rm -r`) | deprecate |
| `plugins/bobs-plugin/skills/agents-md-author-workspace/` | Delete | deprecate (GAP 시점 스냅샷 보존 의무 없음) |
| `plugins/bobs-plugin/skills/context-map-builder/` | Delete | deprecate |
| `plugins/bobs-plugin/skills/context-map-builder-workspace/` | Delete | deprecate |
| `plugins/bobs-plugin/skills/claude-md-improver/` | Delete | deprecate (적극 흡수) |
| `plugins/bobs-plugin/.claude-plugin/plugin.json` | Edit (description) | claude-md-improver 제거 + context-map-architecture 추가 |
| `.claude-plugin/marketplace.json` | Edit (description) | 동일 |
| `README.md` | Edit (file tree + skill 표 + namespace 안내 + migration notes) | 3 자산 참조 → 신규 skill |
| `THIRD_PARTY_NOTICES.md` | Edit (표 행 1개 제거 + LICENSE 단락 갱신 + 흡수 attribution 단락 추가) | claude-md-improver 흡수 표기 |

`third_party_licenses/claude-md-management-LICENSE` 는 *유지* — 흡수된 `references/claude-md-write.md` 의 Apache-2.0 LICENSE 보존 의무.

---

## Note on TDD for skill creation

skill-creator 자체가 GAP-driven (draft → 분석 → 수정 → 재분석) 사이클이므로 본 plan 의 Task 2 는 *외부* TDD 가 아닌 *skill-creator 내부* GAP loop 에 의존한다. Task 3 (workflow doc) 와 Task 4 (deprecation) 는 doc 작업이라 *verify-baseline → change → verify-result → commit* 패턴.

---

### Task 1: skill-creator 호출 준비 — intent brief

**Files:**
- (편집 없음 — preparation only)

skill-creator §0 Capture Intent 가 사용자에게 묻기 전, main session 이 intent 를 사전 정리해 한 번에 제공한다. 본 Task 는 정보 추출만 — commit 없음.

- [ ] **Step 1: 기존 3 skill 본문·references 읽기 (흡수 대상 식별)**

다음 파일을 모두 Read 한다:

- `plugins/bobs-plugin/skills/agents-md-author/SKILL.md` (154 lines — Phase 1-3 + output + common failures)
- `plugins/bobs-plugin/skills/agents-md-author/references/section-guide.md` (114 lines — 섹션별 포함/제외 표 + 책임 누수 점검 + 길이 진단 + 도구 공통성)
- `plugins/bobs-plugin/skills/agents-md-author/references/template.md` (89 lines — 8-section 골격)
- `plugins/bobs-plugin/skills/context-map-builder/SKILL.md` (155 lines — Phase 1-3 + output + common failures)
- `plugins/bobs-plugin/skills/context-map-builder/references/inventory-guide.md` (135 lines — 자원 inventory 절차)
- `plugins/bobs-plugin/skills/context-map-builder/references/template.md` (58 lines — 표 골격 + 빈 칸 채우는 순서 + 길이 가이드)
- `plugins/bobs-plugin/skills/claude-md-improver/SKILL.md` (179 lines — Phase 1-5 (Discovery / Quality / Report / Updates / Apply))
- `plugins/bobs-plugin/skills/claude-md-improver/references/quality-criteria.md` (109 lines — 6 criteria 점수 rubric)
- `plugins/bobs-plugin/skills/claude-md-improver/references/update-guidelines.md` (150 lines — What TO add / What NOT to add + diff format + checklist)
- `plugins/bobs-plugin/skills/claude-md-improver/references/templates.md` (253 lines — Recommended Sections + key-principles)

claude-md-improver 합계 = 179 + 109 + 150 + 253 = **691 lines** (≤200 lines 압축 = 29%).

각 파일의 *흡수 대상 영역* 을 식별:

| 출처 | 흡수 위치 | 흡수 깊이 |
|---|---|---|
| agents-md-author SKILL.md (Phase 1-3 + output + common failures) | `references/agents-md-write.md` 본문 | full procedure |
| agents-md-author/references/section-guide.md (전체) | `references/agents-md-write.md` 안에 통합 | 핵심 섹션 표 + 책임 누수 + 길이 진단 |
| agents-md-author/references/template.md (전체) | `references/agents-md-write.md` 안에 통합 | 8-section 골격 코드 블록 |
| context-map-builder SKILL.md (Phase 1-3 + output + common failures) | `references/context-map-write.md` 본문 | full procedure |
| context-map-builder/references/inventory-guide.md | `references/context-map-write.md` 안에 통합 | 핵심 명령 + 카테고리 표 + 갱신 시 diff |
| context-map-builder/references/template.md | `references/context-map-write.md` 안에 통합 | 표 골격 + 길이 가이드 |
| claude-md-improver SKILL.md (Phase 1-5) | `references/claude-md-write.md` (≤200 lines) | Discovery / Quality / Effect gate / Apply 압축 |
| claude-md-improver/references/quality-criteria.md | `references/claude-md-write.md` 안에 통합 | rubric 표 (점수 본문은 한 줄로 압축) |
| claude-md-improver/references/update-guidelines.md | `references/claude-md-write.md` 안에 통합 | What TO/NOT 표 (예시 코드 제외, 한 줄 규칙만) + checklist |
| claude-md-improver/references/templates.md | `references/claude-md-write.md` 안에 통합 | Recommended Sections 목록만 (섹션 이름 + 1줄 설명, 코드 블록 0개) |
| (없음 — fresh) | `references/docs-tree-write.md` | 새로 작성 — docs/architecture/decisions/domain/integrations/workflows/security skeleton 절차 (Spec §4.2 docs 트리 전반 책임) |

- [ ] **Step 2: skill-creator §0 답안 정리 (메모리만)**

| # | skill-creator §0 질문 | 답 |
|---|---|---|
| 1 | 재사용 책임 (한 문장) | 프로젝트 docs 트리 (`AGENTS.md` / `CLAUDE.md` / `docs/agent/context-map.md` / `docs/agent/roles.md` skeleton / `docs/architecture.md` skeleton / `docs/decisions/` / `docs/domain/` skeleton / `docs/integrations/` / `docs/workflows/` / `docs/security.md`) 의 설계 + 작성을 한 묶음 호출로 처리 |
| 2 | 트리거 (1-3개) | "AGENTS.md 만들어줘", "context map 갱신", "docs 정리", "harness 문서 인덱싱", "CLAUDE.md audit" |
| 3 | Negative trigger (≥1) | 자원 타입 결정 (`resource-design`), 개별 skill/agent/hook 작성 (creator 스킬), 검증 인프라 (`evaluation-loop-design`), `docs/architecture.md` / `docs/domain/` 의 *본문 prose* (skeleton 까지만) |
| 4 | 호출자가 산출물로 무엇을 하나 | Document Plan 검토 → 승인 → Applied Changes 목록을 다음 작업 입력으로 / follow-up 항목으로 후속 design skill 진입 |
| 5 | 부수 효과 | 다수 파일 작성·수정 — 이중 effect gate: design 단계 Document Plan 승인 + 각 파일 write 직전 1차 확인 |
| 6 | scope | plugin (`plugins/bobs-plugin/skills/context-map-architecture/`) |

- [ ] **Step 3: skill-creator 첫 메시지 한 줄 brief 작성**

skill-creator 호출 시 사용자 첫 메시지로 전달할 single-shot brief (의도 캡처 비용 절감):

```
name: context-map-architecture
scope: plugin (plugins/bobs-plugin/skills/context-map-architecture/)
책임: docs 트리 (AGENTS.md / CLAUDE.md / docs/agent/context-map.md / docs/agent/roles.md skeleton /
  docs/architecture.md skeleton / docs/decisions/ / docs/domain/ skeleton / docs/integrations/ /
  docs/workflows/ / docs/security.md) 의 설계 + 작성
트리거: "AGENTS.md 만들어줘", "context map 갱신", "docs 정리", "harness 문서 인덱싱", "CLAUDE.md audit"
negative: 자원 타입 결정 (resource-design), 개별 자원 작성 (creator), 검증 인프라 (evaluation-loop-design),
  docs/architecture.md / docs/domain/ 본문 prose
spec format: Inventory + Gaps + Document Plan + Applied Changes (spec_version v1,
  자체 작성 패턴이라 Execution Plan dispatch 대신 Applied Changes 가 결과)
effect gate: Document Plan 사용자 승인 후 파일 write
references 4개 (main session 이 §2 SKILL.md draft 직후 mini-gate 거쳐 직접 작성):
  - references/agents-md-write.md (agents-md-author 흡수, MIT, 250-350 lines)
  - references/context-map-write.md (context-map-builder 흡수, MIT, 300-400 lines)
  - references/claude-md-write.md (claude-md-improver 흡수, Apache-2.0 attribution, ≤200 lines — Spec §10 Decision 3 강제)
  - references/docs-tree-write.md (fresh, MIT — docs/architecture/domain/decisions/integrations/workflows/security skeleton 작성 절차, 150-250 lines, Spec §4.2 docs 트리 전반 책임)
```

본 brief 는 Task 2 Step 1 에서 skill-creator 호출 시 입력.

---

### Task 2: skill-creator 로 신규 skill 작성 + references 흡수 (Step 2a/2b)

**Files:**
- Create (skill-creator §2): `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/context-map-architecture/references/agents-md-write.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/context-map-architecture/references/context-map-write.md`
- Create (main session, §2 직후): `plugins/bobs-plugin/skills/context-map-architecture/references/claude-md-write.md`
- Create (main session, §2 직후, fresh): `plugins/bobs-plugin/skills/context-map-architecture/references/docs-tree-write.md`
- Create (skill-creator §3a): `plugins/bobs-plugin/skills/context-map-architecture-workspace/gaps/skill-context-map-architecture.GAP.md`

- [ ] **Step 1: skill-creator 호출 (intent 사전 제공)**

호출:

```
/skill-creator
```

첫 메시지: Task 1 Step 3 의 brief block 그대로 붙여넣기.

skill-creator §0 → §1 → §2 자체 흐름 진행. §2 시점 A gate (첫 파일 작성 전, SKILL.md 경로 + frontmatter + 본문 골격 + workspace 경로 제시) 에서 사용자 명시 승인.

예상 SKILL.md 구조 (skill-creator §2 가 SKILL-GUIDE.md 표준 골격 적용):
- Frontmatter: `name: context-map-architecture`, description (trigger + Do NOT 명시), `user-invocable: true` (사용자 직접 호출 가능)
- `# Context Map Architecture`
- `## When to Use` + `## When NOT to Use`
- `## Workflow`
  - `### Phase 1: Inventory & Inspect` — 자원 + docs 트리 스캔 (references/context-map-write.md §Inventory 인용)
  - `### Phase 2: Document Plan` — Inventory / Gaps / Document Plan 산출 (Effect gate 대상)
  - `### Phase 3: Apply` — Document Plan 승인 후 파일별 write (각 파일은 references/ 의 해당 절차 따름)
- `## Output Contract` — Inventory / Gaps / Document Plan / Applied Changes + no-op / blocked 케이스
- `## Common Failures`
- `## References` — agents-md-write.md / context-map-write.md / claude-md-write.md / docs-tree-write.md 인용

- [ ] **Step 2: references 작성 (skill-creator §2 SKILL.md draft 완료 직후, §3 GAP 분석 진입 전)**

skill-creator §2 의 SKILL.md 첫 쓰기가 끝난 시점에서 main session 이 직접 references 를 작성한다. skill-creator 의 시점 A gate 는 SKILL.md 1개 경로만 다루므로 (CONSTITUTION §3.3 effect gate 가 references 에는 적용되지 않는 누수 위험), main session 이 *별도 mini-gate* 를 거친다.

**(0) Mini-gate — references write 직전 사용자 승인**

각 references 파일을 쓰기 전에 다음 5가지를 한 묶음으로 사용자에게 제시한다 (CONSTITUTION §3.3 Effects Require Gates 의 본 plan 내 적용):

| 항목 | 내용 |
|---|---|
| 작성 경로 | 4개 절대 경로 (`agents-md-write.md` / `context-map-write.md` / `claude-md-write.md` / `docs-tree-write.md`) |
| Source 파일 | 각 reference 가 흡수하는 원본 파일 목록 + 줄 수 (Task 1 Step 1 의 흡수 대상 표 인용) |
| Target length | 각 파일 예상 줄 수 (250-350 / 300-400 / ≤200 / 150-250) |
| License / attribution | 각 파일의 라이센스 + 헤더에 박을 attribution 텍스트 |
| 압축 정책 | 어떤 원본 섹션을 그대로 / 표 형식으로 / 제외하는지 한 줄 |

사용자 명시 승인 (`go` / `proceed` / `진행`) 후 (a)-(d) 의 파일 write 로 진행. 사전 합의된 *묻지 말고 진행* 모드에서는 확인 없이 진행하되 본 mini-gate 의 5 항목은 응답에 기록.

**(a) `references/agents-md-write.md` 작성**

source: agents-md-author SKILL.md (Phase 1-3 + output + common failures) + section-guide.md (전체) + template.md (8-section 골격)
target length: 250-350 lines
content outline (헤더 → Phase → 표 → 출력 → 검증 → 길이 진단):

1. 헤더 (출처 표기)
2. Normative source 발췌 (harness-principles §4.1 AGENTS.md 행)
3. Phase 1 Inspect — 읽는 파일 목록 + 수집 항목 표 (SKILL.md Phase 1)
4. Phase 2 Draft — 8-section 골격 (template.md 본문 코드 블록) + 작성 원칙 (SKILL.md Phase 2)
5. 섹션별 포함/제외 표 (section-guide.md §"섹션별 가이드" 8개 표)
6. 책임 누수 점검 표 (section-guide.md §"책임 누수 점검 표")
7. Phase 3 Effect gate — 4가지 사전 제시 (SKILL.md Phase 3)
8. Output Contract (SKILL.md 그대로)
9. Common Failures (SKILL.md 그대로)
10. 길이 진단 + 도구 공통성 검증 (section-guide.md 마지막 두 섹션)

헤더:

```markdown
# AGENTS.md 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference. 원본은 (deprecated) `agents-md-author` skill 의 SKILL.md + references/section-guide.md + references/template.md 본문을 한 파일로 통합했다. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(b) `references/context-map-write.md` 작성**

source: context-map-builder SKILL.md (Phase 1-3 + output + common failures) + inventory-guide.md (전체) + template.md (전체)
target length: 300-400 lines
content outline:

1. 헤더 (출처 표기)
2. Normative source 발췌 (harness-principles §4.5 Context Map)
3. Phase 1 Inventory — Skill / Agent / Hook / Doc / Role inventory 절차 (inventory-guide.md 본문 + SKILL.md Phase 1)
4. Phase 2 Map — 작업 유형 표 + 매핑 원칙 (SKILL.md Phase 2)
5. 표 골격 (template.md 본문 코드 블록)
6. 빈 칸 채우는 순서 (template.md §"빈 칸 채우는 순서")
7. Phase 3 Effect gate — 5가지 사전 제시 (SKILL.md Phase 3)
8. Output Contract (SKILL.md 그대로)
9. Common Failures (SKILL.md 그대로)
10. 갱신 시 diff 절차 (inventory-guide.md §"갱신 시 diff")
11. 길이 가이드 (template.md §"길이 가이드")

헤더:

```markdown
# context-map.md 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference. 원본은 (deprecated) `context-map-builder` skill 의 SKILL.md + references/inventory-guide.md + references/template.md 본문을 한 파일로 통합했다. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(b2) `references/docs-tree-write.md` 작성** *(fresh — 흡수 source 없음, P1 보강)*

spec §4.2 의 자체 작성 범위는 AGENTS/CLAUDE/context-map 외에도 `docs/architecture.md` (skeleton), `docs/decisions/`, `docs/domain/` (skeleton), `docs/integrations/`, `docs/workflows/`, `docs/security.md` 를 포함한다. 이 6 종류의 docs 작성 절차는 기존 3 skill 에 없으므로 *새로 작성*. 본문 prose 는 사용자 작업으로 남기고 본 reference 는 *skeleton 작성 절차* 만 다룬다.

target length: 150-250 lines
content outline:

1. 헤더 (fresh — 출처 없음, MIT in-house)
2. Phase 1 Inspect — 현재 `docs/` 디렉토리 구조 + 누락된 카테고리 식별
3. Phase 2 Skeleton write — 6 종류별 skeleton template (각 한 단락):
   - `docs/architecture.md` — 섹션 헤더 (Overview / Modules / Data Flow / Dependencies / Build & Deploy) + 한 줄 placeholder + "사용자가 채워야 함" 안내 코멘트
   - `docs/decisions/` — ADR 한 개당 한 파일 패턴 + 표준 ADR 헤더 (Context / Decision / Consequences / Date) + 첫 파일 (`0001-record-architecture-decisions.md`) skeleton
   - `docs/domain/` — 도메인 용어집 + 비즈니스 룰 한 파일 패턴 + 한 단락 placeholder
   - `docs/integrations/` — 외부 시스템별 한 파일 패턴 (auth / webhook / API contract / failure mode 섹션)
   - `docs/workflows/` — 운영 절차 한 파일 패턴 (review-process / release / oncall 등)
   - `docs/security.md` — 위협 모델 + 권한 경계 + 사고 대응 섹션 헤더만
4. Skeleton 의 정의 (spec §4.2 인용): "섹션 헤더 + 각 섹션 1-2 줄 placeholder + 무엇을 채워야 하는지 안내 코멘트. 본문 prose 자체는 작성하지 않음"
5. Effect gate — Phase 2 가 다수 파일을 새로 만드므로 작성 직전 사용자 승인 (어떤 파일을 만들지 목록 제시)
6. 길이 / 책임 누수 점검 — 도메인 본문이 누수되면 docs/* 로 이동, AGENTS.md 책임 흡수면 agents-md-write.md 로 환원

헤더:

```markdown
# docs/* 트리 skeleton 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference. 흡수 source 없음 — 본 plan (Step 2, P1#4 보강) 에서 새로 작성. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
```

**(c) `references/claude-md-write.md` 작성**

source: claude-md-improver SKILL.md (179 lines) + quality-criteria.md (109) + update-guidelines.md (150) + templates.md (253) = **691 lines** 원본
target length: **≤200 lines (Spec §10 Decision 3 강제 제약 — 691→200 은 29% 압축)**

Spec §10 Decision 3 의 "핵심 워크플로우만" 의도를 강조해 **코드 블록을 최소화하고 표 중심으로 정리**. 원본의 channel/예시/설명 단락 대부분 제외 — 본 reference 는 *call-out checklist* 역할이지 학습 자료가 아니다.

content outline (총 6 항목, 코드 블록 ≤ 2개):

1. 헤더 (Apache-2.0 attribution — 본 파일에서 필수, 아래 헤더 블록 참고)
2. Phase 1 Discovery — `find . -name "CLAUDE.md"` 한 줄 (코드 블록 1) + File Types & Locations 표 (5 행, SKILL.md Phase 1)
3. Phase 2 Quality — 6 criteria + Quality Scores 표 (rubric 본문 점수 풀이 *전부 한 행으로 압축* — 예: "20=comprehensive · 15=minor gaps · 10=basic · 5=sparse · 0=missing")
4. Phase 3-5 (Report → Approval → Apply) — **절차 한 단락** + Validation Checklist 6 항목 (update-guidelines 마지막 — *코드 블록 없음*, 보고 형식·diff 형식은 호출자가 보일 형태이므로 본 reference 본문에는 포함하지 않음, SKILL.md 본문이 절차 흐름만 기술)
5. What TO add / What NOT to add — 표 2열 (5 행씩, 예시 코드 *전혀 포함하지 않음* — "command 발견 시 추가", "obvious code info 는 추가하지 않음" 등 한 줄 규칙만)
6. CLAUDE.md Recommended Sections — 섹션 이름 + 1줄 설명만 (templates.md 의 코드 블록은 *포함하지 않음* — section 골격은 사용자 작성 시점에 SKILL.md 가 직접 안내)

작성 시 *코드 블록 총 1개만* (Phase 1 의 find 명령). 표·짧은 산문 위주. 줄 수가 200 을 넘으면 *항목 6 (Sections 목록) 의 1줄 설명 압축* 또는 *Validation Checklist 6→3 핵심만* 순으로 추가 컷.

헤더 (**Apache-2.0 attribution 필수 — Spec §10 Decision 3 + skill-creator/references/red-green-refactor.md 패턴 따름**):

```markdown
# CLAUDE.md 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference.
>
> **출처**: vendored from `claude-plugins-official/plugins/claude-md-management/skills/claude-md-improver` (Apache-2.0). 본 파일은 원본 `SKILL.md` + `references/quality-criteria.md` + `references/update-guidelines.md` + `references/templates.md` 를 압축·재구성해 self-contained 형태로 작성. 원본 LICENSE 사본은 `plugins/bobs-plugin/third_party_licenses/claude-md-management-LICENSE` 유지.
```

작성 후 verify:

```bash
wc -l plugins/bobs-plugin/skills/context-map-architecture/references/claude-md-write.md
```

Expected: ≤200. 초과 시 quality-criteria 의 점수 본문 추가 압축.

- [ ] **Step 3: skill-creator §3 GAP 분석 진행 (interactive) — references 까지 target 확장**

skill-creator 가 §3a 에서 workspace 생성:

```bash
mkdir -p plugins/bobs-plugin/skills/context-map-architecture-workspace/gaps
```

§3b (위임 권장) 또는 §3c (인라인) 로 GAP 분석.

**중요: skill-creator §3b 의 default 위임 prompt 는 분석 target 을 `<SKILL_PATH>/SKILL.md` 1개로 제한** (skill-creator SKILL.md line 156, 171 확인 — `분석 대상은 외부 경로 1건` 명시). 본 plan 의 references 4개는 *흡수된 핵심 본문* 이므로 SKILL.md 와 동일 수준의 GAP 적용 대상. main session 은 위임 prompt 의 target 목록을 다음 5개 경로로 *명시 확장* 한다:

```
분석 대상 (확장):
  - <SKILL_PATH>/SKILL.md
  - <SKILL_PATH>/references/agents-md-write.md
  - <SKILL_PATH>/references/context-map-write.md
  - <SKILL_PATH>/references/claude-md-write.md
  - <SKILL_PATH>/references/docs-tree-write.md
각 파일을 같은 GAP-FORMAT §9 형식으로 평가하고 finding 의 `evidence` 필드에 어느 파일의 어느 위치인지 명시한다.
```

분석 깊이:
- SKILL.md: 표준 skill GAP (activation / scope / output contract / effect gate / verification / overlap)
- references 각각: 흡수 절차 완전성 (원본 핵심이 모두 반영되었나) + length budget (≤200 / 150-250 등) + 도구 공통성 (`agents-md-write.md` 가 Codex/Gemini 도구 중립인가) + Apache-2.0 attribution 정합성 (`claude-md-write.md` 만 해당)

skill-creator §4 Final Decision 분기:
- `PASS` → §5 진행
- `PASS_WITH_NOTES` → 옵션 적용 후 §5
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침 — references 도 mini-gate 거침) 후 §3 재실행 (라운드 카운트 +1)
- 5 라운드 초과 → `NEEDS_REVIEW` 사용자 보고, 본 Task 일시 중단

- [ ] **Step 3b: references 흡수 audit (skill-creator GAP 외 추가 검증)**

skill-creator GAP 가 PASS 라도 *흡수 본문 누락* 은 잡지 못할 수 있음 (원본 비교는 GAP 검증 축이 아님). 별도 audit:

```bash
# 각 reference 의 핵심 섹션이 빠지지 않았는지 keyword 검사
echo "--- agents-md-write.md 흡수 검증 ---"
for kw in "Phase 1 Inspect" "Phase 2 Draft" "Phase 3 Effect gate" "Output Contract" \
          "Common Failures" "책임 누수" "길이 진단" "도구 공통성" "8-section"; do
  grep -q "$kw" plugins/bobs-plugin/skills/context-map-architecture/references/agents-md-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- context-map-write.md 흡수 검증 ---"
for kw in "Phase 1 Inventory" "Phase 2 Map" "Phase 3 Effect gate" "Output Contract" \
          "Common Failures" "inventory-guide" "갱신 시 diff" "표 골격"; do
  grep -q "$kw" plugins/bobs-plugin/skills/context-map-architecture/references/context-map-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- claude-md-write.md 흡수 검증 ---"
for kw in "Apache-2.0" "claude-md-management" "Phase 1 Discovery" "Quality" \
          "Recommended Sections" "Validation Checklist"; do
  grep -q "$kw" plugins/bobs-plugin/skills/context-map-architecture/references/claude-md-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done

echo "--- docs-tree-write.md 흡수 검증 ---"
for kw in "Phase 1 Inspect" "Phase 2 Skeleton" "architecture.md" "decisions" "domain" \
          "integrations" "workflows" "security.md" "Effect gate"; do
  grep -q "$kw" plugins/bobs-plugin/skills/context-map-architecture/references/docs-tree-write.md \
    && echo "  ok: $kw" || echo "  MISSING: $kw"
done
```

Expected: 모든 항목 `ok`. `MISSING` 가 1건이라도 있으면 해당 reference 를 다시 작성 (Step 2 (a)-(d) 의 outline 점검 → Edit 으로 보완 → Step 3 재실행).

- [ ] **Step 4: GAP 리포트 경로 + Final Decision 검증**

```bash
ls plugins/bobs-plugin/skills/context-map-architecture-workspace/gaps/skill-context-map-architecture.GAP.md
grep -E "Final Decision|^## 16" plugins/bobs-plugin/skills/context-map-architecture-workspace/gaps/skill-context-map-architecture.GAP.md
```

Expected: 파일 존재 + `Final Decision: PASS` 또는 `PASS_WITH_NOTES`. 그 외면 본 Task 미완료 — Step 3 으로 복귀.

- [ ] **Step 5: skill 디렉토리 구조 최종 verify**

```bash
ls plugins/bobs-plugin/skills/context-map-architecture/
ls plugins/bobs-plugin/skills/context-map-architecture/references/
wc -l plugins/bobs-plugin/skills/context-map-architecture/SKILL.md \
      plugins/bobs-plugin/skills/context-map-architecture/references/*.md
```

Expected:
- SKILL.md 존재
- references/ 에 **4개 파일** (agents-md-write.md, context-map-write.md, claude-md-write.md, docs-tree-write.md)
- claude-md-write.md ≤ 200 lines (Spec §10 Decision 3)
- agents-md-write.md ≈ 250-350 lines
- context-map-write.md ≈ 300-400 lines
- docs-tree-write.md ≈ 150-250 lines

- [ ] **Step 6: Commit — 신규 skill + references + GAP report**

```bash
git add plugins/bobs-plugin/skills/context-map-architecture/ \
        plugins/bobs-plugin/skills/context-map-architecture-workspace/

git commit -m "$(cat <<'EOF'
Add context-map-architecture skill (Step 2a/2b)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 2 + §4.2

- skills/context-map-architecture/SKILL.md (Inventory / Document Plan / Apply 3-phase)
- references/agents-md-write.md (agents-md-author 흡수, MIT in-house)
- references/context-map-write.md (context-map-builder 흡수, MIT in-house)
- references/claude-md-write.md (claude-md-improver 흡수, Apache-2.0 attribution, ≤200 lines)
- references/docs-tree-write.md (fresh — docs/architecture/domain/decisions/integrations/workflows/security skeleton, MIT in-house)
- workspace/gaps/ 의 GAP 리포트 — Final Decision PASS / PASS_WITH_NOTES

기존 3 skill deprecation 은 Step 2d 별도 commit.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: workflow doc §3.2 채움 (Step 2c)

**Files:**
- Modify: `plugins/bobs-plugin/references/harness-installation-workflow.md`

- [ ] **Step 1: Baseline 확인 — 현재 §3.2 placeholder 위치**

```bash
grep -n "^### 3\.\|^- 3\.\|TBD per Step 2\|## 3\." plugins/bobs-plugin/references/harness-installation-workflow.md
```

Expected: `## 3. Phase 1 Design Skills` 헤더 + 3 줄 (3.1 / 3.2 / 3.3) placeholder. 모두 "TBD per Step N" 포함.

- [ ] **Step 2: §3 본문 갱신 — 3.2 하위 섹션 채움**

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/references/harness-installation-workflow.md`
- old_string:

```
## 3. Phase 1 Design Skills

TBD per Step 2-4. 각 design skill 작성 완료 시 본 섹션의 해당 하위 섹션을 채운다.

- 3.1 `resource-design` (TBD per Step 3)
- 3.2 `context-map-architecture` (TBD per Step 2)
- 3.3 `evaluation-loop-design` (TBD per Step 4)

각 하위 섹션 형식: *trigger* / *inspect 도메인* / *spec format* / *effect gate* / *handoff*.
```

- new_string:

```
## 3. Phase 1 Design Skills

각 design skill 의 *trigger* / *inspect 도메인* / *spec format* / *effect gate* / *handoff* 정의. 3.1 과 3.3 은 후속 Step (3 / 4) 에서 채운다.

- 3.1 `resource-design` (TBD per Step 3)

### 3.2 `context-map-architecture`

**Trigger**:

- 사용자가 `AGENTS.md` / `CLAUDE.md` / `docs/agent/context-map.md` / `docs/` 트리 작성·정리·갱신 요청
- 빈 프로젝트에서 "처음부터 하네스" 요청 (Routing 표 §2 마지막 행)
- 자원 (skill / agent / hook) 추가·삭제 후 인덱싱 갱신 필요

**Inspect 도메인**:

- 현재 docs 트리 (`docs/`, `docs/agent/`, `docs/decisions/`, `docs/domain/`, `docs/integrations/`, `docs/workflows/`, `docs/security.md`)
- 인덱싱 누락 (`docs/README.md`, `docs/agent/context-map.md`)
- 책임 누수 (CLAUDE.md 가 AGENTS.md 책임 침범, README 가 작업 계약 흡수, 등)
- 자원 inventory — `references/context-map-write.md` §Inventory 절차 (skill / agent / hook / doc / role)

**Spec format** (workflow doc §4 의 공통 인터페이스 적용):

```markdown
# Harness Installation Spec — context-map

> Generated by: context-map-architecture
> Date: <iso8601>
> Trigger: <user request>
> spec_version: v1

## Inventory
## Gaps                     — 없는 문서 + 누락 인덱스 + 책임 누수
## Document Plan            — 작성/수정/이동 항목 + 각 파일 골격
## Applied Changes          — 실제 작성/수정한 파일 목록 (자체 작성 후 갱신)
```

`Document Plan` 은 §4 표준 섹션의 `Plan` 변형, `Applied Changes` 는 `Execution Plan` 의 자체 작성 패턴 변형 (dispatch 없이 직접 write 한 결과).

**Effect gate** (이중):

- 1단계 (design): Document Plan 사용자 검토 + 승인 (CONSTITUTION §3.3)
- 2단계 (apply): 각 파일 write 직전 경로·종류·요약 1회 확인 — `references/agents-md-write.md` Phase 3, `context-map-write.md` Phase 3, `claude-md-write.md` Phase 4-5 (Targeted Updates → Apply), `docs-tree-write.md` Phase 2 (skeleton write) 의 각 절차

**Handoff**:

- 출력: Applied Changes 목록 + follow-ups (예: `docs/agent/roles.md` 정의 필요 / `docs/architecture.md` 본문 채움 필요 / 인용한 자원 미존재)
- main session 은 follow-up 항목을 후속 design skill (`resource-design` / `evaluation-loop-design`) 입력으로 활용
- no-op: 기존 docs 가 inventory 와 일치하고 책임 누수 없음 → `mode: no-op`
- blocked: 자원 0개 또는 작업 유형 0개로 표를 채울 수 없음 → `mode: blocked` + `needs_input` (예: "첫 자원 결정 — `resource-design` 먼저")

- 3.3 `evaluation-loop-design` (TBD per Step 4)
```

- [ ] **Step 3: Verify**

```bash
grep -c "^### 3\." plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 1 (3.2 만 채워짐)

grep "^### 3.2" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: "### 3.2 `context-map-architecture`"

grep -c "TBD per Step" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 6 (3.1 / 3.3 / 5 / 6 / 7 / 8 의 잔여 placeholder — Step 1 plan §Task 2 Step 2 verify 와 같은 식의 수)
# 정확한 수는 실제 grep 결과로 확인. 6 ± 1 이면 정상 (5,6 같은 묶음 섹션 placeholder).
```

- [ ] **Step 4: Commit**

```bash
git add plugins/bobs-plugin/references/harness-installation-workflow.md
git commit -m "$(cat <<'EOF'
Fill harness-installation-workflow §3.2 (context-map-architecture)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 2c

trigger / inspect / spec format / effect gate / handoff 5개 절. spec_version v1 명시.
Document Plan + Applied Changes 가 §4 표준 섹션의 자체 작성 패턴 변형임을 명시.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 4: deprecate 3 자산 + 메타 파일 정리 (Step 2d)

**Files:**
- Delete: `plugins/bobs-plugin/skills/agents-md-author/`
- Delete: `plugins/bobs-plugin/skills/agents-md-author-workspace/`
- Delete: `plugins/bobs-plugin/skills/context-map-builder/`
- Delete: `plugins/bobs-plugin/skills/context-map-builder-workspace/`
- Delete: `plugins/bobs-plugin/skills/claude-md-improver/`
- Modify: `plugins/bobs-plugin/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md`
- Modify: `THIRD_PARTY_NOTICES.md`

`plugins/bobs-plugin/references/README.md` 의 snapshot tree 의 `claude-md-improver/` 행은 *snapshot inventory* (`references/skills/claude-md-improver/`) 가리킴 — 운영본 (`skills/claude-md-improver/`) 삭제와 무관. 본 Step 에서 *no edit* (Step 6 에서 정합성만 확인).

- [ ] **Step 1: Baseline 확인 — 활성 참조 위치**

```bash
grep -n "agents-md-author\|context-map-builder\|claude-md-improver" \
  plugins/bobs-plugin/.claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  README.md \
  THIRD_PARTY_NOTICES.md
```

Expected (정확 수):
- `plugin.json`: 1 line (line 3 description, 마지막 `and claude-md-improver`)
- `marketplace.json`: 1 line (line 11 description, 마지막 `and claude-md-improver (Apache-2.0)`)
- `README.md`: 4 lines (line 20 file tree, line 46 표, line 67 namespace, line 80 migration notes)
- `THIRD_PARTY_NOTICES.md`: 2 lines (line 8 표 행, line 10 LICENSE 단락)

각 위치는 Step 2-5 에서 개별 처리.

- [ ] **Step 2: `plugin.json` description 갱신**

Read `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/.claude-plugin/plugin.json` line 1-10.

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/.claude-plugin/plugin.json`
- old_string: `"description": "Bob's bundle for Claude harness work: agent-skill-auditor + agent-skill-designer + harness-resource-design + skill-creator + agent-creator + hook-creator (with the agent-skill-best-practices GUIDE), plus vendored claude-automation-recommender and claude-md-improver.",`
- new_string: `"description": "Bob's bundle for Claude harness work: agent-skill-auditor + agent-skill-designer + harness-resource-design + context-map-architecture + skill-creator + agent-creator + hook-creator (with the agent-skill-best-practices GUIDE), plus vendored claude-automation-recommender.",`

주의:
- `agent-skill-designer` 는 Step 3 (별도 plan) 에서 deprecate 예정 — 본 Step 에선 유지
- `version` 필드 (`0.1.3`) 는 본 Step 에서 bump 하지 않음 (Spec §10 Decision 6: 모든 Step 완료 후 한 번 — 0.2.0 minor breaking)

- [ ] **Step 3: `marketplace.json` description 갱신**

Read `/Users/macpro/dev/bobs-plugin/.claude-plugin/marketplace.json` line 1-15.

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/.claude-plugin/marketplace.json`
- old_string: `"description": "Auditor + designer + harness-resource-design + skill-creator + agent-creator + hook-creator, with vendored claude-automation-recommender and claude-md-improver (Apache-2.0).",`
- new_string: `"description": "Auditor + designer + harness-resource-design + context-map-architecture + skill-creator + agent-creator + hook-creator, with vendored claude-automation-recommender (Apache-2.0).",`

- [ ] **Step 4: `README.md` 갱신 — 4곳**

Read `/Users/macpro/dev/bobs-plugin/README.md` 전체 (81 lines) 로 정확한 format 확인.

**(a) line 20 — file tree 의 `claude-md-improver/` 행 → `context-map-architecture/`:**

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/README.md`
- old_string: `│       │   └── claude-md-improver/           (vendored — Apache-2.0)`
- new_string: `│       │   └── context-map-architecture/    (in-house)`

주의: README file tree 는 *대표 자산* 만 나열 — 실제 plugin 의 모든 skill 을 다 적지 않음 (이미 stale, agents-md-author / context-map-builder / agent-creator / hook-creator 도 누락 상태). 본 Step 은 단순 1:1 치환만 — 전체 reorder 는 별도 follow-up.

**(b) line 46 — skill 표의 `claude-md-improver` 행 → `context-map-architecture`:**

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/README.md`
- old_string: `` | `claude-md-improver` | vendored from `claude-plugins-official/claude-md-management` (Apache-2.0) | Audit and improve `CLAUDE.md` files. | ``
- new_string: `` | `context-map-architecture` | in-house | Design + write the docs tree (AGENTS.md / CLAUDE.md / docs/agent/context-map.md / etc.). Absorbs the former `agents-md-author`, `context-map-builder`, and vendored `claude-md-improver` (see THIRD_PARTY_NOTICES.md for Apache-2.0 attribution). | ``

**(c) line 67 — `/plugin install` 후 namespace 안내:**

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/README.md`
- old_string: `- Skills resolve as \`/bobs-plugin:harness-resource-design\`, \`/bobs-plugin:skill-creator\`, \`/bobs-plugin:claude-automation-recommender\`, \`/bobs-plugin:claude-md-improver\`.`
- new_string: `- Skills resolve as \`/bobs-plugin:harness-resource-design\`, \`/bobs-plugin:context-map-architecture\`, \`/bobs-plugin:skill-creator\`, \`/bobs-plugin:claude-automation-recommender\`.`

**(d) line 80 — migration notes:**

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/README.md`
- old_string: `- The marketplace copies of \`skill-creator\`, \`claude-automation-recommender\`, and \`claude-md-improver\` can be uninstalled if you want this plugin to be the sole provider (otherwise both will appear under their respective namespaces and Claude will route based on description match).`
- new_string: `- The marketplace copies of \`skill-creator\` and \`claude-automation-recommender\` can be uninstalled if you want this plugin to be the sole provider (otherwise both will appear under their respective namespaces and Claude will route based on description match).`

- [ ] **Step 5: `THIRD_PARTY_NOTICES.md` 갱신 — 표 행 제거 + LICENSE 단락 갱신 + 흡수 attribution 단락 추가**

Read `/Users/macpro/dev/bobs-plugin/THIRD_PARTY_NOTICES.md` 전체 (12 lines) 로 확인.

**(a) Line 8 — vendored 표에서 `claude-md-improver` 행 삭제:**

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/THIRD_PARTY_NOTICES.md`
- old_string:
```
| `plugins/bobs-plugin/skills/claude-automation-recommender/` | `claude-plugins-official/plugins/claude-code-setup/skills/claude-automation-recommender` | Apache-2.0 | `third_party_licenses/claude-code-setup-LICENSE` |
| `plugins/bobs-plugin/skills/claude-md-improver/` | `claude-plugins-official/plugins/claude-md-management/skills/claude-md-improver` | Apache-2.0 | `third_party_licenses/claude-md-management-LICENSE` |
```
- new_string:
```
| `plugins/bobs-plugin/skills/claude-automation-recommender/` | `claude-plugins-official/plugins/claude-code-setup/skills/claude-automation-recommender` | Apache-2.0 | `third_party_licenses/claude-code-setup-LICENSE` |
```

**(b) Line 10 — "No upstream vendored files have been modified" 문장 + LICENSE 단락의 in-house 자산 목록 갱신:**

원문에는 "No upstream vendored files have been modified" 한 문장이 있으나, 본 Step 후로는 *압축·재구성된 흡수 excerpts* 가 새로 등장한다 — 그 둘을 구분해야 한다. 두 변경을 단일 Edit 으로:

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/THIRD_PARTY_NOTICES.md`
- old_string (line 10 전체):

```
No upstream vendored files have been modified. Refer to each `LICENSE` for the full upstream license terms; the root `LICENSE` (MIT) of this repo applies only to original work (manifests, README, agent-skill-best-practices GUIDE corpus, and the harness-resource-design / skill-creator / agent-creator / hook-creator / agents-md-author / context-map-builder skill/agents authored by the repo owner).
```

- new_string:

```
No upstream vendored files (the directories listed in the table above) have been modified — they remain byte-for-byte copies of upstream. Compressed/re-structured excerpts of other upstream skills are tracked separately in the per-skill paragraphs below. Refer to each `LICENSE` for the full upstream license terms; the root `LICENSE` (MIT) of this repo applies only to original work (manifests, README, agent-skill-best-practices GUIDE corpus, and the harness-resource-design / context-map-architecture / skill-creator / agent-creator / hook-creator skill/agents authored by the repo owner).
```

**(c) Line 12 끝 — skill-creator 흡수 단락 다음에 context-map-architecture 흡수 단락 추가:**

원본 markdown 의 line 12 (skill-creator/writing-skills 흡수 단락) 다음에 빈 줄 + 신규 단락을 추가한다. fence 가 markdown 본문을 감싸지 않도록 (이전 plan 의 ``` 중첩 문제 회피), Edit 의 old_string / new_string 은 원문 평문 그대로:

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/THIRD_PARTY_NOTICES.md`
- old_string (line 12 끝, `superpowers-LICENSE`.` 로 끝나는 문장 전체):

```
`skill-creator/references/red-green-refactor.md` and `skill-creator/references/trigger-eval.md` contain brief excerpts originally from `writing-skills` (MIT, `claude-plugins-official/plugins/superpowers/skills/writing-skills`), restructured for self-containment within `skill-creator`. The upstream `writing-skills` directory is no longer vendored in this repo, but the MIT terms continue to apply to those excerpts; attribution is provided in each excerpt file, and the upstream `LICENSE` is preserved as `third_party_licenses/superpowers-LICENSE`.
```

- new_string (위 단락 그대로 + 빈 줄 + 신규 단락):

```
`skill-creator/references/red-green-refactor.md` and `skill-creator/references/trigger-eval.md` contain brief excerpts originally from `writing-skills` (MIT, `claude-plugins-official/plugins/superpowers/skills/writing-skills`), restructured for self-containment within `skill-creator`. The upstream `writing-skills` directory is no longer vendored in this repo, but the MIT terms continue to apply to those excerpts; attribution is provided in each excerpt file, and the upstream `LICENSE` is preserved as `third_party_licenses/superpowers-LICENSE`.

`context-map-architecture/references/claude-md-write.md` contains compressed excerpts originally from `claude-md-improver` (Apache-2.0, `claude-plugins-official/plugins/claude-md-management/skills/claude-md-improver`), restructured for self-containment within `context-map-architecture`. The upstream `claude-md-improver` directory is no longer vendored in this repo, but the Apache-2.0 terms continue to apply to that excerpt; attribution is provided in the excerpt file header, and the upstream `LICENSE` is preserved as `third_party_licenses/claude-md-management-LICENSE`.
```

주의: 위 두 Edit 모두 원문 평문 — markdown fence 가 외부에서 감싸는 모양은 plan 문서 (이 plan) 의 표기 약속일 뿐. 실제 Edit tool 호출 시 fence 안쪽 텍스트만 old_string / new_string 으로 전달.

- [ ] **Step 6: `plugins/bobs-plugin/references/README.md` snapshot tree 정합성 확인 (대부분 no-op)**

```bash
ls plugins/bobs-plugin/references/skills/claude-md-improver/ 2>/dev/null
```

snapshot 사본이 존재 (확인됨 — 이전 grep 에서 `references/skills/claude-md-improver/SKILL.md` 등 존재) → 인덱스의 `claude-md-improver/      claude-md-management` 행은 정확 → **no edit**.

만약 snapshot 도 함께 청소해야 한다면 별도 사이클 — 본 Step 범위 밖.

- [ ] **Step 7: 3 자산 디렉토리 삭제 (`git rm -r`)**

```bash
git rm -r plugins/bobs-plugin/skills/agents-md-author
git rm -r plugins/bobs-plugin/skills/agents-md-author-workspace
git rm -r plugins/bobs-plugin/skills/context-map-builder
git rm -r plugins/bobs-plugin/skills/context-map-builder-workspace
git rm -r plugins/bobs-plugin/skills/claude-md-improver
```

주의:
- `third_party_licenses/claude-md-management-LICENSE` 는 *유지* (흡수된 `references/claude-md-write.md` 의 Apache-2.0 LICENSE 보존 의무 — skill-creator/writing-skills 의 `third_party_licenses/superpowers-LICENSE` 유지 패턴 동일).
- workspace 디렉토리의 GAP 리포트는 시점 스냅샷 — 삭제 시 git history 에 보존됨.

Verify:

```bash
ls plugins/bobs-plugin/skills/ | grep -E "agents-md-author|context-map-builder|claude-md-improver"
# Expected: 빈 결과

ls plugins/bobs-plugin/skills/
# Expected: context-map-architecture 가 새로 보임. 기존 3 자산 사라짐.
```

- [ ] **Step 8: 최종 verify — 활성 routing reference 0건 + 허용된 attribution/snapshot 만 잔류**

검증을 두 패스로 분리한다. (1) repo 전체 (루트 메타 파일 포함) 활성 routing 위치에서 0건, (2) 허용된 attribution / snapshot 위치만 잔류.

**(a) 활성 routing 위치 — 0건이어야 함**:

```bash
grep -rln "agents-md-author\|context-map-builder\|claude-md-improver" \
  README.md THIRD_PARTY_NOTICES.md LICENSE \
  .claude-plugin/ \
  plugins/bobs-plugin/.claude-plugin/ \
  plugins/bobs-plugin/agents/ \
  plugins/bobs-plugin/skills/ \
  plugins/bobs-plugin/references/AGENT-GUIDE.md \
  plugins/bobs-plugin/references/CONSTITUTION.md \
  plugins/bobs-plugin/references/GAP-FORMAT.md \
  plugins/bobs-plugin/references/GAP-ANALYSIS-PROMPT.md \
  plugins/bobs-plugin/references/HOOK-GUIDE.md \
  plugins/bobs-plugin/references/SKILL-GUIDE.md \
  plugins/bobs-plugin/references/harness-principles.md \
  plugins/bobs-plugin/references/harness-installation-workflow.md \
  --include="*.md" --include="*.json" 2>/dev/null \
  | grep -v "^THIRD_PARTY_NOTICES.md:" \
  | grep -v "/context-map-architecture/references/" \
  | grep -v "/agent-skill-auditor.md" \
  | grep -v "/agent-skill-designer.md"
```

Expected: **빈 결과**.

`grep -v` 제외:
- `THIRD_PARTY_NOTICES.md` — Step 5(c) 의 흡수 attribution 단락이 의도된 잔류 (다음 (b) 에서 확인)
- `/context-map-architecture/references/` — agents-md-write/context-map-write/claude-md-write 헤더의 흡수 출처 표기 (의도된 잔류)
- `agent-skill-auditor.md` / `agent-skill-designer.md` — Step 3 (별도 plan) 에서 처리될 잔존 (본 Step 범위 밖)

활성 routing 위치에서 1건이라도 잡히면 → Task 4 의 어느 Step 이 누락된 것 → 위치 파악 후 Edit 추가.

**(b) 허용된 attribution / snapshot — 예상 위치에서 잔류 확인**:

```bash
# 흡수 attribution (의도된 잔류)
grep -nE "agents-md-author|context-map-builder|claude-md-improver" \
  THIRD_PARTY_NOTICES.md \
  plugins/bobs-plugin/skills/context-map-architecture/references/agents-md-write.md \
  plugins/bobs-plugin/skills/context-map-architecture/references/context-map-write.md \
  plugins/bobs-plugin/skills/context-map-architecture/references/claude-md-write.md \
  2>/dev/null

# snapshot inventory (read-only 사본)
grep -n "claude-md-improver" plugins/bobs-plugin/references/README.md 2>/dev/null
ls -d plugins/bobs-plugin/references/skills/claude-md-improver/ 2>/dev/null
```

Expected:
- `THIRD_PARTY_NOTICES.md` — Step 5(c) 의 새 단락 (`compressed excerpts originally from claude-md-improver ...`)
- `agents-md-write.md` — Task 2 Step 2(a) 의 헤더 (출처 표기 — `(deprecated) agents-md-author`)
- `context-map-write.md` — Task 2 Step 2(b) 의 헤더 (출처 표기 — `(deprecated) context-map-builder`)
- `claude-md-write.md` — Task 2 Step 2(c) 의 헤더 (Apache-2.0 attribution — `claude-md-improver`)
- `references/README.md` snapshot index 1 행 (read-only)
- `references/skills/claude-md-improver/` 디렉토리 존재 (read-only snapshot)

각 위치가 *정확히 예상된 자리* 인지 확인. 예상 외의 매치가 있으면 추가 조사.

**(c) `docs/specs/` 와 `docs/plans/` (현재 plan/spec 자체)** — grep 대상이 아니지만 의도적으로 보존 (시점 스냅샷).

- [ ] **Step 9: Commit (deprecation)**

```bash
git add plugins/bobs-plugin/.claude-plugin/plugin.json \
        .claude-plugin/marketplace.json \
        README.md \
        THIRD_PARTY_NOTICES.md

git commit -m "$(cat <<'EOF'
Deprecate agents-md-author / context-map-builder / claude-md-improver (Step 2d)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 2d + §10 Decision 3

3 자산 디렉토리 삭제 (git rm -r):
- skills/agents-md-author/ (본문은 context-map-architecture/references/agents-md-write.md 로 흡수, MIT)
- skills/agents-md-author-workspace/ (GAP 시점 스냅샷, git history 에 보존)
- skills/context-map-builder/ (본문은 context-map-architecture/references/context-map-write.md 로 흡수, MIT)
- skills/context-map-builder-workspace/
- skills/claude-md-improver/ (본문은 context-map-architecture/references/claude-md-write.md 로 흡수,
  Apache-2.0 attribution — skill-creator/writing-skills 패턴 동일)

메타 파일 갱신:
- plugin.json, marketplace.json: description 에서 claude-md-improver 제거, context-map-architecture 추가
- README.md: file tree / skill 표 / namespace 안내 / migration notes 4곳 갱신
- THIRD_PARTY_NOTICES.md: vendored 표에서 claude-md-improver 행 제거, LICENSE 단락의
  in-house 자산 목록 갱신, claude-md-improver 흡수 attribution 단락 추가

유지:
- third_party_licenses/claude-md-management-LICENSE (흡수 reference 의 LICENSE 보존 의무)
- agent-skill-designer (Step 3 에서 별도 처리)
- references/skills/claude-md-improver/ snapshot (agent-skill-best-practices 운영 별개)

version bump 은 Step 7 (모든 Step 완료 후, 0.2.0 minor breaking) 에서 일괄.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Verify:

```bash
git log --oneline -3
git diff HEAD~1 HEAD --stat
```

Expected: 9+ files changed (4 metadata edits + 5 deleted dir trees). 직전 commit 들 (Task 2 / Task 3) 과 함께 본 Step 2 의 commit 3개가 모두 보임.

---

## Self-Review

### Spec coverage

Spec §7 Step 2 (2a / 2b / 2c / 2d) + §4.2 책임 범위 매핑:

| Spec item | Task |
|---|---|
| 2a 신규 skill draft + references 흡수 (3개) + fresh docs-tree-write.md (P1#4 보강) | Task 1 (preparation) + Task 2 Step 1-2 (skill-creator §2 + main session references write w/ mini-gate) |
| 2b GAP 분석 PASS (SKILL.md + 4 references target 확장) | Task 2 Step 3-4 (skill-creator §3-4 사이클 + references 흡수 audit Step 3b) |
| 2c workflow doc §3.2 채움 (3.1/3.2/3.3 numeric order) | Task 3 |
| 2d 3 자산 deprecate + plugin.json / THIRD_PARTY_NOTICES.md 갱신 | Task 4 |
| §4.2 docs 트리 전반 (architecture/decisions/domain/integrations/workflows/security skeleton) | `docs-tree-write.md` reference (Task 2 Step 2(b2), fresh) |

추가 작업 (spec §7 에 명시 안 됨이나 일관성·재현성 위해 필수):
- `marketplace.json` description 갱신 (Task 4 Step 3) — plugin.json 과 동일 내용 동기화
- `README.md` 4곳 갱신 (Task 4 Step 4) — 사용자가 보는 진입 문서
- `THIRD_PARTY_NOTICES.md` 흡수 attribution 단락 추가 + "No upstream vendored files modified" 문장 분기 (Task 4 Step 5b, 5c) — Spec §10 Decision 3 + skill-creator/writing-skills 패턴
- `references/README.md` snapshot 정합성 확인 (Task 4 Step 6) — 대개 no-op
- references mini-gate (Task 2 Step 2(0)) — skill-creator effect gate 가 references 를 다루지 않는 누수 보완 (CONSTITUTION §3.3 본 plan 내 적용)
- 활성 routing refs 검증 + 허용된 attribution refs 분리 (Task 4 Step 8 (a)/(b)) — codex-review P1 보강

### Placeholder scan

- 본 plan 본문에 TBD 없음.
- Task 2 Step 4 의 grep `^## 16` 은 GAP-FORMAT §16 (Final Decision) 헤더 — 실제 GAP 리포트 형식에 따라 매치.
- Task 3 Step 3 의 `Expected: 6 ± 1` 은 workflow doc §5/§6/§7/§8 placeholder 수 — 정확 값은 실제 grep 으로.

### Type consistency

- skill 이름 일관: `context-map-architecture`
- references 파일명 일관: `agents-md-write.md` / `context-map-write.md` / `claude-md-write.md` / `docs-tree-write.md` (총 **4개**)
- workspace 경로 일관: `plugins/bobs-plugin/skills/context-map-architecture-workspace/gaps/skill-context-map-architecture.GAP.md`
- deprecated 3 자산 이름 일관 (`agents-md-author` / `context-map-builder` / `claude-md-improver`)

### Spec §10 Decisions 반영

| Decision | 본 plan 반영 위치 |
|---|---|
| Decision 3 — claude-md-improver 핵심 워크플로우만 흡수 (≤200 lines) + Apache-2.0 attribution + LICENSE 사본 유지 | Task 2 Step 2(c) (target length ≤200, 헤더 attribution), Task 4 Step 5 (NOTICES 갱신), Task 4 Step 7 (LICENSE 유지 명시) |
| Decision 4 — skill-creator 동일 GAP 사이클 (PASS/PASS_WITH_NOTES 까지) | Task 2 Step 3-4 (skill-creator §3-4 명시 사용) |
| Decision 6 — Step 별 separate commit | Task 2 Step 6 / Task 3 Step 4 / Task 4 Step 9 — 총 3 commit (Step 2 안에서) |
| 사용자 입력: skill 은 skill-creator 로 생성 | Task 2 Step 1 (`/skill-creator` 호출) |

### 잠재 위험

1. **references 작성 시점과 skill-creator §2 effect gate 의 상호작용 (P1#3 보강 완료)**
   - Task 2 Step 2 는 skill-creator §2 SKILL.md 작성 직후, §3 GAP 분석 진입 직전에 끼어든다.
   - skill-creator 의 시점 A gate 는 SKILL.md 1개 경로만 다룸 — references 는 별도 write 가 자연스러우나 effect gate 누수.
   - **완화**: Task 2 Step 2(0) 의 mini-gate (작성 경로 / source / target length / license / 압축 정책 5 항목 사용자 승인) 추가 — CONSTITUTION §3.3 의 본 plan 내 적용.

2. **GAP 분석 5라운드 초과 → NEEDS_REVIEW**
   - skill-creator §4c (5 라운드 초과 시 NEEDS_REVIEW) 발동 시 본 Step 미완료.
   - **완화**: 사용자 보고 → 책임 재정의 (`SPLIT_ASSET`) 또는 자원 타입 재검토 (agent / hook?). 본 plan 범위 밖 → 후속 사이클로 이월.

3. **`claude-md-write.md` ≤200 lines 압축 난이도**
   - 원본 합계 (`SKILL.md` 179 + `quality-criteria.md` 109 + `update-guidelines.md` 150 + `templates.md` 253) = **691 lines** → 200 lines 로 **29% 압축**.
   - **완화**: Task 2 Step 2(c) 의 outline 을 6 항목으로 단축 (코드 블록 최대 1개, 나머지는 표·한 줄 산문). 점수 rubric 본문 (`20 points / 15 points / ...`) 은 표의 한 행으로 합침. update-guidelines 와 templates 의 예시 코드 블록은 *전부 제외* — section 골격은 SKILL.md 가 호출 시점에 직접 안내.
   - 초과 시 wc -l verify (Task 2 Step 2(c) 마지막) 에서 차단 → §5/§6 항목의 1줄 설명 추가 압축 → 재작성.

4. **`agent-skill-designer` 잔존 vs `plugin.json` description**
   - Task 4 Step 2 는 `agent-skill-designer` 를 description 에 유지 (Step 3 에서 deprecate 예정).
   - 본 Step 결과는 *과도기 상태* — description 에 designer 가 있지만 architecture 표에는 architectture 가 추가됨.
   - **수용**: Spec §10 Decision 6 의 *Step 별 separate commit* 원칙. designer 제거는 Step 3 의 책임.

5. **`README.md` 의 더 큰 staleness**
   - README 의 skill 표는 4개만 나열 (현재 plugin 의 11개 skill 중 일부만). 본 Step 은 claude-md-improver → context-map-architecture 1:1 치환만.
   - **수용**: README 전면 갱신은 본 Step 범위 밖 — follow-up 으로 기록.
   - **Follow-up**: Step 6 (workflow doc 최종 정리) 또는 Step 7 (creator skill 호환) 에서 README 전체 sync 검토.

6. **`marketplace.json` 의 `version` 필드**
   - description 만 갱신, `version: "0.1.3"` 은 유지.
   - Spec §10 Decision 6 명시: version bump 는 모든 Step 완료 후 한 번 (0.2.0).
   - **수용**: Step 7 에서 일괄 bump.

7. **Spec §9.4 deprecated stub 권고를 본 Step 이 의도적으로 waive**
   - Spec §9.4 는 "첫 1-2 cycle 동안 deprecated skill 의 SKILL.md 만 stub 으로 유지" 완화책을 제시한다.
   - 본 plan 의 Task 4 Step 7 은 stub 없이 `git rm -r` 즉시 삭제 — §9.4 권고와 충돌.
   - **waiver 근거**: Spec §2 Non-goals 가 "backward compatibility (deprecate 되는 기존 자산은 깨끗하게 제거)" 를 명시. §9.4 의 stub 완화는 *선택지* 이지 의무가 아니며, Non-goals 가 우선.
   - **수용 트레이드오프**: 사용자가 `/agents-md-author` / `/context-map-builder` / `/claude-md-improver` 옛 이름으로 호출 시 "skill not found" 응답 → main session 의 `/skill-creator` 또는 `/context-map-architecture` 로 다시 안내 필요. user-invocable 호출 빈도가 낮으므로 risk 작음.
   - **대안 (선택)**: 운영 우려가 크면 Task 4 Step 7 직전에 stub SKILL.md (frontmatter + 1줄 redirect) 3개 작성 추가 — 본 plan 은 기본 *깨끗한 삭제* 채택.

---

## Execution Handoff

Plan 완료 (Task 4 / commit 3). Spec §7 의 Step 2 (context-map-architecture skill 작성 + 3 자산 deprecate + workflow doc §3.2) 가 본 plan 에 담겼다.

후속:

- Step 3 (resource-design skill + agent-skill-designer subagent deprecate) — 별도 plan
- Step 4 (evaluation-loop-design skill) — 별도 plan
- Step 5 (evaluation-loop-runner skill, runtime)
- Step 6 (workflow doc 최종 정리 — §7 anti-patterns + §8 verification)
- Step 7 (creator skill spec 인터페이스 호환 확인 + version bump 0.2.0)

각 Step 은 본 Step 2 완료 후 새 plan 작성.

다음 단계 결정:

- **A. Subagent-Driven (recommended)** — Task 단위 fresh subagent 가 실행, 사이 검토. `superpowers:subagent-driven-development`
- **B. Inline Execution** — 본 세션에서 batch 실행. `superpowers:executing-plans`
- **C. Pause** — Step 3-7 plan 도 미리 준비 후 일괄 실행
