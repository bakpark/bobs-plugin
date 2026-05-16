# context-map.md template

> 출처: `context-map-builder` SKILL.md §Phase 2 의 골격. 프로젝트 inventory 와 작업 유형으로 채워 사용한다. 모든 자원 이름·경로는 *실제 inventory* 의 것으로 교체해야 한다.

---

```markdown
# Context Map

이 문서는 작업 유형마다 어떤 역할·문서·skill·hook 이 관여하는지 정리한 라우팅 표다.
호출자는 표를 보고 *어디서 시작할지* 를 결정하고, 빈 셀은 *작성 후보* 로 본다.

## 라우팅 표

| 작업 유형 | 우선 역할 | 먼저 볼 문서 | 사용할 skill | 관여 hook |
|---|---|---|---|---|
| 신규 기능 구현 | planner, implementer | `AGENTS.md`, `docs/architecture.md` | feature-implementation | docs-sync-check |
| 버그 수정 | implementer, reviewer | `AGENTS.md`, 관련 테스트 | bug-investigation | task-log-capture |
| PR / 코드 리뷰 | reviewer | `docs/workflows/review-process.md`, `docs/security.md` | code-review | — |
| 외부 시스템 연계 | planner, security-auditor | `docs/integrations/`, `docs/security.md` | integration-change | secret-access-warning |
| 보안 / credential | security-auditor | `docs/security.md` | — | secret-access-warning, dangerous-command-guard |
| 문서 / 운영 정리 | doc-maintainer | `docs/README.md` | docs-sync | — |
| 에이전트 환경 개선 | agent-env-maintainer | `docs/agent/` | agent-environment-audit | task-log-capture |

빈 셀 (`—`) 은 *해당 위치에 자원이 없음* 을 의미하며, 자원을 새로 만들 후보다.

## 읽는 방법

1. 작업 시작 시 작업 유형을 식별한다.
2. 해당 행을 찾는다. 정확히 맞는 행이 없으면 가장 가까운 행을 *시작점* 으로 쓰고, 새 행이 필요한지 보고한다.
3. *우선 역할* 의 책임 정의는 `docs/agent/roles.md` 에서 확인한다.
4. *먼저 볼 문서* 를 읽고, *사용할 skill* 을 호출한다.
5. *관여 hook* 은 자동으로 동작한다 — 호출자가 의식적으로 트리거할 필요 없음.

## 갱신

- 자원 (skill / agent / hook / docs) 이 추가·삭제될 때 표를 갱신한다.
- 새 작업 유형이 반복적으로 등장하면 행을 추가한다.
- 갱신은 `context-map-builder` 스킬로 처리한다.
```

---

## 빈 칸 채우는 순서

1. **자원 inventory** — `references/inventory-guide.md` 절차로 실제 존재하는 skill / agent / hook / doc 수집
2. **작업 유형 식별** — 프로젝트 PR 패턴 / commit prefix / `.github/PULL_REQUEST_TEMPLATE.md` 참조. 6–10 행 권장
3. **역할 매핑** — `docs/agent/roles.md` 에서 정의된 역할 이름만 인용. 없는 역할은 먼저 `roles.md` 에 추가
4. **자원 매핑** — 한 셀에 콤마로 늘어놓지 말고 *주 자원* 한 개. 분기가 필요하면 행을 나눈다
5. **hook 매핑** — 결정론적 가드레일이 정말 필요한 행에만. 비어있어도 정상
6. **읽는 방법 / 갱신 단락** — 표보다 길어지지 않게 1–2 문단

## 길이 가이드

- 표 행: 6–10 행이 권장
- 표 외 prose: 5–15 줄 — 표보다 길면 줄인다
- 행 수 < 5: 작업 유형이 너무 압축됨. 분기 신호가 있는지 확인
- 행 수 > 15: 호출자가 라우팅 판단 비용이 커짐. 그룹화 또는 병합 검토
