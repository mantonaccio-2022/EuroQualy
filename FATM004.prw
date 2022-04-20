#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"   
#include "ap5mail.ch"
#include "msole.ch"

#define ENTER Chr(13)+Chr(10)    
#define OLECREATELINK  400
#define OLECLOSELINK   401
#define OLEOPENFILE    403
#define OLESAVEASFILE  405
#define OLECLOSEFILE   406
#define OLESETPROPERTY 412
#define OLEWDVISIBLE   "206"
#define WDFORMATTEXT   "2" 
#define WDFORMATPDF    "17" // Formato PDF

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATM004   �Autor  �                    � Data �17/05/2018   ���
�������������������������������������������������������������������������͹��
���Descricao �ENVIA ORCAMENTO POR EMAIL E/OU IMPRESSAO                    ���
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
User Function FATM004

//������������������������������������������������������������������Ŀ
//� Definicao de variaveis                                           �
//��������������������������������������������������������������������          
Local aArea      := GetArea()

Private oOrcVen  := Nil
Private nOpc     := 0
Private bOk      := {||nOpc:=1, oOrcVen:End()}
Private bCancel  := {||nOpc:=0, oOrcVen:End()}
Private cObs     := Space(0)
Private cCc      := UsrRetMail(__cUserID) //Alterado 29/11/16 Space(200)
Private cCco     := UsrRetMail(__cUserID)
Private cDe      := AllTrim(GetMV("MV_RELACNT")) //UsrRetMail(__cUserID)
Private cPara    := Space(200)          
Private cMsg

//������������������������������������������������������������������Ŀ
//� Tipo do Cliente (Prospect/Normal)                                �
//��������������������������������������������������������������������          
If 	!Empty(SCJ->CJ_CLIENTE)
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA))
	
	cPara    := SA1->A1_EMAIL2
	cContato := SA1->A1_CONTATO + Space(30)
	cCliente := SCJ->CJ_CLIENTE + "-" + SCJ->CJ_LOJA + " / " + SA1->A1_NOME
Else
	SUS->(dbSetOrder(1))
	SUS->(dbSeek(xFilial("SUS")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA))
	
	cPara    := SUS->US_EMAIL
	cContato := SUS->US_CONTATO + Space(30)                                 
	cCliente := SCJ->CJ_CLIENTE + "-" + SCJ->CJ_LOJA + " / " + SUS->US_NOME
Endif

//������������������������������������������������������������������Ŀ
//� Monta Dialog                                                     �
//��������������������������������������������������������������������          
DEFINE MSDIALOG oOrcVen TITLE "Or�amento via Email" FROM 127,037 TO 308,760 PIXEL

@ 013,006 TO 043,357 TITLE " Dados do Or�amento "
@ 045,006 TO 087,182 TITLE " Destinat�rios "
@ 045,187 To 087,357 TITLE " Observa��es Gerais " 
@ 020,010 SAY "Or�amento:" 
@ 020,042 SAY SCJ->CJ_NUM
@ 020,074 SAY "Contato no Cliente: " 
@ 019,122 Get cContato PICTURE "@" SIZE 60,08
//@ 020,195 SAY "Atendente:" 
//@ 020,227 SAY SCJ->CJ_ATEND  
@ 020,280 SAY "Emiss�o:" 
@ 020,305 SAY DtoC(SCJ->CJ_EMISSAO) 
@ 030,010 SAY "Cliente: " 
@ 030,032 SAY cCliente
@ 052,008 SAY "De:"
@ 052,028 Get cDe PICTURE "@" SIZE 150,08
@ 052,192 Get cObs MEMO SIZE 160,30 	
@ 062,008 SAY "Para  :"
@ 062,028 Get cPara   PICTURE "@" SIZE 150,08
@ 072,008 SAY "Cc  :"
@ 072,028 Get cCC   PICTURE "@" SIZE 150,08

ACTIVATE MSDIALOG oOrcVen ON INIT EnchoiceBar(oOrcVen, bOk, bCancel) CENTERED

//������������������������������������������������������������������Ŀ
//� Processamento                                                    �
//��������������������������������������������������������������������          
If nOpc == 1
	If Len(AllTrim(cPara)) > 0
		Processa({||ImpOrc()}, "Processando Envio...")
	Else
		MsgInfo("Pedido sem Destinat�rio !", "Or�amento de Vendas")
	Endif
EndIf                      

RestArea(aArea)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IMPWORD   �Autor  �                    � Data �23/06/2006   ���
�������������������������������������������������������������������������͹��
���Descricao � GERA E ENVIO ORCAMENTO                                     ���
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
Static Function ImpOrc()  

Local nItem := ""
//������������������������������������������������������������������Ŀ
//� Posiciona Arquivos                                               �
//��������������������������������������������������������������������
SCJ->(dbSetOrder(1))
SCJ->(dbSeek(xFilial("SCJ") + SCJ->CJ_NUM))

SA1->(dbSetOrder(1))
SUS->(dbSetOrder(1))

