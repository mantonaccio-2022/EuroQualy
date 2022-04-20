#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "protheus.ch"

#define ENTER CHR(13)+CHR(10)

User Function MT100AGR()

Local aArea := GetArea()

// FS - Verifica se houve amarra��o
If Type("aSZZxSF1") == "A"
	If Len( aSZZxSF1 ) > 0
		lAmarra := .T.
	EndIf
EndIf

If !lAmarra
	//���������������������������������������������������������������������Ŀ
	//|Dialogo para informar Ticket de Pesagem (NAO OBRIGATORIO)            �
	//�����������������������������������������������������������������������
	If Empty( SF1->F1_TICPESA )
		If INCLUI .And. ! SF1->F1_ESPECIE <> "RECIB"
			U_ESTX003SF1()
		EndIf
	EndIf
EndIf

//���������������������������������������������������������������������Ŀ
//|Restaura area anterior                                               �
//�����������������������������������������������������������������������
Restarea( aArea )

Return
