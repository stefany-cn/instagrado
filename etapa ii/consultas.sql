-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                               CRIAÇÃO DE VISÕES
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Essa visão agrega informações sobre publicações, incluindo a conta que publicou, o número total de comentários e
-- curtidas, permitindo consultas mais eficientes sobre o desempenho das publicações.  
CREATE OR REPLACE VIEW INFO_PUBLICACOES AS
SELECT p.id_conta, p.id_publicacao, p.data_publicacao, p.descricao,
       COUNT(DISTINCT c.id_comentario) AS total_comentarios,
       COUNT(DISTINCT curt.id_curtida) AS total_curtidas
FROM PUBLICACOES p
LEFT JOIN COMENTARIOS c ON p.id_publicacao = c.id_publicacao
LEFT JOIN CURTIDAS curt ON p.id_publicacao = curt.id_publicacao
GROUP BY p.id_publicacao, p.data_publicacao, p.descricao;

-- SELECT * FROM INFO_PUBLICACOES;
-- drop view INFO_PUBLICACOES

-- Essa visão pega informações sobre os criadores de conteúdo, incluindo o número total de interações e visualizações
-- de perfil, permitindo uma análise mais eficiente do desempenho dos criadores.
CREATE OR REPLACE VIEW INFO_CRIADORES_DE_CONTEUDO AS
SELECT cc.id_criador, cc.id_conta, c.nome_usuario, cc.interacao, cc.visualizacoes_do_perfil
FROM CRIADORES_DE_CONTEUDO cc JOIN CONTAS c ON cc.id_conta = c.id_conta;

-- drop view INFO_CRIADORES_DE_CONTEUDO;
-- select * from INFO_CRIADORES_DE_CONTEUDO;

-- Essa visão serve para agregar e explicitar o relacionamento entre contas e perfis
CREATE OR REPLACE VIEW CONTAS_PERFIS AS
SELECT id_conta, id_perfil, nome_usuario
FROM PERFIS natural join CONTAS

-- Essa visão serve para agregar e explicitar a especialização entre contas de criadores e contas
CREATE OR REPLACE VIEW CONTAS_CRIADORES AS
SELECT id_criador, CRIADORES_DE_CONTEUDO.id_conta, nome_usuario
FROM CRIADORES_DE_CONTEUDO NATURAL join CONTAS 

-- select * from CONTAS_CRIADORES
-- drop view CONTAS_CRIADORES
-- drop view CONTAS_PERFIS

-- SELECT * FROM CRIADORES_DE_CONTEUDO
-- SELECT * FROM contas

-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                                    CONSULTAS
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- CONSULTA 1 ==========================================================================================================
-- Consulta usando GROUP BY
-- Para cada criador de conteúdo, o nome de usuario, id da publicação e a quantidade de comentários e curtidas que foram 
-- feitos nas publicações, ordenado de forma decrescente por total de curtidas e total de comentários na publicação.
--		Essa consulta ajuda a identificar publicações com maior engajamento e seus autores.

-- ENTIDADES: CONTA (VISÃO CONTAS_CRIADORES), CRIADOR_DE_CONTEÚDO (VISÃO CONTAS_CRIADORES), PUBLICAÇÃO
-- RELACIONAMENTOS: COMENTAR(PUBLICACAO-CONTA), CURTIR(PUBLICACAO-CONTA)
-- VISOES: CONTAS_CRIADORES
-- TABELAS ENVOLVIDAS: 4 
SELECT 
    cdc.nome_usuario AS usuario,
    p.id_publicacao,
    COUNT(DISTINCT curt.id_curtida) AS total_curtidas,
    COUNT(DISTINCT co.id_comentario) AS total_comentarios
FROM 
    PUBLICACOES p
