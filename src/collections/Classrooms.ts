import { fieldAdminAccess } from "@/lib/access";
import type { CollectionConfig } from "payload";

export const Classrooms: CollectionConfig = {
  slug: "classrooms",
  admin: {
    useAsTitle: "name",
    defaultColumns: ["name", "teacher", "createdAt"],
  },
  access: {
    create: fieldAdminAccess,
    read: () => true,
    update: fieldAdminAccess,
    delete: fieldAdminAccess,
  },
  hooks: {
    beforeDelete: [
      async ({ id, req }) => {
        await req.payload.delete({
          collection: "classroom-invitations",
          where: { classroom: { equals: id } },
          req,
        });
      },
    ],
  },
  fields: [
    {
      name: "name",
      type: "text",
      required: true,
    },
    {
      name: "teacher",
      type: "relationship",
      relationTo: "users",
      required: true,
      index: true,
    },
  ],
  timestamps: true,
};
