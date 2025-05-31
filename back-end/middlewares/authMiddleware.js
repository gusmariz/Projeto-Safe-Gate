import jwt from 'jsonwebtoken';
import pool from '../database/connection.js';

export const verifyToken = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Acesso negado' });

    try {
        req.user = jwt.verify(token, process.env.JWT_SECRET);
        next();
    } catch (error) {
        res.status(400).json({ error: 'Token inválido' });
    }
};

export const adminOnly = async (req, res, next) => {
    try {
        const [users] = await pool.query(
            'SELECT tipo_usuario FROM usuarios WHERE email = ?',
            [req.user.email]
        );

        if (!users.length || users[0].tipo_usuario !== 'admin') {
            return res.status(403).json({ error: 'Acesso restrito a administradores' });
        }
        next();
    } catch (error) {
        res.status(500).json({ error: 'Erro ao verificar permissões' });
    }
};