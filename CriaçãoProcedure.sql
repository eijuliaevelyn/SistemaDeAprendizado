
-- Criação de procedure de insert na tabela Usuário.
CREATE OR ALTER PROC [dbo].[SP_CriarUsuario](
	@IdTipoUsuario TINYINT,
	@NomeCompleto VARCHAR (180),
	@DataNascimento DATE,
	@CPF VARCHAR (15),
	@Email VARCHAR (255),
	@Senha VARCHAR (64)
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Criar um novo usuário.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_CriarUsuario] 
						SELECT * FROM Usuario
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @ValidarEmail TINYINT

		-- Setando valor para variável @ValidarEmail.
		SET @ValidarEmail = [dbo].[FNCValidarEmail](@Email)

		-- Verificando se o usuário já foi inserido.
		IF EXISTS (SELECT Id
						FROM Usuario
							WHERE Email = @Email OR CPF = @CPF)

			-- Mensagem de erro.
			THROW 50002, 'Usuário já cadastrado no sistema.', 1;

		-- Verificando se o Tipo de usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM TipoUsuario
								WHERE Id = @IdTipoUsuario)

			-- Mensagem de erro.
			THROW 50002, 'Tipo de usuário inexistente.', 1;

		-- Validando a data de nascimento.
		IF @DataNascimento > GETDATE()

			-- Mensagem de erro.
			THROW 50002, 'Data de nascimento inválida.', 1;

		-- Validando o formato do CPF.
		IF @CPF NOT LIKE '[0-9][0-9][0-9].[0-9][0-9][0-9].[0-9][0-9][0-9]-[0-9][0-9]'

			-- Mensagem de erro.
			THROW 50002, 'Formato do CPF inválido.', 1;

		-- Validando senha.
		IF LEN(@Senha) < 8 

			-- Mensagem de erro.
			THROW 50002, 'A senha necessita ter ao menos 8 caracteres.', 1;

		-- Verificando Email.
		IF @ValidarEmail = 1

			-- Mensagem de erro.
			THROW 50002, 'Email inválido.', 1;

		ELSE
			-- Inserindo na tabela Usuário.
			INSERT INTO Usuario (IdTipoUsuario, NomeCompleto, DataNascimento, CPF, Email, Senha)
				VALUES (@IdTipoUsuario, @NomeCompleto, @DataNascimento, @CPF, @Email, @Senha)
			BEGIN
				PRINT 'Usuário criado com sucesso! Realize o seu login/autenticação.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro na criação do usuário.', 1;
	END;

-- Criação de procedure de insert na tabela Autenticação.
CREATE OR ALTER PROC [dbo].[SP_AutenticarUsuario](
	@Email VARCHAR (255),
	@Senha VARCHAR (64)
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Realizar login e autenticar usuário.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_AutenticarUsuario] 
						SELECT * FROM Autenticacao
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @IdUsuario INT


		-- Verificando se email ou senha estão corretos.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Email = @Email OR Senha = @Senha)

			-- Mensagem de erro.
			THROW 5002, 'Email ou senha incorreto.', 1;

		-- Setando valor para variável @IdUsuario.
		SET @IdUsuario = (SELECT Id
								FROM Usuario
									WHERE Email = @Email AND Senha = @Senha)
			
		-- Inserindo na tabela Autenticação
		INSERT INTO Autenticacao (IdUsuario)
			VALUES (@IdUsuario)
		BEGIN
			PRINT 'Usuário logado e autenticado com sucesso'
		END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 5002, 'Erro ao autenticar o usuário.', 1;

	END;

