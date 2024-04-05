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