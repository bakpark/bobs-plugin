# CLAUDE.md 작성 절차

> 본 문서는 `context-map-architecture` skill 의 reference.
>
> **출처**: vendored from `claude-plugins-official/plugins/claude-md-management/skills/claude-md-improver` (Apache-2.0). 본 파일은 원본 `SKILL.md` + `references/quality-criteria.md` + `references/update-guidelines.md` + `references/templates.md` 를 압축·재구성해 self-contained 형태로 작성. 원본 LICENSE 사본은 `plugins/bobs-plugin/third_party_licenses/claude-md-management-LICENSE` 유지.

## 책임 경계

CLAUDE.md = Claude 한정 *짧은 운용 지침*. 모든 작업 계약 (build / test / forbidden actions) 은 `AGENTS.md` (→ `references/agents-md-write.md`) 가 소유. 본 절차는 *Claude 사용 시 우선 흡수할 운용 지침* 만 갱신한다.

## Phase 1 Discovery

```bash
find . -name "CLAUDE.md" -o -name ".claude.md" -o -name ".claude.local.md" 2>/dev/null | head -50
```

File Types & Locations:

| Type | Location | Purpose |
|---|---|---|
| Project root | `./CLAUDE.md` | Primary project context (checked into git) |
| Local overrides | `./.claude.local.md` | Personal/local settings (gitignored) |
| Global defaults | `~/.claude/CLAUDE.md` | User-wide defaults |
| Package-specific | `./packages/*/CLAUDE.md` | Module-level context in monorepos |
| Subdirectory | Any nested location | Feature/domain-specific context |

Claude 는 parent directory 의 CLAUDE.md 를 자동 발견 — monorepo 셋업이 자연스럽게 작동.

## Phase 2 Quality

각 CLAUDE.md 를 6 criteria 로 평가 (총 100점):

| Criterion | Weight | Check | Score guide (점수=설명) |
|---|---|---|---|
| Commands/workflows | 20 | build/test/deploy 명령 존재? | 20=all essential · 15=most present · 10=basic only · 5=few · 0=none |
| Architecture clarity | 20 | 코드베이스 구조를 Claude 가 이해 가능? | 20=clear map · 15=good overview · 10=basic listing · 5=vague · 0=none |
| Non-obvious patterns | 15 | gotcha / quirk 문서화? | 15=captured · 10=some · 5=minimal · 0=none |
| Conciseness | 15 | filler 없음, 한 줄 한 가치? | 15=dense · 10=mostly · 5=verbose · 0=filler/restate |
| Currency | 15 | 현재 코드베이스 반영? | 15=current · 10=mostly · 5=several stale · 0=severely outdated |
| Actionability | 15 | 복붙 가능한 명령·실제 경로? | 15=executable · 10=mostly · 5=vague · 0=theoretical |

Grade: A=90-100 · B=70-89 · C=50-69 · D=30-49 · F=0-29.

평가 절차: 파일 전체 읽기 → 코드베이스 cross-reference (명령 실행 mental check, 파일 존재 확인) → 6 criterion 채점 → 총점·grade → 이슈 목록 → 개선 제안.

Red flags: 동작 안 하는 명령 / 삭제된 파일 참조 / 구버전 tech / 미커스터마이즈 템플릿 카피 / 프로젝트 무관 일반 조언 / 미완 TODO / CLAUDE.md 간 중복.

## Phase 3 Report

**ALWAYS output quality report BEFORE updates.**

형식: Summary (files found, average score, files needing update) → 파일별 (score, criterion 표, issues, recommended additions). report 는 호출자가 보일 형태이므로 본 reference 본문에는 코드 블록 예시를 포함하지 않음 — 위의 6 criterion 표를 그대로 채워 작성.

## What TO add / What NOT to add

| TO add (project-specific, 미래 세션 도움) | NOT to add (filler / 일반론) |
|---|---|
| 발견한 build/test/deploy 명령 | 코드에서 이미 명확한 사실 (class 이름이 설명) |
| Gotcha / non-obvious 패턴 (예: 테스트는 `--runInBand` 필요) | 일반적인 best practice ("테스트 작성하라", "의미 있는 변수명") |
| Package 의존 순서·import 순서 같이 코드만 봐선 모르는 것 | 일회성 fix (특정 commit 의 버그 수정 기록) |
| 잘 작동한 testing 접근 (helper, factory 위치) | 장황한 설명 (JWT 표준 설명 → "Auth: JWT HS256" 한 줄로) |
| Config 특이점 (예: `NEXT_PUBLIC_*` build time 만, Redis `?family=0` IPv6) | 다른 CLAUDE.md 와 중복되는 내용 |

## Phase 4 Targeted Updates (approval gate)

Report 출력 후 사용자 승인을 받는다. 각 변경마다:

1. **파일 식별**: `File: ./CLAUDE.md` / `Section: <name>`
2. **diff 표시**: `+ ## Commands\n+ \n+ | Command | Purpose |\n+ |---|---|\n+ | npm run dev | Dev server with HMR |` 형태
3. **Why 설명**: 한 줄 — "build commands 가 누락돼 프로젝트 실행법에 혼란이 있었음"

## Phase 5 Apply

사용자 승인 후 Edit tool 로 적용. 기존 content 구조 보존.

## Recommended Sections (use only what's relevant)

- **Commands** — build / test / dev / lint 표
- **Architecture** — 디렉토리 트리 + 각 dir 한 줄 purpose
- **Key Files** — entry point, config 파일 + purpose
- **Code Style** — 프로젝트 컨벤션 (한 줄씩)
- **Environment** — 필수 환경 변수 + setup step
- **Testing** — test 명령 + 작동하는 testing 패턴
- **Gotchas** — non-obvious quirk / 흔한 실수
- **Workflow** — 작업 패턴 ("X 할 때는 Y")

섹션 골격 코드 블록은 본 reference 에 포함하지 않음 — 작성 시점에 SKILL.md (호출자) 가 직접 안내. 길이 가이드: 한 줄 = 한 개념, 사람 가독성 우선, dense > verbose.

## Validation Checklist

업데이트 완료 직전 확인:

- [ ] 각 추가는 project-specific (일반 조언 / 코드 자명 사실 X)
- [ ] 명령은 실제 작동 (테스트됨)
- [ ] 파일 경로는 정확
- [ ] 새 Claude 세션이 이 정보를 *유용하다고* 판단할까?
- [ ] 가장 간결한 표현인가? (한 줄로 충분하면 한 줄)
- [ ] AGENTS.md 와 중복되지 않나? (작업 계약은 AGENTS, Claude 운용 지침만 CLAUDE)

## User Tips (사용자에게 알릴 만한 것)

- `#` 키: Claude 세션 중 `#` 누르면 학습을 CLAUDE.md 에 자동 통합
- `.claude.local.md`: 팀과 공유 안 할 개인 설정 (`.gitignore` 추가)
- 글로벌 기본값: `~/.claude/CLAUDE.md`

## Common Issues

- Stale commands (더 이상 동작 안 함)
- Missing dependencies (필수 도구 미언급)
- Outdated architecture (파일 구조 변경됨)
- Missing environment setup (필수 env vars / config)
- Broken test commands
- Undocumented gotchas

## Output Contract

```
files_audited: <count>
files_updated: <count>
file_details:
  - path: <CLAUDE.md path>
    grade: A | B | C | D | F
    score: <0-100>
    updates_applied: <list of section names>
follow_ups:
  - <path>: 추가 조사 필요한 항목
mode: applied | report-only | no-op | blocked
```
