#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} f200var
Ponto de Entrada na recepção Bancaria
@type function Ponto de Entrada
@version  1.00
@author mjloz - alterado por mario.antonaccio
@since 02/05/2018 - alterado em 07/04/2022
@return Character, sem retorno definido
/*/

User Function F200VAR()

    Local aArea:=GetArea()
    Local aAreaSE1 := SE1->(GetArea())
    Local aTitulo  := PARAMIXB
    Local aAreaSA6 := SA6->(GetArea())
    Local _nReten := GETMV("MV_XD1",,1)//SA6->A6_RETENCA

    //Transferencia automatica para Cartorio
    If AllTrim(aTitulo[1, 14]) $ "23#21"
        SE1->(dbSetOrder(1))
        If SE1->(dbSeek(xFilial("SE1") + AllTrim(aTitulo[1, 1])))
            If SE1->E1_SALDO != 0
                If (SE1->E1_PORTADO == "033" .and. AllTrim(aTitulo[1, 14]) == "21") .or. (SE1->E1_PORTADO != "033" .and. AllTrim(aTitulo[1, 14]) $ "23|98")
                    SE1->(RecLock("SE1", .F.))
                    SE1->E1_SITUACA := "F"
                    SE1->(MsUnLock())
                EndIf
            EndIf
        EndIf
    EndIf

    cTipo := "01"

    //tratamento para o banco Daycoval
    If MV_PAR06 == '707'
        alert("Juros: "+Str(nJuros,10,2))
        alert("Valor titulo: "+Str(nValrec,10,2))
        alert("Valor Recebido: "+Str(nValcc,10,2))


        dBaixa  := ddatabase + _nReten // Tratamento para data
        nValRec := nValRec + ndespes //tratamento para não gera linha despesas(SE5)
        ndespes := 0
    EndIf

    If MV_PAR06 == '637' //Sofisa
        dBaixa  := ddatabase + _nReten // Tratamento para data
        nValRec := nValRec + ndespes //tratamento para não gera linha despesas(SE5)
        ndespes := 0
    EndIf

    If MV_PAR06 == '633' //Rendimentos
      alert("Juros: "+Str(nJuros,10,2))
        alert("Valor titulo: "+Str(nValrec,10,2))
        alert("Valor Recebido: "+Str(nValcc,10,2))


        ndespes := 0
    EndIf

    //tratamento para itau não gera linha despesas(SE5)
    If mv_par06 == '341'
        nValRec := nValRec + ndespes
        ndespes := 0
    EndIf

    RestArea(aAreaSE1)
    RestArea(aAreaSA6)
    RestArea(aArea)

Return


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
