import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  leaveRoom,
  requireUser,
} from "@/lib/game/server";

export const POST = async (
  request: NextRequest,
  context: { params: Promise<{ id: string }> },
) => {
  try {
    const { id } = await context.params;
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    await leaveRoom(payload, user, id);
    return NextResponse.json({ left: true });
  } catch (error) {
    return errorResponse(error);
  }
};
