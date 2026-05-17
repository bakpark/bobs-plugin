---
name: skill-creator
description: |-
  Use when creating, scaffolding, editing, or verifying a Claude Code skill (`skills/<name>/SKILL.md`). Triggers on "create a skill", "스킬 만들어줘", "skill 작성·개선", or design spec dispatch with optional `name` / `scope`. Do NOT use for subagents (`agent-creator`), hooks (`hook-creator`), resource-type decisions (`resource-design`), static rule audit (`agent-skill-auditor`), or PR/code edits.
---

# skill-creator

Claude Code 스킬(`SKILL.md`) 작성·개선을 위한 절차 메타 스킬. 스킬의 책임, 자동 활성화 조건, 부수 효과, output contract 를 확정한 뒤 draft 하고, creation-time GAP loop 는 `creator-gap-eval` 에 위임한다.

공통 loop 계약은 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/references/creator-loop-contract.md` 를 따른다. 본 파일은 skill 자원에만 해당하는 판단과 draft 기준을 둔다.

## References

각 단계에서 필요한 문서만 읽는다. 모든 경로는 `${CLAUDE_PLUGIN_ROOT}` 기준이며, 미설정 시 현재 SKILL.md 기준 `../../` fallback 을 사용한다.

| 필요 | 읽을 문서 |
|---|---|
| intent / 자원 타입 경계 | `references/CONSTITUTION.md` |
| skill draft 기준 | `references/SKILL-GUIDE.md` |
| creator 공통 loop | `skills/creator-gap-eval/references/creator-loop-contract.md` |
| 자원별 GAP 분기 | `skills/creator-gap-eval/references/resource-type-matrix.md` |
| trigger 측정이 필요할 때 | `skills/skill-creator/references/trigger-eval.md` |
| pressure scenario 가 필요할 때 | `skills/skill-creator/references/red-green-refactor.md` |

권위 문서가 없으면 draft 를 추정하지 말고 `BLOCKED: normative guide not found` 로 종료한다.

## When NOT to Use

- 서브에이전트 작성 → `agent-creator`.
- 훅 작성 → `hook-creator`.
- 자원 타입, 책임 분리, migration 순서 결정 → `resource-design`.
- 사용자 명시 workflow / 문서 링크 주입 / plan gate 중심 entrypoint 작성 → command 트랙 (`resource-design` + `COMMAND-GUIDE.md`).
- 기존 스킬의 정적 rule 감사 → `agent-skill-auditor`.
- 검증 인프라 → `evaluation-loop-design`.
- runtime task log / routing 실행 → `evaluation-loop-runner`.
- PR/code review 또는 외부 모델 의견.

## Inputs

호출자는 자연어 요청 또는 design skill `Execution Plan` args 를 줄 수 있다.

| arg | 의미 | 처리 |
|---|---|---|
| `name` | skill kebab-case 이름 | path/collision check 에 사용. 없으면 제안하거나 질문 |
| `scope` | `user` / `project` / `plugin` | 설치 위치 결정. 없으면 요청 맥락에서 추론하거나 질문 |

`name` / `scope` 는 mechanical pre-fill 이다. 다음 판단은 args 로 우회하지 않는다.

- 한 문장 책임.
- 자동 활성화 trigger.
- negative case 와 sibling 자산.
- 호출자가 기대하는 output.
- 파일 수정, 외부 IO, shell, network 같은 부수 효과.

## Workflow

1. **Capture intent**
   `CONSTITUTION.md` 를 읽고 책임, trigger, negative case, output, effects, scope 를 확정한다. 정보가 부족하면 한 번에 묶어 묻는다.

2. **Reroute if needed**
   skill 이 아닌 자원이 더 적합하면 작성하지 않는다. 사용자에게 한 줄 사유를 보고하고 적절한 creator 또는 `resource-design` 으로 전환한다.

3. **Choose target path**
   scope 에 따라 path 를 정한다.

   | scope | path |
   |---|---|
   | user | `~/.claude/skills/<name>/SKILL.md` |
   | project | `<repo>/.claude/skills/<name>/SKILL.md` |
   | plugin | `plugins/<plugin>/skills/<name>/SKILL.md` |

   기존 동명·유사 책임 스킬이 있으면 새 작성보다 수정·압축을 우선한다.

4. **Draft**
   `SKILL-GUIDE.md` 를 읽고 target SKILL.md 를 작성한다. 새 골격을 발명하기보다 기존 guide 골격을 먼저 적용한다.

5. **Run creator loop**
   `creator-loop-contract.md` 의 Minimal Workflow 와 Final Decision Map 을 따른다. `creator-gap-eval` 호출 시 `resource_type: skill` 을 사용한다.

6. **Report**
   common output fields 를 반환한다. 세부 finding 본문은 반복하지 말고 GAP report path 로 안내한다.

## Skill Draft Constraints

draft 는 다음 결과를 보장해야 한다.

- frontmatter 첫 줄은 `---`.
- `name` 은 kebab-case.
- `description` 은 activation signal 중심. 본문 절차 요약을 넣지 않는다.
- 필요한 경우에만 `tools`, `disable-model-invocation`, 예외적 `user-invocable`, `allowed-tools` 를 쓴다.
- 사용자가 직접 시작하는 workflow 는 skill 로 숨기지 않고 command 로 분리한다.
- 본문에는 When to Use, capability procedure, output contract, no-op/blocked/needs_input 계열을 자원 성격에 맞게 둔다.
- 부수 효과가 있으면 파일 쓰기 전 gate 또는 명시 호출 조건을 둔다.
- project convention 이 핵심이면 reusable skill 보다 `CLAUDE.md` 또는 project-local 자산을 우선한다.

## Effect Gates

첫 파일 쓰기 전에는 다음을 사용자에게 제시한다.

- 작성될 절대 경로.
- frontmatter 초안.
- 본문 골격.
- GAP report workspace 경로.

`REVISE_ASSET` 후 수정 전에는 적용할 finding 제목과 변경 요약을 제시한다. 사용자가 “묻지 말고 진행”을 이미 명시한 경우에만 gate 를 생략하고 가정을 최종 응답 또는 GAP report 에 기록한다.

## creator-gap-eval Call

```yaml
resource_type: skill
draft_path:
  - <SKILL_PATH>/SKILL.md
