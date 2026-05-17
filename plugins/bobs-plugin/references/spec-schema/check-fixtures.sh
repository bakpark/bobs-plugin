#!/usr/bin/env bash
# check-fixtures.sh — spec-schema fixture pair regression test
#
# 사용:
#   bash plugins/bobs-plugin/references/spec-schema/check-fixtures.sh
#
# 절차:
#   1. fixtures/*.md 의 YAML fenced block 추출
#   2. yq (Homebrew) 또는 python3 + PyYAML 으로 파싱
#   3. fixtures/*.expected.yaml 와 deep equal 비교 (key 순서 무관)
#   4. mismatch 시 diff 출력 + exit 1
#
# Tool 의존성 (둘 중 하나 — fallback):
#   - yq:    brew install yq         (https://github.com/mikefarah/yq)
#   - python: python3 + pip install pyyaml
#
# runtime install-harness command 와 별도 — script 는 dev/CI 환경 전용.
# command 는 Claude native YAML 처리 (spec-schema.md §5).

set -euo pipefail

FIXTURES_DIR="$(cd "$(dirname "$0")/fixtures" && pwd)"
FAIL=0

# Tool detection
if command -v yq >/dev/null 2>&1; then
  PARSER="yq"
elif python3 -c "import yaml" >/dev/null 2>&1; then
  PARSER="python"
else
  echo "ERROR: neither 'yq' nor 'python3+PyYAML' available" >&2
  echo "  - Install yq:    brew install yq" >&2
  echo "  - Install pyyaml: python3 -m pip install pyyaml" >&2
  exit 2
fi
echo "Using parser: $PARSER"

# Extract first YAML fenced block from markdown
extract_yaml() {
  local md_file="$1"
  awk '/^```yaml$/{flag=1; next} /^```$/{flag=0} flag' "$md_file"
}

# Normalize YAML to canonical JSON (key-sorted)
to_canonical_json() {
  if [ "$PARSER" = "yq" ]; then
    yq -o=json 'sort_keys(..)' -
  else
    python3 -c "import sys, yaml, json; print(json.dumps(yaml.safe_load(sys.stdin), sort_keys=True, indent=2))"
  fi
}

# Compare one fixture pair
check_pair() {
  local md_file="$1"
  local expected_file="${md_file%.md}.expected.yaml"
  local name="$(basename "${md_file%.md}")"

  if [ ! -f "$expected_file" ]; then
    echo "  [$name] SKIP — expected file missing: $expected_file"
    return 0
  fi

  local actual canonical_actual canonical_expected
  actual="$(extract_yaml "$md_file")"
  if [ -z "$actual" ]; then
    echo "  [$name] FAIL — no YAML fenced block in $md_file"
    return 1
  fi

  canonical_actual="$(echo "$actual" | to_canonical_json)"
  canonical_expected="$(to_canonical_json < "$expected_file")"

  if [ "$canonical_actual" = "$canonical_expected" ]; then
    echo "  [$name] PASS"
    return 0
  else
    echo "  [$name] FAIL — diff:"
    diff <(echo "$canonical_expected") <(echo "$canonical_actual") | sed 's/^/    /'
    return 1
  fi
}

echo "Running fixture checks in: $FIXTURES_DIR"
for md_file in "$FIXTURES_DIR"/*.md; do
  if ! check_pair "$md_file"; then
    FAIL=1
  fi
done

if [ "$FAIL" -eq 0 ]; then
  echo "All fixtures PASS"
  exit 0
else
  echo "Some fixtures FAILED" >&2
  exit 1
fi
