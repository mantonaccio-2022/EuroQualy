#Include "TOTVS.Ch"

// Posições do aDados2.
#DEFINE DESC_TOTAL 8
#DEFINE DT_VENC 1
#DEFINE EMISSAO 5
#DEFINE FORNEC 6
#DEFINE HISTORICO 10
#DEFINE LOJA 7
#DEFINE NOM_FORNEC 9
#DEFINE PREFIXO 2
#DEFINE TAM_DADOS2 15 // Sempre deixar com a quantidade de posições no aDados2.
#DEFINE TAXA 15
#DEFINE TIPO 4
#DEFINE TITUL 3
#DEFINE VL_DIS 14
#DEFINE VL_ORIG 11
#DEFINE VL_PAG 12
#DEFINE VL_REC 13

Static _oFINR1401
Static _oFINR1402
Static cPerg      := "FIN140"
Static lFWCodFil  := .T.
Static lGestao    := (nTamFilial > 2)
Static nTamFilial := IIf(lFWCodFil, FWGETTAMFILIAL, 2)

/*/{Protheus.doc} EQFinr140
Fluxo de Caixa customizado para a Euro/Qualy
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 05/10/2021
@return character, sem retorno especifico
/*/
User Function EQFinr140()

    Local oReport

    // Variáveis utilizadas para parâmetros.
    // mv_par01 - Número de Dias
    // mv_par02 - Moeda
    // mv_par03 - Imprime Por Filial ou Empresa
    // mv_par04 - Considera Pedidos de Vendas
    // mv_par05 - Considera Pedidos de Compras
    // mv_par06 - Considera Vencidos
    // mv_par07 - Considera Comissoes
    // mv_par08 - Considera Moedas
    // mv_par09 - Do Prefixo
    // mv_par10 - At‚ o Prefixo
    // mv_par11 - Retroativo?
    // mv_par12 - Outras Moedas?
    // mv_par13 - Lista abatimentos?
    // mv_par14 - Tit. Emissao Futura
    // mv_par15 - Considera limite de credito ?
    // mv_par16 - Tipo de Saldo ?    (Normal/Conciliado/Nao Conciliado)
    // mv_par17 - Compoe Saldo por?  (Data da Baixa/Data de Credito/Data Digitacao)
    // mv_par19 - Lista Estorno?
    // mv_par20 - Visao Gerencial Financeira
    // mv_par21 - Considera Solic. Fundo
    If Pergunte(cPerg, .T.)
        Private aAplicSeh
        oReport := ReportDef()
        oReport:PrintDialog()
    Endif

Return

