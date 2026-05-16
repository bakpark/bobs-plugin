# Hook GAP: security-guidance security_reminder_hook

## 1. Metadata

```text
작성일: 2026-05-16
기준 버전: v2
검토자: Claude Opus 4.7
asset_type: hook
source_path: hooks/security-guidance/
compared_against: CONSTITUTION.md, HOOK-GUIDE.md, GAP-FORMAT.md
final_decision: REVISE_ASSET
```

> Note: 이 리포트 작성 중 같은 훅이 본 GAP 본문의 substring 매칭에 걸려 Write 작업을 2회 차단한 실증 사례가 발생했다. 자세한 내용은 GAP-001 Evidence 참조. 이 리포트의 본문은 차단을 회피하기 위해 위험 키워드를 직접 적지 않고 추상적으로 기술한다.

## 2. Executive Summary

`PreToolUse` (`Edit|Write|MultiEdit`) 에서 Python 스크립트를 실행해 파일 내용/경로에 보안 위험 substring 이 있으면 차단 exit code 로 tool 실행을 막고 reminder 를 stderr 로 출력하는 훅이다. 외부 송신 없음, 환경변수(`ENABLE_SECURITY_REMINDER=0`) 로 disable 가능, session 단위 dedup state file 관리 등 합리적 설계가 잡혀 있다.

그러나 (1) **blocking vs advisory 가 충돌**: HOOK-GUIDE.md 권장은 "best-effort 이면 차단하지 않음" 이고 advisory reminder 는 best-effort 카테고리인데 이 훅은 차단 exit 로 동작한다. (2) **substring 기반 false positive 가 광범위**: 위험 키워드가 주석, 변수명, docstring, 분석 본문에도 매칭되어 정상 작업을 막는다. (3) **MultiEdit 의 새 형식 미지원 위험**: tool_input 에서 `edits` 배열을 가정하나 schema 변동에 약함. (4) **state file 경로가 `~/.claude/` 에 산재**: dedup state 파일이 session 마다 별도 생성되어 30일 cleanup 의존, 비결정적. (5) **에러 로그를 `/tmp/security-warnings-log.txt` 에 임의 append**: 다른 user 와 공유될 수 있는 경로.

가장 큰 문제는 advisory reminder 가 강제 차단 모드라는 점이다. 사용자 작업 흐름을 막는 false positive 가 누적될 수 있고, HOOK-GUIDE.md 의 "false positive 가 많아 사용자의 작업 흐름을 자주 막는 작업" anti-pattern 에 해당한다. 본 리포트 작성 자체가 두 차례 차단되어 영향이 실증되었다.

## 3. Asset Snapshot

```text
type: hook
plugin: security-guidance
event: PreToolUse
matcher: Edit|Write|MultiEdit
command: python3 ${CLAUDE_PLUGIN_ROOT}/hooks/security_reminder_hook.py
script_lang: python3
async: false
registration: hooks/security-guidance/hooks.json
scope: plugin-bundled
script_path: hooks/security-guidance/security_reminder_hook.py
has_path_filter: partial (path-based rule: GitHub Actions workflow path)
has_exit_policy: blocking (block-coded exit on first match; exit 0 otherwise; opt-out via env)
has_external_io: partial (writes to /tmp log and ~/.claude state files)
has_security_sensitive_behavior: yes (reads tool_input content; blocks Edit/Write/MultiEdit)
```

## 4. Applicable Criteria

- `CONSTITUTION.md §3.3 Effects Require Gates`
- `CONSTITUTION.md §3.4 Output Is A Contract`
- `CONSTITUTION.md §3.5 Capability Surface Must Match Responsibility`
- `CONSTITUTION.md §3.8 Strong Language Belongs To Real Gates`
- `HOOK-GUIDE.md §1 훅의 역할` (false positive anti-pattern)
- `HOOK-GUIDE.md §6 Input Handling`
- `HOOK-GUIDE.md §7 Exit Behavior` (blocking vs best-effort)
- `HOOK-GUIDE.md §8 Security` (pattern as security boundary; tmp file)
- `HOOK-GUIDE.md §13 Anti-Patterns`
- `HOOK-GUIDE.md §14 Version-Sensitive Details`

## 5. Checks

