import jwt from 'jsonwebtoken';
import { createAction, getHistory } from '../models/GateAction.js';

export const controlGate = async (req, res) => {
    try {
        const { acao } = req.body;
        const token = req.headers.authorization.split(' ')[1];
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // valida ações permitidas
        const acoesPermitidas = ['abrir', 'fechar', 'parar'];
        if (!acoesPermitidas.includes(acao)) {
            return res.status(400).json({ error: 'Ação inválida' });
        }

        await createAction(decoded.id, acao);
        res.json({ message: `Portão ${acao} com sucesso!` });
    } catch (error) {
        console.log('Erro no controle do portão:', error);
        res.status(500).json({ error: 'Erro no servidor' });
    }
};

export const history = async (req, res) => {
    try {
        const historico = await getHistory();
        res.json(historico);
    } catch (error) {
        console.log('Erro ao buscar histórico:', error);
        res.status(500).json({ error: 'Erro no servidor' });
    }
};