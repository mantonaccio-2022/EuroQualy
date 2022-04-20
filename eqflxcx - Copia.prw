#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} EQFLXCX
Fluxo de Caixa onforme padrao Euro American
@type function Relatorio
@version  1.00
@author mario.antonaccio
@since 25/01/2022
@return character, sem retorno
/*/
User Function EQFLXCX()

    Local aButtons := {}
    Local aSays    := {}
    Local cTitoDlg := "Fluxo de Caixa EuroAmerican por Natureza"
    Local nOpca    := 0
    Private cCampo
    Private cCampoT
    Private cCampoT1
    Private cCampoT2
    Private cPerg  := "EQFLXCX"
    Private cNatureza

    // Perguntas
    //01  - Data Inicial - D - 8
    //02  - Data Final - D - 8
    //03  - Natureza de ? - C - 10 - SED
    //04  - Natureza ate ? - C - 10 - SED
    //05  - Tipo FLuxo - N -1  (Previsto/Realizado/Comparativo/Diario)
    //06  - Analitico ou Sintetico?  - N - 1  (Analitico/Sintetico)  - NOTA : Nessa op��o so serao mostrados os grupos  nao os itens
    //07 -  Empresas: - C - 10   - Informa quais empresas separadas por ; (ponto e virgula)
    //08 -  Imprime Consolidado - N - 1  (Sim/Nao) -  Informa se imprime a planilha consolidadora por empresa
    //09 -  Imprime DFC - N - 1  (Sim/Nao) -  Informa se imprime a NATUREZAS DFC NO FLUXO

    aAdd(aSays, "Est� rotina tem o objetivo gerar o fluxo de caixa, aglutinado por natureza")
    aAdd(aSays, "para ter uuma vis�o dos gastos gerados.")
    aAdd(aSays, "Pode ser retirado por PREVISTO,REALIZADO,COMPARATIVO e DIARIO.")

    aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
    aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
    aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

    FormBatch(cTitoDlg, aSays, aButtons)
    If nOpca == 1
        Pergunte(cPerg, .F.)
        Processa( {|| EQFLXCX01() }, "Extra��o de Dados", "Gerando Registros...", .F.)
    EndIf

Return

/*/{Protheus.doc} EQFLXCX01
Extra��o de Dados do fluxo por natureza
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 25/01/2022
@return character, dados extraidos
/*/
Static Function EQFLXCX01()

    Local nI
    Private _FSE     := GetNextAlias() //Arquivo filtrado do SE5,SE1,SE2 - conforme tipo fluxo
    Private _SE8     := GetNextAlias() //Arquivo  temporario  SAldos Bancarios
    Private _SLD     := GetNextAlias() //Arquivo  temporario Saldo
    Private _TFLX    := GetNextAlias() //Arquivo  temporario de Fluxo (Excel)
    Private _TMP     := GetNextAlias() //Arquivo  temporario (Auxiliar)
    Private aDatas   := {}
    Private aFields  := {}
    Private aFieldsN := {}
    Private aFilial  := {}
    Private aSomaCol := {}
    Private cArqReal
    Private cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %" //Separa Filiais
    Private cGrupo   := ""
    Private cItem    := ""
    Private cNGrupo  := " "
    Private cNItem   := " "
    Private cNSubGr  := " "
    Private cSubGr   := ""
    Private lAnalitico
    Private lConsolida
    Private lDFC
    Private nDifMes
    Private nInicio  := 0
    Private nSomaCol := 0
    Private nTotReg  := 0
    Private oExcel   := FWMsExcelEX():New()
    Private oObj     := FWSX1Util()  :New()

    // Posi��o 1,Posicao 2,Posicao 3
    //06  - Analitico ou Sintetico?  - N - 1  (Analitico/Sintetico)  - NOTA : Nessa op��o so serao mostrados os grupos  nao os itens
    //08 -  Imprime Consolidado - N - 1  (Sim/Nao) -  Informa se imprime a planilha consolidadora por empresa
    //09 -  Imprime DFC - N - 1  (Sim/Nao) -  Informa se imprime as Naturezas DFC
    lAnalitico:= If(mv_par06==1,.T.,.F.)
    lConsolida:= If(mv_par08==1,.T.,.F.)
    lDFC:=If(mv_par09==1,.T.,.F.)

    MakeDir("C:\TOTVS")

    nDifMes  := If(mv_par05==4,DateDiffDay(mv_par01,mv_par02),DateDiffMonth(mv_par01,mv_par02) )

    //Filiais Utilizadas
    aFilial:=StrTokArr( mv_par07,";" )
    For nI:=1 to Len(aFilial)
        aFilial[nI]:=AllTrim(aFilial[nI])
    Next
    If mv_par08 == 1 // se Gera Consolidado
        AADD(aFilial,Space(02))
    End

    //Cria�ao do arquivo - Campos BAsicos
    aadd(aFields, {"FLAG"  , 'C', 03, 0})
    aadd(aFieldsN, "Flag")
    If lAnalitico
        aadd(aFields, {"FILIAL", 'C', 02, 0})
        aadd(aFields, {"NATGR" , 'C', 02, 0})
        aadd(aFields, {"NOMEGR", 'C', 30, 0})
        aadd(aFields, {"NATSG ", 'C', 02, 0})
        aadd(aFields, {"NOMESG", 'C', 30, 0})
        aadd(aFields, {"NATIT ", 'C', 03, 0})
        aadd(aFields, {"NOMEIT", 'C', 30, 0})
        nInicio:=9
        // Array como snomes dos campos
        aadd(aFieldsN, "Filial")
        aadd(aFieldsN, "Grupo Natureza")
        aadd(aFieldsN, "Nome Grupo")
        aadd(aFieldsN, "Sub-Grupo Nat.")
        aadd(aFieldsN, "Nome Sub-Grupo")
        aadd(aFieldsN, "Item Natureza")
        aadd(aFieldsN, "Nome Item")
    Else
        //cria campos tabela temporario
        aadd(aFields, {"FILIAL", 'C', 02, 0})
        aadd(aFields, {"NATGR" , 'C', 02, 0})
        aadd(aFields, {"NOMEGR", 'C', 30, 0})
        nInicio:=5
        // Array como snomes dos campos
        aadd(aFieldsN,"Filial")
        aadd(aFieldsN,"Grupo Natureza")
        aadd(aFieldsN,"Nome Grupo")
    End

    //Query de fluxoS
    Do Case

        Case  mv_par05  == 1  // Previsto

            EQFLXPRV(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

        Case mv_par05 ==  2 // Realizado

            EQFLXREA(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

        Case mv_par05 ==  3 // Comparativo

            EQFLXCMP(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

        Case mv_par05 ==  4 // Diario Previsto

            EQFLXDIA(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.),"P")

        Case mv_par05 ==  5 // Diario Realziado

            EQFLXDIA(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.),"R")

    ENDCASE

    // SubTotais
    EQFLXST(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

    // Gera Excel
    EQFLXEXC(If(mv_par06==1,.T.,.F.),If(mv_par08==1,.T.,.F.),If(mv_par09==1,.T.,.F.))

Return

/*/{Protheus.doc} EQFLXPRV
Gera o Fluxo Previsto, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXPRV(lAnalitico,lConsolida,lDFC)

    Local nI

    For nI:=0 to nDifMes
        cAnoMes:=ANOMES(MonthSum(mv_par01,nI))  // Retona o NAo e o mes seguintes a data base
        AADD(aFields,{"_"+cAnoMes,'N',14,2})
        //Nome Campo
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4))
        AADD(aDatas,cAnoMes)
    Next
    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total ")

    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})
    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End
    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()

    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    BeginSql Alias _FSE
        SELECT
            FILIAL,
            NATUREZA,
            MESANO,
            SUM(VALOR) AS VALOR
        FROM
            (
                SELECT
                    SUBSTRING(SE1.E1_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_XNEWNAT AS NATUREZA,
                    SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                    SE1.E1_SALDO AS VALOR
                FROM
                    %Table:SE1% SE1
                INNER JOIN %Table:SED% SED
                ON SE1.E1_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    AND SED.ED_XNEWNAT <>'NC'
                WHERE
                    SE1.%NotDel%
                    AND SE1.E1_SALDO > 0
                    AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                UNION
                SELECT
                    SUBSTRING(SE2.E2_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_XNEWNAT AS NATUREZA,
                    SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                    SE2.E2_SALDO AS VALOR
                FROM
                    %Table:SE2% SE2
                INNER JOIN %Table:SED% SED
                ON SE2.E2_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    AND SED.ED_XNEWNAT<>'NC'
                WHERE
                    SE2.%NotDel%
                    AND SE2.E2_SALDO > 0
                    AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
            ) NAT
        GROUP BY
            FILIAL,
            NATUREZA,
            MESANO
    EndSql

    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")

    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FSE)->(!EOF())

        cNatureza:=(_FSE)->NATUREZA

        // Formata��o campo natureza: 99.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item
        If !Empty(cNatureza)

            SED->(dbSetOrder(1))

            cGrupo  := Substr(cNatureza,1,2)
            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)
            //cDFC:=SED->ED_XDFC
            If lAnalitico
                cSubGr  := Substr(cNatureza,3,2)
                //Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)
                // cDFC:=SED->ED_XDFC

                cItem   := Substr(cNatureza,5,3)
                //Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
                //cDFC:=SED->ED_XDFC
            End
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
            lSemNat:=.T.
            cDFC:=""
        End
        cCampo  := "(_FSE)->MESANO"
        cCampoT := "(_TFLX)->_"+&cCampo

        //pesquiso no temporario se existe o Filial+grupo
        (_TFLX)->(dbSetOrder(1))
        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)
            &cCampoT+=(_FSE)->VALOR
        Else
            RecLock((_TFLX),.T.)
            //(_TFLX)->DFC:= cDFC
            (_TFLX)->FILIAL:= (_FSE)->FILIAL
            (_TFLX)->NATGR :=cGrupo
            (_TFLX)->NOMEGR :=cNGrupo
            &cCampoT:=(_FSE)->VALOR
        End
        MsUnlock()

        If lAnalitico
            //pesquiso no temporario se existe o Filial+grupo+SubGrupo
            (_TFLX)->(dbSetOrder(2))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                // (_TFLX)->DFC:= cDFC
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr
                &cCampoT:=(_FSE)->VALOR
            End
            MsUnLock()

            //pesquiso no temporario se existe o Filial+grupo+SubGrupo+Item
            (_TFLX)->(dbSetOrder(3))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                // (_TFLX)->DFC:= cDFC
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR := cGrupo
                (_TFLX)->NATSG := cSubGr
                (_TFLX)->NATIT := cItem
                (_TFLX)->NOMEIT := cNItem
                &cCampoT       := (_FSE)->VALOR
            End
            MsUnLock()

        End

        (_FSE)->(dbSkip())

    End
    (_FSE)->(dbCloseArea())

    // Consolidada
    If lConsolida  // Imprime Planilha Consolidada
        BeginSql Alias _FSE
            SELECT
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR
            FROM
                (
                    SELECT
                        SED.ED_XNEWNAT AS NATUREZA,
                        SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                        SE1.E1_SALDO AS VALOR
                    FROM
                        %Table:SE1% SE1
                    INNER JOIN %Table:SED% SED
                    ON SE1.E1_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT<>'NC'
                    WHERE
                        SE1.%NotDel%
                        AND SE1.E1_SALDO > 0
                        AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SED.ED_XNEWNAT AS NATUREZA,
                        SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                        SE2.E2_SALDO AS VALOR
                    FROM
                        %Table:SE2% SE2
                    INNER JOIN %Table:SED% SED
                    ON SE2.E2_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT<>'NC'
                    WHERE
                        SE2.%NotDel%
                        AND SE2.E2_SALDO > 0
                        AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                ) NAT
            GROUP BY
                NATUREZA,
                MESANO
        EndSql

        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())

            cNatureza:=(_FSE)->NATUREZA

            // Formata��o campo natureza: 99.99.999
            // 99 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item
            If !Empty(cNatureza)

                SED->(dbSetOrder(1))

                cGrupo  := Substr(cNatureza,1,2)
                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)

                If lAnalitico
                    cSubGr  := Substr(cNatureza,3,2)
                    //Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr(cNatureza,5,3)
                    //Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)
                End
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            End
            cFlag:=cGrupo+"1"
            cCampo  := "(_FSE)->MESANO"
            cCampoT := "(_TFLX)->_"+&cCampo

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NOMEGR :=cNGrupo
                &cCampoT:=(_FSE)->VALOR
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR :=cGrupo
                    (_TFLX)->NATSG :=cSubGr
                    (_TFLX)->NOMESG :=cNSubGr
                    &cCampoT:=(_FSE)->VALOR
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR := cGrupo
                    (_TFLX)->NATSG := cSubGr
                    (_TFLX)->NATIT := cItem
                    (_TFLX)->NOMEIT := cNItem
                    &cCampoT       := (_FSE)->VALOR
                End
                MsUnLock()
            End

            (_FSE)->(dbSkip())
        End
    End

    (_FSE)->(dbCloseArea())

