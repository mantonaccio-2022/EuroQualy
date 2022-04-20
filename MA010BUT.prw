#include 'protheus.ch'
#include 'parmtype.ch'
/*/{Protheus.doc} mt010inc
//PE utilizado para gerar o EAN 13 na inclusao do produto
@author mjlozzardo
@since 07/02/2018
@version 1.0
@type function
/*/

User Function MA010BUT()

Local aButtons := {} // bot�es a adicionar

AAdd(aButtons,{ 'NOTE',{| |  U_EQCodBar() }, 'Gerar C�digo de Barras','' } )

Return (aButtons)
