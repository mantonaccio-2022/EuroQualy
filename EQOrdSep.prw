#INCLUDE "Protheus.ch"
#INCLUDE "RptDef.ch"  
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TopConn.ch"

#DEFINE	 IMP_DISCO 	1
#DEFINE	 IMP_SPOOL 	2
#DEFINE	 IMP_EMAIL 	3
#DEFINE	 IMP_EXCEL 	4
#DEFINE	 IMP_HTML  	5
#DEFINE	 IMP_PDF   	6 

#DEFINE	 NMINLIN	030
#DEFINE  NMINCOL	020
#DEFINE	 NMAXLIN   	800
#DEFINE	 NMAXCOL   	570

#DEFINE	 REL_NAME	"Ordem de Separa��o"
#DEFINE  REL_PATH	GetTempPath() 

#DEFINE	 XCOD	01
#DEFINE	 XLOJA	02
#DEFINE	 XNOME	03
#DEFINE	 XEND	04
#DEFINE	 XMUN	05
#DEFINE	 XEST	06
#DEFINE	 XINSCR	07
#DEFINE	 XCEP 	08
#DEFINE	 XCGC	09
#DEFINE	 XTEL	10
#DEFINE	 XBAIR	11
#DEFINE	 XENDENT	12
#DEFINE	 XBAIRROE	13
#DEFINE	 XMUNE		14
#DEFINE	 XESTE		15
#DEFINE	 XCEPE		16


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �BeROrdSep � Autor � Rodrigo Sousa         � Data � 02/06/15 ���
�������������������������������������������������������������������������ĳ��
���Descri��o � Impress�o da Ordem de Separa��o							  ���
���          � 															  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � 						                              ���
�������������������������������������������������������������������������ĳ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EQOrdSep()

Local nY			:= 0

Private oPrn 		:= Nil
Private oSetup		:= Nil
Private oFont07,oFont07n,oFont08,oFont08n,oFont09,oFont09n,oFont10,oFont10n,oFont11,oFont11n,oFont12,oFont12n,oFont12c,oFont12cn,oFont14,oFont14n

Private cPerg		:= "EQOS01"	

ValidPerg()
If !Pergunte(cPerg, .T.)
	ApMsgInfo('Relat�rio Cancelado!', 'Aten��o')
	Return
EndIf 

If PrepPrint() 
	RptStatus({|| ExecPrint() },"Imprimindo Ordem de Separa��o...")
EndIf

Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �PrepPrint � Autor � Rodrigo Sousa         � Data � 02/06/2015���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function PrepPrint(cPathDest,cRelName)

Local nX	:= 0
Local lRet 	:= .T.

Local cPathDest   := GetTempPath() //REL_PATH
Local cRelName	:= "OrdSep_"+MV_PAR01+MV_PAR02

//��������������������������������Ŀ
//�Instancia os objetos de fonte   �
//����������������������������������
oFont07n := TFont():New( "Arial",, 07,,.T.)
oFont07  := TFont():New( "Arial",, 07,,.F.)
oFont08n := TFont():New( "Arial",, 08,,.T.)
oFont08  := TFont():New( "Arial",, 08,,.F.)
oFont09  := TFont():New( "Arial",, 09,,.F.)
oFont09n := TFont():New( "Arial",, 09,,.T.)
oFont10n := TFont():New( "Arial",, 10,,.T.)
oFont10  := TFont():New( "Courier New",, 10,,.F.)
oFont11  := TFont():New( "Courier New",, 11,,.F.)
oFont11n := TFont():New( "Courier New",, 11,,.T.)
oFont12c  := TFont():New( "Courier New",, 12,,.F.)
oFont12cn := TFont():New( "Courier New",, 12,,.T.)
oFont12n := TFont():New( "Arial",, 12,,.T.)
oFont12  := TFont():New( "Arial",, 12,,.F.)
oFont14n := TFont():New( "Arial",, 14,,.T.)
oFont14  := TFont():New( "Arial",, 14,,.F.)

//��������������������������������Ŀ
//�Instancia a Classe FwMsPrinter  �
//����������������������������������
oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
//oPrn 	:= FWMSPrinter():New("DANFE", IMP_PDF)
oPrn:SetResolution(72)
oPrn:SetLandscape()
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4)

//oPrn:cPathPDF := cPathDest 			//Caso seja utilizada impress�o em IMP_PDF      

//��������������������������������Ŀ
//�Instancia a Classe FWPrintSetup �
//����������������������������������
oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"OS")
oSetup:SetUserParms({|| Pergunte(cPerg, .T.)})
oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
oSetup:SetProperty(PD_DESTINATION,2) 
oSetup:SetProperty(PD_PRINTTYPE,IMP_PDF)


//��������������������������������Ŀ
//�Ativa Tela de Setup		  	   �
//����������������������������������
If oSetup:Activate() == 2
	lRet	:= .F.
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �ExecPrint   � Autor � Rodrigo Sousa        � Data � 02/06/2015���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Executa Impress�o.             		  	     				���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ExecPrint()

