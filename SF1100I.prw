#include "rwmake.ch"
#include "protheus.ch"
#Include 'TopConn.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SF1100I  º Autor ³Rodrigo Sousa       º Data ³  11/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executado após a gravação do SF1							  º±±
±±º          ³ Localizado na função A100Grava()							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDocumento ³ PE.SF1100I												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SF1100I()

Local aArea := GetArea()

If cModulo <> "LOJ"
	EQWfRespCC()
End

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BeWfRespCC³ Autor ³ Rodrigo Sousa         ³ Data ³ 12/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ WorkFlow Notificação de Inclusão Documento de Entrada	   ³±±
±±³ 		 ³ Por Responsáveis pelo Centro de Custo					   ³±±
±±³ 		 ³ 															   ³±±
±±³ 		 ³ Solicitante: Ronison - Depto. Controladoria				   ³±±
±±³ 		 ³ 															   ³±±
±±³ 		 ³ Finalidade: 	Notificar o responsável pelo Centro de Custo   ³±±
±±³ 		 ³ 				cadastrada na tabela SZU e utilizado nos itens ³±±
±±³ 		 ³ 				do Documento de entrada. 					   ³±±
±±³ 		 ³ 															   ³±±
±±³ 		 ³ Motivo: 		Obter maior controle das entradas de notas para³±±
±±³ 		 ³ 				seus centros de custos.						   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EQWfRespCC()

Local aArea  	:= GetArea()
Local aAreaSD1  := SD1->(GetArea())
Local aAreaSDE  := SDE->(GetArea())
Local aAreaSB1  := SB1->(GetArea())

Local aItensSD1	:= {}
Local aItensSDE	:= {}

Local cMail		:= ""
Local cCodUser	:= ""
Local cMailUser	:= ""
Local cNomUsr	:= ""
Local cMailNot	:= ""
Local cNaturez	:= ""
Local cDescNat	:= ""

Local lEnvia	:= .F.
Local lRateio	:= .F.

Local oProc
Local oHtml
Local nx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Itens da Nota Fiscal de Entrada								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(1)
dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)

Do While !SD1->( Eof() ) .AND. SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SD1->D1_COD)
	
	aAdd( aItensSD1, {	SD1->D1_ITEM,;
						SD1->D1_COD,; 
						SB1->B1_DESC,; 
						SD1->D1_TP,; 
						SD1->D1_TES,; 
						SD1->D1_CF,; 
						SD1->D1_RATEIO,;
						SD1->D1_CC,;
						SD1->D1_QUANT,;
						SD1->D1_UM,;
						SD1->D1_VUNIT,;
						SD1->D1_TOTAL})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega Linhas de Rateio do Item se houver							   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If SD1->D1_RATEIO == '1'
		dbSelectArea("SDE")
		dbSetOrder(1)
		dbSeek(xFilial("SDE")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM))
	
		Do While !SDE->( Eof() ) .AND. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM) == SDE->(DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF)

			aAdd( aItensSDE, {	SDE->DE_ITEMNF,;
								SDE->DE_ITEM,; 
								SD1->D1_COD,; 
								SDE->DE_PERC,;
								SDE->DE_CUSTO1,;
								SDE->DE_CC,;
								Round(SD1->D1_TOTAL * (SDE->DE_PERC/100),2),;
								SDE->DE_CONTA })
								
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Carrega Emails dos Responsáveis pelo Centro de Custo					   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMailNot := EQGetSZU(SDE->DE_CC,cMailNot)

			SDE->( dbSkip() )
		EndDo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega Emails dos Responsáveis pelo Centro de Custo					   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMailNot := EQGetSZU(SD1->D1_CC,cMailNot)
	EndIf

	SD1->( dbSkip() )

EndDo

