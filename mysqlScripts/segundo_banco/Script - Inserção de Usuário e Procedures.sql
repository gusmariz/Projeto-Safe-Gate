/CRIAR BANCO DE DADOS

CREATE DATABASE SERVO_INFO

/ SELECIONAR BANCO DE DADOS 

USE SERVO_INFO;

/Tabela de Usuários
CREATE TABLE Usuarios ( -- Mudei a coluna login_user para tipo_user
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    nome_user VARCHAR(100) NOT NULL,
    cpf_user VARCHAR(11) UNIQUE NOT NULL,
    contato_user VARCHAR(15),
    email_user VARCHAR(100) UNIQUE NOT NULL,
    tipo_user ENUM('cliente', 'admin') NOT NULL,
    senha_user VARCHAR(255) NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);


/ Tabela de Registros de Movimento do Servo Motor

CREATE TABLE Registros (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    ds_registro VARCHAR(100) NOT NULL,
    dt_acao DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo_acao VARCHAR(100),
    hora_registro DATETIME,
    id_usuario INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_user)
);

/ Tabela Log_Main para Auditoria

CREATE TABLE Log_Main (
	-- Mudei a coluna login_user para tipo_user
    -- Removi a coluna ip_origem
    -- Adicionei duas colunas usuario_excluido e excluido_por
    
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    
    tipo_acao VARCHAR(10) NOT NULL, 
    tipo_user ENUM('cliente', 'admin') NOT NULL, 
    
    dt_acao DATETIME DEFAULT CURRENT_TIMESTAMP,

    ds_registro_old VARCHAR(100),
    ds_registro_now VARCHAR(100),

    tipo_acao_old VARCHAR(100),
    tipo_acao_now VARCHAR(100),

    nome_usuario_old VARCHAR(80),
    nome_usuario_now VARCHAR(80),

    ip_origem VARCHAR(45)
);
alter table Log_Main
change column login_user tipo_user enum('cliente', 'admin') not null;
alter table Log_Main drop column ip_origem;
alter table log_main add column id_usuario_excluido int null;
alter table log_main add column excluido_por int null;
alter table log_main add column dados_usuario JSON;


/ INSERÇÃO DE USUÁRIO VIA PROCEDURE (InserirUsuario)

DELIMITER //

CREATE PROCEDURE InserirUsuario (
    IN p_nome_user VARCHAR(100),
    IN p_cpf_user VARCHAR(11),
    IN p_contato_user VARCHAR(15),
    IN p_email_user VARCHAR(100),
    IN p_tipo_user ENUM('cliente', 'admin'),
    IN p_senha_user VARCHAR(255)
)
BEGIN
	IF p_tipo_user NOT IN ('cliente', 'admin') THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de usuário inválido. Use "cliente" ou "admin"';
	ELSE
		INSERT INTO Usuarios (
			nome_user,
			cpf_user,
			contato_user,
			email_user,
			tipo_user,
			senha_user,
			data_cadastro
		) VALUES (
			p_nome_user,
			p_cpf_user,
			p_contato_user,
			p_email_user,
			p_tipo_user,
			p_senha_user, -- Removi SHA2 pois a senha já é criptografada na API
			NOW()
		);
	END IF;
END;
//

DELIMITER ;


/Procedure: Atualizar Informações de um Usuário (Atualizar Usuário)

DELIMITER //

CREATE PROCEDURE AtualizarUsuario (
    IN p_email_user VARCHAR(100),
    IN p_nome_user VARCHAR(100),
    IN p_contato_user VARCHAR(15),
    IN p_senha_user VARCHAR(255)
)
BEGIN
    -- Exemplo simples de atualização completa (exceto data_cadastro)
    UPDATE Usuarios
    SET
        nome_user = p_nome_user,
        contato_user = p_contato_user,
        senha_user = p_senha_user
    WHERE email_user = p_email_user;
END;
//

DELIMITER ;

-- Procedure para registrar exclusão no log

DELIMITER //

CREATE PROCEDURE RegistrarLogExclusao(
	IN p_tipo_acao VARCHAR(100),
    IN p_tipo_user ENUM('cliente', 'admin'),
    IN p_id_usuario_excluido INT,
    IN p_excluido_por INT,
    IN p_dados_antigos JSON
)
BEGIN
	INSERT INTO log_main (
		tipo_acao,
        tipo_user,
        dt_acao,
        id_usuario_excluido,
        excluido_por,
        dados_antigos
    ) VALUES (
		p_tipo_acao,
        p_tipo_user,
        NOW(),
        p_id_usuario_excluido,
        p_excluido_por,
        p_dados_antigos
    );
END
//

DELIMITER ;

