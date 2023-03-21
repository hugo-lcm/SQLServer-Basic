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

-- 7.12 criando constraints do tipo CHECK
/*alter table PAC_PONTOS_ACESSO add constraint ck_pac_pontos_acesso__data_inicial_data_final
check
(
	pac_data_inicial < pac_data_final and
	datepart(day, pac_data_inicial) = datepart(day, pac_data_final) and
	datepart(month, pac_data_inicial) = datepart(month, pac_data_final) and
	datepart(year, pac_data_inicial) = datepart(year, pac_data_inicial)
); 
datepart é uma função não determinística, por isso não é bom usá-la*/

alter table PAC_PONTOS_ACESSO drop ck_pac_pontos_acesso__data_inicial_data_final;

alter table PAC_PONTOS_ACESSO add constraint ck_pac_pontos_acesso__data_inicial_data_final
check
(
	pac_data_inicial < pac_data_final and
	day(pac_data_inicial) = day(pac_data_final) and
	month(pac_data_inicial) = month(pac_data_final) and
	year(pac_data_inicial) = year(pac_data_inicial)
);

update PAC_PONTOS_ACESSO set pac_data_final = '2023-01-01 06:00:00' where pac_id = 1; -- erro

-- 7.13 cast vs convert
-- em termos de performance não há diferença, a diferença entre eles é que convert é exclusivo do tsql
select *, cast(pac_data_final - pac_data_inicial as time(0)) as diferenca_datas from PAC_PONTOS_ACESSO;

select *, convert(time(0), pac_data_final - pac_data_inicial) as diferenca_datas from PAC_PONTOS_ACESSO;

-- 8.1 consultas com dados de várias tabelas
select concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	f.fun_data_nascimento, 
	p.pac_data_inicial, 
	p.pac_data_final,
	convert(time(0), p.pac_data_final - p.pac_data_inicial) as horas_trabalhadas
from FUN_FUNCIONARIOS f, PAC_PONTOS_ACESSO p
where f.fun_id = p.fun_id;

-- 8.2 inner join
insert into PAC_PONTOS_ACESSO(pac_data_inicial, pac_data_final, fun_id) values ('2023-02-01 07:00:00', '2023-02-01 11:57:00', 3);

select concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	f.fun_data_nascimento, 
	p.pac_data_inicial, 
	p.pac_data_final,
	convert(time(0), p.pac_data_final - p.pac_data_inicial) as horas_trabalhadas
from FUN_FUNCIONARIOS f join PAC_PONTOS_ACESSO p
on(f.fun_id = p.fun_id);

-- 8.3 left join
select concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	f.fun_data_nascimento, 
	p.pac_data_inicial, 
	p.pac_data_final,
	convert(time(0), p.pac_data_final - p.pac_data_inicial) as horas_trabalhadas
from FUN_FUNCIONARIOS f left join PAC_PONTOS_ACESSO p
on(f.fun_id = p.fun_id)
where p.pac_data_final is null;