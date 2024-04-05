--Proc de update na tabela ProgressoCurso
CREATE OR ALTER PROC [dbo].[SP_AtualizarProgresso](
	@IdUsuarioAcesso				INT,
	@IdUsuario						INT,
	@IdCurso						INT,
	@FeedbackProfessor				VARCHAR(100) = NULL,
	@AvaliacaoDesempenho			TINYINT = NULL
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Atualizar tabela ProgressoCurso
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
		EX....................:	EXEC [dbo].[SP_AtualizarProgresso]

	*/

	BEGIN

		--Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME

		--Verificando se o UsuarioAcesso não é professor
		IF (SELECT IdTipoUsuario
				FROM Usuario
				WHERE Id = @IdUsuarioAcesso) <> 3

				THROW 550000, 'Erro: Não é um professor', 1;

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Usuario
							WHERE Id = @IdUsuario)

						THROW 550000, 'Erro: Usuário inexistente', 1;

		--Verificando se o Curso não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Curso
							WHERE Id = @IdCurso)

						THROW 550000, 'Erro: Curso inexistente', 1;
		
		--Verificando se o UsuarioAcesso não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Usuario
							WHERE Id = @IdUsuarioAcesso)

						THROW 550000, 'Erro: UsuarioAcesso inexistente', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuarioAcesso
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE

			--Atualizando os dados
			UPDATE ProgressoCurso
				SET FeedbackProfessor			= ISNULL(@FeedbackProfessor, FeedbackProfessor),							
					AvaliacaoDesempenho			= ISNULL(@AvaliacaoDesempenho, AvaliacaoDesempenho),				
					DataUltimaAvaliacao			= GETDATE()
				WHERE IdUsuario = @IdUsuario AND IdCurso = @IdCurso

				PRINT 'Inserido com Sucesso'

		--Verificandos e tem algum erro
		IF @@ERROR <> 0
			
			THROW 550000, 'Erro', 1;

	END
GO

--Proc de update na tabela Módulo
CREATE OR ALTER PROC [dbo].[SP_AtualizarModulo](
	@IdUsuarioAcesso		INT,
	@IdModulo				INT,
	@Concluido				BIT
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Atualizar tabela Parcela(Campo: Concluido)
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
		EX....................:	EXEC [dbo].[SP_AtualizarModulo]

	*/

	BEGIN

		--Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Usuario
							WHERE Id = @IdUsuarioAcesso)

						THROW 550000, 'Erro: UsuarioAcesso inexistente', 1;

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Modulo
							WHERE Id = @IdModulo)

						THROW 550000, 'Erro: Modulo inexistente', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuarioAcesso
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE

			--Atualizando os dados
			UPDATE Modulo
				SET Concluido = @Concluido
				WHERE Id = @IdModulo 

				PRINT 'Inserido com Sucesso'

		--Verificandos e tem algum erro
		IF @@ERROR <> 0
			
			THROW 550000, 'Erro', 1;

	END
GO

--Proc de update na tabela Parcela
CREATE OR ALTER PROC [dbo].[SP_PagarParcela](
	@IdUsuario				INT,
	@IdParcela				INT,
	@DataDePagamento		DATE
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Atualizar tabela Parcela(Campo: DataPagamentoRealizado)
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
		EX....................:	EXEC [dbo].[SP_PagarParcela]

	*/

	BEGIN

		 --Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME

		--Verificando se o UsuarioAcesso não é aluno
		IF (SELECT IdTipoUsuario
				FROM Usuario
				WHERE Id = @IdUsuario) <> 2

				THROW 550000, 'Erro: Não é um Aluno', 1;

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Parcela
							WHERE Id = @IdParcela)

						THROW 550000, 'Erro: Parcela inexistente', 1;

		IF @DataDePagamento <> CONVERT(DATE, GETDATE())
			
			THROW 550000, 'Erro: Data inválida.', 1;

		--Verificando se a parcela já foi paga
		IF (SELECT Pago
				FROM Parcela
				WHERE Id = @IdParcela) = 0

			THROW 550000, 'Erro: Parcela não paga.', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuario
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE

			--Atualizando os dados
			UPDATE Parcela
				SET DataPagamentoRealizado = @DataDePagamento
				WHERE Id = @IdParcela 

				PRINT 'Atualizado com sucesso'

		--Verificandos e tem algum erro
		IF @@ERROR <> 0
			
			THROW 550000, 'Erro', 1;

	END
