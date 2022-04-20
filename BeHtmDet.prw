#include "protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � BeHtmDet �Autor  � Rodrigo Sousa		 � Data �  29/07/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Detalhes das Colunas do HTML                               ���
���          � Par�metros:                                                ���
���          � aDetCols	-> Array de Detalhes das Colunas do Email		  ���
���          � 				1 - Texto que ir� no cabe�alho da coluna da   ���
���          � 					tabela;									  ���
���          � 				2 - Atributo Width para o tamanho da coluna   ���
���          � 					na tabela;								  ���
���          � 				3 - Atributo Align para o alinhamento do 	  ���
���          � 					texto na coluna da tabela				  ���
���          �				4 - Cor de coluna espec�fica				  ���
���          �				5 - Atributo Class para propriedade da coluna ���
���          �					"N" number, "D" date e "C" currency-format���
���          �				6 - Atributo ColSpan para espa�amentos em mais���
���          �					de uma coluna na tabela;				  ���
���          �			  	7 - Atributo RowSpan para espa�amentos em 	  ���
���          �					mais de uma linha na tabela;			  ���
���          � lCor		-> Para alterar cores da linha na tabela Cinza    ���
���          � 				ou Branco									  ���
���          � lTotal   -> Impress�o da linha na tabela em formato de 	  ���
���          �             totalizador, amarela com fontes em negritos	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function BeHtmDet( aDetCols, lCor, lTotal)

Local cClass    	:= ""
Local cRet      	:= ""
Local cWidth    	:= ""
Local cCorFundo 	:= ""
Local nLin      	:= 0

DEFAULT aDetCols 	:= {}
DEFAULT lCor	    := .F.
DEFAULT	lTotal		:= .F.

If Len( aDetCols ) > 0
	If lCor
		cCorFundo := ""
	Else
		cCorFundo := " bgcolor='#F3F3F3'"
	EndIf
	
	cRet += '<tr>'
	
	aDetCols := U_BeAjTamCol( aDetCols )
	
	If !lTotal
		For nLin := 1 To Len( aDetCols )
			//Largura de colunas linha...
			If aDetCols[nLin][2] > 0
				cWidth := ' width="' + AllTrim(Str(aDetCols[nLin][2])) + '%"'
			Else
				cWidth := ' '
			EndIf

			If Len( aDetCols[nLin] ) > 4
				If AllTrim( aDetCols[nLin][5] ) == "N"
					cClass := ' class="num"'
				ElseIf AllTrim( aDetCols[nLin][5] ) == "D"
					cClass := ' class="date"'
				ElseIf AllTrim( aDetCols[nLin][5] ) == "C"
					cClass := ' class="currency-format"'
				Else
					cClass := 'style=mso-number-format:"\@"'
				EndIf
			Else
				cClass := 'style=mso-number-format:"\@"'
			EndIf

			If Len( aDetCols[nLin] ) > 3
				If aDetCols[nLin][4]
					cRet += "    <td " + cWidth + cClass + " align='" + IIf( aDetCols[nLin][3] == "C", "center", IIf( aDetCols[nLin][3] == "L", "left", "right")) + "'  style='font-weight: bold; background-color: rgb(255, 255, 204); color: rgb(153, 0, 0);' VALIGN='MIDDLE'>"
				Else
					cRet += "    <td " + cWidth + cClass + " align='" + IIf( aDetCols[nLin][3] == "C", "center", IIf( aDetCols[nLin][3] == "L", "left", "right")) + "' " + cCorFundo + " VALIGN='MIDDLE'>"
				EndIf
			Else
				cRet += "    <td " + cWidth + cClass + " align='" + IIf( aDetCols[nLin][3] == "C", "center", IIf( aDetCols[nLin][3] == "L", "left", "right")) + "' " + cCorFundo + " VALIGN='MIDDLE'>"
			EndIf
			
			If aDetCols[nLin][3] == "L"
				cRet += "      <font face='Courier New' size='2'>" + aDetCols[nLin][1] + "</font>"
			Else
				cRet += "      <font face='Courier New' size='2'>" + aDetCols[nLin][1] + "</font>"
			EndIf
			cRet += "    </td>"
		Next
	Else
		For nLin := 1 To Len( aDetCols )
			//Largura de colunas linha...
			If aDetCols[nLin][2] > 0
				cWidth := ' width="' + AllTrim(Str(aDetCols[nLin][2])) + '%"'
			Else
				cWidth := ' '
			EndIf
	
			If Len( aDetCols[nLin] ) > 4
				If AllTrim( aDetCols[nLin][5] ) == "N"
					cClass := ' class="num"'
				ElseIf AllTrim( aDetCols[nLin][5] ) == "D"
					cClass := ' class="date"'
				ElseIf AllTrim( aDetCols[nLin][5] ) == "C"
					cClass := ' class="currency-format"'
				Else
					cClass := 'style=mso-number-format:"\@"'
				EndIf
			Else
				cClass := 'style=mso-number-format:"\@"'
			EndIf

			cRet += "    <td " + cWidth + cClass + " align='" + IIf( aDetCols[nLin][3] == "C", "center", IIf( aDetCols[nLin][3] == "L", "left", "right")) + "'  style='font-weight: bold; background-color: rgb(255, 255, 204); color: rgb(153, 0, 0);' VALIGN='MIDDLE'>"
			If aDetCols[nLin][3] == "L"
				cRet += "      <font face='Courier New' size='2'><B>" + aDetCols[nLin][1] + "</B></font>"
			Else
				cRet += "      <font face='Courier New' size='2'><B>" + aDetCols[nLin][1] + "</B></font>"
			EndIf
			cRet += "    </td>"
		Next
	EndIf
	
	cRet += '</tr>' + CRLF
EndIf

Return cRet
