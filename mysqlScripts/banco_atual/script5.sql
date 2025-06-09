use railway;


create table usuarios(
	id_usuario int auto_increment primary key,
    nome varchar(100) not null,
    cpf varchar(11) unique not null,
    telefone varchar(15) not null,
    email varchar(100) unique not null,
	senha varchar(100) not null,
    tipo_usuario enum('cliente', 'admin') not null,
    data_cadastro datetime default current_timestamp
);

create table registros (
	id_registro int auto_increment primary key,
    ds_registro varchar(100) not null,
    tipo_acao enum('INSERT', 'UPDATE', 'DELETE') not null,
    id_usuario int not null,
    dt_acao datetime default current_timestamp,
    foreign key (id_usuario) references usuarios(id_usuario)
);

create table log (
	id_log int auto_increment primary key,
    tipo_usuario enum('cliente', 'admin') not null,
    tipo_acao_old enum('INSERT', 'UPDATE', 'DELETE') default null,
    tipo_acao_now enum('INSERT', 'UPDATE', 'DELETE') not null,
    nome_usuario_old varchar(100) default null,
    nome_usuario_now varchar(100) not null,
    ds_registro_old varchar(100) default null,
    ds_registro_now varchar(100) default null,
    email_usuario_excluido varchar(100) default null,
    dt_trigger timestamp default current_timestamp
);
alter table log add column id_usuario int after id_log;
alter table log add column id_registro int after id_usuario;
alter table log add column telefone_usuario_old varchar(100) default null after nome_usuario_now;
alter table log add column telefone_usuario_now varchar(100) not null after telefone_usuario_old;

-- PROCEDURE PARA INSERIR USUÁRIO
delimiter //
create procedure inserir_usuario(
	in p_nome varchar(100),
    in p_cpf varchar(11),
    in p_telefone varchar(15),
    in p_email varchar(100),
    in p_senha varchar(100),
    in p_tipo_usuario enum('cliente', 'admin')
)
begin
	insert into usuarios (
		nome,
        cpf,
        telefone,
        email,
        senha,
        tipo_usuario
    ) values (
		p_nome,
        p_cpf,
        p_telefone,
        p_email,
        p_senha,
        p_tipo_usuario
    );
end
//
delimiter ;

-- INSERÇÃO MANUAL DO SISTEMA
call inserir_usuario('sistema', '00000000000', '0000000000000', 'sistema@admin', 'sistema123', 'admin');
select * from log;

-- PROCEDURE PARA ATUALIZAR USUÁRIO
delimiter //
create procedure atualizar_usuario (
	in p_nome varchar(100),
    in p_telefone varchar(15),
    in p_email varchar(100),
    in p_senha varchar(100)
)
begin
	update usuarios
    set nome = p_nome,
		telefone = p_telefone,
        senha = p_senha
	where email = p_email;
end;
//
delimiter ;

-- PROCEDURE PARA EXCLUIR USUÁRIO
delimiter //
create procedure excluir_usuario(
	in p_email varchar(100)
)
begin
	delete from usuarios where email = p_email;
end;
//
delimiter ;

-- PROCEDURE PARA INSERIR REGISTRO
delimiter //
create procedure inserir_registro (
	in p_ds_registro varchar(100),
    in p_id_usuario int
)
begin
	insert into registros (
		ds_registro,
        tipo_acao,
        id_usuario
    ) values (
		p_ds_registro,
        'INSERT',
        p_id_usuario
    );
end;
//
delimiter ;

-- PROCEDURE PARA EXCLUIR REGISTRO
delimiter //
create procedure excluir_registro (
	in p_id_registro int
)
begin
	delete from registros where id_registro = p_id_registro;
end;
//
delimiter ;

-- TRIGGER PARA INSERIR USUÁRIO NO LOG
delimiter //
create trigger t_log_inserir_usuario
after insert on usuarios
for each row
begin
	declare v_tipo_acao_old enum('INSERT', 'UPDATE', 'DELETE');
    
    -- FAZ A TRANSIÇÃO DA AÇÃO NOVA PARA A ANTIGA
    select tipo_acao_now into v_tipo_acao_old
    from log
    order by dt_trigger desc
    limit 1;

	insert into log (
		id_usuario,
		tipo_usuario,
		tipo_acao_old,
		tipo_acao_now,
        nome_usuario_now,
        telefone_usuario_now
    ) values (
		new.id_usuario,
		new.tipo_usuario,
        v_tipo_acao_old,
		'INSERT',
        new.nome,
        new.telefone
    );
end;
//
delimiter ;

-- TRIGGER PARA ATUALIZAR USUÁRIO NO LOG
delimiter //
create trigger t_log_atualizar_usuario
after update on usuarios
for each row
begin
	declare v_tipo_acao_old enum('INSERT', 'UPDATE', 'DELETE');
    declare v_nome_usuario_old varchar(100);
    declare v_telefone_usuario_old varchar(100);
    
    -- PASSA TIPO DA AÇÃO, NOME DO USUÁRIO E O TELEFONE QUE ERA ATUAL PARA A ANTIGA
    select tipo_acao_now, nome_usuario_now, telefone_usuario_now
    into v_tipo_acao_old, v_nome_usuario_old, v_telefone_usuario_old
    from log
    where id_usuario = new.id_usuario
    order by dt_trigger desc
    limit 1;

	insert into log (
		id_usuario,
		tipo_usuario,
        tipo_acao_old,
        tipo_acao_now,
        nome_usuario_old,
        nome_usuario_now,
        telefone_usuario_old,
        telefone_usuario_now
    ) values (
		new.id_usuario,
		new.tipo_usuario,
		v_tipo_acao_old,
        'UPDATE',
        v_nome_usuario_old,
        new.nome,
        v_telefone_usuario_old,
        new.telefone
    );
