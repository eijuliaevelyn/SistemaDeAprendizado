CREATE DATABASE SistemaDeAprendizagem
GO 
USE SistemaDeAprendizagem

-- Criação da tabela Tipo Usuário.
CREATE TABLE TipoUsuario(
	Id TINYINT PRIMARY KEY IDENTITY,
	TipoUsuario VARCHAR (30) NOT NULL
);

-- Criação da tabela Usuário.
CREATE TABLE Usuario(
	Id INT PRIMARY KEY IDENTITY,
	IdTipoUsuario TINYINT NOT NULL,
	NomeCompleto VARCHAR (180) NOT NULL,
	DataNascimento DATE NOT NULL,
	Idade TINYINT NULL,
	CPF VARCHAR (15) NOT NULL,
	Email VARCHAR (255) NOT NULL,
	Senha VARCHAR(64) NOT NULL,
	Ativo BIT NOT NULL DEFAULT 0,
	FOREIGN KEY (IdTipoUsuario) REFERENCES TipoUsuario (Id)
);

-- Criação da tabela Telefone.
CREATE TABLE Telefone(
	Id INT PRIMARY KEY IDENTITY,
	IdUsuario INT NOT NULL,
	DDD SMALLINT NOT NULL,
	Numero INT NOT NULL,
	WhatsApp BIT NOT NULL DEFAULT 0,
	FOREIGN KEY (IdUsuario) REFERENCES Usuario (Id)
);

-- Criação da tabela Estado.
CREATE TABLE Estado(
	Id SMALLINT PRIMARY KEY IDENTITY,
	NomeEstado VARCHAR (60) NOT NULL,
	Sigla VARCHAR (5) NOT NULL
);

-- Criação da tabela Cidade.
CREATE TABLE Cidade(
	Id SMALLINT PRIMARY KEY IDENTITY,
	IdEstado SMALLINT NOT NULL,
	NomeCidade VARCHAR (100) NOT NULL,
	FOREIGN KEY (IdEstado) REFERENCES Estado (Id)
);

-- Criação da tabela Endereço.
CREATE TABLE Endereco(
	Id INT PRIMARY KEY IDENTITY,
	IdUsuario INT NOT NULL,
	IdCidade SMALLINT NOT NULL,
	Logradouro VARCHAR (100) NOT NULL,
	Numero VARCHAR (5) NOT NULL,
	Bairro VARCHAR (80) NOT NULL,
	Complemento VARCHAR (35) NULL,
	PontoDeReferencia VARCHAR (45) NULL,
	FOREIGN KEY (IdUsuario) REFERENCES Usuario (Id),
	FOREIGN KEY (IdCidade) REFERENCES Cidade (Id)
);

-- Criação da tabela Autenticação.
CREATE TABLE Autenticacao(
	Id INT PRIMARY KEY IDENTITY,
	IdUsuario INT NOT NULL,
	DataHoraAutenticacao DATETIME NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (IdUsuario) REFERENCES Usuario (Id)
);

-- Criação da tabela Curso.
CREATE TABLE Curso(
	Id INT PRIMARY KEY IDENTITY,
	NomeCurso VARCHAR (60) NOT NULL,
	DescricaoCurso VARCHAR (100) NOT NULL,
	DuracaoCursoMes SMALLINT NOT NULL,
	ValorCurso DECIMAL (10, 2) NOT NULL
);

-- Criação da tabela Módulo.
CREATE TABLE Modulo(
	Id INT PRIMARY KEY IDENTITY,
	IdCurso INT NOT NULL,
	NomeModulo VARCHAR (50) NOT NULL,
	DescricaoModulo VARCHAR (100) NOT NULL,
	NivelDificuldade VARCHAR (30) NOT NULL,
	Concluido BIT NOT NULL DEFAULT 0,
	FOREIGN KEY (IdCurso) REFERENCES Curso (Id)
);

-- Criação da tabela Atividade.
CREATE TABLE Atividade(
	Id INT PRIMARY KEY IDENTITY,
	IdModulo INT NOT NULL,
	NomeAtividade VARCHAR (50) NOT NULL,
	DescricaoAtividade VARCHAR (120) NOT NULL,
	DataInicio DATE NOT NULL,
	DataTermino DATE NOT NULL,
	NivelDificuldade VARCHAR (30) NOT NULL,
	FOREIGN KEY (IdModulo) REFERENCES Modulo (Id)
);

-- Criação da tabela Recurso Adicional.
CREATE TABLE RecursoAdicional(
	Id INT PRIMARY KEY IDENTITY,
	IdCurso INT NOT NULL,
	NomeRercuso VARCHAR (60) NOT NULL,
	TipoRecurso VARCHAR (30) NOT NULL,
	DescricaoRecurso VARCHAR (120) NOT NULL,
	FOREIGN KEY (IdCurso) REFERENCES Curso (Id)
);

-- Criação da tabela Progresso Curso.
CREATE TABLE ProgressoCurso(
	Id INT PRIMARY KEY IDENTITY,
	IdUsuario INT NOT NULL,
	IdCurso INT NOT NULL,
	Progresso FLOAT NOT NULL,
	FeedbackProfessor VARCHAR (100) NULL,
	AvaliacaoDesempenho TINYINT NULL,
	DataUltimaAvaliacao DATE NULL,
	FOREIGN KEY (IdUsuario) REFERENCES Usuario (Id),
	FOREIGN KEY (IdCurso) REFERENCES Curso (Id)
);

-- Criação da tabela Modalidade Turma.
CREATE TABLE ModalidadeTurma(
	Id TINYINT PRIMARY KEY IDENTITY,
	ModalidadeTurma VARCHAR (20) NOT NULL
);

