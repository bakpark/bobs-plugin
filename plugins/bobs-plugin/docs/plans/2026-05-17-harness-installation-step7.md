# Harness Installation — Step 7 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 3 creator skill (`skill-creator` / `agent-creator` / `hook-creator`) 의 §0 (Capture intent) 가 Phase 1 design skill 의 spec `Execution Plan` args 를 *입력 contract* 로 받도록 정렬한다. main session 이 spec 항목별 dispatch 시 args 를 첫 메시지로 전달하면 creator §0 이 *누락된 키만* 사용자에게 질문. 본 Step 으로 design ↔ execution 자동 chain 이 인터페이스 호환 완성. 동시에 plugin version 0.1.3 → 0.2.0 minor bump (spec §10 Decision 6 — breaking 변경 누적 마무리).

**Architecture:** 3 creator §0 의 *6가지 intent 질문* (책임 / trigger / negative / output / effects / scope) 은 그대로 유지 — args 가 일부 키를 *사전 채움* 만 한다. workflow doc §5.1 의 args 표 (Step 6 산출) 가 contract — `skill-creator: {name, scope}`, `agent-creator: {name, scope, subagent_type?}`, `hook-creator: {name, event, matcher, scope}`. 누락된 키는 §0 의 해당 질문이 그대로 트리거됨 (인터페이스는 *입력 옵션* 이지 *강제* 아님 — pre-fill semantics).

**Tech Stack:** Edit tool (3 creator SKILL.md 의 §0 + frontmatter description), plugin.json / marketplace.json / README version 갱신, agent-skill-auditor (선택 — Step 7 산출의 정적 감사)

**Spec:** `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` §7 Step 7 (Creator skill 정리 — "모두 spec 인터페이스 (`Execution Plan` 의 `target` / `args` 형식) 호환 확인. 호환 안 되면 args 파싱 헬퍼 보강") + §10 Decision 6 (commit 전략 — "version bump 는 모든 Step 완료 후 한 번 0.2.0 minor bump, breaking")

**전체 migration 중 위치:** Step 7 of 7 (마지막). **Prerequisites**:

| Prereq | 상태 | 영향 |
|---|---|---|
| Step 4b (creator-gap-eval 추출) | 사용자 plan 작성 완료 (`2026-05-17-harness-installation-step4b.md`) — 실행 여부에 따라 본 Step 표면 달라짐 | Step 4b 진행 후 본 Step 진입 시 §0 정렬만 (§3-§4 는 stub). Step 4b 미진행 시 본 Step 은 §0 만 만짐 — Step 4b 차후 진행 시 §3-§4 stub 교체와 conflict 없음 (§0 ↔ §3-§4 다른 위치) |
| Step 5 (`evaluation-loop-runner`) | plan 미작성 | runner 본문은 Step 5 책임 — 본 Step 은 *creator skill* 만 정렬. Step 5 자체는 본 Step 의 차후 진행 가능 (의존 없음) |
| Step 6 (workflow doc §5/§6/§7/§8 채움) | plan 작성 완료, 미실행 (본 plan 과 동시 작성) | **권장 prereq** — Step 6 의 §5.1 args 표가 본 Step 의 contract. Step 6 미실행 시 본 Step 의 args 표는 *본 plan Task 1 Step 4* 에 직접 정의 (가독성 ↓ — Step 6 → Step 7 순서 권장) |

본 plan 은 Step 6 완료 가정. Step 6 미실행 시 본 plan 의 §5.1 인용 부분을 *본 plan 의 args 표* 로 inline 처리.

---

## File Structure

