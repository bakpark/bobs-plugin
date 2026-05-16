# 효과적 스킬·에이전트·훅 구성 가이드

생성: 2026-05-16
대상 범위: 유저 스콥(`~/.claude/`) 의 스킬, 서브에이전트, 훅 설계·작성
분석 자료: `./skills/`, `./agents/` 의 6 스킬 + 7 에이전트 + 빌트인 3종 description

---

## §0. 헌법 (Constitution)

본 가이드의 최상위 권위는 **`claude-automation-recommender`** 의 권고이다. 다른 자료(`skill-creator`, `writing-skills`, `brainstorming`, `doc-coauthoring`, `claude-md-improver` 및 7개 에이전트 정의)가 헌법과 충돌하면 헌법이 우선한다. 본문 내 모든 MUST/SHOULD 항목은 헌법에서 직접 도출(D), 헌법과 보강 자료의 합의(C), 보강 자료에서만 도출(S) 로 표시한다.

헌법의 핵심 4 명제:

| # | 명제 | 출처 |
|---|---|---|
| C1 | **자동화는 5종으로 분류된다**: Hooks / Subagents / Skills / Plugins / MCP Servers. 각각 "Best For" 가 명확히 분리되어야 한다. | `claude-automation-recommender/SKILL.md` Table "Automation Types Overview" |
| C2 | **추천은 1–2개 / 카테고리** 가 기본. 모두 나열은 압도(overwhelm). 사용자가 더 요청하면 그때 확장. | 동 SKILL.md Phase 3 "Only include 1-2 recommendations per category" |
| C3 | **스킬 invocation 은 3-mode** 로 통제한다: User+Claude (default) / User-only (`disable-model-invocation`) / Claude-only (`user-invocable: false`). 부수 효과(deploy/send) 는 User-only, 백그라운드 지식은 Claude-only. | 동 SKILL.md "Invocation Control" |
| C4 | **에이전트의 도구 노출은 능력에 맞게 축소** — 리뷰/분석은 read-only(Read/Grep/Glob), 생성은 +Write, 마이그레이션은 +Bash. 모델 선택은 sonnet 기본, opus 복잡, haiku 단순. | `subagent-templates.md` "Tool Access Guide", "Model Selection Guide" |

---

## §1. 정량 데이터 (측정값 원본)

표본 = 본 디렉토리 `./skills/*/SKILL.md` (n=6) + `./agents/**/*.md` (n=7, builtin/README.md 제외). 빌트인 3개(`claude-code-guide`, `Explore`, `general-purpose`) 는 정량 표본 외 — plugin cache 에 원본 `.md` 가 없고 시스템 프롬프트 발췌만 존재(`agents/builtin/README.md`).

측정 시점: 2026-05-16. 측정 환경: macOS Darwin 24.6.0 / `python3` (PyYAML 가용) / `wc` / `grep -i`.

### §1.0 측정 재현 명령

다음 3개 블록을 순서대로 실행하면 §1.1 ~ §1.3 표를 재생산한다. 실행 디렉토리: `/Users/macpro/.claude/research/agent-skill-best-practices/`.

```bash
# §1.1 본문 / description 길이 ──────────────────
# 본문 words / lines
for d in skills/*/; do
  n=$(basename "$d"); wc=$(wc -w < "$d/SKILL.md" 2>/dev/null || echo 0)
  lines=$(wc -l < "$d/SKILL.md" 2>/dev/null || echo 0)
  printf "%-32s %5d words  %4d lines\n" "$n" "$wc" "$lines"
done
find agents -maxdepth 3 -name "*.md" -not -path "*/builtin/*" | while read f; do
  printf "%-50s %5d words  %4d lines\n" "${f#agents/}" "$(wc -w<"$f")" "$(wc -l<"$f")"
done

# description chars / words (YAML 파싱)
for f in skills/*/SKILL.md agents/*.md agents/*/*.md; do
  [ -f "$f" ] && python3 - "$f" <<'EOF'
import sys, yaml, re
p=sys.argv[1]; s=open(p).read()
m=re.match(r'^---\n(.*?)\n---', s, re.DOTALL)
fm=yaml.safe_load(m.group(1)) if m else {}
desc=str(fm.get('description','') or '')
print(f"{p:<60} chars={len(desc)} words={len(desc.split())}")
EOF
done
```

```bash
# §1.2 지시어 빈도 ──────────────────
printf "%-50s %5s %5s %5s %5s %5s %5s\n" file MUST MUSTN NEVER ALWAYS SHOULD DONOT
for f in skills/*/SKILL.md agents/*.md agents/*/*.md; do
  [ -f "$f" ] || continue
  printf "%-50s %5d %5d %5d %5d %5d %5d\n" "${f#./}" \
    "$(grep -ci 'MUST ' "$f")"   "$(grep -c  'MUST NOT' "$f")" \
    "$(grep -ci 'NEVER' "$f")"   "$(grep -ci 'ALWAYS' "$f")" \
    "$(grep -ci 'SHOULD' "$f")"  "$(grep -cEi "DO NOT|Don't|do not" "$f")"
done
```

```bash
# §1.3 frontmatter 사용 ──────────────────
for f in skills/*/SKILL.md agents/*.md agents/*/*.md; do
  [ -f "$f" ] && python3 - "$f" <<'EOF'
import sys, yaml, re
p=sys.argv[1]; s=open(p).read()
m=re.match(r'^---\n(.*?)\n---', s, re.DOTALL)
fm=yaml.safe_load(m.group(1)) if m else {}
tools=fm.get('tools',''); toolc=len([t for t in re.split(r'[,\s]+', str(tools)) if t]) if tools else 0
model=fm.get('model','-'); color=fm.get('color','-')
body=s[m.end():] if m else s
ex=len(re.findall(r'<example>', body))
print(f"{p:<50} t={toolc} m={model} c={color} ex={ex}")
EOF
done
```

호출 통계(에이전트·스킬 hit 카운트)는 별도 DB:

