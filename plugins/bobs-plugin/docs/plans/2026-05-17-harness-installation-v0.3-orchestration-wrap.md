# Harness Installation — v0.3 Orchestration Wrap Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 외부 review (qwen/gpt5/opus 중 하나) 의 P2 권고 4건 적용 — install-harness command 신규 (orchestration 전체 wrap) + Execution Plan YAML schema 고정 + execution_mode 필드 도입 + cycle 종료 조건 정밀화. v0.2.0 의 "메인 세션이 workflow doc 따라 직접 orchestration" 패턴을 v0.3.0 에서 "/install-harness command 가 orchestration boundary" 패턴으로 승격 — CONSTITUTION §3.13 "프롬프트는 실행 경계가 아니다" 원칙 충족.

**Architecture:** install-harness command (Claude Code slash command 형식) 가 routing + design skill 호출 + spec 승인 gate + creator dispatch + runner cycle + 종료 조건 enforce + 사용자 보고를 한 entrypoint 로 통합. workflow doc 은 command 의 reference 로 격하 (현재는 main session 의 reference). 4 Task 는 backward-compatible 1 task (cycle 종료 정밀화) + breaking 3 task (command boundary / YAML schema / execution_mode 필드).

**Tech Stack:** Claude Code slash commands (`plugins/bobs-plugin/commands/*.md` markdown), workflow doc Edit, design skill (3종) 의 spec 산출 형식 변경 (markdown-like → YAML fenced block), creator 3종 + runner 1종 의 args 파싱 변경.

**Spec:** 본 plan 은 v1 spec (`plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md`) 의 *follow-up* 이지만, architecture decision (entrypoint = command vs main session) 이 v1 §1 design intent ("skill 호출 체인") 와 충돌하므로 신규 v2 spec 작성 권장. **Open Question Q1** 에서 spec trajectory 결정.

**전체 migration 중 위치:** v0.2.0 (Step 1-7 + 4b 완료) → v0.3.0 (본 plan). v0.3 는 외부 review 응답 + architecture refinement. backward compatibility 처리는 §8 참조.

**Source of decision:** 외부 review (push 직후 fresh review) — 5 리스크 인용 라인 모두 실제 코드와 일치 (commit `fd188ea` 에서 P0+P1 4건 즉시 fix). 본 plan 은 잔여 P2 4건.

---

## 0. Context (외부 review 응답 정리)

| 리스크 | 평가 권고 | v0.3 응답 |
|---|---|---|
| R1. main session 책임 과다 (workflow:262, :348 + spec §10 Decision 5) | install-harness command 추가 → 라우팅/승인 gate/round counter/stop condition 을 명시적 entrypoint 로 | **Task 1**: `/install-harness` command 신규 (orchestration 전체 wrap) |
| R2. "sub-agent 없이" vs GAP 위임 모순 | 워딩 정정 + GAP 위임 예외 명시 | v0.2.0 commit `fd188ea` 에서 처리 완료 |
| R3. command/runtime/plugin creator 부재 | v1 scope 명시 또는 creator 추가 | v0.2.0 commit `fd188ea` 에서 "design-only/manual" 명시. v2 creator 추가는 별도 plan (본 plan 범위 밖) |
| R4. hook scope 충돌 | workflow args 표 plugin 포함 | v0.2.0 commit `fd188ea` 에서 처리 완료 |
| R5. stale freshness | workflow:5/:47 + spec:474 정정 | v0.2.0 commit `fd188ea` 에서 처리 완료 |
| 과한 부분 1. 이중 gate 모든 곳 | 묶음 승인 검토 | 본 plan 범위 밖 (별도 검토) |
| 과한 부분 2. Execution Plan vs Applied Changes | `execution_mode` 필드 도입 | **Task 3**: design skill 의 spec 산출 contract 에 `execution_mode: dispatch \| self_apply \| plan_only` 필드 추가 |
| 과한 부분 3. "같은 design skill 2회" | same target + same gap fingerprint | **Task 4**: cycle 종료 조건 정밀화 |
| 우선 개선 5번. Execution Plan schema 고정 + dry-run fixture | YAML/JSON schema + fixture | **Task 2**: spec §4 markdown-like Execution Plan → YAML fenced block schema + dry-run fixture |

**사용자 결정 (push 직후 응답)**:
- install-harness scope: **orchestration 전체 wrap** (사용자 명시) — routing + design 호출 + spec gate + creator dispatch + runner cycle + 종료 enforce + 보고 모두 command 책임

---

## 1. Decision Matrix

### Q1: spec trajectory (사용자 결정 필요)

