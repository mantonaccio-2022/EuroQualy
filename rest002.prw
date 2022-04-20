#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rest002
//Rotina para impressão, chamado via mta650mnu
@author mjlozzardo
@since 15/03/2018
@version 1.0
@type function
/*/
user function rest002()
	Local cAlias  := Alias()
	Local cPerg   := "REST002"
	Local cTipoBar:= ""
	Local cEof    := Chr(13) + Chr(10)
	Local aDados  := {}
	Local cCodPrd := ""

	AjustSX1()

	SB1->(DbSetOrder(1))  //filial + cod
	SB8->(DbSetOrder(5))  //filial + produto + lote
	CB5->(DbSetOrder(1))  //filial + cod

	// Rachadinha do FS
	lFazQualy := .F.
	lFazEuro  := .F.
	If cFilAnt == "0901"  //AllTrim( SM0->M0_CODIGO ) == "09"
		If ApMsgYesNo( "Utilizar padrão Qualyvinil?", "Atenção")
			lFazQualy := .T.
		Else
			lFazEuro  := .T.
		EndIf
	EndIf

	//If SM0->M0_CODIGO $ "08" .Or. lFazQualy
	If Left(cFilAnt, 2) == "08" .Or. lFazQualy
		If Pergunte(cPerg, .T.)
			Pergunte(cPerg, .F.)

			//Verifica se ja foi impresso
			/*
			If SC2->C2_IMPFLAG > 0
				If !(MsgYesNo("Já foram emitidas "+AllTrim(Str(SC2->C2_IMPFLAG))+" etiquetas referente a essa OP, imprimir mais?",'A T E N C A O','YESNO'))
					Return
				Endif
			EndIf
			*/

			If CB5->(DbSeek(xFilial("CB5") + MV_PAR01, .F.))
				If !Usacb0("01")
					cTipoBar := 'MB04'
				EndIf

				//Imprime etiqueta
				Set Century Off // IMPRESSAO COM O DOIS DÍGITOS DO ANO.
				SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))
				//If SB1->B1_UM == "PT"
				//	CB5SetImp("000002")
				//Else
					//CB5SetImp(MV_PAR01)
					CB5SetImp("000001")
				//EndIF

				dbSelectArea("SB8")
				dbSetOrder(3)
				If dbSeek(xFilial("SB8")+SC2->C2_PRODUTO+SC2->C2_LOCAL+Padr(SubStr(SC2->C2_NUM, 1, 6),10))
					dDtVld := SB8->B8_DTVALID
					dDtFab := SB8->B8_DFABRIC
				Else
					dDtVld := SC2->C2_XDTVALI
					dDtFab := SC2->C2_EMISSAO
				EndIf

				aDados := {}
				aAdd(aDados, IIF(!EMPTY(SB1->B1_U_DESC2),Rtrim(Substr(SB1->B1_U_DESC2,1,25)),Rtrim(Substr(SB1->B1_DESC,1,25))))	//01 descricao
				aAdd(aDados, SB1->B1_COD)	//02 codigo
				aAdd(aDados, SB1->B1_CODBAR)	//03 ean13
				aAdd(aDados, Padr(SubStr(SC2->C2_NUM, 1, 6),10))	//04  op/lote
				aAdd(aDados, dDtFab)  //05 dt fab
				aAdd(aDados, dDtVld)  //06 dt val

				If MV_PAR02 == 1
					aAdd(aDados, MV_PAR03)  //07 quantidade
				Else
					aAdd(aDados, SC2->C2_QUANT + MV_PAR03)  //07 quantidade
				EndIf

				//Gravar/Adicionar quantidade de etiquetas impressas da OP
				/*
				Reclock("SC2",.F.)
				SC2->C2_IMPFLAG += aDados[07]
				SC2->( MsUnLock() )
				*/

				//aAdd(aDados, SB1->B1_PESO)  //08 peso
				If !Empty(SB1->B1_U_UMETQ)
					aAdd(aDados, RTRIM(SB1->B1_U_CONTD)+Lower(RTRIM(SB1->B1_U_UMETQ)))	//08 peso
				Else
					aAdd(aDados,"")	//08 peso
				EndIf

				If !Empty(SB1->B1_CODBAR)
					//If SB1->B1_UM == "PT"
					//	U_IACD001("004", aDados)  //IMPRIMIR QUALY pequena
					//Else
						U_IACD001("001", aDados)  //IMPRIMIR QUALY media
					//EndIf
					Set Century On  //Termino da impressao
					MscbClosePrinter()
				Else
					MsgStop("Código de barras não preenchido para o produto, solicitar cadastro!")
				EndIf

			EndIf
		EndIf
	//ElseIf SM0->M0_CODIGO $ "02" .Or. lFazEuro
	ElseIf Left(cFilAnt, 2) == "02" .Or. lFazEuro

		/*
		//Verifica se ja foi impresso
		If SC2->C2_IMPFLAG > 0
			If !(MsgYesNo("Já foram emitidas "+AllTrim(Str(SC2->C2_IMPFLAG))+" etiquetas referente a essa OP, imprimir mais?",'A T E N C A O','YESNO'))
				Return
			Endif
		EndIf
		*/

		If Pergunte(cPerg, .T.)
			Pergunte(cPerg, .F.)

			If CB5->(DbSeek(xFilial("CB5") + MV_PAR01, .F.))
				If !Usacb0("01")
					cTipoBar := 'MB04'
				EndIf

				//Imprime etiqueta
				Set Century Off // IMPRESSAO COM O DOIS DÍGITOS DO ANO.
				SB1->(DbSeek(xFilial("SB1") + SC2->C2_PRODUTO, .F.))
				CB5SetImp(MV_PAR01)

				If Substr(SB1->B1_COD,1,2) $ "PI"
					cCodPrd := Rtrim(SB1->B1_COD)
				ElseIf Len(Alltrim(SB1->B1_COD)) > 12
					cCodPrd := SubStr(SB1->B1_COD, 1, 4) + Right(Alltrim(SB1->B1_COD), 2)
				Else
					cCodPrd := SubStr(SB1->B1_COD, 1, 3)
				EndIf
				nQtdCB0 := Int(Iif(SB1->B1_TIPCONV == "D", SC2->C2_QUANT / SB1->B1_CONV, SC2->C2_QUANT * SB1->B1_CONV))

				aDados := {}
				aAdd(aDados, cCodPrd)  //01
				aAdd(aDados, Alltrim(SubStr(SB1->B1_DESC,1,18)) + " (" + Rtrim(SB1->B1_COD) + ")")  //02

				If MV_PAR05 > 0
					aAdd(aDados, MV_PAR05)  //03
				Else
					aAdd(aDados, SC2->C2_QUANT / nQtdCB0)  //03
				EndIf

				aAdd(aDados, SC2->C2_NUM)  //04
				aAdd(aDados, Posicione("SAH", 1, xFilial("SAH") + SB1->B1_SEGUM, "AH_UMRES"))  //05

				//Verifica data de validade do lote
				If SB8->(DbSeek(xFilial("SB8") + SC2->C2_PRODUTO + SC2->C2_NUM, .F.))
					aAdd(aDados, SB8->B8_DATA)  //06
					aAdd(aDados, SB8->B8_DTVALID)  //07
				Else
					aAdd(aDados, SC2->C2_EMISSAO)  //06
					aAdd(aDados, LastDay(SC2->C2_EMISSAO + SB1->B1_PRVALID, 2))  //07
				EndIf

				aAdd(aDados, "")  //08
				If MV_PAR05 > 0
					aAdd(aDados, 1)
				Else
					If MV_PAR02 == 1  //somente adicionais
						aAdd(aDados, MV_PAR03)  //09 quantidade
					Else
						aAdd(aDados, nQtdCB0 + MV_PAR03)  //09 quantidade
					EndIf
				EndIf

				aAdd(aDados, Alltrim(SB1->B1_COD))  //10 codigo produto

				U_IACD001("003", aDados)  //IMPRIMIR A ETIQUETA

				/*
				//Soma flag impressão:
				Reclock("SC2", .F.)
				SC2->C2_IMPFLAG := SC2->C2_IMPFLAG + 1
				SC2->( MsUnLock() )
				*/

				Set Century On  //Termino da impressao
				MscbClosePrinter()
			EndIf
		EndIf
	EndIf
	DbSelectArea(cAlias)
	Return

