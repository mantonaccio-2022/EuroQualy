#include "rwmake.ch"
#include "protheus.ch"
#Include 'TopConn.Ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � SF1100I  � Autor �Rodrigo Sousa       � Data �  11/09/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Executado ap�s a grava��o do SF1							  ���
���          � Localizado na fun��o A100Grava()							  ���
�������������������������������������������������������������������������͹��
���Documento � PE.SF1100I												  ���
�������������������������������������������������������������������������͹��
���Uso       �                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function SF1100I()

Local aArea := GetArea()

If cModulo <> "LOJ"
	EQWfRespCC()
End

RestArea(aArea)

Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �BeWfRespCC� Autor � Rodrigo Sousa         � Data � 12/09/2013���
��������������������������������������������������������������������������Ĵ��
���Descri��o � WorkFlow Notifica��o de Inclus�o Documento de Entrada	   ���
��� 		 � Por Respons�veis pelo Centro de Custo					   ���
��� 		 � 															   ���
��� 		 � Solicitante: Ronison - Depto. Controladoria				   ���
��� 		 � 															   ���
��� 		 � Finalidade: 	Notificar o respons�vel pelo Centro de Custo   ���
��� 		 � 				cadastrada na tabela SZU e utilizado nos itens ���
��� 		 � 				do Documento de entrada. 					   ���
��� 		 � 															   ���
��� 		 � Motivo: 		Obter maior controle das entradas de notas para���
��� 		 � 				seus centros de custos.						   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

//������������������������������������������������������������������������Ŀ
//�Carrega Itens da Nota Fiscal de Entrada								   �
//��������������������������������������������������������������������������
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

	//������������������������������������������������������������������������Ŀ
	//�Carrega Linhas de Rateio do Item se houver							   �
	//��������������������������������������������������������������������������
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
								
			//������������������������������������������������������������������������Ŀ
			//�Carrega Emails dos Respons�veis pelo Centro de Custo					   �
			//��������������������������������������������������������������������������
			cMailNot := EQGetSZU(SDE->DE_CC,cMailNot)

			SDE->( dbSkip() )
		EndDo
	Else
		//������������������������������������������������������������������������Ŀ
		//�Carrega Emails dos Respons�veis pelo Centro de Custo					   �
		//��������������������������������������������������������������������������
		cMailNot := EQGetSZU(SD1->D1_CC,cMailNot)
	EndIf

	SD1->( dbSkip() )

EndDo

If !Empty(cMailNot)

	//������������������������������������������������������������������������Ŀ
	//�Obt�m dados da Natureza												   �
	//��������������������������������������������������������������������������
	cNaturez := MAFISRET(,"NF_NATUREZA")
	
	dbSelectArea("SED")
	dbSetOrder(1)
	If dbSeek(xFilial("SED")+cNaturez)
		cDescNat := SED->ED_DESCRIC
	EndIf                          
	
	//������������������������������������������������������������������������Ŀ
	//�Dados do Usuario 													   �
	//��������������������������������������������������������������������������
	cCodUser 	:= RetCodUsr() 				// Fun��o que retorna o codigo do usuario corrente.
	cMailUser  	:= UsrRetMail(cCodUser)    	// Retorna eMail do Usuario
	cNomUsr  	:= UsrFullName(cCodUser)   	// Retorna eMail do Usuario

	//������������������������������������������������������������������������Ŀ
	//� Instancia Objeto do WF												   �
	//��������������������������������������������������������������������������
	oProc := TWFProcess():New("100200","Notificacao de Inclus�o de N.F de Entrada - Por Centro de Custo")
	oProc:NewTask('Inicio',"\workflow\html\EQNotNFE.html")
	oHtml:= oProc:oHtml

	//������������������������������������������������������������������������Ŀ
	//� Carrega dados da Tabela Dados da Nota Fiscal						   �
	//��������������������������������������������������������������������������
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

	//������������������������������������������������������������������������Ŀ
	//� Carrega dados da Tabela Itens da Nota Fiscal						   �
	//��������������������������������������������������������������������������
	aSort(aItensSD1,,, {|x, y| x[1] < y[1]})

	For nX := 1 to Len(aItensSD1)
				
		aAdd( (oHtml:valbyname( "itNf.Item" 		)), aItensSD1[nX][01]     	) 
		aAdd( (oHtml:valbyname( "itNf.Codigo" 		)), aItensSD1[nX][02] 		) 
		aAdd( (oHtml:valbyname( "itNf.Descr"		)), aItensSD1[nX][03]	    )
		aAdd( (oHtml:valbyname( "itNf.Tipo"			)), aItensSD1[nX][04]	    )
		aAdd( (oHtml:valbyname( "itNf.Tes"			)), aItensSD1[nX][05]	    )
		aAdd( (oHtml:valbyname( "itNf.Cfo"			)), aItensSD1[nX][06]	    )
		aAdd( (oHtml:valbyname( "itNf.Rateio"   	)), Iif(aItensSD1[nX][07] == '1', 'Sim', 'N�o') 		) 
		aAdd( (oHtml:valbyname( "itNf.CCusto"   	)), aItensSD1[nX][08]		) 
		aAdd( (oHtml:valbyname( "itNf.Quant"   		)), Transform( aItensSD1[nX][09],'@E 999,999.99' )) 
		aAdd( (oHtml:valbyname( "itNf.UM"   		)), aItensSD1[nX][10]		) 
		aAdd( (oHtml:valbyname( "itNf.VlrUnit"   	)), Transform( aItensSD1[nX][11],'@E 999,999,999.99' 	)) 
		aAdd( (oHtml:valbyname( "itNf.VlrTotal"   	)), Transform( aItensSD1[nX][12],'@E 999,999,999.99' 	)) 

	Next nX
	
	//������������������������������������������������������������������������Ŀ
	//� Carrega dados da Tabela Itens do Rateio								   �
	//��������������������������������������������������������������������������
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
		aAdd( (oHtml:valbyname( "itRat.Codigo" 		)), 'N�o existe rateio.'		) 
		aAdd( (oHtml:valbyname( "itRat.PercRat"		)), Transform( 0	,'@E 999.99' ))
		aAdd( (oHtml:valbyname( "itRat.ValRat"   	)), Transform( 0	,'@E 999,999,999.99' 	)) 
		aAdd( (oHtml:valbyname( "itRat.CCusto"   	)), ''							) 
		aAdd( (oHtml:valbyname( "itRat.CtaCont"   	)), ''							) 
	EndIf

	//������������������������������������������������������������������������Ŀ
	//� Ativa envio do Email de Notifica��o									   �
	//��������������������������������������������������������������������������
	ConOut('Notifica��o de Inclus�o de N.F de Entrada Por Centro de Custo: ' + alltrim(SF1->F1_DOC) + " Serie: " + SF1->F1_SERIE )

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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �BeGetSZU	� Autor � Rodrigo Sousa         � Data � 20/08/2012���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Busca Emails dos respons�veis pelo Centro de Custo		   ���
��� 		 � 															   ���
��� 		 � Parametros												   ���
��� 		 � cParam1  := Centro de Custo								   ���
��� 		 � cParam2 	:= Emails Adicionados anteriormente				   ���
��� 		 � 															   ���
��� 		 � Retorno													   ���
��� 		 � cRet		:= Emails dos Responsaveis pelo Centro de Custo	   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function EQGetSZU(cCCusto,cRet)

Default cRet	:= ""
Default cCCusto := ""

//������������������������������������������������������������������������Ŀ
//� Busca Emails conforme Centro de Custo								   �
//��������������������������������������������������������������������������
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
