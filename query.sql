-- inserindo dados
insert into FUN_FUNCIONARIOS(fun_nome, fun_sobrenome, fun_data_nascimento, fun_observacoes) values('fulano', 'silva', '1991-02-23', 'dev');
insert into FUN_FUNCIONARIOS(fun_nome, fun_sobrenome, fun_data_nascimento, fun_observacoes) values('ciclano', 'pereira', '1991-12-21');
insert into FUN_FUNCIONARIOS(fun_nome, fun_sobrenome, fun_data_nascimento, fun_observacoes) values('beltrano', 'oliveira', '1985-04-01');

-- 7.3 - entendendo o conceito de projeção e utilizando as primeiras funções T-SQL
select concat(fun_nome, ' ', fun_sobrenome) as 'nome completo' from FUN_FUNCIONARIOS;
select fun_nome + ' ' + fun_sobrenome + ' ' + cast(fun_observacoes as varchar) as nome_completo from FUN_FUNCIONARIOS;
-- caso fun_observacoes tenha algum valor null, usando a função concat nao precisa do cast
select fun_nome + ' ' + fun_sobrenome + ' ' + cast(isnull(fun_observacoes, '') as varchar) as nome_completo from FUN_FUNCIONARIOS;
-- ver o tipo de dados das colunas e retornar apenas a primeira linha
select top 1 sql_variant_property(fun_nome + ' ' + fun_sobrenome + ' ' + cast(isnull(fun_observacoes, '') as varchar), 'BaseType') as nome_completo from FUN_FUNCIONARIOS;

-- 7.4 trabalhando com filtros de informações
-- consultar funcionarios que nasceram no ano de 1985 ou no mes 02
select concat(fun_nome, ' ', fun_sobrenome) as nome_completo, fun_data_nascimento from FUN_FUNCIONARIOS where year(fun_data_nascimento) = 1985 or month(fun_data_nascimento) = 02;
-- consultar funcionarios com mais de 26 anos
select concat(fun_nome, ' ', fun_sobrenome) as nome_completo, fun_data_nascimento from FUN_FUNCIONARIOS where datediff(year, fun_data_nascimento, getdate()) >= 26;

-- 7.5 consultas com campos null
select * from FUN_FUNCIONARIOS where fun_observacoes is null;
select * from FUN_FUNCIONARIOS where fun_observacoes is not null;

-- 7.7 adicionando novas colunas
alter table FUN_FUNCIONARIOS add fun_cpf char(11) not null default '-';

-- 7.8 atualizando dados das tabelas
update FUN_FUNCIONARIOS set fun_cpf = '12345678912', fun_data_nascimento = '1990-02-23' where fun_id = 1;
update FUN_FUNCIONARIOS set fun_cpf = '98765432100' where fun_id = 3;
update FUN_FUNCIONARIOS set fun_cpf = '42857193191' where fun_id = 4;

-- 7.9 criando constraints do tipo unique
alter table FUN_FUNCIONARIOS add constraint uc__fun_funcionarios_fun_cpf unique nonclustered (fun_cpf);
insert into FUN_FUNCIONARIOS(fun_nome, fun_sobrenome, fun_data_nascimento, fun_cpf) values('teste', 'unique', '2000-01-01', '12345678912'); -- erro

-- 7.10 criando tabelas através de comandos
	create table PAC_PONTOS_ACESSO
(
	pac_id int identity(1,1) primary key,
	pac_data_inicial datetime not null,
	pac_data_final datetime default null,
	fun_id int not null
);

-- 7.11 criando foreign keys através de comandos
alter table PAC_PONTOS_ACESSO add constraint fk__pac_pontos_acesso_fun_funcionarios_fun_id 
foreign key(fun_id) references FUN_FUNCIONARIOS(fun_id);

insert into PAC_PONTOS_ACESSO(pac_data_inicial, fun_id) values ('2023-01-01 07:00:00', 1);