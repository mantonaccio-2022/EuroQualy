#include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EQRetWFR �Autor  � Fabio  Sousa       � Data �  08/11/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o para buscar ultima movimenta��o do Status 		  ���
���          � Parametros:	cPar1 := C�digo da Filial					  ���
���          � 				cPar2 := C�digo do Processo  				  ���
���          � 				cPar3 := C�digo do Status    				  ���
���          � 				cPar4 := C�digo Identificador do Processo	  ���
���          � Retorno:		aRet1 := Nome do Usuario       				  ���
���          � 				aRet2 := Data do Movimento 					  ���
���          � 				aRet3 := Hora do Movimento 					  ���
���          � 				aRet4 := C�digo do Status 					  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EQRetWFR(cFilWF,cProc,cStatus,cID)
                                                
Local aRet := {"","","",""} //Usuario, Data, Hora, Status

//������������������������������������������������������������������������Ŀ
//�Posi��o WF3														   �
//��������������������������������������������������������������������������
dbSelectArea("WF3")
dbSetOrder(4)
dbSeek(cFilWF+Substr(cID,1,8))

While !WF3->(EOF()) .And. cFilWF == WF3->WF3_FILIAL .And. cProc == WF3->WF3_PROC .And. Substr(WF3->WF3_ID,1,8) == Substr(cID,1,8)

	If !Empty(cStatus)
		If cStatus == WF3->WF3_STATUS
			aRet := {WF3->WF3_USU, WF3->WF3_DATA,WF3->WF3_HORA,WF3->WF3_STATUS}
		ElseIf 	!Empty(aRet[1]) .And. Substr(cStatus,1,3)+"900" == WF3->WF3_STATUS
			aRet := {"","","",""}	
		EndIf	
	ElseIf WF3->WF3_STATUS >= '100000'
		aRet := {WF3->WF3_USU, WF3->WF3_DATA,WF3->WF3_HORA,WF3->WF3_STATUS}
	EndIf
	
	WF3->(dbSkip())
End

Return aRet