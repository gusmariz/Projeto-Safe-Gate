///Pré-requisito: Ativar o Agendador de Eventos no MySQL - Execute isto antes de qualquer Job - 

SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS job_log_diario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 3 HOUR
DO
INSERT INTO Log_Main (
    tipo_acao,
    login_user,
    dt_acao,
    ds_registro_now,
    tipo_acao_now,
    nome_usuario_now,
    ip_origem
)
VALUES (
    'SYSTEM',
    'sistema',
    NOW(),
    CONCAT('Relatório diário às 03:00 - Status OK'),
    'Relatório Diário',
    'Sistema Noturno',
    '127.0.0.1'
);

/// Registro diário com data e hora (executado todos os dias às 3h) (job_log_diario)

CREATE EVENT IF NOT EXISTS job_log_diario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 3 HOUR
DO
INSERT INTO Log_Main (
    tipo_acao,
    login_user,
    dt_acao,
    ds_registro_now,
    tipo_acao_now,
    nome_usuario_now,
    ip_origem
)
VALUES (
    'SYSTEM',
    'sistema',
    NOW(),
    CONCAT('Relatório diário às 03:00 - Status OK'),
    'Relatório Diário',
    'Sistema Noturno',
    '127.0.0.1'
);


/// Ver Jobs ativos:

SHOW EVENTS;


/ Trigger para INSERT na tabela Usuarios

DELIMITER //

CREATE TRIGGER trg_insert_usuario
AFTER INSERT ON Usuarios
FOR EACH ROW
BEGIN
    INSERT INTO Log_Main (
        tipo_acao,
        login_user,
        dt_acao,
        ds_registro_now,
        tipo_acao_now,
        nome_usuario_now,
        ip_origem
    )
    VALUES (
        'INSERT',
        NEW.login_user,
        NOW(),
        CONCAT('Usuário inserido: ', NEW.nome_user),
        'Criação',
        NEW.nome_user,
        '127.0.0.1'
    );
END;
//

DELIMITER ;


/ Trigger para UPDATE na tabela Usuarios

DELIMITER //

CREATE TRIGGER trg_update_usuario
AFTER UPDATE ON Usuarios
FOR EACH ROW
BEGIN
    INSERT INTO Log_Main (
        tipo_acao,
        login_user,
        dt_acao,
        ds_registro_old,
        ds_registro_now,
        tipo_acao_old,
        tipo_acao_now,
        nome_usuario_old,
        nome_usuario_now,
        ip_origem
    )
    VALUES (
        'UPDATE',
        NEW.login_user,
        NOW(),
        OLD.nome_user,
        NEW.nome_user,
        'Antes',
        'Depois',
        OLD.nome_user,
        NEW.nome_user,
        '127.0.0.1'
    );
END;
//

DELIMITER ;

/ Trigger de DELETE na Tabela Usuários 

DELIMITER //

CREATE TRIGGER trg_delete_usuario
BEFORE DELETE ON Usuarios
FOR EACH ROW
BEGIN
    INSERT INTO Log_Main (
        tipo_acao,
        login_user,
        dt_acao,
        ds_registro_old,
        tipo_acao_old,
        nome_usuario_old,
        ip_origem
    )
    VALUES (
        'DELETE',
        OLD.login_user,
        NOW(),
        CONCAT('Usuário removido: ', OLD.nome_user),
        'Excluído',
        OLD.nome_user,
        '127.0.0.1'
    );
END;
//

DELIMITER ;

/ 


Trigger de INSERT na tabela Registros
DELIMITER //

CREATE TRIGGER trg_insert_registro
AFTER INSERT ON Registros
FOR EACH ROW
BEGIN
    INSERT INTO Log_Main (
        tipo_acao,
        login_user,
        dt_acao,
        ds_registro_now,
        tipo_acao_now,
        nome_usuario_now,
        ip_origem
    )
    SELECT
        'INSERT',
        u.login_user,
        NOW(),
        NEW.DS_REGISTRO,
        NEW.TIPO_ACAO,
        u.nome_user,
        '127.0.0.1'
    FROM Usuarios u
    WHERE u.id_user = NEW.id_usuario;
END;
//

DELIMITER ;

/ Trigger de UPDATE na tabela Registros

DELIMITER //

CREATE TRIGGER trg_update_registro
AFTER UPDATE ON Registros
FOR EACH ROW
BEGIN
    INSERT INTO Log_Main (
        tipo_acao,
        login_user,
        dt_acao,
        ds_registro_old,
        ds_registro_now,
        tipo_acao_old,
        tipo_acao_now,
        nome_usuario_now,
        ip_origem
    )
    SELECT
        'UPDATE',
        u.login_user,
        NOW(),
        OLD.DS_REGISTRO,
        NEW.DS_REGISTRO,
        OLD.TIPO_ACAO,
        NEW.TIPO_ACAO,
        u.nome_user,
        '127.0.0.1'
    FROM Usuarios u
    WHERE u.id_user = NEW.id_usuario;
END;
//

DELIMITER ;


/ Trigger de DELETE na tabela Registros

DELIMITER //

CREATE TRIGGER trg_delete_registro
BEFORE DELETE ON Registros
FOR EACH ROW
BEGIN
    INSERT INTO Log_Main (
        tipo_acao,
        login_user,
        dt_acao,
        ds_registro_old,
        tipo_acao_old,
        nome_usuario_old,
        ip_origem
    )
    SELECT
        'DELETE',
        u.login_user,
        NOW(),
        OLD.DS_REGISTRO,
        OLD.TIPO_ACAO,
        u.nome_user,
        '127.0.0.1'
    FROM Usuarios u
    WHERE u.id_user = OLD.id_usuario;
END;
//

DELIMITER ;
