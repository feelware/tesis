import { NextResponse, type NextRequest } from "next/server";
import {
  createRoom,
  errorResponse,
  getServerPayload,
  requireUser,
} from "@/lib/game/server";

export const POST = async (request: NextRequest) => {
  try {
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    const room = await createRoom(payload, user);
    return NextResponse.json(room);
  } catch (error) {
    return errorResponse(error);
  }
};
