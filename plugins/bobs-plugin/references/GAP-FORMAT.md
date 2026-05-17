# GAP 리포트 포맷 v2.1

생성: 2026-05-16
개정: 2026-05-17
상위 문서:
- `CONSTITUTION.md`
- `SKILL-GUIDE.md`
- `AGENT-GUIDE.md`
- `COMMAND-GUIDE.md`
- `HOOK-GUIDE.md`
- `RUNTIME-GUIDE.md`

이 문서는 v2 기준 문서와 실제 구성 자산 사이의 차이를 기록하는 리포트 형식이다. GAP-FORMAT 은 헌법과 가이드의 권위를 재판단하지 않는다. 헌법과 가이드가 정한 원칙을 실제 자산에 적용할 때 필요한 기록 방식을 정의한다.

문서 권위:

```text
CONSTITUTION.md
-> SKILL-GUIDE.md / AGENT-GUIDE.md / COMMAND-GUIDE.md / HOOK-GUIDE.md / RUNTIME-GUIDE.md
-> GAP-FORMAT.md
-> 개별 GAP 리포트
```

---

## 1. 목적

GAP 리포트의 목적은 자산에 점수를 매기는 것이 아니다.

목적:
- 실제 스킬, 에이전트, 커맨드, 훅, 런타임 설정이 v2 원칙과 얼마나 맞는지 확인한다.
- 차이가 있을 때 자산 문제인지, 가이드 보완점인지, 의도적 예외인지 분리한다.
- 형식 차이가 아니라 라우팅, scope, capability, output, safety 에 미치는 영향을 기록한다.
- 다음 iteration 에서 어떤 문서나 자산을 수정할지 결정할 근거를 남긴다.

GAP 은 "가이드와 다르다" 가 아니라 "차이가 실제 품질이나 안정성에 영향을 준다" 를 뜻한다.

---

## 2. 파일 배치

v2 GAP 리포트는 `v2/gaps/` 아래에 둔다.

권장 파일명:

```text
v2/gaps/skill-<skill-name>.GAP.md
v2/gaps/agent-<path-safe-agent-name>.GAP.md
v2/gaps/command-<command-name>.GAP.md
v2/gaps/hook-<hook-name>.GAP.md
v2/gaps/runtime-<settings-or-policy-name>.GAP.md
```

예시:

```text
v2/gaps/skill-brainstorming.GAP.md
v2/gaps/agent-feature-dev-code-reviewer.GAP.md
v2/gaps/command-weather-orchestrator.GAP.md
v2/gaps/hook-format-on-edit.GAP.md
v2/gaps/runtime-project-settings.GAP.md
```

경로에 `/` 가 있는 자산명은 `-` 로 치환한다.

---

## 3. 평가 순서

항상 권위가 높은 문서부터 적용한다.

1. `CONSTITUTION.md`: 하네스 자산에 공통 적용되는 hard rule 과 design principle
2. 타입별 가이드:
   - skill: `SKILL-GUIDE.md`
   - agent: `AGENT-GUIDE.md`
   - command: `COMMAND-GUIDE.md`
   - hook: `HOOK-GUIDE.md`
   - runtime/settings: `RUNTIME-GUIDE.md`
3. `GAP-FORMAT.md`: 리포트 작성 형식과 판정 절차

평가자가 헌법과 가이드의 해석을 임의로 바꾸면 안 된다. 다만 실제 자산의 좋은 패턴이 가이드에 없거나, 가이드가 헌법보다 좁게 읽히는 경우는 `GUIDE_GAP` 으로 기록해 다음 iteration 의 입력으로 남길 수 있다.

---

## 4. 판정 원칙

