import { hyprctl } from "../lib/hyprctl.ts";

export async function getFocusedMonitor() {
  const monitors = await hyprctl("monitors -j");
  return JSON.parse(monitors).find(({ focused }) => focused);
}

export async function getActiveWindow() {
  return await hyprctl("activewindow -j").then(JSON.parse);
}
