import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  readSpectate,
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
    const data = await readSpectate(payload, user, id);
    return NextResponse.json(data);
  } catch (error) {
    return errorResponse(error);
  }
};
