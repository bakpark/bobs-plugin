# Matcher pressure scenarios

`hook-creator` 본문 §"When the loop stalls" 의 보조 절차. event/matcher 가 좁은지 검증하기 위해 *반응해야 할 case* 와 *반응하지 않아야 할 case* 를 짧게 적고 mental dry-run 으로 분류 결과를 확인한다. registration 변경이나 실제 tool 호출 없이 진행한다.

## 언제 사용

GAP loop 가 3 라운드 이상 도달했거나, matcher 너비·false positive 우려가 finding 으로 잡혀 본문 수정만으로 결론이 나지 않을 때. 본 절차는 self-feedback refine (§4) 의 *보조 검증* 이며 GAP report 를 대체하지 않는다.

## 절차

### 1. should-trigger 2–3개

자산이 *반드시* 반응해야 하는 시나리오. 한 줄로 적는다. 형식:

```
[tool/event] <상황 요약> → expect: fire
```

예 (PostToolUse Edit|Write 의 TypeScript formatter):

```
Edit  src/components/Foo.tsx 수정 (npm 프로젝트, tsconfig 있음) → expect: fire
Write src/utils/dates.ts 신규 작성 → expect: fire
```

### 2. should-not-trigger 2–3개

자산이 *반응하면 안 되는* near-miss 시나리오. 인접 tool 이거나, 같은 tool 의 다른 파일·경로·확장자 케이스.

```
Edit  README.md (문서, ts 아님) → expect: no-op
Write package-lock.json (lockfile blocker 책임 영역) → expect: no-op
Bash  "npm install" 실행 → expect: no-op (Bash 는 matcher 밖)
```

### 3. Mental dry-run

각 시나리오를 registration JSON + script 로 흘려본다. 분류 표 작성:

| Scenario | matcher 통과? | script path filter 통과? | 최종 결과 | expect 와 일치? |
|---|---|---|---|---|
| Edit src/Foo.tsx | yes (`Edit\|Write` ∋ Edit) | yes (`*.ts\|*.tsx` 매치) | fire | ✓ |
| Edit README.md | yes | no | no-op | ✓ |
| Write package-lock.json | yes | no (`*.ts\|*.tsx` 미매치) | no-op | ✓ |
| Bash npm install | no (matcher 밖) | — | no-op | ✓ |

표의 `최종 결과` 가 `expect` 와 *어긋나는 행* 이 발견되면 그 항목이 다음 수정 대상이다.

### 4. False positive 워크플로우 점검

사용자의 평소 작업 패턴에서 위 should-not-trigger 가 *얼마나 자주* 등장할지 확인한다. 빈번하다면 matcher 또는 script path filter 를 더 좁히거나, exit policy 를 best-effort 로 강등한다 (HOOK-GUIDE §13 Advisory hook configured as blocker).

## 산출

본 절차의 산출은 *분류 표 1개* 다. 표 자체를 자산에 commit 하지 않는다 — workspace 의 GAP report `Follow-up Questions` 또는 `Acceptable Deviations` 에 요약으로 남긴다.

표에서 어긋난 행이 없으면 추가 finding 을 만들지 않고 진행한다. 한 행이라도 어긋나면 §4 의 finding 적용 순서를 따라 matcher / script path filter / exit policy 중 어디를 손볼지 결정한다.

## 한계

- mental dry-run 은 실제 runtime 동작 보장이 아니다. matcher 매치, hook input JSON schema, exit code semantics 는 runtime 버전 의존적이며 (HOOK-GUIDE §14), 본 절차는 *설계 단계의 사전 점검* 으로 한정한다.
- 실제 검증은 registration 후 사용자가 평소 워크플로우에서 관찰하거나, 의도된 시나리오로 직접 tool 을 호출해 확인한다.
- 시나리오 수가 많아질수록 dry-run 비용도 늘어난다. should-trigger 2개 + should-not-trigger 2개 가 기본 권장. 5개 초과는 자산 책임이 너무 넓을 가능성이 있으므로 `SPLIT_ASSET` 을 고려한다.
