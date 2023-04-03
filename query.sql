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

-- 8.4 right join
select concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	f.fun_data_nascimento, 
	p.pac_data_inicial, 
	p.pac_data_final,
	convert(time(0), p.pac_data_final - p.pac_data_inicial) as horas_trabalhadas
from FUN_FUNCIONARIOS f right join PAC_PONTOS_ACESSO p
on(f.fun_id = p.fun_id)
where p.pac_data_final is null;

-- 8.6 relacionamentos pt.1
create table DEP_DEPARTAMENTOS
(
	dep_id int identity(1, 1) primary key,
	dep_nome varchar(50) not null
);

insert into DEP_DEPARTAMENTOS(dep_nome) values('recursos humanos'), ('tecnologia de informação'), ('controladoria');

select * from DEP_DEPARTAMENTOS;

alter table FUN_FUNCIONARIOS add dep_id int not null default 1;

select * from FUN_FUNCIONARIOS;

alter table FUN_FUNCIONARIOS add constraint fk_fun_funcionarios__dep_departamentos__dep_id 
foreign key(dep_id) references DEP_DEPARTAMENTOS(dep_id);

update FUN_FUNCIONARIOS set dep_id = 2 where fun_id = 3;
update FUN_FUNCIONARIOS set dep_id = 3 where fun_id = 4;

-- 8.7 relacionamentos pt.2
alter table DEP_DEPARTAMENTOS add fun_id_responsavel int not null default 1;

select * from DEP_DEPARTAMENTOS;
select * from FUN_FUNCIONARIOS;

alter table DEP_DEPARTAMENTOS add constraint fk_dep_departamentos__fun_funcionarios__fun_id_responsavel
foreign key(fun_id_responsavel) references fun_funcionarios(fun_id);

update DEP_DEPARTAMENTOS set fun_id_responsavel = 3 where dep_id = 2;
update DEP_DEPARTAMENTOS set fun_id_responsavel = 4 where dep_id = 3;

-- 8.8 relacionamentos pt.3
select d.dep_nome as departamento,
	concat(f2.fun_sobrenome, ', ', f2.fun_nome) as repsonsavel_departamento,
	concat(f.fun_sobrenome, ', ', f.fun_nome) as funcionario,
	p.pac_data_inicial,
	p.pac_data_final,
	convert(time(0), p.pac_data_final - p.pac_data_inicial) as horas_trabalhadas
from FUN_FUNCIONARIOS f
left join PAC_PONTOS_ACESSO p
	on f.fun_id = p.fun_id
inner join DEP_DEPARTAMENTOS d
	on f.dep_id = d.dep_id
inner join FUN_FUNCIONARIOS f2
	on d.fun_id_responsavel = f2.fun_id;