```bash
sqlite3 /Users/macpro/.claude/logs/session-events.db \
  "SELECT json_extract(payload,'$.skill') s, COUNT(*) FROM events WHERE tool_name='Skill' GROUP BY s ORDER BY 2 DESC;"
sqlite3 /Users/macpro/.claude/logs/session-events.db \
  "SELECT json_extract(payload,'$.subagent_type') a, COUNT(*) FROM events WHERE tool_name='Agent' GROUP BY a ORDER BY 2 DESC;"
```

### §1.1 본문 길이 & description 길이

| 자원 | 본문 words | 본문 lines | desc chars | desc words |
|---|---:|---:|---:|---:|
| **skills/brainstorming** | 1,553 | 164 | 198 | 26 |
| **skills/claude-automation-recommender** (헌법) | 1,508 | 288 | 354 | 55 |
| **skills/claude-md-improver** | 869 | 179 | 338 | 48 |
| **skills/doc-coauthoring** | 2,466 | 375 | 428 | 57 |
| **skills/skill-creator** | 5,205 | 485 | 319 | 49 |
| **skills/writing-skills** | 3,212 | 655 | 97 | 14 |
| agents/code-simplifier | 433 | 52 | 172 | 21 |
| agents/feature-dev/code-architect | 277 | 34 | 230 | 27 |
| agents/feature-dev/code-explorer | 293 | 51 | 195 | 23 |
| agents/feature-dev/code-reviewer | 425 | 46 | 208 | 27 |
| agents/pr-review-toolkit/code-reviewer | 538 | 56 | 972 | 161 |
| agents/pr-review-toolkit/code-simplifier | 734 | 88 | 2,270 | 321 |
| agents/pr-review-toolkit/comment-analyzer | 694 | 79 | 492 | 75 |

**관찰**
- 스킬 본문 분포: 169 ~ 5,205 words. 중앙값 ≈ 1,530. `skill-creator`(5,205) 와 `writing-skills`(3,212) 가 outlier — 둘 다 **메타 스킬**(스킬을 만드는 스킬). 일반 스킬은 1k–2.5k words 대.
- 에이전트 본문은 277 ~ 734 words. 스킬보다 한 자릿수 작다 (median ≈ 425).
- description 길이는 두 군으로 갈린다: **본문 안내형(≤450자)** vs **임베디드 예시형(>900자)**. 후자는 모두 `pr-review-toolkit/*` 계열.

### §1.2 지시어 빈도 (case-insensitive 매칭)

