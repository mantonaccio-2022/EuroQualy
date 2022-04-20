#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT185BAIX � Autor � Fabio    		 � Data � 19/08/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada Baixa Requisicao  (SA) 				      ���
���          �                                 							  ���
�������������������������������������������������������������������������͹��
���Uso       � 				                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT185BAIX()

Local aArea    := GetArea()
Local lValido  := .T.

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lValido
EndIf

lValido := BeAutori()

RestArea( aArea )

Return lValido

Static Function BeAutori()

Local nPosProd := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="CP_PRODUTO" })
Local cPesq    := ""
Local lRet     := .T.

For nLin := 1 To Len( aCols )
	cPesq:= Posicione("SB1",1,xFilial("SB1")+aCols[nLin,nPosProd],"B1_TIPO")
	If ! cPesq $ GetMV( "MV_BE_BSTP",, "'PA','MP','PI','ME','EM','RV','GG','MO','BN','SP','PP','SV'")
		Aviso("MTA105OK / Tipo de Produto!","Tipo Produto: " + cPesq + " N�o Permitido Efetuar Baixa da Solicitacao!",{"Cancela"})
		lRet := .F.
		Exit
	EndIf
Next

Return lRet