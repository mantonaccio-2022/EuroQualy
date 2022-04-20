#INCLUDE "RptDef.ch"
#INCLUDE "FWPrintSetup.ch"
#include "totvs.CH"

#DEFINE	 IMP_DISCO 	1
#DEFINE	 IMP_SPOOL 	2
#DEFINE	 IMP_EMAIL 	3
#DEFINE	 IMP_EXCEL 	4
#DEFINE	 IMP_HTML  	5
#DEFINE	 IMP_PDF   	6

#DEFINE	 NMINLIN	030
#DEFINE  NMINCOL	020
#DEFINE	 NMAXLIN   	820
#DEFINE	 NMAXCOL   	580

#DEFINE	 REL_NAME	"Ordem de Produção 3"
#DEFINE  REL_PATH	"c:\temp\"

/*/{Protheus.doc} EQNewOP3
Impressao da Novo Layput de OP
@type function Relatorio
@version   1.0
@author mario.antonaccio
@since 25/10/2021
@param _cNumOP, character, Numero da OP
@return Character, sem retorno
/*/
User Function EQNewOP3( _cNumOP )

	Private oFont06,oFont07,oFont07n,oFont08,oFont08n,oFont09,oFont09n,oFont10,oFont10n,oFont12,oFont12n,oFont14,oFont14n,oFont16,oFont16n,oFontC7,oFontC7n,oFontCAn
	Private oPrn 		:= Nil
	Private oSetup		:= Nil
	Private cRelName    := ""
	Private cPerg	    := "BENOVORDEM"
	Private lPrimeiro   := .T.
	Private lQualidade  := .T.
	Private cNumOP      := ""
	//Private oBrush      := TBrush():New(,CLR_BLUE,,)
	Private oBrush      := TBrush():New(,CLR_WHITE,,)
	Private oBrusCin    := TBrush():New(,CLR_HGRAY,,)
	Private nPage       := 0
	Private nPagina     := 0
	Private nPagOP      := 0
	Private aQuery :={}
	Private aDados as Array
	Private nSalta    := 0  // Para as operações 50 , será impresso minimo e maximo
	Private nLin_		:= NMINLIN
	Private nCol_		:= NMINCOL
	Private nLin		:= 0
	Private nCol		:= 0

	Private _TMPCOM := GetNextAlias() //Arquivo Base do relatorio
	Private _TMPSC2 := GetNextAlias() //Arquivo que verifica se existe saldo Disponivel
	Private _TMPSEP := GetNextAlias() //Arquivo que indica as ordens de separacao
	Private _TMPROT := GetNextAlias() //Arquivo que indica os roteiros de operação
	Private _SEMOPE := GetNextAlias() //Arquivo que indica as OP sem operação
	Private _TMPSD4 := GetNextAlias() //Arquivo dos empenhos
	Private _TMPQUA := GetNextAlias() //Arquivo de Operaçoes da Qualidade

	Private cLogo		:= ""
	Private cCartCorp	:= ""

	_cNumOP     := ""
	//Default _cNumOP     := ""

	MakeDir( "C:\Temp\" )

	If Empty( _cNumOP )
		Pergunte( cPerg, .T.)
		_cNumOP := mv_par01
	EndIf

	cNumOP  := AllTrim( _cNumOP )
	cNumAte := AllTrim( mv_par02 )

	If PrepPrint()
		RptStatus({|| ExecPrint() },"Imprimindo Ordem de Producao...")
	EndIf

Return

/*/{Protheus.doc} PrepPrint
Prepara a Execução do relatorio
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 25/10/2021
@param cPathDest, character, Diretorio onde sera gravado
@param cRelName, character, nome do relatorio
@return logical, sem retorno
/*/
Static Function PrepPrint(cPathDest,cRelName)

	//Local nX	:= 0
	Local lRet 	:= .T.

	cPathDest   := REL_PATH
	cRelName	:= REL_NAME

	cRelName := "OP_" + AllTrim( cNumOP ) + "_"  + DTOS( dDataBase ) + "_" + Replace( Time(), ":", "") + ".PDF"

	//Instancia os objetos de fonte
	oFont06  := TFont():New( "Courier New",, 06,,.F.)
	oFont07n := TFont():New( "Arial",, 07,,.T.)
	oFont07  := TFont():New( "Arial",, 07,,.F.)
	oFont08n := TFont():New( "Arial",, 08,,.T.)
	oFont08  := TFont():New( "Arial",, 08,,.F.)
	oFont09  := TFont():New( "Arial",, 09,,.F.)
	oFont09n := TFont():New( "Arial",, 09,,.T.)
	oFont10n := TFont():New( "Arial",, 10,,.T.)
	oFont10  := TFont():New( "Arial",, 10,,.F.)
	oFont12n := TFont():New( "Arial",, 12,,.T.)
	oFont12  := TFont():New( "Arial",, 12,,.F.)
	oFont14n := TFont():New( "Arial",, 14,,.T.)
	oFont14  := TFont():New( "Arial",, 14,,.F.)
	oFont16n := TFont():New( "Arial",, 16,,.T.)
	oFont16  := TFont():New( "Arial",, 16,,.F.)
	oFontC7n := TFont():New( "Courier New",, 08,,.T.)
	oFontC7  := TFont():New( "Courier New",, 08,,.F.)
	oFontCAn := TFont():New( "Courier New",, 16,,.T.)
	oFontC10n:= TFont():New( "Courier New",, 10,,.T.)

	//Instancia a Classe FwMsPrinter
	oPrn := FwMsPrinter():New(cRelName,IMP_PDF,.F.,cPathDest,.T.,.F.,@oPrn,,,.F.,.F.,.T.,)
	oPrn:SetResolution(72)
	oPrn:SetPortrait()
	oPrn:SetPaperSize(DMPAPER_A4)

	oPrn:cPathPDF := cPathDest 			//Caso seja utilizada impress?o em IMP_PDF

	//Instancia a Classe FWPrintSetup
	oSetup := FWPrintSetup():New(PD_ISTOTVSPRINTER+PD_DISABLEORIENTATION+PD_DISABLEDESTINATION+PD_DISABLEPAPERSIZE+PD_DISABLEPREVIEW ,"EQNewOP2")
	oSetup:SetUserParms({|| Pergunte(cPerg, .T.)})
	oSetup:SetProperty(PD_MARGIN,{05,05,05,05})
	oSetup:SetProperty(PD_DESTINATION,2)

	//Ativa Tela de Setup
	If oSetup:Activate() == 2
		lRet	:= .F.
	EndIf

Return lRet

/*/{Protheus.doc} ExecPrint
Executa o relatorio
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 25/10/2021
@return character, sem retorno
/*/
Static Function ExecPrint()

	Local lProc       := .F.

	Private aEmpSaldo := {}

	//Cria Arquivo Da OP
	fArquivos("TMPCOM")

	SetRegua( (_TMPCOM)->( RecCount() ) )

	cNumOP := (_TMPCOM)->C2_NUM + (_TMPCOM)->C2_ITEM + (_TMPCOM)->C2_SEQUEN

	While (_TMPCOM)->(!EOF())

		If Left( cNumOP, 6) <> (_TMPCOM)->C2_NUM
			cNumOP  := (_TMPCOM)->C2_NUM + (_TMPCOM)->C2_ITEM + (_TMPCOM)->C2_SEQUEN
			nPage   := 1
			nPagina := 1
			If Mod( nPagOP, 2) <> 0
				oPrn:EndPage()
				oPrn:StartPage()
				nPagOP++
			EndIf
		Else
			nPage++
			nPagina++
		EndIf

		IncRegua("Imprimindo")

		aEmpSaldo := {}

		cMsg := ""

		fArquivos("TMPSC2")

		While (_TMPSC2)->(!Eof() )
			cMsg += "Produto: " + (_TMPSC2)->D4_COD + " Necessário: " + Transform( (_TMPSC2)->QUANTIDADE, "@E 999,999.99") + " Saldo: " + Transform( (_TMPSC2)->SALDO, "@E 999,999.99") + CRLF
			aAdd( aEmpSaldo, { (_TMPSC2)->D4_COD })
			(_TMPSC2)->( dbSkip() )
		EndDo

		If !Empty( cMsg )
			Aviso( "EQNEWOP2 - Aviso", "Ordem de Produção possui componentes sem saldo suficiente disponivel:" + CRLF + cMsg, {"OK"}, 3)
		EndIf
		(_TMPSC2)->( dbCloseArea() )

		lQualidade := .T.

		RunPrint()

		lProc	   := .T.
		(_TMPCOM)->( dbSkip() )

	EndDo

	If lProc
		StartPrint()
	Else
		ApMsgInfo('Não há dados!', 'Sem dados')
	EndIf

	(_TMPCOM)->( dbCloseArea() )

Return

/*/{Protheus.doc} RunPrint
Impressao do relatorio
@type function Relatorio
@version 1.00
@author mario.antonaccio
@since 25/10/2021
@return character, sem retorno
/*/
Static Function RunPrint()

	// Imprime Cabeçalho da Ordem de Separação
	CabPrint(nPage)

	// Cabecalho Operação
	CabPrintOP(nPage)

	// Imprime Cabeçalho dos Itens da Ordem de Separação
	//CabPrIt(nPixLin,nPixCol)

	//Finaliza a Pagina
	oPrn:EndPage()

Return

/*/{Protheus.doc} CabPrint
Cabecalho do Relatorio
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 25/10/2021
@param nPage, numeric, Numero da Pagina
@return character, sem retorno
/*/
Static Function CabPrint(nPage)

	cCartCorp := "coletor.jfif"
	If cEmpAnt == "02"
		cLogo     := "logoeuro.bmp"
		cEmpresa  := "Euroamerican"
	Else
		cLogo     := "logoqualy.bmp"
		cEmpresa  := "Qualycril"
	EndIf

	//Inicializa a pagina
	oPrn:StartPage()
	nPagOP++

	//Box Geral
	nLin+=nLin_
	nCol+=nCol_
	oPrn:Box(nLin,nCol,NMAXLIN,NMAXCOL)

	//Logo Descriçao Filial
	nLin+=5
	oPrn:SayBitmap(nLin,nCol+5, GetSrvProfString("Startpath","") + cLogo,55,17)
	nLin+=5
	oPrn:Say(nLin,nCol+70,AllTrim( SM0->M0_FILIAL ),oFont06)
	nLin+=5
	oPrn:Say(nLin,nCol+70, PadC("ORDEM DE PRODUÇÃO",120),oFont14n)
	oPrn:Say(nLin,NMAXCOL-40,"Página: " + StrZero(nPagina, 3),oFont06)

	//Quadro PMP
	//	oPrn:FillRect({nLin+12,nCol+395,nLin+46,NMAXCOL-12},oBrush)
	oPrn:Box(nLin+10,nCol+383,nLin+108,NMAXCOL-5  ) //Quadro
	nLin+=20
	oPrn:Say(nLin,nCol+005,"LOTE: " + (_TMPCOM)->C2_NUM + " " + (_TMPCOM)->C2_ITEM + " " +(_TMPCOM)->C2_SEQUEN,oFont08n)

	// Quadro do PMP -  Linha 1
	oPrn:Say(nLin,nCol+390,"PCP                       PMP QUALYVINIL"     ,oFont10n,,CLR_BLACK)
	oPrn:Line(nLin+3,nCol+383,nLin+3,NMAXCOL-5)  // Linha abaixo do cabecalho do quadro

	nLin+=12
	oPrn:Say(nLin,nCol+390,"Equipamento        Sequencia"       ,oFont10n,,CLR_BLACK)
	oPrn:Line(nLin+5,nCol+383,nLin+5,NMAXCOL-5) // Linha abaixo do cabecalho dos itens do quadro
	oPrn:Line(nLin-22,nCol+450,nLin+51,nCol+450) // Linha Vertical
	nLin+=10  //alterado de 20 para 10 - maa 20220318
	oPrn:Say(nLin,nCol+005,"PRODUTO: " + (_TMPCOM)->C2_PRODUTO,oFont08n)
	nLin+=10  //alterado de 20 para 10 - maa 20220318
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + (_TMPCOM)->C2_PRODUTO))
	oPrn:Say(nLin,nCol+005,"DESCRIÇÂO: " +  AllTrim(SB1->B1_DESC),oFont08n)

	// Verifica se tem ordem de separação
	fArquivos("TMPSEP")
	If (_TMPSEP)->( ! Eof() )
		nLin+=15
		While (_TMPSEP)->( ! Eof() )
			oPrn:Say(nLin,nCol+5,"ORDEM DE SEP.: " + (_TMPSEP)->CB7_ORDSEP,oFont08n)
			nLin+=5
			(_TMPSEP)->( dbSkip() )
		End
		(_TMPSEP)->( dbCloseArea() )
		//Retorna linha antes de da impressao da OS
		nLin-=15
	End

	//QR Code Numero OP
	oPrn:DataMatrix(nCol+250, nLin+10, (_TMPCOM)->C2_NUM + (_TMPCOM)->C2_ITEM + (_TMPCOM)->C2_SEQUEN, 55 )

	nLin+=20
	oPrn:Line(nLin-13,nCol+383,nLin-13,NMAXCOL-5) // Linha acima linha data do quadro
	oPrn:Say(nLin+5,nCol+390,"DATA:  ______/_______/______"          ,oFont10n,,CLR_BLACK)
	//Detalhes
	nLin+=10  //alterado de 30 para 10 - maa 20220318
	oPrn:Say(nLin,nCol+5,"Qtd. Prev. (KG): " + Transform( (_TMPCOM)->C2_QUANT, "@E 999,999,999.99"),oFont08)
	//oPrn:Say(nLin,nCol+50,"Revisão: ",oFont08)
	oPrn:Say(nLin,nCol+390,"Quant. Real : ( ___________ )   KG",oFont08n)
	oPrn:Line(nLin+10,nCol,nLin+10,NMAXCOL)

	/*
	oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)
	oPrn:Say(nLin+12,nCol+010,"# Itens Sem Saldos [ * ] #",oFont10n,,CLR_HRED)
	oPrn:Say(nLin+22,nCol+010,"LOCAL: " + (_TMPCOM)->C2_LOCAL,oFont08)
	oPrn:Say(nLin+32,nCol+010,"PREV INICIAL: " + DTOC(STOD((_TMPCOM)->C2_DATPRI)),oFont08)
	oPrn:Say(nLin+42,nCol+010,"PREV FINAL:   " + DTOC(STOD((_TMPCOM)->C2_DATPRI)),oFont08)
	oPrn:Line(nLin+=60,nCol,nLin,NMAXCOL)
	*/