| Check | Status | Notes |
|---|---|---|
| Event choice matches purpose | pass | PreToolUse 가 Edit/Write/MultiEdit 차단에 적합 |
| Matcher is narrow enough | pass | `Edit\|Write\|MultiEdit` 로 한정 |
| Input handling is defensive | partial | JSON decode 실패 시 exit 0, tool_name 검증, file_path 검증. 단 MultiEdit 의 edits schema 가 고정 가정 |
| Effect and exit policy are clear | gap | advisory reminder 임에도 차단 exit. blocking 의도라면 명확한 안전 라벨/사용자 가시성 필요 |
| Security-sensitive behavior is safe | partial | substring 으로 차단 — defense-in-depth 만이어야 하나 실제로는 hard block |
| External IO is absent or justified | partial | network 없음. 다만 `/tmp` debug log 와 `~/.claude/` 산재 |
| Performance impact is bounded | pass | 단일 파일 content 만 검사, 빠른 early return |
| Registration path is clear | pass | `hooks/security-guidance/hooks.json` 에 등록 |
| Version-sensitive assumptions are marked | gap | runtime 별 차단 exit code semantics 가 가정만 있고 버전 표기 없음 |
| Behavior can be verified | partial | rule 매칭은 검증 가능하나 dedup state 가 session 단위로 silent 사이드이펙트 |

## 6. Findings

| ID | Type | Severity | Guide Ref | Summary | Recommendation |
|---|---|---|---|---|---|
| GAP-001 | ASSET_GAP | P1 | `HOOK-GUIDE.md §1` / `§7` / `§13` | advisory reminder 가 hard block 으로 동작; false positive 가 사용자 작업을 차단 (실증됨) | warn-only(stderr + exit 0) 모드를 기본으로, opt-in 환경변수로만 차단 |
| GAP-002 | ASSET_GAP | P2 | `HOOK-GUIDE.md §8` | substring 매칭이 보안 경계로 사용됨 (위험 키워드가 주석/변수명에도 매칭) | substring 룰을 advisory 톤으로 강등하고 documentation 으로 위치 변경 |
| GAP-003 | ASSET_GAP | P3 | `HOOK-GUIDE.md §8` | `/tmp` 공유 경로에 권한 검증 없이 debug 로그 append | `~/.claude/logs/` 등 user-scope 경로로 이동, 또는 default 로 disable |
| GAP-004 | ASSET_GAP | P3 | `HOOK-GUIDE.md §6` | MultiEdit 의 `edits` 배열 schema 를 고정 가정; runtime schema 변경에 약함 | schema validation 또는 graceful fallback 추가 |
| GAP-005 | AMBIGUITY | P3 | `HOOK-GUIDE.md §14` | 차단 exit code 가 PreToolUse 차단으로 동작한다는 가정이 runtime 별로 동일한지 불명 | 주석에 verified-against 버전 명시 |
| GAP-006 | ASSET_GAP | P3 | `CONSTITUTION.md §3.3` / `§3.5` / `HOOK-GUIDE.md §8` / `§9` | dedup state 가 session 별 별도 파일로 산재, 30일 cleanup 의존, 비결정적 정리 | XDG_STATE_HOME 또는 단일 SQLite/JSON file 로 통합 |
| GAP-007 | ASSET_GAP | P3 | `CONSTITUTION.md §3.8` | "Security Warning" 표현이 일관되게 강하나 실제 block 의 정당성은 rule 별로 다름 | rule 별 severity 분리 (advisory vs hard block) |

### GAP-001: Advisory reminder enforces hard block on first match

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P1 |
| Guide ref | `HOOK-GUIDE.md §1 훅의 역할` / `§7 Exit Behavior` / `§13 Anti-Patterns` |

**Expected**

HOOK-GUIDE.md §1: 훅에 부적합한 것 중 "false positive 가 많아 사용자의 작업 흐름을 자주 막는 작업". §7: best-effort 검증은 차단하지 않는다. §13: pattern 을 security boundary 로 쓰는 것은 anti-pattern. advisory reminder 는 stderr + exit 0 권장.

**Actual**

스크립트는 첫 substring 매칭 시 stderr 로 reminder 를 출력하고 차단 exit code 로 종료해 Edit/Write/MultiEdit 를 차단한다. dedup state 로 같은 file+rule 조합은 session 당 1회만 차단되긴 하지만, 처음 trigger 시점에 사용자의 정상 작업이 막힌다.

**Evidence**

- `security_reminder_hook.py` 의 main() 마지막 분기 — `print(reminder, file=sys.stderr)` 후 차단 exit code 호출
- `security_reminder_hook.py` 의 `SECURITY_PATTERNS` — Python 직렬화 모듈 이름, JS dynamic-eval 키워드, shell-spawn 라이브러리 식별자, DOM injection 키워드 등 다수 substring 룰
- 실증: 본 GAP 리포트의 이전 작성 시도가 본문에 포함된 substring 때문에 Write tool 호출이 두 번 차단됨 (PreToolUse:Write hook error 메시지 수신)

