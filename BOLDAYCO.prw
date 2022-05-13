#Include "Totvs.ch"

/*/{Protheus.doc} BOLDAYCO
Programa respons�vel pela impress�o de boletos do Banco DAYCOVAL, grava��o do nosso numero na tabela SE1.
@type function Relatorio
@version 1.0
@author mario.antonaccio
@since 01/04/2022
@param nNum, numeric, Numero do titulo
@param serie, character, serie do titulo
@param cliente, character, codigo do cliente
@param loja, character, loja do cliente
@param nopc, numeric, numero da op��o
@return character, sem retorno
/*/
User Function BOLDAYCO(nNum,serie,cliente,loja,nopc)

	Local cEdit1	 := Space(25)
	Local lChk 		 := .F.
	Local lMark      := .F.
	Local oOk        := LoadBitmap( GetResources(), "LBOK" )
	Local oNo        := LoadBitmap( GetResources(), "LBNO" )
	Local oChk       := Nil
	Local oEdit1
	Local _cAlias := GetNextAlias()

	// Variaveis Private
	Private oDBlDayco
	Private lExec      := .F.
	Private cIndexName := ""
	Private cIndexKey  := ""
	Private cFilter    := ""
	Private Tamanho    := "M"
	Private titulo     := "Impress�o do Boleto [Banco Daycoval] "
	Private cDesc1     := "Programa de impressao de boletos para o banco Daycoval."
	Private cDesc2     := ""
	Private cDesc3     := ""
	Private cString    := "SE1"
	Private wnrel      := "BOLDAYCO"
	Private lEnd       := .F.
	Private cPerg      := "CBR009"
	Private aReturn    := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
	Private nLastKey   := 0
	Private aVetor     := {}


	nOpc:=If(nopc==NIL,0,nOpc)
	/*
Perguntas

De Prefixo		,"C",03,0,"MV_PAR01"
Ate Prefixo		,"C",03,0,"MV_PAR02"
De Numero		,"C",09,0,"MV_PAR03"
Ate Numero		,"C",09,0,"MV_PAR04"
De Parcela		,"C",03,0,"MV_PAR05"
Ate Parcela		,"C",03,0,"MV_PAR06"
De Portador		,"C",03,0,"MV_PAR07"
Ate Portador	,"C",03,0,"MV_PAR08"
De Cliente		,"C",06,0,"MV_PAR09"
Ate Cliente		,"C",06,0,"MV_PAR10"
De Loja			,"C",02,0,"MV_PAR11"
Ate Loja		,"C",02,0,"MV_PAR12"
De Emissao		,"D",08,0,"MV_PAR13"
Ate Emissao		,"D",08,0,"MV_PAR14"
De Vencimento	,"D",08,0,"MV_PAR15"
Ate Vencimento	,"D",08,0,"MV_PAR16"
Do Bordero		,"C",06,0,"MV_PAR17"
Ate Bordero		,"C",06,0,"MV_PAR18"

Somente Visualiza�ao
Codigo			,"C",03,0,"MV_PAR19"
Agencia			,"C",04,0,"MV_PAR20"
Nro. Conta		,"C",10,0,"MV_PAR21"
DV Conta		,"C",01,0,"MV_PAR22"
	*/

	Pergunte (cPerg,.F.)
	SetMVValue(cPerg,"MV_PAR19", "707")
	SetMVValue(cPerg,"MV_PAR20", "0001")
	
	If Substr(cFilAnt,1,2) == "02"
		SetMVValue(cPerg,"MV_PAR21", "739490")
		SetMVValue(cPerg,"MV_PAR22", "1")
	ElseIf Substr(cFilAnt,1,2) == "08"
		SetMVValue(cPerg,"MV_PAR21", "739387")
		SetMVValue(cPerg,"MV_PAR22", "5")
	End

	Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

	If nLastKey == 27
		Set Filter to
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Set Filter to
		Return
	Endif

	//Query de filtragem
	BeginSql alias _cAlias
		column E1_EMISSAO as Date
		column E1_VENCTO as Date
		SELECT
			SE1.E1_PREFIXO,
			SE1.E1_NUM,
			SE1.E1_PARCELA,
			SE1.E1_CLIENTE,
			SE1.E1_LOJA,
			SE1.E1_TIPO,
			SE1.E1_SALDO,
			SE1.E1_VENCREA,
			SE1.R_E_C_N_O_ AS REGSE1
		FROM
			%table:SE1% SE1
		INNER JOIN %Table:SA1% SA1
		ON SE1.E1_CLIENTE = SA1.A1_COD
			AND SE1.E1_LOJA = SA1.A1_LOJA
			AND SE1.E1_FILIAL = SA1.A1_FILIAL
			AND SA1.A1_BCO1 <> ' '
			AND SA1.%NotDel%
		WHERE
			SE1.E1_FILIAL = %Exp:xfilial("SE1")%
			AND SE1.E1_PREFIXO >= %Exp:MV_PAR01%
			AND SE1.E1_PREFIXO <= %Exp:MV_PAR02%
			AND SE1.E1_NUM >= %Exp:mv_par03%
			AND SE1.E1_NUM <= %Exp:mv_par04%
			AND SE1.E1_PARCELA >= %Exp:MV_PAR05%
			AND SE1.E1_PARCELA <= %Exp:MV_PAR06%
			AND SE1.E1_PORTADO >= %Exp:MV_PAR07%
			AND SE1.E1_PORTADO <= %Exp:MV_PAR08%
			AND SE1.E1_CLIENTE >= %Exp:MV_PAR09%
			AND SE1.E1_CLIENTE <= %Exp:MV_PAR10%
			AND SE1.E1_LOJA >= %Exp:MV_PAR11%
			AND SE1.E1_LOJA <= %Exp:MV_PAR12%
			AND SE1.E1_EMISSAO >= %Exp:DTOS(mv_par13)%
			AND SE1.E1_EMISSAO <= %Exp:DTOS(mv_par14)%
			AND SE1.E1_VENCREA >= %Exp:DTOS(mv_par15)%
			AND SE1.E1_VENCREA <= %Exp:DTOS(mv_par16)%
			AND SE1.E1_NUMBOR >= %Exp:MV_PAR17%
			AND SE1.E1_NUMBOR <= %Exp:MV_PAR18%
			AND SE1.E1_SALDO > 0
			AND SE1.E1_EMISSAO <> SE1.E1_VENCTO //  RETIRADO OS TITULOS A VISTA -MAA 20210827
			AND SE1.E1_NUMBCO = ' '
			AND SE1.%notDel%
		ORDER BY
			SE1.E1_PREFIXO,
			SE1.E1_NUM,
			SE1.E1_PARCELA,
			SE1.E1_CLIENTE,
			SE1.E1_LOJA
	EndSql

	aQuery:=GetLastQuery()

	(_cAlias)->(DbGoTop())

	While(!(_cAlias)->(EoF()))

		aAdd( aVetor, { lMark,;
			ALLTRIM(Posicione("SA1",1,xFilial("SA1")+(_cALias)->(E1_CLIENTE+E1_LOJA),"A1_NOME")),;
			(_cALias)->E1_PREFIXO,;
			(_cALias)->E1_NUM,;
			(_cALias)->E1_PARCELA,;
			(_cALias)->E1_TIPO,;
			(_cALias)->E1_SALDO,;
			(_cALias)->E1_VENCREA,;
			(_cALias)->REGSE1} )

		(_cALias)->( dbSkip() )
	EndDo

	(_cALias)->(dbCloseArea())

	//� Verifica se existem titulos para impressao.                  �
	If Len( aVetor ) == 0
		ApMsgInfo("N�o existe t�tulos para impress�o de boletos.","Aten��o")
		Return
	Endif

	//� Chamada da Janela de selecao dos titulos para impressao      �
	Define MsDialog oDBlDayco Title "Emiss�o de Boletos [Banco Daycoval]" From C(225),C(407) To C(657),C(1061) Pixel

	@ C(049),C(005) TO C(190),C(325) LABEL " T�tulos Selecionados " Pixel Of oDBlDayco
	@ C(059),C(010) ListBox oLbx Var cVar Fields HEADER " ",;
		"Raz�o Social",;
		"Prefixo",;
		"Numero",;
		"Parc",;
		"Tipo",;
		"Valor",;
		"Vencimento",;
		"No.Registro" Size C(312),C(123) Of oDBlDayco Pixel ;
		On dblClick( Inverter(oLbx:nAt),oLbx:Refresh(.F.) )

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		aVetor[oLbx:nAt,4],;
		aVetor[oLbx:nAt,5],;
		aVetor[oLbx:nAt,6],;
		aVetor[oLbx:nAt,7],;
		aVetor[oLbx:nAt,8],;
		aVetor[oLbx:nAt,9]}}

	@ C(200),C(037) MsGet oEdit1 Var cEdit1 Size C(085),C(009) COLOR CLR_BLACK Pixel Of oDBlDayco
	@ C(200),C(227) Button "&Confirma"      Size C(037),C(012) Pixel Of oDBlDayco Action(MontaRel(),oDBlDayco:End())
	@ C(200),C(274) Button "&Sair"          Size C(037),C(012) Pixel Of oDBlDayco Action(oDBlDayco:End())
	@ C(201),C(008) Say "Pesquisar"         Size C(025),C(008) COLOR CLR_BLACK Pixel OF oDBlDayco
	@ C(201),C(148) CheckBox oChk Var lChk Prompt "Marca/Desmarca" Size C(057),C(008) Pixel Of oDBlDayco;
		On CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

	Activate MsDialog oDBlDayco Centered

