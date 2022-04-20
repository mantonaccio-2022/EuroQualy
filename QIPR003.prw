#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"        

#define PAD_LEFT            0
#define PAD_RIGHT           1
#define PAD_CENTER          2

#define ENTER chr(13) + chr(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QIPR003   � Autor �Tiago O. Beraldi    � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao �CERTIFICADO DE ANALISE                                      ���
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
User Function QIPR003()       

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local lOk		 := .T.      

Private cArq     := "" 
Private aArq     := {}

Private cPerg    := "QIPR003"
Private aArea    := GetArea()
Private aDadosC  := {}  //Matriz Cabecalho
Private aDadosI  := {}  //Matriz Itens          
Private nLin     := 150    

//���������������������������������������������������������������������Ŀ
//� Fontes utilizadas                                                   �
//�����������������������������������������������������������������������
Private oFont0   := TFont():New( "Tahoma"            ,,12     ,,.T.,,,,,.F.) 
Private oFont1   := TFont():New( "Tahoma"            ,,10     ,,.F.,,,,,.F.) 
Private oFont2   := TFont():New( "Tahoma"            ,,10     ,,.T.,,,,,.F.) 
Private oFont3   := TFont():New( "Tahoma"            ,,08     ,,.F.,,,,,.F.) 
Private oFont4   := TFont():New( "Tahoma"            ,,08     ,,.T.,,,,,.F.) 

If Select("QRY") > 0          
	QRY->(dbCloseArea())
EndIf

//���������������������������������������������������������������������Ŀ
//� Verifica dicionario de perguntas                                    �
//�����������������������������������������������������������������������
//fCriaSX1(cPerg)
ValidPerg(cPerg)
Pergunte(cPerg, .F.)

//���������������������������������������������������������������������Ŀ
//� Impressao                                                           �
//�����������������������������������������������������������������������
oPrint   := PcoPrtIni("Certificado de An�lise", .F., 2, .T., @lOk, cPerg) 

oProcess := MsNewProcess():New({|lEnd| fQIPR003I(@lEnd, oPrint, oProcess)},"","",.F.)
oProcess :Activate()
		
PcoPrtEnd(oPrint)           

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FQIPR003I � Autor �Tiago O. Beraldi    � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao �IMPRESSAO                                                   ���
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
Static Function fQIPR003I(lEnd, oPrint, oProcess)

Local lSave 

If MsgYesno("Deseja salvar os cert. an�lise?", "Impress�o de Cert. de An�lise")
	lSave := .T.
Else
	lSave := .F.
EndIf

For nLoop := 1 to Len( Alltrim(mv_par01) ) Step 7

    nLin    := 150
	
	//���������������������������������������������������������������������Ŀ
	//� Processa dados                                                      �
	//�����������������������������������������������������������������������
	If !fDataProc(Subs(mv_par01, nLoop, 6))
		MsgAlert("Parametros inv�lidos!")
		Return
	EndIf                                                                    
	          
	//Verifica Validade
 	If CtoD(aDadosC[6]) <= dDataBase
		MsgStop("Lote vencido! Verifique a validade junto ao laborat�rio.")
	    Return
	EndIf  
        
	oPrint :StartPage()

	//���������������������������������������������������������������������Ŀ
	//� Cabecalho                                                           �
	//�����������������������������������������������������������������������
	fCabec()
	
	//���������������������������������������������������������������������Ŀ
	//� Detalhe                                                             �
	//�����������������������������������������������������������������������
	fDetalhe()  
	
	//���������������������������������������������������������������������Ŀ
	//� Rodape                                                              �
	//�����������������������������������������������������������������������
	fRodape()    

	oPrint :EndPage()
	
	//���������������������������������������������������������������������Ŀ
	//� Salva certificado e envia por e-mail para o cliente                 �
	//�����������������������������������������������������������������������
	If lSave    
	
		//cArq := Lower("L:\laudos\emp_" + AllTrim(cNumEmp) + "_NF_" + AllTrim(mv_par02) + "_LOTE_" + aDadosC[5])
		cArq := Lower("\laudos\emp_" + AllTrim(cNumEmp) + "_NF_" + AllTrim(mv_par02) + "_LOTE_" + aDadosC[5])
	
		oPrint:SaveAllAsJPEG(cArq, 900, nLin/2, 140)         
		  
		If ( SF2->F2_TIPO == "N" ) .And. ( SA1->A1_LAUDO == "S" )
			EnvEmail()
		Else
			MsgStop("Nao foi possivel enviar o laudo referente ao lote " + aDadosC[5] + " por e-mail.")
		EndIf
		
	EndIf

