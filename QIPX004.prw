#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX004  � Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES                                 ���
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
User Function QIPX004()    

Private cAlias    := "QPJ"
Private cCadastro := "Cadastro de Especifica��es"
Private aRotina   := {}
Private aCores    := {}
Private nCnt      := 0
Private nUsado    := 0
Private cVarTemp  := ""
Private oDlg      := Nil
Private oGet      := Nil
Private nOpcA     := 0
Private aHeader   := {}   
Private nOpcao    := 2    

//������������������������������������������������������������Ŀ
//� Menu                                                       �
//��������������������������������������������������������������
aAdd( aRotina, {"Pesquisar"  ,"AxPesqui"  ,0,1})
aAdd( aRotina, {"Incluir"    ,'U_QIPX004I',0,3})
aAdd( aRotina, {"Alterar"    ,'U_QIPX004A',0,4})
aAdd( aRotina, {"Excluir"    ,'U_QIPX004E',0,5})
aAdd( aRotina, {"Legenda"    ,'U_QIPX004L',0,2})

//������������������������������������������������������������Ŀ
//� Filtro                                                     �
//��������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
dbGoTop()

//������������������������������������������������������������Ŀ
//� Legenda                                                    �
//��������������������������������������������������������������
aAdd(aCores,{"QPJ_IMPRES == 'S'","ENABLE"})
aAdd(aCores,{"QPJ_IMPRES == 'N'","DISABLE"})

mBrowse(06,01,22,75,"QPJ",,,,,,aCores)

dbSelectArea("QPJ")
dbSetOrder(1)

Return     

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX004  � Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES - EXCLUSAO                      ���
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
User Function QIPX004E()     
    
Local  cProd := QPJ->QPJ_PROD

If MsgYesNo("Deseja prosseguir com a exclus�o ? ", "Cadastro de Especifica��es")
	While !EOF() .And. QPJ->QPJ_PROD == cProd
		dbSelectArea("QPJ")
		RecLock("QPJ",.F.)
			dbDelete()
		QPJ->( MsUnLock() )
		dbSkip()
	EndDo
EndIf                                 

dbSelectArea("QPJ")
dbSetOrder(1)
dbSeek(xFilial("QPJ") + cProd, .T.) 

Return
   
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX004  � Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES - INCLUSAO                      ���
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
User Function QIPX004I(cAlias, nRecNo, nOpcX)

Local nCnt      := 0
Local Z         := 0
Local cVarTemp  := ""
Local oDlg      := Nil
Local oGet      := Nil
Local nOpcA     := 0
Local cCadastro := "Cadastro de Especifica��es"   
Local aButtons  := {} 

Local cDesc     := Space(30)
Local dData     := dDataBase  

Private nOpcao  := 3
Private cInclui := Alltrim(cUserName)
Private cProd   := Space(15)
Private cAlias  := "QPJ"  
Private cFilQPJ := xFilial("QPJ") 
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0
Private nOpcx 

dbSelectArea(cAlias)
              
While !EOF() .And. QPJ->QPJ_FILIAL + QPJ->QPJ_PROD == cFilQPJ + cProd
	nCnt++
	dbSkip()
End

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. X3_ARQUIVO == cAlias  
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0 
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()) ,;
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
	dbSkip()
End

dbSelectArea(cAlias)   
dbSetOrder(1)
If !dbSeek( cFilQPJ + cProd)
                             
