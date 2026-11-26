import type {
  Difficulty,
  EvaluationResult,
  Melody,
  NoteEvent,
} from "@/lib/music";

export type Activity = "dictation" | "sight_singing";
export type RoomStatus = "waiting" | "in_progress" | "finished";
export type SubmissionStatus = "pending" | "done";

export interface GameSettings {
  difficulty: Difficulty;
  firstActivity: Activity;
  roundCount: number;
  tempoBpm: number;
  showRecordings: boolean;
}

export interface ParticipantInfo {
  userId: string;
  name: string;
  joinOrder: number;
  isHost: boolean;
}

export interface SubmissionInfo {
  id: string;
  status: SubmissionStatus;
  receivedMelody: Melody;
  receivedFromName: string | null;
  response: NoteEvent[] | null;
  evaluation: EvaluationResult | null;
}

export interface RoundPlayerStatus {
  userId: string;
  name: string;
  done: boolean;
}

export interface RoundState {
  number: number;
  activity: Activity;
  submission: SubmissionInfo | null;
  players: RoundPlayerStatus[];
}

export interface LeaderboardRound {
  roundNumber: number;
  activity: Activity;
  overall: number;
  pitch: number;
  rhythm: number;
}

export interface LeaderboardEntry {
  userId: string;
  name: string;
  overall: number;
  pitch: number;
  rhythm: number;
  rounds: LeaderboardRound[];
}

export interface RoomState {
  room: {
    id: string;
    code: string;
    status: RoomStatus;
    currentRound: number;
    settings: GameSettings | null;
    hostUserId: string;
    participants: ParticipantInfo[];
  };
  me: { userId: string; name: string };
  round: RoundState | null;
  leaderboard: LeaderboardEntry[] | null;
}

export interface GalleryMessage {
  authorName: string;
  authorUserId: string | null;
  isSystem: boolean;
  roundNumber: number | null;
  activity: Activity | null;
  notes: NoteEvent[];
  recordingUrl: string | null;
  evaluation: EvaluationResult | null;
}

export interface GalleryStrand {
  messages: GalleryMessage[];
}

export interface MyRoundRow {
  roundNumber: number;
  activity: Activity;
  receivedNotes: NoteEvent[];
  producedNotes: NoteEvent[];
  recordingUrl: string | null;
}

export interface GalleryData {
  showRecordings: boolean;
  strands: GalleryStrand[];
  myRounds: MyRoundRow[];
}

export type MetricKey = "pitch" | "rhythm" | "overall";
export type SortOrder = "asc" | "desc";

export interface PlayerScore {
  userId: string;
  name: string;
  pitch: number;
  rhythm: number;
  overall: number;
}

export interface MetricPoint {
  pitch: number;
  rhythm: number;
  overall: number;
}

export interface TrendSeries {
  pitch: number[];
  rhythm: number[];
  overall: number[];
}

export interface ClassroomGameRow {
  roomId: string;
  code: string;
  finishedAt: string;
  roundCount: number;
  participants: PlayerScore[];
  metric: number;
}

export interface ClassroomStudentRow extends PlayerScore {
  email: string;
  gamesPlayed: number;
  trend: TrendSeries;
}

export interface ClassroomDetail {
  classroom: { id: string; name: string; teacherName: string };
  liveGames: LiveGameInfo[];
  games: ClassroomGameRow[];
  students: ClassroomStudentRow[];
  invitations: { id: string; name: string; email: string; createdAt: string }[];
  filterStudentId: string | null;
}

export interface LiveGameInfo {
  roomId: string;
  code: string;
  classroomNames: string[];
  currentRound: number;
  roundCount: number;
  players: string[];
}

export interface InvitationInfo {
  id: string;
  classroomId: string;
  classroomName: string;
  teacherName: string;
  createdAt: string;
}

export interface MyGameInfo {
  roomId: string;
  code: string;
  finishedAt: string;
  roundCount: number;
  pitch: number;
  rhythm: number;
  overall: number;
  position: number;
  playerCount: number;
}

export interface ClassroomInfo {
  id: string;
  name: string;
  memberCount: number;
  pendingCount: number;
}

export interface MyOverview {
  role: "student" | "professor" | "admin";
  games: MyGameInfo[];
  invitations: InvitationInfo[];
  classrooms: ClassroomInfo[];
  liveGames: LiveGameInfo[];
}

export interface SpectateData {
  room: {
    id: string;
    code: string;
    status: RoomStatus;
    currentRound: number;
    roundCount: number;
    settings: GameSettings | null;
  };
  players: { userId: string; name: string }[];
  strands: GalleryStrand[];
}
