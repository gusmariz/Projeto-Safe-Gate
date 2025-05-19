import jwt from 'jsonwebtoken';
import { SerialPort } from 'serialport';
import { createAction, getHistory } from '../models/GateAction.js';

const port = new SerialPort({
    path: 'COM3',
    baudRate: 9600,
    autoOpen: false,
});

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

        if (!port.isOpen) await port.open(); // Abre a conexão se necessário
        port.write(`${acao}\n`, async (error) => {
            if (error) {
                console.error('Erro ao enviar para Arduino:', error);
                return res.status(500).json({ error: 'Falha na comunicação serial' });
            }

            await createAction(decoded.id, acao);
            res.json({ message: `Comando "${acao}" enviado ao Arduino!` });
        });
    
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