import { hyprctl, batch } from "../lib/hyprctl.ts";
import { getFocusedMonitor } from "./monitor.ts";

const pwidth = 640;
const pheight = 360;
const margin = 40;

export async function pip() {
  const monitor = await getFocusedMonitor();

  await batch(
    "dispatch togglefloating",
    "dispatch pin",
    `dispatch resizeactive exact ${pwidth} ${pheight}`,
    "dispatch centerwindow"
  );

  await hyprctl(
    `dispatch moveactive ${
      parseInt(monitor.width) / monitor.scale / 2 - pwidth / 2 - margin
    } ${parseInt(monitor.height) / monitor.scale / 2 - pheight / 2 - margin}`
  );
}
