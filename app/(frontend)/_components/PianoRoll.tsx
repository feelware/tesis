"use client";

import { Note } from "tonal";
import type { NoteEvent } from "@/lib/music";

export interface PianoRollProps {
  notes: NoteEvent[];
  minPitch: number;
  maxPitch: number;
  totalBeats: number;
  gridBeats: number;
  editable?: boolean;
  onToggleNote?: (midiPitch: number, onsetBeats: number) => void;
  playheadBeat?: number | null;
  colorForNote?: (note: NoteEvent, index: number) => string | undefined;
}

const CELL_WIDTH = 16;
const CELL_HEIGHT = 16;
const BLACK_KEYS = new Set([1, 3, 6, 8, 10]);

export const PianoRoll = ({
  notes,
  minPitch,
  maxPitch,
  totalBeats,
  gridBeats,
  editable = false,
  onToggleNote,
  playheadBeat = null,
  colorForNote,
}: PianoRollProps) => {
  const rows = maxPitch - minPitch + 1;
  const columns = Math.ceil(totalBeats / gridBeats);
  const width = columns * CELL_WIDTH;
  const height = rows * CELL_HEIGHT;

  const toggleAt = (event: React.MouseEvent<HTMLDivElement>) => {
    if (!editable || !onToggleNote) return;
    const bounds = event.currentTarget.getBoundingClientRect();
    const column = Math.floor((event.clientX - bounds.left) / CELL_WIDTH);
    const row = Math.floor((event.clientY - bounds.top) / CELL_HEIGHT);
    if (column < 0 || column >= columns || row < 0 || row >= rows) return;
    onToggleNote(maxPitch - row, column * gridBeats);
  };

  return (
    <div className="overflow-x-auto rounded border border-zinc-300 bg-white">
      <div className="relative" style={{ width: width + 48, height }}>
        <div className="absolute left-0 top-0" style={{ width: 48, height }}>
          {Array.from({ length: rows }, (_, row) => {
            const midiPitch = maxPitch - row;
            return (
              <div
                key={midiPitch}
                className={`flex items-center justify-end pr-1 text-[9px] ${
                  BLACK_KEYS.has(((midiPitch % 12) + 12) % 12)
                    ? "bg-zinc-200 text-zinc-500"
                    : "bg-zinc-50 text-zinc-600"
                }`}
                style={{ height: CELL_HEIGHT }}
              >
                {midiPitch % 12 === 0 ? Note.fromMidi(midiPitch) : ""}
              </div>
            );
          })}
        </div>
        <div
          className={`absolute top-0 ${editable ? "cursor-crosshair" : ""}`}
          style={{
            left: 48,
            width,
            height,
            backgroundColor: "#fafafa",
            backgroundImage: `
              repeating-linear-gradient(to right, #e4e4e7 0 1px, transparent 1px ${gridBeats >= 1 ? CELL_WIDTH : CELL_WIDTH * 2}px),
              repeating-linear-gradient(to right, #a1a1aa 0 1px, transparent 1px ${CELL_WIDTH * 4}px),
              repeating-linear-gradient(to bottom, #e4e4e7 0 1px, transparent 1px ${CELL_HEIGHT}px)
            `,
          }}
          onClick={toggleAt}
        >
          {notes.map((note, index) => {
            const row = maxPitch - note.midiPitch;
            if (row < 0 || row >= rows) return null;
            return (
              <div
                key={`${note.midiPitch}-${note.onsetBeats}-${index}`}
                className="absolute rounded-sm"
                style={{
                  left: (note.onsetBeats / gridBeats) * CELL_WIDTH + 1,
                  width: Math.max((note.durationBeats / gridBeats) * CELL_WIDTH - 2, 6),
                  top: row * CELL_HEIGHT + 1,
                  height: CELL_HEIGHT - 2,
                  backgroundColor: colorForNote?.(note, index) ?? "#6366f1",
                }}
              />
            );
          })}
          {playheadBeat !== null ? (
            <div
              className="absolute top-0 h-full w-px bg-red-500"
              style={{ left: (playheadBeat / gridBeats) * CELL_WIDTH }}
            />
          ) : null}
        </div>
      </div>
    </div>
  );
};