JOIN CONTAS_CRIADORES cdc ON p.id_conta = cdc.id_conta
LEFT JOIN CURTIDAS curt ON curt.id_publicacao = p.id_publicacao
LEFT JOIN COMENTARIOS co ON co.id_publicacao = p.id_publicacao
GROUP BY 
    cdc.nome_usuario, p.id_publicacao
ORDER BY 
    total_curtidas DESC, total_comentarios DESC;
	
-- SELECT 
--     c.nome_usuario,
--     COUNT(co.id_comentario) AS total_comentarios_suas_publicacoes
-- FROM CONTAS c JOIN PUBLICACOES p ON c.id_conta = p.id_conta
-- LEFT JOIN COMENTARIOS co ON p.id_publicacao = co.id_publicacao
-- GROUP BY c.nome_usuario; 

-- CONSULTA 2 ========================================================================================================
-- Consulta usando subconsulta que não possa ser substituída por JOIN
-- Nome dos usuários que tenham pelo menos uma publicação que contenha pelo menos um comentário da usuária "maria_dev".
-- 		Essa subconsulta não pode ser substituída apenas por JOIN, pois contém EXISTS duplamente aninhado para garantir a 
--		existência das duas condições sem precisar de agregação e poderia haver duplicações e para que não houvesse
--		seria necessário usar DISTINCT e/ou outros filtros.
--		Essa consulta é relevante para identificar os interesses de um dado usuário (nesse caso, a usuária "maria_dev")

-- ENTIDADES: CONTA, PUBLICAÇÃO
-- RELACIONAMENTOS: COMENTAR(PUBLICACAO-CONTA)
-- VISOES: []
-- TABELAS ENVOLVIDAS: 3

SELECT c.nome_usuario
FROM CONTAS c
WHERE EXISTS (SELECT * 
			  FROM PUBLICACOES p 
			  WHERE p.id_conta = c.id_conta AND EXISTS (SELECT * 
			  											FROM COMENTARIOS co JOIN CONTAS c2 ON co.id_conta = c2.id_conta 
														WHERE co.id_publicacao = p.id_publicacao AND c2.nome_usuario = 'maria_dev'));

-- CONSULTA 3 =====================================================================================================
-- Consulta usando visão CONTAS_CRIADORES
-- Nome dos usuários, total de publicações que fez e total de comentários que recebeu em suas publicações

-- ENTIDADES: CONTA (VISÃO CONTAS_CRIADORES), CRIADOR_DE_CONTEÚDO (VISÃO CONTAS_CRIADORES), PUBLICAÇÃO
-- RELACIONAMENTOS: COMENTAR(PUBLICACAO-CONTA)
-- VISOES: CONTAS_CRIADORES
-- TABELAS ENVOLVIDAS: 3

SELECT cc.nome_usuario, 
	   COUNT(DISTINCT p.id_publicacao) AS total_publicacoes, 
	   COUNT(co.id_comentario) AS total_comentarios
FROM CONTAS_CRIADORES cc JOIN PUBLICACOES p ON p.id_conta = cc.id_conta 
					     JOIN COMENTARIOS co ON co.id_publicacao = p.id_publicacao
GROUP BY cc.nome_usuario;


-- CONSULTA 4 ====================================================================================================
-- Consulta usando TODOS que/NENHUM que
-- Nome de usuário dos criadores de conteúdo e nome de usuário das contas que curtiram todas as publicações do criador

-- ENTIDADES: CONTA (VISÃO CONTAS_CRIADORES), CRIADOR_DE_CONTEÚDO (VISÃO CONTAS_CRIADORES), PUBLICAÇÃO
-- RELACIONAMENTOS: CURTIR(PUBLICACAO-CONTA)
-- VISOES: CONTAS_CRIADORES
-- TABELAS ENVOLVIDAS: 3

SELECT 
    cc.nome_usuario AS nome_criador,
    u.nome_usuario AS usuario_que_curtiu_todas
FROM 
    CONTAS_CRIADORES cc
