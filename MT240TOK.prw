#Include 'Protheus.Ch'
#Include 'TopConn.Ch'
#Include 'TbiConn.Ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT240TOK º Autor ³ Fabio F Sousa      º Data ³ 19/08/2019  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de entrada para validação de movimentações internas  º±±
±±º          ³ modelo 1                        							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Euroamerican                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT240TOK()

Local aArea         := GetArea()
Local aAreaSF5      := SF5->( GetArea() )
Local aAreaCTT      := CTT->( GetArea() )

Private oDlg
Private oMotivo
Private cMotivo     := Space(250)
Private lRetorno    := .T.
Private lInformado  := .F.
Private lTravaUser  := GetMV("MV_EQ_TUMI",,.F.)
Private cUserPerm   := AllTrim( GetMV( "MV_BE_UPMI",,"ADMINISTRADOR") ) + "/ADMINISTRADOR"
Private cEmailResp  := AllTrim( GetMV( "MV_BE_ERMI",,"roni.martins@euroamerican.com.br;lucas.santos@euroamerican.com.br") )
Private cMensagem   := ""
Private cAssunto    := ""
Private cTexto      := ""
Private cDesc01     := ""

If AllTrim( Upper( GetEnvServer() ) ) <> "FABIO"
	Return lRetorno
EndIf

If l240Auto
	Return lRetorno
EndIf

lRetorno := BeAutori()

If !lRetorno
	Return lRetorno
EndIf

If lTravaUser
	If !(AllTrim( Upper( cUserName ) ) $ cUserPerm)
		Alert( "Usuário sem permissão para este tipo de operação, favor contate a controladoria ou os(as) responsáveis pelo estoque!", "Atenção")
		Return .F.
	EndIf
EndIf

Define MsDialog oDlg Title "Informe o motivo da movimentação interna" From C(178),C(181) To C(288),C(558) Pixel

	@ C(004),C(006) Say "Descreva o motivo da movimentação: " Size C(176),C(008) COLOR CLR_BLUE Pixel Of oDlg
	@ C(014),C(006) MsGet oMotivo Var cMotivo Size C(179),C(009) COLOR CLR_BLACK Pixel Of oDlg
	@ C(028),C(006) Say "Caso não informar o motivo, sua movimentação não será realizada!" Size C(175),C(008) COLOR CLR_RED Pixel Of oDlg
	@ C(038),C(147) Button "Confirmar" Size C(037),C(012) Action (lInformado := .T., oDlg:End()) Pixel Of oDlg

Activate MsDialog oDlg Centered

If lInformado .And. !Empty( cMotivo ) // motivo é obrigatorio, não remover esta expressão...
	EnvEMail()
Else
	lRetorno := .F.
EndIf

CTT->( RestArea( aAreaCTT ) )
SF5->( RestArea( aAreaSF5 ) )
RestArea( aArea )

Return lRetorno

Static Function EnvEMail()

Local nLin := 0

cMensagem := ""
cAssunto  := "MI - Movimentação Interna: " + AllTrim( M->D3_DOC )

dbSelectArea("SF5")
dbSetOrder(1)
If SF5->( dbSeek( xFilial("SF5") + M->D3_TM ) )
	cTexto := AllTrim( SF5->F5_TEXTO )
EndIf

dbSelectArea("CTT")
dbSetOrder(1)
If CTT->( dbSeek( xFilial("CTT") + M->D3_CC ) )
	cDesc01 := AllTrim( CTT->CTT_DESC01 )
EndIf

