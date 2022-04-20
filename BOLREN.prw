#Include "Totvs.ch"

/*/{Protheus.doc} BOLREN
Programa responsável pela impressão de boletos dos Bancos Bradesco e Rendimentos, gravação do nosso numero na tabela SE1.
@type function Relatorio
@version 1.0
@author mario.antonaccio
@since 29/09/2021
@param nNum, numeric, Numero do titulo
@param serie, character, serie do titulo
@param cliente, character, codigo do cliente
@param loja, character, loja do cliente
@param nopc, numeric, numero da opção
@return character, sem retorno
/*/
User Function BOLREN(nNum,serie,cliente,loja,nopc)

	Local cEdit1	 := Space(25)
	Local lChk 		 := .F.
	Local oOk        := LoadBitmap( GetResources(), "LBOK" )
	Local oNo        := LoadBitmap( GetResources(), "LBNO" )
	Local oChk       := Nil
	Local oEdit1
	Local _cAlias := GetNextAlias()

	// Variaveis Private
	Private oDBlRendimentos
	Private lExec      := .F.
	Private cIndexName := ""
	Private cIndexKey  := ""
	Private cFilter    := ""
	Private Tamanho    := "M"
	Private titulo     := "Impressão do Boleto [Banco Rendimentos] "
	Private cDesc1     := "Programa de impressao de boletos para o banco Rendimentos."
	Private cDesc2     := ""
	Private cDesc3     := ""
	Private cString    := "SE1"
	Private wnrel      := "BOLREND"
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