/*/{Protheus.doc} ReportDef
Geração do relatorio de FLuxo de Caixa
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 05/10/2021
@return Object, definição do relatorio
/*/
Static Function ReportDef()

    Local cPictVal
    Local nTamTit, nTamVal
    Local oReport
    Local oSecFil, oSection2

    oReport := TReport():New("EQFINR140","Fluxo de Caixa Analitico",cPerg,{|oReport| ReportPrint(oReport)},"Este programa ir  imprimir o Fluxo de Caixa, informando "+"ao usuario quais as suas contas a receber e a pagar dia a    "+"dia e tambem seu disponivel de acordo com os saldos bancarios")
    oReport:SetLandScape(.T.)
    oReport:DisableOrientation()
    /*
    GESTAO - inicio */
    oReport:SetUseGC(.F.)
    /* GESTAO - fim
    */

    aAplicSeh := Aplicacoes(mv_par03 == 1, MV_PAR02)
    nTamTit   := max(TamSX3("E2_NUM")[1] + TamSX3("E2_PARCELA")[1], TamSX3("C5_FILIAL")[1] + TamSX3("C5_NUM")[1] + 3)
    nTamVal   := TamSX3("E2_VALOR")[1]
    cPictVal  := PesqPict("SE2", "E2_VALOR")

    // Relacao das filiais selecionadas para compor o relatório.
    oSecFil := TRSection():New(oReport, "Filiais", {"SE2"})  // "Filiais"
    TRCell():New(oSecFil,"CODFIL",, "Código",/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)	 
    TRCell():New(oSecFil,"EMPRESA",,"Empresa",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) 
    TRCell():New(oSecFil,"UNIDNEG",,"Unidade de negócio",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	 
    TRCell():New(oSecFil,"NOMEFIL",,"Filial",/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/)	 

    If Empty(MV_PAR20)
        oSection2 := TRSection():New(oReport, "Fluxo de Caixa Analitico", {"SE2","SE1"})  
        TRCell():New(oSection2,"E2_VENCREA","SE2","Data Ref",,, .F.)       
        TRCell():New(oSection2,"E2_PREFIXO","SE2","Prf",,, .F.)      
        TRCell():New(oSection2,"TITULO",,"Numero-PC",, nTamTit,  .F.)       
        TRCell():New(oSection2,"E2_TIPO",    "SE2","Tipo",,,.F.)       
        TRCell():New(oSection2,"E2_EMISSAO", "SE2","Dt Emiss",,,.F.)      
        TRCell():New(oSection2,"E2_FORNECE", "SE2","Cli/For",,,.F.)       
        TRCell():New(oSection2,"E2_LOJA",    "SE2",,,,       .F.)

        // Colunas TOTAL e TOTAL2 escondidas para impressão de textos totalizadores.
        TRCell():New(oSection2,"TOTAL",           ,"Nome Cliente/Fornecedor",, 89,.F.)   
        TRCell():New(oSection2,"TOTAL2",          ,"",, 1,.F.)       
        TRCell():New(oSection2,"E2_NOMFOR",  "SE2","Nome Cliente/Fornecedor",, 40,.F.)   
        TRCell():New(oSection2,"E2_HIST",    "SE2","Historico",, 50,.F.)  

        TRCell():New(oSection2,"VL_ORIGI",,"Valor Original",cPictVal,nTamVal+3,.F.,,,, "RIGHT")  
        TRCell():New(oSection2,"VL_PAGAR",,"a Pagar",cPictVal,nTamVal,  .F.,,,, "RIGHT")   
        TRCell():New(oSection2,"VL_RECEB",,"a Receber",cPictVal,nTamVal,  .F.,,,, "RIGHT")  
        TRCell():New(oSection2,"VL_DISPO",,"Disponivel",cPictVal,nTamVal+3,.F.,,,, "RIGHT")   
        TRCell():New(oSection2,"M2_MOEDA1","SM2","Taxa do Dia",,, .F.,)   

        oSection2:SetHeaderPage(.T.)
        oSection2:Setnofilter("SE2")
        oSection2:Setnofilter("SE1")
    Else
        // Visão gerencial.
        oSection2 := TRSection():New(oReport, "Visão gerencial", {""})  //
        TRCell():New(oSection2, "DATA-DESCRICAO", "cArqTmp",,							, 100)						// "CODIGO E DESCRIÇÃO"
        TRCell():New(oSection2, "RECEBIDOS"   	, "cArqTmp",, PesqPict("SE1","E1_VALOR"), nTamVal,,,,,  "RIGHT")	// "RECEBIDOS"
        TRCell():New(oSection2, "PAGOS"   		, "cArqTmp",, PesqPict("SE1","E1_VALOR"), nTamVal,,,,,  "RIGHT")	// "PAGOS"
        TRCell():New(oSection2, "DISPONIVEL" 	, "cArqTmp",, PesqPict("SE5","E5_VALOR"), nTamVal+3,,,,,"RIGHT")	// "DISPONIVEL"

        oSection2:SetNoFilter("")
        oSection2:SetHeaderPage(.F.)
    EndIf

Return oReport

/*/{Protheus.doc} ReportPrint
Geração do relatorio
@type function
@version  Relatorio
@author mario.antonaccio
@since 05/10/2021
@param oReport, object, Objeto do relatorio
@return Character, sem retorno definido
/*/
Static Function ReportPrint(oReport)

    Local aAplic       := {}
    Local aBancosA     := {}
    Local aBancosR     := {}
    Local aDados2[TAM_DADOS2]
    Local aRecSE1      := {}
    Local aResgate     := {}
    Local aSelFil      := {}
    Local aSM0         := {}
    Local aStru        := SE1->(DbStruct())
    Local aTmpFil      := {}
    Local aValAplic    := 0
    Local cAplCotas    := GetMv("MV_APLCAL4")
    Local cArqFJA      := ""
    Local cArqSA6      := " "
    Local cArqSE1      := " "
    Local cArqSE2      := " "
    Local cArqSE3      := ""
    Local cArqSE5      := " "
    Local cArqSE8      := ""
    Local cArqSEG      := " "
    Local cArqSEH      := " "
    Local cArqTmp      := "" // Arquivo temporário das movimentações.
    Local cCondSE5     := " "
    Local cFilFJA      := xFilial("FJA")
    Local cFilSA6      := xFilial("SA6")
    Local cFilSE1      := xFilial("SE1")
    Local cFilSE2      := xFilial("SE2")
    Local cFilSE5      := xFilial("SE5")
    Local cFilSEG      := xFilial("SEG")
    Local cFilSEH      := xFilial("SEH")
    Local cFilSel      := ""
    Local cFilTmp      := ""
    Local cIpProj      := GetMv("MV_IPPRJAP")
    Local cListBco     := FN022LSTCB(3) // Obtém a lista de situações de cobranças que possuem portador.
    Local cListDesc    := FN022LSTCB(2) // Obtém a lista de situações de cobranças descontadas.
    Local cNumMoeda    := ""
    Local cTitRel      := ""
    Local cTitulo      := "Fluxo de Caixa Analitico"
    Local cTmpFil      := {}
    Local dDataAte
    Local dDataImp
    Local dDataTrab
    Local dDataVcOri
    Local dDataVenc
    Local dDtSE8       := Ctod("")
    Local dOldData     := dDatabase
    Local lAchou       := .F.
    Local lBxFut       := .F.
    Local lChqLiber    := .T.
    Local lFilA6E8     := If( lGestao, FWModeAccess("SA6",3) == FWModeAccess("SE8",3), FWModeAccess("SA1",1) == FWModeAccess("SA2",1))
    Local lFirst       := .T.
    Local lFstPrint    := .T.
    Local lImpDev      := .F.
    Local lImpFut      := .F.
    Local lLibCheq     := GetMv("MV_LIBCHEQ")=="N" // Para controlar os cheques pendentes de liberacao.
    Local lMovBco      := .F.
    Local lMvBr10925   := IIf(cPaisLoc == "BRA", GetMv("MV_BR10925")== "1", .F.)
    Local lSldSE8      := .F.
    Local lSldZera     := (mv_par18 <> 1)
    Local lSolFund     := MV_PAR21 == 1 .and. cPaisLoc == "ARG"
    Local lTxMoeda     := .T.
    Local nAbatim
    Local nAcumRc      := 0
    Local nApagVenc    := 0
    Local nArecVenc    := 0
    Local nAscan
    Local nChqPend     := 0
    Local nComissoes   := 0
    Local nDecs        := GetMv("MV_CENT"+(IIF(mv_par02 > 1 , STR(mv_par02,1),"")))
    Local nDias
    Local nDiasInt     := 0
    Local nDiasRet     := 0
    Local nDispon      := 0
    Local nEl          := 0
    Local nImprPC      := 0
    Local nImprPV      := 0
    Local nIndexFJA
    Local nIndexSE1
    Local nIndexSE2
    Local nIndexSE3
    Local nIndexSE5
    Local nIndexSEG
    Local nIndexSEH
    Local nIndSE8      := 1
    Local nJurDiario   := 0
    Local nLastRec     := 0
    Local nLenFil      := 0
    Local nLenSelFil   := 0
    Local nLimCred     := 0
    Local nMoeda       := mv_par02
    Local nMoedaBco    := 1
    Local nPagHoje     := 0
    Local nPos         := 0
    Local nRecHoje     := 0
    Local nRecSE8      := 0
    Local nRegSa6      := 0
    Local nRegSM0      := 0
    Local nSalDup      := 0
    Local nTamEmp      := Len(FwCodEmp())
    Local nTamTit      := 0
    Local nTamUnNeg    := 0
    Local nTotAplic    := 0
    Local nTotEntradas := 0
    Local nTotFutR     := 0
    Local nTotGTitP    := 0
    Local nTotGTitR    := 0
    Local nTotResg     := 0
    Local nTotSaidas
    Local nTotTitP     := 0
    Local nTotTitR     := 0
    Local nValGanho    := 0
    Local nValJuros    := 0
    Local nValMoeda    := 0
    Local nValor
    Local nVlrImp      := 0
    Local nX, nY
    Local oSecFil      := oReport:Section(1)
    Local oSection2    := oReport:Section(2)
    Local oSX1
    Private aCompras   :={}, aVendas := {}
    Private adCompras  :={}, adVendas := {}
    Private cErros     := ""

    // SITCOB
    // *************************************************************
    // *  oSX1 - Pode ser retirado após o fim da versão 12.1.17.   *
    // *************************************************************
    // Verifica as opções dos parâmetros 4 e 5.
    oSX1 := FWSX1Util():New()
    oSX1:AddGroup(cPerg)
    oSX1:SearchGroup()
    If empty(oSX1:aGrupo[1, 2, 4]:cX1_DEF03)
        // Nesse caso as opções são:
        // 1=Sim / 2=Não.
        nImprPV := If(mv_par04 = 2, 3, mv_par04)
        nImprPC := If(mv_par05 = 2, 3, mv_par05)
    Else
        // Nesse caso as opções são:
        // 1=Sintético / 2=Analítico / 3=Não.
        nImprPV := mv_par04
        nImprPC := mv_par05
    Endif
    oSX1 := nil

    //Ponto de entrada para escolha entre bancos com ou sem movimento
    If ExistBlock("FA140MVB")
        lMovBco := ExecBlock("FA140MVB")
    Endif

    /*
    GESTAO - inicio */
    If !IsBlind()
        If lGestao .and. FindFunction("FwSelectGC")
            nRegSM0 := SM0->(Recno())
            If MV_PAR03 == 1	//filial
                aSelFil := FwSelectGC(.T.)
            Else
                aSelFil := FwSelectGC()
            Endif
        Else
            aSelFil := AdmGetFil(.F., (MV_PAR03 == 1), "SE1")
        Endif
    Endif
    If Empty(aSelFil)
        aSelFil := {cFilAnt}
        MV_PAR03 := 1
    Endif

    If !IsBlind() .and. lGestao .and. FindFunction("FwSelectGC")
        SM0->(DbGoTo(nRegSM0))
    EndIf

    // Imprime a lista de filiais selecionadas para o relatório
    If Len(aSelFil) > 1
        oSection2:SetHeaderSection(.F.)
        aSM0 := FWLoadSM0()
        nTamEmp := Len(FWSM0LayOut(,1))
        nTamUnNeg := Len(FWSM0LayOut(,2))
        cTitRel := oReport:Title()
        oReport:SetTitle(cTitRel + " (" + "Filiais selecionadas para o relatorio" + ")")  
        nTamTit := Len(oReport:Title())
        oSecFil:Init()
        oSecFil:Cell("CODFIL"):SetBlock({||cFilSel})
        oSecFil:Cell("EMPRESA"):SetBlock({||aSM0[nLinha,SM0_DESCEMP]})
        oSecFil:Cell("UNIDNEG"):SetBlock({||aSM0[nLinha,SM0_DESCUN]})
        oSecFil:Cell("NOMEFIL"):SetBlock({||aSM0[nLinha,SM0_NOMRED]})
        For nX := 1 To Len(aSelFil)
            nLinha := Ascan(aSM0,{|sm0|,sm0[SM0_CODFIL] == aSelFil[nX]})
            If nLinha > 0
                cFilSel := Substr(aSM0[nLinha,SM0_CODFIL],1,nTamEmp)
                cFilSel += " "
                cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + 1,nTamUnNeg)
                cFilSel += " "
                cFilSel += Substr(aSM0[nLinha,SM0_CODFIL],nTamEmp + nTamUnNeg + 1)
                oSecFil:PrintLine()
            Endif
        Next
        oReport:SetTitle(cTitRel)
        oSecFil:Finish()
        oSection2:SetHeaderSection(.T.)
        oReport:EndPage()
    Endif
    /* GESTAO - fim
    */

    If Empty(MV_PAR20)
        oSection2:Cell("E2_VENCREA"	):SetBlock({|| If(lBxFut, aDados2[DT_VENC],    If(lImpDev,, E1VENC->E1_VENCREA)) })
        oSection2:Cell("E2_PREFIXO"	):SetBlock({|| If(lBxFut, aDados2[PREFIXO],    If(lImpDev,, E1VENC->E1_PREFIXO)) })
        oSection2:Cell("TITULO"		):SetBlock({|| If(lBxFut, aDados2[TITUL],      If(lImpDev,, E1VENC->E1_NUM+(IIF(!EMPTY(E1VENC->E1_PARCELA),"-",""))+E1VENC->E1_PARCELA)) })
        oSection2:Cell("E2_TIPO"	):SetBlock({|| If(lBxFut, aDados2[TIPO],       If(lImpDev,, E1VENC->E1_TIPO)) })
        oSection2:Cell("E2_EMISSAO"	):SetBlock({|| If(lBxFut, aDados2[EMISSAO],    If(lImpDev,, E1VENC->E1_EMISSAO)) })
        oSection2:Cell("E2_FORNECE"	):SetBlock({|| If(lBxFut, aDados2[FORNEC],     If(lImpDev,, E1VENC->E1_CLIENTE)) })
        oSection2:Cell("E2_LOJA"	):SetBlock({|| If(lBxFut, aDados2[LOJA],       If(lImpDev,, E1VENC->E1_LOJA)) })

        oSection2:Cell("TOTAL"		):SetBlock({|| If(lBxFut, aDados2[DESC_TOTAL], If(lImpDev,"Total De Títulos Vencidos",aDados2[DESC_TOTAL])) })  
        oSection2:Cell("TOTAL2"		):SetBlock({|| ""})
        oSection2:Cell("E2_NOMFOR"	):SetBlock({|| If(lBxFut, aDados2[NOM_FORNEC], If(lImpDev,, SubStr(E1VENC->E1_NOMCLI,1,25))) })
        oSection2:Cell("E2_HIST"	):SetBlock({|| If(lBxFut, aDados2[HISTORICO],  If(lImpDev,, If(E1VENC->E1_SALDO == 0,"Tit.Baixado p/Rec. Futuro",SubStr(E1VENC->E1_HIST,1,25)))) })	 

        oSection2:Cell("VL_ORIGI"	):SetBlock({|| If(lBxFut, aDados2[VL_ORIG],    nil)})
        oSection2:Cell("VL_PAGAR"	):SetBlock({|| If(lBxFut, aDados2[VL_PAG],     If(lImpDev,nApagVenc,aDados2[VL_PAG])) })
        oSection2:Cell("VL_RECEB"	):SetBlock({|| If(lBxFut, aDados2[VL_REC],     If(lImpDev,nArecVenc,nSaldo)) })
        oSection2:Cell("VL_DISPO"	):SetBlock({|| If(lBxFut, aDados2[VL_DIS],     nDispon) })

        oSection2:Cell("TOTAL"):Disable()
        oSection2:Cell("TOTAL2"):Disable()

        If mv_par02 == 1
            oSection2:Cell("M2_MOEDA1"):Disable()
        Else
            cNumMoeda += "M2_MOEDA" + cValToChar(mv_par02)
            oSection2:Cell("M2_MOEDA1"):SetBlock({|| SM2->(&cNumMoeda)})
        EndIf
    Else
        oSection2:Cell("DATA-DESCRICAO"):SetBlock({|| If(lBxFut, aDados2[DESC_TOTAL], CARQTMP->CODDESC)})
        oSection2:Cell("RECEBIDOS"     ):SetBlock({|| If(lBxFut, aDados2[VL_REC],     CARQTMP->RECEBIDOS)})
        oSection2:Cell("PAGOS"         ):SetBlock({|| If(lBxFut, aDados2[VL_PAG],     CARQTMP->PAGOS)})
        oSection2:Cell("DISPONIVEL"    ):SetBlock({|| If(lBxFut, aDados2[VL_DIS],     CARQTMP->DISPON)})
    EndIf

    If mv_par03 == 2 .Or. !Empty(aSelFil)	// Imprime Por Filial ou Empresa		/* GESTAO */
        // Contas a receber
        dbSelectArea("SE1")
        cArqSE1 := SubStr(criatrab("",.f.),1,7)+"A"
        IndRegua("SE1",cArqSE1,"DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA",,,OemToAnsi("Selecionando Registros..."))   
        nIndexSE1 := RetIndex("SE1") + 1
        dbSetOrder( nIndexSE1 )

        // Contas a pagar
        dbSelectArea("SE2")
        cArqSE2 := SubStr(criatrab("",.f.),1,7)+"B"
        IndRegua("SE2",cArqSE2,"DTOS(E2_VENCREA)+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO",,,OemToAnsi("Selecionando Registros..."))   
        dbSetOrder( nIndexSE2 )

        // Movimentacao bancaria
        dbSelectArea("SE5")
        cArqSE5 := SubStr(criatrab("",.f.),1,7)+"C"
        IndRegua("SE5",cArqSE5,"DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA",,,OemToAnsi("Selecionando Registros..."))   
        nIndexSE5 := RetIndex("SE5") + 1

        //Contas Correntes
        If !Empty(xFilial("SA6"))
            dbSelectArea("SA6")
            cArqSA6 := CriaTrab(,.F.)
            IndRegua("SA6",cArqSA6,"A6_COD+A6_AGENCIA+A6_NUMCON",,,OemToAnsi("Selecionando Registros..."))   
            nIndSA6 := RetIndex("SA6") + 1
            dbSetOrder(nIndSA6)
        Endif

        // Saldo Bancario
        dbSelectArea("SE8")
        cArqSE8 := CriaTrab(,.F.)
        IndRegua("SE8",cArqSE8,"E8_BANCO+E8_AGENCIA+E8_CONTA+DTOS(E8_DTSALAT)",,,OemToAnsi("Selecionando Registros..."))  
        nIndSE8 := RetIndex("SE8") + 1
        dbSetOrder(nIndSE8)

        // Aplicacoes e emprestimos
        dbSelectArea("SEG")
        cArqSEG := SubStr(criatrab("",.f.),1,7)+"D"
        IndRegua("SEG",cArqSEG,"DTOS(EG_DATARES)+EG_BANCO+EG_AGENCIA+EG_CONTA",,,OemToAnsi("Selecionando Registros..."))   
        nIndexSEG := RetIndex("SEG") + 1

        // Aplicacoes e emprestimos
        dbCommit()
        dbSelectArea("SEH")
        cArqSEH := criatrab("",.f.)
        IndRegua("SEH",cArqSEH,"EH_STATUS+EH_APLEMP",,,OemToAnsi("Selecionando Registros...") ) 
        SEH->(dbCommit())
        nIndexSEH := RetIndex("SEH") + 1

        //Solicitacoes de Fundo
        If lSolFund
            DbSelectArea("FJA")
            cArqFJA := CriaTrab(,.F.)
            IndRegua("FJA",cArqFJA,"DTOS(FJA_DATAPR)",,,OemToAnsi("Selecionando Registros...") )  
            nIndexFJA := RetIndex("FJA") + 1
        Endif
    Endif

    //³Cria indice condicional temporario para analise das comissoes ³
    if mv_par07 == 1		// Analisa comissoes == Sim
        If Empty(cArqSE3)
            dbSelectArea("SE3")
            cArqSE3 := SubStr(criatrab("",.f.),1,7)+"E"
            cChave := "DTOS(E3_DATA)"

            //³Condicao 1 - Somente filial 			  ³
            //³Condicao 2 - Todas filias (Empresa)	  ³

            if mv_par03 == 1 .And. Empty(aSelFil)
                // Nao Alterar o ctod(01/01/80)
                cCond := 'DTOS(E3_DATA)<="'+Dtos(ctod("01/01/80","ddmmyy"))+'".AND.E3_FILIAL=="'+xFilial("SE3")+'"'
            else
                cCond := 'DTOS(E3_DATA)<="'+Dtos(ctod("01/01/80","ddmmyy"))+'"'
            endif

            IndRegua("SE3",cArqSE3,cChave,,cCond,OemToAnsi("Selecionando Registros..."))  
            dbSelectArea("SE3")
            nIndexSE3		:= RetIndex("SE3") + 1
            dbSetOrder(nIndexSE3)
            SE3->(DbGoTop())
        Else
            dbSelectArea("SE3")
            nIndexSE3		:= RetIndex("SE3") + 1
            dbSetOrder( nIndexSE3 )
        Endif
    Endif

    cTitulo += " em " + GetMV("MV_MOEDA"+AllTrim(Str(mv_par02, 2)))
    dDataAte := dDataBase + mv_par01

    oReport:SetTitle(cTitulo)

    IF mv_par02 != 1
        cSuf := AllTrim(Str(mv_par02,2))
        dbSelectArea("SM2")
        dbSeek( dDataBase )
    EndIF

    // Imprime disponibilidade bancária.
    dbSelectArea("SA6")
    /* GESTAO - inicio */
    If !IsBlind()
        nLenSelFil := Len(aSelFil)
        If nLenSelFil == 0
            If ( MV_PAR03 == 1 )
                dbSeek( cFilSA6 )
            Else
                dbGotop()
            EndIf
        Else
            nPosFil := 0
            SA6->(DbGotop())
        Endif
    Endif
    /* GESTAO - fim
    */
    cSuf := AllTrim(Str(mv_par02,2,0))

    oSection2:Init()
    lBxFut := .T.
    HabiCel(.F.,oReport)

    While !SA6->(Eof()) .and. If(nLenSelFil == 0,If(MV_PAR03==1,SA6->A6_FILIAL == cFilSA6,.T.),.T.)
        /* GESTAO - inicio */
        If nLenSelFil > 0
            cFilTmp := AllTrim(SA6->A6_FILIAL)
            nLenFil := Len(cFilTmp)
            nPosFil := Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)})
            If nPosFil == 0
                SA6->(DbSkip())
                Loop
            Endif
        Else
            If mv_par03 == 2
                If lGestao .and. Substring(SA6->A6_FILIAL, 1,nTamEmp) != Substring(cFilSA6, 1,nTamEmp )
                    SA6->(dbSkip())
                    Loop
                EndIf
            EndIf
        Endif
        /* GESTAO fim
        */
        IF SA6->A6_FLUXCAI == "N"
            SA6->(dbSkip())
            Loop
        Endif
        nRegSa6 := RecNo()
        If lFirst

            //³ Verifica se houve movimenta‡„o bancaria no dia da emissao do fluxo³
            dbSelectArea("SE5")

            // 1-Verifica filial
            If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                cCondSE5 := "!EOF() .and. E5_FILIAL == xFilial('SE5')"
            Else
                cCondSE5 := "!EOF()"
            Endif

            If mv_par03 == 1  // 1-Verifica Filial
                dbSetOrder(1)
                dbSeek( cFilSE5 + DTOS(dDataBase),.T. )
            Else
                dbSetOrder(nIndexSE5)
                dbSeek(DTOS(dDataBase),.T.)
            Endif

            While &cCondSE5
                /*
                GESTAO - inicio */
                If nLenSelFil > 0
                    cFilTmp := AllTrim(SE5->E5_FILIAL)
                    nLenFil := Len(cFilTmp)
                    If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                        SE5->(DbSkip())
                        Loop
                    Endif
                Else
                    If mv_par03 == 2
                        If lGestao .and. Substring(SE5->E5_FILIAL,1,nTamEmp) != Substring(xFilial("SE5"),1, nTamEmp)
                            dbSkip()
                            Loop
                        EndIf
                    EndIf
                Endif
                /* GESTAO - fim
                */
                If mv_par14 == 1
                    If E5_DATA > dDataAte
                        Exit
                    EndIf
                Else
                    If E5_DATA > dDataBase
                        Exit
                    EndIf
                Endif

                IF mv_par03 == 1 .and. E5_FILIAL != cFilSE5
                    Exit
                EndIF

                IF E5_SITUACA == "C" .or. E5_TIPODOC $ "JRþMTþDCþBAþCMþJ2þM2þD2þC2þV2þCXþCPüTL"
                    dbSkip( )
                    Loop
                EndIf

                //³ Verifica se existe baixas estornadas           ³
                If TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
                    dbskip()
                    loop
                EndIf
                nMoedaTit := BuscaMoeda()

                If cPaisLoc	# "BRA".And.!Empty(SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA)
                    SA6->(DbSetOrder(1))
                    SA6->(DbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
                    nMoedaBco	:=	Max(SA6->A6_MOEDA,1)
                Else
                    nMoedaBco	:=	1
                Endif

                If mv_par12 = 2
                    If nMoedaBco <> nMoeda
                        SE5->(dbSkip())
                        Loop
                    EndIf
                EndIf

                IF E5_TIPODOC == "AP"  .And. E5_RECPAG = "P"     //Aplicacoes
                    nTotAplic += xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    nEl := Ascan(aBancosA,E5_BANCO)
                    IF nEl == 0
                        AADD(aBancosA,E5_BANCO)
                        AADD(aAplic,{E5_BANCO,E5_VALOR,E5_FILIAL})
                    Else
                        aAplic[nEl][2] += xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    EndIf
                ElseIf E5_TIPODOC == "AP" .And. E5_RECPAG = "R"      //Estorno de Aplicacoes
                    nTotAplic -= xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    nEl := Ascan(aBancosA,E5_BANCO)
                    IF nEl == 0
                        AADD(aBancosA,E5_BANCO)
                        AADD(aAplic,{E5_BANCO,E5_VALOR,E5_FILIAL})
                    Else
                        aAplic[nEl][2] -= xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    EndIf
                ElseIf E5_TIPODOC == "RF" .And. E5_RECPAG = "R"  //Resgates
                    nTotResg += xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    nEl := Ascan(aBancosR,E5_BANCO)
                    IF nEl == 0
                        AADD(aBancosR,E5_BANCO)
                        AADD(aResgate,{E5_BANCO,E5_VALOR,E5_FILIAL})
                    Else
                        aResgate[nEl][2]+=xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    EndIf
                ElseIf E5_TIPODOC == "RF" .And. E5_RECPAG = "P"  //Estorno de Resgates
                    nTotResg -= xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    nEl := Ascan(aBancosR,E5_BANCO)
                    IF nEl == 0
                        AADD(aBancosR,E5_BANCO)
                        AADD(aResgate,{E5_BANCO,E5_VALOR,E5_FILIAL})
                    Else
                        aResgate[nEl][2]-=xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
                    EndIf
                ElseIf E5_TIPODOC == "EP" .And. E5_RECPAG=="R" // Emprestimo
                    nRecHoje += Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                        If(SEH->EH_MOEDA > 1,E5_VLMOED2,xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1)))
                ElseIf E5_TIPODOC == "EP" .And. E5_RECPAG=="P" // Estorno de Emprestimo
                    nRecHoje -= Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                        If(SEH->EH_MOEDA > 1,E5_VLMOED2,xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1)))
                ElseIf E5_TIPODOC == "PE" .And. E5_RECPAG=="P" // Pagamento de emprestimo
                    nPagHoje += Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                        If(SEH->EH_MOEDA > 1,E5_VLMOED2,xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1)))
                ElseIf E5_TIPODOC == "PE" .And. E5_RECPAG=="R" // Estorno de pagamento de emprestimo
                    nPagHoje -= Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                        If(SEH->EH_MOEDA > 1,E5_VLMOED2,xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1)))
                ElseIf E5_TIPODOC == "RA" .And. E5_RECPAG=="R" .And. E5_DATA <> dDataBase  // Pagamento Antecipado
                    nPagHoje -= Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                        xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1))
                ElseIf E5_RECPAG == "R" .And. ! E5_TIPODOC $ "EP#PE#AP#RF"
                    // Movimento a receber que nao seja emprestimo nem pagto de emprestimo
                    nRecHoje += Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                        If(SEH->EH_MOEDA > 1,E5_VLMOED2,xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1)))
                ElseIf E5_RECPAG == "P" .And. ! E5_TIPODOC $ "EP#PE#AP#RF"
                    If lLibCheq
                        // Pesquisa cheque pendentes de liberacao
                        SEF->(DbSetOrder(3))
                        If SEF->(MsSeek(xFilial("SEF")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_NUMCHEQ+E5_SEQ))) .And.;
                                SEF->EF_LIBER $ " N"
                            nChqPend += SEF->EF_VALOR
                        Else
                            // Movimento a pagar que nao seja emprestimo nem pagto de emprestimo
                            nPagHoje += Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                                xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1))
                        Endif
                    Else
                        // Movimento a pagar que nao seja emprestimo nem pagto de emprestimo
                        nPagHoje += Iif(mv_par02 == 1,xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nDecs+1),;
                            xMoeda(E5_VLMOED2,nMoedaTit,nMoeda,E5_DATA,nDecs+1))
                    Endif
                EndIf

                dbSkip()
            EndDo

            IF (nPagHoje+nRecHoje+nTotAplic+nTotResg+nChqPend) != 0

                aDados2[DESC_TOTAL] :="Movimentacao na data ate a hora da emissao"
                nTotEntradas := nTotResg + nRecHoje
                nTotSaidas	 := nTotAplic + nPagHoje + nChqPend
                oSection2:PrintLine()
                aFill(aDados2,nil)

                aDados2[DESC_TOTAL] := "Aplicacoes "
                aDados2[VL_PAG] := If(mv_par02 == 1,nTotAplic,nTotAplic / &('SM2->M2_MOEDA'+cSuf))
                oSection2:PrintLine()
                aFill(aDados2,nil)

                IF nTotAplic>0
                    For nX := 1 To Len(aBancosA)
                        aDados2[DESC_TOTAL] := PadR(Space(4) + aAplic[nX][1] , 9)
                        dbSelectArea("SA6")
                        If ( xFilial("SA6") == Space(nTamFilial) )
                            dbSeek( cFilSA6 + aAplic[nX][1] )
                        Else
                            dbSeek(aAplic[nX,3]+aAplic[nX][1])
                        EndIf

                        aDados2[DESC_TOTAL] += AllTrim(A6_NREDUZ)
                        aDados2[VL_ORIG] := If(mv_par02==1,aAplic[nX][2],aAplic[nX][2]/&('SM2->M2_MOEDA'+cSuf))
                        oSection2:PrintLine()
                        aFill(aDados2,nil)
                    Next nX
                EndIF

                aDados2[DESC_TOTAL] := "Resgates "
                aDados2[VL_REC] := If(mv_par02==1,nTotResg,nTotResg/&('SM2->M2_MOEDA'+cSuf))
                oSection2:PrintLine()
                aFill(aDados2,nil)

                IF nTotResg>0
                    For nX := 1 To Len(aBancosR)
                        aDados2[DESC_TOTAL] := Space(4) + aResgate[nX][1]
                        dbSelectArea("SA6")
                        If ( xFilial("SA6") == Space(nTamFilial) )
                            dbSeek( cFilSA6 + aResgate[nX][1] )
                        Else
                            dbSeek(aResgate[nX,3]+aResgate[nX][1])
                        EndIf

                        aDados2[DESC_TOTAL] += AllTrim(A6_NREDUZ)
                        aDados2[VL_ORIG] := If(mv_par02==1,aResgate[nX][2],aResgate[nX][2]/&('SM2->M2_MOEDA'+cSuf))
                        oSection2:PrintLine()
                        aFill(aDados2,nil)
                    Next nX
                EndIF

                aDados2[DESC_TOTAL] := "Outras Saidas "
                aDados2[VL_PAG] := If(mv_par02==1,nPagHoje,nPagHoje/&('SM2->M2_MOEDA'+cSuf))
                oSection2:PrintLine()
                aFill(aDados2,nil)

                If lLibCheq
                    aDados2[DESC_TOTAL] :=  "Cheques pendentes de liberacao"
                    aDados2[VL_PAG] := If(mv_par02==1,nChqPend,nChqPend/&('SM2->M2_MOEDA'+cSuf))
                    oSection2:PrintLine()
                    aFill(aDados2,nil)
                Endif

                aDados2[DESC_TOTAL] := "Outras Entradas "
                aDados2[VL_REC] := If(mv_par02==1,nRecHoje,If(SEH->EH_MOEDA > 1,nRecHoje,nRecHoje/&('SM2->M2_MOEDA'+cSuf)))
                oSection2:PrintLine()
                aFill(aDados2,nil)

                oReport:SkipLine()
                aDados2[DESC_TOTAL] := "Totais ate a hora da emissao "
                aDados2[VL_PAG] := If(mv_par02==1,nTotSaidas,If(SEH->EH_MOEDA > 1,nTotSaidas,nTotSaidas/&('SM2->M2_MOEDA'+cSuf)))
                aDados2[VL_REC] := If(mv_par02==1,nTotEntradas,If(SEH->EH_MOEDA > 1,nTotEntradas,nTotEntradas/&('SM2->M2_MOEDA'+cSuf)))
                oSection2:PrintLine()
                aFill(aDados2,nil)

                oReport:ThinLine()
                nPagHoje := 0
                nRecHoje := 0
                nTotAplic:= 0
                nTotResg := 0
            EndIF
        EndIF

        SA6->(dbGoTo(nRegSa6))
        SE8->(dbSetOrder( nIndSE8 ))
        If !(dbSeek(If((MV_PAR03==1 .And. nLenSelFil == 0),xFilial(),"")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS(dDataBase),.t.))	/* GESTAO */
        dbSkip(-1)
        dDtSE8  := SE8->E8_DTSALAT
        lSldSE8 := .F.
        nRecSE8 := SE8->(RECNO())
        /* GESTAO - Inicio */
        While (  !Bof() .And. If((MV_PAR03==1 .And. nLenSelFil == 0),xFilial()==SE8->E8_FILIAL, .T. ) .And.;
                SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON == ;
                SE8->E8_BANCO+SE8->E8_AGENCIA+SE8->E8_CONTA .And.;
                SE8->E8_DTSALAT == dDtSE8 )
            If nLenSelFil > 0
                cFilTmp := AllTrim(SE8->E8_FILIAL)
                nLenFil := Len(cFilTmp)
                If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                    SE8->(DbSkip(-1))
                    Loop
                Endif
            Else
                If mv_par03 == 2
                    If lGestao .and. Substring(xFilial(),1,nTamEmp)!= Substring(SE8->E8_FILIAL,1,nTamEmp)
                        SE8->(DbSkip())
                        Loop
                    EndIf
                EndIf
            Endif
            /* GESTAO - Fim */
            nRecSE8 := SE8->(RECNO())
            dbSkip(-1)
            lSldSE8 := .T.
        EndDo

        If lSldSE8
            dbGoTo(nRecSE8)
        EndIf
        EndIf

        nValor := 0
        /* GESTAO - inicio */
        While ( !Eof() .And. If((mv_par03==1 .And. nLenSelFil == 0),xFilial("SE8")==SE8->E8_FILIAL,.T. ) .And.;
                SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON == ;
                SE8->E8_BANCO+SE8->E8_AGENCIA+SE8->E8_CONTA .And.;
                SE8->E8_DTSALAT <= dDataBase)
            If nLenSelFil > 0
                cFilTmp := AllTrim(SE8->E8_FILIAL)
                nLenFil := Len(cFilTmp)
                If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                    SE8->(DbSkip())
                    Loop
                Endif
                If lFilA6E8 .And. SA6->A6_FILIAL != SE8->E8_FILIAL
                    SE8->(DbSkip())
                    Loop
                EndIf
            Else
                If mv_par03 == 2
                    If lGestao .and. Substring(xFilial("SE8"),1,nTamEmp )!= Substring(SE8->E8_FILIAL,1,nTamEmp)
                        SE8->(DbSKip())
                        Loop
                    EndIf
                EndIf
            Endif
            /* GESTAO - Fim	*/
            If mv_par16 == 1			//Normal
                nValor += xMoeda(SE8->E8_SALATUA,If(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1)),mv_par02)
            ElseIf mv_par16 == 2   //Conciliado
                nValor += xMoeda(SE8->E8_SALRECO,If(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1)),mv_par02)
            ElseIf mv_par16 == 3   //Nao Conciliado
                nValor += xMoeda(SE8->E8_SALATUA-SE8->E8_SALRECO,If(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1)),mv_par02)
            EndIf
            dbSkip()
        Enddo

        If mv_par15 == 1 // Se considera limite de credito
            nLimCred := xMoeda(SA6->A6_LIMCRED,If(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1)),mv_par02)
        Endif

        // Valida a impressao de banco sem movimentacao, de acordo com o resultado do ponto de entrada FA140MVB
        If !(lSldZera .And. nValor == 0) .And. (!lMovBco .or. nValor + nLimCred != 0)
            If lFstPrint
                aDados2[DESC_TOTAL] := "Disponibilidade imediata"
                oSection2:PrintLine()
                aFill(aDados2,nil)
                lFstPrint := .F.
            EndIf

            aDados2[DESC_TOTAL] := SA6->(A6_NREDUZ + "  (" + A6_COD + ") ")
            aDados2[DESC_TOTAL] += SA6->("AG: " + A6_AGENCIA + " C/C: " + RTrim(A6_NUMCON))
            aDados2[VL_DIS]     := nValor
            oSection2:PrintLine()
            aFill(aDados2,nil)

            If mv_par15 == 1
                aDados2[DESC_TOTAL] :=  "Limite de Credito: "
                aDados2[VL_DIS]    := nLimCred
                oSection2:PrintLine()
                aFill(aDados2,nil)
            Endif
        Endif

        nDispon += (nValor + nLimCred)

        // Se emitido por empresa e o SA6 for Exclusivo, posiciono na proxima conta diferenciada
        // ja que a rotina ja aglutinou os saldos de contas identicas (Bco/Age/Cta) que existam
        // nas diferentes filiais
        SA6->(dbGoTo(nRegSa6))
        SA6->(dbSkip())

        lFirst := .F.
    EndDo

    IF (nRegSa6 != 0)
        oReport:SkipLine()
        aDados2[DESC_TOTAL] := "Total Disponivel "
        aDados2[VL_DIS] := nDispon

        oSection2:PrintLine()
        oReport:ThinLine()
        aFill(aDados2,nil)
        oReport:SkipLine()
    EndIF

    HabiCel(.T.,oReport)
    lBxFut := .F.
    oSection2:Finish()

    If Empty(MV_PAR20)

        aFill(aDados2,nil)
        oSection2:Init()

        lFirst := .T.

        // Soma Titulos vencidos - a receber e a pagar
        If mv_par06 == 1  // Considera titulos em atraso

            // Soma contas a pagar vencida pela data de Vencimento
            IF TcSrvType() != "AS/400"
                cOrdSE2 := SqlOrder(SE2->(Indexkey()))
                cRecPagAnt := FormatIn( MVPAGANT, "/" )
                aStru := SE2->(DbStruct())
                cQuery := ""
                aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
                cQuery := "SELECT  " +SubStr(cQuery,2) + ", R_E_C_N_O_ RECNOSE2 "
                cQuery += "FROM " + RetSqlName("SE2") + " SE2 "
                /*
                GESTAO - inicio */
                If nLenSelFil > 0
                    cQuery += "WHERE E2_FILIAL " + GetRngFil( aSelFil, "SE2", .T., @cTmpFil)
                    Aadd(aTmpFil,cTmpFil)
                Else
                    If mv_par03 == 1
                        cQuery += "WHERE E2_FILIAL = '" + xFilial("SE2") + "'"
                    Else
                        If lGestao
                            If UPPER(AllTrim(TcGetDb())) $ "DB2|ORACLE"
                                cQuery += "WHERE SUBSTR(E2_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE2"), 1, nTamEmp)+"'"
                            Else
                                cQuery += "WHERE SUBSTRING(E2_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE2"), 1, nTamEmp)+"'"
                            Endif
                        Else
                            cQuery += "WHERE E2_FILIAL between ' ' AND 'zz'"
                        EndIf
                    Endif
                Endif
                /* GESTAO - fim
                */
                cQuery += " AND E2_PREFIXO between '" + mv_par09 + "' AND '"+mv_par10 + "'"
                cQuery += " AND E2_MOEDA IN " + StrTran(FormatIn(AllTrim('0' + mv_par08),,1),"'","")
                cQuery += " AND E2_VENCREA <= '" + Dtos(dDataBase-1) +"'"
                If cPaisLoc=="BRA"
                    cQuery += " AND E2_TIPO NOT IN " + cRecPagAnt
                EndIf
                If mv_par11 == 2
                    cQuery += " AND E2_SALDO > 0 "
                Endif
                If mv_par12 == 2
                    cQuery += " AND E2_MOEDA = " + Str(nMoeda,2)
                Endif
                cQuery += " AND E2_FLUXO <> 'N'"
                //Considerar ou nao titulos com emissao posterior a database
                If mv_par14 == 2
                    cQuery += " AND E2_EMIS1 <= '"+Dtos(dDataBase) +"'"
                Endif
                cQuery += " AND D_E_L_E_T_ = ' '"
                cQuery += " ORDER BY " + cOrdSE2
                cQuery := ChangeQuery(cQuery)
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"E2VENC",.T.,.T.)
                aEval(aStru, {|e| If(e[2] != "C", TCSetField("E2VENC", e[1], e[2], e[3], e[4]), Nil)})

                oReport:SetMeter(RecCount())
                While E2VENC->(!EOF())
                    oReport:IncMeter()
                    SE2->(MsGoto(E2VENC->RECNOSE2))
                    If mv_par11 == 1
                        nSaldo := SaldoTit(E2VENC->E2_PREFIXO,E2VENC->E2_NUM,E2VENC->E2_PARCELA,E2VENC->E2_TIPO,E2VENC->E2_NATUREZ,"P",E2VENC->E2_FORNECE,mv_par02,E2VENC->E2_VENCREA,dDataBase,E2VENC->E2_LOJA,,If(cPaisLoc=="BRA",E2VENC->E2_TXMOEDA,0), mv_par17)

                        // Calcula valores acessórios.
                        nSaldo   += E2VENC->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, /*lBaixados*/, /*cCodVa*/, "P", dDataBase, /*aValAces*/, E2_MOEDA, mv_par02, E2_TXMOEDA))
                    Else
                        // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                        lTxMoeda := SM2->(MsSeek(E2VENC->E2_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                        nSaldo   := xMoeda((E2VENC->E2_SALDO+E2VENC->E2_SDACRES-E2VENC->E2_SDDECRE),E2VENC->E2_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",E2VENC->E2_TXMOEDA,0))

                        // Calcula valores acessórios.
                        nSaldo   += E2VENC->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, /*lBaixados*/, /*cCodVa*/, "P", E2_VENCREA, /*aValAces*/, E2_MOEDA, mv_par02, E2_TXMOEDA))
                    EndIf

                    If cPaisLoc<>"BRA"
                        If E2VENC->E2_TIPO $ MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM+"/"+MVRECANT+"/"+MVPAGANT
                            nApagVenc -= nSaldo
                        Else
                            nApagVenc += nSaldo
                        Endif
                    Else
                        If E2VENC->E2_TIPO $ MVABATIM .or. E2VENC->E2_TIPO $ MV_CPNEG
                            nApagVenc -= nSaldo
                        Else
                            nApagVenc += nSaldo
                        Endif
                    EndIf
                    E2VENC->(dbSkip())
                Enddo
                E2VENC->(dbCloseArea())
                dbSelectArea("SE2")

            Else

                //³Soma Contas a pagar vencida pela data de Vencimento			  ³
                dDataVenc := dDataBase-1
                dbSelectArea("SE2")

                If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                    If lFirst
                        RetIndex("SE2")
                    EndIf
                    dbSelectArea("SE2")
                    SE2->(dbSetOrder(3))
                    SE2->(dbSeek( cFilSE2 + DTOS(CTOD("01/01/60","ddmmyy")) ,.t.))
                Else
                    dbGoTop()
                EndIf

                While ! SE2->(EOF()) .And. SE2->E2_VENCREA <= dDataVenc
                    /*
                    GESTAO - inicio */
                    If nLenSelFil > 0
                        cFilTmp := AllTrim(SE2->E2_FILIAL)
                        nLenFil := Len(cFilTmp)
                        If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                            SE2->(DbSkip())
                            Loop
                        Endif
                    Else
                        IF mv_par03 == 1 .and. SE2->E2_FILIAL != cFilSE2
                            Exit
                        EndIf
                        If mv_par03 == 2
                            If lGestao .and. Substring(E2_FILIAL,1,nTamEmp)!=Substring(cFilSE2,1,nTamEmp)
                                SE2->(dbSkip())
                                Loop
                            EndIf
                        EndIf
                    Endif
                    /* GESTAO - fim
                    */
                    If SE2->E2_TIPO $ MVPAGANT .And. cPaisLoc=="BRA"
                        SE2->(dbSkip())
                        Loop
                    EndIf
                    If ! ( AllTrim(Str(SE2->E2_MOEDA,2)) $ mv_par08 )
                        dbSkip()
                        Loop
                    EndIf
                    If SE2->E2_SALDO == 0 .and. IIf(mv_par11==1,SE2->E2_BAIXA <= dDataBase,.T.)
                        SE2->(dbSkip())
                        Loop
                    EndIf
                    IF SE2->E2_PREFIXO < mv_par09 .or. SE2->E2_PREFIXO > mv_par10  //Do Prefixo ao Prefixo
                        SE2->(dbSkip())
                        Loop
                    EndIF
                    If SE2->E2_FLUXO == "N" .or. (SE2->E2_EMIS1 > dDataBase .and. mv_par14 == 2)
                        dbSkip()
                        Loop
                    EndIf
                    If mv_par12 = 2
                        If SE2->E2_MOEDA != nMoeda
                            SE2->(dbSkip())
                            Loop
                        EndIf
                    EndIf
                    If mv_par11 == 1
                        nSaldo := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,mv_par02,SE2->E2_VENCREA,dDataBase,SE2->E2_LOJA,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0), mv_par17)
                    Else
                        // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                        lTxMoeda := SM2->(MsSeek(SE2->E2_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                        nSaldo := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))
                    EndIf
                    If SE2->E2_TIPO $ MVABATIM+"/"+MV_CPNEG
                        nApagVenc -= nSaldo
                    Else
                        nApagVenc += nSaldo
                    EndIf
                    SE2->(dbSkip())
                End
            Endif

            // Soma Contas a receber vencida pela data de Vencimento
            IF TcSrvType() != "AS/400"
                cRecPagAnt := FormatIn( MVRECANT + "/" + MVIRF, "/" )
                cOrdSE1 := SqlOrder(SE1->(Indexkey()))
                aStru := SE1->(DbStruct())
                cQuery := ""
                aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
                cQuery := "SELECT  " +SubStr(cQuery,2) + ", R_E_C_N_O_ RECNOSE1 "
                cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
                /*
                GESTAO - inicio */
                If nLenSelFil > 0
                    cQuery += "WHERE E1_FILIAL " + GetRngFil( aSelFil, "SE1", .T., @cTmpFil)
                    Aadd(aTmpFil,cTmpFil)
                Else
                    If mv_par03 == 1
                        cQuery += "WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
                    Else
                        If lGestao
                            If UPPER(AllTrim(TcGetDb())) $ "DB2|ORACLE"
                                cQuery += "WHERE SUBSTR(E1_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE1"), 1, nTamEmp)+"'"
                            Else
                                cQuery += "WHERE SUBSTRING(E1_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE1"), 1, nTamEmp)+"'"
                            EndIf
                        Else
                            cQuery += "WHERE E1_FILIAL between ' ' AND 'zz'"
                        EndIf
                    Endif
                Endif
                /* GESTAO - fim
                */
                cQuery += " AND E1_PREFIXO between '" + mv_par09 + "' AND '"+mv_par10 + "'"
                cQuery += " AND E1_MOEDA IN " + StrTran(FormatIn(AllTrim('0' + mv_par08),,1),"'","")
                cQuery += " AND (E1_VENCREA <= '" + Dtos(dDataBase-1) +"')"
                //cQuery += " OR (E1_MOVIMEN <> ' ' AND E1_MOVIMEN <= '" + Dtos(dDataBase-1) + "'))"
                If  cPaisLoc=="BRA"
                    cQuery += " AND E1_TIPO NOT IN " + cRecPagAnt
                EndIf
                cQuery += " AND E1_SITUACA NOT IN " + FormatIn(cListDesc,"|")			//sitcob
                If mv_par11 == 2
                    cQuery += " AND E1_SALDO > 0 "
                Endif
                If mv_par12 == 2
                    cQuery += " AND E1_MOEDA = " + Str(nMoeda,2)
                Endif
                cQuery += " AND E1_FLUXO <> 'N'"
                //Considerar ou nao titulos com emissao posterior a database
                If mv_par14 == 2
                    cQuery += " AND E1_EMISSAO <= '"+Dtos(dDataBase) +"'"
                Endif
                If mv_par19 == 2
                    cQuery += " AND E1_FILIAL||E1_PREFIXO||E1_NUM||E1_PARCELA NOT IN ( "
                    cQuery += " SELECT SE5.E5_FILIAL||SE5.E5_PREFIXO||SE5.E5_NUMERO||SE5.E5_PARCELA "
                    cQuery += " FROM " + RetSqlName("SE5")  + " SE5 "
                    cQuery += " WHERE  SE5.E5_TIPODOC IN ('ES') AND SE5.D_E_L_E_T_ = ' ' )"
                Endif
                cQuery += " AND D_E_L_E_T_ = ' '"
                cQuery += " ORDER BY " + cOrdSE1
                cQuery := ChangeQuery(cQuery)
                dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"E1VENC",.T.,.T.)
                aEval(aStru, {|e| If(e[2]!= "C", TCSetField("E1VENC", e[1], e[2],e[3],e[4]),Nil)})
                oReport:SetMeter(RecCount())
                While !E1VENC->(EOF())
                    oReport:IncMeter()
                    SE1->(MsGoto(E1VENC->RECNOSE1))
                    If mv_par11 == 1
                        nSaldo := SaldoTit(E1VENC->E1_PREFIXO,E1VENC->E1_NUM,E1VENC->E1_PARCELA,E1VENC->E1_TIPO,E1VENC->E1_NATUREZ,"R",E1VENC->E1_CLIENTE,mv_par02,E1VENC->E1_VENCREA,dDataBase,E1VENC->E1_LOJA,,If(cPaisLoc=="BRA",E1VENC->E1_TXMOEDA,0), mv_par17)
                        IF cPaisLoc == "BRA" .And. lMvBr10925 .and. E1VENC->E1_TIPO $ "PIS|COF|CSL" .and. E1VENC->E1_BAIXA <= dDatabase // Quando o parametro MV_BR10925 estiver igual a 1 - Baixa
                            nSaldo -= E1VENC->E1_VALOR
                        Endif
                        IF E1VENC->E1_TIPO $ MVABATIM .AND. E1VENC->E1_BAIXA <= dDatabase  //Quando se trata de impostos (abatimento) o saldotit não funciona corretamente por nao tratar tais movimentos de baixa.
                            nSaldo -= E1VENC->E1_VALOR
                        Endif
                        IF E1VENC->(E1_PIS+E1_CSLL+E1_COFINS) > 0 .AND. mv_par13 == 1 // Reteve impostos
                            nSaldo -= SomaAbat(E1VENC->E1_PREFIXO,E1VENC->E1_NUM,E1VENC->E1_PARCELA,"R",mv_par02,,E1VENC->E1_CLIENTE,E1VENC->E1_LOJA,E1VENC->E1_FILIAL,E1VENC->E1_EMISSAO)
                        Endif
                    Else
                        // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                        lTxMoeda := SM2->(MsSeek(E1VENC->E1_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                        nSaldo   := xMoeda((E1VENC->E1_SALDO+E1VENC->E1_SDACRES-E1VENC->E1_SDDECRE),E1VENC->E1_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",E1VENC->E1_TXMOEDA,0))
                        IF E1VENC->(E1_PIS+E1_CSLL+E1_COFINS) > 0 .AND. mv_par13 == 1 // Reteve impostos
                            nSaldo -= SomaAbat(E1VENC->E1_PREFIXO,E1VENC->E1_NUM,E1VENC->E1_PARCELA,"R",mv_par02,,E1VENC->E1_CLIENTE,E1VENC->E1_LOJA,,E1VENC->E1_EMISSAO)
                        Endif
                    Endif
                    // Se titulo do Template GEM
                    If HasTemplate("LOT")  .And. !Empty(SE1->E1_NCONTR)
                        If SE1->E1_VALOR == SE1->E1_SALDO .Or.;
                                SE1->E1_VALOR == nSaldo //o titulo pode estar quitado(e1_saldo=0) mas valor em datas retroativas nao, portanto devera somar o valor do gem
                            nSaldo += CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
                        EndIf
                    EndIf
                    If E1VENC->E1_SALDO > 0
                        If cPaisLoc<>"BRA"
                            IF Alltrim(E1VENC->E1_TIPO) $  MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM+"/"+MVRECANT+"/"+MVPAGANT
                                nArecVenc -= nSaldo
                            Else
                                nArecVenc += nSaldo
                            EndIf
                        Else
                            IF E1VENC->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                                nArecVenc -= nSaldo
                            Else
                                nArecVenc += nSaldo
                            EndIf
                        EndIf
                    Else
                        If cPaisLoc<>"BRA"
                            IF Alltrim(E1VENC->E1_TIPO) $  MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM+"/"+MVRECANT+"/"+MVPAGANT
                                nAcumRc -= nSaldo
                            Else
                                nAcumRc += nSaldo
                            EndIf
                        Else
                            IF E1VENC->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                                nAcumRc -= nSaldo
                            Else
                                nAcumRc += nSaldo
                            EndIf
                        EndIf
                    Endif

                    //Quando o parametro mv_par19 = 2 e o titulo tiver estorno ele nao deve ser exibido no relatorio.
                    If mv_par19 == 1 .or. mv_par19 == 2

                        //³ Impressao dos titulos baixados p/ recebimento futuro.		  ³
                        If nSaldo <> 0  .And. E1VENC->E1_SALDO == 0
                            If !lImpFut
                                oReport:ThinLine()
                                oReport:PrintText("Títulos Baixados com Previsão de Movimentação Bancária Futura")
                                lImpFut := .T.
                            EndIf
                            If E1VENC->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                                nDispon  -= nSaldo
                                nTotFutR -= nSaldo
                            Else
                                nDispon  += nSaldo
                                nTotFutR += nSaldo
                            EndIf
                            oSection2:PrintLine()
                        EndIf
                    Endif
                    E1VENC->(dbSkip())
                Enddo
                oReport:SkipLine()
                oReport:ThinLine()
                E1VENC->(dbCloseArea())
                dbSelectArea("SE1")
            Else

                //³Soma Contas a receber vencida pela data de Vencimento			  ³
                dbSelectArea("SE1")
                If mv_par03 == 1
                    If lFirst
                        RetIndex("SE1")
                    EndIf
                    dbSelectArea("SE1")
                    SE1->(dbSetOrder(7))
                    SE1->(dbSeek( cFilSE1 + DTOS(CTOD("01/01/60","ddmmyy")),.T.))
                Else
                    dbGoTop()
                EndIf
                While ! SE1->(EOF()) .And. (SE1->E1_VENCREA <= dDataBase-1) .Or. (!Empty(SE1->E1_MOVIMEN) .And. SE1->E1_MOVIMEN <= dDataBase-1)
                    IF mv_par03 == 1 .and. cFilSE1 != SE1->E1_FILIAL
                        Exit
                    EndIf
                    If mv_par03 == 2
                        If lGestao .and. Substring(E1_FILIAL,1,nTamEmp)!=Substring(cFilSE1,1,nTamEmp)
                            SE1->(dbSkip())
                            Loop
                        EndIf
                    EndIf
                    If SE1->E1_TIPO $ MVRECANT .And. cPaisLoc=="BRA"
                        SE1->(dbSkip())
                        Loop
                    EndIf
                    IF SE1->E1_PREFIXO < mv_par09 .or. SE1->E1_PREFIXO > mv_par10  //Do Prefixo ao Prefixo
                        SE1->(dbSkip())
                        Loop
                    EndIF
                    If ! ( AllTrim(Str(SE1->E1_MOEDA,2)) $ mv_par08 )
                        dbSkip( )
                        Loop
                    EndIf
                    If SE1->E1_FLUXO == "N" .or. (SE1->E1_EMISSAO > dDatabase .and. mv_par14 == 2)
                        dbSkip()
                        Loop
                    EndIf
                    If mv_par12 = 2
                        If SE1->E1_MOEDA != nMoeda
                            SE1->(dbSkip())
                            Loop
                        EndIf
                    EndIf
                    If mv_par11 == 1
                        nSaldo := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par02,SE1->E1_VENCREA,dDataBase,SE1->E1_LOJA,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0), mv_par17)
                    Else
                        // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                        lTxMoeda := SM2->(MsSeek(SE1->E1_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                        nSaldo   := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                    End
                    // Se titulo do Template GEM
                    If HasTemplate("LOT")  .And. !Empty(SE1->E1_NCONTR)
                        If SE1->E1_VALOR == SE1->E1_SALDO .Or.;
                                SE1->E1_VALOR == nSaldup //o titulo pode estar quitado(e1_saldo=0) mas valor em datas retroativas nao, portanto devera somar o valor do gem
                            nSaldo += CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
                        EndIf
                    EndIf
                    If SE1->E1_SALDO > 0
                        IF SE1->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                            nArecVenc -= nSaldo
                        Else
                            nArecVenc += nSaldo
                        EndIf
                    Else
                        IF SE1->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                            nAcumRc -= nSaldo
                        Else
                            nAcumRc += nSaldo
                        EndIf
                    Endif

                    //Quando o parametro mv_par19 = 2 e o titulo tiver estorno ele nao deve ser exibido no relatorio.
                    If mv_par19 == 1 .or. (mv_par19 == 2 .and. ListaES(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA))

                        //³ Impressao dos titulos baixados p/ recebimento futuro.		  ³
                        If nSaldo <> 0  .And. SE1->E1_SALDO == 0
                            If !lImpFut
                                oReport:ThinLine()
                                oReport:PrintText("Títulos Baixados com Previsão de Movimentação Bancária Futura")
                                lImpFut := .T.
                            EndIf
                            If SE1->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                                nDispon  -= nSaldo
                                nTotFutR -= nSaldo
                            Else
                                nDispon  += nSaldo
                                nTotFutR += nSaldo
                            EndIf
                            oSection2:PrintLine()
                        EndIf
                    Endif
                    SE1->(dbSkip())
                EndDo
                oReport:SkipLine()
                oReport:ThinLine()
                oSection2:Finish()
            Endif

            If nArecVenc # 0 .or. nApagVenc # 0
                nDispon += nArecVenc
                nDispon -= nApagVenc

                aDados2[DESC_TOTAL] :=  "Total De Títulos Vencidos"
                lBxFut := .F.
                lImpDev := .T.
                HabiCel(.F.,oReport)
                oSection2:PrintLine()
                HabiCel(.T.,oReport)
                aFill(aDados2,nil)
                oReport:SkipLine()
                lBxFut := .T.
                lImpDev := .F.
            Endif
        Endif

    Else// Se for mostrar por visão Gerencial

        lBxFut := .F.
        FRVisaoGer(nDispon, @cArqTmp, oReport, nMoeda, nDecs)

        oSection2:Init()

        dbSelectArea("FJ3")
        dbSetOrder(1)
        dbGoTop()

        dbSelectArea("cArqTmp")
        nLastRec := LastRec()
        dbSetOrder(1)
        dbGoTop()

        // Impressão
        Do While CARQTMP->(!EOF())

            If FJ3->(dbSeek(xFilial("FJ3") + MV_PAR20 + AllTrim(CARQTMP->ORDEM))) //Procura pela descricao na FJ3 para impressao em branco
                // Inverte o saldo se assim a entidade estiver configurada
                If FJ3->FJ3_FATSLD == "2" .And. !(FJ3->FJ3_IDENT $ "5" ) //Não for linha sem valor
                    RecLock("cArqTmp", .F.)
                    CARQTMP->RECEBIDOS := -(CARQTMP->RECEBIDOS)
                    CARQTMP->PAGOS     := -(CARQTMP->PAGOS)
                    CARQTMP->DISPON    := -(CARQTMP->DISPON)
                    MsUnLock()
                EndIf

                // Imprimir traço
                If FJ3->FJ3_IDENT = '5' .And. Alltrim(FJ3->FJ3_DESCCG) == "-"
                    oReport:ThinLine()
                EndIf
            EndIf

            // Retira a data dos titulos vencidos
            If (mv_par06 == 1 .and. RecNo() = 1 .and. SubStr(CARQTMP->CODDESC, 1, 10) == "00/00/0000")
                RecLock("cArqTmp",.F.)
                CARQTMP->CODDESC :=  "Títulos vencidos"
                MsUnLock()
            EndIf

            If CARQTMP->(RECEBIDOS <> 0 .or. PAGOS <> 0 .or. RecNo() = 1 .or. RecNo() = nLastRec)
                oSection2:PrintLine()
            Endif

            CARQTMP->(dbSkip())
        EndDo
        cArqTmp->(dbCloseArea())

        oSection2:Finish()

        If _oFINR1401 <> Nil
            _oFINR1401:Delete()
            _oFINR1401 := Nil
        Endif
    EndIf

    If Empty(MV_PAR20)

        //³Soma as Comissoes. Os criterios de selecao dos registros foram³
        //³determinados no instante da criacao do indice condicional.	  ³
        if mv_par07 == 1
            DbSelectArea("SE3")
            dbGoTop()
            While !Eof() .and. SE3->E3_DATA <= dDataBase
                /*
                GESTAO - inicio */
                If nLenSelFil > 0
                    cFilTmp := AllTrim(SE3->E3_FILIAL)
                    nLenFil := Len(cFilTmp)
                    If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                        SE3->(DbSkip())
                        Loop
                    Endif
                Endif
                /* GESTAO - fim
                */
                nComissoes += xMoeda(SE3->E3_COMIS,1,mv_par02)
                dbSkip()
            End

            If nComissoes # 0
                nDispon -= nComissoes
                aDados2[DESC_TOTAL] := "Total de Comissoes A Pagar"
                aDados2[VL_PAG] := nComissoes
                aDados2[VL_DIS] := nDispon
                lBxFut := .T.
                lImpDev := .T.
                HabiCel(.F.,oReport)
                oSection2:PrintLine()
                HabiCel(.T.,oReport)
                aFill(aDados2,nil)
                oReport:SkipLine()
            Endif
        Endif

        // Acessa titulos iniciais
        nDias := (dDataAte-dDataBase)
        oReport:SetMeter(nDias)

        // Verifica pedidos de venda
        If nImprPV <> 3
            fc020Venda( mv_par08, /*cAliasPv*/, /*aTotais*/, /*lRegua*/, mv_par02, /*aPeriodo*/, /*cFilIni*/, /*cFilFin*/,,,, aSelFil, .T.)
            aEval(aVendas, {|x| x[1] := max(x[1], dDataBase)})
            aSort(aVendas,,, {|x, y| dtos(x[1]) + x[6] + x[5] < dtos(y[1]) + y[6] + y[5]})
        Endif

        // Verifica pedidos de compra
        If nImprPC <> 3
            fc020Compra(/*cAliasPc*/,/*aTotais*/,/*lRegua*/,mv_par02,/*aPeriodo*/,/*cFilIni*/,/*cFilFin*/, /*cPedidos*/,,, aSelFil, .T.)
            aEval(aCompras, {|x| x[1] := max(x[1], dDataBase)})
            aSort(aCompras,,, {|x, y| dtos(x[1]) + x[6] + x[5] < dtos(y[1]) + y[6] + y[5]})
        Endif

        // Soma Contas a Receber pela data de Vencimento
        For nY := 1 To nDias
            dDataVenc := dDataBase + nY - 1
            lAchou := .F.
            dbSelectArea("SE1")
            If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                dbSetOrder(7)
                dbSeek( cFilSE1 + DTOS(dDataVenc) )
            Else
                dbSetOrder( nIndexSE1 )
                dbSeek(DTOS(dDataVenc))
            Endif
            oReport:IncMeter()
            While !Eof() .And. SE1->E1_VENCREA == dDataVenc
                /*
                GESTAO - inicio */
                If nLenSelFil > 0
                    cFilTmp := AllTrim(SE1->E1_FILIAL)
                    nLenFil := Len(cFilTmp)
                    If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                        SE1->(DbSkip())
                        Loop
                    Endif
                Else
                    IF mv_par03 == 1 .and. SE1->E1_FILIAL != cFilSE1
                        Exit
                    EndIF
                    IF mv_par03 == 2
                        If lGestao .and. Substring(SE1->E1_FILIAL,1,nTamEmp )!= Substring(cFilSE1,1,nTamEmp )
                            SE1->(dbSkip())
                            Loop
                        EndIf
                    EndIF
                Endif
                /* GESTAO - fim
                */
                If SE1->E1_TIPO $ MVRECANT
                    dbSkip()
                    Loop
                Endif
                IF SE1->E1_PREFIXO < mv_par09 .or. SE1->E1_PREFIXO > mv_par10  //Do Prefixo ao Prefixo
                    SE1->(dbSkip())
                    Loop
                EndIF
                If ! ( AllTrim(Str(SE1->E1_MOEDA,2)) $ mv_par08 )
                    dbSkip( )
                    Loop
                EndIf
                If SE1->E1_FLUXO == "N" .or. (SE1->E1_EMISSAO > dDatabase .and. mv_par14 == 2)
                    dbSkip()
                    Loop
                EndIf
                IF ( SE1->E1_SALDO = 0 .and. IIF( mv_par11 == 1, SE1->E1_BAIXA <= dDataBase, .T. )  ) .or. SE1->E1_SITUACA $ cListDesc //SITCOB
                    dbSkip()
                    Loop
                EndIF
                IF mv_par13 == 2 .And. SE1->E1_TIPO $ MVABATIM
                    dbSkip()
                    Loop
                EndIf
                If mv_par12 = 2
                    If SE1->E1_MOEDA != nMoeda
                        SE1->(dbSkip())
                        Loop
                    EndIf
                EndIf
                AAdd(aRecSE1,{SE1->E1_VENCREA,SE1->(Recno()),SE1->E1_NOMCLI})
                SE1->(dbSkip())
            EndDo
        Next nY

        // Ordena por data e cliente respectivamente.
        aRecSE1 := aSort(aRecSE1,,,{|x,y| DTOS(x[1])+x[3]<DTOS(y[1])+y[3]})
        oSection2:Init()
        For nY := 1 To nDias
            dDataVenc := dDataBase + nY - 1
            nPos := 0
            If (nPos := aScan(aRecSe1,{|x| x[1] == dDataVenc},1)) > 0
                While (nPos<=Len(aRecSe1)) .and. (aRecSe1[nPos][1] == dDataVenc)
                    SE1->(dbGoTo(aRecSe1[nPos][2]))
                    If mv_par11 == 1
                        nSaldup := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par02,SE1->E1_VENCREA,dDataBase,SE1->E1_LOJA,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0), mv_par17)
                    Else
                        // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                        lTxMoeda := SM2->(MsSeek(SE1->E1_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                        nSaldup  := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par02,If(lTxMoeda,SE1->E1_VENCREA,dDataBase),nDecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                    End
                    // Se titulo do Template GEM
                    If HasTemplate("LOT")  .And. !Empty(SE1->E1_NCONTR)
                        If SE1->E1_VALOR == SE1->E1_SALDO .Or.;
                                SE1->E1_VALOR == nSaldup //o titulo pode estar quitado(e1_saldo=0) mas valor em datas retroativas nao, portanto devera somar o valor do gem
                            nSaldup += CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
                        EndIf
                    EndIf
                    dbSelectArea("SE1")
                    If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                        dbSetOrder(7)
                    Endif
                    IF SE1->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                        nDispon-=nSalDup
                    Else
                        nDispon+=nSalDup
                    EndIf
                    IF !lAchou
                        dDataTrab := SE1->E1_VENCREA
                        If SE1->E1_SITUACA $ cListBco 	// Situacoes que nao considera dias de retencao  //sitcob
                            dDataVcOri := SE1->E1_VENCTO
                            //Verifico se o proximo dia util apos o vencimento eh igual ao vencto real do titulo
                            //Se for igual e o titulo estiver em cobranca, aplico os dias de retencao do banco
                            //Se for diferente e o titulo estiver em cobranca, quer dizer que ja foram aplicados os dias de retencao
                            //logo nao aplico novamente.
                            If DtoS( DataValida( dDataVcOri ) ) == DtoS( dDataTrab )
                                // Posiciona no banco para obter dias de retencao
                                SA6->( dbSetOrder( 1 ) )
                                SA6->( MsSeek( xFilial("SA6") + SE1->( E1_PORTADO + E1_AGEDEP + E1_CONTA ) ) )
                                // Dias de retencao do banco em que o titulo esta
                                nDiasRet := SA6->A6_RETENCA
                                // Calcula proxima data valida (nao feriado) adicionados os dias de retencao
                                For nX := 1 To nDiasRet
                                    dDataTrab := DataValida( dDataTrab + 1, .T. )
                                Next
                            EndIf
                        EndIf
                        aDados2[DT_VENC] := dDataTrab
                    EndIF
                    aDados2[PREFIXO]    := SE1->E1_PREFIXO
                    aDados2[TITUL]      := SE1->E1_NUM+(If(!EMPTY(SE1->E1_PARCELA),"-",""))+SE1->E1_PARCELA
                    aDados2[TIPO]       := SE1->E1_TIPO
                    aDados2[EMISSAO]    := SE1->E1_EMISSAO
                    aDados2[FORNEC]     := SE1->E1_CLIENTE
                    aDados2[NOM_FORNEC] := SubStr(SE1->E1_NOMCLI,1,25)
                    aDados2[HISTORICO]  := SubStr(SE1->E1_HIST,1,25)
                    nAbatim := 0
                    If mv_par13 == 2
                        If mv_par14 == 1
                            dOldData := dDataBase
                            dDataBase := CTOD("31/12/40")
                        Endif
                        nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par02,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL)

                        If mv_par14 == 1
                            dDataBase := dOldData
                        Endif

                    Endif
                    nSalDup -= nAbatim
                    nDispon -= nAbatim

                    // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                    lTxMoeda := SM2->(MsSeek(dDataVenc)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                    aDados2[VL_ORIG] := xMoeda(SE1->E1_VALOR+SE1->E1_ACRESC-SE1->E1_DECRESC-nAbatim,SE1->E1_MOEDA,mv_par02,If(lTxMoeda,dDataVenc,dDataBase),,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                    aDados2[VL_ORIG] -= FaDescFin("SE1",,SE1->E1_VALOR,SE1->E1_MOEDA)
                    aDados2[VL_REC] := nSalDup
                    aDados2[VL_DIS] := nDispon

                    If mv_par02 != 1 .and. !lAchou
                        aDados2[TAXA] := &('SM2->M2_MOEDA'+cSuf)
                        dDataImp:=dDataVenc
                    EndIf
                    lBxFut := .T.
                    lImpDev := .T.
                    oSection2:PrintLine()
                    aFill(aDados2,nil)

                    lAchou:=.t.
                    dbSelectArea("SE1")
                    IF SE1->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                        nTotTitR -= nSalDup
                    Else
                        nTotTitR += nSalDup
                    End
                    nPos += 1
                EndDo
            EndIf

            If cIpProj =="S"

                //³Verifica se existe aplica‡„o a ser resgatada no dia				³
                dbSelectArea("SEG")
                If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                    dbSetOrder(2)
                    dbSeek( cFilSEG + Dtos(dDataVenc) )
                Else
                    dbSetOrder(nIndexSEG)
                    dbSeek(Dtos(dDataVenc))
                Endif

                lAchou :=.f.
                While !Eof() .And. SEG->EG_DATARES == dDataVenc
                    /*
                    GESTAO - inicio */
                    If nLenSelFil > 0
                        cFilTmp := AllTrim(SEG->EG_FILIAL)
                        nLenFil := Len(cFilTmp)
                        If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                            SEG->(DbSkip())
                            Loop
                        Endif
                    ElseIF mv_par03 == 1 .and. SEG->EG_FILIAL != cFilSEG
                        Exit
                    Elseif mv_par03 == 2
                        If lGestao .and. Substring(xFilial(),1,nTamEmp)!= Substring (SEG->EG_FILIAL,1,nTamEmp)
                            SEG->(DbSkip())
                            Loop
                        EndIf
                    Endif
                    /* GESTAO - fim
                    */
                    If SEG->EG_TIPO == "EMP"
                        dbSkip( )
                        Loop
                    EndIf
                    nDiasInt	:= EG_DATARES-EG_DATA	//Dias de Intervalo
                    nJurDiario:= EG_TAXA/nDiasInt	  //Juros Diario
                    nValJuros := EG_VALOR+((EG_VALOR*nJurDiario)/100)*nDiasInt
                    nValGanho := nValJuros-EG_VALOR
                    nValJuros -= nValGanho*EG_IMPOSTO/100 //Impostos
                    IF mv_par02 == 1
                        nDispon += nValJuros
                    Else
                        dbSelectArea("SM2")
                        dbSeek( dDataVenc )
                        nDispon += nValJuros/&('SM2->M2_MOEDA'+cSuf)
                    EndIF
                    dbSelectArea("SEG")

                    IF !lAchou
                        aDados2[DESC_TOTAL] := DtoC(EG_DATARES)
                    EndIF

                    aDados2[DESC_TOTAL] := PadR(aDados2[DESC_TOTAL], 11) + "Projecao de Resgate de Aplicacao "
                    aDados2[DESC_TOTAL] += EG_TIPO + " - " + EG_BANCO
                    aDados2[VL_ORIG]    := If(mv_par02==1,EG_VALOR,EG_VALOR/&( 'SM2->M2_MOEDA' +cSuf))
                    aDados2[VL_REC]     := If(mv_par02==1,nValJuros,nValJuros/&( 'SM2->M2_MOEDA' +cSuf))
                    aDados2[VL_DIS]     := nDispon

                    IF mv_par02!=1 .and. !lAchou
                        dbSelectArea("SM2")
                        dbSeek(dDataVenc)
                        aDados2[TAXA] := &('SM2->M2_MOEDA'+cSuf)
                    EndIF

                    lAchou:=.T.

                    HabiCel(.F.,oReport)
                    lBxFut := .T.
                    lImpDev := .T.
                    oSection2:PrintLine()
                    HabiCel(.T.,oReport)
                    aFill(aDados2,nil)

                    dbSelectArea("SEG")
                    nTotTitR	+= IIF(mv_par02==1,nValJuros,nValJuros/&('SM2->M2_MOEDA'+cSuf))
                    dbSkip()
                EndDo

                dbSelectArea("SEH")
                If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                    dbSetOrder(2)
                    dbSeek(xFilial("SEH")+"A")
                Else
                    dbSetOrder(nIndexSEH)
                    dbSeek("A")
                Endif

                lAchou := .f.
                While ( !Eof() .And.If((MV_PAR03==1 .And. nLenSelFil == 0),SEH->EH_FILIAL==xFilial("SEH"),.T.) .And.;
                        SEH->EH_STATUS == "A" )

                    If nLenSelFil > 0
                        cFilTmp := AllTrim(SEH->EH_FILIAL)
                        nLenFil := Len(cFilTmp)
                        If Ascan(aSelFil, {|afil| cFilTmp == Substring(afil,1,nLenFil)}) == 0
                            SEH ->(dbSkip())
                            Loop
                        Endif
                    ElseIf mv_par03 == 2
                        If lGestao .and. Substring(EH_FILIAL,1,nTamEmp)!=Substring(xFilial("SEH"),1,nTamEmp)
                            SEH->(dbSkip())
                            Loop
                        Endif
                    Endif

                    If ( SEH->EH_APLEMP != "EMP" )
                        If ( Empty(SEH->EH_DATARES) .And. nY == 1 ) .Or. ((SEH->EH_DATARES < dDataVenc) .And. nY==1) .Or. ( SEH->EH_DATARES == dDataVenc )
                            nValJuros := SEH->EH_SALDO
                            If !SEH->EH_TIPO $ cAplCotas
                                aValAplic := Fa171Calc(	dDataVenc,,,,,,,, mv_par03 = 1)
                                nValJuros += aValAplic[5]-aValAplic[2]-aValAplic[3]-aValAplic[4]
                            Else
                                aValAplic := {0,0,0,0,0,0}
                                nAscan := Ascan(aAplicSeh, {|e|	e[1] == SEH->EH_CONTRAT .And.;
                                    e[2] == SEH->EH_BCOCONT .And.;
                                    e[3] == SEH->EH_AGECONT})
                                If nAscan > 0
                                    aValAplic :=	Fa171Calc(dDataVenc,SEH->EH_SLDCOTA,,,,SE9->E9_VLRCOTA,aAplicSeh[nAscan][6],(SEH->EH_SLDCOTA * aAplicSeh[nAscan][6]))
                                Endif
                                nValJuros := xMoeda(aValAplic[1]-(aValAplic[2]+aValAplic[3]+aValAplic[4]),1,mv_par02)
                            Endif
                        Else
                            nValJuros := 0
                        EndIf
                        If ( nValJuros != 0 )
                            IF MV_PAR02 == 1
                                nDispon += (nValJuros)
                            Else
                                dbSelectArea("SM2")
                                dbSetOrder(1)
                                dbSeek( dDataVenc )
                                nDispon += (nValJuros)/&('SM2->M2_MOEDA'+cSuf)
                            EndIf

                            IF !lAchou
                                aDados2[DESC_TOTAL] := DtoC(SEH->EH_DATARES)
                            EndIF

                            aDados2[DESC_TOTAL] := PadR(aDados2[DESC_TOTAL], 11) +  "Projecao de Resgate de Aplicacao "
                            aDados2[DESC_TOTAL] += SEH->(EH_TIPO + " - " + EH_BANCO)
                            aDados2[VL_ORIG] := If(MV_PAR02==1,SEH->EH_SALDO,SEH->EH_SALDO/&('SM2->M2_MOEDA'+cSuf))
                            aDados2[VL_REC]  := If(MV_PAR02==1,nValJuros,nValJuros/&('SM2->M2_MOEDA'+cSuf))
                            aDados2[VL_DIS]  := nDispon

                            IF ( MV_PAR02 != 1 .And. !lAchou )
                                dbSelectArea("SM2")
                                dbSetOrder(1)
                                dbSeek(dDataVenc)
                                aDados2[TAXA] := &('SM2->M2_MOEDA'+cSuf)
                            EndIf

                            HabiCel(.F.,oReport)
                            lBxFut := .T.
                            lImpDev := .T.
                            oSection2:PrintLine()
                            HabiCel(.T.,oReport)
                            aFill(aDados2,nil)
                        EndIf
                        lAchou:=.T.
                        nTotTitR	+= If(MV_PAR02==1,nValJuros,nValJuros/&('SM2->M2_MOEDA'+cSuf))

                        If dDataVenc < SEH->EH_DATA
                            dDataVenc := SEH->EH_DATA
                        EndIf
                    EndIf

                    dbSelectArea("SEH")
                    dbSkip()
                EndDo
            Endif

            dbSelectArea("SE2")
            If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                If lFirst
                    RetIndex("SE2")
                End
                SE2->(dbSetOrder(3))
                SE2->(dbSeek( cFilSE2 + DTOS(dDataVenc) ,.t.) )
            Else
                dbSetOrder( nIndexSE2 )
                SE2->(dbSeek(DTOS(dDataVenc)),.t.)
            End

            lAchou := .f.
            While !Eof() .And. E2_VENCREA == dDataVenc
                /*
                GESTAO - inicio */
                If nLenSelFil > 0
                    cFilTmp := AllTrim(SE2->E2_FILIAL)
                    nLenFil := Len(cFilTmp)
                    If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                        SE2->(DbSkip())
                        Loop
                    Endif
                Else
                    IF mv_par03 == 1 .and. E2_FILIAL != cFilSE2
                        Exit
                    EndIF
                    If mv_par03 == 2
                        If lGestao .and. Substring(E2_FILIAL,1,nTamEmp)!=Substring(cFilSE2,1,nTamEmp)
                            SE2->(dbSkip())
                            Loop
                        EndIf
                    EndIf
                Endif
                /* GESTAO - fim
                */
                If SE2->E2_SALDO == 0 .and. IIf(mv_par11==1,SE2->E2_BAIXA <= dDataBase,.t.)
                    SE2->(dbSkip())
                    Loop
                End

                If mv_par12 = 2
                    If SE2->E2_MOEDA != nMoeda
                        SE2->(dbSkip())
                        Loop
                    EndIf
                EndIf

                If SE2->E2_BAIXA > dDataBase .And. mv_par11 == 1
                    nSaldup  := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,mv_par02,SE2->E2_VENCREA,dDataBase,SE2->E2_LOJA,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))

                    // Calcula valores acessórios.
                    nSaldup  += SE2->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, /*lBaixados*/, /*cCodVa*/, "P", dDataBase, /*aValAces*/, E2_MOEDA, mv_par02, E2_TXMOEDA))
                Else
                    // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                    lTxMoeda := SM2->(MsSeek(SE2->E2_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                    nSaldup  := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))

                    // Calcula valores acessórios.
                    nSaldup  += SE2->(FValAcess(E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NATUREZ, /*lBaixados*/, /*cCodVa*/, "P", E2_VENCREA, /*aValAces*/, E2_MOEDA, mv_par02, E2_TXMOEDA))
                End

                IF mv_par13 == 2 .And. SE2->E2_TIPO $ MVABATIM
                    dbSkip()
                    Loop
                End
                If E2_TIPO $ MVPAGANT
                    dbSkip( )
                    Loop
                Endif

                IF SE2->E2_PREFIXO < mv_par09 .or. SE2->E2_PREFIXO > mv_par10  //Do Prefixo ao Prefixo
                    SE2->(dbSkip())
                    Loop
                EndIF

                If ! ( AllTrim(Str(SE2->E2_MOEDA,2)) $ mv_par08 )
                    dbSkip()
                    Loop
                End

                If SE2->E2_FLUXO == "N" .or. (SE2->E2_EMIS1 > dDataBase .and. mv_par14 == 2)
                    dbSkip()
                    Loop
                End

                dbSelectArea("SE2")
                If mv_par03 == 1 .And. nLenSelFil == 0		/* GESTAO */
                    dbSetOrder(3)
                Endif

                IF E2_TIPO $ MVABATIM+"/"+MV_CPNEG
                    nDispon+=nSalDup
                Else
                    nDispon-=nSalDup
                Endif

                //³Verifica se existe cheque sobre titulo e busca no  ³
                //³SEF para verificar se cheque esta liberado para    ³
                //³imprimir ou nao o titulo.                          ³
                If SE2->E2_IMPCHEQ == "S" .And. lLibCheq
                    aAreaSE2 := GetArea()
                    dbSelectArea("SEF")
                    SEF->(dbSetOrder(3))
                    SEF->(MsSeek(xFilial("SEF")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))
                    While SEF->(!Eof()) .And. lChqLiber .And.;
                            SEF->(EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO) ==;
                            xFilial("SEF")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)

                        If nLenSelFil > 0
                            cFilTmp := AllTrim(SEF->EF_FILIAL)
                            nLenFil := Len(cFilTmp)
                            If Ascan(aSelFil, {|afil| cFilTmp == Substring(afil,1,nLenFil)}) == 0
                                SEF ->(dbSkip())
                                Loop
                            Endif
                        ElseIf mv_par03 == 2
                            If lGestao .and. Substring(EF_FILIAL,1,nTamEmp)!=Substring(xFilial("SEF"),1,nTamEmp)
                                SEF->(dbSkip())
                                Loop
                            Endif
                        Endif

                        If SEF->EF_ORIGEM = "FINA390TIT" .And. SEF->EF_LIBER == "S"
                            lChqLiber := .F.
                        EndIf
                        SEF->(dbSkip())
                    EndDo
                    RestArea(aAreaSE2)
                    If !lChqLiber
                        SE2->(dbSkip())
                        Loop
                    EndIf
                EndIf

                IF !lAchou
                    aDados2[DT_VENC] := SE2->E2_VENCREA
                EndIF

                aDados2[PREFIXO]    := SE2->E2_PREFIXO
                aDados2[TITUL]      := SE2->E2_NUM+(IIF(!EMPTY(SE2->E2_PARCELA),"-",""))+SE2->E2_PARCELA
                aDados2[TIPO]       := SE2->E2_TIPO
                aDados2[EMISSAO]    := SE2->E2_EMISSAO
                aDados2[FORNEC]     := SE2->E2_FORNECE
                aDados2[NOM_FORNEC] := SubStr(SE2->E2_NOMFOR,1,25)
                aDados2[HISTORICO]  := SubStr(SE2->E2_HIST,1,25)

                nAbatim := 0
                If mv_par13 == 2

                    //Quando considerar Titulos com emissao futura, eh necessario
                    //colocar-se a database para o futuro de forma que a Somaabat()
                    //considere os titulos de abatimento
                    If mv_par14 == 1
                        dOldData := dDataBase
                        dDataBase := CTOD("31/12/40")
                    Endif

                    nAbatim := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",mv_par02,,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_FILIAL)

                    If mv_par14 == 1
                        dDataBase := dOldData
                    Endif

                Endif
                nSaldup -= nAbatim
                nDispon -= nAbatim
                If cPaisLoc <> "BRA" .And. (E2_TIPO $ MV_CPNEG	 .Or. ( SE2->E2_TIPO $ MVPAGANT .And. (!Empty(SE2->E2_ORDPAGO) .Or. cPaisLoc =="ARG")))
                    nVlrImp:= (SE2->E2_VALOR+SE2->E2_ACRESC-SE2->E2_DECRESC-nAbatim) * -1
                Else
                    nVlrImp:= (SE2->E2_VALOR+SE2->E2_ACRESC-SE2->E2_DECRESC-nAbatim)
                EndIf
                // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                lTxMoeda := SM2->(MsSeek(dDataVenc)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0

                aDados2[VL_ORIG] := xMoeda(nVlrImp,SE2->E2_MOEDA,mv_par02,If(lTxMoeda,dDataVenc,dDataBase),,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))
                IF cPaisLoc <> "BRA" .And. E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
                    aDados2[VL_PAG] := nSalDup * -1
                Else
                    aDados2[VL_PAG] := nSalDup
                Endif
                aDados2[VL_DIS] := nDispon

                IF mv_par02!=1 .and. !lAchou
                    dbSelectArea("SM2")
                    dbSeek(dDataVenc)
                    aDados2[TAXA] := &('SM2->M2_MOEDA'+cSuf)
                EndIF

                lBxFut := .T.
                lImpDev := .T.
                oSection2:PrintLine()
                aFill(aDados2,nil)

                lAchou:=.T.
                dbSelectArea("SE2")
                IF E2_TIPO $ MVABATIM+"/"+MV_CPNEG
                    nTotTitP -= nSalDup
                Else
                    nTotTitP += nSalDup
                End
                dbSkip()
            End

            If cIpProj =="S"

                //³Verifica se existe emprestimo a pagar no dia.					  ³
                dbSelectArea( "SEG" )
                If mv_par03 == 1 .And. nLenSelFil == 0
                    dbSetOrder(2)
                    dbSeek( cFilSEG + Dtos(dDataVenc) )
                Else
                    dbSetOrder( nIndexSEG )
                    dbSeek(Dtos(dDataVenc))
                Endif

                lAchou := .f.

                While !Eof() .And. EG_DATARES == dDataVenc
                    /*
                    GESTAO - inicio */
                    If nLenSelFil > 0
                        cFilTmp := AllTrim(SEG->EG_FILIAL)
                        nLenFil := Len(cFilTmp)
                        If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                            SEG->(DbSkip())
                            Loop
                        Endif
                    Else
                        IF mv_par03 == 1 .and. EG_FILIAL != cFilSEG
                            Exit
                        EndIf
                        If mv_par03 == 2
                            If lGestao .and. Substring(EG_FILIAL,1,nTamEmp)!=Substring(cFilSEG,1,nTamEmp)
                                SEG->(dbSkip())
                                Loop
                            EndIf
                        EndIf
                    Endif
                    /* GESTAO - fim
                    */
                    If SEG->EG_TIPO != "EMP"
                        dbSkip( )
                        Loop
                    EndIf

                    nDiasInt	:= EG_DATARES-EG_DATA	//Dias de Intervalo
                    nJurDiario:= EG_TAXA/nDiasInt	  //Juros Diario
                    nValJuros := EG_VALOR+((EG_VALOR*nJurDiario)/100)*nDiasInt
                    nValGanho := nValJuros-EG_VALOR
                    nValJuros -= nValGanho*EG_IMPOSTO/100 //Impostos
                    IF mv_par02 == 1
                        nDispon -= nValJuros
                    Else
                        dbSelectArea("SM2")
                        dbSeek( dDataVenc )
                        nDispon -= nValJuros/&('SM2->M2_MOEDA'+cSuf)
                    EndIF
                    dbSelectArea("SEG")

                    IF !lAchou
                        aDados2[DESC_TOTAL] := DtoC(EG_DATARES)
                    EndIF

                    aDados2[DESC_TOTAL] := PadR(aDados2[DESC_TOTAL], 11) + "Projecao de Pagamento de Emprestimo " + EG_TIPO + " - " + EG_BANCO 
                    aDados2[VL_ORIG]    := If(mv_par02==1,EG_VALOR,EG_VALOR/&( 'SM2->M2_MOEDA' +cSuf))
                    aDados2[VL_PAG]     := If(mv_par02==1,nValJuros,nValJuros/&( 'SM2->M2_MOEDA' +cSuf))
                    aDados2[VL_DIS]     := nDispon

                    IF mv_par02!=1 .and. !lAchou
                        dbSelectArea("SM2")
                        dbSeek(dDataVenc)
                        aDados2[TAXA] := &('SM2->M2_MOEDA'+cSuf)
                    EndIF

                    lAchou:=.T.

                    HabiCel(.F.,oReport)
                    lBxFut := .T.
                    lImpDev := .T.
                    oSection2:PrintLine()
                    HabiCel(.T.,oReport)
                    aFill(aDados2,nil)

                    dbSelectArea("SEG")
                    nTotTitP	+= IIF(mv_par02==1,nValJuros,nValJuros/ &('SM2->M2_MOEDA'+cSuf))
                    dbSkip()
                End

                //³Verifica se existe emprestimo a pagar no dia.					  ³
                dbSelectArea("SEH")
                If ( MV_PAR03 == 1 ) .And. nLenSelFil == 0		/* GESTAO */
                    dbSetOrder(2)
                    dbSeek(xFilial("SEH")+"A")
                Else
                    dbSetOrder( nIndexSEH )
                    dbSeek("A")
                Endif

                lAchou := .f.
                While ( !Eof() .And. If(MV_PAR03==1,SEH->EH_FILIAL==xFilial("SEH"), .T. ) .And.;
                        SEH->EH_STATUS=="A" )
                    /*
                    GESTAO - inicio */
                    If nLenSelFil > 0
                        cFilTmp := AllTrim(SEH->EH_FILIAL)
                        nLenFil := Len(cFilTmp)
                        If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                            SEH->(DbSkip())
                            Loop
                        Endif
                    Else
                        If mv_par03 == 2
                            If lGestao .and. Substring(EH_FILIAL,1,nTamEmp)!=Substring(cFilSEH,1,nTamEmp)
                                SEH->(dbSkip())
                                Loop
                            EndIf
                        EndIf
                    Endif
                    /* GESTAO - fim
                    */
                    If ( SEH->EH_APLEMP == "EMP" )
                        If ( Empty(SEH->EH_DATARES) .And. nY == 1 ) .Or. ( SEH->EH_DATARES == dDataVenc )
                            nValJuros := xMoeda(SEH->EH_SALDO,SEH->EH_MOEDA,1)
                            If mv_par02 == 1 //Controlo a operacao para moeda 1 e demais moedas (2~X)
                                nValJuros := xMoeda(SEH->EH_SALDO,SEH->EH_MOEDA,1)   //Moeda 1
                            Else
                                nValJuros := SEH->EH_SALDO                            //Demais moedas (2~X)
                            EndIf
                            aValAplic := Fa171Calc(dDataVenc,,,,,,,, mv_par03 = 1)
                            If Len(aValAplic) > 0
                                nValJuros += aValAplic[2,2]
                            Endif
                        Else
                            nValJuros := 0
                        EndIf
                        If ( nValJuros != 0 )
                            If ( MV_PAR02 == 1 )
                                nDispon -= (nValJuros)
                            Else
                                dbSelectArea("SM2")
                                dbSetOrder(1)
                                dbSeek( dDataVenc )
                                nDispon -= (nValJuros)
                            EndIf

                            IF !lAchou
                                aDados2[DESC_TOTAL] := If( !Empty(SEH->EH_DATARES) , DtoC(SEH->EH_DATARES),nil )
                            EndIf

                            If(SEH->EH_MOEDA > 1)
                                nValMoeda := &('SM2->M2_MOEDA' + cValToChar(SEH->EH_MOEDA))
                            Else
                                nValMoeda := 1
                            EndIf
                            aDados2[DESC_TOTAL] := PadR(aDados2[DESC_TOTAL], 11) + "Projecao de Pagamento de Emprestimo "+SEH->EH_TIPO+" - "+SEH->EH_BANCO 
                            aDados2[VL_ORIG]    := If(MV_PAR02==1,SEH->EH_SALDO*nValMoeda,If(SEH->EH_MOEDA > 1,SEH->EH_SALDO,SEH->EH_SALDO/&( 'SM2->M2_MOEDA' +cSuf)))
                            aDados2[VL_PAG]     := If(MV_PAR02==1,nValJuros,If(SEH->EH_MOEDA > 1,nValJuros,nValJuros/&( 'SM2->M2_MOEDA' +cSuf)))
                            aDados2[VL_DIS]     := nDispon

                            If ( MV_PAR02!=1 .And. !lAchou )
                                dbSelectArea("SM2")
                                dbSetOrder(1)
                                dbSeek(dDataVenc)
                                aDados2[TAXA] := &('SM2->M2_MOEDA'+cSuf)
                            EndIf

                            HabiCel(.F.,oReport)
                            lBxFut := .T.
                            lImpDev := .T.
                            oSection2:PrintLine()
                            HabiCel(.T.,oReport)
                            aFill(aDados2,nil)
                        EndIf

                        lAchou:=.T.

                        nTotTitP	+= If(MV_PAR02==1,nValJuros,If(SEH->EH_MOEDA > 1,nValJuros,nValJuros/&('SM2->M2_MOEDA'+cSuf)))

                        If dDataVenc < SEH->EH_DATA
                            dDataVenc := SEH->EH_DATA
                        EndIf
                    EndIf
                    dbSelectArea("SEH")
                    dbSkip()
                EndDo
            Endif

            // Imprime os pedidos de venda.
            If Len(aVendas) > 0
                nEl := Ascan(aVendas, {|e| e[1] == dDataVenc})
                IF nEl > 0
                    If nImprPV == 1  // Sintético.
                        nX := 0
                        nValor := 0
                        Do While nEl <= Len(aVendas) .And. aVendas[nEl, 1] == dDataVenc
                            nValor += aVendas[nEl, 2]
                            nEl++
                            nX++
                        EndDo

                        nDispon += nValor
                        aDados2[DT_VENC]    := DtoC(dDataVenc)
                        aDados2[DESC_TOTAL] :=  "Pedidos de Vendas" + " - " + cValToChar(nX) + " " +  "pedido(s)"
                        aDados2[VL_REC]     := nValor
                        aDados2[VL_DIS]     := nDispon

                        IF mv_par02 != 1
                            dbSelectArea("SM2")
                            Seek dDataVenc
                            aDados2[TAXA] := &('SM2->M2_MOEDA' + cSuf)
                        EndIF

                        lBxFut := .T.
                        lImpDev := .T.
                        HabiCel(.F.,oReport)
                        oSection2:PrintLine()
                        HabiCel(.T.,oReport)
                        aFill(aDados2, nil)
                        nTotTitR += nValor
                    Else
                        Do While nEl <= Len(aVendas) .And. aVendas[nEl, 1] == dDataVenc

                            aDados2[DT_VENC] := DtoC(dDataVenc)
                            aDados2[TITUL]   := If(Len(aSelFil) > 1, aVendas[nEl, 6] + " - ", "") + aVendas[nEl, 5]
                            aDados2[TIPO]    :=  "PV"

                            SC5->(dbSetOrder(1))  // C5_FILIAL, C5_NUM.
                            If SC5->(dbSeek(aVendas[nEl, 6] + aVendas[nEl, 5], .F.))
                                aDados2[EMISSAO] := SC5->C5_EMISSAO
                                aDados2[FORNEC]  := SC5->C5_CLIENTE
                                aDados2[LOJA]    := SC5->C5_LOJACLI
                                If SC5->C5_TIPO $ "DB"
                                    SA2->(dbSetOrder(1))  // A2_FILIAL, A2_COD, A2_LOJA.
                                    If SA2->(msSeek(xFilial() + SC5->(C5_CLIENTE + C5_LOJACLI), .F.))
                                        aDados2[NOM_FORNEC] := AllTrim(SA2->A2_NOME)
                                    Endif
                                Else
                                    SA1->(dbSetOrder(1))  // A1_FILIAL, A1_COD, A1_LOJA.
                                    If SA1->(msSeek(xFilial() + SC5->(C5_CLIENTE + C5_LOJACLI), .F.))
                                        aDados2[NOM_FORNEC] := AllTrim(SA1->A1_NOME)
                                    Endif
                                Endif
                            Endif

                            nValor := aVendas[nEl, 2]
                            nDispon += nValor
                            aDados2[VL_REC] := nValor
                            aDados2[VL_DIS] := nDispon

                            IF mv_par02 != 1
                                dbSelectArea("SM2")
                                Seek dDataVenc
                                aDados2[TAXA] := &('SM2->M2_MOEDA' + cSuf)
                            EndIF

                            lBxFut := .T.
                            lImpDev := .T.
                            oSection2:PrintLine()
                            aFill(aDados2, nil)
                            nTotTitR += nValor

                            nEl++
                        EndDo
                    Endif
                EndIF
            EndIF

            // Imprime os pedidos de compra.
            IF Len(aCompras) > 0
                nEl := Ascan(aCompras, {|e| e[1] == dDataVenc})
                IF nEl > 0
                    If nImprPC == 1  // Sintético.
                        nX := 0
                        nValor := 0
                        Do While nEl <= Len(aCompras) .And. aCompras[nEl, 1] == dDataVenc
                            nValor += aCompras[nEl, 2]
                            nEl++
                            nX++
                        EndDo

                        nDispon -= nValor
                        aDados2[DT_VENC]    := DtoC(dDataVenc)
                        aDados2[DESC_TOTAL] := "Pedidos de Compras"  + " - " + cValToChar(nX) + " " +  "pedido(s)"
                        aDados2[VL_PAG]     := nValor
                        aDados2[VL_DIS]     := nDispon

                        IF mv_par02 != 1
                            dbSelectArea("SM2")
                            Seek dDataVenc
                            aDados2[TAXA] := &('SM2->M2_MOEDA' + cSuf)
                        EndIF

                        lBxFut := .T.
                        lImpDev := .T.
                        HabiCel(.F.,oReport)
                        oSection2:PrintLine()
                        HabiCel(.T.,oReport)
                        aFill(aDados2, nil)
                        nTotTitP += nValor
                    Else
                        Do While nEl <= Len(aCompras) .And. aCompras[nEl, 1] == dDataVenc

                            aDados2[DT_VENC] := DtoC(dDataVenc)
                            aDados2[TITUL]   := If(Len(aSelFil) > 1, aCompras[nEl, 6] + " - ", "") + aCompras[nEl, 5]
                            aDados2[TIPO]    :=  "PC"

                            SC7->(dbSetOrder(1))  // C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN.
                            If SC7->(dbSeek(aCompras[nEl, 6] + aCompras[nEl, 5], .F.))
                                aDados2[EMISSAO] := SC7->C7_EMISSAO
                                aDados2[FORNEC]  := SC7->C7_FORNECE
                                aDados2[LOJA]    := SC7->C7_LOJA
                                SA2->(dbSetOrder(1))  // A2_FILIAL, A2_COD, A2_LOJA.
                                If SA2->(msSeek(xFilial() + SC7->(C7_FORNECE + C7_LOJA), .F.))
                                    aDados2[NOM_FORNEC] := AllTrim(SA2->A2_NOME)
                                Endif
                            Endif

                            nValor := aCompras[nEl, 2]
                            nDispon -= nValor
                            aDados2[VL_PAG] := nValor
                            aDados2[VL_DIS] := nDispon

                            IF mv_par02 != 1
                                dbSelectArea("SM2")
                                Seek dDataVenc
                                aDados2[TAXA] := &('SM2->M2_MOEDA' + cSuf)
                            EndIF

                            lBxFut := .T.
                            lImpDev := .T.
                            oSection2:PrintLine()
                            aFill(aDados2, nil)
                            nTotTitP += nValor

                            nEl++
                        EndDo
                    Endif
                EndIF
            EndIF

            //--------------------------------------------------------------
            // Solicitacoes de Fundo
            //--------------------------------------------------------------
            If lSolFund

                DbSelectArea("SA2")

                DbSelectArea("FJA")
                If MV_PAR03 == 1 .And. nLenSelFil == 0		//Imprime por - Filial		/* GESTAO */
                    FJA->(DbSetOrder(5)) //FJA_FILIAL+FJA_DATAPR
                    FJA->(DbSeek( cFilFJA + DToS(dDataVenc)) )
                Else //Imprime por - Empresa
                    DbSetOrder(nIndexFJA)
                    DbSeek(DToS(dDataVenc))
                Endif

                lAchou :=.F.
                While FJA->(!Eof()) .And. FJA_DATAPR == dDataVenc
                    /*
                    GESTAO - inicio */
                    If nLenSelFil > 0
                        cFilTmp := AllTrim(FJA->FJA_FILIAL)
                        nLenFil := Len(cFilTmp)
                        If Ascan(aSelFil,{|afil| cFilTmp == Substr(afil,1,nLenFil)}) == 0
                            FJA->(DbSkip())
                            Loop
                        Endif
                    Else
                        If MV_PAR03 == 1 .And. FJA_FILIAL != cFilFJA
                            Exit
                        EndIf
                        If mv_par03 == 2
                            If lGestao .and. Substring(FJA_FILIAL,1,nTamEmp)!=Substring(cFilFJA,1,nTamEmp)
                                FJA->(dbSkip())
                                Loop
                            EndIf
                        EndIf
                    Endif
                    /* GESTAO - fim
                    */
                    // Solicitacoes de fundo Pendentes ou Aprovadas sem OP associada
                    If ( FJA->FJA_ESTADO <> "1" .AND. FJA->FJA_ESTADO <> "2" )
                        DbSkip()
                        Loop
                    EndIf

                    nDispon -= XMoeda(FJA->FJA_VALOR,Val(FJA->FJA_MOEDA),MV_PAR02,dDataVenc)

                    If !lAchou .And. MV_PAR02 != 1 //Moeda
                        DbSelectArea("SM2")
                        DbSeek(dDataVenc)
                        aDados2[TAXA] := &('SM2->M2_MOEDA'+cSuf)
                    EndIf

                    If !lAchou
                        aDados2[DT_VENC] := FJA->FJA_DATAPR
                    EndIf

                    aDados2[PREFIXO]	:= ""
                    aDados2[TITUL]		:= FJA->FJA_SOLFUN
                    aDados2[EMISSAO]	:= FJA->FJA_DATA
                    aDados2[FORNEC]		:= FJA->FJA_FORNEC
                    aDados2[NOM_FORNEC]	:= SubStr(GetAdvFVal("SA2","A2_NOME",xFilial("SA2")+FJA->(FJA_FORNEC+FJA_LOJA),1,"",.T.),1,25)
                    aDados2[HISTORICO]	:= SubStr(FJA->FJA_OBSERV,1,25)
                    aDados2[VL_ORIG]	:= XMoeda(FJA->FJA_VALOR,Val(FJA->FJA_MOEDA),MV_PAR02,dDataVenc)
                    aDados2[VL_PAG]		:= XMoeda(FJA->FJA_VALOR,Val(FJA->FJA_MOEDA),MV_PAR02,dDataVenc)
                    aDados2[VL_DIS]		:= nDispon

                    lBxFut := .T.
                    lImpDev := .T.
                    oSection2:PrintLine()

                    aFill(aDados2,Nil)

                    lAchou := .T.

                    //----------------------------------------------
                    // Adiciona o valor no total de titulos a pagar
                    //----------------------------------------------
                    nTotTitP += XMoeda(FJA->FJA_VALOR,Val(FJA->FJA_MOEDA),MV_PAR02,dDataVenc)

                    FJA->(DbSkip())
                EndDo
            EndIf

            //------------------------
            // Imprime o total do dia
            //------------------------
            If nTotTitR !=0 .or. nTotTitP != 0
                oReport:SkipLine()
                aDados2[DESC_TOTAL] := "Total Do Dia ---> "+ DtoC(dDataVenc)  
                aDados2[VL_PAG]     := nTotTitP
                aDados2[VL_REC]     := nTotTitR
                aDados2[VL_DIS]     := nDispon
                lBxFut := .T.
                lImpDev := .T.
                HabiCel(.F.,oReport)
                oSection2:PrintLine()
                HabiCel(.T.,oReport)
                aFill(aDados2,nil)
                oReport:SkipLine()
                nTotGTitR += nTotTitR
                nTotGTitP += nTotTitP
                nTotTitP := 0
                nTotTitR := 0
            Endif
        Next nY

        oReport:SkipLine()
        aDados2[DESC_TOTAL] := "Total Geral  --->"
        aDados2[VL_PAG]     := nTotGTitP+nApagVenc
        aDados2[VL_REC]     := nTotGTitR+nTotFutR+nArecVenc
        aDados2[VL_DIS]     := nDispon

        HabiCel(.F.,oReport)
        lBxFut := .T.
        lImpDev := .T.
        oSection2:PrintLine()
        HabiCel(.T.,oReport)
        aFill(aDados2,nil)

        oSection2:Finish()
    EndIf

    /*
    GESTAO - inicio */
    If !Empty(aTmpFil)
        For nX := 1 To Len(aTmpFil)
            CtbTmpErase(aTmpFil[nX])
        Next
    Endif
    /* GESTAO - fim
    */

    // Contas a receber
    RetIndex("SE1")
    dbSelectArea("SE1")
    SE1->(dbSetOrder(1))
    SE1->(dbClearFilter())

    // Contas a pagar
    RetIndex("SE2")
    dbSelectArea("SE2")
    SE2->(dbSetOrder(1))
    SE2->(dbClearFilter())

    // Comissao de vendas
    RetIndex("SE3")
    dbSelectArea("SE3")
    SE3->(dbSetOrder(1))
    SE3->(dbClearFilter())

    // Movimentacao bancaria
    RetIndex("SE5")
    dbSelectArea("SE5")
    SE5->(dbSetOrder(1))
    SE5->(dbClearFilter())

    // Contas Corrente
    RetIndex("SA6")
    dbSelectArea("SA6")
    SA6->(dbSetOrder(1))
    SA6->(dbClearFilter())

    // Saldos bancarios
    RetIndex("SE8")
    dbSelectArea("SE8")
    SE8->(dbSetOrder(1))
    SE8->(dbClearFilter())

    // Controle de aplicacoes
    RetIndex("SEG")
    dbSelectArea("SEG")
    SEG->(dbSetOrder(1))
    SEG->(dbClearFilter())

    RetIndex("SEH")
    dbSelectArea("SEH")
    SEH->(dbSetOrder(1))
    SEH->(dbClearFilter())

    Ferase(cArqSEH+OrdBagExt())
    Ferase(cArqSEG+OrdBagExt())
    Ferase(cArqSE5+OrdBagExt())
    Ferase(cArqSE2+OrdBagExt())
    Ferase(cArqSE1+OrdBagExt())
    Ferase(cArqSE3+OrdBagExt())
    Ferase(cArqSE8+OrdBagExt())
    Ferase(cArqSA6+OrdBagExt())

