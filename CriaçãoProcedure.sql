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