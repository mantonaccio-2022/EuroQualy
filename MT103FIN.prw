#include "protheus.ch"
#include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT100TOK  �Autor  �Rodrigo Sousa       � Data �  26/04/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida Folder Duplicatas da Nota Fiscal de Entrada		  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User FuncTion MT103FIN()

Local lLocRet  	:= PARAMIXB[3]      // Flag de valida��es anteriores padr�es do sistema.                                    

If lLocRet                                                           
	lLocRet := EQVldVcto()
EndIf	

Return(lLocRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BeVldVcto �Autor  �Rodrigo Sousa       � Data �  26/04/15   ���
�������������������������������������������������������������������������͹��
���Desc.     � N�o permite inclus�o de duplicatas com vencimento abaixo	  ���
���     	 � do indicado no parametro MV_BEDVCTO, onde � informado	  ���
���     	 � o numero de dias uteis permitidos para vencimento minimo	  ���
���     	 � de titulos a pagar.										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function EQVldVcto()

Local lRet		:= .T.
Local nX		:= 0

Local aLocHead 	:= PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
Local aLocCols 	:= PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.

Local nPosVcto	:= aScan(aLocHead,{|x| Upper(Alltrim(x[2]))=="E2_VENCTO"})  
Local nPosVlr	:= aScan(aLocHead,{|x| Upper(Alltrim(x[2]))=="E2_VALOR"})  
Local nDiasVcto := SuperGetMV("MV_EQDVCTO",.f.,0)

Local dVctoPer	:= dDataBase + nDiasVcto

If nDiasVcto > 0
	
	For nX := 1 to Len(aLocCols)

		If aLocCols[nX][nPosVcto] < dVctoPer .And. aLocCols[nX][nPosVlr] > 0 .And. !Empty(cCondicao)

			Aviso("MT103FIN / EQVldVcto","Existe(m) titulo(s) com vencimento n�o permitido"+CRLF+;
										 "Data de vencimento minimo permitido � em: "+DtoC(dVctoPer)+CRLF+CRLF+;
										 "Entre em contato com o Departamento Financeiro.",{"Ok"},2)
			lRet := .F.  
			Exit

		EndIf

	Next nX

EndIf

Return lRet
