#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} m680vldpt
//PE usado para alertar a producao parcial da op.
@author mjlozzardo
@since 15/05/2018
@version 1.0
/*/
User Function m680vldpt()
	Local lRet    := .F.
	Local lPrdAut := SuperGetMV("ES_PRDAUT", .T., .F.)  //indica se a diferenca entre C2_QUANT - QtdPrd. deve se perda.

	If lPrdAut  .and. (A680SldProd(.T., .T.) - M->H6_QTDPROD) > 0
		M->H6_PT := "T"
		M->H6_QTDPERD := A680SldProd(.T., .T.) - M->H6_QTDPROD
		/*If MsgYesNo("A qtd produzida n�o bate com a informada na OP, deseja continuar ???", "PRODUCAO A MENOR")
			lRet := .F.
		Else
			lRet := .T.
		EndIf*/
	EndIf

	Return(lRet)
	
	
/*Corrigir os par�metros abaixo
MV_TMPAD   = 001
MV_PRODAUT = .F.
MV_REQAUT  = D
MV_PERDINF = .F.
MV_PATUEMP = S

Criar o par�metro
Nome: ES_PRDAUT
Tipo: 3-L�gico
Conte�do: .T.
Descri��o: Informe se a diferen�a entre a (Qtd.Prevista - Qtd.Produzida) > 0 ser� apontada como perda.

Alterar o Tipo de movimenta��o 001, ou a que estiver no par�metro MV_TMPAD
F5_ATUEMP = S
*/