| 파일 | 변경 종류 | 책임 |
|---|---|---|
| `plugins/bobs-plugin/skills/skill-creator/SKILL.md` | Edit (§0 + frontmatter description + Limits 1줄) | spec args 입력 contract 명시 (~15-25 lines 추가) |
| `plugins/bobs-plugin/skills/agent-creator/SKILL.md` | Edit (§0 + frontmatter description + Limits 1줄) | 동일 (~15-25 lines 추가) |
| `plugins/bobs-plugin/skills/hook-creator/SKILL.md` | Edit (§0 + frontmatter description + Limits 1줄) | 동일 (~15-25 lines 추가) |
| `plugins/bobs-plugin/.claude-plugin/plugin.json` | Edit (version 0.1.3 → 0.2.0) | minor bump (breaking — Step 1-7 누적) |
| `.claude-plugin/marketplace.json` | Edit (version 0.1.3 → 0.2.0) | 동일 |
| `README.md` | Edit (version 인용 — 있다면) | 통일 |
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` | Edit (§7 Step 7 ✅ + 모든 Step ✅ 정리) | spec status 마무리 |
| (선택) `plugins/bobs-plugin/skills/evaluation-loop-runner/` 인용 | grep 검사 | runner 부재 시 본 Step 은 *creator 만* 정렬 — runner 호환은 Step 5 책임 |

**유지** (변경 없음):
- 3 creator skill 의 §1 (Choose scope) / §2 (Draft) / §3 (GAP 분석) / §4 (Self-feedback refine) / §5 (Output) / §6 (Terminology and tone pass) / Mini example / Limits 본문 — 본 Step 은 §0 만 정렬
- 4 design skill — design 쪽은 이미 spec args 산출. 본 Step 은 *수신 side* (creator) 만 정렬
- 모든 references — 변경 없음
- `claude-automation-recommender` (vendored) — 변경 없음
- `agent-skill-auditor` — 변경 없음 (선택 검증 도구로 사용)

**deprecation 없음**: 본 Step 은 인터페이스 정렬 + version bump 만. 자산 삭제 없음.

---

## Note on TDD for creator skill alignment

3 creator §0 정렬은 *명세 변경* 이므로 외부 TDD 가 적용되지 않는다. *verify-baseline → change → verify-result → commit* 패턴:

1. **baseline verify** — 작성 전 grep 으로 현재 §0 본문 + args 입력 흔적 (있다면) 확인
2. **change** — §0 의 *intent table* 앞에 "args 입력 contract" 단락 + Limits 에 args spec 한 줄 추가
3. **result verify** — grep 재실행으로 (a) args 입력 contract 단락 작성됨 (b) intent table 6 항목 보존됨 (c) §1-§6 본문 회귀 없음 확인
4. **commit** — verify 통과 후 즉시

각 creator 별 separate commit 권장 (3 commits) — 회귀 시 rollback 단위 명확.

## Note on "묻지 말고 진행" 모드 (mini-gate 약화)

본 plan 의 mini-gate 는 *명세 변경* 이 부수 효과 (CONSTITUTION §3.3) 이므로 default 강한 형태. 사용자 *묻지 말고 진행* 합의 시 *disclosure-only* 로 약화 — 작성 경로 + 종류 + 변경 요약 4 항목을 응답에 기록하되 확인 없이 진행.

본 plan 은 약화를 plan 단위로 합의한 것으로 간주. 호출자가 강한 gate 를 원하면 본 plan 실행 *전* 합의 철회.

---

### Task 1: 사전 조사 — 3 creator §0 baseline + args 표 contract 확정

**Files:**
- (편집 없음 — 분석만)

본 Task 는 commit 없음. 결과는 Task 2-4 본문 작성 입력.

- [ ] **Step 1: 3 creator §0 본문 baseline read**

```bash
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c §0 ==="
  sed -n '/^## 0\. Capture intent/,/^## 1\./p' "plugins/bobs-plugin/skills/$c/SKILL.md"
done
```

Expected 산출:
- 각 creator §0 의 *6가지 intent 질문* (Capture intent 표) 위치 + 현재 길이 확인
- 기존 args 입력 흔적 (있다면) — 현재 무 (Step 3 의 `resource-design` 가 args 형식 정의했으나 creator side 는 미정렬)

- [ ] **Step 2: workflow doc §5.1 args 표 확인 (Step 6 산출)**

```bash
# Step 6 완료 가정 — §5.1 의 args 표 추출
sed -n '/^### 5\.1/,/^### 5\.2/p' plugins/bobs-plugin/references/harness-installation-workflow.md | \
  grep -E "^\| .skill-creator|^\| .agent-creator|^\| .hook-creator"