**Impact**

위험 키워드가 변수명, 주석, docstring, import 별칭 어디에도 나타날 수 있어 false positive 가 광범위하다. 본 리포트의 자기검증에서 보듯 "보안 분석을 위한 GAP 리포트 작성" 도 차단된다. 첫 매칭 차단은 사용자가 의도한 작업을 강제로 가로막고 "reminder" 가 아닌 "blocker" 로 동작한다. HOOK-GUIDE.md 의 명시적 anti-pattern.

**Recommendation**

asset 수정. 기본 모드를 advisory(stderr + exit 0)로 전환. 차단이 필요하다면 별도 `ENABLE_SECURITY_BLOCK=1` opt-in 환경변수로 분리. 사용자가 "한 번 dismiss 하면 같은 file 에서 안 보임" 같은 UX 도 가능.

### GAP-002: Substring matching used as security boundary

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P2 |
| Guide ref | `HOOK-GUIDE.md §8 Security` / `§13 Anti-Patterns` |

**Expected**

pattern 기반 차단은 defense-in-depth 로만. AST/syntax 기반 분석이나 reviewer 가이드의 일부로 위치.

**Actual**

`<keyword> in content` 형태의 순수 substring 검사가 차단 결정의 근거다. Python 직렬화 모듈명, JS 의 dynamic-eval/DOM injection 키워드, shell-spawn 식별자 등 다양한 substring 룰이 정의되어 있다. 주석/문자열 리터럴/import 별칭/변수명도 매칭된다.

**Evidence**

- `security_reminder_hook.py` 의 `SECURITY_PATTERNS` 리스트 — substring 기반 rule 다수

**Impact**

false positive 가 사용자 신뢰를 갉아먹고, 정작 진짜 보안 issue (예: 동적 문자열 조합 후 셸 실행)는 substring 으로는 못 잡는다. anti-pattern 그대로.

**Recommendation**

asset 수정. (a) rule 들을 advisory 톤으로 강등(GAP-001), (b) AST 기반 또는 reviewer agent/skill 로 이동, (c) 보안 도메인 가이드(SAST 도구) 와 연결.

### GAP-003: Debug log written to shared /tmp path

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `HOOK-GUIDE.md §8 Security` |

**Expected**

훅이 만든 파일은 user-scoped 경로에 권한 제어된 상태로 둔다. `/tmp` 공유 경로는 충돌·정보 누설 위험.

**Actual**

`DEBUG_LOG_FILE = "/tmp/security-warnings-log.txt"` 로 고정. 누가 만들었는지(권한, 모드) 검증 없이 append. multi-user 시스템에서 race/충돌 가능.

**Evidence**

- `security_reminder_hook.py` 상단의 `DEBUG_LOG_FILE` 상수
- `debug_log()` 함수의 append 호출

**Impact**

실제로 secret 이 들어가지는 않지만(JSON decode 에러, IO 에러 정도), 공유 경로 + 권한 무검증 + append 모드는 보안 가이드 작성 hook 의 본보기로 부적절. 사용자 정보의 부분 노출 가능.

**Recommendation**

asset 수정. `~/.claude/logs/security-guidance.log` 또는 XDG_STATE_HOME 경로로 이동. 디폴트로 log 비활성, 환경변수 opt-in.

### GAP-004: MultiEdit schema is hard-coded

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `HOOK-GUIDE.md §6 Input Handling` |

**Expected**

훅은 tool_input schema 변경에 graceful 해야 한다.

**Actual**

`extract_content_from_input` 의 MultiEdit 분기는 `edits` 가 배열이고 각 항목에 `new_string` 이 있다는 schema 를 가정한다.

**Evidence**

- `security_reminder_hook.py` 의 `extract_content_from_input()` MultiEdit 분기

**Impact**

runtime 이 MultiEdit schema 를 바꾸면(예: `replacements`, `changes`) 컨텐츠 검사가 silent 0 결과 반환 → false negative.

**Recommendation**

asset 수정. schema 가정 위반 시 explicit warning 또는 fallback 패턴 추가.

### GAP-005: PreToolUse blocking exit semantics not version-pinned

| Field | Value |
|---|---|
| Type | AMBIGUITY |
| Severity | P3 |
| Guide ref | `HOOK-GUIDE.md §14 Version-Sensitive Details` |

**Expected**

차단 exit code 가 PreToolUse 차단을 의미한다는 가정은 runtime 버전에 따라 달라질 수 있다.

**Actual**

