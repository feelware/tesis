import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  requireProfessor,
  requireUser,
} from "@/lib/game/server";
import { resolveSpectateRoom } from "@/lib/game/teacher";

export const POST = async (request: NextRequest) => {
  try {
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    requireProfessor(user);
    const body = (await request.json().catch(() => ({}))) as {
      code?: string;
    };
    const room = await resolveSpectateRoom(payload, body.code);
    return NextResponse.json(room);
  } catch (error) {
    return errorResponse(error);
  }
};
