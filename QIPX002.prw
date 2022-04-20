#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002  � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � ANALISE DE PRODUCAO E ENTRADAS                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002()

//������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                    �
//��������������������������������������������������������������
Private cAlias    := "SZD"
Private cCadastro := "An�lise de Produ��o e Entradas"
Private aCores    := {}
Private aRotina   := {}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {}   
Private lExibeReal:= SuperGetMv("MV_REALSZD",,.T.)

//������������������������������������������������������������Ŀ
//� Menu                                                       �
//��������������������������������������������������������������
aAdd( aRotina, {"Pesquisar"   	,"AxPesqui"   ,0,1})
aAdd( aRotina, {"Visualizar"  	,"U_QIPX002V" ,0,2})
aAdd( aRotina, {"Lote &PA"    	,"U_QIPX002I" ,0,3})
aAdd( aRotina, {"Alterar"     	,"U_QIPX002A" ,0,4})
aAdd( aRotina, {"Excluir"     	,"U_QIPX002E" ,0,5})
aAdd( aRotina, {"Lote &MP"    	,"U_QIPX002M" ,0,3})
aAdd( aRotina, {"Revalida��o" 	,"U_QIPX002R" ,0,2})
aAdd( aRotina, {"Legenda"     	,"U_QIPX002L" ,0,2})          
aAdd( aRotina, {"Conhecimento"	,"MsDocument" ,0,4})    
aAdd( aRotina, {"Configurar"	,"U_QIPX002C" ,0,4})  

dbSelectArea(cAlias)
dbSetOrder(2)
dbGoTop()

aAdd(aCores,{"ZD_STATUS == 'R'","DISABLE"})
aAdd(aCores,{"ZD_STATUS == 'A'","ENABLE"})

//������������������������������������������������������������Ŀ
//� Definicao de Acessos                                       �
//��������������������������������������������������������������

dbSelectArea("SZD")
Set Filter to 

/*
If AllTrim(cUserName) != "Administrador"

	If AllTrim(cUserName) $ cUserQual 
		Set Filter to &("@ SUBSTRING((SELECT B1_GRUPO FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ <> '*' AND B1_COD = ZD_PRODUT), 1, 1) = '3'")
	ElseIf AllTrim(cUserName) $ cUserEuro 
		Set Filter to &("@ SUBSTRING((SELECT B1_GRUPO FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ <> '*' AND B1_COD = ZD_PRODUT), 1, 1) = '1'")
	Else
		Set Filter to &("@ ZD_PRODUT = ''")
	EndIf
EndIf
*/
	
mBrowse(06,01,22,75,"SZD",,,,,,aCores)

dbSelectArea("SZD")
dbSetOrder(2)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002V � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � ANALISE DE PRODUCAO - VISUALIZACAO                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002V(cAlias, nReg, nOpcX)

Local cLote   := SZD->ZD_LOTE  
Local cLoteI  := SZD->ZD_LI
Local cLoteE  := SZD->ZD_LE                                                                                        

Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_DTATU", "ZD_LOTE", "ZD_PRODUT", "ZD_DESCRI", "ZD_LI", "ZD_LE", "ZD_DTFABR", "ZD_FORN"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {} 
Private aButtons  := {}

dbSelectArea("SZD") 
nFields := FCount()
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)
For nCntFor := 1 To nFields  
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))  
	M->&(FieldName(nCntFor)) := SZD->&(FieldName(nCntFor))
Next nCntFor

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. X3_ARQUIVO == cAlias 

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		
	
	If X3Uso(X3_USADO) .And. X3_NIVEL > 0 
		nUsado++
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO         ,;
		X3_PICTURE       ,;
		X3_TAMANHO       ,;
		X3_DECIMAL       ,;
		X3_VALID         ,;
		X3_USADO         ,;
		X3_TIPO          ,;
		X3_ARQUIVO       ,;
		X3_CONTEXT       })
	Endif
	dbSelectArea("SX3")
	dbSkip()
EndDo

dbSelectArea(cAlias)
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

While !EOF() .And. SZD->ZD_FILIAL + SZD->ZD_LOTE + SZD->ZD_LE + SZD->ZD_LI == xFilial("SZD") + cLote + cLoteE + cLoteI	                      
	aAdd(aCols,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
		If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
			aCols[1][nCntFor] := "01"
		EndIf
	Next nCntFor
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	dbSelectArea(cAlias)
	dbSkip()
EndDo    

dbSelectArea(cAlias)
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice(cAlias, nReg, nOpcx,,,, aEnchoice, aPosObj[1],, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,oDlg:End()},{||oDlg:End()})      

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002E � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � ANALISE DE PRODUCAO - EXCLUSAO                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002E(cAlias, nReg, nOpcX)