GO

--Proc de update na tabela Usuario
CREATE OR ALTER PROC [dbo].[SP_EditarDadosPessoais](
	@IdUsuario					INT,
	@NomeCompleto				VARCHAR (180),
	@DataNascimento				DATE,
	@CPF						VARCHAR (15),
	@Email						VARCHAR (255)
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Atualizar tabela Usuario
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
		EX....................:	EXEC [dbo].[SP_PagarParcela]

	*/

	BEGIN

		 --Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME

		--Verificando se o UsuarioAcesso não é aluno
		IF (SELECT IdTipoUsuario
				FROM Usuario
				WHERE Id = @IdUsuario) <> 2

				THROW 550000, 'Erro: Não é um Aluno', 1;

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Usuario
							WHERE Id = @IdUsuario)

						THROW 550000, 'Erro: Usuário inexistente', 1;

		-- Validando a data de nascimento.
        IF @DataNascimento > GETDATE()

            -- Mensagem de erro.
            THROW 50002, 'Data de nascimento inválida.', 1;

        -- Validando o formato do CPF.
        IF @CPF NOT LIKE '[0-9][0-9][0-9].[0-9][0-9][0-9].[0-9][0-9][0-9]-[0-9][0-9]'

            -- Mensagem de erro.
            THROW 50002, 'Formato do CPF inválido.', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuario
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE

			--Atualizando os dados
			UPDATE Usuario
				SET NomeCompleto			=	ISNULL(@NomeCompleto,NomeCompleto),					
					DataNascimento			=	ISNULL(@DataNascimento, DataNascimento),		
					CPF						=	ISNULL(@CPF,CPF),							
					Email					=	ISNULL(@Email, Email)						
				WHERE Id = @IdUsuario 

				PRINT 'Atualizado com sucesso'

		--Verificandos e tem algum erro
		IF @@ERROR <> 0
			
			THROW 550000, 'Erro', 1;

	END
GO

--Proc de update na tabela Usuario
CREATE OR ALTER PROC [dbo].[SP_AtualizarSenha](
	@IdUsuario					INT,
	@Senha						VARCHAR(64)
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Atualizar senha na tabela USUARIO
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
		EX....................:	EXEC [dbo].[SP_AtualizarSenha]

	*/

	BEGIN

		 --Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME

		--Verificando se o UsuarioAcesso não é aluno
		IF (SELECT IdTipoUsuario
				FROM Usuario
				WHERE Id = @IdUsuario) <> 2

				THROW 550000, 'Erro: Não é um Aluno', 1;

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Usuario
							WHERE Id = @IdUsuario)

						THROW 550000, 'Erro: Usuário inexistente', 1;

        -- Validando senha.
        IF LEN(@Senha) < 8 

            THROW 50002, 'A senha necessita ter ao menos 8 caracteres.', 1;

		--Verificando se a senha é igual a da anterior
		IF @Senha = (SELECT Senha
						FROM Usuario
						WHERE Id = @IdUsuario)

			THROW 50002, 'A senha permanece a mesma.', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuario
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE

			--Atualizando os dados
			UPDATE Usuario
				SET Senha = @Senha						
				WHERE Id = @IdUsuario 

				PRINT 'Atualizado com sucesso'

		--Verificandos e tem algum erro
		IF @@ERROR <> 0
			
			THROW 550000, 'Erro', 1;

	END
GO

