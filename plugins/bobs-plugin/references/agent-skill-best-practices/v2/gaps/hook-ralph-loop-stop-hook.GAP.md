# Hook GAP: ralph-loop stop-hook

## 1. Metadata

```text
작성일: 2026-05-16
기준 버전: v2
검토자: Claude Opus 4.7
asset_type: hook
source_path: hooks/ralph-loop/
compared_against: CONSTITUTION.md, HOOK-GUIDE.md, GAP-FORMAT.md
final_decision: PASS_WITH_NOTES
```

## 2. Executive Summary

`Stop` 이벤트에 반응해 `.claude/ralph-loop.local.md` state 파일이 존재하면 `decision: block` 을 emit 하고 같은 prompt 를 model 에 재주입해 self-referential loop 를 유지하는 훅이다. 즉 hook 의 본질이 "auto-loop trigger" 이며 이는 일반적으로는 위험한 자동화이지만, ralph-loop 플러그인의 핵심 design 으로 명시되어 있어 `INTENTIONAL_EXCEPTION` 으로 분류된다.

방어적 패턴이 풍부하다: max iterations cap, numeric 검증, session-id mismatch fall-through, transcript missing handling, jq 실패 graceful exit, state file 손상 시 정리, atomic rename via temp file. 그러나 (1) `hooks.json` 에 matcher 가 없어 모든 Stop 이벤트에 hook 이 attach 되고, (2) session-isolation 이 *file 존재여부* 와 *session_id field* 두 단계에만 의존하며, (3) `set -euo pipefail` 상태에서 `||` 분기 일부 (예: `|| true` 한 군데, 나머지는 grep no-match 시 errexit 위험), (4) state 파일이 project-scoped 경로 `.claude/ralph-loop.local.md` 에 의존하는데 hook 실행 cwd 가설을 단정한다. 모두 P2 이하다.

## 3. Asset Snapshot

```text
type: hook
plugin: ralph-loop
event: Stop
matcher: none (모든 Stop)
command: bash "${CLAUDE_PLUGIN_ROOT}/hooks/stop-hook.sh"
script_lang: bash
async: false (Stop hook 은 일반적으로 sync, runtime-dependent)
registration: hooks/ralph-loop/hooks.json
scope: plugin-bundled
script_path: hooks/ralph-loop/stop-hook.sh
has_path_filter: n/a (Stop event has no tool path)
has_exit_policy: blocking-by-design (emits `decision: block` JSON; exit 0 in all script paths)
has_external_io: false (reads transcript file + state file; no network)
has_security_sensitive_behavior: partial (auto-loop continuation; reads transcript JSONL; deletes state file)
```

## 4. Applicable Criteria