-- Criação de procedure de insert na tabela Telefone.
CREATE OR ALTER PROC [dbo].[SP_RegistrarTelefone](
	@IdUsuario INT,
	@DDD SMALLINT,
	@Numero INT,
	@WhatsApp BIT
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Registrar o telefone do usuário.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_RegistrarTelefone] 
						SELECT * FROM Telefone
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuario
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuario)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE())) 

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o telefone está em uso.
		IF EXISTS (SELECT Numero
						FROM Telefone
							WHERE Numero = @Numero)

			-- Mensagem de erro.
			THROW 50002, 'Número já está em uso no nosso sistema.', 1;

		ELSE
			-- Inserindo na tabela Telefone.
			INSERT INTO Telefone (IdUsuario, DDD, Numero, WhatsApp)
				VALUES (@IdUsuario, @DDD, @Numero, @WhatsApp)
			BEGIN
				PRINT 'Telefone cadastrado com sucesso.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro no cadastro do telefone.', 1;
	END;

-- Criação de procedure de insert na tabela Endereço.
CREATE OR ALTER PROC [dbo].[SP_RegistrarEndereco](
	@IdUsuario INT,
	@IdCidade SMALLINT,
	@Logradouro VARCHAR (100),
	@Numero VARCHAR (5),
	@Bairro VARCHAR (80),
	@Complemento VARCHAR (35) = NULL,
	@PontoDeReferencia VARCHAR (45) = NULL
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Registrar o endereço do usuário.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_IniciarAssinatura]
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuario
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuario)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se a Cidade existe.
		IF NOT EXISTS (SELECT Id
							FROM Cidade
								WHERE Id = @IdCidade)

			-- Mensagem de erro.
			THROW 50002, 'Cidade inexistente.', 1;

		ELSE
			-- Inserindo na tabela Endereço.
			INSERT INTO Endereco (IdUsuario, IdCidade, Logradouro, Numero, Bairro, Complemento, PontoDeReferencia)
				VALUES (@IdUsuario, @IdCidade, @Logradouro, @Numero, @Bairro, @Complemento, @PontoDeReferencia)
			BEGIN
				PRINT 'Endereço cadastrado com sucesso.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro no cadastro do endereço.', 1;
	END;

-- Criação de procedure de insert na tabela cartão.
CREATE OR ALTER PROC [dbo].[SP_CadastrarCartao](
	@IdUsuario INT,
	@NomeTitular VARCHAR (150),
	@NumeroCartao BIGINT,
	@CVV SMALLINT,
	@Bandeira VARCHAR (20),
	@MesVencimetno TINYINT,
	@AnoVencimento SMALLINT
	)
		
	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Cadastrar Cartão.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_CadastrarCartao] 
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuario
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuario)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando o cvv.
		IF LEN(@CVV) <> 3
		
			-- Mensagem de erro.
			THROW 50002, 'CVV inválido.', 1;

		-- Verificando bandeira.
		IF @Bandeira NOT LIKE 'Visa' AND @Bandeira NOT LIKE 'MasterCard'

			-- Mensagem de erro.
			THROW 50002, 'Bandeira inválida.', 1;

		-- Verificando mês vencimento.
		IF @MesVencimetno < 1 OR @MesVencimetno > 12

			-- Mensagem de erro.
			THROW 50002, 'Mês de vencimento inválido.', 1;

		-- Inserindo na tabela cartão.
		INSERT INTO Cartao (NomeTitular, NumeroCartao, CVV, Bandeira, MesVencimetno, AnoVencimento)
			VALUES (@NomeTitular, @NumeroCartao, @CVV, @Bandeira, @MesVencimetno, @AnoVencimento);
		BEGIN
			PRINT 'Cartão cadastrado!'
		END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro no cadastro do cartão.', 1;
	END;
	

