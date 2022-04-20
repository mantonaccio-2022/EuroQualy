#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MTA105OK � Autor � Hamilton 		     � Data � 16/03/2017  ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada para valida��o Solilcitacao  (SA)         ���
���          �                                 							  ���
�������������������������������������������������������������������������͹��
���Uso       � 				                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MTA105OK()

Local aArea    := GetArea()
Local lValido  := .T.

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lValido
EndIf

lValido := BeAutori()

RestArea(aArea)

Return lValido

Static Function BeAutori()

Local nPosProd := aScan(aHeader,{|x| Upper(AllTrim(x[2]))=="CP_PRODUTO" })
Local cTipos   := GetMv( "MV_BE_SATP",, "'RV','PA','PI','EM','ME','MP','SP','KT','BN','MI'" )
Local lRet     := .T.

For nLin := 1 To Len( aCols )
	If ! aCols[nLin,Len(aHeader)+1]	// Indica se linha esta deletada
		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aCols[nLin,nPosProd] ) )
			If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
				Aviso("MTA105OK / Tipo de Produto!","Tipo do Produto: " + AllTrim( SB1->B1_TIPO ) + " N�o Permitido Efetuar Solicitacao!",{"Cancela"})
				lRet := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return lRet