Return

/*/{Protheus.doc} EQFLXREA
Gera o Fluxo Realizado, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function EQFLXREA(lAnalitico,lConsolida,lDFC)

    Local nI
  
    cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %"

    For nI:=0 to nDifMes
        cAnoMes:=ANOMES(MonthSum(mv_par01,nI))  // Retona o Ano e o mes seguintes a data base
        AADD(aFields,{"_"+cAnoMes,'N',14,2})
        //Nome Campo
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4))
        AADD(aDatas,cAnoMes)
    Next
    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total Natureza")

    // Cria�ao arquivo prnincipal
    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})
    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End
    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()

    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    BeginSql Alias _FSE
        SELECT
            FILIAL,
            NATUREZA,
            MESANO,
            SUM(VALOR) AS VALOR
        FROM
            (
                SELECT
                    SUBSTRING(SE5.E5_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_XNEWNAT AS NATUREZA,
                    SUBSTRING(SE5.E5_DATA, 1, 6) AS MESANO,
                    SE5.E5_VALOR AS VALOR
                FROM
                    %Table:SE5% SE5
                INNER JOIN %Table:SED% SED
                ON SE5.E5_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    AND SED.ED_XNEWNAT <> 'NC'
                WHERE
                    SE5.%NotDel%
                    AND SE5.E5_DATA >= %Exp:DTOS(mv_par01)%
                    AND SE5.E5_DATA <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    AND SE5.E5_MOTBX <>'CMP'
            ) NAT
        GROUP BY
            FILIAL,
            NATUREZA,
            MESANO
        ORDER BY
            FILIAL,
            NATUREZA,
            MESANO
    EndSql

    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")
    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FSE)->(!EOF())

         cNatureza:=(_FSE)->NATUREZA

        // Formata��o campo natureza: 9.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item
        If !Empty(cNatureza)

            SED->(dbSetOrder(1))

            cGrupo  := Substr(cNatureza,1,2)
            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)
            If lAnalitico
                cSubGr  := Substr(cNatureza,3,2)
                //Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)

                cItem   := Substr(cNatureza,5,3)
                //Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
            End
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
        End

        cCampo  := "(_FSE)->MESANO"
        cCampoT := "(_TFLX)->_"+&cCampo

        //pesquiso no temporario se existe o Filial+grupo
        (_TFLX)->(dbSetOrder(1))
        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)
            &cCampoT+=(_FSE)->VALOR
        Else
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL:= (_FSE)->FILIAL
            (_TFLX)->NATGR :=cGrupo
            (_TFLX)->NOMEGR :=cNGrupo
            &cCampoT:=(_FSE)->VALOR
        End
        MsUnlock()

        If lAnalitico
            //pesquiso no temporario se existe o Filial+grupo+SubGrupo
            (_TFLX)->(dbSetOrder(2))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr
                &cCampoT:=(_FSE)->VALOR
            End
            MsUnLock()

            //pesquiso no temporario se existe o Filial+grupo+SubGrupo+Item
            (_TFLX)->(dbSetOrder(3))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR := cGrupo
                (_TFLX)->NATSG := cSubGr
                (_TFLX)->NATIT := cItem
                (_TFLX)->NOMEIT := cNItem
                &cCampoT       := (_FSE)->VALOR
            End
            MsUnLock()

        End

        (_FSE)->(dbSkip())

    End

    (_FSE)->(dbCloseArea())

    // Consolidada
    If lConsolida  // Imprime Planilha Consolidada
        BeginSql Alias _FSE
            SELECT
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR
            FROM
                (
                    SELECT
                        SED.ED_XNEWNAT AS NATUREZA,
                        SUBSTRING(SE5.E5_DATA, 1, 6) AS MESANO,
                        SE5.E5_VALOR AS VALOR
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                    ON SE5.E5_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE5.%NotDel%
                        AND SE5.E5_DATA >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DATA <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        AND SE5.E5_MOTBX <>'CMP'
                ) NAT
            GROUP BY
                NATUREZA,
                MESANO
            ORDER BY
                NATUREZA,
                MESANO
        EndSql

        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())

             cNatureza:=(_FSE)->NATUREZA

            // Formata��o campo natureza: 9.99.999
            // 9 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item
            If !Empty(cNatureza)

                SED->(dbSetOrder(1))

                cGrupo  := Substr(cNatureza,1,2)
                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)

                If lAnalitico
                    cSubGr  := Substr(cNatureza,3,2)
                    //Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr(cNatureza,5,3)
                    //Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)
                End
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            End

            cCampo  := "(_FSE)->MESANO"
            cCampoT := "(_TFLX)->_"+&cCampo

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NOMEGR :=cNGrupo
                &cCampoT:=(_FSE)->VALOR
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR :=cGrupo
                    (_TFLX)->NATSG :=cSubGr
                    (_TFLX)->NOMESG :=cNSubGr
                    &cCampoT:=(_FSE)->VALOR
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR := cGrupo
                    (_TFLX)->NATSG := cSubGr
                    (_TFLX)->NATIT := cItem
                    (_TFLX)->NOMEIT := cNItem
                    &cCampoT       := (_FSE)->VALOR
                End
                MsUnLock()
            End

            (_FSE)->(dbSkip())
        End
        (_FSE)->(dbCloseArea())

    End

Return

/*/{Protheus.doc} EQFLXDIA
Gera o Fluxo Previsto DIARIO, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXDIA(lAnalitico,lConsolida,lDF,cTipo)

    Local nI
 
    cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %"

    //Mostra as datas ao inves dos meses
    nDifMes:=DateDiffDay(mv_par01,mv_par02)
    For nI:=0 to nDifMes
        cData:=DTOC(mv_par01+nI)
        AADD(aFields,{"_"+DTOS(CTOD(cData)),'N',14,2})
        //Nome Campo
        aadd(aFieldsN,cData)
        AADD(aDatas,cData)
    Next

    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total Natureza")

    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})
    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End
    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()
    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    If cTipo == "P"
        BeginSql Alias _FSE
            SELECT
                FILIAL,
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR
            FROM
                (
                    SELECT
                        SUBSTRING(SE1.E1_FILIAL, 1, 2) AS FILIAL,
                        SED.ED_XNEWNAT AS NATUREZA,
                        SE1.E1_EMISSAO AS MESANO,
                        SE1.E1_SALDO AS VALOR
                    FROM
                        %Table:SE1% SE1
                    INNER JOIN %Table:SED% SED
                    ON SE1.E1_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT<>'NC'
                    WHERE
                        SE1.%NotDel%
                        AND SE1.E1_SALDO > 0
                        AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SUBSTRING(SE2.E2_FILIAL, 1, 2) AS FILIAL,
                        SED.ED_XNEWNAT AS NATUREZA,
                        SE2.E2_EMISSAO AS MESANO,
                        SE2.E2_SALDO AS VALOR
                    FROM
                        %Table:SE2% SE2
                    INNER JOIN %Table:SED% SED
                    ON SE2.E2_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE2.%NotDel%
                        AND SE2.E2_SALDO > 0
                        AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                ) NAT
            GROUP BY
                FILIAL,
                NATUREZA,
                MESANO
            ORDER BY
                FILIAL,
                NATUREZA,
                MESANO
        EndSql

    ElseIf cTipo == "R"

        BeginSql Alias _FSE
            SELECT
                FILIAL,
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR
            FROM
                (
                    SELECT
                        SUBSTRING(SE5.E5_FILIAL, 1, 2) AS FILIAL,
                        SED.ED_XNEWNAT AS NATUREZA,
                        SE5.E5_DATA AS MESANO,
                        SE5.E5_VALOR AS VALOR
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                    ON SE5.E5_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE5.%NotDel%
                        AND SE5.E5_DATA >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DATA <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        AND SE5.E5_MOTBX <>'CMP'
                ) NAT
            GROUP BY
                FILIAL,
                NATUREZA,
                MESANO
            ORDER BY
                FILIAL,
                NATUREZA,
                MESANO
        EndSql
    End
    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")
    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FSE)->(!EOF())

        cNatureza:=(_FSE)->NATUREZA

        IncProc()

        // Formata��o campo natureza: 9.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item
        If !Empty(cNatureza)

            SED->(dbSetOrder(1))

            cGrupo  := Substr(cNatureza,1,2)
            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)
            If lAnalitico
                cSubGr  := Substr(cNatureza,3,2)
                //Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)

                cItem   := Substr(cNatureza,5,3)
                //Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
            End
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
        End

        cCampo  := "(_FSE)->MESANO"
        cCampoT := "(_TFLX)->_"+&cCampo

        //pesquiso no temporario se existe o Filial+grupo
        (_TFLX)->(dbSetOrder(1))
        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)
            &cCampoT+=(_FSE)->VALOR
        Else
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL:= (_FSE)->FILIAL
            (_TFLX)->NATGR :=cGrupo
            (_TFLX)->NOMEGR :=cNGrupo
            &cCampoT:=(_FSE)->VALOR
        End
        MsUnlock()

        If lAnalitico
            //pesquiso no temporario se existe o Filial+grupo+SubGrupo
            (_TFLX)->(dbSetOrder(2))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr
                &cCampoT:=(_FSE)->VALOR
            End
            MsUnLock()

            //pesquiso no temporario se existe o Filial+grupo+SubGrupo+Item
            (_TFLX)->(dbSetOrder(3))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)
                &cCampoT+=(_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR := cGrupo
                (_TFLX)->NATSG := cSubGr
                (_TFLX)->NATIT := cItem
                (_TFLX)->NOMEIT := cNItem
                &cCampoT       := (_FSE)->VALOR
            End
            MsUnLock()
        End

        (_FSE)->(dbSkip())

    End

    (_FSE)->(dbCloseArea())

    // Consolidada
    If lConsolida  // Imprime Planilha Consolidada
        BeginSql Alias _FSE
            SELECT
                NATUREZA,
                MESANO,
                SUM(VALOR) AS VALOR
            FROM
                (
                    SELECT
                        SED.ED_XNEWNAT AS NATUREZA,
                        SE5.E5_DATA AS MESANO,
                        SE5.E5_VALOR AS VALOR
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                    ON SE5.E5_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT <> 'NC'
                    WHERE
                        SE5.%NotDel%
                        AND SE5.E5_DATA >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DATA <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        AND SE5.E5_MOTBX <>'CMP'
                ) NAT
            GROUP BY
                NATUREZA,
                MESANO
            ORDER BY
                NATUREZA,
                MESANO
        EndSql

        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())

            cNatureza:=(_FSE)->NATUREZA

            IncProc()

            // Formata��o campo natureza: 9.99.999
            // 9 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item
            If !Empty(cNatureza)

                SED->(dbSetOrder(1))

                cGrupo  := Substr(cNatureza,1,2)
                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)

                If lAnalitico
                    cSubGr  := Substr(cNatureza,3,2)
                    //Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr(cNatureza,5,3)
                    //Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)
                End
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            End

            cCampo  := "(_FSE)->MESANO"
            cCampoT := "(_TFLX)->_"+&cCampo

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)
                &cCampoT += (_FSE)->VALOR
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR  := cGrupo
                (_TFLX)->NOMEGR := cNGrupo
                &cCampoT        := (_FSE)->VALOR
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NOMESG := cNSubGr
                    &cCampoT        := (_FSE)->VALOR
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)
                    &cCampoT+=(_FSE)->VALOR
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NATIT  := cItem
                    (_TFLX)->NOMEIT := cNItem
                    &cCampoT        := (_FSE)->VALOR
                End
                MsUnLock()
            End

            (_FSE)->(dbSkip())
        End
        (_FSE)->(dbCloseArea())

    End

