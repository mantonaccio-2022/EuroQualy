#include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BeHtmRod�Autor  � Rodrigo Sousa		 � Data �  29/07/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rodap� do HTML                                             ���
���          � Par�metros:                                                ���
���          � lEncerra	-> 	Se verdadeiro encerra tabela e imprime linha  ���
���          � 				com rodap� padr�o, caso contr�rio apenas 	  ���
���          �              encerra tabela.                               ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BeHtmRod( lEncerra )

Local cRet := ""

cRet := '</table>'

If lEncerra
	cRet += '<Hr>'
	cRet += "<font face='Arial' size='1'><I>Powered by TI ERP - " + AllTrim( SM0->M0_NOME ) + "</I></font>"
	cRet += '<br>'
	cRet += "<font face='Arial' size='3'><B>" + AllTrim( SM0->M0_NOMECOM ) + "</B></font>"

	cRet += '</body>' + CRLF
	cRet += '</html>' + CRLF
EndIf

Return cRet
