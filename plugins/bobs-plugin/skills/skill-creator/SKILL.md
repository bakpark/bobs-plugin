---
name: skill-creator
description: |-
  Use when creating, scaffolding, editing, or verifying a Claude Code skill (`SKILL.md` under `skills/<name>/`). Triggers on "create a skill", "스킬 만들어줘", "skill 작성·개선", "/skill-name 만들어줘", "draft a skill for X" — including when the user has not yet chosen a name or scope. Do NOT use for writing subagents (`agent-creator`), agent-vs-skill / merge / migration-order decisions (`resource-design`), static rule audit of an existing skill (`agent-skill-auditor`), or PR/code edits.
---

# skill-creator

Claude Code 스킬(`SKILL.md`) 작성·개선을 위한 절차 메타 스킬. agent-skill-best-practices 기준 문서를 단계별로 읽고, draft → GAP 분석 → 수정 → GAP 재분석을 PASS / PASS_WITH_NOTES 까지 반복한다.

관련 자산: `writing-skills`(discipline), `agent-creator`(서브에이전트), `resource-design`(타입·책임 결정), `agent-skill-auditor`(정적 rule 감사).

## Reference Loading Schedule

각 단계에서 *읽어야 할* 권위 문서 — 모든 경로는 `${CLAUDE_PLUGIN_ROOT}/references/` 아래.

**이식성 주의**:

- *배포 전제*: 본 스킬은 `bobs-plugin` references 와 함께 배포될 때 유효하다.
- *Fallback 경로*: `${CLAUDE_PLUGIN_ROOT}` 미설정 환경에서는 현재 SKILL.md 기준 `../../references/` 를 사용한다 (plugin 디렉토리 구조 가정).
- *실패 시*: 두 경로 모두 접근 불가하면 사용자에게 참조 문서 미존재를 보고하고 종료한다. 권위 문서 없이는 GAP 분석 loop 가 작동하지 않는다.

| Phase | 읽는 문서 | 용도 |
|---|---|---|
| §0 Capture intent | `CONSTITUTION.md` §3 (공통 원칙) | 의도·책임·escape hatch 판단 기준 |
| §1 Choose scope | (없음 — 본 스킬 내장 결정 트리) | — |
| §2 Draft | `SKILL-GUIDE.md` §1–§13 (역할·category·Skill vs Command boundary·frontmatter·body·effects·output·anti-patterns) | 스켈레톤 (discipline 요약은 §2 본문에 내재화) |
| §3 GAP 분석 | `GAP-FORMAT.md` (전체) + `GAP-ANALYSIS-PROMPT.md` (위임 프롬프트 verbatim) | 평가 리포트 형식 + 위임 protocol |
| §4 GAP 피드백 반영 | `GAP-FORMAT.md` §13 Findings + §15 Suggested Changes + §16 Final Decision | finding 별 수정 지침 |
| §5 Output to caller | (없음) | — |
| §6 Terminology and tone pass | (작성한 SKILL.md 자체) + CONSTITUTION §3.8 (강한 표현은 실제 gate 에) | 응답 직전 표현 통일 |

본 스킬은 규칙을 본문에 복사하지 않는다 — *언제 어느 문서를 읽고 어떤 산출물을 어디에 저장할지* 만 정의한다.

## When NOT to use

- 서브에이전트(`.md` under `agents/`) 작성 → `agent-creator`.
- 자원 타입(command / skill / agent / hook / runtime setting) 결정 → `resource-design`. 본 스킬은 *이미 스킬로 정한 뒤* 시작.
- 사용자 명시 호출 workflow, 문서 링크/context 주입 라우터 작성 → `resource-design` 의 command 트랙 또는 `COMMAND-GUIDE.md`.
- 기존 스킬의 정적 rule 감사 (P0/P1/P2 + rule ID) → `agent-skill-auditor`. 본 스킬은 §3 에서 GAP 분석을 사용 (영향 기준 평가, rule ID 기반 채점이 아님).
- 검증 인프라 (task log / golden-set / evaluation loop / `docs/agent/roles.md` body) → `evaluation-loop-design`.
- 외부 모델 의견 / PR 리뷰 → `codex-reviewer` / `pr-review-toolkit`.

