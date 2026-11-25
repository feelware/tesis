import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  readRoomState,
  requireUser,
} from "@/lib/game/server";

export const GET = async (
  request: NextRequest,
  context: { params: Promise<{ id: string }> },
) => {
  try {
    const { id } = await context.params;
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    const state = await readRoomState(payload, user, id);
    return NextResponse.json(state);
  } catch (error) {
    return errorResponse(error);
  }
};