Next nLoop   


Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fDetalhe  � Autor �Tiago O. Beraldi    � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao �DETALHE IMPRESSAO                                           ���
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
Static Function fDetalhe()
       
For i := 1 to Len(aDadosI)
	
	nLin += 75
	oPrint :Say( nLin, 0050, aDadosI[i][1], oFont1,,,, PAD_LEFT)
	oPrint :Say( nLin, 0850, aDadosI[i][2], oFont1,,,, PAD_CENTER) 
	                      
	If aDadosI[i][8] == "2"
		oPrint :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
	            "Max. " + aDadosI[i][4]), oFont1,,,, PAD_CENTER)
	ElseIf aDadosI[i][8] == "3"
		oPrint :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
	            "Min. " + aDadosI[i][3]), oFont1,,,, PAD_CENTER)
	Else
		oPrint :Say( nLin, 1450, Iif(!Empty(aDadosI[i][5]), aDadosI[i][5],;
                aDadosI[i][3] + " - " + aDadosI[i][4]), oFont1,,,, PAD_CENTER)
    EndIf	
	
	oPrint :Say( nLin, 2100, Iif(!Empty(aDadosI[i][5]), "OK",;
	                          aDadosI[i][7]), oFont1,,,, PAD_CENTER)
	
Next i
	
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fRodape   � Autor �Tiago O. Beraldi    � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao �RODAPE DE IMPRESSAO                                         ���
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
Static Function fRodape()

oPrint :Say( 3000, 1170, " Documento emitido eletronicamente - dispensa assinatura ", oFont4,,,, PAD_CENTER)
oPrint :Say( 3100, 1170, " Euroamerican do Brasil Importa��o, Ind�stria e Com�rcio Ltda." +;
                         " - Av. Antonio Bardella, 789 - Vl. M�rcia - Jandira - SP", oFont3,,,, PAD_CENTER)
oPrint :Say( 3150, 1170, " Visite nossa p�gina: www.euroamerican.com.br -" +;
                         " PABX: (11)4619-8400 - Fax:(11)4619-8425", oFont3,,,, PAD_CENTER)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCabec    � Autor �Tiago O. Beraldi    � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao �CABECALHO DE IMPRESSAO                                      ���
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
Static Function fCabec()    
  
Local cLogo 	:= "EURO.BMP"
Local nCol		:= 50
Local lAddLin	:= .F.

oPrint :SayBitmap(nLin, 0050, cLogo, 0470, 0250)                            

nLin += 50                                                                   
oPrint :Say( nLin, 1170, " EUROAMERICAN DO BRASIL ", oFont0,,,, PAD_CENTER)

nLin += 50                                                                   
oPrint :Say( nLin, 1170, " Importa��o, Ind�stria e Com�rcio Ltda ", oFont1,,,, PAD_CENTER)

nLin += 100
oPrint :Say( nLin, 1170, " CERTIFICADO DE AN�LISE ", oFont2,,,, PAD_CENTER)

nLin += 75
oPrint :Box( nLin, 0050, nLin + 3, 2350 ) 