Return

/*/{Protheus.doc} CabPrintOP
Impressao do cabecalho das operações
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 01/12/2021
@param nLin, numeric, numero da linha
@param nPage, numeric, numero da pagian
@return numeric, numero da ultima linha processada
/*/
Static Function CabPrintOP(nPage)

	fArquivos("TMPROT")
	nLin += 020

	While   (_TMPROT)->(!Eof() )

		If (_TMPROT)->G2_OPERAC == '50' // Quando conter a operacao 50 ira incrementar a numeracao
			nSalta++
		Endif

		oPrn:Say(nLin,nCol+050,"Operacao: " + (_TMPROT)->G2_OPERAC,oFont08)

		//QR CODE Operação
		oPrn:DataMatrix(nCol+050, nLin+56, (_TMPROT)->G2_OPERAC , 55 )

		oPrn:Say(nLin    ,nCol+430,"Recurso: " + (_TMPROT)->G2_RECURSO,oFont08)

		//QR Code Recurso
		oPrn:DataMatrix(nCol+430, nLin+56, (_TMPROT)->G2_RECURSO, 55 )

		nLin+=1
		oPrn:Say(nLin,nCol+050,PadC("OPERACAO " + (_TMPROT)->G2_OPERAC + " " + AllTrim( (_TMPROT)->G2_DESCRI ),120),oFont14n)
		nLin+=10
		oPrn:Say(nLin,nCol+230,"Seq. Inicial: " + (_TMPROT)->Z0_SEQINI + " Seq. Final: " + AllTrim( (_TMPROT)->Z0_SEQFIN ),oFont08)
		oPrn:Line(nLin+=45,nCol,nLin+=45,NMAXCOL)

		nLin+=5
		oPrn:Say(nLin+=10,nCol+005,(_TMPROT)->INSTRUCAO,oFont08)

		oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

		oPrn:Box(nLin,nCol+000,nLin + 10,nCol+035) // TRT
		oPrn:Box(nLin,nCol+035,nLin + 10,nCol+095) // Codigo
		oPrn:Box(nLin,nCol+095,nLin + 10,nCol+325) // Descricaoo
		oPrn:Box(nLin,nCol+325,nLin + 10,nCol+425) // Quantidade
		oPrn:Box(nLin,nCol+425,nLin + 10,nCol+515) // Lote
		oPrn:Box(nLin,nCol+515,nLin + 10,NMAXCOL)  // Qtd. Real

		nLin += 005  //alterado de 8 para 5 - maa 20220318

		oPrn:Say(nLin-001	,nCol+005	,"TRT"												,oFont10n,,)
		oPrn:Say(nLin-001	,nCol+040	,"Codigo"											,oFont10n,,)
		oPrn:Say(nLin-001	,nCol+100	,"Descricao"										,oFont10n,,)
		oPrn:Say(nLin-001	,nCol+330	,"Quantidade"										,oFont10n,,)
		oPrn:Say(nLin-001	,nCol+430	,"Lote"												,oFont10n,,)
		oPrn:Say(nLin-001	,nCol+520	,"Qtd.Real"											,oFont10n,,)

		fArquivos("TMPSD4")

		While  (_TMPSD4)->(!Eof() )

			If nLin > 684  //Quebra pagina
				oPrn:EndPage()
				nPage++
				nPagina++
				nPagOP++

				nLin := NMINLIN
				nCol := NMINCOL

				CabPrint(nPage)
				nLin  += 020
			EndIf

			oPrn:Box(nLin,nCol+000,nLin + 20,nCol+035) // TRT  //10
			oPrn:Box(nLin,nCol+035,nLin + 20,nCol+095) // Codigo
			oPrn:Box(nLin,nCol+095,nLin + 20,nCol+325) // Descricao
			oPrn:Box(nLin,nCol+325,nLin + 20,nCol+425) // Quantidade
			oPrn:Box(nLin,nCol+425,nLin + 20,nCol+515) // Lote
			oPrn:Box(nLin,nCol+515,nLin + 20,NMAXCOL)  // Qtd. Real

			cFalta := ""
			If aScan( aEmpSaldo, {|x| AllTrim( (_TMPSD4)->D4_COD ) == AllTrim( x[1] ) }) > 0
				cFalta := " [ * ]"
			EndIf

			nLin += 015 //008
			oPrn:Say(nLin-002	,nCol+005	,(_TMPSD4)->D4_TRT											,oFont08,,)
			oPrn:Say(nLin-002	,nCol+040	,AllTrim( (_TMPSD4)->D4_COD ) + cFalta						,oFont08,,)
			oPrn:Say(nLin-002	,nCol+100	,(_TMPSD4)->B1_DESC										,oFont08,,)
			oPrn:Say(nLin-002	,nCol+345	,Transform( (_TMPSD4)->D4_QUANT, "@E 999,999,999.999")		,oFontC7,,)
			oPrn:Say(nLin-002	,nCol+430	,(_TMPSD4)->D4_LOTECTL										,oFont08,,)
			oPrn:Say(nLin-002	,nCol+520	,""														,oFont08,,)

			(_TMPSD4)->( dbSkip() )

		EndDo
		(_TMPSD4)->( dbCloseArea() )

		If (_TMPROT)->G2_OPERAC == '50' .And. nSalta == 1  // se for opera??o 50 e contiver 1 na variavel nSalta, fazer apenas 1 impress?o
			oPrn:Say(nLin+30	,nCol+50	,"Minimo : ______________________                                                                                          Maximo : ______________________"			,oFont08)
		Endif

		nLin += 30

		(_TMPROT)->( dbSkip() )

	EndDo
	(_TMPROT)->( dbCloseArea() )

	If (_TMPCOM)->C2_ITEM + (_TMPCOM)->C2_SEQUEN == "01001"
		nLin := 694

		oPrn:Say(nLin+=05,nCol+005,"ADICAO EXTRA-FORMULA",oFont08)

		oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

		oPrn:Box(nLin,nCol+000,nLin + 20,nCol+095) // Codigo
		oPrn:Box(nLin,nCol+095,nLin + 20,nCol+325) // Descricao
		oPrn:Box(nLin,nCol+325,nLin + 20,nCol+425) // Quantidade
		oPrn:Box(nLin,nCol+425,nLin + 20,nCol+515) // Lote
		oPrn:Box(nLin,nCol+515,nLin + 20,NMAXCOL)  // Visto
		oPrn:Box(nLin,nCol+585,nLin + 20,NMAXCOL)  // 1o.Ajuste
		oPrn:Box(nLin,nCol+655,nLin + 20,NMAXCOL)  // 2o.Ajuste

		nLin += 008
		oPrn:Say(nLin-002	,nCol+005	,"Codigo"											,oFont07n,,)
		oPrn:Say(nLin-002	,nCol+100	,"Descricao"										,oFont07n,,)
		oPrn:Say(nLin-002	,nCol+330	,"Quantidade"										,oFont07n,,)
		oPrn:Say(nLin-002	,nCol+430	,"Lote"												,oFont07n,,)
		oPrn:Say(nLin-002	,nCol+520	,"Visto"											,oFont07n,,)
		oPrn:Say(nLin-002	,nCol+585	,"1o.Ajuste"										,oFont07n,,)
		oPrn:Say(nLin-001	,nCol+655	,"2o.Ajuste"										,oFont07n,,)

		oPrn:Box(nLin,nCol+000,nLin + 10,NMAXCOL)
		nLin += 008
		oPrn:Box(nLin,nCol+000,nLin + 10,NMAXCOL)
		nLin += 008
	EndIf

	nLin := 735

	oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

	oPrn:Say(nLin+=10,nCol+050,"INICIAR PRODUCAO",oFont08)
	oPrn:DataMatrix(nCol+050, nLin+56, "01" , 55 )

	// Informar se é operaçaõ sem sequência de fabricaçaõ...

	fArquivos("SEMOPE")

	If (_SEMOPE)->( !Eof() )
		oPrn:Say(nLin+14,nCol+155,"*** Produto possui Operações sem Sequência de Fabricaçaõ ***",oFont10n,,CLR_HRED)
	EndIf

	n10 := 12

	While (_SEMOPE)->( !Eof() )

		oPrn:Say(nLin+14+n10,nCol+155,"Operação: " +  (_SEMOPE)->G2_OPERAC + " " +  (_SEMOPE)->G2_DESCRI,oFont08,,CLR_HRED)

		n10 += 10

		(_SEMOPE)->( dbSkip() )
	EndDo

	(_SEMOPE)->( dbCloseArea() )

	oPrn:Say(nLin    ,nCol+430,"FINALIZAR PRODUCAO",oFont08)
	oPrn:DataMatrix(nCol+430, nLin+56, "04", 55 )

	If (_TMPCOM)->C2_ITEM + (_TMPCOM)->C2_SEQUEN == "01001"
		oPrn:EndPage()
		nPage++
		nPagina++
		nPagOP++

		nLin := NMINLIN
		nCol := NMINCOL

		CabPrint(nPage)
		nLin  += 020
		fArquivos("TMPQUA")

		If !(_TMPQUA)->( Eof() )
			lQualidade := .T.

			oPrn:Say(nLin + 02 + 14,NMINCOL + 30,"Controle de Qualidade",oFont14n,,CLR_BLUE)
			oPrn:Line(nLin+=02 + 20,nCol,nLin,NMAXCOL)

			oPrn:Box( nLin, nCol+000        , nLin+010, nCol+025        ) // Item
			oPrn:Box( nLin, nCol+025        , nLin+010, nCol+085        ) // C¨®digo
			oPrn:Box( nLin, nCol+085        , nLin+010, nCol+245        ) // Ensaio
			oPrn:Box( nLin, nCol+245        , nLin+010, nCol+305        ) // Lim. Inf.
			oPrn:Box( nLin, nCol+305        , nLin+010, nCol+365        ) // Lim. Sup.
			oPrn:Box( nLin, nCol+365        , nLin+010, nCol+495        ) // Unid. Med.
			oPrn:Box( nLin, nCol+495        , nLin+010, NMAXCOL            ) // M¨¦todo

			nLin += 010
			oPrn:Say(nLin-002	,nCol+003	    ,"Item"				,oFont10n,,)
			oPrn:Say(nLin-002	,nCol+028       ,"Código"			,oFont10n,,)
			oPrn:Say(nLin-002	,nCol+088       ,"Ensaio"			,oFont10n,,)
			oPrn:Say(nLin-002	,nCol+248	    ,"Lim. Inf."		,oFont10n,,)
			oPrn:Say(nLin-002	,nCol+308	    ,"Lim. Sup."		,oFont10n,,)
			oPrn:Say(nLin-002	,nCol+368	    ,"Unid. Med."		,oFont10n,,)
			oPrn:Say(nLin-002	,nCol+498       ,"Método"			,oFont10n,,)
		Else
			lQualidade := .F.
		EndIf

		Do While !(_TMPQUA)->( Eof() )
			oPrn:Box( nLin, nCol+000        , nLin+010, nCol+025        ) // Item
			oPrn:Box( nLin, nCol+025        , nLin+010, nCol+085        ) // C¨®digo
			oPrn:Box( nLin, nCol+085        , nLin+010, nCol+245        ) // Ensaio
			oPrn:Box( nLin, nCol+245        , nLin+010, nCol+305        ) // Lim. Inf.
			oPrn:Box( nLin, nCol+305        , nLin+010, nCol+365        ) // Lim. Sup.
			oPrn:Box( nLin, nCol+365        , nLin+010, nCol+495        ) // Unid. Med.
			oPrn:Box( nLin, nCol+495        , nLin+010, NMAXCOL         ) // M¨¦todo

			nLin += 010
			oPrn:Say(nLin-002	,nCol+003	,AllTrim( (_TMPQUA)->QPJ_ITEM )								,oFont08,,)
			oPrn:Say(nLin-002	,nCol+028    ,AllTrim( (_TMPQUA)->QPJ_ENSAIO )								,oFont08,,)
			oPrn:Say(nLin-002	,nCol+088    ,AllTrim( (_TMPQUA)->ENSAIO )									,oFont08,,)
			oPrn:Say(nLin-002	,nCol+248	,Transform( (_TMPQUA), PesqPict("QPJ","QPJ_LINF",14))	,oFont08,,)
			oPrn:Say(nLin-002	,nCol+308	,Transform( (_TMPQUA), PesqPict("QPJ","QPJ_LSUP",14))	,oFont08,,)
			oPrn:Say(nLin-002	,nCol+368	,AllTrim( (_TMPQUA)->QPJ_DUNMED )								,oFont08,,)
			oPrn:Say(nLin-002	,nCol+498	,AllTrim( (_TMPQUA)->QP1_METODO)								,oFont08,,)

			//nLin += 010
			oPrn:Box( nLin, nCol+000        , nLin+050, NMAXCOL        ) // Item
			oPrn:Say(nLin+=010, 0050, "Analista.....:                     DT/HR INI: ____/____/____  ____:____ DT/HR FIN: ____/____/____  ____:____", oFontC7,,)
			oPrn:Say(nLin+=010, 0050, "Texto........: " + AllTrim( (_TMPQUA)->TEXTO ), oFontC7,,)
			oPrn:Say(nLin+=010, 0050, "Qtd. Amostra.: " + Transform( (_TMPQUA)->QP1_QTDE, PesqPict("QP1","QP1_QTDE",14)), oFontC7,,)
			oPrn:Say(nLin+=010, 0050, "Tipo.........: " + AllTrim( (_TMPQUA)->TIPO ) + "                           An¨¢lise 1: ________ An¨¢lise 2: ________ An¨¢lise 3: ________", oFontC7,,)
			nLin += 010

			(_TMPQUA)->( dbSkip() )
		EndDo
		(_TMPQUA)->( dbCloseArea() )

		oPrn:Say(nLin+=020, 0050, "Aprovado                  (   )                               Reprocessar                 (   )             ", oFontC7,,)
		oPrn:Say(nLin+=010, 0050, "Reprovado                 (   )                               Acerto Comercial            (   )             ", oFontC7,,)
		oPrn:Say(nLin+=010, 0050, "Aprovado Com Restrições   (   )                                                                             ", oFontC7,,)
		oPrn:Say(nLin+=010, 0050, "Analista.........:___________________________________________ Responsável..........:________________________", oFontC7,,)
		oPrn:Say(nLin+=010, 0050, "N. Retenção......:___________________________________________ Observações Gerais...:________________________", oFontC7,,)
		oPrn:Say(nLin+=010, 0050, "____________________________________________________________________________________________________________", oFontC7,,)
		oPrn:Say(nLin+=010, 0050, "____________________________________________________________________________________________________________", oFontC7,,)

		oPrn:Say(nLin+=060, 0420, "__________________________________", oFontC7n,,)
		oPrn:Say(nLin+=012, 0420, "            Assinatura            ", oFontC7n,,)

		nLin := 735

		oPrn:Line(nLin+=10,nCol,nLin,NMAXCOL)

		oPrn:Say(nLin+=10,nCol+050,"INICIAR PAUSA",oFont08)
		oPrn:DataMatrix(nCol+050, nLin+56, "02" , 55 )
		oPrn:Say(nLin    ,nCol+430,"FINALIZAR PAUSA",oFont08)
		oPrn:DataMatrix(nCol+430, nLin+56, "02", 55 )

		nPage++
		//nPagina++
	EndIf

	nLinBoxCab := nLin