--Proc de update na tabela Turma
CREATE OR ALTER PROC [dbo].[SP_AtualizarModalidadePresencial](
	@IdUsuarioAcesso		INT,
	@IdTurma				INT,
	@IdModalidadeTurma		INT
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Atualizar modalidade na tabela Turma
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
		EX....................:	EXEC [dbo].[SP_AtualizarModalidadePresencial]

	*/

	BEGIN

		--Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME

		--Verificando se o UsuárioAcesso não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Usuario
							WHERE Id = @IdUsuarioAcesso)

						THROW 550000, 'Erro: UsuárioAcesso inexistente', 1;

		--Verificando se o UsuarioAcesso não é administrador
		IF (SELECT IdTipoUsuario
				FROM Usuario
				WHERE Id = @IdUsuarioAcesso) <> 1

				THROW 550000, 'Erro: Não é um Administrador', 1;

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Turma
							WHERE Id = @IdTurma)

						THROW 550000, 'Erro: Usuário inexistente', 1;

		--Verificando se a capacidade já foi suprida
		IF  (SELECT IdModalidadeTurma
				FROM Turma
				WHERE Id = @IdTurma) <> 1 AND (SELECT COUNT(ta.IdUsuarioAluno)
												FROM Turma t
												JOIN TurmaAluno ta ON t.Id = ta.IdTurma
												WHERE Id = @IdTurma) < 15

					THROW 550000, 'Erro: A turma presencial não tem capacidade surgerida.', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuarioAcesso
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE

			--Atualizando os dados
			UPDATE Turma
				SET IdModalidadeTurma = @IdModalidadeTurma						
				WHERE Id = @IdTurma 

				PRINT 'Atualizado com sucesso'
			

		--Verificandos e tem algum erro
		IF @@ERROR <> 0
			
			THROW 550000, 'Erro', 1;

	END
GO

