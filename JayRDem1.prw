#include 'protheus.ch'
#include 'rwmake.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

#Define 	CODPROD		1
#Define 	DESCPROD	2
#Define 	TIPOPROD	3
#Define 	UMPROD		4
#Define		QTDATU		5
#Define		VLRATU		6
#Define		QTDVEND		7

/*/
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � � Autor � 		� Data � 15.08.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ���
��� 		 � ���
��� 		 � 								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
User Function JayRDem1()

Local oReport

Private cPerg	:= "JARDEM"

ValidPerg()

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportDef� Autor �         � Data � 15.08.12 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do layout do Relatorio							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport  
Local oSection1
Local cPictVal
Local nTamCli,nTamTit,nTamCtr,nTamDte,nTamVal,nTamPro

oReport := TReport():New("JayRDem1","Relatorio de Demanda Por Periodo","JARDEM",{|oReport| ReportPrint(oReport)},"Imprime Rela��o de demanda por periodo.")

oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas
oReport:ShowParamPage(.T.)

Pergunte("JARDEM",.F.)

//�����������������������������������������������������������Ŀ
//� Inicia Se��o                							  �
//�������������������������������������������������������������
oSection1 := TRSection():New(oReport,"Relatorio de Demanda Por Periodo",{"SB1"},{"Por Periodo"})

//�����������������������������������������������������������Ŀ
//� Define c�lulas                							  �
//�������������������������������������������������������������
TRCell():New(oSection1,"B1_COD"		,		,"Produto"					,							,30			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_DESC"	,		,"Descri��o"				,							,45			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_TIPO"	,		,"Tipo"						,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"B1_UM"		,		,"U.M."						,							,10			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"QTD_ATUAL"	,		,"Quantidade Atual"			, PesqPict("SB2","B2_QATU")	,20			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"VALOR_ATUAL",		,"Valor Atual"				, PesqPict("SB2","B2_VATU1"),20			,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"QTD_VENDIDA",		,"Quantidade Vendida"		, PesqPict("SB2","B2_QATU")	,20			,.F.	,,,,,,,.F.)  

oSection1:SetColSpace(0)

Return oReport

/*
�����������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor �Rodrigo Sousa          � Data �15.08.12  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os  ���
���          �relatorios que poderao ser agendados pelo usuario.           ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
��������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                            ���
��������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                          ���
��������������������������������������������������������������������������Ĵ��
���          �               �                                             ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)

Local oBreak
Local oSection1  	:= oReport:Section(1)

Local nOrdem 		:= oSection1:GetOrder()
Local nBolRec		:= 0
Local nBolNRec		:= 0
Local nTotsRec 		:= 0

Local cFilterUser	
Local cRepTit		:= oReport:Title()

Local aDados[7]

Private cAlias		:= GetNextAlias()

//�����������������������������������������������������������Ŀ
//� Define bloco de c�digo na impress�o das c�lulas		  	  �
//�������������������������������������������������������������
oSection1:Cell("B1_COD"   	):SetBlock( { || aDados[CODPROD]   	})
oSection1:Cell("B1_DESC"   	):SetBlock( { || aDados[DESCPROD]  	})
oSection1:Cell("B1_TIPO"   	):SetBlock( { || aDados[TIPOPROD]  	})
oSection1:Cell("B1_UM"   	):SetBlock( { || aDados[UMPROD]  	})
oSection1:Cell("QTD_ATUAL" 	):SetBlock( { || aDados[QTDATU]  	})
oSection1:Cell("VALOR_ATUAL"):SetBlock( { || aDados[VLRATU]  	})
oSection1:Cell("QTD_VENDIDA"):SetBlock( { || aDados[QTDVEND] 	})

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := "Rela��o de Demanda Por Periodo"

cFilterUser := oSection1:GetSqlExp("SB1")

//---- Relatorio de Demanda                                    
cQuery := "SELECT CODIGO, DESCRI, TIPO, UM, SUM(QTD_ATUAL) QTD_ATUAL, SUM(VALOR_ATUAL) AS VALOR_ATUAL, SUM(QTD_VENDIDA)	AS QTD_VENDIDA  "+CRLF
cQuery += "FROM  "+CRLF
cQuery += "	(SELECT B1_COD AS CODIGO , B1_DESC AS DESCRI, B1_TIPO AS TIPO, B1_UM AS UM, B2_LOCAL, B2_QATU AS QTD_ATUAL,  "+CRLF
cQuery += "			B2_VATU1 AS VALOR_ATUAL, ISNULL(SUM(D2_QUANT-D2_QTDEDEV),0) as QTD_VENDIDA "+CRLF
cQuery += "		FROM "+RetSqlName("SB1")+" AS SB1  "+CRLF
cQuery += "		INNER JOIN "+RetSqlName("SB2")+" SB2  "+CRLF
cQuery += "			ON B1_COD = B2_COD  "+CRLF
cQuery += "			AND B2_FILIAL = '"+xFilial("SB2")+"'  "+CRLF
cQuery += "			AND SB2.D_E_L_E_T_ = ''  "+CRLF
cQuery += "		LEFT JOIN "+RetSqlName("SD2")+" AS SD2  "+CRLF
cQuery += "			ON D2_FILIAL = '"+xFilial("SD2")+"'  "+CRLF
cQuery += "			AND D2_COD = B1_COD "+CRLF
cQuery += "			AND D2_LOCAL = B2_LOCAL  "+CRLF
cQuery += "			AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "+CRLF
cQuery += "			AND SD2.D_E_L_E_T_ = ''  "+CRLF
cQuery += "		WHERE SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += "		AND B2_FILIAL = '"+xFilial("SB2")+"'  "+CRLF
cQuery += "		AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQuery += "		AND B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery += "		AND B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CRLF
cQuery += "		GROUP BY B1_COD, B1_DESC, B1_TIPO, B1_UM, B2_LOCAL, B2_QATU, B2_VATU1 "+CRLF
cQuery += "		HAVING (SUM(D2_QUANT) > 0 OR SUM(B2_QATU) > 0) "+CRLF
cQuery += "		) AS AGRUPADO "+CRLF
cQuery += "GROUP BY CODIGO, DESCRI, TIPO, UM "+CRLF
cQuery += "ORDER BY QTD_VENDIDA "+CRLF

/*
cQuery := "SELECT B1_COD, B1_DESC, B1_TIPO, B1_UM, SUM(B2_QATU) QTD_ATUAL, SUM(B2_VATU1) VALOR_ATUAL, "+CRLF
cQuery += "ISNULL(SUM(D2_QUANT-D2_QTDEDEV),0) AS QTD_VENDIDA "+CRLF
cQuery += "FROM "+RetSqlName("SB1")+" SB1 "+CRLF
cQuery += "INNER JOIN "+RetSqlName("SB2")+" SB2 "+CRLF
cQuery += "	ON B1_COD = B2_COD "+CRLF 
cQuery += "	AND B2_FILIAL = '"+xFilial("SB2")+"' "+CRLF 
cQuery += "	AND SB2.D_E_L_E_T_ = '' "+CRLF
cQuery += "LEFT JOIN "+RetSqlName("SD2")+" AS SD2 "+CRLF 
cQuery += "	ON D2_FILIAL = '"+xFilial("SD2")+"' "+CRLF 
cQuery += "	AND D2_COD = B1_COD "+CRLF
cQuery += "	AND D2_LOCAL = B2_LOCAL "+CRLF
cQuery += "	AND D2_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "+CRLF
cQuery += "	AND SD2.D_E_L_E_T_ = '' "+CRLF
cQuery += "WHERE SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += "AND B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
cQuery += "AND B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cQuery += "AND B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CRLF
//�����������������������������������������������������������������������Ŀ
//� Aplica filtro personalizado se existir								  �
//�������������������������������������������������������������������������
If !empty(cFilterUser)
  	cQuery += " AND ("+ cFilterUser +") "
EndIf
cQuery += "GROUP BY B1_COD, B1_DESC, B1_TIPO, B1_UM, B2_QATU, B2_VATU1 "+CRLF
cQuery += "HAVING (SUM(D2_QUANT) > 0 OR SUM(B2_QATU) > 0)  "+CRLF
cQuery += "ORDER BY QTD_VENDIDA "+CRLF
*/
ConOut(cQuery)                                          

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