JOIN CONTAS u ON u.id_conta != cc.id_conta
WHERE NOT EXISTS (
    SELECT *
    FROM PUBLICACOES p
    WHERE p.id_conta = cc.id_conta
    AND NOT EXISTS (
        SELECT *
        FROM CURTIDAS curt
        WHERE curt.id_publicacao = p.id_publicacao
        AND curt.id_conta = u.id_conta
    )
);

-- CONSULTA 5 =====================================================================================================
-- O nome de usuário de todas as contas que são criadores de conteudo e os usuários que visualizaram seu perfil

-- ENTIDADES: CONTA (VISÃO CONTAS_CRIADORES), CRIADOR_DE_CONTEÚDO (VISÃO CONTAS_CRIADORES)
-- RELACIONAMENTOS: VISUALIZAÇÃO(CRIADORES_DE_CONTEUDO-PERFIS)
-- VISOES: CONTAS_PERFIS, CONTAS_CRIADORES
-- TABELAS ENVOLVIDAS: 4
select CC.nome_usuario Criador, CP.nome_usuario Visualizadores
from CRIADORES_DE_CONTEUDO CDC 
     join CONTAS_CRIADORES CC on(CDC.id_criador = CC.id_criador)
	 join VISUALIZACOES V on (CDC.id_criador = V.id_criador)
	 join CONTAS_PERFIS CP on(V.id_perfil = CP.id_perfil)

-- CONSULTA 6 =============================================================================
-- Para todos os Perfis do aplicativo, seus usuários e suas publicações

-- ENTIDADES: PUBLICACOES, MIDIAS
-- RELACIONAMENTOS: INTEGRAR(PERFIS-PUBLICACACOES), POSSUI(PERFIS-CONTAS), CONTER(PUBLICACOES-MIDIAS)
-- VISOES: CONTAS_PERFIS
-- TABELAS ENVOLVIDAS: 3

select nome_usuario, data_publicacao, descricao, conteudo
from CONTAS_PERFIS CP
	 natural join PUBLICACOES
	 natural join MIDIAS

-- CONSULTA 7 =============================================================================
-- Para todas as contas do instagrado, 
-- as contas mais populares e engajadas, isto é, contas com: curtidas>=5, comentarios>=2, e no minimo dois tipos diferentes de publicações
-- e o numero de publicações que a conta fez,
-- o total de curtidas da conta,
-- o total de comentarios da conta

-- ENTIDADES: CONTAS, POSTS, STORIES, REELS,
-- RELACIONAMENTOS: COMENTAR(PUBLICACAO-CONTA), CURTIR(PUBLICACAO-CONTA), CRIAR(PUBLICACAO-CONTA)
-- VISOES: INFO_PUBLICACOES
-- TABELAS ENVOLVIDAS: 3

select nome_usuario, sum(total_curtidas) conta_curtidas, sum(total_comentarios) conta_comentarios, sum(id_publicacao) n_publicacoes
from INFO_PUBLICACOES IP0 natural join CONTAS
group by nome_usuario, id_conta
having sum(total_curtidas)>=5 and sum(total_comentarios)>=2 
and (select count(*)
	 from(
			select id_conta, id_publicacao
			from INFO_PUBLICACOES IP1 natural join CONTAS natural join POSTS
			where IP1.id_conta = IP0.id_conta
			UNION
			select id_conta, id_publicacao
			from INFO_PUBLICACOES IP2 natural join CONTAS natural join STORIES
			where IP2.id_conta = IP0.id_conta
			UNION
			select id_conta, id_publicacao
			from INFO_PUBLICACOES IP3 natural join CONTAS natural join REELS
			where IP3.id_conta = IP0.id_conta
	) as usuario_publicacoes ) >=2

-- CONSULTA 8 =============================================================================
-- O nome de usuario de todos aqueles que criaram pelo menos uma publicação de cada tipo (STORY, POST, REELS)

