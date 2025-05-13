import express from "express";
import cors from "cors";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

app.post("/home", (req, res) => {
    try {
        const { acao } = req.body;
        if (!acao) {
            return res.status(400).json({ error: 'Parâmetro "acao" é obrigatório' });
        }

        console.log(`Ação recebida: ${acao}`);
        return res.status(200).json({ status: 'recebido', acao });
    } catch (error) {
        console.log('Erro no servidor:', error);
        return res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
});