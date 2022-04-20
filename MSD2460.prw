#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"             

#define ENTER chr(13) + chr(10)  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MSD2460   � Autor �                    � Data �  12/12/17   ���
�������������������������������������������������������������������������͹��
���Descricao �Ponto de Entrada criado na grava��o dos Itens da NF, para   ���
���          �executar um execblock criado pelo usu�rio ap�s a grava��o da���
���          �tabela SD2.                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MSD2460()  
Local aArea		:= GetArea()

//SB1->(dbSetOrder(1))
//SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))

//SC6->(dbSetOrder(1))
//SC6->(dbSeek(xFilial("SC6") + SD2->D2_PEDIDO +  SD2->D2_ITEMPV + SD2->D2_COD))
//MAA - Grava��o do tipo de opera��o no arquivo - 20211206
SF4->(dbSetOrder(1))
SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
	                
//���������������������������������������������������������������������Ŀ
//� Atualiza custo no arquivo SD2                                       �
//�����������������������������������������������������������������������
dbSelectArea("SD2")	     
RecLock("SD2", .F.)
	SD2->D2_CUSTD   := SB1->B1_CUSTD
	SD2->D2_CUSTNET := SB1->B1_CUSTNET
	//SD2->D2_PRCNET  := SD2->D2_PRCVEN * (SD2->D2_PICM/100 + 0.0925)
	//SD2->D2_CUSTREF := SB1->B1_DATREF 
	//SD2->D2_CF      := SC6->C6_CF 
	//SD2->D2_INCLUI  := cUserName  
	//SD2->D2_U_OPER  := SC6->C6_U_OPER
	SD2->D2_FCICOD  := SC6->C6_FCICOD
	//MAA - Grava��o do tipo de opera��o no arquivo - 20211206
 	If FieldPos("D2_XOPER") > 0
	 	SD2->D2_XOPER := SF4->F4_XOPER 
	End	 
SD2->(MsUnlock())           
                                                                

//���������������������������������������������������������������������Ŀ
//� Restaura area anterior ao processamento                             �
//�����������������������������������������������������������������������            
RestArea(aArea)

Return( Nil )
