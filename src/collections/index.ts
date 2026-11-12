import type { CollectionConfig } from "payload";
import { Users } from "@/collections/Users";
import { Melodies } from "@/collections/Melodies";
import { GameSessions } from "@/collections/GameSessions";

const collections: CollectionConfig[] = [Users, Melodies, GameSessions];

export default collections;