Static Function AjustSX1()
	Local cAlias   := Alias()
	Local aHelpPor := {}

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o local de impressão")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST002","01","Local de Impressão ?","Local de Impressão ?","Local de Impressão ?","MV_CH1","C",6,0,0,"G",'ExistCpo("CB5")',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Imprimir total ou somente adicional")
	U_FATUSX1("REST002","02","Imp só adicional?","Imp só adicional?","Imp só adicional?","MV_CH2","N",1,0,0,"C",'',"MV_PAR02","Sim","Sim","Sim","","Não","Não","Não","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o número de etiquetas adicionais")
	U_FATUSX1("REST002","03","Qtd etiqueta adicional?","Qtd etiqueta adicional?","Qtd etiqueta adicional?","MV_CH3","N",3,0,0,"G",'',"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 04
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o numero da etiqueta")
	aAdd(aHelpPor, "para ser impressa. Caso queira")
	aAdd(aHelpPor, "todas, deixar em branco")
	U_FATUSX1("REST002","04","Num.Etiqueta ?","Num.Etiqueta ?","Num.Etiqueta ?","MV_CH4","C",10,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","ZZ","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 05
	aHelpPor := {}
	aAdd(aHelpPor, "Informe a SOBRA de produção")
	aAdd(aHelpPor, "para ser impressa. Essa opção")
	aAdd(aHelpPor, "serve apenas na empresa EURO.")
	U_FATUSX1("REST002","05","Qtd. Sobra","Qtd. Sobra","Qtd. Sobra","MV_CH5","N",12,3,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","ZZ","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)
	Return
