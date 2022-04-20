#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#DEFINE ENTER chr(13) + chr(10) 


/*/{Protheus.doc} MT097APR
PE criação Documento Entrada para PC Reembolso de Despesas
@type function Processamento
@version  1.01
@author Emerson Paiva -  alterado p/mario.antonaccio
@since 25/07/16  -  alterado em 04/01/2022
@return Character, sem retorno especifico
/*/
User Function MT097APR()

Local aArea	:= GetArea()
Local cQry	:= "" 
Local _aCabSF1	:=	{}
Local _aItensSD1	:=	{}
Local _aLinha		:=	{}
Local cFornece		:= ""

If SCR->CR_TIPO <> 'PC'
	Return
EndIf

// Verifica se ja existe NF
cQry := " SELECT COUNT(*) AS NUMREG "  
cQry += " FROM " + RetSqlName("SD1") 
cQry += " WHERE	D_E_L_E_T_ = '' AND D1_COD LIKE 'RE%' "
cQry += " 		AND D1_DOC = '" + StrZero(Val(SCR->CR_NUM),9) + "' " 
cQry += " 		AND D1_FILIAL = '" + SCR->CR_FILIAL + "' "  
                               
If Select("TSD1") > 0
	TSD1->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS TSD1

If TSD1->NUMREG  > 0
	TSD1->(dbCloseArea())
	Return
End	
// Fim verificação NF

cQry := " SELECT ROW_NUMBER() OVER (ORDER BY C7_ITEM) AS ITEM, * "  
cQry += " FROM " + RetSqlName("SC7") 
cQry += " WHERE	D_E_L_E_T_ = '' AND C7_PRODUTO LIKE 'RE%' "
cQry += " 		AND C7_NUM = '" + SCR->CR_NUM + "' " 
cQry += " 		AND C7_FILIAL = '" + SCR->CR_FILIAL + "' "  
cQry += " ORDER BY C7_ITEM "        
                               
If Select("TSC7") > 0
	TSC7->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS TSC7
        
TSC7->(dbGoTop())