스크립트 끝에서 차단을 의도하는 exit code 를 사용하고 코드 주석으로만 의도를 기록한다. 어느 Claude Code 버전에서 검증된 지 명시 없음.

**Evidence**

- `security_reminder_hook.py` 의 main() 차단 분기 주석 "Block tool execution"

**Impact**

runtime 업그레이드 시 차단이 silent 무력화될 수 있다.

**Recommendation**

asset 수정. 주석에 verified-against 버전 또는 docs link 추가. HOOK-GUIDE.md §14 와 동기화.

### GAP-006: Session-scoped state files proliferate

| Field | Value |
|---|---|
| Type | ASSET_GAP |
| Severity | P3 |
| Guide ref | `CONSTITUTION.md §3.3 Effects Require Gates` / `§3.5 Capability Surface Must Match Responsibility` / `HOOK-GUIDE.md §8 Security` / `§9 Performance` |

**Expected**

훅이 만드는 부수 파일은 위치·정리 방침이 결정론적이어야 한다.

**Actual**

`get_state_file(session_id)` 는 `~/.claude/security_warnings_state_<id>.json` 을 세션마다 별도 생성한다. cleanup 은 `random.random() < 0.1` 확률로만 30일 이상 된 파일을 정리한다. 즉 정리는 확률적·지연적이다.

**Evidence**

- `security_reminder_hook.py` 의 `get_state_file()` 와 `cleanup_old_state_files()`

**Impact**

장기 사용 시 `~/.claude/` 가 수천 개 파일로 채워질 수 있다. 결정론적 lifecycle 부재.

**Recommendation**

asset 수정. (a) 모든 session state 를 단일 JSON/SQLite 에 합치고 session_id 를 key 로 두기, 또는 (b) SessionEnd hook 에서 명시 정리.

## 7. Acceptable Deviations

| Deviation | Why acceptable |
|---|---|
| `ENABLE_SECURITY_REMINDER=0` 으로 전체 disable 가능 | escape hatch 제공 |
| GitHub Actions workflow path-based 룰 | 매우 구체적이고 false positive 낮음 |
| Session-scoped dedup 으로 같은 차단 반복 회피 | UX 측면에서 합리적 의도 |
| 매칭 없을 때 exit 0 | best-effort 부분이라도 명확 |

## 8. Suggested Changes

### Asset Changes

- [ ] **(P1)** advisory 모드(exit 0 + stderr) 를 기본으로, 차단은 명시적 opt-in 으로 (GAP-001)
- [ ] substring 룰들을 advisory 톤으로 강등하거나 별도 skill/agent 로 이동 (GAP-002, GAP-007)
- [ ] `/tmp` debug log 경로를 user scope 로 변경, 기본 disable (GAP-003)
- [ ] MultiEdit schema 가정에 graceful fallback (GAP-004)
- [ ] 차단 exit code 가정의 verified-against 버전 주석 (GAP-005)
- [ ] session state 파일을 단일 store 로 통합 (GAP-006)

### Guide Changes

- [ ] HOOK-GUIDE.md §13 Anti-Patterns 에 "Advisory hook configured as blocker" 또는 "Substring rule as hard block" 항목 추가 검토 (GAP-001, GAP-002)
- [ ] HOOK-GUIDE.md 에 "session-scoped sentinel file" 패턴의 lifecycle 권장 추가 (GAP-006)

### Constitution Review

- [ ] None

## 9. Follow-up Questions

- 이 hook 의 핵심 의도가 (a) reminder 인가, (b) blocking control 인가? 두 의도가 코드에 섞여 있어 PASS 결정이 어렵다.
- `ENABLE_SECURITY_REMINDER` 같은 env 가 사용자에게 documented 되어 있는가?
- substring 매칭의 false positive 율을 측정한 자료가 있는가?
- 동일 책임의 reviewer agent/skill 과 overlap 이 있는가? (`code-review`, `security-review` 등)

## 10. Final Decision

`REVISE_ASSET`

이유: hard block 모드가 HOOK-GUIDE.md 의 명시적 anti-pattern("false positive 가 많아 작업 흐름을 자주 막는 작업", pattern 을 security boundary 로 쓰는 anti-pattern) 에 해당하고 사용자 흐름에 직접 영향(P1). 본 리포트 작성 자체가 두 차례 차단된 사례가 실증이다. 외부 송신은 없지만 `/tmp` log/path-relative 가정/substring 강제 차단은 advisory hook 으로 모드 전환 시 자연스럽게 해소된다. 자산 자체의 의도는 유효하나 effect 와 strong-language 정렬을 다시 잡아야 한다.