Return

/*/{Protheus.doc} HabiCel
habilita ou desabilita celulas para imprimir totais.
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 05/10/2021
@param lHabilit, logical, Indica se habiliata ou esabilita celulas
@param oReport, object, Objeto do relatorio
@return Character, sem retorno definido
/*/
Static Function HabiCel(lHabilit, oReport)

    Local oSection2 := oReport:Section(2)

    If Empty(MV_PAR20)
        If lHabilit
            oSection2:Cell("TOTAL"):Disable()
            oSection2:Cell("TOTAL2"):Disable()
            oSection2:Cell("E2_NOMFOR"):Enable()
            oSection2:Cell("E2_HIST"):Enable()
        Else
            oSection2:Cell("TOTAL"):Enable()
            oSection2:Cell("TOTAL2"):Enable()
            oSection2:Cell("E2_NOMFOR"):Disable()
            oSection2:Cell("E2_HIST"):Disable()
        EndIf
    Endif

Return

/*/{Protheus.doc} FRVisaoGer
Funcao que montara o arquivo temporario para impressao  do relatorio com visao gerencial financeira
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 05/10/2021
@param nDispon, numeric, numero de dias para disposição
@param cArqTmp, character, Nome arquivo temporario
@param oReport, object,Obejto do relatorio
@param nMoeda, numeric,Numero da moeda
@param nDecs, numeric, Numero de Decimais
@return character, sem retorno definido
/*/

