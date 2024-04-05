<<<<<<< HEAD
--Trigger para inserir na tabela parcela
CREATE OR ALTER TRIGGER [dbo].[TRG_InsParcela]
	ON Pagamento
	AFTER INSERT

	AS

	/*

		DOCUMENTAÇÃO
		ARQUIVO...............:	SistemaDeApredizagem.sql
		OBJETIVO..............:	Inserir a parcela
		AUTOR.................:	SMN - JOÃO EMANOEL
		DATA..................: 02/04/2024

	*/

	BEGIN

		--Declarando variáveis
		DECLARE @IdI						INT,
				@IdD						INT,
				@IdCartao					INT,
				@Parcelado					BIT,
				@ValorTotal					DECIMAL(10,2),
				@QuantidadeParcela			TINYINT,
				@QuantidadeMes				INT,
				@Contador					INT

		--Recuperando o valor
		SELECT @IdI = Id,		
			   @Parcelado = Parcelado,
			   @ValorTotal = ValorTotal,
			   @IdCartao = IdCartao,
			   @QuantidadeParcela = QuantidadeParcela
			 FROM inserted

		--Recuperando o valor
		SELECT @IdD	= Id
			 FROM deleted

		--Verificando se o IdD é nulo
		IF @IdD IS NULL
			
			--Verificando se é parcelado em apenas uma vez
			IF @Parcelado = 0

				BEGIN

					--Inserindo os dados
					INSERT INTO Parcela (	IdPagamento,
											ValorParcela,
											DataPagamentoParcela,
											Pago,
											DataPagamentoRealizado		)
										VALUES (	@IdI,
													@ValorTotal,
													GETDATE(),
													1,
													GETDATE()		)

				END

			--Verificando se foi parcelado
			IF @Parcelado = 1

			BEGIN
				--Aicionando valor a variável
				SET @Contador = 1

				--Aicionando valor a variável
				SET @QuantidadeMes = 1

				--Fazer um loop para inserir as parcelas
				WHILE @Contador <= @QuantidadeParcela

					BEGIN
						
						--Inserindo os dados
						INSERT INTO Parcela (	IdPagamento,
												ValorParcela,
												DataPagamentoParcela		)
											VALUES (	@IdI,
														@ValorTotal / @QuantidadeParcela,
														DATEADD(MONTH, @QuantidadeMes, GETDATE())	)
						
						--Aicionando valor a variável
						SET @QuantidadeMes = @QuantidadeMes + 1
						--Aicionando valor a variável
						SET @Contador = @Contador + 1

					END
			END

	END
GO
=======
-- Criação de trigger para após uma assinatura for realizada criar registro na tabela progresso.
CREATE OR ALTER TRIGGER [dbo].[TRGCriarRegistroEmProgresso]
ON [AssinaturaCurso]
AFTER INSERT 

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoTriggersJúlia.sql
    Objetivo..........: Após uma assinatura for realizada criar registro na tabela progresso.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[TRGCriarRegistroEmProgresso]
    */
	BEGIN 
		-- Declarando Variáveis.
		DECLARE @IdAssinaturaI INT,
				@IdCursoI INT,
				@IdUsuario INT

		-- Recuperando da Inserted.
		SELECT	@IdAssinaturaI = IdAssinatura,
				@IdCursoI = IdCurso
			FROM inserted

		-- Setando valor para variável @IdUsuario.
		SET @IdUsuario = (SELECT IdUsuario
								FROM Assinatura
									WHERE Id = @IdAssinaturaI)

		-- Verificando evento.
		IF @IdAssinaturaI IS NOT NULL AND @IdCursoI IS NOT NULL
			
			-- Inserindo registro na tabela Progresso Curso.
			BEGIN
				INSERT INTO ProgressoCurso (IdUsuario, IdCurso, Progresso) 
					VALUES (@IdUsuario, @IdCursoI, 0)
			END;
	END;

-- Criação de trigger para que após o preenchimento do campo “DataPagamentoRealziado” da tabela Parcelas atualizar o campo “Pago” para 1.
CREATE OR ALTER TRIGGER [dbo].[TRGAtualizarPago]
ON [Parcela]
AFTER UPDATE 

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoTriggersJúlia.sql
    Objetivo..........: Após uma assinatura for realizada criar registro na tabela progresso.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[TRGCriarRegistroEmProgresso]
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @IdParcelaI INT,
				@IdParcelaD INT,
				@DataPagamentoRealizado DATE

		-- Recuperando da Inserted.
		SELECT	@IdParcelaI = Id,
				@DataPagamentoRealizado = DataPagamentoRealizado
			FROM inserted

		-- Recuperando da Deleted.
		SELECT	@IdParcelaD = Id
			FROM deleted

		-- Verificando Evento.
		IF @IdParcelaI IS NOT NULL AND @IdParcelaD IS NOT NULL

			-- Verificando se o pagamento foi realizado.
			IF @DataPagamentoRealizado IS NOT NULL

				-- Atualizando o campo "Pago".
				BEGIN
					UPDATE Parcela
						SET Pago = 1
					WHERE Id = @IdParcelaI
				END;
	END;

-- Criação de trigger instead of para verificar a capacidade da turma. Caso não houver mais capacidade deverá exibir uma mensagem avisando o usuário.
CREATE OR ALTER TRIGGER [dbo].[TRGVerificarCapacidadeTurma]
ON [TurmaAluno]
INSTEAD OF INSERT

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoTriggersJúlia.sql
    Objetivo..........: Após uma assinatura for realizada criar registro na tabela progresso.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: EXEC [dbo].[TRGCriarRegistroEmProgresso]
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @IdTurmaI INT,
				@IdUsuarioAlunoI INT,
				@CapacidadeTurma TINYINT,
				@QuantidadeAlunos TINYINT

		-- Recuperando da Inserted.
		SELECT	@IdTurmaI = IdTurma,
				@IdUsuarioAlunoI = IdUsuarioAluno
			FROM inserted

		-- Setando valor para variável @CapacidadeTurma.
		SET @CapacidadeTurma = (SELECT CapacidadeTurma
									FROM Turma
										WHERE Id = @IdTurmaI)

		-- Setando valor para variável @QuantidadeAlunos.
		SET @QuantidadeAlunos = (SELECT COUNT(IdUsuarioAluno)
									FROM TurmaAluno
										WHERE IdTurma = @IdTurmaI)

		-- Verificando Evento.
		IF @IdTurmaI IS NOT NULL AND @IdUsuarioAlunoI IS NOT NULL

			-- Verificando Capacidade da turma.
			IF @QuantidadeAlunos = @CapacidadeTurma

				-- Mensagem de erro.
				THROW 50002, 'Não há mais capacidade nessa turma.', 1;

			ELSE
				-- Inserindo na tabela Turma Aluno.
				BEGIN
					INSERT INTO TurmaAluno (IdTurma, IdUsuarioAluno)
						VALUES (@IdTurmaI, @IdUsuarioAlunoI)
				END;
	END;
>>>>>>> Júlia
