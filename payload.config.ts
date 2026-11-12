import path from "node:path";
import { fileURLToPath } from "node:url";
import { buildConfig } from "payload";
import { postgresAdapter } from "@payloadcms/db-postgres";
import { lexicalEditor } from "@payloadcms/richtext-lexical";
import sharp from "sharp";
import collections from "@/collections";

const filename = fileURLToPath(import.meta.url);
const dirname = path.dirname(filename);
const isProduction = process.env.NODE_ENV === "production";

export default buildConfig({
  collections,
  db: postgresAdapter({
    pool: { connectionString: process.env.DATABASE_URL },
    push: !isProduction,
    migrationDir: path.resolve(dirname, "src/migrations"),
  }),
  admin: {
    user: "users",
    meta: { titleSuffix: " — Tesis CMS" },
    importMap: { baseDir: path.resolve(dirname, "src") },
  },
  typescript: {
    outputFile: path.resolve(dirname, "payload-types.ts"),
  },
  secret: process.env.PAYLOAD_SECRET || "",
  editor: lexicalEditor(),
  sharp,
});
