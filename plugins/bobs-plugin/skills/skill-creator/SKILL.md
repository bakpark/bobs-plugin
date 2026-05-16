---
name: skill-creator
description: |-
  Use when creating, scaffolding, editing, or verifying a Claude Code skill (`SKILL.md` under `skills/<name>/`). Triggers on "create a skill", "스킬 만들어줘", "skill 작성·개선", "/skill-name 만들어줘", "draft a skill for X" — including when the user has not yet chosen a name or scope. Do NOT use for writing subagents (`agent-creator`), agent-vs-skill / merge / migration-order decisions (`agent-skill-designer`), static rule audit of an existing skill (`agent-skill-auditor`), or PR/code edits.
---

# skill-creator

Claude Code 스킬(`SKILL.md`) 작성·개선을 위한 절차 메타 스킬. agent-skill-best-practices 기준 문서를 단계별로 읽고, draft → GAP 분석 → 수정 → GAP 재분석을 PASS / PASS_WITH_NOTES 까지 반복한다.

관련 자산: `writing-skills`(discipline), `agent-creator`(서브에이전트), `agent-skill-designer`(타입·책임 결정), `agent-skill-auditor`(정적 rule 감사).

## Reference Loading Schedule

각 단계에서 *읽어야 할* 권위 문서 — 모든 경로는 `${CLAUDE_PLUGIN_ROOT}/references/` 아래.

**이식성 주의**:

- *배포 전제*: 본 스킬은 `bobs-plugin` references 와 함께 배포될 때 유효하다.
- *Fallback 경로*: `${CLAUDE_PLUGIN_ROOT}` 미설정 환경에서는 현재 SKILL.md 기준 `../../references/` 를 사용한다 (plugin 디렉토리 구조 가정).
- *실패 시*: 두 경로 모두 접근 불가하면 사용자에게 참조 문서 미존재를 보고하고 종료한다. 권위 문서 없이는 GAP 분석 loop 가 작동하지 않는다.

| Phase | 읽는 문서 | 용도 |
|---|---|---|
| §0 Capture intent | `CONSTITUTION.md` §3 (10개 design principle) | 의도·책임·escape hatch 판단 기준 |
| §1 Choose scope | (없음 — 본 스킬 내장 결정 트리) | — |
| §2 Draft | `SKILL-GUIDE.md` §2–§11 (frontmatter·body·effects·output·anti-patterns) | 스켈레톤 (discipline 요약은 §2 본문에 내재화) |
| §3 GAP 분석 | `GAP-FORMAT.md` (전체) + `GAP-ANALYSIS-PROMPT.md` (위임 프롬프트 verbatim) | 평가 리포트 형식 + 위임 protocol |
| §4 GAP 피드백 반영 | `GAP-FORMAT.md` §13 Findings + §15 Suggested Changes + §16 Final Decision | finding 별 수정 지침 |
| §5 Output to caller | (없음) | — |
| §6 Terminology and tone pass | (작성한 SKILL.md 자체) + CONSTITUTION §3.8 (강한 표현은 실제 gate 에) | 응답 직전 표현 통일 |

본 스킬은 규칙을 본문에 복사하지 않는다 — *언제 어느 문서를 읽고 어떤 산출물을 어디에 저장할지* 만 정의한다.

## When NOT to use

- 서브에이전트(`.md` under `agents/`) 작성 → `agent-creator`.
- 자원 타입(skill / agent / hook) 결정 → `agent-skill-designer`. 본 스킬은 *이미 스킬로 정한 뒤* 시작.
- 기존 스킬의 정적 rule 감사 (P0/P1/P2 + rule ID) → `agent-skill-auditor`. 본 스킬은 §3 에서 GAP 분석을 사용 (영향 기준 평가, rule ID 기반 채점이 아님).
- 외부 모델 의견 / PR 리뷰 → `codex-reviewer` / `pr-review-toolkit`.

