# Design Rule Index

> 본 문서는 `resource-design` skill 의 reference. v2.1 GUIDE (개정 2026-05-17) 의 **index map** — 규칙 본문을 재생산하지 않고, 어느 주제가 어느 GUIDE 의 어느 § 에 있는지 라우팅만 한다. 소유: 동일 저장소 owner (MIT — 별도 attribution 불요).
>
> Normative source: `${CLAUDE_PLUGIN_ROOT}/references/{CONSTITUTION,SKILL-GUIDE,AGENT-GUIDE,COMMAND-GUIDE,HOOK-GUIDE,RUNTIME-GUIDE,GAP-FORMAT}.md`. 규칙 본문은 항상 GUIDE 가 권위.

규칙 ID prefix:

- S- → `SKILL-GUIDE.md`
- A- → `AGENT-GUIDE.md`
- CMD- → `COMMAND-GUIDE.md`
- H- → `HOOK-GUIDE.md`
- R- → `RUNTIME-GUIDE.md`
- 공통 원칙 → `CONSTITUTION.md`

---

## 5-Asset Taxonomy + Plugin Bundling (CONSTITUTION §1 + §4)

CONSTITUTION §1 의 *core 5 자산* + plugin (배포 묶음). plugin 은 별도 GUIDE 없음 — 자산 분류라기보다 install / share 단위.

| 자산 | 역할 | 선택 가이드 |
|---|---|---|
| skill | 필요할 때 로드되는 판단 절차 / 방법론 | `SKILL-GUIDE.md` |
| agent | 별도 컨텍스트 specialist 역할 | `AGENT-GUIDE.md` |
| command | 사용자 명시 호출 workflow entrypoint + 얕은 orchestration | `COMMAND-GUIDE.md` |
| hook | runtime 이벤트 결정론적 guardrail | `HOOK-GUIDE.md` |
| runtime settings | 권한 / MCP / memory / model / budget / context loading 정책 | `RUNTIME-GUIDE.md` |
| plugin | 위 자산을 install / share 단위로 묶음 | CONSTITUTION §4 — 자산 분류가 아닌 배포 분류 |

선택 순서 (CONSTITUTION §4):

1. 프로젝트 고유 정보 → `CLAUDE.md` (자원 아님).
2. 권한 / 모델 / MCP / memory / budget / tool loading 정책 → runtime settings.
3. 사용자가 명시 호출하는 workflow entrypoint → command.
4. 매 이벤트마다 자동 보장 → hook.
5. 별도 컨텍스트 / 병렬 / specialist role → agent.
6. 자동 활성화되는 외부 인프라 · 도메인 능력 / reference bundle → skill.
7. 어디에도 해당 없음 → 새 자원을 만들지 않음.

---

## 주제 → GUIDE 위치

| 주제 | 위치 |
|---|---|
| Activation Explicit | CONSTITUTION §3.1 |
| Scope Controls Quality | CONSTITUTION §3.2 |
| Effects Require Gates | CONSTITUTION §3.3 |
| Output Is A Contract | CONSTITUTION §3.4 |
| Capability Surface | CONSTITUTION §3.5 |
| Reusable Knowledge vs Local Memory | CONSTITUTION §3.6 |
| Progressive Disclosure | CONSTITUTION §3.7 |
| Context Is A Managed Resource | CONSTITUTION §3.7.1 |
| Strong Language Belongs To Real Gates | CONSTITUTION §3.8 |
| Behavior Must Be Verifiable | CONSTITUTION §3.9 |
| Overlap Must Be Intentional | CONSTITUTION §3.10 |
| User-Initiated Workflows Need Commands | CONSTITUTION §3.11 |
| Runtime Policy Is Shared Infrastructure | CONSTITUTION §3.12 |
| Freshness Requires Evidence | CONSTITUTION §3.13 |
| Prompt Is Not A Harness Boundary | CONSTITUTION §2.1 |
| Skill Categories (9 유형) | SKILL-GUIDE §2 |
| Skill vs Command Boundary | SKILL-GUIDE §3 |
| Skill Frontmatter / Body / Effects / Disclosure | SKILL-GUIDE §4-§8 |
| Skill Verification (trigger eval, pressure scenario) | SKILL-GUIDE §10 |
| Skill Anti-Patterns | SKILL-GUIDE §13 |
| Agent Frontmatter / Body / Scope | AGENT-GUIDE §2-§5 |
| Agent Capability Surface (tools / model / runtime fields) | AGENT-GUIDE §6 |
| Agent Output Contract / Quality Gate | AGENT-GUIDE §7-§8 |
| Agent Memory & CLAUDE.md 관계 | AGENT-GUIDE §9 |
| Agent Anti-Patterns | AGENT-GUIDE §13 |
| Command vs Skill / Agent / Hook 경계 | COMMAND-GUIDE §2 |
| Command Frontmatter (`argument-hint`, `allowed-tools`) | COMMAND-GUIDE §3 |
| Command Body / Inputs / Delegation Contract | COMMAND-GUIDE §4 |
| Command Orchestration Boundary (얕음) | COMMAND-GUIDE §5 |
| Command Effects / Gates / Context Injection | COMMAND-GUIDE §6, §8 |
| Command Anti-Patterns | COMMAND-GUIDE §11 |
| Hook Registration / Placement | HOOK-GUIDE §3 |
| Hook Event 선택 | HOOK-GUIDE §4 |
| Hook Matcher / Input Handling / Exit Behavior | HOOK-GUIDE §5-§7 |
| Hook Security / Performance | HOOK-GUIDE §8-§9 |
| Hook Common Patterns (formatter / blocker / routing / on-demand / measurement) | HOOK-GUIDE §10 |
| Hook Anti-Patterns | HOOK-GUIDE §13 |
| Runtime Permission Policy | RUNTIME-GUIDE §2 |
| Runtime Settings Scope (user / project / local / managed) | RUNTIME-GUIDE §3 |
| Runtime Memory & State | RUNTIME-GUIDE §4 |
| Runtime MCP / Tool Loading | RUNTIME-GUIDE §5 |
| Runtime Model / Effort / Budget | RUNTIME-GUIDE §6 |
| Runtime Session / Context Lifecycle | RUNTIME-GUIDE §7 |
| Runtime Auto Mode / Background Work | RUNTIME-GUIDE §8 |
| Runtime Version-Sensitive Claims | RUNTIME-GUIDE §9 |
| Runtime Anti-Patterns | RUNTIME-GUIDE §11 |
| GAP Finding 유형 (ASSET_GAP / GUIDE_GAP / AMBIGUITY / INTENTIONAL_EXCEPTION / NO_GAP) | GAP-FORMAT §6 |
| GAP Severity (P0-P3) | GAP-FORMAT §7 |
| GAP Report 구조 | GAP-FORMAT §9 |

---

상세 severity / 안티패턴은 위 `주제 → GUIDE 위치` 표의 `GAP Severity (P0-P3) | GAP-FORMAT §7` / 각 GUIDE `Anti-Patterns` 행 참조. 본 문서는 index 만 — 본문 재생산 금지 (drift 회피).
