#!/usr/bin/env -S deno run -A

import { writeFileSync, readFileSync } from "node:fs";
import { getFocusedMonitor } from "./utils/monitor.ts";
import { hyprctl, batch } from "./lib/hyprctl.ts";

(async () => {
  let [nextWorkspace] = Deno.args;
  const state = getState();

  const focusedMonitor = await getFocusedMonitor();
  const activeWorkspace = focusedMonitor.activeWorkspace.id;

  setState({
    ...state,
    [focusedMonitor.id]: activeWorkspace,
  });

  if (nextWorkspace === "last") {
    nextWorkspace = state[focusedMonitor.id];
  }

  if (nextWorkspace === "next") {
    await hyprctl("dispatch  workspace e+1");
    return;
  }

  if (!nextWorkspace || nextWorkspace == activeWorkspace) return;

  await batch(
    `dispatch moveworkspacetomonitor ${nextWorkspace} current`,
    `dispatch workspace ${nextWorkspace}`
  );
})();

// HELPER

function getState() {
  try {
    return JSON.parse(readFileSync("/dev/shm/hyprland.tmp", "utf-8"));
  } catch {
    return {};
  }
}

function setState(state) {
  writeFileSync("/dev/shm/hyprland.tmp", JSON.stringify(state, null, 2));
}
