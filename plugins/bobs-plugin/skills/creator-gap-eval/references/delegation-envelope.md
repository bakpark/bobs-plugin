# Delegation Envelope (creator-gap-eval Phase 3)

`creator-gap-eval` 의 Phase 3 (`delegation_mode: delegate`) 에서 generic subagent 에 보낼 dispatch envelope template + 9 heading 복사 절차. SKILL.md Phase 3 가 *언제·왜* 호출하는지를 다루고, 본 파일은 *어떻게* 를 다룬다.

**출처**: 본 plan + 3 creator §3b 본문 (`skill-creator/SKILL.md` line 164 "경로 resolve 책임" + 166-189 dispatch payload 예시) + GAP-ANALYSIS-PROMPT.md (9 heading source). MIT in-house.

## 1. Dispatch Envelope Template

`<UPPERCASE>` 는 placeholder (main session 이 dispatch 직전에 치환).

```text
subagent_type: "general-purpose"
description: "GAP analysis of new <RESOURCE_TYPE_KOR>: <ASSET_NAME>"
prompt:
  ---
  현재 작업 디렉토리는 <RESOLVED_REFS_DIR> 이다.
  너는 이 대화의 이전 컨텍스트를 전혀 모른다고 가정하고, 현재 cwd 안의 파일만
  기준으로 GAP 분석을 수행한다. 단, 분석 대상은 외부 경로:

    <TARGET_SECTION>

  반드시 먼저 읽을 문서 (cwd 내):
    - CONSTITUTION.md
    - <GUIDE_FILE>.md
    - GAP-FORMAT.md

  <EXTRA_ENVELOPE_HINT>

  리포트 저장 경로:
    <REPORT_PATH>

  [이하 GAP-ANALYSIS-PROMPT.md 의 §"판정 원칙" / §"원칙 강도" / §"Finding 유형" /
   §"Severity" / §"<DELEGATION_CHECK_AXIS> 점검 축" / §"Evidence 작성 규칙" /
   §"리포트 구조" / §"최종 결정" / §"완료 보고" 섹션 verbatim 으로 복사]
  ---
```

## 2. Placeholder 치환표

| Placeholder | 채움 책임 | source |
|---|---|---|
| `<RESOURCE_TYPE_KOR>` | main session | `args.resource_type` → 스킬 / 에이전트 / 훅 |
| `<ASSET_NAME>` | main session | `args.asset_name` |
| `<RESOLVED_REFS_DIR>` | main session | env `${CLAUDE_PLUGIN_ROOT}/references` 우선, 미설정 시 fallback `<SKILL.md 디렉토리>/../../references` |
| `<TARGET_SECTION>` | main session | matrix `delegation_target_wording` (`<SKILL_PATH>` / `<AGENT_PATH>` / `<SCRIPT_PATH>+<REGISTRATION_PATH>` 채움) |
| `<GUIDE_FILE>` | main session | matrix `guide_name` (`SKILL-GUIDE` / `AGENT-GUIDE` / `HOOK-GUIDE`) |
| `<EXTRA_ENVELOPE_HINT>` | main session | matrix `extra_envelope_hint` (없으면 빈 줄) |
| `<REPORT_PATH>` | main session | `${CLAUDE_PLUGIN_ROOT}/skills/creator-gap-eval-workspace/gaps/<resource_type>-<asset_name>.GAP.md` (round 2+ 는 `.round${n}.md` suffix) |
| `<DELEGATION_CHECK_AXIS>` | main session | matrix `delegation_check_axis` (Skill / Agent / Hook) |
| 9 heading 본문 | main session (Read + 복사) | `${CLAUDE_PLUGIN_ROOT}/references/GAP-ANALYSIS-PROMPT.md` |

## 3. 경로 Resolve 책임

위임 prompt 의 `<RESOLVED_REFS_DIR>` 는 main session 이 *절대 경로* 로 채워서 보낸다 — subagent 는 resolved path 만 보며 환경 변수 확장이나 fallback 판단을 하지 않는다.

Resolve 순서:

1. `echo "${CLAUDE_PLUGIN_ROOT}"` 가 비어있지 않으면 `${CLAUDE_PLUGIN_ROOT}/references` 사용.
2. 비어있으면 본 SKILL.md 디렉토리 기준 fallback: `<creator-gap-eval/>../../references`.
3. fallback 도 실패하면 main session 이 사용자에게 보고 + 종료. 임의 경로 임시 사용 금지.

3 creator §3b 의 동일 정책을 본 skill 이 이어받음 (skill-creator/SKILL.md line 164 출처).

## 4. 9 Heading 복사 절차

dispatch 직전에 `${CLAUDE_PLUGIN_ROOT}/references/GAP-ANALYSIS-PROMPT.md` 를 한 번 더 Read.

**복사 순서** (9 heading):

1. §판정 원칙
2. §원칙 강도
3. §Finding 유형
4. §Severity
5. §`<DELEGATION_CHECK_AXIS>` 점검 축  ← matrix 분기 적용
6. §Evidence 작성 규칙
7. §리포트 구조
8. §최종 결정
9. §완료 보고

각 heading 의 *본문* (heading 다음 줄부터 다음 heading 직전까지) 을 *순서·원문 그대로* 복사. heading 이름 자체는 envelope 의 "[이하 GAP-ANALYSIS-PROMPT.md 의 §"...".. 섹션 verbatim 으로 복사]" 줄이 이미 인용했으므로 *본문만* 복사.

**5번 heading (`점검 축`)** 은 matrix `delegation_check_axis` 에 따라 `Skill / Agent / Hook` 중 하나만 선택해 복사. Command / Runtime 점검 축은 본 skill 의 현재 범위 밖이라 복사 안 함.

