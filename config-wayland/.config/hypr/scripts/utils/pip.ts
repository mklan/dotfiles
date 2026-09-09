import { execute } from "../utils/execute.ts";

const pwidth = 640;
const pheight = 360;
const margin = 40;

// Runs the pip toggle as a single Lua chunk inside the running Lua config
// (Hyprland 0.56+). Uses the hl.* query/dispatch API instead of the old
// hyprlang-era dispatcher strings.
const pipChunk = `
local w, h, margin = ${pwidth}, ${pheight}, ${margin};
local win = hl.get_active_window();
hl.dispatch(hl.dsp.window.float({ action = "toggle" }));
if win.floating then
  local m = hl.get_active_monitor();
  -- hl.dsp.window.move targets the TOP-LEFT of the window, while the old
  -- hyprlang moveactive targeted its CENTER. Subtract the full window
  -- size to keep the same corner placement.
  local x = math.floor(m.width / m.scale / 2 - w - margin);
  local y = math.floor(m.height / m.scale / 2 - h - margin);
  hl.dispatch(hl.dsp.window.pin({ action = "toggle" }));
  hl.dispatch(hl.dsp.window.resize({ x = w, y = h }));
  hl.dispatch(hl.dsp.window.center({}));
  hl.dispatch(hl.dsp.window.move({ x = x, y = y }));
end
`;

export async function pip() {
  return await execute(`hyprctl eval '${pipChunk}'`);
}
