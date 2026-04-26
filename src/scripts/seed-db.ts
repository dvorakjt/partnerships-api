import 'dotenv/config';
import fs from 'node:fs';
import path from 'node:path';
import { Client } from 'pg';

class DatabaseSeeder {
  private readonly seedsDir = path.join(import.meta.dirname, '../db/seeds');

  public async seed() {
    const client = new Client(this.databaseUrl);

    try {
      await client.connect();

      const files = this.seedFiles;
      if (files.length === 0) {
        console.log('No seed files found.');
        return;
      }

      for (const file of files) {
        const fullPath = path.join(this.seedsDir, file);
        const sql = fs.readFileSync(fullPath, 'utf-8');

        console.log(`Seeding: ${file}`);
        await client.query(sql);
      }

      console.log('Database seeding complete.');
    } finally {
      await client.end();
    }
  }

  private get databaseUrl() {
    return (
      'postgresql://' +
      process.env.DB_USER +
      ':' +
      process.env.DB_PASSWORD +
      '@' +
      process.env.DB_HOST +
      ':' +
      process.env.DB_PORT +
      '/' +
      process.env.DB_NAME +
      '?sslmode=disable'
    );
  }

  private get seedFiles() {
    const filesFromArg = process.argv.slice(2);

    if (filesFromArg.length > 0) {
      return filesFromArg;
    }

    return fs
      .readdirSync(this.seedsDir)
      .filter(file => file.endsWith('.sql'))
      .sort((a, b) => a.localeCompare(b));
  }
}

new DatabaseSeeder().seed().catch(error => {
  console.error(error);
  process.exit(1);
});