--Proc de update na tabela Usuario
CREATE OR ALTER PROC [dbo].[SP_AtualizarAtivo](
	@IdUsuarioAcesso		INT,
	@IdUsuario				INT,
	@Ativo					BIT
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Atualizar ativo na tabela USUARIO
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
		EX....................:	EXEC [dbo].[SP_AtualizarAtivo]

	*/

	BEGIN

		--Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME

		--Verificando se o UsuarioAcesso não é administrador
		IF NOT EXISTS (SELECT IdTipoUsuario
							FROM Usuario
							WHERE Id = @IdUsuarioAcesso)

				THROW 550000, 'Erro: UsuarioAcesso inexistente.', 1;
		
		--Verificando se o UsuarioAcesso não é administrador
		IF (SELECT IdTipoUsuario
				FROM Usuario
				WHERE Id = @IdUsuarioAcesso) <> 1

				THROW 550000, 'Erro: Não é um Administrador', 1;

		--Verificando se o usuario não existe
		IF NOT EXISTS ( SELECT Id		
							FROM Usuario
							WHERE Id = @IdUsuario)

						THROW 550000, 'Erro: Usuário inexistente', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuarioAcesso
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE
			--Atualizando os dados
			UPDATE Usuario
				SET Ativo = @Ativo --Desativado					
				WHERE Id = @IdUsuario 

				PRINT 'Atualizado com sucesso'

		--Verificandos e tem algum erro
		IF @@ERROR <> 0
			
			THROW 550000, 'Erro', 1;

	END
GO

--Proc select progresso curso
CREATE OR ALTER PROC [dbo].[SP_SelProcessoCurso](
	@IdUsuarioAcesso		INT,
	@IdUsuario				INT = NULL,
	@IdCurso				INT = NULL
	)

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Selecionar o progresso do curso
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024
								EXEC [dbo].[SP_SelProcessoCurso] 1, 2, NULL SELECT * FROM PROGRESSOCURSO SELECT * FROM CURSO

	*/

	BEGIN

		--Declarando variáveis
		DECLARE @DataHoraAutenticacao			DATETIME,
				@TipoUsuario					INT

		--Verificando se o UsuarioAcesso não é administrador
		SET @TipoUsuario = (SELECT IdTipoUsuario
									FROM Usuario
									WHERE Id = @IdUsuarioAcesso)

		--Verificando se o UsuarioAcesso não existe
		IF NOT EXISTS (SELECT Id
							FROM Usuario
							WHERE Id = @IdUsuarioAcesso)

						THROW 550000, 'Erro: UsuárioAcesso inexistente.', 1;

		--Adicionando valor a variável
		SET @DataHoraAutenticacao = (SELECT TOP 1 a.DataHoraAutenticacao
										FROM Usuario u
										JOIN Autenticacao a ON a.IdUsuario = u.Id
										WHERE u.Id = @IdUsuarioAcesso
										ORDER BY a.DataHoraAutenticacao DESC)

		--Verificandos se a autenticação foi expirada
		IF CONVERT(TIME, (GETDATE())) >= CONVERT(TIME, DATEADD(HOUR, 6, @DataHoraAutenticacao)) OR CONVERT(DATE, @DataHoraAutenticacao) <> CONVERT(DATE,(GETDATE()))

			THROW 550000, 'Erro: autenticação expirada.', 1;

		ELSE
			
			BEGIN

				--Verificando se é um aluno que quer ver o progresso do curso
				IF @TipoUsuario = 2

					BEGIN

					--Verificando se o IdUsuario é nulo
					IF @IdUsuario IS NULL OR @IdUsuario <> @IdUsuarioAcesso

						THROW 550000, 'Erro: IdUsuario não pode ser nulo, pois, você é um aluno.', 1;

					ELSE
					
						BEGIN
							--Verificando se o campo NomeCurso estar preenchido
							IF @IdCurso IS NOT NULL

							BEGIN
									--Visualizar o progresso do 
									SELECT	pc.Progresso,
											pc.FeedbackProfessor,
											pc.AvaliacaoDesempenho,
											pc.DataUltimaAvaliacao
										FROM Usuario u
										JOIN ProgressoCurso pc ON pc.IdUsuario = u.Id
										WHERE pc.IdCurso = @IdCurso AND u.Id = @IdUsuario
							END
				
								ELSE

							BEGIN

										SELECT pc.Progresso,
											   pc.FeedbackProfessor,
											   pc.AvaliacaoDesempenho,
											   pc.DataUltimaAvaliacao
										FROM Usuario u
										JOIN ProgressoCurso pc ON pc.IdUsuario = u.Id
										WHERE PC.IdUsuario = @IdUsuario


							END
					

						

					END

			END

							ELSE 
			
							BEGIN
								--Verificando se o campo NomeCurso estar preenchido
								IF @IdCurso IS NOT NULL AND @IdUsuario IS NULL
				
								BEGIN

									SELECT	pc.Progresso,
											pc.FeedbackProfessor,
											pc.AvaliacaoDesempenho,
											pc.DataUltimaAvaliacao
										FROM Usuario u
										JOIN ProgressoCurso pc ON pc.IdUsuario = u.Id
										WHERE pc.IdCurso = @IdCurso

								END
								--Verificando se o campo NomeCurso e IdUsuario estar preenchido
								IF @IdCurso IS NOT NULL AND @IdUsuario IS NOT NULL

								BEGIN
										SELECT	pc.Progresso,
											pc.FeedbackProfessor,
											pc.AvaliacaoDesempenho,
											pc.DataUltimaAvaliacao
										FROM Usuario u
										JOIN ProgressoCurso pc ON pc.IdUsuario = u.Id
										WHERE pc.IdCurso = @IdCurso AND u.Id = @IdUsuario

								END
								--Verificando se o campo IdUsuario estar preenchido
								IF @IdUsuario IS NOT NULL AND @IdCurso IS NULL

								BEGIN
										SELECT	pc.Progresso,
											pc.FeedbackProfessor,
											pc.AvaliacaoDesempenho,
											pc.DataUltimaAvaliacao
										FROM Usuario u
										JOIN ProgressoCurso pc ON pc.IdUsuario = u.Id
										WHERE u.Id = @IdUsuario
								END

								IF @IdUsuario IS NULL AND @IdCurso IS NULL

								BEGIN

										SELECT	pc.Progresso,
											pc.FeedbackProfessor,
											pc.AvaliacaoDesempenho,
											pc.DataUltimaAvaliacao
										FROM Usuario u
										JOIN ProgressoCurso pc ON pc.IdUsuario = u.Id
								END

							
							END
							END
		
				END
GO

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