Procedure com Log de Exclusão na Log_Main

DELIMITER //

CREATE PROCEDURE ExcluirUsuario ( -- Simplifiquei a procedure para excluir usuário
    IN p_id_user INT
)
BEGIN
	DELETE FROM usuarios
    WHERE id_user= p_id_user;
END;
//

DELIMITER ;

Perfeito! Vamos criar três procedures para a tabela Registros:

Inserção de registros (movimentações do servo motor)

Atualização de registros

Exclusão de registros

Todas com registro automático na tabela Log_Main, conforme o padrão que você adotou.

/ Procedure: Inserir Registro + Log (InserirRegistro)

DELIMITER //

CREATE PROCEDURE InserirRegistro (
    IN p_ds_registro VARCHAR(100),
    IN p_tipo_acao VARCHAR(100),
    IN p_hora_registro DATETIME,
    IN p_id_usuario INT,
    IN p_ip_origem VARCHAR(45)
)
BEGIN
    DECLARE v_login_user VARCHAR(20);
    DECLARE v_nome_user VARCHAR(100);

    -- Coleta dados do usuário
    SELECT login_user, nome_user INTO v_login_user, v_nome_user
    FROM Usuarios WHERE id_user = p_id_usuario;

    -- Inserção no Registros
    INSERT INTO Registros (
        ds_registro,
        tipo_acao,
        hora_registro,
        id_usuario
    ) VALUES (
        p_ds_registro,
        p_tipo_acao,
        p_hora_registro,
        p_id_usuario
    );

    -- Log
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
    ) VALUES (
        'INSERT',
        v_login_user,
        NOW(),
        NULL,
        CONCAT('Acao: ', p_tipo_acao, ' | Registro: ', p_ds_registro),
        NULL,
        p_tipo_acao,
        NULL,
        v_nome_user,
        p_ip_origem
    );
END;
//

DELIMITER ;

/ Procedure: Atualizar Registro + Log

DELIMITER //

CREATE PROCEDURE AtualizarRegistro (
    IN p_id_registro INT,
    IN p_ds_registro VARCHAR(100),
    IN p_tipo_acao VARCHAR(100),
    IN p_hora_registro DATETIME,
    IN p_ip_origem VARCHAR(45)
)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_login_user VARCHAR(20);
    DECLARE v_nome_user VARCHAR(100);
    DECLARE v_ds_antigo VARCHAR(100);
    DECLARE v_tipo_antigo VARCHAR(100);

    -- Coleta dados antigos
    SELECT r.ds_registro, r.tipo_acao, u.login_user, u.nome_user, r.id_usuario
    INTO v_ds_antigo, v_tipo_antigo, v_login_user, v_nome_user, v_id_usuario
    FROM Registros r
    JOIN Usuarios u ON r.id_usuario = u.id_user
    WHERE r.id_registro = p_id_registro;

    -- Atualiza registro
    UPDATE Registros
    SET
        ds_registro = p_ds_registro,
        tipo_acao = p_tipo_acao,
        hora_registro = p_hora_registro
    WHERE id_registro = p_id_registro;

    -- Log
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
    ) VALUES (
        'UPDATE',
        v_login_user,
        NOW(),
        v_ds_antigo,
        p_ds_registro,
        v_tipo_antigo,
        p_tipo_acao,
        v_nome_user,
        v_nome_user,
        p_ip_origem
    );
END;
//

DELIMITER ;

/ Procedure: Excluir Registro + Log

DELIMITER //

CREATE PROCEDURE ExcluirRegistro (
    IN p_id_registro INT,
    IN p_ip_origem VARCHAR(45)
)
BEGIN
    DECLARE v_id_usuario INT;
    DECLARE v_login_user VARCHAR(20);
    DECLARE v_nome_user VARCHAR(100);
    DECLARE v_ds_registro VARCHAR(100);
    DECLARE v_tipo_acao VARCHAR(100);

    -- Coleta dados antigos
    SELECT r.ds_registro, r.tipo_acao, u.login_user, u.nome_user, r.id_usuario
    INTO v_ds_registro, v_tipo_acao, v_login_user, v_nome_user, v_id_usuario
    FROM Registros r
    JOIN Usuarios u ON r.id_usuario = u.id_user
    WHERE r.id_registro = p_id_registro;

    -- Log antes da exclusão
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
    ) VALUES (
        'DELETE',
        v_login_user,
        NOW(),
        v_ds_registro,
        NULL,
        v_tipo_acao,
        'Removido',
        v_nome_user,
        NULL,
        p_ip_origem
    );

    -- Exclusão
    DELETE FROM Registros WHERE id_registro = p_id_registro;
END;
//

DELIMITER ;
