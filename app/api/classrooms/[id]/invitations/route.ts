import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  requireProfessor,
  requireUser,
} from "@/lib/game/server";
import { inviteStudent } from "@/lib/game/teacher";

export const POST = async (
  request: NextRequest,
  context: { params: Promise<{ id: string }> },
) => {
  try {
    const { id } = await context.params;
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    requireProfessor(user);
    const body = (await request.json().catch(() => ({}))) as {
      email?: string;
    };
    await inviteStudent(payload, user, id, body.email);
    return NextResponse.json({ invited: true });
  } catch (error) {
    return errorResponse(error);
  }
};
