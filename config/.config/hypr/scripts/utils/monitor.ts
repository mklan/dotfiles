import { hyprctl } from "../lib/hyprctl.ts";

export async function getFocusedMonitor() {
  const monitors = await hyprctl("monitors -j");
  return JSON.parse(monitors).find(({ focused }) => focused);
}