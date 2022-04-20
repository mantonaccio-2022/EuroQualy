#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BeHtmMod2�Autor  � Fabio F Sousa       � Data �  04/07/13  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cabe�alho do HTML                                          ���
���          � Par�metros:                                                ���
���          �     _cTitulo                                               ���
���          �     _aColuna                                               ���
���          �     _lImagem                                               ���
���          �     _aTitulos                                              ���
���          �     _cImg2                                                 ���
���          �     _nWidth                                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Grupo Sabara                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*
Cabe�alho do HTML - Espec�fico para tratamentos de e-commerce da BASF
Par�metros da Fun��o:
_cTitulo  -> T�tulo do Html informado ao lado da imagem
_aColuna  -> Cabe�alho da tabela HTML
			{ 1 - Texto que ir� no cabe�alho da coluna da tabela;
			  2 - Atributo Width para o tamanho da coluna na tabela;
			  3 - Atributo Align para o alinhamento do texto na coluna da tabela}
_lImagem  -> Conte�do verdadeiro para exibir a imagem do logotipo da TN
_aTitulos -> Gera tabela com linhas e colunas antes do cabe�alho da tabela de detalhes
			{ 1 - Texo que ir� na coluna desejada;
			  2 - Define cor de fundo para a coluna at� 5 op��es de cores;
			  3 - Atributo Width para o tamanho da coluna na tabela;
			  4 - Atributo ColSpan para espa�amentos em mais de uma coluna na tabela;
			  5 - Atributo Align para o alinhamento do texto na coluna da tabela;
_cImg2    -> Instru��o para buscar logotipo publicado na internet centralizado a direta do logotipo TN
_nWidth   -> tamanho da tabela na frame do HTML
*/
User Function BeHtmMod2( _cTitulo, _aColuna, lImagem, _aTitulos, _cImg2, _nWidth )

Local cRet      := ""
Local cWith     := ""
Local cCorFundo := ""
Local cEspandi  := ""
Local nLin      := 0
Local nCol      := 0

Default _aTitulos := {}

cRet := '<html>' + CRLF

_aColuna := U_BeAjTamCol( _aColuna )

// Apresenta imagem e t�tulo no inicio do HTML...
If lImagem
	cRet += '<table border="0" width="' + AllTrim(Str(_nWidth)) + '%" align="center">'
	cRet += '  <tbody>'
	cRet += '    <tr>'
	If !Empty( _cTitulo )
		cRet += '      <td style="text-align: center; width: 701px;"><big><big><span style="font-weight: bold;">' + _cTitulo + '</span></big></big></td>'
	EndIf
	If Left(cFilAnt,2) == "02"
		cRet += '      <td style="text-align: center; width: 239px;" bgcolor="#010305"><img style="width: 259px; height: 87px;" alt="" src="http://euroamerican.com.br/images/logo_euroamerican_antigo.png" width=200></td>'
	Else
		cRet += '      <td style="text-align: center; width: 239px;" bgcolor="#010305"><img style="width: 259px; height: 87px;" alt="" src="http://qualyvinil.com.br/assets/images/nav/logo_qv1.png" width=200></td>'
	EndIf
	cRet += '    </tr>'
	cRet += '  </tbody>'
	cRet += '</table>'
	cRet += '<HR>'
EndIf

If Len(_aTitulos) > 0
	cRet += '<table border="0" width="' + AllTrim(Str(_nWidth)) + '%" align="center">'

	For nLin := 1 To Len(_aTitulos)
		cRet += '<tr>'
			For nCol := 1 To Len(_aTitulos[nLin])
				If _aTitulos[nLin][nCol][2] == "1"
					cCorFundo := ""
				ElseIf _aTitulos[nLin][nCol][2] == "2"
					cCorFundo := " bgcolor='#F3F3F3'"
				ElseIf _aTitulos[nLin][nCol][2] == "3"
					cCorFundo := " bgcolor='#F6FBF6'"
				ElseIf _aTitulos[nLin][nCol][2] == "4"
					cCorFundo := " bgcolor='#FFFFCC'"
				Else
					cCorFundo := " bgcolor='#336699'"
				EndIf

				//Expandir colunas horizontalmente na linha...
				If _aTitulos[nLin][nCol][4] > 0
					cEspandi := ' colspan="' + AllTrim(Str(_aTitulos[nLin][nCol][4])) + '"'
				Else
					cEspandi := ' '
				EndIf

				//Largura de colunas linha...
				If _aTitulos[nLin][nCol][3] > 0
					cWith := ' width="' + AllTrim(Str(_aTitulos[nLin][nCol][3])) + '%"'
				Else
					cWith := ' '
				EndIf

				cRet += "    <td" + cEspandi + cWith + " align='" + IIf( _aTitulos[nLin][nCol][5] == "C", "center", IIf( _aTitulos[nLin][nCol][5] == "L", "left", "right")) + "' VALIGN='MIDDLE'" + cCorFundo + ">"
				cRet += "      <font face='Courier New' size='2'>" + _aTitulos[nLin][nCol][1] + "</font>"
				cRet += "    </td>"
			Next
		cRet += '</tr>'
	Next

	cRet += '</table>'
EndIf

If Len( _aColuna ) > 0
	//Cabe�alho da tabela
	cRet += '<table border="0" width="' + AllTrim(Str(_nWidth)) + '%" align="center">'

	cRet += '<tr>'
	For nLin := 1 To Len( _aColuna )
		//Largura de colunas linha...
		If _aColuna[nLin][2] > 0
			cWith := ' width="' + AllTrim(Str(_aColuna[nLin][2])) + '%"'
		Else
			cWith := ' '
		EndIf

		cRet += "    <td " + cWith + " align='" + IIf( _aColuna[nLin][3] == "C", "center", IIf( _aColuna[nLin][3] == "L", "left", "right")) + "' valign='middle' bgcolor='#336699'>"
		cRet += "      <font face='Courier New' size='2' color=WHITE><b>" + _aColuna[nLin][1] + "</b></font>"
		cRet += "    </td>"
	Next
	cRet += '</tr>' + CRLF
Else
	//Cabe�alho da tabela
	cRet += '<table border="0" width="100%" align="center">'
EndIf

Return cRet