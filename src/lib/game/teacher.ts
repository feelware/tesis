import type { Payload } from "payload";
import type { Submission, User } from "@payload-types";
import { isAdmin } from "@/lib/user";
import type { EvaluationResult } from "@/lib/music";
import {
  gameSortScore,
  scoreAverages,
  sortScores,
} from "./rules";
import { buildTrendSeries } from "./insights";
import { HttpError, fetchNames, idOf } from "./server";
import type {
  ClassroomDetail,
  ClassroomGameRow,
  ClassroomInfo,
  ClassroomStudentRow,
  InvitationInfo,
  LiveGameInfo,
  MetricKey,
  MetricPoint,
  MyGameInfo,
  MyOverview,
  SortOrder,
} from "./types";

export interface ClassroomQuery {
  student?: string | null;
  metric?: MetricKey;
  order?: SortOrder;
  studentMetric?: MetricKey | "gamesPlayed";
  studentOrder?: SortOrder;
}

const parseMetric = (value: unknown, fallback: MetricKey): MetricKey =>
  value === "pitch" || value === "rhythm" || value === "overall"
    ? value
    : fallback;

const parseOrder = (value: unknown, fallback: SortOrder): SortOrder =>
  value === "asc" || value === "desc" ? value : fallback;

const parseStudentMetric = (
  value: unknown,
): MetricKey | "gamesPlayed" | null =>
  value === "pitch" ||
  value === "rhythm" ||
  value === "overall" ||
  value === "gamesPlayed"
    ? value
    : null;

const groupEvaluations = (
  docs: Submission[],
): Map<number, Map<number, EvaluationResult[]>> => {
  const byRoomPlayer = new Map<number, Map<number, EvaluationResult[]>>();
  for (const doc of docs) {
    const evaluation = (doc.evaluation ?? null) as EvaluationResult | null;
    if (!evaluation) continue;
    const roomId = idOf(doc.room);
    const playerId = idOf(doc.player);
    const perPlayer = byRoomPlayer.get(roomId) ?? new Map();
    const list = perPlayer.get(playerId) ?? [];
    list.push(evaluation);
    perPlayer.set(playerId, list);
    byRoomPlayer.set(roomId, perPlayer);
  }
  return byRoomPlayer;
};

const fetchUserInfo = async (
  payload: Payload,
  ids: number[],
): Promise<Map<number, { name: string; email: string }>> => {
  const unique = [...new Set(ids)];
  if (unique.length === 0) return new Map();
  const users = await payload.find({
    collection: "users",
    where: { id: { in: unique } },
    pagination: false,
    depth: 0,
  });
  return new Map(
    users.docs.map((doc) => [
      Number(doc.id),
      { name: doc.name ?? doc.email, email: doc.email },
    ]),
  );
};

interface RawLiveGame {
  roomId: string;
  code: string;
  classroomNames: string[];
  currentRound: number;
  roundCount: number;
  playerIds: number[];
}

// Partidas en curso donde participa al menos un miembro de cada grupo de
// salones; una partida compartida entre salones aparece una sola vez.
const findLiveGames = async (
  payload: Payload,
  groups: { name: string; memberIds: number[] }[],
): Promise<RawLiveGame[]> => {
  const byRoom = new Map<string, RawLiveGame>();
  for (const { name, memberIds } of groups) {
    if (memberIds.length === 0) continue;
    const rooms = await payload.find({
      collection: "game-rooms",
      where: {
        status: { equals: "in_progress" },
        "participants.user": { in: memberIds },
      },
      pagination: false,
      depth: 0,
      sort: "-updatedAt",
    });
    for (const room of rooms.docs) {
      const roomId = String(room.id);
      const entry = byRoom.get(roomId) ?? {
        roomId,
        code: room.code,
        classroomNames: [],
        currentRound: room.currentRound,
        roundCount: room.settings?.roundCount ?? 0,
        playerIds: (room.participants ?? [])
          .slice()
          .sort((a, b) => a.joinOrder - b.joinOrder)
          .map((item) => idOf(item.user)),
      };
      if (!entry.classroomNames.includes(name)) {
        entry.classroomNames.push(name);
      }
      byRoom.set(roomId, entry);
    }
  }
  return [...byRoom.values()];
};

