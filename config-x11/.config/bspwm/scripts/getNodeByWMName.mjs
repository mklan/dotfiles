#!/usr/bin/env zx
$.verbose = false;

// TODO
if (!process.argv[3]) {
  await $`exit 1`;
}

const nodes = await $`bspc query -N -n .window`;

const nodeIds = nodes
  .toString()
  .split("\n")
  .filter((n) => !!n);

for await (const nodeId of nodeIds) {
  const title = await $`xtitle ${nodeId}`;
  if (title.toString().includes(process.argv[3])) {
    echo`${nodeId}`;
  }
}