-- Criação de procedure de insert na tabela Pagamento.
CREATE OR ALTER PROC [dbo].[SP_GerarPagamento](
	@IdUsuario INT,
	@IdMetodoPagamento TINYINT,
	@IdCartao INT = NULL,
	@Parcelado BIT,
	@QuantidadeParcela TINYINT
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Cadastrar pagamento.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_GerarPagamento] 
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuario
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuario)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o Método de pagamento existe.
		IF NOT EXISTS (SELECT Id
							FROM MetodoPagamento
								WHERE Id = @IdMetodoPagamento)

			-- Mensagem de erro.
			THROW 50002, 'Método de pagamento inexistente.', 1;

		-- Verificando se o Cartão existe.
		IF @IdCartao IS NOT NULL AND NOT EXISTS (SELECT Id
													FROM Cartao
														WHERE Id = @IdCartao)

			-- Mensagem de erro.
			THROW 50002, 'Cartão não cadastrado.', 1;

		-- Verificando a quantidade de parcelas.
		IF @QuantidadeParcela < 1 OR @QuantidadeParcela > 5

		--	 Mensagem de erro.
			THROW 50002, 'Quantidade de parcelas inválida.', 1;

		-- Validando para que o método de pagamento pix não seja parcelado.
		IF (SELECT MetodoPagamento
				FROM MetodoPagamento
					WHERE Id = @IdMetodoPagamento) = 'Pix' AND @QuantidadeParcela > 1

			-- Mensagem de erro.
			THROW 50002, 'Não é possível parcelar o metódo de pagamento pix.', 1;

		-- Validando para que o método de pagamento pix não seja parcelado.
		IF (SELECT MetodoPagamento
				FROM MetodoPagamento
					WHERE Id = @IdMetodoPagamento) = 'Boleto Bancário' AND @QuantidadeParcela > 1

			-- Mensagem de erro.
			THROW 50002, 'Não é possível parcelar o metódo de pagamento boleto.', 1;

		ELSE
			-- Inserindo na tabela Pagamento.
			INSERT INTO Pagamento (IdMetodoPagamento, IdCartao, Parcelado, QuantidadeParcela)
				VALUES (@IdMetodoPagamento, @IdCartao, @Parcelado, @QuantidadeParcela)
			BEGIN
				PRINT 'Pagamento cadastrado.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro no cadastro do pagamento.', 1;
	END;

-- Criação de procedure de insert na tabela Assinatura.
CREATE OR ALTER PROC [dbo].[SP_IniciarAssinatura](
	@IdUsuario INT,
	@IdTipoAssinatura TINYINT,
	@IdPagamento INT
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Iniciar o procedimento de assinatura.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_IniciarAssinatura] 
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuario
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuario)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o Tipo de assinatura existe.
		IF NOT EXISTS (SELECT Id
							FROM TipoAssinatura
								WHERE Id = @IdTipoAssinatura)

			-- Mensagem de erro.
			THROW 50002, 'Tipo de assinatura inexistente.', 1;

		-- Verificando se o Pagamento existe.
		IF NOT EXISTS (SELECT Id
							FROM Pagamento
								WHERE Id = @IdPagamento)

			-- Mensagem de erro.
			THROW 50002, 'Pagamento inexistente.', 1;

		ELSE
			-- Inserindo na tabela Assinatura.
			INSERT INTO Assinatura (IdUsuario, IdTipoAssinatura, IdPagamento)
				VALUES (@IdUsuario, @IdTipoAssinatura, @IdPagamento)
			BEGIN
				PRINT 'Primeira etapa da assinatura concluída com sucesso. Agora, associe os cursos a assinatura.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro na iniciação da assinatura.', 1;
	END;

-- Criação de procedure de insert na tabela Assinatura Curso.
CREATE OR ALTER PROC [dbo].[SP_ConcluirAssinatura](
	@IdUsuario INT,
	@IdAssinatura INT,
	@IdCurso INT
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Iniciar o procedimento de assinatura.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_ConcluirAssinatura]   
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuario
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuario)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o Assinatura existe.
		IF NOT EXISTS (SELECT Id
							FROM Assinatura
								WHERE Id = @IdAssinatura)

			-- Mensagem de erro.
			THROW 50002, 'Assinatura inexistente.', 1;

		-- Verificando se o Curso existe.
		IF NOT EXISTS (SELECT Id
							FROM Curso
								WHERE Id = @IdCurso)

			-- Mensagem de erro.
			THROW 50002, 'Curso inexistente.', 1;

		ELSE
			-- Inserindo na tabela Assinatura Curso.
			INSERT INTO AssinaturaCurso (IdAssinatura, IdCurso)
				VALUES (@IdAssinatura, @IdCurso)
			BEGIN
				PRINT 'Assinatura concluída.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro na conclusão da assinatura.', 1;
	END;