const withPlayerNames = async (
  payload: Payload,
  games: RawLiveGame[],
): Promise<LiveGameInfo[]> => {
  const names = await fetchNames(
    payload,
    games.flatMap((game) => game.playerIds),
  );
  return games.map((game) => ({
    roomId: game.roomId,
    code: game.code,
    classroomNames: game.classroomNames,
    currentRound: game.currentRound,
    roundCount: game.roundCount,
    players: game.playerIds.map(
      (id) => names.get(id) ?? `jugador ${id}`,
    ),
  }));
};

export const readMyOverview = async (
  payload: Payload,
  user: User,
): Promise<MyOverview> => {
  const rooms = await payload.find({
    collection: "game-rooms",
    where: {
      "participants.user": { equals: user.id },
      status: { equals: "finished" },
    },
    pagination: false,
    depth: 0,
    sort: "-updatedAt",
  });
  const roomIds = rooms.docs.map((doc) => doc.id);
  const submissions =
    roomIds.length > 0
      ? ((await payload.find({
          collection: "submissions",
          where: {
            room: { in: roomIds },
            status: { equals: "done" },
          },
          pagination: false,
          depth: 0,
        })).docs as Submission[])
      : [];
  const byRoomPlayer = groupEvaluations(submissions);
  const games: MyGameInfo[] = rooms.docs.map((room) => {
    const perPlayer = byRoomPlayer.get(Number(room.id)) ?? new Map();
    const scores = [...perPlayer.entries()]
      .map(([playerId, evaluations]) => ({
        userId: String(playerId),
        name: "",
        ...scoreAverages(evaluations),
      }))
      .sort((a, b) => b.overall - a.overall);
    const mineIndex = scores.findIndex(
      (score) => score.userId === String(user.id),
    );
    const mine = scores[mineIndex];
    return {
      roomId: String(room.id),
      code: room.code,
      finishedAt: room.updatedAt,
      roundCount: room.settings?.roundCount ?? 0,
      pitch: mine?.pitch ?? 0,
      rhythm: mine?.rhythm ?? 0,
      overall: mine?.overall ?? 0,
      position: mineIndex >= 0 ? mineIndex + 1 : 0,
      playerCount: scores.length,
    };
  });

  const invitations = await payload.find({
    collection: "classroom-invitations",
    where: { user: { equals: user.id }, status: { equals: "pending" } },
    pagination: false,
    depth: 0,
    sort: "-createdAt",
  });
  const classroomIds = invitations.docs.map((doc) => idOf(doc.classroom));
  const classroomDocs =
    classroomIds.length > 0
      ? (await payload.find({
          collection: "classrooms",
          where: { id: { in: classroomIds } },
          pagination: false,
          depth: 0,
        })).docs
      : [];
  const classroomById = new Map(
    classroomDocs.map((doc) => [Number(doc.id), doc]),
  );
  const names = await fetchNames(
    payload,
    invitations.docs.map((doc) => idOf(doc.invitedBy ?? 0)),
  );
  const invitationInfos: InvitationInfo[] = invitations.docs.map((doc) => {
    const classroom = classroomById.get(idOf(doc.classroom));
    const teacherId = classroom ? idOf(classroom.teacher) : 0;
    return {
      id: String(doc.id),
      classroomId: String(idOf(doc.classroom)),
      classroomName: classroom?.name ?? "salón",
      teacherName: names.get(teacherId) ?? `docente ${teacherId}`,
      createdAt: doc.createdAt,
    };
  });

  const myClassrooms = await payload.find({
    collection: "classrooms",
    where: { teacher: { equals: user.id } },
    pagination: false,
    depth: 0,
    sort: "createdAt",
  });
  const myClassroomIds = myClassrooms.docs.map((doc) => doc.id);
  const classroomInvitations =
    myClassroomIds.length > 0
      ? (await payload.find({
          collection: "classroom-invitations",
          where: { classroom: { in: myClassroomIds } },
          pagination: false,
          depth: 0,
        })).docs
      : [];
  const classroomInfos: ClassroomInfo[] = myClassrooms.docs.map((classroom) => {
    const ofClassroom = classroomInvitations.filter(
      (invitation) => idOf(invitation.classroom) === Number(classroom.id),
    );
    return {
      id: String(classroom.id),
      name: classroom.name,
      memberCount: ofClassroom.filter(
        (invitation) => invitation.status === "accepted",
      ).length,
      pendingCount: ofClassroom.filter(
        (invitation) => invitation.status === "pending",
      ).length,
    };
  });

  const liveGames = await withPlayerNames(
    payload,
    await findLiveGames(
      payload,
      myClassrooms.docs.map((classroom) => ({
        name: classroom.name,
        memberIds: classroomInvitations
          .filter(
            (invitation) =>
              idOf(invitation.classroom) === Number(classroom.id) &&
              invitation.status === "accepted",
          )
          .map((invitation) => idOf(invitation.user)),
      })),
    ),
  );

  return {
    role: user.role,
    games,
    invitations: invitationInfos,
    classrooms: classroomInfos,
    liveGames,
  };
};

