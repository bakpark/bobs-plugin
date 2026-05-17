---
name: evaluation-loop-design
description: |-
  Use when designing or refreshing the project's evaluation infrastructure — `docs/agent/roles.md` body / `docs/agent/evaluation-loop.md` / `docs/agent/golden-set.md` / `docs/agent/task-log-template.md`. Triggers on "검증 인프라 셋업", "task log 템플릿 만들어줘", "golden-set 정의", "evaluation loop 설계", "평가 사이클 셋업", "역할 정의 (docs/agent/roles.md)", "harness verification skeleton". Do NOT use for static rule audit (P0/P1/P2 + rule ID + confidence) — `agent-skill-auditor`. Do NOT use for resource type decision (skill/agent/hook/command) — `resource-design`. Do NOT use for docs-tree index / routing (`AGENTS.md` / `docs/agent/context-map.md`) — `context-map-architecture`. Do NOT use for individual skill/agent/hook authoring — `skill-creator` / `agent-creator` / `hook-creator`. Do NOT use for runtime task log capture + routing — `evaluation-loop-runner` (planned, separate runtime skill).
user-invocable: true
---

# Evaluation Loop Design

프로젝트의 *검증 인프라* 를 설계 + 작성하는 절차 메타 스킬. 본 스킬은 *어떤 검증 자산이 어디에 있어야 하는지* 를 진단하고, 작성·갱신해야 할 항목을 Verification Plan 으로 묶어 사용자 승인 후 실제 파일 write 까지 처리한다.

본 스킬은 *design-meta skill* 카테고리 (`harness-installation-workflow.md §3.3`). `user-invocable: true` 는 (a) 사용자가 `/evaluation-loop-design` 으로 명시 호출, (b) `evaluation-loop-runner` 가 자동 chain 으로 진입 (Routing Decision 의 *평가 인프라 갱신* 행), (c) 모델 자동 활성화 (description trigger phrase) 3종 모두 허용한다. plan-only 모드 + Phase 2 사용자 승인 effect gate 가 command 책임 (workflow gate / 인자 수집) 을 흡수하지 않게 막는다 — *meta design* 책임이지 user workflow command 가 아니다.

`harness-principles` 자산 모델 §4.1 (Docs 책임 — `docs/agent/`) + §4.5 (Context Map 라우팅) + §4.7 (자산 선택 기준) 의 *검증 자산* 만 다룬다. docs-tree 의 다른 카테고리 (`AGENTS.md` / `CLAUDE.md` / `docs/architecture.md` 등) 는 본 스킬 범위 밖 — `context-map-architecture` 가 처리.

## When to Use

**Trigger**:

- 사용자가 검증 인프라 (`docs/agent/evaluation-loop.md` / `docs/agent/golden-set.md` / `docs/agent/task-log-template.md`) 작성·정리·갱신을 요청한다.
- 사용자가 `docs/agent/roles.md` *body* 작성을 요청한다 (`context-map-architecture` 는 *skeleton seed* 까지만 — body 는 본 스킬).
- "얼마나 잘 동작하는지 측정 인프라가 필요" / "회귀를 잡을 골든셋이 필요" / "사이클 종료 조건이 모호" 같은 평가 자산 요구.
- Routing 표 §2 행: "검증 인프라", "task log", "golden-set".

**When NOT to use**:

- 정적 rule 감사 (P0/P1/P2 + rule ID + confidence) → `agent-skill-auditor` (본 스킬의 reference subagent — Routing Decision 표에서 호출).
- 자원 타입 결정 (skill / agent / hook / command / runtime settings 중 무엇?) → `resource-design`.
- docs-tree 인덱스 / 라우팅 (`AGENTS.md` / `CLAUDE.md` / `docs/agent/context-map.md` / `docs/architecture.md` skeleton 등) → `context-map-architecture`. 본 스킬과 ownership 분리: context-map-architecture = `docs/agent/roles.md` **skeleton seed**, evaluation-loop-design = **body**.
- 개별 skill / agent / hook 파일 작성 → `skill-creator` / `agent-creator` / `hook-creator`.
- runtime task log 캡처 + gap 분석 + 라우팅 (실행 시간 동작) → `evaluation-loop-runner` (planned as of 2026-05-17, target Step 5 of `harness-installation-workflow.md`). 본 스킬은 *design time* 만.
- 외부 모델 의견 / PR 리뷰 → `codex-reviewer` / `pr-review-toolkit`.

