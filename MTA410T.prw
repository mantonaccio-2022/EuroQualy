#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "tryexception.ch"

#define ENTER chr(13) + chr(10)


/*/{Protheus.doc}MTA410T
//Ponto de entrada para tratamento pedido de vendas 
@author QualyCryl 
@since 02/01/2013
@version 1.0
/*/
User Function MTA410T()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aArea     := GetArea()
Local aAreaSA3  := SA3->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())
Local aAreaSC7  := SC7->(GetArea())
Local aAreaSC9  := SC9->(GetArea())
Local aAreaDA0  := DA0->(GetArea())
Local aAreaDA1  := DA1->(GetArea())
Local aAreaSCJ  := SCJ->(GetArea())

Local cNomeCli  := ""
Local cPVenda   := ""
Local dEntreg   := ""
Local aVolumes  := Array(14, 2)
Local aPesos    := Array(2)
Local i         := 0
Local k         := 1
Local nVal      := 0

Local lAtVol    := EQVldAlt(1) //.T.
Local lAtPes    := EQVldAlt(2) //.T.

Local nComisOri := M->C5_COMIS1
Local nComiss   := 0	//M->C5_COMIS1  Alterado 05/02/18

Local nPrvFrete := 0
Local cEstFrete := ""
Local cNumOrc   := ""

Local oError	:= Nil
Local lRet      := .T.
Local cQuery    := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Funcao para gerar matriz com dados de especies, volumes e pesos      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len(aVolumes)
	aVolumes[i, 1] := ""
	aVolumes[i, 2] := 0
Next i

aPesos[1] := 0
aPesos[2] := 0


dbSelectArea("SC5")

cPVenda  := SC5->C5_NUM
dEntreg  := SC5->C5_FECENT
//cPedCli  := SC5->C5_PEDCLI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza SC6 conforme Data Informada no arquivo SC5        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SC6->(dbSetOrder(1))
SC6->(MsSeek(xFilial("SC6") + cPVenda))

SA3->(dbSetOrder(1))
SA3->(MsSeek(xFilial("SA3") + SC5->C5_VEND1))

nComiss   := SA3->A3_COMIS	 //Adicionado 09/04/18

nCom    := 0
nPond   := 0
nComAtu := 0
nComNew := 0

