#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"  

#define ENTER chr(13) + chr(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIPE001   � Autor �Tiago O. Beraldi    � Data �  13/12/11   ���
�������������������������������������������������������������������������͹��
���Descricao � AVISO DE REINCIDENCIA DE RECLAMACAO DO LOTE                ���
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
User Function QIPE001(cLote, cSepar)
Local aArea		:= GetArea()

Local cQry		:= ""
Local cMsg		:= ""

Local aLote		:= {}
Local cQryAux	:= ""
Local nRec		:= 0

Default	cSepar	:= ";"    

//��������������������������������������������������������Ŀ
//� Se o parametro de lote for vazio, encerra a rotina	   �
//����������������������������������������������������������        
If Empty(cLote)
	Return cLote
EndIf
                     
//��������������������������������������������������������Ŀ
//� Transforma a string cLote em array                     �
//����������������������������������������������������������        
aLote	:= StrToKarr(cLote, cSepar)
aEval( aLote, {|x| cQryAux += "'" + AllTrim(x) + "'" + IIf( x <> aLote[Len(aLote)],",","" )} )

//��������������������������������������������������������Ŀ
//� Monta script SQL e atribui resultado a workarea QRY    �
//����������������������������������������������������������        
cQry := " SELECT	UI_ATEND NUMERO," + ENTER 
cQry += " 	    	CONVERT(VARCHAR, CONVERT(DATETIME, UI_EMISSAO), 103) EMISSAO," + ENTER
cQry += " 	    	UI_CODCLI + ' - ' + UI_NOMECLI CLIENTE" + ENTER
cQry += " FROM		" + RetSqlName("SUI") + ENTER
cQry += " WHERE		D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND UI_FILIAL = '" + xFilial("SUI") + "' " + ENTER
cQry += " 			AND UI_LOTE IN (" + AllTrim(cQryAux) + ")"

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

dbSelectArea("QRY")         

//��������������������������������������������������������Ŀ
//� Exibe dialogo caso a query retorne ao menos 1 linha    �
//����������������������������������������������������������        
Count To nRec

If nRec > 0

	dbGoTop()
	
	cMsg := PadC("RECLAMA��O DE LOTE REINCIDENTE", 60) + ENTER
	cMsg += Replicate("=", 60) + ENTER
	cMsg += "NUMERO    EMISSAO     CLIENTE" + ENTER
	cMsg += Replicate("-", 60) + ENTER
	                  
	While !QRY->(EOF())    
		cMsg += PadR(QRY->NUMERO, 10) + PadR(QRY->EMISSAO, 12) + PadR(QRY->CLIENTE, 38)
		QRY->(dbSkip())
	EndDo
	    
	oFontLoc := TFont():New("Mono AS", 06, 15)
	DEFINE MSDIALOG oDlg TITLE "Reclama��es" FROM 015,020 TO 032,69
		@ 0.5,0.7  GET oGet VAR cMsg OF oDlg MEMO SIZE 184,118 READONLY COLOR CLR_BLACK,CLR_HGRAY
		oGet:oFont     := oFontLoc
		oGet:bRClicked := {||AllwaysTrue()}
	ACTIVATE MSDIALOG oDlg Centered
	oFontLoc:End()     

EndIf  

//��������������������������������������������������������Ŀ
//� Monta script SQL e atribui resultado a workarea QRY    �
//����������������������������������������������������������        
cQry := " SELECT	C2_NUM + '.' + C2_ITEM + '.' + C2_SEQUEN NUMERO," + ENTER 
cQry += " 	    	CONVERT(VARCHAR, CONVERT(DATETIME, C2_DATRF), 103) FABRICACAO" + ENTER
cQry += " FROM		" + RetSqlName("SC2") + ENTER
cQry += " WHERE		D_E_L_E_T_ = '' " + ENTER
cQry += " 			AND C2_FILIAL = '" + xFilial("SC2") + "' " + ENTER
cQry += " 			AND C2_NUM IN (" + AllTrim(cQryAux) + ") " + ENTER
cQry += " 			AND C2_PRODUTO = '" + M->UI_CODPROD + "' "     

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

dbSelectArea("QRY")         

//��������������������������������������������������������Ŀ
//� Exibe dialogo caso a query retorne ao menos 1 linha    �
//����������������������������������������������������������        
Count To nRec1

If nRec1 > 0

	dbGoTop()
	
	cMsg := PadC("FABRICA��O DOS LOTES", 60) + ENTER
	cMsg += Replicate("=", 60) + ENTER
	cMsg += "LOTE           FABRICA��O" + ENTER
	cMsg += Replicate("-", 60) + ENTER
	                  
	While !QRY->(EOF())    
		cMsg += PadR(QRY->NUMERO, 15) + PadR(QRY->FABRICACAO, 10) 
		QRY->(dbSkip())
	EndDo
	    
	oFontLoc := TFont():New("Mono AS", 06, 15)
	DEFINE MSDIALOG oDlg TITLE "Reclama��es" FROM 015,020 TO 032,69
		@ 0.5,0.7  GET oGet VAR cMsg OF oDlg MEMO SIZE 184,118 READONLY COLOR CLR_BLACK,CLR_HGRAY
		oGet:oFont     := oFontLoc
		oGet:bRClicked := {||AllwaysTrue()}
	ACTIVATE MSDIALOG oDlg Centered
	oFontLoc:End()     

EndIf              

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf
	        
RestArea( aArea )	

Return cLote