| 옵션 | 설명 | 장점 | 단점 |
|---|---|---|---|
| **A. v1 spec 에 Step 8 추가** | 본 spec `2026-05-17-harness-installation-design.md` 에 Step 8 (v0.3 follow-up) 추가, 기존 Step 1-7 의 흐름 연장 | spec 일관성, migration history 한 곳 | v1 §1 design intent ("skill 호출 체인") 와 install-harness command boundary 가 충돌 — design intent 도 갱신 필요 (deep edit) |
| **B. v2 spec 신규 작성 (권장)** | `docs/specs/2026-05-XX-harness-orchestration-v2.md` 신규, v1 은 frozen Implemented historical | architecture refinement (entrypoint boundary 변경) 을 깔끔하게 분리, v1 의 historical 가치 보존, 사용자가 v1/v2 비교 가능 | spec 파일 2개 — 어느 게 진실 source 인지 명시 필요 (cross-ref) |
| C. spec 없이 plan + commit 으로만 | 본 plan + commit log 가 record | spec 작성 비용 절감 | spec 부재 시 future 사용자가 architecture decision rationale 알 수 없음, harness-principles.md 와 mismatch |

**Default reasonable call (사용자 redirect 가능)**: **옵션 B** — v2 spec 신규 (architecture decision 본질이 변하므로 spec 분리가 깔끔). v1 spec 의 §11 Success Criteria 또는 §12 (신규) Future Work 에 v2 spec link 명시.

### Q2: version bump (사용자 결정 필요)

| 옵션 | 의미 |
|---|---|
| **0.3.0 (minor — breaking, 권장)** | install-harness command 도입은 entrypoint 변경 + YAML schema 는 design skill 의 spec 산출 형식 변경 (breaking). 사용자가 v0.2.0 의 직접 호출 패턴을 유지하면 일부 동작 불일치. SemVer 0.x 의 minor bump 가 breaking 처리. |
| 0.2.1 (patch — non-breaking 만) | Task 4 (cycle 종료 정밀화) 만 적용. Task 1-3 는 v0.3 또는 보류. |
| 1.0.0 (major) | v1 stable 선언. install-harness command + YAML schema = stable interface 약속. 시기상조 가능. |

**Default reasonable call**: **0.3.0** (Task 1-4 통합 sprint).

### Q3: backward compatibility (사용자 결정 필요)

| 옵션 | 의미 |
|---|---|
| **A. workflow doc 직접 호출 패턴은 deprecated 표기 + 동작 유지 (권장)** | v0.3 에서 `/install-harness` 권장, 그러나 사용자가 workflow doc 보고 직접 design skill 호출하는 v0.2 패턴도 여전히 동작. workflow doc 상단에 "권장: `/install-harness` command 사용" 명시. |
| B. workflow doc 직접 호출 deprecated + 다음 minor 에서 동작 차단 | v0.3 에서 deprecated warning, v0.4 에서 command 강제. 사용자 migration burden. |
| C. workflow doc 직접 호출 즉시 차단 | v0.3 에서 workflow doc 본문을 command 의 reference 로만 사용, 직접 호출 패턴 제거. clean cut, but 사용자 직접 호출 기존 패턴 모두 깨짐. |

**Default reasonable call**: **옵션 A** — backward-compatible.

### Q4: install-harness command 의 인터랙티브 vs 비대화 (사용자 결정 필요)

| 옵션 | 의미 |
|---|---|
| **A. 인터랙티브 (권장)** | command 가 사용자 요청 받고 routing → design skill 호출 → spec 사용자 검토 gate → 사용자 승인 후 creator dispatch → cycle 진입 + 단계별 진행 보고 + 사용자 redirect 가능 |
| B. 비대화 1-shot | command 가 인자만 받고 끝까지 자동 (gate 도 skip). dry-run 만 가능. |
| C. mixed (default 인터랙티브, `--auto` 플래그 시 1-shot) | 사용자 선택권 |

**Default reasonable call**: **옵션 A** — 인터랙티브 + spec gate 강제 (CONSTITUTION §3.3). 옵션 C 는 v0.4 검토.

### Q5: dry-run fixture 의 형식 (사용자 결정 필요)

| 옵션 | 의미 |
|---|---|
| **A. spec fixture markdown + 기대 출력 markdown (권장)** | `tests/fixtures/spec-{a,b,c}.md` (입력) + `tests/fixtures/spec-{a,b,c}.expected.md` (기대 파싱 출력). 사용자가 직접 비교 가능. |
| B. YAML test cases | `tests/fixtures/parse-cases.yaml` — input/expected 페어. 자동화에 유리. |
| C. fixture 없음 (schema spec 만) | 비용 절감, but 회귀 검증 불가 |

**Default reasonable call**: **옵션 A** — markdown fixture (사용자 가독성 우선).

---

## 2. Architecture Change Summary

### Before (v0.2.0)

```
[사용자 요청]
  ↓
[메인 세션이 workflow doc §2 Routing 표 직접 참조]
  ↓
[메인 세션이 design skill 직접 호출]
  ↓
[메인 세션이 spec 사용자 검토 gate 실행]
  ↓
[메인 세션이 creator skill 직접 dispatch]
  ↓
[메인 세션이 runner cycle 실행 + round counter + 종료 조건 enforce]
  ↓
[메인 세션이 사용자 보고]
```

문제: 모든 책임이 "메인 세션이 잘 따라준다" — 프롬프트 boundary. CONSTITUTION §3.13 충돌.

### After (v0.3.0)