-- 9 funções 
/*funções escalares: que retornam apenas um valor.
para cadeia de caracteres, as mais comuns são:
CONCAT: Agrupa duas ou mais cadeias de caracteres. Sua sintaxe é:
	CONCAT(string1, string2 ... stringN);

LOWER: Converte todos os caracteres para minúsculo. Sua sintaxe é:
	UPPER(string);

REPLACE: Substitui todas as ocorrências de uma sequência de caracteres por outra. Sua sintaxe é:
	REPLACE(string_original, string_a_trocar, string_nova);

SUBSTRING: Retorna parte de uma cadeia de caracteres definida. Sua sintaxe é:
	SUBSTRING('string_original', 'posicao', 'tamanho');

funções escalares matemáticas mais usadas:
ABS: Retorna o valor positivo absoluto do valor de entrada. Sua sintaxe é:
	ABS(valor);

LOG10: Retorna o logaritmo da base 10 do valor de entrada. Sua sintaxe é:
	LOG10(valor);

PI Retorna o valor da constante PI. Sua sintaxe é:
	PI();

RAND: Retorna um número aleatório entre 0 e 1. Se for informado um valor no seu parâmetro, o 
número gerado deixará de ser aleatório, repetindo sempre que o mesmo parâmetro for informado. Sua sintaxe é:
	RAND([valor]);

mais ultilizadas para trabalhar com data e hora:
SYSDATETIME: Retorna data e hora no formato datetime2(7) do computador onde o banco de dados está instalado:
	SYSDATETIME();

CURRENT_TIMESTAMP: Retorna o timestamp do computador onde o banco de dados está instalado:
	CURRENT_TIMESTAMP();

DATEFROMPARTS: Retorna uma data a partir dos parâmetros passados. Sua sintaxe é:
	DATEFROMPARTS(ano, mes, dia);

DATEDIFF: Retorna a diferença entre duas datas. Veja sua sintaxe:
	DATEDIFF(unidade_retorno, data_inicial, data_final);
	A unidade de retorno pode ser: Year- Anos; Quarter – Trimestres;Month – Meses; Dayofyear – Dias do Ano;
									Day – Dias; Week – Semanas; Hour – Horas; Minute – Minutos; Second – Segundos;
									Millisecond – milissegundos; Microsecond – Microssegundos; Nanosecond – Nanossegundos.

outras funções de uso diverso:
HOST_NAME: Retorna o nome da estação que está executando.
DB_NAME: Retorna o banco de dados que está conectado agora.
SYSTEM_USER: Retorna o usuário conectado.
CAST: Realiza a conversão entre tipos de dados. Sua sintaxe é:
	CAST (valor AS tipo_dados [(tamanho)]); --tamanho é opcional

funções de agregação ou sumarizadores: realizam ações sobre um conjunto de valores e retornam apenas um valor como resultado. 
Este valor único retornado geralmente corresponde a um cálculo matemático realizado em cima das tuplas especificadas.
as mais utilizadas são:
MIN: Retorna o menor valor;
MAX: Retorna o maior valor;
SUM: Calcula a soma de todos os valores;
AVG: Calcula a média de todos os valores;
COUNT: Retorna o número de itens.

criação de funções:
CREATE FUNCTION nome_função (@parametro tipo, @parametro2 tipo2, ... @parametroN tipoN)
RETURNS tipo_retorno
BEGIN
  Comando1
  Comando2
  ComandoN
END

declarar e setar variáveis:
DECLARE @nome_variavel tipo_dado (sim, precisa do @ na frente do nome)
SET @nome_variavel = valor

estruturas condicioanis:
IF Expressão booleana
BEGIN

  Comando caso a condição seja verdadeira

  Comando2 caso a condição seja verdadeira

  Comando3 caso a condição seja verdadeira

END
ELSE
BEGIN
  Comando caso a condição seja falsa

  Comando2 caso a condição seja falsa

  Comando3 caso a condição seja falsa
END

exemplo:
DECLARE @nacionalidade varchar(50))
DECLARE @resultado varchar(50)
SET @nacionalidade = 'Brasileiro'
IF @nacionalidade = 'Brasileiro'
BEGIN
  SET @resultado = 'Você é brasileiro '
  SET @resultado = CONCAT('Parabéns ', @resultado)
END
ELSE
BEGIN
  SET @resultado = 'Você não é brasileiro'
  SET @resultado = CONCAT('Que Pena! ', @resultado)
END

estruturas de repetição:
WHILE Teste
BEGIN
Comando1
Comando2
...
ComandoN
END

exemplo:
DECLARE @resultado varchar(max), @contador int
SET @contador = 0
SET @resultado = ''

WHILE @contador <= 10
BEGIN
  SET @resultado = CONCAT(@resultado, @contador, ', ')
  SET @contador = @contador + 1;
END

apagando user functions:
DROP FUNCTION função1, função2, ... funçãoN;
*/

-- 9.1 funções de agregação pt.1
select count(*) from FUN_FUNCIONARIOS;
select count(convert(varchar, fun_observacoes)) from FUN_FUNCIONARIOS;
select min(fun_data_nascimento) from FUN_FUNCIONARIOS;
select max(fun_data_nascimento) from FUN_FUNCIONARIOS;
select fun_nome, fun_sobrenome, fun_data_nascimento from FUN_FUNCIONARIOS where fun_data_nascimento = (select max(fun_data_nascimento) from FUN_FUNCIONARIOS);

