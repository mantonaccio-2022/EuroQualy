#include "totvs.ch"

/*/{Protheus.doc} FINE002
Devolve o nosso numero para o titulo financeiro conforme  o banco selecionado
@type function Processamento
@version  1.01
@author Alexandre Marson  - Alterado por mario.antonaccio
@since 04/08/14  - alterado em 28/10/2021
@param _cBanco, character, numero do banco
@return Character, sem retorno
/*/
User Function FINE002(_cBanco)
	Local aArea		:= GetArea()
	Local cNumBco	:= ""
	Local cMvPar    := "MV_NBOL"+RTrim(_cBanco)

	BEGIN SEQUENCE

		If Empty(SE1->E1_NUMBCO) .and. _cBanco == "001"

			//Verifica a existencia do parametro no SX6
			SX6->( dbSetOrder(1) )
			SX6->( dbSeek(xFilial("SE1")+cMvPar) )

			//Caso nao encontre, cria o mesmo
			If SX6->( !Found() )
				RecLock("SX6", .T.)
				SX6->X6_FIL         := xFilial("SE1")
				SX6->X6_VAR         := cMvPar
				SX6->X6_TIPO        := "C"
				SX6->X6_DESCRIC     := "Ultimo número de boleto gerado"
				SX6->X6_CONTEUD     := "0000000"
				SX6->X6_PROPRI      := "U"
				SX6->( MsUnLock() )
			EndIf

			//Gera um novo numero sequencial
			cNumBco := Left(SX6->X6_CONTEUD,7)
			cNumBco := Soma1(cNumBco)

			//Atualiza valor do parametro
			RecLock("SX6", .F.)
			SX6->X6_CONTEUD       := cNumBco
			MsUnLock()
			//Devolve o nosso numero conforme regra da entidade financeira
			cNumBco := "500" + cNumBco

			//Atualizado 23/01/18
			SE1->(RecLock("SE1",.F.))
			SE1->E1_NUMBCO := cNumBco
			SE1->( MsUnlock() )

		EndIf

	END SEQUENCE

	RestArea( aArea )

Return( )	//Return( lRet )

/*/{Protheus.doc} FINE02NN
DAC Nosoo Numero
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 28/10/2021
@return Character,DAC do Nosso numero
/*/
User Function FINE02NN()
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSEE	:= SEE->( GetArea() )

	Local cBanco	:= RTrim( IIf( ValType("SEE->EE_CODIGO")  != "U", SEE->EE_CODIGO,  "" ) )
	Local cCarteira	:= RTrim( IIf( ValType("SEE->EE_CARTEIR") != "U", SEE->EE_CARTEIR, "" ) )
	Local cConvenio	:= RTrim( IIf( ValType("SEE->EE_CODEMP")  != "U", SEE->EE_CODEMP,  "" ) )
	Local cNumBco	:= RTrim( IIf( ValType("SE1->E1_NUMBCO")  != "U", SE1->E1_NUMBCO,  "" ) )
	Local nCont		:= 0
	Local nPeso		:= 0
	Local nResto	:= 0
	Local i			:= 0
	Local cDV_NNUM	:= ""

	If Empty( cBanco ) .Or. Empty( cCarteira ) 	.Or. Empty( cNumBco )

		MsgStop( "Não foi possível identificar o banco, carteira ou nosso numero", "FINE002DV")

		Return( "" )

	EndIf


	Do Case

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| 001 - Banco do Brasil ( Peso 2 -> 9 )                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cBanco == "001"

			If Len(cConvenio) >= 7
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Não há DV - Dígito Verificador - para o Nosso-Número, quando o      ³
				//| número convênio de cobrança for acima de 1.000.000 (um milhão).     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDV_NNUM := ""

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//| Implementar calculo do nosso numero para outros convenios BB        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| 237 - Bradesco ( Peso: 2 -> 7 )                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case cBanco == "237"

			nCont   	:= 0
			nPeso   	:= 2
			cNNumero	:= StrZero(Val(cCarteira),2) + StrZero(Val(cNumBco),11)

			For i := 13 To 1 Step -1

				nCont :=  nCont + (Val(SubStr(cNNumero,i,1))) * nPeso
				nPeso :=  nPeso + 1

				If nPeso == 8
					nPeso := 2
				EndIf

			Next

			nResto := (nCont % 11)

			If nResto == 1
				cDV_NNUM := "P"

			ElseIf nResto == 0
				cDV_NNUM := "0"

			Else
				nResto		:= (11-nResto)
				cDV_NNUM	:= cValToChar(nResto)

			EndIf

	EndCase

	Restarea( aAreaSE1 )
	Restarea( aAreaSEE )
	Restarea( aArea )

Return( cDV_NNUM )
