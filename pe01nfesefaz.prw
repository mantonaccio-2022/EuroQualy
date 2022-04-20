/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada na NFSEFAZ para ajuste de alguma informação necessaria
@type function Processamento
@version 1.00
@author mario.antonaccio
@since 06/08/2020
@return array, array com as informações ajustadas
/*/

User Function PE01NFESEFAZ()
	//aParam := {aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp,aEntrega,aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,AdetPag}
	Local aParam:=PARAMIXB
	Local _aArea   		:= {}
	Local _aAlias  		:= {}
	Local cMsg:=""
	Local cMsgPV:=" "
	Local cCodCli  as Character
	Local cGrpCli  as Character
	Local cLojaCli as Character
	Local nJ
	Local _cAlias := GetNextAlias()
	Local cMensONU:=SUPERGETMV("EQ_MENSONU", .F., "ONU")
	Local cEntr:=" "
	/*
		aProd		:= aParam[1]
		cMensCli	:= aParam[2]
		cMensFis	:= aParam[3]
		aDest 		:= aParam[4]
		aNota 		:= aParam[5]
		aInfoItem	:= aParam[6]
		aDupl		:= aParam[7]
		aTransp		:= aParam[8]
		aEntrega	:= aParam[9]
		aRetirada	:= aParam[10]
		aVeiculo	:= aParam[11]
		aReboque	:= aParam[12]
		aNfVincRur	:= aParam[13]
		aEspVol     := aParam[14]
		aNfVinc		:= aParam[15]
		aDetPag		:= aParam[16]
		aObsCont    := aParam[17]'
		aProcRef    := aParam[18]
		aMed 		:= aParam[19]
		aLote 		:= aParam[20]
	*/

	CtrlArea(1,@_aArea,@_aAlias,{"SA1","SA2","SA3","SF2","SF1","SD2","SD1","SF4","SB1","SX5","SF3","SFT"}) // GetArea

	If aParam[5][4] == "1"  //Saida  = 1
		
		//Restricao de Entrega - Msg Cliente
		If !Empty(AllTrim(SF2->F2_CLIENT)) .And. !Empty(AllTrim(SF2->F2_LOJENT))
			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1")+SF2->F2_CLIENT+SF2->F2_LOJENT))
			cCodCli	:=SF2->F2_CLIENT
			cLojaCli:=SF2->F2_LOJENT
			cGrpCli	:=SA1->A1_GRPVEN
		Else
			SA1->(dbSetOrder(1))
			SA1->(MsSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
			cCodCli	:=SF2->F2_CLIENTE
			cLojaCli:=SF2->F2_LOJA
			cGrpCli	:=SA1->A1_GRPVEN
		EndIf

		//Endereço Entrega
		cEntr := AllTrim(SA1->A1_ENDENT) + "-" +  AllTrim(SA1->A1_BAIRROE) + "-" + AllTrim(SA1->A1_MUNE) + "-" + SA1->A1_ESTE

		DAD->(dbSetOrder(2))
		If DAD->(DbSeek(SF2->F2_FILIAL + cGrpCli + cCodCli + cLojaCli))
			DAE->(DbSetOrder(1))  				// tabela de restrição x calendário
			If  DAE->(DbSEEK(DAD->DAD_FILIAL + DAD->DAD_CODIGO))
				While DAE->DAE_FILIAL == DAD->DAD_FILIAL .and. DAE->DAE_CODIGO == DAD->DAD_CODIGO
					DAA->(DbSetOrder(1))    		// tabela de Calendário
					DAA->(DbSEEK(DAE->DAE_FILIAL + DAE->DAE_CODCAL))

					cMsg += "CLIENTE "+Iif(DAE->DAE_REGRA = '2',"NÃO","")+ " recebe mercadorias de "
					cMsg += Alltrim( DAA->DAA_DESCRI ) + " "
					cMsg += "das " + DAE->DAE_HRINI + " até as " + DAE->DAE_HRFIM + "  "
					DAE->(DbSkip())
				End
			End
		End

		If !Empty(cMsg)
			aParam[02]+=" "+Alltrim(cMsg)
		End
		// Fim restricao de Entrega

		// Mensagem Pedido de Venda - Msg Cliente
		cMsgPV:= "  "	//Adicionado Euroamerican 11/06/2018

		lOnu := Left(cFilAnt,2) <> "01"

		If lOnu

			// Pega Formula de Aramazenamento ONU
			SM4->(dbSetOrder(1))
			If SM4->(dbSeek(xFilial("SM4")+cMensONU))
				If ! ( FORMULA(cMensONU) $ aParam[02])
					aParam[02]+= IIf(Len(aParam[02]) > 0, " ","") +AllTRIM(Formula(cMensONU))
				End
			End

			For nJ:=1 to Len(aParam[01])
				If  ! Empty(aParam[01][nj][52])
					aParam[01][nj][04]:=AllTrim(aParam[01][nj][04])+" *** "+AllTrim(AllTrim(aParam[01][nj][52]))
					aParam[01][nj][52]:=" "
				Else
					/// Verifica se tem no cadastro de Complemento
					SB5->(DbSetOrder(1))
					SB5->(DbSeek(xFilial("SB5")+aParam[1][nJ][2]))
					If !Empty(SB5->B5_ONU)
						aParam[01][nj][04]:=AllTrim(aParam[01][nj][04])+" *** "+AllTrim(AllTrim(aParam[01][nj][52]))
						//lIMPO  a mensagem ONU ja que esta na descrição
						aParam[01][nj][52]:=" "
						//Senao Pega a Menpad do Produto
					Else
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1")+aParam[1][nJ][2]))
						If !Empty(SB1->B1_MENPAD)
							aParam[01][nj][04]:=AllTrim(aParam[01][nj][04])+" *** "+AllTrim(FORMULA(SB1->B1_MENPAD))
						EndIf
					End
				End
			Next

		End

		BeginSql alias _cAlias
			SELECT
				SD2.D2_PEDIDO AS PEDIDO,
				COUNT(*) AS CONT
			FROM
				%Table:SD2% SD2
			WHERE
				SD2.D2_FILIAL = %Exp:xFilial("SD2")%
				AND SD2.D2_DOC = %Exp:aParam[5][2]%
				AND SD2.D2_SERIE = %Exp:aParam[5][1]%
				AND SD2.%NotDel%
			GROUP BY
				SD2.D2_PEDIDO
		EndSql

		(_cAlias)->(DbGoTop())

		cMsgPV=""
		While(!(_cAlias)->(EoF()))

			cMsgPV+=If(Empty(cMsgPV),""," / ")+AllTrim((_cALias)->PEDIDO)

			(_cALias)->(dbSkip())
		End
		(_cAlias)->(dbCloseArea())

		//Se tiver Endereço de entrega cadastrado, imprime
		If !Empty(cEntr)
			aParam[02]+= IIf(Len(aParam[02]) > 0, " ","") +" *** ENDEREÇO DE ENTREGA: "+Alltrim(cEntr)+" **"
		End
	
		// Imprime os pedidos de venda		
		If !Empty(cMsgPV)
			aParam[02]+=IIf(Len(aParam[02]) > 0, " ","") + "| "+"Pedido(s) de Venda: "+AllTrim(cMsgPV)+" ||"
		End	
		
		// NOTA DE ENTRADA
	ElseIf aParam[05][04] == "0"  //Entrada = 0

		// customização - inicio
		If SF1->(FieldPos("F1_MENNOTA"))>0 .and. !Empty(SF1->F1_MENNOTA)
			If !AllTrim(SF1->F1_MENNOTA) $ aParam[02]
				aParam[02]+=IIf(Len(aParam[02]) > 0, " ","") + AllTrim(SF1->F1_MENNOTA)
			EndIf
		EndIf

		If SF1->(FieldPos("F1_MENPAD"))>0 .and. !Empty(SF1->F1_MENPAD)
			If ! AllTrim(FORMULA(SF1->F1_MENPAD)) $ aParam[03]
				aParam[03]+=IIf(Len(aParam[03]) > 0, " ","")  + AllTrim(FORMULA(SF1->F1_MENPAD))
			EndIf
		EndIf
		// customização - fim

	End

	//Limpa caracteres especiais
	//MSG Cliente
	aParam[2]:=NoAcento(aParam[2])
	//Msg Fiscal
	aParam[3]:=NoAcento(aParam[3])
	//Retorna areas
	CtrlArea(2,_aArea,_aAlias)
	//Final("Encerrando teste")

Return(aParam)

/*/{Protheus.doc} CtrlArea
 Static Function auxiliar no GetArea e ResArea retornando
 o ponteiro nos Aliases descritos na chamada da Funcao.
@type function Processamento
@version  1.00
@author Ricardo Mansano  - mario.antonaccio
@since 18/05/2005 - 10/01/2022
@param _nTipo, numeric, 1=GetArea / 2=RestArea
@param _aArea, array, Array passado por referencia que contera GetArea
@param _aAlias, Array, Array passado por referencia que contera {Alias(), IndexOrd(), Recno()}
@param _aArqs, Array,Array com Aliases que se deseja Salvar o GetArea
@return ccharacter, sem retorno
/*/
Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)
	Local _nN
	// Tipo 1 = GetArea()
	If _nTipo == 1
		_aArea   := GetArea()
		For _nN  := 1 To Len(_aArqs)
			DbSelectArea(_aArqs[_nN])
			AAdd(_aAlias,{ Alias(), IndexOrd(), Recno()})
		Next
		// Tipo 2 = RestArea()
	Else
		For _nN := 1 To Len(_aAlias)
			DbSelectArea(_aAlias[_nN,1])
			DbSetOrder(_aAlias[_nN,2])
			DbGoto(_aAlias[_nN,3])
		Next
		RestArea(_aArea)
	End
Return

/*/{Protheus.doc} NoAcento
Retira caracteres especiais da String  Copia do NFESEFAZ
@type function Processamento
@version  1.00
@author Microsiga - mario.antonaccio
@since 23/06/2018 - 10/01/2022
@param cString, character, String a ser retirada os acentos
@return character, string sem caracteres especiais/Acentuação
/*/
STATIC FUNCTION NoAcento(cString)
	Local cChar  := ""
	Local nX     := 0
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
	Local cTio   := "ãõÃÕ"
	Local cCecid := "çÇ"
	Local cMaior := "&lt;"
	Local cMenor := "&gt;"

	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			End
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			End
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			End
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			End
			nY:= At(cChar,cTio)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			End
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			End
		End
	Next

	If cMaior$ cString
		cString := strTran( cString, cMaior, "" )
	End
	If cMenor$ cString
		cString := strTran( cString, cMenor, "" )
	End

	cString := StrTran( cString, CHR(13)+CHR(10), " " )

	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|'
			cString:=StrTran(cString,cChar,".")
		End
	Next nX
Return cString