aCabec := {}
aAdd( aCabec, {{'<B><Font Size=4 color=white>Dados da Movimentação Interna</Font></B>', '6', 100, 6, 'C'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Evento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>Movimentação Interna</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Documento</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( M->D3_DOC ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Tipo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( M->D3_TM ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Texto</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cTexto ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Centro de Custo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( M->D3_CC ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Descrição</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cDesc01 ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Usuário</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cUserName ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Rotina</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + FunName() + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Filial</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( SM0->M0_CODFIL ) + ' - ' + AllTrim( SM0->M0_FILIAL ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Empresa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( SM0->M0_CODIGO ) + ' - ' + AllTrim( SM0->M0_NOME ) + '</Font>', '1', 40, 2, 'L'}})
aAdd( aCabec, {{'<B><Font Size=2 color=black>Motivo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cMotivo ) + '</Font>', '1', 90, 5, 'L'}})

aAdd( aCabec, {{'<B><Font Size=4 color=white>Itens</Font></B>', '6', 100, 6, 'C'}})

aColunas := {}
aAdd( aColunas, {'Código'					, 12	, 'C'})
aAdd( aColunas, {'Local'					, 05	, 'C'})
aAdd( aColunas, {'Lote'						, 12	, 'C'})
aAdd( aColunas, {'U.M.'						, 05	, 'C'})
aAdd( aColunas, {'Quantidade'				, 10	, 'C'})
aAdd( aColunas, {'Seg. U.M.'				, 05	, 'C'})
aAdd( aColunas, {'Qtde. Seg. UM'			, 10	, 'C'})
aAdd( aColunas, {'Validade'					, 05	, 'C'})
aAdd( aColunas, {'Conta'					, 10	, 'C'})

cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

aColunas := {}

aAdd( aColunas, {AllTrim(M->D3_COD)											, 12	, 'L'})
aAdd( aColunas, {AllTrim(M->D3_LOCAL)  								  		, 05	, 'C'})
aAdd( aColunas, {AllTrim(M->D3_LOTECTL)				  						, 12	, 'L'})
aAdd( aColunas, {AllTrim(M->D3_UM)									  		, 05	, 'C'})
aAdd( aColunas, {Transform(M->D3_QUANT,"@E 999,999,999.99")					, 13	, 'R'})
aAdd( aColunas, {AllTrim(M->D3_SEGUM)										, 05	, 'C'})
aAdd( aColunas, {Transform(M->D3_QTSEGUM,"@E 999,999,999.99")				, 13	, 'R'})
aAdd( aColunas, {DTOC(M->D3_DTVALID)										, 05	, 'C'})
aAdd( aColunas, {AllTrim(M->D3_CONTA)								  		, 10	, 'L'})

//M->D3_BE_MOTI := AllTrim( cMotivo )

cMensagem += U_BeHtmDet( aColunas, .T., .F. )

cMensagem += U_BeHtmRod(.T.)

U_BeSendMail( { cEmailResp, cAssunto, cMensagem} )

Return

Static Function BeAutori()

Local lRet     := .T.
Local cPesq    := ""
Local cTipos   := GetMv( "MV_BE_MITP",, "'PA','MP','PI','ME','EM','RV','BN','SP','PP'" )
Local cLocal   := GetMv( "MV_BE_MILC",, "'XX','  '" )
Local cLocTran := GetMv( "MV_LOCTRAN",, "30" )

dbSelectArea("SB1")
dbSetOrder(1)
If SB1->( dbSeek( xFilial("SB1") + M->D3_COD ) )
	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
		Aviso("MT240TOK / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " Não Permitido Efetuar Movimentacao Interna Mod. 1!",{"Cancela"})
		lRet := .F.
	EndIf
EndIf

If AllTrim( M->D3_LOCAL ) $ cLocal
	Aviso("MT240TOK / Armazem!","Não é permitido efetuar movimentação interna nos armazém " + M->D3_LOCAL + "!",{"Cancela"})
	lRet := .F.
EndIf

If AllTrim( M->D3_LOCAL ) $ cLocTran
	Aviso("MT240TOK / Armazem!","Não é permitido efetuar movimentação interna no armazém de estoque em trânsito!",{"Cancela"})
	lRet := .F.
EndIf

Return lRet