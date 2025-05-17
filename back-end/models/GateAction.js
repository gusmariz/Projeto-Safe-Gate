import pool from '../database/connection.js';

export const createAction = async (usuario_id, acao) => {
    const [result] = await pool.query(
        `insert into acoes_portao (usuario_id, acao) values (?, ?)`, [usuario_id, acao]
    );
    return result.insertId;
};

export const getHistory = async () => {
    const [rows] = await pool.query(
        `select a.*, u.nome
        from acoes_portao a
        join usuarios u on a.usuario_id = u.id
        order by a.data desc`
    );
    return rows;
};