import type { CollectionConfig } from "payload";
import { Users } from "@/collections/Users";
import { GameRooms } from "@/collections/GameRooms";
import { Submissions } from "@/collections/Submissions";
import { Media } from "@/collections/Media";

const collections: CollectionConfig[] = [Users, GameRooms, Submissions, Media];

export default collections;
