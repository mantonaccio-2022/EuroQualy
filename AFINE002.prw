#Include "rwmake.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AFINE002 �Autor  �Tiago O. Beraldi    � Data �  04/11/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Seleciona dados para gera��o de arquivo remessa            ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AFINE002()

c_Return := ''
n_ValOpc := ParamIxb

Do Case
	//Conta Header
	Case n_ValOpc == 1
		//If SM0->M0_CODIGO == "02" //Euroamerican      
		If LEFT(SM0->M0_CODFIL, 2) == "02" //Euroamerican
			c_Return := "09700005328352"   
		//ElseIf SM0->M0_CODIGO == "03"
		ElseIf LEFT(SM0->M0_CODFIL, 2) == "03"
			c_Return := "09700002006508"   
		Endif                  
	
	//Conta Detalhes
	Case n_ValOpc == 2
		//If SM0->M0_CODIGO == "02" //Euroamerican      
		If LEFT(SM0->M0_CODFIL, 2) == "02" //Euroamerican
			c_Return := "005328352"   
//		ElseIf SM0->M0_CODIGO == "03"
		ElseIf LEFT(SM0->M0_CODFIL, 2) == "03"
			c_Return := "002006508"   
		Endif           
EndCase

Return(c_Return)