```
[사용자: /install-harness 또는 자연어 요청]
  ↓
[/install-harness command body 가 명시 entrypoint]
  ↓ (command 절차 §1 Routing)
[command 가 design skill 호출 (Phase 1)]
  ↓ (command 절차 §2 Gate)
[spec gate — command 가 사용자에게 spec 제시 + 승인 대기]
  ↓ (command 절차 §3 Dispatch)
[command 가 spec.Execution Plan 항목별 creator dispatch (Phase 2)]
  ↓ (command 절차 §4 Cycle)
[command 가 runner 호출 + round counter 유지 + 종료 조건 4종 enforce]
  ↓ (command 절차 §5 Report)
[command 가 사용자에게 cycle 결과 + 다음 단계 보고]
```

이점:
- 명시적 entrypoint (`/install-harness`) — 사용자/메인 세션 모두 동일 진입점
- command body 가 절차 명세 (메인 세션 책임 명시) — workflow doc 은 reference 로 격하
- backward-compatible (사용자가 workflow doc 보고 직접 진입해도 v0.2 패턴 유지)

### What stays the same

- 3 design skill (resource-design / context-map-architecture / evaluation-loop-design) 본문 변경 없음 (단, spec 산출 형식만 YAML schema 정렬 — Task 2)
- 3 creator + creator-gap-eval + runner 본문 큰 변경 없음 (args 파싱 정렬만 — Task 2)
- workflow doc §1-§8 본문 유지 (단, §1 상단에 command 권장 명시 + §6 cycle 정밀화 — Task 4)

---

## 3. File Structure

| 파일 | 변경 종류 | Task | 책임 |
|---|---|---|---|
| `plugins/bobs-plugin/commands/install-harness.md` | Create | T1 | Claude Code slash command — orchestration 전체 wrap (routing + design + gate + dispatch + cycle + report) (~400-600 lines, references 분리 가능) |
| `plugins/bobs-plugin/commands/install-harness/references/routing.md` | Create (선택) | T1 | §1 Routing 절차 분리 (~80-120 lines) |
| `plugins/bobs-plugin/commands/install-harness/references/dispatch.md` | Create (선택) | T1 | §3 Dispatch 절차 + Execution Plan YAML 파싱 분리 (~120-180 lines) |
| `plugins/bobs-plugin/commands/install-harness/references/cycle.md` | Create (선택) | T1 + T4 | §4 Cycle 절차 + round counter + 종료 조건 4종 enforce + same-fingerprint 비교 (~100-150 lines) |
| `plugins/bobs-plugin/docs/specs/2026-05-XX-harness-orchestration-v2.md` | Create (옵션 B 채택 시) | T1 | v2 spec — architecture refinement rationale + Q1-Q5 결정 + Section 1-12 (옵션 A 채택 시 v1 spec §11 또는 §12 에 통합) |
| `plugins/bobs-plugin/references/harness-installation-workflow.md` | Edit (§1 상단 + §6) | T1 + T4 | §1 권장 entrypoint 명시 + §6 종료 조건 same-fingerprint 정밀화 |
| `plugins/bobs-plugin/references/execution-plan-schema.md` | Create | T2 | YAML schema 정의 (target/args/rationale/execution_mode 필드) + 변형 케이스 (mode: no-op / needs_input / blocked) (~150-200 lines) |
| `plugins/bobs-plugin/references/execution-plan-schema/fixtures/` | Create | T2 | dry-run fixture 디렉토리 |
| `plugins/bobs-plugin/references/execution-plan-schema/fixtures/spec-a-dispatch.md` | Create | T2 | 정상 dispatch case (입력) |
| `plugins/bobs-plugin/references/execution-plan-schema/fixtures/spec-a-dispatch.expected.yaml` | Create | T2 | 정상 dispatch case (기대 파싱) |
| `plugins/bobs-plugin/references/execution-plan-schema/fixtures/spec-b-self-apply.md` | Create | T2 | self_apply case (context-map-architecture / evaluation-loop-design) |
| `plugins/bobs-plugin/references/execution-plan-schema/fixtures/spec-b-self-apply.expected.yaml` | Create | T2 | 동일 |
| `plugins/bobs-plugin/references/execution-plan-schema/fixtures/spec-c-no-op.md` | Create | T2 | no-op case |
| `plugins/bobs-plugin/references/execution-plan-schema/fixtures/spec-c-no-op.expected.yaml` | Create | T2 | 동일 |
| `plugins/bobs-plugin/skills/resource-design/references/design-output-contract.md` | Edit | T2 + T3 | Section 1 표준 spec 형식 → YAML schema 인용 + `execution_mode` 필드 추가 |
| `plugins/bobs-plugin/skills/context-map-architecture/SKILL.md` | Edit | T3 | spec 산출에 `execution_mode: self_apply` 명시 (현재는 Applied Changes 섹션으로 self-apply 패턴 — 명시 필드로 승격) |
| `plugins/bobs-plugin/skills/evaluation-loop-design/SKILL.md` | Edit | T3 | 동일 — `execution_mode: self_apply` 명시 |
| `plugins/bobs-plugin/skills/resource-design/SKILL.md` | Edit | T3 | spec 산출에 `execution_mode: dispatch` 명시 (3 creator dispatch 패턴) |
| `plugins/bobs-plugin/skills/evaluation-loop-runner/references/runtime-protocol.md` | Edit | T4 | §2 종료 조건 표 — "같은 design skill 2회" → "같은 target + 같은 gap fingerprint 2회" 정밀화 + fingerprint 정의 (예: `case_id + result + summary hash`) |
| `plugins/bobs-plugin/skills/evaluation-loop-runner/SKILL.md` | Edit (1 곳) | T4 | Capability Procedure §3 Phase 3 종료 조건 인용 정밀화 |
| `plugins/bobs-plugin/.claude-plugin/plugin.json` | Edit (version + description) | T1-T4 | 0.2.0 → 0.3.0 + description 끝 `+ /install-harness command` |
| `.claude-plugin/marketplace.json` | Edit (version + description) | T1-T4 | 동일 |
| `README.md` | Edit (intro + file tree + command 표 추가) | T1 | install-harness 추가 + commands/ 디렉토리 노출 |
| `plugins/bobs-plugin/docs/specs/2026-05-17-harness-installation-design.md` | Edit (§7 끝 + §11 link) | T1 (옵션 B 채택 시) | "v2 spec link" 표기 + Implemented 상태 유지 (frozen) |

