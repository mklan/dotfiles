#!/usr/bin/env -S deno run -A --allow-env

Deno.serve(async (_req) => {
  let url = new URL(_req.url);
  if (url.pathname === "/notify") {
    const text = url.searchParams.get("text");
    const type = url.searchParams.get("type");

    if (!text) return new Response("todo proper error [no text]");

    if (type === "sms") {
      let numbers = text.match(/\d+/);
      if (numbers![0]) {
        console.log(numbers![0]);
        toClipboard(numbers![0]);
        await handleNotify(`code ${numbers![0]} copied to clipboard`);
      }
    }

    const response = await handleNotify(text || "no text");

    return new Response(response);
  }
  return new Response("welcome");
});

async function handleNotify(text: string) {
  return run("notify-send", [text]);
}

async function toClipboard(text: string) {
  return run("wl-copy", [text]);
}

async function run(command: string, args: string[]) {
  let res = new Deno.Command(command, { args });
  let { code, stdout, stderr } = await res.output();
  return new TextDecoder().decode(stdout);
}
