import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

// Verificação das variáveis de ambiente
const requiredEnvVars = ['DB_HOST', 'DB_USER', 'DB_PASSWORD', 'DB_NAME', 'DB_PORT'];
for (const envVar of requiredEnvVars) {
  if (!process.env[envVar]) {
    throw new Error(`Variável de ambiente ${envVar} não definida`);
  }
}

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT), // Convertendo para número
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  connectTimeout: 10000 // 10 segundos de timeout
});

pool.query('SELECT DATABASE() AS db')
  .then(([rows]) => console.log('Conectado ao banco:', rows[0].db))
  .catch(err => console.error('Erro ao verificar database:', err));

// Teste de conexão assíncrona
(async () => {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Conexão com o MySQL estabelecida com sucesso!');
    connection.release();
  } catch (error) {
    console.error('❌ Erro ao conectar ao MySQL:', error.message);
    process.exit(1); // Encerra o aplicativo se a conexão falhar
  }
})();

export default pool;