GAP 으로 기록하는 경우:
- activation signal 이 불명확해 잘못 호출될 수 있다.
- scope 가 넓거나 모호해 결과 품질이 흔들릴 수 있다.
- 부수 효과가 있는데 gate 가 없다.
- capability surface 가 responsibility 보다 넓다.
- output contract 가 없어 호출자나 runtime 이 결과를 해석하기 어렵다.
- reusable knowledge 와 project memory 가 섞여 재사용성을 해친다.
- progressive disclosure 가 깨져 context 비용이나 실행 혼선이 생긴다.
- hard gate 와 일반 지침이 섞여 우선순위가 흐려진다.
- 검증할 수 없는 구조라 반복 안정성을 판단하기 어렵다.
- 유사 자산과 overlap 이 있으나 차이가 설명되지 않는다.
- 실제 자산의 좋은 공통 패턴이 가이드에 빠져 있다.
- 사용자가 명시 호출해야 할 workflow 가 skill/agent 로 숨겨져 있다.
- 런타임 권한, memory, MCP, budget 이 책임보다 넓다.
- version-sensitive 가정에 검증일/source 가 없다.

기록하지 않아도 되는 경우:
- 단순 문체 차이
- 섹션명 차이
- 의도적이고 설명 가능한 예외
- heuristic 의 경미한 미준수
- 표본 outlier 이지만 실제 영향이 낮은 경우
- 타입별 가이드의 권장 형식과 다르지만 헌법의 기능을 만족하는 경우

---

## 5. 원칙 강도 적용

`CONSTITUTION.md §2` 의 강도를 그대로 사용한다.

| 강도 | GAP 처리 |
|---|---|
| Hard rule | 위반 시 finding 으로 기록한다. 보통 P0-P1 |
| Design principle | 영향이 있으면 finding 으로 기록한다. 보통 P1-P2 |
| Heuristic | 자동 finding 이 아니다. 실제 영향이 있을 때만 기록한다 |
| Local convention | reusable 자산에는 직접 적용하지 않는다. 필요하면 CLAUDE.md 관련 이슈로 기록한다 |

예:
- `Output Format` 제목 없음은 heuristic 이다. 산출 지시가 실제로 있으면 GAP 이 아니다.
- description word count 초과는 heuristic 이다. 라우팅 혼선이나 context 비용이 있을 때만 GAP 이다.
- advisory 역할이 mutation 권한을 갖고 gate 가 없다면 hard rule/design principle 위반이다.

---

## 6. GAP 유형

| 유형 | 의미 |
|---|---|
| `ASSET_GAP` | 실제 자산이 v2 헌법 또는 타입별 가이드의 핵심 기대에 미달 |
| `GUIDE_GAP` | 실제 자산의 좋은 반복 패턴이 타입별 가이드에 반영되어 있지 않음 |
| `AMBIGUITY` | 자산 의도, 가이드 적용, platform behavior 가 불명확 |
| `INTENTIONAL_EXCEPTION` | 기준과 다르지만 목적과 영향이 설명 가능한 예외 |
| `NO_GAP` | 검토 결과 의미 있는 GAP 없음 |

`GUIDE_GAP` 은 신중하게 사용한다. 다음 중 하나일 때만 쓴다.

- 여러 자산에서 반복되는 좋은 패턴이 가이드에 없다.
- 가이드가 헌법보다 좁게 읽혀 좋은 자산을 false positive 로 만든다.
- 타입별 guide 가 platform behavior 를 단정해 평가 혼선을 만든다.
- 하위 문서 수정으로 향후 GAP 리포트 품질이 좋아진다.

헌법 자체를 수정해야 한다고 제안하려면, 그 내용이 command/skill/agent/hook/runtime 전반에 적용되는 공통 원칙인지 확인한다. 특정 타입에만 해당하면 해당 타입 가이드의 `GUIDE_GAP` 으로 둔다.

---

## 7. Severity

Severity 는 영향 기준이다. 규칙 위반 수가 아니라 라우팅, 안전, 산출 품질, 재사용성, 유지보수성에 미치는 영향을 본다.