Local cLote     := SZD->ZD_LOTE  
Local cLoteI    := SZD->ZD_LI
Local cLoteE    := SZD->ZD_LE

If MsgYesNo("Deseja prosseguir com a dele��o?", cCadastro)
	
	dbSelectArea(cAlias)
	dbSetOrder(2)
	dbSeek(xFilial("SZD") + cLote + cLoteI)
	
	While !EOF("SZD") .And. SZD->ZD_LOTE == cLote;
                      .And. SZD->ZD_LE == cLoteE;
                      .And. SZD->ZD_LI == cLoteI	                      
		dbSelectArea("SZD")
		RecLock("SZD",.F.)
			dbDelete()
		SZD->( MsUnLock() )
		dbSkip()
	EndDo
	
EndIf   

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002A � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � ANALISE DE PRODUCAO - ALTERACAO                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002A(cAlias, nReg, nOpcX)

Local cLote   := SZD->ZD_LOTE  
Local cLoteI  := SZD->ZD_LI
Local cLoteE  := SZD->ZD_LE

Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_DTATU", "ZD_LOTE", "ZD_PRODUT", "ZD_DESCRI", "ZD_LI", "ZD_LE", "ZD_FORN"}
Private aEdit     := {"ZD_FORN"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {} 
Private aButtons  := {}

dbSelectArea("SZD")
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)
For nCntFor := 1 To FCount()  
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
	M->&(FieldName(nCntFor)) := SZD->&(FieldName(nCntFor))
Next nCntFor
          
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

dbSelectArea("SX3")  
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. X3_ARQUIVO == cAlias  

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		

	If X3Uso(X3_USADO) .And. X3_NIVEL > 0
		nUsado++
		aAdd(aHeader,{ TRIM(X3Titulo()) ,;
		X3_CAMPO         ,;
		X3_PICTURE       ,;
		X3_TAMANHO       ,;
		X3_DECIMAL       ,;
		X3_VALID         ,;
		X3_USADO         ,;
		X3_TIPO          ,;
		X3_ARQUIVO       ,;
		X3_CONTEXT       })
	Endif
	dbSelectArea("SX3")
	dbSkip()
EndDo

dbSelectArea(cAlias)
dbSetOrder(2)
dbSeek(xFilial("SZD") + cLote + cLoteI)

While !EOF() .And. SZD->ZD_FILIAL + SZD->ZD_LOTE + SZD->ZD_LE + SZD->ZD_LI == xFilial("SZD") + cLote + cLoteE + cLoteI	                      
	aAdd(aCols,Array(nUsado+1))
	For nCntFor := 1 To nUsado
		If ( aHeader[nCntFor][10] != "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
		Else
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
		EndIf
		If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
			aCols[1][nCntFor] := "01"
		EndIf
	Next nCntFor
	aCols[Len(aCols)][Len(aHeader)+1] := .F.
	dbSelectArea(cAlias)
	dbSkip()
EndDo    
         
aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)     

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice(cAlias, nReg, nOpcX,,,, aEnchoice, aPosObj[1], aEdit, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX002OK(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},,@aButtons)

If nOpcA == 1
	QIPX002GR(cAlias)
Endif

dbSelectArea(cAlias)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002I � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � ANALISE DE PRODUCAO - INCLUSAO PA                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002I(cAlias, nReg, nOpcX)

Private cPath     := "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"    
Private cRet      := ""
Private aButtons  := {}
Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_DTATU", "ZD_LOTE", "ZD_PRODUT", "ZD_DESCRI", "ZD_DTFABR", "ZD_DTVALID", "ZD_LE", "ZD_FORN"}
Private aEdit     := {"ZD_CODANAL", "ZD_LOTE", "ZD_DTFABR", "ZD_DTVALID", "ZD_LE", "ZD_FORN"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}                                                      
Private aTela     := {}   


dbSelectArea("SZD")
dbSetOrder(2)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
Next nCntFor

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZD")
While !EOF() .And. SX3->X3_ARQUIVO == "SZD"  

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		

	If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL > 0
		nUsado++
		aAdd(aHeader,{ Trim(X3Titulo()),;
                 		Trim(SX3->X3_CAMPO),;
                		SX3->X3_PICTURE,;
                		SX3->X3_TAMANHO,;
                		SX3->X3_DECIMAL,;
                		SX3->X3_VALID,;
                		SX3->X3_USADO,;
                		SX3->X3_TIPO,;
                		SX3->X3_ARQUIVO,;
                		SX3->X3_CONTEXT } )
	EndIf

	dbSelectArea("SX3")
	dbSkip()
