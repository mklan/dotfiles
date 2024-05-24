const { exec } = require('child_process');


(async () => {

  const output = await run('notify-send was');

  console.log(output);

})();


function run(command) {
  return new Promise((resolve, reject) => {
    exec(command, (e, stdout, stderr) => {
      if (e instanceof Error) {
        reject(e)
      }
      resolve({ stdout, stderr });
    });
  });
}