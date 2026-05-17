# Harness Installation — Step 6 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `harness-installation-workflow.md` 의 4개 TBD 섹션 (§5 Phase 2 Execution Skills / §6 Cycle Runtime → 재진입 / §7 Anti-patterns / §8 Verification) 을 본문으로 채우고, 전체 workflow doc 의 cross-link / consistency 를 정리한다. 본 Step 으로 workflow doc 이 *self-contained* (placeholder 0건) 상태가 된다.

**Architecture:** workflow doc 은 *normative reference* — Step 1-5 에서 작성된 자산 (`resource-design` / `context-map-architecture` / `evaluation-loop-design` / `evaluation-loop-runner` / 3 creator skill) 의 책임·인터페이스·사이클·검증을 한 문서에 묶는다. 본 Step 은 *문서 작성* 중심이며, 자산 본문은 만지지 않는다 (인용·cross-ref 만 갱신). 4개 섹션을 동일 commit 으로 묶어도 가능하나 *섹션별 separate commit* 권장 — 각 섹션이 독립 검증 가능 (anti-pattern 목록 vs verification 시나리오 vs runtime cycle 명세).

**Tech Stack:** Edit/Write tools (workflow doc 만), grep / sed (cross-link 검색), agent-skill-auditor (선택 — workflow doc 의 인용 자원 ghost reference 정적 감사)

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §7 Step 6 (workflow doc 최종 정리) + §11 Success Criteria 5번 ("workflow doc 이 self-contained — 외부 normative source 없이 harness-principles.md 만으로 이식 절차 진행 가능")

**전체 migration 중 위치:** Step 6 of 7. **Prerequisite: Step 5 (`evaluation-loop-runner` skill) 완료**. Step 5 미완 시 §5.2 (`evaluation-loop-runner`) 본문이 *planned freshness* (CONSTITUTION §3.13) 로 표기되며 Step 5 완료 후 본 Step 의 §5.2 부분만 재실행 필요 — 두 옵션:

| 옵션 | 진행 순서 | 트레이드오프 |
|---|---|---|
| (A) Step 5 → Step 6 (권장) | Step 5 runner skill 먼저 작성 후 본 Step 진입 | §5.2/§6 의 인용이 ghost-free, 한 번에 마무리. Step 5 plan 부재 — 사전 작성 필요 |
| (B) Step 6 부분 진행 → Step 5 → Step 6 §5.2 갱신 | §5.1 / §7 / §8 먼저, §6 도 부분 진행 (chain 절차의 runtime contract 필드 `mode` / `routing_decision` / `round` 는 placeholder, §5.2 완료 후 갱신) | 부분 진행 비용 — §5.2 + §6 두 섹션 두 번 만짐, Step 5 후 회귀 검증 필요 |

본 plan 은 **옵션 (A)** 를 default 로 가정. 옵션 (B) 진행 시:
- Task 2 의 §5.2 본문은 placeholder 유지 ("TBD per Step 5")
- Task 3 의 §6 *Chain 절차 1번* 의 runtime contract 필드 인용 (`mode: cycled | no-op | ...` / `routing_decision` / `round`) 도 placeholder ("TBD per Step 5 — §5.2 완료 후 갱신") 로 대체. §6 의 진입 조건 / 종료 조건 / 카운터 책임 본문은 그대로 진행 가능 (§5.2 의존 없음)
- 본 plan Done Criteria 에서 다음 2 항목 제외: "§5.2 ghost-free" + "§6 chain 절차 ↔ §5.2 runner contract 필드 일치 (`mode` / `routing_decision` / `round`)"
- Step 5 완료 후 본 Step 의 Task 2 Step 3 + Task 3 Step 2 의 placeholder 부분만 재실행 (separate commit)

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (§5/§6/§7/§8 채움) | 4 TBD → 본문 (~200-300 lines 추가) |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (consistency pass) | Routing 표 §2 + Spec Interface §4 의 인용 자원 / spec_version 통일 |
| (선택) `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` | Edit (§7 Step 6 → 본문 인용 갱신) | spec 의 Step 6 placeholder 가 "본 Step 에서 채움" 으로 갱신. spec 자체 본문은 만지지 않음 (Step 7 의 version bump 와 함께 spec 도 마무리 권장) |

**유지** (변경 없음):
- 모든 skill / agent / command / hook / runtime 자산 — 본 Step 은 workflow doc 만 만짐
- `plugins/bobs-plugin/references/harness-principles.md` — normative source, 인용만
- 4 design skill (`resource-design` / `context-map-architecture` / `evaluation-loop-design`) — workflow doc 이 *이들을 인용* 하지 *이들이 workflow doc 을 인용* 하지 않음
- `evaluation-loop-runner` (Step 5 산출) — workflow doc §5.2/§6 의 인용 대상
- 3 creator skill — workflow doc §5.1 의 인용 대상 (본 Step 은 인용만, args 호환은 Step 7)

**deprecation 없음**: 본 Step 은 문서 작성만, 자산 삭제 / 변경 없음.

---

## Note on TDD for doc work

본 Step 은 문서 작성이므로 외부 TDD 가 적용되지 않는다. 대신 *verify-baseline → change → verify-result → commit* 패턴:

1. **baseline verify** — 작성 전 grep 으로 현재 인용 / cross-ref / placeholder 위치 확정
2. **change** — 본문 추가 (Edit / Write)
3. **result verify** — grep 재실행으로 (a) 신규 본문이 작성됐고 (b) placeholder 가 제거됐고 (c) 인용 자원이 실존함 (ghost-free) 확인
4. **commit** — verify 통과 후 즉시

각 Task 의 *Verification* 절이 baseline + result grep 명령을 명시. 본 Step 은 commit 단위 4개 (§5 / §6 / §7-§8 묶음 / consistency pass) 권장.