- `CONSTITUTION.md §3.1 Activation Must Be Explicit`
- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.9 Behavior Must Be Verifiable`
- `HOOK-GUIDE.md §4 Event 선택` (Stop)
- `HOOK-GUIDE.md §5 Matcher 설계`
- `HOOK-GUIDE.md §6 Input Handling`
- `HOOK-GUIDE.md §7 Exit Behavior`
- `HOOK-GUIDE.md §8 Security` (auto-execution, destructive command)
- `HOOK-GUIDE.md §14 Version-Sensitive Details` (Stop hook decision/block schema)

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Event choice matches purpose | pass | Stop 이벤트가 self-referential loop 의 자연스러운 trigger 점 |
| Matcher is narrow enough | partial | matcher 미지정 — Stop 의 sub-matcher 가 runtime 에 있는지 불명. 다만 state file 게이트로 보완 |
| Input handling is defensive | partial | numeric 검증·missing file·empty 분기는 처리하나 `set -euo pipefail` 아래 frontmatter grep 3줄과 jq 두 군데(`HOOK_SESSION`, `TRANSCRIPT_PATH`)에 실패 fallback 없음 — GAP-003 참고 |
| Effect and exit policy are clear | pass | block 결정과 reason 주입이 명시적 JSON 출력 |
| Security-sensitive behavior is safe | partial | auto-loop 라는 design 자체가 위험 카테고리이나 명시적 opt-in(state file)과 max iteration cap 으로 제한 |
| External IO is absent or justified | pass | 네트워크 없음, project-local transcript/state 만 사용 |
| Performance impact is bounded | pass | tail -n 100 으로 jq input 제한, perl regex 1회 |
| Registration path is clear | pass | `hooks/ralph-loop/hooks.json` 에 등록 |
| Version-sensitive assumptions are marked | partial | "advanced stop hook API" 주석만 있고 schema/version 명시 없음 |
| Behavior can be verified | pass | state file 존재 여부, iteration 카운트, promise 매칭 등 검증 가능 포인트 다수 |

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | INTENTIONAL_EXCEPTION | P1→accepted | `CONSTITUTION.md §3.3` | Stop 훅이 자동 loop 를 trigger 하는 destructive automation 카테고리 | 명시적 opt-in(state file) + iteration cap + promise gate 가 있으므로 예외 인정 |
| GAP-002 | ASSET_GAP | P2 | `HOOK-GUIDE.md §5` | matcher 미지정으로 Stop 이벤트 전체에 attach | state file gate 로 보완되나 hooks.json 에 명시적 matcher 또는 description 추가 |
| GAP-003 | ASSET_GAP | P2 | `HOOK-GUIDE.md §6` | `bash -euo pipefail` 에서 frontmatter grep 3줄과 jq 2줄에 실패 fallback 없음 — 누락 시 assignment 실패로 numeric 검증 전에 exit 1 | 모든 grep/jq 분기에 `\|\| true` 또는 명시적 default 값, 혹은 jq/awk 일원화 |
| GAP-004 | AMBIGUITY | P2 | `HOOK-GUIDE.md §14` | Stop hook 의 `decision: block` + `reason` schema 가 runtime 마다 동일한지 불명 | 명세 링크 또는 "Claude Code <version>+" 주석 추가 |
| GAP-005 | ASSET_GAP | P3 | `HOOK-GUIDE.md §8` | state file 경로 `.claude/ralph-loop.local.md` 가 hook cwd 에 상대 의존 | absolute path 도출 또는 hook input 의 `cwd` field 사용 |

### GAP-001: Auto-loop trigger is an intentional but high-risk design

| Field | Value |
|---|---|
| Type | INTENTIONAL_EXCEPTION |
| Severity | accepted (would be P1 absent the design choice) |
| Guide ref | `CONSTITUTION.md §3.3 Effects Require Gates` / `HOOK-GUIDE.md §8 Security` |

**Expected**

훅이 자동 행동을 trigger 하는 경우 명시적 opt-in, 짧은 실행 경로, 사용자 가시성, 종료 조건이 필요하다.

**Actual**

Stop 훅이 `.claude/ralph-loop.local.md` 가 있으면 매번 `decision: block` 으로 session 종료를 막고 동일 prompt 를 재주입한다. 즉, 사용자가 명시적으로 멈출 때까지 model 이 계속 실행된다.

**Evidence**

- `hooks/ralph-loop/stop-hook.sh:14-18` — state file 부재 시 즉시 exit 0 (opt-in gate)
- `hooks/ralph-loop/stop-hook.sh:61-65` — max iterations cap
- `hooks/ralph-loop/stop-hook.sh:129-142` — `<promise>...</promise>` 완료 조건
- `hooks/ralph-loop/stop-hook.sh:181-188` — `decision: block`, `reason`, `systemMessage` emit

**Impact**

자동 loop 는 모델 비용·시간·side-effect 누적 측면에서 위험이 크다. 그러나 (a) state file 이라는 explicit opt-in, (b) max_iterations cap, (c) completion promise 매칭, (d) iteration counter on-disk 라는 다층 gate 가 있어 design 의도와 일치한다.

**Recommendation**

자산 변경 없음. `INTENTIONAL_EXCEPTION` 로 기록. README/플러그인 문서가 위험성과 정지 방법을 명시한다는 전제 하에 수용.

### GAP-002: Matcher omitted in hooks.json

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `HOOK-GUIDE.md §5 Matcher 설계` |

**Expected**

훅은 가능한 좁은 matcher 로 한정한다. Stop event 는 일반적으로 sub-matcher 가 적지만, 어떤 Stop 에서 동작해야 하는지 의도가 등록 파일에 드러나야 한다.

**Actual**

`hooks.json` 의 Stop entry 에 `matcher` field 가 없어 모든 Stop event 에 hook 이 부착된다. state file 게이트로 사실상 빠르게 no-op 하지만, 등록 자체는 광범위하다.

**Evidence**

- `hooks/ralph-loop/hooks.json:4-12` — `"Stop": [{ "hooks": [...] }]`, matcher 없음

**Impact**

state file 부재 시에도 매 Stop 마다 bash, jq, sed, perl 가 invoke 된다. 빈도가 낮으면 미미하지만, "matcher 없는 전역 훅은 비용과 부작용을 설명할 수 있을 때만 사용" 원칙을 따르려면 명시적 의도 표시가 필요하다.

**Recommendation**

asset 수정. (a) Stop event 의 sub-matcher 가 runtime 에서 지원된다면 좁히고, (b) 지원되지 않는다면 `description` field 와 함께 "no matcher: gated by state file" 주석을 hooks.json 에 추가.

### GAP-003: grep/jq pipelines miss fallback under set -euo pipefail

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `HOOK-GUIDE.md §6 Input Handling` |

**Expected**

`set -euo pipefail` 환경에서 optional field 추출은 명시적 fallback 을 가져야 한다. 실패 시 assignment 가 비정상 종료시키지 않도록 `|| true`, `|| echo ""` 또는 jq 의 `// ""` 형태로 안전 분기를 둔다.

