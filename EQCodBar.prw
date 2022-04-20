#include 'protheus.ch'
#include 'parmtype.ch'

/*{Protheus.doc} mt010inc
//PE utilizado para gerar o EAN 13 na inclusao do produto
@author 
@since 07/02/2018
@version 1.0
@type function
*/
   
User Function EQCodBar()

Local cAlias := Alias()
Local aAreaB1:= SB1->(GetArea())
Local cTipo  := SuperGetMV("ES_MTA010A", .T., "KT|PA|PV")
Local cSeq   := ""
Local cEan   := ""
Local nRegB1 := SB1->(RecNo())

//Sequ�ncia contratada Qualyvinil 789825824 + 3 d�gitos + 1 d�gito verificador

If SB1->B1_TIPO $ cTipo .and. Empty(SB1->B1_CODBAR) .and. !Empty(SB1->B1_GRUPO) .And. SB1->B1_MSBLQL <> '1'

	If MsgYesNo("Confirma a gera��o do C�digo de Barras para o Produto = "+SB1->B1_COD)

		SZ2->(DbSetOrder(2))
		SZ2->(DbSeek(xFilial("SZ2") + SB1->B1_GRUPO, .T.))
		If SB1->B1_GRUPO >= SZ2->Z2_GRPDE .and. SB1->B1_GRUPO <= SZ2->Z2_GRPATE
			cSeq := Soma1(SZ2->Z2_SEQ)
			SB1->(DbSetOrder(5))
			While .T.
				cEan := (SZ2->Z2_MATRIZ + cSeq) + Rtrim(EanDigito(SZ2->Z2_MATRIZ + cSeq))
				If SB1->(DbSeek(xFilial("SB1") + cEan, .F.))
					cSeq := Soma1(cSeq)
					Loop
				Else
					SZ2->(RecLock("SZ2", .F.))
					SZ2->Z2_SEQ := cSeq
					SZ2->(MsUnLock())
    	
					SB1->(DbGoTo(nRegB1))
					SB1->(RecLock("SB1", .F.))
					SB1->B1_CODBAR := cEan
					SB1->(MsUnLock())

					MsgAlert("Aten��o", "C�digo de Barras Gerado Com Sucesso!")

					Exit
				EndIf
			EndDo
		Else
			MsgAlert("Aten��o", "N�o foi localizada a configura��o EAN, favor informar o TI.")
		EndIf
    EndIf
Else
	MsgAlert("N�o � permitida a gera��o do codigo de barras para esse produto. Verifique se o produto est� bloqueado, o tipo do produto e o grupo.","Aten��o" )
EndIf

DbSelectArea(cAlias)
RestArea(aAreaB1)

Return
