import path from "node:path";
import { fileURLToPath } from "node:url";
import type { CollectionConfig } from "payload";

const filename = fileURLToPath(import.meta.url);
const dirname = path.dirname(filename);

export const Media: CollectionConfig = {
  slug: "media",
  admin: {
    useAsTitle: "filename",
    defaultColumns: ["filename", "mimeType", "createdAt"],
  },
  access: {
    create: ({ req }) => req.user !== null,
    read: () => true,
    update: () => false,
    delete: () => false,
  },
  upload: {
    staticDir: path.resolve(dirname, "../../media"),
  },
  fields: [
    {
      name: "alt",
      type: "text",
    },
  ],
};