| Severity | 의미 | 예 |
|---|---|---|
| `P0` | 즉시 수정 필요. 안전, 데이터, destructive action 위험 | secret 전송 훅, 승인 없는 deploy, destructive command 자동 허용 |
| `P1` | 라우팅, 권한, 부수 효과, 산출 신뢰성에 직접 영향 | advisory agent 에 mutation 권한, output contract 없음, scope 없는 reviewer |
| `P2` | 품질 저하 가능성이 크거나 반복되면 비용이 커짐 | near-miss 부재, context 비용 과다, overlap 모호 |
| `P3` | 낮은 우선순위의 정리 또는 명확화 | naming 개선, 섹션 재배치, 예시 압축 |

보정 규칙:
- 형식만 다르고 기능이 있으면 finding 으로 만들지 않거나 P3 로 낮춘다.
- "있으면 더 좋음" 수준은 기본 P3 이다.
- 추정 영향만 있고 증거가 약하면 한 단계 낮춘다.
- tool/model/hook 문제는 권한, 비용, 안전, 품질 영향이 구체적일 때만 P1 이상이다.
- P0/P1 은 사용자가 잘못된 자산을 호출하거나, 부수 효과가 발생하거나, 산출물을 신뢰하기 어려운 직접 원인이 있어야 한다.

---

## 8. Guide Reference

각 finding 은 실제 존재하는 문서와 heading 을 참조한다.

예:

```text
CONSTITUTION.md §3.3 Effects Require Gates
CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility
SKILL-GUIDE.md §7 Output Contract
AGENT-GUIDE.md §6 Capability Surface
HOOK-GUIDE.md §8 Security
```

규칙:
- 존재하지 않는 section 번호를 만들지 않는다.
- 정확한 heading 을 모르면 문서명과 주제만 쓴다.
- 가이드 보완점이면 `Guide target` 을 쓴다.

예:

```text
Guide target: AGENT-GUIDE.md §10 Overlap And Reuse
Guide target: HOOK-GUIDE.md Version-Sensitive Details
```

---

## 9. 리포트 구조

개별 GAP 리포트는 다음 순서로 작성한다.

1. Metadata
2. Executive Summary
3. Asset Snapshot
4. Applicable Criteria
5. Checks
6. Findings
7. Acceptable Deviations
8. Suggested Changes
9. Follow-up Questions
10. Final Decision

필요 없는 섹션은 `None` 으로 남긴다. 삭제해서 구조를 흔들지 않는다.

---

## 10. Metadata

공통 metadata:

```text
작성일:
기준 버전: v2
검토자:
asset_type: skill | agent | command | hook | runtime
source_path:
compared_against:
assumptions:
scope:
exclusions:
verification:
final_decision:
```

`compared_against` 는 실제 적용한 문서만 적는다.
`assumptions` 는 cwd, 기준 문서 위치, runtime/version 확인 여부처럼 판단에 영향을 줄 수 있는 전제를 적는다. 없으면 `None` 으로 둔다.
`scope` 는 실제 분석한 대상과 범위를 적는다.
`exclusions` 는 의도적으로 분석하지 않은 대상과 이유를 적는다.
`verification` 은 final decision 전에 확인한 self-check, 파일 존재 확인, heading 확인, 실행 검증 또는 검증하지 못한 이유를 적는다.

예:

```text
compared_against: CONSTITUTION.md, AGENT-GUIDE.md
```

---

## 11. Asset Snapshot

Snapshot 은 판단 근거를 압축해서 남기는 곳이다. 수치는 필수는 아니지만, 길이·권한·라우팅 관련 finding 이 있으면 기록한다.

### 11.1 Skill Snapshot

```text
name:
description:
description_words:
body_words:
body_lines:
tools:
invocation_controls:
has_references:
has_scripts_or_assets:
has_effect_gate:
has_output_contract:
```

### 11.2 Agent Snapshot

```text
name:
description:
description_words:
body_words:
body_lines:
tools:
model:
color:
has_scope:
has_output_contract:
has_quality_gate:
has_project_memory_coupling:
```

### 11.3 Command Snapshot

