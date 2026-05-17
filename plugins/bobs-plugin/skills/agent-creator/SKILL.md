---
name: agent-creator
description: |-
  Use when creating, scaffolding, editing, or verifying a Claude Code subagent (`agents/<name>.md`). Triggers on "create an agent", "에이전트 만들어줘", "subagent 작성·개선", or design spec dispatch with optional `name` / `scope` / `subagent_type`. Do NOT use for skills (`skill-creator`), hooks (`hook-creator`), resource-type decisions (`resource-design`), static rule audit (`agent-skill-auditor`), or PR/code edits.
---

# agent-creator

Claude Code 서브에이전트(`agents/<name>.md`) 작성·개선을 위한 절차 메타 스킬. specialist 책임, dispatch 조건, tools/model/runtime 표면, output contract 를 확정한 뒤 draft 하고, creation-time GAP loop 는 `creator-gap-eval` 에 위임한다.

공통 loop 계약은 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/references/creator-loop-contract.md` 를 따른다. 본 파일은 agent 자원에만 해당하는 판단과 draft 기준을 둔다.

## References

모든 경로는 `${CLAUDE_PLUGIN_ROOT}` 기준이며, 미설정 시 현재 SKILL.md 기준 `../../` fallback 을 사용한다.

| 필요 | 읽을 문서 |
|---|---|
| intent / 자원 타입 경계 | `references/CONSTITUTION.md` |
| agent draft 기준 | `references/AGENT-GUIDE.md` |
| creator 공통 loop | `skills/creator-gap-eval/references/creator-loop-contract.md` |
| 자원별 GAP 분기 | `skills/creator-gap-eval/references/resource-type-matrix.md` |
| pressure scenario 가 필요할 때 | `skills/agent-creator/references/pressure-scenarios.md` |
| trigger 측정이 필요할 때 | `skills/agent-creator/references/trigger-eval.md` |

권위 문서가 없으면 draft 를 추정하지 말고 `BLOCKED: normative guide not found` 로 종료한다.

## When NOT to Use

- 스킬 작성 → `skill-creator`.
- 훅 작성 → `hook-creator`.
- 자원 타입, 책임 분리, migration 순서 결정 → `resource-design`.
- 기존 에이전트의 정적 rule 감사 → `agent-skill-auditor`.
- 검증 인프라 → `evaluation-loop-design`.
- runtime task log / routing 실행 → `evaluation-loop-runner`.
- 사용자 명시 workflow, context router, plan gate entrypoint 작성 → command 트랙.
- PR/code review 자체 수행 또는 외부 모델 의견.

## Inputs

| arg | 의미 | 처리 |
|---|---|---|
| `name` | agent kebab-case 이름 | path/collision check 에 사용 |
| `scope` | `user` / `project` / `plugin` | 설치 위치 결정 |
| `subagent_type` | caller 가 Agent tool 로 부를 식별자 | frontmatter/name 결정에 사용. 없으면 name 기반 제안 |

args 는 mechanical pre-fill 이다. 다음 판단은 우회하지 않는다.

- 한 문장 specialist 책임.
- 언제 dispatch 되어야 하는지.
- 언제 dispatch 되면 안 되는지와 sibling 자산.
- 호출자가 기대하는 output.
- 필요한 tools, model, runtime capability.
- 읽기 전용인지, Write/Bash 권한이 필요한지.

## Workflow

1. **Capture intent**
   `CONSTITUTION.md` 를 읽고 책임, trigger, negative case, output, effects, scope 를 확정한다. 정보가 부족하면 한 번에 묶어 묻는다.

2. **Reroute if needed**
   별도 context/tool/model 격리가 필요하지 않으면 agent 로 만들지 않는다. command, skill, hook, `CLAUDE.md`, main session 작업이 더 적합하면 한 줄 사유를 보고하고 전환한다.

3. **Choose target path**
   | scope | path |
   |---|---|
   | user | `~/.claude/agents/<name>.md` |
   | project | `<repo>/.claude/agents/<name>.md` |
   | plugin | `plugins/<plugin>/agents/<name>.md` |

   built-in subagent type 또는 기존 유사 에이전트와 충돌하면 새 작성보다 이름 조정·수정·차별점 명시를 우선한다.

4. **Draft**
   `AGENT-GUIDE.md` 를 읽고 frontmatter 와 body 를 작성한다. agent 는 본문뿐 아니라 `tools`, `model`, runtime capability field 자체가 safety boundary 다.

5. **Run creator loop**
   `creator-loop-contract.md` 의 Minimal Workflow 와 Final Decision Map 을 따른다. `creator-gap-eval` 호출 시 `resource_type: agent` 를 사용한다.

6. **Report**
   common output fields 에 `tools`, `model` 을 추가한다. 세부 finding 본문은 반복하지 말고 GAP report path 로 안내한다.

## Agent Draft Constraints

draft 는 다음 결과를 보장해야 한다.

- frontmatter 첫 줄은 `---`.
- `name` / `subagent_type` 은 kebab-case 로 자연스럽게 호출 가능해야 한다.
- `description` 은 dispatch trigger 와 대표 negative case 중심. 본문 절차 요약을 넣지 않는다.
- `tools` 는 explicit allowlist 를 우선한다. advisory/read-only agent 가 Write/Edit/Bash 를 갖는 경우 이유가 있어야 한다.
- `model` 은 `sonnet` 기본. `opus`, `haiku`, `inherit` 는 역할상 이유가 있어야 한다.
- 본문 앞부분에서 persona, scope, mission, output contract 를 빠르게 찾을 수 있어야 한다.
- output contract 는 no-finding, `NEEDS_INPUT`, `OUT_OF_SCOPE` 같은 escalation case 를 포함한다.
- 분석과 수정, 리뷰와 commit/deploy, orchestration 과 specialist 판단을 한 agent 에 섞지 않는다.

## Effect Gates

첫 파일 쓰기 전에는 다음을 사용자에게 제시한다.

- 작성될 절대 경로.
- frontmatter 초안.
- tools/model/runtime capability 결정 근거.
- 본문 골격.
- GAP report workspace 경로.

`REVISE_ASSET` 후 수정 전에는 적용할 finding 제목과 변경 요약을 제시한다. 사용자가 “묻지 말고 진행”을 이미 명시한 경우에만 gate 를 생략하고 가정을 최종 응답 또는 GAP report 에 기록한다.

## creator-gap-eval Call

```yaml
resource_type: agent
draft_path:
  - <AGENT_PATH>
