#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
/*/{Protheus.doc} iacd001
//Rotina para impressao de etiqueta
//com base nos modelos pre-definidos e
//dados enviados.
//Informa��es no array
//tipo 001 - {DESCRICAO, CODIGO, EAN, LOTE, FAB MM/AAAA, VAL MM/AAAA, QTD}
//tipo 002 - {CODIGO, DESCRICAO, LOTE, VAL DD/MM/AAAA, QTDE, NOME FOR, NUM.ETIQ., LOTE FOR}
@author mjlozzardo
@since 18/01/2018
@version 1.0
@type function
/*/
User Function iacd001(cTipo, aDados)
	Local cEof   := Chr(13) + Chr(10)

	Default cTipo := "001"

	If cTipo == "001" .Or. cTipo == "004"  //Etiqueta produto + lote
		MscbWrite('CT~~CD,~CC^~CT~' + cEof)
		MscbWrite('^XA' + cEof)
		MscbWrite('^MMT' + cEof)
		MscbWrite('^PW240' + cEof)
		MscbWrite('^LL0559' + cEof)
		MscbWrite('^LS0' + cEof)
		MscbWrite('^FT201,6^A0R,33,33^FH\^FD' + aDados[1] + '^FS' + cEof)
		MscbWrite('^FT163,8^A0R,33,33^FH\^FD' + aDados[2] + '^FS' + cEof)
		MscbWrite('^BY2,2,50^FT42,31^BER,,Y,N' + cEof)
		MscbWrite('^FD' + Alltrim(aDados[3]) + '^FS' + cEof)
		MSCBWrite("^FO20,420^BXN,05,200,20^FD"+aDados[2]+aDados[4]+DtoS(aDados[6])+"^FS"+ cEof) 				// C�digo de Barras 2d - Data Matrix

		//MscbWrite('^FT133,356^A0N,24,24^FH\^FDLote^FS' + cEof)
		MscbWrite('^FT110,6^A0R,39,39^FH\^FD' + aDados[4] + '^FS' + cEof)
		MscbWrite('^FT130,136^A0R,20,20^FH\^FDFAB: ' + SubStr(Dtoc(aDados[5]),4,5) + '^FS' + cEof)
		MscbWrite('^FT110,136^A0R,20,20^FH\^FDVAL: ' + SubStr(Dtoc(aDados[6]),4,5) + '^FS' + cEof)
		//MscbWrite('^BY2,2,60^FT23,539^B3N,N,,N,N' + cEof)
		//MscbWrite('^FD' + aDados[4] + '^FS' + cEof)
		If !Empty(aDados[8])
			MscbWrite('^FO21,250^GB78,156,78^FS' + cEof)
			//MscbWrite('^FT36,321^A0R,62,62^FR^FH\^FD' + TransForm(aDados[8], "@E 999") + 'Kg^FS' + cEof)
			MscbWrite('^FT36,250^A0R,62,62^FR^FH\^FD' + aDados[8] + '^FS' + cEof)
			MscbWrite('^FO98,250^GB21,75,21^FS' + cEof)
			MscbWrite('^FT102,250^A0R,17,16^FR^FH\^FDCONTEUDO^FS' + cEof)
		EndIf
		MscbWrite('^PQ' + Alltrim(Str(aDados[7], 4, 0)) + ',0,1,Y^XZ' + cEof)

	ElseIf cTipo == "002"  //Etiqueta materia prima
		MscbWrite('CT~~CD,~CC^~CT~' + cEof)
		MscbWrite('^XA' + cEof)
		MscbWrite('^MMT' + cEof)
		MscbWrite('^PW797' + cEof)
		MscbWrite('^LL1598' + cEof)
		MscbWrite('^LS0' + cEof)
		MscbWrite('^FT502,108^A0R,135,134^FH\^FD' + aDados[1] + '^FS' + cEof)
		MscbWrite('^FT666,106^A0R,102,100^FH\^FD' + aDados[2] + '^FS' + cEof)
		MscbWrite('^BY5,3,134^FT18,1067^B2R,,Y,Y' + cEof)
		MscbWrite('^FD' + aDados[7] + '^FS' + cEof)
		MscbWrite('^FT499,772^A0R,135,134^FH\^FDL: ' + aDados[3] + '^FS' + cEof)
		MscbWrite('^FT357,106^A0R,102,100^FH\^FDV: ' + Dtoc(aDados[4]) + '^FS' + cEof)
		MscbWrite('^FT354,724^A0R,102,100^FH\^FDQ: ' + TransForm(aDados[1], "@E 9,999,999.999999") + '^FS' + cEof)
		MscbWrite('^FT213,106^A0R,62,62^FH\^FD' + aDados[6] + '^FS' + cEof)
		MscbWrite('^FT118,108^A0R,62,62^FH\^FDL: ' + aDados[8] + '^FS' + cEof)
		MscbWrite('^FO11,21^GB760,78,78^FS' + cEof)
		MscbWrite('^FT11,83^A0N,62,112^FR^FH\^' + Rtrim(SM0->M0_NOME) + '^FS' + cEof)
		MscbWrite('^FT33,114^A0R,56,55^FH\^FDV: ' + Dtoc(aDados[4]) + '^FS' + cEof)
		MscbWrite('^PQ1,0,1,Y^XZ' + cEof)

	ElseIf cTipo == "003"  //Etiqueta OP Euro

		MscbWrite('CT~~CD,~CC^~CT~' + cEof)
		MscbWrite('^XA' + cEof)
		MscbWrite('^MMT' + cEof)
		MscbWrite('^PW797' + cEof)
		MscbWrite('^LL1598' + cEof)
		MscbWrite('^LS0' + cEof)
		MscbWrite('^FT410,35^A0R,180,175^FH\^FD' + aDados[1] + '^FS' + cEof)  //CODIGO
		MscbWrite('^FT517,575^A0R,65,60^FH\^FD' + aDados[2] + '^FS' + cEof)  //DESCRICAO
		MscbWrite('^FT407,575^A0R,55,50^FH\^FD' + TransForm(aDados[3], "@9 99999") + 'Kg^FS' + cEof)  //QTD
		MscbWrite('^FT407,940^A0R,55,50^FH\^FD' + aDados[4] + '^FS' + cEof)  //LOTE
		MscbWrite('^FT407,1305^A0R,55,50^FH\^FD' + aDados[5] + '^FS' + cEof)  //EMBALAGEM
		MscbWrite('^FT297,575^A0R,55,50^FH\^FD' + Dtoc(aDados[6]) + '^FS' + cEof)  //DT.LOTE
		MscbWrite('^FT297,945^A0R,55,50^FH\^FD' + Dtoc(aDados[7]) + '^FS' + cEof)  //VLD.LOTE
		
		//MscbWrite('^BY3,1,90^FT280,1265^B2R,,N,N' + cEof)
		//MscbWrite('^FD' + aDados[4] + '^FS' + cEof)  //NUM.ETIQ.
		MSCBWrite("^FO297,1295^BXN,05,200,20^FD"+Padr(aDados[10],15)+Padr(aDados[4],10)+DtoS(aDados[7])+"^FS"+ cEof) 				// C�digo de Barras 2d - Data Matrix

		MscbWrite('^BY3,3,70^FT291,27^BAR,,N,N' + cEof)
		MscbWrite('^FD' + aDados[10] + '^FS' + cEof)
		MscbWrite('^PQ' + Alltrim(Str(aDados[9], 4, 0)) + ',0,,Y^XZ' + cEof)

		/*
		MscbWrite('CT~~CD,~CC^~CT~' + cEof)
		MscbWrite('^XA' + cEof)
		MscbWrite('^MMT' + cEof)
		MscbWrite('^PW797' + cEof)
		MscbWrite('^LL1598' + cEof)
		MscbWrite('^LS0' + cEof)
		MscbWrite('^FT410,35^A0R,180,175^FH\^FD' + aDados[1] + '^FS' + cEof)  //CODIGO
		MscbWrite('^FT517,575^A0R,65,60^FH\^FD' + aDados[2] + '^FS' + cEof)  //DESCRICAO
		MscbWrite('^FT407,575^A0R,55,50^FH\^FD' + TransForm(aDados[3], "@9 99999") + 'Kg^FS' + cEof)  //QTD
		MscbWrite('^FT407,940^A0R,55,50^FH\^FD' + aDados[4] + '^FS' + cEof)  //LOTE
		MscbWrite('^FT407,1305^A0R,55,50^FH\^FD' + aDados[5] + '^FS' + cEof)  //EMBALAGEM
		MscbWrite('^FT297,575^A0R,55,50^FH\^FD' + Dtoc(aDados[6]) + '^FS' + cEof)  //DT.LOTE
		MscbWrite('^FT297,945^A0R,55,50^FH\^FD' + Dtoc(aDados[7]) + '^FS' + cEof)  //VLD.LOTE
		MscbWrite('^BY3,1,90^FT280,1265^B2R,,N,N' + cEof)
		MscbWrite('^FD' + aDados[4] + '^FS' + cEof)  //NUM.ETIQ.
		MscbWrite('^BY3,3,70^FT291,27^BAR,,N,N' + cEof)
		MscbWrite('^FD' + aDados[10] + '^FS' + cEof)
		MscbWrite('^PQ' + Alltrim(Str(aDados[9], 4, 0)) + ',0,,Y^XZ' + cEof)
        */
	/*  Etiqueta Pequena descontinuada em 20/06/2019. 
	ElseIf cTipo == "004"  //Etiqueta qualy pequena

		MscbWrite('CT~~CD,~CC^~CT~' + cEof)
		MscbWrite('^XA' + cEof)
		MscbWrite('^MMT' + cEof)
		MscbWrite('^PW392' + cEof)
		MscbWrite('^LL0152' + cEof)
		MscbWrite('^LS0' + cEof)
		MscbWrite('^FT18,29^A0N,28,28^FH\^FD' + aDados[1] + '^FS' + cEof)
		MscbWrite('^FT18,48^A0N,20,20^FH\^FDCOD ' + aDados[2] + '^FS' + cEof)
		MscbWrite('^FT18,65^A0N,18,18^FH\^FDFAB ' + aDados[5] + '^FS' + cEof)
		MscbWrite('^FT109,65^A0N,18,18^FH\^FDVAL ' + aDados[6] + '^FS' + cEof)
		MscbWrite('^BY3,2,42^FT40,118^BEN,,Y,N' + cEof)
		MscbWrite('^FD' + aDados[3] + '^FS' + cEof)
		MscbWrite('^FT212,68^A0B,17,12^FH\^FDLOTE^FS' + cEof)
		MscbWrite('^FT216,66^A0N,25,24^FH\^FD' + aDados[4] + '^FS' + cEof)
		If !Empty(aDados[8])
			MscbWrite('^FO291,24^GB97,48,48^FS' + cEof)
			//MscbWrite('^FT291,62^A0N,39,38^FR^FH\^FD' + TransForm(aDados[8], "@E 999") + 'Kg^FS' + cEof)
			MscbWrite('^FT291,62^A0N,39,38^FR^FH\^FD' + aDados[8] + '^FS' + cEof)
			MscbWrite('^FO291,6^GB75,21,21^FS' + cEof)
			MscbWrite('^FT291,22^A0N,17,16^FR^FH\^FDCONTEUDO^FS' + cEof)
		EndIf
		MscbWrite('^PQ' + Alltrim(Str(aDados[7], 4, 0)) + ',0,,Y^XZ' + cEof)
    	*/	
	ElseIf cTipo == "005"  //Etiqueta p/pallet

		MscbWrite('^LS0' + cEof)
		MscbWrite('CT~~CD,~CC^~CT~' + cEof)
		MscbWrite('^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ' + cEof)
		MscbWrite('^XA' + cEof)
		MscbWrite('^MMT' + cEof)
		MscbWrite('^PW799' + cEof)
		MscbWrite('^LL1598' + cEof)
		MscbWrite('^LS0' + cEof)
		MscbWrite('^FT110,1580^A0B,110,80^FH\^FD' + aDados[1] + '^FS' + cEof)
		MscbWrite('^FT210,1581^A0B,110,80^FH\^FD' + aDados[2] + '^FS' + cEof)
		MscbWrite('^FT510,1580^A0B,350,160^FH\^FD' + aDados[4] + '^FS' + cEof) // Numero do Lote

		MscbWrite('^FT310,1050^A0B,70,70^FH\^FD Fabr.: ' + DtoC(aDados[7]) + '^FS' + cEof) // Fabrica��o
		MscbWrite('^FT410,1050^A0B,70,70^FH\^FD Valid: ' + DtoC(aDados[6]) + '^FS' + cEof) // Validade
		
		MscbWrite('^FT750,1580^A0B,75,72^FH\^FD'+ Rtrim(SM0->M0_NOME) +'^FS' + cEof)

		MSCBWrite("^FO500,120^BXN,15,200,20^FD"+aDados[2]+aDados[4]+DtoS(aDados[6])+"^FS" + cEof) 				// C�digo de Barras 2d - Data Matrix

		MscbWrite('^PQ' + Alltrim(Str(aDados[5], 4, 0)) + ',0,,Y^XZ' + cEof)

	ElseIf cTipo == "006"  //caixa coletiva qualy
		MscbWrite('^LS0' + cEof)
		MscbWrite('CT~~CD,~CC^~CT~' + cEof)
		MscbWrite('^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ' + cEof)
		MscbWrite('^XA' + cEof)
		MscbWrite('^MMT' + cEof)
		MscbWrite('^PW240' + cEof)
		MscbWrite('^LL0559' + cEof)
		MscbWrite('^LS0' + cEof)
		MscbWrite('^BY2,3,70^FT191,528^BCB,,Y,N' + cEof)
		MscbWrite('^FD>;>8' + Alltrim(aDados[3]) + '^FS' + cEof)
		MscbWrite('^FT40,535^A0B,34,33^FH\^FD' + aDados[1] + '^FS' + cEof)
		MscbWrite('^FT90,535^A0B,34,33^FH\^FD' + aDados[2] + '^FS' + cEof)
		MscbWrite('^FT97,316^A0B,39,38^FH\^FD' + aDados[4] + '^FS' + cEof)
		MscbWrite('^FT72,198^A0B,23,24^FH\^FDFAB:' + aDados[5] + '^FS' + cEof)
		MscbWrite('^FT104,198^A0B,23,24^FH\^FDVAL:' + aDados[6] + '^FS' + cEof)
		MscbWrite('^FT165,200^A0B,30,30^FH\^FDCX C/^FS' + cEof)
		MscbWrite('^FT204,187^A0B,45,45^FH\^FD' + aDados[8] + '^FS' + cEof)
		MscbWrite('^BY2,2,58^FT221,16^B3I,N,,N,N' + cEof)
		MscbWrite('^FD' + Alltrim(aDados[4]) + '^FS' + cEof)
		MscbWrite('^PQ' + Alltrim(Str(aDados[7], 4, 0)) + ',0,1,Y^XZ' + cEof)

	ElseIf cTipo == "007"  //Etiqueta Padr�o Henkel (Fabio...)

		aArea := GetArea()

		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )
			If AllTrim( SB1->B1_RASTRO ) <> "N"
				dbSelectArea("SB8")
				dbSetOrder(3) // B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID 
				If SB8->( dbSeek( xFilial("SB8") + SC2->C2_PRODUTO + SC2->C2_LOCAL + SC2->C2_NUM ) )
					aDados := {}
					aAdd( aDados, IIF(!EMPTY(SB1->B1_U_DESC2),Rtrim(Substr(SB1->B1_U_DESC2,1,25)),Rtrim(Substr(SB1->B1_DESC,1,25))))	// 01 Descri��o
					aAdd( aDados, SB1->B1_COD		)  // 02 C�digo
					aAdd( aDados, SB1->B1_CODBAR	)  // 03 EAN-13
					aAdd( aDados, SB8->B8_LOTECTL	)  // 04 Lote
					aAdd( aDados, SB8->B8_DFABRIC	)  // 05 Fabrica��o
					aAdd( aDados, SB8->B8_DTVALID	)  // 06 Validade
					aAdd( aDados, SC2->C2_QUANT		)  // 07 Peso L�quido
					aAdd( aDados, SC2->C2_QUANT + (SC2->C2_QUANT * (SB1->B1_PESBRU - SB1->B1_PESO))		)  // 08 Peso Bruto
				EndIf
			EndIf
		EndIf

		RestArea( aArea )

		If Len( aDados ) > 0
			AjustSX1()

			If Pergunte("REST992", .T.)
				dbSelectArea("CB5")
				dbSetOrder(1)
				If CB5->(DbSeek(xFilial("CB5") + MV_PAR01, .F.))
					CB5SetImp(mv_par01)
				Else
					CB5SetImp("000004")
				EndIF

				MSCBBEGIN(1,4)

				MscbWrite('CT~~CD,~CC^~CT~' + cEof)
				MscbWrite('^XA' + cEof)
				MscbWrite('^MMT' + cEof)
				MscbWrite('^PW797' + cEof)
				MscbWrite('^LL1598' + cEof)
				MscbWrite('^LS0' + cEof)
				If mv_par02 == 1
					MscbWrite('^FT287,10^A0R,65,60^FH\^FD' + AllTrim(mv_par03) + '^FS' + cEof)  // Lote
					MscbWrite('^FT187,10^A0R,65,60^FH\^FD' + AllTrim(mv_par04) + '^FS' + cEof)  // Lote
				EndIf
				MscbWrite('^FT587,10^A0R,55,50^FH\^FD' + aDados[4] + '^FS' + cEof)  // Lote
				MscbWrite('^FT517,10^A0R,55,50^FH\^FD' + DTOC(aDados[5]) + '^FS' + cEof)  // Data Fabrica��o
				MscbWrite('^FT447,10^A0R,55,50^FH\^FD' + DTOC(aDados[6]) + '^FS' + cEof)  // Data Validade
				MscbWrite('^FT377,10^A0R,55,50^FH\^FD' + TransForm(aDados[7], "@R 999,999,999.99") + " Kg" + '^FS' + cEof)  // Peso L�quido
				MscbWrite('^FT307,10^A0R,55,50^FH\^FD' + TransForm(aDados[8], "@R 999,999,999.99") + " Kg" + '^FS' + cEof)  // Peso Bruto

				//MscbWrite('^BY3,3,70^FT291,27^BAR,,N,N' + cEof)
				//MscbWrite('^FD' + '' + '^FS' + cEof)
				//MscbWrite('^PQ' + '' + ',0,,Y^XZ' + cEof)

				MscbClosePrinter()
				MSCBInfoEti("Produto","100X50")
				sConteudo:=MSCBEND()
			EndIf
		Else
			ApMsgAlert( "OP n�o encerrada ou produto n�o controla lote, para impress�o de etiqueta Helken � obrigat�rio ter OP e controlar Lote!", "Aten��o" )
		EndIf
	EndIf

	MscbClosePrinter()

