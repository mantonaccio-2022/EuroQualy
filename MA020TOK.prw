#Include 'Protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MA030TOK  �Autor� Evandro Peixoto          �Data 11/10/2019���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada na inclus�o do Forncedor com o objetivo     ���
���          � de gerar o item contabil                                   ���
�������������������������������������������������������������������������͹��
���Uso       �                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA020TOK()
//Local cEmail := ""
Local lRet   := .T.
local nResto := 0
Local nTam   := 0
Local nI     := 1

/*If M->A1_EST # "EX"
	If empty(M->A1_CGC)
		If m->a1_tipo # "L" .AND. m->a1_tipo # "X"
			Alert("O preenchimento de campo CGC/CNPJ deve ser obrigatorio para clientes diferentes de Exportacao e Produtor Rural")
			Return(.f.)
		Endif
	Endif
Endif*/

If M->A1_EST = "EX" 
	If ! EMPTY(M->A2_CGC)
			Alert("Fornecedor estrangeiro n�o deve ter CNPJ cadastrado.")
		Return(.f.)
	Endif
Endif

If m->a2_est # "EX"
	If m->a2_tipo == "X"
		Alert("Para clientes com tipo igual a Exporta��o o Estado deve ser igual a EX, verifique!")
		Return(.f.)
	Endif
Endif

If  M->A2_EST <> "EX" .AND. EMPTY(M->A2_CGC)  
			ALERT("Por favor, cadastrar o CNPJ do cliente.")
			Return(.f.)
EndIf

If M->A2_EST # "EX"
	If empty(M->A2_COD_MUN)
		Alert("Por favor, preencher o C�digo do munic�pio")
		Return(.f.)
	Endif
Endif

If M->A2_EST # "EX"
	If empty(M->A2_INSCR)
		Alert("Por favor, preencher Inscri��o estadual")
		Return(.f.)
	Endif
Endif

	If empty(M->A2_PAIS)
		Alert("Por favor, preencher o c�digo do pais")
		Return(.f.)
	Endif

	
Return(.T.)