EndDo

aAdd(aCols, Array(nUsado+1))

For nCntFor := 1 To nUsado
	aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
		aCols[1][nCntFor] := "01"
	EndIf
Next nCntFor     

aCols[Len(aCols)][Len(aHeader)+1] := .F.

aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)     

aAdd( aButtons, {"HISTORIC", {|| Atualiza()}, "Especifica��o...", "Especifica��o", {|| .T.}})     

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
EnChoice(cAlias, nReg, nOpcx,,,, aEnchoice, aPosObj[1], aEdit, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX002OK(), oDlg:End(), nOpcA:=0)},{||oDlg:End()},,@aButtons)

If nOpcA == 1  

	QIPX002GR(cAlias)
                       
	cLote := AllTrim(M->ZD_LOTE)
	dbSelectArea("SC2")
	dbSetOrder(1)
	If dbSeek(xFilial("SC2") + cLote)     
	
		While !SC2->(EOF()) .And. SC2->C2_NUM == cLote  
		    
		    // Posiciona registro de Produto
		    SB1->(dbSetOrder(1))
		    SB1->(dbSeek(xFilial("SB1") + SC2->C2_PRODUTO))
		    
		    // Envia Mensagem para PCP
			cMsg := '"(An�lise de Produ��o - ' + SC2->C2_NUM + '.' + SC2->C2_ITEM + '.' + SC2->C2_SEQUEN + ')' + chr(13) + chr(10) 
			cMsg += 'De: ' + cUserName + chr(13) + chr(10) 
			cMsg += 'PRODUTO: ' + Alltrim(SC2->C2_PRODUTO) + ' - ' + AllTrim(SB1->B1_DESC) + chr(13) + chr(10) 
			cMsg += 'QUANTID: ' + Transform(SC2->C2_QUJE, "@E 999,999,999.99") + ' " ' 
			//WinExec(cPath + Space(1) + U_getUserGp("PCP-X01") + Space(1) + cMsg, 0)
										
			// Avanca para o proximo registro
			SC2->(dbSkip())
			
		EndDo
	
	EndIf    
	
Endif

dbSelectArea(cAlias)

Return      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002M � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � ANALISE DE PRODUCAO - INCLUSAO MP                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002M(cAlias, nReg, nOpcX)
                  
Private aButtons  := {}
Private aEnchoice := {"ZD_CODANAL", "ZD_ANALIS", "ZD_DTATU", "ZD_LI", "ZD_LE", "ZD_DTFABR", "ZD_PRODUT", "ZD_DESCRI", "ZD_FORN"}
Private oGet
Private oDlg
Private nUsado    := 0
Private nCntFor   := 0
Private nOpcA     := 0
Private aObjects  := {}
Private aPosObj   := {}
Private aSizeAut  := MsAdvSize()
Private aHeader   := {}
Private aCols     := {}
Private aGets     := {}
Private aTela     := {} 
                               
dbSelectArea("SZD")
dbSetOrder(2)
For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := CriaVar(FieldName(nCntFor))
Next nCntFor

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SZD")
While !EOF() .And. SX3->X3_ARQUIVO == "SZD"   

    If !lExibeReal .And. ( AllTrim(X3_CAMPO) == "ZD_RNUMR" .Or. AllTrim(X3_CAMPO) == "ZD_TEXTOR" )
		dbSelectArea("SX3")
		dbSkip()
		Loop
	EndIf		

	If X3Uso(SX3->X3_USADO) .And. SX3->X3_NIVEL > 0 
		nUsado++
		aAdd(aHeader,{ Trim(X3Titulo()),;
                 		Trim(SX3->X3_CAMPO),;
                		SX3->X3_PICTURE,;
                		SX3->X3_TAMANHO,;
                		SX3->X3_DECIMAL,;
                		SX3->X3_VALID,;
                		SX3->X3_USADO,;
                		SX3->X3_TIPO,;
                		SX3->X3_ARQUIVO,;
                		SX3->X3_CONTEXT } )
	EndIf

	dbSelectArea("SX3")
	dbSkip()
EndDo

aAdd(aCols, Array(nUsado+1))

