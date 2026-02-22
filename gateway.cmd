@echo off
set "OPENCLAW_STATE_DIR=C:\Users\deniz\OneDrive\Code\Zeus"
set "OPENCLAW_CONFIG_PATH=C:\Users\deniz\OneDrive\Code\Zeus\openclaw.json"
cd /d "C:\Users\deniz\OneDrive\Code\Zeus"
set OPENCLAW_GATEWAY_PORT=18789
set OPENCLAW_GATEWAY_TOKEN=zeus_sabit_anahtar_2026
echo Starting OpenClaw Gateway (Zeus) on port %OPENCLAW_GATEWAY_PORT%...
node "openclaw-main\openclaw.mjs" gateway --port %OPENCLAW_GATEWAY_PORT% --bind lan