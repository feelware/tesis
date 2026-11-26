import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  requireUser,
} from "@/lib/game/server";
import { readMyOverview } from "@/lib/game/teacher";

export const GET = async (request: NextRequest) => {
  try {
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    const overview = await readMyOverview(payload, user);
    return NextResponse.json(overview);
  } catch (error) {
    return errorResponse(error);
  }
};
