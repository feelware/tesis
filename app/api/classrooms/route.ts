import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  requireProfessor,
  requireUser,
} from "@/lib/game/server";
import { createClassroom } from "@/lib/game/teacher";

export const POST = async (request: NextRequest) => {
  try {
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    requireProfessor(user);
    const body = (await request.json().catch(() => ({}))) as {
      name?: string;
    };
    const classroom = await createClassroom(payload, user, body.name);
    return NextResponse.json(classroom);
  } catch (error) {
    return errorResponse(error);
  }
};
