import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../database/connection.js';

export const register = async (req, res) => {
  try {
    const { nome, email, senha, cpf, telefone, tipo_usuario } = req.body;

    if (!['cliente', 'admin'].includes(tipo_usuario)) {
      return res.status(400).json({ error: 'Tipo de usuário inválido' });
    }

    const hashedPassword = await bcrypt.hash(senha, 10);

    await pool.query('CALL inserir_usuario(?, ?, ?, ?, ?, ?)', [
      nome, cpf, telefone, email, hashedPassword, tipo_usuario
    ]);

    res.status(201).json({ message: 'Usuário criado com sucesso!' });
  } catch (error) {
    console.error("Erro no registro:", error);
    if (error.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'Email ou CPF já cadastrado' });
    }
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

    const token = jwt.sign(
      {
        id: user.id_usuario,
        email: user.email,
        tipo_usuario: user.tipo_usuario
      },
      process.env.JWT_SECRET,
      { expiresIn: '1h' }
    );

    res.json({
      token,
      user: {
        id: user.id_usuario,
        nome: user.nome,
        email: user.email,
        cpf: user.cpf,
        telefone: user.telefone,
        tipo: user.tipo_usuario
      }
    });
  } catch (error) {
    console.error("Erro no login:", error);
    res.status(500).json({ error: 'Erro no servidor' });
  }
};

export const atualizarUsuario = async (req, res) => {
  try {
    const userEmail = req.body.email || req.user?.email;

    if (!userEmail) {
      return res.status(400).json({ error: 'Email é obrigatório' });
    }

    const [usuarios] = await pool.query('SELECT * FROM usuarios WHERE email = ?', [userEmail]);

    if (!usuarios.length) {
      return res.status(404).json({ error: 'Email não encontrado' });
    }

    const { nome, telefone, senha } = req.body;
    const senhaHash = senha ? await bcrypt.hash(senha, 10) : null;

    await pool.query(
      `UPDATE usuarios SET
        nome = COALESCE(?, nome),
        telefone = COALESCE(?, telefone),
        senha = COALESCE(?, senha)
      WHERE email = ?`,
      [nome, telefone, senhaHash, userEmail]
    );

    res.json({ message: 'Dados atualizados com sucesso!' });
  } catch (error) {
    console.log('Erro ao atualizar usuário:', error);
    res.status(500).json({ error: 'Erro no servidor' });
  }
};