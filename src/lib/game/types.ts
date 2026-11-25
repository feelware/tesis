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
  isSystem: boolean;
  roundNumber: number | null;
  activity: Activity | null;
  notes: NoteEvent[];
  recordingUrl: string | null;
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