aAdd( aCols,Array(Len(aHeader)+1))

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
nUsado:=0
While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
		nUsado++
		IF Empty(X3_VALID)
			IF X3_TIPO == "C"
				If Trim(aHeader[nUsado][2]) == "QPJ_ITEM"
					aCols[1][nUsado] := "01"
				Else
					aCols[1][nUsado] := SPACE(x3_tamanho)
				Endif
			ElseIf X3_TIPO == "N"
				aCols[1][nUsado] := 0
			ElseIf X3_TIPO == "D"
				aCols[1][nUsado] := dDataBase
			ElseIf X3_TIPO == "M"
				aCols[1][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Else
				aCols[1][nUsado] := .F.
			Endif
			If X3_CONTEXT == "V"
				aCols[1][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
	Endif
	dbSkip()
End

dbSelectArea("QPJ")
dbSetOrder(1)

aCols[1][nUsado+1] := .F.

Else

nCnt := 0

While !EOF() .And. QPJ->QPJ_FILIAL + QPJ->QPJ_PROD == cFilQPJ + cProd
	
	aAdd( aCols, Array(Len(aHeader)+1))
	
	nCnt++
	nUsado:=0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !EOF() .And. X3_ARQUIVO == cAlias
		IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
			nUsado++
			cVarTemp := cAlias+"->"+(X3_CAMPO)
			If X3_CONTEXT # "V"
				aCols[nCnt][nUsado] := &cVarTemp
			ElseIf X3_CONTEXT == "V"
				aCols[nCnt][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
		dbSkip()
	End
	aCols[nCnt][nUsado+1] := .F.
	dbSelectArea(cAlias)
	dbSkip()
End             

EndIf

//������������������������������������������������������������Ŀ
//� Monta GetDados e Enchoice                                  �
//��������������������������������������������������������������

DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 34,100 OF oMainWnd

@ 15, 2 TO 60,394 LABEL "Cadastro de Especifica��es" OF oDlg PIXEL

@ 27, 006 SAY "C�d. Produto....:"  SIZE 78,7 PIXEL OF oDlg
@ 27, 090 SAY "Descri��o.......:" SIZE 78,7 PIXEL OF oDlg
@ 27, 310 SAY "Ultima Altera��o:" SIZE 78,7 PIXEL OF oDlg
 
@ 26, 050 MSGET cProd F3 "SB1" VALID ExistCPO("SB1") PICTURE "@!" SIZE 035,7 PIXEL OF oDlg
@ 26, 134 MSGET Posicione("SB1",1,xFilial("SB1") + cProd, "B1_DESC") When .F. PICTURE "@!" SIZE 100,7 PIXEL OF oDlg
@ 26, 354 MSGET dData When .F. PICTURE "99/99/99" SIZE 32,7 PIXEL OF oDlg    

@ 230, 2 TO 255,394 LABEL "" OF oDlg PIXEL

@ 240,006 SAY "Incluido por:" SIZE 78,7 PIXEL OF oDlg

@ 239,042 MSGET cInclui When .F. PICTURE "@!" SIZE 094,7 PIXEL OF oDlg

oGet := MSGetDados():New(64,3,232,393,nOpcx,,,"+QPJ_ITEM",.T.)   

aAdd(aButtons, {"HISTORIC", {|| CopiaEspec()}, "Copia Especifica��o", "Copia" , {|| .T.}} )    

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX004OK(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},,@aButtons)

dbSelectArea("QPJ")
dbSetOrder(1)
dbSeek(xFilial()+cProd)

If nOpcA == 1
	QIPX004GR(cAlias)
Endif

dbSelectArea(cAlias)

Return    

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX004  � Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES - ALTERACAO                     ���
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
User Function QIPX004A(cAlias, nRecNo, nOpcX)

Local nCnt      := 0
Local Z         := 0
Local cVarTemp  := ""
Local oDlg      := Nil
Local oGet      := Nil
Local nOpcA     := 0
Local cCadastro := "Cadastro de Especifica��es"  
Local aButtons  := {}

Local cDesc     := Posicione("SB1",1,xFilial("SB1") + QPJ->QPJ_PROD, "B1_DESC")
Local dData     := dDataBase  

Private nOpcao  := 4
Private cInclui := Alltrim(cUserName)
Private cProd   := QPJ->QPJ_PROD                
Private cAlias  := "QPJ"  
Private cFilQPJ := xFilial("QPJ") 
Private aHeader := {}
Private aCols   := {}
Private nUsado  := 0    
Private nOpcx 

//������������������������������������������������������������Ŀ
//� Verifica acesso a alteracao                                �
//��������������������������������������������������������������
SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + QPJ->QPJ_PROD))
                                  
dbSelectArea(cAlias)
If RecCount() == 0
	Return .T.
Endif
              
While !EOF() .And. QPJ->QPJ_FILIAL + QPJ->QPJ_PROD == cFilQPJ + cProd
	nCnt++
	dbSkip()
End

If nCnt == 0 .And. nOpcx # 3
	Return .T.
