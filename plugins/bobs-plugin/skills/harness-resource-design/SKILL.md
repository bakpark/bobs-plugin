---
name: harness-resource-design
description: |-
  Reference material only for agent-skill-designer or the main session after a Claude harness resource design task is already underway. Contains a rule-map index plus per-type guides (CONSTITUTION / SKILL-GUIDE / AGENT-GUIDE / HOOK-GUIDE) for choosing resource type, drafting contracts, and avoiding unsafe automation across skills, subagents, hooks, plugins, and workflow clusters. Do not use as the primary responder when subagent design delegation is available.
---

# harness-resource-design

이 스킬은 `~/.claude/` user-scope 자원 설계용 압축 지식 베이스다. 목표는 research 스냅샷을 그대로 운영 자산으로 복사하지 않고, 검증된 설계 원칙만 필요 시 참조하도록 만드는 것이다.

## Quick Decision

자원 타입을 먼저 결정한다.

| 필요 | 선택 |
|---|---|
| 절차, 도메인 지식, 반복 워크플로우 | skill |
| 별도 context / 도구 권한 / 모델 선택이 필요한 전문가 역할 | agent |
| 매 이벤트마다 보장해야 하는 자동 동작 | hook |
| 여러 자원을 배포·공유 단위로 묶음 | plugin |

기본값은 새 자원 추가가 아니라 기존 자원 수정이다. 새 자원은 중복 호출 경로, description 충돌, 권한 증가를 정당화할 때만 만든다.

## Routing Boundary

- 감사, 점수, metrics, rule evidence 만 필요하면 `agent-skill-auditor`.
- 설계 결정, 책임 분리, contract, migration order 가 필요하면 `agent-skill-designer`.
- 이 스킬은 위 두 경로가 이미 선택된 뒤 읽는 reference 이다.

## Workflow

1. 사용자의 목표를 한 문장으로 재정의한다.
2. 현재 자원과 호출 경로를 확인한다.
3. `guide-rule-map.md` 로 필수 규칙과 안티패턴을 대조한다.
4. 자원 타입별 세부 reference 를 하나만 선택해 읽는다.
5. 설계 산출물을 만든다: frontmatter 초안, 책임 경계, input/output contract, negative cases, migration order.
6. 구현 전 검증 방법을 명시한다. 정적 규칙 검사는 `agent-skill-auditor`, 스킬 작성 자체는 플러그인 `writing-skills` (스킬) / `writing-agents` (에이전트) 원칙을 따른다.

## When NOT To Use

- 정적 compliance 감사만 필요하면 `agent-skill-auditor` 를 사용한다.
- 실제 파일 수정, 코드 리뷰, PR 리뷰, 세션 사용량 집계에는 사용하지 않는다.
- 설계 작업을 subagent 로 위임할 수 있으면 primary responder 로 직접 쓰지 말고 `agent-skill-designer` 의 참고자료로 사용한다.

## References

- `references/guide-rule-map.md`: rule-ID 인덱스 + 임계값 + 안티패턴. 원문 가이드 (CONSTITUTION / SKILL-GUIDE / AGENT-GUIDE / HOOK-GUIDE) 의 압축본.
- `references/skill-patterns.md`: 스킬 설계, progressive disclosure, references 배치, invocation control.
- `references/agent-patterns.md`: 에이전트 description, tools/model, output contract, 책임 분리.
- `references/hook-patterns.md`: hook 이벤트 선택, matcher, failure behavior, routing hints.

## Output Expectations

설계 응답은 다음을 포함한다.

- 권고: create / update / merge / delete / defer 중 하나.
- 자원 형태: skill / agent / hook / plugin / mixed.
- 책임 경계: 해당 자원이 하는 일과 하지 않는 일.
- 호출 contract: input, output, failure modes.
- 적용 순서: 낮은 위험 변경부터.
- 위험: P0/P1/P2 와 완화책.

## Boundaries

- 이 스킬은 설계 지침이다. 파일 수정은 호출자가 수행한다.
- research 디렉토리의 원본 skill/agent를 그대로 복제하지 않는다.
- 가이드 전문을 매번 읽지 않는다. 먼저 `guide-rule-map.md` 를 읽고, 원문이 필요한 규칙만 `${CLAUDE_PLUGIN_ROOT}/references/agent-skill-best-practices/{CONSTITUTION,SKILL-GUIDE,AGENT-GUIDE,HOOK-GUIDE}.md` 에서 확인한다.
