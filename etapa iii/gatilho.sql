--     		  Universidade Federal do Rio Grande do Sul
--             	           Instituto de Informática
--       	    Departamento de Informática Aplicada
--
--      	   INF01145 Fundamentos de Banco de Dados
--                   Profa. Dra. Karin Becker - Turma A
--
--           		 TRABALHO DA DISCIPLINA
--
--    Eduardo Veiga Ferreira (578144) e Stefany Costa Nascimento (263870)

-- Procedimento/função armazenada IncVisualizacao: ==============================================
-- Este procedimento permite utilizar um atributo de visualizações para um determinado criador de conteúdo.
-- Esse atributo é incrementado sempre que uma visualização é inserida na tabela de visualizações contendo o id do criador.
-- Visualizações feitas pelo próprio criador não são válidas.

CREATE EXTENSION IF NOT EXISTS plpgsql;
DROP TRIGGER IF EXISTS Visualizou ON Visualizacoes;
DROP FUNCTION IF EXISTS IncVisualizacao();

CREATE FUNCTION IncVisualizacao()
RETURNS TRIGGER AS $$
DECLARE
    conta_criador INT;
    conta_perfil INT;
BEGIN
    -- Busca o id_conta do criador de conteúdo
    SELECT id_conta INTO conta_criador FROM CRIADORES_DE_CONTEUDO WHERE id_criador = NEW.id_criador;
    -- Busca o id_conta do perfil que realizou a visualização
    SELECT id_conta INTO conta_perfil FROM PERFIS WHERE id_perfil = NEW.id_perfil;

    -- Só incrementa se ambos existirem e não forem a mesma conta (visualização própria não conta)
    IF conta_criador IS NOT NULL AND conta_perfil IS NOT NULL AND conta_criador <> conta_perfil THEN
        UPDATE CRIADORES_DE_CONTEUDO
        SET visualizacoes_do_perfil = visualizacoes_do_perfil + 1
        WHERE id_criador = NEW.id_criador;
    END IF;

    -- Para gatilhos do tipo AFTER, o valor de retorno é ignorado,
    -- mas é necessário retornar um valor. Retornar NEW é uma prática comum.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Gatilho Visualizou: ====================================================
-- Este gatilho é acionado após qualquer inserção de uma instância de visualização,
-- chamando o procedimento IncVisualizacao para contabilizar a visualização corretamente.
CREATE TRIGGER Visualizou
AFTER INSERT ON Visualizacoes
FOR EACH ROW
EXECUTE FUNCTION IncVisualizacao();

-- Testes =========================================
select * from CRIADORES_DE_CONTEUDO
INSERT INTO Visualizacoes values (30,2,5)