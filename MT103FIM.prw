#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"       
#include "tryexception.ch"
#include "fileio.ch"

#DEFINE ENTER chr(13) + chr(10)        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT103FIM �Autor  �Microsiga           � Data �  08/31/20   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada - Executado ap�s a grava��o da NFE.       ���
���          � Ap�s o destravamento de todas as tabelas envolvidas na     ���
���          � grava��o do documento de entrada, depois de fechar a       ���
���          � opera��o realizada neste.                                  ��� 
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Euroamerican                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MT103FIM()

Local aArea		:= GetArea()
Local aAreaSF1  := SF1->( GetArea() )
Local aAreaSD1  := SD1->( GetArea() )
Local aAreaSC7  := SC7->( GetArea() )
Local cQry		:= ""             
Local cSeqDoc	:= "0000"
Local cNumDoc	:= ""          
Local nQtdDoc	:= 0
Local cMsgAux	:= ""
//Local cCICPath	:= "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"    
//Local cCICMsg	:= ""
//Local cCICUsers	:= U_getUserGp("EXP-X00")        
Local cMaskDir	:= ""
Local aFilesTmp := {}
Local cArqTmp   := ""
Local cArqSrv   := ""     
Local nOpc		:= ParamIXB[1]
Local nConfirma := ParamIXB[2] // FS
Local lEstoque  := .F.         // FS - Validar se TES atualiza estoque e verificar se houve amarra��o com pesagem...
Local lAmarra   := .F.         // FS
Local cTES      := ""          // FS
Local aWFIDs    := {}          // FS
Local nPosWS    := 0           // FS
Local nLin      := 0           // FS
Local cTicPesa  := ""          // FS
Local lConfere  := .F.         // FS
Local cCodProc  := GetMv("MV_EQ_PRWF",, "190001") // Processo recebimento...

//���������������������������������������������������������������������Ŀ
//�Nome do arquivo copiado para a pasta temporaria                      � 
//�                                                                     �  
//�** CASO TENHA DE ALTERAR A MASCARA DE FORMACAO DO NOME DO ARQUIVO ** �
//�** ALTERE TAMBEM NO PROGRAMA MT100TOK                             ** �
//�����������������������������������������������������������������������                             

// ============================================================
//  Grupo Empresa - Ajuste realizado em 31.08.20 (CG)
// ============================================================

// cEmpAnt (Substituido por cFilAnt)

Local cMaskTmp := "SF1_" + Alltrim(cFilAnt) + "_" + cA100For + cLoja + "_" + AllTrim(cNFiscal) + AllTrim(cSerie)
                      
//���������������������������������������������������������������������Ŀ
//�Inclui registro no arquivo ZZ6 para disponibilizar arquivo atraves   � 
//�da funcionalidade "DOCUMENTOS"                                       � 
//����������������������������������������������������������������������� 

If cModulo=="LOJ"
	Return
End



