#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CBRETEAN  �Autor  �                    � Data �  22/08/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para possibilitar a leitura de varios     ���
���          � codigos de barra para o mesmo produto.                     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAACD                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/            
User Function CBRETEAN()

//�������������������������������������������������������������������������Ŀ
//� Declara as Variaveis													�
//���������������������������������������������������������������������������
Local aArea    		:= GetArea()
Local aAreaSB1 		:= SB1->(GetArea())
Local aAreaSB8 		:= SB8->(GetArea())
Local aRet     		:= {}
Local cEtiqueta		:= ParamIXB[1]
Local cCodProd		:= Padr(Substr(Alltrim(cEtiqueta),1,15),15)
Local cProduto 		:= Space(Len(SB1->B1_COD))
Local cLote    		:= Padr(Substr(cEtiqueta,16,10),10) //Space(10)
Local dDtValid 		:= SToD(Substr(cEtiqueta,26,8))
Local nQtde    		:= 1 
Local lQtde    		:= .F. 
Local lFound   		:= .F.
Local cCodGrv  		:= ""
Local cCodTip		:= ""
 
If Empty(cCodProd)
   Return (aRet)
Endif  
                                 
//acdV120 - CONFERENCIA
//ACDV121 - CONFERENCIA NF
/*                     
If Alltrim(FunName()) $ "ACDV120|ACDV121|ACDV166|ACDV177"
	dDtValid	:= StoD(substr(cEtiqueta,26,8))
Else
	dDtValid	:= CtoD("  /  /  ")
Endif
*/
//�������������������������������������������������������������������������Ŀ
//� Verifica o Codigo de Controle do Usu�rio								�
//���������������������������������������������������������������������������
If Len(alltrim(cEtiqueta)) == 13 // C�digo EAN-13  

	DBSelectArea("SB1")	// Cadastro de Produto
	DBSetOrder(5) 		// B1_FILIAL+B1_CODBAR
	If DBSeek(xFilial("SB1")+cEtiqueta)
		cProduto := SB1->B1_COD
		lFound 	 := .T.
	EndIf

EndIf

If !lFound

	DBSelectArea("SB1")	// Cadastro de Produto
	DBSetOrder(1) 		// B1_FILIAL+B1_COD
	If DBSeek(xFilial("SB1")+cCodProd)
		cProduto := SB1->B1_COD
		lFound 	 := .T.
	EndIf

EndIf

//�������������������������������������������������������������������������Ŀ
//� Verifica se Localizou Codigo de Etiqueta nas Tabelas PCO/SB1			�
//���������������������������������������������������������������������������
If lFound
	
	//�������������������������������������������������������������������������Ŀ
	//� Alimenta Array de Retorno do Ponto de Entrada							�
	//���������������������������������������������������������������������������
	If Len(Alltrim(cEtiqueta)) > Len(SB1->B1_COD)
    			
		If Alltrim(FunName()) $ "ACDV166|ACDV177" 
			DbSelectArea("SB8")                  
			DbSetOrder(3)
			
			If DbSeek(xFilial("SB8")+cProduto + CB8->CB8_LOCAL +cLote) 
    		
				//If !Empty(dDtValid) .And. dDtValid <> SB8->B8_DTVALID
				//	VtAlert("Validade nao confere","VALIDADE",.T.,4000)  
				//	cProduto := " "
				//	cLote    := " "
	    	    //EndIf 
			Else
				VtAlert("Lote nao encontrado","LOTE",.T.,4000)  
				cProduto := " "
				cLote    := " "
			EndIf 
		EndIf
		
		AAdd(aRet,cProduto)        //01-Codigo do produto
		AAdd(aRet,nQtde)           //02-Quantidade
		AAdd(aRet,cLote)           //03-Lote
		AAdd(aRet,dDtValid)        //04-Data de validade
		AAdd(aRet,Space(20))       //05-Numero de serie

	Else                                               

		AAdd(aRet,cProduto)        //01-Codigo do produto
		AAdd(aRet,nQtde)           //02-Quantidade
		AAdd(aRet,cLote)           //03-Lote
		AAdd(aRet,dDtValid)//04-Data de validade
		AAdd(aRet,Space(20))       //05-Numero de serie

	EndIf	
	
EndIf

RestArea(aAreaSB8)
RestArea(aAreaSB1)
RestArea(aArea)

Return(aRet)
