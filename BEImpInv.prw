#Include 'Rwmake.Ch'
#Include 'Protheus.Ch'
#Include 'TopConn.Ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BEImpInv �Autor  � Fabio F Sousa      � Data � 31/08/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para importa��o de planilha com a contagem de inven-���
���          � t�rio de estoque...                                        ���
���          � Arquivo deve ser no formado csv.                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Euroamerican / Qualycril...                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BEImpInv()

Local lProcesso   := .T.

Private cQuery    := ""
Private cExtensao := "CSV (MS-DOS) (*.CSV)  | *.CSV | "
Private cPerg     := "BEIMPINV01"
Private cFile     := ""
Private cAnoMes   := ""
Private cCusMed   := SuperGetMV("MV_CUSMED")
Private aRegSD3   := {}
Private cSerieSDB := ""
Private lQualiCQ  := .F.
Private lAchou    := .T.
Private lAtivo    := .T.
Private dDataInv  := CTOD("  /  /    ")
Private cContagem := "001"
Private cUMOrig   := ""
Private cSegUMOri := ""
Private cSegUMAnt := ""
Private nFatorOri := 0
Private nPesoDesm := 0
Private cTipoFOri := ""
Private lAjuste   := .F.
Private _lB8Faz   := .F.
Private _aB8Faz   := {}
Private aSB7Inv   := {}
Private nSB7Inv   := 0
Private lContagem := .T. // Flag para somente carga para invent�rio com o c�digo antigo
Private cPath     := GetSrvProfString("Startpath","")
Private cArqErro  := "c:\temp\Orrencias_Inventario.xls"
Private lValLote  := .F. // Valida Lote em Branco (Caso falso, buscar� o ultimo lote do SB8)
Private lValEquip := .F. // Determinar se equipe da contagem 1 deve ser diferente da equipe 2

If File( cArqErro )
	fErase( cArqErro )
EndIf

cFile := Upper( cGetFile( cExtensao, "Selecao de Arquivos Invent�rio",,""))

//������������������������������������������������������������������������Ŀ
//� Verifica se selecionou arquivo...                                      �
//��������������������������������������������������������������������������
If Empty( cFile )
	ApMsgAlert( 'Arquivo com exten��o CSV deve ser selecionado para integra��o!', 'Selecione o Arquivo')
	Return
EndIf

//������������������������������������������������������������������������Ŀ
//� Verifica se arquivo selecionado existe...                              �
//��������������������������������������������������������������������������
If !File( cFile )
	ApMsgAlert( 'Arquivo com exten��o CSV n�o localizado!', 'Selecione o Arquivo')
	Return
EndIf

//������������������������������������������������������������������������Ŀ
//� Informe o per�odo nos par�metros Ano e M�s...                          �
//��������������������������������������������������������������������������
ValidPerg()

If !Pergunte( cPerg, .T.)
	ApMsgAlert( 'Processamento cancelado!', 'Aten��o')
	Return
EndIf

If Empty( mv_par01 )
	ApMsgAlert( 'Per�odo informado no par�metro est� inv�lido!', 'Aten��o')
	Return
EndIf

//If Empty( mv_par02 )
//	ApMsgAlert( 'Informe qual a contagem que ser� efetuada a carga!', 'Aten��o')
//	Return
//EndIf

dDataInv  := mv_par01
cContagem := "000" //StrZero( mv_par02, 3)

//������������������������������������������������������������������������Ŀ
//� Iniciar processamento de importa��o da S&OP para a Previs�o de Vendas  �
//��������������������������������������������������������������������������
Processa( {|| lProcesso := fImportar()}, 'Importando registros para Invent�rio...')

If !lProcesso
	ApMsgAlert( 'H� erros no arquivos!', 'Corrigir arquivo')
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � fImportar�Autor  � Fabio F Sousa      � Data � 26/04/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     � L� e importar arquivo para previs�o de vendas, efetuar     ���
���          � valida��o dos registros do arquivo.                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Beraca Sabara                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function fImportar()

Local lRetorno         := .T.
Local lPrimeiro        := .T.
Local lValido          := .T.
Local lRegistrou       := .F.
Local aPrevisao        := {} // Array para execu��o do execauto da Previs�o de Vendas - MATA700
Local aDados           := {} // Conte�do do arquivo
Local aDicionario      := {} // Campos Obrigat�rios para carga
Local aCampos          := {} // Campos do arquivo
Local aNumerico        := {} // Array com os campos num�ricos do arquivo
Local aData            := {} // Array com os campos de data do arquivo
Local aOcorrencia      := {} // Array com as ocorr�ncias/diverg�ncias do arquivo
Local aProcessado      := {} // Produto e Data j� processado...
Local aVetor           := {} // Autoexec do Invent�rio (SB7)
Local aApurado         := {}
Local aItem            := {}
Local nPosLocal        := 0
Local nPosLote         := 0
Local nPosQuant        := 0
Local nPosObs          := 0
Local nPosPeso         := 0
Local nPosCont         := 0
Local nNumCol          := 0
Local nPosEmpresa      := 0
Local nPosFilial       := 0
Local nPosFicha        := 0
Local nPosProduto      := 0
Local nPosEndereco     := 0
Local nPosEquipe       := 0
Local nPosValidade     := 0
Local nPosContagem     := 0
Local nPosDigitador    := 0
Local nLin             := 0
Local nI               := 0
Local cDocumento       := "" // Replace( DTOC( dDataBase ), "/", "")
Local cContinua        := ""
Local cBuffer          := ""
Local cErro            := ""
Local cObservacao      := "INVENTARIO JUN/2019 JANDIRA"
Local cProduto         := ""
Local cLocal           := ""
Local cLote            := ""
Local cEndereco        := ""
Local cEquipe          := ""
Local cContagem        := ""
Local nQuantidade      := 0
Local nConta           := 0
Local nTotZer          := 0
Local lOk              := .T.
Local nOpcAuto         := 3 // Indica qual tipo de a��o ser� tomada (Inclus�o/Exclus�o)

Private nRegs          := 0
Private lMsErroAuto    := .F.
Private lMsHelpAuto    := .T.
Private lAutoErrNoFile := .T.
Private aTerceira      := {}
Private lTancagem      := .T. // Habilita para puxar o ultimo lote do produto de tancagem
Private aTanque        := {}

aAdd( aTanque, {'227'})
aAdd( aTanque, {'228'})
aAdd( aTanque, {'228'})
aAdd( aTanque, {'412'})
aAdd( aTanque, {'549'})
aAdd( aTanque, {'7000800'})
aAdd( aTanque, {'107.00.00000'})
aAdd( aTanque, {'116.R2'})
aAdd( aTanque, {'518.00.00000'})
aAdd( aTanque, {'539.I2'})
aAdd( aTanque, {'769.00.00000'})
aAdd( aTanque, {'MP.0006'})
aAdd( aTanque, {'MP.0029'})
aAdd( aTanque, {'MP.0030'})
aAdd( aTanque, {'MP.0032'})
aAdd( aTanque, {'MP.0033'})
aAdd( aTanque, {'MP.0039'})
aAdd( aTanque, {'MP.0062'})
aAdd( aTanque, {'MP.0155'})
aAdd( aTanque, {'MP.0228'})
aAdd( aTanque, {'MP.0258'})
aAdd( aTanque, {'MP.0289'})
aAdd( aTanque, {'MP.0299'})
aAdd( aTanque, {'MP.0352'})
aAdd( aTanque, {'MP.0460'})
aAdd( aTanque, {'MP.0490'})
aAdd( aTanque, {'MP.0634'})
aAdd( aTanque, {'MP.0678'})
aAdd( aTanque, {'MP.0732'})
aAdd( aTanque, {'MP.0629'})
aAdd( aTanque, {'PI259'})
aAdd( aTanque, {'PI260'})
aAdd( aTanque, {'PI321'})
aAdd( aTanque, {'PI649'})
aAdd( aTanque, {'TP001'})
aAdd( aTanque, {'TP002'})

cQuery := "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'CONTAGEM_INVENTARIO'"
TCQuery cQuery New Alias "CONINV"
dbSelectArea("CONINV")
dbGoTop()

If !CONINV->( Eof() )
	cQuery := "DELETE CONTAGEM_INVENTARIO WHERE DATA_INVENTARIO = '" + DTOS( dDataInv ) + "' AND EMPRESA = '" + Left(cFilAnt,2) + "' AND FILIAL = '" + Right(cFilAnt,2) + "'"
	TCSqlExec( cQuery )
Else
	cQuery := "CREATE TABLE CONTAGEM_INVENTARIO ( DATA_INVENTARIO VARCHAR(8), EMPRESA VARCHAR(2), FILIAL VARCHAR(2), FICHA VARCHAR(6), PRODUTO VARCHAR(15), ARMAZEM VARCHAR(2), LOTE VARCHAR(10), ENDERECO VARCHAR(20), QUANTIDADE FLOAT, EQUIPE VARCHAR(10), VALIDADE VARCHAR(10), CONTAGEM INT, DIGITADOR VARCHAR(50) )"
	TCSqlExec( cQuery )
EndIf

CONINV->( dbCloseArea() )

cQuery := "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'APURACAO_INVENTARIO'"
TCQuery cQuery New Alias "CONINV"
dbSelectArea("CONINV")
dbGoTop()

If !CONINV->( Eof() )
	cQuery := "DELETE APURACAO_INVENTARIO WHERE DATA_INVENTARIO = '" + DTOS( dDataInv ) + "' AND EMPRESA = '" + Left(cFilAnt,2) + "' AND FILIAL = '" + Right(cFilAnt,2) + "'"
	TCSqlExec( cQuery )
Else
	cQuery := "CREATE TABLE APURACAO_INVENTARIO ( DATA_INVENTARIO VARCHAR(8), EMPRESA VARCHAR(2), FILIAL VARCHAR(2), FICHA VARCHAR(6), PRODUTO VARCHAR(15), ARMAZEM VARCHAR(2), LOTE VARCHAR(10), ENDERECO VARCHAR(20), QUANT_PRI FLOAT, EQUIPE_PRI VARCHAR(10), DIGIT_PRI VARCHAR(50), QUANT_SEG FLOAT, EQUIPE_SEG VARCHAR(10), DIGIT_SEG VARCHAR(50), QUANT_TER FLOAT, EQUIPE_TER VARCHAR(10), DIGIT_TER VARCHAR(50), VALIDADE VARCHAR(10) )"
	TCSqlExec( cQuery )
EndIf

CONINV->( dbCloseArea() )

//������������������������������������������������������������������������Ŀ
//� Verificar se Invent�rio j� foi integrado anteriormente...              �
//��������������������������������������������������������������������������
dbSelectArea("SB7")
dbSetOrder(1)