-- 9.2 funções de agragação pt.2
select d.dep_nome, count(*) as qtd_funcionarios
from DEP_DEPARTAMENTOS d
join FUN_FUNCIONARIOS f
on d.dep_id = f.dep_id
group by d.dep_nome;

-- 9.3 funções de agregação pt.3
alter table FUN_FUNCIONARIOS add fun_salario money not null default 0;
select * from FUN_FUNCIONARIOS;
update FUN_FUNCIONARIOS set fun_salario = 1000 where fun_id = 1;
update FUN_FUNCIONARIOS set fun_salario = 1700 where fun_id = 3;
update FUN_FUNCIONARIOS set fun_salario = 5000 where fun_id = 4;

select sum(fun_salario) as folha_salarial from FUN_FUNCIONARIOS;

select d.dep_nome, sum(f.fun_salario) as folha_salarial, avg(f.fun_salario) as media_salarial
from DEP_DEPARTAMENTOS d
join FUN_FUNCIONARIOS f
on d.dep_id = f.dep_id
group by d.dep_nome;

-- 9.4 funções de agregação pt.4
insert into PAC_PONTOS_ACESSO(pac_data_inicial, pac_data_final, fun_id) values ('2023-01-01 13:02:00', '2023-01-01 17:07:00', 1);
insert into PAC_PONTOS_ACESSO(pac_data_inicial, pac_data_final, fun_id) values ('2023-01-02 07:03:00', '2023-01-02 12:20:00', 1);

select dados_ponto.data,
       concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	   (
		  format(sum(dados_ponto.diferenca_segundos)/3600, '00') + ':' + 
		  format((sum(dados_ponto.diferenca_segundos)%3600)/60, '00') + ':' +
		  format(((sum(dados_ponto.diferenca_segundos)%3600)%60), '00')
	   ) as horas_trabalhadas
from
(
	select datediff(second, pac_data_inicial, pac_data_final) as diferenca_segundos,
		   convert(date, pac_data_inicial) as data,
		   fun_id
		from PAC_PONTOS_ACESSO
) as dados_ponto
join FUN_FUNCIONARIOS f
	on f.fun_id = dados_ponto.fun_id
group by dados_ponto.data, concat(f.fun_sobrenome, ', ', f.fun_nome)
order by dados_ponto.data;

-- 9.5 common table expressions (cte)
with dados_ponto(diferenca_segundos, data, fun_id) as
(
	select datediff(second, pac_data_inicial, pac_data_final) as diferenca_segundos,
		   convert(date, pac_data_inicial) as data,
		   fun_id
		from PAC_PONTOS_ACESSO
)

select dados_ponto.data,
       concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	   (
		  format(sum(dados_ponto.diferenca_segundos)/3600, '00') + ':' + 
		  format((sum(dados_ponto.diferenca_segundos)%3600)/60, '00') + ':' +
		  format(((sum(dados_ponto.diferenca_segundos)%3600)%60), '00')
	   ) as horas_trabalhadas
from dados_ponto
join FUN_FUNCIONARIOS f
	on f.fun_id = dados_ponto.fun_id
group by dados_ponto.data, concat(f.fun_sobrenome, ', ', f.fun_nome)
order by dados_ponto.data;

with dados_ponto(diferenca_segundos, data, fun_id) as
(
	select datediff(second, pac_data_inicial, pac_data_final) as diferenca_segundos,
		   convert(date, pac_data_inicial) as data,
		   fun_id
		from PAC_PONTOS_ACESSO
)

select fun_id, diferenca_segundos
from dados_ponto
where diferenca_segundos in (select min(diferenca_segundos) from dados_ponto) or
diferenca_segundos in (select max(diferenca_segundos) from dados_ponto);

-- 9.6 criando funções pt.1
create function fn_calcula_hora(@p_qtde_segundos int)
returns varchar(8) as
begin
	return format(@p_qtde_segundos/3600, '00') + ':' +
		   format((@p_qtde_segundos%3600)/60, '00') + ':' +
		   format(((@p_qtde_segundos%3600)/60), '00')
