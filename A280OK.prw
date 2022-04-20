#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ A280OK   บ Autor ณ Fabio F. Sousa   บ Data ณ  28/11/2017   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ PE: Validar Virada de Saldos...                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Grupo Sabarแ                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function A280OK()

Local lRetorno    := .T.
Local lMostraTudo := AllTrim( Upper( FunName() ) ) <> "MATA280"
Local dDataFec    := dDataBase

Private cMensagem := ""
Private dUltFec   := GetMv("MV_ULMES")
Private dProxFec  := STOD(Left(DTOS(GetMv("MV_ULMES") + 32), 6) + "01") - 1
Private dAtual    := STOD(Left(DTOS( MsDate() ), 6) + "01") - 1 // Conclui fechamento atualizado...

If AllTrim( Upper( GetEnvServer() ) ) == "FABIO"
	Return lRetorno
EndIf

If !lMostraTudo
	dDataFec := ParamIXB[1]
Else
	dDataFec := dProxFec
EndIf

If DTOS( dProxFec ) < "20200131"
	lRetorno  := .T.
	Return lRetorno
EndIf

If MsDate() < dProxFec
	cMensagem += 'Data para o fechamento ' + DTOC(dProxFec) + ' maior que a data atual, fechamento de estoque impedido!'
	lRetorno  := .F.
EndIf

If dDataBase <> dProxFec
	cMensagem += 'Altere a data base do sistema para a mesma data do pr๓ximo fechamento: ' + DTOC(dProxFec) + ' para executar a virada de saldos, fechamento de estoque impedido!'
	lRetorno  := .F.
EndIf

If dDataFec <> dProxFec
	cMensagem += 'Data de fechamento incorreta, verifique os parโmetros, fechamento de estoque impedido!'
	lRetorno  := .F.
EndIf

If lRetorno .Or. lMostraTudo
	// Validar Erros Crํticos...
	lRetorno := fDivCrit(lRetorno)
EndIf

If lRetorno .Or. lMostraTudo
	// Validar se Perํodo estแ Bloqueado para movimenta็๕es de estoques...
	lRetorno := fPerBloq(lRetorno)
EndIf

If lRetorno .Or. lMostraTudo
	// Validar Processos Obrigat๓rios...
	lRetorno := fValProc(lRetorno)
EndIf

