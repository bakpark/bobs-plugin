# Harness Installation — Step 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** harness-engineering.md 를 harness-principles.md (개념 모델) 로 정리하고 신규 harness-installation-workflow.md skeleton 을 만들어 후속 Step (2-7) 의 전제 조건을 갖춘다.

**Architecture:** rename + 본문 §5-7 삭제 + 신규 workflow doc skeleton + cross-link. doc-only 작업.

**Tech Stack:** git mv, markdown, Edit/Write tools

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §7 Step 1

**전체 migration 중 위치:** Step 1 of 7. Step 2-7 은 본 Step 완료 후 각각 별도 plan.

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/references/harness-engineering.md` | Rename → `harness-principles.md` | 개념 모델 (§1-4) 만 유지 |
| `plugins/bobs-plugin/references/harness-principles.md` (= renamed) | Edit (제목 변경 + §5-7 삭제 + cross-link) | 개념 모델 souce of truth |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Create | 이식 워크플로우 normative spec (skeleton) |
| `plugins/bobs-plugin/skills/agents-md-author/SKILL.md` | Edit (참조 갱신) | inline `harness-engineering` → `harness-principles` |
| `plugins/bobs-plugin/skills/agents-md-author/references/section-guide.md` | Edit (참조 갱신) | 동일 |
| `plugins/bobs-plugin/skills/context-map-builder/SKILL.md` | Edit (참조 갱신) | 동일 |

각 파일이 한 가지 책임만 갖는다. GAP report (workspace 내 시점 스냅샷) 는 갱신하지 않는다.

---

## Note on TDD for documentation

본 plan 은 doc 작업 중심이라 "write failing test first" 가 직접 적용되지 않는다. 대신 *verify-baseline → change → verify-result → commit* 패턴을 따른다:

- 각 Task 시작 전 baseline 확인 (grep / read)
- 변경 실행
- 변경 후 verify (grep / read / 형식 점검)
- commit

---

### Task 1: Rename + §5-7 삭제 + 활성 자산 참조 갱신

**Files:**
- Rename: `plugins/bobs-plugin/references/harness-engineering.md` → `harness-principles.md`
- Modify: 신규 `harness-principles.md` (제목 + §5-7 삭제)
- Modify: `plugins/bobs-plugin/skills/agents-md-author/SKILL.md`
- Modify: `plugins/bobs-plugin/skills/agents-md-author/references/section-guide.md`
- Modify: `plugins/bobs-plugin/skills/context-map-builder/SKILL.md`

- [ ] **Step 1: Baseline 확인 — 현재 파일 + 참조 위치**

```bash
ls plugins/bobs-plugin/references/harness-engineering.md
wc -l plugins/bobs-plugin/references/harness-engineering.md
grep -rln "harness-engineering" plugins/bobs-plugin/ --include="*.md" --include="*.json" \
  | grep -v "docs/specs/" | grep -v "workspace/gaps/"
```

Expected:
- 파일 존재, ≈640 lines
- 참조 위치 6곳 (SKILL.md 5개 + section-guide.md 1개) — workspace/gaps/ 의 GAP report 와 specs/ 의 spec 파일은 grep 제외 (시점 스냅샷이므로 보존)

- [ ] **Step 2: git mv 실행**

```bash
git mv plugins/bobs-plugin/references/harness-engineering.md \
       plugins/bobs-plugin/references/harness-principles.md
```

Verify:

```bash
ls plugins/bobs-plugin/references/harness-principles.md
git status --short | head -3
```

Expected: rename 성공 (`R  hareness-engineering.md -> harness-principles.md` 또는 동등).

- [ ] **Step 3: 제목 변경 — `# Coding Agent Environment` → `# Harness Principles`**

Read line 1-3 of `plugins/bobs-plugin/references/harness-principles.md` to confirm current title.

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/references/harness-principles.md`
- old_string: `# Coding Agent Environment`
- new_string: `# Harness Principles`

- [ ] **Step 4: §5 / §6 / §7 본문 삭제**

Read lines 378-385 to confirm §5 시작 boundary (예상: `## 5. 배치 설계`).
Read lines 638-641 to confirm §7 끝 boundary (예상: 마지막 줄 `## 7. 다음 단계` 의 마지막 항목).