```text
name:
description:
description_words:
argument_hint:
body_words:
body_lines:
allowed_tools:
model:
has_input_contract:
has_delegation_contract:
has_effect_gate:
has_output_contract:
has_fail_closed_path:
```

### 11.4 Hook Snapshot

```text
name:
event:
matcher:
scope: user | project | unknown
command_or_script:
script_path:
has_path_filter:
has_exit_policy:
has_external_io:
has_security_sensitive_behavior:
```

### 11.5 Runtime Snapshot

```text
name:
scope: user | project | local | managed | unknown
source_path:
permissions_allow:
permissions_ask:
permissions_deny:
mcp_servers:
memory_scopes:
model_or_budget_policy:
auto_mode_or_background_policy:
has_secret_or_local_path:
has_version_evidence:
```

Snapshot 판정 메모:
- `has_output_contract` 는 제목이 아니라 기능 기준이다.
- `has_quality_gate` 는 숫자 confidence 만 뜻하지 않는다.
- `tools: omitted` 은 `tools: none` 이 아니다.
- `model: inherit` 은 명시적 model 선택이다.
- hook 의 exact schema 와 exit semantics 는 runtime 확인 전 단정하지 않는다.
- runtime 의 permission precedence, memory injection, MCP loading 은 구현 시점 확인 전 단정하지 않는다.

---

## 12. Checks

Checks 는 finding 을 만들기 전 전체 상태를 빠르게 보여주는 표다.

Status 값:
- `pass`: 기준을 만족
- `partial`: 기능은 있으나 약하거나 간접적
- `gap`: 영향 있는 차이 있음
- `n/a`: 해당 없음
- `unknown`: 자료 부족 또는 platform behavior 미확인

### 12.1 Skill Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass / partial / gap / n/a / unknown | |
| Description avoids workflow shortcut | pass / partial / gap / n/a / unknown | |
| Skill is an automatic external/domain capability, not a user workflow | pass / partial / gap / n/a / unknown | |
| Scope or near-miss is clear when needed | pass / partial / gap / n/a / unknown | |
| Capability procedure is actionable | pass / partial / gap / n/a / unknown | |
| Effect gate exists when mutation is possible | pass / partial / gap / n/a / unknown | |
| Output contract exists | pass / partial / gap / n/a / unknown | |
| Progressive disclosure is appropriate | pass / partial / gap / n/a / unknown | |
| Reusable vs project memory is separated | pass / partial / gap / n/a / unknown | |
| Behavior can be verified | pass / partial / gap / n/a / unknown | |
| Overlap is intentional | pass / partial / gap / n/a / unknown | |

### 12.2 Agent Checks

| Check | Status | Notes |
|---|---|---|
| Activation signal is clear | pass / partial / gap / n/a / unknown | |
| Specialist role and mission are clear | pass / partial / gap / n/a / unknown | |
| Scope and exclusions are clear | pass / partial / gap / n/a / unknown | |
| Capability surface matches responsibility | pass / partial / gap / n/a / unknown | |
| Model choice is explicit or justified | pass / partial / gap / n/a / unknown | |
| Output contract exists | pass / partial / gap / n/a / unknown | |
| Quality gate exists when needed | pass / partial / gap / n/a / unknown | |
| Project memory coupling is appropriate | pass / partial / gap / n/a / unknown | |
| Overlap with other agents is intentional | pass / partial / gap / n/a / unknown | |
| Behavior can be verified | pass / partial / gap / n/a / unknown | |

### 12.3 Command Checks

| Check | Status | Notes |
|---|---|---|
| Explicit user invocation is required | pass / partial / gap / n/a / unknown | |
| Input and missing-input handling are clear | pass / partial / gap / n/a / unknown | |
| Scope and exclusions are clear | pass / partial / gap / n/a / unknown | |
| Delegation contract is clear | pass / partial / gap / n/a / unknown | |
| Context links/selectors are explicit and bounded | pass / partial / gap / n/a / unknown | |
| Capability surface matches workflow | pass / partial / gap / n/a / unknown | |
| Effect gate exists when mutation is possible | pass / partial / gap / n/a / unknown | |
| Output contract exists | pass / partial / gap / n/a / unknown | |
| Fail-closed and no-op paths are clear | pass / partial / gap / n/a / unknown | |
| Main-context output is bounded | pass / partial / gap / n/a / unknown | |
| Behavior can be verified | pass / partial / gap / n/a / unknown | |

