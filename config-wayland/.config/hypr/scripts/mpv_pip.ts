import { pip } from "./utils/pip.ts";
import { execute } from "./utils/execute.ts";
import { hyprctl } from "./lib/hyprctl.ts";
import { getFocusedMonitor } from "./utils/monitor.ts";
import { sleep } from "./utils/sleep.ts";


const pwidth = 640;
const pheight = 360;
const margin = 40;



const monitor = await getFocusedMonitor();


let [videoSrc] = Deno.args;

const command = `dispatch exec "[float;pin;size ${pwidth} ${pheight};center]" "mpv ${videoSrc}"`;

console.log(command);

await hyprctl(command);

await sleep(2000);

await hyprctl(`dispatch moveactive ${parseInt(monitor.width)/2 - pwidth / 2 - margin} ${parseInt(monitor.height)/2 - pheight / 2 - margin}`);