## 0. Capture intent

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md
```

§3 의 10개 design principle 을 체크리스트로 사용해 다음 6가지를 확정한다. 대화 맥락에 있으면 추출하고, 없으면 한 번에 묶어서 묻는다.

10개 원칙: Activation Explicit / Scope Quality / Effects Gates / Output Contract / Capability Surface / Reusable vs Local / Progressive Disclosure / Strong Language / Verifiable / Overlap Intentional.

| # | 질문 | 매핑되는 헌법 §3 원칙 |
|---|---|---|
| 1 | 재사용 가능한 절차·방법은 무엇인가? (한 문장 책임) | §3.5 Capability Surface · §3.6 Reusable |
| 2 | 언제 활성화되어야 하나? (트리거 1–3개) | §3.1 Activation Explicit |
| 3 | 언제 활성화되면 안 되나? (negative case ≥1) | §3.1 · §3.10 Overlap Intentional |
| 4 | 호출자는 산출물로 무엇을 하는가? | §3.4 Output Contract |
| 5 | 부수 효과 있나? (파일 수정 / commit / send / deploy) | §3.3 Effects Require Gates |
| 6 | 어디에 두나? user / project / plugin | §3.6 Reusable vs Local |

### In-flight escape hatches (헌법 §3 위반 패턴별 전환)

의도 캡처 중 자원 타입이 달라 보이면 즉시 다른 자원으로 전환한다.

| 신호 | 위반 | 전환 대상 |
|---|---|---|
| 별도 context / tool 권한 / 별도 model 이 필요한 specialist 역할 | §3.5 — 스킬은 메인 context 에 로드됨 | `agent-creator` |
| 매 이벤트마다 결정론 보장 필요 | §3.1 — 스킬은 명시 activation, hook 은 결정론 | `harness-resource-design` (hook 트랙) |
| 프로젝트 고유 규칙 | §3.6 — reusable 자산이 아닌 local convention | `CLAUDE.md` |
| 회고·서사·세션 사후 정리 | §3.6 — 재사용 method 아님 | PR 설명 / docs |

사용자에게 한 줄로 전환 사유와 인용한 헌법 § 번호를 알리고 종료한다.

## 1. Choose scope

| Scope | Path | When |
|---|---|---|
| user | `~/.claude/skills/<name>/SKILL.md` | 모든 프로젝트에서 쓰임 |
| project | `<repo>/.claude/skills/<name>/SKILL.md` | 저장소 한정 |
| plugin | `plugins/<plugin>/skills/<name>/SKILL.md` | 배포 단위 |

**Name collision check**:

```bash
ls ~/.claude/skills/ <project>/.claude/skills/ plugins/*/skills/ 2>/dev/null
```

빌트인 슬래시 명령어 (`/help`, `/clear` 등) 와 충돌하면 라우팅 불확실 — 이름 변경. 동명·유사 책임 스킬이 있으면 신규 생성보다 *수정·압축* 우선.

## 2. Draft

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/SKILL-GUIDE.md
```

**파일 쓰기·수정 승인 gate (CONSTITUTION §3.3 Effects Require Gates)** — 본 스킬은 파일 시스템에 SKILL.md 와 workspace 디렉토리를 *생성·수정* 한다. 동일 gate 가 두 시점에 적용된다.

**시점 A — 첫 파일 쓰기 전 (§2 본문 작성)**: 다음 4가지를 사용자에게 제시한다.

1. 작성될 파일 절대 경로 (§1 에서 결정된 path)
2. frontmatter 초안 — *skill 지원 필드만* 사용 (`name`, `description`, 필요 시 `tools` / `disable-model-invocation` / `user-invocable` / `allowed-tools`). `model` 은 agent 전용 필드이므로 skill 에 두지 않는다.
3. 본문 골격 (Phase 1–3 헤더 + Output Contract 형태)
4. workspace 디렉토리 경로 (§3a 에서 생성될 위치)

**시점 B — §4 수정 반영 전 (round 2+)**: 적용할 finding 의 short title 과 *변경 요약* (어떤 섹션의 어떤 부분이 어떻게 바뀌는지) 을 사용자에게 제시한다.

각 시점에서 사용자가 "진행" / "go" / "proceed" 같은 명시적 신호를 줄 때만 파일을 쓰거나 수정한다.

사용자가 "묻지 말고 진행" 을 명시한 경우에만 확인 없이 진행한다. 첫 파일 쓰기 시 가정은 최종 응답의 `assumptions:` 필드 또는 SKILL.md 본문 첫 섹션 (`## Assumptions`) 에 기록한다. SKILL.md 첫 줄은 `---` frontmatter 구분자여야 하므로 가정 텍스트를 그 자리에 두지 않는다. 수정 반영 시 가정은 GAP report 의 `Acceptable Deviations` 에 기록한다.

**적용할 기준** — SKILL-GUIDE §2 (Frontmatter), §3 (Description), §4 (Body — `# Skill Title` / `## When to Use` / `## Workflow Phase 1-3` / `## Output Contract` / `## Common Failures` / `## References`), §5 (Effects And Gates), §6 (Progressive Disclosure), §7 (Output Contract), §11 (Anti-Patterns) 을 *표준 골격* 으로 삼는다. 자산 목적에 맞게 필요한 섹션만 조정한다 — SKILL-GUIDE 는 형식보다 기능을 중시하므로 모든 섹션 명을 그대로 강제하지 않는다.

**작성 중 자기검열** — 다음 discipline 을 작성 도중 점검 기준으로 사용한다 (writing-skills 의 핵심 개념을 본 스킬 본문에 내재화한 요약 — 추가 깊이가 필요하면 writing-skills SKILL.md 를 직접 참고):

- **CSO (Claude Search Optimization)** — description 은 activation signal 만 담는다. 본문 절차를 description 에 요약하면 호출자가 본문을 읽지 않고 description 만 따라 단축 실행한다 (Description-as-runbook 안티패턴).
- **Iron Law** — baseline 실패 없이 작성된 스킬은 *어떤 실패를 막는지* 알 수 없다. 작성 전 baseline prompt 로 무엇이 실패하는지 관찰한다.
- **함정 9종 (SKILL-GUIDE §11)** — Description-as-runbook / Narrative skill / Unscoped workflow / Must-bombing / Reference dump / Hidden mutation / Project convention leak / No output contract / Dead skill. 작성 후 §11 표로 자기 검열.

표준 골격을 적용한 SKILL.md 가 1차 draft 다. 새 골격을 발명하기 전, 기존 골격이 자산 목적에 맞지 않는 이유를 먼저 확인한다.

핵심 원칙 요약 (가이드 읽은 뒤 적용):
- description: trigger only, ≤500 chars 권고
- name: kebab-case 동사형 명사구
- 부수 효과: `disable-model-invocation: true` 또는 user-only invocation (Effects Gate)
- output contract: 호출자가 파싱 가능한 구조 + no-op / NEEDS_INPUT 케이스 명시
- 본문 길이: SKILL-GUIDE §9 의 heuristic 으로 ≤ 500 lines 가 검토 신호. 초과 시 `references/` 분리를 검토 (hard limit 아님 — 메타 스킬은 정당화 가능)
- 여러 언어로 분산하기보다 한 도메인을 깊게 작성한다

## 3. GAP 분석

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/GAP-FORMAT.md
Read ${CLAUDE_PLUGIN_ROOT}/references/GAP-ANALYSIS-PROMPT.md
```

GAP-FORMAT 의 §1 목적 (자산이 v2 원칙과 얼마나 맞는지 + 형식 차이가 아니라 영향 기준) + §6 GAP 유형 (ASSET_GAP / GUIDE_GAP / AMBIGUITY / INTENTIONAL_EXCEPTION / NO_GAP) + §7 Severity (P0–P3) 를 적용 기준으로.

### 3a. Workspace 준비

```bash
SKILL_PATH="<absolute path to new SKILL.md dir>"
WORKSPACE="${SKILL_PATH}-workspace"
mkdir -p "$WORKSPACE/gaps"
```

리포트 저장 경로: `$WORKSPACE/gaps/skill-<name>.GAP.md`.

### 3b. GAP 분석 위임 (권장)

generic subagent 로 GAP 분석을 위임한다. prompt 는 GAP-ANALYSIS-PROMPT 본문 (markdown fence 안쪽) 을 그대로 사용하되, 분석 대상은 새 스킬 1개로 제한한다.

현재 환경의 *subagent dispatch 도구* 를 사용한다. Claude Code 환경에서는 `Agent` 도구 + `subagent_type: "general-purpose"`; 다른 환경에서는 동등 메커니즘을 사용한다.

**경로 resolve 책임** — 위임 prompt 의 cwd 필드는 main session 이 *절대 경로* 로 채워서 보낸다 (`${CLAUDE_PLUGIN_ROOT}/references` 우선, env 미설정 시 §Reference Loading Schedule 의 fallback `../../references/`). subagent 는 resolved path 만 보며, 환경 변수 확장이나 fallback 판단을 하지 않는다.

Claude Code 예시 (dispatch 시 `<RESOLVED_REFS_DIR>` 는 main session 이 실제 절대 경로로 치환):

```
subagent_type: "general-purpose"
description: "GAP analysis of new skill: <name>"
prompt:
  ---
  현재 작업 디렉토리는 <RESOLVED_REFS_DIR> 이다.
  너는 이 대화의 이전 컨텍스트를 전혀 모른다고 가정하고, 현재 cwd 안의 파일만
  기준으로 GAP 분석을 수행한다. 단, 분석 대상은 외부 경로 1건:

    <SKILL_PATH>/SKILL.md

  반드시 먼저 읽을 문서 (cwd 내):
    - CONSTITUTION.md
    - SKILL-GUIDE.md
    - GAP-FORMAT.md

  리포트 저장 경로:
    <WORKSPACE>/gaps/skill-<name>.GAP.md

  [이하 GAP-ANALYSIS-PROMPT.md 의 §"판정 원칙" / §"원칙 강도" / §"Finding 유형" /
   §"Severity" / §"Skill 점검 축" / §"Evidence 작성 규칙" / §"리포트 구조" /
   §"최종 결정" / §"완료 보고" 섹션 verbatim 으로 복사]
  ---
```

**위임 prompt 본문 구성** — dispatch 직전에 `${CLAUDE_PLUGIN_ROOT}/references/GAP-ANALYSIS-PROMPT.md` 를 한 번 더 `Read` 하고, 아래 9 개 heading 의 *본문* (heading 다음 줄부터 다음 heading 직전까지) 을 *순서·원문 그대로* 복사해 dispatch payload 의 placeholder 자리에 붙여 넣는다. heading 이름 자체는 본 스킬이 이미 인용했으므로 복사 대상이 아니다.

복사 순서: §판정 원칙 → §원칙 강도 → §Finding 유형 → §Severity → §Skill 점검 축 → §Evidence 작성 규칙 → §리포트 구조 → §최종 결정 → §완료 보고.

복사하지 않는 섹션 (본 스킬의 dispatch envelope 가 직접 지시 → 중복 회피): §목표 / §반드시 먼저 읽을 문서 / §분석 대상 / §수정 가능 범위 / §작업 방식. 본 스킬은 *단일 스킬* 분석이므로 이들 섹션의 multi-asset 가정은 부적용.

위임 이유: main context 절약 + GAP-FORMAT 의 "이전 컨텍스트를 전혀 모른다고 가정" 원칙 충족 (평가자 독립성).

### 3c. 직접 GAP 분석 (경량 1차 평가)

비용을 줄여야 하면 main 세션이 직접 GAP-FORMAT §9 의 10개 섹션 (Metadata → Executive Summary → Asset Snapshot → Applicable Criteria → Checks → Findings → Acceptable Deviations → Suggested Changes → Follow-up Questions → Final Decision) 을 작성한다. 평가자 독립성이 약하므로 §3b 위임을 1회 이상 거치는 것이 권장된다.

### 3d. Self-Check (리포트 작성 전 GAP-FORMAT §17)

위임 결과를 받거나 인라인을 마치기 전 8개 self-check:
1. 헌법 → 타입별 가이드 → GAP-FORMAT 순서로 적용했나?
2. `guide_ref` 가 실제 존재하는 heading 인가?
3. finding 은 형식 차이가 아니라 실제 영향 (라우팅·안전·산출·재사용·유지보수) 인가?
4. heuristic 을 hard rule 처럼 적용하지 않았나?
5. platform behavior 를 확인 없이 단정하지 않았나?
6. 좋은 예외를 finding 으로 과잉 승격하지 않았나?
7. recommendation 이 asset 수정인지 guide 수정인지 명확한가?
8. Constitution Review 를 너무 쉽게 제안하지 않았나?

## 4. Self-feedback refine

**먼저 읽는다 (이번 라운드 산출물)**:

```bash
Read $WORKSPACE/gaps/skill-<name>.GAP.md
```

§13 Findings + §15 Suggested Changes + §16 Final Decision 을 본다.

### 4a. Final Decision 별 행동

| Final Decision | 행동 |
|---|---|
| `PASS` | 종료 (§5 로 진행) |
| `PASS_WITH_NOTES` | 낮은 severity finding 또는 acceptable deviation 만 잔류 — 옵션 적용 후 §5 |
| `REVISE_ASSET` | P0/P1/P2 적용 후 §3 재실행 |
| `REVISE_GUIDE` | 본 스킬 범위 밖 — 사용자에게 보고하고 §5 (자산은 일단 통과) |
| `SPLIT_ASSET` | §0 으로 복귀, 책임 분리 재설계 |
| `DEPRECATE_ASSET` | 호출 경로·차별점 모두 약함 — 폐기 권고로 사용자 confirm |
| `NEEDS_REVIEW` | 근거가 부족하거나 추정이 많은 경우 — 사용자 입력 받기 |

### 4b. Finding 적용 순서

**각 finding 의 적용은 §2 의 시점 B gate (변경 요약 제시 → 사용자 명시 신호 → 수정) 를 거친다.** 아래 순위는 *어떤 finding 을 먼저 처리할지* 의 우선순위이며, gate 자체를 우회하지 않는다 — "적용 의무" 는 *순위가 높다* 는 뜻이지 *gate 생략* 의 뜻이 아니다.

1. **P0 first** — 안전 / 데이터 / destructive. 최우선 처리.
2. **P1** — 라우팅 / 권한 / 부수 효과 / 산출 신뢰성. 다음 우선.
3. **P2** — 품질·반복 비용. 사용자 위임 가능 (기본 적용 권장).
4. **P3** — 보고만 하고 적용은 선택으로 둔다.

각 finding 의 `Recommendation` 필드를 따른다. evidence 가 약하거나 `AMBIGUITY` 면 사용자 확인 후 진행.

### 4c. Re-run gate

수정 후 §3 재실행. 라운드 카운트 증가.

- 3 라운드까지: 평소 흐름.
- 3 라운드 초과: §0 의 *책임* 정의로 복귀 — 책임 모호가 진짜 원인. 또는 자원 타입이 잘못 잡혔는지 (skill 이 아닌 agent/hook/CLAUDE.md) 재검토.
- 5 라운드 초과: 사용자에게 보고하고 NEEDS_REVIEW 로 종료.

### 4d. GUIDE_GAP 처리

자산이 좋은데 가이드가 잡지 못해 false positive 가 나오면 (`GUIDE_GAP`): 자산은 수정하지 *말고* 사용자에게 보고. 가이드 보완은 본 스킬 범위 밖 (다음 v3 사이클의 입력).

## 5. Output to caller

```
created/updated: <relative path>
scope: user | project | plugin
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <path to *.GAP.md>
guide_gaps: <count if any — informational, not blocker>
follow-ups: <Suggested Changes deferred to user — if any>
```

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 `blocked: needs revision` 으로 prefix.

세부 finding 본문을 응답에 풀어 쓰지 말고 GAP report 경로로 안내 — main context 절약. 사용자가 원하면 직접 읽는다.

## 6. Terminology and tone pass

§5 응답을 caller 에게 보내기 *직전에* 실행한다. 실행 순서는 §4 (수정 반영) → §6 (용어·톤 정리) → §5 (응답 송신) 이다.

작성한 SKILL.md 전체를 한 번 더 읽고 용어·톤을 통일한다. 본 pass 는 *표현만* 정리하며 의미 변경이나 새 finding 도입은 §3 GAP 분석에서 처리할 일이다.

### 체크 항목

- **개념 일관성** — 같은 개념을 같은 표현으로 사용한다. 동의어 혼용 (예: "GAP analysis" / "GAP 분석" / "재분석" 혼재) 은 호출자 혼선을 만든다.
- **영어 용어 최소화** — 원문 유지가 필요한 경우에만 영어를 남긴다:
  - tool 이름 (`Read`, `Edit`, `Agent`)
  - file 이름·path (`SKILL.md`, `CONSTITUTION.md`)
  - frontmatter 필드 (`name`, `description`, `tools`)
  - enum 값 (`PASS`, `REVISE_ASSET`, `P0`)
  - 권위 문서·본 스킬이 정의한 도메인 용어 (`output contract`, `GAP report`, `pressure scenario`)

  일반 동사·서술어·연결어는 한국어로 통일한다 (예: `redirect` → 전환, `confirm` → 확인, `prefix` → 앞에 붙임, `procedural` → 절차).
- **구어적 표현 제거** — "떨어뜨리다", "부서지다", "잡지 못함" 같은 구어체는 spec 톤의 평서체로 정리한다 (예: "저장하다", "실패하다", "적절히 평가하지 못함").
- **과도한 축약 풀이** — 단어 1-2 개로 묶은 표현은 의미가 명확해지도록 풀어 쓴다 (예: "추정 다수" → "근거가 부족하거나 추정이 많은 경우").
- **불필요하게 강한 표현 완화** — heuristic 을 hard rule 로 표기하지 않는다. CONSTITUTION §3.8 의 원칙대로 강한 표현은 *실제 gate* 에 한정 (효과 차단, 승인 게이트, 안전).
- **긴 조건 종속문 분리** — 한 문장에 조건·이유·예외가 모두 들어가면 2–3 문장으로 나눈다. 한 문장 = 한 주장이 원칙.

### 산출

본 pass 가 완료되면 SKILL.md 의 표현이 통일된다. 자산 의미는 §4 종료 시점과 동일해야 한다 — 의미가 바뀌었다면 §3 GAP 분석으로 되돌아간다.

본 pass 자체는 응답에 별도 보고하지 않는다. §5 응답의 `gap` 필드가 PASS / PASS_WITH_NOTES 인 한 표현 정리는 *전제 조건* 으로 처리한다.

## Mini example

**요청**: "session-events.db 의 hook 호출 로그를 일자별 집계해 markdown 으로 출력하는 스킬."

- **§0–§2 Draft** — scope: user, path `~/.claude/skills/hook-activity-report/`. Phase 1 db 확인 / Phase 2 sqlite3 집계 / Phase 3 markdown 렌더. description = trigger + Do NOT (단일 도구 흔적 조회는 sqlite3 직접 사용).
- **§3 GAP 분석 round 1 (위임)** — `REVISE_ASSET`. P1: output_contract 부재. P2: near-miss 부재.
- **§4 수정** — Output Contract 섹션 + no-op (`BLOCKED: db not found`) 추가. description 에 negative case 추가.
- **§3 GAP 재분석 round 2** — `PASS_WITH_NOTES` (P3 만 잔류). 종료.
- **§5 응답**: `created: …/SKILL.md · scope: user · gap: PASS_WITH_NOTES (rounds: 2) · findings: P0=0, P1=0, P2=0, P3=1 · gap_report: …/gaps/skill-hook-activity-report.GAP.md`

## When the loop stalls

3 라운드 후에도 PASS 가 안 나오면 GAP-FORMAT §16 의 다른 결정을 고려한다.

1. **책임 모호** → `SPLIT_ASSET`. §0 으로 복귀해 단일 책임을 재정의한다.
2. **자원 타입 오류** → 전환. skill 이 아니라 agent / hook / CLAUDE.md 가 적합한 경우.
3. **GUIDE_GAP** → 가이드가 좋은 자산을 적절히 평가하지 못함. 사용자에게 보고하고 자산은 통과시킨다. 가이드 보완은 별도 작업.
4. **NEEDS_REVIEW** → 근거가 부족하거나 추정이 많은 경우. 사용자 입력 후 재개.

보조 도구로 RED-GREEN-REFACTOR — pressure scenario (실패 유도 입력) 로 자산이 실패하는 경우를 찾는다. 자세한 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/skill-creator/references/red-green-refactor.md` (writing-skills 의 관련 섹션을 self-contained 형태로 가져옴).

## Description optimization (선택)

GAP 분석은 *영향 기준* 평가다. description 의 *트리거 정확도* 는 별도 측정이 필요한 경우가 있다 — 인접 스킬과 키워드 충돌 의심 시. 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/skill-creator/references/trigger-eval.md` (writing-skills CSO 섹션을 self-contained 형태로 가져옴). 비용·시간 소요 — 사용자 동의 후.

## Limits

- **Capability surface** — 본 스킬은 본문 절차에서 `Read` (권위 문서 로드), `Write` / `Edit` (대상 SKILL.md 및 workspace GAP report), `Bash` (`mkdir` · `ls` collision check), `Agent` (§3b GAP 분석 위임 — `general-purpose` 1건) 를 사용한다. Web/MCP/외부 모델·네트워크 IO 미사용. capability 는 frontmatter `tools:` 가 아닌 본문 §2 시점 A/B + §4b gate 로 통제된다.
- 파일 수정은 본 스킬이 직접 한다 (procedural).
- 다른 에이전트 자동 디스패치는 §3b 의 GAP 분석 위임 1건만 — 그 외 orchestration 은 호출자 책임.
- GAP 리포트는 자산과 동급 산출물 — 디버깅·재현·다음 사이클 입력 위해 보존.
- 가이드 자체 수정 (`REVISE_GUIDE` / Constitution Review) 은 본 스킬 범위 밖.
