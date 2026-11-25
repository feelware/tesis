import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  readJson,
  requireUser,
  submitResponse,
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
    const result = await submitResponse(
      payload,
      user,
      id,
      body.response,
      body.recordingId,
    );
    return NextResponse.json(result);
  } catch (error) {
    return errorResponse(error);
  }
};