If nOpc == 3 .Or. ((l103Class .Or. l103TolRec) .And. !AllTrim( SF1->F1_STATUS ) == "B")
	If nConfirma == 1
		cMaskDir	:= "\TEMP\" + cMaskTmp + ".*"
		aFilesTmp	:= Directory(cMaskDir, "D")
		
		If Len(aFilesTmp) > 0 
		       
		    cArqAux := aFilesTmp[1, 1]       
			cArqTmp := "\TEMP\" + cArqAux
			cArqSrv := "\DOCUMENTOS\" + "SF1_" + cValToChar( SF1->(RecNo()) ) + "_" + cFilAnt + "_" + cA100For + cLoja + "_" + AllTrim(cNFiscal) + AllTrim(cSerie) + Right(RTrim(cArqAux),4)
		            
			//���������������������������������������������������������������������Ŀ
			//�Copia arquivo da pasta temporaria para pasta documentos              � 
			//����������������������������������������������������������������������� 
			__CopyFile(cArqTmp, cArqSrv)    
			
		EndIf
	
		// FS - Verifica se h� tes que atualiza estoque...
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek( xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )

		Do While !SD1->( Eof() ) .And. xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == xFilial("SD1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
			dbSelectArea("SF4")
			dbSetOrder(1)
			If SF4->( dbSeek( xFilial("SF4") + SD1->D1_TES ) )
				If AllTrim( SF4->F4_ESTOQUE ) == "S" .And. AllTrim( SF4->F4_TRANSIT ) <> "S"
					lEstoque := .T.
				EndIf

				// Verificar se pedido de compras possui Id. Workflow de recebimento...
				If !Empty( SD1->D1_PEDIDO )
					dbSelectArea("SC7")
					dbSetOrder(1)
					If SC7->( dbSeek( xFilial("SC7") + SD1->D1_PEDIDO ) )
						If !Empty( SC7->C7_EUWFID )
							If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
								aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
							EndIf

							RecLock("SD1", .F.)
								SD1->D1_EUWFID := SC7->C7_EUWFID
							MsUnLock()
							
							If Empty( SF1->F1_EUWFID )
								RecLock("SF1", .F.)
									SF1->F1_EUWFID := SC7->C7_EUWFID
								MsUnLock()
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			SD1->( dbSkip() )
		EndDo

		// Verifica se empresa deve possuir controle de pesagem / workflow...
		lEmp01    := SM0->M0_CODIGO $ GetMv("MV_EQ_SFEM",,"02|08|")
		cFilUsaWF := Alltrim(SuperGetMV("MV_EQ_FIWF",.F.,"00|01|03|",)) // Filiais habilitadas para utiliza��o do controle de processo
		If lEmp01 .And. Alltrim( cFilAnt ) $ cFilUsaWF
			lEstoque := .F.
		EndIf

		If lEstoque
			If !( (AllTrim( cEmpAnt ) == "10" .And. AllTrim( cFilAnt ) == "0200") .Or. (AllTrim( cEmpAnt ) == "10" .And. AllTrim( cFilAnt ) == "0803") )
				lEstoque := .F.
			EndIf
		EndIf

		// FS - Se atualiza estoque, verifica se houve amarra��o com a pesagem...
		If lEstoque
			If Type("aSZZxSF1") == "A"
				If Len( aSZZxSF1 ) > 0
					lAmarra := .T.
				EndIf
			EndIf

			If !lAmarra
				dbSelectArea("SA2")
				dbSetOrder(1)
				SA2->( dbSeek( xFilial("SA2") + cA100For + cLoja ) )

				// Se intercompany n�o exige ticket de pesagem...
				If !( Left(SA2->A2_CGC, 8) $ GetMv("MV_EQ_CNPJ",,"01245930|03294570|04488985|07122447|10760710|10864589|17291293|") ) //.And. AllTrim( Upper( SA2->A2_EST ) ) <> "EX"
					ApMsgAlert( "Documento de entrada possui itens que atualizam estoques, contudo n�o houve amarra��o com a pesagem!" + CRLF + "Efetue o Ticket da Pesagem!", "Aten��o")
				EndIf

				// Atualiza os processos da NF...
				For nPosWF := 1 To Len( aWFIDs )
					dbSelectArea("SC7")
					dbSetOrder(1)
					If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
						If (l103Class .Or. l103TolRec)
							U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Classificada. Pedido: " + AllTrim( SC7->C7_NUM ),;
							 			 "400030",;
										 "CLASSIFICACAO NOTA FISCAL DE ENTRADA",;
								         "1",;
										 "Nota Fiscal de Entrada Classificada e Liberada para Confer�ncia" )
						EndIf

						U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Inclu�da. Pedido: " + AllTrim( SC7->C7_NUM ),;
						 			 "400001",;
									 "ENTRADA NOTA FISCAL",;
							         "1",;
									 "Nota Fiscal de Entrada Inclu�da" )
					EndIf
				Next
			Else
				// Efetua amarra��o...
				RecLock( "SZX", .T.)
					SZX->ZX_FILIAL   := xFilial("SZX")
					SZX->ZX_EMPDES   := Left(cFilAnt,2)
					SZX->ZX_FILDES   := Right(cFilAnt,2)
					SZX->ZX_DOC      := cNFiscal
					SZX->ZX_SERIE    := cSerie
					SZX->ZX_FORNECE  := cA100For
					SZX->ZX_LOJA     := cLoja
					SZX->ZX_TIPO     := cTipo
					SZX->ZX_CODSZZ   := aSZZxSF1[01][01]
					SZX->ZX_RECSZZ   := aSZZxSF1[01][02]
				MsUnLock()

				If Empty( SF1->F1_TICPESA )
					RecLock("SF1", .F.)
						SF1->F1_TICPESA := aSZZxSF1[01][01]
					MsUnLock()
				EndIf

				// Atualiza os processos da NF...
				For nPosWF := 1 To Len( aWFIDs )
					dbSelectArea("SC7")
					dbSetOrder(1)
					If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
						U_EQGeraWFC( "Protheus - Chegada na Portaria Ticket: " + AllTrim( SF1->F1_TICPESA ) + " | Pedido: " + AllTrim( SC7->C7_NUM ),;
						 			 "300001",;
									 "CHEGADA MERCADORIA PORTARIA",;
							         "2",;
									 "Chegada na Portaria" )

						U_EQGeraWFC( "Protheus - Pesagem Recebimento Ticket: " + AllTrim( SF1->F1_TICPESA ) + " | Pedido: " + AllTrim( SC7->C7_NUM ),;
						 			 "300200",;
									 "PESAGEM RECEBIMENTO",;
							         "2",;
									 "Chegada na Portaria" )

						dbSelectArea("SZZ")
						dbSetOrder(1)
						If SZZ->( dbSeek( xFilial("SZZ") + SF1->F1_TICPESA ) )
							cQuery := "UPDATE " + RetSqlName("WF3") + " SET WF3_DATA = '" + DTOS( SZZ->ZZ_EMISSAO ) + "', WF3_HORA = '" + Left( SZZ->ZZ_HREMISS, 5) + ":00' " + CRLF
							cQuery += "FROM " + RetSqlName("WF3") + " AS WF3 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE WF3_FILIAL = '" + xFilial("WF3") + "' " + CRLF
							cQuery += "AND WF3_ID LIKE '" + AllTrim( aWFIDs[nPosWF][1] ) + "%' " + CRLF
							cQuery += "AND WF3_PROC = '" + cCodProc + "' " + CRLF
							cQuery += "AND WF3_STATUS = '300001' " + CRLF
							cQuery += "AND WF3.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("WF3") + " WHERE WF3_FILIAL = WF3.WF3_FILIAL AND WF3_ID LIKE '" + AllTrim( aWFIDs[nPosWF][1] ) + "%' AND WF3_PROC = WF3.WF3_PROC AND WF3_STATUS = WF3.WF3_STATUS AND D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND WF3.D_E_L_E_T_ = ' ' " + CRLF

							TCSqlExec( cQuery )

							cQuery := "UPDATE " + RetSqlName("WF3") + " SET WF3_DATA = '" + DTOS( SZZ->ZZ_DTPES1 ) + "', WF3_HORA = '" + Left( SZZ->ZZ_HRPES1, 5) + ":00' " + CRLF
							cQuery += "FROM " + RetSqlName("WF3") + " AS WF3 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE WF3_FILIAL = '" + xFilial("WF3") + "' " + CRLF
							cQuery += "AND WF3_ID LIKE '" + AllTrim( aWFIDs[nPosWF][1] ) + "%' " + CRLF
							cQuery += "AND WF3_PROC = '" + cCodProc + "' " + CRLF
							cQuery += "AND WF3_STATUS = '300200' " + CRLF
							cQuery += "AND WF3.R_E_C_N_O_ IN (SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("WF3") + " WHERE WF3_FILIAL = WF3.WF3_FILIAL AND WF3_ID LIKE '" + AllTrim( aWFIDs[nPosWF][1] ) + "%' AND WF3_PROC = WF3.WF3_PROC AND WF3_STATUS = WF3.WF3_STATUS AND D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND WF3.D_E_L_E_T_ = ' ' " + CRLF

							TCSqlExec( cQuery )
						EndIf

						U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Inclu�da. Pedido: " + AllTrim( SC7->C7_NUM ),;
						 			 "400001",;
									 "ENTRADA NOTA FISCAL",;
							         "1",;
									 "Nota Fiscal de Entrada Inclu�da" )
					EndIf
				Next
			EndIf

			// FS - Efetuar bloqueio de lotes at� a confer�ncia f�sica do produto...
			dbSelectArea("SD1")
			dbSetOrder(1)
			dbSeek( xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
	
			Do While !SD1->( Eof() ) .And. xFilial("SF1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA == xFilial("SD1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
				dbSelectArea("SF4")
				dbSetOrder(1)
				If SF4->( dbSeek( xFilial("SF4") + SD1->D1_TES ) )
					If AllTrim( SF4->F4_ESTOQUE ) == "S"
						dbSelectArea("SB1")
						dbSetOrder(1)
						SB1->( dbSeek( xFilial("SB1") + SD1->D1_COD ) )

						If SB1->B1_RASTRO <> "N"
							dbSelectArea("SB8")
							dbSetOrder(3) //B8_FILIAL, B8_PRODUTO, B8_LOCAL, B8_LOTECTL, B8_NUMLOTE, B8_DTVALID

							/*
							If SB8->( dbSeek( xFilial("SB8") + SD1->D1_COD + SD1->D1_LOCAL + SD1->D1_LOTECTL + SD1->D1_NUMLOTE ) )
								dbSelectArea('SDD')
								dbSetOrder(2) //DD_FILIAL, DD_PRODUTO, DD_LOCAL, DD_LOTECTL, DD_NUMLOTE, DD_MOTIVO

								If !SDD->( dbSeek( xFilial("SDD") + SB8->B8_PRODUTO + SB8->B8_LOCAL + SB8->B8_LOTECTL + SB8->B8_NUMLOTE + "CO" ) )
									Reclock("SDD", .T.)
										SDD->DD_FILIAL  := xFilial("SDD")
										SDD->DD_DOC     := SD1->D1_DOC
										SDD->DD_PRODUTO := SB8->B8_PRODUTO
										SDD->DD_LOCAL   := SB8->B8_LOCAL
										SDD->DD_LOTECTL := SB8->B8_LOTECTL
										SDD->DD_NUMLOTE := SB8->B8_NUMLOTE
										SDD->DD_DTVALID := SB8->B8_DTVALID
										SDD->DD_MOTIVO  := 'CO'
										SDD->DD_QTDORIG := SD1->D1_QUANT
										SDD->DD_SALDO   := SD1->D1_QUANT
										SDD->DD_QUANT   := SD1->D1_QUANT
										SDD->DD_SALDO2  := SD1->D1_QTSEGUM
										SDD->DD_QTSEGUM := SD1->D1_QTSEGUM
									MsUnLock()

									ProcSDD(.F.)
								EndIf
							EndIf
							*/
						EndIf
					EndIf
				EndIf

				SD1->( dbSkip() )
			EndDo
		Else
			// Atualiza os processos da NF...
			For nPosWF := 1 To Len( aWFIDs )
				dbSelectArea("SC7")
				dbSetOrder(1)
				If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
					U_EQGeraWFC( "Protheus - Chegada na Portaria Ticket: " + AllTrim( SF1->F1_TICPESA ) + " | Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "300001",;
								 "CHEGADA MERCADORIA PORTARIA [SEM CONTROLE ESTOQUE]",;
						         "2",;
								 "Chegada na Portaria" )

					U_EQGeraWFC( "Protheus - Pesagem Recebimento Ticket: " + AllTrim( SF1->F1_TICPESA ) + " | Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "300200",;
								 "PESAGEM RECEBIMENTO [SEM CONTROLE ESTOQUE]",;
						         "2",;
								 "Chegada na Portaria" )

					U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Inclu�da. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400001",;
								 "ENTRADA NOTA FISCAL [SEM CONTROLE ESTOQUE]",;
						         "2",;
								 "Nota Fiscal de Entrada Inclu�da" )

					U_EQGeraWFC( "Protheus - Confer�ncia F�sica: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Realizada. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400200",;
								 "CONFERENCIA FISICA DA MERCADORIA [SEM CONTROLE ESTOQUE]",;
						         "2",;
								 "Confer�ncia F�sica Nota Fiscal de Entrada" )

					U_EQGeraWFC( "Protheus - Desembarque Conclu�do: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Realizada. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "500001",;
								 "LIBERACAO SAIDA CAMINHAO [SEM CONTROLE ESTOQUE]",;
						         "2",;
								 "Desembarque Recebimento Conclu�do - Libera��o Caminh�o" )
				EndIf
			Next
		EndIf
	EndIf
EndIf  

If nOpc == 5 
	If nConfirma == 1
		U_EQJustES( "N", "E", "E", "", SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_TIPO, SF1->F1_FORNECE, SF1->F1_LOJA, SF1->F1_EMISSAO, SF1->F1_DTDIGIT )

		// FS - Exclui amarra��o controle de pesagem
		If !Empty( SF1->F1_TICPESA )
			cTicPesa := SF1->F1_TICPESA

			cQuery := "UPDATE " + RetSqlName("SZX") + " SET D_E_L_E_T_ = '*' " + CRLF
			cQuery += "WHERE ZX_FILIAL = '" + xFilial("SZX") + "' " + CRLF
			cQuery += "AND ZX_DOC = '" + SF1->F1_DOC + "' " + CRLF
			cQuery += "AND ZX_SERIE = '" + SF1->F1_SERIE + "' " + CRLF
			cQuery += "AND ZX_FORNECE = '" + SF1->F1_FORNECE + "' " + CRLF
			cQuery += "AND ZX_LOJA = '" + SF1->F1_LOJA + "' " + CRLF
			cQuery += "AND ZX_TIPO = '" + SF1->F1_TIPO + "' " + CRLF
			cQuery += "AND ZX_CODSZZ = '" + SF1->F1_TICPESA + "' " + CRLF
			cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF

			TCSqlExec( cQuery )
		EndIf

		// FS - Verifica se h� tes que atualiza estoque...
		cQuery := "SELECT D1_PEDIDO, D1_DTTRANS " + CRLF
		cQuery += "FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) " + CRLF
		cQuery += "INNER JOIN " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) ON D1_FILIAL = F1_FILIAL " + CRLF
		cQuery += "  AND D1_DOC = F1_DOC " + CRLF
		cQuery += "  AND D1_SERIE = F1_SERIE " + CRLF
		cQuery += "  AND D1_FORNECE = F1_FORNECE " + CRLF
		cQuery += "  AND D1_LOJA = F1_LOJA " + CRLF
		cQuery += "  AND D1_DOC = F1_DOC " + CRLF
		cQuery += "  AND D1_PEDIDO <> '' " + CRLF
		cQuery += "WHERE F1_FILIAL = '" + xFilial("SF1") + "' " + CRLF
		cQuery += "AND F1_DOC = '" + SF1->F1_DOC + "' " + CRLF
		cQuery += "AND F1_SERIE = '" + SF1->F1_SERIE + "' " + CRLF
		cQuery += "AND F1_FORNECE = '" + SF1->F1_FORNECE + "' " + CRLF
		cQuery += "AND F1_LOJA = '" + SF1->F1_LOJA + "' " + CRLF
		cQuery += "AND F1_TIPO = '" + SF1->F1_TIPO + "' " + CRLF
		cQuery += "GROUP BY D1_PEDIDO, D1_DTTRANS " + CRLF

		TCQuery cQuery New Alias "TMPSD1"
		dbSelectArea("TMPSD1")
		dbGoTop()

		Do While !TMPSD1->( Eof() )
			If !Empty( TMPSD1->D1_DTTRANS )
				lConfere := .T.
			EndIf

			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + TMPSD1->D1_PEDIDO ) )
				If !Empty( SC7->C7_EUWFID )
					If aScan( aWFIDs, {|nLin| AllTrim( nLin[1] ) == AllTrim( SC7->C7_EUWFID ) }) == 0
						aAdd( aWFIDs, { AllTrim( SC7->C7_EUWFID ), SC7->C7_NUM })
					EndIf
				EndIf
			EndIf

			TMPSD1->( dbSkip() )
		EndDo

		TMPSD1->( dbCloseArea() )

		// Atualiza os processos da NF...
		For nPosWF := 1 To Len( aWFIDs )
			dbSelectArea("SC7")
			dbSetOrder(1)
			If SC7->( dbSeek( xFilial("SC7") + aWFIDs[nPosWF][2] ) )
				If !Empty( cTicPesa )
					dbSelectArea("SZZ")
					dbSetOrder(1)
					If SZZ->( dbSeek( xFilial("SZZ") + cTicPesa ) )
						If SZZ->ZZ_PESO2 <> 0
							U_EQGeraWFC( "Protheus - Libera��o Caminh�o: " + AllTrim( cTicPesa ) + " Estornada. Pedido: " + AllTrim( SC7->C7_NUM ),;
							 			 "500901",;
										 "LIBERACAO CAMINHAO ESTORNADA",;
								         "1",;
										 "Libera��o Caminh�o Estornada" )
						EndIf
					EndIf
				EndIf

				U_EQGeraWFC( "Protheus - Nota Fiscal de Entrada: " + AllTrim( SF1->F1_DOC ) + "|" + AllTrim( SF1->F1_SERIE ) + " Exclu�da. Pedido: " + AllTrim( SC7->C7_NUM ),;
				 			 "400901",;
							 "EXCLUSAO DA NOTA FISCAL",;
					         "1",;
							 "Nota Fiscal de Entrada Exclu�da" )

				If lConfere
					U_EQGeraWFC( "Protheus - Confer�ncia F�sica: " + AllTrim( cTicPesa ) + " Estornada. Pedido: " + AllTrim( SC7->C7_NUM ),;
					 			 "400290",;
								 "CONFERENCIA ESTORNADA",;
						         "1",;
								 "Confer�ncia F�sica Estornada" )
				EndIf

				If !Empty( cTicPesa )
					dbSelectArea("SZZ")
					dbSetOrder(1)
					If SZZ->( dbSeek( xFilial("SZZ") + cTicPesa ) )
						If SZZ->ZZ_PESO1 <> 0
							U_EQGeraWFC( "Protheus - Pesagem Recebimento: " + AllTrim( cTicPesa ) + " Estornada. Pedido: " + AllTrim( SC7->C7_NUM ),;
							 			 "300290",;
										 "PESAGEM ESTORNADA",;
								         "1",;
										 "Pesagem Recebimento Estornada" )
						EndIf
					EndIf
				EndIf
			EndIf
		Next
	EndIf
EndIf

//workflow status da Nota
	If nOpc == 3 .and. nConfirma == 1 // nOpc (2-visualiza��o / 3 - inclus�o / 4 - classificar)
		u_COMPSTATUS()
	EndIf 

SC7->( Restarea( aAreaSC7 ) )
SD1->( Restarea( aAreaSD1 ) )
SF1->( Restarea( aAreaSF1 ) )
Restarea( aArea )   

Return( Nil )     
