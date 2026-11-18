export interface ModelParams {
  onsetThresh: number;
  frameThresh: number;
  minNoteLen: number;
  inferOnsets: boolean;
  maxFreq: number | null;
  minFreq: number | null;
  melodiaTrick: boolean;
  energyTolerance: number;
}

export const MODEL_PARAMS: ModelParams = {
  onsetThresh: 0.5,
  frameThresh: 0.3,
  minNoteLen: 12,
  inferOnsets: true,
  maxFreq: 1500,
  minFreq: 75,
  melodiaTrick: true,
  energyTolerance: 11,
};
