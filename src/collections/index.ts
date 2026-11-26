import type { CollectionConfig } from "payload";
import { Users } from "@/collections/Users";
import { GameRooms } from "@/collections/GameRooms";
import { Submissions } from "@/collections/Submissions";
import { Media } from "@/collections/Media";
import { Classrooms } from "@/collections/Classrooms";
import { ClassroomInvitations } from "@/collections/ClassroomInvitations";

const collections: CollectionConfig[] = [
  Users,
  GameRooms,
  Submissions,
  Media,
  Classrooms,
  ClassroomInvitations,
];

export default collections;