Local lProc			:= .T.

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+MV_PAR01,.T.)) // Posiciona no 1o.reg. satisfatorio 

SetRegua(RecCount())

While ! CB7->(EOF()) .and. (CB7->CB7_ORDSEP >= MV_PAR01 .and. CB7->CB7_ORDSEP <= MV_PAR02)
	If CB7->CB7_DTEMIS < MV_PAR03 .or. CB7->CB7_DTEMIS > MV_PAR04 // Nao considera as ordens que nao tiver dentro do range de datas 
		CB7->(DbSkip())
		Loop
	Endif
	If MV_PAR05 == 2 .and. CB7->CB7_STATUS == "9" // Nao Considera as Ordens ja encerradas
		CB7->(DbSkip())
		Loop
	Endif
	CB8->(DbSetOrder(1))
	If ! CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
		CB7->(DbSkip())
		Loop
	EndIf
	IncRegua("Imprimindo") 
	RunPrint() 
	lProc	:= .T.
	CB7->(DbSkip())
Enddo

If lProc
	StartPrint()
Else
	ApMsgInfo('N�o h� dados!', 'Qualyvinil')
EndIf

Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �RunPrint  � Autor � Rodrigo Sousa         � Data � 02/10/2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function RunPrint()

Local nPixLin	:= NMINLIN
Local nPixCol	:= NMINCOL                  
Local nPage		:= 1                        

Local lSaida	:= .F.
Local aItens	:= {}

Private cOrdSep 	:= Alltrim(CB7->CB7_ORDSEP)
Private cPedido 	:= Alltrim(CB7->CB7_PEDIDO)
Private cCliente	:= Alltrim(CB7->CB7_CLIENT)
Private cLoja   	:= Alltrim(CB7->CB7_LOJA)
Private cNota   	:= Alltrim(CB7->CB7_NOTA)
Private cSerie  	:= Alltrim(CB7->CB7_SERIE)
Private cOP     	:= Alltrim(CB7->CB7_OP)
Private cStatus 	:= RetStatus(CB7->CB7_STATUS)
Private cAliasCF	:= ""
Private cUMAtual	:= ""
Private aDadosCli	:= Array(16)

If CB7->CB7_ORIGEM $ "1|2"  
	lSaida	:= .T.
EndIf

//����������������������������������������������������������������Ŀ
//� Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   �
//������������������������������������������������������������������
If lSaida

	//����������������������������������������������������������������Ŀ
	//� Posiciona tabelas											   �
	//������������������������������������������������������������������
	CB8->(DbSetOrder(7))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbSeek(xFilial("SC5")+CB8->CB8_PEDIDO)

	DbSelectArea("SA4")
	DbSetOrder(1)
	Dbseek(xFilial("SA4")+SC5->C5_TRANSP)

	DbSelectArea("SA3")
	dbSetOrder(1)
	Dbseek(xFilial("SA3")+SC5->C5_VEND1)

	DbSelectArea("SE4")
	dbSetOrder(1)
	Dbseek(xFilial("SE4")+SC5->C5_CONDPAG)

	DbSelectArea("SF2")
	dbSetOrder(1)
	DbSeek(xFilial("SF2") + CB7->(CB7_NOTA + CB7_SERIE + CB7_CLIENT + CB7_LOJA))

	cPedido := SC5->C5_NUM

	If !SC5->C5_TIPO $ "BD"
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+cCliente+cLoja)
		
		aDadosCli[XCOD]		:= SA1->A1_COD
		aDadosCli[XLOJA]	:= SA1->A1_LOJA
		aDadosCli[XNOME]	:= SA1->A1_NOME
		aDadosCli[XEND]		:= SA1->A1_END
		aDadosCli[XMUN]		:= SA1->A1_MUN
		aDadosCli[XEST]		:= SA1->A1_EST
		aDadosCli[XINSCR]	:= SA1->A1_INSCR
		aDadosCli[XCEP]		:= SA1->A1_CEP
		aDadosCli[XCGC]		:= Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
		aDadosCli[XTEL]		:= SA1->A1_TEL
		aDadosCli[XBAIR]	:= SA1->A1_BAIRRO

		aDadosCli[XENDENT]	:= SA1->A1_ENDENT
		aDadosCli[XBAIRROE]	:= SA1->A1_BAIRROE
		aDadosCli[XMUNE]	:= SA1->A1_MUNE
		aDadosCli[XESTE]	:= SA1->A1_ESTE
		aDadosCli[XCEPE]	:= SA1->A1_CEPE

	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+cCliente+cLoja)

		aDadosCli[XCOD]		:= SA2->A2_COD
		aDadosCli[XLOJA]	:= SA2->A2_LOJA
		aDadosCli[XNOME]	:= SA2->A2_NOME
		aDadosCli[XEND]		:= SA2->A2_END
		aDadosCli[XMUN]		:= SA2->A2_MUN
		aDadosCli[XEST]		:= SA2->A2_EST
		aDadosCli[XINSCR]	:= SA2->A2_INSCR
		aDadosCli[XCEP]		:= SA2->A2_CEP
		aDadosCli[XCGC]		:= Transform(SA2->A2_CGC,"@R 99.999.999/9999-99")
		aDadosCli[XTEL]		:= SA2->A2_TEL
		aDadosCli[XBAIR]	:= SA2->A2_BAIRRO

		aDadosCli[XENDENT]	:= "" 
		aDadosCli[XBAIRROE]	:= ""
		aDadosCli[XMUNE]	:= ""
		aDadosCli[XESTE]	:= ""
		aDadosCli[XCEPE]	:= ""
    EndIf
    

	//����������������������������������������������������������������Ŀ
	//� Imprime Cabe�alho da Ordem de Separa��o						   �
	//������������������������������������������������������������������
	nPixLin			:= CabPrint(nPage,lSaida,aDadosCli)

	//����������������������������������������������������������������Ŀ
	//� Imprime Cabe�alho dos Itens da Ordem de Separa��o			   �
	//������������������������������������������������������������������
	nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)

	While ! CB8->(EOF()) .and. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP == xFilial("CB8")+cOrdSep)

		//����������������������������������������������������������������Ŀ
		//� Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   �
		//������������������������������������������������������������������
		dbSelectArea("SC6")
		dbSetOrder(1)
		dbSeek(xFilial("SC6")+CB8->CB8_PEDIDO+CB8->CB8_ITEM+CB8->CB8_PROD)

		dbSelectArea("SB8")
		dbsetorder(3)
		dbSeek(xFilial("SB8")+CB8->CB8_PROD+CB8->CB8_LOCAL+CB8->CB8_LOTECT)

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+CB8->CB8_PROD)

		aAdd(aItens,{CB8->CB8_PROD,;
					 Substr(SB1->B1_DESC,1,37),;
					 Alltrim(Transform(CB8->CB8_QTDORI,"@E 9,999,999")),;
					 SB1->B1_UM,;
					 CB8->CB8_LOCAL,;
					 CB8->CB8_LCALIZ,;
					 CB8->CB8_LOTECT,;
					 (Transform(CB8->CB8_SALDOS,"@E 9,999,999"))})

    	CB8->(dbSkip())
	EndDo

	For nX := 1 to Len(aItens)

		nPixLin := IncLinTb(nPixLin,nPixCol)
		oPrn:Say(nPixLin		,nPixCol+005	,aItens[nX][01]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+095	,aItens[nX][02]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+315	,aItens[nX][03]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+360	,aItens[nX][04]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+390	,aItens[nX][05]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+420	,aItens[nX][06]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+480	,aItens[nX][07]	,oFont12c,,)