-- ENTIDADES: CONTA, PUBLICAÇÃO, POST, REELS, STORY
-- RELACIONAMENTOS: CRIAR(CONTA-PUBLICAÇÃO)
-- VISOES: []
-- TABELAS ENVOLVIDAS: 5

SELECT c.nome_usuario
FROM CONTA c
WHERE EXISTS (SELECT *
        	  FROM PUBLICACOES p JOIN POSTS po ON po.id_publicacao = p.id_publicacao
			  WHERE p.id_conta = c.id_conta)
AND EXISTS   (SELECT *
        	  FROM PUBLICACOES p JOIN STORIES s ON s.id_publicacao = p.id_publicacao
			  WHERE p.id_conta = c.id_conta)
AND EXISTS   (SELECT *
        	  FROM PUBLICACOES p JOIN REELS r ON r.id_publicacao = p.id_publicacao
			  WHERE p.id_conta = c.id_conta);

--=======================================================================================================================
-- SUMARIO PARA REQUISITOS
--=======================================================================================================================

--=============
-- A. devem ser usadas tabelas correspondentes a pelo menos 7 entidades diferentes, e 7 relacionamentos distintos do DER

-- ENTIDADES USADAS NAS CONSULTAS:
-- 1. CRIADOR_DE_CONTEUDO - CONSULTAS 1,3,4,5
-- 2. PUBLICAÇÃO - CONSULTAS 1,2,3,4,6,7,8
-- 3. MIDIA - CONSULTA 6
-- 4. CONTA - CONSULTAS 1,2,3,4,5,6,7,8
-- 5. POST - CONSULTAS 7,8
-- 6. STORY - CONSULTAS 7,8
-- 7. REELS - CONSULTAS 7,8

-- RELACIONAMENTOS USADOS NAS CONSULTAS:
-- 1. VISUALIZAR(CRIADOR_DE_CONTEUDO-PERFIL) - CONSULTA 5
-- 2. INTEGRAR(PERFIS-PUBLICACACOES) - CONSULTA 6
-- 3. CONTER(PUBLICACOES-MIDIAS)  - CONSULTA 6
-- 4. POSSUIR(PERFIS-CONTAS) - CONSULTA 6
-- 5. COMENTAR(PUBLICACAO-CONTA) - CONSULTAS 1,2,3,7
-- 6. CURTIR(PUBLICACAO-CONTA) - CONSULTAS 1,4,7
-- 7. CRIAR(PUBLICACAO-CONTA) - CONSULTAS 7,8

--=============
-- B. Todas consultas possuem no minimo 3 tabelas

--=============
-- C. No mínimo três consultas devem necessitar serem respondidas com a cláusula group by, pelo menos uma deve incluir também a cláusula Having.
-- 1. CONSULTA 1 - GROUP BY
-- 2. CONSULTA 7 - GROUP BY HAVING
-- 3. CONSULTA 8 - 

--=============
-- D. No mínimo duas consultas (diferente das consultas acima) devem necessitar serem respondidas com subconsulta
-- 1. CONSULTA 2
-- 2. CONSULTA 9 

--=============
-- E. No mínimo uma delas (diferente de todas consultas acima) deve representar uma consulta do tipo TODOS ou NENHUM que <referencia>
-- 1. CONSULTA 4

--=============
-- F. No mínimos duas consultas devem utilizar a visão definida no item 2.a.
-- 1. CONSULTA 1 - CONTAS_CRIADORES
-- 2. CONSULTA 3 - CONTAS_CRIADORES
-- 3. CONSULTA 4 - CONTAS_CRIADORES
-- 4. CONSULTA 5 - CONTAS_PERFIS E CONTAS_CRIADORES
-- 5. CONSULTA 6 - CONTAS_PERFIS

--=============
-- G. Sua base de dados deve estar populada de forma a retornar resultados para todas consultas. Recomenda-se que
--  as instâncias sejam pensadas para testar se as consultas estão corretas, abrangendo vários cenários.