# Resource Type Matrix (creator-gap-eval)

`creator-gap-eval` 의 `args.resource_type` (`skill | agent | hook`) 에 따라 GAP 분석 절차의 분기 항목을 lookup 하는 표. 본 파일은 *분기 표 only* — SKILL.md 본문의 phase 절차 재생산 없음.

**출처**: 본 plan + 3 creator (skill-creator / agent-creator / hook-creator) §3-§4 본문 통합. MIT in-house, 출처 표기 불요 (동일 plugin).

## 1. Matrix 표 (14 분기 행 × 3 자원)

| # | matrix 키 | skill | agent | hook |
|---|---|---|---|---|
| 1 | `snapshot_section` | GAP-FORMAT §11.1 Skill Snapshot | GAP-FORMAT §11.2 Agent Snapshot | GAP-FORMAT §11.4 Hook Snapshot |
| 2 | `checks_section` | GAP-FORMAT §12.1 Skill Checks | GAP-FORMAT §12.2 Agent Checks (10 축) | GAP-FORMAT §12.4 Hook Checks |
| 3 | `guide_name` | `SKILL-GUIDE` | `AGENT-GUIDE` | `HOOK-GUIDE` |
| 4 | `delegation_check_axis` | `Skill` | `Agent` | `Hook` |
| 5 | `target_paths` (list 길이) | 1 파일 (`SKILL.md`) | 1 파일 (agent `.md`) | 2 파일 (script + registration 한 쌍) |
| 6 | `workspace_name_pattern` (파일명 prefix) | `skill-` | `agent-` (path 의 `/` → `-` 치환) | `hook-` |
| 7 | `split_asset_signals` | (자원-특화 신호 없음 — 일반 SPLIT_ASSET 문구) | persona drift / 분석+수정+commit 다 함 / 한 본문 안에 두 역할 | Mixed responsibility — formatter / blocker / logger 분할 |
| 8 | `severity_examples_p0` | (일반) | 승인 없는 destructive Bash, secret 노출, 자동 commit/push | destructive Bash, 숨은 외부 송신 (curl/wget/nc), secret 송신 |
| 9 | `severity_examples_p1` | (일반) | advisory 역할 + Write/Edit/Bash, output contract 부재, scope 부재, sibling 명시 없는 negative case | matcher 잘못 / 차단 vs advisory 충돌, input handling 결함, 광범위 path |
| 10 | `severity_examples_p2` | (일반) | description bloat, tool 미명시 (AMBIGUITY), persona 길이, low-confidence spam 위험 | matcher 가 약간 넓음, state 산재 |
| 11 | `reroute_candidates` (자원 타입 재검토 후보) | command / agent / hook / runtime / CLAUDE.md | command / skill / hook / runtime / CLAUDE.md | skill / agent / CLAUDE.md |
| 12 | `delegation_target_wording` (envelope `<TARGET_SECTION>`) | "새 스킬 1개: `<SKILL_PATH>/SKILL.md`" | "새 에이전트 1개: `<AGENT_PATH>`" | "새 훅 1건 (script + registration 한 쌍):\n    `<SCRIPT_PATH>`\n    `<REGISTRATION_PATH>`" |
| 13 | `guide_gap_candidates` | (없음) | AGENT-GUIDE §10 sibling 명시 패턴, §6.2 Model inherit 정당화 패턴 | (없음) |
| 14 | `extra_envelope_hint` | (없음) | "Asset Snapshot 은 §11.2 필드, Checks 는 §12.2 의 10 축." | "특히 §11.4 Hook Snapshot, §12.4 Hook Checks." |

총 14 분기 행. 행 5-12 는 dispatch envelope 채움. 행 1-4 는 GAP report 작성 시 직접 사용. 행 14 는 envelope prompt 끝에 추가.

## 2. Lookup 절차

호출자 (creator-gap-eval Phase 3/4) 입장에서:

1. `args.resource_type` 으로 위 표의 컬럼 선택.
2. 필요한 행 (matrix 키) 의 값 추출.
3. SKILL.md Phase 절차 또는 `delegation-envelope.md` template 의 placeholder 자리에 채움.

예시 (skill 분기):

```text
matrix.guide_name        = SKILL-GUIDE
matrix.snapshot_section  = GAP-FORMAT §11.1 Skill Snapshot
matrix.target_paths      = [<SKILL_PATH>/SKILL.md]
matrix.workspace_name_pattern = skill-
→ report_path = $WORKSPACE/gaps/skill-<asset_name>.GAP.md
```

예시 (agent 분기, `pr-review-toolkit/code-reviewer` 같은 슬래시 포함):

```text
matrix.workspace_name_pattern 적용:
  agent-<path-safe-name>  → asset_name="pr-review-toolkit-code-reviewer"
  → report_path = $WORKSPACE/gaps/agent-pr-review-toolkit-code-reviewer.GAP.md
```

호출자가 `asset_name` 을 결정할 때 `/` → `-` 치환 필요 (agent 자원 한정).

예시 (hook 분기):

```text
matrix.target_paths      = [<SCRIPT_PATH>, <REGISTRATION_PATH>]
matrix.delegation_target_wording = "새 훅 1건 (script + registration 한 쌍):
                                     <SCRIPT_PATH>
                                     <REGISTRATION_PATH>"
matrix.extra_envelope_hint = "특히 §11.4 Hook Snapshot, §12.4 Hook Checks."
```

