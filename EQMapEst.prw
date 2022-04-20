#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'Totvs.Ch'

User Function EQMapEst()

Private cQuery     := ""
Private cPerg      := "EQMAPESTOQ"                /* mv_par01 (1=Anal�tico;2=Sint�tico) , mv_par02 (Ano) , mv_par03 (M�s) */
Private aSubQry    := {}
Private aResultado := {}
Private dDataIni   := CTOD("  /  /    ")
Private dDataFim   := CTOD("  /  /    ")
Private dSaldoIni  := CTOD("  /  /    ")
Private cNomeSP    := "SP_EQ_MAPA_ESTOQUE_" + Left(cFilAnt,2) + "_CUSTO"
Private lRet       := .T.

ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento cancelado!', 'Aten��o')
	Return
EndIf

If mv_par02 < 2018 .Or. mv_par02 > Year( MsDate() )
	ApMsgAlert( 'Ano inv�lido, informe um ano v�lido!', 'Aten��o')
	Return
EndIf

If mv_par03 < 1 .Or. mv_par03 > 12
	ApMsgAlert( 'M�s inv�lido, informe um m�s v�lido!', 'Aten��o')
	Return
EndIf

dDataIni  := STOD(StrZero(mv_par02, 4) + StrZero(mv_par03,2) + "01")
dSaldoIni := dDataIni - 1

If mv_par03 == 12
	dDataFim := STOD(StrZero(mv_par02 + 1, 4) + "01" + "01") - 1
Else
	dDataFim := STOD(StrZero(mv_par02, 4) + StrZero(mv_par03 + 1,2) + "01") - 1
EndIf

If !lRet
	ApMsgAlert( 'N�o foi poss�vel gerar dados, contate o suporte ERP!', 'Aten��o')
	Return
EndIf

cQuery := "Exec " + cNomeSP + " '" + DTOS(dDataIni) + "', '" + DTOS(dDataFim) + "', '" + DTOS(dSaldoIni) + "', '" + mv_par04 + "', '" + mv_par05 + "'"

TCQuery cQuery New Alias "TMPEST"
dbSelectArea("TMPEST")
TMPEST->( dbGoTop() )

If TMPEST->( Eof() )
	ApMsgAlert( 'N�o h� dados para gera��o do relat�rio, verifique os par�metros!', 'Aten��o')
	Return
EndIf

Processa( {|| fGeraPla()}, "Gerando Mapa de Estoque")

TMPEST->( dbCloseArea() )

Return

Static Function fGeraPla()

