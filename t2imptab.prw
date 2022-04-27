#Include "RWMAKE.CH"

/*/{Protheus.doc} T2IMPTAB
Importação da tabela de preços da Qualy para o SB0 da Loja
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 26/04/2022
@return Character, sem retorno
/*/
User Function T2IMPTAB()

 Local aParamBox := {}     
 Local aRet  := {}

aAdd(aParamBox,{1, "Tabela a Importar?", Space(TAMSX3("L1_TABELA")[1]), "", "", "DA0", "", 30, .F.})

	If ParamBox(aParamBox,"Parâmetros...",@aRet)
		FWMsgRun(, {|| T2IMPTAB1( aRet ) },'Importação de Tabela','Importando Tabela, aguarde...')
	EndIF

Return

/*/{Protheus.doc} T2IMPTAB1
Executa a Importação da tabela de preços da Qualy para o SB0 da Loja
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 26/04/2022
@return Character, sem retorno
/*/
Static Function T2IMPTAB1(TABELA)
Local _cAlias := GetNextAlias()
Local nTotReg:=0
Local nTotAlt:=0

	BeginSql alias _cAlias
		SELECT
			DA1.DA1_CODPRO,
			DA1.DA1_PRCVEN
		FROM
			DA1100 DA1
		WHERE
			DA1.DA1_FILIAL = '08'
			AND DA1.DA1_CODTAB = %Exp:TABELA%
			AND DA1.%notDel%
		ORDER BY
			DA1.CODPRO
	EndSql

	aQuery:=GetLastQuery()

     nTotReg := Contar((_cAlias),"!EOF()")
    (_cAlias)->(DbGoTop())

    While (_cALias)->(!EOF())

        SB0->(dbSetOrder(1))
       If  SB0->(dbSeek(xFilial("SB5"))+(_cAlias)->DA1_CODPRO)
            RecLock("SB0",.F.)
            SB0->B0_PRV1:=(_cAlias)->DA1_PRCVEN
            MsUnLock()
            nTotAlt++
       End
        (_cAlias)->(dbSkip())
    End
    
    (_cAlias)->(dbCloseArea())

    MSGINFO("Registros Alterados: "+Str(nTotAlt,6,0),"Processo Finalizado")

Return