```

Expected (Step 6 완료 시):
```
| `skill-creator` | `name` (kebab-case), `scope` (user / project / plugin) |
| `agent-creator` | `name` (kebab-case), `scope` (user / project / plugin), `subagent_type` (선택 — main session 호출용 식별자) |
| `hook-creator` | `name` (kebab-case), `event` (PostToolUse / Stop / UserPromptSubmit 등), `matcher` (event 별 — 예: PostToolUse 의 tool 이름), `scope` (user / project) |
```

Step 6 미완 시 본 plan 의 args 표를 *inline* 으로 사용 (위 표 그대로).

- [ ] **Step 3: Step 4b (creator-gap-eval 추출) 상태 확인**

```bash
ls plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md 2>/dev/null
# 있으면 Step 4b 완료 — 3 creator §3-§4 가 stub 으로 교체된 상태
# 없으면 Step 4b 미진행 — 3 creator §3-§4 가 본문 유지 (본 Step 영향 없음 — §0 만 만짐)
```

Step 4b 완료 여부와 무관하게 본 Step 진행 가능 — §0 변경은 §3-§4 변경과 *다른 위치*, conflict 없음. 단 Step 4b 가 *본 Step 후에* 진행되면 §3-§4 stub 교체와 §0 본문이 *동시 존재* 가능 (한 commit 으로 묶지 않음).

- [ ] **Step 4: 6가지 intent 질문 ↔ args 키 매핑 (creator 별)**

| Creator | intent 질문 | args 키 매핑 | 사전 채움 시 §0 동작 |
|---|---|---|---|
| skill-creator | #1 책임 | (없음 — 사용자 의도 본질) | 항상 질문 |
| skill-creator | #2 트리거 (1-3개) | (없음) | 항상 질문 |
| skill-creator | #3 negative trigger (≥1) | (없음) | 항상 질문 |
| skill-creator | #4 호출자 산출물 사용 | (없음) | 항상 질문 |
| skill-creator | #5 부수 효과 | (없음) | 항상 질문 |
| skill-creator | #6 scope | `scope` | 채워지면 질문 skip |
| skill-creator | (별도) 이름 결정 | `name` | 채워지면 §1 collision check 단계 input |
| agent-creator | #1-#5 동일 | (없음) | 항상 질문 |
| agent-creator | #6 scope | `scope` | 채워지면 skip |
| agent-creator | (별도) 이름 + subagent_type | `name` + `subagent_type` | 채워지면 §1 input |
| hook-creator | #1-#5 동일 (단, hook 특수 질문: event / matcher / 실행 비용 / 결정론 요건) | (event/matcher 는 args) | 매핑 |
| hook-creator | #6 scope | `scope` | 채워지면 skip |
| hook-creator | (별도) 이름 + event + matcher | `name` + `event` + `matcher` | 채워지면 §1 + §2 input |

핵심 결정: *args 는 §0 의 일부 키만 사전 채움*, *intent 본질 질문 (#1-#5) 은 args 로 우회 불가* (자원 작성의 핵심). args 가 있으면 §0 의 *해당 질문만 skip*, 나머지는 그대로 사용자에게 묻는다.

- [ ] **Step 5: §0 정렬 본문 template 결정 (3 creator 공통 형태)**

각 creator §0 첫 단락 앞에 *args 입력 contract* 단락 추가:

```markdown
## 0. Capture intent

**args 입력 contract** (선택 — main session 이 design skill spec 의 `Execution Plan` 항목으로 호출 시):

| 키 | 의미 | 본 §0 에서 사용 |
|---|---|---|
| `name` | <creator 별 — skill/agent/hook 의 kebab-case 이름> | §1 collision check input. 채워지면 사용자 이름 질문 skip |
| `scope` | `user` / `project` / `plugin` | 본 §0 의 6번 질문 (어디에 두나) 사전 채움. 채워지면 해당 질문 skip |
| ... (creator 별 추가 키) | <event/matcher 등> | <해당 §0 위치 input> |