If !Empty(cMailNot)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Obtém dados da Natureza												   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNaturez := MAFISRET(,"NF_NATUREZA")
	
	dbSelectArea("SED")
	dbSetOrder(1)
	If dbSeek(xFilial("SED")+cNaturez)
		cDescNat := SED->ED_DESCRIC
	EndIf                          
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados do Usuario 													   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCodUser 	:= RetCodUsr() 				// Função que retorna o codigo do usuario corrente.
	cMailUser  	:= UsrRetMail(cCodUser)    	// Retorna eMail do Usuario
	cNomUsr  	:= UsrFullName(cCodUser)   	// Retorna eMail do Usuario

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Instancia Objeto do WF												   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oProc := TWFProcess():New("100200","Notificacao de Inclusão de N.F de Entrada - Por Centro de Custo")
	oProc:NewTask('Inicio',"\workflow\html\EQNotNFE.html")
	oHtml:= oProc:oHtml

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega dados da Tabela Dados da Nota Fiscal						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oHtml:valbyname( "cEmpresa"  ,	SM0->M0_CODIGO )
	oHtml:valbyname( "cCodFil"  ,	SM0->M0_CODFIL+" "+SM0->M0_FILIAL )
	oHtml:valbyname( "cNomUsr"  , 	Alltrim(Capital(cNomUsr )))
	oHtml:valbyname( "cEmail" 	, 	ALLTRIM(Lower(cMailUser)))
	oHtml:valbyname( "cCodFor" 	, 	SF1->F1_FORNECE )
	oHtml:valbyname( "cLojaFor"	, 	SF1->F1_LOJA )
	oHtml:valbyname( "cNomeFor"	, 	SA2->A2_NREDUZ )
	oHtml:valbyname( "cNumNF"  	, 	ALLTRIM(SF1->F1_DOC) )
	oHtml:valbyname( "cSerie"  	, 	SF1->F1_SERIE )
	oHtml:valbyname( "cEmissao"	, 	DTOC(SF1->F1_EMISSAO) )
	oHtml:valbyname( "nVlrTot" 	, 	Transform( SF1->F1_VALBRUT , '@E 999,999,999.99') )
	oHtml:valbyname( "cEspecNF"	, 	SF1->F1_ESPECIE )
	oHtml:valbyname( "cChaveNFe",	SF1->F1_CHVNFE )
	oHtml:valbyname( "cNaturez",	cNaturez )
	oHtml:valbyname( "cDescNat",	cDescNat )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega dados da Tabela Itens da Nota Fiscal						   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSort(aItensSD1,,, {|x, y| x[1] < y[1]})

	For nX := 1 to Len(aItensSD1)
				
		aAdd( (oHtml:valbyname( "itNf.Item" 		)), aItensSD1[nX][01]     	) 
		aAdd( (oHtml:valbyname( "itNf.Codigo" 		)), aItensSD1[nX][02] 		) 
		aAdd( (oHtml:valbyname( "itNf.Descr"		)), aItensSD1[nX][03]	    )
		aAdd( (oHtml:valbyname( "itNf.Tipo"			)), aItensSD1[nX][04]	    )
		aAdd( (oHtml:valbyname( "itNf.Tes"			)), aItensSD1[nX][05]	    )
		aAdd( (oHtml:valbyname( "itNf.Cfo"			)), aItensSD1[nX][06]	    )
		aAdd( (oHtml:valbyname( "itNf.Rateio"   	)), Iif(aItensSD1[nX][07] == '1', 'Sim', 'Não') 		) 
		aAdd( (oHtml:valbyname( "itNf.CCusto"   	)), aItensSD1[nX][08]		) 
		aAdd( (oHtml:valbyname( "itNf.Quant"   		)), Transform( aItensSD1[nX][09],'@E 999,999.99' )) 
		aAdd( (oHtml:valbyname( "itNf.UM"   		)), aItensSD1[nX][10]		) 
		aAdd( (oHtml:valbyname( "itNf.VlrUnit"   	)), Transform( aItensSD1[nX][11],'@E 999,999,999.99' 	)) 
		aAdd( (oHtml:valbyname( "itNf.VlrTotal"   	)), Transform( aItensSD1[nX][12],'@E 999,999,999.99' 	)) 

	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega dados da Tabela Itens do Rateio								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aItensSDE) > 0 
	
		aSort(aItensSDE,,, {|x, y| x[1]+x[2] < y[1]+x[2]})
	
	    For nX := 1 to Len(aItensSDE)
			aAdd( (oHtml:valbyname( "itRat.Item" 		)), aItensSDE[nX][01]     	) 
			aAdd( (oHtml:valbyname( "itRat.Codigo" 		)), aItensSDE[nX][03] 		) 
			aAdd( (oHtml:valbyname( "itRat.PercRat"		)), Transform( aItensSDE[nX][04],'@E 999.99' ))
			aAdd( (oHtml:valbyname( "itRat.ValRat"   	)), Transform( aItensSDE[nX][07],'@E 999,999,999.99' 	)) 
			aAdd( (oHtml:valbyname( "itRat.CCusto"   	)), aItensSDE[nX][06]		) 
			aAdd( (oHtml:valbyname( "itRat.CtaCont"   	)), aItensSDE[nX][08]		) 
		Next nX	
	Else
		aAdd( (oHtml:valbyname( "itRat.Item" 		)), ''     	) 
		aAdd( (oHtml:valbyname( "itRat.Codigo" 		)), 'Não existe rateio.'		) 
		aAdd( (oHtml:valbyname( "itRat.PercRat"		)), Transform( 0	,'@E 999.99' ))
		aAdd( (oHtml:valbyname( "itRat.ValRat"   	)), Transform( 0	,'@E 999,999,999.99' 	)) 
		aAdd( (oHtml:valbyname( "itRat.CCusto"   	)), ''							) 
		aAdd( (oHtml:valbyname( "itRat.CtaCont"   	)), ''							) 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa envio do Email de Notificação									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ConOut('Notificação de Inclusão de N.F de Entrada Por Centro de Custo: ' + alltrim(SF1->F1_DOC) + " Serie: " + SF1->F1_SERIE )

	oProc:cBCC := cMailNot

	oProc:cSubject := "Notificacao de Inclusao de N.F. de Entrada Por Centro de Custo"
	oProc:Start()
	oProc:Finish()
	wfsendmail()

