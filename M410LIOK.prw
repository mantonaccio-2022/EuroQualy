#include "TOTVS.CH"

// Este programa não estava no projeto, verificar o motivo depois... Adicionado Validação de OS na alteração do PV...

/*/{Protheus.doc} M410LIOK
Ponto de Entrada de validação da linha do Pedido de Venda 
@type function Ponto de Entrada
@version  1.00
@author Fabio Sousa - Alterado por Mario 
@since 19/08/2019 - alterado em 08/09/2021
@return Logical, permite ou nao a mudança de linha
/*/
User Function M410LIOK()

Local lRet		:= .T.
Local aAreaSB1  := SB1->( GetArea() )
Local aArea     := GetArea()
Local nPosGrpEsp  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XGRPESP"      })
Local nPosTotPrd  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_XQTDPRO"      })

//³Valida Custo com Preço de Venda...			³

If lRet
	//lRet := BeVldCusto() // Não validar agora, ver o motivo do programa não estava no projeto depois.
EndIf

// Validar se pedido e item possuem OS registradas na alteração...
If lRet
	//lRet := fVldOrdSep()
EndIf

// Validar se produto possui NCM 
If lRet
	lRet := fVldNCM()
EndIf

// Validar produto especial - PROJETO : Tratativa de produtos especiais para controlar producao x pedido de vendas
If lRet 
	If aCols[n,nPosGrpEsp] $  GETMV("QE_GRPPRES") .and.  aCols[n,nPosTotPrd] == 0
		ApMsgInfo("Este Produto é ESPECIAL!"+CRLF+"Somente podera ser alterado o pedido de vendas"+CRLF+"Apos o TERMINO do apontamento da Ordem de Producao","Produtos Especiais")
	EndIf
End

RestArea( aAreaSB1 ) 
RestArea(aArea)

Return lRet


/*/{Protheus.doc} BeVldCusto
Função para avisar o usuário caso o custo do produto menor que a saída (para TES que atualiza estoque)...            
@type function Validação
@version  1.00
@author Fabio F Sousa
@since 12/05/2017
@return Logical, Valida ou nao a informação
/*/
Static Function BeVldCusto()

Local lRetorno  := .T.
Local nPosItem  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_ITEM"    })
Local nPosProd  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRODUTO" })
Local nPosLocal := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_LOCAL"   })
Local nPosPreco := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRCVEN"  })
Local nPosTES   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_TES"     })
Local nPosCfop  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_CF"      })
Local cLocTran  := AllTrim( GetMv( "MV_LOCTRAN",,"30") )
Local i as number

If AllTrim( Upper( FunName() ) ) $ "RPC"
	Return lRetorno // Não validar se automático...
EndIf

For i := 1 To Len( aCols )
	If AllTrim( aCols[i][nPosLocal] ) == AllTrim( cLocTran )
		ApMsgAlert( 'Local informado (' + AllTrim( aCols[i][nPosLocal] ) +') específico para local em trânsito, informar o local de destino do produto!', 'Atenção' )
		lRetorno := .F.
	EndIf

	If Left( AllTrim( aCols[i][nPosCfop] ), 1) <> "7"
		SF4->(dbSetOrder(1))

		If SF4->( dbSeek( xFilial("SF4") + aCols[i][nPosTES] ) )
			If AllTrim( SF4->F4_ESTOQUE ) == "S"
				SB2->(dbSetOrder(1))
				
				If SB2->( dbSeek( xFilial("SB2") + Padr( aCols[i][nPosProd], TamSX3("B2_COD")[1]) + Padr( aCols[i][nPosLocal], TamSX3("B2_LOCAL")[1]) ) )
					If AllTrim( aCols[i][nPosCfop] ) $ "5152/6152/7152" // Se remessa de transferencia entre filiais não pode ser maior que custo...
						If aCols[i][nPosPreco] > SB2->B2_CM1 .And. SB2->B2_CM1 > 0
							Aviso("M410LIOK / BeVldCusto",	"Aviso..."  + CRLF + ;
															"Preço do item " + aCols[i][nPosItem] + " Produto: " + aCols[i][nPosProd] + " não pode ser maior que o valor de custo do produto:" + CRLF + ;
															"Custo Atual: " + Transform( SB2->B2_CM1, "@R 999,999,999.99") + CRLF + ;
															"Não será permitida a confirmação do Pedido!",{"Ok"},3)
							lRetorno := .F.
						EndIf
					Else
						If aCols[i][nPosPreco] < SB2->B2_CM1 .And. SB2->B2_CM1 > 0 .And. AllTrim( SF4->F4_DUPLIC ) == "S"
							Aviso("M410LIOK / BeVldCusto",	"Aviso..."  + CRLF + ;
															"Preço de Venda utilizada para o item " + aCols[i][nPosItem] + " Produto: " + aCols[i][nPosProd] + " Menor que o Custo Atual do Produto:" + CRLF + ;
															"Custo Atual: " + Transform( SB2->B2_CM1, "@R 999,999,999.99"),{"Ok"},3)
						ElseIf aCols[i][nPosPreco] > (SB2->B2_CM1 * 9) .And. SB2->B2_CM1 > 0
							Aviso("M410LIOK / BeVldCusto",	"Aviso..."  + CRLF + ;
															"Preço de Venda utilizada para o item " + aCols[i][nPosItem] + " Produto: " + aCols[i][nPosProd] + " Com Margem acima de 1.000% para o Produto:" + CRLF + ;
															"Custo Atual: " + Transform( SB2->B2_CM1, "@R 999,999,999.99") + CRLF + ;
															"Confirme se não é Erro ou Problema com Unidade de Medida ou Erro na Digitação ou o Custo está Indevido!",{"Ok"},3)
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next

