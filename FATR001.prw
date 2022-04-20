#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#define ENTER chr(13) + chr(10)
                            
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FINM012   �Autor  �Emerson Paiva       � Data �  31/01/18   ���
�������������������������������������������������������������������������͹��
���Descricao �Relatorio Vendido (Carteira + Faturado)                     ���
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
User Function FATR001

//������������������������������������������������������������Ŀ
//| Declaracoes das variaveis                                  |
//��������������������������������������������������������������
Local cQry      := ""     
Local cMensagem := ""
Local cAssunto  := ""
Local cDe       := ""
Local cPara     := ""  
Local cCCO		:= ""
Local cSrvMail  := "" //AllTrim(GetMV("MV_RELSERV"))
Local cUserAut  := "" //AllTrim(GetMV("MV_RELACNT")) 
Local cPassAut  := "" //AllTrim(GetMV("MV_RELPSW")) 
Local cAuthent	:= "" //AllTrim(GetMV("MV_RELAUTH"))
Local cNReduz	:= ""
Local cNome		:= ""
Local nTime		:= 0

Local lSchdAut	:= .F.

//������������������������������������������������������������������������Ŀ
//� Verifico se rotina esta sendo executada via Schedule				   �
//��������������������������������������������������������������������������
If Select("SX5") <= 0
	lSchdAut	:= .T.
	Prepare Environment Empresa "02" Filial "00" 
EndIf

//���������������������������������������������������������������������Ŀ
//| Executa apena em dias uteis                                        �
//�����������������������������������������������������������������������

//nTime := Val(Replace(Left(Time(),5),":",""))
//If lSchdAut .And. ( ( DataValida( dDatabase, .T.  ) <> dDatabase ) .Or. ( nTime < 1800 .Or. nTime > 1809 ) )
If lSchdAut .And. ( ( DataValida( dDatabase, .T.  ) <> dDatabase ) )
	ConOut("=======================================")
	ConOut("Agendamento FATR001 - Falha na execu��o")
	ConOut(DtoC(dDataBase)+" as "+Time()+" horas. ")
	ConOut("=======================================")
	Return
EndIf	

ConOut("========================================")
ConOut("Agendamento FATR001 - Execu��o realizada")
ConOut(DtoC(dDataBase)+" as "+Time()+" horas. ")
ConOut("========================================")

//���������������������������������������������������������������������Ŀ
//| Relat�rio Vendido Empresa x Tipo                                    �
//�����������������������������������������������������������������������
cQry := " SELECT	CAST(Empresa AS CHAR(12)) Empresa, CAST(Tipo AS CHAR(10)) Tipo, SUM([Margem L�quida]) Margem, SUM(FatRealXValor)/SUM(Valor) Fator, SUM(Valor) Valor " + ENTER
cQry += " FROM	BI.dbo.V_Faturamento_Vendido " + ENTER
cQry += " WHERE	FaturamentoAno = YEAR(GETDATE()) AND FaturamentoM�s = MONTH(GETDATE()) " + ENTER
cQry += " GROUP BY Empresa, Tipo " + ENTER
cQry += " ORDER BY Empresa, Tipo " + ENTER


If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

MemoWrite("fatr001.sql", cQry)

TCQUERY cQry NEW ALIAS QRY

