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
  hooks: {
    beforeDelete: [
      async ({ id, req }) => {
        await req.payload.delete({
          collection: "game-rooms",
          where: { host: { equals: id } },
          req,
        });
        await req.payload.delete({
          collection: "submissions",
          where: { player: { equals: id } },
          req,
        });
        const rooms = await req.payload.find({
          collection: "game-rooms",
          where: { "participants.user": { equals: id } },
          pagination: false,
          depth: 0,
          req,
        });
        for (const room of rooms.docs) {
          const participants = room.participants?.filter((p) => {
            const u = p.user;
            return String(typeof u === "object" && u !== null ? u.id : u) !== String(id);
          });
          await req.payload.update({
            collection: "game-rooms",
            id: room.id,
            data: { participants },
            req,
          });
        }
      },
    ],
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