## 5. 복사 *제외* 섹션

본 envelope 의 prompt 본문이 *이미 직접 지시* 하므로 중복 회피 — 5 섹션 제외:

1. §목표 — envelope 가 "GAP 분석을 수행한다" 로 직접 지시.
2. §반드시 먼저 읽을 문서 — envelope 의 `반드시 먼저 읽을 문서` 섹션이 직접 명시 (CONSTITUTION + matrix `guide_name` + GAP-FORMAT).
3. §분석 대상 — envelope 의 `<TARGET_SECTION>` 이 직접 명시.
4. §수정 가능 범위 — envelope 의 "단, 분석 대상은 외부 경로" 로 read-only 명시.
5. §작업 방식 — envelope 의 "이전 컨텍스트를 전혀 모른다고 가정" 으로 명시.

본 skill 은 *단일 자산* 분석 — GAP-ANALYSIS-PROMPT 의 multi-asset 가정 (§분석 대상 / §수정 가능 범위 등) 은 적용하지 않는다.

## 6. Verify Step (dispatch 직전 self-check)

envelope 작성 후 dispatch 직전에 다음 5 가지 확인:

```bash
# 1. 9 heading 키워드 모두 envelope prompt 에 있는지 (복사 누락 검출)
for kw in "판정 원칙" "원칙 강도" "Finding 유형" "Severity" "점검 축" "Evidence 작성 규칙" "리포트 구조" "최종 결정" "완료 보고"; do
  echo "$envelope_prompt" | grep -q "$kw" || echo "MISSING: $kw"
done

# 2. 분기 슬롯 모두 채워졌는지 (placeholder 잔류 검출)
for ph in "<RESOLVED_REFS_DIR>" "<TARGET_SECTION>" "<GUIDE_FILE>" "<REPORT_PATH>" "<DELEGATION_CHECK_AXIS>" "<RESOURCE_TYPE_KOR>" "<ASSET_NAME>"; do
  echo "$envelope_prompt" | grep -qF "$ph" && echo "PLACEHOLDER LEFT: $ph"
done

# 3. cwd 외부 path 노출 차단 (분석 대상 외 절대 경로가 prompt 본문에 없어야)
# (manual review — envelope template 자체가 외부 path 를 <TARGET_SECTION> 한 곳에만 두므로 보통 통과)

# 4. report path 가 통합 workspace 경로인지
echo "$envelope_prompt" | grep -q "creator-gap-eval-workspace/gaps/" \
  || echo "WRONG WORKSPACE PATH"

# 5. delegation_check_axis 와 envelope 5번 heading 본문 일치 (자원-타입 mismatch 차단)
case "$delegation_check_axis" in
  Skill) expected_axis="Skill 점검 축" ;;
  Agent) expected_axis="Agent 점검 축" ;;
  Hook)  expected_axis="Hook 점검 축" ;;
esac
count=$(echo "$envelope_prompt" | grep -c "$expected_axis")
[ "$count" -eq 1 ] || echo "AXIS MISMATCH: expected '$expected_axis' (count=$count)"
# 다른 axis 본문이 envelope 에 leaked 됐는지 확인
for other in Skill Agent Hook; do
  [ "$other" = "$delegation_check_axis" ] && continue
  echo "$envelope_prompt" | grep -q "$other 점검 축" && echo "FOREIGN AXIS LEAKED: $other"
done
```

## 7. Common Failures

- **9 heading 중 일부 누락** — 복사 시 단순 누락 또는 GAP-ANALYSIS-PROMPT.md 가 갱신되면서 heading 이름 변경. Verify Step 1 이 사전 차단.
- **분기 슬롯 미채움** — placeholder 가 prompt 본문에 잔류. Verify Step 2 가 차단.
- **`<TARGET_SECTION>` 에 hook 의 2 파일 중 하나만 채움** — matrix `target_paths_len: 2` 인 경우 두 path 모두 명시 필수. `delegation_target_wording` 의 multi-line 형식 따름.
- **envelope 가 cwd 외부 path 노출** — `<TARGET_SECTION>` 외 외부 path 가 prompt 본문에 노출되면 subagent 의 "cwd 안의 파일만 기준" 원칙 위반. envelope template 의 외부 path 슬롯은 `<TARGET_SECTION>` 한 곳 (+ `<REPORT_PATH>` 의 workspace 경로).
- **5번 heading 의 `점검 축` 가 잘못된 자원 타입으로 복사** — matrix `delegation_check_axis` lookup 누락. 예: agent 자산인데 `Skill 점검 축` 본문이 복사됨. Verify Step 5 (자원-타입 mismatch grep) 가 사전 차단.
- **`<EXTRA_ENVELOPE_HINT>` 누락** — agent / hook 자원의 §11.X / §12.X 직접 지시가 빠짐 → subagent 가 §11.1 default Snapshot 사용. matrix `extra_envelope_hint` 가 비어있지 않으면 반드시 envelope 의 명시 위치에 삽입.

## 8. 위임 이유 (요약)

- **main context 절약** — 9 heading 본문 (수백 lines) 을 main session 이 직접 읽고 분석 안 함.
- **평가자 독립성** — GAP-FORMAT 의 "이전 컨텍스트를 전혀 모른다고 가정" 원칙 충족 — main session 의 작성 의도가 평가 편향 안 함.
- **자원 격리** — subagent 는 cwd 안의 normative source + 분석 대상 1건만 봄. 다른 자원 / plan / 사용자 발화 노출 없음.

`delegation_mode: inline` (Phase 4) 은 *비용 절감 모드* — 위 3 가지 trade-off 를 호출자가 명시 결정.
