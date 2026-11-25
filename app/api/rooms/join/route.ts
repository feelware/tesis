import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  joinRoom,
  readJson,
  requireUser,
} from "@/lib/game/server";

export const POST = async (request: NextRequest) => {
  try {
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    const body = await readJson(request);
    const room = await joinRoom(payload, user, body.code);
    return NextResponse.json(room);
  } catch (error) {
    return errorResponse(error);
  }
};