end;

with dados_ponto(diferenca_segundos, data, fun_id) as
(
	select datediff(second, pac_data_inicial, pac_data_final) as diferenca_segundos,
	       convert(date, pac_data_inicial) as data,
		   fun_id
		from PAC_PONTOS_ACESSO
)

select dados_ponto.data,
	   concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	   dbo.fn_calcula_hora(sum(dados_ponto.diferenca_segundos)) as horas_trabalhadas
from dados_ponto
join FUN_FUNCIONARIOS f
	on f.fun_id = dados_ponto.fun_id
group by dados_ponto.data, concat(f.fun_sobrenome, ', ', f.fun_nome)
order by dados_ponto.data;

alter function fn_calcula_hora(@p_qtde_segundos int)
returns varchar(8) as
begin
	declare @resultado varchar(8);
	set @resultado = format(@p_qtde_segundos/3600, '00') + ':';
	set @resultado = @resultado + format((@p_qtde_segundos%3600)/60, '00') + ':';
	set @resultado = @resultado + format(((@p_qtde_segundos%3600)%60), '00');
	return @resultado;
end;

--drop function fn_calcula_hora;

-- 9.7 criando funções pt.2
create function fn_dados_ponto()
returns table as
return select datediff(second, pac_data_inicial, pac_data_final) as diferenca_segundos,
			  convert(date, pac_data_inicial) as data,
			  fun_id
		from PAC_PONTOS_ACESSO;

select * from dbo.fn_dados_ponto();

select dados_ponto.data,
	   concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_completo,
	   dbo.fn_calcula_hora(sum(dados_ponto.diferenca_segundos)) as horas_trabalhadas
from dbo.fn_dados_ponto() as dados_ponto
join fun_funcionarios f
	on f.fun_id = dados_ponto.fun_id
group by dados_ponto.data, concat(f.fun_sobrenome, ', ', f.fun_nome)
order by dados_ponto.data;

-- 9.8 criando funções pt.3
drop function fn_dados_ponto;
create function fn_dados_ponto(@p_fun_id int = null)
returns @resultado table
(
	diferenca_segundos int,
	data date,
	fun_id int
)
as
begin
	if @p_fun_id is null
	begin
		insert into @resultado select datediff(second, pac_data_inicial, pac_data_final) as diferenca_segundos,
							          convert(date, pac_data_inicial) as data,
									  fun_id
									from PAC_PONTOS_ACESSO;
	end
	else
	begin
		insert into @resultado select datediff(second, pac_data_inicial, pac_data_final) as diferenca_segundos,
							          convert(date, pac_data_inicial) as data,
									  fun_id
									from PAC_PONTOS_ACESSO
									where fun_id = @p_fun_id;
	end
	return;
end;

select * from dbo.fn_dados_ponto(1);

select dados_ponto.data,
	   concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	   dbo.fn_calcula_hora(sum(dados_ponto.diferenca_segundos)) as horas_trabalhadas
from dbo.fn_dados_ponto(default) as dados_ponto
join fun_funcionarios f
	on f.fun_id = dados_ponto.fun_id
group by dados_ponto.data, concat(f.fun_sobrenome, ', ', f.fun_nome)
order by dados_ponto.data;

-- 10 views
-- o comando usado para criar uma view é o CREATE VIEW. Sua sintaxe mais básica é a seguinte:
CREATE VIEW nome_view AS consulta;
-- sendo que consulta pode ser qualquer pesquisa utilizando SELECT. Por exemplo:
CREATE VIEW carros_antigos AS
SELECT * FROM carro WHERE ano_fabricacao < 2013;
-- o processo para alterar uma view é muito parecido com o processo de criação, pois todas as partes do comando de criação devem ser reescritas:
ALTER VIEW nome_view AS consulta;
-- o comando usado para excluir uma view é muito simples também:
DROP VIEW nome_view;

-- 10.1 criando uma view
create view vw_ponto_funcionarios as
select dados_ponto.data,
	   concat(f.fun_sobrenome, ', ', f.fun_nome) as nome_funcionario,
	   dbo.fn_calcula_hora(sum(dados_ponto.diferenca_segundos)) as horas_trabalhadas
