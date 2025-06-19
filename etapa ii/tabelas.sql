-- CRIAÇÃO DE VISÕES
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


-- CRIAÇÃO DAS TABELAS DA APLICAÇÃO INSTAGRADO
-- OBS: 
--     - Foi usado SERIAL para as id's para gerar automaticamente
--       id's incrementadas



-- Tabela: CONTAS
CREATE TABLE CONTAS (
    id_conta SERIAL PRIMARY KEY,    
    nome_usuario VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: CRIADORES_DE_CONTEUDO
CREATE TABLE CRIADORES_DE_CONTEUDO (
    id_criador SERIAL PRIMARY KEY,
    id_conta INT UNIQUE NOT NULL,
    interacao INT,  
    visualizacoes_do_perfil INT,                               
    FOREIGN KEY (id_conta) REFERENCES CONTA(id_conta)
);

-- Tabela: PERFIS
CREATE TABLE PERFIS (
    id_perfil SERIAL PRIMARY KEY,
    id_conta INT UNIQUE NOT NULL,
    descricao TEXT,
    FOREIGN KEY (id_conta) REFERENCES CONTA(id_conta)
);

-- Tabela: PUBLICACOES
CREATE TABLE PUBLICACOES (
    id_publicacao SERIAL PRIMARY KEY,
    id_conta INT NOT NULL,
    data_publicacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descricao TEXT,
    FOREIGN KEY (id_conta) REFERENCES CONTAS(id_conta)
);

-- Tabela: POSTS
CREATE TABLE POSTS (
    id_post SERIAL PRIMARY KEY,
    id_publicacao INT UNIQUE NOT NULL,
    privado BOOLEAN,
    FOREIGN KEY (id_publicacao) REFERENCES PUBLICACAO(id_publicacao)
);

-- Tabela: STORIES
CREATE TABLE STORIES (
    id_story SERIAL PRIMARY KEY,
    id_publicacao INT UNIQUE NOT NULL,
    tempo_expiracao TIME,                               -- COMO GARANTIR AS 24 HORAS??
    FOREIGN KEY (id_publicacao) REFERENCES PUBLICACAO(id_publicacao)
);

-- Tabela: REELS
CREATE TABLE REELS (
    id_reels SERIAL PRIMARY KEY,
    id_publicacao INT UNIQUE NOT NULL,
    duracao INT,
    FOREIGN KEY (id_publicacao) REFERENCES PUBLICACAO(id_publicacao)
);

-- Tabela: MÍDIAS
CREATE TABLE MIDIAS (
    id_midia SERIAL PRIMARY KEY,
    id_publicacao INT NOT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('FOTO', 'VIDEO')), -- DÚVIDA SOBRE SE VAMOS FAZER ASSIM
    extensao VARCHAR(20),
    nome_conteudo VARCHAR(200),
    conteudo BYTEA NOT NULL,
    (nome_conteudo,extensao) UNIQUE,                    -- NAO LEMBRO COMO FAZ ISSO
    FOREIGN KEY (id_publicacao) REFERENCES PUBLICACAO(id_publicacao)
);

-- Tabela: MENSAGEM
CREATE TABLE MENSAGENS (
    id_mensagem SERIAL PRIMARY KEY,
    id_remetente INT NOT NULL,
    id_destinatario INT NOT NULL,
    conteudo TEXT NOT NULL,
    data_msg TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_remetente) REFERENCES CONTA(id_conta),
    FOREIGN KEY (id_destinatario) REFERENCES CONTA(id_conta)
);

-- Tabela: VISUALIZACOES
CREATE TABLE VISUALIZACOES (
    id_visualizacao SERIAL PRIMARY KEY,
    id_publicacao INT NOT NULL,
    id_conta INT NOT NULL,
    FOREIGN KEY (id_publicacao) REFERENCES PUBLICACAO(id_publicacao),
    FOREIGN KEY (id_conta) REFERENCES CONTA(id_conta)
);

-- Tabela: CURTIDAS
CREATE TABLE CURTIDAS (
    id_curtida SERIAL PRIMARY KEY,
    id_publicacao INT NOT NULL,
    id_conta INT NOT NULL,
    FOREIGN KEY (id_publicacao) REFERENCES PUBLICACAO(id_publicacao),
    FOREIGN KEY (id_conta) REFERENCES CONTA(id_conta)
);

-- Tabela: COMENTARIOS
CREATE TABLE COMENTARIOS (
    id_comentario SERIAL PRIMARY KEY,
    id_publicacao INT NOT NULL,
    id_conta INT NOT NULL,
    conteudo TEXT NOT NULL,
    data_comentario TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_publicacao) REFERENCES PUBLICACAO(id_publicacao),
    FOREIGN KEY (id_conta) REFERENCES CONTA(id_conta)
);
