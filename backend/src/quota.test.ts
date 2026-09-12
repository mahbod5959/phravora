import { describe, expect, it } from "vitest";
import { cancel, finish, FREE_DAILY_SECONDS, QuotaError, reserve } from "./quota.js";
const quota = { dateBucket: "2026-08-28", secondsUsed: 0, secondsReserved: 0, dailyLimit: FREE_DAILY_SECONDS };
const session = { id: "s1", uid: "u1", missionID: "status-update", durationSeconds: 120, state: "reserved" as const, expiresAt: new Date() };
describe("quota", () => {
  it("reserves atomically and prevents concurrent active sessions", () => { const reserved = reserve(quota, session); expect(reserved.secondsReserved).toBe(120); expect(() => reserve(reserved, {...session,id:"s2"})).toThrow(QuotaError); });
  it("rejects invalid mission, duration, and over-limit use", () => { expect(() => reserve(quota,{...session,missionID:"bad"})).toThrow("invalid-mission"); expect(() => reserve(quota,{...session,durationSeconds: 361})).toThrow("invalid-duration"); expect(() => reserve({...quota,secondsUsed:590},{...session,durationSeconds:30})).toThrow("quota-exceeded"); });
  it("finishes and cancels safely", () => { const r=reserve(quota,session); expect(finish(r,session,90)).toMatchObject({secondsUsed:90,secondsReserved:0}); expect(cancel(r,session)).toMatchObject({secondsUsed:0,secondsReserved:0}); });
});