## Note on "묻지 말고 진행" 모드 (mini-gate 약화)

본 plan 의 mini-gate 는 *문서 작성* 자체가 부수 효과 (CONSTITUTION §3.3) 이므로 default 강한 형태. 사용자가 *묻지 말고 진행* (pre-approved batch) 모드를 사전 합의한 경우 mini-gate 는 *disclosure-only* (작성 경로 + 종류 + 요약 + diff 추정 4 항목을 응답에 기록하되 확인 없이 진행) 로 약화된다.

본 plan 은 약화를 plan 단위로 합의한 것으로 간주 — Task 2-5 의 본문 Edit 이 silent execution 으로 보여도 의도된 동작. 호출자가 강한 gate 를 원하면 본 plan 실행 *전* 합의를 철회.

---

### Task 1: 사전 조사 — Step 1-5 산출 자산 inventory + 인용 매핑

**Files:**
- (편집 없음 — 분석만)

본 Task 는 commit 없음. 결과는 Task 2-5 의 본문 작성 입력.

- [ ] **Step 1: 인용 대상 자산 inventory (Step 1-5 완료 상태 확인)**

```bash
# Phase 1 design skill 3종
ls plugins/bobs-plugin/skills/resource-design/SKILL.md \
   plugins/bobs-plugin/skills/context-map-architecture/SKILL.md \
   plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md

# Phase 2 execution skill — creator 3종 + runner
ls plugins/bobs-plugin/skills/skill-creator/SKILL.md \
   plugins/bobs-plugin/skills/agent-creator/SKILL.md \
   plugins/bobs-plugin/skills/hook-creator/SKILL.md \
   plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md 2>/dev/null

# 검증 자산 (`docs/agent/`)
ls docs/agent/roles.md docs/agent/evaluation-loop.md docs/agent/golden-set.md \
   docs/agent/task-log-template.md docs/agent/context-map.md 2>/dev/null

# reference subagent
ls plugins/bobs-plugin/agents/agent-skill-auditor.md
```

Expected 결과:
- 7 design + creator skill 모두 존재 (Step 2-4 + 기존 creator)
- `evaluation-loop-runner` 존재 여부로 옵션 (A) vs (B) 분기 결정
- `docs/agent/` 자산은 *프로젝트 적용 산출물* 이므로 본 plan 시점에 없을 수 있음 (workflow doc 은 *이들이 작성될 path* 만 명시)

`evaluation-loop-runner` 부재 시 본 plan 의 Goal 절 옵션 (A) vs (B) 결정 — 사용자 confirm 또는 default (A) 로 Step 5 plan 작성 후 본 Step 진입.

- [ ] **Step 2: 현재 workflow doc 의 TBD 위치 매핑**

```bash
grep -nE "^## 5\.|^## 6\.|^## 7\.|^## 8\.|TBD per Step" \
  plugins/bobs-plugin/references/harness-installation-workflow.md
```

Expected:
- line 252: `## 5. Phase 2 Execution Skills` + `TBD per Step 5 + Step 7`
- line 259: `## 6. Cycle — Runtime → 재진입` + `TBD per Step 5`
- line 272: `## 7. Anti-patterns` + `TBD per Step 6`
- line 284: `## 8. Verification` + `TBD per Step 6`

본 Step 이 4 TBD 모두 제거.

- [ ] **Step 3: 인용 자원 ghost reference 사전 검사**

```bash
# §3.1-§3.3 에 이미 인용된 자원이 모두 존재해야 ghost-free
grep -oE "\`[a-z-]+\.(md|sh)\`|\`[a-z-]+/?\`" \
  plugins/bobs-plugin/references/harness-installation-workflow.md | sort -u
```

본 grep 결과의 각 자원이 실제 path 에 존재하는지 1회 확인. 누락 발견 시 본 Step 진입 *전* 해당 자원 누락을 사용자에게 보고 (본 Step 범위 밖 — Step 3/4/5 의 회귀 신호).

- [ ] **Step 4: §5/§6 의 대상 자원 책임 한 줄 정리 (메모리)**

| 섹션 | 자원 | 책임 한 줄 |
|---|---|---|
| §5.1 | `skill-creator` | SKILL.md draft → GAP 분석 → 수정 사이클. spec args 입력 받음 (Step 7) |
| §5.1 | `agent-creator` | agent `.md` draft → GAP 분석 → 수정 사이클. spec args 입력 받음 (Step 7) |
| §5.1 | `hook-creator` | hook script + settings.json registration draft → GAP 분석 → 수정 사이클. spec args 입력 받음 (Step 7) |
| §5.2 | `evaluation-loop-runner` | task log 캡처 + golden-set 비교 + Routing Decision → 다음 design skill chain |
| §6 | (runner) | Routing Decision 표 6행 (4 design skill + 외부 + no-op) + 종료 조건 4종 |

§6 의 Routing Decision 표는 `evaluation-loop-design` 의 `references/evaluation-loop-write.md` 에 이미 정의 — workflow doc §6 은 *동일 표 인용* 하지 *재정의* 하지 않는다 (drift-avoidance).

- [ ] **Step 5: §7 anti-pattern 후보 정리 (메모리)**

workflow doc line 276-282 의 "후보:" 5건 + 추가 후보:

| # | 후보 | 인용 source |
|---|---|---|
| 1 | design 없이 직접 creator 호출 | line 277 |
| 2 | spec 미수정 자동 dispatch (사용자 승인 skip) | line 278 |
| 3 | Phase 1 모두 호출 (선택적 원칙 위반) | line 279 |
| 4 | design + creator 통합 시도 (책임 누수) | line 280 |
| 5 | workflow doc 외부 진입 (사용자가 임의 skill 만 호출) | line 281 |
| 6 (추가) | runner 사이클 종료 조건 무시 | evaluation-loop-write §Common Failures |
| 7 (추가) | spec_version mismatch (v1 design + v2 creator) | §4 의 versioning 항목 |
| 8 (추가) | docs/agent/ body 재생산 (drift — context-map-architecture seed vs evaluation-loop-design body) | Step 4 의 ownership 분리 |

총 8 항목 후보. 본 Step 의 §7 본문은 각 항목 *증상 / 원인 / 수정* 표로 정리.

- [ ] **Step 6: §8 verification 시나리오 후보 정리 (메모리)**

workflow doc line 286-292 의 "후보:" 3건 + 확장:

| 시나리오 종류 | 시나리오 | Expected |
|---|---|---|
| should-trigger | "스킬 만들어줘" 발화 | `resource-design` 진입 |
| should-trigger | "AGENTS.md 만들어줘" 발화 | `context-map-architecture` 진입 |
| should-trigger | "검증 인프라" 발화 | `evaluation-loop-design` 진입 |
| should-not-trigger | "PR 리뷰" 발화 | workflow doc 외부 (codex-reviewer / pr-review-toolkit) |
| should-not-trigger | "코드 simplify" 발화 | workflow doc 외부 (code-simplifier) |
| no-op | 이미 적절한 자원 + 인덱싱 | `mode: no-op` 반환 |
| blocked | 자원 0개 / 작업 유형 0개 | `mode: blocked` + needs_input |
| cycle | runner → design → creator → runner 1 round | 종료 조건 충족 (Routing Decision no-op) |
| cycle 종료 | 사용자 "stop" 입력 | runner 즉시 break |
| cycle 무한 방지 | 같은 design skill 2회 연속 | NEEDS_REVIEW |

총 10 시나리오. 본 Step 의 §8 본문은 *시나리오 표 + 검증 방법* 으로 정리.

---

### Task 2: §5 Phase 2 Execution Skills 채움

**Files:**
- Edit: `plugins/bobs-plugin/references/harness-installation-workflow.md` line 252-258 (§5 본문)

**Prerequisite check**: Task 1 Step 1 의 `evaluation-loop-runner` 존재 확인. 옵션 (A) 진행 시 존재 필수, 옵션 (B) 진행 시 §5.2 는 placeholder 유지.

- [ ] **Step 1: 현재 §5 본문 baseline read**

```bash
sed -n '252,258p' plugins/bobs-plugin/references/harness-installation-workflow.md
```

현재 본문:
```
## 5. Phase 2 Execution Skills

TBD per Step 5 (`evaluation-loop-runner`) + Step 7 (creator skills 호환 확인).

- 5.1 `skill-creator` / `agent-creator` / `hook-creator` (이미 GAP-driven, spec 입력 받음)
- 5.2 `evaluation-loop-runner` (runtime — task log + gap 라우팅)
```

- [ ] **Step 2: §5.1 본문 작성 — 3 creator skill**

template:

```markdown
### 5.1 Creator skills — `skill-creator` / `agent-creator` / `hook-creator`

**역할**: Phase 1 design skill 의 spec (`Execution Plan` 섹션) 항목별로 dispatch 되어, 신규 자원 (skill / agent / hook) 의 본문을 *작성 + GAP 분석 + 수정 사이클* 로 생산.

**입력**: design skill 의 `Execution Plan` 항목 1개 — `target: <creator-name>` + `args: {<creator-specific keys>}` + `rationale`.

**호출 패턴** (main session 책임):

1. design skill 의 spec `Execution Plan` 섹션 파싱 (workflow doc §4 의 YAML-like 형식)
2. 각 항목의 `target` 이 가리키는 creator skill 호출
3. `args` 를 첫 메시지로 전달 (단, args 가 비어 있으면 creator 의 §0 intent capture 가 사용자에게 질문)
4. creator 의 §2 effect gate 가 *2단계 effect gate* 의 두 번째 (apply) — 실제 파일 write 직전 사용자 승인

**args 형식** (creator 마다 다름 — design skill 이 *모를 때* 비워둠 허용. Step 7 에서 호환 인터페이스 정렬):

| Creator | 최소 필수 args |
|---|---|
| `skill-creator` | `name` (kebab-case), `scope` (user / project / plugin) |
| `agent-creator` | `name` (kebab-case), `scope` (user / project / plugin), `subagent_type` (선택 — main session 호출용 식별자) |
| `hook-creator` | `name` (kebab-case), `event` (PostToolUse / Stop / UserPromptSubmit 등), `matcher` (event 별 — 예: PostToolUse 의 tool 이름), `scope` (user / project) |

`args` 키가 누락된 채 호출되면 creator 의 §0 (intent capture) 가 *부분 입력* 으로 시작 — 사용자에게 누락된 키만 질문.

**산출 contract** (creator 의 §5 Output 참고):

```yaml
created/updated: <relative path>
scope: user | project | plugin
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <path to *.GAP.md>
```

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 `blocked: needs revision` prefix. main session 은 blocked 시 다음 Execution Plan 항목으로 진행하지 *말고* 사용자에게 보고.
```

`args` 표가 design skill spec args 가 *empty 허용* 임을 명시 — Step 7 의 호환 정렬에서 이 인터페이스를 creator §0 가 받음.

- [ ] **Step 3: §5.2 본문 작성 — evaluation-loop-runner (옵션 A 진행 시)**

**옵션 (B) 진행 시 본 Step skip** — §5.2 는 placeholder 유지 ("TBD per Step 5") + Step 5 완료 후 재진입.

옵션 (A) template:

