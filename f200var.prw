#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} F200VAR
Ponto de Entrada na Recepcao de arquivo de Cobranca
@type function Processamento
@version  1.00
@author mario.antonaccio
@since 11/05/2022
@return Array, O array modificado
/*/

User Function F200VAR()

    Local aArea:=GetArea()
    Local aAreaSE1 := SE1->(GetArea())
    Local aTitulo  := PARAMIXB
    Local aAreaSA6 := SA6->(GetArea())
    Local _nReten := GETMV("MV_XD1",,1)   //SA6->A6_RETENCA

    //Transferencia automatica para Cartorio
    If AllTrim(aTitulo[1, 14]) $ "23#21"
        SE1->(dbSetOrder(1))
        If SE1->(dbSeek(xFilial("SE1") + AllTrim(aTitulo[1, 1])))
            If SE1->E1_SALDO != 0
                If (SE1->E1_PORTADO == "033" .and. AllTrim(aTitulo[1, 14]) == "21") .or.;
                   (SE1->E1_PORTADO != "033" .and. AllTrim(aTitulo[1, 14]) $ "23|98")
                    SE1->(RecLock("SE1", .F.))
                    SE1->E1_SITUACA := "F"
                    SE1->(MsUnLock())
                EndIf
            EndIf
        EndIf
    EndIf

    cTipo := "01"

    //tratamento para o banco Daycoval/Sofisa
    If MV_PAR06 $ ("707/637")
       dBaixa  := ddatabase + _nReten // Tratamento para data    
    EndIf
  
    If MV_PAR06 $ ("707")
       cOcorr  :=If(Empty(cOcorr),Substring(aTitulo[1,16],109,2),cOcorr)+Space(01) // Tratamento para Ocorrencia ESPECIFICO DAYCOVAL
    EndIf
  

    If mv_par06 $ ("707/637/633/341") // DaycoVal/Sofisa/Rendimentos/Itau
        nValRec := nValRec + nDespes //tratamento para não gera linha despesas(SE5)
        nDespes:=0    
    End    

    If mv_par06 $ ("633") // Rendimentos
        nValCC := 0 // Gera��o de Despesa Bancaria Como Credito - Verifica posteriormente se deve ser computada
    End    


    aTitulo[1,02]:=dBaixa
    aTitulo[1,03]:=cTipo
    aTitulo[1,08]:=nValRec    
    aTitulo[1,11]:=nDespes
    aTitulo[1,12]:=nValCC
    aTitulo[1,14]:=cOcorr

    RestArea(aAreaSE1)
    RestArea(aAreaSA6)
    RestArea(aArea)

Return(aTitulo)

 /*/
Obs:Variaveis Utilizadas
01 - cNumTit -> Número do título
02 - Baixa -> Data da Baixa
03 - cTipo -> Tipo do título
04 - cNsNum -> Nosso Número
05 - nDespes -> Valor da despesa
06 - nDescont -> Valor do desconto
07 - nAbatim -> Valor do abatimento
08 - nValRec -> Valor recebidos
09 - nJuros -> Juros
10 - nMulta -> Multa
11 - nOutrDesp -> Outras despesas
12 - nValCc -> Valor do crédito
13 - dDataCred -> Data do crédito
14 - cOcorr -> Ocorrencia
15 - cMotBai -> Motivo da baixa
16 - xBuffer -> Linha inteira
17 - dDtVc -> Data do vencimento
    /*/