EndIf	

RestArea( aArea )
RestArea ( aAreaSD1 )
RestArea ( aAreaSDE )
RestArea ( aAreaSB1 )

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BeGetSZU	³ Autor ³ Rodrigo Sousa         ³ Data ³ 20/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Emails dos responsáveis pelo Centro de Custo		   ³±±
±±³ 		 ³ 															   ³±±
±±³ 		 ³ Parametros												   ³±±
±±³ 		 ³ cParam1  := Centro de Custo								   ³±±
±±³ 		 ³ cParam2 	:= Emails Adicionados anteriormente				   ³±±
±±³ 		 ³ 															   ³±±
±±³ 		 ³ Retorno													   ³±±
±±³ 		 ³ cRet		:= Emails dos Responsaveis pelo Centro de Custo	   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EQGetSZU(cCCusto,cRet)

Default cRet	:= ""
Default cCCusto := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca Emails conforme Centro de Custo								   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cCCusto)

    dbSelectArea("SZU")
    dbSetOrder(1)
    dbSeek(xFilial("SZU")+cCCusto)
    
	Do While !SZU->( Eof() ) .And. xFilial("SZU") == SZU->ZU_FILIAL .And. SZU->ZU_CCUSTO == cCCusto
        If !Alltrim(SZU->ZU_EMAIL) $ cRet .And. SZU->ZU_NOTIFIC == '1'
			cRet += Alltrim(SZU->ZU_EMAIL)+";"
        EndIf
		
		SZU->(dbSkip())
	EndDo	
EndIf

Return cRet
