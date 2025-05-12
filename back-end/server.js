import express from "express";
import cors from "cors";

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json);

app.post("/home", (req, res) => {
    console.log("Usuário abriu");
    res.json(200).json({ status: "recebido" });
})

app.listen(PORT, () => {
    console.log(`Servidor rodando na porta ${PORT}`);
})