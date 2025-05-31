import express from 'express';
import { getUsuarios, deleteUsuario } from '../controllers/adminController.js';
import { verifyToken, adminOnly } from '../middlewares/authMiddleware.js';
import { getLogs } from '../controllers/gateController.js';

const router = express.Router();

router.get('/users', verifyToken, adminOnly, getUsuarios);
router.delete('/users/:email', verifyToken, adminOnly, deleteUsuario);
router.get('/logs', verifyToken, adminOnly, getLogs);

export default router;