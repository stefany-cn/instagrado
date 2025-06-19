-- ===================================================
-- DADOS DE EXEMPLO PARA A APLICAÇÃO INSTAGRADO
-- ===================================================

-- CONTAS
INSERT INTO CONTAS(nome_usuario, email) VALUES
('joao123', 'joao@example.com'),
('maria_dev', 'maria@example.com'),
('lucas_fotos', 'lucas@example.com'),
('ana_influencer', 'ana@example.com'),
('bruno_gamer', 'bruno@example.com'),
('carla_fit', 'carla@example.com'),
('dani_food', 'dani@example.com'),
('edu_musica', 'edu@example.com'),
('felipe_viaja', 'felipe@example.com'),
('giovanna_art', 'giovanna@example.com');

-- CRIADORES_DE_CONTEUDO
INSERT INTO CRIADORES_DE_CONTEUDO (id_conta, interacao, visualizacoes_do_perfil) VALUES
(1, 500, 1200),
(2, 1500, 3500),
(4, 2500, 7000),
(5, 800, 2000),
(6, 1100, 2800),
(7, 1300, 3000);

-- PERFIS
INSERT INTO PERFIS (id_conta, descricao) VALUES
(1, 'Fotos de natureza e viagens.'),
(2, 'Desenvolvedora full stack.'),
(3, 'Fotógrafo amador.'),
(4, 'Lifestyle, moda e beleza.'),
(5, 'Streamer de jogos.'),
(6, 'Dicas de fitness e saúde.'),
(7, 'Receitas rápidas e fáceis.'),
(8, 'Músico independente.'),
(9, 'Aventuras pelo mundo.'),
(10, 'Arte e ilustração.');

-- PUBLICACOES
INSERT INTO PUBLICACOES (id_conta, descricao) VALUES
(1, 'Pôr do sol incrível na praia!'), --1
(2, 'Lançando meu novo projeto open source.'), --2
(3, 'Foto da cachoeira escondida.'), --3
(4, 'Maquiagem para o verão.'), --4
(5, 'Jogando o novo lançamento de FPS!'), --5
(6, 'Treino de pernas hoje!'), --6
(7, 'Receita de bolo de cenoura.'), --7
(8, 'Nova música disponível no Spotify!'), --8
(9, 'Dicas para viajar gastando pouco.'), --9
(10, 'Ilustração digital finalizada.'), --10
(4, 'Morning routine ☀️'), --11
(6, 'Desafio de 30 dias de abdominal!'), --12
(9, 'Top 5 destinos para 2025.'), --13
(7, 'Smoothie saudável para o café.'), --14
(2, 'Como fazer deploy no Heroku.' ); --15

-- POSTS
INSERT INTO POSTS (id_publicacao, privado) VALUES
(1, FALSE),
(2, FALSE),
(3, TRUE),
(4, FALSE),
(5, TRUE),
(6, FALSE),
(7, FALSE);

-- STORIES
INSERT INTO STORIES (id_publicacao, tempo_expiracao) VALUES
(8, '24:00:00'),
(9, '24:00:00'),
(10, '24:00:00'),
(11, '24:00:00');

-- REELS
INSERT INTO REELS (id_publicacao, duracao) VALUES
(12, 60),
(13, 45),
(14, 30),
(15, 90);

-- MIDIAS (dummy binário usando decode como exemplo)
INSERT INTO MIDIAS (id_publicacao, tipo, extensao, nome_conteudo, conteudo) VALUES
(1, 'FOTO', 'jpg', 'por_do_sol', decode('FFD8FFE0', 'hex')),
(2, 'FOTO', 'png', 'projeto', decode('89504E47', 'hex')),
(3, 'FOTO', 'jpg', 'cachoeira', decode('FFD8FFE0', 'hex')),
(4, 'FOTO', 'jpg', 'maquiagem_verao', decode('FFD8FFE0', 'hex')),
(5, 'VIDEO', 'mp4', 'gameplay', decode('00000020', 'hex')),
(6, 'FOTO', 'jpg', 'treino_pernas', decode('FFD8FFE0', 'hex')),
(7, 'FOTO', 'png', 'bolo_cenoura', decode('89504E47', 'hex')),
(8, 'VIDEO', 'mp4', 'musica_spotify', decode('00000020', 'hex')),
(9, 'FOTO', 'jpg', 'viagem_economica', decode('FFD8FFE0', 'hex')),
(10, 'FOTO', 'png', 'ilustracao', decode('89504E47', 'hex')),
(11, 'FOTO', 'jpg', 'morning_routine', decode('FFD8FFE0', 'hex')),
(12, 'VIDEO', 'mp4', 'desafio_abdominal', decode('00000020', 'hex')),
(13, 'FOTO', 'jpg', 'destinos_2025', decode('FFD8FFE0', 'hex')),
(14, 'FOTO', 'png', 'smoothie', decode('89504E47', 'hex')),
(15, 'FOTO', 'jpg', 'deploy_heroku', decode('FFD8FFE0', 'hex'));

-- MENSAGENS
INSERT INTO MENSAGENS (id_remetente, id_destinatario, conteudo) VALUES
(1, 2, 'Maria, adorei seu projeto!'),
(3, 1, 'João, onde foi essa foto?'),
(4, 6, 'Parabéns pelos resultados no treino!'),
(5, 2, 'Quer jogar hoje à noite?'),
(7, 8, 'Sua música tá incrível!'),
(9, 10, 'Amei sua última arte!'),
(2, 4, 'Adorei o vídeo de maquiagem.'),
(3, 7, 'Vou testar essa receita.'),
(8, 5, 'Top sua gameplay!'),
(6, 1, 'Me ensina a tirar fotos assim!');

-- VISUALIZACOES
INSERT INTO VISUALIZACOES (id_publicacao, id_conta) VALUES
(1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
(2, 1), (2, 4), (2, 5), (2, 7), (2, 8),
(8, 1), (8, 2), (8, 3), (8, 4), (8, 5), (8, 6), (8, 7), (8, 8), (8, 9), (8, 10),
(12, 1), (12, 2), (12, 3), (12, 4), (12, 5), (12, 6), (12, 7), (12, 8), (12, 9), (12, 10),
(13, 1), (13, 2), (13, 3), (13, 4), (13, 5), (13, 6), (13, 7), (13, 8), (13, 9), (13, 10);

-- CURTIDAS
INSERT INTO CURTIDAS (id_publicacao, id_conta) VALUES
(1, 2), (1, 3), (1, 4), (1, 5),
(2, 1), (2, 3), (2, 4),
(5, 6), (5, 7),
(8, 1), (8, 2), (8, 3), (8, 4), (8, 5), (8, 6),
(12, 7), (12, 8), (12, 9), (12, 10),
(13, 1), (13, 2), (13, 3), (13, 4),
(14, 5), (14, 6), (14, 7), (14, 8),
(15, 9), (15, 10);

-- COMENTARIOS
INSERT INTO COMENTARIOS (id_publicacao, id_conta, conteudo) VALUES
(1, 2, 'Incrível!'),
(1, 3, 'Maravilhoso lugar!'),
(2, 1, 'Ótima iniciativa!'),
(4, 6, 'Que linda make!'),
(5, 7, 'GG!'),
(8, 3, 'Adorei a música!'),
(12, 5, 'Já comecei o desafio!'),
(13, 4, 'Quero visitar todos esses lugares!'),
(14, 8, 'Vou fazer amanhã!'),
(15, 2, 'Tutorial top!');

