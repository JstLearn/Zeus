import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import dotenv from "dotenv";
import { resolveRequiredHomeDir } from "./home-dir.js";

function resolveConfigDirMinimal(env: NodeJS.ProcessEnv): string {
  const override = env.OPENCLAW_STATE_DIR?.trim() || env.CLAWDBOT_STATE_DIR?.trim();
  if (override) {
    return path.resolve(override.trim());
  }
  return path.join(resolveRequiredHomeDir(env, os.homedir), ".openclaw");
}

export function loadDotEnv(opts?: { quiet?: boolean }) {
  const quiet = opts?.quiet ?? true;

  // Load from process CWD first (dotenv default).
  dotenv.config({ quiet });

  // Then load global fallback: ~/.openclaw/.env (or OPENCLAW_STATE_DIR/.env),
  // without overriding any env vars already present.
  const globalEnvPath = path.join(resolveConfigDirMinimal(process.env), ".env");
  if (!fs.existsSync(globalEnvPath)) {
    return;
  }

  dotenv.config({ quiet, path: globalEnvPath, override: false });
}