Return Nil

/*/{Protheus.doc} MontaRel
Montagem e Impressao de boleto Grafico do Banco Daycoval.
@type function Relatorio
@version  1.00
@author S/A - alterado por mario.antonaccio
@since 02/02/09 - alterado em 09/09/2021
@return Character, Nulo
/*/
Static Function MontaRel()

	Local oPrint
	Local n := 0
	Local aBitmap      := ""
	Local i            := 1
	Local CB_RN_NN     := {}
	//Local nRec         := 0
	Local cParcela	   := ""
	Local aDadosTit
	Local aDadosBanco
	Local aDatSacado
	Local iT

	Private _nVlrAbat  := 0
	Private cAgDayco    := MV_PAR20
	Private cCntDayco  := mv_par21
	Private cDVDayco    :=mv_par22


	aDadosEmp := {	AllTrim(SM0->M0_NOMECOM),;													//[1]Nome da Empresa
		AllTrim(SM0->M0_ENDCOB),;													//[2]Endere�o
		AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB,; //[3]Complemento
		"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Substr(SM0->M0_CEPCOB,6,3),;			//[4]CEP
		"PABX/FAX: "+SM0->M0_TEL,; 													//[5]Telefones
		"CNPJ: " + '07.122.447/0001-82',;                                 			//[5]CNPJ
		"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Substr(SM0->M0_INSC,4,3)+"."+;			//[6]I.E
		Substr(SM0->M0_INSC,7,3)+"."+Substr(SM0->M0_INSC,10,3)}						//[6]I.E

	aBolText  := {"Ap�s o vencimento cobrar multa de R$ ",;
		"Mora Diaria de R$ ",;
		"Sujeito a Protesto ap�s 05 (cinco) dias do vencimento."}

	oPrint:=TMSPrinter():New( "Emiss�o de Boletos [Banco Daycoval]" )
	oPrint:SetPortrait()
	oPrint:StartPage()

	For it:= 1 To Len( aVetor )

		If !aVetor[it][1]
			Loop
		EndIf

		SE1->(dbSetOrder(1))
		SE1->(dbSeek(xFilial("SE1")+aVetor[it][3]+aVetor[it][4]+aVetor[it][5]+aVetor[it][6]))

		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA))

		Do Case
			Case aVetor[it][5]  == "A"
				cParcela := "10"
			Case aVetor[it][5]  == "B"
				cParcela := "11"
			Case aVetor[it][5]  == "C"
				cParcela := "12"
			Case aVetor[it][5]  == "D"
				cParcela := "13"
			Case aVetor[it][5]  == "E"
				cParcela := "14"
			Case aVetor[it][5]  == "F"
				cParcela := "15"
			Case aVetor[it][5]  == "G"
				cParcela := "16"
			Case aVetor[it][5]  == "H"
				cParcela := "17"
			Case aVetor[it][5]  == "I"
				cParcela := "18"
			Case Empty(aVetor[it][5])
				cParcela := "0"
			OtherWise
				cParcela := aVetor[it][5]
		EndCase

		_cFilNum := cFilAnt

		//Composicao do nosso numero ( Filial + Titulo + Parcela )
		If !IsNumeric(cParcela)
			Do Case
				Case AllTrim(cParcela) == "A"
					cParcela := "0"
				Case AllTrim(cParcela) == "B"
					cParcela := "1"
				Case AllTrim(cParcela) == "C"
					cParcela := "2"
				Case AllTrim(cParcela) == "D"
					cParcela := "3"
				Case AllTrim(cParcela) == "E"
					cParcela := "4"
				Case AllTrim(cParcela) == "F"
					cParcela := "5"
				Case AllTrim(cParcela) == "G"
					cParcela := "6"
				Case AllTrim(cParcela) == "H"
					cParcela := "7"
				Case AllTrim(cParcela) == "I"
					cParcela := "8"
				Case AllTrim(cParcela) == "J"
					cParcela := "9"
			EndCase
		EndIf

		_cNossoNum := Right(_cFilNum, 2) + Substr((StrZero(Val(Alltrim(aVetor[it][4])),6)),2,5) + cParcela

		//Posiciona tabela de clientes

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.f.))

		aDadosBanco  := {"707-2",;			// [1]Numero do Banco
			"Banco Daycoval ",;// [2]Nome do Banco
			cAgDayco,;			// [3]Ag�ncia
			cCntDayco,;			// [4]Conta Corrente
			cDVDayco,;			// [5]D�gito da conta corrente
			"   ",;			// [6]Codigo da Carteira
			"  "}				// [7]???

		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME),;								// [1]Raz�o Social
				AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;				// [2]C�digo
				AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO),;		// [3]Endere�o
				AllTrim(SA1->A1_MUN),;									// [4]Cidade
				AllTrim(SA1->A1_EST),;									// [5]Estado
				Transform(SA1->A1_CEP,"@R 99999-999"),;				// [6]CEP
				SA2->A2_CGC,;											// [7]CGC
				SA2->A2_TIPO}											// [8]Tipo
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME),;								// [1]Raz�o Social
				AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA,;				// [2]C�digo
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	// [3]Endere�o
				AllTrim(SA1->A1_MUNC),;								// [4]Cidade
				SA1->A1_ESTC,;											// [5]Estado
				Transform(SA1->A1_CEPC,"@R 99999-999"),;				// [6]CEP
				SA1->A1_CGC,;											// [7]CGC
				SA1->A1_TIPO}											// [8]Tipo
		Endif

		//Verifica se o titulo possui valores de abatimento
		_nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

		//Montagem do codigo de barras
		CB_RN_NN := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],AllTrim(_cNossoNum),IIf(SE1->E1_SALDO == SE1->E1_VLCRUZ,(SE1->E1_SALDO-_nVlrAbat),(SE1->E1_VLCRUZ-_nVlrAbat)),SE1->E1_VENCREA)

		//Monta array com informacoes do titulo para impressao do boleto
		aDadosTit := {AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),;				 // [01] N�mero do t�tulo
			SE1->E1_EMISSAO,;												 // [02] Data da emiss�o do t�tulo
			dDataBase,;													 // [03] Data da emiss�o do boleto
			SE1->E1_VENCREA,;  // [04] Data do vencimento
			IIf(SE1->E1_SALDO == SE1->E1_VLCRUZ,(SE1->E1_SALDO-_nVlrAbat),(SE1->E1_VLCRUZ-_nVlrAbat)),; // [05] Valor para recebimento
			CB_RN_NN[3],;					// [06] Nosso n�mero (Ver f�rmula para calculo)
			SE1->E1_PREFIXO,;				// [07] Prefixo da NF
			SE1->E1_TIPO,;				// [08] Tipo do Titulo
			SE1->E1_VLCRUZ-_nVlrAbat,;	// [09] Valor com Juros e Multa
			SE1->E1_ACRESC,;				// [10] Juros e Multa
			SE1->E1_SALDO,;				// [11] Saldo
			DATAVALIDA(SE1->E1_VENCTO),;	// [12] Vencimento real
			_nVlrAbat}					// [13] Abatimento

		//Impressao do boleto bancario
		Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

		n := n + 1
		IncProc()
		i := i + 1

	Next it

	oPrint:EndPage()     // Finaliza a p�gina
	oPrint:Preview()     // Visualiza antes de imprimir

	If aReturn[5]==1
		dbCommitAll()
	Endif

	MS_FLUSH()