//		oPrn:Say(nPixLin		,nPixCol+490	,aItens[nX][08]	,oFont11,,)

		If nPixLin > 700 
			nPage := RodaImp(nPage,nPixLin,nPixCol)
			nPixLin	:= CabPrint(nPage,lSaida,aDadosCli)
			nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)
        EndIf

	Next nX
	
	nPage := RodaImp(nPage,nPixLin,nPixCol)			

Else

	/*
	oPrn:Say(nPixLin+=08,nPixCol+005,"Ordem de Produ��o: "+cOP+" Status: "+cStatus,oFont07,,)
	oPrn:Line(nPixLin+=08,NMINCOL,nPixLin,NMAXCOL)

	//����������������������������������������������������������������Ŀ
	//� Imprime Cabe�alho dos Itens da Ordem de Separa��o			   �
	//������������������������������������������������������������������
	nPixLin := CabPrIt(nPixLin,nPixCol)

	CB8->(DbSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	While ! CB8->(EOF()) .and. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP == xFilial("CB8")+cOrdSep)

		If nPixLin > 550 
			oPrn:EndPage()
			nPage += 1
			nPixLin	:= CabPrint(nPage)
			nPixLin := CabPrIt(nPixLin,nPixCol)
        EndIf

		//����������������������������������������������������������������Ŀ
		//� Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   �
		//������������������������������������������������������������������
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial("SC2")+cOP)
		
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+CB8->CB8_PROD)

		oPrn:Say(nPixLin+=008	,nPixCol+005	,CB8->CB8_PROD												,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+080	,SUBSTR(SB1->B1_DESC,1,30)									,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+230	,SC2->C2_UM													,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+260	,CB8->CB8_LOCAL												,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+290	,CB8->CB8_LCALIZ											,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+350	,CB8->CB8_LOTECT											,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+420	,DtoC(SC2->C2_EMISSAO)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+470	,DtoC(SC2->C2_XDTVALI)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+520	,DtoC(SC2->C2_DATPRF)										,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+570	,Alltrim(Transform(CB8->CB8_QTDORI,"@E 999,999,999.99"))	,oFont07,,)
		oPrn:Say(nPixLin		,nPixCol+640	,Alltrim(Transform(CB8->CB8_SALDOS,"@E 999,999,999.99"))	,oFont07,,)
//		oPrn:Say(nPixLin		,nPixCol+720	,Alltrim(Transform(CB8->CB8_SALDOE,"@E 999,999,999.99"))	,oFont07,,)


    	CB8->(dbSkip())
	EndDo
    */
	//CB8->(DbSetOrder(1))
	CB8->(DbSetOrder(7))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))

	aItens := {}

	//����������������������������������������������������������������Ŀ
	//� Imprime Itens da Nota Fiscal de Saida ou Pedido de Venda	   �
	//������������������������������������������������������������������
	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cOP)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+CB8->CB8_PROD)

	//����������������������������������������������������������������Ŀ
	//� Imprime Cabe�alho da Ordem de Separa��o						   �
	//������������������������������������������������������������������
	nPixLin			:= CabPrint(nPage,lSaida,{})

	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cOP)
	
	cQuery := "SELECT G2_OPERAC, G2_RECURSO, G2_DESCRI "
	cQuery += "FROM " + RetSqlName("SG2") + " AS SG2 WITH (NOLOCK) "
	cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON H1_FILIAL = '" + xFilial("SH1") + "' "
	cQuery += "  AND H1_CODIGO = G2_RECURSO "
	cQuery += "  AND SH1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SHB") + " AS SHB WITH (NOLOCK) ON HB_FILIAL = '" + xFilial("SHB") + "' "
	cQuery += "  AND HB_COD = G2_CTRAB "
	cQuery += "  AND SHB.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE G2_FILIAL = '" + xFilial("SG2") + "' "
	cQuery += "AND G2_CODIGO = '01' " 
	cQuery += "AND G2_OPERAC = '10' "
	cQuery += "AND G2_PRODUTO = '" + SC2->C2_PRODUTO + "' " 
	cQuery += "AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY G2_OPERAC "
	
	TCQuery cQuery New Alias "TMPROT"
	dbSelectArea("TMPROT")
	dbGoTop()
	
	nPixLin += 008
	
	Do While !TMPROT->( Eof() )
		oPrn:Say(nPixLin+=10,nPixCol+050,PadC("OPERA��O " + TMPROT->G2_OPERAC + " " + AllTrim( TMPROT->G2_DESCRI ),120),oFont14n)
	
		oPrn:Say(nPixLin+=10,nPixCol+150,"Opera��o: " + TMPROT->G2_OPERAC,oFont08)
		oPrn:DataMatrix(nPixCol+150, nPixLin+56, TMPROT->G2_OPERAC , 55 )
		oPrn:Say(nPixLin    ,nPixCol+430,"Recurso: " + TMPROT->G2_RECURSO,oFont08)
		oPrn:DataMatrix(nPixCol+430, nPixLin+56, TMPROT->G2_RECURSO, 55 )
	
		oPrn:Line(nPixLin+=65,nPixCol,nPixLin,NMAXCOL)
	
		TMPROT->( dbSkip() )
	EndDo
	
	TMPROT->( dbCloseArea() )
	
	//oPrn:Line(nPixLin+=10,nPixCol,nPixLin,NMAXCOL)
	
	/*
	oPrn:Say(nPixLin+=10,nPixCol+050,"INICIAR PRODU��O",oFont08)
	oPrn:DataMatrix(nPixCol+050, nPixLin+56, "01" , 55 )
	oPrn:Say(nPixLin    ,nPixCol+430,"FINALIZAR PRODU��O",oFont08)
	oPrn:DataMatrix(nPixCol+430, nPixLin+56, "04", 55 )

	oPrn:Line(nPixLin+=65,nPixCol,nPixLin,NMAXCOL)
    */
 
	//����������������������������������������������������������������Ŀ
	//� Imprime Cabe�alho dos Itens da Ordem de Separa��o			   �
	//������������������������������������������������������������������
	nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)

	nPixLin += 08

	While ! CB8->(EOF()) .and. (CB8->CB8_FILIAL+CB8->CB8_ORDSEP == xFilial("CB8")+cOrdSep)

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+CB8->CB8_PROD)

		aAdd(aItens,{CB8->CB8_PROD,;
					 Substr(SB1->B1_DESC,1,37),;
					 Alltrim(Transform(CB8->CB8_QTDORI,"@E 9,999,999")),;
					 SB1->B1_UM,;
					 CB8->CB8_LOCAL,;
					 CB8->CB8_LCALIZ,;
					 CB8->CB8_LOTECT,;
					 (Transform(CB8->CB8_SALDOS,"@E 9,999,999"))})

    	CB8->(dbSkip())
	EndDo

	For nX := 1 to Len(aItens)
		nPixLin := IncLinTb(nPixLin,nPixCol)
		oPrn:Say(nPixLin		,nPixCol+005	,aItens[nX][01]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+095	,aItens[nX][02]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+315	,aItens[nX][03]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+360	,aItens[nX][04]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+390	,aItens[nX][05]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+420	,aItens[nX][06]	,oFont12c,,)
		oPrn:Say(nPixLin		,nPixCol+480	,aItens[nX][07]	,oFont12c,,)