Local aCabec	:= {}
Local aColunas	:= {}
Local cMensagem	:= ""
Local cAssunto	:= ""
Local cMensagem := ""
Local cArquivo  := "c:\temp\Mapa_Estoque_" + StrZero(mv_par02, 4) + StrZero(mv_par03, 2) + "_" + Left(cFilAnt,2) + ".xls"
Local cAnexo1   := ""
Local nLin      := 0
Local nElemento := 0
Local aTotal    := {"","","","","",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
Local nTotal    := 0

MakeDir( "C:\TEMP\" )

If File( cArquivo )
	fErase( cArquivo )
EndIf

ProcRegua( TMPEST->( RecCount() ) )

cAssunto := 'Mapa de Estoque - Per�odo: ' + StrZero(mv_par03, 2) + "/" + StrZero(mv_par02, 4)

_nFile := MsFCreate( cArquivo )
	
cMensagem := ""
aCabec    := {}
aColunas  := {}
aAdd( aColunas, {'Filial'			   					, 05	, 'C'})
aAdd( aColunas, {'Produto'								, 15	, 'C'})
aAdd( aColunas, {'Descri��o'							, 30	, 'C'})
aAdd( aColunas, {'Tipo'									, 05	, 'C'})
aAdd( aColunas, {'Local'								, 05	, 'C'})

aAdd( aColunas, {'Saldo Inicial'						, 12	, 'C'})

aAdd( aColunas, {'Compras'								, 12	, 'C'})
aAdd( aColunas, {'Devolu��o de Compras'					, 12	, 'C'})
aAdd( aColunas, {'Vendas'								, 12	, 'C'})
aAdd( aColunas, {'Devolu��o de Vendas'					, 12	, 'C'})
aAdd( aColunas, {'Sa�da por Remessa'					, 12	, 'C'})
aAdd( aColunas, {'Entrada por Remessa'					, 12	, 'C'})

aAdd( aColunas, {'Entrada Transfer�ncia Filiais'		, 12	, 'C'})
aAdd( aColunas, {'Sa�da Transfer�ncia Filiais'			, 12	, 'C'})

aAdd( aColunas, {'Sa�da por Perda'						, 12	, 'C'})

aAdd( aColunas, {'Fechamento Produ��o'					, 12	, 'C'})
aAdd( aColunas, {'Requisi��o Produ��o'					, 12	, 'C'})
aAdd( aColunas, {'Estorno Fechamento Produ��o'			, 12	, 'C'})
aAdd( aColunas, {'Estorno Requisi��o Produ��o'			, 12	, 'C'})
aAdd( aColunas, {'Sa�da Perda Produ��o'					, 12	, 'C'})
aAdd( aColunas, {'Entrada Perda Produ��o'				, 12	, 'C'})
aAdd( aColunas, {'Entrada Movimenta��o Interna'			, 12	, 'C'})
aAdd( aColunas, {'Sa�da Movimenta��o Interna'			, 12	, 'C'})
aAdd( aColunas, {'Devolu��o Valoriza��o'				, 12	, 'C'})
aAdd( aColunas, {'Requisi��o Valoriza��o'				, 12	, 'C'})
aAdd( aColunas, {'Entrada Desmontagem'					, 12	, 'C'})
aAdd( aColunas, {'Sa�da Desmontagem'					, 12	, 'C'})
aAdd( aColunas, {'Entrada Invent�rio'					, 12	, 'C'})
aAdd( aColunas, {'Sa�da Invent�rio'						, 12	, 'C'})

aAdd( aColunas, {'Entrada Transfer�ncia Armaz�ns'		, 12	, 'C'})
aAdd( aColunas, {'Sa�da Transfer�ncia Armaz�ns'			, 12	, 'C'})

aAdd( aColunas, {'Saldo Final Calculado'				, 12	, 'C'})
aAdd( aColunas, {'Saldo Final Tabela'					, 12	, 'C'})
aAdd( aColunas, {'Check Diferen�as'						, 12	, 'C'})

cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

FlushFile(_nFile, @cMensagem, 0)

Do While !TMPEST->( Eof() )
	IncProc( 'Filial: ' + TMPEST->D1_FILIAL + ' Produto: ' + AllTrim( TMPEST->B1_COD ) + ' Local: ' + TMPEST->D1_LOCAL )

	nElemento := 5

	aColunas := {}
	aAdd( aColunas, {AllTrim( TMPEST->D1_FILIAL )				   									, 05	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_COD )					  		  							, 15	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_DESC )			 							  				, 30	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->B1_TIPO )		   					 		  					, 05	, 'L'})
	aAdd( aColunas, {AllTrim( TMPEST->D1_LOCAL )									  				, 05	, 'L'})

	aAdd( aColunas, {Transform( TMPEST->SAL_INICIAL, "@E 999,999,999.99" )						, 12	, 'R'})

	aAdd( aColunas, {Transform( TMPEST->COMPRAS, "@E 999,999,999.99" )								, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->DEV_COMPRAS, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->VENDAS, "@E 999,999,999.99" )								, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->DEV_VENDAS, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->SAI_REMESSA, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->DEV_REMESSA, "@E 999,999,999.99" )				, 12	, 'R'})

	aAdd( aColunas, {Transform( TMPEST->ENT_TRA_FIL, "@E 999,999,999.99" )				, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->SAI_TRA_FIL, "@E 999,999,999.99" )				, 12	, 'R'})

	aAdd( aColunas, {Transform( TMPEST->SAI_PERDA, "@E 999,999,999.99" )						, 12	, 'R'})

	aAdd( aColunas, {Transform( TMPEST->FEC_PRO, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->REQ_PRO, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->EST_FEC_PRO, "@E 999,999,999.99" )			, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->EST_REQ_PRO, "@E 999,999,999.99" )			, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->SAI_OP, "@E 999,999,999.99" )							, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->ENT_OP, "@E 999,999,999.99" )						, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->ENT_MOV_INT, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->SAI_MOV_INT, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->DEV_VAL, "@E 999,999,999.99" )				, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->REQ_VAL, "@E 999,999,999.99" )				, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->ENT_DES, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->SAI_DES, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->ENT_INV, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->SAI_INV, "@E 999,999,999.99" )						, 12	, 'R'})

	nMovEntSint := TMPEST->DEV_TRANSF //DEVTRA_HPC + TMPEST->DEVTRA_FI + TMPEST->DEVTRA_WT + TMPEST->DEVTRA_BIO + TMPEST->DEVTRA_OUTROS
	aAdd( aColunas, {Transform( nMovEntSint, "@E 999,999,999.99" )									, 12	, 'R'})

	nMovEntSint := TMPEST->REQ_TRANSF //REQTRA_HPC + TMPEST->REQTRA_FI + TMPEST->REQTRA_WT + TMPEST->REQTRA_BIO + TMPEST->REQTRA_OUTROS
	aAdd( aColunas, {Transform( nMovEntSint, "@E 999,999,999.99" )									, 12	, 'R'})

	aAdd( aColunas, {Transform( TMPEST->SALFIN_CAL, "@E 999,999,999.99" )				, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->SALFIN_TAB, "@E 999,999,999.99" )					, 12	, 'R'})
	aAdd( aColunas, {Transform( TMPEST->CHECK_DIF, "@E 999,999,999.99" )							, 12	, 'R'})

	cMensagem += U_BeHtmDet( aColunas, ((nLin % 2) == 0) , .F. )

	FlushFile(_nFile, @cMensagem, 0)

	aTotal[06] += TMPEST->SAL_INICIAL
	aTotal[07] += TMPEST->COMPRAS
	aTotal[08] += TMPEST->DEV_COMPRAS
	aTotal[09] += TMPEST->VENDAS
	aTotal[10] += TMPEST->DEV_VENDAS
	aTotal[11] += TMPEST->SAI_REMESSA
	aTotal[12] += TMPEST->DEV_REMESSA
	aTotal[13] += TMPEST->ENT_TRA_FIL
	aTotal[14] += TMPEST->SAI_TRA_FIL
	aTotal[15] += TMPEST->SAI_PERDA
	aTotal[16] += TMPEST->FEC_PRO
	aTotal[17] += TMPEST->REQ_PRO
	aTotal[18] += TMPEST->EST_FEC_PRO
	aTotal[19] += TMPEST->EST_REQ_PRO
	aTotal[20] += TMPEST->SAI_OP
	aTotal[21] += TMPEST->ENT_OP
	aTotal[22] += TMPEST->ENT_MOV_INT
	aTotal[23] += TMPEST->SAI_MOV_INT
	aTotal[24] += TMPEST->DEV_VAL
	aTotal[25] += TMPEST->REQ_VAL
	aTotal[26] += TMPEST->ENT_DES
	aTotal[27] += TMPEST->SAI_DES
	aTotal[28] += TMPEST->ENT_INV
	aTotal[29] += TMPEST->SAI_INV
	aTotal[30] += TMPEST->DEV_TRANSF //DEVTRA_HPC + TMPEST->DEVTRA_FI + TMPEST->DEVTRA_WT + TMPEST->DEVTRA_BIO + TMPEST->DEVTRA_OUTROS
	aTotal[31] += TMPEST->REQ_TRANSF //REQTRA_HPC + TMPEST->REQTRA_FI + TMPEST->REQTRA_WT + TMPEST->REQTRA_BIO + TMPEST->REQTRA_OUTROS
	aTotal[32] += TMPEST->SALFIN_CAL
	aTotal[33] += TMPEST->SALFIN_TAB
	aTotal[34] += TMPEST->CHECK_DIF

	nLin++

	TMPEST->( dbSkip() )
