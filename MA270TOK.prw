#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA270TOK � Autor � Fabio    	         � Data � 19/08/2019  ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de entrada para valida��o de inclus�o de invent�rio  ���
���          �                                 							  ���
�������������������������������������������������������������������������͹��
���Uso       � Euroamerican                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MA270TOK()

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
Local cTipos := GetMV( "MV_BE_INTP",, "'AF','AI','SV','GG','MO'")

// Verifica se Permite Incluir Invent�rio - Tipos de Produtos...
dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + M->B7_COD ) )
	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
		Aviso("MA270TOK / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " N�o Permitido Efetuar Inclus�o de Invent�rio!",{"Cancela"})
		lRet := .F.
	EndIf
EndIf

Return lRet