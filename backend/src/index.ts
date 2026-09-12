import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { cancel, finish, FREE_DAILY_SECONDS, Quota, QuotaError, reserve, RESERVATION_TTL_SECONDS } from "./quota.js";

initializeApp();
const db = getFirestore();
const day = () => new Date().toISOString().slice(0, 10);
const map = (e: unknown): never => { if (e instanceof QuotaError) throw new HttpsError(e.code === "quota-exceeded" ? "resource-exhausted" : e.code === "session-conflict" ? "already-exists" : "invalid-argument", e.code); throw e; };

export const reservePracticeSession = onCall({ region: "europe-west3", enforceAppCheck: process.env.PHRAVORA_ENV === "production" }, async request => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication is required.");
  const { missionID, durationSeconds } = request.data ?? {};
  const uid = request.auth.uid, sessionID = crypto.randomUUID(), quotaRef = db.doc(`users/${uid}/quota/current`), sessionRef = db.doc(`users/${uid}/sessions/${sessionID}`);
  try { await db.runTransaction(async tx => {
    const now = new Date(), existing = (await tx.get(quotaRef)).data();
    const quota: Quota = existing?.dateBucket === day() ? existing as Quota : { dateBucket: day(), secondsUsed: 0, secondsReserved: 0, dailyLimit: FREE_DAILY_SECONDS };
    const updated = reserve(quota, { id: sessionID, uid, missionID, durationSeconds, state: "reserved", expiresAt: new Date(now.getTime() + RESERVATION_TTL_SECONDS * 1000) });
    tx.set(quotaRef, updated); tx.set(sessionRef, { missionID, durationSeconds, state: "reserved", createdAt: FieldValue.serverTimestamp(), expiresAt: new Date(now.getTime() + RESERVATION_TTL_SECONDS * 1000) });
  }); } catch (e) { map(e); }
  // This is only a server-authoritative quota reservation. It never creates a provider session.
  return { sessionID, state: "reserved" };
});

export const finishRealtimeSession = onCall({ region: "europe-west3", enforceAppCheck: process.env.PHRAVORA_ENV === "production" }, async request => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication is required.");
  const { sessionID, secondsUsed } = request.data ?? {}; const uid = request.auth.uid, quotaRef = db.doc(`users/${uid}/quota/current`), sessionRef = db.doc(`users/${uid}/sessions/${sessionID}`);
  await db.runTransaction(async tx => { const session = (await tx.get(sessionRef)).data(); if (!session || session.state !== "reserved") throw new HttpsError("failed-precondition", "Session is not active."); const quota=(await tx.get(quotaRef)).data() as Quota; const next = finish(quota,{id:sessionID,uid,...session,expiresAt:session.expiresAt.toDate()} as any, Number(secondsUsed)); const { activeSessionID: _, ...fields } = next; tx.update(quotaRef,{...fields,activeSessionID:FieldValue.delete()}); tx.update(sessionRef,{state:"finished",finishedAt:FieldValue.serverTimestamp()}); }); return { ok: true };
});

export const cancelRealtimeSession = onCall({ region: "europe-west3", enforceAppCheck: process.env.PHRAVORA_ENV === "production" }, async request => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication is required."); const { sessionID }=request.data??{}, uid=request.auth.uid, quotaRef=db.doc(`users/${uid}/quota/current`), sessionRef=db.doc(`users/${uid}/sessions/${sessionID}`);
  await db.runTransaction(async tx=>{const s=(await tx.get(sessionRef)).data(); if(!s || s.state!=="reserved") return; const q=(await tx.get(quotaRef)).data() as Quota; const next=cancel(q,{id:sessionID,uid,...s,expiresAt:s.expiresAt.toDate()} as any); const { activeSessionID: _, ...fields }=next; tx.update(quotaRef,{...fields,activeSessionID:FieldValue.delete()}); tx.update(sessionRef,{state:"cancelled",cancelledAt:FieldValue.serverTimestamp()});}); return {ok:true};
});
