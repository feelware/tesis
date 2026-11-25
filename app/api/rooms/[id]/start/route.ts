import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  readJson,
  requireUser,
  startRoom,
} from "@/lib/game/server";

export const POST = async (
  request: NextRequest,
  context: { params: Promise<{ id: string }> },
) => {
  try {
    const { id } = await context.params;
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    const body = await readJson(request);
    await startRoom(payload, user, id, body.settings);
    return NextResponse.json({ started: true });
  } catch (error) {
    return errorResponse(error);
  }
};