//		oPrn:Say(nPixLin		,nPixCol+490	,aItens[nX][08]	,oFont11,,)

		If nPixLin > 700 
			nPage := RodaImp(nPage,nPixLin,nPixCol)
			nPixLin	:= CabPrint(nPage,lSaida,{})
			nPixLin := CabPrIt(nPixLin,nPixCol,lSaida)
        EndIf
	Next nX
	
	nPage := RodaImp(nPage,nPixLin,nPixCol)			
EndIf

//���������������������������������Ŀ
//�Fiinaliza a Pagina				�
//�����������������������������������
oPrn:EndPage()   		

Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �CabPrint	� Autor � Rodrigo Sousa         � Data � 02/06/2015���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Cabe�alho do Relat�rio							   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function CabPrint(nPage,lSaida,aDadosCli)

Local nLin		:= NMINLIN
Local nCol		:= NMINCOL
Local nZ		:= 0

Local cLogo		:= "logoqualy.bmp" 
Local cPedCli	:= ""

Local cStatus 	:= RetStatus(CB7->CB7_STATUS)
Local cQuery 	:= ""
Local cAlias	:= ""

DEFAULT nPage		:= 1
DEFAULT lSaida		:= .F.
DEFAULT aDadosCli	:= {}

//�����������������������Ŀ
//�Inicializa a pagina    �
//�������������������������
oPrn:StartPage()	

