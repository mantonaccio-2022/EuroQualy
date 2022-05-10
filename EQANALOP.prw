#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} EQANALOP
Rotina de |Recalculo de Envase e baixa de OP quando da alteração de OP
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 06/26/2022
@return Character, sem retorno definido
/*/
User Function EQANALOP()

    Private cCadastro := OEMTOANSI("Analise de Ordem de Produção")
    Private cPerg     := "EQCANALOP"
    Private cTitulo   := "Analise de Ordem de Producao"
    Private oBrowse
    Private oExcel     := FWMsExcelEX():New()
    Private _TMP       := GetNextAlias()
    Private lUltTolVol :=.F.
    Private lUltTolDen :=.F.
    Private cNumOP     := Space(11)

    //InstÃ¢nciando FWMBrowse - Somente com dicionÃ¡rio de dados
    oBrowse := FWMBrowse():New()

    //Setando a tabela de cadastro de comissoes
    oBrowse:SetAlias("SC2")

    //Setando a descriÃ§Ã£o da rotina
    oBrowse:SetDescription(cTitulo)

    //Legendas
    oBrowse:AddLegend( 'SC2->C2_XLIBOP == "1"' , "RED" , "OP Analisada" )
    oBrowse:AddLegend( 'SC2->C2_XLIBOP <> "1"' , "GREEN" , "OP para Analise" )
    oBrowse:SetFilterDefault("SC2->C2_ITEM ='01' .AND. SC2->C2_QUJE == 0")

    //Ativa a Browse
    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
DescriÃ§Ã£o dos Botoes de tela
@type function Tela
@version  1.00
@author mario.antonaccio
@since 06/12/2021
@return array, opÃ§Ãµes de funÃ§Ãµes
*/
Static Function MenuDef()

    Local aMenu := {}

    ADD OPTION aMenu TITLE 'Pesquisar' 	    ACTION 'AxPesqui'		OPERATION 1 ACCESS 0
    ADD OPTION aMenu TITLE 'Visualiza OP'   ACTION 'AxVisual'	    OPERATION 2 ACCESS 0
    //ADD OPTION aMenu TITLE 'Visual Analise' ACTION 'U_EQANAOPV()'  OPERATION 2 ACCESS 0
    ADD OPTION aMenu TITLE 'Analisar' 	    ACTION 'U_EQANAOPA()'	OPERATION 3 ACCESS 0
    ADD OPTION aMenu TITLE 'Relatorio' 	    ACTION 'U_EQANAOPR()'	OPERATION 4 ACCESS 0
    ADD OPTION aMenu TITLE 'Legenda'        ACTION 'U_EQANAOPL()'   OPERATION 6 ACCESS 0 //OPERATION X

Return( aMenu )

