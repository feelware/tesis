import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  requireUser,
} from "@/lib/game/server";
import { respondInvitation } from "@/lib/game/teacher";

export const POST = async (
  request: NextRequest,
  context: { params: Promise<{ id: string }> },
) => {
  try {
    const { id } = await context.params;
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    const body = (await request.json().catch(() => ({}))) as {
      action?: string;
    };
    if (body.action !== "accept" && body.action !== "reject") {
      return NextResponse.json(
        { error: "la acción debe ser accept o reject" },
        { status: 400 },
      );
    }
    await respondInvitation(payload, user, id, body.action === "accept");
    return NextResponse.json({ responded: true });
  } catch (error) {
    return errorResponse(error);
  }
};
