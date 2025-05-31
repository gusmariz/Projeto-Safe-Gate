import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/authRoutes.js';
import gateRoutes from './routes/gateRoutes.js';
import adminRoutes from './routes/adminRoutes.js'

dotenv.config();
const app = express();

app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/gate', gateRoutes);
app.use('/admin', adminRoutes);

app.get('/', (req, res) => res.send('API SafeGate Online!'));

app.listen(process.env.PORT, () => {
  console.log(`Servidor rodando na porta ${process.env.PORT}`);
});