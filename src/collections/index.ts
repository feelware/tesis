import type { CollectionConfig } from "payload";
import { Users } from "@/collections/Users";
import { GameRooms } from "@/collections/GameRooms";
import { Submissions } from "@/collections/Submissions";

const collections: CollectionConfig[] = [Users, GameRooms, Submissions];

export default collections;
