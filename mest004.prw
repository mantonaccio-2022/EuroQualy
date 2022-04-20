#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mest004
//Rotina para manuten��o das etiquetas CB0
@author mjlozzardo
@since 15/03/2018
@version 1.0
@type function
/*/
user function mest004()
	Local cAlias := Alias()

	If SM0->M0_CODIGO $ "08"
		MsgInfo("Essa rotina n�o pode ser executada nesta empresa.", "Sem autoriza��o")
		Return
	EndIf

	DbSelectArea("CB0")
	DbSetOrder(1)
	MsFilter("CB0->CB0_OP == '" + SC2->(C2_NUM + C2_ITEM + C2_SEQUEN +C2_ITEMGRD) + "'")

	AxCadastro("CB0", "Manuten��o de Etiquetas", "U_MEST04D()", ".T.")

	DbClearFilter()

	DbSelectArea(cAlias)
	Return

User Function mest04d()
	Local lRet := .F.

	If RetCodUsr() $ SuperGetMV("ES_MEST03A", .T., "000000|")  //Apenas o administrador pode excluir etiqueta
		lRet := .T.
	Else
		MsgStop("Apenas o Administrador do sistema pode excluir etiqueta, favor comunica-lo.", "Sem permiss�o")
	EndIf
	Return(lRet)