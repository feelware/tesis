import type { User } from "@payload-types";

export type Role = User["role"];

export const isAdmin = (user: User): boolean => user.role === "admin";

export const isProfessor = (user: User): boolean => user.role === "professor";
