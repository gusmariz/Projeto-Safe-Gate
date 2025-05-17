import {verifyToken} from '../middlewares/authMiddleware.js';

router.post('/action', verifyToken, controlGate);
router.get('/history', verifyToken, history);