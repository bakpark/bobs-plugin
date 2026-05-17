# Agent / Skill / Hook Best Practices

위치: `plugins/bobs-plugin/references/`
생성: 2026-05-16
용도: `bobs-plugin` 이 다루는 skill · agent · command · hook · runtime settings 다섯 자원 타입을 설계하고 검토하기 위한 reference collection. 적용 범위는 플러그인 (`plugins/*/`) 과 프로젝트 (`<repo>/.claude/`) scope — user scope 자산은 본 collection 의 범위 밖. 자산 스냅샷은 read-only 사본이며 원본은 각 플러그인 캐시에 있다.

---

## 디렉토리 구조

```
references/
├── README.md                    ← 이 파일 (인덱스)
├── CONSTITUTION.md              ← 하네스 자산 공통 헌법
├── SKILL-GUIDE.md               ← 스킬 작성 가이드
├── AGENT-GUIDE.md               ← 서브에이전트 작성 가이드
├── COMMAND-GUIDE.md             ← 사용자 명시 호출 workflow 가이드
├── HOOK-GUIDE.md                ← 훅 작성 가이드
├── RUNTIME-GUIDE.md             ← settings/permissions/MCP/memory/session 가이드
├── GAP-FORMAT.md                ← GAP 리포트 포맷
├── GAP-ANALYSIS-PROMPT.md       ← GAP 분석 위임 프롬프트
├── STATUS-2026-05-16.md         ← 현재 작업 상태
│
├── skills/                      ← 외부 플러그인 skill 스냅샷 (read-only)
├── agents/                      ← 외부 플러그인 + 내장 agent 스냅샷
├── hooks/                       ← 외부 플러그인 hook 스냅샷
│
├── v1/                          v1 사이클 archive
└── v2/
    ├── gaps/                    v2 사이클 GAP 리포트
    └── v2-update.md             v2 자산 inventory 시점 기록
```

각 스냅샷의 marketplace / plugin / asset 좌표는 아래 **외부 의존 자원** 표 참조.

---

## 문서 권위

```
CONSTITUTION.md
└─ SKILL-GUIDE.md / AGENT-GUIDE.md / COMMAND-GUIDE.md / HOOK-GUIDE.md / RUNTIME-GUIDE.md
   └─ GAP-FORMAT.md
      └─ GAP-ANALYSIS-PROMPT.md
         └─ v2/gaps/*.GAP.md
```

하위 문서는 헌법을 해석·구체화하되 뒤집을 수 없다.

---

## 권장 읽기 순서

1. `CONSTITUTION.md` — 하네스 자산에 공통 적용되는 헌법
2. `SKILL-GUIDE.md` / `AGENT-GUIDE.md` / `COMMAND-GUIDE.md` / `HOOK-GUIDE.md` / `RUNTIME-GUIDE.md` — 타입별 실무 가이드
3. `GAP-FORMAT.md` + `GAP-ANALYSIS-PROMPT.md` — 자산 평가 절차
4. `v2/gaps/` — 직전 사이클의 평가 결과 (실제 적용 사례)

---

## 자산 스냅샷 갱신

자산은 플러그인 업데이트 시 원본이 덮어쓰일 수 있어 이 디렉토리에 사본을 둔다. 갱신 흐름:

1. 현재 설치 상태를 `v2-update.md` 같은 inventory 파일로 기록
2. `skills/`, `agents/`, `hooks/` 를 inventory 와 일치시킴 (추가·제거·플러그인 캐시에서 복사)
3. `v2/gaps/` 에 새 GAP 리포트를 생성하고 차이를 정리

원본 위치:
- 플러그인 마켓플레이스: `~/.claude/plugins/marketplaces/<marketplace>/plugins/<plugin>/`
- 플러그인 캐시: `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`

---

## 외부 의존 자원 (Marketplace → Plugin → Asset)

스냅샷 본문은 다음 외부 플러그인에서 가져온 사본이다. 원본을 수정해야 한다면 아래 좌표를 따른다.

### Skills (`skills/`)

| 스냅샷 디렉토리 | Marketplace | Plugin | Skill |
|---|---|---|---|
| `brainstorming/` | `claude-plugins-official` | `superpowers` | `brainstorming` |
| `claude-md-improver/` | `claude-plugins-official` | `claude-md-management` | `claude-md-improver` |
| `frontend-design/` | `claude-plugins-official` | `frontend-design` | `frontend-design` |
| `skill-creator/` | `claude-plugins-official` | `skill-creator` | `skill-creator` |
| `using-git-worktrees/` | `claude-plugins-official` | `superpowers` | `using-git-worktrees` |
| `writing-plans/` | `claude-plugins-official` | `superpowers` | `writing-plans` |
| `writing-skills/` | `claude-plugins-official` | `superpowers` | `writing-skills` |

### Agents (`agents/`)

| 스냅샷 | Marketplace | Plugin | Agent |
|---|---|---|---|
| `builtin/README.md` | (Claude Code 내장) | — | `claude-code-guide`, `general-purpose`, `Explore`, `Plan` |
| `code-simplifier.md` | `claude-plugins-official` | `code-simplifier` | `code-simplifier` |
| `pr-review-toolkit/code-reviewer.md` | `claude-plugins-official` | `pr-review-toolkit` | `code-reviewer` |
| `pr-review-toolkit/code-simplifier.md` | `claude-plugins-official` | `pr-review-toolkit` | `code-simplifier` |
| `pr-review-toolkit/comment-analyzer.md` | `claude-plugins-official` | `pr-review-toolkit` | `comment-analyzer` |

### Hooks (`hooks/`)

| 스냅샷 디렉토리 | Marketplace | Plugin | Event |
|---|---|---|---|
| `superpowers/` | `claude-plugins-official` | `superpowers` | `SessionStart` (`startup\|clear\|compact`) |
| `ralph-loop/` | `claude-plugins-official` | `ralph-loop` | `Stop` |
| `security-guidance/` | `claude-plugins-official` | `security-guidance` | `PreToolUse` |

원본 경로 패턴:
- 마켓플레이스: `~/.claude/plugins/marketplaces/<marketplace>/plugins/<plugin>/`
- 캐시 (버전 핀): `~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`
- 예) superpowers 훅 원본: `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/hooks/`

---

## 외부 참고 자료

이 디렉토리에 사본이 들어있지는 않지만 가이드 작성·검토 시 교차 확인하는 외부 출처.

| 출처 | 용도 |
|---|---|
| <https://github.com/shanraisshan/claude-code-best-practice> | Claude Code best-practice 외부 레퍼런스. 헌법·가이드와 교차 확인용. |

---

## 사이클 archive 운영 원칙

- `v1/`, `v2/` 는 각 사이클의 self-contained snapshot 으로 둔다.
- 현재 active 가이드는 root 에만 둔다. 사이클을 닫을 때 root 의 사본을 해당 사이클 디렉토리로 복사한다.
- 다음 사이클(`v3/`) 을 열 때는 root 가이드를 그대로 사용하고 `v3/gaps/` 만 새로 만든다.