from dbo.fn_dados_ponto(default) as dados_ponto
join FUN_FUNCIONARIOS f
	on f.fun_id = dados_ponto.fun_id
group by dados_ponto.data, concat(f.fun_sobrenome, ', ', f.fun_nome);

select * from vw_ponto_funcionarios order by data;

-- 11 stored procedures
/*conjunto de instruções que ficam armazenados pré-compilados no servidor e agrupados por um nome, assim como as funções. Só que, diferente de 
funções, as stored procedures não retornam valores. Outras diferenças entre funções e procedimentos são:
	. funções não podem executar stored procedures. Mas procedimentos podem executar funções e outras stored procedures;
	. procedures podem criar tabelas, inserir, excluir ou alterar seus dados. Já funções não podem executar nenhuma dessas ações.
sintaxe para criar STORED PROCEDURES:*/
CREATE PROCEDURE nome_do_stored_procedure
[
{@nome_parâmetro1 tipo_de_dados_do_parâmetro} [=valor_default] [OUTPUT]
]
[,..n]
AS
comando 1
comando 2
...
comando n
/*dentro do bloco de comandos da procedure, podemos utilizar todos recursos que vimos para funções: variáveis, condicionais e estruturas de 
repetição; além de poder executar comandos DDL e DML.*/

-- 11.1 criando stored procedures
create or alter procedure spe_registrar_ponto_acesso @p_fun_id int, @p_data datetime
as
begin
	set nocount on;
	declare @qtde_pontos_abertos int;
	select @qtde_pontos_abertos = count(*)
		from PAC_PONTOS_ACESSO
	where fun_id = @p_fun_id
		and pac_data_final is null;
	if @qtde_pontos_abertos = 0
	begin
		-- NOVO PONTO
		insert into PAC_PONTOS_ACESSO(pac_data_inicial, fun_id)
			values(@p_data, @p_fun_id);
	end
	else
	begin
		-- ATUALIZAR PONTO ABERTO
		update PAC_PONTOS_ACESSO
			set pac_data_final = @p_data
		where fun_id = @p_fun_id
			and pac_data_final is null;
	end
	set nocount off;
end;

execute dbo.spe_registrar_ponto_acesso 1, '2023-01-03 07:00:00';
execute dbo.spe_registrar_ponto_acesso 1, '2023-01-03 12:00:00';
execute dbo.spe_registrar_ponto_acesso 1, '2023-01-03 13:00:00';
execute dbo.spe_registrar_ponto_acesso 1, '2023-01-03 17:00:00';
select * from PAC_PONTOS_ACESSO;
select * from vw_ponto_funcionarios;

-- 11.2 stored procedures: tabelas temporárias, variáveis de tabela e cursor
create table AVS_AVISOS_FUNCIONARIOS
(
	avs_id int identity(1,1) primary key,
	avs_nome_funcionario varchar(20) not null,
	avs_horas_trabalhadas char(8) not null,
	avs_data_aviso date not null
);

create or alter procedure spe_notificar_horas_extras @p_data_refderencia date
as
begin
	set nocount on;
	declare cr_funcionarios cursor for
		select data, nome_funcionario, horas_trabalhadas
		from dbo.vw_ponto_funcionarios
		where data = @p_data_refderencia;
	if object_id(N'tempdb..#horas_extras') is null
	begin
		-- CRIAR TABELA TEMPORÁRIA
		create table #horas_extras
		(
			nome_funcionario varchar(70),
			data_evento date,
			horas_trabalhadas char(8)
		);
	end
	else
	begin
		-- LIMPAR A TABELA TEMPORÁRIA
		delete from #horas_extras;
	end
	declare @data date;
	declare @nome_funcionario varchar(70);
	declare @horas_trabalhadas char(8);
	declare @tempo_trabalhado int;
	open cr_funcionarios;
	fetch next from cr_funcionarios
		into @data, @nome_funcionario, @horas_trabalhadas;
	while @@fetch_status = 0
	begin
		set @tempo_trabalhado = datepart(second, convert(time(0), @horas_trabalhadas)) +
								datepart(minute, convert(time(0), @horas_trabalhadas)) * 60 +
								datepart(hour, convert(time(0), @horas_trabalhadas)) * 3600;
		if @tempo_trabalhado > 8 * 60 * 60
		begin
			insert into #horas_extras(nome_funcionario, data_evento, horas_trabalhadas)
				values(@nome_funcionario, @data, @horas_trabalhadas);
		end
		fetch next from cr_funcionarios
			into @data, @nome_funcionario, @horas_trabalhadas;
	end
	close cr_funcionarios;
	deallocate cr_funcionarios;
	insert into AVS_AVISOS_FUNCIONARIOS(avs_nome_funcionario, avs_data_aviso, avs_horas_trabalhadas)
		select nome_funcionario, data_evento, horas_trabalhadas from #horas_extras;
	set nocount off;
