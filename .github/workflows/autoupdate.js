const { exec } = require("child_process");

module.exports = ({github, context}) => {
  github.repos.getLatestRelease({
    owner: 'conda-forge',
    repo: 'miniforge',
  }).then((release) => {
    const miniforge_version = release['data']['tag_name'];

    exec("sed -i -e 's/MINIFORGE_VERSION: \"[0-9.\\-]*\"/MINIFORGE_VERSION: \"" + miniforge_version + "\"/' azure-pipelines.yml", (error, stdout, stderr) => {
      if (error) {
        console.log(`error: ${error.message}`);
        return;
      }
      if (stderr) {
        console.log(`stderr: ${stderr}`);
        return;
      }
      exec("sed -i -e 's/MINIFORGE_VERSION=[0-9.\\-]*/MINIFORGE_VERSION=" + miniforge_version + "/' ubuntu/Dockerfile", (error, stdout, stderr) => {
        if (error) {
          console.log(`error: ${error.message}`);
          return;
        }
        if (stderr) {
          console.log(`stderr: ${stderr}`);
          return;
        }
      });
    });
  });
}