For nCntFor := 1 To nUsado
	aCols[1][nCntFor] := CriaVar(aHeader[nCntFor][2])
	If ( AllTrim(aHeader[nCntFor][2]) == "ZD_ITEM" )
		aCols[1][nCntFor] := "01"
	EndIf
Next nCntFor     

aCols[Len(aCols)][Len(aHeader)+1] := .F.

aObjects := {}
aAdd(aObjects, {315,  50, .T., .T.})
aAdd(aObjects, {100, 100, .T., .T.})

aInfo   := {aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3}
aPosObj := MsObjSize(aInfo, aObjects, .T.)

aAdd( aButtons, {"HISTORIC", {|| Atualiza()}, "Especifica��o...", "Especifica��o", {|| .T.}})     

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

EnChoice(cAlias, nReg, nOpcx,,,, aEnchoice, aPosObj[1],, 3)
oGet := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], nOpcx, "AllwaysTrue", "AllwaysTrue", "+ZD_ITEM", .T.)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX002OK(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},,@aButtons)

If nOpcA == 1
	QIPX002GR(cAlias)
Endif

dbSelectArea(cAlias)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002GR� Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � GRAVACAO                                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Static Function QIPX002GR(cAlias)

Local cVar     := ""
Local lOk      := .T.
Local cMsg     := ""
Local nPos     := aScan(aHeader, {|x|AllTrim(Upper(x[2])) == "ZD_ITEM"})
Local nPosEns  := aScan(aHeader, {|x|AllTrim(Upper(x[2])) == "ZD_ENSAIO"})
Local cProd    := M->ZD_PRODUT 
Local dDataFab := M->ZD_DTFABR    
Local dDataVld := M->ZD_DTVALID    
Local cLote    := M->ZD_LOTE      
Local cLoteI   := M->ZD_LI        
Local cLoteE   := M->ZD_LE     
Local cCombo   := M->ZD_ANALIS      
Local cCodAna  := M->ZD_CODANAL    
Local cCodFor  := M->ZD_FORN
Local dAnalise := Iif(Empty(M->ZD_DATA), dDataBase, M->ZD_DATA)
Local aArea    := GetArea()

dbSelectArea(cAlias)   
dbSetOrder(5)

For i := 1 To Len(aCols)
	
	If !aCols[i][nUsado+1]
		If dbSeek(xFilial("SZD") + cLote + cLoteI + cLoteE + aCols[i, nPosEns] + aCols[i, nPos])
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		Endif
		
		SZD->ZD_FILIAL    := xFilial("SZD")
		SZD->ZD_PRODUT    := cProd
		SZD->ZD_DESCRI    := Posicione("SB1",1,xFilial("SB1") + cProd, "B1_DESC")
		SZD->ZD_DTFABR    := dDataFab
		SZD->ZD_DTVALID   := dDataVld		
		SZD->ZD_DTATU     := dDataBase
		SZD->ZD_DATA      := dAnalise
		SZD->ZD_LOTE      := cLote
		SZD->ZD_LI        := cLoteI
		SZD->ZD_LE        := cLoteE
		SZD->ZD_ANALIS    := cCombo    
		SZD->ZD_CODANAL   := cCodAna      
		SZD->ZD_FORN      := cCodFor      
				
		For nY := 1 to Len(aHeader)
			If aHeader[nY][10] # "V"
				cVar  := Trim(aHeader[nY][2])
				&cVar := Iif(Type("aCols[i][nY]") == "N", Round(aCols[i][nY], 3), aCols[i][nY])
			Endif
		Next nY    
		
		(cAlias)->( MsUnLock() )
		
	Else
		
		If !Found()
			Loop
		Endif
		
		If lOk
			RecLock(cAlias,.F.)
			dbDelete()
			(cAlias)->( MsUnLock() )
		Else
			cMsg := "Nao foi possivel deletar o item " + aCols[i, nPos] + ", o mesmo possui amarracao"
			MsgStop(cMsg)
		Endif
		
	Endif
	
Next i

RestArea(aArea)

Return .T.     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIPX02DT  � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � VALIDACAO ENCHOICE                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX02Dt(cLoteT)

Local aArea  := GetArea()      
Local aAreaSC2  := SC2->(GetArea())
Local aDatas := Array(2) // Fabricacao#Validade
                                        
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1") + U_QIPX02getEspec(cLoteT))

dbSelectArea("SC2")
dbSetOrder(1)
dbSeek(xFilial("SC2") + cLoteT , .T.)