While !EOF("SC6") .And. SC6->C6_NUM == cPVenda

	If Empty(cNumOrc)
		cNumOrc := Subs(SC6->C6_PEDCLI, 1, 6)
	EndIf

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + SC6->C6_PRODUTO))

	cCampo := Iif((Subs(SB1->B1_GRUPO, 1, 1) != "3" .And. SB1->B1_GRUPO != "1300") .And. SB1->B1_TIPO == "PA", "SB1->B1_SEGUM", "SB1->B1_UM")

	nPos0  := Ascan(aVolumes, {|x| &cCampo $ x[1]})

	//Alterado 16/03/2018: nVal   := Iif((Subs(SB1->B1_GRUPO, 1, 1) != "3" .And. SB1->B1_GRUPO != "1300") .And. SB1->B1_TIPO == "PA",(SC6->C6_QTDVEN / SB1->B1_PESO), SC6->C6_QTDVEN)
	// EP - Neste caso, não respeitar o cadastro do grupo do produto, que provavelmente está errado...
	//      Se primeira UM quilo e segunda, diferente, CONVERTER:
	If AllTrim( SB1->B1_UM ) == "KG" .And. AllTrim( SB1->B1_SEGUM ) <> "KG" .And. SB1->B1_TIPO == "PA" .And. !Empty( SB1->B1_SEGUM ) .And. SB1->B1_CONV <> 0
		nVal   := Iif(SB1->B1_TIPCONV == "D", SC6->C6_QTDVEN / SB1->B1_CONV, SC6->C6_QTDVEN * SB1->B1_CONV)
		cCampo := "SB1->B1_SEGUM"
		nPos0  := Ascan(aVolumes, {|x| &cCampo $ x[1]})
	Else
		nVal := Iif((Subs(SB1->B1_GRUPO, 1, 1) != "3" .And. SB1->B1_GRUPO != "1300") .And. SB1->B1_TIPO == "PA",Iif(SB1->B1_TIPCONV == "D",SC6->C6_QTDVEN / SB1->B1_CONV, SC6->C6_QTDVEN * SB1->B1_CONV), SC6->C6_QTDVEN)
	EndIf

	//Tratamento de Fardos - Qualyvinil (Hardcode)
	If Subs(SB1->B1_GRUPO, 1, 1) == "3" .And. SB1->B1_UM $ "GL#PT"
		If Subs(AllTrim(SB1->B1_COD), -2) == "06" .And. SubStr(AllTrim(SB1->B1_COD),1,8) $ ("7770.909/7770.910") // tratamento caixa somente para o alcool - 14/04/2021 
			nPos1 := Ascan(aVolumes, {|x| "CX" $ x[1]})
		Else
			nPos1 := Ascan(aVolumes, {|x| "FD" $ x[1]})
		EndIf

		If &cCampo == "GL"
			nValFd := ((nVal - (nVal % 4)))/4
			nVal   := nVal % 4
		ElseIf &cCampo == "PT"
			If Subs(AllTrim(SB1->B1_COD), -2) $ "02|06"
				nValFd := ((nVal - (nVal % 12)))/12
				nVal   := nVal % 12
			Else  //If Subs(AllTrim(SB1->B1_COD), -2) != "02"
				nValFd := ((nVal - (nVal % 6)))/6
				nVal   := nVal % 6
			EndIf
		EndIf
		
		If nValFd > 0

			If nPos1 == 0
				aVolumes[k, 1]     := If(Subs(AllTrim(SB1->B1_COD), -2) == "06", "CX", "FD")
				aVolumes[k, 2]     := nValFd
				aPesos[1]          += aVolumes[k, 2] * SB1->B1_PESO * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
				aPesos[2]          += aVolumes[k, 2] * SB1->B1_PESBRU * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
				k++
			Else
				aVolumes[nPos1, 2] += nValFd
				aPesos[1]          += nValFd * SB1->B1_PESO * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
				aPesos[2]          += nValFd * SB1->B1_PESBRU * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
			EndIf

		EndIf
		
		If nVal > 0

			If nPos0 == 0
				aVolumes[k, 1]     := &(cCampo)
				aVolumes[k, 2]     := nVal
				k++
			Else
				aVolumes[nPos0, 2] += nVal
			EndIf
			
		EndIf

	Else 
		//Tratamento Default
		// alterado em 25/03/2021, para n�o duplicar os pesos para os produtos com final 02 e 06
		If nVal > 0
			If nPos0 == 0
				aVolumes[k, 1]     := &(cCampo)
				aVolumes[k, 2]     := nVal
				aPesos[1]          += SC6->C6_QTDVEN * SB1->B1_PESO		//Alterado 16/03/2018 aVolumes[k, 2] * SB1->B1_PESO
				aPesos[2]          += SC6->C6_QTDVEN *	SB1->B1_PESBRU 	//Alterado 16/03/2018 aVolumes[k, 2] * SB1->B1_PESBRU
				k++
			Else
				aVolumes[nPos0, 2] += nVal
				aPesos[1]          += SC6->C6_QTDVEN * SB1->B1_PESO 	//Alterado 16/03/2018 nVal * SB1->B1_PESO
				aPesos[2]          += SC6->C6_QTDVEN * SB1->B1_PESBRU	//Alterado 16/03/2018 nVal * SB1->B1_PESBRU
				
			EndIf
		EndIf
	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Campos Itens Pedido Venda                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC6")
	RecLock("SC6",.F.)

	// Tratamento para gravar peso oriundos do  or�amnento que � gerado o pedido de vendas 
	If SC6->C6_XPESBUT = 0 
		SC6->C6_XPESBUT := SC6->C6_QTDVEN * SB1->B1_PESBRU	
	EndIf
	If SC6->C6_XPESLIQ = 0 
		SC6->C6_XPESLIQ := SC6->C6_QTDVEN * SB1->B1_PESO
	EndIf

	If SC5->C5_TIPO == "N"

			//Atualiza Segunda Unidade de Medida
			If SB1->B1_CONV > 0 .And. SC6->C6_UNSVEN == 0
				nQtdCalc := Iif ( SB1->B1_TIPCONV == 'D', SC6->C6_QTDVEN / SB1->B1_CONV, SC6->C6_QTDVEN * SB1->B1_CONV ) 
				If nQtdCalc > 0 
					SC6->C6_UNSVEN := nQtdCalc
				EndIf
			EndIf

			If !Empty(dEntreg) .And. Empty(SC6->C6_NOTA)
				SC6->C6_ENTREG := dEntreg
			EndIf

			
			If SB1->B1_TIPO != "PA"
				//SC6->C6_PRUNIT  := SC6->C6_PRCVEN
				If SC5->C5_TIPO == "N"
					SC6->C6_U_FATOR := 1
					SC6->C6_U_FTNET := 1
				EndIf
				SC6->C6_U_CUSTD := SC6->C6_PRCVEN
				SC6->C6_U_CTNET := SC6->C6_PRCVEN
				SC6->C6_U_PRNET := SC6->C6_PRCVEN

			Else
				//SC6->C6_PRUNIT  := SB1->B1_CUSTD
				If SC5->C5_TIPO == "N"
					SC6->C6_U_FATOR := Round(SC6->C6_PRCVEN/Iif(SB1->B1_CUSTD == 0 .Or. Subs(SB1->B1_GRUPO,1,1) == "X", SC6->C6_PRCVEN,(SB1->B1_CUSTD * 1.03)),2)
					SC6->C6_U_FTNET := Round(SC6->C6_PRCVEN/Iif(SB1->B1_CUSTNET == 0 .Or. Subs(SB1->B1_GRUPO,1,1) == "X", SC6->C6_PRCVEN,(SB1->B1_CUSTNET * 1.03)),2)
				EndIf
				SC6->C6_U_CUSTD := SB1->B1_CUSTD
				SC6->C6_U_CTNET := SB1->B1_CUSTNET

				// Grupo Empresa - Ajuste realizado (CG)

				// If cEmpAnt+cFilAnt $ "0200#0801"

				If cFilAnt $ "0200#0801"
					SC6->C6_U_PRNET := SC6->C6_PRCVEN  * (1 - (AliqICMS(SA1->A1_EST, SB1->B1_POSIPI)/100 + 0.0925)) //PIS + COFINS 9,25%
				Else
					SC6->C6_U_PRNET := SC6->C6_PRCVEN  * (1 - (AliqICMS(SA1->A1_EST, SB1->B1_POSIPI)/100 + 0.0365 + 0.0228))	//Alterado 20/01/17 - PIS + COFINS 3,65% e IRPJ + CSLL 2,28%
				EndIf

				DA1->(dbSetOrder(2))
				If DA1->(MsSeek(xFilial("DA1") + SC6->C6_PRODUTO + SC5->C5_TABELA))
					SC6->C6_ZPRCXTB	:= ROUND(((SC6->C6_PRCVEN /DA1->DA1_PRCVEN)-1)*100,2)
				EndIf

				SC6->C6_ZULTPVD	:= U_GETUPRVD(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC6->C6_PRODUTO,"V")
				SC6->C6_ZULTVND	:= U_GETUPRVD(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC6->C6_PRODUTO,"D")
			EndIf
		SC6->( MsUnlock() )

		// FS - Aviso que produto pode ser fracionado no calculo...
		If AllTrim( SB1->B1_UM ) == "KG" .And. AllTrim( SB1->B1_SEGUM ) <> "KG" .And. SB1->B1_TIPO == "PA" .And. !Empty( SB1->B1_SEGUM ) .And. SB1->B1_CONV <> 0
			If Mod( SC6->C6_QTDVEN, SB1->B1_CONV ) <> 0
				ApMsgInfo( "O item " + SC6->C6_ITEM + " possui quantidade divergente do fator de conversão, que podem gerar fracionamento no estoque de PA, verifique se a quantidade informada está realmente correta e será separada em embalagem específica e repessada!", "Atenção" )
			EndIf
		EndIf

		/* Removido 11/12/17
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao atualiza volumes para essa TES                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Subs(SC6->C6_PRODUTO, 1, 1) == "X"
			lAtVol := .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao atualiza peso para devolucao de compras                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SC5->C5_TIPO == "D" .And. SB1->B1_TIPO $ "MP#ME"
			lAtPes := .F.
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Data de Entrega no SC6                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SC6")
		RecLock("SC6",.F.)
			SC6->C6_ENTREG := dEntreg
			If Empty(SC6->C6_PEDCLI)
				SC6->C6_PEDCLI := cPedCli
			EndIf
			If SB1->B1_TIPO != "PA"
				SC6->C6_PRUNIT  := SC6->C6_PRCVEN
				SC6->C6_U_FATOR := 1
				SC6->C6_U_CUSTD := SC6->C6_PRCVEN
				SC6->C6_U_FTNET := 1
				SC6->C6_U_CTNET := SC6->C6_PRCVEN
				SC6->C6_U_PRNET := SC6->C6_PRCVEN
			EndIf
		SC6->( MsUnlock() )
		*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Comissoes - Euroamerican                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		// Grupo Empresa - Ajuste realizado (CG)

		// If SC5->C5_TIPO == "N" .And. cEmpAnt + cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")


		If SC5->C5_TIPO == "N" .And. cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

			If Subs(SC6->C6_PRODUTO, 1, 1) == '8' .And. Subs(SC6->C6_PRODUTO, 4, 1) == '.'

				If SA3->A3_TIPO $ "P"	//Adicionado comissão adicional para representantes (Parceiros) se venda acima preço tabela
					If SC6->C6_ZPRCXTB >= 1.2 .And. SC6->C6_ZPRCXTB < 2.4
						nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (1.0 / 100)
					ElseIf SC6->C6_ZPRCXTB >= 2.4
						nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (2.0 / 100)
					EndIf
				Else
					nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (0.5 / 100)
				EndIf

			ElseIf Alltrim(SC6->C6_PRODUTO) $ "ME.0044"

				nCom += 0

			Else

				nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (nComiss / 100)

			EndIf

			nPond += SC6->C6_PRCVEN * SC6->C6_QTDVEN

			/*nDescFrt := SC5->C5_VLR_FRT / SC6->C6_QTDVEN

			If SB1->B1_TIPO == "PA"

				nComAtu += (SC6->C6_PRCVEN - nDescFrt) * SC6->C6_QTDVEN * (SA3->A3_COMIS/100)

				If (SC6->C6_PRCVEN - nDescFrt) < (SB1->B1_CUSTD * 1.6 * 1.03) .And. SA3->A3_COMIS > 0.40
					nComNew += (SC6->C6_PRCVEN - nDescFrt) * SC6->C6_QTDVEN * (SA3->A3_COMIS / 200)
				Else
					nComNew += (SC6->C6_PRCVEN - nDescFrt) * SC6->C6_QTDVEN * (SA3->A3_COMIS/100)
				Endif

			EndIf*/

		//EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Comissoes - Qualyvinil e CDs                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		// Grupo Empresa - Ajuste realizado (CG)

		// If SC5->C5_TIPO == "N" .And. cEmpAnt + cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

		ElseIf SC5->C5_TIPO == "N" .And. cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

			If SB1->B1_TIPO == "PA" //.And. ( SubStr(SB1->B1_GRUPO,1,1) == "3" .Or. SubStr(SB1->B1_GRUPO,1,2) == "13" )

				DA1->(dbSetOrder(2))
				If DA1->(MsSeek(xFilial("DA1") + SC6->C6_PRODUTO + SC5->C5_TABELA))
					dbSelectArea("SC6")
					Reclock("SC6",.F.)
						SC6->C6_PRUNIT := DA1->DA1_PRCVEN
					SC6->( MsUnlock() )
				Else
					MsgStop("Produto " + Alltrim(SB1->B1_COD) + " - " + Alltrim(SB1->B1_DESC) + " não está na tabela de preços " + SC5->C5_TABELA + "." + ENTER +;
							"Verifique se a tabela de preco vinculada ao cliente esta correta ou faca a inclusão do produto na atual.")
				Endif

				If SA3->A3_COMIS >= DA1->DA1_COMISS .And. DA1->DA1_COMISS > 0	//Alterado 04/07/2017 SC6->C6_PRCVEN <= DA1->DA1_PRCMIN
					nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (DA1->DA1_COMISS / 100)
				Else
					nCom += SC6->C6_PRCVEN * SC6->C6_QTDVEN * (nComiss / 100) //(SA3->A3_COMIS / 100)
				Endif

				nPond += SC6->C6_PRCVEN * SC6->C6_QTDVEN

			EndIf

		EndIf

	EndIf

	dbSelectArea("SC6")
	dbSkip()

Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Comissao - Reajusta o valor conforme o teto                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If SC5->C5_TIPO == "N" .And. 100*(nCom/nPond) > 0 //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440") //.And. cEmpAnt + cFilAnt $ "0203#0108#0107#0304#0801"
	nComiss := 100*(nCom/nPond)
