# Hook GAP: superpowers session-start

## 1. Metadata

```text
작성일: 2026-05-16
기준 버전: v2
검토자: Claude Opus 4.7
asset_type: hook
source_path: hooks/superpowers/
compared_against: CONSTITUTION.md, HOOK-GUIDE.md, GAP-FORMAT.md
final_decision: PASS_WITH_NOTES
```

## 2. Executive Summary

`SessionStart` 매처(`startup|clear|compact`)에서 한 번 실행되어 `using-superpowers` 스킬 본문을 `additionalContext`/`additional_context` 형태로 prompt 에 주입하는 훅이다. event 선택과 cross-platform 분기 처리, missing-bash silent no-op 등 방어적 패턴이 잘 잡혀 있다. 다만 (1) `using-superpowers` SKILL.md 전체를 매 세션마다 system context 에 박아넣는 것은 progressive disclosure 관점에서 무거운 선택이고, (2) `<EXTREMELY_IMPORTANT>` 와 `<important-reminder>` 같은 강한 표현이 실제 hard gate 가 아닌 routing hint 에 쓰이며, (3) `set -euo pipefail` 상태에서 `cat 2>&1 || echo` 로 stderr 까지 context 에 끌어와 외부 오류 메시지가 prompt 에 노출될 수 있는 미세한 경로가 있다. 이들은 모두 design principle 차원 P2-P3 이며 hard rule 위반은 없다.

## 3. Asset Snapshot

```text
type: hook
plugin: superpowers
event: SessionStart
matcher: startup|clear|compact
command: "${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start
script_lang: bash (polyglot cmd/bash wrapper) + bash script
async: false
registration: hooks/superpowers/hooks.json
scope: plugin-bundled (likely user/plugin scope, unknown without runtime check)
script_path: hooks/superpowers/session-start, hooks/superpowers/run-hook.cmd
has_path_filter: n/a (no tool_input.file_path; SessionStart event)
has_exit_policy: best-effort (exit 0 in all paths)
has_external_io: false (no network; reads local SKILL.md)
has_security_sensitive_behavior: partial (injects file content into prompt context)
```

## 4. Applicable Criteria

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context`
- `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`
- `HOOK-GUIDE.md §4 Event 선택` (SessionStart)
- `HOOK-GUIDE.md §6 Input Handling` (defensive read)
- `HOOK-GUIDE.md §7 Exit Behavior` (best-effort vs blocking)
- `HOOK-GUIDE.md §8 Security` (외부 송신 금지)
- `HOOK-GUIDE.md §9 Performance` (heavy work 동기 실행 여부)
- `HOOK-GUIDE.md §14 Version-Sensitive Details` (hookSpecificOutput schema)

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Event choice matches purpose | pass | SessionStart 가 매 session 시작 시 context 주입에 적합 |
| Matcher is narrow enough | pass | `startup\|clear\|compact` 로 명확히 한정 |
| Input handling is defensive | partial | runtime 의 stdin 을 직접 읽지는 않고 plugin file 만 읽음. `cat ... 2>&1 \|\| echo` 가 errexit 안에서 동작 |
| Effect and exit policy are clear | pass | 항상 exit 0; output 은 JSON context 주입만 |
| Security-sensitive behavior is safe | partial | 외부 송신 없음. 다만 file content + stderr 가 prompt context 로 들어감 (내부 reminder 라 위험 낮음) |
| External IO is absent or justified | pass | network 없음, local plugin file 만 읽음 |
| Performance impact is bounded | partial | SessionStart 1회/session 이라 빈도 낮으나 SKILL.md 전체를 항상 inline 주입 |
| Registration path is clear | pass | `hooks/superpowers/hooks.json` 에 등록, `${CLAUDE_PLUGIN_ROOT}` 경유 |
| Version-sensitive assumptions are marked | pass | 코드 주석이 platform 별 schema 차이(Cursor/Claude Code/Copilot)를 명시 |
| Behavior can be verified | partial | output JSON 을 직접 inspect 가능하나 매처 분기 테스트는 runtime 의존 |

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P2 | `CONSTITUTION.md §3.7` / `HOOK-GUIDE.md §4` | SKILL.md 본문 전체를 매 SessionStart 마다 context 에 inline 주입 | 짧은 pointer 또는 toc 만 주입하고 본문 로드는 Skill tool 에 위임 |
| GAP-002 | ASSET_GAP | P3 | `CONSTITUTION.md §3.8` | `<EXTREMELY_IMPORTANT>`, `<important-reminder>` 가 실제 gate 가 아닌 routing/legacy 경고에 사용 | 강한 표현은 hard gate 에 한정, 경고 톤은 일반 알림으로 약화 |
| GAP-003 | ASSET_GAP | P3 | `HOOK-GUIDE.md §8` | `cat "${...}/SKILL.md" 2>&1` 이 stderr 까지 context 에 합쳐져 prompt 에 노출될 수 있음 | `2>/dev/null` 로 stderr 분리하거나 read 실패 시 빈 문자열·일반 메시지로 fallback |
| GAP-004 | AMBIGUITY | P3 | `HOOK-GUIDE.md §14` | `hookSpecificOutput.hookEventName: "SessionStart"` schema 와 `additional_context` vs `additionalContext` 의 runtime 별 merge 동작을 단정할 수 없음 | runtime 별 동작 검증; 주석은 이미 양호 |

### GAP-001: Large skill body injected into every session context

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `CONSTITUTION.md §3.7 Progressive Disclosure Protects Context` / `HOOK-GUIDE.md §4 Event 선택` |

**Expected**

`SessionStart` 훅은 짧은 routing hint/요약/활성 자원 pointer 를 주입하는 것이 권장된다. 본문이 필요하면 Skill tool 로 on-demand 로드한다.

**Actual**

`session-start` 스크립트가 `cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md"` 를 통째로 escape 해서 `<EXTREMELY_IMPORTANT>` 블록 안에 inline 한다. session 마다 동일한 본문이 context 비용으로 누적된다.

