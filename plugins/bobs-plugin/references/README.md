# Agent / Skill / Hook Best Practices

생성: 2026-05-16
용도: 유저 스콥(`~/.claude/`) 의 스킬·서브에이전트·훅을 설계하고 검토하기 위한 reference collection. 자산 스냅샷은 read-only 사본이며 원본은 각 플러그인 캐시에 있다.

---

## 디렉토리 구조

```
agent-skill-best-practices/
├── README.md                    ← 이 파일 (인덱스)
├── CONSTITUTION.md              ← 세 자산 공통 헌법
├── SKILL-GUIDE.md               ← 스킬 작성 가이드
├── AGENT-GUIDE.md               ← 서브에이전트 작성 가이드
├── HOOK-GUIDE.md                ← 훅 작성 가이드
├── GAP-FORMAT.md                ← GAP 리포트 포맷
├── GAP-ANALYSIS-PROMPT.md       ← GAP 분석 위임 프롬프트
├── STATUS-2026-05-16.md         ← 현재 작업 상태
│
├── skills/                      ← 자산 스냅샷 (read-only)
│   ├── brainstorming/           superpowers
│   ├── claude-automation-recommender/  claude-code-setup
│   ├── claude-md-improver/      claude-md-management
│   ├── frontend-design/         frontend-design
│   ├── skill-creator/           skill-creator
│   ├── using-git-worktrees/     superpowers
│   ├── writing-plans/           superpowers
│   └── writing-skills/          superpowers
│
├── agents/
│   ├── builtin/README.md        claude-code-guide / general-purpose / Explore / Plan
│   ├── code-simplifier.md       code-simplifier
│   └── pr-review-toolkit/
│       ├── code-reviewer.md
│       ├── code-simplifier.md
│       └── comment-analyzer.md
│
├── hooks/
│   ├── README.md                훅 스냅샷 인덱스
│   ├── superpowers/             SessionStart hook
│   ├── ralph-loop/              Stop hook
│   └── security-guidance/       PreToolUse hook
│
├── v1/                          v1 사이클 archive (자체완결: 헌법 + 3 가이드 + GAP-FORMAT + GAP-ANALYSIS-PROMPT + gaps/ + SIGNALS.md)
│
└── v2/
    ├── gaps/                    v2 사이클 GAP 리포트 15개
    └── v2-update.md             v2 자산 inventory 시점 기록
```

---

## 문서 권위

```
CONSTITUTION.md
└─ SKILL-GUIDE.md / AGENT-GUIDE.md / HOOK-GUIDE.md
   └─ GAP-FORMAT.md
      └─ GAP-ANALYSIS-PROMPT.md
         └─ v2/gaps/*.GAP.md
```

하위 문서는 헌법을 해석·구체화하되 뒤집을 수 없다.

---

## 권장 읽기 순서

1. `CONSTITUTION.md` — 세 자산에 공통 적용되는 헌법
2. `SKILL-GUIDE.md` / `AGENT-GUIDE.md` / `HOOK-GUIDE.md` — 타입별 실무 가이드
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

## 사이클 archive 운영 원칙

- `v1/`, `v2/` 는 각 사이클의 self-contained snapshot 으로 둔다.
- 현재 active 가이드는 root 에만 둔다. 사이클을 닫을 때 root 의 사본을 해당 사이클 디렉토리로 복사한다.
- 다음 사이클(`v3/`) 을 열 때는 root 가이드를 그대로 사용하고 `v3/gaps/` 만 새로 만든다.