Return

/*/{Protheus.doc} EQFLXCMP
Gera o Fluxo Previsto Comparativo, podensdo ser ANalitico ou sintetico (so grupos) Impime Colsolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXCMP(lAnalitico,lConsolida,lDFC)

    Local nI
 
    cExprEmp := "% "+FormatIn(AllTrim(mv_par07),";")+" %"

    //Mostra as datas ao inves dos meses
    For nI:=0 to nDifMes
        cAnoMes:=ANOMES(MonthSum(mv_par01,nI))  // Retona o NAo e o mes seguintes a data base
        AADD(aFields,{"_"+cAnoMes+"P",'N',14,2})
        AADD(aFields,{"_"+cAnoMes+"R",'N',14,2})

        //Nome do Campo
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4)+"_PRV")
        aadd(aFieldsN,Substr(cAnoMes,5,2)+"/"+Substr(cAnoMes,1,4)+"_REA")
        AADD(aDatas,cAnoMes)
    Next

    AADD(aFields,{"Total_Nat",'N',14,2})
    //Nome Campo
    AADD(aFieldsN,"Total")

    oTmpTable:=FWTemporaryTable():New((_TFLX))
    oTmpTable:SetFields(aFields)
    oTmpTable:AddIndex("01",{"FILIAL","NATGR"})
    If lAnalitico
        oTmpTable:AddIndex("02",{"FILIAL","NATGR","NATSG"})
        oTmpTable:AddIndex("03",{"FILIAL","NATGR","NATSG","NATIT"})
    End
    oTmpTable:AddIndex("04",{"FILIAL","FLAG"})
    oTmpTable:Create()

    cArqReal:="%"+oTmpTable:GetRealName()+"%"

    // Gera por empresa conforme Parametro 07
    BeginSql Alias _FSE
        SELECT
            FILIAL,
            NATUREZA,
            MESANO,
            SUM(VALORPRV) AS VALORPRV,
            SUM(VALORREA) AS VALORREA
        FROM
            (
                SELECT
                    SUBSTRING(SE1.E1_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_XNEWNAT AS NATUREZA,
                    SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                    SE1.E1_SALDO AS VALORPRV,
                    0 AS VALORREA
                FROM
                    SE1100 SE1
                INNER JOIN %Table:SED% SED
                ON SE1.E1_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    AND SED.ED_XNEWNAT<>'NC'                    
                WHERE
                    SE1.D_E_L_E_T_ = ' '
                    AND SE1.E1_SALDO > 0
                    AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                UNION
                SELECT
                    SUBSTRING(SE2.E2_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_XNEWNAT AS NATUREZA,
                    SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                    SE2.E2_SALDO AS VALORPRV,
                    0 AS VALORREA
                FROM
                    SE2100 SE2
                INNER JOIN %Table:SED% SED
                ON SE2.E2_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel%
                    AND SED.ED_XNEWNAT<>'NC'
                WHERE
                    SE2.D_E_L_E_T_ = ' '
                    AND SE2.E2_SALDO > 0
                    AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                    AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                UNION
                SELECT
                    SUBSTRING(SE5.E5_FILIAL, 1, 2) AS FILIAL,
                    SED.ED_XNEWNAT AS NATUREZA,
                    SUBSTRING(SE5.E5_DATA, 1, 6) AS MESANO,
                    0 AS VALOPRV,
                    SE5.E5_VALOR AS VALORREA
                FROM
                    SE5100 SE5
                INNER JOIN %Table:SED% SED
                ON SE5.E5_NATUREZ = SED.ED_CODIGO
                    AND SED.%NotDel% 
                    AND SED.ED_XNEWNAT <>'NC'
                WHERE
                    SE5.D_E_L_E_T_ = ' '
                    AND SE5.E5_DATA >= %Exp:DTOS(mv_par01)%
                    AND SE5.E5_DATA <= %Exp:DTOS(mv_par02)%
                    AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    AND SE5.E5_MOTBX <>'CMP'
            ) NAT
        GROUP BY
            FILIAL,
            NATUREZA,
            MESANO
    EndSql

    aQuery:=GetLastQuery()

    nTotReg := Contar((_FSE),"!EOF()")
    (_FSE)->(DbGoTop())

    ProcRegua(nTotReg)

    While (_FSE)->(!EOF())

        cNatureza:=(_FSE)->NATUREZA

        // Formata��o campo natureza: 9.99.999
        // 99 - Grupo
        // 99 - Sub-Grupo
        // 999 - Item
        If !Empty(cNatureza)

            SED->(dbSetOrder(1))

            cGrupo  := Substr(cNatureza,1,2)
            //Pega Nome da Natureza: Grupo
            SED->(MsSeek(xFilial("SED")+cGrupo))
            cNGrupo:=AllTrim(SED->ED_DESCRIC)
            If lAnalitico
                cSubGr  := Substr(cNatureza,3,2)
                //Pega Nome da Natureza: SubGrupo
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                cNSubGr:=Alltrim(SED->ED_DESCRIC)

                cItem   := Substr(cNatureza,5,3)
                //Pega Nome da Natureza: Item
                SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                cNItem:=AlLTrim(SED->ED_DESCRIC)
            End
        Else
            cGrupo:="99"
            cNGrupo:="SEM NATUREZA"
            cSubGr:=""
            cItem:=""
            cNSubGr:=""
            cNItem:=""
        End

        cCampo  := "(_FSE)->MESANO"
        cCampoT1 := "(_TFLX)->_"+&cCampo+"P"
        cCampoT2 := "(_TFLX)->_"+&cCampo+"R"

        //pesquiso no temporario se existe o Filial+grupo
        (_TFLX)->(dbSetOrder(1))
        If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo))
            RecLock((_TFLX),.F.)
            &cCampoT1+=(_FSE)->VALORPRV
            &cCampoT2+=(_FSE)->VALORREA
        Else
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL:= (_FSE)->FILIAL
            (_TFLX)->NATGR :=cGrupo
            (_TFLX)->NOMEGR :=cNGrupo
            &cCampoT1:=(_FSE)->VALORPRV
            &cCampoT2:=(_FSE)->VALORREA
        End
        MsUnlock()

        If lAnalitico
            //pesquiso no temporario se existe o Filial+grupo+SubGrupo
            (_TFLX)->(dbSetOrder(2))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr))
                RecLock((_TFLX),.F.)
                &cCampoT1+=(_FSE)->VALORPRV
                &cCampoT2+=(_FSE)->VALORREA
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR :=cGrupo
                (_TFLX)->NATSG :=cSubGr
                (_TFLX)->NOMESG :=cNSubGr
                &cCampoT1=(_FSE)->VALORPRV
                &cCampoT2:=(_FSE)->VALORREA
            End
            MsUnLock()

            //pesquiso no temporario se existe o Filial+grupo+SubGrupo+Item
            (_TFLX)->(dbSetOrder(3))
            If (_TFLX)->(Dbseek((_FSE)->FILIAL+cGrupo+cSubGr+cItem))
                RecLock((_TFLX),.F.)
                &cCampoT1+=(_FSE)->VALORPRV
                &cCampoT2+=(_FSE)->VALORREA
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->FILIAL:= (_FSE)->FILIAL
                (_TFLX)->NATGR := cGrupo
                (_TFLX)->NATSG := cSubGr
                (_TFLX)->NATIT := cItem
                (_TFLX)->NOMEIT := cNItem
                &cCampoT1       := (_FSE)->VALORPRV
                &cCampoT2      := (_FSE)->VALORREA
            End
            MsUnLock()
        End

        (_FSE)->(dbSkip())

    End

    (_FSE)->(dbCloseArea())

    // Consolidada
    If lConsolida

        BeginSql Alias _FSE
            SELECT
                NATUREZA,
                MESANO,
                SUM(VALORPRV) AS VALORPRV,
                SUM(VALORREA) AS VALORREA
            FROM
                (
                    SELECT
                        SED.ED_XNEWNAT as NATUREZA,
                        SUBSTRING(SE1.E1_EMISSAO, 1, 6) AS MESANO,
                        SE1.E1_SALDO AS VALORPRV,
                        0 as VALORREA
                    FROM
                        SE1100 SE1
                    INNER JOIN %Table:SED% SED
                    ON SE1.E1_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT<>'NC'
                    WHERE
                        SE1.D_E_L_E_T_ = ' '
                        AND SE1.E1_SALDO > 0
                        AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE1.E1_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SED.ED_XNEWNAT AS NATUREZA,
                        SUBSTRING(SE2.E2_EMISSAO, 1, 6) AS MESANO,
                        SE2.E2_SALDO AS VALORPRV,
                        0 AS VALORREA
                    FROM
                        SE2100 SE2
                    INNER JOIN %Table:SED% SED
                    ON SE2.E2_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT<>'NC'
                    WHERE
                        SE2.D_E_L_E_T_ = ' '
                        AND SE2.E2_SALDO > 0
                        AND SE2.E2_EMISSAO >= %Exp:DTOS(mv_par01)%
                        AND SE2.E2_EMISSAO <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE2.E2_FILIAL, 1, 2) IN %Exp:cExprEmp%
                    UNION
                    SELECT
                        SED.ED_XNEWNAT AS NATUREZA,
                        SUBSTRING(SE5.E5_DATA, 1, 6) AS MESANO,
                        0 as VALOPRV,
                        SE5.E5_VALOR AS VALORREA
                    FROM
                        %Table:SE5% SE5
                    INNER JOIN %Table:SED% SED
                    ON SE5.E5_NATUREZ = SED.ED_CODIGO
                        AND SED.%NotDel%
                        AND SED.ED_XNEWNAT<>'NC'
                    WHERE
                        SE5.D_E_L_E_T_ = ' '
                        AND SE5.E5_DATA >= %Exp:DTOS(mv_par01)%
                        AND SE5.E5_DATA <= %Exp:DTOS(mv_par02)%
                        AND SUBSTRING(SE5.E5_FILIAL, 1, 2) IN %Exp:cExprEmp%
                        AND SE5.E5_MOTBX <>'CMP'
                ) NAT
            GROUP BY
                NATUREZA,
                MESANO
        EndSql

        aQuery:=GetLastQuery()

        nTotReg := Contar((_FSE),"!EOF()")
        (_FSE)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_FSE)->(!EOF())

            cNatureza:=(_FSE)->NATUREZA

            // Formata��o campo natureza: 9.99.999
            // 9 - Grupo
            // 99 - Sub-Grupo
            // 999 - Item
            If !Empty(cNatureza)

                SED->(dbSetOrder(1))

                cGrupo  := Substr(cNatureza,1,2)
                //Pega Nome da Natureza: Grupo
                SED->(MsSeek(xFilial("SED")+cGrupo))
                cNGrupo:=AllTrim(SED->ED_DESCRIC)

                If lAnalitico
                    cSubGr  := Substr(cNatureza,3,2)
                    //Pega Nome da Natureza: SubGrupo
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr))
                    cNSubGr:=Alltrim(SED->ED_DESCRIC)

                    cItem   := Substr(cNatureza,5,3)
                    //Pega Nome da Natureza: Item
                    SED->(MsSeek(xFilial("SED")+cGrupo+cSubGr+cItem))
                    cNItem:=AlLTrim(SED->ED_DESCRIC)
                End
            Else
                cGrupo:="99"
                cNGrupo:="SEM NATUREZA"
                cSubGr:=""
                cItem:=""
                cNSubGr:=""
                cNItem:=""
            End

            cCampo1  := "(_FSE)->MESANOP"
            cCampo2  := "(_FSE)->MESANOR"
            cCampoT1 := "(_TFLX)->_"+&cCampo+"P"
            cCampoT2 := "(_TFLX)->_"+&cCampo+"R"

            //pesquiso no temporario se existe o grupo
            (_TFLX)->(dbSetOrder(1))
            If (_TFLX)->(Dbseek(Space(02)+cGrupo))
                RecLock((_TFLX),.F.)
                &cCampoT1 += (_FSE)->VALORPRV
                &cCampoT2 += (_FSE)->VALORREA
            Else
                RecLock((_TFLX),.T.)
                (_TFLX)->NATGR  := cGrupo
                (_TFLX)->NOMEGR := cNGrupo
                &cCampoT1       := (_FSE)->VALORPRV
                &cCampoT2       := (_FSE)->VALORREA
            End
            MsUnlock()

            If lAnalitico
                //pesquiso no temporario se existe o grupo+SubGrupo
                (_TFLX)->(dbSetOrder(2))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr))
                    RecLock((_TFLX),.F.)
                    &cCampoT1+=(_FSE)->VALORPRV
                    &cCampoT2+=(_FSE)->VALORREA
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NOMESG := cNSubGr
                    &cCampoT1        := (_FSE)->VALORPRV
                    &cCampoT2        := (_FSE)->VALORREA
                End
                MsUnLock()

                //pesquiso no temporario se existe o grupo+SubGrupo+Item
                (_TFLX)->(dbSetOrder(3))
                If (_TFLX)->(Dbseek(Space(02)+cGrupo+cSubGr+cItem))
                    RecLock((_TFLX),.F.)
                    &cCampoT1+=(_FSE)->VALORPRV
                    &cCampoT2+=(_FSE)->VALORREA
                Else
                    RecLock((_TFLX),.T.)
                    (_TFLX)->NATGR  := cGrupo
                    (_TFLX)->NATSG  := cSubGr
                    (_TFLX)->NATIT  := cItem
                    (_TFLX)->NOMEIT := cNItem
                    &cCampoT1        := (_FSE)->VALORPRV
                    &cCampoT2        := (_FSE)->VALORREA
                End
                MsUnLock()
            End
            (_FSE)->(dbSkip())

        End
    End
    (_FSE)->(dbCloseArea())

Return

/*/{Protheus.doc} EQFLXEXC
Gera Planilha EXCEL do fluxos contemplando analitico Consolidado e DFC
@type function Processmento
@version  1.00
@author mario.antonaccio
@since 10/02/2022
@param lAnalitico, logical, Indica se Imprime Analitico (.T.) ou Sintetico (.F.)
@param lConsolida, logical, Indica se Imprime Dados Consolidados (.T.) ou so Dados por Empresa (.F.)
@param lDFC, logical, Indica se Imprime Naturezas DFC (.T.) ou nao (.F.)
@return Character, Tabelas com os dados
/*/
Static Function  EQFLXEXC(lAnalitico,lConsolida,lDFC)

    Local aLinhaAux := {}
    Local aPergunte := {}
    Local cArqDst   := "C:\TOTVS\EQFLX"
    Local cCampos   := " "
    Local cNomeFil  := " "
    Local cTitPla   := "Fluxo - "
    Local lAbre     := .F.
    Local nCampos   := 0
    Local nI        := 0
    Local nJ        := 0
    Local nTotReg   := 0

    //Deixa a planilha  sen o azul no corpo
    oExcel:SetLineFrColor("#000000")
    oExcel:SetLineBgColor("#FFFFFF")
    oExcel:Set2LineFrColor("#000000")
    oExcel:Set2LineBgColor("#FFFFFF")

    //Indica quais campos entrrao na montaem do EXCEL
    cCampos:="%"
    For nI:=2 to Len(aFields)
        cCampos+=aFields[nI,1]+If(nI==Len(afIelds),"",",")
        nCampos++
    Next
    cCampos+="%"

    oObj:AddGroup(cPerg)
    oObj:SearchGroup()
    aPergunte := oObj:GetGroup(cPerg)

    If Mv_par05 == 1
        cTitPla+="Previst0 "
        cArqDst+="PRV_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    ElseIf Mv_par05 == 2
        cTitPla+="Realizado"
        cArqDst+="REA_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    ElseIf Mv_par05 == 3
        cTitPla+="Comparativo"
        cArqDst+="CMP_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    ElseIf Mv_par05 == 4
        cTitPla+="Diario Previsto"
        cArqDst+="DIA_PRV_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    ElseIf Mv_par05 == 5
        cTitPla+="Diario Realizado"
        cArqDst+="DIA_REA_"+ Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
    End

    cTitPla+= If(mv_par06 == 1," - Analitico"," - Sintetico")

    For nJ:=1 To Len(aFilial)

        cNomeFil=If(Empty(aFilial[nJ]),"Consolidado",AllTrim(FWFilialName(cEmpAnt,aFilial[nJ],1)))

        oExcel:AddworkSheet(cNomeFil)
        oExcel:AddTable(cNomeFil, cTitPla)

        If SELECT(_TMP) > 0
            (_TMP)->(dbCloseArea())
        End

        BeginSql Alias _TMP
            SELECT
                %Exp:cCampos%
            FROM
                %Exp:cArqReal%
            WHERE
                FILIAL = %Exp:aFilial[nJ]%
            ORDER BY
                FILIAL,
                FLAG,
                NATGR
        EndSql

        //Monta Excel Dinamico conforme os campos selecionados
        For nI := 1 To nCampos
            If aFields[nI+1,2] == "C"
                oExcel:AddColumn(cNomeFil, cTitPla, aFieldsN[nI+1], 1, 1, .F.)
            ElseIf aFields[nI+1,2] == "N"
                oExcel:AddColumn(cNomeFil, cTitPla, aFieldsN[nI+1], 3, 2, .F.)
            End
        Next

        nTotReg := Contar((_TMP),"!EOF()")
        (_TMP)->(DbGoTop())

        ProcRegua(nTotReg)

        While (_TMP)->(!EOF())

            IncProc()

            lAbre:=.T.

            //Carrega array auxiiar para carregar planilha
            aLinhaAux:={}
            For nI := 1 To (_TMP)->(FCOUNT()) //nCampos
                //If VALTYPE((_TFLX)->(FIELDGET(nI)))=="N"
                //     AADD(aLinhaAux, ABS((_TMP)->(FieldGet(nI))))
                // Else
                AADD(aLinhaAux, (_TMP)->(FieldGet(nI)))
                // End
            Next

            //Nudan�a de Cor na linha???????
            /*
            If "Saldo" $ (_TMP)->NOMEGR  .or. "Endividamento" $ (_TMP)->NOMEGR
                oExcel:SetCelFrColor("#FFFFFF")
                oExcel:SetCelBgColor("#708090")
            Else
                oExcel:SetCelBgColor("#FFFFFF")
                oExcel:SetCelFrColor("#000000")
            End
            */

            oExcel:AddRow(cNomeFil, cTitPla,aLinhaAux)

            (_TMP)->(dbSkip())

        End

    Next nJ
    //Fim Fluxo
    (_TMP)->(dbCloseArea())

    lDFC:=.F.
    If lDFC
    End

    // ABA de Parametros
    oExcel:AddworkSheet("Parametros")
    oExcel:AddTable ("Parametros","Defini��es")

    oExcel:AddColumn("Parametros","Defini��es","Ordem",1,1)
    oExcel:AddColumn("Parametros","Defini��es","Pergunta",1,1)
    oExcel:AddColumn("Parametros","Defini��es","Resposta",1,1)

    For nI:=1 to Len(aPergunte[2])
        If aPergunte[2][nI]:CX1_TIPO == "D"
            cVar:=DTOC(&(aPergunte[2][nI]:CX1_VAR01))
        ElseIf aPergunte[2][nI]:CX1_TIPO == "N"
            If aPergunte[2][nI]:CX1_GSC=="G"
                cVar:=Transform(&(aPergunte[2][nI]:CX1_VAR01),"@ER 999,999,99.99")
            ElseIf aPergunte[2][nI]:CX1_GSC=="C"
                cVar:=&("aPergunte[2][nI]:CX1_DEF"+StrZero(&(aPergunte[2][nI]:CX1_VAR01),2,0))
            End
        Else
            cVar:=&(aPergunte[2][nI]:CX1_VAR01)
        End
        oExcel:AddRow("Parametros","Defini��es",{aPergunte[2][nI]:CX1_ORDEM,RTRIM(aPergunte[2][nI]:CX1_PERGUNT),cVar})
    Next

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