EndIf


// Grupo Empresa - Ajuste realizado (CG)

// If SC5->C5_TIPO == "N" .And. cEmpAnt + cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

If SC5->C5_TIPO == "N" .And. cFilAnt $ "0200#0201#0204#0205" //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")

	//nComiss := (SA3->A3_COMIS * nComNew) / nComAtu

	If nComiss > 5
		nComiss := 5
	EndIf

	// Verifica Piso e Teto da Comissao
	If(SA3->A3_TPCOMIS == "T" .And. nComiss > SA3->A3_COMIS) .Or. SA3->A3_TPCOMIS == "F"
		nComiss := SA3->A3_COMIS
	ElseIf SA3->A3_COMINF != 0 .And. nComiss < SA3->A3_COMINF
		nComiss := SA3->A3_COMINF
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Comissao - Verifica comissao por cliente                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

If SC5->C5_TIPO == "N" .And. SA1->A1_COMIS != 0 //.And. !(Upper(Alltrim(FunName())) $ "YFATM001#MATA440")
	If nComiss > SA1->A1_COMIS
		nComiss := SA1->A1_COMIS
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula valor do frete previsto                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SC5->C5_TIPO == "N"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Qualyvinil                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	// Grupo Empresa - Ajuste realizado (CG)
	
	// If cEmpAnt + cFilAnt $ "0203#0304#0801#0803"

	If cFilAnt $ "0203#0304#0801#0803"

		If SC5->C5_TRANSP != "000002"

			If SC5->C5_TRANSP == "000001"
				//+----------------------------------------------------------------------------
				//| NOSSO CARRO / AGREGADO
				//+----------------------------------------------------------------------------
				cEstFrete := AllTrim(Upper(SA1->A1_ESTE)) //AllTrim(Upper(SC5->C5_ESTREC))
			Else
				//+----------------------------------------------------------------------------
				//| TRANSPORTADORA / REDESPACHO
				//+----------------------------------------------------------------------------
				cEstFrete := Posicione("SA4", 1, xFilial("SA4")+SC5->C5_TRANSP, "A4_EST")
			EndIf

			//+----------------------------------------------------------------------------
			//| FRETE/KG: 0.07 - SAO PAULO | 0.12 - OUTROS ESTADOS
			//+----------------------------------------------------------------------------
			If AllTrim(Upper(cEstFrete)) == "SP"
				nPrvFrete := ( aPesos[2] * 0.07 )
			Else
				nPrvFrete := ( aPesos[2] * 0.12 )
			EndIf

		EndIf

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Outras empresas                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPrvFrete := M->C5_FRETPRV
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Alteracao de Comissao                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
nPCNota  := U_FATM018(.F., 2)[2]
nNotaMin := GetMV("MV_NOTAMIN")
SCJ->(dbSetOrder(1))
SCJ->(dbSeek(xFilial("SCJ") + cNumOrc))
If SCJ->(Found()) .And. nPCNota < nNotaMin .And. ("012-" $ SCJ->CJ_APROV)
	nNovaCom := (nPCNota * nComiss)/5
	If nNovaCom < nComiss
		nComiss := nNovaCom
	EndIf
