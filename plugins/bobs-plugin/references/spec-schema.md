# Harness Installation Spec — Schema

> Normative source: 본 schema 는 v0.3 spec 의 *top-level discriminator + mode-specific payload* 정의. v0.2 markdown-like 형식 (`target=<x> | args=<...> | rationale=<한 줄>`) 의 후속 — 외부 review 의 P2 권고 (execution_mode 는 per-item 아닌 spec 의 top-level) 반영.
> 본 reference 는 design skill 산출 spec 의 *구조* 만 정의 — 각 design skill 의 inspect/draft 절차는 해당 SKILL.md 책임. install-harness command 가 본 schema 를 따라 spec 을 파싱 + mode 분기.

---

## 1. Goal + scope

v0.3 spec 의 통일 schema. 3 design skill (`resource-design`, `context-map-architecture`, `evaluation-loop-design`) 의 산출 spec 이 동일한 *top-level mode discriminator* + mode-specific payload 형식을 따른다.

본 schema 는 다음을 정의:

- 공통 header (spec_version / mode / metadata)
- top-level mode discriminator (6종) + design skill ↔ mode mapping
- mode-specific payload 4종 (dispatch / self_apply / plan_only + 변형 케이스 묶음)
- 파싱 규칙
- v0.2 markdown-like 형식 backward compatibility

본 reference 는 *spec 의 형식* 만 다룬다. design skill 내부 절차 (inspect / draft / GAP) 와 install-harness command body 의 분기 절차는 별도 자원 (각 SKILL.md / `commands/install-harness/*.md`) 책임.

---

## 2. 공통 header + top-level discriminator

모든 design skill 산출 spec 의 첫 부분:

```yaml
spec_version: v2
generated_by: <design skill name>     # resource-design | context-map-architecture | evaluation-loop-design
date: <iso8601>
trigger: <user request 한 줄>
mode: dispatch | self_apply | plan_only | no-op | needs_input | blocked
```

`mode` 가 *top-level discriminator* — payload 본문이 mode 에 따라 달라진다. install-harness command 가 mode 를 먼저 read 하고 해당 payload 만 파싱.

### 2.1 mode 6종 의미

| mode | 의미 | payload 본문 |
|---|---|---|
| `dispatch` | creator skill 호출이 필요 (skill / agent / hook 작성·갱신) | `execution_plan` (§3.1) |
| `self_apply` | design skill 본문이 *이미* 파일 write 완료. install-harness 는 변경 사항 보고 + 사후 승인 gate (Risk 12.4 참조) | `applied_changes` (§3.2) |
| `plan_only` | spec 만 산출, 적용은 사용자 결정 보류 (effect gate 미통과 또는 사용자가 검토만 요청) | `proposed_plan` (§3.3) |
| `no-op` | 변경 불요 — 기존 자산으로 충분 | `reasoning` (§4.1) |
| `needs_input` | 사용자 추가 정보 필요 (자원 타입 결정 모호 / 인벤토리 누락 등) | `category` + `items` (§4.2) |
| `blocked` | 의존 자원 부재 또는 권한 부족 — 진행 불가 | `reason` + `needs_input` (§4.3) |

### 2.2 design skill ↔ mode mapping

각 design skill 이 어떤 mode 를 산출할 수 있는지:

| design skill | 가능 mode | 현재 SKILL.md mode 동의어 |
|---|---|---|
| `resource-design` | `dispatch` (default) / `no-op` / `needs_input` | (mode 명시 없음 — Execution Plan 만; v0.3 에서 명시 추가) |
| `context-map-architecture` | `self_apply` / `plan_only` / `no-op` / `blocked` | `applied ↔ self_apply`, `plan-only ↔ plan_only` (SKILL.md:104) |
| `evaluation-loop-design` | `self_apply` / `plan_only` / `no-op` / `needs_input` / `blocked` | `applied ↔ self_apply`, `plan-only ↔ plan_only` (SKILL.md:124) |

design skill 본문은 기존 mode 키워드 유지 (옵션 A — backward-compat). install-harness command 가 schema 의 mode 와 design skill 의 mode 를 동의어로 처리.

---

## 3. mode-specific payload

### 3.1 mode: dispatch

creator skill 호출이 필요한 경우 — resource-design 의 표준 출력.

