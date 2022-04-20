#include "protheus.ch"
#include "topconn.ch"

/*/
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � EQ� Autor � Rodrigo Sousa 		� Data � 10.11.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �   ���
��� 		 � 															  ���
��� 		 � 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
User Function EQRCARNC()

Local oReport

Private cPerg	:= "EQRCRN"

ValidPerg()

oReport := ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportDef� Autor � Rodrigo Sousa         � Data �  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao do layout do Relatorio							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico 	 	 		  	                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local oReport  
Local oSection1
Local cPictVal
Local nTamFil,nTamCod,nTamDesc,nTamQtde

oReport := TReport():New("EQRCRN","Rela��o Clientes Ativos x RNC",cPerg,{|oReport| ReportPrint(oReport)},"Imprime rela��o de clientes ativos x RNC de acordo com os par�metros.")

oReport:SetLandScap(.T.)
oReport:SetTotalInLine(.F.) 

Pergunte(cPerg,.F.)

//�����������������������������������������������������������Ŀ
//� Inicia Se��o                							  �
//�������������������������������������������������������������
oSection1 := TRSection():New(oReport,"Clientes Ativos x RNC",{"SA1"},{""})

//�����������������������������������������������������������Ŀ
//� Define c�lulas                							  �
//�������������������������������������������������������������
TRCell():New(oSection1,"A1_COD"		,	,"C�digo"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A1_LOJA"	,	,"Loja"				,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"A1_NREDUZ"	,	,"Cliente"			,	,	,.F.	,,,,,,,.F.)  
TRCell():New(oSection1,"QTD_RNC"	,	,"Quantidade RNC"	,	,	,.F.	,,,,,,,.F.)  

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
Local nSeek			:= 0

Local cFilterUser	
Local cRepTit		:= oReport:Title()
Local cDescrMot		:= ""
Local cNomFil		:= ""

Local aDados[4]

Private cAlias		:= GetNextAlias()

//�����������������������������������������������������������Ŀ
//� Define bloco de c�digo na impress�o das c�lulas		  	  �
//�������������������������������������������������������������
oSection1:Cell("A1_COD" 	):SetBlock( { || aDados[01]})
oSection1:Cell("A1_LOJA" 	):SetBlock( { || aDados[02]})
oSection1:Cell("A1_NREDUZ" 	):SetBlock( { || aDados[03]})
oSection1:Cell("QTD_RNC"  	):SetBlock( { || aDados[04]})

oReport:NoUserFilter()

oSection1:Init()

aFill(aDados,nil)

cTitulo := "Rela��o Clientes x RNC"

cQuery	:= "SELECT A1_COD, A1_LOJA, A1_NREDUZ, COUNT(UI_CODIGO) QTD_RNC "+CRLF 
cQuery	+= "FROM "+RetSqlName("SA1")+" SA1 "+CRLF
cQuery	+= "LEFT JOIN "+RetSqlName("SUI")+" SUI "+CRLF
cQuery	+= "	ON UI_FILIAL = A1_FILIAL"+CRLF
cQuery	+= "	AND UI_CODCLI = A1_COD"+CRLF
cQuery	+= "	AND UI_LOJA = A1_LOJA"+CRLF
cQuery	+= "	AND UI_EMISSAO BETWEEN '"+DtoS(mv_par02)+"' AND '"+DtoS(mv_par03)+"'"+CRLF
cQuery	+= "WHERE A1_FILIAL = '"+xFilial("SA1")+"'"+CRLF
cQuery	+= "AND A1_ULTCOM >= '"+DtoS(mv_par01)+"'"+CRLF
cQuery	+= "AND SA1.D_E_L_E_T_ = ''"+CRLF
cQuery	+= "GROUP BY A1_COD, A1_LOJA, A1_NREDUZ"+CRLF
cQuery	+= "ORDER BY A1_COD, A1_LOJA, A1_NREDUZ"+CRLF

MemoWrite("eqrcarnc.sql",cQuery)

TCQuery cQuery New Alias (cAlias)

nTotsRec := (cAlias)->(RecCount())
oReport:SetMeter(nTotsRec)

While !(cAlias)->(Eof()) 

	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	aDados[1]	:= (cAlias)->A1_COD
	aDados[2]	:= (cAlias)->A1_LOJA
	aDados[3]	:= (cAlias)->A1_NREDUZ
	aDados[4]	:= (cAlias)->QTD_RNC

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

Aadd(aPerg, {cPerg, "01", "Clientes Ativos De?"	, "MV_CH1" , 	"D", 08	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "02", "Da Emiss�o RNC?"		, "MV_CH2" , 	"D", 08	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"",""})
Aadd(aPerg, {cPerg, "03", "At� Emiss�o RNC"		, "MV_CH3" , 	"D", 08	, 0	, "G"	, "MV_PAR03", ""	,""		,""				,""				,"",""})

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