/*If Empty(SC2->C2_DTETIQ)
	aDatas[1] := dDataBase
	aDatas[2] := dDataBase + SB1->B1_PRVALID  
Else
	aDatas[1] := SC2->C2_DTETIQ
	aDatas[2] := SC2->C2_DTETIQ + SB1->B1_PRVALID  
EndIf*/
//Alterado para padr�o etiquetas produtos MEST001 27/04/18
aDatas[1] := SC2->C2_EMISSAO
aDatas[2] := LastDay(SC2->C2_EMISSAO + SB1->B1_PRVALID, 2)

RestArea(aAreaSC2)
RestArea(aArea)

Return aDatas

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIPX002VAL� Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � VALIDACAO ENCHOICE                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX02Valid(cLoteT, nBusca)

Local aArea		:= GetArea()
Local aAreaSC2	:= SC2->( GetArea() )
                            
// Obriga preenchimento do campo lote                                        
If Empty(cLoteT) 
	MsgStop("Lote n�o pode ser vazio!")	
	cLoteT := ""
EndIf                                

// Verifica se lote ja foi cadastrado
dbSelectArea("SZD")
dbSetOrder(nBusca)   
If MsSeek(xFilial("SZD") + cLoteT)
	MsgStop("Lote j� cadastrado!")	
	cLoteT := ""
EndIf      
	               
RestArea( aAreaSC2 )
RestArea( aArea )

Return cLoteT

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002L � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � LEGENDA                                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002L

BrwLegenda(cCadastro, "Legenda",  {{"ENABLE"  , "Ensaio Aprovado" },;
                                    {"DISABLE" , "Ensaio Reprovado"}})

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ATUALIZA � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � CARREGA ESPECIFICACAO PADRAO DO PRODUTO                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Static Function Atualiza()

Local cProd    := M->ZD_PRODUT 

dbSelectArea("QPJ")
dbSetOrder(1)

cProduto := AllTrim(cProd)
cDesc    := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_DESC")

If dbSeek(xFilial("QPJ") + cProduto)
	
	nItem := 1  
	nZD_ITEM    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_ITEM"})
	nZD_ENSAIO  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_ENSAIO"})
	nZD_DENSAI  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_DENSAI"}) 
	nZD_LINF    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_LINF"}) 
	nZD_LSUP    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_LSUP"})
	nZD_RNUM    := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RNUM"})
	nZD_RNUMR   := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RNUMR"})
	nZD_RTEXTP  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RTEXTP"})
	nZD_RTEXTO  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_RTEXTO"})
	nZD_TEXTOR  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_TEXTOR"})
	nZD_LIMITE  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_LIMITE"})
	nZD_STATUS  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_STATUS"})
	nZD_IMPRES  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_IMPRES"})
	nZD_METODO  := aScan(aHeader,{|x| AllTrim(x[2])=="ZD_METODO"})
	
	While !EOF("QPJ") .And. Alltrim(QPJ->QPJ_PROD) == cProduto
		
		//������������������������������������������������������������������Ŀ
		//� Cria linha em branco no acols de acordo com o tamanho do aHeader �
		//��������������������������������������������������������������������
		If nItem <> 1
			Aadd(aCols, Array(Len(aHeader)+1))
			aCols[Len(aCols), Len(aHeader)+1] := .f.
		EndIf
		
		nItem++

		//��������������������������������������������������������Ŀ
		//� Preenche cada elemento da linha do aCols com seu valor �
		//� padr�o e depois copia os valores do item original.     �
		//����������������������������������������������������������
		aCols[Len(aCols), nZD_ITEM]   := QPJ_ITEM      //Item
		aCols[Len(aCols), nZD_ENSAIO] := QPJ_ENSAIO    //Ensaio
		aCols[Len(aCols), nZD_DENSAI] := QPJ_DESENS    //Descricao do Ensaio
		aCols[Len(aCols), nZD_LINF]   := QPJ_LINF      //Limite Inferior
		aCols[Len(aCols), nZD_LSUP]   := QPJ_LSUP      //Limite Superior
		aCols[Len(aCols), nZD_RNUM]   := 0             //Resultado Numerico Verificado

		aCols[Len(aCols), nZD_RTEXTP] := QPJ_TEXTO     //Resultado Texto Padrao
		aCols[Len(aCols), nZD_RTEXTO] := "C"           //Resultado Texto Verificado
		aCols[Len(aCols), nZD_LIMITE] := QPJ_LIMITE    //Limite medida
		aCols[Len(aCols), nZD_STATUS] := ""            //Status
		aCols[Len(aCols), nZD_IMPRES] := QPJ_IMPRES    //Impressao
		aCols[Len(aCols), nZD_METODO] := QPJ_METODO    //Metodo                            
		
		If lExibeReal
			aCols[Len(aCols), nZD_RNUMR]  := 0             //Resultado Numerico Verificado Real
			aCols[Len(aCols), nZD_TEXTOR] := "C"           //Resultado Texto Verificado Real
		EndIf
			
		dbSelectArea("QPJ")
		dbSkip()
		
	EndDo

	GetdRefresh()	               

