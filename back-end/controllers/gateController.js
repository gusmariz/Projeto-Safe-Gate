import jwt from 'jsonwebtoken';
import pool from '../database/connection.js';

export const controlGate = async (req, res) => {
    try {
        const { acao, descricao } = req.body;
        const token = req.headers.authorization.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // valida ações permitidas
        const acoesPermitidas = ['abrir', 'fechar', 'parar'];
        if (!acoesPermitidas.includes(acao)) {
            return res.status(400).json({ error: 'Ação inválida' });
        }

        await pool.query(
            'CALL inserir_registro(?, ?)',
            [descricao || `Portão ${acao}`, decoded.id]
        );

        res.json({ message: `Portão ${acao} com sucesso!` });
    } catch (error) {
        console.log('Erro no controle do portão:', error);
        res.status(500).json({ error: 'Erro no servidor' });
    }
};

export const history = async (req, res) => {
    try {
        const [rows] = await pool.query(
            `SELECT r.*, u.nome, u.tipo_usuario
            FROM registros r
            JOIN usuarios u ON r.id_usuario = u.id_usuario
            ORDER BY r.dt_acao DESC
            LIMIT 50`
        );
        res.json(rows);
    } catch (error) {
        console.log('Erro ao buscar histórico:', error);
        res.status(500).json({ error: 'Erro no servidor' });
    }
};

export const getLogs = async (req, res) => {
    try {
        const [rows] = await pool.query(
            `SELECT * FROM log
            ORDER BY dt_trigger DESC
            LIMIT 100`
        );
        res.json(rows);
    } catch (error) {
        console.log('Erro ao buscar logs:', error);
        res.status(500).json({ error: 'Erro no servidor' });
    }
};