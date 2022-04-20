#Include "TOTVS.CH"

/*/{Protheus.doc} SF2460I
Foi feito tratativa para gravar os pesos  dos pedidos liberados parcialmente
@type function Ponto de entrada
@version  1.00
@author Emerson Paiva / modificado por Fabio Carneiro e Mario Angelo
@since 25/05/2021
@return  character, sem retorno especifico
/*/

User Function SF2460I()

	Local aArea    := GetArea()
	Local aAreaSD2 := SD2->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())
	Local aPesos   := Array(2)
	Local aVolumes := Array(14, 2)
	Local cPVenda  := ""
	Local i        := 0
	Local k        := 1
	//Local lAtPes   := EQVldAlt(2) //.T.
	Local lAtVol   := EQVldAlt(1) //.T.
	Local nVal     := 0
	Local nValFd   := 0
	Local nPesoB:=0
	Local nPesoL:=0

	For i := 1 to Len(aVolumes)
		aVolumes[i, 1] := ""
		aVolumes[i, 2] := 0
	Next i

	aPesos[1] := 0
	aPesos[2] := 0

	//³ Atualiza SF2 com dados do SB1 conforme lctos SD2
	SD2->(dbSetOrder(3))	//Nota Fiscal + Série
	SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE))

	While SD2->(!EOF()) .And. SD2->D2_DOC == SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE

		cPVenda   := ""
		//MsgAlert("Dentro While: " + SD2->D2_COD)
		cPVenda := SD2->D2_PEDIDO
		cCampo  := ""
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))

		cCampo := Iif((Subs(SB1->B1_GRUPO, 1, 1) != "3" .And. SB1->B1_GRUPO != "1300") .And. SB1->B1_TIPO == "PA", "SB1->B1_SEGUM", "SB1->B1_UM")

		nPos0  := Ascan(aVolumes, {|x| &cCampo $ x[1]})

		//Alterado 19/03/18 nVal   := Iif((Subs(SB1->B1_GRUPO, 1, 1) != "3" .And. SB1->B1_GRUPO != "1300") .And. SB1->B1_TIPO == "PA",(SD2->D2_QUANT / SB1->B1_PESO), SD2->D2_QUANT)
		///nVal   := Iif((Subs(SB1->B1_GRUPO, 1, 1) != "3" .And. SB1->B1_GRUPO != "1300") .And. SB1->B1_TIPO == "PA",Iif(SB1->B1_TIPCONV == "D",SD2->D2_QUANT / SB1->B1_CONV, SD2->D2_QUANT * SB1->B1_CONV), SD2->D2_QUANT)

		If AllTrim( SB1->B1_UM ) == "KG" .And. AllTrim( SB1->B1_SEGUM ) <> "KG" .And. SB1->B1_TIPO == "PA" .And. !Empty( SB1->B1_SEGUM ) .And. SB1->B1_CONV <> 0
			nVal   := Iif(SB1->B1_TIPCONV == "D", SD2->D2_QUANT / SB1->B1_CONV, SD2->D2_QUANT * SB1->B1_CONV)
		Else
			nVal := Iif((Subs(SB1->B1_GRUPO, 1, 1) != "3" .And. SB1->B1_GRUPO != "1300") .And. SB1->B1_TIPO == "PA",Iif(SB1->B1_TIPCONV == "D",SD2->D2_QUANT / SB1->B1_CONV, SD2->D2_QUANT * SB1->B1_CONV), SD2->D2_QUANT)
		EndIf

		//Tratamento de Fardos - Qualyvinil/Multicores (Hardcode)
		If Subs(SB1->B1_GRUPO, 1, 1) $ "3/4" .And. SB1->B1_UM $ "GL#PT"
			If Subs(AllTrim(SB1->B1_COD), -2) == "06" .Or. SubStr(AllTrim(SB1->B1_COD),1,8) $ ("7770.909/7770.910") // tratamento caixa somente para o alcool - 14/04/2021
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
				Else
					nValFd := ((nVal - (nVal % 6)))/6
					nVal   := nVal % 6
				EndIf
			EndIf

			If nValFd > 0
				If nPos1 == 0
					aVolumes[k, 1]     := If(Subs(AllTrim(SB1->B1_COD), -2) == "06", "CX", "FD")
					aVolumes[k, 2]     := nValFd
					//aPesos[1]          += aVolumes[k, 2] * SB1->B1_PESO * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
					//aPesos[2]          += aVolumes[k, 2] * SB1->B1_PESBRU * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
					k++
				Else
					aVolumes[nPos1, 2] += nValFd
					//aPesos[1]          += nValFd * SB1->B1_PESO * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
					//aPesos[2]          += nValFd * SB1->B1_PESBRU * Iif(&cCampo == "GL", 4, Iif(!Subs(AllTrim(SB1->B1_COD), -2) $ "02|06", 6, 12))
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

			//FIM DA ALTERACAO 05/11/18
		Else
			//Tratamento Default
			If nVal > 0
				If nPos0 == 0
					aVolumes[k, 1]     := &(cCampo)
					aVolumes[k, 2]     := nVal
					//	aPesos[1]          += SD2->D2_QUANT	* SB1->B1_PESO		//Alterado 19/03/18 aVolumes[k, 2] * SB1->B1_PESO
					//	aPesos[2]          += SD2->D2_QUANT	* SB1->B1_PESBRU	//Alterado 19/03/18 aVolumes[k, 2] * SB1->B1_PESBRU
					k++
				Else
					aVolumes[nPos0, 2] += nVal
					//	aPesos[1]          += SD2->D2_QUANT	* SB1->B1_PESO		//Alterado 19/03/18 nVal * SB1->B1_PESO
					//	aPesos[2]          += SD2->D2_QUANT	* SB1->B1_PESBRU	//Alterado 19/03/18 nVal * SB1->B1_PESBRU
				EndIf
			EndIf

		EndIf

		nPesoL+=SD2->D2_QUANT * SB1->B1_PESO
		nPesoB+=SD2->D2_QUANT * SB1->B1_PESBRU

		SD2->(dbSkip())

	EndDo

	If lAtVol

		Reclock("SF2",.F.)

		SF2->F2_ESPECI1 := aVolumes[1][1]
		SF2->F2_VOLUME1 := aVolumes[1][2]
		SF2->F2_ESPECI2 := aVolumes[2][1]
		SF2->F2_VOLUME2 := aVolumes[2][2]
		SF2->F2_ESPECI3 := aVolumes[3][1]
		SF2->F2_VOLUME3 := aVolumes[3][2]
		SF2->F2_ESPECI4 := aVolumes[4][1]
		SF2->F2_VOLUME4 := aVolumes[4][2]
		SF2->F2_ESPECI5 := aVolumes[5][1]
		SF2->F2_VOLUME5 := aVolumes[5][2]
		SF2->F2_ESPECI6 := aVolumes[6][1]
		SF2->F2_VOLUME6 := aVolumes[6][2]
		SF2->F2_ESPECI7 := aVolumes[7][1]
		SF2->F2_VOLUME7 := aVolumes[7][2]
		
		SF2->( Msunlock() )

	EndIf

	RecLock("SF2",.F.)
	If nPesoB <> SF2->F2_PBRUTO
		SF2->F2_PBRUTO  := nPesoB
	End
	If nPesoL <> SF2->F2_PLIQUI
		SF2->F2_PLIQUI := nPesoL
	End
	MsUnLock()

	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aArea)

Return

/*/{Protheus.doc} EQVldAlt
Valida recalculo de Peso e Volume peloPonto de Entrada
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 14/10/2021
@param nTipo, numeric,1 = Volume / Especie  2 = Peso Liquido e Peso Bruto
@return Logical, Seguindo o processo
/*/
Static Function EQVldAlt(nTipo)

	Local lRet 		:= .T.

	Local cMVEQAVol	:= GetMv("MV_XEQAVOL",,"") // Indica Operações que não serão considerados para recalculo de volume
	Local cMVEQAPes	:= GetMv( "MV_XEQAPES",, "")  // Indica Operações que não serão considerados para recalculo de peso
	Local aAreaSC5 	:= SC5->(GetArea())

	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+SC9->C9_PEDIDO))

		If nTipo == 1 .And. SC5->C5_XOPER $ cMVEQAVOL
			lRet := .F.
		ElseIf nTipo == 2 .And. SC5->C5_XOPER $ cMVEQAPES
			lRet := .F.
		Endif

	EndIf

	RestArea(aAreaSC5)

Return lRet