EndIf 

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002  � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � OBTEM O ITEM DA ESPECIFICACAO PADRAO (SXB "OP1")           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX02getEspec(cLote)
          
Local cRet     := ""                                         
Local lRet     := .T.
Local aAreaSC2 := SC2->(GetArea())
Local aArea    := GetArea()
Local cProd    := M->ZD_PRODUT 
Local cLote    := TRIM(M->ZD_LOTE)      
Local cLoteI   := M->ZD_LI        
Local cLoteE   := M->ZD_LE     

SC2->(dbSetOrder(1))
SC2->(dbSeek(xFilial("SC2") + cLote))

While !SC2->(EOF()) .And. SC2->C2_NUM == cLote
	
	/*
	cQry := " SELECT   G1_COD PRODUTO1,	G1_COMP PRODUTO2 "
	cQry += " FROM	" + RetSqlName("SG1")
	cQry += " WHERE	D_E_L_E_T_ <> '*' "
	cQry += " 		AND G1_COD = '" + SC2->C2_PRODUTO + "' "
	
	TCQUERY cQry NEW ALIAS QRY     

	dbSelectArea("QRY")
    */
    
    If Empty(cRet)
		QPJ->(dbSetOrder(1))
		If QPJ->(dbSeek(xFilial("QPJ") + SC2->C2_PRODUTO))
			cRet := SC2->C2_PRODUTO
			lRet := .F.
		EndIf
	EndIf
	
	If Empty(cRet)
		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1") + PadR(AllTrim(SC2->C2_PRODUTO), 15)))
			If SB1->B1_TIPO == "PI"
				
				QPJ->(dbSetOrder(1))
				If QPJ->(dbSeek(xFilial("QPJ") + SC2->C2_PRODUTO))
					cRet := SC2->C2_PRODUTO
					lRet := .F.
				EndIf
			EndIf
		EndIf		
	EndIf
		
	// Familia A1, B1, C1, K1, BC, LM                 
	If Empty(cRet)
		cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, At(".", SC2->C2_PRODUTO) - 1) + "." + Subs(SC2->C2_PRODUTO, -2), 15)              
		If Subs(SC2->C2_PRODUTO, -2) $ "A1#B1#BS#C1#D1#E1#E2#TR#I1#I2#C2#K1#BC#LM#AK#AL#MV#BV#OR#IT#OC#EC#TE#EU#IM#CO#R1#R2#R4#R6#AM#SL#V1#X1#Y1#Z1"
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1") + cProduto))
				If SB1->B1_TIPO == "PI" 
					QPJ->(dbSetOrder(1))
					If QPJ->(dbSeek(xFilial("QPJ") + cProduto)) .And. AllTrim(QPJ->QPJ_PROD) == AllTrim(cProduto)
						cRet := cProduto
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
	// Familia de Produtos - Normal
	If Empty(cRet)
		SB1->(dbSetOrder(1))                  
		If Subs(SC2->C2_GRUPO, 1, 1) == "1"
			cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, At(".", SC2->C2_PRODUTO) - 1), 15)              
		Else
			If Len(AllTrim(SC2->C2_PRODUTO)) == 11
				cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, 8), 15)              
			Else
				cProduto := PadR(Subs(SC2->C2_PRODUTO, 1, 9), 15)              
			EndIf
		EndIf
			
		If SB1->(dbSeek(xFilial("SB1") + cProduto))
			If SB1->B1_TIPO == "PI" 
				QPJ->(dbSetOrder(1))
				If QPJ->(dbSeek(xFilial("QPJ") + cProduto)) .And. AllTrim(QPJ->QPJ_PROD) == AllTrim(cProduto)
					cRet := cProduto
					lRet := .F.
				EndIf
			EndIf
		EndIf         
	EndIf
		
	/*While !QRY->(EOF()) .And. Empty(cRet)
		
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + QRY->PRODUTO1))
		
		If SB1->B1_TIPO == "PI"
			
			QPJ->(dbSetOrder(1))
			If QPJ->(dbSeek(xFilial("QPJ") + QRY->PRODUTO1))
				cRet := AllTrim(QRY->PRODUTO1)
				lRet := .F.
			EndIf
			
		Else
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + QRY->PRODUTO2))
			
			IF SB1->B1_TIPO == "PI"
				
				QPJ->(dbSetOrder(1))
				If QPJ->(dbSeek(xFilial("QPJ") + QRY->PRODUTO2))
					cRet := AllTrim(QRY->PRODUTO2)
					lRet := .F.
				EndIf
			EndIf
			
		EndIf
		
		QRY->(dbSkip())
		
	EndDo

	QRY->(dbCloseArea())*/
		
	SC2->(dbSkip())
	
