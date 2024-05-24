import { execute as $ } from "./utils/execute.ts";

//const CMD_ROUTE = new URLPattern({ pathname: "/bash/:cmd" });
const CMD_ROUTE = new URLPattern({ pathname: "/bash" });

async function handler(req: Request): Response {

  const match = CMD_ROUTE.exec(req.url);
  const url = new URL(req.url);

  const cmd = url.searchParams.get('cmd');

  if (match) {
    if(!cmd) {
      return new Response("Cmd missing", { status: 401 })
    }
//    const { cmd } = match.pathname.groups;
    console.log(cmd);
    const res = await $(`${cmd}`);
    return new Response(`${res}`);
  }

  return new Response("Not found!", {
    status: 404,
  });
}

Deno.serve(handler);