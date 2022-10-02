#!/usr/bin/env zx
$.verbose = false;

const BACKGROUND_DESKTOP = 9;

const nodeId = await $`./getNodeByWMName.mjs KeePassXC`;

const found = await $`./isNodeOnFocusedDesktop.mjs ${nodeId}`;

const onFocusedDesktop = found.toString() === nodeId.toString();

const desktop = onFocusedDesktop ? BACKGROUND_DESKTOP : "focused";
const focus = onFocusedDesktop ? "" : "-f";

await $`bspc node ${nodeId} --to-desktop ${desktop} ${focus}`;

if (!onFocusedDesktop) {
  await $`./corner-float-node`;
}