// Verificar se hแ outras filiais pendentes de virada hแ mais de 2 meses... Caso seja virada para concluir atual...
If dProxFec == dAtual
	cQuery := "SELECT * FROM ( " + CRLF
	cQuery += "SELECT EMPRESA, FILIAL, " + CRLF
	cQuery += "CASE WHEN ULTIMOFECHAMENTO = '' THEN ULTIMOFECHAMENTO ELSE CONVERT(VARCHAR(10), CONVERT(DATETIME, ULTIMOFECHAMENTO), 103) END AS ULTIMOFECHAMENTO, " + CRLF
	cQuery += "CASE WHEN EMPRESA = '01' AND ULTIMOFECHAMENTO <> '' THEN (SELECT SUM(B9_VINI1) FROM SB9010 WHERE B9_FILIAL = FILIAL AND B9_DATA = ULTIMOFECHAMENTO AND D_E_L_E_T_ = ' ') ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '02' AND ULTIMOFECHAMENTO <> '' THEN (SELECT SUM(B9_VINI1) FROM SB9020 WHERE B9_FILIAL = FILIAL AND B9_DATA = ULTIMOFECHAMENTO AND D_E_L_E_T_ = ' ') ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '03' AND ULTIMOFECHAMENTO <> '' THEN (SELECT SUM(B9_VINI1) FROM SB9030 WHERE B9_FILIAL = FILIAL AND B9_DATA = ULTIMOFECHAMENTO AND D_E_L_E_T_ = ' ') ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '06' AND ULTIMOFECHAMENTO <> '' THEN (SELECT SUM(B9_VINI1) FROM SB9060 WHERE B9_FILIAL = FILIAL AND B9_DATA = ULTIMOFECHAMENTO AND D_E_L_E_T_ = ' ') ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '08' AND ULTIMOFECHAMENTO <> '' THEN (SELECT SUM(B9_VINI1) FROM SB9080 WHERE B9_FILIAL = FILIAL AND B9_DATA = ULTIMOFECHAMENTO AND D_E_L_E_T_ = ' ') ELSE 0 END END END END END AS VALOR, " + CRLF
	cQuery += "CASE WHEN EMPRESA = '01' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 'Concluํdo' ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '02' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 'Concluํdo' ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '03' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 'Concluํdo' ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '06' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 'Concluํdo' ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '08' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 'Concluํdo' ELSE " + CRLF
	cQuery += "CASE WHEN ULTIMOFECHAMENTO = '' THEN 'Nunca houve fechamento' ELSE 'Pendente hแ ' + RTRIM(LTRIM(CONVERT( VARCHAR(8), DATEDIFF( MM, CONVERT(DATETIME, ULTIMOFECHAMENTO), DATEADD( MM, -1, GETDATE()))))) + ' mes(es)' END END END END END END AS STATUSFECHAMENTO, " + CRLF
	cQuery += "CASE WHEN EMPRESA = '01' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 0 ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '02' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 0 ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '03' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 0 ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '06' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 0 ELSE " + CRLF
	cQuery += "CASE WHEN EMPRESA = '08' AND LEFT( ULTIMOFECHAMENTO, 6) = LEFT( CONVERT(VARCHAR(8),DATEADD( MM, -1, GETDATE()), 112), 6) THEN 0 ELSE " + CRLF
	cQuery += "CASE WHEN ULTIMOFECHAMENTO = '' THEN 999 ELSE DATEDIFF( MM, CONVERT(DATETIME, ULTIMOFECHAMENTO), DATEADD( MM, -1, GETDATE())) END END END END END END AS MESESPENDENTES " + CRLF
	cQuery += "FROM ( " + CRLF
	cQuery += "SELECT '01' AS EMPRESA, B9_FILIAL AS FILIAL, MAX(B9_DATA) AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "FROM SB9010 AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL IN ('04','07','08','11','12') " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B9_FILIAL " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '01' AS EMPRESA, '04' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9010 WHERE B9_FILIAL = '04' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '01' AS EMPRESA, '07' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9010 WHERE B9_FILIAL = '07' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '01' AS EMPRESA, '08' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9010 WHERE B9_FILIAL = '08' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '01' AS EMPRESA, '11' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9010 WHERE B9_FILIAL = '11' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '01' AS EMPRESA, '12' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9010 WHERE B9_FILIAL = '12' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT '02' AS EMPRESA, B9_FILIAL AS FILIAL, MAX(B9_DATA) AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "FROM SB9020 AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL IN ('00','05','06') " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B9_FILIAL " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '02' AS EMPRESA, '00' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9020 WHERE B9_FILIAL = '00' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '02' AS EMPRESA, '05' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9020 WHERE B9_FILIAL = '05' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '02' AS EMPRESA, '06' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9020 WHERE B9_FILIAL = '06' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT '03' AS EMPRESA, B9_FILIAL AS FILIAL, MAX(B9_DATA) AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "FROM SB9030 AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL IN ('00','04') " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B9_FILIAL " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '03' AS EMPRESA, '00' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9030 WHERE B9_FILIAL = '00' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '03' AS EMPRESA, '04' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9030 WHERE B9_FILIAL = '04' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '06' AS EMPRESA, B9_FILIAL AS FILIAL, MAX(B9_DATA) AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "FROM SB9060 AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL IN ('01','02') " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B9_FILIAL " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '06' AS EMPRESA, '01' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9060 WHERE B9_FILIAL = '01' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '06' AS EMPRESA, '02' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9060 WHERE B9_FILIAL = '02' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT '08' AS EMPRESA, B9_FILIAL AS FILIAL, MAX(B9_DATA) AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "FROM SB9080 AS SB9 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B9_FILIAL IN ('01','03') " + CRLF
	cQuery += "AND SB9.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B9_FILIAL " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '08' AS EMPRESA, '01' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9080 WHERE B9_FILIAL = '01' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT '08' AS EMPRESA, '03' AS FILIAL, '' AS ULTIMOFECHAMENTO " + CRLF
	cQuery += "WHERE NOT EXISTS (SELECT * FROM SB9080 WHERE B9_FILIAL = '03' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF
	cQuery += ") AS AGRUP1 " + CRLF
	cQuery += "WHERE MESESPENDENTES > 1 " + CRLF
	cQuery += "ORDER BY EMPRESA, FILIAL " + CRLF

	//TCQuery cQuery New Alias "TMPATU"
	//dbSelectArea("TMPATU")
	//dbGoTop()

	//If !TMPATU->( Eof() )
	//	cMensagem += 'Ainda hแ empresas/filiais pendentes de fechamento de saldos hแ mais de 2 meses. Efetue o fechamento das empresas/filiais abaixo antes de seguir com esta virada de saldo: ' + CRLF
	//	lRetorno  := .F.
	//EndIf

	//Do While !TMPATU->( Eof() )
	//	cMensagem += 'Empresa: ' + TMPATU->EMPRESA + ' Filial: '  + TMPATU->FILIAL + CRLF

	//	TMPATU->( dbSkip() )
	//EndDo

	//TMPATU->( dbCloseArea() )
