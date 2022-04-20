#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  |MT097APR  �Autor  �Emerson Paiva       � Data �  28/07/16   ���
�������������������������������������������������������������������������͹��
���Descricao � PE cria��o Documento Entrada para PC Reembolso de Despesas ���
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

User Function GENC002(cTab)

Local aArea		:= GetArea()
Local cTabela	:= cTab
Local cQry		:= ""
Local cFiltro	:= ""
Local cFiltroIN	:= ""

If cTabela == "CTT"  //Filtrar CC de custos permitidos para usu�rio conforme tabela ZZA
	
	cQry := " SELECT	DISTINCT RTRIM(ZZA_CCUSTO) ZZA_CCUSTO "  
	cQry += " FROM " + RetSqlName("ZZA") 
	cQry += " WHERE	D_E_L_E_T_ = '' AND ZZA_USUARI = '" + __cUserID + "' "
	
	If Select("QRYZZA") > 0
		QRYZZA->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS QRYZZA
	        
	Do While QRYZZA->( !EoF() )
		cFiltroIN	+= QRYZZA->ZZA_CCUSTO + "#"
		QRYZZA->( dbSkip() )
	EndDO
	
	cFiltro	:= "@#CTT->CTT_CUSTO $ '" + cFiltroIN + "' @#"
	
	If Select("QRYZZA") > 0
		QRYZZA->(dbCloseArea())
	EndIf

	//MsgStop(cFiltro)

EndIf

Restarea( aArea )

Return( cFiltro )