//��������������������������������������������������������������Ŀ
//� Imprime informacoes da NF/OP de acordo com parametros        �
//���������������������������������������������������������������� 
nLin += 50
oPrint :Say( nLin, 0050, " Cliente: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 0220, aDadosC[1], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1350, " N.F.: ", oFont2,,,, PAD_LEFT)          
oPrint :Say( nLin, 1500, aDadosC[2], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1850, " Ordem Compra: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 2150, aDadosC[8], oFont1,,,, PAD_LEFT)

nLin += 75
oPrint :Say( nLin, 0050, " Produto: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 0250, aDadosC[4], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 0850, " Lote: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 1000, aDadosC[5], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1350, " Fabrica��o: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 1600, aDadosC[3], oFont1,,,, PAD_LEFT)
oPrint :Say( nLin, 1850, " Validade: ", oFont2,,,, PAD_LEFT)    
oPrint :Say( nLin, 2150, aDadosC[6], oFont1,,,, PAD_LEFT)
       
If !Empty(aDadosC[9])
	nLin 	+= 75 
	nCol := 850
	
	oPrint :Say( nLin, 0050, " Fabricante: ", oFont2,,,, PAD_LEFT)
	oPrint :Say( nLin, 0250, aDadosC[9], oFont1,,,, PAD_LEFT)
EndIf	

If mv_par05  > 0

	If MsgYesNo("Deseja imprimir a Quantidade no Laudo?")
		If nCol == 50
			nLin += 75
		EndIf
	
		oPrint :Say( nLin, nCol, " Quantidade: ", oFont2,,,, PAD_LEFT)
		oPrint :Say( nLin, nCol+200, Alltrim(Transform(mv_par05,"@E 999,999,999.99"))+" Kg", oFont1,,,, PAD_LEFT)

	EndIf

EndIf

nLin += 75
oPrint :Box( nLin, 0050, nLin + 3, 2350 )                      

nLin += 50
oPrint :Box( nLin - 20, 0050, nLin + 50, 2350 )                      
oPrint :Say( nLin, 0050, " Observa��es: ", oFont4,,,, PAD_LEFT)
oPrint :Say( nLin, 0300, " As embalagens devem ser mantidas bem fechadas" +;
                         " em ambiente ventilado, protegidas de intemp�ries.", oFont3,,,, PAD_LEFT)
nLin += 75
oPrint :Say( nLin, 0050, " Analisado por: ", oFont2,,,, PAD_LEFT)
oPrint :Say( nLin, 0350, aDadosC[7], oFont1,,,, PAD_LEFT)

nLin += 100
oPrint :Say( nLin, 0250, " An�lises ", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 0850, " M�todo ", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 1450, " Especifica��es", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 2100, " Resultados ", oFont2,,,, PAD_CENTER)

nLin += 50
oPrint :Say( nLin, 0250, " F�sico Qu�mica ", oFont2,,,, PAD_CENTER)
oPrint :Say( nLin, 0850, " de An�lise ", oFont2,,,, PAD_CENTER)

nLin += 75
oPrint :Box( nLin, 0050, nLin + 3, 2350 )                      


Return           

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fDataProc � Autor �Tiago O. Beraldi    � Data �  16/10/07   ���
�������������������������������������������������������������������������͹��
���Descricao �PROCESSA DADOS                                              ���
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
Static Function fDataProc(cLote)    

Local cProduto  := ""
Local cDescr    := ""
Local lRet      := .F.  
                                            
//��������������������������������������������������������������Ŀ
//� Dados da NF                                                  �
//���������������������������������������������������������������� 
aDadosC := {}  //Matriz Cabecalho
aDadosI := {}  //Matriz Itens                   

dbSelectArea("SF2")
dbSetOrder(1)
If !MsSeek(xFilial("SF2") + mv_par02 + mv_par03)
	MsgAlert("NF n�o encontrada!")
	Return .F.
EndIf     

If SF2->F2_TIPO == "B"   
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA)
	
	cCampo := "SA2->A2_NOME"
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA)
	
	cCampo := "SA1->A1_NOME"
	
	If SA1->A1_LAUDO == "N"
		MsgStop("Cliente n�o habilitado para envio de Laudo!")
		Return
	EndIf

EndIf

//��������������������������������������������������������������Ŀ
//� Dados da OP                                                  �
//���������������������������������������������������������������� 
If mv_par04 == 1                        

	cQry := " UPDATE " + RetSqlName("SC2")
	cQry += " SET    C2_DTETIQ = '" + DtoS(dDataBase) + "' "
	cQry += " WHERE  C2_NUM = '" + cLote + "' AND C2_DTETIQ = ''"
	
	TcSqlExec(cQry)
    
	cQry := " SELECT	MIN(C2_DTETIQ) C2_DTETIQ "
	cQry += " FROM " + RetSqlName("SC2")  
	cQry += " WHERE   D_E_L_E_T_ <> '*' "
	cQry += "         AND C2_NUM = '" + cLote + "' "
    
	TCQUERY cQry NEW ALIAS QRY        
	TcSetField("QRY", "C2_DTETIQ", "D", 8, 0)
	
	If EOF()
		MsgAlert("Lote inv�lido. Lote " + cLote + "!")
		Return .F.
	EndIf
	
EndIf

//��������������������������������������������������������������Ŀ
//� Dados da Analise                                             �
//���������������������������������������������������������������� 
dbSelectArea("SZD")
If mv_par04 == 1
	dbSetOrder(2)                
	If !MsSeek(xFilial("SZD") + cLote)
		MsgAlert("Lote n�o analisado. Lote: " + cLote + "!")
		Return .F.
	EndIf
Else
	dbSetOrder(3)                
	If !MsSeek(xFilial("SZD") + cLote)
		MsgAlert("Lote n�o analisado. Lote: " + cLote + "!")
		Return .F.
	EndIf
EndIf

cProduto := SZD->ZD_PRODUT

//��������������������������������������������������������������Ŀ
//|Verifica Produto X NF                                         �
//���������������������������������������������������������������� 
dbSelectArea("SD2")
dbSetOrder(3)
MsSeek(xFilial("SD2") + mv_par02 + mv_par03)
     
dbSelectArea("SB1")
dbSetOrder(1)                                 

If Subs(cProduto, 1, 2) == "MP"
	MsSeek(xFilial("SB1") + cProduto)                 
Else
	MsSeek(xFilial("SB1") + AllTrim(cProduto))
EndIf

dbSelectArea("SD2") 

cPedCom := ""

While !EOF("SD2") .And. (SD2->D2_DOC + SD2->D2_SERIE) == (mv_par02 + mv_par03)  

	If Subs(cProduto, 1, 2) == "MP"
		bEvalPrd := {|| SD2->D2_COD == cProduto}
	ElseIf	Subs(SD2->D2_COD, 1, 3) == "870"	//Exce��o linha 870 � envase 470
		bEvalPrd := {|| Subs(cProduto, 1, 3) $ "470#870" .Or. SD2->D2_COD == cProduto }
	Else
		bEvalPrd := {|| Subs(SD2->D2_COD, 1, 3) == Subs(cProduto, 1, 3)}
	EndIf

	// Verifica compatibilidade de Lote x NF Saida
	cQry := " SELECT 	C2_NUM " + ENTER
	cQry += " FROM 		" + RetSqlName("SC2") + " "+ ENTER
	cQry += " WHERE 	D_E_L_E_T_ = '' " + ENTER
	cQry += " 			AND C2_FILIAL = '" + XFILIAL("SC2") + "' " + ENTER
	cQry += " 			AND C2_NUM = '" + cLote + "' " + ENTER
	cQry += " 			AND C2_PRODUTO = '" + SD2->D2_COD + "' " + ENTER
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS QRY

    If Eval(bEvalPrd) .And. !QRY->(EOF())
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		MsSeek(SD2->D2_FILIAL + SD2->D2_PEDIDO + SD2->D2_ITEMPV + SD2->D2_COD)
        
		/*RecLock("SC6", .F.)		
			SC6->C6_LOTECTL := cLote         
			SC6->C6_LOTES   := SC6->C6_LOTES + "Lote: " + cLote + " Valid.: " + DtoC(SZD->ZD_DTVALID) + chr(13) + chr(10)
		   	SC6->C6_DTVALID := SZD->ZD_DTVALID
		SC6->( MsUnLock() )*/
		
		cDescr  := SC6->C6_DESCRI
		cPedCom += Iif(!Empty(cPedCom) .And. !Empty(SC6->C6_PEDCLI), "-", "") + SC6->C6_PEDCLI 
				
    	lRet := .T.            	
    	
    EndIf     
    
   	QRY->(dbCloseArea())
    
	dbSelectArea("SD2")
	dbSkip()
EndDo                  
   

If !lRet
  	MsgAlert("NF x Lote incompat�veis!")
	Return .F.
EndIf	         


/************************** aDadosC	***********************
1  - Cliente 
2  - NF   
3  - Fabricacao                   
4  - Produto                    
5  - Lote                          
6  - Validade                         
7  - Analisado por       
8  - Pedido de Compra        
9  - Fabricante 
/*********************************************************/                         
dbSelectArea("SZD")
If mv_par04 == 1
	dbSetOrder(2)                
	MsSeek(xFilial("SZD") + cLote)
Else
	dbSetOrder(3)                
    MsSeek(xFilial("SZD") + cLote)
EndIf

//Matriz Vetor Cabecalho
aAdd(aDadosC, Upper(&cCampo))
aAdd(aDadosC, mv_par02)
aAdd(aDadosC, DtoC(SZD->ZD_DTFABR))
aAdd(aDadosC, Upper(cDescr))
aAdd(aDadosC, AllTrim(SZD->ZD_LE) + "(" + cLote + ")")
aAdd(aDadosC, DtoC(SZD->ZD_DTVALID))
aAdd(aDadosC, Iif(Empty(SZD->ZD_ANALIS), "Thiago Silva", SZD->ZD_ANALIS))
aAdd(aDadosC, cPedCom) 
aAdd(aDadosC, Posicione("SA2", 1, xFilial("SA2") + SZD->ZD_FORN, "A2_NOME"))

If mv_par04 == 1
	cExpr := "SZD->ZD_LOTE"
Else
	cExpr := "SZD->ZD_LI"
EndIf

While !EOF("SZD") .And. TRIM(&cExpr) == cLote 

	If AllTrim(cProduto) != AllTrim(SZD->ZD_PRODUT)
		dbSelectArea("SZD")
		dbSkip()		
		Loop
	EndIf

	/************************** aDadosI	***********************
	1  - Descricao do Ensaio
	2  - Metodo de Analise   
	3  - Lim Inferior                 
	4  - Lim Superior               
	5  - Resultado texto padrao              
	6  - Resultado texto 
	7  - Resultado
	8  - Limite da medida
	/*********************************************************/
    dbSelectArea("QPJ")
    dbSetOrder(2)
    MsSeek(xFilial("QPJ") + SZD->ZD_ENSAIO + AllTrim(cProduto) + Space(15 - Len(AllTrim(cProduto))) + SZD->ZD_ITEM)
                  
    //Impede impressao de Lotes fora da especificacao
    If SZD->ZD_STATUS != "A"
   		MsgStop("O Lote " + SZD->ZD_LOTE + " apresenta item(s) de especifica��o reprovados. Impress�o cancelada!")
   		Return .T.
    EndIf
    
    If SZD->ZD_IMPRES != "N" 
		//Matriz Vetor Detalhe
		aAdd(aDadosI,{Posicione("QP1", 1, xFilial("QP1") + SZD->ZD_ENSAIO, "QP1_DESCPO");
	                , Upper(SZD->ZD_METODO);
		            , AllTrim(Transform(SZD->ZD_LINF, "@E 999,999.99"));
		            , AllTrim(Transform(SZD->ZD_LSUP, "@E 999,999.99"));
		            , Upper(AllTrim(SZD->ZD_RTEXTP));
	   	            , Upper(SZD->ZD_RTEXTO);
		            , AllTrim(Transform(SZD->ZD_RNUM, "@E 999,999.99"));
		            , SZD->ZD_LIMITE})
	EndIf

	dbSelectArea("SZD")
	dbSkip()
EndDo                          
                  
If Select("QRY") > 0          
	QRY->(dbCloseArea())
EndIf
   
Return .T.           

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fCriaSX1  � Autor �Tiago O. Beraldi    � Data �  10/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �DICIONARIO DE PERGUNTAS                                     ���
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
Static Function fCriaSX1(cPerg)

//���������������������������������������������������������������������Ŀ
//|Declaracao de variaveis                                              �
//�����������������������������������������������������������������������
Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","Lotes            ? ","","","mv_ch1","C",35,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","Nota Fiscal      ? ","","","mv_ch2","C",09,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","S�rie            ? ","","","mv_ch3","C",03,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"04","Tipo             ? ","","","mv_ch4","N",01,0,0,"C","","","","","mv_par04","Prod Acabado","","","","Mat Prima","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"05","Qtde./Kg         ? ","","","mv_ch5","N",07,2,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe os Lotes.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "02."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Nota Fiscal.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "03."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a S�rie da NF.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)  

