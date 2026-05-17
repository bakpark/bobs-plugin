---
name: hook-creator
description: |-
  Use when creating, scaffolding, editing, or verifying a Claude Code hook: a registration entry plus the script it runs. Triggers on "create a hook", "훅 만들어줘", "PostToolUse for X", "PreToolUse 차단", "hook script 작성", or design spec dispatch with optional `name` / `event` / `matcher` / `scope`. Do NOT use for skills (`skill-creator`), agents (`agent-creator`), resource-type decisions (`resource-design`), static rule audit (`agent-skill-auditor`), or PR/code edits.
---

# hook-creator

Claude Code hook 작성·개선을 위한 절차 메타 스킬. hook 은 자동 실행 registration 과 script 한 쌍이므로 event, matcher, exit policy, security/performance 영향을 먼저 확정한다. creation-time GAP loop 는 `creator-gap-eval` 에 위임한다.

공통 loop 계약은 `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval/references/creator-loop-contract.md` 를 따른다. 본 파일은 hook 자원에만 해당하는 판단과 draft 기준을 둔다.

## References

모든 경로는 `${CLAUDE_PLUGIN_ROOT}` 기준이며, 미설정 시 현재 SKILL.md 기준 `../../` fallback 을 사용한다.

| 필요 | 읽을 문서 |
|---|---|
| intent / 자원 타입 경계 | `references/CONSTITUTION.md` |
| hook draft 기준 | `references/HOOK-GUIDE.md` |
| creator 공통 loop | `skills/creator-gap-eval/references/creator-loop-contract.md` |
| 자원별 GAP 분기 | `skills/creator-gap-eval/references/resource-type-matrix.md` |
| matcher pressure 가 필요할 때 | `skills/hook-creator/references/matcher-pressure.md` |

권위 문서가 없으면 draft 를 추정하지 말고 `BLOCKED: normative guide not found` 로 종료한다.

## When NOT to Use

- 스킬 작성 → `skill-creator`.
- 서브에이전트 작성 → `agent-creator`.
- 자원 타입, 책임 분리, migration 순서 결정 → `resource-design`.
- 기존 훅의 정적 rule 감사 → `agent-skill-auditor`.
- 자연어 trade-off, 긴 분석, 별도 context specialist 판단 → skill 또는 agent.
- 검증 인프라 → `evaluation-loop-design`.
- runtime task log / routing 실행 → `evaluation-loop-runner`.
- PR/code review 또는 외부 모델 의견.

## Inputs

| arg | 의미 | 처리 |
|---|---|---|
| `name` | hook/script kebab-case 이름 | path/collision check 에 사용 |
| `event` | `PreToolUse`, `PostToolUse`, `Stop`, `UserPromptSubmit` 등 | registration 작성에 사용 |
| `matcher` | event 별 matcher. 없으면 전역 또는 script-side filter 필요 | matcher 최소성 검토 |
| `scope` | `user` / `project` / `plugin` | script path 와 registration 위치 결정 |

args 는 mechanical pre-fill 이다. 다음 판단은 우회하지 않는다.

- 자동 보장할 단일 책임.
- matcher 가 반응해야 할 case 와 반응하지 않아야 할 near-miss.
- exit policy: `best-effort`, `blocking`, `context-inject`.
- 파일 mutation, network, secret 접근, state 저장 같은 부수 효과.
- 사용자 흐름을 막을 false positive 위험.

## Workflow

1. **Capture intent**
   `CONSTITUTION.md` 를 읽고 책임, event, matcher, exit policy, effects, scope 를 확정한다. 정보가 부족하면 한 번에 묶어 묻는다.

2. **Reroute if needed**
   hook 은 빠르고 결정론적인 guardrail 에 적합하다. 자연어 판단, 긴 분석, orchestration, 프로젝트 설명 작성이 핵심이면 다른 자원으로 전환한다.

3. **Choose target path**
   | scope | script path | registration |
   |---|---|---|
   | user | `~/.claude/hooks/<name>.sh` | `~/.claude/settings.json` |
   | project | `<repo>/.claude/hooks/<name>.sh` | `<repo>/.claude/settings.json` |
   | plugin | `plugins/<plugin>/hooks/<name>/<script>` | `plugins/<plugin>/hooks/<name>/hooks.json` |

   기존 동명·유사 책임 hook 이 있으면 새 작성보다 matcher 확장·수정·분리를 우선한다.

