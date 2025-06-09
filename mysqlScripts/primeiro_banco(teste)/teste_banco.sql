create database safegate;
use safegate;

create table usuarios (
	id int auto_increment primary key,
    nome varchar(100) not null,
    email varchar(100) not null unique,
    senha varchar(255) not null,
    cpf varchar(14) not null unique,
    telefone varchar(20) not null,
    criado_em timestamp default current_timestamp
);

create table acoes_portao (
	id int auto_increment primary key,
    usuario_id int not null,
    acao enum('abrir', 'fechar', 'parar') not null,
    data timestamp default current_timestamp,
    foreign key (usuario_id) references usuarios(id)
);