### 12.4 Hook Checks

| Check | Status | Notes |
|---|---|---|
| Event choice matches purpose | pass / partial / gap / n/a / unknown | |
| Matcher is narrow enough | pass / partial / gap / n/a / unknown | |
| Input handling is defensive | pass / partial / gap / n/a / unknown | |
| Effect and exit policy are clear | pass / partial / gap / n/a / unknown | |
| Security-sensitive behavior is safe | pass / partial / gap / n/a / unknown | |
| External IO is absent or justified | pass / partial / gap / n/a / unknown | |
| Performance impact is bounded | pass / partial / gap / n/a / unknown | |
| Registration path is clear | pass / partial / gap / n/a / unknown | |
| Version-sensitive assumptions are marked | pass / partial / gap / n/a / unknown | |
| Behavior can be verified | pass / partial / gap / n/a / unknown | |

### 12.5 Runtime Checks

| Check | Status | Notes |
|---|---|---|
| Settings scope matches shareability | pass / partial / gap / n/a / unknown | |
| Allow rules are narrowly scoped | pass / partial / gap / n/a / unknown | |
| Deny/block rules protect destructive actions | pass / partial / gap / n/a / unknown | |
| Ask rules cover risky but legitimate operations | pass / partial / gap / n/a / unknown | |
| Secrets and personal paths are not project-shared | pass / partial / gap / n/a / unknown | |
| MCP servers have source and capability notes | pass / partial / gap / n/a / unknown | |
| Memory/state lifecycle is clear | pass / partial / gap / n/a / unknown | |
| Model/effort/budget choices are justified | pass / partial / gap / n/a / unknown | |
| Auto/background behavior has opt-in/cap/stop path | pass / partial / gap / n/a / unknown | |
| Version-sensitive assumptions are marked | pass / partial / gap / n/a / unknown | |

---

## 13. Findings

각 finding 은 하나의 문제만 다룬다.

필수 필드:
- `id`: `GAP-001`
- `type`: `ASSET_GAP` / `GUIDE_GAP` / `AMBIGUITY` / `INTENTIONAL_EXCEPTION`
- `severity`: `P0`-`P3`
- `guide_ref`
- `expected`
- `actual`
- `evidence`
- `impact`
- `recommendation`

요약 표:

```markdown
| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `CONSTITUTION.md §3.3` | ... | ... |
```

상세 형식:

```markdown
### GAP-001: [short title]

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `CONSTITUTION.md §3.3 Effects Require Gates` |

**Expected**

v2 기준의 기대 상태.

**Actual**

현재 자산의 상태.

**Evidence**

짧은 section name, phrase, frontmatter 값, file path.

**Impact**

라우팅, 안전, capability, output, 재사용성, 유지보수성 중 어떤 영향인지 설명한다.

**Recommendation**

asset 수정인지 guide 수정인지 분명히 쓴다.
```

Evidence 는 짧게 쓴다. 긴 원문 복사는 피한다.

---

## 14. Acceptable Deviations

기준과 다르지만 목적과 영향이 설명 가능한 예외를 기록한다.

예:

```markdown
| Deviation | Why acceptable |
|---|---|
| Long body | Meta skill with verification loop and bundled references |
| `model: inherit` | Agent is intended to match caller reasoning profile |
| Output contract embedded in workflow | Output is still explicit and actionable |
```

좋은 예외는 finding 으로 승격하지 않는다.

---

## 15. Suggested Changes

