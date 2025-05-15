import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../database/connection.js';

export const register = async (req, res) => {
    try {
        const { nome, email, senha, cpf, telefone } = req.body;
        const hashedPassword = await bcrypt.hash(senha, 10);

        const [result] = await pool.query(
            'insert into usuarios (nome, email, senha, cpf, telefone) values (?, ?, ?, ?, ?)',
            [nome, email, hashedPassword, cpf, telefone]
        );

        res.status(201).json({ message: 'Usuário criado com sucesso!' });
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            res.status(400).json({ error: 'E-mail ou CPF já cadastrado.' });
        } else {
            res.status(500).json({ error: 'Erro interno no servidor.' });
        }
    }
};

export const login = async (req, res) => {
    const { email, senha } = req.body;

    try {
        const [usuarios] = await pool.query('select * from usuarios where email = ?', [email]);
        if (usuarios.length === 0) {
            return res.status(401).json({ error: 'Credenciais inválidas.' });
        }

        const usuario = usuarios[0];
        const isPasswordValid = await bcrypt.compare(senha, usuario.senha);
        if (!isPasswordValid) {
            return res.status(401).json({ error: 'Credenciais inválidas.' });
        }

        const token = jwt.sign({ id: usuario.id }, process.env.JWT_SECRET, { expiresIn: '1h' });
        res.json({ token });
    } catch (error) {
        res.status(500).json({ error: 'Erro interno no servidor.' });
    }
};