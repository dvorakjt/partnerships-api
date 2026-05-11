import { exec } from 'child_process';
import { promisify } from 'util';
import config from '../../pg-container.config';

const execAsync = promisify(exec);

class PostgresContainerManager {
  private static readonly platform = 'linux/amd64';
  private static readonly imageTag = '8by8engineeringteam/postgres-18:latest';

  public static async run(mode: 'dev' | 'test') {
    await this.checkDockerStatus();
    await this.pullImage();
    await this.runContainer(mode);
  }

  public static async stop(mode: 'dev' | 'test') {
    await this.checkDockerStatus();
    await execAsync(`docker stop ${config[mode].containerName}`);
  }

  private static async checkDockerStatus() {
    try {
      await execAsync('docker info');
    } catch (e) {
      throw new Error(
        'Cannot connect to the Docker daemon. Is Docker installed and running?',
      );
    }
  }

  private static async pullImage() {
    try {
      await execAsync(`docker pull --platform="${this.platform}" ${this.imageTag}`);
    } catch (e) {
      throw new Error(`Failed to pull image "${this.imageTag}".`, { cause: e });
    }
  }

  private static async runContainer(mode: 'dev' | 'test') {
    try {
      if (mode === 'dev') await this.runDevContainer();
      else await this.runTestContainer();
    } catch (e) {
      throw new Error('Failed to start PostgreSQL container.', { cause: e });
    }
  }

  private static async runDevContainer() {
    const { containerName, port, volumeName, dummyPassword } = config.dev;

    await execAsync(
      `docker run --platform="${this.platform}" -dp ${port}:5432 -v ${volumeName}:/var/lib/postgresql --rm -e POSTGRES_PASSWORD="${dummyPassword}" --name ${containerName} ${this.imageTag}`,
    );

    console.log(
      `PostgreSQL Dev Container running at http://localhost:${port}\nUser: postgres\nPassword: ${dummyPassword}`,
    );
  }

  private static async runTestContainer() {
    const { containerName, port, dummyPassword } = config.test;

    await execAsync(
      `docker run --platform="${this.platform}" -dp ${port}:5432 --rm -e POSTGRES_PASSWORD=${dummyPassword} --name ${containerName} ${this.imageTag}`,
    );

    console.log(
      `PostgreSQL Test Container running at http://localhost:${port}\nUser: postgres\nPassword: ${dummyPassword}`,
    );
  }
}

function isModeValid(mode: string): mode is 'dev' | 'test' {
  return mode === 'dev' || mode === 'test';
}

function isCommandValid(command: string): command is 'start' | 'stop' {
  return command === 'start' || command === 'stop';
}

function getModeAndCommand(): ['dev' | 'test', 'start' | 'stop'] {
  const args = process.argv.slice(2, 4);
  let mode = args[0].split('=')[1];
  if (/^"[^"]+"$/.test(mode)) mode = mode.slice(1, -1);
  const command = args[1];

  if (!isModeValid(mode)) {
    throw new Error(`Invalid mode. Expected "dev" or "test" but got "${mode}"`);
  }

  if (!isCommandValid(command)) {
    throw new Error(
      `Invalid command. Expected "start" or "stop" but got "${command}"`,
    );
  }

  return [mode, command];
}

const [mode, command] = getModeAndCommand();

if (command === 'start') {
  PostgresContainerManager.run(mode);
} else {
  PostgresContainerManager.stop(mode);
}