| 자원 | MUST | MUST NOT | NEVER | ALWAYS | SHOULD | DO NOT/Don't |
|---|---:|---:|---:|---:|---:|---:|
| brainstorming | 4 | 0 | 0 | 1 | 3 | 7 |
| claude-automation-recommender (헌법) | 0 | 0 | 0 | 0 | 2 | 1 |
| claude-md-improver | 0 | 0 | 0 | 1 | 3 | 0 |
| doc-coauthoring | 0 | 0 | 2 | 1 | 4 | 3 |
| skill-creator | 3 | 0 | 3 | 7 | 20 | 16 |
| writing-skills | 4 | 0 | 3 | 2 | 5 | 15 |
| code-simplifier (plugin) | 1 | 0 | 1 | 0 | 0 | 0 |
| feature-dev/* (3개 합산) | 0 | 0 | 0 | 1 | 1 | 0 |
| pr-review-toolkit/* (3개 합산) | 1 | 0 | 1 | 1 | 10 | 2 |

**관찰**
- **헌법은 MUST/NEVER 를 0회 사용**. 명령형 대신 권고형(`Recommend / See / Use` ) 으로 일관. 이는 `skill-creator`(§"Writing Style") 의 권고와 일치 — *"Try to explain to the model why things are important in lieu of heavy-handed musty MUSTs."*
- 강한 명령(MUST/NEVER) 이 가장 많은 자원은 **메타 스킬**(skill-creator, writing-skills) — 즉 규율(discipline)을 강제하는 영역. 일반 워크플로우 스킬은 SHOULD/Don't 위주.
- 에이전트는 MUST 가 0~1회로 극히 적다. 톤은 "You are …" 페르소나 + 절차 나열이지 명령 폭격이 아니다.

### §1.3 frontmatter 필드 사용

| 자원 | tools 수 | model | color | description에 `<example>` |
|---|---:|---|---|---:|
| brainstorming | — (omitted) | — | — | 0 |
| claude-automation-recommender (헌법) | 4 | — | — | 0 |
| claude-md-improver | 5 | — | — | 0 |
| doc-coauthoring | — | — | — | 0 |
| skill-creator | — | — | — | 0 |
| writing-skills | — | — | — | 0 |
| code-simplifier (plugin) | — | opus | — | 0 |
| feature-dev/code-architect | 10 | sonnet | green | 0 |
| feature-dev/code-explorer | 10 | sonnet | yellow | 0 |
| feature-dev/code-reviewer | 10 | sonnet | red | 0 |
| pr-review-toolkit/code-reviewer | — | opus | green | 0 (description 내 산문) |
| pr-review-toolkit/code-simplifier | — | opus | — | **3 (description YAML block)** |
| pr-review-toolkit/comment-analyzer | — | inherit | green | 0 (description 내 산문) |

**관찰**
- **스킬은 tools 를 자주 생략**(default = 모든 도구). 헌법·improver 만 명시적으로 축소(Read/Glob/Grep + 필요 시 Bash/Edit). 부수 효과 가능성이 있을 때만 명시.
- **에이전트는 model 을 거의 항상 명시** (7/7) — sonnet 4, opus 3, inherit 1. 헌법(`subagent-templates.md`) 권고와 일치.
- **feature-dev 계열은 10개 도구를 명시적으로 나열** + read-only (`Write` 없음, `Edit` 없음). 헌법의 "리뷰/분석은 read-only" 권고를 그대로 구현.
- **pr-review-toolkit/code-simplifier 의 description은 2,270자 / 321 단어** — `<example>` 태그 3개 임베드. description 만으로 트리거 시나리오를 명세하는 극단적 사례. 단점: 카탈로그 토큰 비용 증가. 장점: 라우팅 모호성 최소화.

---

## §2. 공통점 (모든 자원이 따르는 6개 규칙)

| # | 규칙 | 출처 | 확인된 위반 사례 |
|---|---|---|---|
| 1 | **frontmatter 의 `name`/`description` 은 절대 필수** | C / writing-skills "two required fields" / skill-creator | 0 |
| 2 | **description 은 3인칭 + "언제 트리거할지" 명시** | S / writing-skills "Third-person, describes ONLY when to use" | 0 (모두 준수) |
| 3 | **본문 첫 섹션은 "역할 / 목적 1–2문장"** | C — 헌법: "Analyze codebase patterns to recommend tailored…" / 에이전트는 "You are an expert …" | 0 |
| 4 | **워크플로우는 phase/step/checklist 로 분해** | C — 헌법 "Phase 1/2/3" / brainstorming "9-step checklist" / 에이전트 "1.~5. process" | 0 |
| 5 | **출력 형식을 산출 단계에서 명시** ("Output Guidance / Output Format / Report structure") | C | 0 |
| 6 | **이름은 hyphen-kebab-case + 동사적 명사** (e.g. `code-reviewer`, `claude-md-improver`) | S / writing-skills §3 "Active voice, verb-first" | 0 |

---

## §3. 차이점 — 스킬 vs 에이전트 vs 훅

### §3.1 트리거 메커니즘

| 차원 | 스킬 | 에이전트 | 훅 |
|---|---|---|---|
| 트리거 주체 | Claude (description 매칭) **or** 사용자(`/skill-name`) | 호출자 Claude **or** 다른 에이전트(orchestrator) | Claude Code runtime (이벤트) |
| 트리거 신호 | description 자연어 매칭 | description + 호출 시 인자 | matcher (PreToolUse/PostToolUse 등) + tool name regex |
| 사용자 직접 호출 | 가능 (`/`) | 불가 (간접) | 불가 (이벤트 기반) |
| 자동 재호출 | 새 트리거 발생 시 | orchestrator 가 결정 | 매 이벤트 발화 |
| 가시성 | 사용자에게 표시됨 | 사용자에게 진행 표시 | 보이지 않음 (silent) |

### §3.2 길이·톤 비교

| 차원 | 스킬 | 에이전트 |
|---|---|---|
| 본문 단어수(중앙값) | ~1,530 | ~425 |
| description 단어수(중앙값) | 49 | 27 (단순형) ~ 321 (예시 임베드형) |
| 페르소나 사용 | 드물게 ("You are a …" 거의 없음) | 거의 항상 ("You are an expert …") |
| 강한 명령(MUST/NEVER) | 메타 스킬에서 많음, 일반은 적음 | 거의 없음 (0~1회) |
| 출력 형식 명시 | 종종 ("Report structure"), 자유로움도 허용 | 매우 자주 ("Output Guidance", 구체 필드 나열) |
| 도구 노출 | 자주 생략 (default 전부) | 자주 명시 (read-only / read+write 등) |
| 모델 지정 | 생략 (런타임 모델) | 거의 항상 명시 (sonnet/opus/inherit) |

### §3.3 책임 경계

- **스킬**: 방법(method) 의 캡슐화. *"이런 일을 이렇게 한다"* 의 절차·체크리스트·참고 자료 묶음. 호출은 가볍고, 상태는 호출 컨텍스트에 머무름.
- **에이전트**: 책임(role) 의 캡슐화. *"이 영역의 전문가가 이 입력을 받아 이 출력만 낸다"*. 별도 컨텍스트 윈도우, 도구 권한 분리, 모델 선택까지 별도 결정.
- **훅**: 보장(guarantee) 의 자동화. *"이 이벤트가 발생하면 반드시 이 명령이 실행된다"*. Claude 의 추론에 의존하지 않고 runtime 이 강제.

**결정 트리** (헌법 §"Decision Framework" 에서 도출):

```
필요한 게 자연어 추론을 거치는 절차/지식인가?
  ├─ 사용자가 직접 호출하고 싶다 → 스킬 (User-only or default)
  └─ Claude 가 알아서 적용해야 한다 → 스킬 (Claude-only) 또는 페르소나 분리가 필요하면 에이전트
필요한 게 병렬 / 격리된 전문가 작업인가?
  └─ → 에이전트 (도구·모델 분리)
필요한 게 매 이벤트마다 결정론적으로 발생해야 하는가?
  └─ → 훅 (PreToolUse / PostToolUse / SessionStart / UserPromptSubmit)
```

---

## §4. 톤 분석

### §4.1 어조 스펙트럼

자원들을 인칭·강도 기준으로 배치하면:

```
  설명형 ←————————————————————————————————→ 명령형
  (헌법, claude-md-improver)        (writing-skills, brainstorming)
                  ↑                          ↑
              "Recommend X"            "You MUST", "MUST NOT"

  3인칭 객관          ←——————————————→        2인칭 페르소나
  (스킬 일반)                              (에이전트 일반)
                                          "You are an expert …"
```

### §4.2 단어 선택 데이터

| 표현 | 헌법 | skill-creator | writing-skills | brainstorming | 에이전트 평균 |
|---|---:|---:|---:|---:|---:|
| "Recommend" / "Suggest" | 다수 | 산문 | 산문 | 산문 | 0회 |
| "Use when" (description) | 0 | 0 | **권장 (CSO §1)** | 0 | 가끔 |
| "MUST" 대문자 | 0 | 3 | 4 | 4 | 0~1 |
| "Don't" / "Do not" | 1 | 16 | 15 | 7 | 0 |
| "Why this matters / Why" | 산재 | 산재 | 산재 | 산재 | 거의 없음 |
| 페르소나 ("You are …") | 0 | 0 | 0 | 0 | 7/7 |

### §4.3 톤 권고 (헌법 + skill-creator 합의)

1. **이유(Why) 를 설명하라**. 헌법의 "Value: [reason]" 패턴, skill-creator §"Writing Style" — *"explain to the model why things are important in lieu of heavy-handed musty MUSTs"*.
2. **MUST 는 규율 강제용 한정**. 메타 스킬(TDD/verification 등 discipline-enforcing) 에서만 사용. 일반 스킬·에이전트는 *Don't / Avoid / Prefer* 정도가 적정.
3. **금지는 구체적 회피 동작까지 적시** — writing-skills §"Close Every Loophole Explicitly" 의 "Delete it. Start over. **No exceptions:** Don't keep it as 'reference'. Don't 'adapt' it…" 패턴.
4. **에이전트는 페르소나로 시작**. *"You are an expert X specializing in Y"* — 7/7 에이전트가 이 패턴. 책임 영역 한정 + 자격 부여.
5. **스킬은 페르소나 없이 절차로 시작**. *"Help turn ideas into …"*, *"Audit, evaluate, and improve …"* 같이 동작 명사로. 6/6 스킬이 페르소나 없음.

---

## §5. MUST / MUST NOT / SHOULD / MAY — 헌법 기반 통합 가이드

### §5.1 스킬 작성

#### MUST (위반 시 자원이 작동하지 않거나 헌법 충돌)

| # | 항목 | 출처 |
|---|---|---|
| S-M1 | `name` 필드는 letters/numbers/hyphens 만 사용 (괄호·특수문자 금지) | C |
| S-M2 | `description` 은 frontmatter 에 포함 (트리거의 유일한 메커니즘) | C |
| S-M3 | `description` 은 3인칭으로 작성 | S (writing-skills CSO §1) |
| S-M4 | frontmatter 합계 1024자 이내 (YAML spec) | S |
| S-M5 | 부수 효과(deploy/commit/send/외부 호출) 가 있는 스킬은 `disable-model-invocation: true` 로 User-only 설정 | D (헌법 "Invocation Control") |
| S-M6 | Claude-only 백그라운드 지식 스킬은 `user-invocable: false` 명시 | D |
| S-M7 | 본문이 500 lines 를 넘어가면 references/ 디렉토리로 계층 분리 + 본 SKILL.md 에 포인터 명시 | S (skill-creator §"Progressive Disclosure") |

#### MUST NOT

| # | 항목 | 출처 |
|---|---|---|
| S-X1 | `description` 에 워크플로우 요약 포함 — Claude 가 본문을 안 읽고 description 만 따라 단축 실행하는 버그 발생 | S (writing-skills CSO "CRITICAL: Description = When to Use, NOT What the Skill Does") |
| S-X2 | `@path/to/file` 자동 로딩 링크 사용 — 200k+ 컨텍스트 강제 소비 | S (writing-skills §"no @ links") |
| S-X3 | 멀티 언어 동일 예시 나열 (example-js/py/go) — *"One excellent example beats many mediocre ones"* | S (writing-skills §"Anti-Patterns") |
| S-X4 | 한 스킬에 단일 책임 위반 — 다중 도메인은 references/ 로 분리, SKILL.md 는 선택자 역할만 | S (skill-creator §"Domain organization") |

#### SHOULD

| # | 항목 | 출처 |
|---|---|---|
| S-S1 | `description` 은 "Use when …" 으로 시작하거나 동치 트리거 조건으로 시작 | S |
| S-S2 | 본문에 "When to use / When NOT to use" 양면 가이드 명시 | C / S 합의 |
| S-S3 | 본문 길이는 getting-started 스킬 <150 words, 빈번 로딩 <200, 일반 <500 lines | S |
| S-S4 | 단어 선택: keyword coverage 를 위해 에러 메시지·증상·동의어를 본문에 포함 (검색 최적화) | S (writing-skills CSO §2) |
| S-S5 | flowchart 는 *비자명한 결정 지점에만* 사용; 참고 자료는 표/리스트 | S |
| S-S6 | 트리거 keyword 가 모호하다면 `should_trigger`/`should_not_trigger` eval set 으로 검증 | S (skill-creator §"Description Optimization") |
| S-S7 | description 약간 "pushy" 톤 — Claude 는 undertrigger 경향이 있음 | S (skill-creator) |

#### SHOULD NOT

| # | 항목 |
|---|---|
| S-N1 | 헌법이 권고하는 5종 카테고리 외의 자원 타입을 새로 발명하지 않는다 (Hooks/Subagents/Skills/Plugins/MCP 안에 들어와야 함) |
| S-N2 | description 에 1인칭("I can help…") 사용 |
| S-N3 | 본문에 narrative 회고("In session 2025-XX, we found…") |
| S-N4 | 한 스킬에 카테고리(C1) 의 다중 책임 — 예: 훅 등록 + 에이전트 호출 + 스킬 콘텐츠 를 한 스킬에 묶지 않음 |

#### MAY

- `tools: Read, Glob, Grep, Bash` 등 도구 명시적 축소 (부수 효과 있는 스킬에 권장)
- `context: fork` 로 격리 실행 (장시간·고비용 워크플로우)
- `allowed-tools` 로 추가 제한
- bundled `scripts/`, `references/`, `assets/` (skill-creator §"Anatomy")

---

### §5.2 에이전트 작성

#### MUST

| # | 항목 | 출처 |
|---|---|---|
| A-M1 | frontmatter 에 `name`, `description`, `model` 필수 (model 생략 시 런타임 의존, 비결정적) | C (Model Selection Guide) |
| A-M2 | description 의 첫 줄은 *언제 호출해야 하는가* (When to invoke) — 매칭의 일차 신호 | C / S |
| A-M3 | description 에 **negative case** 1건 이상 명시 — "Do NOT use for …" 또는 동치 ("nitpick → don't use" 등) | D (헌법 빌트인 Explore 의 "Do NOT use it for code review, design-doc auditing…") |
| A-M4 | 본문은 페르소나("You are …") 로 시작 + 책임 영역 한정 | S (7/7 에이전트 패턴) |
| A-M5 | 산출 가능한 부수 효과가 있다면(파일 쓰기·git 명령 등) `tools` 를 명시 제한 | D (subagent-templates "Tool Access Guide") |
| A-M6 | "Output Guidance / Output Format" 섹션으로 산출 구조 명시 (호출자가 파싱할 수 있도록) | C |

#### MUST NOT

| # | 항목 |
|---|---|
| A-X1 | 동일 에이전트가 분석 + 자동 수정 + 커밋 + 푸시까지 모두 수행 — 책임 분리 위반 |
| A-X2 | 모델을 항상 opus 고정 — 비용·지연 증가. 헌법: sonnet 기본, opus 는 복잡 케이스 한정 |
| A-X3 | description 에 호출 절차를 길게 기술 (호출 prompt 에서 전달되어야 할 정보) — description 은 트리거 결정용 |
| A-X4 | 다른 에이전트를 자동 디스패치 (오케스트레이션은 스킬/메인 세션의 책임) |

#### SHOULD

| # | 항목 | 출처 |
|---|---|---|
| A-S1 | 리뷰/분석 에이전트는 read-only (Read/Grep/Glob, 선택적으로 Bash) | C |
| A-S2 | 코드 생성·문서 작성 에이전트는 read+Write | C |
| A-S3 | 마이그레이션·인프라 에이전트만 read+Write+Bash (전체 권한) + opus | C |
| A-S4 | 리뷰 류는 **confidence scoring** 도입 + 임계값 게이트 (예: ≥80 만 보고) — false positive 제어 | S (feature-dev/code-reviewer, pr-review-toolkit/code-reviewer) |
| A-S5 | description 에 `<example>` 임베드는 트리거 모호성이 큰 도메인에서만 (e.g. "코드 리뷰" 처럼 공용 단어). 토큰 비용을 인지 | S (pr-review-toolkit/code-simplifier 의 desc 2,270자가 실제 사례) |
| A-S6 | "When to invoke" 섹션을 본문에 두고 3개 대표 시나리오 나열 | S (pr-review-toolkit 패턴) |
| A-S7 | CLAUDE.md 와 협력 관계라면 description 에 명시 ("checks against project guidelines in CLAUDE.md") | S |

#### SHOULD NOT

| # | 항목 |
|---|---|
| A-N1 | 모든 도구(`tools: *`) 노출 — catch-all (general-purpose) 같은 빌트인에만 정당화됨 |
| A-N2 | description 단어수 500 words 초과 (카탈로그가 매 세션 로드됨; 비용 누적) |
| A-N3 | 본문에 외부 시스템 인증 정보·secret reference 포함 |

#### MAY

- `color` (UI 표시 색) — feature-dev 처럼 같은 plugin 의 에이전트 그룹에 색 패밀리 부여
- `model: inherit` (호출자 모델 따라감) — pr-review-toolkit/comment-analyzer 사례
- 재호출 가이드 (claude-code-guide 의 "before spawning a new agent, check … SendMessage")

---

### §5.3 훅 작성

헌법 §"When to Recommend Hooks" + `references/hooks-patterns.md` 기반.

#### MUST

| # | 항목 | 출처 |
|---|---|---|
| H-M1 | settings.json 의 `hooks` 절에 등록되어야 실행됨 — 스크립트 파일 존재만으로는 작동 안 함 | D |
| H-M2 | `matcher` 로 트리거 도구를 명시 (예: `"Edit|Write"`) | D |
| H-M3 | 실패 시 silent fail (`exit 0`) — 사용자 작업 차단 금지. 차단이 목적인 경우(Pre 차단) 만 non-zero | D |
| H-M4 | 시크릿/락 파일 보호용 PreToolUse 훅은 정확한 path 매칭 사용 — 광범위 차단 금지 | D |

#### MUST NOT

| # | 항목 |
|---|---|
| H-X1 | 훅 안에서 long-running 작업 — 매 이벤트에 호출되어 누적 지연 발생. 비동기/백그라운드 큐로 분리 |
| H-X2 | stdin/stdout 의 hook JSON contract 무시 — hookSpecificOutput / additionalContext 등 표준 필드 사용 |
| H-X3 | 사용자 모르게 외부로 데이터 송신 |

#### SHOULD

| # | 항목 | 출처 |
|---|---|---|
| H-S1 | 포맷터/린터(`prettier`, `eslint`, `ruff`, `gofmt`, `rustfmt`)는 PostToolUse(Edit|Write) | D |
| H-S2 | 타입체커(`tsc --noEmit`, `mypy`)는 PostToolUse 로 비동기 검증 | D |
| H-S3 | UserPromptSubmit 훅으로 의도 라우팅 힌트 주입 — 키워드/cwd 기반 (단, additionalContext 로 1줄 이내) | S (본 가이드 §6 응용) |
| H-S4 | SessionStart 훅은 cwd 컨텍스트(activated agents/skills 요약)를 1회 주입 | S |

#### MAY

- `async: true` 로 비차단 실행
- 다중 hook 등록 (matcher 다른 단계로 분리)

---

## §6. 정량 권고 임계값 (cheat sheet)

| 자원 | 메트릭 | 권고치 | 절대 한계 | 근거 | 출처 종류 |
|---|---|---:|---:|---|---|
| 스킬 description | 글자 수 | ≤ 500 | 1024 (YAML frontmatter total) | writing-skills CSO §1 + spec | 규범 |
| 스킬 본문 | words | ≤ 500 (일반), ≤ 200 (빈번 로드), ≤ 150 (getting-started) | 5,200 (skill-creator 같은 극단 메타 스킬) | writing-skills §"Token Efficiency" | **규범** (본 표본 6 스킬의 측정 median 1,530 words 는 권고치를 초과 — 외부 가이드 인용임을 명시) |
| 스킬 본문 | lines | ≤ 500 | (계층 분리로 회피) | skill-creator §"Progressive Disclosure" | 규범 |
| 에이전트 description | words | 20–60 (단순형), ≤ 300 (예시 임베드형) | 500 | 본 표본 측정 분포 + 토큰 비용 추론 | 측정+추론 |
| 에이전트 본문 | words | 250–700 | 1,000 | 본 표본 측정 분포 (median 425, max 734) | 측정 |
| 에이전트 tools | 개수 | 3 (read-only) / 5–6 (생성) / 10+ (full) | — | 헌법 Tool Access Guide | 규범 |
| confidence scoring 임계값 | report cutoff | ≥ 80 | — | feature-dev / pr-review-toolkit 본 표본의 공통 규약 | 측정 (관행) |
| 훅 1회 실행 | wall time | ≤ 500 ms | 2 s | 누적 지연 예방 — 추론 권고 (벤치마크 없음) | 추론 |
| description 에 `<example>` | 개수 | 0 (단순), 1–3 (모호 영역) | 3 | pr-review-toolkit/code-simplifier 사례 (desc 2,270 chars / 321 words) | 측정 (사례) |

출처 종류 정의:
- **규범**: Anthropic 공식 자료(writing-skills, skill-creator, spec) 에서 직접 인용된 권고치. 본 표본 측정과 별개.
- **측정**: 본 표본 n=13 에서 관측된 분포로부터 도출.
- **추론**: 측정 없이 도메인 일반론에서 도출 (벤치마크로 검증되지 않음).

---

## §7. 정성 지표 — 작성 후 self-review 체크리스트

각 항목은 yes/no. 예외 정당화는 PR 설명에 기록.

### §7.1 모든 자원 공통

- [ ] frontmatter 의 `name`/`description` 이 있고 형식 규약 준수 (kebab-case, 1024자, 3인칭)
- [ ] 단일 책임 — 한 자원이 하나의 목적만 수행
- [ ] negative case (When NOT to use) 가 description 또는 본문에 1건 이상
- [ ] description 안에 워크플로우 요약 없음 (= 본문을 읽도록 유도)
- [ ] 본문에 산출 형식(Output / Report structure) 명시
- [ ] 의도된 호출자(사용자 / Claude / 다른 에이전트) 가 명확

### §7.2 스킬 전용

- [ ] invocation control (`disable-model-invocation`, `user-invocable`) 이 부수 효과·역할에 맞게 설정
- [ ] 본문 500 lines 초과 시 references/ 분리됨
- [ ] keyword coverage (에러 메시지·증상·도구명) 가 본문에 포함됨
- [ ] flowchart 는 *비자명 결정* 에만 사용
- [ ] `@path` 자동 로드 링크 사용하지 않음
- [ ] 멀티 언어 동일 예시 없음 (one excellent example)

### §7.3 에이전트 전용

- [ ] `model` 명시됨 (sonnet / opus / haiku / inherit 중 하나)
- [ ] `tools` 가 능력에 맞게 축소됨 (`*` 사용은 catch-all 한정)
- [ ] 본문 페르소나("You are an expert …") 로 시작
- [ ] When to invoke 에 3개 대표 시나리오 (또는 명시적 negative case)
- [ ] confidence scoring (리뷰/분석 류) 또는 명시적 출력 contract (생성 류)
- [ ] 다른 에이전트를 직접 디스패치하지 않음 (오케스트레이션은 호출자 책임)

### §7.4 훅 전용

- [ ] settings.json 의 `hooks` 절에 등록됨 (스크립트 존재만으로는 부족)
- [ ] matcher 가 정확한 도구/이벤트로 한정됨
- [ ] 실패 시 silent fail (`exit 0`); 차단이 의도라면 non-zero + 명시적 차단 메시지
- [ ] long-running 작업은 백그라운드로 분리
- [ ] 시크릿 송신·외부 데이터 유출 없음

### §7.5 디스커버리·라우팅 (헌법 §"Phase 3" 응용)

- [ ] 헌법의 5종 카테고리(Hooks/Subagents/Skills/Plugins/MCP) 중 하나에 정확히 속함
- [ ] 동일 사용자 의도에 대해 카테고리 간 책임 중복 없음
- [ ] 카테고리당 1–2개 우선 권고 원칙 (사용자가 더 요청 시 확장) 위배 없음

---

## §8. 안티패턴 카탈로그

작성 중 자기검열용. 실제 자료에서 발견되거나 위반 시점이 명확한 것만 수록.

| 안티패턴 | 증상 | 회피책 | 근거 |
|---|---|---|---|
| **Description-as-runbook** | description 에 본문 요약 — Claude 가 본문 안 읽고 description 만으로 동작 | description 은 트리거 조건만 (`Use when …`), workflow 는 본문에 | writing-skills CSO |
| **MUST-bombing** | 본문에 MUST/NEVER 가 20회 이상 — 모델이 압도되어 핵심 규율을 못 가림 | 메타·discipline 스킬에만 사용, 일반은 *Why* 로 설득 | skill-creator §"Writing Style" |
| **All-tools agent** | `tools: *` (또는 omit) — 리뷰 에이전트가 Write 권한 보유, 부수 효과 위험 | 능력에 맞게 명시적 축소 | 헌법 Tool Access Guide |
| **Always-opus** | 모든 에이전트가 opus — 비용·지연 누적 | sonnet 기본, opus 는 마이그레이션·아키텍처·복잡 추론에만 | 헌법 Model Selection Guide |
| **Plugin-as-bag-of-files** | 한 plugin 에 무관한 스킬·에이전트가 잡탕 | 카테고리·도메인별 plugin 분할 | C2 |
| **Hook-as-validator-then-blocker** | PostToolUse 훅이 실패 시 작업 차단 | Pre 차단은 PreToolUse 에서, Post 는 비동기 검증·리포트 | hooks-patterns.md |
| **Skill calling skill calling skill** | 한 스킬이 다른 스킬을 호출하고 그 안에서 또 다른 스킬 호출 — 디버깅 불가 | orchestrator 스킬은 명시적으로 자식 자원을 *나열*; 깊이 ≤ 2 | brainstorming + phase-pipeline 패턴 |
| **Description-bloat (`<example>` 폭주)** | description 이 2,000자 이상 — 카탈로그 토큰이 매 세션 비용 | 본문에 examples, description 은 트리거 조건 + 1개 example 까지 | pr-review-toolkit/code-simplifier 사례 |
| **Persona in skill / no persona in agent** | 스킬 본문이 "You are …" 로 시작 / 에이전트가 절차만 나열 | 스킬은 동작 명사, 에이전트는 페르소나로 시작 | 측정 분포 |
| **Dead asset** | 등록은 됐지만 호출 경로가 없는 에이전트/스킬 | 분기마다 호출 로그(session-events.db 등) 점검 + 회수 | 본 작업의 fe-reviewer 사례 |

---

## §9. 작성 워크플로우 — TL;DR

새 자원을 만들 때 이 순서로:

1. **카테고리 결정** (§3.3 결정 트리) — Hook / Subagent / Skill / Plugin / MCP 중 하나로.
2. **헌법의 1–2개 원칙 확인** — 이미 비슷한 권고가 있는지. 있으면 그대로 따른다.
3. **이름 짓기** — kebab-case 동사적 명사 (skill-creator §"Descriptive Naming"). 부르는 사람이 *언제 이걸 쓸지* 떠올릴 수 있는 이름.
4. **description 초안** — "Use when …" 으로 시작. trigger 조건 + 1개 negative case. 100–300자.
5. **본문 초안** — 스킬은 동작·체크리스트, 에이전트는 페르소나·책임·output contract. §6 임계값 안.
6. **frontmatter 보강** — 스킬: invocation control. 에이전트: model + tools. 훅: matcher + async.
7. **§7 self-review 체크리스트** 적용.
8. **트리거 eval (선택)** — `skill-creator` §"Description Optimization" 절차로 should/should-not 쌍 20개로 description 정밀도 측정.
9. **테스트** — writing-skills §"RED-GREEN-REFACTOR": 자원 없이 베이스라인 행동을 관찰한 뒤 자원 적용으로 행동이 바뀌는지 확인.
10. **deploy + 다음 사이클 회수 계획** — 호출 로그(예: session-events.db) 로 30일 후 dead asset 여부 확인.

---

## §10. 본 가이드의 적용 우선순위

본 가이드를 다른 작업(예: 본 유저 셋업의 skill/agent/hook 최적화) 에 적용할 때는 다음 순서로 충돌을 해소한다:

```
1순위. claude-automation-recommender (헌법)
2순위. 본 GUIDE.md (§5 의 MUST/MUST NOT 표)
3순위. writing-skills, skill-creator (메타 가이드)
4순위. 측정 데이터 (§1) — 실제 사례 분포
5순위. 사용자 CLAUDE.md (`~/.claude/CLAUDE.md`)
6순위. 프로젝트 로컬 CLAUDE.md
```

상위와 하위가 충돌하면 상위가 이긴다. 단, 사용자 명시 지시(CLAUDE.md 또는 직접 메시지) 는 모든 자동화 권고 위에 있다(브레인스토밍 스킬 §"Instruction Priority" 와 일치).

---

## §11. 작성 템플릿 (스켈레톤)

본 절은 §5 의 MUST/SHOULD 규칙과 §6 임계값을 그대로 만족하는 *최소 작동 스켈레톤* 이다. 그대로 복사한 뒤 `[대괄호]` 부분만 교체하면 §7 self-review 의 공통 항목을 통과한다. 출처: `skills/skill-creator/SKILL.md` §"Anatomy of a Skill" + `skills/writing-skills/SKILL.md` §"SKILL.md Structure" + `agents/feature-dev/code-architect.md` 등 본 표본 7개 에이전트 공통 골격.

### §11.1 스킬 SKILL.md 스켈레톤

```markdown
---
name: [skill-name-kebab-case]
description: Use when [구체적 트리거 조건·증상·맥락]. [선택: 기술 한정 트리거]. Do NOT use for [negative case 1건].
---

# [Skill Title]

## Overview
[이 스킬이 해결하는 핵심 문제 1–2 문장. 워크플로우 요약은 description 이 아닌 여기에.]

## When to Use
- [트리거 증상/상황 bullet 1]
- [트리거 증상/상황 bullet 2]

**When NOT to use**: [중복되는 다른 자원이 있거나 단순 직접 호출이 더 적절한 경우 — §5 S-M / §7 공통 #3 만족]

## Core Pattern
[해결 패턴 1개 — before/after 코드 또는 결정 트리. 멀티언어 동일 예시는 금지 (S-X3).]

## Quick Reference
| 상황 | 동작 |
|---|---|
| [case A] | [동작 A] |
| [case B] | [동작 B] |

## Implementation
[인라인 코드 또는 references/[file].md 포인터. 본문 500 lines 초과 시 references/ 로 분리 (S-M7).]

## Common Mistakes
- [흔한 실수 1 + 회피책]
- [흔한 실수 2 + 회피책]
```

**부수 효과(deploy / commit / send / 외부 호출) 가 있는 스킬은 frontmatter 에 다음을 추가** (S-M5):

```yaml
disable-model-invocation: true   # User-only 호출 강제
allowed-tools: Read, Bash        # 도구 명시 축소
```

**Claude-only 백그라운드 지식 스킬은** (S-M6):

```yaml
user-invocable: false
```

### §11.2 에이전트 `.md` 스켈레톤

```markdown
---
name: [agent-name-kebab-case]
description: [한 줄 책임 정의 — 동사로 시작]. When to invoke: [조건 1], [조건 2]. Do NOT use for [negative case 1건 — A-M3 만족].
tools: [Read, Grep, Glob]   # 리뷰/분석은 read-only / 생성은 +Write / 인프라만 +Bash (A-S1~A-S3)
model: sonnet               # sonnet 기본 / 복잡 추론·아키텍처는 opus / 단순 분류는 haiku (A-X2 회피)
color: [green|blue|...]     # 선택
---

You are a [페르소나 — 예: "senior software architect who delivers comprehensive blueprints"]. (A-M4)

## Core Process

**1. [단계 1 이름]**
[책임 영역 한정. 다른 에이전트를 디스패치하지 않음 (A-X4).]

**2. [단계 2 이름]**
[…]

**3. [단계 3 이름]**
[…]

## Output Guidance
[호출자가 파싱 가능한 산출 구조 명시 (A-M6). 예시:]

- **[Section 1]**: [무엇이 들어가는지]
- **[Section 2]**: [무엇이 들어가는지]
- **[Section 3]**: [무엇이 들어가는지]

[리뷰/분석 류는 confidence scoring 추가 (A-S4):]
> Report only items with confidence ≥ 80. For each: severity (P0/P1/P2), file:line, why.

## When to invoke (선택, 트리거 모호 도메인만 — A-S5)

<example>
Context: [상황 묘사].
User: "[발화]"
Assistant: "Using [agent-name] to [목적]."
</example>
```

**책임 분리 체크** (A-X1): 동일 에이전트가 *분석 + 자동 수정 + 커밋 + 푸시* 를 모두 하지 않는다. 다단계는 호출자(스킬/메인 세션) 가 오케스트레이션.

### §11.3 훅 `settings.json` 스니펫

`~/.claude/settings.json` 또는 `<project>/.claude/settings.json` 의 `hooks` 절에 등록 (H-M1).

**예시 1 — PostToolUse 포맷터** (H-S1):

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/format-on-edit.sh"
          }
        ]
      }
    ]
  }
}
```

스크립트 (`~/.claude/hooks/format-on-edit.sh`):

```bash
#!/usr/bin/env bash
# PostToolUse(Edit|Write) — 파일 확장자에 따라 포맷터 적용.
# 실패해도 사용자 작업 차단하지 않도록 항상 exit 0 (H-M3).
set -u
file_path="$(jq -r '.tool_input.file_path // empty')"
[[ -z "$file_path" ]] && exit 0

case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx|*.json) npx --yes prettier --write "$file_path" >/dev/null 2>&1 ;;
  *.py)                          ruff format "$file_path" >/dev/null 2>&1 ;;
  *.go)                          gofmt -w "$file_path" >/dev/null 2>&1 ;;
esac
exit 0
```

**예시 2 — PreToolUse 시크릿·락파일 차단** (H-M4):

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/block-sensitive.sh" }]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# PreToolUse(Edit|Write) — 민감 파일 차단. 차단이 목적이므로 non-zero exit 사용 (H-M3 예외).
set -u
file_path="$(jq -r '.tool_input.file_path // empty')"
case "$file_path" in
  */.env|*/.env.*|*/credentials.json|*/id_rsa|*/*.pem|*/package-lock.json|*/yarn.lock|*/pnpm-lock.yaml)
    echo "Blocked: $file_path is a protected file. Edit it manually or unblock via hook config." >&2
    exit 2 ;;
