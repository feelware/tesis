import { NextResponse, type NextRequest } from "next/server";
import {
  closeRound,
  errorResponse,
  getServerPayload,
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
    await closeRound(payload, user, id);
    return NextResponse.json({ closed: true });
  } catch (error) {
    return errorResponse(error);
  }
};
