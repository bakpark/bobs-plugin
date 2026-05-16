# Built-in Claude Code Agents

Claude Code 의 빌트인(코드 베이스 내장) 에이전트들. 별도 `.md` 파일이 없으므로 `Agent` 툴 카탈로그(시스템 프롬프트)에 노출된 설명을 그대로 옮긴다. 커스텀 에이전트 description 을 다듬을 때 참고용 — Anthropic이 빌트인에 권장하는 description / 도구 노출 / 사용 가이드의 reference 톤이다.

---

## general-purpose

> General-purpose agent for researching complex questions, searching for code, and executing multi-step tasks. When you are searching for a keyword or file and are not confident that you will find the right match in the first few tries use this agent to perform the search for you.

- Tools: `*` (모든 도구)
- 위치: built-in

## Explore

> Fast read-only search agent for locating code. Use it to find files by pattern (eg. "src/components/**/*.tsx"), grep for symbols or keywords (eg. "API endpoints"), or answer "where is X defined / which files reference Y." Do NOT use it for code review, design-doc auditing, cross-file consistency checks, or open-ended analysis — it reads excerpts rather than whole files and will miss content past its read window. When calling, specify search breadth: "quick" for a single targeted lookup, "medium" for moderate exploration, or "very thorough" to search across multiple locations and naming conventions.

- Tools: All tools except `Agent`, `ExitPlanMode`, `Edit`, `Write`, `NotebookEdit` (read-only)
- 위치: built-in

## claude-code-guide

> Use this agent when the user asks questions ("Can Claude...", "Does Claude...", "How do I...") about: (1) Claude Code (the CLI tool) — features, hooks, slash commands, MCP servers, settings, IDE integrations, keyboard shortcuts; (2) Claude Agent SDK — building custom agents; (3) Claude API (formerly Anthropic API) — API usage, tool use, Anthropic SDK usage. **IMPORTANT:** Before spawning a new agent, check if there is already a running or recently completed claude-code-guide agent that you can continue via SendMessage.

- Tools: `Bash`, `Read`, `WebFetch`, `WebSearch`
- 위치: built-in

## Plan

> Software architect agent for designing implementation plans. Use this when you need to plan the implementation strategy for a task. Returns step-by-step plans, identifies critical files, and considers architectural trade-offs.

- Tools: All tools except `Agent`, `ExitPlanMode`, `Edit`, `Write`, `NotebookEdit` (read-only, planning only)
- 위치: built-in

---

## 빌트인이 보여주는 best practice

1. **이름은 동사가 아니다** — `general-purpose`, `Explore` (특화) 가 아니라 능력 묘사. 커스텀 에이전트도 `do-XYZ` 같은 동작형 이름보다 역할(`code-reviewer`, `feature-developer`) 가 좋다.
2. **description 은 "언제 호출할지" + "언제 호출하지 말지" 양쪽을 명시** — Explore 의 "Do NOT use it for code review …" 라인이 대표. 커스텀 description 도 negative 케이스를 적시하면 라우팅 정확도가 올라간다.
3. **도구 노출은 능력에 맞게 축소** — Explore 는 read-only 전용, claude-code-guide 는 4개로 제한. `tools: *` 는 general-purpose 같은 catch-all 에만.
4. **호출 가이드는 description 안에 직접** — Explore 의 "specify search breadth: quick/medium/very thorough" 처럼 호출자에게 파라미터 힌트를 description 으로 노출하면 prompt 설계 부담이 줄어든다.
5. **재호출/이어가기 안내** — claude-code-guide 의 "Before spawning a new agent, check … SendMessage" 처럼 동일 에이전트 재사용 가이드를 명시. 비싼 에이전트는 이 패턴이 필수.
