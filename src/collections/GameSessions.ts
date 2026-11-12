import type { CollectionConfig } from "payload";

const activityOptions = [
  { label: "Dictado", value: "dictation" },
  { label: "Repentización", value: "sight_singing" },
];

export const GameSessions: CollectionConfig = {
  slug: "game-sessions",
  admin: {
    defaultColumns: ["sessionSeed", "difficulty", "averageScore", "createdAt"],
  },
  access: {
    create: () => true,
    read: () => true,
    update: () => false,
    delete: () => true,
  },
  fields: [
    {
      name: "sessionSeed",
      type: "text",
      required: true,
    },
    {
      name: "difficulty",
      type: "select",
      required: true,
      options: ["low", "medium", "high"],
    },
    {
      name: "firstActivity",
      type: "select",
      required: true,
      options: activityOptions,
    },
    {
      name: "tempoBpm",
      type: "number",
      required: true,
    },
    {
      name: "averageScore",
      type: "number",
    },
    {
      name: "rounds",
      type: "array",
      fields: [
        {
          name: "roundNumber",
          type: "number",
          required: true,
        },
        {
          name: "activity",
          type: "select",
          required: true,
          options: activityOptions,
        },
        {
          name: "melody",
          type: "relationship",
          relationTo: "melodies",
        },
        {
          name: "response",
          type: "json",
        },
        {
          name: "pitchScore",
          type: "number",
        },
        {
          name: "rhythmScore",
          type: "number",
        },
        {
          name: "overallScore",
          type: "number",
        },
      ],
    },
  ],
};
