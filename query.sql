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