import { execute } from "../utils/execute.ts";

export const hyprctl = async (...args: string[]) => {
  const command = args.map(arg => `hyprctl ${arg}`).join('&&');

  return await execute(command);
}

export const batch = async (...args: string[]) => {
  return await execute(`hyprctl --batch "${args.join(';')}"`);
}