If !Empty(SCJ->CJ_CLIENTE)
	SA1->(dbSeek(xFilial("SA1") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA))
Else
	SUS->(dbSeek(xFilial("SUS") + SCJ->CJ_CLIENTE + SCJ->CJ_LOJA))
EndIf  

If !Empty(SCJ->CJ_CLIENTE)
	cNome     := AllTrim(SA1->A1_NOME)
	cCod      := SA1->A1_COD
	cLoja     := SA1->A1_LOJA
	cEnd      := Alltrim(SA1->A1_END)
	cBairro   := Alltrim(SA1->A1_BAIRRO)
	cMun      := Alltrim(SA1->A1_MUN)
	cEst      := SA1->A1_EST
	cTel      := SA1->A1_TEL
	cFax      := SA1->A1_FAX
	cCNPJ     := Transform(Alltrim(SA1->A1_CGC),"@R 99.999.999/9999-99")
	cInsc     := Trim(SA1->A1_INSCR)
Else
	cNome     := AllTrim(SUS->US_NOME)
	cCod      := SUS->US_COD
	cLoja     := SUS->US_LOJA
	cEnd      := Alltrim(SUS->US_END)
	cBairro   := Alltrim(SUS->US_BAIRRO)
	cMun      := Alltrim(SUS->US_MUN)
	cEst      := SUS->US_EST
	cTel      := SUS->US_TEL
	cFax      := SUS->US_FAX
	cCNPJ     := Transform(Alltrim(SUS->US_CGC),"@R 99.999.999/9999-99")
	cInsc     := " "
Endif     
             
cEmpresa := AllTrim(SM0->M0_NOMECOM)

cCab := 'Conforme contato estamos enviando proposta de fornecimento. Para maiores esclarecimentos estamos a disposi��o.' + ENTER + ENTER
cCab += 'Atenciosamente,' + ENTER + ENTER
cCab += PswRet()[1][4] + ENTER
cCab += '----------------------------------------------------------------------' + ENTER
cCab += 'COMERCIAL - ' + cEmpresa 

cMsg := '<html>'
cMsg += '<body>'
cMsg += '<font size="3" face="Courier New, Courier, mono">=================================================================================================<br>' 
cMsg += '<strong>OR�AMENTO ' + SCJ->CJ_NUM + '</strong><br>' 
cMsg += '=================================================================================================<br>' 
cMsg += '<strong>FORNECEDOR...: </strong>' + cEmpresa + '<br>'         
cMsg += '<strong>ENDERE�O.....: </strong>' + AllTrim(SM0->M0_ENDCOB) + " - " + Transform(AllTrim(SM0->M0_CEPCOB), "@R 99999-999") + " - " + AllTrim(SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB + '<br>'
cMsg += '<strong>TELEFONE.....: </strong>' + SM0->M0_TEL + '<br>'
cMsg += '<strong>FAX..........: </strong>' + SM0->M0_FAX + '<br>'
cMsg += '<strong>CNPJ.........: </strong>' + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + '<br>'
cMsg += '<strong>I.E..........: </strong>' + SM0->M0_INSC + '<br>'
cMsg += '=================================================================================================<br>' 
cMsg += '<strong>CLIENTE......: </strong>' + cNome + '<br>'
cMsg += '<strong>CONTATO......: </strong>' + cContato + '<br>
cMsg += '<strong>ENDERE�O.....: </strong>' + cEnd + "-" + cBairro + "-" + cMun + "-" + cEst + '<br>'
cMsg += '<strong>TELEFONE.....: </strong>' + cTel + '<br>'
cMsg += '<strong>FAX..........: </strong>' + cFax + '<br>'
cMsg += '<strong>CNPJ.........: </strong>' + cCNPJ + '<br>'
cMsg += '<strong>I.E..........: </strong>' + cInsc + '<br>'
cMsg += '=================================================================================================<br>' 
cMsg += '<strong>EMISS�O......: </strong>' + DtoC(SCJ->CJ_EMISSAO) + '<br>'
cMsg += '<strong>VENDEDOR.....: </strong>' + Posicione("SA3", 1, xFilial("SA3") + SCJ->CJ_COD, "A3_NOME") + '<br>'
cMsg += '<strong>EMAIL........: </strong>' + cDe + '<br>'
cMsg += '=================================================================================================<br>' 
cMsg += '<strong>PRODUTO &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|DESCRI��O &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|UN| &nbsp;QUANTID|IPI %|PRC UNIT | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SUBTOTAL</strong><br>'
cMsg += '-------------------------------------------------------------------------------------------------<br>'

nTotal  := 0

SCK->(dbSetOrder(1))
If SCK->(dbSeek(xFilial("SCK") + SCJ->CJ_NUM))
    
	SCK->(dbSetOrder(1))
	SCK->(dbSeek(xFilial("SCK") + SCJ->CJ_NUM))
	                                   
	nItem := 1
	
	While !SCK->(EOF()) .And. SCK->CK_NUM == SCJ->CJ_NUM  
	
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SCK->CK_PRODUTO)) 
		
		cQuantid := AllTrim(Transform(SCK->CK_QTDVEN, "@E 9,999,999.99"))		
		cPrcUnit := "R$ " + AllTrim(Transform(SCK->CK_PRCVEN,"@E 9,999.99"))
		cSubTot  := "R$ " + AllTrim(Transform(SCK->CK_VALOR,"@E 999,999,999.99"))

		cMsg += AllTrim(SCK->CK_PRODUTO) + Replicate('&nbsp;', 15 - Len(AllTrim(SCK->CK_PRODUTO))) + "|" +;
			    AllTrim(Subs(SCK->CK_DESCRI,1, 32)) + Replicate('&nbsp;', 32 - Len(AllTrim(SCK->CK_DESCRI))) + "|" +; 
			    AllTrim(SB1->B1_UM) + "|" +; 
				Replicate('&nbsp;', 8 - Len(cQuantid)) + cQuantid + "|" +;
				Transform(Posicione("SB1",1,xFilial("SB1")+SCK->CK_PRODUTO,"B1_IPI"), "@E 999.99") + "|" +;      
				Replicate('&nbsp;', 9 - Len(cPrcUnit)) + cPrcUnit + "|" +;
				Replicate('&nbsp;', 19 - Len(cSubTot)) + cSubTot + '<br>'

		nTotal += SCK->CK_VALOR 
        
		SCK->(dbSkip())
	
	EndDo      
	
