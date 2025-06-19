-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                                  CONSULTAS
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- "Encontrar todas as publicações que possuem mais comentários do que visualizações."
--          Essa consulta simula uma análise para identificar "conteúdo que está gerando uma quantidade 
--          de discussão desproporcionalmente alta em relação ao número de visualizações", possivelmente 
--          indicando que o post está viralizando por meio de compartilhamentos ou por ser polêmico.
SELECT p.id_publicacao, p.descricao
FROM PUBLICACOES p
WHERE (
    SELECT COUNT(*)
    FROM COMENTARIOS c
    WHERE c.id_publicacao = p.id_publicacao
) > (
    SELECT COUNT(*)
    FROM VISUALIZACOES v
    WHERE v.id_publicacao = p.id_publicacao
);
-- "Encontrar todos os criadores de conteúdo que possuem mais de 1000 visualizações."
--          Essa consulta identifica criadores de conteúdo que estão alcançando um grande público,
--          o que pode ser um indicador de popularidade ou relevância na plataforma.
SELECT cc.id_criador, cc.interacao, cc.visualizacoes
FROM CRIADORES_DE_CONTEUDO cc
WHERE cc.visualizacoes > 1000;  