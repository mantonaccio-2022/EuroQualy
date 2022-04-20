#include "protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

#define DATACOTAC	1
#define CODMOEDA 	2
#define TIPOMOEDA	3
#define DESCMOEDA	4
#define TXCOMPRA	5
#define TXVENDA		6
#define PARCOMPRA	7
#define PARVENDA	8

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �BeWSICSTx � Autor � 				        � Data � 28.06.16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consumo de Web Service de atualiza��o das taxas de cota��o ���
���			 � das moedas Dolar e Euro no Financeiro e Importa��o		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void BeWSICSTx(ExpD1)			                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpD1 = Data de Atualiza��o da Moeda                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function EQBCBTx(aParam)

Local cPathBCB	:= "\BCB\"+DtoS(msdate())+"\"
Local cArqCSV	:= ""
Local cHttpTx	:= "https://www4.bcb.gov.br/Download/fechamento/"
Local cMensagem	:= ""
Local cMailNot	:= ""

Local aRetTx	:= {}

Local dDtVld	:= CtoD("  /  /  ")

Local lErro		:= .F.

Private aErro	:= {}
Private aMsgAt	:= {}
Private dDtExec	:= CtoD("  /  /  ") 

DEFAULT aParam := {msdate(),"01","01",,}

dDtExec := aParam[01]

//������������������������������������������������������������������������Ŀ
//� Verifico se rotina esta sendo executada via Schedule				   �
//��������������������������������������������������������������������������
If Select("SX5") <= 0
	lSchdAut := .T.
 	RPCSETENV(aParam[2],aParam[3],,,"FIN",,{"SM2","SYE"})
EndIf

//������������������������������������������������������������������������Ŀ
//�Cria Cria Diretorio caso n�o exista									   �
//���������������������������ĵ����������������������������������������������
If !ExistDir(cPathBCB,,.F.)
	MakeDir(cPathBCB,,.F.)
EndIf

If Empty(dDtExec)
	dDtExec := msdate()
EndIf

dDtVld := DataValida(dDtExec,.F.)

cCert 	:= "\certificados\000010_all.pem"
cKey	:= "\certificados\000010_key.pem"

cArqCSV	:= cPathBCB+DtoS(dDtVld)+".csv"
nArqCSV	:= MsFCreate(cArqCSV)

FWrite(nArqCSV,Httpsget(cHttpTx+DtoS(dDtVld)+".csv",cCert,cKey,"1234")) 
FClose(nArqCSV)   

//������������������������������������������������������������������������Ŀ
//�Carrega Variavel com o XML do Resultado do Get						   �
//��������������������������������������������������������������������������
nHdlCSV	:= FT_FUse(cArqCSV)
cLinRet	:= ""
If nHdlCSV == -1
	Return .F.
EndIf	

// Posiciona na primeria linha
FT_FGoTop()

While !FT_FEOF()   
	cLinRet  := FT_FReadLn() 
	
	If ";" $ cLinRet

		If Substr(cLinRet,12,3) $ "220|978"
			aAdd(aRetTx,StrTokArr(cLinRet,";"))
		EndIf

		// Pula para pr�xima linha  
		FT_FSKIP()

	Else	
		lErro := .T.			
		Exit
	EndIf
End

// Fecha o Arquivo
FT_FUSE()

//������������������������������������������������������������������������Ŀ
//�Processa Recebimento													   �
//��������������������������������������������������������������������������
If Len(aRetTx) > 0
	aEval(aRetTx,{|x| x[6] := Val(StrTran(x[6],",",".")) })

	lErro := BeExecProc(aRetTx, dDtExec)
EndIf

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �BeExecProc� Autor � 				        � Data � 28.06.16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza tabelas SM2 e SYE de cota��o das moedas conforme  ���
���			 � retorno do Web Service.									  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Void BeExecProc(ExpA1, ExpD2)	                          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpA1 = [01] - Vers�o WS ICS			         	          ���
���          �         [02] - C�digo da Moeda				              ���
���          �         [03] - Data Inicial   				              ���
���          �         [04] - Data Final					              ���
���          �         [05] - Taxa da Moeda no dia  		              ���
���          � ExpD2 = Data de Atualiza��o da Moeda no Sistema 	          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function BeExecProc(aTaxas, dDtExec)

Local lRetErro	:= .F.
Local nX		:= 0
Local nPosDol	:= aScan(aTaxas,{|x| Alltrim(x[2]) == "220" })
Local nPosEUR	:= aScan(aTaxas,{|x| Alltrim(x[2]) == "978" })

Local dDtGrv	:= dDtExec+1
//������������������������������������������������������������������������Ŀ
//�Atualiza Moeda Financeiro											   �
//��������������������������������������������������������������������������
Begin Transaction

	dbSelectArea("SM2")
	dbSetOrder(1)
	If dbSeek(dDtGrv)
		RecLock("SM2",.F.)
	Else
		RecLock("SM2",.T.)
	EndIf

	SM2->M2_DATA 	:= dDtGrv
	SM2->M2_MOEDA2  := aTaxas[nPosDol][6]
	SM2->M2_MOEDA3	:= 0
	SM2->M2_MOEDA4	:= aTaxas[nPosEUR][6] 
	SM2->M2_MOEDA5	:= 0  
	SM2->M2_INFORM	:= "S"
	SM2->(MsUnlock())

End Transaction	

Return lRetErro
