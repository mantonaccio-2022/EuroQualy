#include "RWMAKE.ch"
#include "protheus.ch"

*-----------------------*
User Function A415LIOK()
*-----------------------*  

Local lRet := .T.

If cModulo=="LOJ"  //  Se For loja nao executa = MAA 01/11/2021
		Return lRet
End


dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+TMP1->CK_PRODUTO)

	If SB1->B1_LOTVEN > 0 .And. (TMP1->CK_QTDVEN%SB1->B1_LOTVEN<>0)                                                                                                
 
		Aviso("Atenção","A Quantidade digitada não pode ser menor que a quantidade do lote minimo permitido."+CRLF+CRLF+;
				"Digite uma quantidade menor ou igual a minima ou altere a quantidade do lote minimo no cadastro de produto",{"Ok"},3)
		lRet := .F.    	

 	EndIf

EndIf

Return lRet