`## 5. 배치 설계` 부터 파일 끝까지 삭제. 두 가지 방법 중 택1:

**Option A (single Edit):** old_string 에 §5 시작부터 §7 마지막 줄까지 전체 복사. new_string 빈 문자열.

**Option B (sed 또는 line range):** Edit 으로 처리하기 어려우면 Read → Write 로 line 1-379 만 다시 쓴다.

권장: Option A — Edit 도구가 정확. 길이가 매우 길면 §5, §6, §7 각각 별도 Edit.

Verify:

```bash
wc -l plugins/bobs-plugin/references/harness-principles.md
grep -c "^## " plugins/bobs-plugin/references/harness-principles.md
grep "^## " plugins/bobs-plugin/references/harness-principles.md
```

Expected:
- 줄 수 ≈ 378 (원본 640 - 약 262)
- 최상위 헤더: §1 §2 §3 §4 — 정확히 4개 (또는 본 파일 구조 따라 더 많을 수 있음 — §1-4 만 남아있는지 확인)

- [ ] **Step 5: 활성 자산 6곳 참조 갱신 — `harness-engineering` → `harness-principles`**

각 파일에 대해 Edit (replace_all true):

```
file_path: /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/agents-md-author/SKILL.md
old_string: harness-engineering
new_string: harness-principles
replace_all: true
```

```
file_path: /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/agents-md-author/references/section-guide.md
old_string: harness-engineering
new_string: harness-principles
replace_all: true
```

```
file_path: /Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/skills/context-map-builder/SKILL.md
old_string: harness-engineering
new_string: harness-principles
replace_all: true
```

주의: `harness-installation-workflow` 는 별개 파일명이므로 영향 없음. `harness-engineering` 만 정확히 매치.

- [ ] **Step 6: Verify — 본문 정리 + 참조 정리 확인**

```bash
head -5 plugins/bobs-plugin/references/harness-principles.md
wc -l plugins/bobs-plugin/references/harness-principles.md

grep -rln "harness-engineering" plugins/bobs-plugin/ --include="*.md" --include="*.json" \
  | grep -v "docs/specs/" | grep -v "workspace/gaps/"
```

Expected:
- 첫 줄: `# Harness Principles`
- 줄 수: §5-7 삭제 반영 (≈378)
- 활성 자산의 `harness-engineering` 참조: **빈 결과** (specs/ 와 workspace/gaps/ 제외)

- [ ] **Step 7: Commit**

```bash
git add plugins/bobs-plugin/references/harness-principles.md \
        plugins/bobs-plugin/skills/agents-md-author/ \
        plugins/bobs-plugin/skills/context-map-builder/

git commit -m "$(cat <<'EOF'
Split harness-engineering: rename to harness-principles + drop §5-7 (Step 1a/1b)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 1

- git mv harness-engineering.md → harness-principles.md
- 제목 변경: "Coding Agent Environment" → "Harness Principles"
- §5 (배치 설계), §6 (체크리스트), §7 (다음 단계) 본문 삭제
  → 신규 harness-installation-workflow.md 가 대체 (Step 1c, 별도 commit)
- 활성 자산 6곳의 참조 경로 갱신 (agents-md-author, context-map-builder)
- workspace/gaps/ 의 GAP report 와 docs/specs/ 의 spec 은 시점 스냅샷이라 보존

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Verify:

```bash
git log --oneline -1
git diff HEAD~1 HEAD --stat
```

Expected: 5+ files changed, rename + edits.

---

### Task 2: harness-installation-workflow.md skeleton 작성

**Files:**
- Create: `plugins/bobs-plugin/references/harness-installation-workflow.md`

- [ ] **Step 1: 신규 파일 작성 — §1 / §2 / §4 채움, §3 / §5 / §6 / §7-8 은 placeholder**

Write file with this exact content:

````markdown
# Harness Installation Workflow

> Normative source: `harness-principles.md`
> 실행 주체: Claude 메인 세션 (skill 호출 체인)
> 본 문서의 §3, §5, §6, §7, §8 은 후속 Step (2-6) 에서 자산 작성 후 채워진다.

## 1. Overview

하네스 이식 — 빈 또는 기존 프로젝트에 하네스 (docs / agents / skills / hooks + 검증 인프라) 를 도입하는 워크플로우.

두 phase 구조:

- **Phase 1 Diagnose + Design** (선택적 호출) — design skill 들이 현황 진단 + 변경 spec 산출
- **Phase 2 Execution** (자동 dispatch) — Phase 1 spec 의 Execution Plan 항목별 creator 호출

실행 주체: Claude 메인 세션. sub-agent 없이 skill 호출 체인.

```
[사용자 요청]
   ↓