## 0. Capture intent

**먼저 읽는다**:

```bash
Read ${CLAUDE_PLUGIN_ROOT}/references/CONSTITUTION.md
```

§3 의 공통 원칙을 체크리스트로 사용해 다음 6가지를 확정한다. 대화 맥락에 있으면 추출하고, 없으면 한 번에 묶어서 묻는다.

핵심 원칙: Activation / Scope / Effects Gate / Output Contract / Capability Surface / Reusable vs Local Memory / Progressive Disclosure / Strong Language / Verification / Overlap / Command Boundary / Runtime Policy / Freshness.

| # | 질문 | 매핑되는 헌법 §3 원칙 |
|---|---|---|
| 1 | 자동 활성화할 외부 인프라·API·provider·도메인 capability 는 무엇인가? (한 문장 책임) | §3.5 Capability Surface · §3.6 Reusable · §3.11 Command Boundary |
| 2 | 모델이 언제 자동 활성화해야 하나? (트리거 1–3개) | §3.1 Activation Explicit |
| 3 | 언제 활성화되면 안 되나? (negative case ≥1) | §3.1 · §3.10 Overlap Intentional |
| 4 | 호출자는 산출물로 무엇을 하는가? | §3.4 Output Contract |
| 5 | 부수 효과 있나? (파일 수정 / commit / send / deploy) | §3.3 Effects Require Gates |
| 6 | 어디에 두나? user / project / plugin | §3.6 Reusable vs Local |

### In-flight escape hatches (헌법 §3 위반 패턴별 전환)

의도 캡처 중 자원 타입이 달라 보이면 즉시 다른 자원으로 전환한다.

| 신호 | 위반 | 전환 대상 |
|---|---|---|
| 사용자가 직접 시작하는 workflow / 사용자 질문 / plan gate / 단계 진행 | §3.11 — workflow entrypoint 는 command | `resource-design` (command 트랙) |
| docs/specs/decisions/context-map 링크를 모아 하위 자산에 주입하는 라우터 | §3.11 — context router 는 command | `COMMAND-GUIDE.md` 또는 `context-map` |
| 별도 context / tool 권한 / 별도 model 이 필요한 specialist 역할 | §3.5 — 스킬은 메인 context 에 로드됨 | `agent-creator` |
| 매 이벤트마다 결정론 보장 필요 | §3.1 — 스킬은 명시 activation, hook 은 결정론 | `resource-design` (hook 트랙) |
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
2. frontmatter 초안 — *skill 지원 필드만* 사용 (`name`, `description`, 필요 시 `tools` / `disable-model-invocation` / 예외적 `user-invocable` / `allowed-tools`). `model` 은 agent 전용 필드이므로 skill 에 두지 않는다. 사용자가 직접 시작하는 workflow 는 `user-invocable` skill 이 아니라 command 로 분리한다.
3. 본문 골격 (Capability Procedure + Output Contract 형태)
4. workspace 디렉토리 경로 (§3a 에서 생성될 위치)

**시점 B — §4 수정 반영 전 (round 2+)**: 적용할 finding 의 short title 과 *변경 요약* (어떤 섹션의 어떤 부분이 어떻게 바뀌는지) 을 사용자에게 제시한다.

각 시점에서 사용자가 "진행" / "go" / "proceed" 같은 명시적 신호를 줄 때만 파일을 쓰거나 수정한다.

사용자가 "묻지 말고 진행" 을 명시한 경우에만 확인 없이 진행한다. 첫 파일 쓰기 시 가정은 최종 응답의 `assumptions:` 필드 또는 SKILL.md 본문 첫 섹션 (`## Assumptions`) 에 기록한다. SKILL.md 첫 줄은 `---` frontmatter 구분자여야 하므로 가정 텍스트를 그 자리에 두지 않는다. 수정 반영 시 가정은 GAP report 의 `Acceptable Deviations` 에 기록한다.

