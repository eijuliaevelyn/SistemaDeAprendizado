-- Criação de function para validar o formato do 
CREATE OR ALTER FUNCTION [dbo].[FNCValidarEmail](
	@Email VARCHAR (255)
	)

	RETURNS TINYINT
	
	AS
	/*
    Documentação
    Arquivo fonte.....: SQLQuery.CriaçãoFunctionJúlia.sql
    Objetivo..........: Validar se o Email está no formato correto.
    Autor.............: Júlia Evelyn - SMN
    Data..............: 28/02/2024
    Ex................: SELECT [dbo].[FNCValidarEmail]('') AS Resultado
	Retornos..........: 0 - Email válido
						1 - Email inválido.  
  */
	BEGIN
		-- Declarando Variáveis.
		DECLARE @Retorno TINYINT

		IF @Email IN (SELECT @Email
						WHERE	(@Email like '[a-z,0-9,,-]%@[a-z,0-9,,-]%.[a-z]%') -- exige formato: [letras-numeros-underline-traço] + [qualquer coisa] + [@] + [letras-numeros-underline-traço] + [qualquer coisa] + [.] + [letras] + qualquer coisa
												AND    (@Email not like '%[^a-z0-9@.-]%') -- impede caracteres que não sejam: a-z 0-9 @ .  -
												AND    (@Email not like '%@%@%') -- impede dois arrobas
												AND    (@Email not like '%.@%') -- impede .@
												AND    (@Email not like '%..%') -- impede ..
												AND    (@Email not like '%.')) -- impede terminar com .

			-- Setando valor para variável @Retorno.
			SET @Retorno = 0

		ELSE
			-- Setando valor para variável @Retorno.
			SET @Retorno = 1

		RETURN @Retorno
	END;