Return lRetorno


/*/{Protheus.doc} fVldOrdSep
Função para avisar o usuário caso haja ordem de separação para o item que atualiza estoque no pedido...
@type function Tela
@version  1.00
@author Fabio F Sousa 
@since 25/06/2020
@return logical, validaçao ou nao a informação
/*/
Static Function fVldOrdSep()

Local lRetorno  := .T.
Local nPosNum   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_NUM"     })
Local nPosTES   := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_TES"     })
Local i         := 0

If AllTrim( Upper( FunName() ) ) $ "RPC"
	Return lRetorno // Não validar se automático...
EndIf

For i := 1 To Len( aCols )
    SF4->(dbSetOrder(1))

    If SF4->( dbSeek( xFilial("SF4") + aCols[i][nPosTES] ) )
        If AllTrim( SF4->F4_ESTOQUE ) == "S"
            dbSelectArea("CB7")
            dbSetOrder(2)
            If CB7->( dbSeek( xFilial("CB7") + aCols[i][nPosNum] ) )
                Aviso("M410LIOK / fVldOrdSep",	"Aviso..."  + CRLF + ;
                                                "Pedido possui Ordem de Separação, ação não permitida" + CRLF + ;
                                                "Defazer separações caso feito e estornar a OS para prosseguir!",{"Ok"},3)
                lRetorno := .F.
                Exit
            EndIf
        EndIf
    EndIf
Next

Return lRetorno


/*/{Protheus.doc} fVldNCM
Função para validar se produto possui NCM preenchido...
@type function Validacao	
@version  1.00
@author Fabio F Sousa  
@since 07/02/2020
@return logical, validaçao ou nao a informação
/*/
Static Function fVldNCM()

Local lRetorno  := .T.
Local nPosProd  := aScan( aHeader, {|x| Upper( AllTrim(x[2]) ) == "C6_PRODUTO"     })
Local i         := 0

If AllTrim( Upper( FunName() ) ) $ "RPC"
	Return lRetorno // Não validar se automático...
EndIf

For i := 1 To Len( aCols )
	SB1->(dbSetOrder(1))
	If !(aCols[i][nPosProd] == NIL .Or. Empty( aCols[i][nPosProd] ))
		If SB1->( dbSeek( xFilial("SB1") + aCols[i][nPosProd] ) )
			If Empty( SB1->B1_POSIPI )
				Aviso("M410LIOK / fVldNCM",	"Aviso..."  + CRLF + ;
												"Produto informado não possui NCM classificado, favor informar o fiscal." + CRLF + ;
												"Para prosseguir com a saída deste item, é necessário corrigir o produto!",{"Ok"},3)
				lRetorno := .F.
				Exit
			EndIf
		EndIf
	EndIf
Next

Return lRetorno
