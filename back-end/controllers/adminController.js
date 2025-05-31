import pool from "../database/connection.js";

export const  getUsuarios = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT id_usuario, nome, email, tipo_usuario FROM usuarios');
        res.json(rows);
    } catch (error) {
        console.log('Erro ao buscar usuários:', error);
        res.status(500).json({error: 'Erro no servidor'});
    }
};

export const deleteUsuario = async (req, res) => {
    try {
        const {email} = req.params;
        await pool.query('CALL excluir_usuario(?)', [email]);
        res.json({message: 'Usuário excluído com sucesso!'});
    } catch (error) {
        console.log('Erro ao excluir usuário:', error);
        res.status(500).json({error: 'Erro no servidor'});
    }
};