수정 제안은 대상별로 나눈다.
각 제안은 관련 finding ID, acceptable deviation, 또는 follow-up question 과 연결한다. 연결할 근거가 없으면 제안하지 않는다.
제안은 확인된 영향을 해결하는 가장 작은 변경 단위로 쓴다. 장래 확장성, 문체 통일, 인접 문서 정리는 현재 finding 해결에 필요할 때만 포함한다.

```markdown
### Asset Changes

- [ ] ...

### Guide Changes

- [ ] ...

### Constitution Review

- [ ] ...
```

`Constitution Review` 는 드물게만 사용한다. 하네스 자산 전반에 적용되는 공통 원칙 수준일 때만 적는다.

Follow-up Questions 작성 규칙:
- 질문은 final decision 에 영향을 줄 수 있는 ambiguity 만 남긴다.
- 분석을 계속할 수 있는 불확실성은 `assumptions`, `unknown`, `AMBIGUITY` 로 표시하고 질문을 좁게 쓴다.
- blocking ambiguity 가 있으면 final decision 은 `NEEDS_REVIEW` 로 둔다.
- 있으면 좋은 개선이나 범위 밖 정리는 질문이 아니라 별도 follow-up 후보로 둔다.

---

## 16. Final Decision

리포트 마지막에 하나를 선택한다.

| 결정 | 의미 |
|---|---|
| `PASS` | 영향 있는 GAP 없음 |
| `PASS_WITH_NOTES` | 예외나 개선점은 있으나 자산 목적과 충돌하지 않음 |
| `REVISE_ASSET` | 자산의 라우팅, scope, effect, capability, output, 재사용성 수정 권장 |
| `REVISE_GUIDE` | 타입별 가이드가 좋은 자산을 false positive 로 만들거나 반복 패턴을 놓침 |
| `SPLIT_ASSET` | 여러 책임이 섞여 실제 호출/수행 품질을 떨어뜨림 |
| `DEPRECATE_ASSET` | 호출 경로와 차별점이 모두 약함 |
| `NEEDS_REVIEW` | 근거 부족, platform behavior 미확인, 사용자 의도 확인 필요 |

결정 기준:
- `PASS_WITH_NOTES` 는 findings 가 있어도 severity 가 낮고 목적과 충돌하지 않을 때 가능하다.
- `REVISE_ASSET` 은 실제 영향 있는 `ASSET_GAP` 이 있을 때 쓴다.
- `REVISE_GUIDE` 는 `GUIDE_GAP` 이 주요 결론일 때 쓴다.
- `NEEDS_REVIEW` 는 추정이 많거나 runtime behavior 확인 없이는 판단할 수 없을 때 쓴다.

---

## 17. 작성 전 Self-Check

리포트를 마치기 전에 확인한다.

```text
1. 헌법 -> 타입별 가이드 -> GAP-FORMAT 순서로 적용했는가?
2. guide_ref 는 실제 존재하는 heading 인가?
3. finding 은 형식 차이가 아니라 실제 영향이 있는가?
4. heuristic 을 hard rule 처럼 적용하지 않았는가?
5. platform default, tools behavior, hook schema 를 확인 없이 단정하지 않았는가?
6. 좋은 예외를 finding 으로 과잉 승격하지 않았는가?
7. recommendation 이 asset 수정인지 guide 수정인지 명확한가?
8. Constitution Review 를 너무 쉽게 제안하지 않았는가?
9. assumptions, scope, exclusions, verification 을 기록했는가?
10. Suggested Changes 는 finding 또는 질문에 연결된 최소 변경인가?
```

---

## 18. 작성 톤

- findings first 로 쓴다.
- 추측보다 증거를 우선한다.
- 형식 차이를 과잉 보고하지 않는다.
- 좋은 예외는 `Acceptable Deviations` 로 남긴다.
- 자산을 고칠지, 가이드를 고칠지 분리한다.
- platform behavior 가 불명확하면 `unknown` 또는 `NEEDS_REVIEW` 로 둔다.
- "섹션 없음", "길이 초과", "권장과 다름" 같은 표현은 impact 와 함께 쓸 때만 finding 으로 인정한다.