Static Function FRVisaoGer(nDispon,cArqTmp, oReport, nMoeda,nDecs)

    Local dDataAnt
    Local dDataAte
    Local aCampos		:= {		{"CODDESC   ","C",30 ,0},;
        {"RECEBIDOS ","N",17,2},;
        {"PAGOS     ","N",17,2},;
        {"DISPON","N",17,2},;
        {"DATAAN","D",8,0},;
        {"ORDEM","C",17,0}}

    //Local nMoedaBco	:=	1
    Local cQueryVis
    Local cQuerySE1
    Local cSuperior
    Local cIdenti
    Local nCont
    Local nTotRec	:= 0
    Local nTotPago  := 0
    Local nTotDisp	:= 0
    Local cData
    Local nRec
    Local cRecPagAntSE1

    //Local cFilSA6   := xFilial("SA6")
    //Local cFilSE5   := xFilial("SE5")
    Local cFilSE2   := xFilial("SE2")
    Local cFilSE1   := xFilial("SE1")
    //Local cFilSEG   := xFilial("SEG")
    //Local cFilFJA   := xFilial("FJA")
    Local nTamEmp 	:= Len(FwCodEmp())
    Local cListDesc := FN022LSTCB(2)	//Obtem a lista de situacos de cobrancas Descontadas

    Local cTable     := ""
    Local nProcQry   := 0
    Local cInsert    := ""
    Local cColuna    := ""
    Local aEstruct   := {}
    Local nJ		 := 0
    Local lMvBr10925 := IIf(cPaisLoc == "BRA", GetMv("MV_BR10925")== "1", .F.)
    Local nTamFil    := TamSX3("FJ3_FILIAL")[1]
    Local nTamCodPla := TamSX3("FJ3_CODPLA")[1]
    Local nTamOrd    := TamSX3("FJ3_ORDEM")[1]
    Local nTamContag := TamSX3("FJ3_CONTAG")[1]
    Local nTamCtaSup := TamSX3("FJ3_CTASUP")[1]
    Local nTamDscCg  := TamSX3("FJ3_DESCCG")[1]
    Local nTamDetHcg := TamSX3("FJ3_DETHCG")[1]
    Local nTamNorm   := TamSX3("FJ3_NORMAL")[1]
    Local nTamCol    := TamSX3("FJ3_COLUNA")[1]
    Local nTamClas   := TamSX3("FJ3_CLASSE")[1]
    Local nTamIdent  := TamSX3("FJ3_IDENT")[1]
    Local nTamNome   := TamSX3("FJ3_NOME")[1]
    Local nTamLin    := TamSX3("FJ3_LINHA")[1]
    Local nTamSedIn  := TamSX3("FJ3_SEDINI")[1]
    Local nTamSedFm  := TamSX3("FJ3_SEDFIM")[1]
    Local nTamForm   := TamSX3("FJ3_FORMUL")[1]
    Local nTamTvsIs  := TamSX3("FJ3_TOTVIS")[1]
    Local nTamVisEnt := TamSX3("FJ3_VISENT")[1]
    Local nTamSldEnt := TamSX3("FJ3_SLDENT")[1]
    Local nTamFatSld := TamSX3("FJ3_FATSLD")[1]

    //³ Cria o arquivo tempor rio das movimentacoes.  ³
    If _oFINR1401 <> Nil
        _oFINR1401:Delete()
        _oFINR1401 := Nil
    Endif

    _oFINR1401 := FWTemporaryTable():New( "cArqTmp" )
    _oFINR1401:SetFields(aCampos)
    _oFINR1401:AddIndex("1", {"DATAAN"})
    _oFINR1401:Create()

    dbSetOrder(1)

    dDataAnt := dDataBase
    dDataAte := dDataBase + MV_PAR01 //Data final

    //³Query para buscar a visão gerencial escolhida no parametro³
    cQueryVis := " SELECT 0 as FJ3_REC, 0 AS FJ3_PAGO, 0 AS FJ3_DISP,FJ3.FJ3_FILIAL,FJ3.FJ3_CODPLA,FJ3.FJ3_ORDEM,FJ3.FJ3_CONTAG,FJ3.FJ3_CTASUP,"
    cQueryVis += " FJ3.FJ3_DESCCG,FJ3.FJ3_DETHCG,FJ3.FJ3_NORMAL,FJ3.FJ3_COLUNA,FJ3.FJ3_CLASSE,FJ3.FJ3_IDENT,FJ3.FJ3_NOME,FJ3.FJ3_LINHA,"
    cQueryVis += " FJ3.FJ3_SEDINI,FJ3.FJ3_SEDFIM,FJ3.FJ3_FORMUL,FJ3.FJ3_TOTVIS,FJ3.FJ3_VISENT,FJ3.FJ3_SLDENT,FJ3.FJ3_FATSLD"
    cQueryVis += " FROM " + RetSqlName("FJ3") + " FJ3 "
    cQueryVis += " WHERE FJ3_CODPLA = '" + MV_PAR20 + "' "
    cQueryVis += " AND FJ3.D_E_L_E_T_ = ' ' "

    //cQueryVis := ChangeQuery(cQueryVis)

    //Define as colunas e suas propriedades para criar a tabela temporaria TRB4
    AADD(aEstruct,{"FJ3_REC"   ,"N",17,2})
    AADD(aEstruct,{"FJ3_PAGO"  ,"N",17,2})
    AADD(aEstruct,{"FJ3_DISP"  ,"N",17,2})
    AADD(aEstruct,{"FJ3_FILIAL","C",nTamFil,0})
    AADD(aEstruct,{"FJ3_CODPLA","C",nTamCodPla,0})
    AADD(aEstruct,{"FJ3_ORDEM" ,"C",nTamOrd,0})
    AADD(aEstruct,{"FJ3_CONTAG","C",nTamContag,0})
    AADD(aEstruct,{"FJ3_CTASUP","C",nTamCtaSup,0})
    AADD(aEstruct,{"FJ3_DESCCG","C",nTamDscCg,0})
    AADD(aEstruct,{"FJ3_DETHCG","C",nTamDetHcg,0})
    AADD(aEstruct,{"FJ3_NORMAL","C",nTamNorm,0})
    AADD(aEstruct,{"FJ3_COLUNA","N",nTamCol,0})
    AADD(aEstruct,{"FJ3_CLASSE","C",nTamClas,0})
    AADD(aEstruct,{"FJ3_IDENT" ,"C",nTamIdent,0})
    AADD(aEstruct,{"FJ3_NOME"  ,"C",nTamNome,0})
    AADD(aEstruct,{"FJ3_LINHA" ,"C",nTamLin,0})
    AADD(aEstruct,{"FJ3_SEDINI","C",nTamSedIn,0})
    AADD(aEstruct,{"FJ3_SEDFIM","C",nTamSedFm,0})
    AADD(aEstruct,{"FJ3_FORMUL","C",nTamForm,0})
    AADD(aEstruct,{"FJ3_TOTVIS","C",nTamTvsIs,0})
    AADD(aEstruct,{"FJ3_VISENT","C",nTamVisEnt,0})
    AADD(aEstruct,{"FJ3_SLDENT","C",nTamSldEnt,0})
    AADD(aEstruct,{"FJ3_FATSLD","C",nTamFatSld,0})

    //Armazena colunas para utilizar no insert de dados na tabela temporaria TRB4
    for nJ := 1 to Len( aEstruct )
        cColuna += IIF(nJ>1,","+aEstruct[nJ][1],aEstruct[nJ][1])
    next nJ

    //----------------------------
    //Criação da tabela temporaria
    //----------------------------
    If _oFINR1402 <> Nil
        _oFINR1402:Delete()
        _oFINR1402 := Nil
    Endif

    _oFINR1402 := FWTemporaryTable():New( "TRB4" )
    _oFINR1402:SetFields(aEstruct)

    //Adiciono o índice da tabela temporária
    _oFINR1402:AddIndex("1",{"FJ3_CODPLA","FJ3_ORDEM"})

    _oFINR1402:Create()

    //Obtenho o nome físico da tabela temporária no banco de dados
    cTable := _oFINR1402:GetRealName()

    cInsert := " INSERT "
    If AllTrim(TcGetDb()) == "ORACLE"
        cInsert += " /*+ APPEND */ "
    EndIf

    If AllTrim(TcGetDb()) == "DB2"
        cQueryVis := STRTRAN( cQueryVis, "FOR READ ONLY", "" )
    EndIf

    cInsert += " INTO " + cTable + " ("+cColuna+" ) " + cQueryVis

    //Executo o comando para alimentar a tabela temporária
    Processa({|| nProcQry := TcSQLExec(cInsert)})

    If nProcQry != 0
        UserException( TCSqlError() )
    EndIf

    dbSelectArea("TRB4")
    TRB4->(dbGoTop())

    If (mv_par06 == 1)	 // Considera titulos em atraso

        //³Query da SE2³
        cOrdSE2 := SqlOrder(SE2->(Indexkey()))
        cRecPagAnt := FormatIn( MVPAGANT, "/" )
        aStru := SE2->(DbStruct())
        cQuery := ""
        aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
        cQuery := "SELECT  " +SubStr(cQuery,2) + ", R_E_C_N_O_ RECNOSE2 "
        cQuery += " FROM " + RetSqlName("SE2")
        If mv_par03 == 1
            cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "'"
        Else
            If lGestao
                If UPPER(AllTrim(TcGetDb())) $ "DB2|ORACLE"
                    cQuery += " WHERE SUBSTR(E2_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE2"), 1, nTamEmp)+"'"
                Else
                    cQuery += " WHERE SUBSTRING(E2_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE2"), 1, nTamEmp)+"'"
                EndIf
            Else
                cQuery += " WHERE E2_FILIAL between ' ' AND 'zz'"
            EndIf
        Endif
        cQuery += " AND E2_PREFIXO between '" + mv_par09 + "' AND '"+mv_par10 + "'"
        cQuery += " AND E2_MOEDA IN " + StrTran(FormatIn(AllTrim('0' + mv_par08),,1),"'","")
        cQuery += " AND E2_VENCREA <= '" + Dtos(dDataBase-1) +"'"
        If cPaisLoc=="BRA"
            cQuery += " AND E2_TIPO NOT IN " + cRecPagAnt
        EndIf
        If mv_par11 == 2
            cQuery += " AND E2_SALDO > 0 "
        Endif
        If mv_par12 == 2
            cQuery += " AND E2_MOEDA = " + Str(nMoeda,2)
        Endif
        cQuery += " AND E2_FLUXO <> 'N'"
        //Considerar ou nao titulos com emissao posterior a database
        If mv_par14 == 2
            cQuery += " AND E2_EMISSAO <= '"+Dtos(dDataBase) +"'"
        Endif
        cQuery += " AND D_E_L_E_T_ = ' '"
        cQuery += " ORDER BY " + cOrdSE2

        //cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB2",.T.,.T.)
        aEval(aStru, {|e| If(e[2]!= "C", TCSetField("TRB2", e[1], e[2],e[3],e[4]),Nil)})

        // Query da SE1
        cRecPagAntSE1 := FormatIn( MVRECANT + "/" + MVIRF, "/" )
        cOrdSE1 := SqlOrder(SE1->(Indexkey()))
        aStruSE1 := SE1->(DbStruct())
        cQuerySE1 := ""
        aEval(aStruSE1,{|x| cQuerySE1 += ","+AllTrim(x[1])})
        cQuerySE1 := "SELECT  " +SubStr(cQuerySE1,2) + ", R_E_C_N_O_ RECNOSE1 "
        cQuerySE1 += " FROM " + RetSqlName("SE1")
        If mv_par03 == 1
            cQuerySE1 += " WHERE E1_FILIAL = '" + xFilial("SE1") + "'"
        Else
            If lGestao
                If UPPER(AllTrim(TcGetDb())) $ "DB2|ORACLE"
                    cQuerySE1 += " WHERE SUBSTR(E1_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE1"), 1, nTamEmp)+"'"
                Else
                    cQuerySE1 += " WHERE SUBSTRING(E1_FILIAL, 1,"+Str(nTamEmp)+" )= '"+ Substring(xFilial("SE1"), 1, nTamEmp)+"'"
                EndIf
            Else
                cQuerySE1 += " WHERE E1_FILIAL between ' ' AND 'zz'"
            EndIf
        Endif
        cQuerySE1 += " AND E1_PREFIXO between '" + mv_par09 + "' AND '"+mv_par10 + "'"
        cQuerySE1 += " AND E1_MOEDA IN " + StrTran(FormatIn(AllTrim('0' + mv_par08),,1),"'","")
        cQuerySE1 += " AND (E1_VENCREA <= '" + Dtos(dDataBase-1) +"')"
        If  cPaisLoc=="BRA"
            cQuerySE1 += " AND E1_TIPO NOT IN " + cRecPagAntSE1
        EndIf
        cQuerySE1 += " AND E1_SITUACA NOT IN " + FormatIn(cListDesc,"|")		//SITCOB
        If mv_par11 == 2
            cQuerySE1 += " AND E1_SALDO > 0 "
        Endif
        If mv_par12 == 2
            cQuerySE1 += " AND E1_MOEDA = " + Str(nMoeda,2)
        Endif
        cQuerySE1 += " AND E1_FLUXO <> 'N'"
        If mv_par14 == 2  // Considerar ou nao titulos com emissao posterior a database
            cQuerySE1 += " AND E1_EMISSAO <= '"+Dtos(dDataBase) +"'"
        Endif
        cQuerySE1 += " AND D_E_L_E_T_ = ' '"
        cQuerySE1 += " ORDER BY " + cOrdSE1

        //cQuerySE1 := ChangeQuery(cQuerySE1)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySE1),"TRB3",.T.,.T.)
        aEval(aStruSE1, {|e| If(e[2]!= "C", TCSetField("TRB3", e[1], e[2],e[3],e[4]),Nil)})

        TRB4->(dbGoTop())

        TRB2->(dbGoTop())

        TRB3->(dbGoTop())

        //³Tratamento de recebidos, pagos e DISPON de Titulos vencidos   ³
        Do While (TRB4->(!EOF()))

            // Se for analitica -  busco por naturezas
            If (!Empty(TRB4->FJ3_SEDINI) .And. !Empty(TRB4->FJ3_SEDFIM))

                Do While (TRB2->(!EOF()))

                    nSaldo := 0

                    //Confere a natureza do registro SE5 E se a data eh a do dia processado
                    If ((AllTrim(TRB2->E2_NATUREZ) >= AllTrim(TRB4->FJ3_SEDINI) .And. AllTrim(TRB2->E2_NATUREZ) <= AllTrim(TRB4->FJ3_SEDFIM)) /*.And. TRB2->E2_VENCREA == dDataAnt*/)

                        //Descobrir qual o valor real do titulo
                        If mv_par11 == 1
                            nSaldo:=SaldoTit(TRB2->E2_PREFIXO,TRB2->E2_NUM,TRB2->E2_PARCELA,TRB2->E2_TIPO,TRB2->E2_NATUREZ,"P",TRB2->E2_FORNECE,mv_par02,TRB2->E2_VENCREA,dDataBase,TRB2->E2_LOJA,,If(cPaisLoc=="BRA",TRB2->E2_TXMOEDA,0), mv_par17)
                        Else
                            // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                            lTxMoeda := SM2->(MsSeek(TRB2->E2_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                            nSaldo:=xMoeda((TRB2->E2_SALDO+TRB2->E2_SDACRES-TRB2->E2_SDDECRE),TRB2->E2_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",TRB2->E2_TXMOEDA,0))
                        EndIf

                        //Soma na propria linha da Entidade o valor correto do titulo
                        If cPaisLoc<>"BRA"
                            If TRB2->E2_TIPO $ MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM+"/"+MVRECANT+"/"+MVPAGANT
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_PAGO -= nSaldo
                                TRB4->(MsUnLock())
                            Else
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_PAGO += nSaldo
                                TRB4->(MsUnLock())
                            Endif
                        Else

                            If TRB2->E2_TIPO $ MVABATIM .or. TRB2->E2_TIPO $ MV_CPNEG
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_PAGO -= nSaldo
                                TRB4->(MsUnLock())
                            Else
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_PAGO += nSaldo
                                TRB4->(MsUnLock())
                            Endif
                        EndIf

                        cSuperior := TRB4->FJ3_CTASUP // Conta Superior
                        cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
                        nCont     := TRB4->(Recno())

                        //Procurar nas superiores e somar ou subtrair
                        Do While (!Empty(cSuperior))

                            //Somar ou Subtrair conforme campo FJ3_IDENTI
                            If (cSuperior == TRB4->FJ3_CONTAG)
                                If (cIdenti == '1')
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_PAGO += nSaldo
                                    TRB4->(MsUnLock())
                                Else
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_PAGO -= nSaldo
                                    TRB4->(MsUnLock())
                                EndIf
                            EndIf

                            cSuperior := TRB4->FJ3_CTASUP
                            TRB4->(dbSkip(-1))
                        EndDo

                        TRB4->(dbGoto(nCont))// Posiciona no ultimo registro
                    EndIf

                    TRB2->(dbSkip())
                EndDo

                //Contas a receber
                Do While (TRB3->(!EOF()))

                    nSaldo := 0

                    //Confere a natureza do registro SE5 E se a data eh a do dia processado
                    If ((AllTrim(TRB3->E1_NATUREZ) >= AllTrim(TRB4->FJ3_SEDINI) .And. AllTrim(TRB3->E1_NATUREZ) <= AllTrim(TRB4->FJ3_SEDFIM)))

                        If mv_par11 == 1
                            nSaldo := SaldoTit(TRB3->E1_PREFIXO,TRB3->E1_NUM,TRB3->E1_PARCELA,TRB3->E1_TIPO,TRB3->E1_NATUREZ,"R",TRB3->E1_CLIENTE,mv_par02,TRB3->E1_VENCREA,dDataBase,TRB3->E1_LOJA,,If(cPaisLoc=="BRA",TRB3->E1_TXMOEDA,0), mv_par17)

                            IF cPaisLoc == "BRA" .And. lMvBr10925 .and. TRB3->E1_TIPO $ "PIS|COF|CSL" .and. TRB3->E1_BAIXA <= dDatabase // Quando o parametro MV_BR10925 estiver igual a 1 - Baixa
                                nSaldo -= TRB3->E1_VALOR
                            Endif

                            IF TRB3->E1_TIPO $ MVABATIM .AND. TRB3->E1_BAIXA <= dDatabase  //Quando se trata de impostos (abatimento) o saldotit não funciona corretamente por nao tratar tais movimentos de baixa.
                                nSaldo -= TRB3->E1_VALOR
                            Endif

                            IF TRB3->(E1_PIS+E1_CSLL+E1_COFINS) > 0 .AND. mv_par13 == 1 // Reteve impostos
                                nSaldo -= SomaAbat(TRB3->E1_PREFIXO,TRB3->E1_NUM,TRB3->E1_PARCELA,"R",mv_par02,,TRB3->E1_CLIENTE,TRB3->E1_LOJA,TRB3->E1_FILIAL,TRB3->E1_EMISSAO)
                            Endif

                        Else
                            // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                            lTxMoeda := SM2->(MsSeek(TRB3->E1_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                            nSaldo   := xMoeda((TRB3->E1_SALDO+TRB3->E1_SDACRES-TRB3->E1_SDDECRE),TRB3->E1_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",TRB3->E1_TXMOEDA,0))

                            IF TRB3->(E1_PIS+E1_CSLL+E1_COFINS) > 0 .AND. mv_par13 == 1 // Reteve impostos
                                nSaldo -= SomaAbat(TRB3->E1_PREFIXO,TRB3->E1_NUM,TRB3->E1_PARCELA,"R",mv_par02,,TRB3->E1_CLIENTE,TRB3->E1_LOJA,TRB3->E1_FILIAL,TRB3->E1_EMISSAO)
                            Endif
                        Endif

                        // Se titulo do Template GEM
                        If HasTemplate("LOT")  .And. !Empty(SE1->E1_NCONTR)
                            If SE1->E1_VALOR == SE1->E1_SALDO .Or.;
                                    SE1->E1_VALOR == nSaldo //o titulo pode estar quitado(e1_saldo=0) mas valor em datas retroativas nao, portanto devera somar o valor do gem
                                nSaldo += CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
                            EndIf
                        EndIf

                        If TRB3->E1_SALDO > 0
                            If cPaisLoc<>"BRA"
                                IF Alltrim(TRB3->E1_TIPO) $  MV_CRNEG+"/"+MV_CPNEG+"/"+MVIRABT+"/"+MVCSABT+"/"+MVCFABT+"/"+MVPIABT+"/"+MVABATIM+"/"+MVRECANT+"/"+MVPAGANT
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_REC -= nSaldo
                                    TRB4->(MsUnLock())
                                Else
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_REC += nSaldo
                                    TRB4->(MsUnLock())
                                EndIf
                            Else
                                IF TRB3->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_REC -= nSaldo
                                    TRB4->(MsUnLock())
                                Else
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_REC += nSaldo
                                    TRB4->(MsUnLock())
                                EndIf
                            EndIf
                        Endif

                        cSuperior := TRB4->FJ3_CTASUP // Conta Superior
                        cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
                        nCont     := TRB4->(Recno())

                        //Procurar nas superiores e somar ou subtrair
                        Do While (!Empty(cSuperior))

                            //Somar ou Subtrair conforme campo FJ3_IDENTI
                            If (cSuperior == TRB4->FJ3_CONTAG)
                                If (cIdenti == '1')
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_REC += nSaldo
                                    TRB4->(MsUnLock())
                                Else
                                    RecLock("TRB4",.F.)
                                    TRB4->FJ3_REC -= nSaldo
                                    TRB4->(MsUnLock())
                                EndIf
                            EndIf

                            cSuperior := TRB4->FJ3_CTASUP
                            TRB4->(dbSkip(-1))
                        EndDo

                        TRB4->(dbGoto(nCont))// Posiciona no ultimo registro
                    EndIf

                    TRB3->(dbSkip())
                EndDo
            EndIf

            TRB4->(dbSkip())

            If !(TRB4->(EOF()))
                If (TRB2->(EOF()))
                    TRB2->(dbGoTop()) //Inicia o arquivo de SE2 novamente pois o arquivo de visao nao esta no fim
                EndIf

                If (TRB3->(EOF()))
                    TRB3->(dbGoTop()) //Inicia o arquivo de SE1 novamente pois o arquivo de visao nao esta no fim
                EndIf
            EndIf
        EndDo

        dbSelectArea("TRB4")
        TRB4->(dbGoTop())

        //Calcular o DISPON de todas as contas (Recebido - Pago)
        Do While (TRB4->(!EOF()))

            RecLock("TRB4",.F.)
            TRB4->FJ3_DISP = TRB4->FJ3_REC - TRB4->FJ3_PAGO
            //Com saldo bancario
            TRB4->FJ3_DISP += nDispon
            TRB4->(MsUnLock())

            TRB4->(dbSkip())
        EndDo

        TRB4->(dbGoTop())

        //Calculo das formulas digitadas pelo usuario
        Do While (TRB4->(!EOF()))

            If (!Empty(TRB4->FJ3_SEDINI) .And. !Empty(TRB4->FJ3_SEDFIM)) //Soh entra nas analiticas

                CNICalc140()
            EndIf

            TRB4->(dbSkip())
        EndDo

        TRB4->(dbGoTop())

        Do While (TRB4->(!EOF()))
            // Soh imprimir se a linha estiver como SIM no VISENT
            If (TRB4->FJ3_VISENT == '1')
                // Incluir no arquivo de trabalho para impressão na tela
                RecLock("cArqTmp",.T.)
                CARQTMP->CODDESC    := "00/00/0000"+" "+Space(TRB4->FJ3_COLUNA)+TRB4->FJ3_DESCCG
                CARQTMP->RECEBIDOS  := TRB4->FJ3_REC
                CARQTMP->PAGOS      := TRB4->FJ3_PAGO
                CARQTMP->DISPON 	:= TRB4->FJ3_DISP
                CARQTMP->DATAAN 	:= dDataAnt
                CARQTMP->ORDEM 		:= TRB4->FJ3_ORDEM
                TRB4->(MsUnLock())
            EndIf

            RecLock("TRB4",.F.)
            //Inicializo os campos utilizados
            TRB4->FJ3_REC  := 0
            TRB4->FJ3_PAGO := 0
            TRB4->FJ3_DISP := 0
            TRB4->(MsUnLock())

            TRB4->(dbSkip())
        EndDo

        TRB4->(dbGoTop())// Comecar de novo

        dbSelectArea("FJ3")
        dbSetOrder(1)
        dbGoTop()

        dbSelectArea("cArqTmp")
        dbSetOrder(1)
        dbGoTop()

        //Soma o Total Geral(Recebido, pago e DISPON)
        Do While (CARQTMP->(!EOF()))

            nTotRec  := 0
            nTotPago := 0
            nTotDisp := 0

            cData := SubStr(CARQTMP->CODDESC,1,10)
            nRec := CARQTMP->(Recno())

            Do While(cData == SubStr(CARQTMP->CODDESC,1,10))

                If FJ3->(dbSeek(xFilial("FJ3")+MV_PAR20+AllTrim(CARQTMP->ORDEM)))
                    //Se nao tiver entidade superior deve ser somada
                    If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '2')
                        //Se for debito
                        //	If(FJ3->FJ3_NORMAL == '1')
                        nTotRec  += CARQTMP->RECEBIDOS
                        nTotPago += CARQTMP->PAGOS
                        nTotDisp += CARQTMP->DISPON
                        /*	Else //Se for credito
					nTotRec  += (CARQTMP->RECEBIDOS * -1)
					nTotPago += (CARQTMP->PAGOS * -1)
					nTotDisp += (CARQTMP->DISPON * -1)
                        EndIf */
                    EndIf
                EndIf

                CARQTMP->(dbSkip())
            EndDo

            CARQTMP->(dbGoto(nRec))//Volta para o primeiro registro da data selecionada
            cData := SubStr(CARQTMP->CODDESC,1,10)

            Do While(cData == SubStr(CARQTMP->CODDESC,1,10))

                If FJ3->(dbSeek(xFilial("FJ3")+MV_PAR20+AllTrim(CARQTMP->ORDEM)))
                    If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '1') // Totaliza na entidade totalizadora por data
                        RecLock("cArqTmp",.F.)
                        CARQTMP->RECEBIDOS := nTotRec
                        CARQTMP->PAGOS := nTotPago
                        CARQTMP->DISPON := nTotDisp
                        MsUnLock()
                    EndIf
                EndIf

                CARQTMP->(dbSkip())
            EndDo
        EndDo

    EndIf

    SE1->(dbGoTop())//Receber

    SE2->(dbGoTop())//Pagar

    TRB4->(dbGoTop())

    //³Tratamento de recebidos, pagos e DISPON de Titulos que irão vencer   ³
    Do While (dDataAnt <= dDataAte)

        // Se for analitica -  busco por naturezas
        If (!Empty(TRB4->FJ3_SEDINI) .And. !Empty(TRB4->FJ3_SEDFIM))

            Do While (SE2->(!EOF()))

                nSaldo := 0

                IF mv_par03 == 1 .and. SE2->E2_FILIAL != cFilSE2
                    Exit
                EndIF

                If SE2->E2_SALDO == 0 .and. IIf(mv_par11==1,SE2->E2_BAIXA <= dDataBase,.t.)
                    SE2->(dbSkip())
                    Loop
                End

                If mv_par12 = 2
                    If SE2->E2_MOEDA != nMoeda
                        SE2->(dbSkip())
                        Loop
                    EndIf
                EndIf

                //Confere a natureza do registro SE5 E se a data eh a do dia processado
                If ((AllTrim(SE2->E2_NATUREZ) >= AllTrim(TRB4->FJ3_SEDINI) .And. AllTrim(SE2->E2_NATUREZ) <= AllTrim(TRB4->FJ3_SEDFIM)) .And. SE2->E2_VENCREA == dDataAnt)

                    nSaldup := 0

                    If SE2->E2_BAIXA > dDataBase .And. mv_par11 == 1
                        nSaldup:=SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,mv_par02,SE2->E2_VENCREA,dDataBase,SE2->E2_LOJA,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))
                    Else
                        // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                        lTxMoeda := SM2->(MsSeek(SE2->E2_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                        nSaldup:=xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,mv_par02,,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))
                    End

                    IF mv_par13 == 2 .And. SE2->E2_TIPO $ MVABATIM
                        SE2->(dbSkip())
                        Loop
                    End
                    If SE2->E2_TIPO $ MVPAGANT
                        SE2->(dbSkip())
                        Loop
                    Endif

                    IF SE2->E2_PREFIXO < mv_par09 .or. SE2->E2_PREFIXO > mv_par10  //Do Prefixo ao Prefixo
                        SE2->(dbSkip())
                        Loop
                    EndIF

                    If ! ( AllTrim(Str(SE2->E2_MOEDA,2)) $ mv_par08 )
                        SE2->(dbSkip())
                        Loop
                    End

                    If SE2->E2_FLUXO == "N" .or. (SE2->E2_EMISSAO > dDataBase .and. mv_par14 == 2)
                        SE2->(dbSkip())
                        Loop
                    End

                    nAbatim := 0
                    If mv_par13 == 2

                        //Quando considerar Titulos com emissao futura, eh necessario
                        //colocar-se a database para o futuro de forma que a Somaabat()
                        //considere os titulos de abatimento
                        If mv_par14 == 1
                            dOldData := dDataBase
                            dDataBase := CTOD("31/12/40")
                        Endif

                        nAbatim := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",mv_par02,,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_FILIAL)

                        If mv_par14 == 1
                            dDataBase := dOldData
                        Endif

                    Endif

                    nSaldup -= nAbatim

                    RecLock("TRB4",.F.)
                    IF cPaisLoc <> "BRA" .And. E2_TIPO $ MVPAGANT+"/"+MV_CPNEG
                        TRB4->FJ3_PAGO += (nSalDup * -1)
                    Else
                        TRB4->FJ3_PAGO += nSalDup
                    Endif
                    TRB4->(MsUnLock())

                    cSuperior := TRB4->FJ3_CTASUP // Conta Superior
                    cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
                    nCont     := TRB4->(Recno())

                    //Procurar nas superiores e somar ou subtrair
                    Do While (!Empty(cSuperior))

                        //Somar ou Subtrair conforme campo FJ3_IDENTI
                        If (cSuperior == TRB4->FJ3_CONTAG)
                            If (cIdenti == '1')
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_PAGO += nSalDup
                                TRB4->(MsUnLock())
                            Else
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_PAGO -= nSalDup
                                TRB4->(MsUnLock())
                            EndIf
                        EndIf

                        cSuperior := TRB4->FJ3_CTASUP
                        TRB4->(dbSkip(-1))
                    EndDo

                    TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

                EndIf

                SE2->(dbSkip())
            EndDo

            //Contas a receber
            Do While (SE1->(!EOF()))

                nSaldo := 0

                IF mv_par03 == 1 .and. SE1->E1_FILIAL != cFilSE1
                    Exit
                EndIF

                If SE1->E1_TIPO $ MVRECANT
                    SE1->(dbSkip())
                    Loop
                Endif

                IF SE1->E1_PREFIXO < mv_par09 .or. SE1->E1_PREFIXO > mv_par10  //Do Prefixo ao Prefixo
                    SE1->(dbSkip())
                    Loop
                EndIF

                If ! ( AllTrim(Str(SE1->E1_MOEDA,2)) $ mv_par08 )
                    SE1->(dbSkip())
                    Loop
                EndIf

                If SE1->E1_FLUXO == "N" .or. (SE1->E1_EMISSAO > dDatabase .and. mv_par14 == 2)
                    SE1->(dbSkip())
                    Loop
                EndIf

                IF ( SE1->E1_SALDO = 0 .and. IIF( mv_par11 == 1, SE1->E1_BAIXA <= dDataBase, .T. )  ) .or. SE1->E1_SITUACA $ cListDesc  //SITCOB
                    SE1->(dbSkip())
                    Loop
                EndIF

                IF mv_par13 == 2 .And. SE1->E1_TIPO $ MVABATIM
                    SE1->(dbSkip())
                    Loop
                EndIf
                If mv_par12 = 2
                    If SE1->E1_MOEDA != nMoeda
                        SE1->(dbSkip())
                        Loop
                    EndIf
                EndIf

                nSaldup := 0

                //Confere a natureza do registro SE5 E se a data eh a do dia processado
                If ((AllTrim(SE1->E1_NATUREZ) >= AllTrim(TRB4->FJ3_SEDINI) .And. AllTrim(SE1->E1_NATUREZ) <= AllTrim(TRB4->FJ3_SEDFIM)) .And. SE1->E1_VENCREA == dDataAnt)

                    If mv_par11 == 1
                        nSaldup := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,mv_par02,SE1->E1_VENCREA,dDataBase,SE1->E1_LOJA,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0), mv_par17)
                    Else
                        // Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
                        lTxMoeda := SM2->(MsSeek(SE1->E1_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(mv_par02))) != 0
                        nSaldup  := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,mv_par02,If(lTxMoeda,SE1->E1_VENCREA,dDataBase),nDecs+1,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
                    End

                    // Se titulo do Template GEM
                    If HasTemplate("LOT")  .And. !Empty(SE1->E1_NCONTR)
                        If SE1->E1_VALOR == SE1->E1_SALDO .Or.;
                                SE1->E1_VALOR == nSaldup //o titulo pode estar quitado(e1_saldo=0) mas valor em datas retroativas nao, portanto devera somar o valor do gem
                            nSaldup += CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
                        EndIf
                    EndIf

                    nAbatim := 0
                    If mv_par13 == 2
                        If mv_par14 == 1
                            dOldData := dDataBase
                            dDataBase := CTOD("31/12/40")
                        Endif

                        nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",mv_par02,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL)

                        If mv_par14 == 1
                            dDataBase := dOldData
                        Endif

                    Endif
                    nSalDup -= nAbatim

                    RecLock("TRB4",.F.)
                    TRB4->FJ3_REC += nSalDup
                    TRB4->(MsUnLock())

                    cSuperior := TRB4->FJ3_CTASUP // Conta Superior
                    cIdenti	  := TRB4->FJ3_IDENT // Somar ou Subtrair
                    nCont     := TRB4->(Recno())

                    //Procurar nas superiores e somar ou subtrair
                    Do While (!Empty(cSuperior))

                        //Somar ou Subtrair conforme campo FJ3_IDENTI
                        If (cSuperior == TRB4->FJ3_CONTAG)
                            If (cIdenti == '1')
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_REC += nSalDup
                                TRB4->(MsUnLock())
                            Else
                                RecLock("TRB4",.F.)
                                TRB4->FJ3_REC -= nSalDup
                                TRB4->(MsUnLock())
                            EndIf
                        EndIf

                        cSuperior := TRB4->FJ3_CTASUP
                        TRB4->(dbSkip(-1))
                    EndDo

                    TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

                EndIf

                SE1->(dbSkip())
            EndDo

        EndIf

        TRB4->(dbSkip())

        If (TRB4->(EOF()))

            dbSelectArea("TRB4")
            If (dDataAnt <= dDataAte)
                TRB4->(dbGoTop())

                //Calcular o DISPON de todas as contas (Recebido - Pago)
                Do While (TRB4->(!EOF()))

                    RecLock("TRB4",.F.)
                    TRB4->FJ3_DISP = TRB4->FJ3_REC - TRB4->FJ3_PAGO
                    //Com saldo bancario
                    TRB4->FJ3_DISP += nDispon
                    TRB4->(MsUnLock())

                    TRB4->(dbSkip())
                EndDo

                TRB4->(dbGoTop())

                //Calculo das formulas digitadas pelo usuario
                Do While (TRB4->(!EOF()))

                    If (!Empty(TRB4->FJ3_SEDINI) .And. !Empty(TRB4->FJ3_SEDFIM)) //Soh entra nas analiticas

                        CNICalc140()
                    EndIf

                    TRB4->(dbSkip())
                EndDo

                TRB4->(dbGoTop())

                Do While (TRB4->(!EOF()))

                    // Soh imprimir se a linha estiver como SIM no VISENT
                    If (TRB4->FJ3_VISENT == '1')
                        // Incluir no arquivo de trabalho para impressão na tela
                        RecLock("cArqTmp",.T.)
                        CARQTMP->CODDESC    := DTOC(dDataAnt)+" "+Space(TRB4->FJ3_COLUNA)+TRB4->FJ3_DESCCG
                        CARQTMP->RECEBIDOS  := TRB4->FJ3_REC
                        CARQTMP->PAGOS      := TRB4->FJ3_PAGO
                        CARQTMP->DISPON 	:= TRB4->FJ3_DISP
                        CARQTMP->DATAAN 	:= dDataAnt//DTOC(dDataAnt)
                        CARQTMP->ORDEM 		:= TRB4->FJ3_ORDEM
                        MsUnLock()
                    EndIf

                    RecLock("TRB4",.F.)
                    //Inicializo os campos utilizados
                    TRB4->FJ3_REC  := 0
                    TRB4->FJ3_PAGO := 0
                    TRB4->FJ3_DISP := 0
                    TRB4->(MsUnLock())

                    TRB4->(dbSkip())
                EndDo

                TRB4->(dbGoTop())// Comecar de novo
                SE2->(dbGoTop())
            EndIf

            dDataAnt := dDataAnt + 1//soma 1 dia na data anterior
        Else
            If (SE2->(EOF()))
                SE2->(dbGoTop()) //Inicia o arquivo de SE2 novamente pois o arquivo de visao nao esta no fim
            EndIf

            If (SE1->(EOF()))
                SE1->(dbGoTop()) //Inicia o arquivo de SE2 novamente pois o arquivo de visao nao esta no fim
            EndIf
        EndIf

    EndDo

    FJ3->(dbSetOrder(1))
    FJ3->(dbGoTop())

    (cArqTmp)->(dbSetOrder(1))
    (cArqTmp)->(dbGoTop())

    //Soma o Total Geral(Recebido, pago e DISPON)
    Do While (CARQTMP->(!EOF()))

        nTotRec  := 0
        nTotPago := 0
        nTotDisp := 0

        cData := SubStr(CARQTMP->CODDESC,1,10)
        nRec := CARQTMP->(Recno())

        Do While(cData == SubStr(CARQTMP->CODDESC,1,10))

            If FJ3->(dbSeek(xFilial("FJ3")+MV_PAR20+AllTrim(CARQTMP->ORDEM)))
                //Se nao tiver entidade superior deve ser somada
                If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '2')
                    //Se for debito
                    //	If(FJ3->FJ3_NORMAL == '1')
                    nTotRec  += CARQTMP->RECEBIDOS
                    nTotPago += CARQTMP->PAGOS
                    nTotDisp += CARQTMP->DISPON
                    /*	Else //Se for credito
				nTotRec  += (CARQTMP->RECEBIDOS * -1)
				nTotPago += (CARQTMP->PAGOS * -1)
				nTotDisp += (CARQTMP->DISPON * -1)
                    EndIf*/
                EndIf
            EndIf

            CARQTMP->(dbSkip())
        EndDo

        CARQTMP->(dbGoto(nRec))//Volta para o primeiro registro da data selecionada
        cData := SubStr(CARQTMP->CODDESC,1,10)
        Do While(cData == SubStr(CARQTMP->CODDESC,1,10))

            If FJ3->(dbSeek(xFilial("FJ3")+MV_PAR20+AllTrim(CARQTMP->ORDEM)))
                If (Empty(FJ3->FJ3_CTASUP) .And. FJ3->FJ3_TOTVIS == '1') // Totaliza na entidade totalizadora por data
                    RecLock("cArqTmp",.F.)
                    CARQTMP->RECEBIDOS := nTotRec
                    CARQTMP->PAGOS     := nTotPago
                    CARQTMP->DISPON    := nTotDisp
                    MsUnLock()
                EndIf
            EndIf

            CARQTMP->(dbSkip())
        EndDo
    EndDo

    If (mv_par06 == 1)
        TRB2->(dbCloseArea())
        TRB3->(dbCloseArea())
    EndIf

    TRB4->(dbCloseArea())

    If _oFINR1402 <> Nil
        _oFINR1402:Delete()
        _oFINR1402 := Nil
    Endif