cQuery := "SELECT * FROM " + RetSqlName("SB7") + " AS SB7 WITH (NOLOCK) " + CRLF
cQuery += "WHERE B7_FILIAL = '" + xFilial("SB7") + "' " + CRLF
cQuery += "AND B7_DATA = '" + DTOS( dDataInv ) + "' " + CRLF
cQuery += "AND B7_DOC <> '999999' " + CRLF
cQuery += "AND B7_DOC <> '000000' " + CRLF
cQuery += "AND SB7.D_E_L_E_T_ = ' ' " + CRLF

TCQuery cQuery New Alias "TMPZ15"
dbSelectArea("TMPZ15")
dbGoTop()

If !TMPZ15->( Eof() )
	If !ApMsgYesNo( 'J� houveram importa��es de Invent�rio no per�odo para esta contagem.' + CRLF + 'Deseja substituir?' )
		ApMsgInfo( 'Processamento cancelado!', 'Aten��o')
		TMPZ15->( dbCloseArea() )
		Return lRetorno
	Else
		//������������������������������������������������������������������������Ŀ
		//� Apaga contagem anterior...                                             �
		//��������������������������������������������������������������������������
		cQuery := "UPDATE " + RetSqlName("SB7") + " SET D_E_L_E_T_ = '*' " + CRLF
		cQuery += "WHERE B7_FILIAL = '" + xFilial("SB7") + "' " + CRLF
		cQuery += "AND B7_DOC <> '999999' " + CRLF
		cQuery += "AND B7_DOC <> '000000' " + CRLF
		cQuery += "AND B7_DATA = '" + DTOS( dDataInv ) + "' " + CRLF
		cQuery += "AND D_E_L_E_T_ = ' ' " + CRLF

		TCSqlExec( cQuery )
	EndIf
EndIf

TMPZ15->( dbCloseArea() )

//������������������������������������������������������������������������Ŀ
//� Campos do arquivo CSV para importa��o...                               �
//��������������������������������������������������������������������������
aAdd( aDicionario, {'EMPRESA'})
aAdd( aDicionario, {'FILIAL'})
aAdd( aDicionario, {'FICHA'})
aAdd( aDicionario, {'PRODUTO'})
aAdd( aDicionario, {'LOCAL'})
aAdd( aDicionario, {'LOTE'})
aAdd( aDicionario, {'ENDERECO'})
aAdd( aDicionario, {'QUANTIDADE'})
aAdd( aDicionario, {'EQUIPE'})
aAdd( aDicionario, {'VALIDADE'})
aAdd( aDicionario, {'CONTAGEM'})
aAdd( aDicionario, {'DIGITADOR'})

//������������������������������������������������������������������������Ŀ
//� Campos do tipo num�rico...                                             �
//��������������������������������������������������������������������������
aAdd( aNumerico,   {'QUANTIDADE'})
aAdd( aNumerico,   {'CONTAGEM'})

//������������������������������������������������������������������������Ŀ
//� Campos do tipo data...                                                 �
//��������������������������������������������������������������������������
aAdd( aData,       {'VALIDADE'})

//������������������������������������������������������������������������Ŀ
//� Abre arquivo...                                                        �
//��������������������������������������������������������������������������
If FT_FUSE( AllTrim( cFile ) ) == 1
	FT_FGOTOP()

	ProcRegua( FT_FLASTREC() )

	//������������������������������������������������������������������������Ŀ
	//� Processa as linhas do arquivo...                                       �
	//��������������������������������������������������������������������������
	While !FT_FEOF()
		nLin++

		IncProc( "Linha do Arquivo: " + StrZero( nLin, 6) )

		cBuffer := FT_FREADLN()
		nNumCol := Len(cBuffer)

		//������������������������������������������������������������������������Ŀ
		//� L� a linha at� o final...                                              �
		//��������������������������������������������������������������������������
		Do While nNumCol == 1023
			FT_FSKIP()

			cContinua := FT_FREADLN()
			nNumCol   := Len(cContinua)
			cBuffer   := cBuffer + cContinua
		EndDo

		cBuffer := cBuffer + ";"

		//������������������������������������������������������������������������Ŀ
		//� Se primeira linha, tratar cabe�alho e campos...                        �
		//��������������������������������������������������������������������������
		If lPrimeiro
			Do While (Len(cBuffer) <> 0)
				nPonto   := At(';',cBuffer)
				cDescCpo := AllTrim(SubStr(cBuffer,1,nPonto - 1))

				If aScan( aNumerico, {|x| AllTrim( x[1] ) == Upper( AllTrim( cDescCpo ) )} ) > 0
					cTipo := "N"
				ElseIf aScan( aData, {|x| AllTrim( x[1] ) == Upper( AllTrim( cDescCpo ) )} ) > 0
					cTipo := "D"
				Else
					cTipo := "C"
				EndIf

				aAdd( aCampos, { .T., Upper( AllTrim( cDescCpo ) ), cTipo } )

				cBuffer := SubStr(cBuffer,nPonto + 1)
			EndDo

			aDados    := Array(1,Len(aCampos),0)
			lPrimeiro := .F.
		Else
			//������������������������������������������������������������������������Ŀ
			//� Alimenta dados da planilha...                                          �
			//��������������������������������������������������������������������������
			If !Empty( cBuffer )
				nRegs++
	
				For nI := 1 to Len(aCampos)
					nPonto := At(';',cBuffer)
					If aCampos[nI][1]
						If aCampos[nI][3] == "N"
							//If IsNumeric( Replace( AllTrim(SubStr(cBuffer,1,nPonto - 1)), ",", ".") )
								aAdd(aDados[1,nI],Val( Replace( Replace( AllTrim(SubStr(cBuffer,1,nPonto - 1)), ".", ""), ",", ".") ))
							//Else
							//	aAdd(aDados[1,nI],0)
							//EndIf
						ElseIf aCampos[nI][3] == "D"
							If Len( Replace(Replace(AllTrim(SubStr(cBuffer,1,nPonto - 1)),".","/"),"-","/") ) == 8 .Or. Len( Replace(Replace(AllTrim(SubStr(cBuffer,1,nPonto - 1)),".","/"),"-","/") ) == 10
								aAdd(aDados[1,nI],CTOD(Replace(Replace(AllTrim(SubStr(cBuffer,1,nPonto - 1)),".","/"),"-","/")))
							Else
								aAdd(aDados[1,nI],STOD("        "))
							EndIf
						Else
							aAdd(aDados[1,nI],AllTrim(Upper(SubStr(cBuffer,1,nPonto - 1))))
						EndIf
					EndIf
	
					cBuffer := SubStr(cBuffer,nPonto + 1)
				Next
			EndIf
		EndIf

		FT_FSKIP()
	Enddo

	FT_FUSE()
Else
	ApMsgAlert( 'N�o foi poss�vel abrir o arquivo, verifique!', 'Aten��o')
	lRetorno := .F.
	Return lRetorno
EndIf

//������������������������������������������������������������������������Ŀ
//� Verifica se arquivo possui todas as colunas obrigat�rias...            �
//��������������������������������������������������������������������������
For nI := 1 To Len(aDicionario)
	If aScan( aCampos, {|x| AllTrim( x[1] ) == AllTrim( aDicionario[nI][1] )} ) > 0
		lValido := .F.
	EndIf
Next

If !lValido
	ApMsgAlert( 'Arquivo n�o possui colunas obrigat�rias, verifique!', 'Aten��o')
	lRetorno := .F.
	Return lRetorno
EndIf

//������������������������������������������������������������������������Ŀ
//� Guarda posi��es das colunas conforme layout...                         �
//��������������������������������������������������������������������������
nPosEmpresa    := aScan( aCampos, {|x| AllTrim(x[2]) $ 'EMPRESA'})
nPosFilial     := aScan( aCampos, {|x| AllTrim(x[2]) $ 'FILIAL'})
nPosFicha      := aScan( aCampos, {|x| AllTrim(x[2]) $ 'FICHA'})
nPosProduto    := aScan( aCampos, {|x| AllTrim(x[2]) $ 'PRODUTO'})
nPosLocal      := aScan( aCampos, {|x| AllTrim(x[2]) $ 'LOCAL'})
nPosLote       := aScan( aCampos, {|x| AllTrim(x[2]) $ 'LOTE'})
nPosEndereco   := aScan( aCampos, {|x| AllTrim(x[2]) $ 'ENDERECO'})
nPosQuant      := aScan( aCampos, {|x| AllTrim(x[2]) $ 'QUANTIDADE'})
nPosEquipe     := aScan( aCampos, {|x| AllTrim(x[2]) $ 'EQUIPE'})
nPosValidade   := aScan( aCampos, {|x| AllTrim(x[2]) $ 'VALIDADE'})
nPosContagem   := aScan( aCampos, {|x| AllTrim(x[2]) $ 'CONTAGEM'})
nPosDigitador  := aScan( aCampos, {|x| AllTrim(x[2]) $ 'DIGITADOR'})

dbSelectArea("SD3")

If nPosEmpresa == 0 .Or. nPosFilial == 0 .Or. nPosFicha == 0 .Or. nPosProduto == 0 .Or. nPosLocal == 0 .Or. nPosLote == 0 .Or. nPosEndereco == 0 ;
   .Or. nPosQuant == 0 .Or. nPosEquipe == 0 .Or. nPosValidade == 0 .Or. nPosContagem == 0 .Or. nPosDigitador == 0
	ApMsgAlert( "Estrutura do arquivo incorreto!" + CRLF + "Processo ser� interrompido.", "Aten��o")
	Return .F.
EndIf

