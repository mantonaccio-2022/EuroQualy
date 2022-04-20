#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        
#include "protheus.ch"

#define ENTER CHR(13) + CHR(10)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATX008V  � Autor � Thiago             � Data �  21/09/11   ���
�������������������������������������������������������������������������͹��
���Descricao � ORCAMENTO - OBTEM VENDEDOR LOGADO                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX008V( lSQL )

Local aArea		:= GetArea()
Local cVend		:= ""
Local cQry		:= ""

Default lSQL := .F.

cVend := Iif(lSQL, "''", "")

cQry := " SELECT	A3_COD CODIGO " + ENTER
cQry += " FROM	" + RetSqlName("SA3") + ENTER
cQry += " WHERE		D_E_L_E_T_ = ''" + ENTER
cQry += " 			AND A3_FILIAL = '" + xFilial("SA3") + "'" + ENTER
cQry += " 			AND A3_MSBLQL <> '1'" + ENTER
cQry += " 			AND (  " + ENTER
cQry += " 						A3_COD IN ( " + ENTER
cQry += " 									SELECT  A3_COD " + ENTER
cQry += " 									FROM	" + RetSqlName("SA3") + ENTER
cQry += " 									WHERE	D_E_L_E_T_ = ''" + ENTER
cQry += " 									AND		A3_FILIAL = '" + xFilial("SA3") + "'" + ENTER
cQry += " 									AND		A3_CODUSR = '" + __cUserID + "'" + ENTER
cQry += " 									AND		A3_MSBLQL <> '1'" + ENTER	
cQry += " 							      ) " + ENTER
cQry += " 				 	OR	A3_SUPER IN ( " + ENTER
cQry += " 										SELECT  A3_COD " + ENTER
cQry += " 										FROM	" + RetSqlName("SA3") + ENTER
cQry += " 										WHERE	D_E_L_E_T_ = ''" + ENTER
cQry += " 										AND		A3_FILIAL = '" + xFilial("SA3") + "'" + ENTER
cQry += " 										AND		A3_CODUSR = '" + __cUserID + "'" + ENTER
cQry += " 										AND		A3_MSBLQL <> '1'" + ENTER	
cQry += " 							      	) " + ENTER
cQry += "				) " + ENTER           

MemoWrite("fatx008v.sql", cQry )
  
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

QRY->(dbGoTop())
                               
While !QRY->(EOF())
	
	If lSQL
		cVend += "," + "'" + QRY->CODIGO + "'"
	Else
		cVend += "," + QRY->CODIGO        
	EndIf
	
	QRY->(dbSkip())

EndDo

QRY->(dbCloseArea())	

If !Empty(cVend)
	cVend := Iif(lSQL, SubStr(cVend,4,Len(cVend)), SubStr(cVend,2,Len(cVend)))
EndIf
	
RestArea(aArea)

Return cVend  