**Actual**

```bash
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/...//')
...
HOOK_SESSION=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')
...
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')
```

세 grep 분기와 두 jq 분기 모두 fallback 이 없다. `STATE_SESSION` 줄만 `|| true` 가 붙어 있어 일관성도 깨진다. `set -euo pipefail` 아래에서는 `var=$(failing-cmd)` assignment 가 exit 1 로 즉시 종료되어 후속 numeric 검증·error 메시지 분기까지 도달하지 못한다.

**Evidence**

- `hooks/ralph-loop/stop-hook.sh:22-25` — iteration/max/promise grep, fallback 없음
- `hooks/ralph-loop/stop-hook.sh:31` — session_id grep 에만 `|| true`
- `hooks/ralph-loop/stop-hook.sh:32` — `HOOK_SESSION` jq, fallback 없음
- `hooks/ralph-loop/stop-hook.sh:68` — `TRANSCRIPT_PATH` jq, fallback 없음

**Impact**

frontmatter 의 field 가 빠지거나 jq 가 비정상 입력을 받으면 hook 이 numeric 검증·corruption 메시지·정상 cleanup 으로 가지 못하고 침묵 종료한다. 사용자는 loop 가 왜 멈췄는지 알 수 없고, state file 도 그대로 남는다.

**Recommendation**

asset 수정. 세 grep 줄과 두 jq 줄 모두 `|| true` 또는 명시적 default 추가. 또는 frontmatter 파싱을 jq/awk 로 일원화해 missing field semantics 를 한 곳에서 처리.

### GAP-004: Stop hook output schema is version-dependent and not annotated

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P2 |
| Guide ref | `HOOK-GUIDE.md §14 Version-Sensitive Details` |

**Expected**

훅이 emit 하는 control JSON (`decision`, `reason`, `systemMessage`) 의 schema 는 runtime 의존이며, 가정한 버전이 주석/문서에 남아 있어야 한다.

**Actual**

스크립트 1행 주석에 `Stop Hook ... Feeds Claude's output back as input to continue the loop` 만 있고, `decision: block` schema 가 Claude Code 의 어느 버전에서 지원되는지 표시가 없다. `# Read hook input from stdin (advanced stop hook API)` 주석은 있지만 버전 미명시.

**Evidence**

- `hooks/ralph-loop/stop-hook.sh:1-11` — 헤더 주석
- `hooks/ralph-loop/stop-hook.sh:181-188` — `decision`/`reason`/`systemMessage` JSON

**Impact**

