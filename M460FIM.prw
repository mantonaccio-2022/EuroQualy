#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} M460FIM
//Ponto de entrada apos a gera��o da nota fiscal
@author erics
@since 26/12/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function M460FIM
Local cPedido	:= SD2->D2_PEDIDO

// Processar PA0 -- Elimina��o de Residuo
U_ProcPA0(cPedido, 3) // inclus�o

Return( Nil )
