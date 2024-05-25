#!/usr/bin/env -S deno run -A --allow-env

import { execute as $ } from "./utils/execute.ts";

const [packagesFile] = Deno.args;

const packages = await Deno.readTextFile(packagesFile).then(JSON.parse);



const options = Object.entries(packages).sort((a, b) => {
  if (a[0] < b[0]) {
    return -1;
  }
  if (a[0] > b[0]) {
    return 1;
  }
  return 0;
}).map(([name, comment]) => {
  return `"${name}" "${comment}" "on"`;
}).join(' ');

const selection = await $(`dialog --separate-output --checklist "Select options:" 22 76 16 ${options} 2>&1 >/dev/tty`);

console.log(selection);
