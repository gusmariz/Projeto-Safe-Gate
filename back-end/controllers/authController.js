import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../database/connection.js';

export const register = async (req, res) => {
  try {
    const { nome, email, senha, cpf, telefone } = req.body;
    const hashedPassword = await bcrypt.hash(senha, 10);

    await pool.query(
      `INSERT INTO usuarios (nome, email, senha, cpf, telefone) 
       VALUES (?, ?, ?, ?, ?)`,
      [nome, email, hashedPassword, cpf, telefone]
    );

    res.status(201).json({ message: 'Usuário criado com sucesso!' });
  } catch (error) {
    console.error("Erro no registro:", error);
    res.status(500).json({ error: 'Erro no servidor' });
  }
};

export const login = async (req, res) => {
  try {
    const { email, senha } = req.body;
    const [users] = await pool.query('SELECT * FROM usuarios WHERE email = ?', [email]);

    if (!users.length) return res.status(401).json({ error: 'Credenciais inválidas' });

    const user = users[0];
    const validPassword = await bcrypt.compare(senha, user.senha);
    if (!validPassword) return res.status(401).json({ error: 'Credenciais inválidas' });

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.json({ token });
  } catch (error) {
    console.error("Erro no login:", error);
    res.status(500).json({ error: 'Erro no servidor' });
  }
};