Somente Visualizaçao
Codigo			,"C",03,0,"MV_PAR19"
Agencia			,"C",05,0,"MV_PAR20"
Nro. Conta		,"C",10,0,"MV_PAR21"
DV Conta		,"C",01,0,"MV_PAR22"
	*/

	Pergunte (cPerg,.F.)

	SetMVValue(cPerg,"MV_PAR19", "633")
	SetMVValue(cPerg,"MV_PAR20", "3003")
	SetMVValue(cPerg,"MV_PAR21", "0117100")
	SetMVValue(cPerg,"MV_PAR22", "3")

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

		aAdd( aVetor, { lChk,;
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

	//³ Verifica se existem titulos para impressao.                  ³
	If Len( aVetor ) == 0
		ApMsgInfo("Não existe títulos para impressão de boletos.","Atenção")
		Return
	Endif

	//³ Chamada da Janela de selecao dos titulos para impressao      ³
	Define MsDialog oDBlRendimentos Title "Emissão de Boletos [Banco Rendimentos]" From C(225),C(407) To C(657),C(1061) Pixel

	@ C(049),C(005) TO C(190),C(325) LABEL " Títulos Selecionados " Pixel Of oDBlRendimentos
	@ C(059),C(010) ListBox oLbx Var cVar Fields HEADER " ",;
		"Razão Social",;
		"Prefixo",;
		"Numero",;
		"Parc",;
		"Tipo",;
		"Valor",;
		"Vencimento",;
		"No.Registro" Size C(312),C(123) Of oDBlRendimentos Pixel ;
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

	@ C(200),C(037) MsGet oEdit1 Var cEdit1 Size C(085),C(009) COLOR CLR_BLACK Pixel Of oDBlRendimentos
	@ C(200),C(227) Button "&Confirma"      Size C(037),C(012) Pixel Of oDBlRendimentos Action(MontaRel(),oDBlRendimentos:End())
	@ C(200),C(274) Button "&Sair"          Size C(037),C(012) Pixel Of oDBlRendimentos Action(oDBlRendimentos:End())
	@ C(201),C(008) Say "Pesquisar"         Size C(025),C(008) COLOR CLR_BLACK Pixel OF oDBlRendimentos
	@ C(201),C(148) CheckBox oChk Var lChk Prompt "Marca/Desmarca" Size C(057),C(008) Pixel Of oDBlRendimentos;
		On CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

	Activate MsDialog oDBlRendimentos Centered

Return Nil

/*/{Protheus.doc} MontaRel
Montagem e Impressao de boleto Grafico do Banco Rendimentos.
@type function Relatorio
@version  1.00
@author S/A - alterado por mario.antonaccio
@since 02/02/09 - alterado em 09/09/2021
@return Character, Nulo
/*/

Static Function MontaRel(aMarked)

	Local nTxJuros :=( GETMV("MV_@CMY001",.T.,6) / 30) // Taxa de juros aplicada por dia de atraso. Percentual / por 30
	Local n:=0
	Local oPrint
	Local cBitmap      := "\SYSTEM\BRAD" + SM0->M0_CODIGO + SM0->M0_CODFIL + ".BMP" // Logo da empresa
	Local aDadosEmp    := {SM0->M0_NOMECOM                                    ,; //[1]Nome da Empresa
		SM0->M0_ENDCOB                                                            ,; //[2]Endereço
		AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
		"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
		"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
		"C.N.P.J.: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          ; //[6]
		Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
		Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
		"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
		Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                        }  //[7]I.E

	Local aDadosTit
	Local aDadosBanco
	Local aDatSacado
	Local aBolText
	Local nI         := 1
	Local CB_RN_NN  := {}
	Local _nVlrAbat := 0
	Local _nTotEnc  := 0
	Local cFatura := ""

	Private _cNossoNum := "0000000"

	oPrint:= TMSPrinter():New( "Boleto Laser" )
	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:StartPage()   // Inicia uma nova página

	For nI:=1 To Len(aVetor)

		//Verifica se esta marcadp
		If ! aVetor[nI,1]
			Loop
		End
		n++
		SE1->(dbGoto(aVetor[nI,9]))

		//Posiciona o SA6 (Bancos)
		SA6->(DbSetOrder(1))
		SA6->(DbSeek(xFilial("SA6")+mv_par19+mv_par20+mv_par21+mv_par22))
	  
	  //SEE (Parametros Bancos)
		SEE->( DbSetOrder(1) )
		If ! SEE->(DbSeek(xFilial("SEE")+mv_par19+mv_par20+mv_par21,.T.))
	 		ALERT("Dados Bancarios nao encontrados: "+mv_par19+" "+mv_par20+" "+mv_par21+" "+mv_par22+" 001")
			Loop
		End

		If Empty(SE1->E1_NUMBCO)
			_cNossoNum := StrZero(Val(Alltrim(SEE->EE_FAXATU))+1,7)
			RecLock("SEE",.f.)
			SEE->EE_FAXATU :=	_cNossoNum
			MsUnlock()
		Else
			_cNossoNum := Substr(SE1->E1_NUMBCO,5,7)
		Endif
	
		

		//Posiciona o SA1 (Cliente)
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA))

		dbSelectArea("SE1")

		aDadosBanco  := {	"237-2"     ,;     //SA6->A6_NUMBCO        ,; // [1]Numero do Banco
			Substr(SA6->A6_NOME,1,16)    	            	                 ,; // [2]Nome do Banco
			SUBSTR(Alltrim(SA6->A6_AGENCIA), 1, 4)                        ,; // [3]Agência
			StrZero(Val(Subs(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1)),7),; // [4]Conta Corrente
			Subs(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1)  ,; // [5]Dígito da conta corrente
			"09"				                         	  ,; // [6]Codigo da Carteira
			RIGHT(Alltrim(SA6->A6_AGENCIA),1)                    }  // [7]Digito da Agência


		If Empty(SA1->A1_ENDCOB)
			aDatSacado   := {AllTrim(SA1->A1_NOME)                           ,;      // [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      // [2]Código
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      // [3]Endereço
				AllTrim(SA1->A1_MUN )                            ,;      // [4]Cidade
				SA1->A1_EST                                      ,;      // [5]Estado
				SA1->A1_CEP                                      }       // [6]CEP
		Else
			aDatSacado   := {AllTrim(SA1->A1_NOME)                           	,;      // [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA             ,;      // [2]Código
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;      // [3]Endereço
				AllTrim(SA1->A1_MUNC)	                            ,;      // [4]Cidade
				SA1->A1_ESTC	                                    ,;      // [5]Estado
				SA1->A1_CEPC                                        }       // [6]CEP
		Endif
		_nTotEnc	:= 	SE1->(E1_IRRF+E1_INSS+E1_PIS+E1_COFINS+E1_CSLL+((E1_DESCFIN * E1_SALDO)/100))		 && Bop's 110407 - Inclusao do E1_DESCFIN
		_nVlrAbat   := 0

		//									Codigo Banco           Agencia			C.Corrente     Digito C/C
		CB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],;
			aDadosBanco[5],aDadosBanco[6],_cNossoNum,SE1->E1_SALDO )

		aDadosTit    := {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)						,;  // [1] Número do título
			E1_EMISSAO                              					,;  // [2] Data da emissão do título
			Date()                                  					,;  // [3] Data da emissão do boleto
			E1_VENCTO													,;  // [4] Data do vencimento
			E1_SALDO                     			  					,;  // [5] Valor do título
			CB_RN_NN[3]                             					,;  // [6] Nosso número (Ver fórmula para calculo)
			E1_PREFIXO                               					,;  // [7] Prefixo da NF
			E1_TIPO	                               						,;  // [8] Tipo do Titulo
			E1_IRRF		                               					,;  // [9] IRRF
			E1_ISS	                             						,;  // [10] ISS
			E1_INSS 	                               					,;  // [11] INSS
			E1_PIS                                  					,;  // [12] PIS
			E1_COFINS                               					,;  // [13] COFINS
			E1_CSLL                               						,;  // [14] CSLL
			_nVlrAbat                               					}   // [15] Abatimentos

		cFatura := " "
		If SE1->E1_TIPO == "FT "
			cFatura  := BuscaNF(SE1->E1_PREFIXO,SE1->E1_NUM)
		Endif

		aBolText	:= 	{	"Instruções de responsabilidade do BENEFICIÁRIO.Qualquer dúvida sobre boleto contate o BENEFICIÁRIO" ,;
			"Juros/mora ao dia: R$ "+AllTrim(Transform(aDadosTit[05]*(nTxJuros/100),"@E 9,999.99"))+" após "+StrZero(Day(aDadosTit[02]),2) +"/"+ StrZero(Month(aDadosTit[02]),2) +"/"+ Right(Str(Year(aDadosTit[02])),4),;
			"PROTESTAR APÓS 05 DIAS CORRIGIDOS DO VENCIMENTO",;
			"COBRANÇA ESCRITURAL."}

		ImpBrad(oPrint,cBitMap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
		IncProc()

	Next

	If  N > 0
		oPrint:EndPage()     // Finaliza a página
		oPrint:Setup()     // Seta a Impressora
		oPrint:Preview()     // Visualiza antes de imprimir
	End

Return nil

/*/{Protheus.doc} ImpBrad
Impressao de boleto Grafico do Banco Rendimentos
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
Static Function ImpBrad(oPrint,cBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

	Local cBmp       := ""
	LOCAL cImpData   := " "
	Local cStartPath := GetSrvProfString("StartPath","")
	LOCAL i          := 0
	LOCAL oBrush
	LOCAL oFont10
	LOCAL oFont14n
	LOCAL oFont16
	LOCAL oFont16n
	LOCAL oFont24
	LOCAL oFont8

	cStartPath	:= AllTrim(cStartPath)
	If SubStr(cStartPath,Len(cStartPath),1) <> "\"
		cStartPath	+= "\"
	EndIf
	cBmp	:= cStartPath+"BRADESCO.bmp"

	//Parâmetros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14n:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24 := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oBrush := TBrush():New("",4)

	oPrint:StartPage()   // Inicia uma nova página
	//Pinta os campos de cinza
	//oPrint:FillRect(aCoords1,oBrush)
	//oPrint:FillRect(aCoords2,oBrush)
	//oPrint:FillRect(aCoords3,oBrush)
	//oPrint:FillRect(aCoords4,oBrush)
	//oPrint:FillRect(aCoords5,oBrush)
	//oPrint:FillRect(aCoords6,oBrush)
	//oPrint:FillRect(aCoords7,oBrush)
	//oPrint:FillRect(aCoords8,oBrush)

	// Inicia aqui
	oPrint:Line (0150,550,0050, 550)
	oPrint:Line (0150,800,0050, 800)

	oPrint:SayBitMap(0084,100,cBitMap,0184,050)		// Logo da Empresa
	oPrint:Say  (0084,100,aDadosBanco[2],oFont14n)	// [2]Nome do Banco

	oPrint:Say  (0062,567,aDadosBanco[1],oFont24 )	// [1]Numero do Banco
	oPrint:Say  (0084,1900,"Comprovante de Entrega",oFont10)
	oPrint:Line (0150,100,0150,2300)
	oPrint:Say  (0150,100 ,"Cedente"                                        ,oFont8)
	oPrint:Say  (0200,100 ,aDadosEmp[1]  					                 ,oFont10)
	oPrint:Say  (0150,1060,"Agência/Código Cedente"                         ,oFont8)
	oPrint:Say  (0200,1060,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)
	oPrint:Say  (0150,1510,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (0200,1510,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela
	oPrint:Say  (0250,100 ,"Sacado"                                         ,oFont8)
	oPrint:Say  (0300,100 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont8)	//Nome + Codigo

	oPrint:Say  (0250,1060,"Vencimento"                                     ,oFont8)
	cImpData := Strzero(Day(aDadosTit[4]),2)+"/"+Strzero(Month(aDadosTit[4]),2)+"/"+Strzero(Year(aDadosTit[4]),4)
	oPrint:Say  (0300,1060,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresentação",cImpData),oFont10)
	//oPrint:Say  (0300,1060,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresentação",DTOC(aDadosTit[4])),oFont10)

	oPrint:Say  (0250,1510,"Valor do Documento"                          	,oFont8)
	oPrint:Say  (0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)
	oPrint:Say  (0400,0100,"Recebi(emos) o bloqueto/título"                 ,oFont10)
	oPrint:Say  (0450,0100,"com as características acima."             		,oFont10)
	oPrint:Say  (0350,1060,"Data"                                           ,oFont8)
	oPrint:Say  (0350,1410,"Assinatura"                                 	,oFont8)
	oPrint:Say  (0450,1060,"Data"                                           ,oFont8)
	oPrint:Say  (0450,1410,"Entregador"                                 	,oFont8)

	oPrint:Line (0250, 100,0250,1900 )
	oPrint:Line (0350, 100,0350,1900 )
	oPrint:Line (0450,1050,0450,1900 ) //---
	oPrint:Line (0550, 100,0550,2300 )

	oPrint:Line (0550,1050,0150,1050 )
	oPrint:Line (0550,1400,0350,1400 )
	oPrint:Line (0350,1500,0150,1500 ) //--
	oPrint:Line (0550,1900,0150,1900 )

	oPrint:Say  (0160,1910,"(  )Mudou-se"                                	,oFont8)
	oPrint:Say  (0200,1910,"(  )Ausente"                                    ,oFont8)
	oPrint:Say  (0240,1910,"(  )Não existe nº indicado"                  	,oFont8)
	oPrint:Say  (0280,1910,"(  )Recusado"                                	,oFont8)
	oPrint:Say  (0320,1910,"(  )Não procurado"                              ,oFont8)
	oPrint:Say  (0360,1910,"(  )Endereço insuficiente"                  	,oFont8)
	oPrint:Say  (0400,1910,"(  )Desconhecido"                            	,oFont8)
	oPrint:Say  (0440,1910,"(  )Falecido"                                   ,oFont8)
	oPrint:Say  (0480,1910,"(  )Outros(anotar no verso)"                  	,oFont8)

	For i := 100 to 2300 step 50
		oPrint:Line( 0600, i, 0600, i+30)
	Next i

	oPrint:Line (0710,100,0710,2300)
	oPrint:Line (0710,550,0610, 550)
	oPrint:Line (0710,800,0610, 800)

	oPrint:Say  (0644,100,aDadosBanco[2],oFont14n)	// [2]Nome do Banco
	oPrint:SayBitMap(0644,100,cBitMap,0184,050)		// Logo da Empresa // <linha><coluna>cbitmap<largura><altura>

	oPrint:Say  (0622,567,aDadosBanco[1],oFont24 )	// [1]Numero do Banco
	oPrint:Say  (0644,1900,"Recibo do Sacado",oFont10)

	oPrint:Line (0810,100,0810,2300 )
	oPrint:Line (0910,100,0910,2300 )
	oPrint:Line (0980,100,0980,2300 )
	oPrint:Line (1050,100,1050,2300 )

	oPrint:Line (0910,500,1050,500)
	oPrint:Line (0980,750,1050,750)
	oPrint:Line (0910,1000,1050,1000)
	oPrint:Line (0910,1350,0980,1350)
	oPrint:Line (0910,1550,1050,1550)

	oPrint:Say  (0710,100 ,"Local de Pagamento"                             ,oFont8)
	oPrint:Say  (0750,100 ,"Pagável preferencialmente na rede Bradesco ou do banco Postal"        ,oFont10)

	oPrint:Say  (0710,1910,"Vencimento"                                     ,oFont8)
	cImpData := Strzero(Day(aDadosTit[4]),2)+"/"+Strzero(Month(aDadosTit[4]),2)+"/"+Strzero(Year(aDadosTit[4]),4)
	oPrint:Say  (0750,2010,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresentação",cImpData),oFont10)

	oPrint:Say  (0810,100 ,"Cedente"                                        ,oFont8)
	oPrint:Say  (0200,100 ,aDadosEmp[1]  					                 ,oFont10)
	oPrint:Say  (0810,1910,"Agência/Código Cedente"                         ,oFont8)
	oPrint:Say  (0850,2010,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)

	oPrint:Say  (0910,100 ,"Data do Documento"                              ,oFont8)
	cImpData := Strzero(Day(aDadosTit[2]),2)+"/"+Strzero(Month(aDadosTit[2]),2)+"/"+Strzero(Year(aDadosTit[2]),4)
	oPrint:Say  (0940,100 ,cImpData                               ,oFont10) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (0910,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (0940,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (0910,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (0940,1050,If(aDadosTit[8]$"NF |NFF","DM",aDadosTit[8])		,oFont10) //Tipo do Titulo

	oPrint:Say  (0910,1355,"Aceite"                                         ,oFont8)
	oPrint:Say  (0940,1455,"N"                                             ,oFont10)

	oPrint:Say  (0910,1555,"Data do Processamento"                          ,oFont8)
	cImpData := Strzero(Day(aDadosTit[3]),2)+"/"+Strzero(Month(aDadosTit[3]),2)+"/"+Strzero(Year(aDadosTit[3]),4)
	oPrint:Say  (0940,1655,cImpData                             ,oFont10) // Data impressao

	oPrint:Say  (0910,1910,"Nosso Número"                                   ,oFont8)
	oPrint:Say  (0940,1995,aDadosTit[6]                                     ,oFont10)

	oPrint:Say  (0980,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (0980,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (1010,555 ,aDadosBanco[6]                                  	,oFont10)

	oPrint:Say  (0980,755 ,"Espécie"                                        ,oFont8)
	oPrint:Say  (1010,805 ,"R$"                                             ,oFont10)

	oPrint:Say  (0980,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say  (0980,1555,"Valor"                                          ,oFont8)

	oPrint:Say  (0980,1910,"Valor do Documento"                          	,oFont8)
	oPrint:Say  (1010,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

	oPrint:Say  (1050,100 ,"Instruções (Texto de responsabilidade do cedente)  *** Valores expressos em R$ ***",oFont8)
	oPrint:Say  (1100,100 ,aBolText[1]                                      ,oFont10)
	oPrint:Say  (1150,100 ,aBolText[2]                                      ,oFont10)
	oPrint:Say  (1200,100 ,aBolText[3]                                      ,oFont10)
	oPrint:Say  (1250,100 ,aBolText[4]                                      ,oFont10)

	oPrint:Say  (1050,1910,"(-)Desconto/Abatimento"                         ,oFont8)
	If aDadosTit[15] > 0
		oPrint:Say  (1080,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10)
	Endif
	oPrint:Say  (1120,1910,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (1190,1910,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (1260,1910,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (1330,1910,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (1400,100 ,"Sacado"                                         ,oFont8)
	oPrint:Say  (1430,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
	oPrint:Say  (1483,400 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (1536,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	oPrint:Say  (1605,100 ,"Sacador/Avalista"                               ,oFont8)
	oPrint:Say  (1645,1500,"Autenticação Mecânica -"                        ,oFont8)

	oPrint:Line (0710,1900,1400,1900 )
	oPrint:Line (1120,1900,1120,2300 )
	oPrint:Line (1190,1900,1190,2300 )
	oPrint:Line (1260,1900,1260,2300 )
	oPrint:Line (1330,1900,1330,2300 )
	oPrint:Line (1400,100 ,1400,2300 )
	oPrint:Line (1640,100 ,1640,2300 )

	For i := 100 to 2300 step 50
		oPrint:Line( 1850, i, 1850, i+30)
	Next i

	oPrint:Line (2000,100,2000,2300)
	oPrint:Line (2000,550,1900, 550)
	oPrint:Line (2000,800,1900, 800)

	oPrint:SayBitMap(1934,100,cBitMap,0184,050)		// Logo da Empresa // <linha><coluna>cbitmap<largura><altura>
	oPrint:Say  (1934,100,aDadosBanco[2],oFont14n)	// [2]Nome do Banco

	oPrint:Say  (1912,567,aDadosBanco[1],oFont24 )	// [1]Numero do Banco
	oPrint:Say  (1934,820,CB_RN_NN[2],oFont14n)	//Linha Digitavel do Codigo de Barras

	oPrint:Line (2100,100,2100,2300 )
	oPrint:Line (2200,100,2200,2300 )
	oPrint:Line (2270,100,2270,2300 )
	oPrint:Line (2340,100,2340,2300 )

	oPrint:Line (2200,500,2340,500)
	oPrint:Line (2270,750,2340,750)
	oPrint:Line (2200,1000,2340,1000)
	oPrint:Line (2200,1350,2270,1350)
	oPrint:Line (2200,1550,2340,1550)

	oPrint:Say  (2000,100 ,"Local de Pagamento"                             ,oFont8)
	oPrint:Say  (2040,100 ,"Pagável preferencialmente na rede Bradesco ou do banco Postal" ,oFont10)

	oPrint:Say  (2000,1910,"Vencimento"                                     ,oFont8)
	cImpData := Strzero(Day(aDadosTit[4]),2)+"/"+Strzero(Month(aDadosTit[4]),2)+"/"+Strzero(Year(aDadosTit[4]),4)
	oPrint:Say  (2040,2010,If(Dtoc(aDadosTit[4])=="11/11/11","C/Apresentação",cImpData),oFont10)

	oPrint:Say  (2100,100 ,"Cedente"                                        ,oFont8)
	oPrint:Say  (0200,100 ,aDadosEmp[1]  				                 ,oFont10)
	oPrint:Say  (2100,1910,"Agência/Código Cedente"                         ,oFont8)
	oPrint:Say  (2140,2010,aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5],oFont10)

	oPrint:Say  (2200,100 ,"Data do Documento"                              ,oFont8)
	cImpData := Strzero(Day(aDadosTit[2]),2)+"/"+Strzero(Month(aDadosTit[2]),2)+"/"+Strzero(Year(aDadosTit[2]),4)
	oPrint:Say  (2230,100 , cImpData       ,oFont10) // Emissao do Titulo (E1_EMISSAO)

	oPrint:Say  (2200,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (2230,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (2200,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (2230,1050,If(aDadosTit[8]$"NF |NFF","DM",aDadosTit[8])		,oFont10) //Tipo do Titulo

	oPrint:Say  (2200,1355,"Aceite"                                         ,oFont8)
	oPrint:Say  (2230,1455,"N"                                             ,oFont10)

	oPrint:Say  (2200,1555,"Data do Processamento"                          ,oFont8)
	cImpData := Strzero(Day(aDadosTit[3]),2)+"/"+Strzero(Month(aDadosTit[3]),2)+"/"+Strzero(Year(aDadosTit[3]),4)
	oPrint:Say  (2230,1655, cImpData             ,oFont10) // Data impressao

	oPrint:Say  (2200,1910,"Nosso Número"                                   ,oFont8)
	oPrint:Say  (2230,1995,aDadosTit[6]                                     ,oFont10)

	oPrint:Say  (2270,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (2270,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (2300,555 ,aDadosBanco[6]                                  	,oFont10)

	oPrint:Say  (2270,755 ,"Espécie"                                        ,oFont8)
	oPrint:Say  (2300,805 ,"R$"                                             ,oFont10)

	oPrint:Say  (2270,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say  (2270,1555,"Valor"                                          ,oFont8)

	oPrint:Say  (2270,1910,"Valor do Documento"                          	,oFont8)
	oPrint:Say  (2300,2010,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

	oPrint:Say  (2340,100 ,"Instruções (Texto de responsabilidade do cedente)  *** Valores expressos em R$ ***",oFont8)
	oPrint:Say  (2390,100 ,aBolText[1]                                      ,oFont10)
	oPrint:Say  (2440,100 ,aBolText[2]										,oFont10)
	oPrint:Say  (2490,100 ,aBolText[3]                                      ,oFont10)
	oPrint:Say  (2540,100 ,aBolText[4]                                      ,oFont10)

	oPrint:Say  (2340,1910,"(-)Desconto/Abatimento"                         ,oFont8)
	If aDadosTit[15] > 0
		oPrint:Say  (2370,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont10)
	Endif
	oPrint:Say  (2410,1910,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (2480,1910,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (2550,1910,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (2620,1910,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (2690,100 ,"Sacado"                                         ,oFont8)
	oPrint:Say  (2720,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
	oPrint:Say  (2773,400 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (2826,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	oPrint:Say  (2895,100 ,"Sacador/Avalista"                               ,oFont8)
	oPrint:Say  (2935,1500,"Autenticação Mecânica -"                        ,oFont8)
	oPrint:Say  (2935,1850,"Ficha de Compensação"                           ,oFont10)

	oPrint:Line (2000,1900,2690,1900 )
	oPrint:Line (2410,1900,2410,2300 )
	oPrint:Line (2480,1900,2480,2300 )
	oPrint:Line (2550,1900,2550,2300 )
	oPrint:Line (2620,1900,2620,2300 )
	oPrint:Line (2690,100 ,2690,2300 )

	oPrint:Line (2930,100,2930,2300  )

	MSBAR3("INT25",25.2,1.0,CB_RN_NN[1],oPrint,.F.,,,,1.2,,,,.F.)

	For i := 100 to 2300 step 50
		oPrint:Line( 3220, i, 3220, i+30)
	Next i

	DbSelectArea("SE1")
	RecLock("SE1",.f.)
	SE1->E1_NUMBCO :=  Substr(CB_RN_NN[3],4)
	MsUnlock()

	oPrint:EndPage() // Finaliza a página

Return Nil

/*/{Protheus.doc} Modulo10
Calculo digito pelo modulo 10
@type function Provessamento
@version  1.00
@author N/A - Alterado por mario.antonaccio
@since  S/D  - Alterado em 19/10/2021
@param cData, character, String de Calculo
@return Character, digito calculado
/*/
Static Function Modulo10(cData)

	LOCAL L,D,P := 0
	LOCAL B     := .F.

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
Calculo digito pelo modulo 11
@type function Provessamento
@version  1.00
@author N/A - Alterado por mario.antonaccio
@since  S/D  - Alterado em 19/10/2021
@param cData, character, String de Calculo
@return Character, digito calculado
/*/
Static Function Modulo11(cData) //Modulo 11 com base 7

	LOCAL L, D, P := 0

	L := Len(cdata)
	D := 0
	P := 1
	DV:= " "

	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 7   //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
			P := 1
		End
		L := L - 1
	End

	_nResto := mod(D,11)  //Resto da Divisao
	D := 11 - _nResto
	DV:=STR(D)

	If _nResto == 0
		DV := "0"
	End
	If _nResto == 1
		DV := "P"
	End

Return(DV)

/*/{Protheus.doc} Mod11CB
Calculo digito pelo modulo 11 do COdigo de Barras
@type function Provessamento
@version  1.00
@author N/A - Alterado por mario.antonaccio
@since  S/D  - Alterado em 19/10/2021
@param cData, character, String de Calculo
@return Character, digito calculado
/*/
Static Function Mod11CB(cData) // Modulo 11 com base 9

	LOCAL CBL, CBD, CBP := 0

	CBL := Len(cdata)
	CBD := 0
	CBP := 1

	While CBL > 0
		CBP := CBP + 1
		CBD := CBD + (Val(SubStr(cData, CBL, 1)) * CBP)
		If CBP = 9
			CBP := 1
		End
		CBL := CBL - 1
	End

	_nCBResto := mod(CBD,11)  //Resto da Divisao
	CBD := 11 - _nCBResto

	If (CBD == 0 .Or. CBD == 1 .Or. CBD > 9)
		CBD := 1
	End

Return(CBD)

/*/{Protheus.doc} Ret_cBarra
Gera a codificacao da Linha digitavel gerando o codigo de barras.
Retorna os strings para inpressão do Boleto
CB = String para o cód.barras, RN = String com o número digitável
Cobrança não identificada, número do boleto = Título + Parcela
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
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)

	LOCAL BlDocNuFinal := cAgencia + Strzero(val(cNroDoc),7)
	LOCAL blvalorfinal := Strzero(nValor*100,10)
	LOCAL CB           := ''
	Local cFator       := Strzero(SE1->E1_VENCTO - ctod("07/10/97"),4)
	LOCAL cMoeda       := "9"
	LOCAL dv           := 0
	LOCAL dvcb         := 0
	LOCAL dvnn         := 0
	LOCAL NN           := ''
	LOCAL RN           := ''

	//Montagem no NOSSO NUMERO
	//   s :=  cAgencia + cConta + cCarteira + bldocnufinal
	snn := bldocnufinal     // Agencia + Numero (pref+num+parc)
	// RAI
	//dvnn := modulo10(s)  //Digito verificador no Nosso Numero
	dvnn := modulo11(cCarteira+snn)  //Digito verificador no Nosso Numero

	//[RAI] NN := '/' + bldocnufinal + '-' + AllTrim(Str(dvnn))
	NN := cCarteira +"/"+ bldocnufinal +'-'+ AllTrim(dvnn)

	_cLivre := cAgencia+cCarteira+bldocnufinal+cconta+'0'

	scb := cBanco + cMoeda+ cFator + blvalorfinal	+ _cLivre
	dvcb := mod11CB(scb)	//digito verificador do codigo de barras

	CB := SubStr(scb,1,4)+AllTrim(Str(dvcb))+SubStr(scb,5,39)

	//MONTAGEM DA LINHA DIGITAVEL
	srn := cBanco + cMoeda + Substr(_cLivre,1,5) //Codigo Banco + Codigo Moeda + 5 primeiros digitos do campo livre
	dv := modulo10(SubStr(srn,1,5))
	RN := SubStr(srn,1,5) + '.' + SubStr(srn,6,4) + Alltrim(Str(DV)) + '  '

	srn := SubStr(_cLivre,6,10)	// posicao 6 a 15 do campo livre
	dv := modulo10(srn)
	RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+'  '

	srn := SubStr(_cLivre,16,10)	// posicao 16 a 25 do campo livre
	dv := modulo10(srn)
	RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + '  '

	RN := RN + AllTrim(Str(dvcb))+'  '
	RN := RN + cFator
	RN := RN + Strzero(nValor * 100,10)

Return({CB,RN,NN})

/*/{Protheus.doc} BUSCANF
Busca titulos principais que compoem a Fatuta
@type function Processamento
@version   1.00
@author S/A - alterado por  mario.antonaccio
@since 27/12/2006 - alterado em 19/10/2021
@param cPrefFat, character, Prefixo do Titulo
@param cNumFat, character, Numero da Fatura
@return Character, Titulos que compoem a Fatura
/*/
Static Function BUSCANF(cPrefFat,cNumFat)

	Local cRet := " "
	Local _cAlias := GetNextAlias()

	BeginSql alias _cAlias
		SELECT
			SE1.E1_NUM
		FROM
			%Table:SE1% SE1
		WHERE
			SE1.E1_FILIAL = %Exp:xFilial("SE1")%
			AND SE1.E1_FATURA = %Exp:cNumFat%
			AND SE1.E1_FATPREF = %Exp:cPrefFat%
			AND SE1.%NotDel%
	EndSql

	aQuery:=GetLastQuery()

	(_cAlias)->(DbGoTop())

	While(!(_cAlias)->(EoF()))

		cRet += (cAlias)->E1_NUM + "/"
		(_cAlias)->(dbSkip())

	End

	(_cAlias)->(dbCloseArea())

Return(cRet)

/*/{Protheus.doc} Inverter
Inverte selecao conforme clique do usuario.
@type function  Processamento
@version  1.0
@author sem autor - alterado por mario.antonaccio
@since 02/02/2009 - alterado em  09/09/2021
@param nPos, numeric, Posição dentro do arrya de titulos
@return character, sem retorno
/*/
Static Function Inverter(nPos)
	aVetor[nPos][1] := !aVetor[nPos][1]
	oLbx:Refresh()
Return

/*/{Protheus.doc} CalcBra
Funcao para tratamento do Valor com Acrescimo e Decrescimos
@type function Processamento
@version  1.00
@author S/A - mario.antonaccio
@since S/D - 19/10/2021
@return Numeric, Valor de Abatimento/Acrescimo
/*/
Static Function CalcBra()

	//  Declaração de Variaveis Locais
	Local aArea	:= SE1->(GetArea())
	Local nVlrAbat	:= 0
	Local nAcresc	:= 0
	Local nDecres	:= 0
	Local nValorT	:= 0

	//     Atribuição de Valores
	nValor	:= SE1->E1_VALOR
	nVlrAbat:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nAcresc	:= SE1->E1_ACRESC
	nDecres := SE1->E1_DECRESC

	//     Processamento
	nValorT := nValor - nVlrAbat + nAcresc - nDecres

	//     Restaura Area
	RestArea(aArea)

	//     Retorno da Função
Return (nValorT)



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