/*
While ! TSC7->(EOF())
	//Tratamento verificar se existe algum item ainda bloqueado
	If TSC7->C7_CONAPRO = "B"
		RestArea(aArea)
		Return ()
	EndIf
	TSC7->(dbSkip())
EndDo

TSC7->(dbGoTop())
*/
If ! TSC7->(EOF())

	//lMsHelpAuto     :=	.F.
	lMsErroAuto     :=	.F.
	cFornece		:=	TSC7->C7_FORNECE
		
	Aadd(_aCabSF1,{"F1_FILIAL"		,TSC7->C7_FILIAL	,Nil})
	Aadd(_aCabSF1,{"F1_TIPO"		,"N"				,Nil})
	Aadd(_aCabSF1,{"F1_FORMUL"		,"N"				,Nil})
	Aadd(_aCabSF1,{"F1_DOC"			,StrZero(Val(SCR->CR_NUM),9)	,Nil})
	Aadd(_aCabSF1,{"F1_SERIE"		,"REC"				,Nil})
	Aadd(_aCabSF1,{"F1_EMISSAO"		,dDataBase			,Nil})
	Aadd(_aCabSF1,{"F1_FORNECE"     ,TSC7->C7_FORNECE	,Nil})
	Aadd(_aCabSF1,{"F1_LOJA"		,TSC7->C7_LOJA		,Nil})
	Aadd(_aCabSF1,{"F1_ESPECIE"		,"RECIB"			,Nil})
	Aadd(_aCabSF1,{"F1_COND"		,TSC7->C7_COND		,Nil})
	Aadd(_aCabSF1,{"F1_DTDIGIT"		,dDataBase			,Nil})
	Aadd(_aCabSF1,{"F1_EST"			," "				,Nil})
	If	AllTrim(TSC7->C7_PRODUTO) $ "RE.0017"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1403.1"		,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0018"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1606"			,Nil})
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0019"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1304"			,Nil})
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0021"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1519"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0022"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1402"			,Nil})
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0030"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1403.2"		,Nil})
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0031"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1901"			,Nil})
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0033"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1931"			,Nil})
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0034"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1932"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0035"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1514"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0036"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1802"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0037"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1803"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0038"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1804"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0039"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1801"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0040"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1806"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0041"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1899"			,Nil})	
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0042"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1447"			,Nil})
	ElseIf AllTrim(TSC7->C7_PRODUTO) $ "RE.0044"
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1719"			,Nil})				
	Else
		Aadd(_aCabSF1,{"E2_NATUREZ"		,"1917"			,Nil})
	EndIf
	 
	While ! TSC7->(EOF())
				
		_aLinha		:=	{}
		Aadd(_aLinha,{"D1_FILIAL"	,TSC7->C7_FILIAL	,Nil})
		Aadd(_aLinha,{"D1_ITEM"		,StrZero(TSC7->ITEM,4),Nil})  //Alterado 28/09/2016 TSC7->C7_ITEM
		Aadd(_aLinha,{"D1_FORNECE"	,TSC7->C7_FORNECE	,Nil})
		Aadd(_aLinha,{"D1_LOJA"		,TSC7->C7_LOJA		,Nil})
		Aadd(_aLinha,{"D1_DOC"		,StrZero(Val(SCR->CR_NUM),9)	,Nil})
		Aadd(_aLinha,{"D1_PEDIDO"	,TSC7->C7_NUM		,Nil})	
		Aadd(_aLinha,{"D1_COD"		,TSC7->C7_PRODUTO	,Nil})
		Aadd(_aLinha,{"D1_UM"		,TSC7->C7_UM		,Nil})
		Aadd(_aLinha,{"D1_QUANT"	,TSC7->C7_QUANT		,Nil})
		Aadd(_aLinha,{"D1_VUNIT"	,TSC7->C7_PRECO		,Nil})
		Aadd(_aLinha,{"D1_TOTAL"	,TSC7->C7_TOTAL		,Nil})
		Aadd(_aLinha,{"D1_TES"		,IIf(Empty(AllTrim(TSC7->C7_TES)),"000",TSC7->C7_TES),Nil})		
		Aadd(_aLinha,{"D1_CF"		,"1949"				,Nil})
		Aadd(_aLinha,{"D1_CC"		,TSC7->C7_CC		,Nil})	
		Aadd(_aLinha,{"D1_ITEMPC"	,TSC7->C7_ITEM		,Nil})
		Aadd(_aLinha,{"D1_EMISSAO"	,dDataBase				})
		Aadd(_aLinha,{"D1_DTDIGIT"	,dDataBase			,Nil})
		Aadd(_aLinha,{"D1_LOCAL"	,TSC7->C7_LOCAL		,Nil})
		Aadd(_aLinha,{"D1_SERIE"	,"REC"				,Nil})
		Aadd(_aLinha,{"D1_TIPO"		,"N"				,Nil})
		Aadd(_aLinha,{"D1_FORMUL"	,"N"					})
		Aadd(_aLinha,{"D1_RATEIO"	,"2"				,Nil})
		Aadd(_aLinha,{"D1_TP"		,"RE"				,Nil})
		Aadd(_aLinha,{"AUTDELETA"	,"N"				,Nil})						
		Aadd(_aItensSD1,_aLinha)
		         
		TSC7->(dbSkip())
	
	EndDo
	
	MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabSF1,_aItensSD1,3)
	 
	If lMsErroAuto
	    MostraErro()
	    
	    If Select("TSE2") > 0
	    	TSE2->(dbCloseArea())
		EndIf
	     
	    cQry := " SELECT	E2_NUM "  
	    cQry += " FROM " + RetSqlName("SE2")  + " "
	    cQry += " WHERE	D_E_L_E_T_ = '' AND E2_NUM = '" + StrZero(Val(SCR->CR_NUM),9) + "' " 
	    cQry += " 		AND E2_FILIAL = '" + SCR->CR_FILIAL + "' "
	    cQry += " 		AND E2_FORNECE = '" + cFornece + "' "
	     
	    TCQUERY cQry NEW ALIAS TSE2
        
		dbSelectArea("TSE2")
		dbGoTop()
		
		If	! TSE2->(EOF())
			//MsgInfo("Criação da despesa realizada!")
		Else
			//MsgInfo("Erro na criação da despesa, favor informar para a área de TI ou Financeira!")
		EndIf	     
	     
	Else
		//// Exibe mensagem ao usuario
		//MsgInfo("Criação da despesa realizada com sucesso! " + ENTER +;
		//"Título : " + StrZero(Val(SCR->CR_NUM),9) + ".")
	Endif

EndIf

RestArea(aArea)

Return ()