Return

/*/{Protheus.doc} ListaES
Essa funcao checa se o registro tem algum movimento bancario do tipo ES
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 05/10/2021
@param cChavES, character, Chave de pesquisa no SE5
@return Character, Deveria ser logico porem , retorna se tem ou nao tem estorno
/*/
Static Function ListaES(cChavES)

    Local cRetorno := .T.
    Local aArea    := GetArea()

    Static cAliasListaES := Nil

    If cAliasListaES == Nil
        cAliasListaES := Criatrab(,.F.)
    Endif

    Default cChavES := ""

    If !Empty(cChavES)
        BeginSql Alias cAliasListaES
            SELECT
                SE5.E5_FILIAL,
                SE5.E5_PREFIXO,
                SE5.E5_NUMERO,
                SE5.E5_PARCELA
            FROM
                %table:SE5% SE5
            WHERE
                SE5.E5_FILIAL + SE5.E5_PREFIXO + SE5.E5_NUMERO + SE5.E5_PARCELA = %exp:cChavES%
                AND SE5.E5_TIPODOC = "ES"
                AND SE5.%notDel%
            ORDER BY
                %Order:SE5%
        EndSql

        If !(cAliasListaES)->(Eof())
            cRetorno := .F.
        EndIf

        (cAliasListaES)->(DbCloseArea())
    Endif

    RestArea(aArea)