EndDo

aColunas := {}
For nTotal := 1 To Len( aTotal )
	If nTotal <= 5
		aAdd( aColunas, {AllTrim( aTotal[nTotal] )				   									, 05	, 'L'})
	Else
		aAdd( aColunas, {Transform( aTotal[nTotal], "@E 999,999,999.99" )	  						, 12	, 'R'})
	EndIf
Next

cMensagem += U_BeHtmDet( aColunas, ((nLin % 2) == 0) , .T. )

FlushFile(_nFile, @cMensagem, 0)

cMensagem += U_BeHtmRod(.T.)

FlushFile(_nFile, @cMensagem, 0)

FClose(_nFile)

ShellExecute( "open", AllTrim( cArquivo ), "", "C:\temp\", 1)

//cAnexo1 := cArquivo

//��������������������������������������������������������������Ŀ
//� Inicia envio de e-mail...                                    �
//����������������������������������������������������������������
//cMensagem := ""
//cMensagem += U_BeHtmRod(.T.)

//U_BeSendMail( { "fabio@xisinformatica.com.br", cAssunto, cMensagem, cAnexo1 } )

Return

Static Function FlushFile(_nFile, cMsg, nMaxSize)

Default nMaxSize := 50 * 1024 //50KB

FWrite(_nFile, cMsg)
cMsg := ""

Return Nil

Static Function ValidPerg()

Local _aArea := GetArea()
Local _aPerg := {}

Aadd(_aPerg, {cPerg, "01", "Tipo                  ?", "MV_CH1" , 	"N", 01	, 0	, "C"	, "MV_PAR01", "   "	,"Anal�tico","Sint�tico","","",""})
Aadd(_aPerg, {cPerg, "02", "Ano                   ?", "MV_CH2" , 	"N", 04	, 0	, "G"	, "MV_PAR02", "   "	,""         ,""         ,"","",""})
Aadd(_aPerg, {cPerg, "03", "M�s                   ?", "MV_CH3" , 	"N", 02	, 0	, "G"	, "MV_PAR03", "   "	,""         ,""         ,"","",""})
Aadd(_aPerg, {cPerg, "04", "Da Filial             ?", "MV_CH4" , 	"C", 02	, 0	, "G"	, "MV_PAR04", "   "	,""         ,""         ,"","",""})
Aadd(_aPerg, {cPerg, "05", "At� Filial            ?", "MV_CH5" , 	"C", 02	, 0	, "G"	, "MV_PAR05", "   "	,""         ,""         ,"","",""})

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