Return nLin

/*/{Protheus.doc} CabPrIt
Impressao dos Itens
@type function relatorio
@version  1.00
@author mario.antonaccio
@since 25/10/2021
@param nLin, numeric, Numero da Linha
@param nCol, numeric, Numero da Coluna
@return numeric, numero da linha
/*/
Static Function CabPrIt(nLin,nCol)

Return nLin

/*/{Protheus.doc} StartPrint
Inicialização da Impressao
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 25/10/2021
@return character, sem retorno
/*/
Static Function StartPrint()

	If ValType(oPrn) == "O"
		oPrn:Print()
	Else
		Alert('O Objeto de impressão nao foi inicializado com exito')
	EndIf

Return

/*/{Protheus.doc}FArquivos
Gera arquivo Principala da OP
@type function Processamerto
@version  1.00
@author mario.antonaccio
@since 01/12/2021
@return Character, sem returno especifico
/*/
Static Function FArquivos(cArq)

	If cArq == "TMPCOM"
		BeginSql alias _TMPCOM
			SELECT
				SC2.C2_NUM,
				SC2.C2_ITEM,
				SC2.C2_SEQUEN,
				SC2.C2_PRODUTO,
				SC2.C2_LOCAL,
				SC2.C2_QUANT,
				SC2.C2_DATPRI,
				SC2.C2_ROTEIRO
			FROM
				%Table:SC2% SC2
			INNER JOIN %Table:SB1% SB1
			ON SC2.C2_PRODUTO = SB1.B1_COD
				AND SB1.%NotDel%
			WHERE
				SC2.C2_FILIAL = %Exp:xFilial("SC2")%
				AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN BETWEEN %Exp:cNumOP% AND %Exp:AllTrim(cNumAte)%
				AND SC2.%NotDel%
			ORDER BY
				SC2.C2_NUM,
				SC2.C2_ITEM,
				SC2.C2_SEQUEN,
				SC2.C2_PRODUTO
		EndSql

	ElseIf cArq =="TMPSC2"

		If SELECT((_TMPSC2)) > 0
			(_TMPSC2)->(dbCloseArea())
		End

		BeginSql alias _TMPSC2
			SELECT
				SD4.D4_COD,
				SUM(SD4.D4_QUANT) AS QUANTIDADE,
				SUM(SB2.B2_QATU) AS SALDO
			FROM
				%Table:SC2% SC2
			INNER JOIN %Table:SD4% SD4
			ON SC2.C2_FILIAL = SD4.D4_FILIAL
				AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN = SD4.D4_OP
				AND SC2.%NotDel%
			INNER JOIN %Table:SB1% SB1
			ON SC2.C2_PRODUTO = SB1.B1_COD
				AND SB1.%NotDel%
				AND SB1.B1_TIPO <> 'PI'
			INNER JOIN %Table:SB2% SB2
			ON SC2.C2_FILIAL = SB2.B2_FILIAL
				AND SD4.D4_COD = SB2.B2_COD
				AND SB2.%NotDel%
			WHERE
				SC2.C2_FILIAL = %Exp:xFilial("SC2")%
				AND SC2.C2_NUM = %Exp:(_TMPCOM)->C2_NUM%
				AND SC2.C2_ITEM = %Exp:(_TMPCOM)->C2_ITEM%
				AND SC2.C2_SEQUEN = %Exp:(_TMPCOM)->C2_SEQUEN%
				AND SC2.%NotDel%
			GROUP BY
				SD4.D4_COD
			HAVING
				SUM(SB2.B2_QATU) - SUM(SD4.D4_QUANT) < 0.00
		EndSql

	ElseIf cArq=="TMPSEP"

		// Verifica Ordem de Separação
		If SELECT((_TMPSEP)) > 0
			(_TMPSEP)->(dbCloseArea())
		End

		BeginSql alias _TMPSEP
			SELECT
				CB7_ORDSEP
			FROM
				%Table:CB7%
			WHERE
				CB7_FILIAL = %Exp:xFilial("CB7")%
				AND CB7_OP = %Exp:(_TMPCOM)->C2_NUM+(_TMPCOM)->C2_ITEM+(_TMPCOM)->C2_SEQUEN%
				AND %NotDel%
			ORDER BY
				CB7_ORDSEP
		EndSql

	ElseIf cArq == "TMPROT"

		If SELECT((_TMPROT)) > 0
			(_TMPROT)->(dbCloseArea())
		End

		If (_TMPCOM)->C2_ITEM + (_TMPCOM)->C2_SEQUEN == "01001"

			BeginSql alias _TMPROT
				SELECT
					SG2.G2_OPERAC,
					SG2.G2_RECURSO,
					SG2.G2_DESCRI,
					ISNULL(
						RTRIM(
							LTRIM(
								CONVERT(
									VARCHAR(8000),
									CONVERT(VARBINARY(8000), SZ0.Z0_DESCRIC)
								)
							)
						),
						''
					) AS INSTRUCAO,
					SZ0.Z0_SEQINI,
					SZ0.Z0_SEQFIN
				FROM
					%Table:SG2% AS SG2
				INNER JOIN %Table:SB1% AS SB1
				ON SB1.B1_FILIAL = %Exp:xFilial("SB1")%
					AND SG2.G2_PRODUTO = SB1.B1_COD
					AND (
						(
							SB1.B1_EQ_DISP <> 'N'
							AND SB1.B1_EQ_COMP <> 'N'
						)
						OR (
							SB1.B1_EQ_DISP = 'N'
							AND SB1.B1_EQ_COMP = 'N'
						)
					)
					AND SB1.%NotDel%
				INNER JOIN %Table:SH1% AS SH1
				ON SH1.H1_FILIAL = %Exp:xFilial("SH1")%
					AND SG2.G2_RECURSO = SH1.H1_CODIGO
					AND SH1.%NotDel%
				INNER JOIN %Table:SHB% AS SHB
				ON SHB.HB_FILIAL = %Exp:xFilial("SHB")%
					AND SG2.G2_CTRAB = SHB.HB_COD
					AND SHB.%NotDel%
				INNER JOIN %Table:SZ0% AS SZ0
				ON SZ0.Z0_FILIAL = %Exp:xFilial("SZ0")%
					AND SG2.G2_PRODUTO = SZ0.Z0_PRODUTO
					AND SG2.G2_OPERAC = SZ0.Z0_OPERAC
					AND SZ0.%NotDel%
				WHERE
					SG2.G2_FILIAL = %Exp:xFilial("SH1")%
					AND SG2.G2_CODIGO = %Exp:(_TMPCOM)->C2_ROTEIRO%
					AND SG2.G2_PRODUTO = %Exp:(_TMPCOM)->C2_PRODUTO%
					AND SG2.%NotDel%
				UNION
				ALL
				SELECT
					SG2.G2_OPERAC,
					SG2.G2_RECURSO,
					SG2.G2_DESCRI,
					ISNULL(
						RTRIM(
							LTRIM(
								CONVERT(
									VARCHAR(8000),
									CONVERT(VARBINARY(8000), SZ0.Z0_DESCRIC)
								)
							)
						),
						''
					) AS INSTRUCAO,
					'001' AS Z0_SEQINI,
					SZ0.Z0_SEQFIN
				FROM
					%Table:SG2% AS SG2
				INNER JOIN %Table:SB1% AS SB1
				ON SB1.B1_FILIAL = %Exp:xFilial("SB1")%
					AND SB1.B1_COD = SG2.G2_PRODUTO
					AND SB1.B1_EQ_DISP = 'N'
					AND SB1.B1_EQ_COMP <> 'N'
					AND SB1.%NotDel%
				INNER JOIN %Table:SH1% AS SH1
				ON SH1.H1_FILIAL = %Exp:xFilial("SH1")%
					AND SH1.H1_CODIGO = SG2.G2_RECURSO
					AND SH1.%NotDel%
				INNER JOIN %Table:SHB% AS SHB
				ON SHB.HB_FILIAL = %Exp:xFilial("SHB")%
					AND SHB.HB_COD = SG2.G2_CTRAB
					AND SHB.%NotDel%
				INNER JOIN %Table:SZ0% AS SZ0
				ON SZ0.Z0_FILIAL = %Exp:xFilial("SZ0")%
					AND SZ0.Z0_PRODUTO = SG2.G2_PRODUTO
					AND SZ0.Z0_OPERAC = SG2.G2_OPERAC
					AND SZ0.Z0_OPERAC <> '20'
					AND SZ0.Z0_OPERAC <> '40'
					AND SZ0.%NotDel%
				WHERE
					SG2.G2_FILIAL = %Exp:xFilial("SG2")%
					AND SG2.G2_CODIGO = %Exp:(_TMPCOM)->C2_ROTEIRO%
					AND SG2.G2_PRODUTO = %Exp:(_TMPCOM)->C2_PRODUTO%
					AND SG2.%NotDel%
				UNION
				ALL
				SELECT
					SG2.G2_OPERAC,
					SG2.G2_RECURSO,
					SG2.G2_DESCRI,
					ISNULL(
						RTRIM(
							LTRIM(
								CONVERT(
									VARCHAR(8000),
									CONVERT(VARBINARY(8000), SZ0.Z0_DESCRIC)
								)
							)
						),
						''
					) AS INSTRUCAO,
					SZ0.Z0_SEQINI,
					'099' AS Z0_SEQFIN
				FROM
					%Table:SG2% AS SG2
				INNER JOIN %Table:SB1% AS SB1
				ON SB1.B1_FILIAL = %Exp:xFilial("SB1")%
					AND SB1.B1_COD = SG2.G2_PRODUTO
					AND SB1.B1_EQ_DISP <> 'N'
					AND SB1.B1_EQ_COMP = 'N'
					AND SB1.%NotDel%
				INNER JOIN %Table:SH1% AS SH1
				ON SH1.H1_FILIAL = %Exp:xFilial("SH1")%
					AND SH1.H1_CODIGO = SG2.G2_RECURSO
					AND SH1.%NotDel%
				INNER JOIN %Table:SHB% AS SHB
				ON SHB.HB_FILIAL = %Exp:xFilial("SHB")%
					AND SHB.HB_COD = SG2.G2_CTRAB
					AND SHB.%NotDel%
				INNER JOIN %Table:SZ0% AS SZ0
				ON SZ0.Z0_FILIAL = %Exp:xFilial("SZ0")%
					AND SZ0.Z0_PRODUTO = SG2.G2_PRODUTO
					AND SZ0.Z0_OPERAC = SG2.G2_OPERAC
					AND SZ0.Z0_OPERAC <> '30'
					AND SZ0.Z0_OPERAC <> '40'
					AND SZ0.%NotDel%
				WHERE
					SG2.G2_FILIAL = %Exp:xFilial("SG2")%
					AND SG2.G2_CODIGO = %Exp:(_TMPCOM)->C2_ROTEIRO%
					AND SG2.G2_PRODUTO = %Exp:(_TMPCOM)->C2_PRODUTO%
					AND SG2.%NotDel%
				UNION
				ALL
				SELECT
					SG2.G2_OPERAC,
					SG2.G2_RECURSO,
					SG2.G2_DESCRI,
					ISNULL(
						RTRIM(
							LTRIM(
								CONVERT(
									VARCHAR(8000),
									CONVERT(VARBINARY(8000), SZ0.Z0_DESCRIC)
								)
							)
						),
						''
					) AS INSTRUCAO,
					SZ0.Z0_SEQINI AS Z0_SEQINI,
					SZ0.Z0_SEQFIN
				FROM
					%Table:SG2% AS SG2
				INNER JOIN %Table:SB1% AS SB1
				ON SB1.B1_FILIAL = %Exp:xFilial("SB1")%
					AND SB1.B1_COD = SG2.G2_PRODUTO
					AND (
						(
							SB1.B1_EQ_DISP = 'N'
							AND SB1.B1_EQ_COMP <> 'N'
						)
						OR (
							SB1.B1_EQ_DISP <> 'N'
							AND SB1.B1_EQ_COMP = 'N'
						)
					)
					AND SB1.%NotDel%
				INNER JOIN %Table:SH1% AS SH1
				ON SH1.H1_FILIAL = %Exp:xFilial("SH1")%
					AND SH1.H1_CODIGO = SG2.G2_RECURSO
					AND SH1.%NotDel%
				INNER JOIN %Table:SHB% AS SHB
				ON SHB.HB_FILIAL = %Exp:xFilial("SHB")%
					AND SHB.HB_COD = SG2.G2_CTRAB
					AND SHB.%NotDel%
				INNER JOIN %Table:SZ0% AS SZ0
				ON SZ0.Z0_FILIAL = %Exp:xFilial("SZ0")%
					AND SZ0.Z0_PRODUTO = SG2.G2_PRODUTO
					AND SZ0.Z0_OPERAC = SG2.G2_OPERAC
					AND SZ0.Z0_OPERAC <> '20'
					AND SZ0.Z0_OPERAC <> '30'
					AND SZ0.%NotDel%
				WHERE
					SG2.G2_FILIAL = %Exp:xFilial("SG2")%
					AND SG2.G2_CODIGO = %Exp:(_TMPCOM)->C2_ROTEIRO%
					AND SG2.G2_PRODUTO = %Exp:(_TMPCOM)->C2_PRODUTO%
					AND SG2.%NotDel%
				ORDER BY
					SG2.G2_OPERAC
			EndSQl

		Else

			BeginSql alias _TMPROT
				SELECT
					SG2.G2_OPERAC,
					SG2.G2_RECURSO,
					SG2.G2_DESCRI,
					ISNULL(
						RTRIM(
							LTRIM(
								CONVERT(
									VARCHAR(8000),
									CONVERT(VARBINARY(8000), SZ0.Z0_DESCRIC)
								)
							)
						),
						'Envase Manual'
					) AS INSTRUCAO,
					ISNULL(SZ0.Z0_SEQINI, '001') AS Z0_SEQINI,
					ISNULL(SZ0.Z0_SEQFIN, '999') AS Z0_SEQFIN
				FROM
					%Table:SG2% AS SG2
				INNER JOIN %Table:SH1% AS SH1
				ON SH1.H1_FILIAL = %Exp:xFilial("SH1")%
					AND SG2.G2_RECURSO = SH1.H1_CODIGO
					AND SH1.%NotDel%
				INNER JOIN %Table:SHB% AS SHB
				ON HB_FILIAL = %Exp:xFilial("SHB")%
					AND SG2.G2_CTRAB = SHB.HB_COD
					AND SHB.%NotDel% "
			 LEFT JOIN  %Table:SZ0% AS SZ0
			 ON SZ0.Z0_FILIAL =%Exp:xFilial(" SZ0 ")%
				 AND SG2.G2_PRODUTO = SZ0.Z0_PRODUTO
				 AND SG2.G2_OPERAC = SZ0.Z0_OPERAC
				 AND SZ0.%NotDel%"
				WHERE
					SG2.G2_FILIAL = %Exp:xFilial("SG2")%
					AND SG2.G2_CODIGO = %Exp:(_TMPCOM)->C2_ROTEIRO%
					AND SG2.G2_PRODUTO = %Exp:(_TMPCOM)->C2_PRODUTO%
					AND SG2.%NotDel%
				ORDER BY
					G2_OPERAC
			EndSQl
		End

	ElseIf cArq == "TMPSD4"

		If SELECT((_TMPSD4)) > 0
			(_TMPSD4)->(dbCloseArea())
		End

		BeginSql alias _TMPSD4
			SELECT
				SD4.D4_TRT,
				SD4.D4_COD,
				SD4.D4_QUANT,
				SD4.D4_LOTECTL,
				SB1.B1_DESC
			FROM
				%Table:SD4% AS SD4
			INNER JOIN %Table:SB1% AS SB1
			ON B1_FILIAL = %Exp:xFilial("SB1")%
				AND SD4.D4_COD = SB1.B1_COD
				AND SB1.%NotDel% "
			 WHERE
			 SD4.D4_FILIAL = %Exp:xFilial(" SD4 ")%
			 AND SD4.D4_OP = %Exp:(_TMPCOM)->C2_NUM+(_TMPCOM)->C2_ITEM+(_TMPCOM)->C2_SEQUEN%
			 AND SD4.D4_TRT BETWEEN  %Exp:(_TMPROT)->Z0_SEQINI%  AND  %Exp:(_TMPROT)->Z0_SEQFIN% AND SD4.%NotDel%
			 ORDER BY SD4.D4_TRT, SD4.D4_COD
		EndSQl

	ElseIf cArq=="SEMOPE"

		If SELECT((_SEMOPE)) > 0
			(_SEMOPE)->(dbCloseArea())
		End

		BeginSql alias _SEMOPE
			SELECT
				SG2.G2_OPERAC,
				SG2.G2_DESCRI
			FROM
				%Table:SG2% AS SG2
			INNER JOIN %Table:SH1% AS SH1
			ON SH1.H1_FILIAL = %Exp:xFilial("SH1")%
				AND SG2.G2_RECURSO = SH1.H1_CODIGO
				AND SH1.%NotDel%
			INNER JOIN %Table:SHB% AS SHB
			ON SHB.HB_FILIAL = %Exp:xFilial("SHB")%
				AND SG2.G2_CTRAB = SHB.HB_COD
				AND SHB.%NotDel%
			WHERE
				SG2.G2_FILIAL = %Exp:xFilial("SG2")%
				AND SG2.G2_CODIGO = %Exp:(_TMPCOM)->C2_ROTEIRO%
				AND SG2.G2_PRODUTO = %Exp:(_TMPCOM)->C2_PRODUTO%
				AND NOT EXISTS (
					SELECT
						SZ0.Z0_FILIAL,
						SZ0.Z0_CODIGO,
						SZ0.Z0_PRODUTO,
						SZ0.Z0_OPERAC,
						SZ0.Z0_RECURSO,
						SZ0.Z0_REVPRC,
						SZ0.Z0_FERRAM,
						SZ0.Z0_TPLINHA,
						SZ0.Z0_LINHAPR,
						SZ0.Z0_DESCRIC,
						SZ0.Z0_DESCRI,
						SZ0.Z0_MAOOBRA,
						SZ0.Z0_SETUP,
						SZ0.Z0_TPOPER,
						SZ0.Z0_LOTEPAD,
						SZ0.Z0_TPSOBRE,
						SZ0.Z0_TEMPAD,
						SZ0.Z0_TPDESD,
						SZ0.Z0_TEMPSOB,
						SZ0.Z0_TEMPDES,
						SZ0.Z0_DESPROP,
						SZ0.Z0_CTRAB,
						SZ0.Z0_OPE_OBR,
						SZ0.Z0_REVIPRD,
						SZ0.Z0_SEQ_OBR,
						SZ0.Z0_LAU_OBR,
						SZ0.Z0_CHAVE,
						SZ0.Z0_ROTALT,
						SZ0.Z0_GRSETUP,
						SZ0.Z0_GRUPREC,
						SZ0.Z0_NIVMONT,
						SZ0.Z0_CHAVMON,
						SZ0.Z0_TMAXPRO,
						SZ0.Z0_TPINTER,
						SZ0.Z0_MAXINCR,
						SZ0.Z0_FOLMIN,
						SZ0.Z0_HOROTIM,
						SZ0.Z0_OPERGRP,
						SZ0.Z0_FORMSTP,
						SZ0.Z0_TPALOCF,
						SZ0.Z0_TEMPEND,
						SZ0.Z0_REFGRD,
						SZ0.Z0_SEQINI,
						SZ0.Z0_SEQFIN,
						SZ0.Z0_DEPTO
					FROM
						%Table:SZ0% as SZ0
					WHERE
						SZ0.Z0_FILIAL = %Exp:xFilial("SZ0")%
						AND SG2.G2_PRODUTO = SZ0.Z0_PRODUTO
						AND SG2.G2_OPERAC = SZ0.Z0_OPERAC
						AND SZ0.%NotDel%
				)
				AND SG2.G2_OPERAC NOT IN ('10', '50')
				AND SG2.%NotDel% "
			 ORDER BY
			 SG2.G2_OPERAC
		EndSQl

	ElseIf cArq =="TMPQUA"

		If SELECT((_TMPQUA)) > 0
			(_TMPQUA)->(dbCloseArea())
		End

		BeginSql alias _TMPQUA
			SELECT
				QPJ.QPJ_ITEM,
				QPJ.QPJ_ENSAIO,
				QPJ.QPJ_DUNMED,
				UPPER(QPJ_DESENS) ENSAIO,
				QPJ.QPJ_LINF LIMINF,
				QPJ.QPJ_LSUP LIMSUP,
				QPJ.QPJ_TEXTO TEXTO,
				CASE
					WHEN QP1.QP1_TIPO = 'C'
						THEN 'Calculado'
					ELSE 'Digitado'
				END TIPO,
				QP1.QP1_QTDE,
				QP1.QP1_METODO
			FROM
				%Table:QPJ% AS QPJ
			INNER JOIN %Table:QP1% AS QP1
			ON QP1.QP1_FILIAL = %Exp:xFilial("QP1")%
				AND QPJ.QPJ_ENSAIO = QP1.QP1_ENSAIO
				AND QP1.%NotDel% "
			 WHERE
			 QPJ.QPJ_FILIAL = %Exp:xFilial(" QPJ ")%
			 AND QPJ.QPJ_PROD = %Exp:(_TMPCOM)->C2_PRODUTO%
			 AND QPJ.%NotDel%"
			ORDER BY
				QPJ.QPJ_PROD,
				QPJ.QPJ_ITEM
		EndSQl
	End
	//Guarada as Querys usadas
	aDados:=GetLastQuery()

	//Guarada as Querys usadas
	AADD(aQuery,{aDados[1],aDados[2],cArq})

Return
