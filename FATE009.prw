#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATE009  � Autor �                    � Data �  05/08/07   ���
�������������������������������������������������������������������������͹��
���Descricao �GERA FATOR DE VENDA - MATA410                               ���
���          �                                                            ���
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
User Function FATE009(nOpc)     

//���������������������������������������������������������������������Ŀ
//|Declaracao de variaveis                                              �
//�����������������������������������������������������������������������     

Local aArea    := GetArea()
Local aAreaSB1 := SB1->(GetArea())
Local aAreaSM2 := SM2->(GetArea())

Local nMoeda := ""
Local nPos1  := Ascan(aHeader,{|x| "C6_PRCVEN"  $ x[2]})
Local nPos2  := Ascan(aHeader,{|x| "C6_U_PRNET" $ x[2]})
Local nFator := 0             

If !Empty( aCols[n,2] )

	SB1->(dbSetOrder(1))
	SB1->(MsSeek(xFilial("SB1") + aCols[n,2]))
	    
	//If !(U_isGroup("FAT-X00", AllTrim(cUserName)))
	  
	 	If nOpc == 1 .And. !(M->C5_TIPO $ "C#I#P")
	 	 	nFator := Round(aCols[n,nPos1]/Iif(SB1->B1_CUSTD == 0 .Or. Subs(SB1->B1_GRUPO,1,1) == "X", aCols[n,nPos1],(SB1->B1_CUSTD * 1.03)),2)
	 	ElseIf nOpc == 2 .And. !(M->C5_TIPO $ "C#I#P")
			nFator := Round(aCols[n,nPos2]/Iif(SB1->B1_CUSTNET == 0 .Or. Subs(SB1->B1_GRUPO,1,1) == "X", aCols[n,nPos2],(SB1->B1_CUSTNET * 1.03)),2)
		EndIf	
		
		nMoeda := IIf( Type("M->C5_MOEDA")!="U", M->C5_MOEDA, SC5->C5_MOEDA )
		
		//���������������������������������������������������������������������Ŀ
		//|Verifica Moeda                                                       �
		//�����������������������������������������������������������������������
		If nMoeda == 2
			dbSelectArea("SM2")
			dbSetOrder(1)
			If dbSeek(DtoS(dDataBase))
				If SM2->M2_MOEDA2 <> 0
					nFator := Round((nFator * SM2->M2_MOEDA2), 2)
				Else
					MsgStop("Moeda com valor 0!")
				EndIf
			Else
				MsgStop("N�o h� moeda cadastrada para data base da Venda!")
			EndIf
		EndIf
		
	//EndIf                 
	
EndIf
	               
SB1->(RestArea(aAreaSB1))
SM2->(RestArea(aAreaSM2))
RestArea(aArea)

Return nFator