cKey     := "P." + cPerg + "04."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe o Tipo de Produto.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "05."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Quantidade em Kg.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return Nil

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidPerg � Autor � Rodrigo Sousa  		� Data � 15.08.12  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := cPerg + Space(3)

Aadd(aPerg, {cPerg, "01", "Lotes		    ?", "MV_CH1" , 	"C", 35	, 0	, "G"	, "MV_PAR01", ""	,""		,""				,""				,"","",0})
Aadd(aPerg, {cPerg, "02", "Nota Fiscal    	?", "MV_CH2" , 	"C", 09	, 0	, "G"	, "MV_PAR02", ""	,""		,""				,""				,"","",0})
Aadd(aPerg, {cPerg, "03", "S�rie 	        ?", "MV_CH3" , 	"C", 03	, 0	, "G"	, "MV_PAR03", ""	,""		,""				,""				,"","",0})
Aadd(aPerg, {cPerg, "04", "Tipo      		?", "MV_CH4" , 	"N", 01	, 0	, "C"	, "MV_PAR04", ""	,"Prod. Acabado"		,"Materia Prima"				,""				,"","",0})
Aadd(aPerg, {cPerg, "05", "Qtde/Kg         	?", "MV_CH5" , 	"N", 12	, 0	, "G"	, "MV_PAR05", ""	,""		,""				,""				,"","",2})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	Replace X1_DECIMAL with aPerg[i,16]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)