-- Criação da tabela Turma.
CREATE TABLE Turma(
	Id INT PRIMARY KEY IDENTITY,
	IdModalidadeTurma TINYINT NOT NULL,
	IdUsuarioProfessor INT NOT NULL,
	IdCurso INT NOT NULL,
	CapacidadeTurma TINYINT NOT NULL,
	FOREIGN KEY (IdModalidadeTurma) REFERENCES ModalidadeTurma (Id),
	FOREIGN KEY (IdUsuarioProfessor) REFERENCES Usuario (Id),
	FOREIGN KEY (IdCurso) REFERENCES Curso (Id)
);

-- Criação da tabela Turma Aluno.
CREATE TABLE TurmaAluno(
	IdTurma INT NOT NULL,
	IdUsuarioAluno INT NOT NULL,
	PRIMARY KEY (IdTurma, IdUsuarioAluno),
	FOREIGN KEY (IdTurma) REFERENCES Turma (Id),
	FOREIGN KEY (IdUsuarioAluno) REFERENCES Usuario (Id)
);

-- Criação da tabela Metôdo Pagamento.
CREATE TABLE MetodoPagamento(
	Id TINYINT PRIMARY KEY IDENTITY,
	MetodoPagamento VARCHAR (30)
);

-- Criação da tabela Cartão.
CREATE TABLE Cartao(
	Id INT PRIMARY KEY IDENTITY,
	NomeTitular VARCHAR (150) NOT NULL,
	NumeroCartao BIGINT NOT NULL,
	CVV SMALLINT NOT NULL,
	Bandeira VARCHAR (20) NOT NULL,
	MesVencimetno TINYINT NOT NULL,
	AnoVencimento SMALLINT NOT NULL
);

-- Criação da tabela Pagamento.
CREATE TABLE Pagamento(
	Id INT PRIMARY KEY IDENTITY,
	IdMetodoPagamento TINYINT NOT NULL,
	IdCartao INT NULL,
	Parcelado BIT NOT NULL,
	QuantidadeParcela TINYINT NOT NULL,
	ValorTotal DECIMAL (15, 2) NULL,
	DataPagamento DATE NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (IdMetodoPagamento) REFERENCES MetodoPagamento (Id),
	FOREIGN KEY (IdCartao) REFERENCES Cartao (Id)
);

-- Criação da tabela Parcela.
CREATE TABLE Parcela(
	Id INT PRIMARY KEY IDENTITY,
	IdPagamento INT NOT NULL,
	ValorParcela DECIMAL (10, 2) NULL,
	DataPagamentoParcela DATE NOT NULL,
	Pago BIT NOT NULL DEFAULT 0,
	DataPagamentoRealizado DATE NULL,
	FOREIGN KEY (IdPagamento) REFERENCES Pagamento (Id)
);

-- Criação da tabela Tipo Assinatura.
CREATE TABLE TipoAssinatura(
	Id TINYINT PRIMARY KEY IDENTITY,
	TipoAssinatura VARCHAR (30) NOT NULL,
	DescricaoTipo VARCHAR (50) NOT NULL,
	TaxaAssinatura DECIMAL (5, 2) NOT NULL
);

-- Criação da tabela Assinatura.
CREATE TABLE Assinatura(
	Id INT PRIMARY KEY IDENTITY,
	IdTipoAssinatura TINYINT NOT NULL,
	IdUsuario INT NOT NULL,
	IdPagamento INT NOT NULL,
	ValorTotal DECIMAL (15, 2) NULL,
	FOREIGN KEY (IdTipoAssinatura) REFERENCES TipoAssinatura (Id),
	FOREIGN KEY (IdUsuario) REFERENCES Usuario (Id),
	FOREIGN KEY (IdPagamento) REFERENCES Pagamento (Id)
);

-- Criação da tabela Assinatura Curso.
CREATE TABLE AssinaturaCurso(
	IdAssinatura INT NOT NULL,
	IdCurso INT NOT NULL,
	PRIMARY KEY (IdAssinatura, IdCurso),
	FOREIGN KEY (IdAssinatura) REFERENCES Assinatura (Id),
	FOREIGN KEY (IdCurso) REFERENCES Curso (Id)
);
	
-- Criação da tabela Controle Assinatura.
CREATE TABLE ControleAssinatura(
	Id INT PRIMARY KEY IDENTITY,
	IdCurso INT NOT NULL,
	TotalDeAssinatura INT NOT NULL,
	AssinaturaPorDia SMALLINT NULL,
	DataAtualizacao DATE NULL,
	FOREIGN KEY (IdCurso) REFERENCES Curso (Id)
);

-- Criação da tabela Mensagem.
CREATE TABLE Mensagem(
	Id INT PRIMARY KEY IDENTITY,
	IdUsuarioAutor INT NOT NULL,
	IdUsuarioReceptor INT NOT NULL,
	Mensagem TEXT NOT NULL,
	DataMensagem DATE NOT NULL DEFAULT GETDATE(),
	HoraMensagem TIME NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (IdUsuarioAutor) REFERENCES Usuario (Id),
	FOREIGN KEY (IdUsuarioReceptor) REFERENCES Usuario (Id)
);

-- Criação da tabela Forúm.
CREATE TABLE Forum(
	Id INT PRIMARY KEY IDENTITY,
	IdMensagem INT NOT NULL,
	TopicoForum VARCHAR (70) NOT NULL,
	DataCriacaoForum DATE NOT NULL DEFAULT GETDATE(),
	FOREIGN KEY (IdMensagem) REFERENCES Mensagem (Id)
);