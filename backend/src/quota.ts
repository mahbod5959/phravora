export const validMissionIDs = new Set(["tell-yourself","experience","difficult-question","technical-clarity","polite-disagreement","status-update","clarification","dissatisfied-client","defend-decision","deadline","small-talk","present-idea"]);
export const FREE_DAILY_SECONDS = 600;
export const MAX_SESSION_SECONDS = 360;
export const RESERVATION_TTL_SECONDS = 300;
export type SessionState = "reserved" | "active" | "finished" | "cancelled" | "expired";
export type Quota = { dateBucket: string; secondsUsed: number; secondsReserved: number; dailyLimit: number; activeSessionID?: string };
export type Session = { id: string; uid: string; missionID: string; durationSeconds: number; state: SessionState; expiresAt: Date };
export class QuotaError extends Error { constructor(public code: "invalid-mission" | "invalid-duration" | "quota-exceeded" | "session-conflict") { super(code); } }
export function reserve(quota: Quota, session: Session, now = new Date()): Quota {
  if (!validMissionIDs.has(session.missionID)) throw new QuotaError("invalid-mission");
  if (session.durationSeconds < 30 || session.durationSeconds > MAX_SESSION_SECONDS) throw new QuotaError("invalid-duration");
  if (quota.activeSessionID) throw new QuotaError("session-conflict");
  if (quota.secondsUsed + quota.secondsReserved + session.durationSeconds > quota.dailyLimit) throw new QuotaError("quota-exceeded");
  return { ...quota, secondsReserved: quota.secondsReserved + session.durationSeconds, activeSessionID: session.id };
}
export function finish(quota: Quota, session: Session, secondsUsed: number): Quota {
  const used = Math.max(0, Math.min(secondsUsed, session.durationSeconds));
  return { ...quota, secondsReserved: Math.max(0, quota.secondsReserved - session.durationSeconds), secondsUsed: quota.secondsUsed + used, activeSessionID: undefined };
}
export function cancel(quota: Quota, session: Session): Quota { return { ...quota, secondsReserved: Math.max(0, quota.secondsReserved - session.durationSeconds), activeSessionID: undefined }; }