-- Criação de procedure de insert na tabela Turma.
CREATE OR ALTER PROC [dbo].[SP_CriarTurma](
	@IdUsuarioADM INT,
	@IdModalidadeTurma TINYINT,
	@IdUsuarioProfessor INT,
	@IdCurso INT,
	@CapacidadeTurma TINYINT
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Criar uma nova turma.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_CriarTurma] 
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuarioADM
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioADM)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o Professor existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioProfessor)

			-- Mensagem de erro.
			THROW 50002, 'Professor inexistente.', 1;

		-- Verificando se a Modalidade existe.
		IF @IdModalidadeTurma <> 1

			-- Mensagem de erro.
			THROW 50002, 'A modalidade inicial deve ser EAD.', 1;

		-- Verificando se o Curso existe.
		IF NOT EXISTS (SELECT Id
							FROM Curso
								WHERE Id = @IdCurso)

			-- Mensagem de erro.
			THROW 50002, 'Curso inexistente.', 1;

		ELSE
			-- Inserindo na tabela Turma.
			INSERT INTO Turma (IdModalidadeTurma, IdUsuarioProfessor, IdCurso, CapacidadeTurma)
				VALUES (@IdModalidadeTurma, @IdUsuarioProfessor, @IdCurso, @CapacidadeTurma)
			BEGIN
				PRINT 'Turma criada com sucesso!.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro na criação da turma.', 1;
	END;

-- Criação de procedure de insert na tabela TurmaAluno.
CREATE OR ALTER PROC [dbo].[SP_AssociarTurmaAluno](
	@IdUsuarioADM INT,
	@IdTurma INT,
	@IdUsuarioAluno INT
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Associar o aluno a turma.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_AssociarTurmaAluno] 
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuarioADM
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioADM)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se a Turma existe.
		IF NOT EXISTS (SELECT Id
							FROM Turma
								WHERE Id = @IdTurma)

			-- Mensagem de erro.
			THROW 50002, 'Turma inexistente.', 1;

		-- Verificando se o Aluno existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioAluno AND IdTipoUsuario = 2)

			-- Mensagem de erro.
			THROW 50002, 'Aluno inexistente.', 1;

		ELSE
			-- Inserindo na tabela Turma.
			INSERT INTO TurmaAluno (IdTurma, IdUsuarioAluno)
				VALUES (@IdTurma, @IdUsuarioAluno)
			BEGIN
				PRINT 'Aluno associado a turma com sucesso!.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro na associação do aluno com a turma.', 1;
	END;

-- Criação de procedure de insert na tabela Módulo.
CREATE OR ALTER PROC [dbo].[SP_CriarModulo](
	@IdUsuarioADM INT,
	@IdCurso INT,
	@NomeModulo VARCHAR (50),
	@DescricaoModulo VARCHAR (100),
	@NivelDificuldade VARCHAR (30)
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Criar uma novo Módulo.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_CriarModulo] 
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuarioADM
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioADM)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE()))

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o Curso existe.
		IF NOT EXISTS (SELECT Id
							FROM Curso
								WHERE Id = @IdCurso)

			-- Mensagem de erro.
			THROW 50002, 'Curso inexistente.', 1;

		ELSE
			-- Inserindo na tabela Módulo.
			INSERT INTO Modulo (IdCurso, NomeModulo, DescricaoModulo, NivelDificuldade)
				VALUES (@IdCurso, @NomeModulo, @DescricaoModulo, @NivelDificuldade)
			BEGIN
				PRINT 'Módulo criado com sucesso!.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro na criação do módulo.', 1;
	END;

