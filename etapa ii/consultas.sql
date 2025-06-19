-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                  CRIAÇÃO DE VISÕES
-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Essa visão agrega informações sobre publicações, incluindo o número total de visualizações, comentários e
-- curtidas, permitindo consultas mais eficientes sobre o desempenho das publicações.  
CREATE OR REPLACE VIEW INFO_PUBLICACOES AS
SELECT p.id_publicacao, p.data_publicacao, p.descricao,
       COUNT(DISTINCT v.id_conta) AS total_visualizacoes,
       COUNT(DISTINCT c.id_comentario) AS total_comentarios,
       COUNT(DISTINCT curt.id_curtida) AS total_curtidas
FROM PUBLICACOES p
LEFT JOIN VISUALIZACOES v ON p.id_publicacao = v.id_publicacao
LEFT JOIN COMENTARIOS c ON p.id_publicacao = c.id_publicacao
LEFT JOIN CURTIDAS curt ON p.id_publicacao = curt.id_publicacao
GROUP BY p.id_publicacao, p.data_publicacao, p.descricao;

SELECT * FROM INFO_PUBLICACOES;

-- Essa visão pega informações sobre os criadores de conteúdo, incluindo o número total de interações e visualizações
-- de perfil, permitindo uma análise mais eficiente do desempenho dos criadores.
CREATE OR REPLACE VIEW INFO_CRIADORES_DE_CONTEUDO AS
SELECT cc.id_criador, cc.id_conta, c.nome_usuario, cc.interacao, cc.visualizacoes_do_perfil
FROM CRIADORES_DE_CONTEUDO cc JOIN CONTAS c ON cc.id_conta = c.id_conta;

-- drop view INFO_CRIADORES_DE_CONTEUDO;
-- select * from INFO_CRIADORES_DE_CONTEUDO;

-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                  CONSULTAS
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- Consulta usando GROUP BY
-- Para cada usuário, a quantidade de comentários foram feitos em todas as publicações dele.
SELECT 
    c.nome_usuario,
    COUNT(co.id_comentario) AS total_comentarios_suas_publicacoes
FROM CONTAS c JOIN PUBLICACOES p ON c.id_conta = p.id_conta
LEFT JOIN COMENTARIOS co ON p.id_publicacao = co.id_publicacao
GROUP BY c.nome_usuario; 

-- Consulta usando subconsulta que não possa ser substituída por JOIN
-- Nome dos usuários que tenham pelo menos uma publicação que contenha pelo menos um comentário da usuária "maria_dev".
-- 		Essa subconsulta não pode ser substituída apenas por JOIN, pois contém EXISTS duplamente aninhado para garantir a 
--		existência das duas condições sem precisar de agregação e poderia haver duplicações e para que não houvesse
--		seria necessário usar DISTINCT e/ou outros filtros.
SELECT c.nome_usuario
FROM CONTAS c
WHERE EXISTS (SELECT * 
			  FROM PUBLICACOES p 
			  WHERE p.id_conta = c.id_conta AND EXISTS (SELECT * 
			  											FROM COMENTARIOS co JOIN CONTAS c2 ON co.id_conta = c2.id_conta 
														WHERE co.id_publicacao = p.id_publicacao AND c2.nome_usuario = 'maria_dev'));

-- Consulta usando visão INFO_CRIADORES_DE_CONTEUDO
-- Nome dos usuários, total de publicações que fez e total de comentários que recebeu em suas publicações

SELECT ic.nome_usuario, COUNT(DISTINCT p.id_publicacao) AS total_publicacoes, COUNT(co.id_comentario) AS total_comentarios
FROM INFO_CRIADORES_DE_CONTEUDO ic JOIN PUBLICACOES p ON p.id_conta = ic.id_conta 
								   JOIN COMENTARIOS co ON co.id_publicacao = p.id_publicacao
GROUP BY ic.nome_usuario;

-- Consulta usando TODOS que
-- Nome dos usuários que possuem comentários em TODAS as suas publicações, excluindo aqueles que não possuem publicações
SELECT c.nome_usuario
FROM CONTAS c
WHERE EXISTS 
(SELECT * 
 FROM PUBLICACOES p 
 WHERE p.id_conta = c.id_conta) AND NOT EXISTS 
 (SELECT *
  FROM PUBLICACOES p
  WHERE p.id_conta = c.id_conta AND NOT EXISTS 
  (SELECT * FROM COMENTARIOS co
   WHERE co.id_publicacao = p.id_publicacao));
