const { Pool } = require('pg');

let pool;

function getPool() {
  if (!pool) {
    pool = new Pool({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT || 5432,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      max: 20,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });
  }
  return pool;
}

async function query(text, params, ownerId) {
  const client = await getPool().connect();
  try {
    if (ownerId) {
      await client.query('SET LOCAL app.current_owner_id = $1', [ownerId]);
    }
    const result = await client.query(text, params);
    return result;
  } finally {
    client.release();
  }
}

async function getClient() {
  return getPool().connect();
}

module.exports = {
  getPool,
  query,
  getClient
};