//������������������������������������������������������������������������Ŀ
//� Efetuar valida��es de todos os dados da planilha...                    �
//��������������������������������������������������������������������������
For nI := 1 To nRegs
	lValido := .T.

	IncProc( "Validando registro da Linha: " + StrZero( nI + 1, 6) )

	//������������������������������������������������������������������������Ŀ
	//� Valida preenchimento das linhas...                                     �
	//��������������������������������������������������������������������������
	If Empty( aDados[1,nPosEmpresa,nI] )
		aAdd( aOcorrencia, {'Empresa em branco.', AllTrim(aDados[1,nPosEmpresa,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		lValido := .F.
	Else
		If Len(aDados[1,nPosEmpresa,nI]) <> 2
			If IsNumeric( aDados[1,nPosEmpresa,nI] )
				aDados[1,nPosEmpresa,nI] := StrZero( Val( aDados[1,nPosEmpresa,nI] ), 2)
			EndIf
		EndIf

		If !(aDados[1,nPosEmpresa,nI] $ "02/08")
			aAdd( aOcorrencia, {'Empresa inv�lida.', AllTrim(aDados[1,nPosEmpresa,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
			lValido := .F.
		EndIf
	EndIf

	If !Empty( aDados[1,nPosEndereco,nI] )
		aDados[1,nPosEndereco,nI] := Replace( Replace( AllTrim( aDados[1,nPosEndereco,nI] ), ".", ""), "-", "")
	EndIf

	If Empty( aDados[1,nPosFilial,nI] )
		aAdd( aOcorrencia, {'Filial em branco.', AllTrim(aDados[1,nPosFilial,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		lValido := .F.
	Else
		If Len(aDados[1,nPosFilial,nI]) <> 2
			If IsNumeric( aDados[1,nPosFilial,nI] )
				aDados[1,nPosFilial,nI] := StrZero( Val( aDados[1,nPosFilial,nI] ), 2)
			EndIf
		EndIf

		If !(aDados[1,nPosFilial,nI] $ "00/03")
			aAdd( aOcorrencia, {'Filial inv�lida.', AllTrim(aDados[1,nPosFilial,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
			lValido := .F.
		EndIf
	EndIf

	If !(AllTrim( aDados[1,nPosEmpresa,nI] ) == Left(cFilAnt,2))
		aAdd( aOcorrencia, {'Empresa inv�lida para integra��o do arquivo', AllTrim(aDados[1,nPosEmpresa,nI]), "Fazer Login na Empresa/Filial Correta", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		lValido := .F.
	EndIf

	If !(AllTrim( aDados[1,nPosFilial,nI] ) == AllTrim( cFilAnt ))
		aAdd( aOcorrencia, {'Filial inv�lida para integra��o do arquivo', AllTrim(aDados[1,nPosFilial,nI]), "Fazer Login na Filial Correta", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		lValido := .F.
	EndIf

	//Se endere�o Q01AV001 for�ar endere�o 07...
	If !Empty( aDados[1,nPosEndereco,nI] ) .And. AllTrim( aDados[1,nPosEndereco,nI] ) == "Q01AV001"
		aDados[1,nPosLocal,nI] := "07"
	EndIf

	If Empty( aDados[1,nPosProduto,nI] )
		aAdd( aOcorrencia, {'Produto em branco.', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		lValido := .F.
	EndIf

	If Empty( aDados[1,nPosFicha,nI] )
		aAdd( aOcorrencia, {'Ficha em branco.', AllTrim(aDados[1,nPosFicha,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		lValido := .F.
	Else
		If !IsNumeric( aDados[1,nPosFicha,nI] )
			aAdd( aOcorrencia, {'Ficha com c�digo indevido.', AllTrim(aDados[1,nPosFicha,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
			lValido := .F.
		Else
			aDados[1,nPosFicha,nI] := StrZero( Val( aDados[1,nPosFicha,nI] ), 6)
		EndIf
	EndIf

	If !Empty( aDados[1,nPosLocal,nI] )
		If IsNumeric( aDados[1,nPosLocal,nI] )
			aDados[1,nPosLocal,nI] := StrZero( Val( aDados[1,nPosLocal,nI] ), 2)
		EndIf
	EndIf

	If Empty( aDados[1,nPosEquipe,nI] )
		aDados[1,nPosEquipe,nI] := "NC"
	EndIf

	If aDados[1,nPosQuant,nI] > 0.00
		//������������������������������������������������������������������������Ŀ
		//� Processa dados para gera��o do Invent�rio...                           �
		//��������������������������������������������������������������������������
		If lValido
			dbSelectArea("SB1")
			dbSetOrder(1)

			// Verificar e corrigir o c�digo do produto que o danado do usu�rio ocultou os zeros �s esquerdas da planilha de contagem :( ->...
			If !SB1->( dbSeek( xFilial("SB1") + AllTrim(aDados[1,nPosProduto,nI]) ) )
				cProduto := AllTrim( Replace( Replace( aDados[1,nPosProduto,nI], ".", ""), ",", "") )
				If IsNumeric( cProduto )
					cQuery := "SELECT B1_COD FROM " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) " + CRLF
					cQuery += "WHERE B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
					cQuery += "AND B1_COD LIKE '%" + AllTrim( aDados[1,nPosProduto,nI] ) + "' " + CRLF
					cQuery += "AND SB1.D_E_L_E_T_ = ' ' " + CRLF

					TCQuery cQuery New Alias "TMPSB1"
					dbSelectArea("TMPSB1")
					TMPSB1->( dbGoTop() )

					If !TMPSB1->( Eof() )
						aDados[1,nPosProduto,nI] := AllTrim( TMPSB1->B1_COD )
					EndIf

					TMPSB1->( dbCloseArea() )
				EndIf
			EndIf

			If !SB1->( dbSeek( xFilial("SB1") + AllTrim(aDados[1,nPosProduto,nI]) ) )
				aDados[1,nPosProduto,nI] := AllTrim( Upper( Replace(aDados[1,nPosProduto,nI], "(CONTAINNER)", "") ) )

				If !SB1->( dbSeek( xFilial("SB1") + AllTrim(aDados[1,nPosProduto,nI]) ) )
					If Left( aDados[1,nPosProduto,nI], 2) == "MP" .And. SubStr( aDados[1,nPosProduto,nI], 3, 1) <> "."
						aDados[1,nPosProduto,nI] := "MP." + Replace( aDados[1,nPosProduto,nI], "MP", "")
					Else
						aDados[1,nPosProduto,nI] := Replace( aDados[1,nPosProduto,nI], " ", "")
					EndIf

					If !SB1->( dbSeek( xFilial("SB1") + AllTrim(aDados[1,nPosProduto,nI]) ) )
						If !Empty(AllTrim(aDados[1,nPosLote,nI]))
							cQuery := "SELECT B8_PRODUTO FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
							cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
							cQuery += "AND B8_LOTECTL = '" + AllTrim(aDados[1,nPosLote,nI]) + "' " + CRLF
							cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
							cQuery += "ORDER BY B8_DTVALID DESC " + CRLF

							TCQuery cQuery New Alias "TMPULTIMO"
							dbSelectArea("TMPULTIMO")
							TMPULTIMO->( dbGoTop() )

							If !TMPULTIMO->( Eof() )
								aDados[1,nPosProduto,nI] := TMPULTIMO->B8_PRODUTO
							EndIf

							TMPULTIMO->( dbCloseArea() )
						Else
							//������������������������������������������������������������������������Ŀ
							//� Se c�digo n�o existe, gera ocorr�ncia...                               �
							//��������������������������������������������������������������������������
							aAdd( aOcorrencia, {'C�digo do Produto n�o encontrado.', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
							lValido := .F.
						EndIf
					EndIf
				EndIf
			Else
				//������������������������������������������������������������������������Ŀ
				//� Tratar produtos sem controle de lote...                                �
				//��������������������������������������������������������������������������
				If AllTrim( SB1->B1_MSBLQL ) == "1"
					dbSelectArea("SB1")
					//RecLock("SB1", .F.)
					//	SB1->B1_MSBLQL := "2"
					//MsUnLock()
					ConOut("Desbloqueio Produto: " + SB1->B1_COD + " para Invent�rio")
				EndIf

				//������������������������������������������������������������������������Ŀ
				//� Tratar produtos sem controle de lote...                                �
				//��������������������������������������������������������������������������
				If AllTrim( SB1->B1_RASTRO ) == "N"
					//������������������������������������������������������������������������Ŀ
					//� Tratar valida��es do local de estoque...                               �
					//��������������������������������������������������������������������������
					If Empty( aDados[1,nPosLocal,nI] ) // Se local vazio, busca o local padr�o
						dbSelectArea("SB2")
						dbSetOrder(1)
						If !SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD ) ) // Se n�o existir local padr�o no saldo, busca outro local
							cQuery := "SELECT B2_LOCAL FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
							cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
							cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
							cQuery += "ORDER BY B2_QATU DESC " + CRLF

							TCQuery cQuery New Alias "TMPNNR"
							dbSelectArea("TMPNNR")
							TMPNNR->( dbGoTop() )

							If TMPNNR->( Eof() ) // Se n�o houver local para o produto, corre��o manual no item inventariado
								aAdd( aOcorrencia, {'Produto n�o encontrado no SB2 para um local v�lido', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
								lValido := .F.
							Else
								aDados[1,nPosLocal,nI] := TMPNNR->B2_LOCAL
							EndIf

							TMPNNR->( dbCloseArea() )
						Else
							aDados[1,nPosLocal,nI] := SB1->B1_LOCPAD
						EndIf
					Else
						dbSelectArea("NNR")
						dbSetOrder(1)
						If !NNR->( dbSeek( xFilial("NNR") + aDados[1,nPosLocal,nI] ) )
							If !IsNumeric( aDados[1,nPosLocal,nI] )
								dbSelectArea("SB2")
								dbSetOrder(1)
								If !SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD ) ) // Se n�o existir local padr�o no saldo, busca outro local
									cQuery := "SELECT B2_LOCAL FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
									cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
									cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
									cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
									cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
									cQuery += "ORDER BY B2_QATU DESC " + CRLF
		
									TCQuery cQuery New Alias "TMPNNR"
									dbSelectArea("TMPNNR")
									TMPNNR->( dbGoTop() )
		
									If TMPNNR->( Eof() ) // Se n�o houver local para o produto, corre��o manual no item inventariado
										aAdd( aOcorrencia, {'Produto n�o encontrado no SB2 para um local v�lido', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
										lValido := .F.
									Else
										aDados[1,nPosLocal,nI] := TMPNNR->B2_LOCAL
									EndIf
		
									TMPNNR->( dbCloseArea() )
								Else
									aDados[1,nPosLocal,nI] := SB1->B1_LOCPAD
								EndIf
							Else
								If !NNR->( dbSeek( xFilial("NNR") + StrZero(Val(aDados[1,nPosLocal,nI]), 2) ) )
									dbSelectArea("SB2")
									dbSetOrder(1)
									If !SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD ) ) // Se n�o existir local padr�o no saldo, busca outro local
										cQuery := "SELECT B2_LOCAL FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
										cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
										cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
										cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
										cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
										cQuery += "ORDER BY B2_QATU DESC " + CRLF
			
										TCQuery cQuery New Alias "TMPNNR"
										dbSelectArea("TMPNNR")
										TMPNNR->( dbGoTop() )
			
										If TMPNNR->( Eof() ) // Se n�o houver local para o produto, corre��o manual no item inventariado
											aAdd( aOcorrencia, {'Produto n�o encontrado no SB2 para um local v�lido', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
											lValido := .F.
										Else
											aDados[1,nPosLocal,nI] := TMPNNR->B2_LOCAL
										EndIf
			
										TMPNNR->( dbCloseArea() )
									Else
										aDados[1,nPosLocal,nI] := SB1->B1_LOCPAD
									EndIf
								Else
									aDados[1,nPosLocal,nI] := StrZero(Val(aDados[1,nPosLocal,nI]), 2)
								EndIf
							EndIf
						EndIf
					EndIf
				Else
					If lTancagem
						If aScan( aTanque, {|x| AllTrim( x[1] ) == AllTrim( SB1->B1_COD ) }) <> 0
							cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
							cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
							cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
							cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
							cQuery += "ORDER BY B8_DTVALID DESC " + CRLF

							TCQuery cQuery New Alias "TMPULTIMO"
							dbSelectArea("TMPULTIMO")
							TMPULTIMO->( dbGoTop() )

							If !TMPULTIMO->( Eof() )
								aDados[1,nPosLocal,nI] := TMPULTIMO->B8_LOTECTL
								aDados[1,nPosLote,nI]  := TMPULTIMO->B8_LOCAL
							EndIf

							TMPULTIMO->( dbCloseArea() )
						EndIf
					EndIf

					//������������������������������������������������������������������������Ŀ
					//� Tratar valida��es do lote e local de estoque...                        �
					//��������������������������������������������������������������������������
					If Empty( aDados[1,nPosLote,nI] )
						If !lValLote
							cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
							cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
							cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
							cQuery += "AND B8_LOCAL = '" + AllTrim( aDados[1,nPosLocal,nI] ) + "' " + CRLF
							cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
							cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF

							TCQuery cQuery New Alias "TMPULTIMO"
							dbSelectArea("TMPULTIMO")
							TMPULTIMO->( dbGoTop() )

							If !TMPULTIMO->( Eof() )
								aDados[1,nPosLote,nI] := TMPULTIMO->B8_LOTECTL
							Else
								cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
								cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
								cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
								cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
								cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
								cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
								cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
	
								TCQuery cQuery New Alias "TMPLOCAL"
								dbSelectArea("TMPLOCAL")
								TMPLOCAL->( dbGoTop() )
	
								If !TMPLOCAL->( Eof() )
									aDados[1,nPosLote,nI]  := TMPLOCAL->B8_LOTECTL
									aDados[1,nPosLocal,nI] := TMPLOCAL->B8_LOCAL
								Else
									//aAdd( aOcorrencia, {'Lote em branco.', AllTrim(aDados[1,nPosLote,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
									//lValido := .F.
									dbSelectArea("SB1")
									//RecLock( "SB1",.F.)
									//	SB1->B1_RASTRO := "N"
									//MsUnLock()

									cQuery := "SELECT B2_LOCAL FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
									cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
									cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
									cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
									cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
									cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF
		
									TCQuery cQuery New Alias "TMPCORR"
									dbSelectArea("TMPCORR")
									TMPCORR->( dbGoTop() )
		
									If !TMPCORR->( Eof() )
										aDados[1,nPosLocal,nI] := TMPCORR->B2_LOCAL
									Else
										aDados[1,nPosLocal,nI] := SB1->B1_LOCPAD
									EndIf
									
									TMPCORR->( dbCloseArea() )
								EndIf
	
								TMPLOCAL->( dbCloseArea() )
							EndIf

							TMPULTIMO->( dbCloseArea() )
						Else
							//aAdd( aOcorrencia, {'Lote em branco.', AllTrim(aDados[1,nPosLote,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
							//lValido := .F.
							dbSelectArea("SB1")
							//RecLock( "SB1",.F.)
							//	SB1->B1_RASTRO := "N"
							//MsUnLock()

							cQuery := "SELECT B2_LOCAL FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
							cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
							cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
							cQuery += "ORDER BY R_E_C_N_O_ DESC " + CRLF

							TCQuery cQuery New Alias "TMPCORR"
							dbSelectArea("TMPCORR")
							TMPCORR->( dbGoTop() )

							If !TMPCORR->( Eof() )
								aDados[1,nPosLocal,nI] := TMPCORR->B2_LOCAL
							Else
								aDados[1,nPosLocal,nI] := SB1->B1_LOCPAD
							EndIf
							
							TMPCORR->( dbCloseArea() )
						EndIf
					Else
						If Empty( aDados[1,nPosLocal,nI] ) // Se local vazio, priorizar o local padr�o do produto...
							cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
							cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
							cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
							cQuery += "AND B8_LOTECTL = '" + AllTrim( aDados[1,nPosLote,nI] ) + "' " + CRLF
							cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
							cQuery += "ORDER BY B8_SALDO DESC " + CRLF

							TCQuery cQuery New Alias "TMPSB8"
							dbSelectArea("TMPSB8")
							TMPSB8->( dbGoTop() )

							If TMPSB8->( Eof() ) // Caso n�o encontre o local no lote e produto, verificar se o mesmo faltou zeros � esquerdas
								cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
								cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
								cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
								cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
								cQuery += "AND B8_LOTECTL LIKE '%" + AllTrim( aDados[1,nPosLote,nI] ) + "' " + CRLF
								cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
								cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
								cQuery += "ORDER BY B8_SALDO DESC " + CRLF
		
								TCQuery cQuery New Alias "TMPACHE1"
								dbSelectArea("TMPACHE1")
								TMPACHE1->( dbGoTop() )

								If TMPACHE1->( Eof() ) // Se nem achar, gerar ocorrencia de erro para avalia��o e acerto manual
									cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
									cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
									cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
									cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
									cQuery += "AND B8_LOTECTL LIKE '%" + AllTrim( aDados[1,nPosLote,nI] ) + "' " + CRLF
									cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
									cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
									cQuery += "ORDER BY B8_SALDO DESC " + CRLF
			
									TCQuery cQuery New Alias "TMPACHE2"
									dbSelectArea("TMPACHE2")
									TMPACHE2->( dbGoTop() )
	
									If TMPACHE2->( Eof() ) // Se nem achar, gerar ocorrencia de erro para avalia��o e acerto manual
										cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
										cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
										cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
										cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
										cQuery += "AND B8_LOTECTL LIKE '%" + AllTrim( Replace( Replace( aDados[1,nPosLote,nI], ".", "%"), "-", "%") ) + "' " + CRLF
										cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
										cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
										cQuery += "ORDER BY B8_SALDO DESC " + CRLF

										TCQuery cQuery New Alias "TMPACHE3"
										dbSelectArea("TMPACHE3")
										TMPACHE3->( dbGoTop() )
	
										If TMPACHE3->( Eof() ) // Se nem achar, gerar ocorrencia de erro para avalia��o e acerto manual
											//aAdd( aOcorrencia, {'Produto, Lote e Local n�o encontrado na base', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
											//lValido := .F.
											aDados[1,nPosLocal,nI] := IIf( Empty(aDados[1,nPosLocal,nI]), SB1->B1_LOCPAD, aDados[1,nPosLocal,nI])
											aDados[1,nPosLote,nI]  := IIf( Empty(aDados[1,nPosLote,nI]), "LU", aDados[1,nPosLote,nI])

											dbSelectArea("SB2")
											If !SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + aDados[1,nPosLocal,nI] ) )
												RecLock("SB2", .T.)
													SB2->B2_FILIAL  := xFilial("SB2")
													SB2->B2_COD     := SB1->B1_COD
													SB2->B2_LOCAL   := aDados[1,nPosLocal,nI]
													SB2->B2_QATU    := 0
												MsUnlock()
											EndIf

											dbSelectArea("SB8")

										    RecLock("SB8", .T.)
												SB8->B8_FILIAL  := xFilial("SB8")
												SB8->B8_PRODUTO := SB1->B1_COD
												SB8->B8_LOCAL   := aDados[1,nPosLocal,nI]
												SB8->B8_LOTECTL := aDados[1,nPosLote,nI]
												SB8->B8_DATA    := dDataBase
												SB8->B8_DTVALID := dDataBase
												SB8->B8_QTDORI  := 0
												SB8->B8_SALDO   := 0
												SB8->B8_ORIGLAN := "MI"
												SB8->B8_DOC     := aDados[1,nPosFicha,nI]
											MsUnlock()
										Else
											aDados[1,nPosLocal,nI] := TMPACHE3->B8_LOCAL
											aDados[1,nPosLote,nI]  := TMPACHE3->B8_LOTECTL
										EndIf
	
										TMPACHE3->( dbCloseArea() )
									Else
										aDados[1,nPosLocal,nI] := TMPACHE2->B8_LOCAL
										aDados[1,nPosLote,nI]  := TMPACHE2->B8_LOTECTL
									EndIf
	
									TMPACHE2->( dbCloseArea() )
								Else
									aDados[1,nPosLocal,nI] := TMPACHE1->B8_LOCAL
									aDados[1,nPosLote,nI]  := TMPACHE1->B8_LOTECTL
								EndIf

								TMPACHE1->( dbCloseArea() )
							Else
								aDados[1,nPosLocal,nI] := TMPSB8->B8_LOCAL
							EndIf

							TMPSB8->( dbCloseArea() )
						Else // Verificar se existe o lote no local e produto conforme o arquivo...
							dbSelectArea("NNR")
							dbSetOrder(1)
							If !NNR->( dbSeek( xFilial("NNR") + aDados[1,nPosLocal,nI] ) )
								If !IsNumeric( aDados[1,nPosLocal,nI] )
									dbSelectArea("SB2")
									dbSetOrder(1)
									If !SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD ) ) // Se n�o existir local padr�o no saldo, busca outro local
										cQuery := "SELECT B2_LOCAL FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
										cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
										cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
										cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
										cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
										cQuery += "ORDER BY B2_QATU DESC " + CRLF
			
										TCQuery cQuery New Alias "TMPNNR"
										dbSelectArea("TMPNNR")
										TMPNNR->( dbGoTop() )
			
										If TMPNNR->( Eof() ) // Se n�o houver local para o produto, corre��o manual no item inventariado
											aAdd( aOcorrencia, {'Produto n�o encontrado no SB2 para um local v�lido', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
											lValido := .F.
										Else
											aDados[1,nPosLocal,nI] := TMPNNR->B2_LOCAL
										EndIf
			
										TMPNNR->( dbCloseArea() )
									Else
										aDados[1,nPosLocal,nI] := SB1->B1_LOCPAD
									EndIf
								Else
									If !NNR->( dbSeek( xFilial("NNR") + StrZero(Val(aDados[1,nPosLocal,nI]), 2) ) )
										dbSelectArea("SB2")
										dbSetOrder(1)
										If !SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD ) ) // Se n�o existir local padr�o no saldo, busca outro local
											cQuery := "SELECT B2_LOCAL FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
											cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
											cQuery += "AND B2_COD = '" + SB1->B1_COD + "' " + CRLF
											cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
											cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF
											cQuery += "ORDER BY B2_QATU DESC " + CRLF
				
											TCQuery cQuery New Alias "TMPNNR"
											dbSelectArea("TMPNNR")
											TMPNNR->( dbGoTop() )
				
											If TMPNNR->( Eof() ) // Se n�o houver local para o produto, corre��o manual no item inventariado
												aAdd( aOcorrencia, {'Produto n�o encontrado no SB2 para um local v�lido', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
												lValido := .F.
											Else
												aDados[1,nPosLocal,nI] := TMPNNR->B2_LOCAL
											EndIf
				
											TMPNNR->( dbCloseArea() )
										Else
											aDados[1,nPosLocal,nI] := SB1->B1_LOCPAD
										EndIf
									Else
										aDados[1,nPosLocal,nI] := StrZero(Val(aDados[1,nPosLocal,nI]), 2)
									EndIf
								EndIf
							EndIf

							cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
							cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
							cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
							cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
							cQuery += "AND B8_LOCAL = '" + aDados[1,nPosLocal,nI] + "' " + CRLF
							cQuery += "AND B8_LOTECTL = '" + AllTrim( aDados[1,nPosLote,nI] ) + "' " + CRLF
							cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
							cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
							cQuery += "ORDER BY B8_SALDO DESC " + CRLF

							TCQuery cQuery New Alias "TMPSB8"
							dbSelectArea("TMPSB8")
							TMPSB8->( dbGoTop() )

							If TMPSB8->( Eof() ) // Caso n�o encontre o local no lote e produto, verificar se o mesmo faltou zeros � esquerdas
								cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
								cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
								cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
								cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
								cQuery += "AND B8_LOCAL = '" + aDados[1,nPosLocal,nI] + "' " + CRLF
								cQuery += "AND B8_LOTECTL LIKE '%" + AllTrim( aDados[1,nPosLote,nI] ) + "' " + CRLF
								cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
								cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
								cQuery += "ORDER BY B8_SALDO DESC " + CRLF
		
								TCQuery cQuery New Alias "TMPACHE1"
								dbSelectArea("TMPACHE1")
								TMPACHE1->( dbGoTop() )

								If TMPACHE1->( Eof() ) // Se n�o achar o lote no produto e no local, procurar em qualquer local...
									cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
									cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
									cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
									cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
									cQuery += "AND B8_LOTECTL LIKE '%" + AllTrim( aDados[1,nPosLote,nI] ) + "' " + CRLF
									cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
									cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
									cQuery += "ORDER BY B8_SALDO DESC " + CRLF
			
									TCQuery cQuery New Alias "TMPACHE2"
									dbSelectArea("TMPACHE2")
									TMPACHE2->( dbGoTop() )
	
									If TMPACHE2->( Eof() ) // Se nem achar, gerar ocorrencia de erro para avalia��o e acerto manual
										cQuery := "SELECT B8_LOTECTL, B8_LOCAL FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
										cQuery += "WHERE B8_FILIAL = '" + xFilial("SB2") + "' " + CRLF
										cQuery += "AND B8_PRODUTO = '" + SB1->B1_COD + "' " + CRLF
										cQuery += "AND B8_LOTECTL LIKE '%" + AllTrim( Replace( Replace( aDados[1,nPosLote,nI], ".", "%"), "-", "%") ) + "' " + CRLF
										cQuery += "AND B8_LOCAL <> '" + AllTrim( GetMV("MV_CQ",,"01") ) + "' " + CRLF
										cQuery += "AND EXISTS (SELECT * FROM " + RetSqlName("NNR") + " AS NNR WITH (NOLOCK) WHERE NNR_FILIAL = '" + xFilial("NNR") + "' AND NNR_CODIGO = B8_LOCAL AND NNR.D_E_L_E_T_ = ' ') " + CRLF
										cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
										cQuery += "ORDER BY B8_SALDO DESC " + CRLF
			
										TCQuery cQuery New Alias "TMPACHE3"
										dbSelectArea("TMPACHE3")
										TMPACHE3->( dbGoTop() )
	
										If TMPACHE3->( Eof() ) // Se nem achar, gerar ocorrencia de erro para avalia��o e acerto manual
											//aAdd( aOcorrencia, {'Produto, Lote e Local n�o encontrado na base', AllTrim(aDados[1,nPosProduto,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
											//lValido := .F.
											aDados[1,nPosLocal,nI] := IIf( Empty(aDados[1,nPosLocal,nI]), SB1->B1_LOCPAD, aDados[1,nPosLocal,nI])
											aDados[1,nPosLote,nI]  := IIf( Empty(aDados[1,nPosLote,nI]), "LU", aDados[1,nPosLote,nI])

											If !SB2->( dbSeek( xFilial("SB2") + SB1->B1_COD + aDados[1,nPosLocal,nI] ) )
												RecLock("SB2", .T.)
													SB2->B2_FILIAL  := xFilial("SB2")
													SB2->B2_COD     := SB1->B1_COD
													SB2->B2_LOCAL   := aDados[1,nPosLocal,nI]
													SB2->B2_QATU    := 0
												MsUnlock()
											EndIf

											dbSelectArea("SB8")

										    RecLock("SB8", .T.)
												SB8->B8_FILIAL  := xFilial("SB8")
												SB8->B8_PRODUTO := SB1->B1_COD
												SB8->B8_LOCAL   := aDados[1,nPosLocal,nI]
												SB8->B8_LOTECTL := aDados[1,nPosLote,nI]
												SB8->B8_DATA    := dDataBase
												SB8->B8_DTVALID := dDataBase
												SB8->B8_QTDORI  := 0
												SB8->B8_SALDO   := 0
												SB8->B8_ORIGLAN := "MI"
											 	SB8->B8_DOC     := aDados[1,nPosFicha,nI]
											MsUnlock()
										Else
											aDados[1,nPosLocal,nI] := TMPACHE3->B8_LOCAL
											aDados[1,nPosLote,nI]  := TMPACHE3->B8_LOTECTL
										EndIf
	
										TMPACHE3->( dbCloseArea() )
									Else
										aDados[1,nPosLocal,nI] := TMPACHE2->B8_LOCAL
										aDados[1,nPosLote,nI]  := TMPACHE2->B8_LOTECTL
									EndIf
	
									TMPACHE2->( dbCloseArea() )
								Else
									aDados[1,nPosLote,nI]  := TMPACHE1->B8_LOTECTL
								EndIf

								TMPACHE1->( dbCloseArea() )
                            EndIf

							TMPSB8->( dbCloseArea() )
						EndIf
					EndIf
				EndIf
				
				If lValido
					If AllTrim( SB1->B1_LOCALIZ ) == "S"
						If Empty( aDados[1,nPosEndereco,nI] )
							aAdd( aOcorrencia, {'Endere�o em branco.', AllTrim(aDados[1,nPosEndereco,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
							lValido := .F.
						Else
							dbSelectArea("SBE")
							dbSetOrder(1)
							If !SBE->( dbSeek( xFilial("SBE") + aDados[1,nPosLocal,nI] + Padr( aDados[1,nPosEndereco,nI],TamSX3("BE_LOCALIZ")[1] ) ) )
								// Verificar se informaram tra�os "-" no endere�o...
								If !SBE->( dbSeek( xFilial("SBE") + aDados[1,nPosLocal,nI] + Padr( Replace( aDados[1,nPosEndereco,nI], "-", ""), TamSX3("BE_LOCALIZ")[1] ) ) )
									// Verificar se informaram alem de tra�os "-", pontos "." no endere�o...
									If !SBE->( dbSeek( xFilial("SBE") + aDados[1,nPosLocal,nI] + Padr( Replace( Replace( aDados[1,nPosEndereco,nI], "-", ""), ".", ""),TamSX3("BE_LOCALIZ")[1] ) ) )
										// Caso n�o encontrado endere�o no local... verificar o endere�o e se achar, corrigir o local...
										cQuery := "SELECT BE_LOCAL, BE_LOCALIZ " + CRLF
										cQuery += "FROM " + RetSqlName("SBE") + " AS SBE WITH (NOLOCK) " + CRLF
										cQuery += "WHERE BE_FILIAL = '" + xFilial("SBE") + "' " + CRLF
										cQuery += "AND BE_LOCALIZ = '" + AllTrim( Replace( Replace( aDados[1,nPosEndereco,nI], "-", ""), ".", "") ) + "' " + CRLF
										cQuery += "AND SBE.D_E_L_E_T_ = ' ' " + CRLF

										TCQuery cQuery New Alias "TMPSBE"
										dbSelectArea("TMPSBE")
										TMPSBE->( dbGoTop() )
		
										If TMPSBE->( Eof() ) // N�o encontrou nem assim, gera ocorrencia...
											aAdd( aOcorrencia, {'Endere�o informado n�o existe.', AllTrim(aDados[1,nPosEndereco,nI]), "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
											lValido := .F.
										Else
											aDados[1,nPosLocal,nI]    := TMPSBE->BE_LOCAL
											aDados[1,nPosEndereco,nI] := TMPSBE->BE_LOCALIZ
										EndIf

										TMPSBE->( dbCloseArea() )
									Else
										aDados[1,nPosEndereco,nI]  := SBE->BE_LOCALIZ
									EndIf
								Else
									aDados[1,nPosEndereco,nI]  := SBE->BE_LOCALIZ
								EndIf
							EndIf
						EndIf
					Else
						aDados[1,nPosEndereco,nI] := Replace( Replace( Replace( Replace( aDados[1,nPosEndereco,nI], ".", ""), "-", ""), "/", ""), "|", "")
						aDados[1,nPosEndereco,nI] := AllTrim( Upper( Replace( Replace( aDados[1,nPosEndereco,nI], ".", ""), " ", "") ) )
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	// Inserir a Contagem do Invent�rio para Formata��o da Matriz...
	cQuery := "INSERT INTO CONTAGEM_INVENTARIO VALUES ('" + DTOS( dDataInv ) + "', "
	cQuery +=                                         "'" + Left(cFilAnt,2) + "', "
	cQuery +=                                         "'" + Right(cFilAnt,2) + "', "
	cQuery +=                                         "'" + aDados[1,nPosFicha,nI] + "', "
	cQuery +=                                         "'" + aDados[1,nPosProduto,nI] + "', "
	cQuery +=                                         "'" + aDados[1,nPosLocal,nI] + "', "
	cQuery +=                                         "'" + aDados[1,nPosLote,nI] + "', "
	cQuery +=                                         "'" + aDados[1,nPosEndereco,nI] + "', "
	cQuery +=                                         ""  + AllTrim(Str(aDados[1,nPosQuant,nI])) + ", "
	cQuery +=                                         "'" + aDados[1,nPosEquipe,nI] + "', "
	cQuery +=                                         "'" + DTOS(aDados[1,nPosValidade,nI]) + "', "
	cQuery +=                                         "" + AllTrim(Str(aDados[1,nPosContagem,nI])) + ", "
	cQuery +=                                         "'" + aDados[1,nPosDigitador,nI] + "') "

	TCSqlExec( cQuery )
Next

For nI := 1 To nRegs
	IncProc( "Equalizando dados com terceira contagem: " + StrZero( nI, 6) )

	If aDados[1,nPosContagem,nI] <> 3
		cQuery := "SELECT * " + CRLF
		cQuery += "FROM CONTAGEM_INVENTARIO WITH (NOLOCK) " + CRLF
		cQuery += "WHERE EMPRESA = '" + Left(cFilAnt,2) + "' " + CRLF
		cQuery += "AND FILIAL = '" + Right(cFilAnt,2) + "' " + CRLF
		cQuery += "AND FICHA = '" + AllTrim( aDados[1,nPosFicha,nI] ) + "' " + CRLF
		cQuery += "AND DATA_INVENTARIO = '" + DTOS( dDataInv ) + "' " + CRLF
		cQuery += "AND CONTAGEM = 3 " + CRLF
		cQuery += "ORDER BY FICHA, PRODUTO, LOTE " + CRLF
	
		TCQuery cQuery New Alias "TMPCU"
		dbSelectArea("TMPCU")
		dbGoTop()

		// Se quantidade diferente...
		If !TMPCU->( Eof() )
			aAdd( aTerceira, {'Eliminar Ocorrencia', "", "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		EndIf

		TMPCU->( dbCloseArea() )
	EndIf
Next

aApurado := {}

For nI := 1 To nRegs
	lValido  := .T.
	nPosicao := 0

	IncProc( "Acumulando para Apura��o: " + StrZero( nI + 1, 6) )

	If aDados[1,nPosQuant,nI] > 0 // Somente apurar contagens com quantidade informada...
		nPosicao := aScan( aApurado, {|x| AllTrim(x[1]) == AllTrim(aDados[1,nPosFicha,nI]) .And. ;
		                                  AllTrim(x[2]) == AllTrim(aDados[1,nPosProduto,nI]) .And. ;
		                                  AllTrim(x[3]) == AllTrim(aDados[1,nPosLocal,nI]) .And. ;
		                                  AllTrim(x[4]) == AllTrim(aDados[1,nPosLote,nI]) })
	
		If nPosicao == 0
			aAdd( aApurado, { 	aDados[1,nPosFicha,nI],;												// 01 - Ficha
								aDados[1,nPosProduto,nI],;												// 02 - Produto
								aDados[1,nPosLocal,nI],;												// 03 - Local
								aDados[1,nPosLote,nI],;													// 04 - Lote
								aDados[1,nPosEndereco,nI],;												// 05 - Endere�o
								IIf(aDados[1,nPosContagem,nI] == 1, aDados[1,nPosQuant,nI], 0),;		// 06 - Quantidade 1a Contagem
								IIf(aDados[1,nPosContagem,nI] == 1, aDados[1,nPosEquipe,nI], ""),;		// 07 - Equipe 1a Contagem
								IIf(aDados[1,nPosContagem,nI] == 1, aDados[1,nPosDigitador,nI], ""),;	// 08 - Digitador 1a Contagem
								IIf(aDados[1,nPosContagem,nI] == 2, aDados[1,nPosQuant,nI], 0),;		// 09 - Quantidade 2a Contagem
								IIf(aDados[1,nPosContagem,nI] == 2, aDados[1,nPosEquipe,nI], ""),;		// 10 - Equipe 2a Contagem
								IIf(aDados[1,nPosContagem,nI] == 2, aDados[1,nPosDigitador,nI], ""),;	// 11 - Digitador 1a Contagem
								IIf(aDados[1,nPosContagem,nI] == 3, aDados[1,nPosQuant,nI], 0),;		// 12 - Quantidade 2a Contagem
								IIf(aDados[1,nPosContagem,nI] == 3, aDados[1,nPosEquipe,nI], ""),;		// 13 - Equipe 2a Contagem
								IIf(aDados[1,nPosContagem,nI] == 3, aDados[1,nPosDigitador,nI], ""),;	// 14 - Digitador 1a Contagem
								aDados[1,nPosValidade,nI] })											// 15 - Validade Lote
		Else
			If AllTrim( aApurado[nPosicao][05] ) <> AllTrim( aDados[1,nPosEndereco,nI] ) //If AllTrim( aApurado[nPosicao][05] ) == AllTrim( aDados[1,nPosEndereco,nI] )
				If Empty( aApurado[nPosicao][05] ) .Or. !(AllTrim( Upper( aApurado[nPosicao][05] ) ) == "SALA" .And. !Empty( aDados[1,nPosEndereco,nI] )) //If Empty( aApurado[nPosicao][05] ) .Or. !(AllTrim( Upper( aDados[1,nPosEndereco,nI] ) ) == "SALA" .And. !Empty( aApurado[nPosicao][05] ))
					aApurado[nPosicao][05] := AllTrim( aDados[1,nPosEndereco,nI] )
				Else
					//// Trata se Ficha j� foi utilizada em outro endere�o...
					//aAdd( aOcorrencia, {'Ficha utilizada em outro endere�o, verifique.', 'Digita��o ou Processo Indevido', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
					//lValido := .F.
				EndIf
			EndIf
	
			If aDados[1,nPosContagem,nI] == 1
				If aApurado[nPosicao][06] > 0 .And. !Empty(aApurado[nPosicao][07])
					If aApurado[nPosicao][06] <> aDados[1,nPosQuant,nI]
						//aAdd( aOcorrencia, {'Primeira contagem da Ficha Digitado 2 vezes, verifique!', 'Digita��o ou Processo Indevido', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
						//lValido := .F.
						aApurado[nPosicao][06] += aDados[1,nPosQuant,nI]
					EndIf
				Else
					aApurado[nPosicao][06] := aDados[1,nPosQuant,nI]
					aApurado[nPosicao][07] := aDados[1,nPosEquipe,nI]
					aApurado[nPosicao][08] := aDados[1,nPosDigitador,nI]
				EndIf
			Else
				If aDados[1,nPosContagem,nI] == 2
					If aApurado[nPosicao][09] > 0 .And. !Empty(aApurado[nPosicao][10])
						If aApurado[nPosicao][09] <> aDados[1,nPosQuant,nI]
							//aAdd( aOcorrencia, {'Segunda contagem da Ficha Digitado 2 vezes, verifique!', 'Digita��o ou Processo Indevido', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
							//lValido := .F.
							aApurado[nPosicao][09] += aDados[1,nPosQuant,nI]
						EndIf
					Else
						aApurado[nPosicao][09] := aDados[1,nPosQuant,nI]
						aApurado[nPosicao][10] := aDados[1,nPosEquipe,nI]
						aApurado[nPosicao][11] := aDados[1,nPosDigitador,nI]
					EndIf
				Else
					If aApurado[nPosicao][12] > 0 .And. !Empty(aApurado[nPosicao][13])
						If aApurado[nPosicao][12] <> aDados[1,nPosQuant,nI]
							//aAdd( aOcorrencia, {'Terceira contagem da Ficha Digitado 2 vezes, verifique!', 'Digita��o ou Processo Indevido', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
							//lValido := .F.
							aApurado[nPosicao][12] += aDados[1,nPosQuant,nI]
						EndIf
					Else
						aApurado[nPosicao][12] := aDados[1,nPosQuant,nI]
						aApurado[nPosicao][13] := aDados[1,nPosEquipe,nI]
						aApurado[nPosicao][14] := aDados[1,nPosDigitador,nI]
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next

For nI := 1 To Len( aApurado )
	lValido := .T.

	IncProc( "Apurando resultados das contagens: " + StrZero( nI, 6) )

	/*
	If aApurado[nI][06] == 0 .And. Empty( aApurado[nI][07] ) .And. Empty( aApurado[nI][08] )
		aAdd( aOcorrencia, {'Faltando 1a Contagem da Ficha', 'Conferir Fichas e Digitar', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
		lValido := .F.
	Else
		If aApurado[nI][09] == 0 .And. Empty( aApurado[nI][10] ) .And. Empty( aApurado[nI][11] )
			aAdd( aOcorrencia, {'Faltando 2a Contagem da Ficha', 'Conferir Fichas e Digitar', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
			lValido := .F.
		Else
			// Se n�o houve terceira contagem...
			If aApurado[nI][12] == 0 .And. Empty( aApurado[nI][13] ) .And. Empty( aApurado[nI][14] )
				If aApurado[nI][06] <> aApurado[nI][09]
					// Se quantidade diferente...
					aAdd( aOcorrencia, {'Quantidade 1a e 2a Contagem Divergente.', 'Efetuar Terceira Contagem/Conferir Fichas.', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
					lValido := .F.
				ElseIf AllTrim( aApurado[nI][07] ) == AllTrim( aApurado[nI][10] ) .And. lValEquip
					// Se Equipe Igual...
					aAdd( aOcorrencia, {'Equipe 1a e 2a Contagem Igual.', 'Efetuar Terceira Contagem/Conferir Fichas.', "", nI + 1, cFile, AllTrim(aDados[1,nPosEmpresa,nI]), AllTrim(aDados[1,nPosFilial,nI]), AllTrim(aDados[1,nPosFicha,nI]), AllTrim(aDados[1,nPosProduto,nI]), AllTrim(aDados[1,nPosLocal,nI]), AllTrim(aDados[1,nPosLote,nI]), AllTrim(aDados[1,nPosEndereco,nI]), Str(aDados[1,nPosQuant,nI]), AllTrim(aDados[1,nPosEquipe,nI]), AllTrim(Str(aDados[1,nPosContagem,nI]))})
					lValido := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	*/

	// Inserir a Apura��o do Invent�rio para Formata��o da Matriz...
	cQuery := "INSERT INTO APURACAO_INVENTARIO VALUES ('" + DTOS( dDataInv ) + "', "
	cQuery +=                                         "'" + Left(cFilAnt,2) + "', "
	cQuery +=                                         "'" + Right(cFilAnt,2) + "', "
	cQuery +=                                         "'" + aApurado[nI][01] + "', "
	cQuery +=                                         "'" + aApurado[nI][02] + "', "
	cQuery +=                                         "'" + aApurado[nI][03] + "', "
	cQuery +=                                         "'" + aApurado[nI][04] + "', "
	cQuery +=                                         "'" + aApurado[nI][05] + "', "
	cQuery +=                                         "" + AllTrim(Str(aApurado[nI][06])) + ", "
	cQuery +=                                         "'" + aApurado[nI][07] + "', "
	cQuery +=                                         "'" + aApurado[nI][08] + "', "
	cQuery +=                                         "" + AllTrim(Str(aApurado[nI][09])) + ", "
	cQuery +=                                         "'" + aApurado[nI][10] + "', "
	cQuery +=                                         "'" + aApurado[nI][11] + "', "
	cQuery +=                                         "" + AllTrim(Str(aApurado[nI][12])) + ", "
	cQuery +=                                         "'" + aApurado[nI][13] + "', "
	cQuery +=                                         "'" + aApurado[nI][14] + "', "
	cQuery +=                                         "'" + DTOS( aApurado[nI][15] ) + "') "

	TCSqlExec( cQuery )
Next

/*
cQuery := "SELECT * FROM APURACAO_INVENTARIO WHERE DATA_INVENTARIO = '" + DTOS( dDataInv ) + "' AND EMPRESA = '" + Left(cFilAnt,2) + "' AND FILIAL = '" + Right(cFilAnt,2) + "' "
TCQuery cQuery New Alias "APURACAO"
dbSelectArea("APURACAO")
dbGoTop()

Do While !APURACAO->( Eof() )
	//If APURACAO->QUANT_PRI == 0 .And. Empty( APURACAO->EQUIPE_PRI )
	//	aAdd( aOcorrencia, {'Faltando 1a Contagem da Ficha', 'Conferir Fichas e Digitar', "", nI + 1, cFile, AllTrim(APURACAO->EMPRESA), AllTrim(APURACAO->FILIAL), AllTrim(APURACAO->FICHA), AllTrim(APURACAO->PRODUTO), AllTrim(APURACAO->ARMAZEM), AllTrim(APURACAO->LOTE), AllTrim(APURACAO->ENDERECO), Str(APURACAO->QUANT_PRI), AllTrim(APURACAO->EQUIPE_PRI), "0"})
	//	lValido := .F.
	//Else
	//	If APURACAO->QUANT_SEG == 0 .And. Empty( APURACAO->EQUIPE_SEG )
	//		aAdd( aOcorrencia, {'Faltando 2a Contagem da Ficha', 'Conferir Fichas e Digitar', "", nI + 1, cFile, AllTrim(APURACAO->EMPRESA), AllTrim(APURACAO->FILIAL), AllTrim(APURACAO->FICHA), AllTrim(APURACAO->PRODUTO), AllTrim(APURACAO->ARMAZEM), AllTrim(APURACAO->LOTE), AllTrim(APURACAO->ENDERECO), Str(APURACAO->QUANT_PRI), AllTrim(APURACAO->EQUIPE_PRI), "0"})
	//		lValido := .F.
	//	Else
	//		// Se n�o houve terceira contagem...
	//		If APURACAO->QUANT_TER == 0 .And. Empty( APURACAO->EQUIPE_TER )
	//			If APURACAO->QUANT_PRI <> APURACAO->QUANT_SEG
	//				// Se quantidade diferente...
	//				aAdd( aOcorrencia, {'Quantidade 1a e 2a Contagem Divergente.', 'Efetuar Terceira Contagem/Conferir Fichas.', "", nI + 1, cFile, AllTrim(APURACAO->EMPRESA), AllTrim(APURACAO->FILIAL), AllTrim(APURACAO->FICHA), AllTrim(APURACAO->PRODUTO), AllTrim(APURACAO->ARMAZEM), AllTrim(APURACAO->LOTE), AllTrim(APURACAO->ENDERECO), Str(APURACAO->QUANT_PRI), AllTrim(APURACAO->EQUIPE_PRI), "0"})
	//				lValido := .F.
	//			EndIf
	//		EndIf
	//	EndIf
	//EndIf

	APURACAO->( dbSkip() )
EndDo

APURACAO->( dbCloseArea() )
*/

If Len( aTerceira ) == Len( aOcorrencia ) .And. Len( aApurado ) > 0
	aOcorrencia := {}
EndIf

//������������������������������������������������������������������������Ŀ
//� N�o permitir gerar invent�rio se houver ocorr�ncia...                  �
//��������������������������������������������������������������������������
If Len( aOcorrencia ) > 0
	_nFile := MsFCreate( cArqErro )

	cMensagem := ""
	cAssunto  := "INVENT�RIO: Importa��o das Contagens com diverg�ncias: " + AllTrim( SM0->M0_NOME )

	aCabec := {}
	aAdd( aCabec, {{'<B><Font Size=4 color=white>Log do Evento</Font></B>', '6', 100, 6, 'C'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Empresa</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + SM0->M0_NOMECOM  + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Filial</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + SM0->M0_FILIAL + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Data</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + DTOC( MsDate() ) + '</Font>', '1', 40, 2, 'L'},{'<B><Font Size=2 color=black>Hora</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + Time() + '</Font>', '1', 40, 2, 'L'}})
	aAdd( aCabec, {{'<B><Font Size=2 color=black>Arquivo</Font></B>', '2', 10, 0, 'L'}, {'<Font Size=2 color=black>' + AllTrim( cFile ) + '</Font>', '1', 90, 5, 'L'}})

	aAdd( aCabec, {{'<B><Font Size=4 color=white>Ocorr�ncias</Font></B>', '6', 100, 6, 'C'}})

	aColunas := {}
	aAdd( aColunas, {'Descri��o'				, 15	, 'C'})
	aAdd( aColunas, {'A��o'						, 10	, 'C'})
	aAdd( aColunas, {'Linha'					, 05	, 'C'})
	aAdd( aColunas, {'Empresa'					, 05	, 'C'})
	aAdd( aColunas, {'Filial'					, 05	, 'C'})
	aAdd( aColunas, {'Ficha'					, 05	, 'C'})
	aAdd( aColunas, {'Produto'					, 05	, 'C'})
	aAdd( aColunas, {'Local'					, 05	, 'C'})
	aAdd( aColunas, {'Lote'						, 05	, 'C'})
	aAdd( aColunas, {'Endere�o'					, 05	, 'C'})
	aAdd( aColunas, {'Quantidade'				, 05	, 'C'})
	aAdd( aColunas, {'Equipe'					, 05	, 'C'})
	aAdd( aColunas, {'Contagem'					, 05	, 'C'})

	cMensagem += U_BeHtmHead( '',.T.,aCabec, aColunas )

	FlushFile(_nFile, @cMensagem, 0)

	For nI := 1 To Len( aOcorrencia )
		If aScan( aTerceira, {|e| e[4] == aOcorrencia[nI][04] }) == 0
			aColunas := {}
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][01] )		, 12	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][02] )		, 05	, 'L'})
			aAdd( aColunas, {StrZero( aOcorrencia[nI][04], 6)	, 05	, 'R'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][06] )		, 05	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][07] )	  	, 05	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][08] ) 	, 05	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][09] )		, 05	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][10] )		, 05	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][11] )		, 08	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][12] )		, 05	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][13] )		, 05	, 'R'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][14] )		, 05	, 'L'})
			aAdd( aColunas, {AllTrim( aOcorrencia[nI][15] )		, 05	, 'R'})
			
			cMensagem += U_BeHtmDet( aColunas, ((nI % 2) == 0) , .F. )
			
			FlushFile(_nFile, @cMensagem, 0)
		EndIf
	Next

	cMensagem += U_BeHtmRod(.T.)

	FlushFile(_nFile, @cMensagem, 0)

	FClose(_nFile)

	ShellExecute( "open", AllTrim( cArqErro ), "", "C:\temp\", 1)

	lRetorno := .F.
Else
	For nI := 1 To Len( aApurado )
		IncProc( "Gerando Lan�amentos do Invent�rio Apurados: " + StrZero( nI, 6) )

		cObservacao := "INVENTARIO JUN/2019 JANDIRA"
		cDocumento  := ""
		cProduto    := ""
		cLocal      := ""
		cLote       := ""
		cEndereco   := ""
		cEquipe     := ""
		cContagem   := ""
		nQuantidade := 0
		nConta      := 0
		aVetor      := {}
		lValido     := .T.

		cDocumento  := Right( "000000" + AllTrim( aApurado[nI][01] ), 6 )

		dbSelectArea("SB1")
		dbSetOrder(1)
		If SB1->( dbSeek( xFilial("SB1") + aApurado[nI][02] ) )
			cProduto := SB1->B1_COD
		Else
			cProduto := Padr( aApurado[nI][02], TamSX3("B1_COD")[1])
		EndIf

		dbSelectArea("SB2")
		dbSetOrder(1)
		If SB2->( dbSeek( xFilial("SB2") + cProduto + aApurado[nI][03] ) )
			cLocal := SB2->B2_LOCAL
		Else
			cLocal := Padr( aApurado[nI][03], TamSX3("B2_LOCAL")[1])
		EndIf

		If SB1->B1_RASTRO <> "N"
			dbSelectArea("SB8")
			dbSetOrder(3)
			If SB8->( dbSeek( xFilial("SB8") + cProduto + cLocal + aApurado[nI][04] ) )
				cLote := SB8->B8_LOTECTL
			Else
				cLote := Padr( aApurado[nI][04], TamSX3("B8_LOTECTL")[1])
			EndIf
		EndIf

		If SB1->B1_LOCALIZ <> "N"
			dbSelectArea("SBE")
			dbSetOrder(1)
			If SBE->( dbSeek( xFilial("SBE") + cLocal + aApurado[nI][05] ) )
				cEndereco := SBE->BE_LOCALIZ
			Else
				cEndereco := Padr( aApurado[nI][05], TamSX3("BE_LOCALIZ")[1])
			EndIf
		EndIf

		//If aApurado[nI][06] == aApurado[nI][09] .And. aApurado[nI][12] == 0
		If aApurado[nI][12] == 0
			nQuantidade := aApurado[nI][09]
			cEquipe     := "[" + AllTrim(aApurado[nI][07]) + "/" + AllTrim(aApurado[nI][10]) + "]"
			cContagem   := "002"
		Else
			nQuantidade := aApurado[nI][12]
			cEquipe     := "[" + AllTrim(aApurado[nI][07]) + "/" + AllTrim(aApurado[nI][10]) + "/" + AllTrim(aApurado[nI][13]) + "]"
			cContagem   := "003"
		EndIf

		dbSelectArea("SB7")
		dbSetOrder(1)

		/*
		aVetor := {}

		aVetor :=   {;
		            {"B7_FILIAL"	, xFilial("SB7")						,Nil},;
		            {"B7_DOC"		, cDocumento							,Nil},;
		            {"B7_COD"		, cProduto								,Nil},;
		            {"B7_QUANT"		, nQuantidade							,Nil},;
		            {"B7_LOCAL"		, cLocal								,Nil},;
		            {"B7_LOTECTL"	, cLote									,Nil},;
		            {"B7_LOCALIZ"	, cEndereco								,Nil},;
		            {"B7_OBS"		, cObservacao							,Nil},;
		            {"B7_CONTAGE"	, cContagem								,Nil},;
		            {"B7_ORIGEM"	, "MATA270"								,Nil},;
		            {"B7_DATA"		, dDataInv								,Nil}}

		MSExecAuto({|x,y,z| MATA270(x,y,z)}, aVetor, .T., 3)

		If lMsErroAuto
			DisarmTransaction()
		    MostraErro()
			lRetorno := .F.
			ApMsgAlert("Documento: " + cDocumento)
		    Return lRetorno
		EndIf
		*/
		dbSelectArea("SB7")

		RecLock("SB7", .T.)
			SB7->B7_FILIAL  := xFilial("SB7")
			SB7->B7_DOC     := cDocumento
			SB7->B7_COD     := cProduto
			SB7->B7_TIPO    := SB1->B1_TIPO
			SB7->B7_QUANT   := nQuantidade
			SB7->B7_QTSEGUM := ConvUM( SB1->B1_COD, nQuantidade, 0, 2)
			SB7->B7_ESCOLHA := "S"
			SB7->B7_STATUS  := "1"
			SB7->B7_LOCAL   := cLocal
			SB7->B7_LOTECTL := cLote
			If SB1->B1_RASTRO <> "N"
				If !Empty( cLote )
					dbSelectArea("SB8")
					dbSetOrder(3)
					If SB8->( dbSeek( xFilial("SB8") + cProduto + cLocal + cLote ) )
						SB7->B7_NUMDOC  := SB8->B8_DOC
						SB7->B7_DTVALID := SB8->B8_DTVALID
						SB7->B7_NUMDOC  := SB8->B8_DOC
						SB7->B7_NUMLOTE := SB8->B8_NUMLOTE
						SB7->B7_FORNECE := SB8->B8_CLIFOR
						SB7->B7_LOJA    := SB8->B8_LOJA
					EndIf
				EndIf
			EndIf
			SB7->B7_LOCALIZ := cEndereco
			SB7->B7_OBS     := cObservacao
			SB7->B7_CONTAGE := cContagem
			SB7->B7_ORIGEM  := "MATA270"
			SB7->B7_DATA    := dDataInv
		MsUnLock()
	Next

	cQuery := "SELECT BF_FILIAL, BF_PRODUTO, BF_LOCAL, BF_LOTECTL, BF_LOCALIZ " + CRLF
	cQuery += "FROM " + RetSqlName("SBF") + " AS SBF WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = BF_PRODUTO " + CRLF
	cQuery += "  AND NOT (B1_COD = 'MP.0001' OR LEFT( B1_COD, 2) IN ('XA','XS')) " + CRLF
	cQuery += "  AND B1_LOCALIZ = 'S' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE BF_FILIAL = '" + xFilial("SBF") + "' " + CRLF
	cQuery += "AND BF_QUANT <> 0 " + CRLF
	cQuery += "AND BF_LOCAL <> '99' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SB7") + " WITH (NOLOCK) WHERE B7_FILIAL = BF_FILIAL AND B7_COD = BF_PRODUTO AND B7_LOCAL = BF_LOCAL AND B7_LOTECTL = BF_LOTECTL AND B7_LOCALIZ = BF_LOCALIZ AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SBF.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT B8_FILIAL AS BF_FILIAL, B8_PRODUTO AS BF_PRODUTO, B8_LOCAL AS BF_LOCAL, B8_LOTECTL AS BF_LOTECTL, '' AS BF_LOCALIZ " + CRLF
	cQuery += "FROM " + RetSqlName("SB8") + " AS SB8 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B8_PRODUTO " + CRLF
	cQuery += "  AND NOT (B1_COD = 'MP.0001' OR LEFT( B1_COD, 2) IN ('XA','XS')) " + CRLF
	cQuery += "  AND B1_LOCALIZ <> 'S' " + CRLF
	cQuery += "  AND B1_RASTRO <> 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
	cQuery += "AND B8_LOCAL <> '99' " + CRLF
	cQuery += "AND B8_SALDO <> 0 " + CRLF
	cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SB7") + " WITH (NOLOCK) WHERE B7_FILIAL = B8_FILIAL AND B7_COD = B8_PRODUTO AND B7_LOCAL = B8_LOCAL AND B7_LOTECTL = B8_LOTECTL AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SB8.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "UNION ALL " + CRLF
	cQuery += "SELECT B2_FILIAL AS BF_FILIAL, B2_COD AS BF_PRODUTO, B2_LOCAL AS BF_LOCAL, '' AS BF_LOTECTL, '' AS BF_LOCALIZ " + CRLF
	cQuery += "FROM " + RetSqlName("SB2") + " AS SB2 WITH (NOLOCK) " + CRLF
	cQuery += "INNER JOIN " + RetSqlName("SB1") + " AS SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQuery += "  AND B1_COD = B2_COD " + CRLF
	cQuery += "  AND NOT (B1_COD = 'MP.0001' OR LEFT( B1_COD, 2) IN ('XA','XS')) " + CRLF
	cQuery += "  AND B1_LOCALIZ <> 'S' " + CRLF
	cQuery += "  AND B1_RASTRO = 'N' " + CRLF
	cQuery += "  AND SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE B2_FILIAL = '" + xFilial("SB2") + "' " + CRLF
	cQuery += "AND B2_QATU <> 0 " + CRLF
	cQuery += "AND B2_LOCAL <> '99' " + CRLF
	cQuery += "AND NOT EXISTS (SELECT * FROM " + RetSqlName("SB7") + " WITH (NOLOCK) WHERE B7_FILIAL = B2_FILIAL AND B7_COD = B2_COD AND B7_LOCAL = B2_LOCAL AND D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "AND SB2.D_E_L_E_T_ = ' ' " + CRLF

	TCQuery cQuery New Alias "TMPZERA"
	dbSelectArea("TMPZERA")
	dbGoTop()

	nTotZer := TMPZERA->( RecCount() )

	Do While !TMPZERA->( Eof() )
		nConta++
		IncProc( "Zerando itens n�o Apurados - " + StrZero( nConta, 6) + " de " + StrZero( nTotZer, 6) )

		dbSelectArea("SB1")
		dbSetOrder(1)
		SB1->( dbSeek( xFilial("SB1") + TMPZERA->BF_PRODUTO ) )

		If AllTrim( SB1->B1_MSBLQL ) == "1"
			dbSelectArea("SB1")
			//RecLock("SB1", .F.)
			//	SB1->B1_MSBLQL := "2"
			//MsUnLock()
			ConOut("Desbloqueio Produto: " + SB1->B1_COD + " para Invent�rio")
		EndIf

		dbSelectArea("SB7")
		dbSetOrder(1)

		/*
		aVetor :=   {;
		            {"B7_FILIAL"	, xFilial("SB7")						,Nil},;
		            {"B7_DOC"		, "000000"								,Nil},;
		            {"B7_COD"		, TMPZERA->BF_PRODUTO					,Nil},;
		            {"B7_QUANT"		, 0										,Nil},;
		            {"B7_LOCAL"		, TMPZERA->BF_LOCAL						,Nil},;
		            {"B7_LOTECTL"	, TMPZERA->BF_LOTECTL					,Nil},;
		            {"B7_LOCALIZ"	, TMPZERA->BF_LOCALIZ					,Nil},;
		            {"B7_OBS"		, cObservacao							,Nil},;
		            {"B7_CONTAGE"	, "000"									,Nil},;
		            {"B7_ORIGEM"	, "MATA270"								,Nil},;
		            {"B7_DATA"		, dDataInv								,Nil}}

		MSExecAuto({|x,y,z| MATA270(x,y,z)}, aVetor, .T., 3)

		If lMsErroAuto
			DisarmTransaction()
		    MostraErro()
			lRetorno := .F.
		    Return lRetorno
		EndIf
		*/

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek( xFilial("SB1") + TMPZERA->BF_PRODUTO )

		RecLock("SB7", .T.)
			SB7->B7_FILIAL  := xFilial("SB7")
			SB7->B7_DOC     := "000000"
			SB7->B7_COD     := TMPZERA->BF_PRODUTO
			SB7->B7_TIPO    := SB1->B1_TIPO
			SB7->B7_QUANT   := 0
			SB7->B7_QTSEGUM := 0
			SB7->B7_ESCOLHA := "S"
			SB7->B7_STATUS  := "1"
			SB7->B7_LOCAL   := TMPZERA->BF_LOCAL
			SB7->B7_LOTECTL := TMPZERA->BF_LOTECTL
			If SB1->B1_RASTRO <> "N"
				If !Empty( cLote )
					dbSelectArea("SB8")
					dbSetOrder(3)
					If SB8->( dbSeek( xFilial("SB8") + TMPZERA->BF_PRODUTO + TMPZERA->BF_LOCAL + TMPZERA->BF_LOTECTL ) )
						SB7->B7_NUMDOC  := SB8->B8_DOC
						SB7->B7_DTVALID := SB8->B8_DTVALID
						SB7->B7_NUMDOC  := SB8->B8_DOC
						SB7->B7_NUMLOTE := SB8->B8_NUMLOTE
						SB7->B7_FORNECE := SB8->B8_CLIFOR
						SB7->B7_LOJA    := SB8->B8_LOJA
					EndIf
				EndIf
			EndIf
			SB7->B7_LOCALIZ := TMPZERA->BF_LOCALIZ
			SB7->B7_OBS     := cObservacao
			SB7->B7_CONTAGE := "000"
			SB7->B7_ORIGEM  := "MATA270"
			SB7->B7_DATA    := dDataInv
		MsUnLock()

		TMPZERA->( dbSkip() )
	EndDo

	TMPZERA->( dbCloseArea() )
EndIf

Return lRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ValidPerg�Autor  � Fabio F Sousa      � Data � 26/04/2016  ���
�������������������������������������������������������������������������͹��
���Desc.     � Par�metros da rotina...                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Beraca Sabara                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := PADR( cPerg, Len(SX1->X1_GRUPO))

aAdd( aPerg, { cPerg, "01", "Data de Invent�rio  ?", "MV_CH1" , "D", 08, 0, "G", "MV_PAR01", "", "", "", "", "", ""})
aAdd( aPerg, { cPerg, "02", "Contagem            ?", "MV_CH2" , "N", 03, 0, "G", "MV_PAR02", "", "", "", "", "", ""})

dbSelectArea("SX1")
dbSetOrder(1)

For i := 1 To Len(aPerg)
	If  !dbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIf
	Replace X1_GRUPO   With aPerg[i,01]
	Replace X1_ORDEM   With aPerg[i,02]
	Replace X1_PERGUNT With aPerg[i,03]
	Replace X1_VARIAVL With aPerg[i,04]
	Replace X1_TIPO	   With aPerg[i,05]
	Replace X1_TAMANHO With aPerg[i,06]
	Replace X1_PRESEL  With aPerg[i,07]
	Replace X1_GSC	   With aPerg[i,08]
	Replace X1_VAR01   With aPerg[i,09]
	Replace X1_F3	   With aPerg[i,10]
	Replace X1_DEF01   With aPerg[i,11]
	Replace X1_DEF02   With aPerg[i,12]
	Replace X1_DEF03   With aPerg[i,13]
	Replace X1_DEF04   With aPerg[i,14]
	Replace X1_VALID   With aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)

Static Function FlushFile(_nFile, cMsg, nMaxSize)

Default nMaxSize := 50 * 1024 //50KB

FWrite(_nFile, cMsg)
cMsg := ""

Return Nil