/*/{Protheus.doc} EQFLXST
Rotina de gera��o de subtottais para a planilha
@type function processameno
@version  1.00
@author mario.antonaccio
@since 21/02/2022
@return vCHaracter, sem retorno especifico
/*/
Static Function EQFLXST(lAnalitico,lConsolida,lDFC)

    Local aNSubTot := {}
    Local aSemNat  := {}
    Local nDB      := 0 //SOma Receitas despesas Bancarias
    Local nEB      := 0 //Soma Endividamento Bancario
    Local nI
    Local nJ
    Local nPG      := 0 // Soma Pagamentos
    Local nRC      := 0 // Soma Recebimentos
    Local nSF      := 0 //Saldo FInal Caixa
    Local nSI      := 0 // SAldos Iniciais
    Local nSL      := 0 // Saldo de Caixa
    Local nSomaLin := 0
    Local nX
    Local cExpr

    //Nome Subtotais
    AADD(aNSubTot,{"111","Saldos Recebimentos"})
    AADD(aNSubTot,{"211","Saldos Pagamentos"})
    AADD(aNSubTot,{"311","Saldo de Caixa"})
    //   AADD(aNSubTot,{"611","Endividamento Bancario"})
    //    AADD(aNSubTot,{"711","Receitas/Despesas Banco"})
    AADD(aNSubTot,{"811","Saldo Final de Caixa"})

    // Atualiza flag de indexa��o
    (_TFLX)->(dbGoTop())
    While (_TFLX)->(!EOF())

        For nI:=nInicio To Len(aFields)
            nSomaLin+=(_TFLX)->(FieldGet(nI))
        Next

        RecLock((_TFLX),.F.)
        If AllTrim((_TFLX)->NATGR) $ "01"  //REcebimentos
            (_TFLX)->FLAG:="11"
        ElseIf AllTrim((_TFLX)->NATGR) $  "02/03/04" //Pagamentos
            (_TFLX)->FLAG:="21"
        ElseIf AllTrim((_TFLX)->NATGR)$  "05" // Enprestimos Bancarios
            (_TFLX)->FLAG:="51"
        ElseIf AllTrim((_TFLX)->NATGR) $  "06" // Pagamneto emprestimos
            (_TFLX)->FLAG:="52"
        ElseIf AllTrim((_TFLX)->NATGR) $  "07"  //Despesas Financeiras
            (_TFLX)->FLAG:="71"
        ElseIf AllTrim((_TFLX)->NATGR) $  "08" //Receitas Financeiras NOVO
            (_TFLX)->FLAG:="72"
        ElseIf AllTrim((_TFLX)->NATGR) $  "09"  //Capitalizacao Investimentos NOVO
            (_TFLX)->FLAG:="73"
        ElseIf AllTrim((_TFLX)->NATGR) $  "10"  //Resgate Capitaliza�ao NOVO
            (_TFLX)->FLAG:="74"
        Else  //Outros
            (_TFLX)->FLAG:="ZZ"
        End
        (_TFLX)->(FieldPut(Len(aFields),nSomaLin))
        MsUnlock()
        nSomaLin:=0
        (_TFLX)->(dbSkip())
    End

    //Como � mensal , entao pega o do ultimo dia do mes anterior
    cDia:=CTOD("01/"+StrZero(Month(mv_par01),2,0)+"/"+Str(Year(mv_par01),4,0)) - 1

    BeginSql Alias _SE8
        SELECT
            SUBSTRING (SE8.E8_FILIAL, 1, 2) AS FILIAL,
            SUM (SE8.E8_SALATUA) AS VALOR
        FROM
            %Table:SE8% SE8
        INNER JOIN %Table:SA6% SA6
        ON SUBSTRING (SE8.E8_FILIAL, 1, 2) = SA6.A6_FILIAL
            AND SE8.E8_BANCO = SA6.A6_COD
            AND SA6.A6_FLUXCAI = 'S'
            AND SA6.D_E_L_E_T_ = ' '
        WHERE
            SE8.D_E_L_E_T_ = ' '
            AND SE8.E8_DTSALAT = %Exp:cDia%
        GROUP BY
            SUBSTRING (SE8.E8_FILIAL, 1, 2)
    ENDSQL

    //Grava ARRAY DE sALDO
    aSaldo:={}
    nSaldo:=0
    While (_SE8)->(!EOF())
        AADD(aSaldo,{(_SE8)->FILIAL,(_SE8)->VALOR})
        nSaldo+=(_SE8)->VALOR
        (_SE8)->(dbSkip())
    End
    AADD(aSaldo,{" ",nSaldo})

    //Crio Linhas  de Saldo Inciial
    For nI:=1 to Len(aFilial)
        nPos:=Ascan(aSaldo,{|x| AllTrim(x[1])==Alltrim(aFILIAL[nI])})

        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="000"
        (_TFLX)->NOMEGR:="Saldos Iniciais"
        If nPos > 0
            (_TFLX)->(FieldPut(nInicio,aSaldo[nPos,2]))
        End
        MsUnLock()
    Next
    //Fim Saldo Bancario

    //Crio as Linhas de SubTotal
    For nI:=1 To Len(aFilial)
        For nJ:=1 To Len(aNSubTot)
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL := aFilial[nI]
            (_TFLX)->FLAG   := aNSubTot[nJ,1]
            (_TFLX)->NOMEGR := aNSubTot[nJ,2]
            MsUnLock()
        Next nJ
    Next nI

    // Calculo SubTot
    For nX:=1 to Len(aFilial)

        nDB := 0 //Soma Receitas despesas Bancarias
        nEB := 0 //Soma Endividamento Bancario
        nPG := 0 // Soma Pagamentos
        nRC := 0 // Soma Recebimentos
        nSF := 0 //Saldo FInal Caixa
        nSI := 0 // SAldos Iniciais
        nSL := 0 // Saldo de Caixa

        For nI:=nInicio To Len(aFields)-1
            cCampo:="%"+aFields[nI,1]+"%"
            cExpr:="%FILIAL = '"+aFilial[nX]+If(mv_par06==1,"' AND NATSG=' '","'")+"%"
            If SELECT((_TMP)) > 0
                (_TMP)->(dbCloseArea())
            End
            BeginSql Alias _TMP
                SELECT
                    FLAG,
                    SUM(%Exp:cCampo%)
                FROM
                    %Exp:cArqReal%
                WHERE
                    FLAG NOT IN ('99')
                    AND LEN(FLAG) = 2
                    AND %Exp:cExpr%
                GROUP BY
                    FLAG
            EndSql
            cQuery:=GetLastQuery()

            nRC:=0
            nPG:=0
            nSC:=0
            nEB:=0
            nDB:=0

            If nSF == 0  // Primeira Coluna
                nPos:=Ascan(aSaldo,{|x| AllTrim(x[1])==Alltrim(aFILIAL[nX])})
                If nPos > 0
                    nSI:=aSaldo[nPos,2]
                Else
                    nSI:=0
                End
            Else
                nSI:=nSF
            End

            While (_TMP)->(!EOF())
                If AllTrim((_TMP)->FLAG) == "11"
                    nRC+=(_TMP)->(FieldGet(2))
                ElseIf AllTrim((_TMP)->FLAG) == "21"
                    nPG+=(_TMP)->(FieldGet(2))
                ElseIf AllTrim((_TMP)->FLAG) == "51"
                    nEB+=(_TMP)->(FieldGet(2))
                ElseIf AllTrim((_TMP)->FLAG) == "52"
                    nEB-=(_TMP)->(FieldGet(2))
                ElseIf AllTrim((_TMP)->FLAG) == "71"
                    nDB-=(_TMP)->(FieldGet(2))
                ElseIf AllTrim((_TMP)->FLAG) == "72"
                    nDB+=(_TMP)->(FieldGet(2))
                ElseIf AllTrim((_TMP)->FLAG) == "73"
                    nDB-=(_TMP)->(FieldGet(2))
                ElseIf AllTrim((_TMP)->FLAG) == "74"
                    nDB+=(_TMP)->(FieldGet(2))
                End

                nSC:=nSI+nRC-nPG
                nSF:=nSC+nEB+nDB
                (_TMP)->(dbSkip())
            End
            (_TMP)->(dbCloseArea())

            //Grava Subtotais
            (_TFLX)->(dbSetOrder(If(lAnalitico,4,2)))

            //SAldos Inciais
            (_TFLX)->(MsSeek(aFilial[nX]+"000"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nSI))
            MsUnLock()

            //Grava Registro de Saldos Recebimentos
            (_TFLX)->(MsSeek(aFilial[nX]+"111"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nRC))
            MsUnLock()

            //Grava Registro de Saldos Pagamentos
            (_TFLX)->(MsSeek(aFilial[nX]+"211"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nPG))
            MsUnLock()

            //Grava Registro de Saldos Caixa Incial
            (_TFLX)->(MsSeek(aFilial[nX]+"311"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nSC))
            MsUnLock()

            /*
            //Grava Registro de Endividamento Bancario
            (_TFLX)->(MsSeek(aFilial[nX]+"611"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nEB))
            MsUnLock()

              //Grava Registro de Despeas/Receitas Bancarias
            (_TFLX)->(MsSeek(aFilial[nX]+"711"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nDB))
            MsUnLock()
            */
            //Grava Registro de Saldos Caixa Final
            (_TFLX)->(MsSeek(aFilial[nX]+"811"))
            RecLock((_TFLX),.F.)
            (_TFLX)->(FIELDPUT(nI,nSF))
            MsUnLock()

            nRC:=0
            nPG:=0
            nSC:=0
            nEB:=0
            nDB:=0
        Next nI
    Next nX

    // Tratamento para a Ultima coluna por ser um resumo geral

    For nX:=1 to Len(aFilial)
        nUltCol:=Len(aFields)
        cCampo:="%"+aFields[nUltCol,1]+"%"
        cExpr:="%FILIAL = '"+aFilial[nX]+If(mv_par06==1,"' AND NATSG=' '","'")+"%"
        If SELECT((_TMP)) > 0
            (_TMP)->(dbCloseArea())
        End
        BeginSql Alias _TMP
            SELECT
                FLAG,
                SUM(%Exp:cCampo%)
            FROM
                %Exp:cArqReal%
            WHERE
                FLAG NOT IN ('01')
                AND LEN(FLAG) = 2
                AND %Exp:cExpr%
            GROUP BY
                FLAG
        EndSql

        nSF:=0
        nRC:=0
        nPG:=0
        nSC:=0
        nEB:=0
        nDB:=0

        If nSF == 0  // Primeira Coluna
            nPos:=Ascan(aSaldo,{|x| AllTrim(x[1])==Alltrim(aFILIAL[nX])})
            If nPos > 0
                nSI:=aSaldo[nPos,2]
            Else
                nSI:=0
            End
        Else
            nSI:=nSF
        End

        //Soma SubTotal
        While (_TMP)->(!EOF())
            If AllTrim((_TMP)->FLAG) == "11"
                nRC+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "21"
                nPG+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "51"
                nEB+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "52"
                nEB-=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "71"
                nDB-=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "72"
                nDB+=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "73"
                nDB-=(_TMP)->(FieldGet(2))
            ElseIf AllTrim((_TMP)->FLAG) == "74"
                nDB+=(_TMP)->(FieldGet(2))
            End

            nSC:=nSI+nRC-nPG
            nSF:=nSC+nEB+nDB
            (_TMP)->(dbSkip())
        End

        (_TMP)->(dbCloseArea())

        //Grava Subtotais
        (_TFLX)->(dbSetOrder(If(lAnalitico,4,2)))

        //SAldos Inciais
        (_TFLX)->(MsSeek(aFilial[nX]+"000"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nSI))
        MsUnLock()

        //Grava Registro de Saldos Recebimentos
        (_TFLX)->(MsSeek(aFilial[nX]+"111"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nRC))
        MsUnLock()

        //Grava Registro de Saldos Pagamentos
        (_TFLX)->(MsSeek(aFilial[nX]+"211"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nPG))
        MsUnLock()

        //Grava Registro de Saldos Caixa Incial
        (_TFLX)->(MsSeek(aFilial[nX]+"311"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nSC))
        MsUnLock()

        /*
        //Grava Registro de Endividamento Bancario
        (_TFLX)->(MsSeek(aFilial[nX]+"611"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nEB))
        MsUnLock()

        //Grava Registro de Despesas/Receitas Bancarias
        (_TFLX)->(MsSeek(aFilial[nX]+"711"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nDB))
        MsUnLock()
        */
        //Grava Registro de Saldos Caixa Final
        (_TFLX)->(MsSeek(aFilial[nX]+"811"))
        RecLock((_TFLX),.F.)
        (_TFLX)->(FIELDPUT(nUltCol,nSF))
        MsUnLock()

    Next nX

    // Acresenta Linhas em branco
    For nI:=1 To Len(aFilial)

        // Pula Linha Apos SAldo inciail
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="001"
        MsUnLock()

        //Pula Linha depois do sem natureza se houver
        If ASCAN(aSemNat,aFilial[nI]) > 0
            RecLock((_TFLX),.T.)
            (_TFLX)->FILIAL:=aFilial[nI]
            (_TFLX)->FLAG:="002"
            MsUnLock()
        End

        //Linha de Soma de recebimento
        // Pula Linha antes
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="110"
        MsUnLock()

        // Pula Linha Depois
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="112"
        MsUnLock()

        // SAldo de Pagamentos
        // Pula Linha Antes
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="210"
        MsUnLock()

        // Pula Linha antes do Saldo de Caixa
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="310"
        MsUnLock()

        // Pula Linha antes do Saldo de Caixa
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="312"
        MsUnLock()


        /*
       RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="610"
        MsUnLock()
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="612"
        MsUnLock()

        // Pula Linha antes do Despesas Bancarias
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="312"
        MsUnLock()  // Pula Linha antes do Despesas Bancarias
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="710"
        MsUnLock()
        */

        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="810"
        MsUnLock()
        RecLock((_TFLX),.T.)
        (_TFLX)->FILIAL:=aFilial[nI]
        (_TFLX)->FLAG:="812"
        MsUnLock()

    Next
Return