```markdown
### 5.2 `evaluation-loop-runner` — runtime cycle

**역할**: Phase 1 design skill 의 산출 (검증 자산 `docs/agent/*.md`) 를 *실행 시점* 에 따라 task log 캡처 + golden-set 비교 + Routing Decision 결정. design skill 은 *명세* 만 작성, 본 runner 가 *명세대로 실행*.

**입력 trigger** (3종):

1. 사용자 명시 호출 (`/runner` 또는 동등 command)
2. 자동 chain — 이전 사이클의 Routing Decision 이 *다음 design skill* 을 가리키면 main session 이 chain
3. PR / commit 후 hook 트리거 (사전 등록된 PostCommit / Stop hook)

**Capability Procedure** (`evaluation-loop-design` 가 작성한 `docs/agent/evaluation-loop.md` 명세 따름):

1. task log 캡처 — `docs/agent/task-log-template.md` schema 로 `docs/agent/logs/YYYY-MM-DD-<slug>.md` entry 생성
2. gap 분석 — `docs/agent/golden-set.md` case 와 entry 비교 (PASS / FAIL / no-op / blocked / needs_input 5종)
3. Routing Decision — `docs/agent/evaluation-loop.md` Routing Decision 표 행 선택
4. 다음 design skill 진입 또는 사이클 종료

**산출 contract**:

```yaml
mode: cycled | no-op | needs_input | blocked
last_entry: <path to log entry>
gap_summary: <case ID> <PASS/FAIL/...> + <한 줄>
routing_decision: <design skill name 또는 no-op>
round: <N>
```

**Effect**: task log entry write (`docs/agent/logs/*.md`) — design 자산은 만지지 않음. 진단 결과의 *다음 design skill* 은 main session 이 별도 호출. runner 자체는 chain 결정만 반환.

**docs/agent body 부재 시**: `mode: blocked` + needs_input ("`evaluation-loop-design` 먼저 호출해 검증 자산 작성 필요"). runner 는 *명세 실행자* 이지 *명세 작성자* 아님.
```

`evaluation-loop-runner` skill 자체의 본문 (Phase 1 / Phase 2 / Phase 3) 은 Step 5 plan 에서 작성 — 본 workflow doc §5.2 는 *책임 인터페이스* 만 명시.

- [ ] **Step 4: Edit 적용**

mini-gate 5 항목:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `plugins/bobs-plugin/references/harness-installation-workflow.md` (절대 경로) |
| 작업 종류 | Edit (line 252-258 → 본문 ~60-90 lines) |
| 추가 본문 | §5.1 (creator skill 인터페이스 + args 표) + §5.2 (runner Capability Procedure + 산출 contract, 옵션 A 진행 시) |
| 인용 자원 | 3 creator skill + (옵션 A) `evaluation-loop-runner` + `docs/agent/*.md` 4종 (`evaluation-loop-design` 가 정의) |
| 후속 영향 | Step 7 의 creator §0 args 호환 정렬 — 본 §5.1 의 args 표가 contract |

Edit 적용:

```
Edit(workflow doc, old_string="## 5. Phase 2 Execution Skills\n\nTBD per Step 5 (`evaluation-loop-runner`) + Step 7 (creator skills 호환 확인).\n\n- 5.1 `skill-creator` / `agent-creator` / `hook-creator` (이미 GAP-driven, spec 입력 받음)\n- 5.2 `evaluation-loop-runner` (runtime — task log + gap 라우팅)",
     new_string=<Step 2 + Step 3 template 합쳐서>)
```

- [ ] **Step 5: Verify (write 후 즉시)**

```bash
# §5 본문에 TBD 사라짐
grep -n "TBD per Step 5\|TBD per Step 7" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 0 lines (또는 §6 의 "TBD per Step 5" 1 lines — §6 는 Task 3 에서 처리)

# §5.1 + §5.2 본문 작성됨
grep -nE "^### 5\.1|^### 5\.2" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 2 lines

# 인용 자원 ghost-free (옵션 A)
for r in skill-creator agent-creator hook-creator evaluation-loop-runner; do
  ls "plugins/bobs-plugin/skills/$r/SKILL.md" 2>/dev/null || echo "MISSING: $r"
done
# Expected: runner 는 옵션 A 진행 시 존재. 옵션 B 진행 시 MISSING 허용 (placeholder 유지)
```

- [ ] **Step 6: Commit §5**

```bash
git add plugins/bobs-plugin/references/harness-installation-workflow.md
git commit -m "Fill harness-installation-workflow §5 (Phase 2 Execution Skills)"
```

---

### Task 3: §6 Cycle Runtime → 재진입 채움

**Files:**
- Edit: `plugins/bobs-plugin/references/harness-installation-workflow.md` line 259-271 (§6 본문)

- [ ] **Step 1: baseline read**

```bash
sed -n '259,271p' plugins/bobs-plugin/references/harness-installation-workflow.md
```

현재:
```
## 6. Cycle — Runtime → 재진입

TBD per Step 5.

`evaluation-loop-runner` 의 Routing Decision → 적절한 design skill 으로 재진입 사이클.

**종료 조건**:

- gap 분석 결과 `Routing Decision: no-op`
- 사용자 명시 종료 ("stop", "충분")
- 같은 design skill 이 2회 연속 호출됨 (재진입 무한 루프 신호)
- 누적 라운드 5회 초과 (NEEDS_REVIEW)
```

종료 조건 4종은 이미 본문 — *유지*. 추가: 사이클 *진입 조건* / Routing Decision 표 *인용* / chain 절차.

- [ ] **Step 2: §6 본문 template 작성**

```markdown
## 6. Cycle — Runtime → 재진입

`evaluation-loop-runner` 의 Routing Decision → 적절한 design skill 으로 재진입 사이클. 본 §6 은 cycle 의 *상위 흐름* 만 명시 — 사이클 단계별 세부 (task log 캡처 + gap 분석 + Routing Decision 표) 는 `docs/agent/evaluation-loop.md` (project-side 산출) 에 명세 (drift-avoidance: workflow doc 은 *명세 위치* 만 인용, 본문 재생산 금지).

### 진입 조건

§5.2 의 *입력 trigger 3종* 과 동일 — 명시 호출 / 자동 chain / hook 트리거.

### Chain 절차 (main session 책임)

1. runner 호출 (진입 조건 중 하나) → `mode: cycled | no-op | needs_input | blocked` + `routing_decision` 반환 *(옵션 (B) 진행 시: 본 contract 필드 표는 §5.2 placeholder 상태에서 `TBD per Step 5 — §5.2 완료 후 갱신` 로 대체)*
2. `routing_decision` 이 design skill 이름이면 main session 이 해당 skill 호출 — input 으로 `prior_task_log` path + `gap_summary` 전달 (`docs/agent/evaluation-loop.md` 의 *자원 호출 contract* 참조)
3. design skill 산출 spec (또는 자체 작성 결과) 반영 후 다시 runner 호출 (자동 chain)
4. 종료 조건 충족까지 반복

### 종료 조건

다음 중 하나일 때 chain 중단:

- gap 분석 결과 `Routing Decision: no-op` (개선 필요 자산 없음)
- 사용자 명시 종료 ("stop", "충분", "그만")
- 같은 design skill 이 2회 연속 호출됨 (재진입 무한 루프 신호)
- 누적 라운드 5회 초과 (`NEEDS_REVIEW` — 사용자에게 핸드오프)

종료 후 main session 은 사이클 결과를 사용자에게 한 줄 요약 + 마지막 task log entry path 안내.

### Cycle 카운터 책임

- 라운드 카운트는 *main session* 이 유지 — runner 는 각 호출마다 stateless (이전 호출 모름)
- 동일 design skill 2회 연속 검출은 main session 이 호출 이력에서 비교
- 종료 조건 위반 시 main session 이 chain 중단 + 사용자에게 사유 보고
```

`docs/agent/evaluation-loop.md` 의 Routing Decision 표 *전체 본문 재생산은 금지* — workflow doc 은 *인용 path* 만 표기 (drift-avoidance, Step 4 의 design 패턴 동일).

- [ ] **Step 3: Edit 적용**

mini-gate 5 항목:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `plugins/bobs-plugin/references/harness-installation-workflow.md` (line 259-271 → 본문 ~40-60 lines) |
| 작업 종류 | Edit (기존 종료 조건 유지 + 진입 조건 + chain 절차 + 카운터 책임 추가) |
| 인용 자원 | `evaluation-loop-runner` + `docs/agent/evaluation-loop.md` (책임 명세 위치) |
| Routing Decision 표 | *인용만* (drift-avoidance — Step 4 의 design 의도) |
| 후속 영향 | §8 verification 시나리오 (cycle / 종료 / 무한 방지) 의 검증 대상 |

```
Edit(workflow doc, old_string=<현재 line 259-271>, new_string=<Step 2 template>)
```

- [ ] **Step 4: Verify**

```bash
# TBD 제거
grep -n "TBD per Step 5" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 0

# 진입 조건 3종 / 종료 조건 4종 / chain 절차 4 단계 명시
grep -nE "^### 진입 조건|^### Chain 절차|^### 종료 조건|^### Cycle 카운터" \
  plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 4 lines

# Routing Decision 표 본문 재생산 0 (drift-avoidance)
grep -c "^| 신호 | 환원 위치 |" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 0 (Routing Decision 표는 docs/agent/evaluation-loop.md 에만)
```

- [ ] **Step 5: Commit §6**

```bash
git commit -am "Fill harness-installation-workflow §6 (Cycle Runtime → 재진입)"
```

---

### Task 4: §7 Anti-patterns + §8 Verification 묶음 채움

**Files:**
- Edit: `plugins/bobs-plugin/references/harness-installation-workflow.md` line 272-292 (§7 + §8 본문)

§7 / §8 는 모두 *목록 + 표* 형식으로 짧음. 같은 commit 으로 묶어도 검증 단위가 유지됨.

- [ ] **Step 1: baseline read**

```bash
sed -n '272,292p' plugins/bobs-plugin/references/harness-installation-workflow.md
```

- [ ] **Step 2: §7 본문 template**

```markdown
## 7. Anti-patterns

본 workflow 를 벗어나는 호출 패턴. 발견 시 *호출자가 적절한 routing 으로 redirect* (자원 자체 수정 아님 — workflow 외부 진입이 본질 원인).

| # | 안티패턴 | 증상 | 수정 |
|---|---|---|---|
| 1 | Design skip — 직접 creator 호출 | 사용자가 `/skill-creator` 직접 진입 (자원 타입 결정 / 책임 분리 미검토) | `resource-design` 먼저 호출 권고. 단, 자원 타입이 명확한 단일 자원 작성은 예외 (creator 의 §0 intent capture 가 보완) |
| 2 | spec 미수정 자동 dispatch | design skill 산출 spec 사용자 승인 skip 후 main session 이 곧장 creator 호출 | 1단계 effect gate (design spec 승인) 강제. CONSTITUTION §3.3 위반 |
| 3 | Phase 1 모두 호출 | 사용자 요청과 무관하게 3 design skill 모두 진입 | Routing 표 §2 의 *제일 명시적 신호* 우선 — 1개 design skill 만 진입 |
| 4 | design + creator 통합 시도 | design skill 본문이 직접 자원 파일 write (예: resource-design 이 SKILL.md 직접 write) | 책임 분리 강제 — design 은 spec 만, write 는 creator (또는 자체 작성 스킬: context-map-architecture / evaluation-loop-design) |
| 5 | workflow doc 외부 진입 | 사용자가 임의 skill 만 호출 (workflow doc 미인지) | onboarding 시 workflow doc 인지 강화. README + plugin description 에 workflow doc path 명시 |
| 6 | runner 사이클 종료 조건 무시 | 같은 design skill 2회 연속 또는 5회 초과 라운드를 main session 이 chain 계속 | §6 종료 조건 4종 강제 — main session 의 cycle 카운터 책임 (§6 *Cycle 카운터 책임*) |
| 7 | spec_version mismatch | design skill 이 v2 spec 산출하는데 creator 가 v1 만 파싱 | §4 의 versioning 정책 — v1→v2 bump 시 모든 design/execution skill 호환 확인 후 일제 갱신 |
| 8 | docs/agent body 재생산 | workflow doc 이 `docs/agent/evaluation-loop.md` Routing Decision 표 본문을 재생산 (drift 원인) | workflow doc 은 *인용 path* 만, 본문 재생산 금지 — Step 4 의 ownership 분리 패턴 |
```

- [ ] **Step 3: §8 본문 template**

```markdown
## 8. Verification

본 workflow 의 동작 검증 시나리오. 시나리오는 *호출자 검증* (workflow 진입점 트리거 정확도 + 종료 조건 동작) 중심 — 각 자원 *내부* 검증은 자원 자체의 GAP report 가 책임.

### 시나리오

| 종류 | 시나리오 | Expected |
|---|---|---|
| should-trigger | "스킬 만들어줘" / "에이전트 만들어줘" / "훅 만들어줘" | Routing 표 §2 첫 행 → `resource-design` 진입 |
| should-trigger | "AGENTS.md 만들어줘" / "context-map 정리" | Routing 표 §2 두 번째 행 → `context-map-architecture` |
| should-trigger | "검증 인프라" / "task log" / "golden-set" | Routing 표 §2 세 번째 행 → `evaluation-loop-design` |
| should-trigger | 빈 프로젝트 / "처음부터 하네스" | Routing 표 §2 네 번째 행 → `context-map-architecture` |
| should-not-trigger | "PR 리뷰" | workflow doc 외부 — `codex-reviewer` / `pr-review-toolkit` |
| should-not-trigger | "코드 simplify" / "리팩터링" | workflow doc 외부 — `code-simplifier` |
| should-not-trigger | "정적 rule 감사" (자원 1개 P0/P1 점검) | workflow doc 외부 — `agent-skill-auditor` |
| no-op case | 이미 적절한 자원 + 인덱싱 + 검증 자산 존재 | design skill 이 `mode: no-op` 반환, main session 이 사용자에게 "현재 상태 충분" 보고 |
| blocked case | 자원 0개 / 작업 유형 0개 / 의존 자산 누락 | design skill 이 `mode: blocked` + `needs_input` 반환. main session 은 누락된 의존 자원 우선 작성 권고 |
| cycle (1 round) | runner → design → creator → runner 1회 | 종료 조건 *Routing Decision: no-op* 충족 시 chain 중단 |
| cycle 종료 (사용자) | runner chain 중 사용자 "stop" 입력 | runner 다음 호출 직전 main session 이 chain 중단 + 사용자에게 보고 |
| cycle 무한 방지 | 같은 design skill 2회 연속 호출 신호 | main session 의 cycle 카운터가 검출 → `NEEDS_REVIEW` 사용자 핸드오프 |
| cycle 무한 방지 | 누적 5회 초과 | 동일 — `NEEDS_REVIEW` |

### 검증 방법

- **should-trigger / should-not-trigger** — 사용자 발화 시나리오 10건을 main session 이 1회씩 처리, Routing 표 §2 행 매핑 정확도 ≥ 9/10 (description-based trigger 정확도)
- **no-op / blocked** — design skill 의 `mode` 필드 반환을 main session 이 분기 처리하는지 dry-run 시나리오로 점검
- **cycle 종료** — 인공 cycle (가짜 task log entry 3건 + 동일 design skill 2회 연속 가짜 호출) 으로 종료 조건 발동 확인

### Limits (verification)

- 본 §8 의 시나리오는 *workflow 진입점* 검증만 — 자원 내부 (예: `resource-design` 가 올바른 spec 산출하는지) 는 자원 자체의 GAP report 가 진실 source
- description-based trigger 정확도는 매번 측정하지 않음 — Routing 표 §2 가 7-10 행 초과 시 또는 false trigger 신고 누적 시 측정
```

- [ ] **Step 4: Edit 적용 (§7 + §8 한 commit)**

mini-gate 5 항목:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `plugins/bobs-plugin/references/harness-installation-workflow.md` (line 272-292 → 본문 ~100-130 lines) |
| 작업 종류 | Edit (§7 8 항목 표 + §8 13 시나리오 표 + 검증 방법 3 항목 + Limits) |
| 인용 자원 | (§7) CONSTITUTION §3.3 / Routing 표 §2 / §4 versioning / §6 Cycle / `docs/agent/evaluation-loop.md`. (§8) Routing 표 §2 / design skill 의 `mode` 필드 |
| Source | (§7) workflow doc line 277-281 5건 + Task 1 Step 5 추가 3건 = 8. (§8) Task 1 Step 6 정리 10 + 분리 3 = 13 |
| 후속 영향 | Task 5 (consistency pass) 가 인용 자원 ghost-free 최종 검사 |

```
Edit(workflow doc, old_string=<line 272-292 현재 본문>, new_string=<Step 2 + Step 3>)
```

- [ ] **Step 5: Verify**

```bash
# §7 + §8 TBD 제거
grep -n "TBD per Step 6" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: 0

# §7 anti-pattern 8 항목
sed -n '/^## 7\. Anti-patterns/,/^## 8\./p' \
  plugins/bobs-plugin/references/harness-installation-workflow.md | grep -c '^| [0-9] '
# Expected: 8

# §8 시나리오 13 항목 + 검증 방법 3 항목 + Limits
sed -n '/^## 8\. Verification/,$p' \
  plugins/bobs-plugin/references/harness-installation-workflow.md | grep -c '^| should\|^| no-op\|^| blocked\|^| cycle'
# Expected: ≥10
```

- [ ] **Step 6: Commit §7 + §8**

```bash
git commit -am "Fill harness-installation-workflow §7 (Anti-patterns) + §8 (Verification)"
```

---

### Task 5: Consistency pass — cross-link / 인용 자원 / spec_version 통일

**Files:**
- Edit (필요 시): `plugins/bobs-plugin/references/harness-installation-workflow.md` (전체)

본 Task 는 workflow doc 전체를 한 번 더 읽고 *consistency* 정리. spec §7 Step 6 의 "cross-link / consistency 점검 / 4 신규 skill 의 description 이 workflow doc 의 routing 표와 일치" 요구사항.

- [ ] **Step 1: 전체 인용 자원 grep + ghost-free 검사**

```bash
# 모든 backtick-quoted file/path
grep -oE "\`[a-z][a-z0-9-]*\.(md|sh|json)\`|\`docs/[a-z/-]+\`|\`plugins/[a-z/-]+\`" \
  plugins/bobs-plugin/references/harness-installation-workflow.md | sort -u

# 각 자원 실존 확인 (자동 loop)
for r in $(grep -oE "\`[a-z][a-z0-9-]*\.(md|sh)\`" \
  plugins/bobs-plugin/references/harness-installation-workflow.md | \
  sed 's/`//g' | sort -u); do
  found=$(find plugins/bobs-plugin -name "$r" 2>/dev/null | head -1)
  [ -z "$found" ] && find docs -name "$r" 2>/dev/null | head -1
  [ -z "$found" ] && echo "MISSING: $r"
done
```

ghost reference 발견 시 본 Step 에서 *수정* (오타 / path 누락) 또는 *제거* (자원이 다른 Step 의 책임). 새 ghost 가 §5-§8 신규 본문에서 발생 시 Task 2-4 의 본문 회귀.

- [ ] **Step 2: Routing 표 §2 ↔ §3 design skill ↔ §5 creator skill ↔ §6 runner chain 일관성**

| 표 | 행 / 항목 | 검증 |
|---|---|---|
| §2 Routing | 4 행 (resource-design / context-map-architecture / evaluation-loop-design / 빈 프로젝트) | §3.1/3.2/3.3 의 3 design skill 과 1:1 매핑, 빈 프로젝트 → 3.2 |
| §3 design skill | 3종 모두 trigger / inspect / spec / effect gate / handoff 5절 | 본문 작성 완료 (Step 2-4 산출) |
| §5.1 creator | 3종 args 표 | Step 7 의 호환 정렬과 prefix 일치 |
| §5.2 runner | 입력 trigger 3종 / 산출 contract | §6 chain 절차의 entry path 와 일치 |
| §6 chain | 진입 조건 / chain 절차 / 종료 조건 / 카운터 책임 | §8 시나리오 cycle 검증 대상 |

inconsistency 발견 시 *workflow doc 본문* 수정. 자원 본문 (skill SKILL.md) 수정은 본 Step 범위 밖 — 별도 follow-up.

- [ ] **Step 3: spec_version v1 통일 검사**

```bash
grep -n "spec_version" plugins/bobs-plugin/references/harness-installation-workflow.md
# Expected: §3.1 / §3.2 / §3.3 / §4 공통 헤더 — 모두 v1
```

v1 외 표기 발견 시 통일.

- [ ] **Step 4: 4 design skill description ↔ workflow doc routing 일치 (선택, spec §7 Step 6 명시)**

```bash
# 각 design skill 의 frontmatter description grep
for s in resource-design context-map-architecture evaluation-loop-design; do
  echo "=== $s ==="
  head -10 "plugins/bobs-plugin/skills/$s/SKILL.md"
done
```

각 description 의 trigger 키워드가 workflow doc §2 Routing 표의 해당 행 신호와 일치하는지 확인. 불일치 발견 시 *workflow doc 의 Routing 표* 갱신 (skill description 은 만지지 않음 — 별도 follow-up).

- [ ] **Step 5: (선택) agent-skill-auditor 정적 감사 — workflow doc 인용 자원 ghost-free 보강**

```bash
# 본 plan 의 자체 ghost 검사가 충분하면 skip 가능. 호출 시:
# /agent-skill-auditor — target: harness-installation-workflow.md
```

본 Task 의 Step 1-2 자체 검사가 통과하면 본 Step skip.

- [ ] **Step 6: Edit (필요 시) + Commit**

수정 없으면 commit 없음. 수정 있으면:

```bash
git commit -am "Pass workflow doc consistency (ghost-free + cross-link + spec_version v1)"
```

---

### Task 6: spec 갱신 (선택) + version bump 영향 검사

**Files:**
- (선택) Edit: `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §7 Step 6 placeholder
- (선택) `plugins/bobs-plugin/.claude-plugin/plugin.json` description — 본 Step 의 4 섹션 완성을 description 에 *반영하지 않음* (description 은 *자산 목록* 만, workflow 진행도 X)

spec §7 Step 6 의 "anti-patterns / verification (전체 통합) / cross-link / consistency / 4 skill description 일치" 가 본 Step 의 Task 2-5 로 달성. spec 본문 자체는 *static archive* 이지만, Step 6 완료 표기는 spec 의 §7 footer 또는 status 필드에 한 줄 추가 가능 (옵션).

- [ ] **Step 1: spec §7 Step 6 본문 갱신 (옵션)**

현재 spec line 334-339:
```
### Step 6. workflow doc 최종 정리

- §7 anti-patterns
- §8 verification (전체 통합)
- cross-link / consistency 점검
- 4 신규 skill 의 description 이 workflow doc 의 routing 표와 일치하는지 확인
```

옵션 갱신:
```
### Step 6. workflow doc 최종 정리 ✅

- §5 Phase 2 Execution Skills (5.1 creator + 5.2 runner)
- §6 Cycle Runtime → 재진입 (chain + 종료 조건 + 카운터 책임)
- §7 anti-patterns (8 항목)
- §8 verification (13 시나리오 + 검증 방법 + Limits)
- cross-link / consistency 점검 (Task 5 consistency pass)
- 4 신규 skill (3 design + 1 runner) 의 description ↔ routing 표 일치 (Task 5 Step 4)
```

본 Step 의 ✅ 표기는 Step 7 (version bump) 직전에 한 번 더 갱신 — spec 의 모든 Step 이 ✅ 표기되면 version bump 가능 신호.

- [ ] **Step 2: version bump 영향 검사 (Step 7 prereq)**

본 Step 6 자체는 version bump 없음 — Step 7 의 책임. 다만 본 Step 의 workflow doc 변경이 *breaking* 인지 확인:

| 변경 | breaking? |
|---|---|
| §5.1 creator args 표 명시 | 호환 — 기존 creator 가 args 받지 못해도 §0 intent capture 가 보완 |
| §5.2 runner 인터페이스 | breaking — runner 신규 (Step 5), 기존 사용자에게 영향 없음 |
| §6 chain 종료 조건 4종 | non-breaking — 기존 chain 동작 보존, 검증만 강화 |
| §7 anti-pattern 8 항목 | non-breaking — 가이드 명시화 |
| §8 verification 시나리오 | non-breaking — 검증 방법 명시화 |

전체적으로 *minor bump* (0.1.3 → 0.2.0) 가 적절. Step 7 plan 의 version bump 결정 입력.

- [ ] **Step 3: (선택) spec 갱신 commit**

옵션 갱신을 적용한 경우만:

```bash
git commit -am "Mark spec Step 6 complete in design doc"
```

옵션 1 (spec 본문 손대지 않음) 진행 시 Step 6 commit 은 Task 2-5 의 3-4 commit 만.

---

## Done Criteria

본 Step 6 가 완료되면 다음 조건이 모두 충족됨:

- [ ] workflow doc 의 4 TBD (§5 / §6 / §7 / §8) 모두 본문화. grep 검증:
  ```
  grep -c "TBD per Step" plugins/bobs-plugin/references/harness-installation-workflow.md
  # Expected: 0
  ```

- [ ] workflow doc 의 모든 인용 자원이 ghost-free (옵션 A 진행 시 `evaluation-loop-runner` 포함, 옵션 B 진행 시 runner 는 *planned* 표기 명시):
  ```
  # Task 5 Step 1 의 자동 loop 가 MISSING 출력 0
  ```

- [ ] §5.1 의 args 표가 3 creator skill (Step 7 정렬 대상) 과 호환 — `name` / `scope` / event-specific keys 가 명시

- [ ] §6 chain 절차가 §5.2 runner 산출 contract 와 일치 (`mode` / `routing_decision` / `round` 필드)

- [ ] §6 종료 조건 4종이 §8 verification cycle 시나리오 3건 (no-op / 사용자 stop / 같은 skill 2회) 의 검증 대상으로 명시

- [ ] §7 anti-pattern 8 항목이 *증상 + 수정* 표로 정리 (CONSTITUTION §3.3 / Routing §2 / §6 카운터 책임 등 cross-ref 포함)

- [ ] §8 verification 13 시나리오 + 검증 방법 3 항목 + Limits 명시

- [ ] spec_version v1 통일 (§3.1 / §3.2 / §3.3 / §4 공통 헤더)

- [ ] (선택) spec §7 Step 6 ✅ 표기 갱신 — Step 7 version bump 직전 한 번 더

- [ ] Step 7 진행 가능 신호 — version bump 영향 검사 결과 *minor bump* 적합 (Task 6 Step 2 정리)

- [ ] Commit 3-4건 (§5 / §6 / §7+§8 / consistency pass) + (옵션) spec 갱신 1건 = 3-5 commits

---

## Notes for executor

본 plan 은 *문서 작성* 중심이므로 실행 비용이 Step 2-4 대비 낮다 (자산 본문 만지지 않음). 전체 4 commit + 옵션 1 commit, 예상 ~1-2시간.

옵션 (A) (Step 5 → Step 6) 진행 시 Step 5 plan 부재 → 사용자가 Step 5 plan 을 먼저 요청해야 본 plan 진입 가능. Step 5 plan 작성 후 Step 6 진입.

옵션 (B) 진행 시 §5.2 만 placeholder 유지 + Step 5 후 §5.2 부분만 재실행 — Task 2 Step 3 skip + Task 2 Step 4 의 §5.1 만 작성. 재진입 시 Task 2 Step 3 만 실행 (separate commit).

Step 7 (`creator skill args 호환 정렬 + version bump 0.1.3 → 0.2.0`) 은 본 Step 6 의 §5.1 args 표를 contract 로 사용 — Step 6 → Step 7 순서 권장. Step 4b (creator-gap-eval 추출) 는 Step 7 의 prerequisite refinement (3 creator §0 surface 정리) — Step 6 와 무관, 별도 순서.
