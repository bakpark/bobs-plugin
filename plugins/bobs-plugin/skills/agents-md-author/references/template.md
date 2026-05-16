# AGENTS.md template

> 출처: `agents-md-author` SKILL.md §Phase 2 의 기본 골격을 그대로 시작용으로 제공. 프로젝트 컨텍스트 (Phase 1 inspect) 를 채워 넣어 사용한다. 모든 명령·경로·규칙은 *실제 프로젝트* 의 것으로 교체해야 한다.

---

```markdown
# AGENTS.md

## Project context

<프로젝트가 무엇인지 1-3 문장. 도메인 / 사용자 / 핵심 흐름. 긴 설명은 `docs/` 로.>

## Quick start

```bash
<setup 명령 — 예: pnpm install>
<build 명령 — 예: pnpm build>
<run 명령 — 예: pnpm dev>
```

## Verification

작업 후 다음을 통과해야 한다:

```bash
<test 명령 — 예: pnpm test>
<lint 명령 — 예: pnpm lint>
<typecheck — 예: pnpm typecheck>
```

CI 가 추가로 실행하는 항목은 `.github/workflows/` 참조.

## Code editing rules

- 작업 시작 전 기존 코드를 먼저 읽는다.
- 요청 범위만 변경한다 — 무관한 리팩터·주석 추가·기능 확장 금지.
- <프로젝트 컨벤션 1>
- <프로젝트 컨벤션 2>
- <테스트 정책>

## Document reference order

작업 유형별 첫 참조:

| 작업 | 먼저 볼 문서 |
|---|---|
| 신규 기능 | `docs/architecture.md`, 관련 spec |
| 버그 수정 | 관련 테스트, `docs/decisions/` |
| 외부 연계 | `docs/integrations/`, `docs/security.md` |
| 도메인 판단 | `docs/domain/` |

## Forbidden actions

- `.env`, credential 파일 commit / 출력 금지
- main / master 에 force push 금지
- `git reset --hard`, `rm -rf` 등 destructive 명령은 사용자 명시 승인 후에만
- 외부 서비스로 코드·데이터 전송 금지 (지정된 CI / linter 외)
- <프로젝트 한정 금지 사항>

## Pull request expectations

- PR 제목: <컨벤션 예: `<type>(<scope>): <subject>`>
- 본문: 변경 요약 + 테스트 방법
- 통과해야 할 CI 작업: <목록>
- 리뷰어 지정: <팀 정책>

## When in doubt

- 의사결정 근거가 필요하면 `docs/decisions/` 확인
- 컨벤션이 불분명하면 가장 가까운 기존 코드를 따른다
- 그래도 모호하면 PR 또는 이슈로 묻는다 — 추정으로 진행하지 않는다
```

---

## 빈 칸 채우는 순서

1. **Quick start / Verification 명령** — `package.json` scripts, Makefile, CI yaml 에서 그대로 복사
2. **Document reference order** — `docs/` 디렉토리가 있다면 매핑, 없으면 작성 후 채움 (또는 행 자체 삭제)
3. **Forbidden actions** — 최소 3개는 명시: secret 접근 / force push / destructive 명령
4. **Project context** — 한 문단. 긴 설명은 README · `docs/architecture.md` 로
5. **Code editing rules / PR expectations** — `CONTRIBUTING.md` 또는 PR 템플릿 발췌

## 길이 가이드

- 100 줄 미만: 명령·금지 항목 충분히 들어있는지 확인 (under-scoped)
- 100–250 줄: 정상
- 300 줄 초과: 분리 필요 — 아키텍처·도메인은 `docs/`, Claude 한정은 `CLAUDE.md`
