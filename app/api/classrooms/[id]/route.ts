import { NextResponse, type NextRequest } from "next/server";
import {
  errorResponse,
  getServerPayload,
  requireProfessor,
  requireUser,
} from "@/lib/game/server";
import { readClassroomDetail, type ClassroomQuery } from "@/lib/game/teacher";

export const GET = async (
  request: NextRequest,
  context: { params: Promise<{ id: string }> },
) => {
  try {
    const { id } = await context.params;
    const payload = await getServerPayload();
    const user = await requireUser(payload, request.headers);
    requireProfessor(user);
    const params = request.nextUrl.searchParams;
    const query: ClassroomQuery = {
      student: params.get("student"),
      metric: (params.get("metric") ?? undefined) as ClassroomQuery["metric"],
      order: (params.get("order") ?? undefined) as ClassroomQuery["order"],
      studentMetric: (params.get("studentMetric") ?? undefined) as
        ClassroomQuery["studentMetric"],
      studentOrder: (params.get("studentOrder") ?? undefined) as
        ClassroomQuery["studentOrder"],
    };
    const detail = await readClassroomDetail(payload, user, id, query);
    return NextResponse.json(detail);
  } catch (error) {
    return errorResponse(error);
  }
};