-- Criação de procedure de insert na tabela Atividade.
CREATE OR ALTER PROC [dbo].[SP_CriarAtividade](
	@IdUsuarioADM INT,
	@IdModulo INT,
	@NomeAtividade VARCHAR (50),
	@DescricaoAtividade VARCHAR (120),
	@DataInicio DATE,
	@DataTermino DATE,
	@NivelDificuldade VARCHAR (30)
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Criar uma nova Atividade.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_CriarAtividade] 
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuarioADM
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioADM)

			-- Mensagem de erro.
			THROW 50002, 'Usuário inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE())) 

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o Módulo existe.
		IF NOT EXISTS (SELECT Id
							FROM Modulo
								WHERE Id = @IdModulo)

			-- Mensagem de erro.
			THROW 50002, 'Módulo inexistente.', 1;

		-- Verificando a data de término.
		IF @DataTermino < @DataInicio

			-- Mensagem de erro.
			THROW 50002, 'Data de termíno inválida.', 1;

		ELSE
			-- Inserindo na tabela Atividade.
			INSERT INTO Atividade (IdModulo, NomeAtividade, DescricaoAtividade, DataInicio, DataTermino, NivelDificuldade)
				VALUES (@IdModulo, @NomeAtividade, @DescricaoAtividade, @DataInicio, @DataTermino, @NivelDificuldade)
			BEGIN
				PRINT 'Atividade criada com sucesso!.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro na criação da atividade.', 1;
	END;

-- Criação de procedure de insert na tabela	Mensagem.
CREATE OR ALTER PROC [dbo].[SP_EnviarMensagem](
	@IdUsuarioAutor INT,
	@IdUsuarioReceptor INT,
	@Mensagem TEXT
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Enviar uma Mensagem.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_EnviarMensagem]
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuarioAutor
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário Autor existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioAutor)

			-- Mensagem de erro.
			THROW 50002, 'Usuário autor inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE())) 

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se o Usuário Receptor existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioReceptor)

			-- Mensagem de erro.
			THROW 50002, 'O usuário receptor não foi encontrado.', 1;

		ELSE
			-- Inserindo na tabela Mensagem.
			INSERT INTO Mensagem (IdUsuarioAutor, IdUsuarioReceptor, Mensagem)
				VALUES (@IdUsuarioAutor, @IdUsuarioReceptor, @Mensagem)
			BEGIN
				PRINT 'Mensagem enviada com sucesso!.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro no envio da mensagem.', 1;
	END;

-- Criação de procedure de insert na tabela	Forúm.
CREATE OR ALTER PROC [dbo].[SP_RegistrarMensagemForum](
	@IdUsuarioAutor INT,
	@IdMensagem INT,
	@TopicoForum VARCHAR (70)
	)

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoProceduresJúlia.sql
    Objetivo..........: Registar uma mensagem para o forúm.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[SP_RegistrarMensagemForum]
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataHoraAutenticacao DATETIME

		-- Setando valor para variável @HoraAutenticacao.
		SET @DataHoraAutenticacao = (SELECT TOP 1 DataHoraAutenticacao
										FROM Autenticacao
											WHERE IdUsuario = @IdUsuarioAutor
										ORDER BY DataHoraAutenticacao DESC)

		-- Verificando se o Usuário Autor existe.
		IF NOT EXISTS (SELECT Id
							FROM Usuario
								WHERE Id = @IdUsuarioAutor)

			-- Mensagem de erro.
			THROW 50002, 'Usuário autor inexistente.', 1;

		-- Verificando se o usuário está autenticado.
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) < CONVERT(DATE,(GETDATE())) 

			-- Mensagem de erro.
			THROW 50002, 'O usuário não está mais autenticado.', 1;

		-- Verificando se a Mensagem existe.
		IF NOT EXISTS (SELECT Id
							FROM Mensagem
								WHERE Id = @IdMensagem)

			-- Mensagem de erro.
			THROW 50002, 'A mensgem não foi encontrada.', 1;

		ELSE
			-- Inserindo na tabela Forúm.
			INSERT INTO Forum (IdMensagem, TopicoForum)
				VALUES (@IdMensagem, @TopicoForum)
			BEGIN
				PRINT 'Mensagem registrada no Forúm com sucesso!.'
			END;

		-- Se erro...
		IF @@ERROR <> 0

			-- Mensagem de erro.
			THROW 50002, 'Erro no registro da mensagem no Forúm.', 1;
	END;