asset_name: <path-safe-name>
delegation_mode: delegate
reentry_count: 0
round_count: 1
```

agent 특화 분기와 report path 는 `resource-type-matrix.md` 의 agent 컬럼을 따른다. 재호출 규칙, round 한도, Final Decision 처리는 `creator-loop-contract.md` 를 따른다.

## Output Contract

```text
created/updated: <relative path>
scope: user | project | plugin
tools: <list>
model: <id>
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <path to *.GAP.md>
guide_gaps: <count if any>
follow-ups: <count or short summary>
```

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 `blocked: needs revision` 을 앞에 붙인다.

## Escalation

- 책임이 넓거나 persona drift 가 보이면 `SPLIT_ASSET` 또는 `resource-design` 으로 전환한다.
- 사용자 workflow orchestration 은 command 로 전환한다.
- 외부 인프라/API/domain capability 가 핵심이면 skill 로 전환한다.
- deterministic event guardrail 이 핵심이면 hook 으로 전환한다.
- 3 rounds 후에도 같은 문제가 남으면 추가 수정보다 `SPLIT_ASSET`, `GUIDE_GAP`, `NEEDS_REVIEW` 를 검토한다.

## Limits

- 파일 수정은 본 스킬이 직접 한다.
- 외부 모델·네트워크 IO·자동 commit/push 는 사용하지 않는다.
- 다른 에이전트 자동 디스패치는 `creator-gap-eval` 의 위임 1건만 허용한다.
- behavior verification pressure dispatch 는 선택이다. 사용자가 요청하거나 loop 가 막힐 때 `pressure-scenarios.md` 를 사용한다.
- GAP report 는 자산과 동급 산출물로 보존한다.
- guide 자체 수정은 본 스킬 범위 밖이다.
