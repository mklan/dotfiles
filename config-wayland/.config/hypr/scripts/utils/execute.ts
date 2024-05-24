import { exec } from "node:child_process";

export async function execute(command: string, onData?: (data: string) => void): Promise<string> {
  return new Promise(async (resolve) => {
    const { stdout } = await exec(command);

    let result = "";

    
    stdout.on("data", (data) => {
      result += data.toString();
      onData && onData(data.toString());
    });

    stdout.on("end", () => resolve(result));
  });
}