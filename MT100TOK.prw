#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TRYEXCEPTION.CH"

#define ENTER chr(13) + chr(10)
User Function MT100TOK

	Local aArea     	:= GetArea()
	Local aAreaSC7  	:= SC7->(GetArea())
	Local aAreaSA2  	:= SA2->(GetArea())
	Local aAreaSA1  	:= SA1->(GetArea())

	Local lRet      	:= .T.
	Local cQry      	:= ""

	Local cArqUsr		:= ""
	Local cArqSrv		:= ""

	Local oAuxXML		:= Nil
	Local cError   	 	:= ""
	Local cWarning  	:= ""
	Local lFound		:= .F.

	Local cPedido		:= ""
	Local cItemPC		:= ""
	Local cProduto		:= ""
	Local cQtde			:= ""

	Local cCICPath		:= "" //"\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"
	Local cCICMsg		:= ""
	Local cCICMsgAux	:= ""
	Local lEstoque      := .F. // FS - Validar se TES atualiza estoque e verificar se houve amarração com pesagem...
	Local lAmarra       := .F. // FS
	Local nLin          := 0   // FS
	Local cTES          := ""  // FS

	Local lDevSemRNC	:= .F.

	Local cXespec := GetMv( "MV_XESPEC" , ,"SPED#CTE#NFE#NFCF#CTR#NFS#NFSE#NFST#NFCEE#NFF#RPS#RECIB#INV#NFSC#NTST")

	Private oXML		:= Nil

	Private macroALIAS	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2", "SA1" )
	Private macroEST	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2->A2_EST", "SA1->A1_EST" )
	Private macroCLIFOR	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2->A2_COD", "SA1->A1_COD" )
	Private macroLOJA	:= IIf( AllTrim(cTipo) $ "N#C#I#P", "SA2->A2_LOJA", "SA1->A1_LOJA" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//| Este P.E. ?excutado na utilizacao da funcao RETORNAR e algumas das ?
	//| regras retornavam falsa e a tela de documento de entrada nao era    ?
	//| exibida ao usuario.                                                 ?
	//| Com a regra abaixo, as validacoes sao desconsideradas no momento da ?
	//| da execucao do RETORNAR mas ser? acionadas ao clicar no botao      ?
	//| confirmar - Alexandre Marson                                        ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If IsInCallStack("A103Devol") .And. l103Auto
		Return .T.
	EndIf

	If cModulo=="LOJ"  //  Se For loja nao executa = MAA 01/11/2021
		Return
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Processa items da nota fiscal                                        ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet

		For nX := 1 To Len( aCols )

			If !(aCols[nX][Len(aHeader)+1])

				If RTrim(cTipo) == "D"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//|Verifica se o item  devolvido possui RNC associada                   ?
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					cCodRNC	:= aCols[nX,GDFieldPos("D1_U_IDRNC")]
					cIteRNC	:= aCols[nX,GDFieldPos("D1_U_ITRNC")]

				//	If cEmpAnt+cFilAnt $ "0200" .And. ( cA100For == '032579' .Or. aCols[nX,GDFieldPos("D1_TES")] $ "121" )
					If AllTrim(Left(cFilant, 2))+AllTrim(Right(cfilant, 2)) $ "0200" .And. ( cA100For == '032579' .Or. aCols[nX,GDFieldPos("D1_TES")] $ "121" )
						lDevSemRNC	:= .F.	//Cliente Jays - Ignorar RNC
					//ElseIf cEmpAnt+cFilAnt $ "0304" .And. ( cA100For == '003519' .Or. aCols[nX,GDFieldPos("D1_TES")] $ "121" )
					ElseIf AllTrim(Left(cFilant, 2))+AllTrim(Right(cfilant, 2)) $ "0304" .And. ( cA100For == '003519' .Or. aCols[nX,GDFieldPos("D1_TES")] $ "121" )
					
						lDevSemRNC	:= .F.	//Cliente ITACOR - Ignorar RNC devido a acordo p/ devolução de mercadorias 31/08/2017
					EndIf

				EndIf

			EndIf

		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//|Dispara mensagem para controladoria caso exista item nao conferido   ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If !Empty(cCICMsgAux)

			cCICMsg := '"' + ENTER
			cCICMsg += 'ENTRADA DE MATERIAL SEM CONFERENCIA' + ENTER
			cCICMsg += 'DE: ' + Upper(AllTrim(cUserName)) + ENTER + ENTER
			cCICMsg += 'NOTA FISCAL : " + cNFiscal + " / " + cSerie ' + ENTER
			cCICMsg += 'FORNECEDOR .: " + cA100For + "-" + cLoja + " " + SA2->A2_NOME ' + ENTER
			cCICMsg += cCICMsgAux
			cCICMsg += '"' + ENTER

			//WinExec(cCICPath + Space(1) + "Administrador" + Space(1) + cCICMsg, 0)

		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Verifica se numero da NF tem 9 posicoes                              ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet .And.  AllTrim(cFormul) == "N" .And. Len(AllTrim(cNFiscal)) != 9
		MsgStop( "O campo de nota fiscal deve ser preenchido com 9 caracteres numericos." + ENTER +;
		"Se necessario, complete o campo com zeros a esquerda.", "Atenção" )
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Valida a especie da NF quando tipo igual DEVOLUCAO                   ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet

		If AllTrim(cTipo) == "D" .And. AllTrim(cFormul) == "S"

			If AllTrim(cEspecie) $ "SPED#NFE"

				If ( AllTrim(cEspecie) == "SPED" .And. AllTrim(cSerie) == "REQ" ) .Or.;
				( AllTrim(cEspecie) == "NFE"  .And. AllTrim(cSerie) != "REQ" )

					lRet := .F.

					MsgStop("Especie invalida para o documento de devolu��o." + ENTER + ENTER +;
					"- Utilize a especie SPED quando a serie do documento for DIFERENTE de REQ;" + ENTER +;
					"- Utilize a especie NFE quando a serie do documento for IGUAL a REQ;" )

				EndIf

			Else

				lRet := .F.
				MsgStop("Especie invalida para o documento de devolu�ao.")

			EndIf
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Aviso temporario para associar RNC quando nota de devolucao          ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet .And. AllTrim(cTipo) == "D" .And. lDevSemRNC .And. dDatabase >= CtoD("01/10/15")

		lRet := .F.
		MsgStop("Item sem RNC associada.")

	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Verifica se o numero da NF ja nao foi utilizando anteriormente       ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	/*
	If lRet

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//|FORMULARIO = PROPRIO                                                 ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If AllTrim(cEspecie) == "SPED" .And. AllTrim(cFormul) == "S"
			cQry := " SELECT " + ENTER
			cQry += " 		SUM(QTD) QTD " + ENTER
			cQry += " FROM " + ENTER
			cQry += " 		( " + ENTER
			cQry += " 		SELECT	COUNT(1) QTD " + ENTER
			cQry += " 		FROM " + RetSqlName("SF2") + ENTER
			cQry += " 		WHERE	D_E_L_E_T_ = '' " + ENTER
			cQry += " 				AND F2_FILIAL = '" + xFilial("SF2") + "' " + ENTER
			cQry += " 				AND F2_DOC = '" + cNFiscal + "' " + ENTER
			cQry += " 				AND F2_SERIE = '" + cSerie + "' " + ENTER
			cQry += " 		UNION ALL " + ENTER
			cQry += " 		SELECT	COUNT(1) QTD " + ENTER
			cQry += " 		FROM " + RetSqlName("SF1") + ENTER
			cQry += " 		WHERE	D_E_L_E_T_ = '' " + ENTER
			cQry += " 				AND F1_FILIAL = '" + xFilial("SF1") + "' " + ENTER
			cQry += " 				AND F1_DOC = '" + cNFiscal + "' " + ENTER
			cQry += " 				AND F1_SERIE = '" + cSerie + "' " + ENTER
			cQry += " 				AND F1_ESPECIE = 'SPED' " + ENTER
			cQry += " 				AND F1_FORMUL = 'S' " + ENTER
			cQry += " 		) QRY " + ENTER

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|FORMULARIO = TERCEIROS                                               ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		Else
			cQry := " SELECT  COUNT(1) QTD " + ENTER
			cQry += " FROM " + RetSqlName("SF1") + ENTER
			cQry += " WHERE	D_E_L_E_T_ = '' " + ENTER
			cQry += " 	AND F1_FILIAL = '" + xFilial("SF1") + "' " + ENTER
			cQry += " 	AND F1_FORNECE = '" + cA100For + "' " + ENTER
			cQry += "   AND F1_LOJA = '" + cLoja + "' " + ENTER
			cQry += " 	AND F1_DOC = '" + cNFiscal + "' " + ENTER
			cQry += " 	AND F1_SERIE = '" + cSerie + "' " + ENTER
			cQry += " 	AND F1_STATUS <> '' " + ENTER


		EndIf

		If Select("QRY") > 0
			QRY->(dbCloseArea())
		EndIf

		TCQUERY cQry NEW ALIAS QRY


		If QRY->QTD != 0
			//MsgStop("Numero de NF " + cSerie + cNFiscal + " ja utilizado!")
			//lRet := .F.
		EndIf


		QRY->(dbCloseArea())

	EndIf
    */
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Valida especie do documento                                          ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet .And. .Not. AllTrim(cEspecie) $ cXespec//"SPED#CTE#NFE#NFCF#CTR#NFS#NFSE#NFST#NFCEE#NFF#RPS#RECIB#INV"
		MsgStop("A especie de documento nao e permitida. Verifique!")
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Valida data de emissao para Formulario Proprio SPED                  ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet .And. AllTrim(cEspecie) == "SPED" .And. AllTrim(cFormul) == "S" .And. dDEmissao != dDataBase
		MsgStop("Data invalida para operação!")
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Vincula arquivo ao documento de entrada                              ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If lRet

		BEGIN SEQUENCE

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|Posiciona no registro no fornecedor/cliente                          ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			(macroAlias)->(dbSelectArea(macroAlias))
			(macroAlias)->(dbSetOrder(1))
			(macroAlias)->(dbSeek(xFilial(macroAlias)+cA100For+cLoja))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			//|Verifica a UF do documento fiscal                                    ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
			If AllTrim( &macroEST ) != "EX"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//|Verifica o tipo do formulario fiscal                                 ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				If AllTrim(cFormul) == "N"

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//?efine caminho do arquivo no servidor para realizar copia temporaria ?
					//?* CASO TENHA DE ALTERAR A MASCARA DE FORMACAO DO NOME DO ARQUIVO ** ?
					//?* ALTERE TAMBEM NO PROGRAMA MT103FIM                             ** ?
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//cArqSrv := "\TEMP\" + "SF1_" + cEmpAnt + cFilAnt + "_" + cA100For + cLoja + "_" + AllTrim(cNFiscal) + AllTrim(cSerie)
					cArqSrv := "\TEMP\" + "SF1_" + AllTrim(Left(cFilant, 2))+AllTrim(Right(cfilant, 2)) + "_" + cA100For + cLoja + "_" + AllTrim(cNFiscal) + AllTrim(cSerie)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					//|Verifica a especie do documento fiscal                               ?
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					If AllTrim(cEspecie) $ "SPED#CTE"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//|Solicita arquivo XML                                                 ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						cArqUsr := cGetFile("*.XML","Selecione arquivo XML referente a nota fiscal",1,"F:\",.F.,GETF_LOCALHARD,.F.,.T.)

						If Empty(cArqUsr) .Or. Right(Upper(RTrim(cArqUsr)), 4) != ".XML"
							lRet := .F.
							MsgStop("Arquivo n? permitido." + ENTER +;
							"Selecione o arquivo XML referente a nota fiscal de entrada.")
							Break
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//|Copia arquivo para o servidor ( TEMP )                               ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						cArqSrv := RTrim(cArqSrv) + ".xml"
						__CopyFile(cArqUsr, cArqSrv)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//|Testa se arquivo foi copiado                                         ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						If .Not. File(cArqSrv)
							lRet := .F.
							MsgStop( "N? foi possivel copiar arquivo para o servidor." + ENTER + ENTER +;
							"Origem: " + cArqUsr + ENTER +;
							"Destino: " + cArqSrv, "Atenção")
							Break
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//|Cria objeto XML                                                      ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						oXML    := XmlParserFile(cArqSrv,"_",@cError,@cWarning)
						oAuxXML := oXML

						If Empty(oXML) .Or. !Empty(cError)
							lRet := .F.
							MsgStop( "Este arquivo n? pode ser v?idado!" + ENTER + ENTER +;
							"Erro: " + cError, "Atenção" )
							Break
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//|Identifica o tipo de arquivo ( NFe ou CTe )                          ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						If lRet

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//|Verifica se o XML trata-se de uma  NFe                               ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							If !lFound

								oAuxXML := XmlChildEx(oXML,"_NFEPROC")

								lFound := ( oAuxXML # NIL .And. oAuxXML:_NFE # NIL )

								If lFound .And. AllTrim(cEspecie) == "SPED"

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
									//|Verifica se documento fiscal trata-se de uma requisição e valida     ?
									//|conforme documento emitido pela empresa Euroamerican                 ?
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
									//If (cEmpAnt+cFilAnt $ "0107;0108" .And. cA100For+cLoja $ "01486501")
									//	lRet := ValidaSD2xSD1()
									//EndIf

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
									//|Valida dados informados pelo usuario com o que existe no XML         ?
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
									oXML := XmlChildEx(oAuxXML,"_NFE")
									lRet := U_ValidNFe()

									If lRet

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
										//|Atualiza campo F1_CHVNFE                                             ?
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
										aNfeDanfe[13]	:= StrTran(Upper(oXML:_INFNFE:_ID:TEXT),"NFE","")

									EndIf

								Else
									lFound := .F.
								EndIf

							EndIf


							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//|Verifica se o XML trata-se de uma  CTe                               ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							If !lFound

								oAuxXML := XmlChildEx(oXML,"_CTEPROC")

								lFound := ( oAuxXML # NIL .And. oAuxXML:_CTE # NIL )

								If lFound .And. AllTrim(cEspecie) == "CTE"

									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
									//|Valida dados informados pelo usuario com o que existe no XML         ?
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
									oXML := XmlChildEx(oAuxXML,"_CTE")
									lRet := U_ValidCTe()

									If lRet

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
										//|Atualiza campo F1_CHVNFE                                             ?
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
										aNfeDanfe[13]	:= StrTran(Upper(oXML:_INFCTE:_ID:TEXT),"CTE","")

									EndIf
								Else
									lFound := .F.
								EndIf

							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//|Arquivo nao identificado como NFe ou CTe - Retornar false            ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							If !lFound
								lRet := .F.
								MsgStop("Arquivo selecionado n? pode ser identificado como uma NFe ou CTe.")
								break
							EndIf

						EndIf

					Else

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//|Verifica se documento fiscal trata-se de uma requisição e valida     ?
						//|conforme documento emitido pela empresa Euroamerican                 ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//If (cEmpAnt+cFilAnt $ "0107;0108" .And. cA100For+cLoja $ "01486501")
						//	lRet := ValidaSD2xSD1()
						//EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
						//|Solicita arquivo digitalizado                                        ?
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
					// FABIO BATISTA 11/08/2020
						If lRet .And. !AllTrim(cEspecie) == "RECIB"
							//cArqUsr := cGetFile("*.*","Selecione arquivo referente a nota fiscal",1,"F:\",.F.,GETF_LOCALHARD,.F.,.T.)

							//If Empty(cArqUsr) .Or. Right(Upper(RTrim(cArqUsr)), 4) == ".XML"
							//	lRet := .F.
							//	MsgStop("Arquivo n? permitido." + ENTER +;
							//	"Arquivo XML somente ?aceito em nota fiscal de esp?ie SPED ou CTE.")
							//	Break
							//EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//|Copia arquivo para o servidor ( TEMP )                               ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//__CopyFile(cArqUsr, cArqSrv)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//|Testa se arquivo foi copiado                                         ?
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
							//If .Not. File(cArqSrv)
							//	lRet := .F.
							//	MsgStop( "N? foi possivel copiar arquivo para o servidor." + ENTER + ENTER +;
							//	"Origem: " + cArqUsr + ENTER +;
							//	"Destino: " + cArqSrv, "Atenção")
							//	Break
							//EndIf

						EndIf

					EndIf

				EndIf

			EndIf

		END SEQUENCE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		//|Forca destruicao objeto XML                                          ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
		If Type("oXML") != "U"
			FreeObj(oXML)
			oXML := Nil
		EndIf

		If Type("oAuxXML") != "U"
			FreeObj(oAuxXML)
			oAuxXML := Nil
		EndIf

	EndIf

	// FS - Se quantidade zero e atualiza estoque (somente custeio) n? permitir local 01...
	If lRet
		For nLin := 1 To Len( aCols )
			If !(aCols[nLin][Len(aHeader)+1])
				If aCols[ nLin, GDFieldPos("D1_QUANT")] == 0 .And. aCols[ nLin, GDFieldPos("D1_LOCAL")] $ AllTrim( GetMv("MV_CQ",,"01") )
					cTES := aCols[ nLin, GDFieldPos("D1_TES")]
					dbSelectArea("SF4")
					dbSetOrder(1)
					If SF4->( dbSeek( xFilial("SF4") + cTES ) )
						If AllTrim( SF4->F4_ESTOQUE ) == "S" .And. AllTrim( SF4->F4_TRANSIT ) <> "S"
							ApMsgAlert( "N? ?permitido local de CQ 01 para quantidade igual a zero [0.00]!", "Atenção")
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		// FS - Verifica se h?tes que atualiza estoque...
		For nLin := 1 To Len( aCols )
			If !(aCols[nLin][Len(aHeader)+1])
				cTES := aCols[ nLin, GDFieldPos("D1_TES")]
				dbSelectArea("SF4")
				dbSetOrder(1)
				If SF4->( dbSeek( xFilial("SF4") + cTES ) )
					If AllTrim( SF4->F4_ESTOQUE ) == "S" .And. AllTrim( SF4->F4_TRANSIT ) <> "S"
						lEstoque := .T.
						Exit
					EndIf
				EndIf
			EndIf
		Next

		dbSelectArea("SA2")
		dbSetOrder(1)
		SA2->( dbSeek( xFilial("SA2") + cA100For + cLoja ) )

		// Se intercompany n? exige ticket de pesagem...
		If Left(SA2->A2_CGC, 8) $ GetMv("MV_EQ_CNPJ",,"01245930|03294570|04488985|07122447|10760710|10864589|17291293|")
			lEstoque := .F.
		ElseIf AllTrim( cTipo ) == "D"
			lEstoque := .F.
		ElseIf dDataBase <= STOD("20190830")
			lEstoque := .F.
		//ElseIf AllTrim( Upper( SA2->A2_EST ) ) == "EX" // Retirar ap? estoque em tr?sito...
		//	lEstoque := .F.
		EndIf

		// Verifica se empresa deve possuir controle de pesagem / workflow...
		lEmp01    := SM0->M0_CODIGO $ GetMv("MV_EQ_SFEM",,"02|08|")
		cFilUsaWF := Alltrim(SuperGetMV("MV_EQ_FIWF",.F.,"00|01|03|",)) // Filiais habilitadas para utilização do controle de processo
		If lEmp01 .And. Alltrim( cFilAnt ) $ cFilUsaWF
			lEstoque := .F.
		EndIf

		If lEstoque
			//If !( (AllTrim( cEmpAnt ) == "02" .And. AllTrim( cFilAnt ) == "00") .Or. (AllTrim( cEmpAnt ) == "08" .And. AllTrim( cFilAnt ) == "03") )
			If !(AllTrim(Left(cFilant, 2)) == "02" .And. AllTrim(Right(cfilant, 2)) == "00" .Or. AllTrim(Left(cFilant, 2)) == "08" .And. AllTrim(Right(cfilant, 2)) == "03")
				lEstoque := .F.
			EndIf
		EndIf

		// FS - Se atualiza estoque, verifica se houve amarração com a pesagem...
		If lEstoque
			If Type("aSZZxSF1") == "A"
				If Len( aSZZxSF1 ) > 0
					lAmarra := .T.
				EndIf
			EndIf
			If !lAmarra
				ApMsgAlert( "Documento de entrada possui itens que atualizam estoques, contudo n? houve amarração com a pesagem!" + CRLF + "Operação obrigat?ia!", "Atenção")
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Restaura area anterior                                               ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	//RestArea(aAreaZZ6)
	RestArea(aArea)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//|Forca gravação da NFe quando usuario ?do grupo Administrador        ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	/*If !lRet .And. U_IsGroup("Administradores")
	lRet := MsgYesNo("Foram encontradas inconsistencias entre as informações digitadas e o arquivo XML." + ENTER +;
	"Confirma a inclus? da Nota Fiscal ?", "Administrador - Inconsistencia NFe")
	EndIf*/

Return lRet
