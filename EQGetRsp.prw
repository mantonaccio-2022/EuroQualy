#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EQGetRsp �Autor  � Fabio Sousa        � Data �  02/03/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Execblock para retornar os emails do respons�veis pela 	  ���
���          � tarefa do processo de expedi��o workflow tabela Z17.		  ���
�������������������������������������������������������������������������͹��
���Documento � 												  			  ���
�������������������������������������������������������������������������͹��
���Uso       � Euroamerican.                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function EQGetRsp(cCodProc,cCodStatus, cCCusto)
           
Local cRet		:= ""
Local lProc		:= .T.

dbSelectArea("Z17")
dbSetOrder(1)
dbSeek(xFilial("Z17")+cCodProc+cCodStatus)

Do While !Z17->(Eof()) .And. Z17->Z17_FILIAL == xFilial("Z17") .And. Z17->Z17_PROC == cCodProc .And. Z17->Z17_STATUS == cCodStatus
	lProc := .T.		

    If Z17->Z17_NOTIF == '1' .And. lProc
		//������������������������������������������������������������������������Ŀ
		//�Dados do Usuario 													   �
		//��������������������������������������������������������������������������
		PswOrder(1) // Ordem de nome
		If PswSeek(Z17->Z17_RESP,.T.) // Efetuo a pesquisa, definindo se pesquiso usu�rio ou grupo
		   aRetUser 	:= PswRet(1) // Obtenho o resultado conforme vetor
		   cRet   		+= lower(alltrim(aRetUser[1,14]))+";" //Busco Email do usuario
		EndIf
    EndIf
	
	Z17->(dbSkip())
EndDo

Return cRet