**적용할 기준** — SKILL-GUIDE §3 (Skill vs Command Boundary), §4 (Frontmatter), §5 (Description), §6 (Body — `# Skill Title` / `## When to Use` / `## Capability Procedure` / `## Output Contract` / `## Common Failures` / `## Gotchas` / `## Setup / Config` / `## References`), §7 (Effects And Gates), §8 (Progressive Disclosure), §9 (Output Contract), §13 (Anti-Patterns) 을 *표준 골격* 으로 삼는다. 자산 목적에 맞게 필요한 섹션만 조정한다 — SKILL-GUIDE 는 형식보다 기능을 중시하므로 모든 섹션 명을 그대로 강제하지 않는다.

**작성 중 자기검열** — 다음 discipline 을 작성 도중 점검 기준으로 사용한다 (writing-skills 의 핵심 개념을 본 스킬 본문에 내재화한 요약 — 추가 깊이가 필요하면 writing-skills SKILL.md 를 직접 참고):

- **CSO (Claude Search Optimization)** — description 은 activation signal 만 담는다. 본문 절차를 description 에 요약하면 호출자가 본문을 읽지 않고 description 만 따라 단축 실행한다 (Description-as-runbook 안티패턴).
- **Iron Law** — baseline 실패 없이 작성된 스킬은 *어떤 실패를 막는지* 알 수 없다. 작성 전 baseline prompt 로 무엇이 실패하는지 관찰한다.
- **안티패턴 (SKILL-GUIDE §13)** — Description-as-runbook / Narrative skill / Unscoped capability / Must-bombing / Reference dump / Hidden mutation / Project convention leak / No output contract / Dead skill / User workflow hidden as skill. 작성 후 §13 표로 자기 검열.

표준 골격을 적용한 SKILL.md 가 1차 draft 다. 새 골격을 발명하기 전, 기존 골격이 자산 목적에 맞지 않는 이유를 먼저 확인한다.

핵심 원칙 요약 (가이드 읽은 뒤 적용):
- description: trigger only, ≤500 chars 권고
- name: kebab-case 동사형 명사구
- 부수 효과: `disable-model-invocation: true` 또는 명시 호출 gate. 단, 사용자가 시작하는 workflow 자체는 command 로 분리
- output contract: 호출자가 파싱 가능한 구조 + no-op / NEEDS_INPUT 케이스 명시
- 본문 길이: SKILL-GUIDE §11 의 heuristic 으로 ≤ 500 lines 가 검토 신호. 초과 시 `references/` 분리를 검토 (hard limit 아님 — 메타 스킬은 정당화 가능)
- 여러 언어로 분산하기보다 한 도메인을 깊게 작성한다

## 3. GAP 분석 (creator-gap-eval 호출)

본 절차는 `creator-gap-eval` skill 이 통합 처리한다 (Step 4b 추출 결과). §0-§2 에서 결정된 다음 값으로 호출 — workspace 는 creator-gap-eval 이 자체 결정 (plugin 단위 통합 — `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/`).

```yaml
resource_type: skill
draft_path:
  - <SKILL_PATH>/SKILL.md        # §2 에서 결정된 절대 경로
asset_name: <name>               # §1 에서 결정된 kebab-case. report = skill-<name>.GAP.md
delegation_mode: delegate        # 기본 위임 (비용 절감 필요 시 inline)
reentry_count: 0                 # 본 creator 가 호출하는 경로는 항상 0 (creator-gap-eval 자기 자신 분석 아님)
round_count: 0                   # REVISE_ASSET 재호출 시 +1 (5 초과 시 NEEDS_REVIEW)
```

호출 (Claude Code 환경): `Skill` tool 로 `creator-gap-eval` 활성화. 반환 yaml 의 `final_decision` 으로 분기 — 상세는 §4 참조. `report_path` 는 통합 workspace 의 절대 경로 반환.

## 4. Self-feedback refine — Final Decision 처리

`creator-gap-eval` 의 반환 yaml 을 받아 다음 분기:

- `PASS` / `PASS_WITH_NOTES` → §5 (Output to caller) 로 진행
- `REVISE_GUIDE` → 사용자 보고 후 §5 (자산은 일단 통과)
- `REVISE_ASSET` → P0/P1/P2 적용 (§2 시점 B gate 거침) 후 `creator-gap-eval` 재호출 (`round_count + 1`)
- `SPLIT_ASSET` → §0 으로 복귀, 책임 분리 재설계
- `DEPRECATE_ASSET` → 사용자 confirm 후 폐기 권고
- `NEEDS_REVIEW` → 사용자 입력 받기 (creator-gap-eval 의 reentry_count 한도 또는 round_count 한도 초과 포함)