[§2 Routing] — 어느 design skill 부터?
   ↓
[Phase 1 design skill] — Inspect → Spec 산출
   ↓
[사용자 spec 검토 + 승인 (design effect gate)]
   ↓
[Phase 2 Execution] — 자동 dispatch
   ↓
[evaluation-loop-runner] — runtime, 사이클 진입
```

## 2. Routing — "어느 design skill 부터?"

| 신호 | 첫 design skill |
|---|---|
| "스킬·에이전트·훅 만들어줘", 자원 타입 결정 | `resource-design` |
| "AGENTS.md 만들어줘", "문서 정리", "context-map" | `context-map-architecture` |
| "검증 인프라", "task log", "golden-set" | `evaluation-loop-design` |
| 빈 프로젝트, "처음부터 하네스" | `context-map-architecture` (먼저 인덱스/계약) |

호출자는 사용자 발화 + 프로젝트 상태를 기준으로 한 행 선택. 동시에 둘 이상 후보면 *제일 명시적인 신호* 우선.

본 표는 단일 표 형식 — 7-10 행 초과 시 decision tree (graphviz) 도입 검토.

## 3. Phase 1 Design Skills

TBD per Step 2-4. 각 design skill 작성 완료 시 본 섹션의 해당 하위 섹션을 채운다.

- 3.1 `resource-design` (TBD per Step 3)
- 3.2 `context-map-architecture` (TBD per Step 2)
- 3.3 `evaluation-loop-design` (TBD per Step 4)

각 하위 섹션 형식: *trigger* / *inspect 도메인* / *spec format* / *effect gate* / *handoff*.

## 4. Spec Interface (markdown structured section)

모든 design skill 의 spec 은 공통 헤더 + 4개 표준 섹션을 따른다.

### 공통 헤더

```markdown
# Harness Installation Spec — <domain>

> Generated by: <skill-name>
> Date: <iso8601>
> Trigger: <user request 또는 runner Routing>
> spec_version: v1
```

### 4개 표준 섹션

1. **Inventory** — 현재 상태 (자원 / docs / 검증 인프라)
2. **Gaps** — 간격 식별 (없는 자원 + 누락 인덱스 + 책임 누수)
3. **Plan** — 변경 제안 (작성 / 수정 / 이동 항목)
4. **Execution Plan** — forward target skill (Phase 2 dispatch 용)

### Execution Plan 형식

```markdown
## Execution Plan
- target: skill-creator
  args:
    name: "context-hint-emitter"
    scope: "project"
  rationale: hook trigger 시 짧은 routing hint 주입이 반복 패턴
- target: agent-creator
  args:
    name: "harness-env-maintainer"
  rationale: 환경 개선 specialist 가 별도 컨텍스트 필요
```

main session 은 이 섹션을 YAML 처럼 파싱해 순차 dispatch. 각 dispatch 는 해당 creator skill 의 §2 (또는 동등) effect gate 를 거친다 — 이중 gate (design 단계 + execution 단계) 가 safety 확보.

**`args` 형식**: target creator skill 마다 다르다 — 표준화하지 않는다. design skill 은 target 의 frontmatter / 본문을 읽어 args 키 (`name` / `scope` 등) 를 선택. 모르면 비워두고 creator 의 §0 (intent capture) 가 사용자에게 묻도록 한다.

### no-op / blocked case

```markdown
## Execution Plan
mode: no-op
reason: 진단 결과 현재 자원으로 충분
```

```markdown
## Execution Plan
mode: blocked
reason: 자원 결정 모호 — 사용자 입력 필요
needs_input:
  - <질문 1>
  - <질문 2>