EndDo

If Empty(cRet)
	MsgAlert("N�o h� especifica��o para o produto")
EndIf    
               
RestArea(aAreaSC2)
RestArea(aArea)

Return cRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002  � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � FILTRO PARA CONSULTA OP1 (SXB)                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX02SetFilter()

Local cRet := "@ "

/*If U_isGroup("LAB-Q01", AllTrim(cUserName))
	cRet := "@ SUBSTRING((SELECT B1_GRUPO FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ <> '*' AND B1_COD = C2_PRODUTO), 1, 1) = '3'"
ElseIf U_isGroup("LAB-X00#LAB-E01", AllTrim(cUserName))
	cRet := "@ SUBSTRING((SELECT B1_GRUPO FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ <> '*' AND B1_COD = C2_PRODUTO), 1, 1) = '1'"
Else
	cRet := "@ "
EndIf*/

Return cRet  


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002  � Autor �Tiago O. Beraldi    � Data �  25/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � PREENCHE COMBO ANALISTAS                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Static Function QIPX02SetAnalis()

Local cRet := "" 

For i := 1 to Len(aCombo)
	cRet += ";" + AllTrim(aCombo[1]) + "=" + AllTrim(aCombo[1]) 
Next i

Return cRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EQIPX003  �Autor  �Tiago O. Beraldi    � Data �  01/04/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida Tudo                                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Euroamerican                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function QIPX002OK()

Local lRet     := .T.    
Local nPos0    := Ascan(aHeader,{|x| "ZD_RTEXTO" $ x[2]})
Local nPos1    := Ascan(aHeader,{|x| "ZD_RTEXTP" $ x[2]})
Local nPos2    := Ascan(aHeader,{|x| "ZD_STATUS" $ x[2]})
Local cProd    := M->ZD_PRODUT 
Local cLote    := M->ZD_LOTE      
Local cLoteI   := M->ZD_LI      
Local cLoteE   := M->ZD_LE
Local cCodAna  := M->ZD_CODANAL

For n := 1 to (Len(aCols)-1)
	If Empty(aCols[n][nPos0]) .And. !Empty(aCols[n][nPos1])
		lRet := .F.
	ElseIf Empty(aCols[n][nPos2])
		lRet := .F.
	Endif
Next n       

If Empty(cProd) .Or. (Empty(cLote) .And. Empty(cLoteI)) .Or. Empty(cCodAna) 
	lRet := .F.
EndIf 

If !lRet
	cMsg := "Campos obrigat�rios sem preenchimento!"
	MsgStop(cMsg)
Endif

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002R � Autor �Tiago O. Beraldi    � Data �  15/07/11   ���
�������������������������������������������������������������������������͹��
���Descricao � REVALIDACAO DO LOTE DE PRODUCAO                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002R    

Local aButtons := {}
Local oGet1
Local cGet1 := ""
Local oGet2
Local cGet2 := ""
Local oSay1
Local oSay2  
Local cLote  := SZD->ZD_LOTE   
Local cLoteI := SZD->ZD_LI   
Local cLoteE := SZD->ZD_LE   
Local lOk   := .F.
Local oDlg  

cGet1 := SZD->ZD_DTVALID
cGet2 := DtoC(StoD(Space(8)))

//DEFINE MSDIALOG oDlg TITLE "Revalida��o de Lotes" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL
DEFINE MSDIALOG oDlg TITLE "Revalida��o de Lotes" FROM 100, 000  TO 300, 500 COLORS 0, 16777215 PIXEL

