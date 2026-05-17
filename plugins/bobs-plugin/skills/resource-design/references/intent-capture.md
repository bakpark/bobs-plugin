# Intent Capture and Decision Procedure

> 본 문서는 `resource-design` skill 의 reference. (deprecated) `agent-skill-designer.md` §0-§3 절차를 흡수한 *resource-design 고유* content. AGENT-GUIDE / 다른 GUIDE 의 모양 규칙은 `decision-rules.md` index 를 통해 GUIDE 직접 참조. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).

resource-design 본 스킬이 사용자 요청을 받았을 때 따라야 할 절차다. SKILL.md Phase 1-3 의 *세부 절차* 를 정의한다.

---

## 0. 트리거 판단

진행 조건:

1. 사용자가 command / skill / agent / hook / runtime setting / plugin / routing 설계 또는 리팩터 방향을 요청.
2. 호출자가 draft 자원의 역할 분리 / frontmatter / 호출 contract / migration order 설계를 위임.
3. 감사 결과를 바탕으로 개선 설계안이 필요.

범위 밖 라벨 (escape hatch):

| 라벨 | 조건 | 라우팅 |
|---|---|---|
| `NOT_DESIGN_REQUEST` | 단순 정적 규칙 감사 (P0/P1/P2 + rule ID) | `agent-skill-auditor` |
| `OUT_OF_SCOPE_DOCS` | docs-tree (AGENTS.md / CLAUDE.md / routing 표) 설계 | `context-map-architecture` |
| `OUT_OF_SCOPE_EVAL` | 평가 loop / GAP report 인프라 설계 | `evaluation-loop-design` |
| `OUT_OF_SCOPE_CODE_REVIEW` | 코드 / PR 리뷰 | 기존 review 자원 |
| `OUT_OF_SCOPE_IMPLEMENTATION` | 실제 파일 수정 (resource 본문 작성) | `skill-creator` / `agent-creator` / `hook-creator` |
| `NEEDS_INPUT` | 대상 경로 / 목표 의도 / 설계 대상 타입이 모두 없음 | 사용자에게 질문 |

라우팅 분리 한 줄 요약:

- "위반 / 점수 / metrics / rule ID / 정적 감사" → `agent-skill-auditor`.
- "무엇을 만들지 / 어떻게 나눌지 / 어떤 contract / 어떤 순서로 이전" → `resource-design`.
- "실제 본문 작성 · 수정" → 해당 creator skill (`skill-creator` / `agent-creator` / `hook-creator`).
- "설계 기준 확인" → `decision-rules.md` index 를 통한 GUIDE 직접 참조.

---

## 1. 입력 추출

호출 prompt 에서 가능한 만큼 추출:

```
objective: <사용자 목표>
target_paths: <optional files or dirs>
resource_types: command | skill | agent | hook | runtime_settings | plugin | mixed | unknown
constraints: <breaking-change 금지, read-only, user-only 등>
existing_flow: <있으면 phase / review / routing 흐름>
```

대상 경로가 있으면 `Read` / `Grep` / `Glob` 로 현재 frontmatter / description / tools / model / 호출 contract 확인.

전체 프로젝트 또는 plugin 설계라면 다음만 inspect:

- `<repo>/.claude/commands/*.md` 와 `plugins/*/commands/*.md`
- `<repo>/.claude/agents/*.md` 와 `plugins/*/agents/*.md`
- `<repo>/.claude/skills/*/SKILL.md` 와 `plugins/*/skills/*/SKILL.md`
- `<repo>/.claude/settings.json` 와 `plugins/*/.claude-plugin/plugin.json`
- MCP 설정 (project scope)

---

## 2. 설계 기준 로드

먼저 `decision-rules.md` index 를 보고, 결정에 필요한 GUIDE § 만 직접 읽는다. references 본문 안에 GUIDE 규칙을 재생산하지 않음 — drift 위험과 maintenance cost 가 normative source 직접 참조로 사라진다.

읽는 순서:

1. `decision-rules.md` — 5-asset taxonomy + 선택 순서 + 주제 → GUIDE 위치.
2. 결정한 타입의 GUIDE 본문 — frontmatter / body / anti-patterns 등 필요한 § 만.
3. `design-output-contract.md` — Phase 3 산출 형식.

---

## 3. 결정 절차

1. 사용자 의도를 한 문장으로 재정의.
2. 자원 타입 결정 — CONSTITUTION §4 선택 순서 적용:
   1. 프로젝트 고유 정보 → `CLAUDE.md`.
   2. 권한 / 모델 / MCP / memory / budget / tool loading 정책 → runtime settings.
   3. 사용자가 명시 호출하는 workflow entrypoint → command.
   4. 매 이벤트마다 자동 보장 → hook.
   5. 별도 컨텍스트 / 병렬 / specialist role → agent.
   6. 자동 활성화되는 외부 인프라 · 도메인 능력 / reference bundle → skill.
3. 중복되는 기존 자원이 있으면 새 자원보다 *수정 / 압축 / 라우팅 개선* 우선 (CONSTITUTION §3.10 Overlap Must Be Intentional).
4. 부수 효과가 있으면 explicit command invocation / user-only skill / 제한 tools / runtime permission / confirmation gate 설계 (CONSTITUTION §3.3 Effects Require Gates).
5. 호출 contract 명시: 입력 / 출력 / 실패 모드 / owner / cleanup 책임.
6. 변경 순서를 낮은 위험부터 배열: documentation / frontmatter → contract 명세 → routing → destructive / automation.

---

## 부수 효과 금지 (resource-design 본 스킬에 적용)

본 스킬은 spec markdown 만 출력. 다음은 금지:

- 파일 수정 (`Edit` / `Write` 금지 — workspace 디렉토리 mkdir 만 허용).
- git commit / push.
- 다른 에이전트 자동 디스패치.
- 외부 모델 / GitHub API / 네트워크 호출.
- "일단 새 자원 추가" 를 기본값으로 삼지 않음. 기존 자원 수정이 더 단순하면 그렇게 권고.