Return

/*/{Protheus.doc} Impress
Impressao de boleto Grafico do Banco Daycoval.
@type function Relatorio
@version  1.00
@author S/A - Alterado por mario.antonaccio
@since 02/02/09 - alterado em 09/09/2021
@param oPrint, object, Objeto de impressao
@param aBitmap, array, Array cpm os Bitmaps
@param aDadosEmp, array, Array com os dados da empresa
@param aDadosTit, array, Array com os dados dos titulos
@param aDadosBanco, array, Array com dados deo banco
@param aDatSacado, array, Array com  dados do sacadon
@param aBolText, array, Array com dados de mensagens
@param CB_RN_NN, Array, Array com Codigo de Barras, Linha Digitavel e Nosso Nuemro
@return Character,  sem retorno
/*/
Static Function Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

	Local nTxJuros :=( GETMV("MV_@CMY001",.T.,6) / 30) // Taxa de juros aplicada por dia de atraso. Percentual / por 30
	Local oFont2n
	Local oFont08
	Local oFont09
	Local oFont10
	Local oFont15n
	Local oFont16
	Local oFont16n
	Local oFont14n
	Local oFont11n
	Local oFont24
	Local oBrush
	//Local nI        := 0
	Local I        := 0
	Local sDtaDoc  := DTOS(aDadosTit[2])
	Local sDtaPro  := DTOS(aDadosTit[3])
	Local sDtaVen  := DTOS(aDadosTit[4])
	Local aBmpLog	:=" "
	//Local _cNomLogo	:=" "

	sDtaDoc := Substr(sDtaDoc,7,2)+"/"+Substr(sDtaDoc,5,2)+"/"+Substr(sDtaDoc,1,4)
	sDtaPro := Substr(sDtaPro,7,2)+"/"+Substr(sDtaPro,5,2)+"/"+Substr(sDtaPro,1,4)
	sDtaVen := Substr(sDtaVen,7,2)+"/"+Substr(sDtaVen,5,2)+"/"+Substr(sDtaVen,1,4)

	aBmp2 := "\SYSTEM\Daycoval_Bol.png"


	oFont08  := TFont():New("Arial"          , 9, 8 , .T., .F., 5, .T., 5, .T., .F.)
	oFont09  := TFont():New("Arial"          , 9, 9 , .T., .F., 5, .T., 5, .T., .F.)
	oFont09c := TFont():New("Courier New"    , 9, 10, .T., .T., 5, .T., 5, .T., .F.)
	oFont10  := TFont():New("Arial"          , 9, 9 , .T., .T., 5, .T., 5, .T., .F.)
	oFont11n := TFont():New("Courier New"    , , 11,    , .T.)
	oFont14n := TFont():New("Arial"          , 9, 14, .T., .F., 5, .T., 5, .T., .F.)
	oFont15n := TFont():New("Arial"          , 9, 15, .T., .T., 5, .T., 5, .T., .F.)
	oFont16  := TFont():New("Arial"          , 9, 16, .T., .T., 5, .T., 5, .T., .F.)
	oFont16n := TFont():New("Arial"          , 9, 16, .T., .T., 5, .T., 5, .T., .F.)
	oFont20  := TFont():New("Arial"          , 9, 14, .T., .F., 5, .T., 5, .T., .F.)
	oFont22  := TFont():New("Arial"          , 9, 21, .T., .T., 5, .T., 5, .T., .F.)
	oFont24  := TFont():New("Arial"          , 9, 24, .T., .T., 5, .T., 5, .T., .F.)
	oFont2n  := TFont():New("Times New Roman",  , 10,    , .T.,  ,    ,  ,    , .F.)
	oFont8   := TFont():New("Arial"          , 9, 8 , .T., .F., 5, .T., 5, .T., .F.)
	oBrush := TBrush():New("",CLR_HGRAY)

	oPrint:StartPage()

	If FWCodEmp() == '08'
		aBmpLog := "\SYSTEM\lgmid01.png"
		cTexto := "http://www.qualyvinil.com.br"
	EndIf

	If FWCodEmp() == '02'
		aBmpLog := "\SYSTEM\lgmid02.png"
		cTexto := "http://euroamerican.com.br"
	EndIf

	//� Logotipo                                                     �
	If File(aBmpLog)
		oPrint:SayBitmap( 0120,0118,aBmpLog,430,430 )
		oPrint:Say  (283,565,cTexto,oFont15n )	// [2]site empresa
	EndIf
	//� Corpo do Boleto                                              �
	//oPrint:Say  (0084,1860,"Comprovante de Entrega"	,oFont10)
	//oPrint:Line (0160,415,0150,2300)
	oPrint:Say  (0135,565 ,"Benefici�rio",oFont10)
	oPrint:Line (0175,565,0175,2295 )
	oPrint:Say  (0230,565 ,aDadosEmp[1],oFont15n)

	oPrint:Say  (0360,0570,"Telefone de Cobran�a",oFont10)
	oPrint:Say  (0360,0908,"(011) 4619-8417",oFont10)
	//cima/fim/baixo
	oPrint:Box( 0100,2295,0560,0108 )

	For i := 100 to 2300 step 50
		oPrint:Line( 0590, i, 0590, i+30)
	Next i

	oPrint:Line (0710,100,0710,2300)
	oPrint:Line (0710,550,0610, 550)
	oPrint:Line (0710,800,0610, 800)

	//� Logotipo                                                     �
	If File(aBmp2)
		oPrint:SayBitmap( 0600,0100,aBmp2,0100,0100 )
		oPrint:Say  (0640,240,"Banco Daycoval",oFont10 )
	Else
		oPrint:Say  (0644,100,aDadosBanco[2],oFont15n )
	EndIf

	oPrint:Say  (0618,569,aDadosBanco[1],oFont22 )
	oPrint:Say  (0644,820,CB_RN_NN[2],oFont14n)

	oPrint:Line (0810,0100,0810,2300)
	oPrint:Line (0910,0100,0910,2300)
	oPrint:Line (0980,0100,0980,2300)
	oPrint:Line (1050,0100,1050,2300)

	oPrint:Line (0910,0500,1050,0500)
	oPrint:Line (0980,0750,1050,0750)
	oPrint:Line (0910,1000,1050,1000)
	oPrint:Line (0910,1350,0980,1350)
	oPrint:Line (0910,1550,1050,1550)

	oPrint:Say  (0710,100 ,"Local de Pagamento"                    		,oFont08)
	oPrint:Say  (0730,400 ,"PAGAVEL EM QUALQUER REDE BANC�RIA,"			,oFont09)
	oPrint:Say  (0770,400 ,"MESMO AP�S VENCIMENTO."						,oFont09)

	oPrint:Say  (0710,1910,"Vencimento"												,oFont08)
	oPrint:Say  (0750,2010,sDtaVen													,oFont10) // Data de Vencimento

	oPrint:Say  (0810,100 ,"Benefici�rio"                                        		,oFont08)
	oPrint:Say  (0850,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]							,oFont10)

	oPrint:Say  (0810,1910,"Ag�ncia/C�digo Benefici�rio"                         		,oFont08)
	oPrint:Say  (0850,2010,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]	,oFont10)

	oPrint:Say  (0910,100 ,"Data do Documento"                              		,oFont08)
	oPrint:Say  (0940,100 ,sDtaDoc ,oFont10) // Data impressao

	oPrint:Say  (0910,505 ,"Nro.Documento"                                  		,oFont08)
	oPrint:Say  (0940,605 ,(alltrim(aDadosTit[7]))+aDadosTit[1]					,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (0910,1005,"Esp�cie Doc."                                   		,oFont08)
	oPrint:Say  (0940,1050,"DM"     												,oFont10) //Tipo do Titulo

	oPrint:Say  (0910,1355,"Aceite"                                         		,oFont08)
	oPrint:Say  (0940,1455,"N"                                             			,oFont10)

	oPrint:Say  (0910,1555,"Data do Processamento"                          		,oFont08)
	oPrint:Say  (0940,1655,sDtaPro ,oFont10) // Data impressao

	oPrint:Say  (0910,1910,"Nosso N�mero"                                   		,oFont08)
	//oPrint:Say  (0940,2010,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4)	,oFont10)
	oPrint:Say  (0940,2010,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)	,oFont10)

	oPrint:Say  (0980,100 ,"Uso do Banco"                                   		,oFont08)

	oPrint:Say  (0980,505 ,"Carteira"                                       		,oFont08)
	oPrint:Say  (1010,555 ,aDadosBanco[6]                                  			,oFont10)

	oPrint:Say  (0980,755 ,"Esp�cie"                                        		,oFont08)
	oPrint:Say  (1010,805 ,"R$"                                             		,oFont10)

	oPrint:Say  (0980,1005,"Quantidade"                                     		,oFont08)
	oPrint:Say  (0980,1555,"Valor"                                          		,oFont08)

	oPrint:Say  (0980,1910,"Valor do Documento"                          			,oFont08)

	cString := Alltrim(Transform(aDadosTit[11],"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (1010,nCol,cString ,oFont09c)

	oPrint:Say  (1050,100 ,"Instru��es de responsabilidade do BENEFICI�RIO.Qualquer d�vida sobre boleto contate o BENEFICI�RIO",oFont08)
	//oPrint:Say  (1110,100 ,"Juros/mora ao dia: R$ "+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont10)
	oPrint:Say  (1090,100 ,"AP�S O VENCIMENTO COBRAR MORO DE R$......."+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont08)
	oPrint:Say  (1130,100 ,"PROTESTAR AP�S 05 DIAS CORRIGIDOS DO VENCIMENTO",oFont08)
	oPrint:Say  (1170,100 ,"COBRAN�A ESCRITURAL.",oFont08)
	//oPrint:Say  (1210,100 ,"CREDITO DADO EM GARANTIA AO BANCO ITA� S.A. PAGAR SOMENTE EM BANCO",oFont08)
	//oPrint:Say  (1190,100 ,aBolText[3],oFont10)

	oPrint:Say  (1250,100 ,"Benefici�rio:",oFont10)
	oPrint:Say  (1290,100 ,aDadosEmp[1]  + ' - ' + aDadosEmp[6] ,oFont08)
	oPrint:Say  (1330,100 ,aDadosEmp[2]  + ' - ' + aDadosEmp[3] + ' - ' + aDadosEmp[4] ,oFont08)

	oPrint:Say  (1050,1910,"(+)Outros Acr�scimos"          ,oFont08)

	If _nVlrAbat == 0
		oPrint:Say  (1120,1910,"(-)Desconto/Abatimento:"    ,oFont08)
	Else
		oPrint:Say  (1120,1910,"(-)Desconto/Abatimento:"    ,oFont08)
		cString := Alltrim(Transform(_nVlrAbat,"@E 99,999,999.99"))
		nCol := 1900+(374-(len(cString)*22))
		oPrint:Say  (1150,nCol,cString ,oFont09c)
	EndIf

	oPrint:Say  (1190,1910,"(-)Outras Dedu��es"                ,oFont08)

	If aDadosTit[10]<> 0
		oPrint:Say  (1260,1910,"(+) Mora/Multa:"               ,oFont08)
		cString := Alltrim(Transform(aDadosTit[10],"@E 99,999,999.99"))
		nCol := 1900+(374-(len(cString)*22))
		oPrint:Say  (1290,nCol,cString ,oFont09c)

		oPrint:Say  (1330,1910,"(=) Valor Cobrado:"            ,oFont08)

		cString := Alltrim(Transform(aDadosTit[9],"@E 99,999,999.99"))
		nCol := 1900+(374-(len(cString)*22))
		oPrint:Say  (1360,nCol,cString ,oFont09c)
	Else
		oPrint:Say  (1260,1910,"(+)Mora/Multa" 		                          ,oFont08)
		oPrint:Say  (1330,1910,"(=)Valor Cobrado"                             ,oFont08)
	EndIf

	oPrint:Say  (1400,100 ,"Pagador"                                         ,oFont08)
	oPrint:Say  (1430,200 ,aDatSacado[1]+" ("+aDatSacado[2]+") - "+"C.N.P.J: "+Transform(aDatSacado[7],"@R 99.999.999/9999-99")             ,oFont10)
	oPrint:Say  (1470,200 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (1520,200 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
	oPrint:Say  (1589,1850,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4,8)+Substr(aDadosTit[6],13,1)  ,oFont10)

	oPrint:Say  (1605,100 ,"Sacador/Avalista"								,oFont08)
	oPrint:Say  (1645,1500,"Autentica��o Mec�nica" ,oFont08)
	oPrint:Say  (1645,1900,"Recibo do Pagador"	   ,oFont10)

	oPrint:Line (0710,1900,1400,1900 )
	oPrint:Line (1120,1900,1120,2300 )
	oPrint:Line (1190,1900,1190,2300 )
	oPrint:Line (1260,1900,1260,2300 )
	oPrint:Line (1330,1900,1330,2300 )
	oPrint:Line (1400,100 ,1400,2300 )
	oPrint:Line (1640,100 ,1640,2300 )

	For i := 100 to 2300 step 50
		oPrint:Line( 1930, i, 1930, i+30)                 // 1850
	Next i

	oPrint:Line (2080,100,2080,2300)                                                       //   2000
	oPrint:Line (2080,550,1980, 550)                                                       //   2000 - 1900
	oPrint:Line (2080,800,1980, 800)                                                       //    2000 - 1900

	// LOGOTIPO
	If File(aBmp2)
		oPrint:SayBitmap( 1970,0100,aBmp2,0100,0100 )
		oPrint:Say  (2010,240,"Banco Daycoval",oFont10 )			// [2]Nome do Banco
	Else
		oPrint:Say  (2014,100,aDadosBanco[2],oFont15n )		// [2]Nome do Banco                     1934
	EndIf

	oPrint:Say  (1988,569,"707-2",oFont22 )						// [1]Numero do Banco                       1912
	oPrint:Say  (2014,820,CB_RN_NN[2],oFont14n)	   			//Linha Digitavel do Codigo de Barras   1934

	oPrint:Line (2180,100,2180,2300 )
	oPrint:Line (2280,100,2280,2300 )
	oPrint:Line (2350,100,2350,2300 )
	oPrint:Line (2420,100,2420,2300 )

	oPrint:Line (2280, 500,2420,500)
	oPrint:Line (2350, 750,2420,750)
	oPrint:Line (2280,1000,2420,1000)
	oPrint:Line (2280,1350,2350,1350)
	oPrint:Line (2280,1550,2420,1550)

	oPrint:Say  (2080,100 ,"Local de Pagamento"                             ,oFont08)
	oPrint:Say  (2140,400 ,"PAGAVEL EM QUALQUER REDE BANC�RIA, MESMO AP�S VENCIMENTO"  ,oFont09)

	oPrint:Say  (2080,1910,"Vencimento"                                     ,oFont08)
	oPrint:Say  (2120,2010,sDtaVen	 		                               ,oFont10)

	oPrint:Say  (2180,100 ,"Benefici�rio"                                        ,oFont08)
	oPrint:Say  (2220,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

	oPrint:Say  (2180,1910,"Ag�ncia/C�digo Benefici�rio"                         ,oFont08)
	oPrint:Say  (2220,2010,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)

	oPrint:Say  (2280,100 ,"Data do Documento"                              ,oFont08)
	oPrint:Say  (2310,100 ,sDtaDoc                               ,oFont10) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (2280,505 ,"Nro.Documento"                                  ,oFont08)
	oPrint:Say  (2310,605 ,(alltrim(aDadosTit[7]))+aDadosTit[1]			,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (2280,1005,"Esp�cie Doc."                                   ,oFont08)
	oPrint:Say  (2310,1050,"DM"  										,oFont10) //Tipo do Titulo

	oPrint:Say  (2280,1355,"Aceite"                                         ,oFont08)  // 2200
	oPrint:Say  (2310,1455,"N"                                             ,oFont10)  // 2230

	oPrint:Say  (2280,1555,"Data do Processamento"                          ,oFont08)       // 2200
	oPrint:Say  (2310,1655,sDtaPro 			                              ,oFont10) // Data impressao  2230

	oPrint:Say  (2280,1910,"Nosso N�mero"                                   ,oFont08)       // 2200
	//oPrint:Say  (2310,2010,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4),oFont10)  // 2230
	oPrint:Say  (2310,2010,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4),oFont10)  // 2230

	oPrint:Say  (2350,100 ,"Uso do Banco"                                   ,oFont08)       // 2270

	oPrint:Say  (2350,505 ,"Carteira"                                       ,oFont08)       // 2270
	oPrint:Say  (2380,555 ,aDadosBanco[6]                                  	,oFont10)      //  2300

	oPrint:Say  (2350,755 ,"Esp�cie"                                        ,oFont08)       //  2270
	oPrint:Say  (2380,805 ,"R$"                                             ,oFont10)      //  2300

	oPrint:Say  (2350,1005,"Quantidade"                                     ,oFont08)       //  2270
	oPrint:Say  (2350,1555,"Valor"                                          ,oFont08)       //  2270

	oPrint:Say  (2350,1910,"Valor do Documento"                          	,oFont08)        //  2270
	cString := Alltrim(Transform(aDadosTit[11],"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (2380,nCol,cString ,oFont09c)

	oPrint:Say  (2420,100 ,"Instru��es (Todas informa��es deste bloqueto s�o de exclusiva responsabilidade do Benefici�rio)",oFont08) // 2340
	//oPrint:Say  (2520,100 ,"Juros/mora ao dia: R$ "+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont10)
	oPrint:Say  (2465,100 ,"AP�S O VENCIMENTO COBRAR MORO DE R$....... "+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont08)
	oPrint:Say  (2505,100 ,"PROTESTAR AP�S 05 DIAS CORRIGIDOS DO VENCIMENTO",oFont08)
	oPrint:Say  (2557,100 ,"COBRAN�A ESCRITURAL.",oFont08)


	//oPrint:Say  (2620,100 ,aBolText[3],oFont10)

	oPrint:Say  (2420,1910,"(+)Outros Acr�scimos"          ,oFont08)

	If _nVlrAbat == 0
		oPrint:Say  (2490,1910,"(-)Desconto/Abatimento:"    ,oFont08)
	Else
		oPrint:Say  (2490,1910,"(-)Desconto/Abatimento:"    ,oFont08)
		cString := Alltrim(Transform(_nVlrAbat,"@E 99,999,999.99"))
		nCol := 1900+(374-(len(cString)*22))
		oPrint:Say  (2520,nCol,cString ,oFont09c)
	EndIf

	oPrint:Say  (2560,1910,"(-)Outras Dedu��es"                ,oFont08)

	If aDadosTit[10]<> 0
		oPrint:Say  (2630,1910,"(+) Mora/Multa:"               ,oFont08)
		cString := Alltrim(Transform(aDadosTit[10],"@E 99,999,999.99"))
		nCol := 1900+(374-(len(cString)*22))
		oPrint:Say  (2660,nCol,cString ,oFont09c)

		oPrint:Say  (2700,1910,"(=) Valor Cobrado:"            ,oFont08)

		cString := Alltrim(Transform(aDadosTit[9],"@E 99,999,999.99"))
		nCol := 1900+(374-(len(cString)*22))
		oPrint:Say  (2730,nCol,cString ,oFont09c)
	Else
		oPrint:Say  (2630,1910,"(+)Mora/Multa" 		           ,oFont08)
		oPrint:Say  (2700,1910,"(=)Valor Cobrado"              ,oFont08)
	EndIf

	oPrint:Say  (2770,100 ,"Pagador"                                         ,oFont08)
	oPrint:Say  (2800,200 ,aDatSacado[1]+" ("+aDatSacado[2]+") - "+"C.N.P.J: "+Transform(aDatSacado[7],"@R 99.999.999/9999-99")             ,oFont10)

	oPrint:Say  (2840,200 ,aDatSacado[3]                                    ,oFont10)       // 2773
	oPrint:Say  (2880,200 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado  2826
	oPrint:Say  (2959,1850,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4,8)+Substr(aDadosTit[6],13,1)  ,oFont10)         //  2879

	oPrint:Say  (2975,100 ,"Pagador/Avalista"                               ,oFont08)
	oPrint:Say  (3015,1500,"Autentica��o Mec�nica - Ficha de Compensa��o",oFont10)
	oPrint:Line (2080,1900,2770,1900 )
	oPrint:Line (2490,1900,2490,2300 )
	oPrint:Line (2560,1900,2560,2300 )
	oPrint:Line (2630,1900,2630,2300 )
	oPrint:Line (2700,1900,2700,2300 )
	oPrint:Line (2770,100 ,2770,2300 )
	oPrint:Line (3010,100 ,3010,2300 )

	MSBAR("INT25",26.2,1,CB_RN_NN[1],oPrint,.F.,Nil,Nil,0.0250,1.5,Nil,Nil,"A",.F.)
	//MSBAR("INT25",27.2,1,CB_RN_NN[1],oPrint,.F.,Nil,Nil,0.0250,1.5,Nil,Nil,"A",.F.),oPrint,.F.,,,,1.2,,,,.F.)

	CB_RN_NN := {}

	SE1->(dbSetOrder(1))
	If SE1->(dbSeek(xFilial('SE1') + aDadosTit[7] + aDadosTit[1], .F. ))
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO := Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4,8)+Substr(aDadosTit[6],13,1)   // Nosso n�mero (Ver f�rmula para calculo)
		//SE1->E1_HIST   := "BOLETO BCO Daycoval"
		MsUnlock()
	EndIf

	oPrint:EndPage() // Finaliza a p�gina

Return Nil

/*/{Protheus.doc} Modulo10
Faz a verificacao e geracao do digito verificador no Modulo 10
@type function Processamento
@version  1.0
@author Sem autor -  modificado por mario.antonaccio
@since 02/02/09 - alterado em  09/09/2021
@param cData, character, String para calculo
@return Character, digito calculado
/*/
Static Function Modulo10(cData)

	Local L,D,P := 0
	Local B     := .F.

	L := Len(cData)
	B := .T.
	D := 0

	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End

	D := 10 - (Mod(D,10))

	If D = 10
		D := 0
	End

Return(D)

/*/{Protheus.doc} Modulo11
Faz a verificacao e geracao do digito Verificador no Modulo 11.
@type function Processamento
@version  1.00
@author Sem Autor -  alterado por mario.antonaccio
@since Sem data - alterado em 09/09/2021
@param cData, character, String para calculo do digito
@return Character, digito Calculado
/*/
Static Function Modulo11(cData)

	Local L, D, P := 0

	L := Len(cdata)
	D := 0
	P := 1

	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End

	D := 11 - (mod(D,11))

	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End

Return(D)

/*/{Protheus.doc} Ret_cBarra
Gera a codificacao da Linha digitavel gerando o codigo de barras.
@type function Processamento
@version  1.0
@author sem autor -  alterado por mario.antonaccio
@since sem data - alterado em 09/09/2021
@param cBanco, character, Codigo do Banco
@param cAgencia, character, Codigo da Agencia
@param cConta, character, Numero da Conta Bancaria
@param cDacCC, character, Digito de Contrle da Conta Corrente
@param cNroDoc, character, Numero Documento
@param nValor, numeric, Valor Documento
@param dVencto, date, Data de Vencimento
@return Array, Array Contendo Codigo de Barra, Linha Digitavel e nosso numero
/*/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)

	Local bldocnufinal := strzero(val(cNroDoc),8)
	Local blvalorfinal := strzero(int(nValor*100),10)
	Local dvnn         := 0
	Local dvcb         := 0
	Local dv           := 0
	Local NN           := ''
	Local RN           := ''
	Local CB           := ''
	Local s            := ''
	Local _cfator      := strzero(dVencto - ctod("07/10/97"),4)
	Local _cCart	   := "121" //carteira de cobranca

	//-------- Definicao do NOSSO NUMERO
	s    :=  cAgencia + cConta + _cCart + bldocnufinal
	dvnn := modulo10(s) // digito verifacador Agencia + Conta + Carteira + Nosso Num
	NN   := _cCart + bldocnufinal + '-' + AllTrim(Str(dvnn))

	//	-------- Definicao do CODIGO DE BARRAS
	s    := cBanco + _cfator + blvalorfinal + _cCart + bldocnufinal + AllTrim(Str(dvnn)) + cAgencia + cConta + cDacCC + '000'
	dvcb := modulo11(s)
	CB   := SubStr(s, 1, 4) + AllTrim(Str(dvcb)) + SubStr(s,5)

	//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
	//	Campo 1			Campo 2			Campo 3			Campo 4		Campo 5
	//	AAABC.CCDDX		DDDDD.DEFFFY	FGGGG.GGHHHZ	K			UUUUVVVVVVVVVV
	//
	// 	CAMPO 1:
	//	AAA	= Codigo do banco na Camara de Compensacao
	//	  B = Codigo da moeda, sempre 9
	//	CCC = Codigo da Carteira de Cobranca
	//	 DD = Dois primeiros digitos no nosso numero
	//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	//
	s    := cBanco + _cCart + SubStr(bldocnufinal,1,2)
	dv   := modulo10(s)
	RN   := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + '  '
	//
	// 	CAMPO 2:
	//	DDDDDD = Restante do Nosso Numero
	//	     E = DAC do campo Agencia/Conta/Carteira/Nosso Numero
	//	   FFF = Tres primeiros numeros que identificam a agencia
	//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	//
	s    := SubStr(bldocnufinal, 3, 6) + AllTrim(Str(dvnn)) + SubStr(cAgencia, 1, 3)
	dv   := modulo10(s)
	RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//
	// 	CAMPO 3:
	//	     F = Restante do numero que identifica a agencia
	//	GGGGGG = Numero da Conta + DAC da mesma
	//	   HHH = Zeros (Nao utilizado)
	//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
	s    := SubStr(cAgencia, 4, 1) + cConta + cDacCC + '000'
	dv   := modulo10(s)
	RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
	//
	// 	CAMPO 4:
	//	     K = DAC do Codigo de Barras
	RN   := RN + AllTrim(Str(dvcb)) + '  '
	//
	// 	CAMPO 5:
	//	      UUUU = Fator de Vencimento
	//	VVVVVVVVVV = Valor do Titulo
	RN   := RN + _cfator + StrZero(Int(nValor * 100),14-Len(_cfator))
	//
Return({CB,RN,NN})

/*/{Protheus.doc} Inverter
Inverte selecao conforme clique do usuario.
@type function  Processamento
@version  1.0
@author sem autor - alterado por mario.antonaccio
@since 02/02/2009 - alterado em  09/09/2021
@param nPos, numeric, Posi��o dentro do arrya de titulos
@return character, sem retorno
/*/
Static Function Inverter(nPos)
	aVetor[nPos][1] := !aVetor[nPos][1]
	oLbx:Refresh()
Return

/*/{Protheus.doc} Marca
Marca ou desmarca todos os registros.
@type function Processamento
@version  1.00
@author sem autor - alterado por mario.antonaccio
@since 02/02/2009 - alterado em 09/09/2021
@param lMarca, logical, Indica se o registro esta ou nao marcado
@return character, sem retorno
/*/
Static Function Marca(lMarca)
	Local i := 0

	For i := 1 To Len(aVetor)
		aVetor[i][1] := lMarca
	Next i

	oLbx:Refresh()

Return


/*/{Protheus.doc} C
Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario.

SERA DESATIVADA

@type function Tela
@version  1.0
@author sem autor - alterado por mario.antonaccio
@since 02/02/09 - alterada em  09/09/2021
@param nTam, numeric, Coordernada para ajuste da resolu��o
@return Numeric, coordernada corrigida
/*/
Static Function C(nTam)

	Local nHRes	:=	oMainWnd:nClientWidth			// Resolucao horizontal do monitor
	If nHRes == 640								// Resolucao 640x480 (So o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else										// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//�Tratamento para tema "Flat"                                �
	If "MP8/MP10" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)


/*
//� Corpo do Boleto                                              �
//oPrint:Say  (0084,1860,"Comprovante de Entrega"	,oFont10)
//oPrint:Line (0160,415,0150,2300)
oPrint:Say  (0135,565 ,"Benefici�rio",oFont10)
oPrint:Line (0175,565,0175,2295 )
oPrint:Say  (0230,565 ,aDadosEmp[1],oFont15n)

oPrint:Say  (0360,0570,"Telefone de Cobran�a",oFont10)
oPrint:Say  (0360,0908,"(011) 4619-8417",oFont10)
        //cima/fim/baixo
oPrint:Box( 0100,2295,0560,0108 )

For i := 100 to 2300 step 50
	oPrint:Line( 0590, i, 0590, i+30)
Next i

oPrint:Line (0710,100,0710,2300)
oPrint:Line (0710,550,0610, 550)
oPrint:Line (0710,800,0610, 800)

//� Logotipo                                                     �
If File(aBmp2)
	oPrint:SayBitmap( 0600,0100,aBmp2,0100,0100 )
	oPrint:Say  (0640,240,"Banco Ita� SA",oFont10 )
Else
	oPrint:Say  (0644,100,aDadosBanco[2],oFont15n )
EndIf

oPrint:Say  (0618,569,"341-7",oFont22 )
oPrint:Say  (0644,820,CB_RN_NN[2],oFont14n)

oPrint:Line (0810,0100,0810,2300)
oPrint:Line (0910,0100,0910,2300)
oPrint:Line (0980,0100,0980,2300)
oPrint:Line (1050,0100,1050,2300)

oPrint:Line (0910,0500,1050,0500)
oPrint:Line (0980,0750,1050,0750)
oPrint:Line (0910,1000,1050,1000)
oPrint:Line (0910,1350,0980,1350)
oPrint:Line (0910,1550,1050,1550)

oPrint:Say  (0710,100 ,"Local de Pagamento"                             		,oFont08)
oPrint:Say  (0730,400 ,"At� o vencimento, preferencialmente no Ita�."			,oFont09)
oPrint:Say  (0770,400 ,"N�o receber ap�s o vencimento."			,oFont09)

oPrint:Say  (0710,1910,"Vencimento"												,oFont08)
oPrint:Say  (0750,2010,sDtaVen													,oFont10) // Data de Vencimento

oPrint:Say  (0810,100 ,"Benefici�rio"                                        		,oFont08)
oPrint:Say  (0850,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]							,oFont10)

oPrint:Say  (0810,1910,"Ag�ncia/C�digo Benefici�rio"                         		,oFont08)
oPrint:Say  (0850,2010,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]	,oFont10)

oPrint:Say  (0910,100 ,"Data do Documento"                              		,oFont08)
oPrint:Say  (0940,100 ,sDtaDoc ,oFont10) // Data impressao

oPrint:Say  (0910,505 ,"Nro.Documento"                                  		,oFont08)
oPrint:Say  (0940,605 ,(alltrim(aDadosTit[7]))+aDadosTit[1]					,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (0910,1005,"Esp�cie Doc."                                   		,oFont08)
oPrint:Say  (0940,1050,aDadosTit[8]												,oFont10) //Tipo do Titulo

oPrint:Say  (0910,1355,"Aceite"                                         		,oFont08)
oPrint:Say  (0940,1455,"N"                                             			,oFont10)

oPrint:Say  (0910,1555,"Data do Processamento"                          		,oFont08)
oPrint:Say  (0940,1655,sDtaPro ,oFont10) // Data impressao

oPrint:Say  (0910,1910,"Nosso N�mero"                                   		,oFont08)
//oPrint:Say  (0940,2010,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4)	,oFont10)
oPrint:Say  (0940,2010,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)	,oFont10)

oPrint:Say  (0980,100 ,"Uso do Banco"                                   		,oFont08)

oPrint:Say  (0980,505 ,"Carteira"                                       		,oFont08)
oPrint:Say  (1010,555 ,aDadosBanco[6]                                  			,oFont10)

oPrint:Say  (0980,755 ,"Esp�cie"                                        		,oFont08)
oPrint:Say  (1010,805 ,"R$"                                             		,oFont10)

oPrint:Say  (0980,1005,"Quantidade"                                     		,oFont08)
oPrint:Say  (0980,1555,"Valor"                                          		,oFont08)

oPrint:Say  (0980,1910,"Valor do Documento"                          			,oFont08)

cString := Alltrim(Transform(aDadosTit[11],"@E 99,999,999.99"))
nCol := 1900+(374-(len(cString)*22))
oPrint:Say  (1010,nCol,cString ,oFont09c)

oPrint:Say  (1050,100 ,"Instru��es de responsabilidade do BENEFICI�RIO.Qualquer d�vida sobre boleto contate o BENEFICI�RIO",oFont08)
//oPrint:Say  (1110,100 ,"Juros/mora ao dia: R$ "+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont10)
oPrint:Say  (1090,100 ,"AP�S O VENCIMENTO COBRAR MORO DE R$......."+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont08)
oPrint:Say  (1130,100 ,"PROTESTAR AP�S 05 DIAS CORRIGIDOS DO VENCIMENTO",oFont08)
oPrint:Say  (1170,100 ,"COBRAN�A ESCRITURAL.",oFont08)
//oPrint:Say  (1210,100 ,"CREDITO DADO EM GARANTIA AO BANCO ITA� S.A. PAGAR SOMENTE EM BANCO",oFont08)
//oPrint:Say  (1190,100 ,aBolText[3],oFont10)

oPrint:Say  (1250,100 ,"Benefici�rio:",oFont10)
oPrint:Say  (1290,100 ,aDadosEmp[1]  + ' - ' + aDadosEmp[6] ,oFont08)
oPrint:Say  (1330,100 ,aDadosEmp[2]  + ' - ' + aDadosEmp[3] + ' - ' + aDadosEmp[4] ,oFont08)

oPrint:Say  (1050,1910,"(+)Outros Acr�scimos"          ,oFont08)

If _nVlrAbat == 0
   oPrint:Say  (1120,1910,"(-)Desconto/Abatimento:"    ,oFont08)
Else
	oPrint:Say  (1120,1910,"(-)Desconto/Abatimento:"    ,oFont08)
	cString := Alltrim(Transform(_nVlrAbat,"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (1150,nCol,cString ,oFont09c)
EndIf

oPrint:Say  (1190,1910,"(-)Outras Dedu��es"                ,oFont08)

If aDadosTit[10]<> 0
	oPrint:Say  (1260,1910,"(+) Mora/Multa:"               ,oFont08)
	cString := Alltrim(Transform(aDadosTit[10],"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (1290,nCol,cString ,oFont09c)

	oPrint:Say  (1330,1910,"(=) Valor Cobrado:"            ,oFont08)

	cString := Alltrim(Transform(aDadosTit[9],"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (1360,nCol,cString ,oFont09c)
Else
	oPrint:Say  (1260,1910,"(+)Mora/Multa" 		                          ,oFont08)
	oPrint:Say  (1330,1910,"(=)Valor Cobrado"                             ,oFont08)
EndIf

oPrint:Say  (1400,100 ,"Pagador"                                         ,oFont08)
oPrint:Say  (1430,200 ,aDatSacado[1]+" ("+aDatSacado[2]+") - "+"C.N.P.J: "+Transform(aDatSacado[7],"@R 99.999.999/9999-99")             ,oFont10)
oPrint:Say  (1470,200 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (1520,200 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
oPrint:Say  (1589,1850,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4,8)+Substr(aDadosTit[6],13,1)  ,oFont10)

oPrint:Say  (1605,100 ,"Sacador/Avalista"								,oFont08)
oPrint:Say  (1645,1500,"Autentica��o Mec�nica" ,oFont08)
oPrint:Say  (1645,1900,"Recibo do Pagador"	   ,oFont10)

oPrint:Line (0710,1900,1400,1900 )
oPrint:Line (1120,1900,1120,2300 )
oPrint:Line (1190,1900,1190,2300 )
oPrint:Line (1260,1900,1260,2300 )
oPrint:Line (1330,1900,1330,2300 )
oPrint:Line (1400,100 ,1400,2300 )
oPrint:Line (1640,100 ,1640,2300 )

For i := 100 to 2300 step 50
	oPrint:Line( 1930, i, 1930, i+30)                 // 1850
Next i

oPrint:Line (2080,100,2080,2300)                                                       //   2000
oPrint:Line (2080,550,1980, 550)                                                       //   2000 - 1900
oPrint:Line (2080,800,1980, 800)                                                       //    2000 - 1900

// LOGOTIPO
If File(aBmp2)
	oPrint:SayBitmap( 1970,0100,aBmp2,0100,0100 )
	oPrint:Say  (2010,240,"Banco Ita� SA",oFont10 )			// [2]Nome do Banco
Else
	oPrint:Say  (2014,100,aDadosBanco[2],oFont15n )		// [2]Nome do Banco                     1934
EndIf

oPrint:Say  (1988,569,"341-7",oFont22 )						// [1]Numero do Banco                       1912
oPrint:Say  (2014,820,CB_RN_NN[2],oFont14n)	   			//Linha Digitavel do Codigo de Barras   1934

oPrint:Line (2180,100,2180,2300 )
oPrint:Line (2280,100,2280,2300 )
oPrint:Line (2350,100,2350,2300 )
oPrint:Line (2420,100,2420,2300 )

oPrint:Line (2280, 500,2420,500)
oPrint:Line (2350, 750,2420,750)
oPrint:Line (2280,1000,2420,1000)
oPrint:Line (2280,1350,2350,1350)
oPrint:Line (2280,1550,2420,1550)

oPrint:Say  (2080,100 ,"Local de Pagamento"                             ,oFont08)
oPrint:Say  (2100,400 ,"At� o vencimento, preferencialmente no Ita�."   ,oFont09)
oPrint:Say  (2140,400 ,"N�o receber ap�s o vencimento."  ,oFont09)

oPrint:Say  (2080,1910,"Vencimento"                                     ,oFont08)
oPrint:Say  (2120,2010,sDtaVen	 		                               ,oFont10)

oPrint:Say  (2180,100 ,"Benefici�rio"                                        ,oFont08)
oPrint:Say  (2220,100 ,aDadosEmp[1]+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (2180,1910,"Ag�ncia/C�digo Benefici�rio"                         ,oFont08)
oPrint:Say  (2220,2010,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)

oPrint:Say  (2280,100 ,"Data do Documento"                              ,oFont08)
oPrint:Say  (2310,100 ,sDtaDoc                               ,oFont10) // Emissao do Titulo (E1_EMISSAO)

oPrint:Say  (2280,505 ,"Nro.Documento"                                  ,oFont08)
oPrint:Say  (2310,605 ,(alltrim(aDadosTit[7]))+aDadosTit[1]			,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (2280,1005,"Esp�cie Doc."                                   ,oFont08)
oPrint:Say  (2310,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (2280,1355,"Aceite"                                         ,oFont08)  // 2200
oPrint:Say  (2310,1455,"N"                                             ,oFont10)  // 2230

oPrint:Say  (2280,1555,"Data do Processamento"                          ,oFont08)       // 2200
oPrint:Say  (2310,1655,sDtaPro 			                              ,oFont10) // Data impressao  2230

oPrint:Say  (2280,1910,"Nosso N�mero"                                   ,oFont08)       // 2200
//oPrint:Say  (2310,2010,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4),oFont10)  // 2230
oPrint:Say  (2310,2010,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4),oFont10)  // 2230

oPrint:Say  (2350,100 ,"Uso do Banco"                                   ,oFont08)       // 2270

oPrint:Say  (2350,505 ,"Carteira"                                       ,oFont08)       // 2270
oPrint:Say  (2380,555 ,aDadosBanco[6]                                  	,oFont10)      //  2300

oPrint:Say  (2350,755 ,"Esp�cie"                                        ,oFont08)       //  2270
oPrint:Say  (2380,805 ,"R$"                                             ,oFont10)      //  2300

oPrint:Say  (2350,1005,"Quantidade"                                     ,oFont08)       //  2270
oPrint:Say  (2350,1555,"Valor"                                          ,oFont08)       //  2270

oPrint:Say  (2350,1910,"Valor do Documento"                          	,oFont08)        //  2270
cString := Alltrim(Transform(aDadosTit[11],"@E 99,999,999.99"))
nCol := 1900+(374-(len(cString)*22))
oPrint:Say  (2380,nCol,cString ,oFont09c)

oPrint:Say  (2420,100 ,"Instru��es (Todas informa��es deste bloqueto s�o de exclusiva responsabilidade do Benefici�rio)",oFont08) // 2340
//oPrint:Say  (2520,100 ,"Juros/mora ao dia: R$ "+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont10)
oPrint:Say  (2465,100 ,"AP�S O VENCIMENTO COBRAR MORO DE R$....... "+AllTrim(Transform(((aDadosTit[11]*nTxJuros)/100),"@E 999.99"))+" ap�s "+StrZero(Day(aDadosTit[12]),2) +"/"+ StrZero(Month(aDadosTit[12]),2) +"/"+ Right(Str(Year(aDadosTit[12])),4),oFont08)
oPrint:Say  (2505,100 ,"PROTESTAR AP�S 05 DIAS CORRIGIDOS DO VENCIMENTO",oFont08)
oPrint:Say  (2557,100 ,"COBRAN�A ESCRITURAL.",oFont08)
//oPrint:Say  (2640,100 ,"CREDITO DADO EM GARANTIA AO BANCO ITA� S.A. PAGAR SOMENTE EM BANCO",oFont08)

//oPrint:Say  (2620,100 ,aBolText[3],oFont10)

oPrint:Say  (2420,1910,"(+)Outros Acr�scimos"          ,oFont08)

If _nVlrAbat == 0
   oPrint:Say  (2490,1910,"(-)Desconto/Abatimento:"    ,oFont08)
Else
   oPrint:Say  (2490,1910,"(-)Desconto/Abatimento:"    ,oFont08)
	cString := Alltrim(Transform(_nVlrAbat,"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (2520,nCol,cString ,oFont09c)
EndIf

oPrint:Say  (2560,1910,"(-)Outras Dedu��es"                ,oFont08)

If aDadosTit[10]<> 0
	oPrint:Say  (2630,1910,"(+) Mora/Multa:"               ,oFont08)
	cString := Alltrim(Transform(aDadosTit[10],"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (2660,nCol,cString ,oFont09c)

	oPrint:Say  (2700,1910,"(=) Valor Cobrado:"            ,oFont08)

	cString := Alltrim(Transform(aDadosTit[9],"@E 99,999,999.99"))
	nCol := 1900+(374-(len(cString)*22))
	oPrint:Say  (2730,nCol,cString ,oFont09c)
Else
	oPrint:Say  (2630,1910,"(+)Mora/Multa" 		           ,oFont08)
	oPrint:Say  (2700,1910,"(=)Valor Cobrado"              ,oFont08)
EndIf

oPrint:Say  (2770,100 ,"Pagador"                                         ,oFont08)
oPrint:Say  (2800,200 ,aDatSacado[1]+" ("+aDatSacado[2]+") - "+"C.N.P.J: "+Transform(aDatSacado[7],"@R 99.999.999/9999-99")             ,oFont10)

oPrint:Say  (2840,200 ,aDatSacado[3]                                    ,oFont10)       // 2773
oPrint:Say  (2880,200 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado  2826
oPrint:Say  (2959,1850,Substr(aDadosTit[6],1,3)+"/"+Substr(aDadosTit[6],4,8)+Substr(aDadosTit[6],13,1)  ,oFont10)         //  2879

oPrint:Say  (2975,100 ,"Pagador/Avalista"                               ,oFont08)
oPrint:Say  (3015,1500,"Autentica��o Mec�nica - Ficha de Compensa��o",oFont10)
oPrint:Line (2080,1900,2770,1900 )
oPrint:Line (2490,1900,2490,2300 )
oPrint:Line (2560,1900,2560,2300 )
oPrint:Line (2630,1900,2630,2300 )
oPrint:Line (2700,1900,2700,2300 )
oPrint:Line (2770,100 ,2770,2300 )
oPrint:Line (3010,100 ,3010,2300 )

MSBAR("INT25",26.2,1,CB_RN_NN[1],oPrint,.F.,Nil,Nil,0.0250,1.5,Nil,Nil,"A",.F.)
//MSBAR("INT25",27.2,1,CB_RN_NN[1],oPrint,.F.,Nil,Nil,0.0250,1.5,Nil,Nil,"A",.F.)
*/