//@ 005, 045 MSGET oGet1 VAR cGet1 WHEN .F. PICTURE "99/99/99" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
//@ 007, 005 SAY oSay1 PROMPT "Validade Atual" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL
//@ 020, 045 MSGET oGet2 VAR cGet2 PICTURE "99/99/99" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
//@ 022, 005 SAY oSay2 PROMPT "Revalida��o" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 045, 045 MSGET oGet1 VAR cGet1 WHEN .F. PICTURE "99/99/99" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 047, 005 SAY oSay1 PROMPT "Validade Atual" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 060, 045 MSGET oGet2 VAR cGet2 PICTURE "99/99/99" SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
@ 062, 005 SAY oSay2 PROMPT "Revalida��o" SIZE 039, 007 OF oDlg COLORS 0, 16777215 PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {||lOk := .T., oDlg:End()}, {||oDlg:End()},, aButtons)         
                                                                            
If lOk   

	cQry := " UPDATE " + RetSqlName("SZD")
	cQry += " SET    ZD_DTVALID = '" + DtoS(CtoD(cGet2)) + "' "
	cQry += " WHERE  ZD_LOTE = '" + cLote + "'"
	cQry += "        AND ZD_LI = '" + cLoteI + "'"
	cQry += "        AND ZD_LE = '" + cLoteE + "'"
	
	TcSqlExec(cQry)

EndIf  

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX002C � Autor �Tiago O. Beraldi    � Data �  15/07/11   ���
�������������������������������������������������������������������������͹��
���Descricao � EXIBE/OCULTA DADOS DE RESULTADO DE ANALISE ( REAL )        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
User Function QIPX002C    
Local aArea		:= GetArea()
Local aAreaSX6	:= SX6->(GetArea())
Local mvPar		:= "MV_REALSZD"

Local oDlg		:= Nil
Local cPwd 		:= Space(08)
Local lRet 		:= .F.

DEFINE MSDIALOG oDlg FROM 0,0 TO 285,544 TITLE "STR0169" Of oMainWnd PIXEL
DEFINE FONT oBold NAME "Courier New" SIZE 0, -13 BOLD
DEFINE FONT oFNor NAME "Tahoma" SIZE 0, -13 

@ 0  , 0 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 55,200 NOBORDER WHEN .F. PIXEL
@ 0.4,08 SAY OemToAnsi("M�dulo Configurador") 									Font oBold Color CLR_BLUE

@ 1.8,08 SAY OemToAnsi("Entre com a senha do administrador para iniciar")		Font oFNor
@ 2.4,08 SAY OemToAnsi("o assistente virtual, o qual o ir� guia-lo durante")	Font oFNor
@ 3.0,08 SAY OemToAnsi("todas as etapas deste processo.")						Font oFNor

@ 5.0,08 SAY OemToAnsi("Este processo ir� levar alguns minutos.")				Font oFNor

@ 8.0,10 SAY OemToAnsi("Senha")													Font oBold
@ 8.0,18 MSGET cPwd Picture "@!" Size 80,08 PASSWORD

DEFINE SBUTTON FROM 130,240 TYPE 1 ACTION ( IIf( cPwd == DtoS(dDatabase), ( lRet := .T., oDlg:End() ), MsgStop("Senha inv�lida.") )) ENABLE OF oDlg PIXEL
DEFINE SBUTTON FROM 130,210 TYPE 2 ACTION ( lRet := .F., oDlg:End() ) ENABLE OF oDlg PIXEL
    
ACTIVATE MSDIALOG oDlg CENTERED

If lRet

	SX6->( dbSetOrder(1) )
	SX6->( dbSeek( xFilial("SX6") + mvPar ) )
	
	If SX6->( !Found() )
	
		RecLock("SX6", .T.) 
			SX6->X6_FIL		:= xFilial("SX6") 
			SX6->X6_VAR		:= mvPar 
			SX6->X6_TIPO	:= "L" 
			SX6->X6_DESCRIC	:= "Exibe/Oculta campos com resultado de analise ( REAL )" 
			SX6->X6_CONTEUD	:= ".F."
			SX6->X6_PROPRI	:= "U" 
			SX6->X6_PYME	:= "S" 
		SX6->( MsUnlock() )
	
	Else
	
		RecLock("SX6", .F.) 
			SX6->X6_CONTEUD	:= IIf( RTrim(SX6->X6_CONTEUD) == ".T.", ".F.", ".T." )
		SX6->( MsUnlock() )
	
	EndIf	
	   
	//Atualiza valor da variavel privada que controla exibicao dos campos 
	lExibeReal := ( RTrim(SX6->X6_CONTEUD) == ".T." )
	
EndIf

RestArea(aAreaSX6)
RestArea(aArea)

Return( Nil )