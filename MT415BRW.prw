#include "protheus.ch"
//#include "rwmake.ch"
#include "topconn.ch"



/*/{Protheus.doc} MT415BRW
Filtrar Browse Orçamentos de Vendas
@type function Processamento
@version  1.00
@author Emerson Paiva  - alterado por mario.antonaccio
@since 12/12/17  - alterado em 24/11/2021
@return cFiltro, Variavel de filtro
/*/
User Function MT415BRW()

	Local cFiltro  := ""



		If	!UPPER(cUserName)  $ SuperGetMV("ES_MT415BR", .T., .F.) //"Administrator#Alessandra.Monea#Thiago.Monea#Robson.Moraes#Joelita.Silva#Luciana.Mota#Daiane.Gomes#Kely.Souza#Eunice.Godoy#Tatiane.Paz#Marcia.Oliveira" // ! Vendedores externos
			cFiltro := "CJ_COD $ '" + U_FATX008V() + "'"
		EndIf
	
Return cFiltro