const findClassroom = async (payload: Payload, classroomId: string) => {
  try {
    return await payload.findByID({
      collection: "classrooms",
      id: classroomId,
      depth: 0,
    });
  } catch {
    throw new HttpError(404, "el salón no existe");
  }
};

export const createClassroom = async (
  payload: Payload,
  user: User,
  nameValue: unknown,
): Promise<{ id: string; name: string }> => {
  const name = String(nameValue ?? "").trim();
  if (name.length < 2) {
    throw new HttpError(400, "el nombre del salón debe tener al menos 2 caracteres");
  }
  const classroom = await payload.create({
    collection: "classrooms",
    data: { name, teacher: user.id },
  });
  return { id: String(classroom.id), name };
};

const requireClassroomTeacher = async (
  payload: Payload,
  user: User,
  classroomId: string,
) => {
  const classroom = await findClassroom(payload, classroomId);
  if (!isAdmin(user) && String(idOf(classroom.teacher)) !== String(user.id)) {
    throw new HttpError(403, "no eres el docente de este salón");
  }
  return classroom;
};

export const readClassroomDetail = async (
  payload: Payload,
  user: User,
  classroomId: string,
  query: ClassroomQuery,
): Promise<ClassroomDetail> => {
  const classroom = await requireClassroomTeacher(payload, user, classroomId);
  const metric = parseMetric(query.metric, "overall");
  const order = parseOrder(query.order, "desc");
  const studentMetric = parseStudentMetric(query.studentMetric) ?? "overall";
  const studentOrder = parseOrder(query.studentOrder, "desc");
  const filterStudentId =
    typeof query.student === "string" && query.student !== ""
      ? query.student
      : null;

  const invitations = await payload.find({
    collection: "classroom-invitations",
    where: { classroom: { equals: classroom.id } },
    pagination: false,
    depth: 0,
    sort: "createdAt",
  });
  const members = invitations.docs.filter(
    (invitation) => invitation.status === "accepted",
  );
  const pending = invitations.docs.filter(
    (invitation) => invitation.status === "pending",
  );
  const memberIds = members.map((invitation) => idOf(invitation.user));
  const userInfo = await fetchUserInfo(payload, [
    ...memberIds,
    ...pending.map((invitation) => idOf(invitation.user)),
    idOf(classroom.teacher),
  ]);

  const rooms =
    memberIds.length > 0
      ? (await payload.find({
          collection: "game-rooms",
          where: {
            status: { equals: "finished" },
            "participants.user": { in: memberIds },
          },
          pagination: false,
          depth: 0,
          sort: "-updatedAt",
        })).docs
      : [];
  const roomIds = rooms.map((room) => room.id);
  const submissions =
    roomIds.length > 0
      ? ((await payload.find({
          collection: "submissions",
          where: { room: { in: roomIds }, status: { equals: "done" } },
          pagination: false,
          depth: 0,
        })).docs as Submission[])
      : [];
  const byRoomPlayer = groupEvaluations(submissions);

  const memberSet = new Set(memberIds.map(Number));
  const games: ClassroomGameRow[] = rooms
    .filter((room) => {
      if (filterStudentId === null) return true;
      return (byRoomPlayer.get(Number(room.id)) ?? new Map()).has(
        Number(filterStudentId),
      );
    })
    .map((room) => {
      const perPlayer = byRoomPlayer.get(Number(room.id)) ?? new Map();
      const participants = [...perPlayer.entries()]
        .filter(([playerId]) => memberSet.has(playerId))
        .map(([playerId, evaluations]) => ({
          userId: String(playerId),
          name: userInfo.get(playerId)?.name ?? `jugador ${playerId}`,
          ...scoreAverages(evaluations),
        }));
      return {
        roomId: String(room.id),
        code: room.code,
        finishedAt: room.updatedAt,
        roundCount: room.settings?.roundCount ?? 0,
        participants,
        metric: gameSortScore(
          participants,
          filterStudentId === null ? null : String(filterStudentId),
          metric,
        ),
      };
    });
  const sortedGames = sortScores(games, "metric", order);

  const students: ClassroomStudentRow[] = members.map((invitation) => {
    const playerId = idOf(invitation.user);
    const evaluations: EvaluationResult[] = [];
    const points: MetricPoint[] = [];
    let gamesPlayed = 0;
    for (const room of rooms) {
      const perPlayer = byRoomPlayer.get(Number(room.id)) ?? new Map();
      const roomEvaluations = perPlayer.get(playerId);
      if (!roomEvaluations) continue;
      gamesPlayed += 1;
      evaluations.push(...roomEvaluations);
      points.push(scoreAverages(roomEvaluations));
    }
    return {
      userId: String(playerId),
      name: userInfo.get(playerId)?.name ?? `jugador ${playerId}`,
      email: userInfo.get(playerId)?.email ?? "",
      gamesPlayed,
      ...scoreAverages(evaluations),
      // rooms va del más reciente al más antiguo; la serie es cronológica.
      trend: buildTrendSeries(points.slice().reverse()),
    };
  });
  const sortedStudents = sortScores(students, studentMetric, studentOrder);

  return {
    classroom: {
      id: String(classroom.id),
      name: classroom.name,
      teacherName:
        userInfo.get(idOf(classroom.teacher))?.name ??
        `docente ${idOf(classroom.teacher)}`,
    },
    liveGames: await withPlayerNames(
      payload,
      await findLiveGames(payload, [{ name: classroom.name, memberIds }]),
    ),
    games: sortedGames,
    students: sortedStudents,
    invitations: pending.map((invitation) => ({
      id: String(invitation.id),
      name:
        userInfo.get(idOf(invitation.user))?.name ??
        `jugador ${idOf(invitation.user)}`,
      email: userInfo.get(idOf(invitation.user))?.email ?? "",
      createdAt: invitation.createdAt,
    })),
    filterStudentId,
  };
};