**Auditor 와의 대상 자산 차이** (overlap 명시):

| 비교 | 본 스킬 (`evaluation-loop-design`) | `agent-skill-auditor` |
|---|---|---|
| 대상 자산 | `docs/agent/roles.md` body / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md` | `SKILL.md` / `agent.md` / `settings.json` |
| 동작 | 작성·갱신 (mutation) | 정적 감사 (read-only) |
| 출력 | Verification Plan + Applied Changes spec | P0/P1/P2 findings + rule evidence |

auditor 는 본 스킬이 작성한 `docs/agent/*.md` 를 감사 대상으로 받지 않는다 — docs audit 은 본 스킬의 self-verify 가 담당.

## Capability Procedure

본 스킬은 3 phase 로 동작한다. Phase 1 진단 → Phase 2 사용자 승인 (effect gate 1단계) → Phase 3 직접 파일 write (effect gate 2단계).

### Phase 1: Inventory & Inspect

작성 *전* 에 현재 `docs/agent/` 검증 자산 + 자원 inventory + 작업 유형을 점검해 중복·누락·toy case 를 막는다.

읽는다 (있는 것만):

- `<repo>/docs/agent/` 전체 — `roles.md`, `evaluation-loop.md`, `golden-set.md`, `task-log-template.md`, `logs/` 디렉토리
- `<repo>/docs/agent/roles.md` skeleton (있다면 `context-map-architecture` 가 seed 한 상태 — 본 스킬은 body 만 채움)
- 자원 inventory — skill / agent / hook / command / runtime settings (role 매핑 source)
- 기존 task log (있다면) — schema 일관성 진단
- 사용자 발화의 작업 유형 — golden-set case 후보 추출

수집 항목:

| 카테고리 | 출처 | 사용 |
|---|---|---|
| 존재하는 검증 자산 | `find docs/agent -maxdepth 2 -name "*.md"` | Inventory 섹션의 *what exists* |
| 누락된 검증 자산 | `roles.md body` / `evaluation-loop.md` / `golden-set.md` / `task-log-template.md` 중 빠진 것 | Gaps 섹션의 *missing* |
| 자원 inventory | skill / agent / hook / command 이름 (frontmatter / settings.json) | roles.md body 의 role 페어 매핑 source |
| 작업 유형 후보 | 이미 발생한 task log + harness-principles §4.7 사례 표 + 사용자 발화 | golden-set case 풀 |
| 기존 task log schema | `docs/agent/logs/*.md` 의 entry 형식 (있다면) | task-log-template.md 의 baseline |

각 reference 가 다루는 작성 절차:

- `references/roles-write.md` — `docs/agent/roles.md` body (role 페어 / 책임 한 줄 / 자원 매핑)
- `references/evaluation-loop-write.md` — `docs/agent/evaluation-loop.md` (진입 / 사이클 단계 / 종료 조건 / Routing Decision 표)
- `references/golden-set-write.md` — `docs/agent/golden-set.md` (case 선정 기준 / schema / no-op·blocked 표면)
- `references/task-log-template-write.md` — `docs/agent/task-log-template.md` (entry schema / 보존 정책 / golden-set 연결)

### Phase 2: Verification Plan

Phase 1 결과를 다음 4 섹션으로 정리해 사용자에게 제시한다 (Effect gate 1단계 — CONSTITUTION §3.3).

```markdown
# Harness Installation Spec — evaluation-loop

> Generated by: evaluation-loop-design
> Date: <iso8601>
> Trigger: <user request>
> spec_version: v1

## Inventory
- 존재하는 검증 자산 (파일별)
- 자원 inventory (skill / agent / hook / command — role 매핑 source)
- 작업 유형 후보 (task log + 사용자 발화)

## Gaps
- 누락된 검증 자산
- role body 미정 (skeleton 만 있음)
- golden-set case 가 toy 예제 (실제 발생 작업 부재)
- task log schema 일관성 부재

## Verification Plan
- 작성 / 수정 / 이동 항목 (파일별)
- 각 파일의 골격 (어떤 섹션 / 어떤 데이터)
- follow-up 으로 남길 항목 (예: task log 누적 후 golden-set case 갱신)

## Applied Changes
- (Phase 3 후 채워짐 — 실제 작성/수정한 파일 목록)
```

사용자가 Verification Plan 을 검토해 "진행" / "go" / "proceed" 신호를 줄 때 Phase 3 진입. "묻지 말고 진행" 이 사전 합의된 경우만 확인 없이 진행한다. Phase 2 만 실행하고 Phase 3 를 보류하는 *plan-only* 모드도 허용 (사용자가 명시 시).

### Phase 3: Apply

Verification Plan 에 적힌 각 파일을 *해당 reference 의 절차를 따라* write 한다. 각 reference 는 자체 effect gate (write 직전 경로·종류·요약 1회 확인) 를 가진다 — Phase 3 는 reference 호출 wrapper.

write 순서 (의존성 기반):

1. `docs/agent/task-log-template.md` (다른 자산이 이를 인용 — schema 가 먼저 확정되어야 함, `task-log-template-write.md` Phase 3)
2. `docs/agent/roles.md` body (자원 inventory 와 task log schema 가 확정된 후 — `roles-write.md` Phase 3). skeleton 이 없으면 *blocked* 로 `context-map-architecture` 호출 follow-up 으로 보고.
3. `docs/agent/golden-set.md` (roles + task log 가 확정된 후 — `golden-set-write.md` Phase 3)
4. `docs/agent/evaluation-loop.md` (위 세 자산 모두 인용 — `evaluation-loop-write.md` Phase 3)

각 write 후 즉시 verify (해당 reference 의 verify 절차) — schema 일관성 / 인용 자원 일치 / Routing Decision 종착 자원 존재 / case 의 PASS/no-op/blocked 표면 모두 정의.

## Output Contract

caller (사용자 또는 상위 워크플로우) 에게 반환:

```
spec: Harness Installation Spec — evaluation-loop (spec_version: v1)
mode: applied | plan-only | no-op | needs_input
inventory:
  existing_assets: <list of docs/agent/*.md>
  resources_indexed: skills=<n>, agents=<n>, hooks=<n>, commands=<n>
  task_log_entries: <count if any>
gaps:
  missing_assets: <list>
  role_body_missing: <bool>
  toy_golden_set: <bool>
  task_log_schema_drift: <bool>
verification_plan:
  create: <list of new files>
  modify: <list of edited files>
applied_changes:
  - <file>: <action — created / edited>
follow_ups:
  - <docs/agent/roles.md skeleton 부재>: context-map-architecture 먼저 호출 권고
  - <golden-set toy case>: 실제 task log 누적 후 case 갱신
  - <자원이름>: role 정의에 필요하나 inventory 에 없음 — resource-design 권고
```

**No-op case**: 기존 검증 인프라가 inventory 와 일치하고 누락 없음 → `mode: no-op` + 변경 없음.

**needs_input case**: `category: design | inventory` 로 사유 구분.

- `category: design` — golden-set case 선정 모호 (사용자 의도 캡처 질문). 예: "이 작업 유형에 대한 PASS 정의가 *결과 동일성* 인가 *시간 한도* 인가?"
- `category: inventory` — 자원 inventory 미완 / 기존 task log 접근 불가 / `docs/agent/roles.md` skeleton 부재 (환경 보완 요청). 예: "`context-map-architecture` 가 roles.md skeleton 을 seed 하지 않았다 — 먼저 호출 필요".

호출자는 항상 *사용자에게 묻는다* 라는 동일 후처리를 하되, `category` 로 질문 톤을 분기 (design = 의도 캡처, inventory = 환경 보완).

**Plan-only case**: 사용자가 Phase 2 까지만 요청 (Verification Plan 검토 후 보류) → `mode: plan-only` + spec 본문 반환. Phase 3 는 다음 호출에서.

세부 spec 본문은 응답에 풀어 쓰지 말고 spec_path 만 안내한다 — main context 절약 (CONSTITUTION §3.7.2).

## Common Failures

| 안티패턴 | 증상 | 수정 |
|---|---|---|
| Step 5 책임 흡수 | runtime task log 캡처·라우팅 절차를 본 스킬에 통합 | `evaluation-loop-runner` (Step 5, runtime) 가 별도. 본 스킬은 *design time* 만 |
| roles.md ownership 위반 | skeleton 부재 상태에서 본 스킬이 *처음부터* roles.md 생성 | `context-map-architecture` 가 skeleton seed → 본 스킬이 body. 부재 시 needs_input (category: inventory) 로 보고 |
| Toy golden-set | 실제 task log 없이 가짜 case 로 golden-set 채움 | golden-set 은 *실제 발생 작업* 기준. follow-up 으로 task log 누적 후 case 갱신 표기 |
| Role inflation | 자원 수만큼 role 정의 (자원-role 1:1 매핑 강제) | role 은 *책임* 단위. 한 role 이 여러 자원 호출 (1:N) 또는 N:1 허용 |
| 무한 사이클 | `evaluation-loop.md` 의 종료 조건 누락 | 종료 조건 4종 (no-op / 사용자 명시 종료 / 같은 design skill 2회 / 누적 5회) 명시 강제 |
| Routing Decision 누락 | 사이클에 *어디로 환원* 인지 정의 없음 | 4 sibling skill (`context-map-architecture` / `resource-design` / 본 skill / `agent-skill-auditor`) 표 명시 |
| PASS-only golden-set | case 가 정상 동작만 정의 (no-op / blocked 표면 부재) | golden-set 은 PASS + no-op + blocked + needs_input 모두 정의 |
| Phase 2 skip | Verification Plan 없이 곧바로 Phase 3 write | CONSTITUTION §3.3 위반 — Phase 2 effect gate 강제 |
| Order violation | `evaluation-loop.md` 를 `roles.md` 보다 먼저 작성 | Phase 3 의존성 순서 (1→4) 강제. evaluation-loop 가 roles 인용 |
| Plan vs Apply 혼동 | Verification Plan 에 "applied" 표시 | Plan = 의도, Applied Changes = 실행 결과 |

## Verification

본 스킬의 trigger / no-op / near-miss 검증 인프라는 *본 스킬 자체* 가 표준화하는 자산 (`docs/agent/golden-set.md`) 에 의존한다. 자기 참조 회피: 본 스킬의 회귀는 description trigger phrase 6건 (한·영 혼용) + `When NOT to Use` 6항 + Common Failures 10항이 사실상의 가벼운 검증 표면. 자세한 평가가 필요하면 `agent-skill-auditor` 가 정적 rule 감사 (P0/P1/P2 + rule ID + confidence) 를 별도 수행.

## References

- `references/roles-write.md` — `docs/agent/roles.md` body 작성 절차 (role inventory / 페어 매핑 / Effect gate)
- `references/evaluation-loop-write.md` — `docs/agent/evaluation-loop.md` 작성 절차 (진입·종료 조건 / Routing Decision 표 / 4 sibling 환원)
- `references/golden-set-write.md` — `docs/agent/golden-set.md` 작성 절차 (case 선정 / schema / no-op·blocked 표면)
- `references/task-log-template-write.md` — `docs/agent/task-log-template.md` 작성 절차 (entry schema / 보존 정책 / golden-set 연결)

Normative source: `${CLAUDE_PLUGIN_ROOT}/references/harness-principles.md` §4.1 (Docs 책임 — `docs/agent/`), §4.5 (Context Map 라우팅), §4.7 (자산 선택 기준), `${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md` §3 (10개 design principle), `${CLAUDE_PLUGIN_ROOT}/references/GAP-FORMAT.md` (vocabulary borrow only — Severity P0-P3 어휘만 재사용, GAP report 본문 형식 재사용 아님). Workflow 정의: `${CLAUDE_PLUGIN_ROOT}/references/harness-installation-workflow.md` §3.3.

Reference subagent: `agent-skill-auditor` (정적 rule 감사 — Routing Decision 표의 *정적 감사 필요* 행에서 호출).

본 스킬은 본문에 표준 규칙을 복사하지 않는다 — *언제 어느 reference 를 따라 무엇을 작성·검증할지* 만 정의한다.
