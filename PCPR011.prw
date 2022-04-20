#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    
#include "colors.ch" 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCPR011   � Autor �Tiago O. Beraldi    � Data �  01/08/09   ���
�������������������������������������������������������������������������͹��
���Descricao �IMPRESSAO DE PROCESSOS                                      ���
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
User Function PCPR011()   


//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local aArea     := GetArea()  
Local lOk	    := .F.      

Private cPerg   := "PCPR011"    
Private cTitulo := ""  

//���������������������������������������������������������������������Ŀ
//� Dicionario de Perguntas                                             �
//�����������������������������������������������������������������������
fCriaSX1(cPerg)    
Pergunte(cPerg, .F.)

cTitulo := "PROCESSO DE PRODU��O"

oPrint := PcoPrtIni(cTitulo, .F., 2,, @lOk, cPerg) 

If lOk
	oProcess := MsNewProcess():New({|lEnd| PCPR011Imp(@lEnd, oPrint, oProcess)},"","",.F.)
	oProcess :Activate()
	PcoPrtEnd(oPrint)
EndIf
                   
RestArea(aArea)                              

Return
          
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCPR011IMP� Autor �Tiago O Beraldi     � Data � 06/02/09    ���
�������������������������������������������������������������������������͹��
���Descricao �FUNCAO DE IMPRESSAO                                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PCPR011Imp(lEnd,oPrint)     

//���������������������������������������������������������������������Ŀ
//� Variaveis                                                           �
//�����������������������������������������������������������������������
Private nLin    := 6000

//���������������������������������������������������������������������Ŀ
//� Fontes utilizadas                                                   �
//�����������������������������������������������������������������������
Private oFont1  := TFont():New( "Tahoma"     ,,16,,.T.,,,,,.F.)
Private oFont2  := TFont():New( "Tahoma"     ,,10,,.T.,,,,,.F.)
Private oFont3  := TFont():New( "Tahoma"     ,,12,,.F.,,,,,.F.)
Private oFont4  := TFont():New( "Tahoma"     ,,14,,.T.,,,,,.F.)
Private oFont5  := TFont():New( "Courier New",,12,,.F.,,,,,.F.)
Private oFont6  := TFont():New( "Tahoma"     ,,20,,.T.,,,,,.F.)
                                                                        
Private cTitulo := "Processo de Produ��o - " + AllTrim(mv_par01) + " (" +;
                   Alltrim(Posicione("SB1",1,xFilial("SB1") + mv_par01,"B1_DESC")) + ")"            
                   
//���������������������������������������������������������������������Ŀ
//� Incio da Impressao                                                  �
//�����������������������������������������������������������������������
oPrint:SetPaperSize(9)  //Papel A4
oPrint:SetPortrait()    //Retrato

SG2->(dbSetOrder(3))
SG2->(dbSeek(xFilial("SG2") + mv_par01))

SB1->(dbSetOrder(1))
SB1->(dbSeek(xFilial("SB1") + SG2->G2_PRODUTO))

SG5->(dbSetOrder(1))
If !SG5->(dbSeek(xFilial("SG5") + SB1->B1_COD + SB1->B1_REVATU))
	MsgStop("N�o h� revis�o cadastrada para o produto")
	Return
EndIf
        
cTpO := ""   

nCnt := 0