end;

select * from vw_ponto_funcionarios;

exec dbo.spe_notificar_horas_extras '2023-02-01';
exec dbo.spe_notificar_horas_extras '2023-01-03';

select * from AVS_AVISOS_FUNCIONARIOS;

-- 11.3 stored procedures: lançamento e tratamento de erros
create or alter procedure spe_notificar_horas_extras @p_data_refderencia date, @qtde_eventos int output
as
begin
	if eomonth(@p_data_refderencia) = @p_data_refderencia
	begin;
		-- raiserror('último do dia do mês não pode gerar avisos!', 11, 1);
		throw 50000, 'último do dia do mês não pode gerar avisos!', 1;
		print 'erro lançado';
		-- raiserror nao impede a execução da sp, throw sim, por isso o print acima não é executado no throw
	end
	set nocount on;
	declare cr_funcionarios cursor for
		select data, nome_funcionario, horas_trabalhadas
		from dbo.vw_ponto_funcionarios
		where data = @p_data_refderencia;
	if object_id(N'tempdb..#horas_extras') is null
	begin
		-- CRIAR TABELA TEMPORÁRIA
		create table #horas_extras
		(
			nome_funcionario varchar(70),
			data_evento date,
			horas_trabalhadas char(8)
		);
	end
	else
	begin
		-- LIMPAR A TABELA TEMPORÁRIA
		delete from #horas_extras;
	end
	declare @data date;
	declare @nome_funcionario varchar(70);
	declare @horas_trabalhadas char(8);
	declare @tempo_trabalhado int;
	open cr_funcionarios;
	fetch next from cr_funcionarios
		into @data, @nome_funcionario, @horas_trabalhadas;
	while @@fetch_status = 0
	begin
		set @tempo_trabalhado = datepart(second, convert(time(0), @horas_trabalhadas)) +
								datepart(minute, convert(time(0), @horas_trabalhadas)) * 60 +
								datepart(hour, convert(time(0), @horas_trabalhadas)) * 3600;
		if @tempo_trabalhado > 8 * 60 * 60
		begin
			insert into #horas_extras(nome_funcionario, data_evento, horas_trabalhadas)
				values(@nome_funcionario, @data, @horas_trabalhadas);
		end
		fetch next from cr_funcionarios
			into @data, @nome_funcionario, @horas_trabalhadas;
	end
	close cr_funcionarios;
	deallocate cr_funcionarios;
	insert into AVS_AVISOS_FUNCIONARIOS(avs_nome_funcionario, avs_data_aviso, avs_horas_trabalhadas)
		select nome_funcionario, data_evento, horas_trabalhadas from #horas_extras;
		select @qtde_eventos = count(*) from AVS_AVISOS_FUNCIONARIOS;
	set nocount off;
end;

select * from vw_ponto_funcionarios;

declare @qtde_horas_extras int;
begin try
	exec spe_notificar_horas_extras '2023-01-04', @qtde_eventos = @qtde_horas_extras output;
	select @qtde_horas_extras as quantidade_eventos;
end try
begin catch
	print 'houve um erro ao realizar o procedimento';
	print error_message();
	print 'severidade: ';
	print error_severity();
	print 'estado: ';
	print error_state();
