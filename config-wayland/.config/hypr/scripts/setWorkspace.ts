#!/usr/bin/env -S deno run -A
// Smart workspace switcher for multi-monitor Hyprland setups (Lua config).
// When a workspace is already on another monitor, it is moved to the focused
// monitor. History is kept in /dev/shm/ (tmpfs = RAM only, no disk writes).
//
// NOTE: Hyprland's Lua config manager breaks `hyprctl dispatch` — all
// dispatching goes through `hyprctl eval` with hl.dsp.* calls.

import { writeFileSync, readFileSync } from "node:fs";
import { hyprctl } from "./lib/hyprctl.ts";

const STATE_FILE = "/dev/shm/hypr-ws-history.json";
const MAX_HISTORY = 20;

type State = Record<number, { history: number[] }>;

const evalLua = (code: string) => hyprctl(`eval '${code}'`);

// ── Main ─────────────────────────────────────────────────────────────────────

(async () => {
  const [targetArg] = Deno.args;
  if (!targetArg) return;

  const state: State = getState();
  const monitors: any[] = JSON.parse(await hyprctl("monitors -j"));
  const focused = monitors.find((m: any) => m.focused);
  if (!focused) return;

  const focusedId = focused.id;
  const focusedName = focused.name;
  const currentWs = focused.activeWorkspace.id;

  for (const m of monitors) {
    if (!state[m.id]) state[m.id] = { history: [] };
  }

  // ── Relative / special workspace switches (pass-through) ──────────────────

  if (targetArg.startsWith("e") || targetArg === "previous") {
    await evalLua(`hl.dispatch(hl.dsp.focus({workspace="${targetArg}"}))`);
    return;
  }

  // ── "last" — most recent workspace on this monitor ────────────────────────

  if (targetArg === "last") {
    const last = popValidHistory(state, focusedId, monitors, focusedId);
    if (!last) return;
    pushHistory(state, focusedId, currentWs);
    await moveToFocusedMonitor(last, monitors, focusedId, focusedName);
    setState(state);
    return;
  }

  // ── Numeric workspace switch ──────────────────────────────────────────────

  const targetWs = parseInt(targetArg);
  if (isNaN(targetWs)) return;
  if (targetWs === currentWs) return;

  pushHistory(state, focusedId, currentWs);
  await moveToFocusedMonitor(targetWs, monitors, focusedId, focusedName);
  setState(state);
})();

// ── Core: move a workspace to the focused monitor ────────────────────────────

async function moveToFocusedMonitor(
  ws: number,
  monitors: any[],
  focusedId: number,
  focusedName: string,
) {
  const otherMon = monitors.find((m: any) => m.id !== focusedId && m.activeWorkspace.id === ws);

  if (otherMon) {
    // Workspace is on another monitor — move it here.
    // hl.dsp.workspace.move handles the source monitor automatically
    // (gives it its previous workspace when the moved ws was active).
    await evalLua(`hl.dispatch(hl.dsp.workspace.move({workspace=${ws}, monitor="${focusedName}"}))`);
    await evalLua(`hl.dispatch(hl.dsp.focus({workspace=${ws}}))`);
  } else {
    // Workspace is free — just switch
    await evalLua(`hl.dispatch(hl.dsp.focus({workspace=${ws}}))`);
  }
}

// ── History helpers ──────────────────────────────────────────────────────────

function popValidHistory(
  state: State,
  monitorId: number,
  monitors: any[],
  excludeMonitorId: number,
): number | null {
  const hist = state[monitorId].history;
  while (hist.length > 0) {
    const candidate = hist.shift()!;
    const taken = monitors.some(
      (m: any) => m.id !== excludeMonitorId && m.activeWorkspace.id === candidate,
    );
    if (!taken) return candidate;
  }
  return null;
}

function pushHistory(state: State, monitorId: number, ws: number) {
  const hist = state[monitorId].history;
  if (hist[0] !== ws) hist.unshift(ws);
  while (hist.length > MAX_HISTORY) hist.pop();
}

// ── State persistence (/dev/shm = tmpfs = RAM) ─────────────────────────────

function getState(): State {
  try {
    return JSON.parse(readFileSync(STATE_FILE, "utf-8"));
  } catch {
    return {};
  }
}

function setState(state: State) {
  writeFileSync(STATE_FILE, JSON.stringify(state));
}
