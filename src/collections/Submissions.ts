import type { CollectionConfig } from "payload";
import { activityOptions } from "./GameRooms";

export const Submissions: CollectionConfig = {
  slug: "submissions",
  admin: {
    defaultColumns: [
      "room",
      "roundNumber",
      "player",
      "activity",
      "status",
      "createdAt",
    ],
  },
  access: {
    create: () => false,
    read: () => true,
    update: () => false,
    delete: () => false,
  },
  fields: [
    {
      name: "room",
      type: "relationship",
      relationTo: "game-rooms",
      required: true,
      index: true,
    },
    {
      name: "roundNumber",
      type: "number",
      required: true,
    },
    {
      name: "player",
      type: "relationship",
      relationTo: "users",
      required: true,
    },
    {
      name: "activity",
      type: "select",
      required: true,
      options: activityOptions,
    },
    {
      name: "status",
      type: "select",
      required: true,
      defaultValue: "pending",
      options: [
        { label: "Pendiente", value: "pending" },
        { label: "Enviada", value: "done" },
      ],
    },
    {
      name: "receivedMelody",
      type: "json",
      required: true,
    },
    {
      name: "receivedFrom",
      type: "relationship",
      relationTo: "users",
    },
    {
      name: "sourceSubmission",
      type: "relationship",
      relationTo: "submissions",
    },
    {
      name: "response",
      type: "json",
    },
    {
      name: "evaluation",
      type: "json",
    },
    {
      name: "submittedAt",
      type: "date",
    },
  ],
  timestamps: true,
};
