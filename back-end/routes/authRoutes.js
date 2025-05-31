import express from 'express';
import { register, login, atualizarUsuario } from '../controllers/authController.js';

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.put('/update', atualizarUsuario);

export default router;