EndIf

cMsg += '-------------------------------------------------------------------------------------------------<br>'
cMsg += '<strong>COND. PAGTO..: </strong>' + Posicione("SE4", 1, xFilial("SE4") + SCJ->CJ_CONDPAG, "E4_DESCRI") + '<br>'
cMsg += '<strong>FRETE........: </strong>' + Iif(AllTrim(SCJ->CJ_TPFRETE) == "C", "CIF", "FOB") + '<br>' //+ " - " + SCJ->CJ_OBSFRT + '<br>'
//cMsg += '<strong>ICMS.........: </strong>' + Iif(SCJ->CJ_ICMS == "I", "Incluso", "N�o Incluso") + " - " + SCJ->CJ_OBSICM + '<br>'
cMsg += '-------------------------------------------------------------------------------------------------<br>'

cTotal := "R$ " + AllTrim(Transform(nTotal, "@E 999,999,999.99"))

cMsg += '<strong>TOTAL GERAL..:</strong>' + Replicate('&nbsp;', 82 - Len(cTotal)) + cTotal + '<br>'
cMsg += '-------------------------------------------------------------------------------------------------<br>'
cMsg += '<strong>OBSERVA��ES..: </strong>' + cObs + SCJ->CJ_OBS + '<br>'
cMsg += '-------------------------------------------------------------------------------------------------<br>'
cMsg += 'FAVOR REFERENCIAR O N�MERO ' + SCJ->CJ_NUM + ' PARA QUALQUER TROCA DE INFORMA��ES REFERENTE A ESTE OR�AMENTO.<br>'
cMsg += '=================================================================================================<br>' 

//���������������������������������������������������������������������Ŀ
//� Envia Email                                                         �
//�����������������������������������������������������������������������
EnvEMail()

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ENVEMAIL  �Autor  �                    � Data �23/06/2006   ���
�������������������������������������������������������������������������͹��
���Descricao � ENVIO DO EMAIL                                             ���
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
Static Function EnvEmail()

Local cSrvMail  := AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := AllTrim(GetMV("MV_RELPSW"))  
Local cAuthent	:= ".T."//AllTrim(GetMV("MV_RELAUTH")) 
Local cArqTxt   := "\temp\orc" + SCJ->CJ_NUM + ".html"
Local nHdl      := fCreate(cArqTxt)       

If fWrite(nHdl, cMsg, Len(cMsg)) != Len(cMsg)
	MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?", "Atencao!")
Endif

fClose(nHdl)

CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk

If (lOk)
	
	If cAuthent == ".T."
		MAILAUTH(cUserAut, cPassAut)
	EndIf
	
	SEND MAIL FROM cDe TO cPara ;
	BCC cCco ;
	CC cCc ;
	SUBJECT "Or�amento N�." + SCJ->CJ_NUM + " / " + If(!Empty(SCJ->CJ_CLIENTE), AllTrim(Left(SA1->A1_NOME,30)), AllTrim(Left(SUS->US_NOME,30)));
	BODY cCab;  
	ATTACHMENT cArqTxt;
	RESULT lOK     
	DISCONNECT SMTP SERVER
	
Endif       

//���������������������������������������������������������������������Ŀ
//� Limpa Diretorio Temporario                                          �
//�����������������������������������������������������������������������
aDirectory := Directory("\temp\*.html")  
aEval(aDirectory, {|x| FErase("\temp\" + x[1])}) 

If (lOk)
	MsgInfo("Or�amento Enviado com Sucesso!", "Envio de Email OK")
Else
	MsgStop("A mensagem n�o pode ser Enviada!", "Falha no Envio de Email")
Endif

Return        