While !SG2->(EOF()) .And. SG2->G2_PRODUTO == mv_par01

    If nLin > 2800  
                      
		If nCnt == 1
			oPrint:Say(0445, 0185, "FL. 01 / 02", oFont2)  
			nCnt++
		Else
			nCnt++			                   
		EndIf
		 
   		oPrint:EndPage()
		oPrint:StartPage()
		
		// Box
		oPrint:Box(0150, 0050, 0500, 2330) 
		oPrint:Box(0151, 0051, 0501, 2331) 
		                  
		// Linhas Horizontais
		oPrint:Box(0225, 0050, 0226, 1900)
		oPrint:Box(0425, 0050, 0426, 0550)
                             
		// Linhas Verticais
		oPrint:Box(0150, 1900, 0500, 1901)
		oPrint:Box(0150, 0550, 0500, 0551)
		
		oPrint:Say(0165, 0169, "N� / Revis�o", oFont2)  
		oPrint:Say(0165, 0980, "Descri��o do Material", oFont2)  

		oPrint:SayBitmap(0215, 1960, "EURO.BMP", 320, 210)
		oPrint:Say(0290, 0115, "FP-" + AllTrim(StrTran(SB1->B1_COD, 'KONILON', ''))  + "/" + Subs(AllTrim(SG5->G5_REVPRC), 2, 2), oFont1)      
		oPrint:Say(0325, 0900, SB1->B1_DESC, oFont6)                     
		
		nLin := 600

		// Box
		oPrint:Box(3150, 0050, 3350, 2330) 
		oPrint:Box(3151, 0051, 3351, 2331) 
		                  
		// Linhas Horizontais
		oPrint:Box(3200, 0050, 3201, 2330)
                             
		// Linhas Verticais
		oPrint:Box(3150, 0810, 3350, 0811)
		oPrint:Box(3150, 1570, 3350, 1571)
		
		oPrint:Say(3155, 0075, "Elabora��o / Data", oFont2)
		oPrint:Say(3155, 0835, "Aprova��o / Data", oFont2)
		oPrint:Say(3155, 1595, "Distribui��o de C�pia", oFont2)
		
		oPrint:Say(3275, 0075, "____/____/____ ________________", oFont2)
		oPrint:Say(3275, 0835, "____/____/____ ________________", oFont2)
		oPrint:Say(3250, 1595, "CONFIDENCIAL", oFont1)

	EndIf

	If SG2->G2_TPOPER == cTpO     
        nCol := 112 
		For nn := 1 To MlCount(SG2->G2_DESCRIC, nCol)
			cText := Memoline(SG2->G2_DESCRIC, nCol, nn)
			If ".." $ cText
				nLin += 20
				oPrint:Say( nLin , 0080 , cText , oFont5)  
	        Else
				oPrint:Say( nLin , 0080 , cText , oFont3)
			EndIf
			nLin += 55
        Next 
       	nLin += 55
    Else
    	cTpO := SG2->G2_TPOPER                   
    	oPrint:Box(nLin, 0050, nLin + 2, 2338)
		nLin += 10
		oPrint:Say(nLin, 0050, Tabela("15", Alltrim(cTpO)) + ":", oFont4)
		nLin += 60
    	oPrint:Box(nLin, 0050, nLin + 2, 2338)    	
    	nLin += 20    	

        nCol := 112
		For nn := 1 To MlCount(SG2->G2_DESCRIC, nCol)
			cText := Memoline(SG2->G2_DESCRIC, nCol, nn)
			If ".." $ cText
				nLin += 20
				oPrint:Say(nLin, 0080, cText, oFont5)
	        Else
				oPrint:Say(nLin, 0080, cText, oFont3)
			EndIf
			nLin += 55
        Next    
       	nLin += 55
    EndIf     
    	
	SG2->(dbSkip()) 
	
EndDo	
            
cTpO := SG2->G2_TPOPER
oPrint:Box(nLin, 0050, nLin + 2, 2338)
nLin += 10
oPrint:Say(nLin, 0050, "REVIS�ES", oFont4)
nLin += 60          
oPrint:Box(nLin, 0050, nLin + 2, 2338)
nLin += 20

//oPrint:Say(nLin, 0080, SG5->G5_HIST, oFont3)
nCol := 112
For nn := 1 To MlCount(SG5->G5_HIST, nCol)
	cText := Memoline(SG5->G5_HIST, nCol, nn)
	oPrint:Say(nLin, 0080, cText, oFont3)
	nLin += 55
Next nn

If nCnt > 1
	oPrint:Say(0445, 0185, "FL. 02 / 02", oFont2)                     
Else
	oPrint:Say(0445, 0185, "FL. 01 / 01", oFont2)                     
EndIf

// Box
oPrint:Box(3150, 0050, 3350, 2330)
oPrint:Box(3151, 0051, 3351, 2331)

// Linhas Horizontais
oPrint:Box(3200, 0050, 3201, 2330)

// Linhas Verticais
oPrint:Box(3150, 0810, 3350, 0811)
oPrint:Box(3150, 1570, 3350, 1571)

oPrint:Say(3155, 0075, "Elabora��o / Data", oFont2)
oPrint:Say(3155, 0835, "Aprova��o / Data", oFont2)
oPrint:Say(3155, 1595, "Distribui��o de C�pia", oFont2)

oPrint:Say(3275, 0075, "____/____/____ ________________", oFont2)
oPrint:Say(3275, 0835, "____/____/____ ________________", oFont2)
oPrint:Say(3250, 1595, "CONFIDENCIAL", oFont1)

oPrint:EndPage()	

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FCRIASX1  � Autor �Tiago O. Beraldi    � Data �  06/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao �GERA DICIONARIO DE PERGUNTAS                                ���
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

Local cKey     := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","Produto           ?","","","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a Emiss�o Inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return