oPrn:Box(nLin,nCol,NMAXLIN,NMAXCOL)

If cEmpAnt == '08'
	oPrn:SayBitmap(nLin+=15,nCol+10,"logoqualy.bmp",115,35)	
ElseIf cEmpAnt == '02'
	oPrn:SayBitmap(nLin+=15,nCol+10,"logoeuro.bmp",90,35)	
Else
	nLin += 15
EndIf	

oPrn:Say(nLin+=15,nCol+50,PadC("O R D E M  D E  S E P A R A � � O",125),oFont14n)
oPrn:Say(nLin+=15,nCol+270,Alltrim(CB7->CB7_ORDSEP),oFont12n)

oPrn:DataMatrix(500,090,Alltrim(CB7->CB7_ORDSEP), 60 )

oPrn:Line(nLin+=15,nCol,90,NMAXCOL)

If lSaida

	If CB7->CB7_ORIGEM == "1"
		oPrn:Say(nLin+=12,nCol+005,Left(Iif(!Empty(SC5->C5_NUM)," Pedido: "+SC5->C5_NUM + " (" + Dtoc(SC5->C5_EMISSAO) + ")","")+" Status: "+cStatus,90),oFont12c,,)
    Else
		oPrn:Say(nLin+=12,nCol+005,Left("Nota Fiscal: "+CB7->CB7_NOTA+"-"+CB7->CB7_SERIE + "(" + Dtoc(SF2->F2_EMISSAO) + ") "+Iif(!Empty(SC5->C5_NUM)," Pedido: "+SC5->C5_NUM + " (" + Dtoc(SC5->C5_EMISSAO) + ")","")+" Status: "+cStatus,90),oFont12c,,)
	EndIf

	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)

	//����������������������������������������������������������������Ŀ
	//� Imprime Quadro Dados do Cliente e Dados do Pedido			   �
	//������������������������������������������������������������������
	//oPrn:Line(nPixLin,nPixCol+300,nPixLin+42,nPixCol+300)
	//oPrn:Say(nPixLin+=10,nPixCol+005,"DADOS DO CLIENTE",oFont09n,,)
	//oPrn:Say(nPixLin,nPixCol+305,"DADOS DO PEDIDO",oFont09n,,)
	
	oPrn:Say(nLin+=012	,nCol+005	,"Cliente......: "+Left(aDadosCli[XCOD]+"/"+aDadosCli[XLOJA]+" - "+Alltrim(aDadosCli[XNOME]),94),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"Vendedor(a)..: "+Left(SA3->A3_COD+" - "+Alltrim(SA3->A3_NOME),45),oFont12c,,)
	//oPrn:Say(nPixLin		,nPixCol+450	,"Cond. Pagto.: "+SE4->E4_CODIGO+"  -  "+SE4->E4_DESCRI,oFont07,,)
	
	oPrn:Say(nLin+=012	,nCol+005	,"Endere�o.....: "+Left(Alltrim(aDadosCli[XEND])+" - "+Alltrim(aDadosCli[XBAIR])+" - "+Alltrim(aDadosCli[XMUN])+" - "+Alltrim(aDadosCli[XEST])+" - "+TransForm(Alltrim(aDadosCli[XCEP]), "@R 99999-999"),80),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"End. Entr....: "+Left(Alltrim(aDadosCli[XENDENT])+" - "+Alltrim(aDadosCli[XBAIRROE])+" - "+Alltrim(aDadosCli[XMUNE])+" - "+Alltrim(aDadosCli[XESTE])+" - "+Transform(Alltrim(aDadosCli[XCEPE]),"@R 99999-999"),80),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"Transportador: "+Left(SA4->A4_COD+" - "+Alltrim(SA4->A4_NOME),41)+" Tel.: "+Alltrim(SA4->A4_TEL),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+005	,"End. Transp..: "+Left(AllTrim(SA4->A4_END)+" - "+ AllTrim(SA4->A4_MUN) + " - " + SA4->A4_EST + " - " + TransForm(SA4->A4_CEP, "@R 99999-999"),80),oFont12c,,)

	oPrn:Say( nLin+=012, nCol+005	,"Observa��es..: " + MemoLine(SC5->C5_OBS, 80, 1) , oFont12c,,,,)
	For i := 2 To MlCount(SC5->C5_OBS, 80)
		If Empty(AllTrim(MemoLine(SC5->C5_OBS, 80, i)))
			oPrn:Say( nLin+=012,nCol+045, Space(15) + AllTrim(MemoLine(SC5->C5_OBS, 80, i)), oFont12c,,,,)
		EndIf	
	Next

	If !Empty(SA1->A1_U_ENTRG)
				oPrn:Say( nLin+=012, nCol+015, Space(15) + "*** " + AllTrim(SA1->A1_U_ENTRG) + " ***", oFont12c,,,,)
	EndIf

	If AllTrim(SA1->A1_LAUDO) == "S"
		oPrn:Say( nLin+=020, nCol+045, Space(15) + "*** ACOMPANHA LAUDO ***", oFont12cn,,,,)
	EndIf


	If CB7->CB7_ORIGEM == "2"
	
		cVolumes := Iif(SF2->F2_VOLUME1 > 0,Transform(SF2->F2_VOLUME1,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI1),"");
				+ Iif(SF2->F2_VOLUME2 > 0,Transform(SF2->F2_VOLUME2,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI2),"");
				+ Iif(SF2->F2_VOLUME3 > 0,Transform(SF2->F2_VOLUME3,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI3),"");
				+ Iif(SF2->F2_VOLUME4 > 0,Transform(SF2->F2_VOLUME4,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI4),"");
				+ Iif(SF2->F2_VOLUME5 > 0,Transform(SF2->F2_VOLUME5,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI5),"");
				+ Iif(SF2->F2_VOLUME6 > 0,Transform(SF2->F2_VOLUME6,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI6),"");
				+ Iif(SF2->F2_VOLUME7 > 0,Transform(SF2->F2_VOLUME7,"@E 9,999") + " " + AllTrim(SF2->F2_ESPECI7),"")
	
		oPrn:Say( nLin+=020, nCol+005,  "Volumes......: " + cVolumes, oFont12c,,,,)

		oPrn:Say( nLin+=020,nCol+005, "Peso Bruto...: " + Transform(SF2->F2_PBRUTO, "@E 999,999,999.99") + " KG         Valor..........: R$ " + AllTrim(Transform(SF2->F2_VALMERC, "@E 999,999,999.99")), oFont12c,,,,)
	Else
		
		cAlias := GetNextAlias()
		
		If Select(cAlias) > 0
			(cAlias)->(dbCloseArea())
		EndIf
		
		cQuery := "SELECT SUM(ROUND(C6_PRCVEN * CB8_QTDORI,2)) AS TOTAL FROM "+RetSqlName("SC6")+" AS SC6 "+CRLF
		cQuery += "INNER JOIN "+RetSqlName("CB8")+" CB8 ON CB8_FILIAL = C6_FILIAL AND CB8_PEDIDO = C6_NUM AND CB8_ITEM = C6_ITEM AND CB8_NOTA = '' AND CB8.D_E_L_E_T_ = '' "+CRLF
		cQuery += "INNER JOIN "+RetSqlName("CB7")+" CB7 ON CB7_FILIAL = CB8_FILIAL AND CB7_ORDSEP = CB8_ORDSEP AND CB7_ORIGEM = '1' AND CB7.D_E_L_E_T_ = '' "+CRLF
		cQuery += "WHERE SC6.D_E_L_E_T_ = ''"+CRLF
		cQuery += "AND C6_FILIAL = '"+xFilial("SC6")+"'"+CRLF
		cQuery += "AND CB7_ORIGEM = '1'"+CRLF
		cQuery += "AND CB7_ORDSEP = '"+CB7->CB7_ORDSEP+"'"+CRLF
		
		TcQuery cQuery NEW ALIAS (cAlias)
		
		nTotal := (cAlias)->TOTAL

		(cAlias)->(dbCloseArea())
	
		cVolumes := Iif(SC5->C5_VOLUME1 > 0,Transform(SC5->C5_VOLUME1,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI1),"");
				+ Iif(SC5->C5_VOLUME2 > 0,Transform(SC5->C5_VOLUME2,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI2),"");
				+ Iif(SC5->C5_VOLUME3 > 0,Transform(SC5->C5_VOLUME3,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI3),"");
				+ Iif(SC5->C5_VOLUME4 > 0,Transform(SC5->C5_VOLUME4,"@E 9,999") + " " + AllTrim(SC5->C5_ESPECI4),"")		

		oPrn:Say( nLin+=020, nCol+005,  "Volumes......: " + cVolumes, oFont12c,,,,)

		oPrn:Say( nLin+=020,nCol+005, "Peso Bruto...: " + Transform(SC5->C5_PBRUTO, "@E 999,999,999.99") + " KG         Valor..........: R$ " + AllTrim(Transform(nTotal, "@E 999,999,999.99")), oFont12c,,,,)
	EndIf
	
	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)