asset_name: <name>
delegation_mode: delegate
reentry_count: 0
round_count: 1
```

재호출 규칙, round 한도, Final Decision 처리는 `creator-loop-contract.md` 를 따른다. `resource-type-matrix.md` 의 skill 컬럼이 report path, guide, snapshot/checks 분기를 정의한다.

## Output Contract

```text
created/updated: <relative path>
scope: user | project | plugin
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <path to *.GAP.md>
guide_gaps: <count if any>
follow-ups: <count or short summary>
```

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 `blocked: needs revision` 을 앞에 붙인다.

## Escalation

- 책임이 넓거나 두 자산 이상으로 갈라지면 `SPLIT_ASSET` 또는 `resource-design` 으로 전환한다.
- command / agent / hook / runtime / `CLAUDE.md` 가 더 적합하면 해당 경로로 전환한다.
- 3 rounds 후에도 같은 유형의 문제가 남으면 추가 수정보다 `SPLIT_ASSET`, `GUIDE_GAP`, `NEEDS_REVIEW` 를 검토한다.
- description trigger 정확도는 GAP 분석과 별개다. 충돌이 의심될 때만 `trigger-eval.md` 를 사용하고, 비용·시간이 들면 사용자 동의를 받는다.

## Limits

- 파일 수정은 본 스킬이 직접 한다.
- 외부 모델·네트워크 IO·자동 commit/push 는 사용하지 않는다.
- 다른 에이전트 자동 디스패치는 `creator-gap-eval` 의 위임 1건만 허용한다.
- GAP report 는 자산과 동급 산출물로 보존한다.
- guide 자체 수정은 본 스킬 범위 밖이다.
