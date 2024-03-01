#!/usr/bin/env zx
$.verbose = false;

// TODO
if (!process.argv[3]) {
  await $`exit 1`;
}

const nodes = await $`bspc query -N -n .window -d focused`;

const found = nodes
  .toString()
  .split("\n")
  .filter((n) => !!n)
  .find((n) => n === process.argv[3]);

echo`${found}`;
