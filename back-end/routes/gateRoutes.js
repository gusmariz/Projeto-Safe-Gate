import express from 'express';
import { controlGate, history, getLogs, deleteRegistro } from '../controllers/gateController.js';
import { verifyToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Rotas protegidas por JWT
router.post('/action', verifyToken, controlGate);
router.get('/history', verifyToken, history);
router.get('/logs', verifyToken, getLogs);
router.delete('/history/:id', verifyToken, deleteRegistro);

export default router;