args 키가 누락된 채 호출되면 *해당 키의 §0 질문만* 사용자에게 묻는다 (intent 본질 질문 #1-#5 는 args 로 우회 불가 — 항상 질문). args 없는 호출 (사용자 직접 `/<creator-name>` 진입) 은 본 §0 의 6 질문 모두 사용자에게 묻는 동작 — 기존 동작 보존.

본 §0 의 *6가지 intent 질문* (책임 / trigger / negative / output / effects / scope) ...

[이하 기존 §0 본문 유지]
```

본 단락은 §0 진입 직후, 기존 6질문 표 직전에 위치. 기존 본문은 *보존* — args 가 없는 (사용자 직접 호출) 흐름은 변경 없음.

**Limits 추가 한 줄** (각 creator §Limits 절):

```markdown
- args 입력 contract (§0) — main session 의 design skill spec dispatch 진입점. `name` / `scope` 등 일부 키 사전 채움 허용, intent 본질 질문 (책임 / trigger / negative / output / effects) 은 args 로 우회 불가
```

- [ ] **Step 6: frontmatter description 갱신 (각 creator)**

현재 description (3 creator 공통 패턴 — 단축):
- skill-creator: "Claude Code 스킬(`SKILL.md`) 작성·개선을 위한 절차 메타 스킬..."
- agent-creator: "..."
- hook-creator: "..."

각 description 끝에 *args 호환 한 줄* 추가 (≤ 50 chars):

```
... design skill spec 의 Execution Plan args 입력 가능.
```

총 description 길이 ≤ 500 chars (SKILL-GUIDE §3 권고) 유지. 현재 길이 측정 후 50 chars 여유 확인:

```bash
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c ==="
  awk '/^description:/,/^[a-z]/' "plugins/bobs-plugin/skills/$c/SKILL.md" | \
    sed '/^[a-z]/d' | wc -c
done
```

길이 부족하면 다른 부분 한 줄 압축. 본 작업은 Task 2/3/4 의 각 Step 에서 처리.

---

### Task 2: skill-creator §0 + frontmatter + Limits 정렬

**Files:**
- Edit: `plugins/bobs-plugin/skills/skill-creator/SKILL.md`

- [ ] **Step 1: baseline read (§0 + frontmatter + Limits)**

```bash
# frontmatter
sed -n '1,15p' plugins/bobs-plugin/skills/skill-creator/SKILL.md

# §0
sed -n '/^## 0\. Capture intent/,/^## 1\./p' plugins/bobs-plugin/skills/skill-creator/SKILL.md

# Limits
sed -n '/^## Limits/,$p' plugins/bobs-plugin/skills/skill-creator/SKILL.md
```

- [ ] **Step 2: §0 args 입력 contract 단락 추가**

template (Task 1 Step 5 의 형태에 skill-creator 별 args 매핑 반영):

```markdown
## 0. Capture intent

**args 입력 contract** (선택 — main session 이 design skill (`resource-design`) spec 의 `Execution Plan` 항목으로 호출 시):

| 키 | 의미 | 본 §0 에서 사용 |
|---|---|---|
| `name` | skill 의 kebab-case 이름 | §1 collision check input. 채워지면 사용자 이름 질문 skip |
| `scope` | `user` / `project` / `plugin` | 본 §0 의 6번 질문 (어디에 두나) 사전 채움. 채워지면 해당 질문 skip |

args 키가 누락된 채 호출되면 *해당 키의 §0 질문만* 사용자에게 묻는다. intent 본질 질문 (#1 책임 / #2 트리거 / #3 negative / #4 호출자 산출물 / #5 부수 효과) 은 args 로 우회 불가 — 항상 사용자에게 묻는다 (skill 의 핵심 의도 결정).

args 없는 사용자 직접 호출 (`/skill-creator`) 은 본 §0 의 6 질문 + 이름 결정 모두 사용자에게 묻는 동작 — 기존 동작 보존.

[이하 기존 §0 본문 유지]
```

- [ ] **Step 3: frontmatter description 갱신**

기존 description 끝에 추가:
```
... design skill spec 의 Execution Plan args 입력 가능.
```

전체 길이 ≤ 500 chars 검증. 초과 시 description 의 *최소한* 압축 (기존 본문은 보존, 새 한 줄만 우선).

- [ ] **Step 4: Limits 한 줄 추가**

```markdown
- args 입력 contract (§0) — main session 의 design skill spec dispatch 진입점. `name` / `scope` 사전 채움 허용, intent 본질 질문 (#1-#5) 은 args 로 우회 불가
```

`## Limits` 절의 첫 항목 (Capability surface) 다음에 위치.

- [ ] **Step 5: Edit 적용 (3 부분 한 commit)**

mini-gate 5 항목:

| 항목 | 내용 |
|---|---|
| 작성 경로 | `plugins/bobs-plugin/skills/skill-creator/SKILL.md` |
| 작업 종류 | Edit (3 부분 — frontmatter description / §0 args 단락 / Limits 한 줄) |
| 추가 본문 | ~20-30 lines |
| intent 본질 보존 | §0 의 6 질문 표 + escape hatch 표 + collision check 모두 그대로 |
| 후속 영향 | main session 이 spec dispatch 시 `name` / `scope` 사전 채움 가능 — backward-compatible (사용자 직접 호출 동작 보존) |

3 Edit 적용:

```
Edit(SKILL.md, old_string="## 0. Capture intent\n\n**먼저 읽는다**:", 
     new_string=<Step 2 contract 단락> + "\n\n**먼저 읽는다**:")

Edit(SKILL.md, old_string="description: ...<기존 끝>", 
     new_string="description: ...<기존 끝>... design skill spec 의 Execution Plan args 입력 가능.")

Edit(SKILL.md, old_string="## Limits\n\n- **Capability surface** — ...", 
     new_string="## Limits\n\n- **Capability surface** — ...\n- args 입력 contract (§0) — ...")
```

- [ ] **Step 6: Verify**

```bash
# §0 args 단락 작성
grep -c "args 입력 contract" plugins/bobs-plugin/skills/skill-creator/SKILL.md
# Expected: 2 (§0 + Limits)

# 6 intent 질문 표 보존
grep -c "재사용 책임\|트리거 (1-3개)\|Negative trigger\|호출자가 산출물" \
  plugins/bobs-plugin/skills/skill-creator/SKILL.md
# Expected: ≥4 (기존 §0 표 보존 확인)

# frontmatter description 한 줄 추가
grep -A2 "^description:" plugins/bobs-plugin/skills/skill-creator/SKILL.md | grep -c "Execution Plan args"
# Expected: ≥1

# 본문 회귀 검사 — §1-§6 본문 line 수 변화 없음
sed -n '/^## 1\./,/^## End$/p' plugins/bobs-plugin/skills/skill-creator/SKILL.md | wc -l
# Expected: 변경 전과 동일 (±2 line 허용)
```

- [ ] **Step 7: Commit**

```bash
git commit -am "Align skill-creator §0 with design skill spec args contract"
```

---

### Task 3: agent-creator §0 + frontmatter + Limits 정렬

**Files:**
- Edit: `plugins/bobs-plugin/skills/agent-creator/SKILL.md`

agent-creator 의 args 표는 skill-creator + `subagent_type` (선택 — main session 호출용 식별자).

- [ ] **Step 1: baseline read** — Task 2 Step 1 패턴 동일, 대상만 agent-creator

- [ ] **Step 2: §0 args 입력 contract 단락 추가**

template:

```markdown
## 0. Capture intent

**args 입력 contract** (선택 — main session 이 design skill (`resource-design`) spec 의 `Execution Plan` 항목으로 호출 시):

| 키 | 의미 | 본 §0 에서 사용 |
|---|---|---|
| `name` | agent 의 kebab-case 이름 | §1 collision check input. 채워지면 사용자 이름 질문 skip |
| `scope` | `user` / `project` / `plugin` | 본 §0 의 6번 질문 사전 채움. 채워지면 skip |
| `subagent_type` | (선택) main session `Agent` tool 호출용 식별자 | §1 또는 §2 frontmatter 작성 시 input. 채워지면 자동 결정 skip |

args 키가 누락된 채 호출되면 *해당 키의 §0 질문만* 사용자에게 묻는다. intent 본질 질문 (#1-#5) 은 args 로 우회 불가 — agent 의 책임 / 격리 정당화 / 부수 효과 정책 결정의 핵심.

args 없는 사용자 직접 호출 (`/agent-creator`) 은 §0 의 6 질문 + 이름 + subagent_type 모두 사용자에게 묻는 동작 — 기존 동작 보존.

[이하 기존 §0 본문 유지]
```

- [ ] **Step 3: frontmatter description 갱신** — Task 2 Step 3 동일

- [ ] **Step 4: Limits 한 줄 추가** — Task 2 Step 4 패턴, args 키는 `name` / `scope` / `subagent_type`

- [ ] **Step 5: Edit 적용** — Task 2 Step 5 패턴

mini-gate 5 항목 (Task 2 Step 5 표 동일, args 키만 다름).

- [ ] **Step 6: Verify** — Task 2 Step 6 패턴, grep 대상 동일

- [ ] **Step 7: Commit**

```bash
git commit -am "Align agent-creator §0 with design skill spec args contract"
```

---

### Task 4: hook-creator §0 + frontmatter + Limits 정렬

**Files:**
- Edit: `plugins/bobs-plugin/skills/hook-creator/SKILL.md`

hook-creator 의 args 는 가장 풍부 — `name` / `event` / `matcher` / `scope` 4종.

- [ ] **Step 1: baseline read** — Task 2 Step 1 패턴, 대상 hook-creator

- [ ] **Step 2: §0 args 입력 contract 단락 추가**

template:

```markdown
## 0. Capture intent

**args 입력 contract** (선택 — main session 이 design skill (`resource-design`) spec 의 `Execution Plan` 항목으로 호출 시):

| 키 | 의미 | 본 §0 에서 사용 |
|---|---|---|
| `name` | hook 의 kebab-case 이름 (script 파일명 기반) | §1 collision check input. 채워지면 사용자 이름 질문 skip |
| `event` | `PostToolUse` / `Stop` / `UserPromptSubmit` / `PreToolUse` / `PostCompact` 등 | 본 §0 의 *언제 트리거* 질문 사전 채움. 채워지면 skip |
| `matcher` | event 별 — `PostToolUse` 의 tool 이름 / `Stop` 의 reason 등. 비워두면 모든 매칭 | §2 settings.json registration 작성 input |
| `scope` | `user` / `project` (hook 은 plugin scope 없음 — settings.json 위치 고정) | 본 §0 의 6번 질문 사전 채움 |

args 키가 누락된 채 호출되면 *해당 키의 §0 질문만* 사용자에게 묻는다. intent 본질 질문 (#1 책임 / #2 negative / #3 결정론 요건 / #4 실행 비용 / #5 부수 효과 — hook 특수 형태) 은 args 로 우회 불가 — hook 의 보안·성능·결정론 결정의 핵심.

args 없는 사용자 직접 호출 (`/hook-creator`) 은 §0 의 모든 질문 + 이름 + event + matcher 모두 사용자에게 묻는 동작 — 기존 동작 보존.

[이하 기존 §0 본문 유지]
```

- [ ] **Step 3: frontmatter description 갱신** — Task 2 Step 3 동일

- [ ] **Step 4: Limits 한 줄 추가** — args 키는 `name` / `event` / `matcher` / `scope`

- [ ] **Step 5: Edit 적용** — Task 2 Step 5 패턴

mini-gate 5 항목 (args 키 풍부 — `name` / `event` / `matcher` / `scope`).

- [ ] **Step 6: Verify** — Task 2 Step 6 패턴 + hook 특수 질문 (event / matcher) 보존 확인:

```bash
grep -c "event\|matcher\|결정론\|실행 비용" plugins/bobs-plugin/skills/hook-creator/SKILL.md
# Expected: ≥5 (hook 특수 질문 보존)
```

- [ ] **Step 7: Commit**

```bash
git commit -am "Align hook-creator §0 with design skill spec args contract"
```

---

### Task 5: version bump 0.1.3 → 0.2.0 (plugin.json + marketplace.json + README + spec)

**Files:**
- Edit: `plugins/bobs-plugin/.claude-plugin/plugin.json`
- Edit: `.claude-plugin/marketplace.json`
- Edit: `README.md` (version 인용 — 있다면)
- Edit: `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` (§7 Step 7 ✅ + 마무리 status)

spec §10 Decision 6: "version bump 는 모든 Step 완료 후 한 번 (0.2.0 — minor bump, breaking)". Step 1-6 + 4b 모두 *breaking* 누적 (자산 신규 / 삭제 / 인터페이스 변경). Step 7 의 §0 args 정렬은 backward-compatible 이지만 *누적 변경* 으로 minor bump.

- [ ] **Step 1: 현재 version 확인 + 인용 위치 검색**

```bash
# version 위치
grep -rn '"version"' plugins/bobs-plugin/.claude-plugin/ .claude-plugin/ 2>/dev/null

# README 인용
grep -n "0\.1\.3\|0\.2\.0" README.md plugins/bobs-plugin/README.md 2>/dev/null

# 본문 인용 — references / skills 에 version 직접 인용 있나
grep -rn "0\.1\.3" plugins/bobs-plugin/ --include="*.md" 2>/dev/null
```

Expected:
- `plugin.json` + `marketplace.json` 의 `"version": "0.1.3"`
- README: 0건 또는 1-2건 (file tree 의 path 인용 — 0.1.3 plugins cache path)
- skill 본문의 fallback path 인용 (`0.1.3` 디렉토리) — 갱신 필요

- [ ] **Step 2: plugin.json + marketplace.json version bump**

```
Edit(plugin.json, old_string='"version": "0.1.3"', new_string='"version": "0.2.0"')
Edit(marketplace.json, old_string='"version": "0.1.3"', new_string='"version": "0.2.0"')
```

- [ ] **Step 3: README + 본문 인용 갱신**

README + skill 본문의 `0.1.3` path 인용 모두 `0.2.0` 으로 갱신. 단, *historical archive* (예: `references/v1/` / `references/v2/` snapshot 헤더) 는 *유지* — 과거 버전 표기 의도적.

```bash
# 갱신 대상 자동 발견 (historical archive 제외)
grep -rl "0\.1\.3" plugins/bobs-plugin/ \
  --include="*.md" --include="*.json" \
  --exclude-dir=v1 --exclude-dir=v2 --exclude-dir=workspace --exclude-dir=gaps 2>/dev/null
```

각 파일 별 Edit. 본 Step 의 갱신 위치 수 *기록* (Task 6 verification 입력).

- [ ] **Step 4: spec status 마무리**

spec `docs/specs/2026-05-17-harness-installation-design.md` §7 Step 7 갱신:

```
### Step 7. Creator skill 정리 ✅

- `agent-creator` 상태 정리 — 이미 사용자 측에서 완료 확인됨
- `hook-creator` 완성 (별도)
- 모두 spec 인터페이스 (`Execution Plan` 의 `target` / `args` 형식) 호환 확인 — Step 7 plan 실행으로 §0 args 입력 contract 정렬 완료
- version bump 0.1.3 → 0.2.0 (minor, breaking — Step 1-7 누적)
```

전체 Step 1-7 모두 ✅ 표기. 상태 필드 (`상태: Draft (사용자 검토 대기)`) 도 `Implemented` 로 갱신 (옵션).

- [ ] **Step 5: 모두 한 commit (version bump 는 atomic)**

mini-gate 5 항목:

| 항목 | 내용 |
|---|---|
| 작성 경로 | plugin.json + marketplace.json + README + 본문 (~N 위치) + spec |
| 작업 종류 | Edit (version 숫자 + spec status 마무리) |
| 변경 본질 | 0.1.3 → 0.2.0 (minor, breaking) |
| historical archive 보존 | `references/v1/` `references/v2/` `*-workspace/` `gaps/` 모두 유지 |
| 후속 영향 | 새 cache path (`/Users/macpro/.claude/plugins/cache/bobs-plugin/bobs-plugin/0.2.0/`) — 사용자가 plugin update 후 로드 |

```bash
git commit -am "Bump plugin version 0.1.3 → 0.2.0 (minor, breaking: Step 1-7 cumulative)"
```

- [ ] **Step 6: Verify version 통일**

```bash
# version 0.2.0 적용
grep -c '"version": "0.2.0"' plugins/bobs-plugin/.claude-plugin/plugin.json .claude-plugin/marketplace.json
# Expected: 2

# 0.1.3 잔존 0 (historical archive 제외)
grep -rln "0\.1\.3" plugins/bobs-plugin/ \
  --include="*.md" --include="*.json" \
  --exclude-dir=v1 --exclude-dir=v2 --exclude-dir=workspace --exclude-dir=gaps 2>/dev/null
# Expected: empty (활성 자산에서 0.1.3 잔존 0)
```

---

### Task 6: Verification — design ↔ creator chain 호환 + ghost-free + spec mark complete

**Files:**
- (선택) Edit: workflow doc / spec — Task 2-5 산출 회귀 검사 결과 따라

본 Task 는 *integration verification* — Step 7 의 모든 변경이 일관되게 동작하는지 검증.

- [ ] **Step 1: design skill → creator chain dry-run (수동 점검)**

각 design skill (`resource-design` 우선) 의 spec `Execution Plan` 형식이 본 Step 의 creator §0 args 입력 contract 와 호환되는지 확인:

```bash
# resource-design 의 spec 형식 인용
grep -A20 "## Execution Plan" plugins/bobs-plugin/skills/resource-design/references/design-output-contract.md 2>/dev/null
# 또는
grep -A20 "## Execution Plan" plugins/bobs-plugin/references/harness-installation-workflow.md
```

각 creator args 표 (Task 2-4 의 §0) ↔ spec `Execution Plan` 의 `args` 키 형식 일치 확인. 불일치 발견 시 design skill 의 design-output-contract 갱신 (별도 follow-up) 또는 본 Step 의 §0 args 표 보강.

- [ ] **Step 2: workflow doc §5.1 args 표 ↔ 3 creator §0 args 표 일치**

```bash
# §5.1 args 표
sed -n '/^### 5\.1/,/^### 5\.2/p' plugins/bobs-plugin/references/harness-installation-workflow.md | \
  grep -E "skill-creator|agent-creator|hook-creator"

# 3 creator §0 args 표
for c in skill-creator agent-creator hook-creator; do
  echo "=== $c ==="
  sed -n '/args 입력 contract/,/intent 본질 질문/p' "plugins/bobs-plugin/skills/$c/SKILL.md" | \
    head -20
done
```

각 args 키 (`name`, `scope`, `subagent_type?`, `event`, `matcher`) 가 workflow doc + 3 creator 양측 일치. 불일치 시 *workflow doc 측* 또는 *creator 측* 어느 쪽이 진실 source 인지 결정 (Step 6 의 §5.1 이 contract → workflow doc 우선).

- [ ] **Step 3: backward compatibility 회귀 검사 — 사용자 직접 호출 동작 보존**

각 creator 의 §0 *args 없는 직접 호출* 흐름이 기존 동작 보존하는지 확인 — Task 2-4 Step 6 의 grep 으로 6 intent 질문 표 + escape hatch 표 + collision check 모두 보존 확인. 회귀 발견 시 본 Step rollback (해당 Task commit revert).

- [ ] **Step 4: ghost reference 정적 감사 (선택, agent-skill-auditor)**

```
# /agent-skill-auditor — target: 3 creator SKILL.md
```

본 Step 의 §0 args 단락이 *존재하지 않는 키 / 자원* 을 인용하지 않는지 audit. 본 plan 의 args 키는 design skill spec 의 표준 인터페이스 — ghost 가능성 낮음. audit 결과 P0/P1 0건 expected.

- [ ] **Step 5: spec 의 모든 Step ✅ 표기 (마무리)**

```bash
grep -nE "^### Step [1-7]" plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md
# Expected: 7 행, 모두 ✅ 표기 (Step 5 plan 미실행 시 Step 5 만 미완 표기 유지)
```

Step 5 (`evaluation-loop-runner`) 가 미진행이면 Step 5 만 ✅ 미표기. 본 Step 7 plan 의 마무리는 *Step 5 별도 진행 가능* 으로 두고 spec 의 Step 5 는 *진행 중* 또는 *plan 작성 필요* 표기.

- [ ] **Step 6: (선택) spec 갱신 commit**

Step 5 가 본 Step 진행 시점에 미완 → spec 갱신은 Step 5 plan 작성 후 일괄 처리 권장 (본 Step 의 spec 갱신은 *§7 Step 7 마무리 + version bump 표기* 만, Step 5 마무리는 별도).

---

## Done Criteria

본 Step 7 가 완료되면 다음 조건이 모두 충족됨:

- [ ] 3 creator skill 의 §0 에 *args 입력 contract* 단락 작성 (3 commits):
  ```
  grep -l "args 입력 contract" plugins/bobs-plugin/skills/skill-creator/SKILL.md \
    plugins/bobs-plugin/skills/agent-creator/SKILL.md \
    plugins/bobs-plugin/skills/hook-creator/SKILL.md | wc -l
  # Expected: 3
  ```

- [ ] 각 creator 의 §0 본문 6 intent 질문 표 + escape hatch 표 + collision check 모두 보존 (backward-compatible)

- [ ] 각 creator 의 frontmatter description 끝에 *Execution Plan args 입력 가능* 한 줄 추가 (≤ 500 chars 유지)

- [ ] 각 creator 의 §Limits 에 *args 입력 contract (§0)* 한 줄 추가

- [ ] workflow doc §5.1 args 표 ↔ 3 creator §0 args 표 일치 (모든 args 키 양측 매핑)

- [ ] design skill spec `Execution Plan` 형식이 creator §0 args 입력 contract 와 호환 (dry-run 확인)

- [ ] plugin.json + marketplace.json version 0.1.3 → 0.2.0:
  ```
  grep -c '"version": "0.2.0"' plugins/bobs-plugin/.claude-plugin/plugin.json .claude-plugin/marketplace.json
  # Expected: 2
  ```

- [ ] 활성 자산 (historical archive 제외) 에서 0.1.3 잔존 0:
  ```
  grep -rln "0\.1\.3" plugins/bobs-plugin/ \
    --include="*.md" --include="*.json" \
    --exclude-dir=v1 --exclude-dir=v2 --exclude-dir=workspace --exclude-dir=gaps
  # Expected: empty
  ```

- [ ] spec §7 Step 7 ✅ + version bump 표기 (Step 5 미완 시 Step 5 만 ✅ 미표기)

- [ ] Commit 4건 (3 creator + version bump) + (선택) spec 갱신 1건 = 4-5 commits

- [ ] (선택) agent-skill-auditor 정적 감사 P0/P1 0건

---

## Notes for executor

본 plan 은 *명세 정렬* + *version bump* 만 — 자산 본문 (§1-§6) 만지지 않음. 전체 4-5 commit + 옵션 1 commit, 예상 ~30-60분.

**Step 4b 와의 순서 무관성**:
- Step 4b (`creator-gap-eval` 추출) 진행 시 3 creator §3-§4 가 stub 으로 교체 — 본 Step 7 의 §0 변경과 *다른 위치* 이므로 conflict 없음
- Step 4b 후 Step 7 진행 시: §0 정렬만 → 작업 표면 작음
- Step 7 후 Step 4b 진행 시: §3-§4 stub 교체 — 본 Step 의 §0 args 단락 보존됨
- 양측 모두 가능, 순서 어느 쪽이든 무관 (단 한 commit 으로 묶지 말 것 — separate commit 으로 회귀 단위 명확)

**Step 5 와의 순서**:
- Step 5 (`evaluation-loop-runner`) 의 §0 도 본 Step 7 의 args 입력 contract 패턴 적용 권장 — 단, Step 5 본문 작성이 본 Step 진행 시점에 미완 → Step 5 plan 에서 처리. 본 Step 7 은 *creator 3종만* 정렬

**다음 plan**:
- Step 5 plan (별도 — `evaluation-loop-runner` runtime skill)
- (선택) GAP-005 GUIDE_GAP follow-up — SKILL-GUIDE §7/§8 에 write-procedure reference 권장 골격 추가 (Step 4 GAP report 의 follow-up)

**version 0.2.0 의미**:
- minor bump (breaking) — Step 1-7 누적 변경:
  - Step 1: harness-engineering.md → harness-principles.md 이름 변경 + §5-7 삭제
  - Step 2: 3 skill 삭제 (`agents-md-author` / `context-map-builder` / `claude-md-improver`) + `context-map-architecture` 신규
  - Step 3: `harness-resource-design` 삭제 + `agent-skill-designer` agent 삭제 + `resource-design` 신규
  - Step 4: `evaluation-loop-design` 신규
  - Step 4b (옵션): `creator-gap-eval` 신규 + 3 creator §3-§4 stub 교체
  - Step 5 (별도): `evaluation-loop-runner` 신규
  - Step 6: workflow doc 4 TBD 본문화
  - Step 7: 3 creator §0 args 호환 정렬
- 0.1.3 사용자가 새 version 으로 update 시 plugin cache 재로드 필요 (`/plugin reload`)
