import { fieldAdminAccess } from "@/lib/access";
import type { CollectionConfig } from "payload";

export const ClassroomInvitations: CollectionConfig = {
  slug: "classroom-invitations",
  admin: {
    defaultColumns: ["classroom", "user", "status", "createdAt"],
  },
  access: {
    create: fieldAdminAccess,
    read: () => true,
    update: fieldAdminAccess,
    delete: fieldAdminAccess,
  },
  fields: [
    {
      name: "classroom",
      type: "relationship",
      relationTo: "classrooms",
      required: true,
      index: true,
    },
    {
      name: "user",
      type: "relationship",
      relationTo: "users",
      required: true,
      index: true,
    },
    {
      name: "status",
      type: "select",
      required: true,
      defaultValue: "pending",
      options: [
        { label: "Pendiente", value: "pending" },
        { label: "Aceptada", value: "accepted" },
        { label: "Rechazada", value: "rejected" },
      ],
    },
    {
      name: "invitedBy",
      type: "relationship",
      relationTo: "users",
    },
  ],
  timestamps: true,
};