```yaml
mode: dispatch
execution_plan:
  - target: skill-creator | agent-creator | hook-creator
    args:
      <key>: <value>     # creator §0 args contract (workflow doc §5.1)
    rationale: <한 줄>
```

#### 3.1.1 creator 별 args 키 (workflow doc §5.1 인용)

| target | 필수 args |
|---|---|
| `skill-creator` | `name` (kebab-case), `scope` (user / project / plugin) |
| `agent-creator` | `name` (kebab-case), `scope` (user / project / plugin), `subagent_type` (선택) |
| `hook-creator` | `name` (kebab-case), `event` (PostToolUse / Stop / UserPromptSubmit 등), `matcher` (event 별), `scope` (user / project / plugin) |

args 키가 누락된 채 호출되면 creator 의 §0 가 *부분 입력* 으로 시작 — 사용자에게 누락된 키만 질문.

### 3.2 mode: self_apply

design skill 본문이 이미 파일 write 완료 — install-harness 는 변경 사항 사용자에게 보고 + 사후 승인 gate.

```yaml
mode: self_apply
applied_changes:
  - file: <abs path>
    action: created | edited | moved
    summary: <한 줄 변경 요약>
follow_ups:
  - description: <한 줄>
    recommended_skill: <next design skill if any>    # 선택
```

design skill 본문이 *gate 통과 후* write 했는지 install-harness 가 검증 — 미통과 시 사후 승인 요청 (Risk 12.4 완화).

### 3.3 mode: plan_only

spec 만 산출, 적용 결정 보류. 사용자에게 plan 본문 제시 + 사용자 결정 후 진행.

```yaml
mode: plan_only
proposed_plan:
  - file: <abs path>
    action: create | edit | move
    rationale: <한 줄>
    preview: |
      <변경 본문 미리보기 — 사용자 검토 용>
```

사용자가 승인하면 design skill 재호출 (→ `self_apply` 또는 `dispatch`). 거부하면 chain 종료.

---

## 4. 변형 케이스

### 4.1 mode: no-op

```yaml
mode: no-op
reasoning: <기존 자원명 + 책임 매핑 + 왜 새 자원이 불필요한지 — 2-4줄>
existing_resources:    # 선택
  - <name>: <path>
```

### 4.2 mode: needs_input

```yaml
mode: needs_input
category: design | inventory
items:
  - <질문 또는 누락 path>
```

| category | 사유 | install-harness 후처리 |
|---|---|---|
| `design` | 자원 타입 결정 모호 (반복 vs 일회성 / 명시 호출 vs 자동 활성화 등) | 사용자에게 의도 캡처 질문 |
| `inventory` | 접근 불가 디렉토리 / 권한 부족 / 외부 도구 정보 누락 | 사용자에게 환경 보완 요청 |

### 4.3 mode: blocked

```yaml
mode: blocked
reason: <한 줄 — 어느 의존 자원이 부재 또는 어느 권한 부족>
needs_input:
  - <복구 위해 사용자가 해야 할 일 1-3 항목>
recommended_action: <design skill 호출 권고 또는 사용자 직접 조치>
```

---

## 5. 파싱 규칙

install-harness command (Round 4 Task 1) 가 spec 파일을 read 한 후:

1. spec 의 첫 YAML fenced block (` ```yaml ... ``` `) 추출
2. `mode` 필드 read (top-level discriminator)
3. mode 별 payload 섹션만 추가 파싱 (다른 mode payload 는 무시)
4. payload 필드 누락 시 `mode: needs_input` 으로 강제 전환 (사용자에게 필드 누락 안내)

**Claude native YAML 처리** — install-harness command 가 runtime 에 yq/PyYAML 등 외부 도구에 의존하지 않는다. Claude 가 YAML fenced block 을 *직접* 읽고 필드 추출. regression test 용 `check-fixtures.sh` 는 dev/CI 환경 전용 (§7 참조).

**위치 규칙**:
- design skill 산출 spec 은 `docs/specs/<date>-<slug>.md` (project) 또는 `${CLAUDE_PLUGIN_ROOT}/docs/specs/` (plugin) 에 저장 — context-map-architecture / evaluation-loop-design 은 *spec 파일 자체를 write* 하는 self_apply 패턴
- resource-design 은 spec 을 대화 응답으로 반환 (파일 write 없음) — install-harness 가 응답에서 YAML fenced block 추출 후 dispatch