**유지** (변경 없음):
- `plugins/bobs-plugin/references/{harness-principles,CONSTITUTION,SKILL-GUIDE,AGENT-GUIDE,HOOK-GUIDE,COMMAND-GUIDE,RUNTIME-GUIDE,GAP-FORMAT}.md` — normative source (CONSTITUTION §3.13 인용으로 충분)
- `plugins/bobs-plugin/skills/{skill,agent,hook}-creator/SKILL.md` — args 파싱은 이미 v0.2 에서 정렬됨, T2 의 YAML schema 가 호환 (key=value 형식 그대로)
- `plugins/bobs-plugin/skills/creator-gap-eval/SKILL.md` — 변경 없음
- `plugins/bobs-plugin/agents/agent-skill-auditor.md` — 변경 없음 (command 도 정적 감사 대상이지만 별도 plan)

**deprecation 없음**: install-harness command 는 신규, 기존 자산 흡수 대상 없음.

---

## 4. Task 1: `/install-harness` command 신규 (orchestration 전체 wrap)

**Goal**: Claude Code slash command `/install-harness` 신규 — 사용자 요청 받아 routing + design + gate + dispatch + cycle + report 까지 한 entrypoint 로 통합.

**Sub-tasks**:

- [ ] **1a. commands/ 디렉토리 생성**
  - `mkdir -p plugins/bobs-plugin/commands/install-harness/references`
  - verify: `ls plugins/bobs-plugin/commands/install-harness/`

- [ ] **1b. install-harness.md command body 작성**
  - frontmatter: `name: install-harness`, `description: 하네스 이식 entrypoint — routing + design + gate + dispatch + cycle + report`, `user-invocable: true`
  - body 절차 §1-§5:
    - §1 Routing — workflow doc §2 의 routing 표 *행 선택* (재생산 X, 인용만)
    - §2 Design phase — 선택된 design skill 호출 + spec 산출 받기
    - §3 Gate — spec 사용자 검토 + 승인 신호 ("진행"/"go"/"approve") 대기. 명시 거부 시 design skill 재호출 또는 종료
    - §4 Dispatch — spec.Execution Plan 항목별 처리. `execution_mode: dispatch` 면 creator 호출, `self_apply` 면 design skill 산출 본문 적용, `plan_only` 면 사용자에게 plan 만 제시
    - §5 Cycle — `evaluation-loop-runner` 호출 + round counter 유지 + 종료 조건 4종 enforce (`runtime-protocol.md` §2 인용, same-fingerprint 비교는 본 command 책임)
    - §6 Report — 최종 결과 한 줄 요약 + cycle 산출물 path + 잔여 follow-up 안내
  - verify: command body ≤ 600 lines (≥ 600 lines 면 references 분리)

- [ ] **1c. references 분리 (≥ 600 lines 시)**
  - `references/routing.md` (§1 절차 + routing 표 인용)
  - `references/dispatch.md` (§4 Dispatch 절차 + Execution Plan YAML 파싱 — Task 2 schema 인용)
  - `references/cycle.md` (§5 Cycle 절차 + round counter + same-fingerprint — Task 4 의 fingerprint 정의 인용)
  - verify: 각 reference ≤ 200 lines

- [ ] **1d. workflow doc §1 권장 entrypoint 명시**
  - 현재 §1 Overview 끝에 한 문단 추가: "v0.3 권장 entrypoint: `/install-harness` command 호출. 메인 세션이 본 workflow doc 보고 직접 호출하는 v0.2 패턴도 backward-compatible 로 동작 (deprecated 표기 없이 유지)."
  - verify: workflow doc §1 본문 read

