#include "totvs.ch"

/*/{Protheus.doc} ma415end
PE usado para gravar o peso liq. e bruto no orcamento de venda
@type function Ponto de Entrada
@version  1.00
@author mjlozzardo
@since 12/09/2018
@return Logical, permitindo a continuação do processo  - ou nao
/*/

User Function MA415END()

	//Local lConf := (ParamIxb[1] == 1)
	Local lExcl := (ParamIxb[2] == 3)
	Local cArea := GetArea()
	Local nPesLiq:= 0
	Local nPesBrt:= 0

	If ! lExcl

		SCK->(DbSetOrder(1))
		If SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM))

			While SCK->(!Eof()) .and. SCK->CK_NUM == SCJ->CJ_NUM

				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1") + SCK->CK_PRODUTO))

				nPesLiq += (SCK->CK_QTDVEN * SB1->B1_PESO)
				nPesBrt += (SCK->CK_QTDVEN * SB1->B1_PESBRU)

				SCK->(DbSkip())

			EndDo

			RecLock("SCJ", .F.)
			SCJ->CJ_PESOL  := nPesLiq
			SCJ->CJ_PBRUTO := nPesBrt
			MsUnLock()

		EndIf

	EndIf

	RestArea(aArea)

Return(.T.)