/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �EnvEmail  � Autor �                       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function EnvEmail()  
Local cSrvMail  := AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := AllTrim(GetMV("MV_RELPSW")) 
Local cAuthent	:= AllTrim(GetMV("MV_RELAUTH"))    

Local cDe		:= ""
Local cPara		:= ""
Local cCc		:= ""
Local cCco		:= "cq@euroamerican.com.br"
Local cSubject  := ""
Local cBody		:= ""

//+----------------------------------------------------------------------------
//| Define email de remetente 
//+----------------------------------------------------------------------------   

If Left(cFilAnt,2) == "02"
	
	If AllTrim(cFilAnt) $ "00#01#04"
		cDe      := "workflow@euroamerican.com.br"
		cSubject := "Certificado de Analise - EUROAMERICAN"
		
	ElseIf AllTrim(cFilAnt) $ "03"
		cDe      := "workflow@qualyvinil.com.br"
		cSubject := "Certificado de Analise - QUALYVINIL"
		
	EndIf
	
ElseIf Left(cFilAnt,2) == "03"
	
	cDe      := "workflow@qualyvinil.com.br"
	cSubject := "Certificado de Analise - QUALYVINIL"
	
ElseIf Left(cFilAnt,2) == "01"
	
	If AllTrim(cFilAnt) $ "08"
		cDe      := "workflow@qualycor.com.br"
		cSubject := "Certificado de Analise - QUALYCOR"
		
	ElseIf AllTrim(cFilAnt) $ "07"
		cDe      := "workflow@jaystintas.com.br"
		cSubject := "Certificado de Analise - JAYS TINTAS"
		
	EndIf
	