export const inviteStudent = async (
  payload: Payload,
  user: User,
  classroomId: string,
  emailValue: unknown,
): Promise<void> => {
  const classroom = await requireClassroomTeacher(payload, user, classroomId);
  const email = String(emailValue ?? "").trim().toLowerCase();
  if (!email.includes("@")) {
    throw new HttpError(400, "debes indicar un correo válido");
  }
  const exact = await payload.find({
    collection: "users",
    where: { email: { equals: email } },
    limit: 1,
    depth: 0,
  });
  let target: User | undefined = exact.docs[0];
  if (!target) {
    const all = await payload.find({
      collection: "users",
      pagination: false,
      depth: 0,
    });
    target = all.docs.find((doc) => doc.email.toLowerCase() === email);
  }
  if (!target) {
    throw new HttpError(404, "no existe un usuario con ese correo");
  }
  if (String(target.id) === String(user.id)) {
    throw new HttpError(400, "no puedes invitarte a ti mismo");
  }
  const existing = await payload.find({
    collection: "classroom-invitations",
    where: {
      classroom: { equals: classroom.id },
      user: { equals: target.id },
    },
    limit: 1,
    depth: 0,
  });
  const previous = existing.docs[0];
  if (previous?.status === "accepted") {
    throw new HttpError(400, "ese usuario ya forma parte del salón");
  }
  if (previous?.status === "pending") {
    throw new HttpError(400, "ese usuario ya tiene una invitación pendiente");
  }
  if (previous) {
    await payload.update({
      collection: "classroom-invitations",
      id: previous.id,
      data: { status: "pending", invitedBy: user.id },
    });
    return;
  }
  await payload.create({
    collection: "classroom-invitations",
    data: {
      classroom: classroom.id,
      user: target.id,
      status: "pending",
      invitedBy: user.id,
    },
  });
};

export const respondInvitation = async (
  payload: Payload,
  user: User,
  invitationId: string,
  accept: boolean,
): Promise<void> => {
  let invitation;
  try {
    invitation = await payload.findByID({
      collection: "classroom-invitations",
      id: invitationId,
      depth: 0,
    });
  } catch {
    throw new HttpError(404, "la invitación no existe");
  }
  if (String(idOf(invitation.user)) !== String(user.id)) {
    throw new HttpError(403, "esta invitación no es tuya");
  }
  if (invitation.status !== "pending") {
    throw new HttpError(400, "esta invitación ya fue respondida");
  }
  await payload.update({
    collection: "classroom-invitations",
    id: invitation.id,
    data: { status: accept ? "accepted" : "rejected" },
  });
};
