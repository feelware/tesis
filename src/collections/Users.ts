import {
  collectionAdminAccess,
  fieldAdminAccess,
  fieldProfessorAccess,
} from "@/lib/access";
import { isAdmin, isProfessor } from "@/lib/user";
import type { CollectionConfig } from "payload";

export const Users: CollectionConfig = {
  slug: "users",
  auth: true,
  admin: {
    useAsTitle: "email",
    defaultColumns: ["email", "name", "role"],
  },
  access: {
    admin: ({ req }) =>
      req.user !== null && (isAdmin(req.user) || isProfessor(req.user)),
    read: ({ req, id }) =>
      req.user !== null &&
      (isAdmin(req.user) ||
        isProfessor(req.user) ||
        String(req.user.id) === String(id)),
    create: () => true,
    update: ({ req, id }) =>
      req.user !== null &&
      (isAdmin(req.user) || String(req.user.id) === String(id)),
    delete: collectionAdminAccess,
  },
  fields: [
    {
      name: "name",
      type: "text",
    },
    {
      name: "role",
      type: "select",
      required: true,
      defaultValue: "student",
      options: ["student", "professor", "admin"],
      access: {
        read: fieldProfessorAccess,
        create: fieldAdminAccess,
        update: fieldAdminAccess,
      },
    },
  ],
};
