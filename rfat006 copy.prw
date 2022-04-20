#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} rfat006
//Relacao do faturamento por vendedor
@author mjlozzardo
@since 30/08/2018
@version 1.0
/*/
User Function rfat006()

Local aSays    := {}
Local aButtons := {}
Local aHelpPor := {}
Local cTitoDlg := "Faturamento por vendedor"
Local cPerg    := "RFAT006"
Local nOpca    := 0

//Pergunta 01
aHelpPor := {}
aAdd(aHelpPor, "Informe a data inicial")
aAdd(aHelpPor, "a ser considerada.")
U_FATUSX1(cPerg,"01","Data Inicio","Data Inicio","Data Inicio","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

//Pergunta 02
aHelpPor := {}
aAdd(aHelpPor, "Informe a data final")
aAdd(aHelpPor, "a ser considerada.")
U_FATUSX1(cPerg,"02","Data Final","Data Final","Data Final","MV_CH2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","", aHelpPor, aHelpPor, aHelpPor)

aAdd(aSays, "Rotina para gerar a relação das vendas, devolucoes e pedidos em carteira")
aAdd(aSays, "de acordo com o periodo informado.")
aAdd(aSays, "A planilha será salva no diretorio C:\TOTVS\RFAT006.XML ")

aAdd(aButtons,{5, .T., {|o| Pergunte(cPerg, .T.)}})
aAdd(aButtons,{1, .T., {|o| nOpca := 1, FechaBatch()}})
aAdd(aButtons,{2, .T., {|o| nOpca := 2, FechaBatch()}})

FormBatch(cTitoDlg, aSays, aButtons)
If nOpca == 1
	Pergunte(cPerg, .F.)
	MontaDir("C:\TOTVS\")
	Processa({|| U_rfat06ok("Gerando planilha, aguarde...")})
EndIf
Return

User Function rfat06ok()
Local aDados := {}
Local n1     := 0
Local nPos   := 0
Local cQuery := ""

Local cArqDst := "C:\TOTVS\RFAT006_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
Local oExcel  := FWMsExcelEX():New()
Local cPlan   := "Empresa_" + Rtrim(SM0->M0_CODIGO) + "_Filial_" + Rtrim(SM0->M0_CODFIL)
Local cTit    := "Relação das vendas por Vendedor De: " + Dtoc(MV_PAR01) + " Ate: " + Dtoc(MV_PAR02)
Local cQuebra := ""
Local nTotal1 := 0
Local nTotal2 := 0
Local nTotal3 := 0
Local nTotal4 := 0
Local nTotal5 := 0
Local nTotal6 := 0
Local nTotal7 := 0
Local nTotal8 := 0
Local nTotal9 := 0
Local nTotal10:= 0
Local nTotal90:= 0 // Valor
Local nTotal91:= 0 // Custo
Local nTotal1G := 0
Local nTotal2G := 0
Local nTotal3G := 0
Local nTotal4G := 0
Local nTotal5G := 0
Local nTotal6G := 0
Local nTotal7G := 0
Local nTotal8G := 0
Local nTotal9G := 0
Local nTotal10G:= 0
Local nTotal90G:= 0 // Valor
Local nTotal91G:= 0 // Custo
Local cRegiao  := ""
                                
//dados da planilha
oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan, cTit)
oExcel:AddColumn(cPlan, cTit, "Gerente" , 1, 1, .F.)  //01
oExcel:AddColumn(cPlan, cTit, "Vendedor", 1, 1, .F.)  //02
oExcel:AddColumn(cPlan, cTit, "Nome"    , 1, 1, .F.)  //03
oExcel:AddColumn(cPlan, cTit, "Meta", 3, 2, .F.)  //12
oExcel:AddColumn(cPlan, cTit, "Vlr.Fat. - Devol.", 3, 2, .F.)  //04
oExcel:AddColumn(cPlan, cTit, "Mrg. Contr.", 3, 2, .F.)  //
oExcel:AddColumn(cPlan, cTit, "Vlr.Devol."  , 3, 2, .F.)  //05
oExcel:AddColumn(cPlan, cTit, "% Atend."  	, 3, 2, .F.)  // 
oExcel:AddColumn(cPlan, cTit, "Aguard.Lib." , 3, 2, .F.)  //06
oExcel:AddColumn(cPlan, cTit, "Aguard.Crd." , 3, 2, .F.)  //07
oExcel:AddColumn(cPlan, cTit, "Aguard.Fat." , 3, 2, .F.)  //08
oExcel:AddColumn(cPlan, cTit, "Fat.no Dia"  , 3, 2, .F.)  //09
oExcel:AddColumn(cPlan, cTit, "PVs.no Dia"  , 3, 2, .F.)  //10
oExcel:AddColumn(cPlan, cTit, "Vlr.Transf."  , 3, 2, .F.)  //11


//busca faturamento geral
//cQuery := "SELECT A3_GEREN, F2_VEND1, A3_NOME, SUM(D2_TOTAL) VLRFAT, SUM(D2_CUSTO1) CUSTO "  //SUM(D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_ICMSDIF) VLRFAT"
cQuery := "SELECT A3_GEREN, F2_VEND1, A3_NOME, SUM(D2_TOTAL) VLRFAT, SUM(D2_CUSTO1) CUSTO, ISNULL(SUM(D2_VALBRUT - D2_VALIPI - D2_VALICM - D2_VALIMP5 - D2_VALIMP6 - D2_DESPESA - D2_VALFRE - D2_DESCON - D2_SEGURO - D2_ICMSRET), 0) AS VALOR "  //SUM(D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_ICMSDIF) VLRFAT"
cQuery += " FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4, " + RetSqlName("SF2") + " SF2"
cQuery += "  LEFT JOIN " + RetSqlName("SA3") + " SA3"
cQuery += "    ON A3_FILIAL = '" + FWxFilial("SA3") + "'"
cQuery += "   AND A3_COD = F2_VEND1"
cQuery += "   AND SA3.D_E_L_E_T_ = ''"
cQuery += " WHERE D2_FILIAL = '" + FWxFilial("SD2") + "'"
cQuery += "   AND D2_EMISSAO >= '" + Dtos(MV_PAR01) + "'"
cQuery += "   AND D2_EMISSAO <= '" + Dtos(MV_PAR02) + "'"
cQuery += "   AND D2_TIPO = 'N'"
cQuery += "   AND SD2.D_E_L_E_T_ = ''"
cQuery += "   AND F4_FILIAL = ''"
cQuery += "   AND F4_CODIGO = D2_TES"
cQuery += "   AND F4_DUPLIC = 'S'"
cQuery += "   AND SF4.D_E_L_E_T_ = ''"
cQuery += "   AND F2_FILIAL = '" + FWxFilial("SF2") + "'"
cQuery += "   AND F2_DOC = D2_DOC"
cQuery += "   AND F2_SERIE = D2_SERIE"
cQuery += "   AND F2_CLIENTE = D2_CLIENTE"
cQuery += "   AND F2_LOJA = D2_LOJA"
//cQuery += "   AND F2_CLIENTE NOT IN ('006043', '001604')"
cQuery += "   AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "   AND SF2.D_E_L_E_T_ = ''"
cQuery += " GROUP BY A3_GEREN, A3_NOME, F2_VEND1"
cQuery += " ORDER BY A3_GEREN, A3_NOME, F2_VEND1"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

SA3->(DbSetOrder(1))
TRB1->(DbGoTop())
While TRB1->(!Eof())
	nPos := aScan(aDados, {|x|, x[2] == TRB1->F2_VEND1})
	If nPos > 0
		aDados[nPos, 4] += TRB1->VLRFAT
		aDados[nPos, 13] += TRB1->CUSTO
		aDados[nPos, 14] += TRB1->VALOR
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {TRB1->A3_GEREN, TRB1->F2_VEND1, TRB1->A3_NOME, TRB1->VLRFAT, 0, 0, 0, 0, 0, 0, 0, 0, TRB1->CUSTO, TRB1->VALOR})
	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

//busca devolucoes
//cQuery := "SELECT SUM(D1_TOTAL + D1_VALIPI + D1_ICMSRET) D1_TOTAL, F2_VEND1, SUM(D1_CUSTO) CUSTO
cQuery := "SELECT SUM(D1_TOTAL-D1_VALDESC-D1_VALIPI+D1_DESPESA+D1_VALFRE+D1_SEGURO-D1_ICMSRET-D1_VALICM-D1_VALIMP5-D1_VALIMP6) D1_TOTAL, F2_VEND1, SUM(D1_CUSTO) CUSTO
//cQuery += "	FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SF2") + " SF2"
cQuery += "	FROM " + RetSqlName("SD1") + " SD1, " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF2") + " SF2, " + RetSqlName("SF4") + " SF4"
cQuery += "	WHERE D1_FILIAL = '" + FWxFilial("SD1") + "'"
cQuery += "	  AND D1_DTDIGIT >= '" + Dtos(MV_PAR01) + "'"
cQuery += "	  AND D1_DTDIGIT <= '" + Dtos(MV_PAR02) + "'"
cQuery += "	  AND D1_TIPO = 'D'"
cQuery += "	  AND SD1.D_E_L_E_T_ = ''"
//--------------
cQuery += "  AND D2_DOC = D1_NFORI "
cQuery += "  AND D2_SERIE = D1_SERIORI "
cQuery += "  AND D2_CLIENTE = D1_FORNECE "
cQuery += "  AND D2_LOJA = D1_LOJA "
cQuery += "  AND D2_ITEM = D1_ITEMORI "
cQuery += "  AND D2_TIPO = 'N' "
cQuery += "  AND SD2.D_E_L_E_T_ = ' ' "
//--------------
cQuery += "   AND F4_FILIAL = ''"
cQuery += "   AND F4_CODIGO = D2_TES"
cQuery += "   AND F4_DUPLIC = 'S'"
cQuery += "   AND SF4.D_E_L_E_T_ = ''"
//--------------
cQuery += "	  AND F2_FILIAL = D1_FILIAL"
cQuery += "	  AND F2_DOC = D1_NFORI"
cQuery += "	  AND F2_SERIE = D1_SERIORI"
cQuery += "	  AND F2_CLIENTE = D1_FORNECE"
cQuery += "	  AND F2_LOJA = D1_LOJA"
cQuery += "   AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "	  AND SF2.D_E_L_E_T_ = ''"
cQuery += "	GROUP BY F2_VEND1"
cQuery += "	ORDER BY F2_VEND1"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

TRB1->(DbGoTop())
While TRB1->(!Eof())
	SA3->(DbSeek(FWxFilial("SA3") + TRB1->F2_VEND1, .F.))
	nPos := aScan(aDados, {|x|, x[2] == TRB1->F2_VEND1})
	If nPos > 0
		aDados[nPos, 5]  += TRB1->D1_TOTAL
		//aDados[nPos, 13] += TRB1->CUSTO
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {SA3->A3_GEREN, TRB1->F2_VEND1, SA3->A3_NOME, 0, TRB1->D1_TOTAL, 0, 0, 0, 0, 0, 0, 0, 0, 0}) //TRB1->CUSTO
	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

//busca carteira
cQuery := "SELECT C5_VEND1, SUM((C6_QTDVEN-C6_QTDENT) * C6_PRCVEN) TOTAL"
cQuery += "	FROM " + RetSqlName("SC5") + " SC5, " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF4") + " SF4"
cQuery += "	WHERE C5_FILIAL = '" + FWxFilial("SC5") + "'"
cQuery += "	  AND C5_TIPO = 'N'"
cQuery += "	  AND C5_LIBEROK = ''"
cQuery += "	  AND SC5.D_E_L_E_T_ = ''"
cQuery += "	  AND C6_FILIAL = C5_FILIAL"
cQuery += "	  AND C6_NUM = C5_NUM"
cQuery += "	  AND C6_QTDENT < C6_QTDVEN"
cQuery += "	  AND C6_BLQ = ' '"
cQuery += "	  AND SC6.D_E_L_E_T_ = ''"
cQuery += "	  AND F4_FILIAL = '" + FWxFilial("SF4") + "'"
cQuery += "	  AND F4_CODIGO = C6_TES"
cQuery += "	  AND F4_DUPLIC = 'S'"
cQuery += "   AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "	  AND SF4.D_E_L_E_T_ = ''"
cQuery += "	GROUP BY C5_VEND1"
cQuery += "	ORDER BY C5_VEND1"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

TRB1->(DbGoTop())
While TRB1->(!Eof())
	SA3->(DbSeek(FWxFilial("SA3") + TRB1->C5_VEND1, .F.))
	nPos := aScan(aDados, {|x|, x[2] == TRB1->C5_VEND1})
	If nPos > 0
		aDados[nPos, 6] += TRB1->TOTAL
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {SA3->A3_GEREN, TRB1->C5_VEND1, SA3->A3_NOME, 0, 0, TRB1->TOTAL, 0, 0, 0, 0, 0, 0, 0, 0})
	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

//busca carteira blq.credito
cQuery := "SELECT C5_VEND1, SUM((C9_QTDLIB * C9_PRCVEN)) TOTAL"
cQuery += "	FROM " + RetSqlName("SC9") + " SC9, " + RetSqlName("SC5") + " SC5, " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF4") + " SF4"
cQuery += "	WHERE C9_FILIAL = '" + FWxFilial("SC9") + "'"
cQuery += "	  AND C9_NFISCAL = ''"
cQuery += "   AND C9_BLCRED <> ''"
cQuery += "	  AND SC9.D_E_L_E_T_ = ''"
cQuery += "	  AND C5_FILIAL = C9_FILIAL"
cQuery += "	  AND C5_NUM = C9_PEDIDO"
cQuery += "	  AND C5_TIPO = 'N'"
cQuery += "	  AND SC5.D_E_L_E_T_ = ''"
cQuery += "	  AND C6_FILIAL = C9_FILIAL"
cQuery += "	  AND C6_NUM = C9_PEDIDO"
cQuery += "	  AND C6_ITEM = C9_ITEM"
cQuery += "	  AND C6_BLQ = ' '"
cQuery += "	  AND SC6.D_E_L_E_T_ = ''"
cQuery += "	  AND F4_FILIAL = '" + FWxFilial("SF4") + "'"
cQuery += "	  AND F4_CODIGO = C6_TES"
cQuery += "	  AND F4_DUPLIC = 'S'"
cQuery += "   AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "	  AND SF4.D_E_L_E_T_ = ''"
cQuery += "	GROUP BY C5_VEND1"
cQuery += "	ORDER BY C5_VEND1"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

TRB1->(DbGoTop())
While TRB1->(!Eof())
	SA3->(DbSeek(FWxFilial("SA3") + TRB1->C5_VEND1, .F.))
	nPos := aScan(aDados, {|x|, x[2] == TRB1->C5_VEND1})
	If nPos > 0
		aDados[nPos, 7] += TRB1->TOTAL
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {SA3->A3_GEREN, TRB1->C5_VEND1, SA3->A3_NOME, 0, 0, 0, TRB1->TOTAL, 0, 0, 0, 0, 0, 0, 0})
	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

//aguardando faturamento
cQuery := "SELECT C5_VEND1, SUM((C9_QTDLIB * C9_PRCVEN)) TOTAL"
cQuery += "	FROM " + RetSqlName("SC9") + " SC9, " + RetSqlName("SC5") + " SC5, " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF4") + " SF4"
cQuery += "	WHERE C9_FILIAL = '" + FWxFilial("SC9") + "'"
cQuery += "	  AND C9_NFISCAL = ''"
cQuery += "   AND C9_BLCRED = ''"
cQuery += "	  AND SC9.D_E_L_E_T_ = ''"
cQuery += "	  AND C5_FILIAL = C9_FILIAL"
cQuery += "	  AND C5_NUM = C9_PEDIDO"
cQuery += "	  AND C5_TIPO = 'N'"
cQuery += "	  AND SC5.D_E_L_E_T_ = ''"
cQuery += "	  AND C6_FILIAL = C9_FILIAL"
cQuery += "	  AND C6_NUM = C9_PEDIDO"
cQuery += "	  AND C6_ITEM = C9_ITEM"
cQuery += "	  AND C6_BLQ = ' '"
cQuery += "	  AND SC6.D_E_L_E_T_ = ''"
cQuery += "	  AND F4_FILIAL = '" + FWxFilial("SF4") + "'"
cQuery += "	  AND F4_CODIGO = C6_TES"
cQuery += "	  AND F4_DUPLIC = 'S'"
cQuery += "   AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "	  AND SF4.D_E_L_E_T_ = ''"
cQuery += "	GROUP BY C5_VEND1"
cQuery += "	ORDER BY C5_VEND1"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

TRB1->(DbGoTop())
While TRB1->(!Eof())
	SA3->(DbSeek(FWxFilial("SA3") + TRB1->C5_VEND1, .F.))
	nPos := aScan(aDados, {|x|, x[2] == TRB1->C5_VEND1})
	If nPos > 0
		aDados[nPos, 8] += TRB1->TOTAL
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {SA3->A3_GEREN, TRB1->C5_VEND1, SA3->A3_NOME, 0, 0, 0, 0, TRB1->TOTAL, 0, 0, 0, 0, 0, 0})
	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

//busca faturamento do dia
//	cQuery := "SELECT A3_GEREN, F2_VEND1, A3_NOME, SUM(D2_TOTAL) VLRFAT "  //SUM(D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_ICMSDIF) VLRFAT"
cQuery := "SELECT A3_GEREN, F2_VEND1, A3_NOME, SUM((D2_TOTAL) - D2_VALIPI - D2_ICMSRET - D2_ICMSDIF) VLRFAT "  //SUM(D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_ICMSDIF) VLRFAT"
cQuery += " FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4, " + RetSqlName("SF2") + " SF2"
cQuery += "  LEFT JOIN " + RetSqlName("SA3") + " SA3"
cQuery += "    ON A3_FILIAL = '" + FWxFilial("SA3") + "'"
cQuery += "   AND A3_COD = F2_VEND1"
cQuery += "   AND SA3.D_E_L_E_T_ = ''"
cQuery += " WHERE D2_FILIAL = '" + FWxFilial("SD2") + "'"
cQuery += "   AND D2_EMISSAO = '" + Dtos(dDataBase) + "'"
cQuery += "   AND D2_TIPO = 'N'"
cQuery += "   AND SD2.D_E_L_E_T_ = ''"
cQuery += "   AND F4_FILIAL = ''"
cQuery += "   AND F4_CODIGO = D2_TES"
cQuery += "   AND F4_DUPLIC = 'S'"
cQuery += "   AND SF4.D_E_L_E_T_ = ''"
cQuery += "   AND F2_FILIAL = '" + FWxFilial("SF2") + "'"
cQuery += "   AND F2_DOC = D2_DOC"
cQuery += "   AND F2_SERIE = D2_SERIE"
cQuery += "   AND F2_CLIENTE = D2_CLIENTE"
cQuery += "   AND F2_LOJA = D2_LOJA"
cQuery += "   AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "   AND SF2.D_E_L_E_T_ = ''"
cQuery += " GROUP BY A3_GEREN, A3_NOME, F2_VEND1"
cQuery += " ORDER BY A3_GEREN, A3_NOME, F2_VEND1"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

SA3->(DbSetOrder(1))
TRB1->(DbGoTop())
While TRB1->(!Eof())
	nPos := aScan(aDados, {|x|, x[2] == TRB1->F2_VEND1})
	If nPos > 0
		aDados[nPos, 9] += TRB1->VLRFAT
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {TRB1->A3_GEREN, TRB1->F2_VEND1, TRB1->A3_NOME, 0, 0, 0, 0, 0, TRB1->VLRFAT, 0, 0, 0, 0, 0})
	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

//busca pedidos colocados no dia
//	cQuery := "SELECT C5_VEND1, SUM((C6_QTDVEN-C6_QTDENT) * C6_PRCVEN) TOTAL"
cQuery := "SELECT C5_VEND1, SUM(C6_QTDVEN * C6_PRCVEN) TOTAL"
cQuery += "	FROM " + RetSqlName("SC5") + " SC5, " + RetSqlName("SC6") + " SC6, " + RetSqlName("SF4") + " SF4"
cQuery += "	WHERE C5_FILIAL = '" + FWxFilial("SC5") + "'"
cQuery += "   AND C5_EMISSAO = '" + Dtos(dDataBase) + "'"
cQuery += "	  AND C5_TIPO = 'N'"
cQuery += "	  AND SC5.D_E_L_E_T_ = ''"
cQuery += "	  AND C6_FILIAL = C5_FILIAL"
cQuery += "	  AND C6_NUM = C5_NUM"
cQuery += "	  AND C6_BLQ = ' '"
cQuery += "	  AND SC6.D_E_L_E_T_ = ''"
cQuery += "	  AND F4_FILIAL = '" + FWxFilial("SF4") + "'"
cQuery += "	  AND F4_CODIGO = C6_TES"
cQuery += "	  AND F4_DUPLIC = 'S'"
cQuery += "   AND NOT EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "	  AND SF4.D_E_L_E_T_ = ''"
cQuery += "	GROUP BY C5_VEND1"
cQuery += "	ORDER BY C5_VEND1"
cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

TRB1->(DbGoTop())
While TRB1->(!Eof())
	SA3->(DbSeek(FWxFilial("SA3") + TRB1->C5_VEND1, .F.))
	nPos := aScan(aDados, {|x|, x[2] == TRB1->C5_VEND1})
	If nPos > 0
		aDados[nPos, 10] += TRB1->TOTAL
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {SA3->A3_GEREN, TRB1->F2_VEND1, SA3->A3_NOME, 0, 0, 0, 0, 0, 0, TRB1->TOTAL, 0, 0, 0, 0})
	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

//busca transferencias.
cQuery := "SELECT A3_GEREN, F2_VEND1, A3_NOME, SUM(D2_TOTAL) VLRFAT"  //SUM(D2_TOTAL + D2_VALIPI + D2_ICMSRET + D2_ICMSDIF) VLRFAT"
cQuery += " FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SF4") + " SF4, " + RetSqlName("SF2") + " SF2"
cQuery += "  LEFT JOIN " + RetSqlName("SA3") + " SA3"
cQuery += "    ON A3_FILIAL = '" + FWxFilial("SA3") + "'"
cQuery += "   AND A3_COD = F2_VEND1"
cQuery += "   AND SA3.D_E_L_E_T_ = ''"
cQuery += " WHERE D2_FILIAL = '" + FWxFilial("SD2") + "'"
cQuery += "   AND D2_EMISSAO >= '" + Dtos(MV_PAR01) + "'"
cQuery += "   AND D2_EMISSAO <= '" + Dtos(MV_PAR02) + "'"
cQuery += "   AND D2_TIPO = 'N'"
cQuery += "   AND SD2.D_E_L_E_T_ = ''"
cQuery += "   AND F4_FILIAL = ''"
cQuery += "   AND F4_CODIGO = D2_TES"
cQuery += "   AND F4_DUPLIC = 'S'"
cQuery += "   AND SF4.D_E_L_E_T_ = ''"
cQuery += "   AND F2_FILIAL = '" + FWxFilial("SF2") + "'"
cQuery += "   AND F2_DOC = D2_DOC"
cQuery += "   AND F2_SERIE = D2_SERIE"
cQuery += "   AND F2_CLIENTE = D2_CLIENTE"
cQuery += "   AND F2_LOJA = D2_LOJA"
//cQuery += "   AND F2_CLIENTE IN ('006043', '001604')"
cQuery += "   AND EXISTS (SELECT A1_FILIAL FROM " + RetSqlName("SA1") + " WHERE A1_FILIAL = '" + xFilial("SA1") + "' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1_EQ_PRRL = '1' AND D_E_L_E_T_ = ' ') "
cQuery += "   AND SF2.D_E_L_E_T_ = ''"
cQuery += " GROUP BY A3_GEREN, A3_NOME, F2_VEND1"
cQuery += " ORDER BY A3_GEREN, A3_NOME, F2_VEND1"
cQuery := ChangeQuery(cQuery)
MemoWrite("RFAT006_TRANSF.sql", cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

SA3->(DbSetOrder(1))
TRB1->(DbGoTop())
While TRB1->(!Eof())
	nPos := aScan(aDados, {|x|, x[2] == TRB1->F2_VEND1})
	If nPos > 0
		aDados[nPos, 11] += TRB1->VLRFAT
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		//aAdd(aDados, {SA3->A3_GEREN, TRB1->F2_VEND1, SA3->A3_NOME, 0, 0, 0, 0, 0, 0, 0, TRB1->VLRFAT})
		aAdd(aDados, {TRB1->A3_GEREN, TRB1->F2_VEND1, TRB1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, TRB1->VLRFAT, 0, 0, 0})

	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())

cQuery := "SELECT A3_GEREN, CT_VEND, A3_NOME, SUM(CT_VALOR) VLRMETA "+CRLF
cQuery += "FROM "+RetSqlName("SCT")+" SCT "+CRLF
cQuery += "INNER JOIN "+RetSqlName("SA3")+" SA3 ON A3_FILIAL = '"+xFilial("SA3")+"' AND A3_COD = CT_VEND AND SA3.D_E_L_E_T_ = ''"+CRLF
cQuery += "WHERE CT_DATA BETWEEN '" + Dtos(MV_PAR01) + "' AND '" + Dtos(MV_PAR02) + "'"+CRLF
cQuery += "AND CT_FILIAL = '"+xFilial("SCT")+"' "+CRLF
cQuery += "AND CT_MSBLQL <> '1'"+CRLF
cQuery += "AND SCT.D_E_L_E_T_ = ''"+CRLF
cQuery += "GROUP BY A3_GEREN, CT_VEND, A3_NOME"+CRLF
cQuery += "ORDER BY A3_GEREN, CT_VEND, A3_NOME"+CRLF

cQuery := ChangeQuery(cQuery)
MemoWrite("RFAT006_META.sql", cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB1", .F., .F.)

SA3->(DbSetOrder(1))
TRB1->(DbGoTop())
While TRB1->(!Eof())
	nPos := aScan(aDados, {|x|, x[2] == TRB1->CT_VEND})
	If nPos > 0
		aDados[nPos, 12] += TRB1->VLRMETA
	Else
		//GERENTE, VENDEDOR, NOME, TOT.FAT, TOT.DEV., LIB., CRED., FAT. TOT.DIA, META
		aAdd(aDados, {TRB1->A3_GEREN, TRB1->CT_VEND, TRB1->A3_NOME, 0, 0, 0, 0, 0, 0, 0, 0, TRB1->VLRMETA, 0, 0})

	EndIf
	TRB1->(DbSkip())
EndDo
TRB1->(DbCloseArea())


If Len(aDados) > 0
	aSort(aDados,,, {|x,y| x[1] < y[1]})
	cQuebra := aDados[1, 1]
	nTotal1 := 0
	nTotal2 := 0
	nTotal3 := 0
	nTotal4 := 0
	nTotal5 := 0
	nTotal6 := 0
	nTotal7 := 0
	nTotal8 := 0
	nTotal9 := 0
	nTotal10 := 0
	nTotal90 := 0
	nTotal91 := 0
	
	For n1 := 1 To Len(aDados)
		nTotal1G  += aDados[n1, 4] - aDados[n1, 5]//aDados[n1, 4]
		nTotal2G  += aDados[n1, 5]
		nTotal3G  += aDados[n1, 6]
		nTotal4G  += aDados[n1, 7]
		nTotal5G  += aDados[n1, 8]
		nTotal6G  += aDados[n1, 9]
		nTotal7G  += aDados[n1,10]
		nTotal8G  += aDados[n1,11]
		nTotal9G  += aDados[n1,12]
		nTotal10G += aDados[n1,13]
		If aDados[n1,14] > 0 .And. aDados[n1,13] > 0
			nTotal90G += aDados[n1,14]
			nTotal91G += aDados[n1,13]
		EndIf
		
		If cQuebra == aDados[n1, 1]
			
			If Left(cFilAnt,2) == "08"
				If	Empty(cQuebra)
					cRegiao :=  "TOTAL DA REGIAO - CD JAYS"  
				ElseIf cQuebra == "000001"
					cRegiao :=  "TOTAL REGIONAL SÃO PAULO 2"//"TOTAL DA REGIAO - INTERIOR 2"
				ElseIf cQuebra == "000035"
					cRegiao :=  "TOTAL DA REGIAO - INTERNO"
				ElseIf cQuebra == "000093"
					cRegiao :=  "TOTAL DA REGIAO - LITORAL"
				ElseIf Alltrim(cQuebra) $ "001995|002065"
					cRegiao := "TOTAL DA REGIAO - NOVOS NEGOCIOS"
				ElseIf Alltrim(cQuebra) $ "002003|002047"
					cRegiao :=  "TOTAL DA REGIAO - RIO CENTRO"
				ElseIf cQuebra == "002027"
					cRegiao :=  "TOTAL DA REGIAO - SUL"
				ElseIf cQuebra == "002048"
					cRegiao :=  "TOTAL DA REGIAO SÃO PAULO 1"
				ElseIf cQuebra == "002071"
					cRegiao :=  "TOTAL DICICO"
				Else
					cRegiao :=  "TOTAL DA REGIAO"
				EndIf
			Else
				cRegiao :=  "TOTAL GERENTE"
			EndIf	
	
			oExcel:AddRow(cPlan, cTit,{aDados[n1, 1],;  //gerente
			aDados[n1, 2],;  //vendedor
			aDados[n1, 3],;	//nome
			aDados[n1, 12],;	//Meta
			aDados[n1, 4] - aDados[n1, 5],;//aDados[n1, 4],;	//fat.geral
			Transform(IIf(aDados[n1, 4] <= 0, 0, 100 - ((aDados[n1, 13] / aDados[n1, 14]) * 100)),"@R 999.99%"),;//Fator (Transform(IIf(aDados[n1, 4] <= 0, 0, 100.00 - ((aDados[n1, 13] / (aDados[n1, 4] - aDados[n1, 5])) * 100.00)),"@R 999.99%"),;//Fator)
			aDados[n1, 5],;	//devolucoes
			Iif(aDados[n1, 12] > 0, Transform(((aDados[n1, 4]-aDados[n1, 5]) / aDados[n1, 12])*100,"@R 9999%"),"") ,;	//% Atend.
			aDados[n1, 6],;	//aguard.lib
			aDados[n1, 7],;	//aguard.crd
			aDados[n1, 8],;	//aguard.fat
			aDados[n1, 9],;	//fat.dia
			aDados[n1,10],;	//pedido dia
			aDados[n1,11]})	//Transferencias
			nTotal1 += aDados[n1, 4] - aDados[n1, 5] //aDados[n1, 4]
			nTotal2 += aDados[n1, 5]
			nTotal3 += aDados[n1, 6]
			nTotal4 += aDados[n1, 7]
			nTotal5 += aDados[n1, 8]
			nTotal6 += aDados[n1, 9]
			nTotal7 += aDados[n1,10]
			nTotal8 += aDados[n1,11]
			nTotal9 += aDados[n1,12]
			nTotal10+= aDados[n1,13]
			If aDados[n1,14] > 0 .And. aDados[n1,13] > 0
				nTotal90+= aDados[n1,14]
				nTotal91+= aDados[n1,13]
			EndIf
		Else

			If Left(cFilAnt,2) == "08"
				If	Empty(cQuebra)
					cRegiao :=  "TOTAL DA REGIAO - CD JAYS"  
				ElseIf cQuebra == "000001"
					cRegiao :=  "TOTAL REGIONAL SÃO PAULO 2"//"TOTAL DA REGIAO - INTERIOR 2"
				ElseIf cQuebra == "000035"
					cRegiao :=  "TOTAL DA REGIAO - INTERNO"
				ElseIf cQuebra == "000093"
					cRegiao :=  "TOTAL DA REGIAO - LITORAL"
				ElseIf Alltrim(cQuebra) $ "001995|002065"
					cRegiao := "TOTAL DA REGIAO - NOVOS NEGOCIOS"
				ElseIf Alltrim(cQuebra) $ "002003|002047"
					cRegiao :=  "TOTAL DA REGIAO - RIO CENTRO"
				ElseIf cQuebra == "002027"
					cRegiao :=  "TOTAL DA REGIAO - SUL"
				ElseIf cQuebra == "002048"
					cRegiao :=  "TOTAL DA REGIAO SÃO PAULO 1"
				ElseIf cQuebra == "002071"
					cRegiao :=  "TOTAL DICICO"
				Else
					cRegiao :=  "TOTAL DA REGIAO"
				EndIf
			Else
				cRegiao :=  "TOTAL GERENTE"
			EndIf	

			oExcel:AddRow(cPlan, cTit,{" ",;  //gerente
			" ",;  //vendedor
			cRegiao,;
			nTotal9,;  //Meta
			nTotal1,;  //fat.geral
			Transform(IIf(nTotal1 <= 0, 0, 100 - ((nTotal91 / nTotal90) * 100)),"@R 999.99%"),;//Fator (Transform(IIf(nTotal1 <= 0, 0, 100.00 - ((nTotal10 / nTotal1) * 100.00)),"@R 999.99%"))
			nTotal2,;  //devolucoes
			Iif(nTotal9 > 0,Transform(( (nTotal1-nTotal2) / nTotal9)*100,"@R 9999%"),""),;  //% Atend.
			nTotal3,;  //aguard.lib
			nTotal4,;  //aguard.crd
			nTotal5,;  //aguard.fat
			nTotal6,;  //fat.dia
			nTotal7,;  //pedido dia
			nTotal8})  //Transferencias
			
			oExcel:AddRow(cPlan, cTit,{" ",;  //gerente
			" ",;  //vendedor
			" ",;  //nome
			"",;  //Meta
			"",;  //fat.geral
			"",;  //Fator
			"",;  //devolucoes
			"",;  //% Atend.
			"",;  //aguard.lib
			"",;  //aguard.crd
			"",;  //aguard.fat
			"",;	//fat.dia
			"",; //pedido dia
			}) //Transferencias
			
			cQuebra := aDados[n1, 1]
			nTotal1 := aDados[n1, 4] - aDados[n1, 5] //aDados[n1, 4]
			nTotal2 := aDados[n1, 5]
			nTotal3 := aDados[n1, 6]
			nTotal4 := aDados[n1, 7]
			nTotal5 := aDados[n1, 8]
			nTotal6 := aDados[n1, 9]
			nTotal7 := aDados[n1,10]
			nTotal8 := aDados[n1,11]
			nTotal9 := aDados[n1,12]
			nTotal10:= aDados[n1,13]
			If aDados[n1,14] > 0 .And. aDados[n1,13] > 0
				nTotal90:= aDados[n1,14]
				nTotal91:= aDados[n1,13]
			EndIf
			oExcel:AddRow(cPlan, cTit,{aDados[n1, 1],;  //gerente
			aDados[n1, 2],;  //vendedor
			aDados[n1, 3],;	//nome
			aDados[n1, 12],;	//Meta
			aDados[n1, 4]-aDados[n1, 5],;//aDados[n1, 4],;	//fat.geral
			Transform(IIf(aDados[n1, 4] <= 0, 0, 100 - ((aDados[n1, 13] / aDados[n1, 14]) * 100)),"@R 999.99%"),;//Fator (Transform(IIf(aDados[n1, 4] <= 0, 0, 100.00 - ((aDados[n1, 13] / (aDados[n1, 4] - aDados[n1, 5])) * 100.00)),"@R 999.99%"))
			aDados[n1, 5],;	//devolucoes
			Iif(aDados[n1, 12] > 0, Transform(((aDados[n1, 4] - aDados[n1, 5])/aDados[n1, 12])*100,"@R 9999%"),""),;	//% Atend.
			aDados[n1, 6],;	//aguard.lib
			aDados[n1, 7],;	//aguard.crd
			aDados[n1, 8],;	//aguard.fat
			aDados[n1, 9],;	//fat.dia
			aDados[n1,10],;	//pedido dia
			aDados[n1,11]}) //Transferencias
			
		EndIf
	Next n1

	If Left(cFilAnt,2) == "08"
		If	Empty(cQuebra)
			cRegiao :=  "TOTAL DA REGIAO - CD JAYS"  
		ElseIf cQuebra == "000001"
			cRegiao :=  "TOTAL REGIONAL SÃO PAULO 2"//"TOTAL DA REGIAO - INTERIOR 2"
		ElseIf cQuebra == "000035"
			cRegiao :=  "TOTAL DA REGIAO - INTERNO"
		ElseIf cQuebra == "000093"
			cRegiao :=  "TOTAL DA REGIAO - LITORAL"
		ElseIf Alltrim(cQuebra) $ "001995|002065"
			cRegiao := "TOTAL DA REGIAO - NOVOS NEGOCIOS"
		ElseIf Alltrim(cQuebra) $ "002003|002047"
			cRegiao :=  "TOTAL DA REGIAO - RIO CENTRO"
		ElseIf cQuebra == "002027"
			cRegiao :=  "TOTAL DA REGIAO - SUL"
		ElseIf cQuebra == "002048"
			cRegiao :=  "TOTAL DA REGIAO SÃO PAULO 1"
		ElseIf cQuebra == "002071"
			cRegiao :=  "TOTAL DICICO"
		Else
			cRegiao :=  "TOTAL DA REGIAO"
		EndIf
	Else
		cRegiao :=  "TOTAL GERENTE"
	EndIf	

	oExcel:AddRow(cPlan, cTit,{" ",;  //gerente
	" ",;  //vendedor
	cRegiao,;  //nome
	nTotal9,;  //Meta
	nTotal1,;  //fat.geral
	Transform(IIf(nTotal1 <= 0, 0, 100 - ((nTotal91 / nTotal90) * 100)),"@R 999.99%"),;//Fator (Transform(IIf(nTotal1 <= 0, 0, 100.00 - ((nTotal10 / nTotal1) * 100.00)),"@R 999.99%"))
	nTotal2,;  //devolucoes
	Iif(nTotal9 > 0,Transform(( (nTotal1 - nTotal2)/nTotal9)*100,"@R 9999%"),""),;  //% Atend.
	nTotal3,;  //aguard.lib
	nTotal4,;  //aguard.crd
	nTotal5,;  //aguard.fat
	nTotal6,;  //fat.dia
	nTotal7,;  //pedido dia
	nTotal8})  //Transferencias
	
	oExcel:AddRow(cPlan, cTit,{" ",;  //gerente
	" ",;  //vendedor
	" ",;  //nome
	"",;  //Meta
	"",;  //fat.geral
	"",;  //Fator
	"",;  //devolucoes
	"",;  //% Atend.
	"",;  //aguard.lib
	"",;  //aguard.crd
	"",;  //aguard.fat
	"",;  //fat.dia
	"",;  //pedido dia
	})	//Transferencias
	
	oExcel:AddRow(cPlan, cTit,{" ",;  //gerente
	" ",;  //vendedor
	"T O T A L  G E R A L",;  //nome
	nTotal9G,;  //Meta
	nTotal1G,;  //fat.geral
	Transform(IIf(nTotal1G <= 0, 0, 100 - ((nTotal91G / nTotal90G) * 100)),"@R 999.99%"),;//Fator (Transform(IIf(nTotal1G <= 0, 0, 100.00 - ((nTotal10G / nTotal1G) * 100.00)),"@R 999.99%"))
	nTotal2G,;  //devolucoes
	Iif(nTotal9G > 0,Transform(( (nTotal1G - nTotal2G)/nTotal9G)*100,"@R 9999%"),""),;  //% Atend.
	nTotal3G,;  //aguard.lib
	nTotal4G,;  //aguard.crd
	nTotal5G,;  //aguard.fat
	nTotal6G,;  //fat.dia
	nTotal7G,;  //pedido dia
	nTotal8G})  //Transferencias
	
	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()
	
EndIf
Return

Static Function OPENXML(cArq)
Local cDirDocs := MsDocPath()
Local cPath	   := AllTrim(GetTempPath())

If !ApOleClient("MsExcel")
	Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
Else
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cArq)
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()
EndIf

Return