- [ ] **1e. README.md 갱신**
  - intro: install-harness 한 줄 추가
  - file tree: commands/ 디렉토리 노출
  - command 표 (신규 섹션): install-harness | 한 줄 책임 | user-invocable
  - verify: README diff 확인

- [ ] **1f. plugin.json + marketplace.json description 갱신**
  - description 끝 `+ /install-harness command (orchestration entrypoint)` 추가

- [ ] **1g. GAP 분석** (skill 아닌 command 라 creator-gap-eval 비적용 — 대신 manual review)
  - CONSTITUTION §3.1-§3.10 10 원칙 체크리스트 적용
  - command body 의 effects gate (사용자 spec 승인) 강제 확인
  - 의도된 deviation (이중 gate 약화 권한) 명시 — Acceptable Deviations 섹션
  - verify: `docs/agent/logs/` 또는 별도 GAP report 작성 — Final Decision PASS / PASS_WITH_NOTES

**Verification**:
- `/install-harness` 호출 시 routing 표 따라 design skill 진입 확인
- spec gate 에서 사용자 거부 시 chain 중단 확인
- spec.Execution Plan dispatch 가 v0.2 와 동일 동작 (regression 없음)
- cycle 종료 조건 4종 각각 trigger 시 chain 중단 확인 (Task 4 의 fingerprint 정밀화 포함)

---

## 5. Task 2: Execution Plan YAML schema 고정 + dry-run fixture

**Goal**: workflow doc §4 의 markdown-like Execution Plan 형식을 YAML fenced block schema 로 정밀화 + dry-run fixture 로 회귀 검증 가능하게.

**Current pain point** (외부 review 인용):
- 현재 design-output-contract.md 의 Execution Plan 형식: `target=<x> | args=<key=value, ...> | rationale=<한 줄>` markdown-like — 파싱 모호 (특히 args 의 value 가 `,` 포함 시)
- design skill 별 산출 형식 일관성 검증 부재 — context-map-architecture 의 self-apply 패턴이 spec 형식과 불일치

**Sub-tasks**:

- [ ] **2a. execution-plan-schema.md 작성**
  - 경로: `plugins/bobs-plugin/references/execution-plan-schema.md`
  - 구조:
    - §1 Goal + scope
    - §2 YAML schema 정의 (fenced block `yaml`):
      ```yaml
      execution_plan:
        - target: <creator-name | self-apply>
          args:
            <key>: <value>
          rationale: <한 줄>
          execution_mode: dispatch | self_apply | plan_only   # Task 3
      ```
    - §3 변형 케이스 — `mode: no-op` / `mode: needs_input` (category + items) / `mode: blocked` (reason + needs_input)
    - §4 파싱 규칙 — YAML 파싱 표준 (PyYAML / `yq` 호환), `args` 키 누락 시 creator §0 가 부분 입력으로 시작
    - §5 backward compatibility — v0.2 markdown-like 형식도 호환 파싱 (Task 1 의 command §3 Dispatch 가 둘 다 지원)
    - §6 fixture 인용 path
  - verify: schema ≤ 200 lines

- [ ] **2b. fixture 디렉토리 + 정상 케이스 3종 작성**
  - `mkdir -p plugins/bobs-plugin/references/execution-plan-schema/fixtures/`
  - `spec-a-dispatch.md` (입력) — resource-design 의 3 creator dispatch
  - `spec-a-dispatch.expected.yaml` (기대 파싱 결과) — yaml 구조화
  - `spec-b-self-apply.md` — context-map-architecture self-apply (AGENTS.md 작성)
  - `spec-b-self-apply.expected.yaml` — `execution_mode: self_apply` 명시
  - `spec-c-no-op.md` — design skill 의 mode: no-op
  - `spec-c-no-op.expected.yaml` — 동일
  - verify: 각 fixture pair (입력 + 기대) 가 schema 따름

- [ ] **2c. design-output-contract.md 갱신**
  - Section 1 표준 spec 형식: YAML schema 인용 (재생산 X) + 기존 markdown 표 (1.2 표준 4 섹션) 유지 + Execution Plan 섹션만 YAML schema link 로 교체
  - verify: design-output-contract.md ≤ 200 lines

- [ ] **2d. workflow doc §4 갱신**
  - `spec_version: v2` (v1 markdown-like → v2 YAML schema, breaking)
  - §4 본문에 schema link 인용 (재생산 X)
  - v1 호환 표기 (Task 2 sub 5a + command §3 Dispatch backward-compat)
  - verify: workflow doc §4 read

- [ ] **2e. dry-run verification 절차**
  - 각 fixture 입력 → YAML 파싱 → expected.yaml 비교 (shell or python script)
  - 절차는 `references/execution-plan-schema.md` §6 Verification 섹션에 명시
  - verify: 3 fixture 모두 expected 일치

**Verification**:
- `yq` 또는 PyYAML 으로 모든 fixture 파싱 성공
- design skill 산출이 schema 따름 (Task 3 의 execution_mode 필드 포함)
- v0.2 markdown-like 형식도 backward-compat 파싱 가능 (graceful fallback)

---

