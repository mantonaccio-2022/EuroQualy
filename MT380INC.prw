#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MT380INC � Autor � Fabio    	         � Data � 23/12/2017  ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada para valida��o de ajuste de empenho Mod 1 ���
���          �                                 							  ���
�������������������������������������������������������������������������͹��
���Uso       � Grupo Sabar�                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MT380INC()

Local aArea    := GetArea()
Local lValido  := .T.

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lValido
EndIf

lValido := BeAutori()

RestArea(aArea)

Return lValido

Static Function BeAutori()

Local lRet   := .T.
Local nLin   := 0
Local cTipos := GetMV( "MV_BE_AJTP",, "'PA','MP','PI','ME','EM','RV','BN','SP','PP','KT'")

// Verifica se Permite Validar Baixa de SA - Tipos de Produtos...
dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + M->D4_COD ) )
	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
		Aviso("MT380INC / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " N�o Permitido Efetuar Ajuste de Empenho Mod. 1!",{"Cancela"})
		lRet := .F.
	EndIf
EndIf

Return lRet