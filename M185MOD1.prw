#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � M185MOD1 � Autor � Fabio    	         � Data � 19/08/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada para valida��o de baixa SA Mod 1          ���
���          �                                 							  ���
�������������������������������������������������������������������������͹��
���Uso       � Euroamerican                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function M185MOD1()

Local aArea    := GetArea()
Local lValido  := .T.

Private aBaixa := aClone( ParamIXB )

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lValido
EndIf

lValido := BeAutori()

RestArea(aArea)

Return lValido

Static Function BeAutori()

Local lRet   := .T.
Local nLin   := 0
Local cTipos := GetMV( "MV_BE_BSTP",, "'PA','MP','PI','ME','EM','RV','GG','MO','BN','SP','PP','SV'")

// Verifica se Permite Validar Baixa de SA - Tipos de Produtos...
dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + aBaixa[2] ) )
	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
		Aviso("M185MOD1 / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " N�o Permitido Efetuar Baixa SA Mod. 1!",{"Cancela"})
		lRet := .F.
	EndIf
EndIf

Return lRet