```

### spec versioning

`spec_version: v1` 필드를 spec 헤더에 명시. 인터페이스 변경 시 v2 로 bump + 본 §4 의 변경 정책 갱신 + 모든 design/execution skill 의 호환 확인.

## 5. Phase 2 Execution Skills

TBD per Step 5 (`evaluation-loop-runner`) + Step 7 (creator skills 호환 확인).

- 5.1 `skill-creator` / `agent-creator` / `hook-creator` (이미 GAP-driven, spec 입력 받음)
- 5.2 `evaluation-loop-runner` (runtime — task log + gap 라우팅)

## 6. Cycle — Runtime → 재진입

TBD per Step 5.

`evaluation-loop-runner` 의 Routing Decision → 적절한 design skill 으로 재진입 사이클.

**종료 조건**:

- gap 분석 결과 `Routing Decision: no-op`
- 사용자 명시 종료 ("stop", "충분")
- 같은 design skill 이 2회 연속 호출됨 (재진입 무한 루프 신호)
- 누적 라운드 5회 초과 (NEEDS_REVIEW)

## 7. Anti-patterns

TBD per Step 6 (workflow doc 최종 정리).

후보:

- design 없이 직접 creator 호출
- spec 미수정 자동 dispatch (사용자 승인 skip)
- Phase 1 모두 호출 (선택적 원칙 위반)
- design + creator 통합 시도 (책임 누수)
- workflow doc 외부 진입 (사용자가 임의 skill 만 호출)

## 8. Verification

TBD per Step 6.

후보:

- should-trigger / should-not-trigger 시나리오
- no-op case (이미 적절한 하네스가 있음)
- blocked case (진단 결과 자산 부족)
````

- [ ] **Step 2: Verify — placeholder 명시 + cross-link 확인**

```bash
wc -l plugins/bobs-plugin/references/harness-installation-workflow.md

grep -c "^## " plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 8 (§1-§8)

grep -c "TBD per Step" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 4+ (§3, §5, §6, §7, §8 의 placeholder)

grep "harness-principles" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 첫 줄 normative source 참조
```

- [ ] **Step 3: Commit**

```bash
git add plugins/bobs-plugin/references/harness-installation-workflow.md
git commit -m "$(cat <<'EOF'
Add harness-installation-workflow.md skeleton (Step 1c)

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 1

- §1 Overview (Phase 1/2 + 데이터 흐름)
- §2 Routing 표 (신호 → 첫 design skill, 4 행)
- §4 Spec Interface (공통 헤더 + 4 표준 섹션 + Execution Plan 파싱 + spec_version)
- §3, §5, §6, §7, §8 은 placeholder "TBD per Step N"

후속 Step (2-6) 에서 해당 design/execution skill 작성 완료 시 placeholder 갱신.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

### Task 3: harness-principles.md 에 reverse cross-link 추가

**Files:**
- Modify: `plugins/bobs-plugin/references/harness-principles.md`

- [ ] **Step 1: 본문 첫 섹션 시작 직전에 워크플로우 cross-link 추가**

Read line 1-5 of `plugins/bobs-plugin/references/harness-principles.md` to confirm exact format (Task 1 Step 3 에서 제목 바꿈 + Task 1 Step 4 에서 §5-7 삭제 — 첫 줄 `# Harness Principles` + 빈 줄 + `## 1. 배경` 시작 가정).

Edit:
- file_path: `/Users/macpro/dev/bobs-plugin/plugins/bobs-plugin/references/harness-principles.md`
- old_string:
  ```
  # Harness Principles

  ## 1. 배경
  ```
- new_string:
  ```
  # Harness Principles

  > 본 문서는 하네스의 **개념 모델** 만 정의한다. 실제 *이식 워크플로우* (진단 → 설계 → 실행 → 사이클) 는 `harness-installation-workflow.md` 를 참고.

  ## 1. 배경
  ```

주의: old_string 매치가 안 될 경우 line 1-5 를 다시 Read 해서 정확한 indentation / 빈 줄 / 헤더 형식 확인.

- [ ] **Step 2: Verify**