---

## 6. v0.2 backward compatibility

v0.2 의 markdown-like Execution Plan (`target=<x> | args=<key=value, ...> | rationale=<한 줄>`) 도 install-harness command 가 graceful fallback 으로 파싱:

1. v2 YAML fenced block 우선 시도
2. 파싱 실패 (또는 `spec_version: v1` 명시) 시 v1 markdown-like 형식 시도
3. v1 형식은 mode 명시 없음 → `mode: dispatch` default 추정

v0.2 mode 키워드 ↔ v0.3 mode 동의어:

| v0.2 키워드 | v0.3 mode |
|---|---|
| `applied` | `self_apply` |
| `plan-only` | `plan_only` |
| `no-op` | `no-op` (동일) |
| `needs_input` | `needs_input` (동일) |
| `blocked` | `blocked` (동일) |
| (mode 명시 없음, Execution Plan 있음) | `dispatch` (resource-design default) |

v0.4 에서 v1 형식 deprecated warning. v0.5 에서 제거.

---

## 7. Fixture + verification

회귀 검증용 fixture pair 는 `spec-schema/fixtures/` 디렉토리:

| pair | 입력 | 기대 파싱 |
|---|---|---|
| spec-a-dispatch | `fixtures/spec-a-dispatch.md` (resource-design 산출 예) | `fixtures/spec-a-dispatch.expected.yaml` |
| spec-b-self-apply | `fixtures/spec-b-self-apply.md` (context-map 산출 예) | `fixtures/spec-b-self-apply.expected.yaml` |
| spec-c-no-op | `fixtures/spec-c-no-op.md` (resource-design no-op 예) | `fixtures/spec-c-no-op.expected.yaml` |

회귀 검증 script: `spec-schema/check-fixtures.sh` (yq + python PyYAML fallback, ~30-50 lines). dev/CI 환경 전용 — runtime install-harness 는 Claude native 처리 (§5).

verification 절차:

```bash
bash plugins/bobs-plugin/references/spec-schema/check-fixtures.sh
# exit 0 → 3 fixture pair 모두 PASS
# exit 1 → mismatch + diff 출력
```

---

## 8. Common Failures

| # | 안티패턴 | 증상 | 수정 |
|---|---|---|---|
| 1 | per-item execution_mode | execution_plan 각 항목에 execution_mode 필드 추가 | top-level mode discriminator 가 spec 전체 분기 — per-item 불요. 다른 mode 가 한 spec 안에 섞이면 spec 을 분리 (각 spec 이 한 mode) |
| 2 | mode 없이 payload 만 | mode 필드 누락, execution_plan 또는 applied_changes 만 | install-harness 가 mode 추정 가능하지만 ambiguous — design skill 본문에 mode 명시 강제 |
| 3 | self_apply 가 gate 우회 | design skill 이 effect gate 거치지 않고 파일 write 후 self_apply 보고 | install-harness §4 가 self_apply 시 사후 승인 gate 강제 (CONSTITUTION §3.3) |
| 4 | mode 동의어 일관성 깨짐 | 같은 design skill 이 `applied` 와 `self_apply` 를 번갈아 사용 | design skill 본문은 한 가지 키워드 유지 (현재는 `applied` / `plan-only`), schema mapping 표가 동의어 처리 |
| 5 | v1 형식 강제 | install-harness 가 v2 YAML 만 파싱 시도, v1 markdown-like 거부 | §6 backward-compat 절차 — v2 우선, 실패 시 v1 fallback. v0.5 까지 v1 지원 |

---

## 9. References

- `${CLAUDE_PLUGIN_ROOT}/references/harness-installation-workflow.md` §4 (spec 인터페이스 + versioning) + §5.1 (creator args contract)
- `${CLAUDE_PLUGIN_ROOT}/skills/resource-design/references/design-output-contract.md` §1.2 (resource-design 의 표준 4 섹션)
- `${CLAUDE_PLUGIN_ROOT}/skills/context-map-architecture/SKILL.md` Output Contract (mode mapping source)
- `${CLAUDE_PLUGIN_ROOT}/skills/evaluation-loop-design/SKILL.md` Output Contract (mode mapping source)
- `${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md` §3.3 (Effects Gates — self_apply gate 강제) + §3.4 (Output Contract)
