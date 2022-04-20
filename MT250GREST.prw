/*/{Protheus.doc} MT250GREST
Ponto de Entrada para permitir nova Analise OP quando do estorno
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 10/03/2022
@return variant, sem retorno 
/*/
User Function MT250GREST()

Local aArea:=GetArea()

SC2->(dbSetOrder(1))
If SC2->(dbSeek(xFilial("SC2")+SH6->H6_OP))
    RecLock("SC2", .F.)
    SC2->C2_XLIBOP:="2"        
    MsUnlock()
End    
RestArea(aArea)
Return Nil