If !QRY->(EOF())

	ConOut("==============================================")
	ConOut("Agendamento FATR001 - Possui dados fatr001.sql")
	ConOut("==============================================")

	//��������������������������������������������������������Ŀ
	//� Define conta para envio                                �
	//����������������������������������������������������������
	cDe := "workflow@euroamerican.com.br"    
	cNReduz := "EUROAMERICAN"           
	cNome	:= "EUROAMERICAN DO BRASIL IMPORTA��O, IND�STRIA E COM�RCIO LTDA"
		
	
			cSrvMail  := AllTrim("smtp.gmail.com:587")
			cUserAut  := AllTrim("workflow@euroamerican.com.br") 
			cPassAut  := AllTrim("Nsqeiflef#19") 			
			cAuthent  := ".T." 
	
	//��������������������������������������������������������Ŀ
	//� Define parametros do envio                             �
	//����������������������������������������������������������
	cPara		:= "gerson@euroamerican.com.br;thiago.monea@euroamerican.com.br;caroline.monea@euroamerican.com.br;alessandra.monea@euroamerican.com.br"
	cCCO		:= "ti@euroamerican.com.br"            
	cAssunto	:= cNReduz + " - RELAT�RIO VENDIDO DI�RIO "

	//��������������������������������������������������������Ŀ
	//� Define mensagem para envio                             �
	//����������������������������������������������������������
	cMensagem := '<html>' 
	cMensagem += '<head>' 
	cMensagem += '<title>Relat�rio Vendido Di�rio</title>'
	cMensagem += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' 
	cMensagem += '<style>table, th, td {'
	cMensagem += '	border: 1px solid black;'
	cMensagem += '	text-align: center;'
	cMensagem += '}'
	cMensagem += '</style>'
	cMensagem += '</head>'
	cMensagem += '<body>' 
	cMensagem += '<font size="4" face="Courier New, Courier, mono">======================================================================================<br>'
	cMensagem += '  <strong>Relat�rio Vendido</strong><br>' 
	cMensagem += '  ======================================================================================<br><br>' 
	cMensagem += '  Segue relat�rio vendido di�rio para acompanhamento <br>'        
	cMensagem += '  <br></font>' 
	
	cMensagem += '<table style="width:100%">'
	//cMensagem += '<caption>Relat�rio Vendido</caption>'
	cMensagem += '<tr bgcolor="#999999"> <th>Empresa</th> <th>Tipo</th> <th>Magem L�quida</th> <th>Fator</th> <th>Valor</th> </tr>'
	                        	       
   	While !QRY->(EOF())     
   		
		//cMensagem += QRY->Empresa + '| ' + QRY->Tipo + '|   ' + Transform(QRY->Margem, "@E 9,999,999.99") + " | " + Transform(QRY->Fator, "@E 999.99") + "| " + Transform(QRY->Valor, "@E 999,999,999.99") +  '<br>' 
		cMensagem += '<tr><td>'+QRY->Empresa+'</td> <td>'+QRY->Tipo+'</td> <td>'+Transform(QRY->Margem, "@E 999,999,999.99")+'</td> <td>'+Transform(QRY->Fator, "@E 999.99")+'</td> <td>'+Transform(QRY->Valor, "@E 999,999,999.99")+'</td> </tr>'
		
		QRY->(dbSkip())
		
	EndDo    
	
	//���������������������������������������������������������������������Ŀ
	//| Relat�rio Vendido Totalizador x Tipo                                    �
	//�����������������������������������������������������������������������
	cQry2 := " SELECT	CAST(Tipo AS CHAR(10)) Tipo, SUM([Margem L�quida]) Margem, SUM(FatRealXValor)/SUM(Valor) Fator, SUM(Valor) Valor " + ENTER
	cQry2 += " FROM	BI.dbo.V_Faturamento_Vendido " + ENTER
	cQry2 += " WHERE	FaturamentoAno = YEAR(GETDATE()) AND FaturamentoM�s = MONTH(GETDATE()) " + ENTER
	cQry2 += " GROUP BY Tipo " + ENTER
	cQry2 += " ORDER BY Tipo " + ENTER
	
	
	If Select("QRY2") > 0
		QRY2->(dbCloseArea())
	EndIf
	
	MemoWrite("fatr001_2.sql", cQry2)
	
	TCQUERY cQry2 NEW ALIAS QRY2
	
	While !QRY2->(EOF())	

		cMensagem += '<tr><td><b>'+'Total'+'</td> <td>'+QRY2->Tipo+'</td> <td>'+Transform(QRY2->Margem, "@E 999,999,999.99")+'</td> <td>'+Transform(QRY2->Fator, "@E 999.99")+'</td> <td>'+Transform(QRY2->Valor, "@E 999,999,999.99")+'</b></td> </tr>'
		
		QRY2->(dbSkip())
		
	EndDo
	
	cMensagem += '</table>'          
	
	//cMensagem += '  -------------------------------------------------------------------------------------</font>' 
	cMensagem += ' </font>' 
	cMensagem += ' <br><br>'
	cMensagem += ' <font size="4" face="Courier New, Courier, mono">	
	cMensagem += ' ======================================================================================<br>'
	cMensagem += ' Email enviado automaticamente. Favor n&atilde;o responder este e-mail.<br>' 
	cMensagem += ' ======================================================================================</font> ' 
	cMensagem += ' </font>'
	cMensagem += '</body>' 
	cMensagem += '</html>' 
	
	//������������������������������������������������������������Ŀ
	//| Envia Email                                                |
	//��������������������������������������������������������������  
	CONNECT SMTP SERVER cSrvMail ACCOUNT cUserAut PASSWORD cPassAut TIMEOUT 60 RESULT lOk
	
	If (lOk)
		
		ConOut("============================================")
		ConOut("Agendamento FATR001 - Conex�o SMTP Realizada")
		ConOut("============================================")

		If cAuthent == ".T."
			MAILAUTH(cUserAut, cPassAut)
		EndIf
		
		SEND MAIL FROM cDe TO cPara ;     
		BCC cCCO ;
		SUBJECT cAssunto;
		BODY cMensagem;
		RESULT lOK     
		
		DISCONNECT SMTP SERVER
		
	Else
		ConOut("============================================")
		ConOut("Agendamento FATR001 - Conex�o SMTP Falhou!")
		ConOut("============================================")
	Endif          

Else
	ConOut("========================================")
	ConOut("Agendamento FATR001 - N�o Possui dados")
	ConOut("========================================")
EndIf
		  
//Atualiza Prazo M�dio Condi��es Pagamento
//U_PrzMedio()

Return