**Evidence**

- `hooks/superpowers/session-start:18` — `using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md" ...)`
- `hooks/superpowers/session-start:35` — `session_context="<EXTREMELY_IMPORTANT>\n...${using_superpowers_escaped}\n..."`

**Impact**

매 startup/clear/compact 마다 같은 SKILL.md 본문이 context 에 들어가 token 비용을 증가시키고, 다른 자원 hint 가 들어갈 자리를 잠식한다. SKILL 본문이 길어질수록 누적 비용도 커진다.

**Recommendation**

asset 수정. 본문 inline 대신 (a) `using-superpowers` skill 의 핵심 instruction 만 발췌하거나, (b) "Skill 사용법은 `superpowers:using-superpowers` 를 호출하라" 수준의 짧은 pointer 만 inject 하도록 단순화한다.

### GAP-002: Strong language used for non-gate guidance

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates` |

**Expected**

`MUST`, `EXTREMELY_IMPORTANT`, `<important-reminder>` 같은 강한 표현은 안전·승인·secret 보호 같은 hard gate 에 쓴다. 일반 routing/legacy 알림은 normal tone.

**Actual**

스크립트는 모든 주입 본문을 `<EXTREMELY_IMPORTANT>` 로 감싸고, legacy `~/.config/superpowers/skills` 경고에 `<important-reminder>...⚠️ **WARNING:** ...IN YOUR FIRST REPLY ... YOU MUST TELL THE USER` 형태를 쓴다. 실제 안전 차단은 아니고 사용성 경고에 가깝다.

**Evidence**

- `hooks/superpowers/session-start:14` — `<important-reminder>...YOU MUST TELL THE USER:⚠️ **WARNING:** ...`
- `hooks/superpowers/session-start:35` — `<EXTREMELY_IMPORTANT>\nYou have superpowers.\n\n...`

**Impact**

강한 표현이 일상화되면 진짜 hard gate(예: secret 노출, destructive command)와 routing hint 의 우선순위가 흐려지고, 사용자가 강한 표현을 무시하는 학습이 생긴다.

**Recommendation**

asset 수정. legacy 경고는 일반 notice 톤으로 낮추고, 전체 wrapper 는 `<system-context>` 정도로 중립화한다. 강한 표현은 실제 안전 차단에 한정.

### GAP-003: stderr merged into prompt context on read failure

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `HOOK-GUIDE.md §8 Security` / `HOOK-GUIDE.md §6 Input Handling` |

**Expected**

훅이 prompt 로 주입하는 문자열은 의도된 본문만 포함해야 한다. 파일 read 실패 시 fallback 은 명시적이고 안전한 문자열이어야 한다.

**Actual**

`using_superpowers_content=$(cat "..." 2>&1 || echo "Error reading using-superpowers skill")` 가 stderr 를 stdout 으로 합치며 errexit 환경에서 동작한다. 만약 path 가 깨졌거나 권한 문제가 있으면 OS-specific 에러 메시지가 그대로 prompt context 에 들어간다.

**Evidence**

- `hooks/superpowers/session-start:18` — `using_superpowers_content=$(cat "${PLUGIN_ROOT}/skills/using-superpowers/SKILL.md" 2>&1 || echo "Error reading using-superpowers skill")`

**Impact**

극단적인 경우 환경 경로/권한 정보가 의도치 않게 모델 context 에 노출된다. 외부 송신은 없지만 model 입력으로는 들어간다. 위험도는 낮으나 일관성 측면에서 의도와 다르다.

**Recommendation**

asset 수정. `2>/dev/null` 로 stderr 를 버리고, read 실패 시 빈 문자열 또는 짧고 신뢰 가능한 fallback("(superpowers skill content unavailable)") 으로 대체한다.

### GAP-004: Runtime-specific output schema cannot be verified statically

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `HOOK-GUIDE.md §14 Version-Sensitive Details` |

**Expected**

훅의 output schema(`hookSpecificOutput`, `additional_context`, `additionalContext`) 는 runtime 마다 다르므로 검증 가능해야 한다.

**Actual**

스크립트는 `CURSOR_PLUGIN_ROOT`, `CLAUDE_PLUGIN_ROOT`, `COPILOT_CLI` 환경변수로 분기해 세 가지 schema 를 emit 한다. 각 schema 가 해당 runtime 에서 실제로 어떻게 merge 되는지(특히 Claude Code 의 `hookSpecificOutput` 과 `additional_context` 동시 인식 여부)는 정적으로 확인할 수 없다.

**Evidence**

- `hooks/superpowers/session-start:46-55` — 세 갈래 printf 분기
- 주석: `Claude Code reads BOTH additional_context and hookSpecificOutput without deduplication`

**Impact**

분기 자체는 합리적이지만, 주석이 단정 형태("reads BOTH ... without deduplication")여서 runtime 변경 시 stale 가능성이 있다.

**Recommendation**

asset 수정 + guide 보완. 코드 주석 톤을 "as of <version>" 으로 약화하거나 별도 docs 로 분리. HOOK-GUIDE 의 `§14 Version-Sensitive Details` 에 multi-runtime emit 패턴을 사례로 추가하면 유용(GUIDE_GAP 후보로도 고려).

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `.cmd` polyglot wrapper 가 길고 복잡함 | Windows/Unix 양쪽 지원과 `.sh` 자동 prepend 회피라는 명시적 이유가 주석으로 설명됨 |
| missing bash 시 silent exit 0 | 플러그인 기능이 일부만 동작해도 사용자 작업을 막지 않도록 의도된 fallback |
| `set -euo pipefail` 의 strict mode | 짧은 스크립트, 모든 분기에서 exit 0 보장됨 |
| SessionStart 외 다른 이벤트 미사용 | 의도된 단일 책임 |

## 8. Suggested Changes

### Asset Changes

- [ ] `session-start` 의 inline SKILL.md 주입을 짧은 pointer 또는 핵심 instruction 발췌로 축소 (GAP-001)
- [ ] `<EXTREMELY_IMPORTANT>` / `<important-reminder>` wrapper 톤을 routing hint 수준으로 낮추기 (GAP-002)
- [ ] `cat ... 2>&1` 를 `cat ... 2>/dev/null` 로 바꾸고 read 실패 fallback 을 안전 문자열로 고정 (GAP-003)
- [ ] runtime schema 주석을 "as of <date>" 형식으로 약화 (GAP-004)

### Guide Changes

- [ ] HOOK-GUIDE.md 에 multi-runtime hookSpecificOutput emit 패턴 예시 추가 검토 (GAP-004)
- [ ] HOOK-GUIDE.md 의 Asset Snapshot 필드가 GAP-FORMAT.md `§11.3` 에 정의되어 있으나, 본 가이드(HOOK-GUIDE.md) 본문에는 hook 별 Asset Snapshot 필드가 정의되어 있지 않음 — cross-reference 강화

### Constitution Review

- [ ] None

## 9. Follow-up Questions

- Claude Code runtime 이 `additional_context` 와 `hookSpecificOutput.additionalContext` 를 실제로 모두 읽고 dedup 하지 않는가? (코드 주석이 단정형)
- `using-superpowers` skill 의 본문이 SKILL tool 호출 없이 매 세션 inline 되어야 하는 강한 product 요구가 있는가? (있다면 GAP-001 은 INTENTIONAL_EXCEPTION)
- legacy `~/.config/superpowers/skills` 경고가 plugin v5.1.0 시점에서도 실효성이 있는가?

## 10. Final Decision

`PASS_WITH_NOTES`

이유: hard rule 위반 없음. 외부 송신 없음, exit policy 일관(exit 0), event/matcher 적절, cross-platform 분기 합리적. P2 GAP-001(progressive disclosure 비용)과 P3 표현/방어적 read 개선 여지만 남으며, 자산 목적과 충돌하지 않는다.