4. **Draft**
   `HOOK-GUIDE.md` 를 읽고 script + registration 을 작성한다. registration 변경은 자동 실행 범위를 바꾸는 부수 효과다.

5. **Run creator loop**
   `creator-loop-contract.md` 의 Minimal Workflow 와 Final Decision Map 을 따른다. `creator-gap-eval` 호출 시 `resource_type: hook` 을 사용한다.

6. **Report**
   common output fields 에 `event`, `matcher`, `exit_policy` 를 추가한다. 세부 finding 본문은 반복하지 말고 GAP report path 로 안내한다.

## Hook Draft Constraints

draft 는 다음 결과를 보장해야 한다.

- script 와 registration 의 pair 를 함께 다룬다.
- matcher 는 가능한 좁게 잡고, script 안에서 path/type filter 를 한 번 더 둔다.
- advisory 성격은 `exit 0` 이 기본이다. blocking hook 은 짧고 구체적인 stderr 사유가 있어야 한다.
- 매칭되지 않는 입력은 조용히 no-op 한다.
- JSON input 은 방어적으로 파싱한다. missing field 는 실패보다 no-op 또는 명시 메시지로 처리한다.
- 외부 network, secret 접근, destructive shell 은 명시 opt-in 없이는 넣지 않는다.
- long-running 작업은 hook 에 직접 넣지 않고 background 또는 별도 자산을 검토한다.
- runtime schema, exit code, merge precedence 가정은 단정하지 않는다. 코드에 박는 경우 verified 주석을 둔다.
- formatter, blocker, logger, context injector 를 한 hook 에 섞지 않는다.

## Effect Gates

첫 파일 쓰기 전에는 다음을 사용자에게 제시한다.

- script 절대 경로.
- registration 변경 요약 또는 JSON delta.
- event + matcher 와 선택 근거.
- exit policy 와 차단 시 사용자에게 보일 메시지.
- GAP report workspace 경로.

`REVISE_ASSET` 후 수정 전에도 변경 요약을 제시한다. registration 변경은 자동 실행 범위에 직접 영향을 주므로 사용자가 “묻지 말고 진행”을 명시했더라도 최종 변경 요약을 남긴다.

## creator-gap-eval Call

```yaml
resource_type: hook
draft_path:
  - <SCRIPT_PATH>
  - <REGISTRATION_PATH>
asset_name: <name>
delegation_mode: delegate
reentry_count: 0
round_count: 1
```

hook 특화 분기와 report path 는 `resource-type-matrix.md` 의 hook 컬럼을 따른다. 재호출 규칙, round 한도, Final Decision 처리는 `creator-loop-contract.md` 를 따른다.

## Output Contract

```text
created/updated: <script path>, <registration path>
scope: user | project | plugin
event: <event name>
matcher: <matcher value or *>
exit_policy: best-effort | blocking | context-inject
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <path to *.GAP.md>
guide_gaps: <count if any>
follow-ups: <count or short summary>
```

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 `blocked: needs revision` 을 앞에 붙인다.

## Escalation

- 책임이 섞이면 `SPLIT_ASSET` 또는 `resource-design` 으로 전환한다.
- false positive 가 사용자 흐름을 자주 막을 위험이면 best-effort 로 재설계하거나 reviewer 자산으로 전환한다.
- 자연어 판단·trade-off 가 필요하면 skill 또는 agent 로 전환한다.
- 3 rounds 후에도 같은 문제가 남으면 추가 수정보다 `SPLIT_ASSET`, `GUIDE_GAP`, `NEEDS_REVIEW` 를 검토한다.

## Limits

- 파일 수정은 본 스킬이 직접 한다.
- registration 변경은 항상 사용자가 이해할 수 있는 형태로 드러낸다.
- 외부 모델·네트워크 IO·자동 commit/push 는 사용하지 않는다.
- 다른 에이전트 자동 디스패치는 `creator-gap-eval` 의 위임 1건만 허용한다.
- GAP report 는 자산과 동급 산출물로 보존한다.
- Stop hook 자기 재호출 패턴은 opt-in, iteration cap, completion gate, visibility, stop path 가 모두 있을 때만 작성한다.
- guide 자체 수정은 본 스킬 범위 밖이다.
