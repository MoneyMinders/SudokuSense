VPS_HOST     ?= root@187.127.131.123
VPS_DIR      ?= /home/apps/SudokuSense

# ═══════════════════════════════════════════════════════════════
#  WEB
# ═══════════════════════════════════════════════════════════════

# Build Flutter web for production (output: build/web/)
web-build:
	flutter build web --release

# Deploy web to VPS: build + rsync + restart nginx container
web-deploy: web-build
	rsync -az --delete build/web/ $(VPS_HOST):$(VPS_DIR)/web-dist/
	ssh $(VPS_HOST) "cd $(VPS_DIR) && ./scripts/vps-deploy.sh web-restart"

# First-time setup on VPS: create dirs, copy config, start container
web-init:
	ssh $(VPS_HOST) "mkdir -p $(VPS_DIR)/web-dist $(VPS_DIR)/docker $(VPS_DIR)/scripts"
	rsync -az docker/docker-compose.server.yml $(VPS_HOST):$(VPS_DIR)/docker/
	rsync -az docker/nginx-web.conf $(VPS_HOST):$(VPS_DIR)/docker/
	rsync -az scripts/vps-deploy.sh $(VPS_HOST):$(VPS_DIR)/scripts/
	ssh $(VPS_HOST) "chmod +x $(VPS_DIR)/scripts/vps-deploy.sh"
	ssh $(VPS_HOST) "cd $(VPS_DIR) && ./scripts/vps-deploy.sh deploy"

# Restart only the web container (no rebuild needed)
web-restart:
	ssh $(VPS_HOST) "cd $(VPS_DIR) && ./scripts/vps-deploy.sh web-restart"

# View web container logs
web-logs:
	ssh $(VPS_HOST) "cd $(VPS_DIR) && ./scripts/vps-deploy.sh web-logs"

# Check web container status
web-status:
	ssh $(VPS_HOST) "cd $(VPS_DIR) && ./scripts/vps-deploy.sh ps"

# ═══════════════════════════════════════════════════════════════
#  MOBILE
# ═══════════════════════════════════════════════════════════════

ICLOUD_DIR = $(HOME)/Library/Mobile Documents/com~apple~CloudDocs/SudokuSense

# Build release APK + copy to iCloud
apk:
	flutter build apk --release
	@mkdir -p "$(ICLOUD_DIR)"
	@rm -f "$(ICLOUD_DIR)"/SudokuSense*.apk 2>/dev/null || true
	cp build/app/outputs/flutter-apk/app-release.apk "$(ICLOUD_DIR)/SudokuSense-$(shell date +%Y%m%d-%H%M).apk"
	@echo "APK copied to iCloud"

# Build release iOS
ios:
	flutter build ios --release

.PHONY: web-build web-deploy web-init web-restart web-logs web-status apk ios
