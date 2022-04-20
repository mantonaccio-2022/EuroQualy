#Include 'Protheus.ch'

User Function MT120PCOK()

Local nPosRat	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_RATEIO"}) 
Local nPosCC	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})
Local lValido	:= .T.

If	aCols[n, nPosRat] <> "1"
	lValido := !Empty(aCols[n, nPosCC])
	
	If !lValido
		MsgAlert("� obrigat�rio informar o Centro de Custo para cada item da Solicita��o!","Aten��o")
	EndIf
EndIf

Return(lValido)

Return