```bash
grep "harness-installation-workflow" plugins/bobs-plugin/references/harness-principles.md
# Expected: 본문에 한 줄 cross-link

head -7 plugins/bobs-plugin/references/harness-principles.md
# Expected: 제목 + 빈 줄 + cross-link 박스 + 빈 줄 + ## 1. 배경
```

- [ ] **Step 3: Commit**

```bash
git add plugins/bobs-plugin/references/harness-principles.md
git commit -m "$(cat <<'EOF'
Link harness-principles → harness-installation-workflow

본문 첫 줄에 cross-link 추가 — 본 문서는 개념 모델, 이식 워크플로우는
별도 문서임을 명시.

Spec: plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md §7 Step 1

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Self-Review

### Spec coverage

Spec §7 Step 1 의 1a / 1b / 1c 모두 task 매핑됨:

| Spec item | Task |
|---|---|
| 1a `git mv harness-engineering.md → harness-principles.md` | Task 1 Step 2 |
| 1b §5-7 본문 삭제 | Task 1 Step 4 |
| 1c `harness-installation-workflow.md` skeleton 작성 (§1 / §2 / §4 채움, §3 / §5-6 / §7-8 placeholder) | Task 2 |
| 1c-추가 (placeholder 명시 + cross-link) | Task 2 Step 2 + Task 3 |

추가 작업:
- 활성 자산 6곳 참조 갱신 (`harness-engineering` → `harness-principles`) — Task 1 Step 5. spec 에 명시 안 됨이나 dangling reference 방지 필수.
- 제목 변경 (`Coding Agent Environment` → `Harness Principles`) — Task 1 Step 3. spec 에 명시 안 됨이나 의미상 자연.

### Placeholder scan

본 plan 본문에 TBD 없음.
workflow.md 본문의 "TBD per Step N" 은 *의도된* placeholder (후속 Step 에서 채움) — spec §7 의 Step 1c 가 명시.

### Type consistency

- 파일 경로 일관 (`plugins/bobs-plugin/references/`)
- 자산 이름 일관 (`harness-principles.md`, `harness-installation-workflow.md`)
- skill 이름 일관 (`resource-design`, `context-map-architecture`, `evaluation-loop-design`, `evaluation-loop-runner`, `skill-creator`, `agent-creator`, `hook-creator`)

### Spec §10 Decisions 반영

- Decision 2 (단일 routing 표) → workflow.md §2 단일 표 ✅
- Decision 4 (spec versioning) → workflow.md §4 의 `spec_version: v1` 명시 ✅
- Decision 5 (runner 명시 호출) → workflow.md §5.2 의 placeholder 안내 ✅

### 잠재 위험

- Task 1 Step 4 (§5-7 삭제) — line range 가 큼 (≈262 lines). Edit 한 번에 매치 안 되면 §5 / §6 / §7 별도 Edit. 또는 Read → Write 로 line 1-378 만 재작성.
- Task 1 Step 5 (참조 갱신) — `replace_all: true` 사용. 의도하지 않은 매치가 있을 수 있으므로 Step 6 verify 에서 grep 으로 잔여 확인 필수.
- Task 3 Step 1 (cross-link 추가) — old_string 매치는 Task 1 의 결과 (제목 변경 후) 가정. Task 1 가 완료된 후에만 동작.

---

## Execution Handoff

Plan 완료 (Task 3 / commit 3). Spec §7 의 Step 1 (Document split) 만 본 plan 에 담겼다.

후속:
- Step 2 (context-map-architecture skill) — 별도 plan
- Step 3 (resource-design + agent-skill-designer deprecate)
- Step 4 (evaluation-loop-design)
- Step 5 (evaluation-loop-runner)
- Step 6 (workflow doc 종합)
- Step 7 (creator skill 호환 확인)

각 Step 은 본 Step 1 완료 후 새 plan 작성.

다음 단계 결정:

- **A. Subagent-Driven (recommended)** — 각 task 를 fresh subagent 가 실행, 사이 검토. `superpowers:subagent-driven-development`
- **B. Inline Execution** — 본 세션에서 batch 실행. `superpowers:executing-plans`
- **C. Pause** — Step 2-7 plan 도 미리 준비 후 일괄 실행
