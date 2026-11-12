import { copyFileSync, mkdirSync } from "node:fs";
import { resolve } from "node:path";

const sourceDir = resolve("node_modules/@spotify/basic-pitch/model");
const targetDir = resolve("public/models/basic-pitch");

mkdirSync(targetDir, { recursive: true });
for (const file of ["model.json", "group1-shard1of1.bin"]) {
  copyFileSync(resolve(sourceDir, file), resolve(targetDir, file));
}
console.log("modelo de Basic Pitch copiado a public/models/basic-pitch");