라운드 5 초과 시 `creator-gap-eval` 이 `NEEDS_REVIEW` 반환 (round_count 한도). Finding 적용 / Re-run gate / GUIDE_GAP 의 상세 절차는 `creator-gap-eval/SKILL.md` Phase 7-9 와 `references/resource-type-matrix.md` 의 자원별 분기 행 참조.

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

**요청**: "Open-Meteo API 응답을 가져와 weather card command 가 쓸 canonical JSON 으로 정규화하는 스킬."

- **§0–§2 Draft** — scope: plugin, path `plugins/weather/skills/weather-fetcher/`. Capability Procedure = 입력 location/unit 검증 → Open-Meteo fetch → canonical JSON 정규화. description = 자동 활성화 조건 + Do NOT (weather workflow orchestration 은 command 가 담당).
- **§3 GAP 분석 round 1 (위임)** — `REVISE_ASSET`. P1: output_contract 부재. P2: near-miss 부재.
- **§4 수정** — Output Contract 섹션 + no-op (`BLOCKED: location missing`, `BLOCKED: provider unavailable`) 추가. description 에 negative case 추가.
- **§3 GAP 재분석 round 2** — `PASS_WITH_NOTES` (P3 만 잔류). 종료.
- **§5 응답**: `created: …/SKILL.md · scope: plugin · gap: PASS_WITH_NOTES (rounds: 2) · findings: P0=0, P1=0, P2=0, P3=1 · gap_report: …/gaps/skill-weather-fetcher.GAP.md`

## When the loop stalls

3 라운드 후에도 PASS 가 안 나오면 GAP-FORMAT §16 의 다른 결정을 고려한다.

1. **책임 모호** → `SPLIT_ASSET`. §0 으로 복귀해 단일 책임을 재정의한다.
2. **자원 타입 오류** → 전환. skill 이 아니라 command / agent / hook / runtime settings / CLAUDE.md 가 적합한 경우.
3. **GUIDE_GAP** → 가이드가 좋은 자산을 적절히 평가하지 못함. 사용자에게 보고하고 자산은 통과시킨다. 가이드 보완은 별도 작업.
4. **NEEDS_REVIEW** → 근거가 부족하거나 추정이 많은 경우. 사용자 입력 후 재개.

보조 도구로 RED-GREEN-REFACTOR — pressure scenario (실패 유도 입력) 로 자산이 실패하는 경우를 찾는다. 자세한 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/skill-creator/references/red-green-refactor.md` (writing-skills 의 관련 섹션을 self-contained 형태로 가져옴).

## Description optimization (선택)

GAP 분석은 *영향 기준* 평가다. description 의 *트리거 정확도* 는 별도 측정이 필요한 경우가 있다 — 인접 스킬과 키워드 충돌 의심 시. 절차는 `${CLAUDE_PLUGIN_ROOT}/skills/skill-creator/references/trigger-eval.md` (writing-skills CSO 섹션을 self-contained 형태로 가져옴). 비용·시간 소요 — 사용자 동의 후.

## Limits

- **Capability surface** — 본 스킬은 본문 절차에서 `Read` (권위 문서 로드), `Write` / `Edit` (대상 SKILL.md 및 workspace GAP report), `Bash` (`mkdir` · `ls` collision check), `Agent` (§3b GAP 분석 위임 — `general-purpose` 1건) 를 사용한다. Web/MCP/외부 모델·네트워크 IO 미사용. capability 는 frontmatter `tools:` 가 아닌 본문 §2 시점 A/B + §4b gate 로 통제된다.
- 파일 수정은 본 스킬이 직접 한다 (capability-authoring procedure).
- 다른 에이전트 자동 디스패치는 §3b 의 GAP 분석 위임 1건만 — 그 외 orchestration 은 호출자 책임.
- GAP 리포트는 자산과 동급 산출물 — 디버깅·재현·다음 사이클 입력 위해 보존.
- 가이드 자체 수정 (`REVISE_GUIDE` / Constitution Review) 은 본 스킬 범위 밖.