Return (cRetorno)

/*/{Protheus.doc} CNICalc140
Calcula saldo com base na formula digitada
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 05/10/2021
@return Character, sem retorno definido
/*/

Static Function CNICalc140 ()

    Local cSuperior := TRB4->FJ3_CTASUP // Conta Superior
    Local nCont     := TRB4->(Recno())
    Local nFator    := 0

    //Procurar nas superiores e somar ou subtrair
    Do While (!Empty(cSuperior))

        //Ralizar calculo com a formula digitada pelo usuario
        If (cSuperior == TRB4->FJ3_CONTAG)
            If (Left(TRB4->FJ3_FORMUL, 7) == "ROTINA=")
                nFator := &(Subs(TRB4->FJ3_FORMUL, 8))

                RecLock("TRB4",.F.)
                TRB4->FJ3_DISP *= nFator
                TRB4->(MsUnLock())

            ElseIf Left(TRB4->FJ3_FORMUL, 6) == "FATOR="
                nFator := &(Subs(TRB4->FJ3_FORMUL, 7))

                RecLock("TRB4",.F.)
                TRB4->FJ3_DISP *= nFator
                TRB4->(MsUnLock())

            Elseif Left(TRB4->FJ3_FORMUL,6 ) == "SALDO="
                nFator := &(Subs(TRB4->FJ3_FORMUL, 7))

                RecLock("TRB4",.F.)
                TRB4->FJ3_DISP := nFator
                TRB4->(MsUnLock())

            EndIf
        EndIf

        cSuperior := TRB4->FJ3_CTASUP
        TRB4->(dbSkip(-1))
    EndDo

    TRB4->(dbGoto(nCont))// Posiciona no ultimo registro

Return
