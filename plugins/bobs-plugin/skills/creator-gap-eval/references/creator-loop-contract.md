# Creator Loop Contract

`skill-creator`, `agent-creator`, `hook-creator` 가 공유하는 작성 loop 계약. 각 creator 는 자원별 판단과 draft 작성만 소유하고, creation-time GAP 분석과 재분석 loop 는 `creator-gap-eval` 에 위임한다.

본 파일은 반복 절차의 source 이다. 자원별 차이는 `resource-type-matrix.md` 에 둔다.

## 1. Caller Responsibility

creator 는 다음 결과를 보장한다.

- 사용자 intent 를 자원 책임, scope, 부수 효과, output contract 로 정리한다.
- 대상 파일 경로와 첫 draft 범위를 파일 쓰기 전에 사용자에게 제시한다.
- 자원별 GUIDE 를 읽고 draft 한다.
- draft 후 `creator-gap-eval` 을 호출하고 Final Decision 에 따라 한정된 수정만 적용한다.
- 최종 응답에는 변경 경로, scope, GAP 결과, finding count, GAP report path 를 남긴다.

creator 는 다음을 직접 하지 않는다.

- 자원 타입 결정이 불명확한 상태에서 작성 계속.
- 정적 rule 감사 대체 (`agent-skill-auditor` 책임).
- 외부 모델/PR/code review.
- guide 자체 수정. `REVISE_GUIDE` 는 보고하고 별도 작업으로 남긴다.

## 2. Minimal Workflow

1. **Capture intent**
   사용자 요청과 optional args 를 읽어 책임, trigger, negative case, output, 부수 효과, scope 를 확정한다. `name` / `scope` / event 같은 mechanical args 는 pre-fill 할 수 있지만 책임·부수 효과·output 판단을 우회하지 않는다.

2. **Choose target**
   scope 별 path 를 결정하고 기존 동명/유사 자산을 확인한다. 중복이면 새 작성보다 수정 또는 `resource-design` 재검토를 우선한다.

3. **Draft with guide**
   해당 자원 GUIDE 를 읽고 target 파일을 작성한다. 첫 write 전에는 path, frontmatter/registration 초안, 본문 골격, workspace 경로를 제시한다. 사용자가 이미 “묻지 말고 진행”을 명시한 경우에만 이 gate 를 생략하고 가정을 기록한다.

4. **Run GAP eval**
   `creator-gap-eval` 에 `resource_type`, `draft_path`, `asset_name`, `delegation_mode`, `round_count`, `reentry_count` 를 전달한다. 자원별 matrix 는 `resource-type-matrix.md` 를 따른다.

5. **Apply Final Decision**
   `PASS` / `PASS_WITH_NOTES` 면 종료한다. `REVISE_ASSET` 은 P0/P1/P2 중심으로 수정 요약을 제시한 뒤 적용하고 `round_count + 1` 로 재호출한다. `SPLIT_ASSET`, `DEPRECATE_ASSET`, `NEEDS_REVIEW` 는 사용자 handoff 로 전환한다.

6. **Report**
   세부 finding 본문은 반복하지 않는다. GAP report path 와 한 줄 요약만 남긴다.

## 3. GAP Eval Args

공통 shape:

```yaml
resource_type: skill | agent | hook
draft_path:
  - <abs path>      # hook 은 script + registration 두 경로
asset_name: <path-safe name>
delegation_mode: delegate | inline
reentry_count: 0
round_count: 1
```

규칙:

- 첫 호출은 `round_count: 1`.
- `REVISE_ASSET` 후 재호출은 반환된 `round_count` 에 1만 더한다.
- `reentry_count` 는 creator-gap-eval 자기 자신 분석이 아닌 한 0을 유지한다.
- round 5 초과는 `NEEDS_REVIEW` 로 handoff 한다.
- `draft_path` 는 절대 경로를 사용한다. hook 은 script 와 registration 모두 포함한다.

## 4. Final Decision Map

| Decision | Creator action |
|---|---|
| `PASS` | 최종 보고 |
| `PASS_WITH_NOTES` | 최종 보고. P3/follow-up 은 별도 권고로 남김 |
| `REVISE_ASSET` | 수정 요약 gate 후 P0/P1/P2 적용, round 증가 후 재호출 |
| `REVISE_GUIDE` | 자산은 일단 통과로 보고, guide 보완은 별도 작업 |
| `SPLIT_ASSET` | 작성 중단, 책임 분리 재설계 또는 `resource-design` 으로 전환 |
| `DEPRECATE_ASSET` | 사용자 확인 후 폐기 권고 |
| `NEEDS_REVIEW` | 근거 부족, round/reentry 한도, 사용자 판단 필요 사항 보고 |

## 5. Common Output Fields

creator 최종 응답은 최소한 다음 필드를 포함한다.

```text
created/updated: <relative path or paths>
scope: user | project | plugin
gap: <Final Decision> (rounds: <N>)
findings: P0=<n>, P1=<n>, P2=<n>, P3=<n>
gap_report: <path to *.GAP.md>
guide_gaps: <count if any>
follow-ups: <count or short summary>
```

자원별 추가 필드:

- agent: `tools`, `model`.
- hook: `event`, `matcher`, `exit_policy`.

`Final Decision` 이 `PASS` / `PASS_WITH_NOTES` 가 아니면 `blocked: needs revision` 을 앞에 붙인다.

## 6. Hard Constraints

- 파일 수정은 creator 가 직접 하지만, write 전 gate 와 revise 전 gate 를 지킨다.
- registration 변경은 자동 실행 범위를 바꾸므로 항상 gate 를 지킨다.
- GAP report 는 자산과 동급 산출물이다. 덮어쓰지 말고 round suffix 정책을 따른다.
- 강한 표현은 실제 gate, safety, secret 보호, destructive action 차단에만 쓴다.
- 상세 guide 규칙은 각 GUIDE 와 `resource-type-matrix.md` 를 읽어 적용한다. 본 파일에 GUIDE 본문을 재생산하지 않는다.