end catch;

-- 12 transações
-- no T-SQL uma transação é definida dentro de um bloco declarado a partir do BEGIN TRANSACTION, conforme a sintaxe:
BEGIN { TRAN | TRANSACTION }
    [ transacao_nome
      [ WITH MARK [ 'descricao' ] ]
--instruções
COMMIT [ transacao_nome]
ROLLBACK [transacao_nome]

/*
na sintaxe acima, a transação/unidade lógica começa no comando BEGIN TRAN ou BEGIN TRANSACTION. O COMMIT é uma 
operação de confirmação de que correu tudo bem e que todos os comandos que fazem parte da unidade lógica, ou da
transação, foram executados com sucesso e o banco de dados encontra-se em um estado consistente. Já o ROLLBACK 
retornará todos os comandos anteriores àquele onde houve um erro, ou seja: tudo será desfeito se houve um 
problema com algum comando dentro de uma transação.

COMMIT: indica o término de uma transação bem-sucedida. Ela informa ao gerenciador de transações que uma unidade
lógica de trabalho foi concluída com sucesso, o banco de dados já está novamente em um estado consistente e todas
as atualizações feitas por essa unidade de trabalho já podem se tornar permanentes.

ROLLBACK: assinala o término de uma transação malsucedida. Ela informa ao gerenciador de transações que algo saiu
errado, que o banco de dados pode estar em um estado inconsistente, e que todas as atualizações feitas pela unidade
lógica de trabalho até agora devem ser desfeitas.

as vantagens do uso de transações em um ambiente web, por exemplo, são inúmeras. As principais são:

	não carregar com processamento no lado cliente;
	ter uma estrutura modular;
	evitar perda de informações, pois um usuário pode simplesmente fechar o browser e apagar todo o carrinho de compras;
	diminuir o tráfego na rede já que se está trafegando parâmetros e os entregando ao banco de dados;
	ter controle sobre os erros que possam acontecer com as lógicas de definição de fluxo de dados;
	ter controle das atualizações de registros através de bloqueios.

para usar essa engenharia toda deve-se, ainda, conhecer as propriedades ACID, que são atributos necessários à toda 
transação para que não existam problemas durante a execução. ACID é uma sigla que significa:

	atomicidade: toda transação deverá ser atômica – o verdadeiro "tudo ou nada";
	consistência: as transações devem preservar a consistência do banco de dados, ou seja: transforma um estado 
		consistente do banco de dados em outro estado consistente, sem necessariamente preservar o estado de 
		consistência em todos os pontos intermediários;
	isolamento: as transações são isoladas umas das outras, de acordo com o nível de isolamento definido no 
		momento em que a transação se inicia, que no SQL Server são: REPEATABLE READ, READ COMMITED, 
		READ UNCOMMITED e SERIALIZABLE;
	durabilidade: uma vez comprometida a transação, suas atualizações sobrevivem no banco de dados mesmo que
		haja uma queda subsequente do sistema.

o SQL Server dá 100% de suporte às propriedades ACID, com possibilidade de Auto Recovery que é a recuperação do
banco de dados após uma falha e amparo com vários arquivos de log.
*/

-- 12.1 usando comandos BEGIN TRAN, COMMIT e ROLLBACK
create table LOG_LOGS
(
	log_id int identity(1,1) not null,
	log_evento varchar(300)
);

declare @qtde_horas_extras int;
begin transaction;
begin try
	insert into LOG_LOGS(log_evento) values('spe_notificar_horas_extras vai ser invocada');
	exec spe_notificar_horas_extras '2023-01-04', @qtde_eventos = @qtde_horas_extras output;
	select @qtde_horas_extras as quantidade_eventos;
	insert into LOG_LOGS(log_evento) values('spe_notificar_horas_extras foi invocada');
	commit;
end try
begin catch
	rollback;
	print 'houve um erro ao realizar o procedimento';
	print error_message();
	print 'severidade: ';
	print error_severity();
	print 'estado: ';
	print error_state();
end catch;

select * from LOG_LOGS;