EndIf

If !lRetorno
	ApMsgAlert( AllTrim( cMensagem ), 'Virada nใo Permitida!')
ElseIf lMostraTudo
	ApMsgInfo( "Parab้ns! Rotina de Virada para o Perํodo liberado para processamento!", 'Virada Autorizada')
EndIf

Return lRetorno

Static Function fDivCrit( _lRet )

Local lRet     := _lRet
Local lDivCrit := GetMv("MV_BE_FECR",, .F.)

If lDivCrit
	cQuery := "SELECT SUM(CONTAS) AS CONTAS FROM ( " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	//cQuery += "AND (B2_CMFIM1 < -0.009 OR B2_VFIM1 < -0.009) " + CRLF
	cQuery += "AND B2_VFIM1 < 0.00 " + CRLF
	cQuery += "AND ABS(B2_VFIM1) > 0.009 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QFIM < 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QFIM <> 0 " + CRLF
	cQuery += "AND ABS(B2_QFIM) > 0.009 " + CRLF
	cQuery += "AND B2_VFIM1 = 0 " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND B1_TIPO IN ('AI','AF','SV') " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND (ABS(B2_VFIM1) > 0.009 OR ABS(B2_QFIM) > 0.009) " + CRLF
	//cQuery += "AND (B2_VFIM1 <> 0.00 OR B2_QFIM <> 0.00) " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) ON B8_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND B8_PRODUTO = B2_COD " + CRLF
	cQuery += "  AND B8_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_QFIM, B2_CMFIM1, B2_VFIM1 " + CRLF
	cQuery += "HAVING ABS(CONVERT(DECIMAL(20,4),SUM(B8_SALDO) - B2_QATU)) > 0.009 " + CRLF
    /*
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) ON BF_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND BF_PRODUTO = B2_COD " + CRLF
	cQuery += "  AND BF_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND SBF.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND B1_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND B1_RASTRO = 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_QFIM, B2_CMFIM1, B2_VFIM1, B2_QACLASS " + CRLF
	cQuery += "HAVING ABS(CONVERT(DECIMAL(12,4),SUM(BF_QUANT) - (B2_QATU - B2_QACLASS))) > 0.00 " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) ON B8_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND B8_PRODUTO = B2_COD " + CRLF
	cQuery += "  AND B8_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) ON BF_FILIAL = B8_FILIAL " + CRLF
	cQuery += "  AND BF_PRODUTO = B8_PRODUTO " + CRLF
	cQuery += "  AND BF_LOCAL = B8_LOCAL " + CRLF
	cQuery += "  AND BF_LOTECTL = B8_LOTECTL " + CRLF
	cQuery += "  AND SBF.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND B1_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "GROUP BY B2_FILIAL, B2_COD, B2_LOCAL, B2_QATU, B2_QFIM, B2_CMFIM1, B2_VFIM1, B8_LOTECTL " + CRLF
	cQuery += "HAVING ABS(CONVERT(DECIMAL(12,4),SUM(BF_QUANT) - SUM(B8_SALDO - B8_QACLASS))) > 0.00 " + CRLF
	*/
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SDA") + " AS SDA WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = DA_PRODUTO " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND B1_MSBLQL <> '1' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "LEFT JOIN " + RetSqlName("SBZ") + " AS SBZ WITH (NOLOCK) ON BZ_FILIAL = DA_FILIAL " + CRLF
	cQuery += "  AND BZ_COD = DA_PRODUTO " + CRLF
	cQuery += "  AND BZ_LOCALIZ <> 'N' " + CRLF
	cQuery += "  AND SBZ.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE DA_FILIAL = '" + xFilial("SDA") + "' " + CRLF
	cQuery += "AND DA_DATA BETWEEN '" + DTOS( dUltFec ) + "' AND '" + DTOS( dProxFec ) + "' " + CRLF
	cQuery += "AND DA_SALDO > 0.009 " + CRLF
	cQuery += "AND SDA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD1") + " AS SD1 WITH (NOLOCK) ON D1_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND D1_COD = B2_COD " + CRLF
	cQuery += "  AND D1_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND LEFT(D1_DTDIGIT, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "  AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D1_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND D1_SEQCALC = '' " + CRLF
	cQuery += "  AND SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD2") + " AS SD2 WITH (NOLOCK) ON D2_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND D2_COD = B2_COD " + CRLF
	cQuery += "  AND D2_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND LEFT(D2_EMISSAO, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "  AND EXISTS (SELECT * FROM " + RetSqlName("SF4") + " WITH (NOLOCK) WHERE F4_FILIAL = '" + xFilial("SF4") + "' AND F4_CODIGO = D2_TES AND F4_ESTOQUE = 'S' AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "  AND D2_SEQCALC = '' " + CRLF
	cQuery += "  AND SD2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) ON D3_FILIAL = B2_FILIAL " + CRLF
	cQuery += "  AND D3_COD = B2_COD " + CRLF
	cQuery += "  AND D3_LOCAL = B2_LOCAL " + CRLF
	cQuery += "  AND LEFT(D3_EMISSAO, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "  AND D3_SEQCALC = '' " + CRLF
	cQuery += "  AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT COUNT(*) AS CONTAS " + CRLF
	cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
	cQuery += "AND LEFT(D3_EMISSAO, 6) = '" + Left(DTOS(dProxFec), 6) + "' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("CV3") + " WHERE CV3_FILIAL = D3_FILIAL AND LEFT(CV3_DTSEQ, 6) = '" + Left(DTOS(dProxFec), 6) + "' AND CV3_TABORI = 'SD3' AND CV3_RECORI = SD3.R_E_C_N_O_ AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND D3_CUSTO1 > 0.009 " + CRLF
	cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += ") AS AGRUPADO " + CRLF

	TCQuery cQuery New Alias "TMPVAL"
	dbSelectArea("TMPVAL")
	dbGoTop()

	If !TMPVAL->( Eof() ) .And. TMPVAL->CONTAS > 0
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Hแ erros crํticos no estoque, favor corrigi-los antes de efetuar o fechamento de estoque!'
		lRet := .F.
	EndIf

	TMPVAL->( dbCloseArea() )
EndIf

Return lRet

Static Function fPerBloq( _lRet )

Local lRet      := _lRet
Local lPerBloq  := GetMv("MV_BE_FEPB",, .T.)
Local lFisBloq  := GetMv("MV_BE_FEFI",, .T.)
Local lCtbAtivo := GetMv("MV_BE_FEAT",, .F.)
Local lCtbFolha := GetMv("MV_BE_FEFP",, .F.)

If lPerBloq
	If dProxFec > GetMv("MV_DBLQMOV")
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Data para o fechamento ' + DTOC(dProxFec) + ' nใo bloqueado para movimenta็๕es!'
		lRet := .F.
	EndIf
EndIf

If lFisBloq
	If dProxFec > GetMv("MV_DATAFIS")
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Data para o fechamento ' + DTOC(dProxFec) + ' nใo bloqueado no fiscal!'
		lRet := .F.
	EndIf
EndIf

If lCtbAtivo
	If dProxFec > GetMv("MV_ULTDEPR")
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Data de deprecia็ใo menor que pr๓ximo fechamento ' + DTOC(dProxFec) + ', efetuar cแlculo de deprecia็ใo!'
		lRet := .F.
	EndIf
EndIf

If lCtbFolha
	If dProxFec > GetMv("MV_FOLMES")
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Data de fechamento da folha menor que pr๓ximo fechamento ' + DTOC(dProxFec) + '!'
		lRet := .F.
	EndIf
EndIf

Return lRet

Static Function fValProc( _lRet )

Local lRet      := _lRet
Local lRateio   := GetMv("MV_BE_FERA",, .F.)
Local lProcFec  := GetMv("MV_BE_FEPR",, .T.)
Local lProcRef  := GetMv("MV_BE_FERR",, .T.)
Local lPodTerc  := GetMv("MV_BE_FEPT",, .F.) // Se exige refaz acumulado mas nใo exige poder de terceiros, deixar falso...
Local lCtbComp  := GetMv("MV_BE_FECC",, .F.)
Local lCtbFatur := GetMv("MV_BE_FECF",, .F.)
Local lCtbFolha := GetMv("MV_BE_FEFP",, .F.)
Local lCtbAtivo := GetMv("MV_BE_FEAT",, .F.)
Local cLimTempo := GetMv("MV_BE_FELT",, "0000 02:00:00")
Local cVirada   := ""
Local dLanc     := CTOD("  /  /    ")

If lProcFec
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA280' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPVIR"
	dbSelectArea("TMPVIR")
	dbGoTop()
	
	If !TMPVIR->( Eof() )
		cVirada := TMPVIR->CV8_DATA + TMPVIR->CV8_HORA
	EndIf
	
	TMPVIR->( dbCloseArea() )

	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA300' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPSAL"
	dbSelectArea("TMPSAL")
	dbGoTop()
	
	If !TMPSAL->( Eof() )
		dLanc := STOD( TMPSAL->CV8_DATA )
		cTempo := DWElapTime( dLanc, TMPSAL->CV8_HORA + ":00", MsDate(), Time() )
		If cTempo > cLimTempo
			cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Processo cแlculo de Saldo Atual executado al้m do limite mแximo (' + cTempo + '), deve ser reprocessado!'
			lRet := .F.
		EndIf
	Else
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Cแlculo de Saldo Atual nใo executado no perํodo!'
		lRet := .F.
	EndIf
	
	TMPSAL->( dbCloseArea() )

	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA190' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPENT"
	dbSelectArea("TMPENT")
	dbGoTop()
	
	If !TMPENT->( Eof() )
		dLanc := STOD( TMPENT->CV8_DATA )
		cTempo := DWElapTime( dLanc, TMPENT->CV8_HORA + ":00", MsDate(), Time() )
		If cTempo > cLimTempo
			cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Processo cแlculo de Custo de Entrada executado al้m do limite mแximo (' + cTempo + '), deve ser reprocessado!'
			lRet := .F.
		EndIf
	Else
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Cแlculo de Custo de Entrada nใo executado no perํodo!'
		lRet := .F.
	EndIf
	
	TMPENT->( dbCloseArea() )

	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA330' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPCUS"
	dbSelectArea("TMPCUS")
	dbGoTop()
	
	If !TMPCUS->( Eof() )
		dLanc := STOD( TMPCUS->CV8_DATA )
		cTempo := DWElapTime( dLanc, TMPCUS->CV8_HORA + ":00", MsDate(), Time() )
		If cTempo > cLimTempo
			cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Processo cแlculo de Custo M้dio executado al้m do limite mแximo (' + cTempo + '), deve ser reprocessado!'
			lRet := .F.
		EndIf
	Else
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Cแlculo de Custo M้dio nใo executado no perํodo!'
		lRet := .F.
	EndIf
	
	TMPCUS->( dbCloseArea() )
EndIf

If lRateio
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
	cQuery += "AND CV8_PROC = 'CTBA280' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPRAT"
	dbSelectArea("TMPRAT")
	dbGoTop()
	
	If TMPRAT->( Eof() )
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Processo de Rateio Off-Line nใo executado no perํodo!'
		lRet := .F.
	EndIf
	
	TMPRAT->( dbCloseArea() )
EndIf

If lProcRef
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	//cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "WHERE CV8_FILIAL <> '**' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
	cQuery += "AND CV8_PROC = 'MATA215' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPREF"
	dbSelectArea("TMPREF")
	dbGoTop()
	
	If TMPREF->( Eof() )
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Processo Refaz Acumulados nใo executado no perํodo!'
		lRet := .F.
	EndIf
	
	TMPREF->( dbCloseArea() )

	If lPodTerc
		cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
		cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
		cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
		cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
		cQuery += "AND CV8_PROC = 'MATA216' " + CRLF
		cQuery += "AND CV8_INFO = '1' " + CRLF
		cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
		cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
		TCQuery cQuery New Alias "TMPPOD"
		dbSelectArea("TMPPOD")
		dbGoTop()
		
		If TMPPOD->( Eof() )
			cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Processo Refaz Poder de Terceiros nใo executado no perํodo!'
			lRet := .F.
		EndIf
		
		TMPPOD->( dbCloseArea() )
	EndIf
EndIf

If lCtbComp
	cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF1") + " AS SF1 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE F1_FILIAL = '" + xFilial("SF1") + "' " + CRLF
	cQuery += "AND LEFT( F1_DTDIGIT, 6) = '" + Left( DTOS( dProxFec ), 6) + "' " + CRLF
	cQuery += "AND F1_DTLANC = '' " + CRLF
	cQuery += "AND SF1.D_E_L_E_T_ = ' ' " + CRLF
	
	TCQuery cQuery New Alias "TMPCOM"
	dbSelectArea("TMPCOM")
	dbGoTop()
	
	If TMPCOM->( Eof() )
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Hแ lan็amentos de Notas Fiscais de Entradas no Perํodo sem contabiliza็ใo!'
		lRet := .F.
	EndIf
	
	TMPCOM->( dbCloseArea() )
EndIf

If lCtbFatur
	cQuery := "SELECT COUNT(*) AS CONTA " + CRLF
	cQuery += "FROM " + RetSqlName("SF2") + " AS SF2 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE F2_FILIAL = '" + xFilial("SF2") + "' " + CRLF
	cQuery += "AND LEFT( F2_EMISSAO, 6) = '" + Left( DTOS( dProxFec ), 6) + "' " + CRLF
	cQuery += "AND F2_DTLANC = '' " + CRLF
	cQuery += "AND SF2.D_E_L_E_T_ = ' ' " + CRLF
	
	TCQuery cQuery New Alias "TMPFAT"
	dbSelectArea("TMPFAT")
	dbGoTop()
	
	If TMPFAT->( Eof() )
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Hแ lan็amentos de Notas Fiscais de Saํdas no Perํodo sem contabiliza็ใo!'
		lRet := .F.
	EndIf
	
	TMPFAT->( dbCloseArea() )
EndIf

If lCtbAtivo
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
	cQuery += "AND CV8_PROC IN ('ATFA370','CTBAATF') " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPATF"
	dbSelectArea("TMPATF")
	dbGoTop()
	
	If TMPATF->( Eof() )
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Contabiliza็ใo do Ativo Imobilizado nใo executado no perํodo!'
		lRet := .F.
	EndIf
	
	TMPATF->( dbCloseArea() )
EndIf

If lCtbFolha
	cQuery := "SELECT TOP 1 RTRIM(LTRIM(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), CV8_DET)))) AS CV8_PARAM, CV8_DATA, CV8_HORA, CV8_USER " + CRLF
	cQuery += "FROM " + RetSqlName("CV8") + " AS CV8 WITH (NOLOCK) " + CRLF
	cQuery += "WHERE CV8_FILIAL = '" + xFilial("CV8") + "' " + CRLF
	cQuery += "AND CV8_DATA + CV8_HORA >= '" + cVirada + "' " + CRLF
	cQuery += "AND CV8_PROC = 'GPEM110' " + CRLF
	cQuery += "AND CV8_INFO = '1' " + CRLF
	cQuery += "AND CV8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
	TCQuery cQuery New Alias "TMPFOL"
	dbSelectArea("TMPFOL")
	dbGoTop()
	
	If TMPFOL->( Eof() )
		cMensagem += IIf( Empty(cMensagem), '', CRLF) + 'Contabiliza็ใo da Folha de Pagamentos nใo executado no perํodo!'
		lRet := .F.
	EndIf
	
	TMPFOL->( dbCloseArea() )
EndIf

Return lRet