Else
	cOP := Alltrim(CB7->CB7_OP)

	dbSelectArea("SC2")
	dbSetOrder(1)
	dbSeek(xFilial("SC2")+cOP)

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek( xFilial("SB1") + SC2->C2_PRODUTO )

	oPrn:Say(nLin+=08,nCol+005,"Ordem de Produ��o: "+cOP+" Status: "+cStatus,oFont07,,)
	oPrn:Line(nLin+=08,NMINCOL,nLin,NMAXCOL)

	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)

	//oPrn:DataMatrix(500,nLin+067,cOP, 60 )
	oPrn:DataMatrix(025,nLin+065,cOP, 60 )

	oPrn:Say(nLin+=012	,nCol+105	,"Ordem Produ��o......: " + Alltrim( cOp ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Emiss�o.............: " + DTOC( SC2->C2_EMISSAO ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Status Separa��o....: " + Alltrim( cStatus ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Produto.............: " + Alltrim( SC2->C2_PRODUTO ) + " | " + Alltrim( SB1->B1_DESC ),oFont12c,,)
	oPrn:Say(nLin+=012	,nCol+105	,"Quantidade..........: " + Transform( SC2->C2_QUANT, "@E 999,999,999.99"),oFont12c,,)
	
	oPrn:Line(nLin+=10,NMINCOL,nLin,NMAXCOL)
EnDif	

Return nLin
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �CabPrIt	� Autor � Rodrigo Sousa         � Data � 02/06/2015���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Cabe�alho do Item								   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function CabPrIt(nLin,nCol,lSaida)

//oPrn:Say(nLin+=08,nCol+005,"DADOS DOS PRODUTOS",oFont07n,,)

If lSaida
	nLin := IncLinTb(nLin,nCol)
	oPrn:Say(nLin		,nCol+005	,"Produto"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+095	,"Descri��o"		,oFont12cn,,)
	oPrn:Say(nLin		,nCol+310	,"Qtd."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+360	,"U.M."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+390	,"Arm."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+420	,"Endere�o"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+480	,"Lote"				,oFont12cn,,)
	//oPrn:Say(nLin		,nCol+420	,"Fabric."			,oFont07n,,)
	//oPrn:Say(nLin		,nCol+470	,"Validade"			,oFont07n,,)
	//oPrn:Say(nLin		,nCol+520	,"Entrega"			,oFont07n,,)
	//oPrn:Say(nLin		,nCol+490	,"Qtd. a Sep."	,oFont11n,,)
	//oPrn:Say(nLin		,nCol+580	,"Qtd. a Embalar"	,oFont09n,,)
Else
	nLin := IncLinTb(nLin,nCol)
	oPrn:Say(nLin		,nCol+005	,"Produto"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+095	,"Descri��o"		,oFont12cn,,)
	oPrn:Say(nLin		,nCol+310	,"Qtd."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+360	,"U.M."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+390	,"Arm."				,oFont12cn,,)
	oPrn:Say(nLin		,nCol+420	,"Endere�o"			,oFont12cn,,)
	oPrn:Say(nLin		,nCol+480	,"Lote"				,oFont12cn,,)
	//oPrn:Say(nLin		,nCol+420	,"Fabric."			,oFont07n,,)
	//oPrn:Say(nLin		,nCol+470	,"Validade"			,oFont07n,,)
	//oPrn:Say(nLin		,nCol+520	,"Entrega"			,oFont07n,,)
	//oPrn:Say(nLin		,nCol+490	,"Qtd. a Sep."	,oFont11n,,)
	//oPrn:Say(nLin		,nCol+580	,"Qtd. a Embalar"	,oFont09n,,)
EndIf

Return nLin
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �StartPrint� Autor � Rodrigo Sousa         � Data � 02/10/2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function StartPrint()

If ValType(oPrn) == "O"
  	oPrn:Print()
Else
	MsgInfo('O Objeto de impress�o n�o foi inicializado com exito')
EndIf

Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �StartPrint� Autor � Rodrigo Sousa         � Data � 02/10/2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function RetStatus(cStatus)
Local cDescri:= " "

If Empty(cStatus) .or. cStatus == "0"
	cDescri:= "Nao iniciado"
ElseIf cStatus == "1"
	cDescri:= "Em separacao"
ElseIf cStatus == "2"
	cDescri:= "Separacao finalizada"
ElseIf cStatus == "3"
	cDescri:= "Em processo de embalagem"
ElseIf cStatus == "4"
	cDescri:= "Embalagem Finalizada"
ElseIf cStatus == "5"
	cDescri:= "Nota gerada"
ElseIf cStatus == "6"
	cDescri:= "Nota impressa"
ElseIf cStatus == "7"
	cDescri:= "Volume impresso"
ElseIf cStatus == "8"
	cDescri:= "Em processo de embarque"
ElseIf cStatus == "9"
	cDescri:= "Finalizado"
EndIf

Return(cDescri)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �StartPrint� Autor � Rodrigo Sousa         � Data � 02/10/2011���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function IncLinTb(nLin,nCol)

Local nRet	:= 0

oPrn:Line(nLin,nCol+94,nLin+25,nCol+94)
oPrn:Line(nLin,nCol+309,nLin+25,nCol+309)
oPrn:Line(nLin,nCol+359,nLin+25,nCol+359)
oPrn:Line(nLin,nCol+389,nLin+25,nCol+389)
oPrn:Line(nLin,nCol+419,nLin+25,nCol+419)
oPrn:Line(nLin,nCol+479,nLin+25,nCol+479)

nRet := nLin + 20

oPrn:Line(nRet+5,NMINCOL,nRet+5,NMAXCOL)


Return nRet

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidPerg � Autor � Rodrigo Sousa         � Data � 16/02/2012���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function RodaImp(nPage,nPixLin,nPixCol)

Local nRet := nPage + 1 

oPrn:Say(710,nPixCol+005,"Separador: _________________________________________ Conferente: _______________________________________ Data ______ /______ /______ ",oFont09n,,)

nPixLin := 720

oPrn:Line(nPixLin+=10,nPixCol,nPixLin,NMAXCOL)
oPrn:Say(nPixLin+=10,nPixCol+050,"INICIAR PRODU��O",oFont08)
oPrn:DataMatrix(nPixCol+050, nPixLin+56, "01" , 55 )
oPrn:Say(nPixLin    ,nPixCol+430,"FINALIZAR PRODU��O",oFont08)
oPrn:DataMatrix(nPixCol+430, nPixLin+56, "04", 55 )

oPrn:EndPage()

Return nRet
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidPerg � Autor � Rodrigo Sousa         � Data � 16/02/2012���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}

cPerg := cPerg + Space(4)

Aadd(_aPerg, {cPerg, "01", "Ordem de Sep. De ?"	  	, "MV_CH1" ,  "C", 06	, 0	, "G"	, "MV_PAR01", "CB7"		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "02", "Ordem de Sep. Ate ?"  	, "MV_CH2" ,  "C", 06	, 0	, "G"	, "MV_PAR02", "CB7"		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "03", "Data de Emissao De ?" 	, "MV_CH3" ,  "D", 08	, 0	, "G"	, "MV_PAR03", ""		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "04", "Data de Emissao Ate ?"	, "MV_CH4" ,  "D", 08	, 0	, "G"	, "MV_PAR04", ""		,""		,""			,"","",""})
Aadd(_aPerg, {cPerg, "05", "Cons.Sep.Encerradas ?"	, "MV_CH5" ,  "N", 1	, 0	, "C"	, "MV_PAR05", ""		,"Sim"		,"N�o"			,"","",""})
Aadd(_aPerg, {cPerg, "06", "Imprime Cod.Barras ?"	, "MV_CH6" ,  "N", 1	, 0	, "C"	, "MV_PAR06", ""		,"Sim"		,"N�o"			,"","",""})
//Aadd(_aPerg, {cPerg, "07", "Ordena Por?"			, "MV_CH7" ,  "N", 1	, 0	, "C"	, "MV_PAR07", ""		,"Localiza��o"		,"U.M. + Localiza��o"			,"","",""})
//Aadd(_aPerg, {cPerg, "08", "Quebra Pagina P/ UM?"	, "MV_CH8" ,  "N", 1	, 0	, "C"	, "MV_PAR08", ""		,"Sim"		,"N�o"			,"","",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(_aPerg)
	IF  !DbSeek(_aPerg[i,1]+_aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with _aPerg[i,01]
	Replace X1_ORDEM   with _aPerg[i,02]
	Replace X1_PERGUNT with _aPerg[i,03]
	Replace X1_VARIAVL with _aPerg[i,04]
	Replace X1_TIPO	   with _aPerg[i,05]
	Replace X1_TAMANHO with _aPerg[i,06]
	Replace X1_PRESEL  with _aPerg[i,07]
	Replace X1_GSC	   with _aPerg[i,08]
	Replace X1_VAR01   with _aPerg[i,09]
	Replace X1_F3	   with _aPerg[i,10]
	Replace X1_DEF01   with _aPerg[i,11]
	Replace X1_DEF02   with _aPerg[i,12]
	Replace X1_DEF03   with _aPerg[i,13]
	Replace X1_DEF04   with _aPerg[i,14]
	Replace X1_DEF05   with _aPerg[i,15]
	MsUnlock()
Next i

RestArea(_aArea)

Return(.T.)
