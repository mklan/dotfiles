import { exec } from "node:child_process";

export async function execute(command): Promise<string> {
  return new Promise(async (resolve) => {
    const { stdout } = await exec(command);

    let result = "";

    stdout.on("data", (data) => {
      result += data.toString();
    });

    stdout.on("end", () => resolve(result));
  });
}