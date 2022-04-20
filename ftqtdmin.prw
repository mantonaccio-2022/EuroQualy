#Include "RWMAKE.CH"

/*/{Protheus.doc} FTQTDMIN
PE usado para permitir gerar um pedido de venda com a quantidade fora do multiplo do B1_LOTVEN
@type function Ponto de Entrada
@version  1.00
@author  mjlozzardo
@since 18/02/2019
@return Logical, permite ou nao a continuação do processo
/*/
User Function FTQTDMIN()

Local cAlias := Alias()
Local lRet   := .T.
Local cOper  := SuperGetMV("ES_TOPER01", .T., "ZZ") //tipo de operacao que nao valida b1_lotven

/*

Grupo Empresa - Ajuste realizado (CG)

//If Alltrim(cEmpAnt) == "01"  //apenas para a empresa 01
//	If M->C5_TPFRETE == "F" .and. M->C5_TRANSP = "000002"
//		lRet := .T.
//	ElseIf M->C5_XOPER $ cOper  //operacoes que nao devem validar
//		lRet := .T.
//	Else
//		lRet := .F.
//	EndIf
	
//ElseIf Alltrim(cEmpAnt) == "08"  //apenas para a empresa 08
//	If M->C5_XOPER $ cOper  //operacoes que nao devem validar
//		lRet := .T.
//	Else
//		lRet := .F.
//	EndIf
//EndIf
*/

If Left(cFilAnt,2) == "01"  //apenas para a empresa 01
	If M->C5_TPFRETE == "F" .and. M->C5_TRANSP = "000002"
		lRet := .T.
	ElseIf M->C5_XOPER $ cOper  //operacoes que nao devem validar
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	
ElseIf Left(cFilAnt,2) == "08"  //apenas para a empresa 08
	If M->C5_XOPER $ cOper  //operacoes que nao devem validar
		lRet := .T.
	Else
		lRet := .F.
	EndIf
EndIf
REstArea(cAlias)
Return(lRet)
