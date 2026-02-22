@echo off
rem OpenClaw Gateway (Lina - Optimized)
rem This script launches the local Gateway directly on Windows with custom configuration.

set PATH=C:\Program Files\nodejs\;%PATH%
set OPENCLAW_GATEWAY_PORT=18789
set OPENCLAW_GATEWAY_TOKEN=zeus_sabit_anahtar_2026

echo Starting OpenClaw Gateway (Lina Configuration) on port %OPENCLAW_GATEWAY_PORT%...
"C:\Program Files\nodejs\node.exe" "C:\Users\deniz\.openclaw\openclaw-main\openclaw.mjs" gateway --port %OPENCLAW_GATEWAY_PORT% --bind lan