hook 은 *2 파일* 분석이 본질 — envelope 의 target 슬롯이 list. `args.draft_path` 도 list 길이 2 여야 함.

## 3. Lookup 시뮬레이션 (Self-test 입력)

Task 2 Step 4 audit + Task 4 self-eval 입력으로 사용. 각 자원 1 case 씩:

### Case A — skill (예: `skill-creator` 자체 검증)

```yaml
args:
  resource_type: skill
  draft_path: [/abs/.../skills/skill-creator/SKILL.md]
  asset_name: skill-creator
  delegation_mode: delegate
  reentry_count: 0

matrix lookup:
  snapshot_section: GAP-FORMAT §11.1
  checks_section: GAP-FORMAT §12.1
  guide_name: SKILL-GUIDE
  delegation_check_axis: Skill
  target_paths_len: 1
  workspace_name_pattern: skill-
  report_path: $WORKSPACE/gaps/skill-skill-creator.GAP.md
  delegation_target_wording: "새 스킬 1개: /abs/.../skills/skill-creator/SKILL.md"
```

### Case B — agent (예: `agent-skill-auditor`)

```yaml
args:
  resource_type: agent
  draft_path: [/abs/.../agents/agent-skill-auditor.md]
  asset_name: agent-skill-auditor
  delegation_mode: delegate
  reentry_count: 0

matrix lookup:
  snapshot_section: GAP-FORMAT §11.2
  checks_section: GAP-FORMAT §12.2 (10 축)
  guide_name: AGENT-GUIDE
  delegation_check_axis: Agent
  target_paths_len: 1
  workspace_name_pattern: agent-
  report_path: $WORKSPACE/gaps/agent-agent-skill-auditor.GAP.md
  extra_envelope_hint: "Asset Snapshot 은 §11.2 필드, Checks 는 §12.2 의 10 축."
```

### Case C — hook (예: hypothetical 2 파일 hook)

```yaml
args:
  resource_type: hook
  draft_path: [/abs/.../hooks/foo/foo.sh, /abs/.../hooks/foo/hooks.json]
  asset_name: foo
  delegation_mode: delegate
  reentry_count: 0

matrix lookup:
  snapshot_section: GAP-FORMAT §11.4
  checks_section: GAP-FORMAT §12.4
  guide_name: HOOK-GUIDE
  delegation_check_axis: Hook
  target_paths_len: 2
  workspace_name_pattern: hook-
  report_path: $WORKSPACE/gaps/hook-foo.GAP.md
  delegation_target_wording: |
    새 훅 1건 (script + registration 한 쌍):
      /abs/.../hooks/foo/foo.sh
      /abs/.../hooks/foo/hooks.json
  extra_envelope_hint: "특히 §11.4 Hook Snapshot, §12.4 Hook Checks."
```

## 4. 알려진 한계

- **matrix 에 없는 `resource_type`** (command / runtime / plugin / 외 등) → `unknown_resource_type` 에러 + SKILL.md Phase 0 가 `NEEDS_REVIEW` 반환. command / runtime 은 본 skill 의 *현재 범위 밖* — 별도 creator skill (`command-creator` 미존재, `hook-creator` 가 가장 가까움) 부재로 인해 본 matrix 가 다루지 않음. command 자원의 GAP 적용은 향후 별도 Step (out of scope).
- **agent 의 `asset_name` 슬래시** — 호출자가 `/` → `-` 치환 책임. 본 matrix 의 `workspace_name_pattern` 행 4에 명시.
- **hook 의 2 파일 분기 단순화** — 일부 hook 은 script 만 있고 registration 은 `settings.json` 같은 공용 파일에 있을 수 있음. 이 경우 `args.draft_path` 의 두 번째 요소가 공용 파일 절대 경로. matrix 는 *목표 path 형태* 만 다루고 공용 파일 처리는 dispatch envelope 의 prompt 본문 (delegation-envelope.md) 에서 명시.
- **SPLIT_ASSET 신호의 skill 자원 부재** — 본 표의 행 7 (skill 컬럼) 이 "자원-특화 신호 없음" 으로 비어있음. skill 자원의 SPLIT_ASSET 은 일반 신호 (책임 너무 큼, 본문 너무 김) 로 처리. 자원-특화 신호가 발견되면 본 표에 추가.
- **GUIDE_GAP 후보의 agent 편향** — 행 13 이 agent 컬럼에만 후보. skill / hook 의 GUIDE_GAP 은 *runtime 발견* 시 추가 (관찰 누적).

## 5. Maintenance

- 본 matrix 의 행 추가/변경 시: (1) SKILL.md 의 Phase 절차에 영향 있는지 검토, (2) `delegation-envelope.md` 의 placeholder 자리 영향 검토.
- GAP-FORMAT.md 의 §11.X / §12.X 섹션 번호 변경 시: 본 표 행 1-2 동기 갱신 필수.
- 새 `resource_type` 추가 (예: command 자원) 시: (1) 컬럼 추가, (2) `args.resource_type` enum 확장, (3) SKILL.md description / When NOT to Use 갱신.
