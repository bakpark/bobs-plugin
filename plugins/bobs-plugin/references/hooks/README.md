# Hooks 스냅샷

이 디렉토리는 현재 활성화된 훅 스크립트와 등록 설정의 참고용 스냅샷이다. `v2-update.md` 에 명시된 세 플러그인의 훅만 포함한다.

| 플러그인 | 이벤트 | 스크립트 | 등록 위치 |
|---|---|---|---|
| superpowers | `SessionStart` (`startup\|clear\|compact`) | `run-hook.cmd` → `session-start` | `superpowers/hooks.json` |
| ralph-loop | `Stop` | `stop-hook.sh` | `ralph-loop/hooks.json` |
| security-guidance | (참고 본문) | `security_reminder_hook.py` | `security-guidance/hooks.json` |

원본 경로:
- `superpowers`: `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.1.0/hooks/`
- `ralph-loop`: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/ralph-loop/hooks/`
- `security-guidance`: `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/security-guidance/hooks/`

스냅샷은 정확한 등록 schema, command 인자, exit semantics 를 확인하기 위해 보관한다. 실제 동작은 사용 시점에 원본 플러그인을 확인한다.
