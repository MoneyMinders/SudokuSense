#!/usr/bin/env bash
# SudokuSense VPS — deploy and Docker commands.
#
# Deploy:   ./scripts/vps-deploy.sh deploy
# Other:    ./scripts/vps-deploy.sh up|down|restart|logs|ps|web-restart|web-logs

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COMPOSE_REL="${COMPOSE_FILE:-docker/docker-compose.server.yml}"
if [[ "$COMPOSE_REL" = /* ]]; then
  COMPOSE="$COMPOSE_REL"
else
  COMPOSE="$ROOT/$COMPOSE_REL"
fi

if [[ ! -f "$COMPOSE" ]]; then
  echo "Compose file not found: $COMPOSE" >&2
  exit 1
fi

if docker compose version &>/dev/null; then
  DC=(docker compose -f "$COMPOSE")
elif command -v docker-compose &>/dev/null; then
  DC=(docker-compose -f "$COMPOSE")
else
  echo "Install Docker Compose." >&2
  exit 1
fi

cmd="${1:-deploy}"
case "$cmd" in
  deploy|"")
    mkdir -p "$ROOT/web-dist"
    echo "==> docker compose down"
    "${DC[@]}" down
    echo "==> docker compose up -d"
    "${DC[@]}" up -d
    echo "==> Done. Status:"
    "${DC[@]}" ps
    ;;
  up)
    "${DC[@]}" up -d
    ;;
  down)
    "${DC[@]}" down
    ;;
  restart)
    "${DC[@]}" down
    "${DC[@]}" up -d
    ;;
  logs)
    "${DC[@]}" logs -f --tail=200
    ;;
  ps)
    "${DC[@]}" ps
    ;;
  web-restart)
    "${DC[@]}" restart web
    ;;
  web-logs)
    "${DC[@]}" logs -f --tail=200 web
    ;;
  *)
    echo "Usage: $0 [deploy|up|down|restart|logs|ps|web-restart|web-logs]" >&2
    exit 1
    ;;
esac