TCQuery cQuery New Alias (cAlias)

nTotsRec := (cAlias)->(RecCount())
oReport:SetMeter(nTotsRec)

While !(cAlias)->(Eof()) 

	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	aDados[CODPROD]		:= (cAlias)->CODIGO
	aDados[DESCPROD]	:= Substr((cAlias)->DESCRI,1,40)
	aDados[TIPOPROD]	:= (cAlias)->TIPO
	aDados[UMPROD]		:= (cAlias)->UM
	aDados[QTDATU]		:= (cAlias)->QTD_ATUAL
	aDados[VLRATU]		:= (cAlias)->VALOR_ATUAL
	aDados[QTDVEND]		:= (cAlias)->QTD_VENDIDA

	//�����������������������������������������������������������Ŀ
	//� Imprime Linha 	 		 								  �
	//�������������������������������������������������������������
	oSection1:PrintLine()
	aFill(aDados,nil)
    
	(cAlias)->(dbSkip())

EndDo

oSection1:Finish()

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

Return
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidPerg � Autor � Rodrigo Sousa  		� Data � 15.08.12  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := cPerg + Space(4)

Aadd(aPerg, {cPerg, "01", "Do Produto   	?", "MV_CH1" , 	"C", 06	, 0	, "G"	, "MV_PAR01", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "At� o Produto	?", "MV_CH2" , 	"C", 06	, 0	, "G"	, "MV_PAR02", "SB1"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "03", "Do Grupo	        ?", "MV_CH3" , 	"C", 04	, 0	, "G"	, "MV_PAR03", "SBM"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "04", "At� o Grupo	    ?", "MV_CH4" , 	"C", 04	, 0	, "G"	, "MV_PAR04", "SBM"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "05", "Do Tipo	        ?", "MV_CH5" , 	"C", 04	, 0	, "G"	, "MV_PAR05", "02"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "06", "At� o Tipo       ?", "MV_CH6" , 	"C", 04	, 0	, "G"	, "MV_PAR06", "02"	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "07", "Do Periodo	    ?", "MV_CH7" , 	"D", 08	, 0	, "G"	, "MV_PAR07", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "08", "At� o Periodo    ?", "MV_CH8" , 	"D", 08	, 0	, "G"	, "MV_PAR08", ""	,""		,""				,""				,"",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)
