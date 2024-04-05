--
INSERT INTO TipoUsuario (Tipousuario)
	VALUES	('Administrador'),
			('Aluno'),
			('Professor') 

INSERT INTO Estado (NomeEstado, Sigla)
	VALUES	('Paraíba', 'PB'),
			('Ceará', 'CE'),
			('Pernambuco', 'PE'),
			('Bahia', 'BA'),
			('Sergipe', 'SE'),
			('Alagoas', 'AL'),
			('Rio Grande do Norte', 'RN'),
			('Piauí', 'PI'),
			('Maranhão', 'MA'),
			('Tocantins', 'TO'),
			('Pará', 'PA'),
			('Amapá', 'AP'),
			('Amazonas', 'AM'),
			('Roraima', 'RR'),
			('Acre', 'AC'),
			('Rondônia', 'RO'),
			('Goiás', 'GO'),
			('Mato Grosso', 'MT'),
			('Distrito Federal', 'DF'),
			('Minas Gerais', 'MG'),
			('Espírito Santo', 'ES'),
			('Rio de Janeiro', 'RJ'),
			('São Paulo', 'SP'),
			('Paraná', 'PR'),
			('Santa Catarina', 'SC'),
			('Rio Grande do Sul', 'RS'),
			('Mato Grosso do Sul', 'MS')

INSERT INTO Cidade (IdEstado, NomeCidade)
	VALUES	(1, 'João Pessoa'),
			(2, 'Fortaleza'),
			(3, 'Recife'),
			(4, 'Salvador'),
			(5, 'Aracaju'),
			(6, 'Maceió'),
			(7, 'Natal'),
			(8, 'Teresina'),
			(9, 'São Luís'),
			(10, 'Palmas'),
			(11, 'Belém'),
			(12, 'Macapá'),
			(13, 'Manaus'),
			(14, 'Boa Vista'),
			(15, 'Rio Branco'),
			(16, 'Porto Velho'),
			(17, 'Goiânia'),
			(18, 'Cuiabá'),
			(19, 'Brasília'),
			(20, 'Belo Horizonte'),
			(21, 'Vitória'),
			(22, 'Rio de Janeiro'),
			(23, 'São Paulo'),
			(24, 'Curitiba'),
			(25, 'Florianópolis'),
			(26, 'Porto Alegre'),
			(27, 'Campo Grande')

INSERT INTO ModalidadeTurma (ModalidadeTurma)
	VALUES	('EAD'),
			('Presencial')

INSERT INTO MetodoPagamento (MetodoPagamento)
	VALUES	('Pix'),
			('Cartão')

INSERT INTO TipoAssinatura(MetodoPagamento)
	VALUES	('Básica', 'Assinatura Básica', 0.00),
			('Intermediária', 'Assinatura Intermediária', 9.99),
			('Avançada', 'Assinatura Avançada', 19.99)

-- Inserindo dados na tabela Curso
INSERT INTO Curso (NomeCurso, DescricaoCurso, DuracaoCursoMes, ValorCurso)
VALUES 
('Curso de Gramática', 'Curso completo de gramática da língua portuguesa', 6, 500.00),
('Curso de Vocabulário', 'Curso completo de vocabulário em língua portuguesa', 6, 500.00),
('Curso de Compreensão Auditiva', 'Curso completo de compreensão auditiva em língua portuguesa', 6, 500.00),
('Curso de Expressão Escrita', 'Curso completo de expressão escrita em língua portuguesa', 6, 500.00);

-- Inserindo dados na tabela RecursoAdicional
INSERT INTO RecursoAdicional (IdCurso, NomeRercuso, TipoRecurso, DescricaoRecurso)
VALUES 
(1, 'Livro de Referência de Gramática', 'Livro', 'Livro de referência abrangente para estudo adicional de gramática'),
(2, 'Aplicativo de Vocabulário', 'Aplicativo', 'Aplicativo móvel com jogos e quizzes para melhorar o vocabulário'),
(3, 'Playlist de Áudios em Português', 'Áudio', 'Playlist com uma variedade de áudios em português para prática auditiva'),
(4, 'Oficina de Escrita Criativa', 'Oficina', 'Oficina presencial ou online para aprimorar habilidades de escrita criativa');