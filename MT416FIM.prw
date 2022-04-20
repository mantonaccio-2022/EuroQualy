/*/{Protheus.doc} MT416FIM
PE após efetivação orçamento para gravar grupo de produto no Pedido
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 22/10/2021
@return Character, sem retorno
/*/
User Function MT416FIM()

    Local aArea:=GetArea()

    SCK->(dbSetOrder(1))
    If SCK->(dbSeek(xFilial("SCK")+SCJ->CJ_NUM))
        While SCK->(!EOF()) .and. SCK->CK_NUM == SCJ->CJ_NUM

            If ! Empty(SCK->CK_NUMPV)
                SC6->(dbSetOrder(2))
                If SC6->(dbSeek(xFilial("SC6")+SCK->CK_PRODUTO+SCK->CK_NUMPV))

                    SB1->(dbSetOrder(1))
                    SB1->(dbSeek(xFilial("SB1")+SCK->CK_PRODUTO))

                    SBM->(dbSetOrder(1))
                    SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))

                    RecLock("SC6",.F.)
                    SC6->C6_XGRPESP:=SB1->B1_GRUPO
                    SC6->C6_XGRPDSC:=SBM->BM_DESC
                    MsUnLock()
                    
                End
            End
            
            SCK->(dbSkip())

        EndDO
    End

    RestArea(aArea)

Return NIL
