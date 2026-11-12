import type { CollectionConfig } from "payload";

export const Melodies: CollectionConfig = {
  slug: "melodies",
  admin: {
    defaultColumns: ["seed", "difficulty", "tempoBpm", "key", "createdAt"],
  },
  access: {
    create: () => true,
    read: () => true,
    update: () => false,
    delete: () => true,
  },
  fields: [
    {
      name: "symbolicData",
      type: "json",
      required: true,
    },
    {
      name: "seed",
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
      name: "tempoBpm",
      type: "number",
      required: true,
    },
    {
      name: "generatorVersion",
      type: "text",
    },
    {
      name: "key",
      type: "text",
    },
    {
      name: "scale",
      type: "text",
    },
  ],
};
