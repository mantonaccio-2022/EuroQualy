#Include 'Protheus.Ch'
#Include 'Totvs.Ch'

// PE Sele��o S�ries tabela 01 no faturamento para selecionar NF... (Fabio)

User Function SX5Nota()

Local lRetorno  := .T.
Local cIniSerie := GetMv("MV_EQ_INSE",,"REQ|REC") // Par�metro para inibir s�ries no faturamento

If AllTrim( SX5->X5_CHAVE ) $ cIniSerie
    lRetorno := .F.
EndIf

Return lRetorno