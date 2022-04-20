
/*/{Protheus.doc} FILC6PRESP
Filtro para selecionar pedidos com produtos especias na Inclusao da OP
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 21/09/2021
@return character, filtro em SQL
/*/
User Function FILC6PRESP()         

Local cSql as character

cSQL := "@C6_XGRPESP IN '"+GETMV("QE_GRPPRES") +"'"  

Return cSQL


