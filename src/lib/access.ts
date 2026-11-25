import type { Access, FieldAccess } from "payload";
import { isAdmin, isProfessor } from "./user";

export const collectionAdminAccess: Access = ({ req }) =>
  req.user !== null && isAdmin(req.user);

export const fieldAdminAccess: FieldAccess = ({ req }) =>
  req.user !== null && isAdmin(req.user);

export const fieldProfessorAccess: FieldAccess = ({ req }) =>
  req.user !== null && (isAdmin(req.user) || isProfessor(req.user));
