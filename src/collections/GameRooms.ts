import type { CollectionConfig } from "payload";

export const activityOptions = [
  { label: "Dictado", value: "dictation" },
  { label: "Repentización", value: "sight_singing" },
];

export const GameRooms: CollectionConfig = {
  slug: "game-rooms",
  admin: {
    useAsTitle: "code",
    defaultColumns: ["code", "status", "currentRound", "createdAt"],
  },
  access: {
    create: () => false,
    read: () => true,
    update: () => false,
    delete: () => false,
  },
  fields: [
    {
      name: "code",
      type: "text",
      required: true,
      unique: true,
      index: true,
    },
    {
      name: "host",
      type: "relationship",
      relationTo: "users",
      required: true,
    },
    {
      name: "status",
      type: "select",
      required: true,
      defaultValue: "waiting",
      options: [
        { label: "Esperando", value: "waiting" },
        { label: "En curso", value: "in_progress" },
        { label: "Finalizada", value: "finished" },
      ],
    },
    {
      name: "currentRound",
      type: "number",
      required: true,
      defaultValue: 0,
    },
    {
      name: "sessionSeed",
      type: "text",
    },
    {
      name: "settings",
      type: "group",
      fields: [
        {
          name: "difficulty",
          type: "select",
          options: ["low", "medium", "high"],
        },
        {
          name: "firstActivity",
          type: "select",
          options: activityOptions,
        },
        {
          name: "roundCount",
          type: "number",
        },
        {
          name: "tempoBpm",
          type: "number",
        },
      ],
    },
    {
      name: "participants",
      type: "array",
      fields: [
        {
          name: "user",
          type: "relationship",
          relationTo: "users",
          required: true,
        },
        {
          name: "joinOrder",
          type: "number",
          required: true,
        },
      ],
    },
  ],
  timestamps: true,
};