/*/{Protheus.doc} EQANAOPA
Tela de Demosntração de Demosntração do Calculo de Massas e outras ionformações
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 26/02/2022
@return Character, sem retorno definido
/*/
User Function EQANAOPA()

    Local nOpcEmp      := GD_INSERT+GD_DELETE+GD_UPDATE
    Local nOpcEnv      := 0
    Private aCoEmpenho := {}
    Private aCoEnvase  := {}
    Private aHoEmpenho := {}
    Private aHoEnvase  := {}
    Private aSomaEnv   := {}
    Private cLocalAr   := Space(02)
    Private cNAnalise  := ""
    Private cNproduto  := Space(30)
    Private cObs       := " "
    Private cProduto   := Space(15)
    Private cTempoIni  := Substr(TIME(),1,5)
    Private cUMOri     := Space(02)
    Private cUMRea     := Space(02)
    Private dDataApon  := dDataBase
    Private dDataIni   := dDataBase
    Private dDtEmiss   := CtoD(" ")
    Private dDtPrf     := CtoD(" ")
    Private dDtPri     := CtoD(" ")
    Private lFim       := .F.
    Private nDensRea   := 0
    Private nDifEnv    := 0
    Private noEmpenho  := 0
    Private noEnvase   := 0
    Private nPercDens  := 0
    Private nPercQtd   := 0
    Private nQtdeOri   := 0
    Private nQtdeRea   := 0
    Private nSomaEnv   := 0
    Private nTotMassa  := 0

    SetPrvt("oNegrito","oAnaop","oPOP","oSay1","oSay2","oSay4","oSay3","oSay5","oSay6","oSay8","oSay7","oSay9")
    SetPrvt("oDtEmiss","oDtEntrega","oLocalAr","oProduto","oNproduto","oQtdeOri","oQtdeRea","oDensOri","oDensRea")
    SetPrvt("oEmpenho","oPEnvase","oEnvase","oPObs","oObs","oCancela","oConfirma","oTotMassa","oUMRea","oUMOri",,"oPercQtd","oPercDens")

    // Se ja foi analisada, nao precisa reanalise
    If SC2->C2_XLIBOP == '1'
        MsgInfo("OP ja Analisada!","Ja Analisada")
        Return
    End

    // Se ja foi totalmente entregue, nao tem porque fazer analise
    If SC2->C2_QUJE == SC2->C2_QUANT
        RecLock("SC2",.F.)
        SC2->C2_XLIBOP:="1"
        MsUnLock()
        MsgInfo("OP ja Encerrada.Nao Há necessidade de Análise","Ja Encerrada")
        Return
    End


    cNumOP     := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
    dDtEmiss   := SC2->C2_EMISSAO
    dDtPri     := SC2->C2_DATPRI
    dDtPrF     := SC2->C2_DATPRF
    cLocalAr   := SC2->C2_LOCAL
    cProduto   := SC2->C2_PRODUTO
    cNProduto  := Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC")
    cUMORI     := Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_UM")
    cUMREA     := Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_UM")
    nQtdeOri   := SC2->C2_QUANT
    nQtdeRea   := SC2->C2_QUANT
    nDensOri   := If(Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_CONV")==0,SuperGetMv("EQ_OPDENPD",.F.,1.48),;
        Posicione("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_CONV"))
    nDensRea   := nDensOri

    SZC->(dbSetOrder(1))
    If SZC->(dbSeek(xFilial("SZC")+"_OP"+cNumOP))
        cNAnalise:=Soma1(SZC->zC_NROAN,3)
    Else
        cNAnalise:="001"
    End

    //Definicao do Dialog e todos os seus componentes.
    //oNegrito   := TFont():New( "MS Sans Serif",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
    oNegrito   := TFont():New( "MS Sans Serif",0,-11,,.F.,0,,700,.F.,.F.,,,,,, )

    oAnaop     := MSDialog():New( 138,213,663,1331,"Analise de OP",,,.F.,,,,,,.T.,,oNegrito,.T. )

    oPOP   := TGroup():New(004, 008, 092                     , 332 , " Dados OP ", oAnaop  , CLR_BLACK, CLR_WHITE, .T., .F.)
    oSay1  := TSay()  :New(016, 012, {||"Numero "}           , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 024, 008)
    oSay2  := TSay()  :New(016, 104, {||"Data Emissao"}      , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay4  := TSay()  :New(016, 192, {||"Data Entrega"}      , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay3  := TSay()  :New(016, 280, {||"Local"}             , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 020, 008)
    oSay5  := TSay()  :New(031, 012, {||"Produto"}           , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 024, 008)
    oSay6  := TSay()  :New(046, 012, {||"Quantidade OP"}     , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay8  := TSay()  :New(046, 180, {||"Densidade Original"}, oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 056, 008)
    oSay7  := TSay()  :New(060, 012, {||"Quantidade Real"}   , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay9  := TSay()  :New(060, 180, {||"Densidade Real"}    , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 056, 008)
    oSay12 := TSay()  :New(076, 012, {||"% Quanttidade"}     , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
    oSay13 := TSay()  :New(076, 180, {||"% Densidade"}       , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 048, 008)
    oSay10 := TSay()  :New(212, 012, {||"Total Massa"}       , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 040, 008)

    oNumOP     := TGet():New(014, 040, {|u| If(PCount()>0,cNumOP:=u,cNumOP)}      , oPOP, 060, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cNumOP"   , , , ,)
    oDtEmiss   := TGet():New(014, 148, {|u| If(PCount()>0,dDtEmiss:=u,dDtEmiss)}  , oPOP, 040, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "dDtEmiss" , , , ,)
    oDtEntrega := TGet():New(014, 236, {|u| If(PCount()>0,dDtPrf:=u,dDtPrf)}      , oPOP, 040, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "dDtPrf"  , , , ,)
    oLocalAr   := TGet():New(014, 300, {|u| If(PCount()>0,cLocalAr:=u,cLocalAr)}  , oPOP, 024, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cLocalAr" , , , ,)
    oProduto   := TGet():New(030, 040, {|u| If(PCount()>0,cProduto:=u,cProduto)}  , oPOP, 060, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cProduto" , , , ,)
    oNproduto  := TGet():New(030, 104, {|u| If(PCount()>0,cNproduto:=u,cNproduto)}, oPOP, 220, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cNproduto", , , ,)
    oQtdeOri   := TGet():New(045, 068, {|u| If(PCount()>0,nQtdeOri:=u,nQtdeOri)}  , oPOP, 060, 008, '@ER 999,999.9999', , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nQtdeOri" , , , ,)
    oUMOri     := TGet():New(045, 132, {|u| If(PCount()>0,cUMOri:=u,cUMOri)}      , oPOP, 016, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cUMOri"   , , , ,)
    oQtdeRea   := TGet():New(060, 068, {|u| If(PCount()>0,nQtdeRea:=u,nQtdeRea)}  , oPOP, 060, 008, '@ER 999,999.9999', , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nQtdeRea" , , , ,)
    oUMRea     := TGet():New(060, 132, {|u| If(PCount()>0,cUMRea:=u,cUMRea)}      , oPOP, 016, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cUMRea"   , , , ,)
    oPercQtd   := TGet():New(076, 068, {|u| If(PCount()>0,nPercQtd:=u,nPercQtd)}  , oPOP, 060, 008, '@ER 999.9999'      , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nPercQtd" , , , ,)

    oQtdeRea  := TGet():New(060, 068, {|u| If(PCount()>0,nQtdeRea:=u,nQtdeRea)}  , oPOP  , 060, 008, '@ER 999,999.9999',                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .F., .F., , "nQtdeRea" , , , ,)
    oDensOri  := TGet():New(045, 244, {|u| If(PCount()>0,nDensOri:=u,nDensOri)}  , oPOP  , 060, 008, '@ER 999,999.9999',                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nDensOri" , , , ,)
    oDensRea  := TGet():New(060, 244, {|u| If(PCount()>0,nDensRea:=u,nDensRea)}  , oPOP  , 060, 008, '@ER 999,999.9999',{|| U_CALCMASSA()}, CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .F., .F., , "nDensRea" , , , ,)
    oPercDens := TGet():New(076, 244, {|u| If(PCount()>0,nPercDens:=u,nPercDens)}, oPOP  , 060, 008, '@ER 999.9999'      ,                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nPercDens", , , ,)
    oTotMassa := TGet():New(212, 068, {|u| If(PCount()>0,nTotMassa:=u,nTotMassa)}, oAnaOp, 060, 008, '@ER 999,999.9999',                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nTotMassa", , , ,)

    oPEmpenho  := TGroup():New( 104,004,232,272," Empenho ",oAnaop,CLR_BLACK,CLR_WHITE,.T.,.F. )
    MHoEmpenho()
    MCoEmpenho()
    oEmpenho   := MsNewGetDados():New(116,012,204,268,nOpcEmp,'U_CALCMASSA("T")','U_CALCMASSA("T")','++C6_ITEM',{"D4_COD","GXT_QTREAL"},2,999,'AllwaysTrue()','','AllwaysTrue()',oAnaop,aHoEmpenho,aCoEmpenho )

    oPEnvase   := TGroup():New( 104,284,204,544," OP de Envase ",oAnaop,CLR_BLACK,CLR_WHITE,.T.,.F. )
    MCoEnvase()
    oEnvase    := MsNewGetDados():New(120,290,204,536,nOpcEnv,'AllwaysTrue()','AllwaysTrue()','',,0,999,'AllwaysTrue()','','AllwaysFalse()',oAnaop,aHoEnvase,aCoEnvase )

    oPObs      := TGroup():New( 004,336,092,540," Observações ",oAnaop,CLR_BLACK,CLR_WHITE,.T.,.F. )
    oObs       := TMultiGet():New( 012,340,{|u| If(PCount()>0,cObs:=u,cObs)},oPObs,196,076,,,,,,.T.)
    oCancela   := TButton():New( 232,416,"Cancela ",oAnaop,{||oAnaOP:End()},053,012,,,.F.,.T.,.F.,,.F.,,,.F. )
    oConfirma  := TButton():New( 232,486,"Confirma Analise",oAnaop,{||MsAguarde({|lFim|,fCONFIRMA()},"Processamento","Aguarde a finalização do processamento...")},057,012,,,.F.,.T.,.F.,,.F.,,,.F. )

    oAnaop:Activate(,,,.T.)

Return

/*/{Protheus.doc} MHoEmpenho
Monta aHeader da MsNewGetDados para o Alias: SD4
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 27/02/2022
@return Array, Cabecalho do GetDados do Empenho
/*/
Static Function MHoEmpenho()

    Local aCampos:={"C6_ITEM","D4_COD","D4_QTDEORI","GXT_QTREAL","B1_DESC","D4_LOCAL","CZI_NRRGAL"}
    Local nI

    For nI:=1 To Len(aCampos)
        SX3->(DbSetOrder(2))
        SX3->(DbSeek(aCampos[nI]))
        If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
            noEmpenho++
            Aadd(aHoEmpenho,{Trim(X3Titulo()),;
                SX3->X3_CAMPO,;
                SX3->X3_PICTURE,;
                IF("DESC"$aCampos[nI],30,SX3->X3_TAMANHO),;
                SX3->X3_DECIMAL,;
                "",;
                "",;
                SX3->X3_TIPO,;
                "",;
                IF("REAL"$aCampos[nI],"R","V") } )
        End
    Next

Return

/*/{Protheus.doc} MCoEmpenho
Monta aCols da MsNewGetDados para o Alias: SD4
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 27/02/2022
@return Array, acols dos Get Dados do Empenho (SD4)
/*/
Static Function MCoEmpenho()
    Local nI:=1

    SD4->(dbSetOrder(2))
    If SD4->(dbSeek(xFilial("SD4")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))
        nTotMassa:=0
        While SD4->(!EOF()) .and. Alltrim(SD4->D4_OP) == SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
            AADD(aCoEmpenho,{StrZero(nI,2,0),SD4->D4_COD,SD4->D4_QTDEORI,SD4->D4_QTDEORI,Substr(Posicione("SB1",1,xFilial("SB1")+SD4->D4_COD,"B1_DESC"),1,30),SD4->D4_LOCAL,SD4->(RecNo()),.F.})
            nTotMassa+=SD4->D4_QTDEORI
            nI++
            SD4->(dbSkip())
        End
    End
    oTotMassa:Refresh()
    If nTotmassa <> nQtdeOri
        oQtdeOri   := TGet():New( 045,068,{|u| If(PCount()>0,nQtdeOri:=u,nQtdeOri)}     ,oPOP,060,008,'@ER 999,999.9999',,CLR_RED,CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nQtdeOri",,,,)
        oQtdeOri:Refresh()
        oTotMassa  := TGet():New( 212,068,{|u| If(PCount()>0,nTotMassa:=u,nTotMassa)},  oAnaOp,060,008,'@ER 999,999.9999',,CLR_RED,CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"nTotMassa",,,, )
        oSay11     := TSay():New( 212,140,{||"Divergencia de Massa"},oAnaOp,,,.F.,.F.,.F.,.T.,CLR_RED,CLR_WHITE,080,008)
        //    Else
        //      oSay10     := TSay():New( 212,012,{||"Total Massa"},oAnaOp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,040,008)
    End

Return

/*/{Protheus.doc} MCoEnvase
Monta aCols da MsNewGetDados para o Alias: SC2
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 27/02/2022
@return Array, acols dos Get Dados das OP de envase (SC2)
/*/
Static Function MCoEnvase()

    Local nI:=1

    aadd(aHoEnvase, {"Item"           , "ITEM"     , "99"            , 02, 0, "", "", "C", "", ""})
    aadd(aHoEnvase, {"No.OP"          , "NUMOP "   , "@!"            , 11, 0, "", "", "C", "", ""})
    aadd(aHoEnvase, {"Produto"        , "PROD "    , "@!"            , 15, 0, "", "", "C", "", ""})
    aadd(aHoEnvase, {"UM"             , "UM"       , "@!"            , 02, 0, "", "", "C", "", ""})
    aadd(aHoEnvase, {"Qtd.Env.Orig"   , "QTDENVORI", "@ER 999,999"   , 07, 0, "", "", "N", "", ""})
    aadd(aHoEnvase, {"Qtd.Env.Real"   , "QTDENVREA", "@ER 999,999"   , 07, 0, "", "", "N", "", ""})
    aadd(aHoEnvase, {"Qtd PI Orig"    , "QTDPIORI" , "@ER 999,999.99", 11, 2, "", "", "N", "", ""})
    aadd(aHoEnvase, {"Qtd PI Real"    , "QTDPIREA ", "@ER 999,999.99", 11, 2, "", "", "N", "", ""})
    aadd(aHoEnvase, {"Local"          , "ARMAZ"    , "@!"            , 02, 0, "", "", "C", "", ""})
    aadd(aHoEnvase, {"Descrição"      , "DESCR"    , "@!"            , 30, 0, "", "", "C", "", ""})
    aadd(aHoEnvase, {"Peso Total Prod", "PESOTOT"  , "@ER 9,999.9999", 11, 2, "", "", "N", "", ""})
    aadd(aHoEnvase, {"Peso Produto"   , "PESO"     , "@ER 9,999.9999", 11, 2, "", "", "N", "", ""})
    aadd(aHoEnvase, {"Volume"         , "VOLUME "  , "@ER 9,999.9999", 11, 2, "", "", "N", "", ""})
    noEmpenho:=Len(aHoEnvase)

    BeginSql Alias _TMP
        SELECT
            SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN AS NUMOP,
            SC2.C2_PRODUTO AS PROD,
            SC2.C2_QUANT AS QTDENVORI,
            SC2.C2_LOCAL AS ARMAZ,
            SC2.C2_QUANT * SB1.B1_PESO AS PESOTOT,
            SD4.D4_QTDEORI AS QTDPIORI,
            SB1.B1_DESC AS DESCR,
            SB1.B1_UM AS UM,
            SB1.B1_PESO AS PESO,
            SB1.B1_CONV AS VOLUME
        FROM
            %Table:SC2% SC2
        INNER JOIN %Table:SB1% SB1
        ON SB1.B1_COD = SC2.C2_PRODUTO
            AND SB1.%NotDel%
        INNER JOIN SD4100 SD4
        ON SD4.D4_OP = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN
            AND SD4.D4_COD = %Exp:cProduto%
            AND SD4.D4_FILIAL = %Exp:xFilial("SD4")%
            AND SD4.%NotDel%
        WHERE
            SC2.%NotDel%
            AND SC2.C2_NUM = %Exp:Substr(cNumOp,1,6)%
        ORDER BY
            SC2.C2_NUM,
            SC2.C2_ITEM,
            SC2.C2_SEQUEN
    EndSql

    aQuery:=GetLastQuery()

    While (_TMP)->(!EOF())
        AADD(aCoEnvase,{StrZero(nI,2,0),;
            (_TMP)->NUMOP,;
            (_TMP)->PROD,;
            (_TMP)->UM,;
            (_TMP)->QTDENVORI,;
            (_TMP)->QTDENVORI,;
            (_TMP)->QTDPIORI ,;
            (_TMP)->QTDPIORI ,;
            (_TMP)->ARMAZ,;
            (_TMP)->DESCR,;
            (_TMP)->PESOTOT,;
            (_TMP)->PESO,;
            (_TMP)->VOLUME,;
            .F.})
        nI++
        (_TMP)->(dbSkip())
    End

    (_TMP)->(dbCloseArea())
Return

/*/{Protheus.doc} EQANAOPL
Legenda da tela
@type function Tela (Browse)
@version  1.00
@author mario.antonaccio
@since 15/12/2021
@return character, sem retuorno
/*/
User Function EQANAOPL()
    Local aLegenda:={}

    aadd(aLegenda, {"BR_VERDE"   , "OP para Analise"})
    aadd(aLegenda, {"BR_VERMELHO", "OP Analisada"})

    BrwLegenda("Analise de OP", "Situação", aLegenda)

Return

/*/{Protheus.doc} CalcMassa
Calculo das alterações de empenho
@type function Processamento
@version 1.00
@author mario.antonaccio
@since 27/02/2022
@param cTipo, character, Indica Linha ou Total
@return Logical, permite gravar ou nao
/*/
User Function CalcMassa(cTipo)

    Local nI
    Local lRet:=.T.
    Local nSomaPI:=0
    Local nDiferPI:=0
    Local nDifer:=0

    nTotMassa:=0

    nSomaPI:=0
    For nI:=1 to Len(oEnvase:aCols)
        nSomaPI+=NwFieldGet(oEnvase,"QTDPIORI",nI)
    Next

    For nI:=1 To Len(aCoEmpenho)
        If  NwDeleted(oEmpenho,nI)
            Loop
        End
        nTotMassa+=NwFieldGet(oEmpenho,"GXT_QTREAL",nI)
    Next
    nQtdeRea:=nTotMassa
    nDiferPI:=  nQtdeOri - nSomaPI
    nDifer  := (nTotMassa + nDiferPI) - nQtdeOri

    // Verifica densidades
    If nQtdeRea <> nQtdeOri
        nPercQtd:=((nQtdeRea/nQtdeOri)-1)*100
    Else
        nPercQtd:=0
    End
    If nDensRea <> nDensOri
        nPercDens:=((nDensRea/nDensOri)-1)*100
    Else
        nPercDens:=0
    End

    If  nPercQtd > SuperGetMv("EQ_OPTOLE",.F.,5)
        lUltTolVol:=.T.
        ALERT("Total de Massa Real MAIOR que tolerancia permitida de "+Str(SuperGetMv("EQ_OPTOLE",.F.,50) ,2,0)+ " %"+CRLF+;
            "Perc.Massa apontado: "+Str(nPercQtd,7,3) +" %")
        If !(UPPER(UsrRetName(RetCodUsr())) $ SuperGetMv("EQ_LIBANOP",.F.,"ADMINISTRADOR")    )
            lRet:=.T.  // Ate resolver
        Else
            lRet:=.T.
        End
    Else
        lRet:=.T.
    End

    If  nPercDens > SuperGetMv("EQ_OPTOLED",.F.,3)
        lUltTolDen:=.T.
        ALERT("Densidade Real MAIOR que tolerancia permitida de "+Str(SuperGetMv("EQ_OPTOLED",.F.,50) ,2,0)+ " %"+CRLF+;
            "Perc.Densidade apontada: "+Str(nPercDens,7,3)+ " %")
        If !(UPPER(UsrRetName(RetCodUsr())) $ SuperGetMv("EQ_LIBANOP",.F.,"ADMINISTRADOR")    )
            lRet:=.T.  // ate resolver
        Else
            lRet:=.T.
        End
    Else
        lRet:=.T.
    End

    If cTipo == "L"
        Return(lRet)
    End

    // Houve alteração do peso dos empenhos sem alteraçao de densidade
    // entao soma a diferença dos pesos na ultima OP de envase e ajusta a quantidade de envasae
    nQtdeRea:=nTotMassa
    If nTotmassa <> nQtdeOri .and. nDensOri == nDensRea

        nQtdPIOri:= NwFieldGet(oEnvase,"QTDPIORI",Len(oEnvase:aCols))
        nVolume := NwFieldGet(oEnvase,"VOLUME",Len(oEnvase:aCols))
        nPeso   := NwFieldGet(oEnvase,"PESO",Len(oEnvase:aCols))

        nNewPeso   := nVolume * nDensrea
        nNewPIENV  := nQtdPIOri + nDifer
        nNewQtdEnv := Round(nNewPIEnv / nNewPeso,0)

        NwFieldPut(oEnvase,"QTDENVREA",Len(oEnvase:aCols),nNewQtdEnv)
        NwFieldPut(oEnvase,"QTDPIREA",Len(oEnvase:aCols),nNewPIENV)

    End

    // Houve alteração do peso dos empenhos sem alteraçao de densidade
    // entao Recalcula Tudo PI do Envase
    //Quantidade so na Ultima

    If nTotmassa == nQtdeOri .and. nDensOri <> nDensRea

        For nI:=1 to Len(oEnvase:aCols)

            nQtdEnvOri:= NwFieldGet(oEnvase,"QTDENVORI",nI)

            nQtdPIOri:= NwFieldGet(oEnvase,"QTDPIORI",nI)
            nVolume := NwFieldGet(oEnvase,"VOLUME",nI)
            nPeso   := NwFieldGet(oEnvase,"PESO",nI)

            nNewPeso:=nVolume * nDensrea
            nNewPIENV:= (nQtdEnvOri * nVolume * nDensRea)

            NwFieldPut(oEnvase,"QTDPIREA",nI,nNewPIENV)

        Next

        nSomaPI:=0

        For nI:=1 to Len(oEnvase:aCols)
            nSomaPI+=NwFieldGet(oEnvase,"QTDPIREA",nI)
        Next

        //Diferenca de Densidade acerto na ultima OP
        nDifer:=nQtdeRea - nSomaPI
        nQtdPIRea:=NwFieldGet(oEnvase,"QTDPIREA",Len(oEnvase:aCols)) +  nDifer
        NwFieldPut(oEnvase,"QTDPIREA",Len(oEnvase:aCols),nQtdPIRea)
        NwFieldPut(oEnvase,"QTDENVREA",Len(oEnvase:aCols),nQtdPIRea/nNewPeso)

    End

    //Houve Alteração dos itens, recalcula
    If nTotmassa <> nQtdeOri .and. nDensOri <> nDensRea

        nSomaPI:=0
        For nI:=1 to Len(oEnvase:aCols)

            nQtdEnvOri := NwFieldGet(oEnvase,"QTDENVORI",nI)
            nQtdPIOri  := NwFieldGet(oEnvase,"QTDPIORI",nI)
            nVolume    := NwFieldGet(oEnvase,"VOLUME",nI)
            nPeso      := NwFieldGet(oEnvase,"PESO",nI)

            nNewPeso:=nVolume * nDensrea
            nNewPIENV:= (nQtdEnvOri * nVolume * nDensRea)

            nSomaPI+=nNewPIENV
            NwFieldPut(oEnvase,"QTDPIREA",nI,nNewPIENV)

        Next

        nDifer:=nTotMassa - nSomaPI

        nNewPIENV:= NwFieldGet(oEnvase,"QTDPIREA",Len(oEnvase:aCols)) + nDifer
        nNewQtdEnv:= Round(nNewPIEnv / nNewPeso,0)

        NwFieldPut(oEnvase,"QTDENVREA",Len(oEnvase:aCols),nNewQtdEnv)
        NwFieldPut(oEnvase,"QTDPIREA",Len(oEnvase:aCols),nNewPIENV)

    End

    // Retorna ao original caso o operador precise voltar para reanalisar
    If nTotmassa == nQtdeOri .and. nDensOri == nDensRea

        For nI:=1 to Len(oEnvase:aCols)

            NwFieldPut(oEnvase,"QTDENVREA",nI,NwFieldGet(oEnvase,"QTDENVORI",nI))
            NwFieldPut(oEnvase,"QTDPIREA",nI,NwFieldGet(oEnvase,"QTDPIORI",nI))

        Next

        nQtdeRea:=nQtdeOri
        nDensrea:=nDensOri
    End
    nQtdeRea:=nTotMassa

    oPercQtd:Refresh()
    oPercDens:Refresh()
    oQtdeRea:Refresh()
    oTotMassa:Refresh()
    oEnvase:Refresh()
    oAnaOp:Refresh()

Return(lRet)

/*/{Protheus.doc} fConfirma
Gravação do LOG de Analise
@type function Processanento
@version 1.00
@author mario.antonaccio
@since 27/02/2022
@return character, sem retorno
/*/
Static Function fConfirma()

    // Local lOkEmp  := .F.
    // Local lOkEnv  := .F.
    // Local lOkEstPI := .F.
    // Local lOkEstEN := .F.
    // Local lOkPI   := .F.
    // Local lOkBxPI := .F.
    Local lRet    := .T.
    Private lFim:=.F.

    If nQtdeOri <> nQtdeRea .or. nDensOri <> nDensRea
        // Verifica densidades
        If nQtdeRea <> nQtdeOri
            nPercQtd:=((nQtdeRea/nQtdeOri)-1)*100
        Else
            nPercQtd:=0
        End
        If nDensRea <> nDensOri
            nPercDens:=((nDensRea/nDensOri)-1)*100
        Else
            nPercDens:=0
        End

        If  nPercQtd > SuperGetMv("EQ_OPTOLE",.F.,5)
            If !(UPPER(UsrRetName(RetCodUsr())) $ SuperGetMv("EQ_LIBANOP",.F.,"ADMINISTRADOR")    )
                lRet:=.T.  // Ate resolver
            Else
                lRet:=.T.
            End
        Else
            lRet:=.T.
        End

        If  nPercDens > SuperGetMv("EQ_OPTOLED",.F.,3)
            If !(UPPER(UsrRetName(RetCodUsr())) $ SuperGetMv("EQ_LIBANOP",.F.,"ADMINISTRADOR")    )
                lRet:=.T.  // ate resolver
            Else
                lRet:=.T.
            End
        Else
            lRet:=.T.
        End

        If Empty(cObs)
            If ! lRet
                Alert("Necessario informar Justicativa para aumento/Perda Massa")
                lRet:=.F.
            End
        End
    End

    If lRet

        MsAguarde({|lFim|,GravaSZC()},"Processamento","Gravando LOG da Analise...")
        MsAguarde({|lFim|,GravaOP()},"Processamento","Ajustando OPs...")


        /*
        // Faço o Estorno da OP Principal
        //MsAguarde({|lFim|,lOkEstPi:=EstorPI()},"Processamento","Estornando a OP de PI...")

        //Se Ok estorno do PI , entao Estono as Ops de Envase
        If lOkEstPI
          //  MsAguarde({|lFim|,lOkEstEN:=EstorEnv()},"Processamento","Estornando as OP's de Envase..")
        End

        //Se estornou Todo o Processo, entao incluo as OPs de Envase Primeiro
        If lOkEstEN
           // MsAguarde({|lFim|,lOkEnv:=GrvOPEnv()},"Processamento","Gerando OP's de Envase..")
        End

        //Se Gravou OP de Envase, Entao Gero OP de PI
        If lOkEnv
           MsAguarde({|lFim|,lOkPI:=GrvOPPI()},"Processamento","Gerando OP de PI..")
        End

        // Se gerou OP de PI, então Incluo o Empenho com o novo volume
        If lOkPI
            MsAguarde({|lFim|,lOkEmp:=GrvOpEmp()},"Processamento","Gerando Empenho da OP de PI..")
        End

        // Se Gerou Empenho de PI e a OP de PI entao baixo a OP de PI
        If lOkEmp
            MsAguarde({|lFim|,lOkBxPI:=GrvBXPI()},"Processamento","Baixando OP de PI..")
        End

        //Se Todo Processo Ok,entao
        If  lOkEmp .and. lOkEnv  .and. lOkEstPI .and. lOkEstEN .and. lOkPI .and. lOkBxPI
            SC2->(dbSetOrder(1))
            If SC2->(dbSeek(xFilial("SC2")+cNumOp))
                RecLock("SC2",.F.)
                SC2->C2_XLIBOP:="1"
                MsUnLock()
            End
        */
        cMsg := "OP "+cNumOP+ " Incluida com sucesso"+CRLF
        cMsg += "Soma das MPs prevista = "+Str(nQtdeOri,10,2)+" "+cUMOri+CRLF
        cMsg += "Soma das MPs real = "+Str(nQtdeRea,10,2)+" "+cUMOri+CRLF
        cMsg += "Diferença kg = "+Str(nQtdeRea - nQtdeOri,10,2)+" "+cUMOri+CRLF
        cMsg += "Porcentagem = "+ STr(nPercQtd,8,4)+" %"

        RecLock("SZC",.T.)
        SZC->ZC_FILIAL  := xFilial("SZC")
        SZC->ZC_OP      := Substr(cNumOP,1,6)+"99999"
        SZC->ZC_NROAN   := cNAnalise
        SZC->ZC_EMISSAO := dDtEmiss
        SZC->ZC_TIPO    := "RES"
        SZC->ZC_PRODUTO := cProduto
        SZC->ZC_UM      := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")
        SZC->ZC_LOCAL   := cLocalAr
        SZC->ZC_QTDORI  := nQtdeOri
        SZC->ZC_QTDREA  := nQtdeRea
        SZC->ZC_PERCQTD := (nQtdeRea/nQtdeOri)
        SZC->ZC_DENSORI := nDensOri
        SZC->ZC_DENSREA := nDensRea
        SZC->ZC_PERCDEN := (nDensRea/nDensOri)
        SZC->ZC_PIENORI := 0
        SZC->ZC_PIENREA := 0
        SZC->ZC_PERPIEN := 0
        SZC->ZC_OBS     := cMsg
        SZC->ZC_USUARIO := UsrRetName(RetCodUsr())
        SZC->ZC_DTLIB   := dDataBase
        MsUnLock()

        MsgInfo(cMsg,"Processo Concluido")
        oAnaOP:End()
        //   Else
        //     ALERT("Processo Nao FInalizado Devido a Erro em alguma etapa")
        // End
    End
Return(Nil)

/*/{Protheus.doc} NwFieldGet
Retorna Valor da Celula da NewGetDados
@type function Processamento
@version  1.00
@author Ricardo Mansano - alterado por mario.antonaccio
@since 06/09/2005 - alterado em 04/03/2022
@param oObjeto, object, Objeto da NewGetDados
@param cCampo, character, Nome do Campo a ser localizado
@param nLinha, numeric, Linha da GetDados, caso o parametro nao seja
                        preenchido o Default sera o nAt da NewGetDados
@return variant, O Valor da Celula independente de seu TYPE
/*/
Static Function NwFieldGet(oObjeto,cCampo,nLinha)
    Local nCol := aScan(oObjeto:aHeader,{|x| Upper(AllTrim(x[2])) == Upper(cCampo)})
    Local xRet
    // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
    Default nLinha := oObjeto:nAt
    xRet := oObjeto:aCols[nLinha,nCol]
Return(xRet)

/*/{Protheus.doc} NwFieldPut
Alimenta novo Valor na Celula da NewGetDados
@type function Processamento
@version  1.00
@author Ricardo Mansano - alterado por mario.antonaccio
@since 06/09/2005 - alterado em 04/03/2022
@param oObjeto, object, Objeto da NewGetDados
@param cCampo, character, Nome do Campo a ser localizado
@param nLinha, numeric, Linha da GetDados, caso o parametro nao seja
                        preenchido o Default sera o nAt da NewGetDados
@param xNewValue, variant, Valor a ser inputado na Celula.
@return variant, sem retorno definido
/*/
Static Function NwFieldPut(oObjeto,cCampo,nLinha,xNewValue)
    Local nCol := aScan(oObjeto:aHeader,{|x| Upper(AllTrim(x[2])) == Upper(cCampo)})
    // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
    Default nLinha := oObjeto:nAt
    // Alimenta Celula com novo Valor se este foi preenchido
    If !Empty(xNewValue)
        oObjeto:aCols[nLinha,nCol] := xNewValue
    Endif
Return Nil

/*/{Protheus.doc} NwDeleted
Verifica se a linha da NewGetDados esta Deletada.
@type function Processamento
@version 1.00
@author Ricardo Mansano - alterado por mario.antonaccio
@since 06/09/2005 - alterado em 04/03/2022
@param oObjeto, object, Objeto da NewGetDados
@param nLinha, numeric, Linha da GetDados, caso o parametro nao seja
                        preenchido o Default sera o nAt da NewGetDados
@return logical, True = Linha Deletada / False = Nao Deletada
/*/
Static Function NwDeleted(oObjeto,nLinha)
    Local nCol := Len(oObjeto:aCols[1])
    Local lRet := .T.
    // Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
    Default nLinha := oObjeto:nAt
    // Alimenta Celula com novo Valor
    lRet := oObjeto:aCols[nLinha,nCol]
Return(lRet)

/*/{Protheus.doc} NwFieldPos
Retorna numero da coluna onde se encontra o Campo na NewGetDados
@type function Processmento
@version  1.00
@author Ricardo Mansano - alterado por mario.antonaccio
@since 06/09/2005 - alterado em 04/03/2022
@param oObjeto, object, Objeto da NewGetDados
@param cCampo, character, Nome do Campo a ser localizado
@return numeric, Numero da coluna localizada pelo aScan
              OBS: Se retornar Zero significa que nao localizou o Registro
/*/
Static Function NwFieldPos(oObjeto,cCampo)
    Local nCol := aScan(oObjeto:aHeader,{|x| Upper(AllTrim(x[2])) == Upper(cCampo)})
Return(nCol)

/*/{Protheus.doc} GravaSZC
Grava Dados para relatorio
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 06/03/2022
@return variant, sem retorno
/*/
Static Function GravaSZC()

    Local nI:=1
    Local aTexto:={}
    Local cMensagem

    //Agrega Memsagem de Tolerancia Ultrapassada
    If  lUltTolVol
        cObs+=CRLF+"Total de Massa Real MAIOR que tolerancia permitida de "+Str(SuperGetMv("EQ_OPTOLE",.F.,50) ,2,0)+ " %"
    End

    If lUltTolDen
        cObs+=CRLF+"Densidade Real MAIOR que tolerancia permitida de "+Str(SuperGetMv("EQ_OPTOLED",.F.,50) ,2,0)+ " %"
    End

    //Grava dados para Relatorio
    // OP
    RecLock("SZC",.T.)
    SZC->ZC_FILIAL  := xFilial("SZC")
    SZC->ZC_OP      := cNumOP
    SZC->ZC_NROAN   := cNAnalise
    SZC->ZC_EMISSAO := dDtEmiss
    SZC->ZC_TIPO    := "1OP"
    SZC->ZC_PRODUTO := cProduto
    SZC->ZC_UM      := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")
    SZC->ZC_LOCAL   := cLocalAr
    SZC->ZC_QTDORI  := nQtdeOri
    SZC->ZC_QTDREA  := nQtdeRea
    SZC->ZC_PERCQTD := (nQtdeRea/nQtdeOri)
    SZC->ZC_DENSORI := nDensOri
    SZC->ZC_DENSREA := nDensRea
    SZC->ZC_PERCDEN := (nDensRea/nDensOri)
    SZC->ZC_PIENORI := 0
    SZC->ZC_PIENREA := 0
    SZC->ZC_PERPIEN := 0
    SZC->ZC_OBS     := cObs
    SZC->ZC_USUARIO := UsrRetName(RetCodUsr())
    SZC->ZC_DTLIB   := dDataBase
    MsUnLock()

    // Empenho
    For nI:=1 To Len(oEmpenho:aCols)

        RecLock("SZC",.T.)
        SZC->ZC_FILIAL  := xFilial("SZC")
        SZC->ZC_OP      := cNumOP
        SZC->ZC_NROAN   := cNAnalise
        SZC->ZC_EMISSAO := dDtEmiss
        SZC->ZC_TIPO    := "EMP"
        SZC->ZC_PRODUTO := NwFieldGet(oEmpenho,"D4_COD",nI)
        SZC->ZC_LOCAL   := NwFieldGet(oEmpenho,"D4_LOCAL",nI)
        SZC->ZC_UM      := Posicione("SB1",1,xFilial("SB1")+NwFieldGet(oEmpenho,"D4_COD",nI),"B1_UM")
        SZC->ZC_QTDORI  := NwFieldGet(oEmpenho,"D4_QTDEORI",nI)
        SZC->ZC_QTDREA  := NwFieldGet(oEmpenho,"GXT_QTREAL",nI)
        SZC->ZC_PERCQTD := (NwFieldGet(oEmpenho,"GXT_QTREAL",nI)/NwFieldGet(oEmpenho,"D4_QTDEORI",nI))
        SZC->ZC_DENSORI := nDensOri
        SZC->ZC_DENSREA := nDensRea
        SZC->ZC_PERCDEN := (nDensRea/nDensOri)
        SZC->ZC_PIENORI := 0
        SZC->ZC_PIENREA := 0
        SZC->ZC_PERPIEN := 0
        SZC->ZC_OBS     := If( NwDeleted(oEmpenho,nI),"Deletado"," ")
        SZC->ZC_USUARIO := UsrRetName(RetCodUsr())
        SZC->ZC_DTLIB   := dDataBase
        MsUnLock()
    Next

    // Envase
    For nI:=1 To Len(oEnvase:aCols)
        RecLock("SZC",.T.)
        SZC->ZC_FILIAL  := xFilial("SZC")
        SZC->ZC_OP      := NwFieldGet(oEnvase,"NUMOP",nI)
        SZC->ZC_NROAN   := cNAnalise
        SZC->ZC_EMISSAO := dDtEmiss
        SZC->ZC_TIPO    := "ENV"
        SZC->ZC_PRODUTO := NwFieldGet(oEnvase,"PROD",nI)
        SZC->ZC_UM      := NwFieldGet(oEnvase,"UM",nI)
        SZC->ZC_LOCAL   := IF(NwFieldGet(oEnvase,"PROD",nI)==cProduto,cLocalAr,NwFieldGet(oEnVase,"ARMAZ",nI))
        SZC->ZC_QTDORI  := NwFieldGet(oEnvase,"QTDENVORI",nI)
        SZC->ZC_QTDREA  := NwFieldGet(oEnvase,"QTDENVREA",nI)
        SZC->ZC_PERCQTD := (NwFieldGet(oEmpenho,"GXT_QTREAL",nI)/NwFieldGet(oEmpenho,"D4_QTDEORI",nI))
        SZC->ZC_DENSORI := nDensOri
        SZC->ZC_DENSREA := nDensRea
        SZC->ZC_PERCDEN := (nDensRea/nDensOri)
        SZC->ZC_PIENORI := NwFieldGet(oEnvase,"QTDPIORI",nI)
        SZC->ZC_PIENREA := NwFieldGet(oEnvase,"QTDPIREA",nI)
        SZC->ZC_PERPIEN := (1-(NwFieldGet(oEnvase,"QTDPIORI",nI)/NwFieldGet(oEnvase,"QTDPIREA",nI)))*100
        SZC->ZC_OBS     := " "
        SZC->ZC_USUARIO := UsrRetName(RetCodUsr())
        SZC->ZC_DTLIB   := dDataBase
        MsUnLock()
    Next

    If nQtdeOri > nQtdeRea // perda
        RecLock("SZC",.T.)
        SZC->ZC_FILIAL   := xFilial("SZC")
        SZC->ZC_OP       := cNumOp
        SZC->ZC_NROAN    := cNAnalise
        SZC->ZC_EMISSAO  := dDtEmiss
        SZC->ZC_TIPO     := "ZPD"
        SZC->ZC_PRODUTO  := cProduto
        SZC->ZC_UM       := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM")
        SZC->ZC_LOCAL    := " " //Armazem de perda
        SZC->ZC_QTDORI   := 0
        SZC->ZC_QTDREA   := nQtdeOri - nQtdeRea
        SZC->ZC_PERCQTD  := 0
        SZC->ZC_DENSORI  := 0
        SZC->ZC_DENSREA  := 0
        SZC->ZC_PERCDEN  := 0
        SZC->ZC_PIENVORI := 0
        SZC->ZC_PIENVREA := 0
        SZC->ZC_PERCPIEN := 0
        SZC->ZC_OBS      := " "
        SZC->ZC_USUARIO  := UsrRetName(RetCodUsr())
        SZC->ZC_DTLIB    := dDataBase
        MsUnLock()
    End

    //Dispara e-mail quado ultrapassa tolerancia
    If lUltTolVol .or. lUltTolDen
        cEmail:=SuperGetMv("QE_MLTOLOP",.F.,"mario.antonaccio@euroamerican.com.br;alexsandro.blasques@qualyvinil.com")

        cMensagem:="<h2>Prezados</h2>"
        cMensagem+="<p>A OP <u> <strong>"+cNumOp+"</strong> teve tolerancia Ultrapassada </u></p>"
        If  lUltTolVol
            cMensagem+="<p>em Volume </u></p>"
        End
        If   lUltTolDen
            cMensagem+="<p>em Densidade </u></p>"
        End
        aTexto:=U_zMemoToA(SZC->ZC_OBS,80)
        For nI:=1 to Len(aTexto)
            cMensagem+=aTexto[nI]
        Next
        cMensagem+="</tbody>"
        cMensagem+="</table>"
        cMensagem+="<p>"+" "+"</p>"
        cMensagem+="<p>Atenciosamente</p>"

        U_CPEmail(cEmail," ","Tolerancia OP Ultrpassada",cMensagem,"",.F.)
    End

Return

/*/{Protheus.doc} EstorPI
Estorna a OP Original
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 06/03/2022
@return variant, Sem retorno - Salvose Der Erro de ExecAturo
/*/
Static Function EstorPI()

    Local aMata650:={}
    Private lMsErroAuto:=.F.

    /// Estorno OP para reciar novamente com nova quantiade e empenho

    aMATA650 :={{ 'C2_FILIAL' ,cFilAnt ,NIL},;
        {'C2_NUM'                   , Substr(cNumOp,1,6), NIL},;
        {'C2_ITEM'                  , Substr(cNumOP,7,2), NIL},;
        {'C2_SEQUEN'                , substr(cNumOp,9,3), NIL},;
        {'C2_PRODUTO'               , cProduto          , NIL},;
        {'C2_LOCAL'                 , cLocalAr          , NIL},;
        {'C2_QUANT'                 , nQtdeOri          , NIL},;
        {'C2_DATPRI'                , dDtEmiss          , NIL},;
        {'C2_DATPRF'                , dDtPrf            , NIL},;
        {'AUTEXPLODE'               , "S"               , NIL}} // Indica de explode empenho

    ///Se For Qualy, antes de estornar pega o Horario Inicial para a operação 40
    If cFilAnt == "0803"
        SH6->(dbSetOrder(1))
        If SH6->(dbSeek(xFilial("SH6")+cNumOP+cProduto+"40"))
            cTempoIni:=SH6->H56_HORAINI
            dDataIni:=SH6->H6_DATAINI
        End
    End

    SC2->(DbSetOrder(1))//FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
    SC2->(DbSeek(xFilial("SC2")+cNumOP))

    msExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)

    If lMsErroAuto
        MostraErro()
    End

Return(!(lMsErroAuto))


/*/{Protheus.doc} EstorEnv
Estorna a OP dos Envases
@type function Processameto
@version  1.00
@author mario.antonaccio
@since 06/03/2022
@return variant, Sem retorno - Salvose Der Erro de ExecAturo
/*/
Static Function EstorEnv()

    Local nI
    Local aMata650:={}
    Local cOpEnv
    Private lMsErroAuto:=.F.

    /// Estorno OP para reciar novamente com nova quantiade e empenho

    For nI:=1 To Len(oEnvase:aCols)

        cOpEnv:=NwFieldGet(oEnvase,"NUMOP",nI)

        aMATA650 :={{ 'C2_FILIAL' ,cFilAnt ,NIL},;
            {'C2_NUM'                   , Substr(cOpEnv,1,6)                , NIL},;
            {'C2_ITEM'                  , Substr(cOPEnv,7,2)                , NIL},;
            {'C2_SEQUEN'                , substr(cOpEnv,9,3)                , NIL},;
            {'C2_PRODUTO'               , NwFieldGet(oEnvase,"PROD",nI)     , NIL},;
            {'C2_LOCAL'                 , NwFieldGet(oEnvase,"ARMAZ",nI)    , NIL},;
            {'C2_QUANT'                 , NwFieldGet(oEnvase,"QTDENVORI",nI), NIL},;
            {'C2_DATPRI'                , dDtEmiss                          , NIL},;
            {'C2_DATPRF'                , dDtPrf                            , NIL},;
            {'AUTEXPLODE'               , "S"                               , NIL}} // Indica de explode empenho

        SC2->(DbSetOrder(1))//FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
        SC2->(DbSeek(xFilial("SC2")+cOPEnv))

        msExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)

        If lMsErroAuto
            MostraErro()
            Exit
        End

    Next
Return(!(lMsErroAuto))


/*/{Protheus.doc} GrvOPPI
Grava a OP Original
@type function Processameto
@version  1.00
@author mario.antonaccio
@since 06/03/2022
@return variant, Sem retorno - Salvose Der Erro de ExecAturo
/*/
Static Function GrvOPPI()

    Local aMata650:={}
    Private lMsErroAuto:=.F.

    /// Estorno OP para reciar novamente com nova quantidade e empenho

    aMATA650 :={{ 'C2_FILIAL' ,cFilAnt ,NIL},;
        {'C2_NUM'                   , Substr(cNumOp,1,6), NIL},;
        {'C2_ITEM'                  , Substr(cNumOP,7,2), NIL},;
        {'C2_SEQUEN'                , substr(cNumOp,9,3), NIL},;
        {'C2_PRODUTO'               , cProduto          , NIL},;
        {'C2_LOCAL'                 , cLocalAr          , NIL},;
        {'C2_QUANT'                 , nQtdeRea          , NIL},;
        {'C2_DATPRI'                , dDataBase         , NIL},;
        {'C2_DATPRF'                , dDataBase         , NIL},;
        {'AUTEXPLODE'               , "N"               , NIL}} // Indica de explode empenho

    msExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
    If lMsErroAuto
        MostraErro()
    Else
        RecLock("SC2",.F.)
        SC2->C2_DATPRI  := dDtPri
        SC2->C2_DATPRF  := dDtPrf
        SC2->C2_EMISSAO := dDtEMiss
        MsUnlock()
    End
Return(!(lMsErroAuto))

/*/{Protheus.doc} GrvOPEMP
Estorna a OP Original e grava ujmanova com o mesmo Numero
@type function Processameto
@version  1.00
@author mario.antonaccio
@since 06/03/2022
@return variant, Sem retorno - Salvose Der Erro de ExecAturo
/*/
Static Function GrvOPEMP()

    Local nI
    Local aCabec:={}
    Local aItens:={}
    Local aItem:={}
    Private lMsErroAuto:=.F.

    //Monta o cabeçalho com o número da OP que será utilizada para inclusão dos empenhos.
    aCabec := {{"D4_OP",cNumOP+Space(03),NIL}}

    //Adiciona novo empenho
    For nI:=1 to Len(oEmpenho:aCols)
        If NwDeleted(oEmpenho,nI)
            Loop
        End
        aItens := {}
        aadd(aItens, {"D4_COD"    , NwFieldGet(oEmpenho,"D4_COD",nI)    , NIL})
        aadd(aItens, {"D4_LOCAL"  , NwFieldGet(oEmpenho,"D4_LOCAL",nI)  , NIL})
        aadd(aItens, {"D4_DATA"   , dDtEmiss                            , NIL})
        aadd(aItens, {"D4_OP"     , cNumOp                              , NIL})
        aadd(aItens, {"D4_QTDEORI", NwFieldGet(oEmpenho,"GXT_QTREAL",nI), NIL})
        aadd(aItens, {"D4_QUANT"  , NwFieldGet(oEmpenho,"GXT_QTREAL",nI), NIL})
        aadd(aItens, {"D4_TRT"    , "001"                               , NIL})
        //Adiciona a linha do empenho no array de itens.
        aAdd(aItem,aItens)
    Next
    MSExecAuto({|x,y,z| mata381(x,y,z)},aCabec,aItem,3)
    If lMsErroAuto
        MostraErro()
    EndIf
Return(!(lMsErroAuto))

/*/{Protheus.doc} GrvBxPI
Baixa  OP Original
@type function Processameto
@version  1.00
@author mario.antonaccio
@since 06/03/2022
@return variant, Sem retorno - Salvo se Der Erro de ExecAturo
/*/
Static Function GrvBXPI()

    Local aOper:={}
    Local aVetor:={}
    Local aRefugos:={}
    Local cRoteiro:=""
    Local nI
    Local nPerda:=If(nQtdeOri > nQtdeRea,nQtdeOri - nQtdeRea,0)
    Private lMsErroAuto:=.F.

    If cFilAnt == "0200"
        /// Estorno OP para reciar novamente com nova quantiade e empenho
        aVetor :={{"D3_OP" ,cNumOp ,NIL},;
            {"D3_PERDA"           , nPerda, NIL},;
            {"D3_TM"              , "001" , NIL}}

        If nPerda > 0
            aRefugos :={{"BC_PRODUTO" , cProduto ,Nil},;
                {"BC_LOCORIG"                 , cLocalAr, Nil},;
                {"BC_TIPO"                    , "R"     , Nil},;
                {"BC_MOTIVO"                  , "FH"    , Nil},;
                {"BC_QUANT"                   , nPerda  , Nil}}

            aAdd(aVetor, {"AUTREFUGO", aRefugos, Nil})
        End

        MSExecAuto({|x, y| mata250(x, y)},aVetor, 3 )

    ElseIf cFilAnt == "0803"

        //Verifico os roteiros
        SG2->(dbSetOrder(1))
        SG2->(dbSeek(xFilial("SG2")+cProduto+"01"))
        While SG2->(!EOF()) .and. SG2->G2_PRODUTO == cProduto
            If SG2->G2_OPERAC > '40'
                SG2->(dbSkip())
                Loop
            End
            AADD(aOper,{SG2->G2_OPERAC,SG2->G2_RECURSO})
            SG2->(dbSkip())
        End

        For nI:=1 To Len(aOper)
            cRoteiro+=aOper[nI,1]+If(nI == Len(aOper),"",";")
        Next

        For nI:=1 To Len(aOper)
            aVetor :={{"H6_FILIAL" ,cFilAnt ,NIL},;
                {"H6_OP"                   , cNumOP                                       , NIL},;
                {"H6_PRODUTO"              , cProduto                                     , NIL},;
                {"H6_OPERAC"               , aOper[nI,1]                                  , NIL},;
                {"H6_RECURSO"              , aOper[nI,2]                                  , NIL},;
                {"H6_DTAPONT"              , dDataBase                                    , NIL},;
                {"H6_DATAINI"              , dDataIni                                     , NIL},;
                {"H6_HORAINI"              , cTempoINI                                    , NIL},;
                {"H6_DATAFIN"              , dDataBase                                    , NIL},;
                {"H6_HORAFIN"              , Substring(IncTime( TIME() , 0 , 3 , 00 ),1,5), NIL},;
                {"H6_PT"                   , 'T'                                          , NIL},;
                {"H6_LOCAL"                , cLocalAr                                     , NIL},;
                {"H6_QTDPERD"              , nPerda                                       , NIL},;
                {"H6_QTDPROD"              , nQtdeRea                                     , NIL}}

            //chamada ExecAuto
            //MSExecAuto({|v,x,y,z| MATA681(v,x,y,z)},"SH6",0,3,aVetor)
            MSExecAuto({|x| mata681(x)},aVetor)

            If lMsErroAuto
                MostraErro()
                Exit
            Else
                CBH->(dbSetOrder(5))
                If CBH->(dbSeek(xFilial(CBH)+cNumOP+aOper[nI,1] ))
                    RecLokc("SH6",.F.)
                    SH6->H6_DATAINI:=CBH->CBH_DTINI
                    SH6->H6_HORAINI:=CBH->CBH_HRINI
                    SH6->H6_DATAFIN:=CBH->CBH_DTFIM
                    SH6->H6_HORAFIN:=CBH->CBH_HRFIM
                    MsUnLock()
                End
            End
        Next
    End
Return(!(lMsErroAuto))

/*/{Protheus.doc} GrvOPEnv
Grava as Ops de envase
@type function Processameto
@version  1.00
@author mario.antonaccio
@since 06/03/2022
@return variant, Sem retorno - Salvose Der Erro de ExecAturo
/*/
Static Function GrvOPEnv()

    Local nI
    Local cItem
    Local aMata650:={}
    Private lMsErroAuto:=.F.

    ///OP para reciar novamente com nova quantidade e empenho
    For nI:=1 To Len(oEnvase:aCols)

        cOpEnv:=NwFieldGet(oEnvase,"NUMOP",nI)
        cItem:=Soma1(substr(cOpEnv,9,3) ,3)

        aMATA650 :={{ 'C2_FILIAL' ,cFilAnt ,NIL},;
            {'C2_NUM'                   , Substr(cOpEnv,1,6)                     , NIL},;
            {'C2_ITEM'                  , Substr(cOPEnv,7,2)                     , NIL},;
            {'C2_SEQUEN'                , substr(cOpEnv,9,3)                     , NIL},;
            {'C2_PRODUTO'               , NwFieldGet(oEnvase,"PROD",nI)          , NIL},;
            {'C2_LOCAL'                 , NwFieldGet(oEnvase,"ARMAZ",nI)         , NIL},;
            {'C2_QUANT'                 , Int(NwFieldGet(oEnvase,"QTDENVREA",nI)), NIL},;
            {'C2_DATPRI'                , dDatabase                              , NIL},;
            {'C2_DATPRF'                , dDataBase                              , NIL},;
            {'AUTEXPLODE'               , "S"                                    , NIL}} // Indica de explode empenho

        msExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)
        If lMsErroAuto
            MostraErro()
            Exit
        Else
            //Acerta Qtde Empenho Conforme o calculo
            RecLock("SC2",.F.)
            SC2->C2_DATPRI:=dDtPri
            SC2->C2_DATPRF:=dDtPrf
            SC2->C2_EMISSAO:=dDtEMiss
            SC2->C2_XLIBOP:="1"
            MsUnLock()
            SD4->(dbSetOrder(2))
            If  SD4->(dbSeek(xFilial("SD4")+NwFieldGet(oEnvase,"NUMOP",nI)+Space(03)+cProduto+cLocalAr))
                RecLock("SD4",.F.)
                //SD4->D4_DATA    := dDtEmiss
                SD4->D4_QTDEORI := NwFieldGet(oEnvase,"QTDPIREA",nI)
                SD4->D4_QUANT   := NwFieldGet(oEnvase,"QTDPIREA",nI)
                MsUnLock()
            End
        End
    Next

Return(!(lMsErroAuto))

/*/{Protheus.doc} zMemoToA
Função Memo To Array, que quebra um texto em um array conforme número de colunas
@type function Processamento
@version 1.00
@author Atilio
@since 15/08/2014
@param cTexto, Character, Texto que será quebrado (campo MEMO)
@param nMaxCol, Numeric, Coluna máxima permitida de caracteres por linha
@param cQuebra, Character, Quebra adicional, forçando a quebra de linha além do enter (por exemplo '<br>')
@param lTiraBra, Logical, Define se em toda linha será retirado os espaços em branco (Alltrim)
@return array, array com as linhas de texto

Exemplo
cCampoMemo := SB1->B1_X_TST
nCol        := 200
aDados      := u_zMemoToA(cCampoMemo, nCol)
obs Difere da MemoLine(), pois já retorna um Array pronto para impressão
/*/

User Function zMemoToA(cTexto, nMaxCol, cQuebra, lTiraBra)
    Local aArea     := GetArea()
    Local aTexto    := {}
    Local aAux      := {}
    Local nAtu      := 0
    Default cTexto  := ''
    Default nMaxCol := 80
    Default cQuebra := ';'
    Default lTiraBra:= .T.
    //Quebrando o Array, conforme -Enter-
    aAux:= StrTokArr(cTexto,Chr(13))

    //Correndo o Array e retirando o tabulamento
    For nAtu:=1 TO Len(aAux)
        aAux[nAtu]:=StrTran(aAux[nAtu],Chr(10),'')
    Next

    //Correndo as linhas quebradas
    For nAtu:=1 To Len(aAux)

        //Se o tamanho de Texto, for maior que o número de colunas
        If (Len(aAux[nAtu]) > nMaxCol)

            //Enquanto o Tamanho for Maior
            While (Len(aAux[nAtu]) > nMaxCol)
                //Pegando a quebra conforme texto por parÃ¢metro
                nUltPos:=RAt(cQuebra,SubStr(aAux[nAtu],1,nMaxCol))

                //Caso não tenha, a última posição será o último espaço em branco encontrado
                If nUltPos == 0
                    nUltPos:=Rat(' ',SubStr(aAux[nAtu],1,nMaxCol))
                EndIf

                //Se não encontrar espaço em branco, a última posição será a coluna máxima
                If(nUltPos==0)
                    nUltPos:=nMaxCol
                EndIf

                //Adicionando Parte da Sring (de 1 até a Ãšlima posição válida)
                aAdd(aTexto,SubStr(aAux[nAtu],1,nUltPos))

                //Quebrando o resto da String
                aAux[nAtu] := SubStr(aAux[nAtu], nUltPos+1, Len(aAux[nAtu]))
            EndDo

            //Adicionando o que sobrou
            aAdd(aTexto,aAux[nAtu])
        Else
            //Se for menor que o Máximo de colunas, adiciona o texto
            aAdd(aTexto,aAux[nAtu])
        EndIf
    Next

    //Se for para tirar os brancos
    If lTiraBra
        //Percorrendo as linhas do texto e aplica o AllTrim
        For nAtu:=1 To Len(aTexto)
            aTexto[nAtu] := Alltrim(aTexto[nAtu])
        Next
    EndIf

    RestArea(aArea)
Return (aTexto)

/*/{Protheus.doc} EQANAOPR
Chamada do relatorio
@type function Tela
@version  1.00
@author mario.antonaccio
@since 26/02/2022
@return Character, sem retorno definido
/*/
User Function EQANAOPR()
    Local aButtons := {}
    Local aSays    := {}
    Local cTitoDlg := "Relatorio de Analise De OP"
    Local nOpca    := 0

    If SC2->C2_XLIBOP <> "1"
        MsgInfo("Relatorio so pode ser Extraido de OP ja Analisadas","Sem Analise")
        Return
    End

    aAdd(aSays, "Está rotina tem como objetivo gerar o relatorio")
    aAdd(aSays, "Analise OP de No."+RTRIM(SZC->ZC_OP))
    aAdd(aSays, "Para análise das alterações.")

    aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
    aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

    FormBatch(cTitoDlg, aSays, aButtons)

    If nOpca == 1
        Processa( {|| EQANAOPR1() }, "Extração de Dados", "Gerando Registros...", .F.)
    EndIf
Return (nil)

/*/{Protheus.doc} EQANAOPR1
Geração do relatorio de Antes/Depois Analise OP
@type function Tela
@version  1.00
@author mario.antonaccio
@since 26/02/2022
@return Character, sem retorno definido
/*/

Static Function EQANAOPR1()

    Local cArqDst   := "C:\TOTVS\ANOP_"+RTRIM(cNumOp) + StrTran(Time(),":","") + ".XML"
    Local cTipo     := " "
    Local cTitPla   := "Ordem de Producao No. "+AllTrim(cNumOp)
    Local cNomePla  := "Analise OP"
    Local lAbre     := .F.
    Local nI        := 0
    Local nTotReg   := 0
    Local aLinhaAux :={}
    Local aLinhaBca :={" "," "," "," "," "," "," "," "," ",0,0,0,0,0,0,0,0,0," "," "," "}

    //Deixa a planilha  sen o azul no corpo
    /*
    oExcel:SetLineFrColor("#000000")
    oExcel:SetLineBgColor("#FFFFFF")
    oExcel:Set2LineFrColor("#000000")
    oExcel:Set2LineBgColor("#FFFFFF")
    */

    oExcel:AddworkSheet(cNomePla)
    oExcel:AddTable(cNomePla, cTitPla)

    If SELECT(_TMP) > 0
        (_TMP)->(dbCloseArea())
    End

    BeginSql Alias _TMP
        SELECT
            ZC_FILIAL,
            ZC_OP,
            ZC_EMISSAO,
            ZC_TIPO,
            ZC_PRODUTO,
            ZC_UM,
            ZC_LOCAL,
            ZC_QTDORI,
            ZC_QTDREA,
            ZC_PERCQTD,
            ZC_DENSORI,
            ZC_DENSREA,
            ZC_PERCDEN,
            ZC_PIENORI,
            ZC_PIENREA,
            ZC_PERPIEN,
            ZC_USUARIO,
            ZC_DTLIB,
            ZC_NROAN,
            R_E_C_N_O_ AS REG
        FROM
            %Table:SZC%
        WHERE
            ZC_FILIAL = %Exp:xFilial("SZC")%
            AND SUBSTRING(ZC_OP, 1, 6) = %exp:SUBSTRING(SZC->ZC_OP,1,6)%
        ORDER BY
            ZC_OP,
            ZC_TIPO
    EndSql

    //Monta Excel Dinamico conforme os campos selecionados
    oExcel:AddColumn(cNomePla, cTitPla,"Filial", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"No.OP", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"No.Analise", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Emissao", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Tipo", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Produto", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Descricao", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"UM", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Local", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Qtde.Orig", 2, 3, .F.,"999,999.99")
    oExcel:AddColumn(cNomePla, cTitPla,"Qtde.Real", 2, 3, .F.,"999,999.99")
    oExcel:AddColumn(cNomePla, cTitPla,"% Qtde", 2, 3, .F.,"999.9999")
    oExcel:AddColumn(cNomePla, cTitPla,"Densid.Orig", 2, 3, .F.,"999.9999")
    oExcel:AddColumn(cNomePla, cTitPla,"Densid.Real", 2, 3, .F.,"999.9999")
    oExcel:AddColumn(cNomePla, cTitPla,"% Densid.", 2, 3, .F.,"999.9999")
    oExcel:AddColumn(cNomePla, cTitPla,"Qtd.PI Env.Orig.", 2, 3, .F.,"999,999.99")
    oExcel:AddColumn(cNomePla, cTitPla,"Qtd.PI Env.Real.", 2, 3, .F.,"999,999.99")
    oExcel:AddColumn(cNomePla, cTitPla,"% Qtd.PI", 2, 3, .F.,"999.9999")
    oExcel:AddColumn(cNomePla, cTitPla,"Usuario", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Data Liber.", 1, 1, .F.)
    oExcel:AddColumn(cNomePla, cTitPla,"Observaçoes", 1, 1, .F.)

    nTotReg := Contar((_TMP),"!EOF()")
    (_TMP)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_TMP)->(!EOF())

        IncProc()

        lAbre:=.T.

        If (_TMP)->ZC_TIPO == "1OP"
            cTipo:="Ordem Producao"
        ElseIf  (_TMP)->ZC_TIPO == "RES"
            cTipo:="Resumo"
            oExcel:AddRow(cNomePla, cTitPla,aLinhaBca)
        ElseIf (_TMP)->ZC_TIPO =="EMP"
            cTipo:="Empenho PI"
        ElseIf (_TMP)->ZC_TIPO =="ENV"
            cTipo:="OP Envase"
            oExcel:AddRow(cNomePla, cTitPla,aLinhaBca)
        ElseIf (_TMP)->ZC_TIPO =="ZPD"
            cTipo:="Perda PI"
            oExcel:AddRow(cNomePla, cTitPla,aLinhaBca)
        End

        aLinhaAux:={}

        AADD(aLinhaAux,(_TMP)->ZC_FILIAL)
        AADD(aLinhaAux,(_TMP)->ZC_OP)
        AADD(aLinhaAux,(_TMP)->ZC_NROAN)
        AADD(aLinhaAux,DTOC(STOD((_TMP)->(ZC_EMISSAO))))
        AADD(aLinhaAux,cTipo)
        AADD(aLinhaAux,(_TMP)->ZC_PRODUTO)
        AADD(aLinhaAux,Posicione("SB1",1,xFilial("SB1")+(_TMP)->ZC_PRODUTO,"B1_DESC"))
        AADD(aLinhaAux,(_TMP)->ZC_UM)
        AADD(aLinhaAux,(_TMP)->ZC_LOCAL)
        AADD(aLinhaAux,(_TMP)->ZC_QTDORI)
        AADD(aLinhaAux,(_TMP)->ZC_QTDREA)
        AADD(aLinhaAux,(_TMP)->ZC_PERCQTD)
        AADD(aLinhaAux,(_TMP)->ZC_DENSORI)
        AADD(aLinhaAux,(_TMP)->ZC_DENSREA)
        AADD(aLinhaAux,(_TMP)->ZC_PERCDEN)
        AADD(aLinhaAux,(_TMP)->ZC_PIENORI)
        AADD(aLinhaAux,(_TMP)->ZC_PIENREA)
        AADD(aLinhaAux,(_TMP)->ZC_PERPIEN)
        AADD(aLinhaAux,(_TMP)->ZC_USUARIO)
        AADD(aLinhaAux,DTOC(STOD((_TMP)->(ZC_DTLIB))))

        If (_TMP)->ZC_TIPO $ "1OP/RES"  //OP e Resumo

            SZC->(dbGoTo((_TMP)->REG))
            aTexto:=U_zMemoToA(SZC->ZC_OBS,80)
            AADD(aLinhaAux,aTexto[1])

            oExcel:AddRow(cNomePla, cTitPla,aLinhaAux)

            //Gera as proximas Linhas
            For nI:=2 To Len(aTexto)
                oExcel:AddRow(cNomePla, cTitPla,{;
                    " ",;
                    " ",;
                    " ",;
                    " ",;
                    " ",;
                    " ",;
                    " ",;
                    " ",;
                    " ",;
                    0,;
                    0,;
                    0,;
                    0,;
                    0,;
                    0,;
                    0,;
                    0,;
                    0,;
                    " ",;
                    " ",;
                    aTexto[nI]})
            Next

        Else

            AADD(aLinhaAux," ")
            oExcel:AddRow(cNomePla, cTitPla,aLinhaAux)

        End

        (_TMP)->(dbSkip())

    End
    (_TMP)->(dbCloseArea())

    If lAbre
        oExcel:Activate()
        oExcel:GetXMLFile(cArqDst)
        OPENXML(cArqDst)
        oExcel:DeActivate()
    Else
        MsgInfo("Nao existem dados para serem impressos.", "SEM DADOS")
    EndIf

Return

/*/{Protheus.doc} OPENXML
Abertura do arquivo XML Gerado
@type function Files
@version  1.00
@author mario.antonaccio
@since 16/12/2021
@param cArq, character, Nome do Arquivo XML
@return character, sem retorno
/*/
Static Function OPENXML(cArq)

    If !ApOleClient("MsExcel")
        Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
    Else
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open(cArq)
        oExcelApp:SetVisible(.T.)
        oExcelApp:Destroy()
    EndIf

Return

/*/{Protheus.doc} EQANAOPV
Tela de Demosntração de Visualização da Analise
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 26/02/2022
@return Character, sem retorno definido
/*/
User Function EQANAOPV()

    Local nOpcEmp      := 0
    Local nOpcEnv      := 0
    Private aCoEmpenho := {}
    Private aCoEnvase  := {}
    Private aHoEmpenho := {}
    Private aHoEnvase  := {}
    Private aSomaEnv   := {}
    Private cLocalAr   := Space(02)
    Private cNAnalise  := ""
    Private cNproduto  := Space(30)
    Private cObs       := " "
    Private cProduto   := Space(15)
    Private cTempoIni  := Substr(TIME(),1,5)
    Private cUMOri     := Space(02)
    Private cUMRea     := Space(02)
    Private dDataApon  := dDataBase
    Private dDataIni   := dDataBase
    Private dDtEmiss   := CtoD(" ")
    Private dDtPrf     := CtoD(" ")
    Private dDtPri     := CtoD(" ")
    Private lFim       := .F.
    Private nDensRea   := 0
    Private nDifEnv    := 0
    Private noEmpenho  := 0
    Private noEnvase   := 0
    Private nPercDens  := 0
    Private nPercQtd   := 0
    Private nQtdeOri   := 0
    Private nQtdeRea   := 0
    Private nSomaEnv   := 0
    Private nTotMassa  := 0

    SetPrvt("oNegrito","oAnaop","oPOP","oSay1","oSay2","oSay4","oSay3","oSay5","oSay6","oSay8","oSay7","oSay9")
    SetPrvt("oDtEmiss","oDtEntrega","oLocalAr","oProduto","oNproduto","oQtdeOri","oQtdeRea","oDensOri","oDensRea")
    SetPrvt("oEmpenho","oPEnvase","oEnvase","oPObs","oObs","oCancela","oConfirma","oTotMassa","oUMRea","oUMOri",,"oPercQtd","oPercDens")

    If SELECT(_TMP) > 0
        (_TMP)->(dbCloseArea())
    End

    BeginSql Alias _TMP
        SELECT
            ZC_FILIAL,
            ZC_OP,
            ZC_EMISSAO,
            ZC_TIPO,
            ZC_PRODUTO,
            ZC_UM,
            ZC_LOCAL,
            ZC_QTDORI,
            ZC_QTDREA,
            ZC_PERCQTD,
            ZC_DENSORI,
            ZC_DENSREA,
            ZC_PERCDEN,
            ZC_PIENORI,
            ZC_PIENREA,
            ZC_PERPIEN,
            ZC_USUARIO,
            ZC_DTLIB,
            ZC_NROAN,
            R_E_C_N_O_ AS REG
        FROM
            %Table:SZC%
        WHERE
            ZC_FILIAL = %Exp:xFilial("SZC")%
            AND SUBSTRING(ZC_OP, 1, 6) = %exp:SC2->C2_NUM%
        ORDER BY
            ZC_OP,
            ZC_TIPO
    EndSql

    SC2->(dbSetOrder(1))
    SC2->(dbSeek(xFilial("SC2")+(_TMP)->ZC_OP))



    cNumOP     := (_TMP)->ZC_OP
    dDtEmiss   := STOD((_TMP)->ZC_EMISSAO)
    dDtPri     := SC2->C2_DATPRI
    dDtPrF     := SC2->C2_DATPRF
    cLocalAr   := (_TMP)->ZC_LOCAL
    cProduto   := (_TMP)->ZC_PRODUTO
    cNProduto  := Posicione("SB1",1,xFilial("SB1")+(_TMP)->ZC_PRODUTO,"B1_DESC")
    cUMORI     := (_TMP)->ZC_UM
    cUMREA     := (_TMP)->ZC_UM
    nQtdeOri   := (_TMP)->ZC_QTDORI
    nQtdeRea   := (_TMP)->ZC_QTDREA
    nPercQtd   := (_TMP)->ZC_PERCQTD
    nDensOri   := (_TMP)->ZC_DENSORI
    nDensRea   := (_TMP)->ZC_DENSREA
    nPercDen   := (_TMP)->ZC_PERCDEN
    cNAnalise  := (_TMP)->zC_NROAN


    //Definicao do Dialog e todos os seus componentes.
    //oNegrito   := TFont():New( "MS Sans Serif",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )
    oNegrito   := TFont():New( "MS Sans Serif",0,-11,,.F.,0,,700,.F.,.F.,,,,,, )

    oAnaop     := MSDialog():New( 138,213,663,1331,"Analise de OP - Visualização",,,.F.,,,,,,.T.,,oNegrito,.T. )

    oPOP   := TGroup():New(004, 008, 092                     , 332 , " Dados OP ", oAnaop  , CLR_BLACK, CLR_WHITE, .T., .F.)
    oSay1  := TSay()  :New(016, 012, {||"Numero "}           , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 024, 008)
    oSay2  := TSay()  :New(016, 104, {||"Data Emissao"}      , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay4  := TSay()  :New(016, 192, {||"Data Entrega"}      , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay3  := TSay()  :New(016, 280, {||"Local"}             , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 020, 008)
    oSay5  := TSay()  :New(031, 012, {||"Produto"}           , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 024, 008)
    oSay6  := TSay()  :New(046, 012, {||"Quantidade OP"}     , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay8  := TSay()  :New(046, 180, {||"Densidade Original"}, oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 056, 008)
    oSay7  := TSay()  :New(060, 012, {||"Quantidade Real"}   , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 060, 008)
    oSay9  := TSay()  :New(060, 180, {||"Densidade Real"}    , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 056, 008)
    oSay12 := TSay()  :New(076, 012, {||"% Quanttidade"}     , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 044, 008)
    oSay13 := TSay()  :New(076, 180, {||"% Densidade"}       , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 048, 008)
    oSay10 := TSay()  :New(212, 012, {||"Total Massa"}       , oPOP,             , oNegrito, .F.      , .F.      , .F., .T., CLR_BLACK, CLR_WHITE, 040, 008)

    oNumOP     := TGet():New(014, 040, {|u| If(PCount()>0,cNumOP:=u,cNumOP)}      , oPOP, 060, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cNumOP"   , , , ,)
    oDtEmiss   := TGet():New(014, 148, {|u| If(PCount()>0,dDtEmiss:=u,dDtEmiss)}  , oPOP, 040, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "dDtEmiss" , , , ,)
    oDtEntrega := TGet():New(014, 236, {|u| If(PCount()>0,dDtPrf:=u,dDtPrf)}      , oPOP, 040, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "dDtPrf"  , , , ,)
    oLocalAr   := TGet():New(014, 300, {|u| If(PCount()>0,cLocalAr:=u,cLocalAr)}  , oPOP, 024, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cLocalAr" , , , ,)
    oProduto   := TGet():New(030, 040, {|u| If(PCount()>0,cProduto:=u,cProduto)}  , oPOP, 060, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cProduto" , , , ,)
    oNproduto  := TGet():New(030, 104, {|u| If(PCount()>0,cNproduto:=u,cNproduto)}, oPOP, 220, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cNproduto", , , ,)
    oQtdeOri   := TGet():New(045, 068, {|u| If(PCount()>0,nQtdeOri:=u,nQtdeOri)}  , oPOP, 060, 008, '@ER 999,999.9999', , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nQtdeOri" , , , ,)
    oUMOri     := TGet():New(045, 132, {|u| If(PCount()>0,cUMOri:=u,cUMOri)}      , oPOP, 016, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cUMOri"   , , , ,)
    oQtdeRea   := TGet():New(060, 068, {|u| If(PCount()>0,nQtdeRea:=u,nQtdeRea)}  , oPOP, 060, 008, '@ER 999,999.9999', , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nQtdeRea" , , , ,)
    oUMRea     := TGet():New(060, 132, {|u| If(PCount()>0,cUMRea:=u,cUMRea)}      , oPOP, 016, 008, ''                , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "cUMRea"   , , , ,)
    oPercQtd   := TGet():New(076, 068, {|u| If(PCount()>0,nPercQtd:=u,nPercQtd)}  , oPOP, 060, 008, '@ER 999.9999'    , , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nPercQtd" , , , ,)

    oQtdeRea  := TGet():New(060, 068, {|u| If(PCount()>0,nQtdeRea:=u,nQtdeRea)}  , oPOP  , 060, 008, '@ER 999,999.9999',                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .F., .F., , "nQtdeRea" , , , ,)
    oDensOri  := TGet():New(045, 244, {|u| If(PCount()>0,nDensOri:=u,nDensOri)}  , oPOP  , 060, 008, '@ER 999,999.9999',                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nDensOri" , , , ,)
    oDensRea  := TGet():New(060, 244, {|u| If(PCount()>0,nDensRea:=u,nDensRea)}  , oPOP  , 060, 008, '@ER 999,999.9999',{|| U_CALCMASSA()}, CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .F., .F., , "nDensRea" , , , ,)
    oPercDens := TGet():New(076, 244, {|u| If(PCount()>0,nPercDens:=u,nPercDens)}, oPOP  , 060, 008, '@ER 999.9999'      ,                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nPercDens", , , ,)
    oTotMassa := TGet():New(212, 068, {|u| If(PCount()>0,nTotMassa:=u,nTotMassa)}, oAnaOp, 060, 008, '@ER 999,999.9999',                , CLR_BLACK, CLR_WHITE, , .F., , .T., , .F., , .F., .F., , .T., .F., , "nTotMassa", , , ,)

    oPEmpenho  := TGroup():New( 104,004,232,272," Empenho ",oAnaop,CLR_BLACK,CLR_WHITE,.T.,.F. )
    MHoEmpenho()
    MCoEmpenho()
    oEmpenho   := MsNewGetDados():New(116,012,204,268,nOpcEmp,'','','++C6_ITEM',{"D4_COD","GXT_QTREAL"},2,999,'AllwaysTrue()','','AllwaysTrue()',oAnaop,aHoEmpenho,aCoEmpenho )

    oPEnvase   := TGroup():New( 104,284,204,544," OP de Envase ",oAnaop,CLR_BLACK,CLR_WHITE,.T.,.F. )
    MCoEnvase()
    oEnvase    := MsNewGetDados():New(120,290,204,536,nOpcEnv,'AllwaysTrue()','AllwaysTrue()','',,0,999,'AllwaysTrue()','','AllwaysFalse()',oAnaop,aHoEnvase,aCoEnvase )

    oPObs      := TGroup():New( 004,336,092,540," Observações ",oAnaop,CLR_BLACK,CLR_WHITE,.T.,.F. )
    oObs       := TMultiGet():New( 012,340,{|u| If(PCount()>0,cObs:=u,cObs)},oPObs,196,076,,,,,,.T.)
    oCancela   := TButton():New( 232,416,"Cancela ",oAnaop,{||oAnaOP:End()},053,012,,,.F.,.T.,.F.,,.F.,,,.F. )
    oConfirma  := TButton():New( 232,486,"Confirma Analise",oAnaop,{||MsAguarde({|lFim|,fCONFIRMA()},"Processamento","Aguarde a finalização do processamento...")},057,012,,,.F.,.T.,.F.,,.F.,,,.F. )

    oAnaop:Activate(,,,.T.)

Return


/*/{Protheus.doc} GravaOP
Gravaçaõ dos ajustes de OP
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 03/05/2022
@return Logical, Gravacao ok ou nao
/*/
Static Function GravaOP()

    Local lRet := .T.
    Local nI
    Local aOpAlt:={}

    //Ajustando SC2
    //Ajustando Quantidade da OP Principal
    SC2->(dbSetOrder(1))
    If SC2->(dbSeek(xFilial("SC2")+cNumOp))
        RecLock("SC2",.F.)
        SC2->C2_QUANT:=nQtdeRea
        SC2->C2_QTSEGUM:=ConvUM(SC2->C2_PRODUTO, nQtdeRea, 0,   2)
        SC2->C2_XLIBOP:="1"
        MsUnLock()
    End

    //Ajusta Empenho da OP Principal
    For nI:=1 to Len(oEmpenho:aCols)
        SD4->(dbGoTo(NwFieldGet(oEmpenho,"CZI_NRRGAL",nI)))
        If NwDeleted(oEmpenho,nI)
            RecLock("SD4",.F.)
            SD4->(dbDelete())
            MsUnLock()
        Else
            If SD4->D4_QUANT <>   NwFieldGet(oEmpenho,"GXT_QTREAL",nI)
                RecLock("SD4",.F.)
                SD4->D4_QTDEORI :=NwFieldGet(oEmpenho,"GXT_QTREAL",nI)
                SD4->D4_QUANT   :=NwFieldGet(oEmpenho,"GXT_QTREAL",nI)
                SD4->D4_QTSEGUM:=ConvUM(SD4->D4_COD, NwFieldGet(oEmpenho,"GXT_QTREAL",nI), 0,   2)
                MsUnLock()
            End
        End
    Next

    // Ajuste das OPS de Envase
    For nI:=1 To Len(oEnvase:aCols)

        SC2->(dbSetOrder(1))
        If SC2->(dbSeek(xFilial("SC2")+NwFieldGet(oEnvase,"NUMOP",nI)))
            RecLock("SC2",.F.)
            SC2->C2_XLIBOP:="1"
            If SC2->C2_QUANT <>  Int(NwFieldGet(oEnvase,"QTDENVREA",nI))
                SC2->C2_QUANT:=Int(NwFieldGet(oEnvase,"QTDENVREA",nI))
                SC2->C2_QTSEGUM:=ConvUM(SC2->C2_PRODUTO, Int(NwFieldGet(oEnvase,"QTDENVREA",nI)), 0,   2)
                AADD(aOpAlt,{NwFieldGet(oEnvase,"NUMOP",nI),Int(NwFieldGet(oEnvase,"QTDENVREA",nI))})
            End
            MsUnLock()

            //Ajusta Empenho do Envase
            SD4->(dbSetOrder(2))
            If  SD4->(dbSeek(xFilial("SD4")+NwFieldGet(oEnvase,"NUMOP",nI)+Space(03)+cProduto+cLocalAr))
                If SD4->D4_QTDEORI <> NwFieldGet(oEnvase,"QTDPIREA",nI)
                    RecLock("SD4",.F.)
                    SD4->D4_QTDEORI := NwFieldGet(oEnvase,"QTDPIREA",nI)
                    SD4->D4_QUANT   := NwFieldGet(oEnvase,"QTDPIREA",nI)
                    SD4->D4_QTSEGUM := ConvUM(SD4->D4_COD,  NwFieldGet(oEnvase,"QTDPIREA",nI), 0,   2)
                    MsUnLock()
                End
            End
        End

    Next

    //Ajusta Embalagem
    For nI:=1 To Len(aOpAlt)
        SD4->(dbSetOrder(2))
        If  SD4->(dbSeek(xFilial("SD4")+aOpAlt[nI,1]+Space(03)))
            While SD4->(!EOF()) .and. RTRIM(SD4->D4_OP) ==RTRIM(aOpAlt[nI,1])
                If Substr(SD4->D4_COD,1,3) ==  "ME."
                    RecLock("SD4",.F.)
                    SD4->D4_QTDEORI := aOpAlt[nI,2]
                    SD4->D4_QUANT   := aOpAlt[nI,2]
                    SD4->D4_QTSEGUM := ConvUM(SD4->D4_COD,  aOpAlt[nI,2], 0,   2)
                    MsUnLock()
                End
                SD4->(dbSkip())
            End
        End
    Next

    MsAguarde({|lFim|,lRet:=GrvBXPI()},"Processamento","Gerando OP de PI..")

Return (lRet)