EndIf


//+----------------------------------------------------------------------------
//| Define mensagem de corpo
//+----------------------------------------------------------------------------
cBody := "Prezado Cliente, " + ENTER + ENTER 
cBody += "Segue anexo certificado de analise do seu produto." + ENTER + ENTER 
cBody += "Este e-mail foi enviado automaticamente e n�o deve ser respondido." 


//+----------------------------------------------------------------------------
//| Define anexo 
//+----------------------------------------------------------------------------
cDir := "\Laudos\"
aArq := Directory( cArq + "*.jpg" )

If Len(aArq) <= 0
	Return
EndIf

cAnexo := cDir + aArq[1][1]
For nX := 2 to Len(aArq)
	cAnexo := cAnexo + "#" + cDir + aArq[nX][1]
Next nX

//+----------------------------------------------------------------------------
//| Define email de destino
//+----------------------------------------------------------------------------
cPara := SA1->A1_EMAIL
//cPara := "alexandre.marson@euroamerican.com.br"       

//+----------------------------------------------------------------------------
//| Define objeto de email
//+----------------------------------------------------------------------------
CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk

If (lOk)
	
	If cAuthent == ".T."
		MAILAUTH(cUserAut, cPassAut)
	EndIf
	
	SEND MAIL FROM cDe TO cPara ;
	BCC cCco ;
	CC cCc ;
	SUBJECT cSubject ;
	BODY cBody ;  
	ATTACHMENT cAnexo;
	RESULT lOK     
	DISCONNECT SMTP SERVER

	
Endif       

Return 