Endif                                  

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
While !EOF() .And. X3_ARQUIVO == cAlias  
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0 
		nUsado++
		AADD(aHeader,{ TRIM(X3Titulo()) ,;
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
	dbSkip()
End

dbSelectArea(cAlias)   
dbSetOrder(1)
If !dbSeek( cFilQPJ + cProd)
                             
aAdd(aCols,Array(Len(aHeader)+1))

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
nUsado:=0
While !EOF() .And. X3_ARQUIVO == cAlias
	IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
		nUsado++
		IF Empty(X3_VALID)
			IF X3_TIPO == "C"
				If Trim(aHeader[nUsado][2]) == "QPJ_ITEM"
					aCols[1][nUsado] := "01"
				Else
					aCols[1][nUsado] := SPACE(x3_tamanho)
				Endif
			ElseIf X3_TIPO == "N"
				aCols[1][nUsado] := 0
			ElseIf X3_TIPO == "D"
				aCols[1][nUsado] := dDataBase
			ElseIf X3_TIPO == "M"
				aCols[1][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Else
				aCols[1][nUsado] := .F.
			Endif
			If X3_CONTEXT == "V"
				aCols[1][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
	Endif
	dbSkip()
End

dbSelectArea("QPJ")
dbSetOrder(1)

aCols[1][nUsado+1] := .F.

Else

nCnt := 0

While !EOF() .And. QPJ->QPJ_FILIAL + QPJ->QPJ_PROD == cFilQPJ + cProd
	
	aAdd( aCols, Array(Len(aHeader)+1))
	
	nCnt++
	nUsado:=0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !EOF() .And. X3_ARQUIVO == cAlias
		IF X3USO(X3_USADO) .AND. X3_NIVEL > 0
			nUsado++
			cVarTemp := cAlias+"->"+(X3_CAMPO)
			If X3_CONTEXT # "V"
				aCols[nCnt][nUsado] := &cVarTemp
			ElseIf X3_CONTEXT == "V"
				aCols[nCnt][nUsado] := CriaVar(AllTrim(X3_CAMPO))
			Endif
		Endif
		dbSkip()
	End
	aCols[nCnt][nUsado+1] := .F.
	dbSelectArea(cAlias)
	dbSkip()
End             

EndIf

//������������������������������������������������������������Ŀ
//� Monta GetDados e Enchoice                                  �
//��������������������������������������������������������������

DEFINE MSDIALOG oDlg TITLE cCadastro From 0,0 To 34,100 OF oMainWnd

@ 15, 2 TO 60,394 LABEL "Cadastro de Especifica��es" OF oDlg PIXEL

@ 27, 006 SAY "C�d. Produto....:"  SIZE 78,7 PIXEL OF oDlg
@ 27, 090 SAY "Descri��o.......:" SIZE 78,7 PIXEL OF oDlg
@ 27, 310 SAY "Ultima Altera��o:" SIZE 78,7 PIXEL OF oDlg
                                                              
@ 42, 090 SAY "Descri��o.......:" SIZE 78,7 PIXEL OF oDlg

@ 26, 050 MSGET cProd When .F. PICTURE "@!" SIZE 035,7 PIXEL OF oDlg
@ 26, 134 MSGET cDesc When .F. PICTURE "@!" SIZE 100,7 PIXEL OF oDlg
@ 26, 354 MSGET dData When .F. PICTURE "99/99/99" SIZE 32,7 PIXEL OF oDlg    

@ 230, 2 TO 255,394 LABEL "" OF oDlg PIXEL

@ 240,006 SAY "Incluido por:" SIZE 78,7 PIXEL OF oDlg

@ 239,042 MSGET cInclui When .F. PICTURE "@!" SIZE 094,7 PIXEL OF oDlg

oGet := MSGetDados():New(64,3,232,393,nOpcx,,,"+QPJ_ITEM",.T.)            

aAdd(aButtons, {"HISTORIC", {|| CopiaEspec()}, "Copia Especifica��o", "Copia" , {|| .T.}} )    

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,Iif(U_QIPX004OK(),oDlg:End(),nOpcA:=0)},{||oDlg:End()},,@aButtons)

dbSelectArea("QPJ")
dbSetOrder(1)
dbSeek(xFilial()+cProd)

If nOpcA == 1
	QIPX004GR(cAlias,nOpcx)
Endif

dbSelectArea(cAlias)

Return    

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX004  � Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES - VALIDA LINHA                  ���
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
User Function QIPX004OK(cAlias)

Local lRet := .T. 

dbSelectArea("QPJ")
dbSetOrder(1)
dbSeek(xFilial("QPJ")+cProd)

If Found() .And. nOpcao # 4 
	MsgStop("J� existe registro de especifica��o para Produto!","Cadastro de Especifica��es")
   	lRet := .F.
EndIf	 
         
dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+cProd)

If !(SB1->B1_TIPO $ "PA#PI#MP#ME")
	MsgStop("S� devem ser cadastradas especifica��es para produtos base","Cadastro de Especifica��es")
   	lRet := .F.
EndIf	 

Return lRet      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX004  � Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES - GRAVACAO                      ���
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
Static Function QIPX004GR(cAlias,nOpcx)

Local lRet  := .T.
Local nI    := 0
Local nY    := 0
Local cVar  := ""
Local lOk   := .T.
Local cMsg  := ""                                        
Local nPos := aScan(aHeader,{|x|AllTrim(Upper(x[2])) == "QPJ_ITEM"})
Local nOPCxTmp := nOpcx

dbSelectArea("QPJ")
dbSetOrder(1)
dbSeek(xFilial("QPJ") + cProd)

For nI := 1 To Len(aCols)
	
	dbSeek(cFilQPJ + cProd + aCols[nI][nPos])
	
	If !aCols[nI][nUsado+1]
		
		//If (Found() .or. nOpcx == 4) .And. !EOF()
		If (Found() .or. nOPCxTmp == 4) .And. !EOF()
			RecLock(cAlias,.F.)
		Else
			RecLock(cAlias,.T.)
		Endif
		 
		QPJ->QPJ_PROD   := cProd
		QPJ->QPJ_DALTER := dDataBase
		QPJ->QPJ_INCLUI := cInclui
 
		For nY = 1 to Len(aHeader)
			If aHeader[nY][10] # "V" 
			    cVar := Trim(aHeader[nY][2])
				Replace &cVar. With aCols[nI][nY]
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
			cMsg := "Nao foi possivel deletar o item " + aCols[nI][nPos] + ", o mesmo possui amarracao"
			MsgStop(cMsg)
		Endif
		
	Endif
	
Next nI

dbSelectArea("QPJ")
dbSetOrder(1)
dbSeek(xFilial("QPJ") + cProd)

Return lRet              

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � QIPX004  � Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES - LEGENDA                       ���
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
User Function QIPX004L(nOpc)

BrwLegenda(cCadastro,"Legenda",{{"ENABLE"    	,"Especifi��o habilitada para impress�o"    },;
								 {"DISABLE"     ,"Especifi��o n�o habilitada para impress�o"}})

Return
     
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �COPIAESPEC� Autor �Tiago O. Beraldi    � Data �  05/03/07   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE ESPECIFICACOES - COPIA ESPECIFICAO DE OUTRO    ���
���          � PRODUTO                                                    ���
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
Static Function CopiaEspec()

Local cPerg := "QIPX004C"

If Pergunte(cPerg, .T.)
	
	cProduto := AllTrim(mv_par01)
	
	QPJ->(dbSetOrder(1))
	
	If QPJ->(dbSeek(xFilial("QPJ") + cProduto))
	
		nItem := 1
		
		While !QPJ->(EOF()) .And. AllTrim(QPJ->QPJ_PROD) == cProduto
		
			//������������������������������������������������������������������Ŀ
			//� Cria linha em branco no acols de acordo com o tamanho do aHeader �
			//��������������������������������������������������������������������
			If nItem <> 1
				Aadd(aCols, Array(Len(aHeader)+1))
				aCols[Len(aCols), Len(aHeader)+1] := .f.
			EndIf
		
			nItem++
			
			For _x := 1 to Len(aHeader)
			
				//��������������������������������������������������������Ŀ
				//� Preenche cada elemento da linha do aCols com seu valor �
				//� padr�o e depois copia os valores do item original.     �
				//����������������������������������������������������������
				If _x == 1
					aCols[Len(aCols), _x] := QPJ_ITEM      //Item
				ElseIf _x == 2
					aCols[Len(aCols), _x] := QPJ_ENSAIO    //Ensaio
				ElseIf _x == 3
					aCols[Len(aCols), _x] := QPJ_DESENS    //Descricao do Ensaio
				ElseIf _x == 4
					aCols[Len(aCols), _x] := QPJ_UNMED     //Unidade de Medida
				ElseIf _x == 5
					aCols[Len(aCols), _x] := QPJ_DUNMED    //Descricao da Unidade de Medida
				ElseIf _x == 6
					aCols[Len(aCols), _x] := QPJ_METODO    //Metodo
				ElseIf _x == 7
					aCols[Len(aCols), _x] := QPJ_LINF      //Limite Inferior
				ElseIf _x == 8
					aCols[Len(aCols), _x] := QPJ_LSUP       //Limite Superior
				ElseIf _x == 9
					aCols[Len(aCols), _x] := QPJ_TEXTO     //Resultado Texto Padrao
				ElseIf _x == 10
					aCols[Len(aCols), _x] := QPJ_LIMITE    //Limite medida
				ElseIf _x == 11
					aCols[Len(aCols), _x] := QPJ_IMPRES    //Impressao
				EndIf
				
			Next
		
			QPJ->(dbSkip())
		
		EndDo

		GetdRefresh()	               
	
	EndIf

EndIf

Return 