end;
//
delimiter ;

-- TRIGGER PARA REGISTRAR EXCLUSÃO DO USUÁRIO
delimiter //
create trigger t_log_excluir_usuario
after delete on usuarios
for each row
begin
	declare v_tipo_acao_old enum('INSERT', 'UPDATE', 'DELETE');
    
    -- PASSA O TIPO DA AÇÃO QUE ERA ATUAL PARA A ANTIGA
    select tipo_acao_now into v_tipo_acao_old
    from log
    where id_usuario = old.id_usuario
    order by dt_trigger desc
    limit 1;
    
	insert into log (
		id_usuario,
        tipo_usuario,
        tipo_acao_old,
        tipo_acao_now,
        nome_usuario_now,
        telefone_usuario_now,
        email_usuario_excluido
    ) values (
		old.id_usuario,
        old.tipo_usuario,
        v_tipo_acao_old,
        'DELETE',
        old.nome,
        old.telefone,
        old.email
    );
end;
//
delimiter ;

-- TRIGGER PARA INSERIR REGISTRO NO LOG
delimiter //
 create trigger t_log_inserir_registro
 after insert on registros
 for each row
 begin
	declare v_tipo_acao_old enum('INSERT', 'UPDATE', 'DELETE');
    declare v_ds_registro_old varchar(100);
    declare v_tipo_usuario enum('cliente', 'admin');
    declare v_nome varchar(100);
    declare v_telefone varchar(15);
    
    -- PASSA TIPO DA AÇÃO E DESCRIÇÃO DO REGISTRO QUE ERA ATUAL PARA A ANTIGA
    select tipo_acao_now, ds_registro_now
    into v_tipo_acao_old, v_ds_registro_old
    from log
    order by dt_trigger desc
    limit 1;
    
    -- PEGA ALGUMAS INFORMAÇÕES DA TABELA USUARIOS
    select tipo_usuario, nome, telefone
    into v_tipo_usuario, v_nome, v_telefone
    from usuarios
    where id_usuario = new.id_usuario;
    
    insert into log (
		id_usuario,
        id_registro,
        tipo_usuario,
        tipo_acao_old,
		tipo_acao_now,
        nome_usuario_now,
        telefone_usuario_now,
        ds_registro_old,
		ds_registro_now
    ) values (
		new.id_usuario,
        new.id_registro,
        v_tipo_usuario,
        v_tipo_acao_old,
        'INSERT',
        v_nome,
        v_telefone,
        v_ds_registro_old,
        new.ds_registro
    );
end;
//
delimiter ;

-- TRIGGER PARA EXCLUIR REGISTRO DO LOG
delimiter //
create trigger t_log_excluir_registro
after delete on registros
for each row
begin
	declare v_tipo_acao_old enum('INSERT', 'UPDATE', 'DELETE');
    declare v_tipo_usuario enum ('cliente', 'admin');
    declare v_nome varchar(100);
    declare v_telefone varchar(15);
    
    -- PASSA O TIPO DA AÇÃO QUE ERA ATUAL PARA A ANTIGA
    select tipo_acao_now into v_tipo_acao_old
    from log
    where id_registro = old.id_registro
    order by dt_trigger desc
    limit 1;
    
    -- PEGA ALGUMAS INFORMAÇÕES DA TABELA USUARIOS
    select tipo_usuario, nome, telefone
    into v_tipo_usuario, v_nome, v_telefone
    from usuarios
    where id_usuario = old.id_usuario;
    
    insert into log (
		id_usuario,
        id_registro,
        tipo_usuario,
        tipo_acao_old,
        tipo_acao_now,
        nome_usuario_now,
        telefone_usuario_now,
        ds_registro_now
    ) values (
		old.id_usuario,
        old.id_registro,
        v_tipo_usuario,
        v_tipo_acao_old,
        'DELETE',
        v_nome,
        v_telefone,
        old.ds_registro
    );
end;
//
delimiter ;

-- JOB PARA FAZER A LIMPEZA DO LOG
set global event_scheduler = off;

-- PROCEDURE PARA RETIRAR ANTIGAS AÇÕES NO LOG
delimiter //
create procedure p_limpar_log_antigo()
begin
	delete from log
    where dt_trigger < date_sub(now(), interval 2 minute)
    order by dt_trigger asc
    limit 1;
    
    insert into registros (ds_registro, tipo_acao, id_usuario)
    values ('Limpeza automática', 'DELETE', 1);
end;
//
delimiter ;

-- CRIAÇÃO DO EVENTO
delimiter //
create event j_limpar_log
on schedule every 2 minute
do
begin
	call p_limpar_log_antigo();
end;
//
delimiter ;