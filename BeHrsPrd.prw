#include "protheus.ch"   
#include "topconn.ch"

User Function BeHrsPrd()

Local oReport

Private cPerg	:= "BEHORAS001"

ValidPerg()

oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport  
Local oSection1
Local cPictVal

oReport := TReport():New("BeHrsPrd","Rela��o de Horas Apontadas","BEHORAS001",{|oReport| ReportPrint(oReport)},"Imprime rela��o de horas apontadas por Centro de Custos no per�odo.")

oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.) // Imprime o total em linhas

Pergunte("BEHORAS001",.F.)

//�����������������������������������������������������������Ŀ
//� Inicia Se��o                							  �
//�������������������������������������������������������������
oSection1 := TRSection():New(oReport,"Rela��o de Horas Apontadas",{""},{"Por Centro de Custos"})
oSection1:SetHeaderPage()

//�����������������������������������������������������������Ŀ
//� Define c�lulas                							  �
//�������������������������������������������������������������
TRCell():New(oSection1,"H1_CCUSTO"	,,"Centro Custos"	,,30	,.F.	,,,,,,,.F.)
TRCell():New(oSection1,"CTT_DESC01"	,,"Descri��o"		,,60	,.F.	,,,,,,,.F.)
TRCell():New(oSection1,"HORAS"		,,"Horas"			,,20	,.F.	,,,,,,,.F.)

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
Local cTipo			:= ""

Local cFilterUser	
Local cRepTit		:= oReport:Title()

Local aDados[12]

Private cAlias		:= GetNextAlias()

//�����������������������������������������������������������Ŀ
//� Define bloco de c�digo na impress�o das c�lulas		  	  �
//�������������������������������������������������������������
oSection1:Cell("H1_CCUSTO" 	):SetBlock( { || aDados[01]   	})
oSection1:Cell("CTT_DESC01"	):SetBlock( { || aDados[02]   	})
oSection1:Cell("HORAS"  	):SetBlock( { || aDados[03]   	})

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := ""

cQuery := "SELECT H1_CCUSTO, CTT_DESC01, SUM(D3_QUANT) AS HORAS " + CRLF
cQuery += "FROM " + RetSqlName("SD3") + " AS SD3 WITH (NOLOCK) " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SH6") + " AS SH6 WITH (NOLOCK) ON H6_FILIAL = D3_FILIAL " + CRLF
cQuery += "  AND H6_TIPO <> 'I' " + CRLF
cQuery += "  AND H6_IDENT = D3_IDENT " + CRLF
cQuery += "  AND SH6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SH1") + " AS SH1 WITH (NOLOCK) ON (H1_FILIAL = H6_FILIAL OR H1_FILIAL = '') " + CRLF
cQuery += "  AND H1_CODIGO = H6_RECURSO " + CRLF
cQuery += "  AND SH1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("CTT") + " AS CTT WITH (NOLOCK) ON CTT_FILIAL = '  ' " + CRLF
cQuery += "  AND CTT_CUSTO = H1_CCUSTO " + CRLF
cQuery += "  AND CTT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "' " + CRLF
cQuery += "AND D3_EMISSAO BETWEEN '" + DTOS( mv_par01 ) + "' AND '" + DTOS( mv_par02 ) + "' " + CRLF
cQuery += "AND D3_EMPOP <> '' " + CRLF
cQuery += "AND D3_ESTORNO = '' " + CRLF
cQuery += "AND D3_TIPO = 'MO' " + CRLF
cQuery += "AND SUBSTRING( D3_COD, 1, 2) = 'MO' " + CRLF
cQuery += "AND SD3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "GROUP BY H1_CCUSTO, CTT_DESC01 " + CRLF
cQuery += "ORDER BY H1_CCUSTO, CTT_DESC01 " + CRLF

If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

TCQuery cQuery New Alias (cAlias)

While !(cAlias)->(Eof()) 

	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	aDados[01]	:= (cAlias)->H1_CCUSTO
	aDados[02]	:= (cAlias)->CTT_DESC01
	aDados[03]	:= (cAlias)->HORAS

	//�����������������������������������������������������������Ŀ
	//� Imprime Linha 	 		 								  �
	//�������������������������������������������������������������
	oSection1:PrintLine()
	aFill(aDados,nil)

	(cAlias)->(dbSkip())
EndDo

TRFunction():New(oSection1:Cell("HORAS"),,"SUM",,,,, .T., .T., .T. )

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

cPerg := Padr(cPerg, 10)

Aadd(aPerg, {cPerg, "01", "Da Dt. Apont.?" , "MV_CH1" , 	"D", 08	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "At� Dt. Apont.?", "MV_CH2" , 	"D", 08	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"",""})

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