EndIf
*/
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se comissao foi alterado manualmente e mantem o   ³
//³ percentual - CHAMADO 017566                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEmpAnt $ "03#08" .And. AT("[ALTERACAO DE COMISSAO]", Upper(RTrim(SC5->C5_OBS))) > 0
	nComiss := nComisOri
EndIf	*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza SC5                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

cQuery := "SELECT SUM(C6_XPESBUT) AS PESOBRU, SUM(C6_XPESLIQ) AS PESOLIQ  FROM "+RetSqlName("SC6")+" SC6 "
cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += " AND C6_NUM  = '"+AllTrim(cPVenda)+"' "
cQuery += " AND C6_NOTA = ' '  "
cQuery += " AND SC6.D_E_L_E_T_ = ' '  "

TcQuery cQuery ALIAS "TRB1" NEW

TRB1->(DbGoTop())

Reclock("SC5",.F.)

If lAtVol

	SC5->C5_ESPECI1 := aVolumes[1][1]
	SC5->C5_VOLUME1 := aVolumes[1][2]
	SC5->C5_ESPECI2 := aVolumes[2][1]
	SC5->C5_VOLUME2 := aVolumes[2][2]
	SC5->C5_ESPECI3 := aVolumes[3][1]
	SC5->C5_VOLUME3 := aVolumes[3][2]
	SC5->C5_ESPECI4 := aVolumes[4][1]
	SC5->C5_VOLUME4 := aVolumes[4][2]
	//SC5->C5_ESPECI5 := aVolumes[5][1]
	//SC5->C5_VOLUME5 := aVolumes[5][2]
	//SC5->C5_ESPECI6 := aVolumes[6][1]
	//SC5->C5_VOLUME6 := aVolumes[6][2]
	//SC5->C5_ESPECI7 := aVolumes[7][1]
	//SC5->C5_VOLUME7 := aVolumes[7][2]

    If lAtPes

		If aPesos[1] == TRB1->PESOLIQ .And. aPesos[2] == TRB1->PESOBRU 

			SC5->C5_PESOL   := aPesos[1]
			SC5->C5_PBRUTO  := aPesos[2]
		
		Else 

			SC5->C5_PESOL   := TRB1->PESOLIQ
			SC5->C5_PBRUTO  := TRB1->PESOBRU
		
		Endif 	
	
	EndIf

