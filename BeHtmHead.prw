#include "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BeHtmHead�Autor  � Rodrigo Sousa 	 � Data �  29/07/14  ���
�������������������������������������������������������������������������͹��
���Desc.     � Cabe�alho do HTML                                          ���
���          � Par�metros:                                                ���
���          � cTitulo 	-> T�tulo do Html informado ao lado da imagem     ���
���          � 															  ���
���          � lImagem	-> Informa se ir� inserir Logotipo                ���
���          � 															  ���
���          � aHeadID	-> Array do Cabe�alho de Identifica��o do Email   ���
���          � 			 	1 - Texo que ir� na coluna desejada;		  ���
���          � 				2 - Define cor de fundo para a coluna 		  ���
���          � 					"1" Branco, "2" Cinza e "3" Azul Escuro;  ���
���          � 				3 - Atributo Width para o tamanho da coluna na��� 
���          � 					tabela;									  ���
���          � 				4 - Atributo ColSpan para espa�amentos em 	  ���
���          � 					mais de uma coluna na tabela;			  ���
���          � 				5 - Atributo Align para o alinhamento do 	  ���
���          � 					texto na coluna da tabela;				  ���
���          � 				6 - Atributo Class para propriedade da coluna ��� 
���          � 					"N" number, "D" date e 					  ���
���          � 					"C" currency-format						  ���
���          �                                                            ���
���          � aCabCols	-> Array de Cabe�alho das Colunas do Email		  ���
���          � 				1 - Texto que ir� no cabe�alho da coluna da   ���
���          �					tabela;                                   ���
���          �             	2 - Atributo Width para o tamanho da coluna na���
���          �     				a tabela;								  ���
���          �             	3 - Atributo Align para o alinhamento do 	  ���
���          �              	texto na coluna da tabela.                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �       	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function BeHtmHead(cTitulo,lImagem,aHeadID,aCabCols)

Local cClass    := ""
Local cRet      := ""
Local cWidth     := ""
Local cCorFundo := ""
Local cEspandi  := ""
Local nLin      := 0
Local nCol      := 0

Default aHeadID := {}

cRet := '<html>' + CRLF

aCabCols := U_BeAjTamCol( aCabCols )

// Apresenta imagem e t�tulo no inicio do HTML...
If lImagem
	cRet += '<table style="text-align: left; width: 100%; height: 10%;" border="0" cellpadding="0" cellspacing="0">'
	cRet += '  <tbody>'
	cRet += '    <tr>'

	If !Empty( cTitulo )
		cRet += '      <td style="text-align: center; width: 701px;"><big><big><span style="font-weight: bold;">' + cTitulo + '</span></big></big></td>'
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

If Len(aHeadID) > 0
	cRet += '<table border="1" width="100%" align="center">'

	For nLin := 1 To Len(aHeadID)
		cRet += '<tr>'
			For nCol := 1 To Len(aHeadID[nLin])
				If aHeadID[nLin][nCol][2] == "1"
					cCorFundo := ""
				ElseIf aHeadID[nLin][nCol][2] == "2"
					cCorFundo := " bgcolor='#F3F3F3'"
				Else
					cCorFundo := " bgcolor='#336699'"
				EndIf

				//Expandir colunas horizontalmente na linha...
				If aHeadID[nLin][nCol][4] > 0
					cEspandi := ' colspan="' + AllTrim(Str(aHeadID[nLin][nCol][4])) + '"'
				Else
					cEspandi := ' '
				EndIf

				//Largura de colunas linha...
				If aHeadID[nLin][nCol][3] > 0
					cWidth := ' width="' + AllTrim(Str(aHeadID[nLin][nCol][3])) + '%"'
				Else
					cWidth := ' '
				EndIf

				If Len( aHeadID[nLin][nCol] ) > 5
					If AllTrim( aHeadID[nLin][nCol][6] ) == "N"
						cClass := ' class="num"'
					ElseIf AllTrim( aHeadID[nLin][nCol][6] ) == "D"
						cClass := ' class="date"'
					ElseIf AllTrim( aHeadID[nLin][nCol][6] ) == "C"
						cClass := ' class="currency-format"'
					Else
						cClass := 'style=mso-number-format:"\@"'
					EndIf
				Else
					cClass := 'style=mso-number-format:"\@"'
				EndIf

				cRet += "    <td" + cEspandi + cWidth + cClass + " align='" + IIf( aHeadID[nLin][nCol][5] == "C", "center", IIf( aHeadID[nLin][nCol][5] == "L", "left", "right")) + "' VALIGN='MIDDLE'" + cCorFundo + ">"
				cRet += "      <font face='Courier New' size='2' color=WHITE>" + aHeadID[nLin][nCol][1] + "</font>"
				cRet += "    </td>"
			Next
		cRet += '</tr>'
	Next

	cRet += '</table>'
	cRet += '<Hr>'
EndIf

If Len( aCabCols ) > 0
	//Cabe�alho da tabela
	cRet += '<table border="1" width="100%" align="center">'

	cRet += '<tr>'
	For nLin := 1 To Len( aCabCols )
		//Largura de colunas linha...
		If aCabCols[nLin][2] > 0
			cWidth := ' width="' + AllTrim(Str(aCabCols[nLin][2])) + '%"'
		Else
			cWidth := ' '
		EndIf

		cRet += "    <td " + cWidth + " align='" + IIf( aCabCols[nLin][3] == "C", "center", IIf( aCabCols[nLin][3] == "L", "left", "right")) + "' VALIGN='MIDDLE' bgcolor='#336699'>"
		cRet += "      <font face='Courier New' size='2' color=WHITE><b>" + aCabCols[nLin][1] + "</b></font>"
		cRet += "    </td>"
	Next
	cRet += '</tr>' + CRLF
Else
	//Cabe�alho da tabela
	cRet += '<table border="0" width="100%" align="center">'
EndIf

Return cRet