esac
exit 0
```

**예시 3 — UserPromptSubmit 라우팅 힌트 주입** (H-S3):

```jsonc
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/route-hint.sh" }]
      }
    ]
  }
}
```

```bash
#!/usr/bin/env bash
# UserPromptSubmit — cwd / 키워드 기반 라우팅 힌트 1줄 주입.
# 표준 hookSpecificOutput.additionalContext contract 사용 (H-X2 회피).
set -u
prompt="$(jq -r '.prompt // empty')"
cwd="$(pwd)"
hint=""
case "$prompt" in
  *리뷰*|*review*) hint="Hint: codex-review skill 또는 pr-review-toolkit:review-pr 고려" ;;
  *phase*|*사이클*) hint="Hint: phase-pipeline skill 활성화 후보" ;;
esac
[[ -z "$hint" ]] && { echo '{}'; exit 0; }
jq -n --arg c "$hint" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$c}}'
exit 0
```

**훅 체크리스트** (§7.4 재인용):
- [ ] settings.json 의 `hooks` 절에 등록됨
- [ ] matcher 가 정확한 도구·이벤트로 한정
- [ ] 실패 시 `exit 0` (차단 의도면 `exit 2` + stderr 메시지)
- [ ] 1회 실행 ≤ 500 ms (long-running 은 백그라운드)
- [ ] 시크릿/외부 데이터 송신 없음

### §11.4 trigger eval 스켈레톤 (선택, S-S6)

description 정밀도 측정을 위한 `skill-creator` 절차의 입력 포맷:

```jsonc
{
  "skill_name": "[skill-name]",
  "evals": [
    { "prompt": "[should_trigger 케이스 1 — 사용자가 자연어로 할 만한 발화]", "expected": "trigger" },
    { "prompt": "[should_trigger 케이스 2]", "expected": "trigger" },
    // … 총 10건
    { "prompt": "[should_not_trigger 케이스 1 — 비슷해 보이지만 다른 스킬이 적합]", "expected": "no" },
    // … 총 10건
  ]
}
```

실행은 `skill-creator` SKILL.md §"Running and evaluating test cases" 절차 (with-skill / baseline 두 그룹 동일 turn 에 spawn → 결과 비교).

---

## §12. 본 템플릿 사용 시 빠지기 쉬운 함정

§8 안티패턴 카탈로그를 §11 의 각 슬롯에 매핑:

| 슬롯 | 함정 | 회피 |
|---|---|---|
| 스킬 `description` | Description-as-runbook (워크플로우 요약) | "Use when …" + 트리거 조건만. 본문에 절차. |
| 스킬 본문 | MUST-bombing | 메타·discipline 스킬에만. 일반은 *Why* 로 설득. |
| 에이전트 `tools` | All-tools agent | 리뷰는 Read/Grep/Glob만. catch-all 만 `*`. |
| 에이전트 `model` | Always-opus | sonnet 기본. opus 는 마이그레이션·아키텍처·복잡 추론에만. |
| 에이전트 `description` | Description-bloat (`<example>` ≥3) | 1개까지. 나머지는 본문 "When to invoke" 절로. |
| 훅 시점 | PostToolUse 가 작업 차단 | 차단은 PreToolUse 에서만. Post 는 비동기 검증·리포트. |
| 스킬 ↔ 스킬 | Skill calling skill calling skill | 깊이 ≤ 2. orchestrator 는 자식 자원을 명시 나열. |
| 등록 | Dead asset | 분기별로 `session-events.db` 로 호출 0 자원 회수. |