Return   

Static Function AjustSX1()

	Local cAlias   := Alias()
	Local aHelpPor := {}

	//Pergunta 01
	aHelpPor := {}
	aAdd(aHelpPor, "Informe o local de impress�o")
	aAdd(aHelpPor, "das etiquetas")
	U_FATUSX1("REST992","01","Local de Impress�o ?","Local de Impress�o ?","Local de Impress�o ?","MV_CH1","C",6,0,0,"G",'ExistCpo("CB5")',"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","CB5","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 02
	aHelpPor := {}
	aAdd(aHelpPor, "Imprime Descri��o e IDH Henkel")
	U_FATUSX1("REST992","02","Imprime Descri��o Henkel?","Imprime Descri��o Henkel?","Imprime Descri��o Henkel?","MV_CH2","N",1,0,0,"C",'',"MV_PAR02","Sim","Sim","Sim","","N�o","N�o","N�o","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "Descri��o Henkel")
	U_FATUSX1("REST992","03","Descri��o","Descri��o","Descri��o","MV_CH3","C",80,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	//Pergunta 03
	aHelpPor := {}
	aAdd(aHelpPor, "IDH Henkel")
	U_FATUSX1("REST992","04","IDH","IDH","IDH","MV_CH4","C",20,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

	DbSelectArea(cAlias)

Return
