import express from 'express';
import { controlGate, history } from '../controllers/gateController.js';
import { verifyToken } from '../middlewares/authMiddleware.js';

const router = express.Router();

// Rotas protegidas por JWT
router.post('/action', verifyToken, controlGate);
router.get('/history', verifyToken, history);

export default router;