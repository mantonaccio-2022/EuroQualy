#Include 'TOTVS.Ch'

/*/{Protheus.doc} MT250TOK
Ponto de entrada para valida��o de apontamento produ��o
@type function Ponto de Entrada
@version  1.00
@author Fabio - alterado por mario.antonaccio
@since 23/12/2017- alterado em 14/09/2021
@return logical, permite ou nao o apontamento da OP
/*/
User Function MT250TOK()

	Local aArea    := GetArea()
	Local lValido  := .T.
	Local lRet     := .T.
	Local lDif     := SuperGetMV("ES_A250DIF", .T., .F.)
//	Local cEmail as Character

	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+M->D3_OP))
	If SC2->C2_XLIBOP<>"1"
		ALERT("OP Nao Analisada - Necessario Analise antes do Apontamento (MT250TOK")
		lValido:=.F.
	End	

	If AllTrim( Upper( GetEnvServer() ) ) == "FABIO"

		// Valida��o anterior a modifica��o Fabio...
		If ParamIxb  //Validacao padrao ok
			If M->D3_PARCTOT == "P" .and. M->D3_PERDA == 0  //verifica perda
				lRet := MsgYesNo("Aten��o, n�o foi informado um valor de perda, deseja continuar ???", "Perda")
			EndIf

			If lRet .and. lDif  //Mostra divergencia no empenho
				U_mpcp002(M->D3_OP)
				lRet := MsgYesNo("Producao", "Confirma o apontamento da ordem de producao ???")
			EndIf

			If !lRet
				RestArea(aArea)
				Return lRet
			EndIf
		EndIf

		If lValido
			lValido := BeAutori()
		EndIf

	EndIf

	RestArea(aArea)

Return lValido

/*/{Protheus.doc} BeAutori
Valida��o de usuario
@type function Ponto de entrada
@version  1.00
@author mario.antonaccio
@since 14/09/2021
@return Logical, permite ou nao a continuidade do processo
/*/
Static Function BeAutori()

	Local lRet   := .T.

	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->( dbSeek( xFilial("SB1") + M->D3_COD ) )
		If !(AllTrim( SB1->B1_TIPO ) $ "PA/PI/KT/PP/BN")
			Aviso("MT250TOK / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " N�o Permitido Efetuar Apontamento de Produ��o, somente PA, PI, KT, PP e BN s�o v�lidos para apontamentos!",{"Cancela"})
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If Left(cFilAnt,2) == "08"
			Aviso("MT250TOK / Empresa!","N�o permitido apontamento de OP de Estoque na Qualycril, utilizar apontamento PCP com roteiros de opera��es!",{"Cancela"})
			lRet := .F.
		EndIf
	EndIf

Return lRet
