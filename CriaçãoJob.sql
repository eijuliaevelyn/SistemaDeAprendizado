-- Criação de JOB para atualizar o progesso após o módulo ser concluído.
CREATE OR ALTER PROC [dbo].[JOBAtualizarProgressoCurso]

	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoJobJúlia.sql
    Objetivo..........: atualizar o progesso após o módulo ser concluído.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 02/04/2024
    Ex................: BEGIN TRANSACTION
						SELECT * FROM ProgressoCurso 
						EXEC [dbo].[JOBAtualizarProgressoCurso]
						SELECT * FROM ProgressoCurso
						ROLLBACK
    */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @DataProc DATE = GETDATE()

		-- Atualizando Progresso.
		UPDATE ProgressoCurso
			SET Progresso = Progresso + 1,
				DataUltimaAvaliacao = GETDATE()
		WHERE IdCurso IN (SELECT IdCurso
								FROM Modulo
									WHERE Concluido = 1) AND ISNULL(DataUltimaAvaliacao, DATEADD(DAY, -1, @DataProc)) < @DataProc
	END;