## 6. Task 3: `execution_mode` 필드 도입 (`dispatch | self_apply | plan_only`)

**Goal**: design skill 의 spec 산출 형식에 `execution_mode` 필드를 명시 — 현재 암묵적인 self-apply 패턴 (context-map-architecture / evaluation-loop-design) 을 명시 필드로 승격.

**Current pain point** (외부 review 인용):
- "Execution Plan을 모든 design skill의 표준처럼 말하면서, context-map-architecture와 evaluation-loop-design은 Applied Changes 자체 작성 패턴" — spec 의 §4 와 design skill 본문 사이 mismatch

**3 mode 의 의미**:
- `dispatch` — spec.Execution Plan 항목별 creator skill 호출. resource-design 패턴.
- `self_apply` — design skill 본문이 직접 파일 write (creator 없이). context-map-architecture (AGENTS.md / docs tree write) / evaluation-loop-design (docs/agent/*.md write) 패턴.
- `plan_only` — spec 만 산출, dispatch/apply 는 사용자 결정. design skill 이 "이 변경이 적합한지 사용자가 결정" 으로 미루는 경우.

**Sub-tasks**:

- [ ] **3a. execution-plan-schema.md 에 `execution_mode` 필드 정의** (Task 2 와 같이)
  - field type: enum {`dispatch`, `self_apply`, `plan_only`}
  - default: `dispatch` (생략 시)
  - mode 별 install-harness command §4 Dispatch 의 분기 절차 명시
  - verify: schema 본문 read

- [ ] **3b. resource-design SKILL.md 갱신**
  - spec 산출 예시에 `execution_mode: dispatch` 명시 (default 라 생략 가능, but 명시 권장)
  - verify: SKILL.md diff

- [ ] **3c. context-map-architecture SKILL.md 갱신**
  - spec 산출 본문에 `execution_mode: self_apply` 명시
  - Output Contract 섹션 갱신 — Applied Changes 와 execution_mode 의 관계 명시
  - verify: SKILL.md diff

- [ ] **3d. evaluation-loop-design SKILL.md 갱신**
  - 동일 — `execution_mode: self_apply` 명시
  - verify: SKILL.md diff

- [ ] **3e. install-harness command §4 Dispatch 분기 절차 작성** (Task 1c 의 dispatch.md 와 같이)
  - dispatch mode → creator 호출
  - self_apply mode → design skill 산출 본문 적용 (사용자 승인 후)
  - plan_only mode → 사용자 redirect (보고만)
  - verify: command body §4 절차 read

**Verification**:
- 3 design skill 산출 spec 의 `execution_mode` 필드 명시 확인
- install-harness command §4 Dispatch 의 각 mode 분기 동작 확인 (manual test 3종)

---

## 7. Task 4: cycle 종료 조건 정밀화 (same target + same gap fingerprint)

**Goal**: workflow doc §6 + runner runtime-protocol.md §2 의 종료 조건 "같은 design skill 2회 연속" 을 "같은 target + 같은 gap fingerprint 2회 연속" 으로 정밀화 — 정상 재진입의 false positive 회피.

**Current pain point** (외부 review 인용):
- "같은 design skill 2회 연속이면 중단" — 같은 skill 재진입이 정상인 경우 있음 (예: evaluation-loop-design 으로 두 번 진입해서 첫 round 는 golden-set 추가, 두 번째 round 는 task-log-template 정밀화 — 서로 다른 gap 인데 stop)
- fingerprint 비교가 더 정확

**fingerprint 정의**:
- `routing_decision` (target design skill 이름)
- `gap_analysis.case_id`
- `gap_analysis.result` (PASS / FAIL / no-op / blocked / needs_input)
- `gap_analysis.summary` (정규화된 hash — 공백/대소문자 무시)

→ 4 필드 모두 동일하면 same fingerprint 로 판정. 셋 중 하나라도 다르면 다른 cycle (정상 재진입).

**Sub-tasks**:

- [ ] **4a. evaluation-loop-runner/references/runtime-protocol.md §2 정밀화**
  - 종료 조건 표 행 3 ("같은 design skill 2회 연속") → "같은 target + 같은 gap fingerprint 2회 연속"
  - fingerprint 정의 sub-section 추가 (4 필드 + 정규화 규칙)
  - 예시 2종 — false positive 회피 케이스 (같은 target 다른 fingerprint = 진행) + true positive 케이스 (같은 fingerprint = stop)
  - verify: runtime-protocol.md diff

- [ ] **4b. workflow doc §6 종료 조건 갱신**
  - 4 종료 조건 표 행 3 → "같은 target + 같은 gap fingerprint 2회 연속"
  - fingerprint 정의는 runtime-protocol.md §2 인용 (재생산 X)
  - verify: workflow doc §6 read

- [ ] **4c. install-harness command §5 Cycle 의 fingerprint 비교 절차 작성** (Task 1c 의 cycle.md 와 같이)
  - command 가 round 별 fingerprint 유지 (직전 1개)
  - 신규 round fingerprint == 직전 fingerprint → stop
  - else → continue
  - verify: command body §5 절차 read

- [ ] **4d. evaluation-loop-runner SKILL.md Capability Procedure §3 Phase 3 정밀화**
  - 종료 조건 인용 갱신 (runtime-protocol.md §2 의 새 표 행 인용)
  - runner 본문에서 fingerprint 정의 재생산 안 함 (인용만)
  - verify: SKILL.md §3 read

**Verification**:
- runner 가 같은 target 다른 fingerprint 로 재호출 받으면 cycle continue (regression 없음)
- runner 가 같은 target 같은 fingerprint 로 재호출 받으면 cycle stop + NEEDS_REVIEW 보고

---

## 8. Migration / Backward Compatibility

### v0.2 → v0.3 transition table

| 자원 | v0.2 동작 | v0.3 동작 | backward-compat |
|---|---|---|---|
| workflow doc 직접 호출 | 메인 세션이 routing 표 + design skill 직접 호출 | 동작 유지 (deprecated 표기 없음) | ✅ |
| `/install-harness` command | 미존재 | 신규 권장 entrypoint | n/a |
| design skill 산출 spec 형식 | markdown-like (`target=X | args=...`) | YAML fenced block (`execution_mode` 필드 포함) | ⚠️ install-harness command 는 둘 다 파싱 (Task 2 sub 5a) — 사용자 직접 호출 시 v0.2 형식 그대로 사용 가능 |
| spec_version 필드 | `v1` | `v2` (YAML schema) | ⚠️ design skill 이 산출 시 v2 default, v1 도 호환 파싱 |
| runner 종료 조건 | "같은 design skill 2회" | "같은 target + 같은 gap fingerprint 2회" | ⚠️ runner 본문 변경 — main session 호출 패턴 동일, 종료 조건 판정만 정밀화 (false positive 줄어듦 — 더 관대) |
| creator 3종 args 인터페이스 | name/scope/event/matcher/subagent_type | 동일 | ✅ |

### 사용자 영향

- v0.2 사용자가 v0.3 업데이트 후: 기존 패턴 유지하면서 `/install-harness` 신규 entrypoint 사용 가능. 강제 migration 없음.
- design skill 산출 시 v2 YAML 형식 default — v0.2 markdown-like 형식 사용하던 사용자가 직접 spec 작성 시 v1 형식도 호환되지만 v2 권장.

### Deprecation roadmap (v0.4 검토)

- v0.4: workflow doc 직접 호출 패턴 deprecated warning (메인 세션이 routing 표 직접 참조 시 install-harness command 추천 메시지)
- v0.5: workflow doc 본문을 command body 에 통합, workflow doc 은 command 의 reference 로 격하
- v1.0: stable interface — `/install-harness` 가 sole entrypoint

---

## 9. Verification Matrix

| 검증 항목 | Task | 방법 | 기대 결과 |
|---|---|---|---|
| install-harness command frontmatter | T1 | Read command.md head | name/description/user-invocable 모두 존재 |
| install-harness routing 절차 | T1 + T4 | manual test (사용자 요청 → design skill 진입) | workflow doc §2 의 routing 표 행 일치 |
| spec gate 강제 | T1 | manual test (사용자 거부 → chain 중단) | spec.Execution Plan dispatch 미실행 |
| execution_mode 분기 | T3 | manual test 3종 (dispatch / self_apply / plan_only) | 각 mode 별 절차 분기 동작 |
| YAML schema 파싱 | T2 | `yq` 또는 PyYAML 으로 3 fixture 파싱 | 3 fixture 모두 expected.yaml 일치 |
| backward-compat v1 형식 | T2 + T1 | manual test (v1 markdown-like spec 입력) | install-harness command 가 v1 도 파싱 + dispatch |
| cycle 정상 재진입 (다른 fingerprint) | T4 | manual test (같은 target 다른 case_id) | cycle continue |
| cycle stop (같은 fingerprint) | T4 | manual test (같은 target 같은 fingerprint 2회) | cycle stop + NEEDS_REVIEW |
| README + plugin.json 갱신 | T1 | git diff | 변경 일관성 (install-harness 인용 + version 0.3.0) |
| 외부 review 5 리스크 모두 응답 | T1-T4 | review-response 표 (§0) 갱신 | 5/5 응답 완료 |

---

## 10. Open Questions

- [ ] **Q1 (spec trajectory)** — v1 spec 에 Step 8 추가 vs v2 spec 신규. 기본값: 옵션 B (v2 신규).
- [ ] **Q2 (version bump)** — 0.3.0 minor breaking vs 0.2.1 patch (Task 4 만) vs 1.0.0 major. 기본값: 0.3.0.
- [ ] **Q3 (backward compatibility)** — v0.2 workflow doc 직접 호출 deprecated 표기 없음 (옵션 A) vs deprecated warning (옵션 B) vs 즉시 차단 (옵션 C). 기본값: 옵션 A.
- [ ] **Q4 (install-harness 인터랙티브)** — A 인터랙티브 vs B 1-shot vs C mixed. 기본값: 옵션 A.
- [ ] **Q5 (dry-run fixture 형식)** — A markdown vs B YAML vs C 없음. 기본값: 옵션 A.
- [ ] **Q6 (Task 순서)** — Task 1 → 2 → 3 → 4 순차 vs Task 4 (작고 backward-compat) 먼저 → Task 1-3 통합. 기본값: T4 먼저 (low-risk, separate commit), T1-3 통합 sprint.
- [ ] **Q7 (commands/ 디렉토리 정책)** — bobs-plugin 의 첫 command — 향후 다른 command (`/evaluation-loop-runner` 명시 호출 등) 추가 정책 명시 필요. 기본값: 본 plan 범위 밖, v0.3 후 별도 검토.
- [ ] **Q8 (workflow doc 운명)** — v0.3 에서 workflow doc 본문 유지 (command 의 reference) vs command body 에 흡수 (workflow doc 격하). 기본값: 유지 (deprecation roadmap §8 참조).

---

## 11. Rollout sequencing

### 권장 순서 (Q6 default)

- **Round 1**: Task 4 (cycle 정밀화) — backward-compat, low-risk, single commit. 검증 빠름.
- **Round 2**: Task 2 (YAML schema + fixture) — backward-compat 파싱 유지하면서 schema 도입. 별도 commit.
- **Round 3**: Task 3 (execution_mode 필드) — design skill 3종 spec 산출 변경, Task 2 schema 와 같이. 별도 commit.
- **Round 4**: Task 1 (install-harness command) — 가장 큰 변경, Task 2/3 의 schema/필드 인용. 별도 commit.
- **Round 5**: v2 spec 작성 (Q1 옵션 B) + version bump (0.3.0) + README/plugin.json 갱신. final commit.

각 Round 별 verify → commit → 다음 Round. Round 1-4 가 PASS 면 Round 5 통합.

### alternative — single big-bang sprint

전체 4 Task 한 sprint 로 묶고 마지막에 단일 commit. 비추천 (rollback 어려움).

---

## 12. Risks

### 12.1 v2 spec architecture 가 v1 design intent 와 충돌

v1 §1 "skill 호출 체인" 의도가 v2 command boundary 도입으로 architectural 변화. v2 spec 본문에 *왜 v1 intent 를 갱신하는지* 명시 필수 (외부 review R1 인용).

**완화**: v2 spec §0 Context 에 외부 review R1 인용 + CONSTITUTION §3.13 근거.

### 12.2 install-harness command body 비대

orchestration 전체 wrap 이라 command body 가 길어질 위험 (≥ 600 lines). references 분리 정책 (Task 1c) 으로 완화.

**완화**: routing.md / dispatch.md / cycle.md 3 reference 로 분리 + command body 는 상위 흐름 + reference link 만.

### 12.3 YAML schema 파싱 의존성

v0.3 의 spec 파싱이 YAML 표준 의존 — `yq` 또는 PyYAML 미설치 환경에서 install-harness command 가 직접 파싱 어려움.

**완화**: install-harness command body 가 YAML 파싱 절차를 *Claude 가 직접* 처리 (외부 도구 의존 X). YAML 은 Claude 가 native 처리 가능.

### 12.4 self_apply mode 의 effect gate 누락

execution_mode: self_apply 면 creator 없이 design skill 본문이 직접 파일 write. install-harness command §4 Dispatch 가 self_apply 시에도 사용자 승인 gate 강제 필수 (CONSTITUTION §3.3).

**완화**: install-harness command §4 절차에 mode 별 gate 명시 — self_apply 도 사용자 승인 후 진행.

### 12.5 backward-compat v1 형식 파싱 부담

Task 2 의 backward-compat 가 v1 markdown-like + v2 YAML 둘 다 지원 — install-harness command 의 파싱 복잡도 증가.

**완화**: v1 형식은 graceful fallback (v2 파싱 실패 시 v1 시도). v0.4 에서 v1 deprecated, v0.5 에서 제거.

---

## 13. Success Criteria

- [ ] `/install-harness` command 호출 시 v0.2 직접 호출 패턴과 동일한 cycle 결과 (regression 없음)
- [ ] design skill 산출 spec 의 `execution_mode` 필드 명시 (3 design skill 모두)
- [ ] YAML schema dry-run fixture 3종 모두 PASS
- [ ] cycle 정상 재진입 (다른 fingerprint) false positive 회피 확인
- [ ] 외부 review 5 리스크 모두 응답 완료 (P0+P1 v0.2.0 commit + P2 v0.3.0 commit)
- [ ] backward-compat — v0.2 workflow doc 직접 호출 패턴 동작 유지
- [ ] version bump 0.2.0 → 0.3.0 + plugin.json/marketplace.json/README 일관성

---

## 14. Approval status

- 외부 review (push 직후 fresh) — ✅ 5 리스크 모두 인용 라인 검증 완료
- 사용자 결정 (push 직후 응답) — ✅ install-harness scope: orchestration 전체 wrap
- 본 plan (v0.3 sprint) — 사용자 검토 대기
- Q1-Q8 결정 — 사용자 redirect 대기 (default reasonable call 명시)