EndIf

//SC5->C5_ALTERA  := cUserName
//SC5->C5_TIME    := DtoC(dDataBase) + "-" + Time()

If !Empty(SC5->C5_VEND2) .And. nComiss > 0.5
	SC5->C5_COMIS1  := nComiss - 0.5
	SC5->C5_COMIS2  := 0.5
Else
	SC5->C5_COMIS1  := nComiss
	SC5->C5_COMIS2  := 0
EndIf

SC5->C5_FRETPRV := nPrvFrete
SC5->( Msunlock() )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Comissões Euroamerican - Desconto % baseado em preço tabel ³
//³ Solicitação Alessandra Monea 05/09/17                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// Grupo Empresa - Ajuste realizado (CG)

// If cEmpAnt $ "02" .And. SA3->A3_COMIS > 1.5 .And. !SC5->C5_CLIENTE$"000300#000301#000302#032729#035059#035055#" .And. !SC5->C5_VEND1 $ "000297"  //Clientes Klabin/Orsa comissão 2.5 deve estar cadastro Cliente

If Left(cFilAnt,2) $ "02" .And. SA3->A3_COMIS > 1.5 .And. !SC5->C5_CLIENTE$"000300#000301#000302#032729#035059#035055#" .And. !SC5->C5_VEND1 $ "000297"  //Clientes Klabin/Orsa comissão 2.5 deve estar cadastro Cliente

	BEGIN SEQUENCE

	cQry := " SELECT ISNULL(CAST((( 1 - (SUM(VALOR) / SUM(TOTPRCTBL)))*100) AS NUMERIC(7,2)),99) AS DESCONTO " + ENTER
	cQry += " FROM  " + ENTER
	cQry += " (
	cQry += "	SELECT	C6_VALOR VALOR,  " + ENTER
	cQry += "			(	SELECT DA1.DA1_PRCVEN FROM " + RetSqlName("DA1") + " DA1  " + ENTER
	cQry += " 				WHERE DA1.D_E_L_E_T_ = '' AND SC5.C5_TABELA = DA1.DA1_CODTAB AND SC5.C5_MOEDA = DA1.DA1_MOEDA AND SC6.C6_PRODUTO = DA1.DA1_CODPRO ) * C6_QTDVEN AS TOTPRCTBL " + ENTER
	cQry += " 	FROM   " + ENTER
	cQry += " 		" + RetSqlName("SC6") + " SC6 INNER JOIN  " + ENTER
	cQry += " 		" + RetSqlName("SC5") + " SC5 ON SC5.C5_NUM = SC6.C6_NUM AND SC5.C5_FILIAL = SC6.C6_FILIAL " + ENTER
	cQry += "	 WHERE   " + ENTER
	cQry += " 		SC6.D_E_L_E_T_ = ''    " + ENTER
	cQry += " 		AND SC5.D_E_L_E_T_ = ''  " + ENTER
	cQry += "		AND SC5.C5_TIPO NOT IN  ('C','I','P') " + ENTER
	cQry += " 		AND C6_FILIAL = '" + xFilial("SC6") + "'   " + ENTER
	cQry += "		AND C6_NUM = '" + SC5->C5_NUM + "'  " + ENTER
	cQry += " ) PEDIDOS  " + ENTER

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TRYEXCEPTION	//TRY EXCEPTION

	TCQUERY cQry NEW ALIAS QRY

	If !QRY->(EOF())

		If QRY->DESCONTO > 5.01 .And. QRY->DESCONTO < 10.01	//Considerando adicional 0.01 relativo a arredondamentos

			Reclock("SC5",.F.)

				SC5->C5_COMIS1  := nComiss * 0.75
				If !Empty(SC5->C5_VEND2)
					SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.75
				EndIf

			SC5->( Msunlock() )

		ElseIf QRY->DESCONTO > 10.01 .And. QRY->DESCONTO <= 50

			Reclock("SC5",.F.)

				SC5->C5_COMIS1  := nComiss * 0.5
				If !Empty(SC5->C5_VEND2)
					SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.5
				EndIf

			SC5->( Msunlock() )

		ElseIf QRY->DESCONTO > 50	//Preço de tabela não cadastrado

			Reclock("SC5",.F.)

				SC5->C5_COMIS1  := nComiss * 0.5
				If !Empty(SC5->C5_VEND2)
					SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.5
				EndIf

			SC5->( Msunlock() )

			MsgInfo("Preço de tabela não cadastrado! " + ENTER +;
						"Favor solicitar cadastramento para dar andamento no pedido! ",;
						"A comissão do vendedor zerá de 0% (zerada) quando não existir preço de tabela cadastrado.")

		EndIf

	EndIf

	CATCHEXCEPTION USING oError

		MsgInfo("Pedido com produto cadastrado mais de uma vez na tabela de precos, favor solicitar a correcao! COMISSAO SERA DESCONTADA EM 50% ATE CORRECAO!!!")
		lRet := .F.

		Reclock("SC5",.F.)
			SC5->C5_COMIS1  := nComiss * 0.5
			If !Empty(SC5->C5_VEND2)
				SC5->C5_COMIS2  := SC5->C5_COMIS2 * 0.5
			EndIf
		SC5->( Msunlock() )

	ENDEXCEPTION //END TRY

	END SEQUENCE

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Restaura Area de Trabalho                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TRB1") > 0
	TRB1->(DbCloseArea())
EndIf

RestArea(aAreaSCJ)
RestArea(aAreaSA3)
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSC7)
RestArea(aAreaSC9)
RestArea(aAreaDA0)
RestArea(aAreaDA1)
RestArea(aArea)

Return lRet

/*
Valida recalculo de Peso e Volume peloPonto de Entrada

nTipo: 	1 = Volume / Especie
		2 = Peso Liquido e Peso Bruto
*/

Static Function EQVldAlt(nTipo)

Local lRet 		:= .T.

Local cMVXEQAVol	:= GetMv("MV_XEQAVOL",,"") // Indica Operações que não serão considerados para recalculo de volume
Local cMVXEQAPes	:= GetMv( "MV_XEQAPES",, "")  // Indica Operações que não serão considerados para recalculo de peso

Local aAreaSC5 	:= SC5->(GetArea())

If nTipo == 1 .And. SC5->C5_XOPER $ cMVXEQAVOL
	lRet := .F.
ElseIf nTipo == 2 .And. SC5->C5_XOPER $ cMVXEQAPES
	lRet := .F.
Endif

RestArea(aAreaSC5)

Return lRet