runtime upgrade 시 schema 변경이 발생하면 hook 이 silent fail 할 수 있다(block 대신 무시될 수 있음). 검증할 reference 가 코드에 없다.

**Recommendation**

asset 수정. 주석에 "Verified against Claude Code <version>+" 또는 docs link 추가. HOOK-GUIDE.md `§14` 항목과 일관.

### GAP-005: State file path is cwd-relative

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `HOOK-GUIDE.md §8 Security` / `CONSTITUTION.md §3.1` |

**Expected**

훅이 활성화 여부를 판단하는 sentinel 파일은 활성화 조건이 명확해야 하며 runtime cwd 가정을 단정하지 않는다.

**Actual**

```bash
RALPH_STATE_FILE=".claude/ralph-loop.local.md"
```

이 상대경로는 hook 실행 시 cwd 가 project root 라는 가정에 의존한다. Stop hook input 의 `cwd` field 또는 transcript path 의 project root 도출 같은 신호를 쓰지 않는다.

**Evidence**

- `hooks/ralph-loop/stop-hook.sh:13` — `RALPH_STATE_FILE=".claude/ralph-loop.local.md"`

**Impact**

다른 cwd 에서 Stop hook 이 실행되면 state file 을 못 찾아 loop 가 silent 종료된다. 반대로 다른 프로젝트 root 에서 우연히 동일 파일이 존재하면 잘못된 loop 가 시작될 수 있다. 후자는 가능성이 낮으나 명시적 가드가 없다.

**Recommendation**

asset 수정. hook input 의 `cwd` 또는 `transcript_path` 에서 project root 를 도출해 absolute path 로 state file 을 찾도록 보강.

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| Stop hook 이 model 동작을 차단하고 prompt 를 재주입함 | ralph-loop 플러그인의 핵심 design; 명시적 opt-in 과 cap 으로 보호됨 |
| atomic write via `${RALPH_STATE_FILE}.tmp.$$` + mv | concurrent write 회피를 위한 합리적 패턴 |
| transcript JSONL 의 마지막 100 assistant lines 만 처리 | bounded performance, 합리적 절충 |
| state file 손상 시 rm + exit 0 | corruption recovery 로 안전한 선택 |

## 8. Suggested Changes

### Asset Changes

- [ ] hooks.json 의 Stop entry 에 sub-matcher 또는 명시적 description 추가 (GAP-002)
- [ ] grep|sed frontmatter 추출에 `|| true` 일관 적용 또는 jq/awk 단일화 (GAP-003)
- [ ] decision/block schema 의 verified-against 버전 주석 추가 (GAP-004)
- [ ] state file path 를 hook input cwd 기반 absolute 로 변경 (GAP-005)

### Guide Changes

- [ ] HOOK-GUIDE.md 에 "auto-loop trigger" 패턴의 안전 요건(opt-in gate, max cap, completion gate, visibility) 사례 추가 (GAP-001 의 일반화)
- [ ] HOOK-GUIDE.md `§14 Version-Sensitive Details` 에 Stop hook 의 `decision`/`reason`/`systemMessage` schema 가 version-sensitive 임을 명시

### Constitution Review

- [ ] None (auto-loop 는 hook 한정 design 으로 type-specific 가이드에서 다루는 게 적합)

## 9. Follow-up Questions

- Claude Code runtime 이 Stop hook 의 sub-matcher 를 지원하는가? (지원되면 matcher 좁히기 가능)
- ralph-loop README 가 "Stop hook 이 session 종료를 차단할 수 있음"을 사용자에게 충분히 알리는가?
- max_iterations=0 (무한)이 design 상 의도된 옵션인가? (그렇다면 강력한 경고 필요)
- transcript_path 가 항상 hook input 에 존재하는 runtime 인가?

## 10. Final Decision

`PASS_WITH_NOTES`

이유: auto-loop design 이라는 본질적 위험이 있으나 명시적 state-file opt-in, max iteration cap, completion promise gate, session_id isolation, transcript-missing graceful exit 등 다층 guard 가 잘 갖춰져 있다. 외부 송신 없음, exit policy 명확. matcher/path/version 주석 보강(P2-P3)만 권장.
