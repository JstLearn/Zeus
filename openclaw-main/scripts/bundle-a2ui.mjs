import { execSync } from 'node:child_process';
import { existsSync, readFileSync, writeFileSync, statSync, readdirSync } from 'node:fs';
import { join, dirname, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const ROOT_DIR = join(__dirname, '..');

const HASH_FILE = join(ROOT_DIR, 'src/canvas-host/a2ui/.bundle.hash');
const OUTPUT_FILE = join(ROOT_DIR, 'src/canvas-host/a2ui/a2ui.bundle.js');
const A2UI_RENDERER_DIR = join(ROOT_DIR, 'vendor/a2ui/renderers/lit');
const A2UI_APP_DIR = join(ROOT_DIR, 'apps/shared/OpenClawKit/Tools/CanvasA2UI');

if (!existsSync(A2UI_RENDERER_DIR) || !existsSync(A2UI_APP_DIR)) {
  if (existsSync(OUTPUT_FILE)) {
    console.log("A2UI sources missing; keeping prebuilt bundle.");
    process.exit(0);
  }
  console.error(`A2UI sources missing and no prebuilt bundle found at: ${OUTPUT_FILE}`);
  process.exit(1);
}

const INPUT_PATHS = [
  join(ROOT_DIR, 'package.json'),
  join(ROOT_DIR, 'pnpm-lock.yaml'),
  A2UI_RENDERER_DIR,
  A2UI_APP_DIR
];

function normalize(p) {
  return p.split(sep).join("/");
}

function getAllFiles(dirPath, arrayOfFiles) {
  const files = readdirSync(dirPath);
  arrayOfFiles = arrayOfFiles || [];

  files.forEach(function(file) {
    const fullPath = join(dirPath, file);
    if (statSync(fullPath).isDirectory()) {
      arrayOfFiles = getAllFiles(fullPath, arrayOfFiles);
    } else {
      arrayOfFiles.push(fullPath);
    }
  });

  return arrayOfFiles;
}

function computeHash() {
  let files = [];
  for (const input of INPUT_PATHS) {
    if (statSync(input).isDirectory()) {
      files = getAllFiles(input, files);
    } else {
      files.push(input);
    }
  }

  files.sort((a, b) => normalize(a).localeCompare(normalize(b)));

  const hash = createHash("sha256");
  for (const filePath of files) {
    const rel = normalize(relative(ROOT_DIR, filePath));
    hash.update(rel);
    hash.update("\0");
    const content = readFileSync(filePath);
    hash.update(content);
    hash.update("\0");
  }
  return hash.digest("hex");
}

const currentHash = computeHash();

if (existsSync(HASH_FILE)) {
  const previousHash = readFileSync(HASH_FILE, 'utf8').trim();
  if (previousHash === currentHash && existsSync(OUTPUT_FILE)) {
    console.log("A2UI bundle up to date; skipping.");
    process.exit(0);
  }
}

console.log("Bundling A2UI...");

try {
  // tsc
  console.log("Running tsc...");
  execSync(`pnpm -s exec tsc -p "${join(A2UI_RENDERER_DIR, 'tsconfig.json')}"`, { stdio: 'inherit', cwd: ROOT_DIR });
  
  // rolldown
  console.log("Running rolldown...");
  // Use pnpm exec to ensure we use the local rolldown binary
  execSync(`pnpm exec rolldown -c "${join(A2UI_APP_DIR, 'rolldown.config.mjs')}"`, { stdio: 'inherit', cwd: ROOT_DIR });
  
  writeFileSync(HASH_FILE, currentHash);
  console.log("A2UI bundled successfully.");
} catch (error) {
  console.error("A2UI bundling failed.");
  process.exit(1);
}
