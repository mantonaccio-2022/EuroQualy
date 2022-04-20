#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"                           
#include "apwebsrv.ch"
#include "shell.ch"

#define ENTER chr(13) + chr(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �WEBSERVICE �Autor  �Alexandre Marson    � Data �  29/04/05  ���
�������������������������������������������������������������������������͹��
���Descricao � Descritor WSDL do servico de envio de SMS - ZENVIA         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������

===============================================================================
WSDL Location    http://www.zenvia360.com.br/GatewayIntegration/services/Sms?WSDL
Gerado em        04/02/13 14:46:22
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
===============================================================================

/*/

User Function _QNKLLGF ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSSms_BindingImplService
------------------------------------------------------------------------------- */

WSCLIENT WSSms_BindingImplService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD sendSms

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSsendSmsRequest         AS Sms_BindingImplService_SendSmsRequest
	WSDATA   csendSmsReturn            AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSms_BindingImplService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSms_BindingImplService
	::oWSsendSmsRequest  := Sms_BindingImplService_SENDSMSREQUEST():New()
Return

WSMETHOD RESET WSCLIENT WSSms_BindingImplService
	::oWSsendSmsRequest  := NIL 
	::csendSmsReturn     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSms_BindingImplService
Local oClone := WSSms_BindingImplService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSsendSmsRequest :=  IIF(::oWSsendSmsRequest = NIL , NIL ,::oWSsendSmsRequest:Clone() )
	oClone:csendSmsReturn := ::csendSmsReturn
Return oClone

// WSDL Method sendSms of Service WSSms_BindingImplService

WSMETHOD sendSms WSSEND oWSsendSmsRequest WSRECEIVE csendSmsReturn WSCLIENT WSSms_BindingImplService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:sendSms xmlns:q1="http://system.human.com.br/GatewayIntegration/services/Sms">'
cSoap += WSSoapValue("sendSmsRequest", ::oWSsendSmsRequest, oWSsendSmsRequest , "SendSmsRequest", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:sendSms>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://system.human.com.br/GatewayIntegration/services/Sms",,,; 
	"http://www.zenvia360.com.br/GatewayIntegration/services/Sms")

::Init()
::csendSmsReturn     :=  WSAdvValue( oXmlRet,"_SENDSMSRETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure SendSmsRequest

WSSTRUCT Sms_BindingImplService_SendSmsRequest
	WSDATA   caccount                  AS string OPTIONAL
	WSDATA   ccode                     AS string OPTIONAL
	WSDATA   cmsg                      AS string OPTIONAL
	WSDATA   cfrom                     AS string OPTIONAL
	WSDATA   cmobile                   AS string OPTIONAL
	WSDATA   cid                       AS string OPTIONAL
	WSDATA   cschedule                 AS dateTime OPTIONAL
	WSDATA   ncallbackOption           AS int OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Sms_BindingImplService_SendSmsRequest
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Sms_BindingImplService_SendSmsRequest
Return

WSMETHOD CLONE WSCLIENT Sms_BindingImplService_SendSmsRequest
	Local oClone := Sms_BindingImplService_SendSmsRequest():NEW()
	oClone:caccount             := ::caccount
	oClone:ccode                := ::ccode
	oClone:cmsg                 := ::cmsg
	oClone:cfrom                := ::cfrom
	oClone:cmobile              := ::cmobile
	oClone:cid                  := ::cid
	oClone:cschedule            := ::cschedule
	oClone:ncallbackOption      := ::ncallbackOption
Return oClone

WSMETHOD SOAPSEND WSCLIENT Sms_BindingImplService_SendSmsRequest
	Local cSoap := ""
	cSoap += WSSoapValue("account", ::caccount, ::caccount , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("code", ::ccode, ::ccode , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("msg", ::cmsg, ::cmsg , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("from", ::cfrom, ::cfrom , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("mobile", ::cmobile, ::cmobile , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("id", ::cid, ::cid , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("schedule", ::cschedule, ::cschedule , "dateTime", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("callbackOption", ::ncallbackOption, ::ncallbackOption , "int", .F. , .T., 0 , NIL, .F.) 
Return cSoap
              
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SMSOperacao�Autor  �Alexandre Marson    � Data �  29/04/05  ���
�������������������������������������������������������������������������͹��
���Descricao � Retorna um array com os parametros para envio do SMS       ���
���          � conforme operacao                                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SMSOperacao( cOperacao )
Local aRet			:= {}    
Local cOper         := ""

Local cTitulo       := ""
Local cKeyFld       := ""   
Local cKeyVal		:= ""  
Local cMetodo       := ""
Local dExpira		:= CtoD("//")
Local cMsg          := ""  
Local cFuncao       := ""                               
                               
Default cOperacao   := ""

//���������������������������������������������������������������������Ŀ
//� Ajusta valor do parametro cOperacao                                 �
//�����������������������������������������������������������������������
cOper := AllTrim( cOperacao )

//���������������������������������������������������������������������Ŀ
//� Monta chave da operacao                                             �
//�����������������������������������������������������������������������
Do Case

	//+-----------------------------------------------------------------
	//| SZF -> CONTROLE DE CARGA E DESCARGA ( PESO < 80% )
	//+-----------------------------------------------------------------
	Case cOper == "001"       

	 	cTransp := Posicione("DA3",3,xFilial("DA3")+SZF->ZF_VEICULO,"DA3_TRANSP")

	 	cRzSoci := AllTrim(Subs(Posicione("SA4",1,xFilial("SA4")+cTransp, "A4_NOME"),1,30))

		cTitulo := "APV PESO"

		cKeyFld := "ZF_FILIAL+ZF_NUM" // INDICE 01 

		cKeyVal := SZF->&( cKeyFld )              

		cMetodo := "2"   

		dExpira := DaySum(dDatabase, 1)
	
		cMsg	:= "CARGA: " + SZF->ZF_NUM + " " + ;
		           "TRANSP: " + cRzSoci + " " +;
		           "PESO: " + AllTrim( Transform(SZF->ZF_APVPESO, "@E 999,999.99") ) + "% " +;
		           "FRETE: " + AllTrim( Transform(SZF->ZF_APVFRET, "@E 999,999.99") ) + "% "
		           
		cFuncao := "U_FATX011P(.T.)"      
		
	//+-----------------------------------------------------------------
	//| SZF -> CONTROLE DE CARGA E DESCARGA ( FRETE > 5% )
	//+-----------------------------------------------------------------
	Case cOper == "002"       

	 	cTransp := Posicione("DA3",3,xFilial("DA3")+SZF->ZF_VEICULO,"DA3_TRANSP")

	 	cRzSoci := AllTrim(Subs(Posicione("SA4",1,xFilial("SA4")+cTransp, "A4_NOME"),1,30))

		cTitulo := "APV FRETE"

		cKeyFld := "ZF_FILIAL+ZF_NUM" // INDICE 01

		cKeyVal := SZF->&( cKeyFld )              

		cMetodo := "2"   

		dExpira := DaySum(dDatabase, 1)
	
		cMsg	:= "CARGA: " + SZF->ZF_NUM + " " +;
				   "TRANSP: " +	cRzSoci + " " +;
		           "PESO: " + AllTrim( Transform(SZF->ZF_APVPESO, "@E 999,999.99") ) + "% " +;
		           "FRETE: " + AllTrim( Transform(SZF->ZF_APVFRET, "@E 999,999.99") ) + "% "
		           
		cFuncao := "U_FATX011F(.T.)"						
EndCase

//���������������������������������������������������������������������Ŀ
//� Atualiza retorno                                                    �
//�����������������������������������������������������������������������
aAdd(aRet, cTitulo)
aAdd(aRet, cKeyFld)
aAdd(aRet, cKeyVal)
aAdd(aRet, cMetodo)
aAdd(aRet, dExpira)
aAdd(aRet, cMsg)
aAdd(aRet, cFuncao)

Return aRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SMSSend   � Autor � Alexandre Marson   � Data � 28/03/13    ���
�������������������������������������������������������������������������͹��
���Descri��o �Enviar uma mensagem SMS para um unico celular de destino.   ���
���          �                                                            ���
�������������������������������������������������������������������������ĺ��
���Retorno   �String                                                      ���
�������������������������������������������������������������������������ĺ��
���Parametros�cOperacao : String(050) Identificador unico para o SMS.     ���
���          �cNumero   : String(015) Celular destino ( Ex: 555199887766 )���
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
User Function SMSSend(cOperacao, cCelular)

Local aArea			:= GetArea()

Local oWsSMS		:= Nil  
Local lWsRet		:= .F.

Local cId           := GetSX8Num("ZZ7", "ZZ7_ID")

Local cQry          := ""

Local aOperacao     := {}

Default cOperacao	:= ""  
Default cCelular	:= ""
/*                        
Begin Sequence

	//���������������������������������������������������������������������Ŀ
	//� Verifica parametros x metodo SMS                                    �
	//�����������������������������������������������������������������������
	If Empty(cOperacao) .Or. Empty(cCelular)
		MsgStop("Nao foi possivel enviar o SMS." + ENTER + ENTER + ;
					"Verifique os parametros passados e tente novamente.")
		Break
	EndIf
	            
	//���������������������������������������������������������������������Ŀ
	//� Guarda informacoes referente a campos chave da operacao             �
	//�����������������������������������������������������������������������
	aOperacao := SMSOperacao( cOperacao ) 
	
	//���������������������������������������������������������������������Ŀ
	//� Verifica se ja foi disparado um SMS anteriormente para o numero     �
	//�����������������������������������������������������������������������
	cQry := "SELECT " + ENTER     
	cQry += "	RTRIM(U5_CONTAT) [NOME], " + ENTER
	cQry += "	RTRIM(ISNULL(ZZ7_USRENV,'')) [USUARIO], " + ENTER
	cQry += "	RTRIM(ISNULL(ZZ7_DTENV,'')) [DTENVIO], " + ENTER
	cQry += "	RTRIM(ISNULL(ZZ7_ID,'')) [ID] " + ENTER
	cQry += "FROM " + ENTER
	cQry += "	" + RetSqlName("ZZ7") + " ZZ7 " + ENTER
	cQry += "INNER JOIN" + ENTER
	cQry += "	" + RetSqlName("SU5") + " SU5 " + ENTER
	cQry += "	ON	SU5.D_E_L_E_T_ = '' " + ENTER
	cQry += "	AND	U5_FILIAL = '" + xFilial("SU5") + "' " + ENTER
	cQry += "	AND	U5_CELULAR = ZZ7_NUMERO " + ENTER
	cQry += "	AND	U5_SMSOPER = '" + cOperacao + "' " + ENTER
	cQry += "WHERE	ZZ7.D_E_L_E_T_ = '' " + ENTER
	cQry += "	AND	ZZ7_FILIAL = '" + xFilial("ZZ7") + "' " + ENTER
	cQry += "	AND ZZ7_KEYFLD = '" + aOperacao[2] + "' " + ENTER
	cQry += "	AND ZZ7_KEYVAL = '" + aOperacao[3] + "' " + ENTER
	cQry += "	AND ZZ7_NUMERO = '" + cCelular + "' " + ENTER
	cQry += "	AND ZZ7_MSGRET = '' "
	
	If Select("QRYSEND") > 0
		QRYSEND->(dbCloseArea())
	EndIf
	
	TCQUERY cQry NEW ALIAS QRYSEND 
	
	dbSelectArea("QRYSEND")
	
	If QRYSEND->( !BoF() .And. !EoF() )
		MsgStop("Ja foi enviada uma solicitacao para " + AllTrim(QRYSEND->NOME) + " por " + AllTrim(QRYSEND->USUARIO) + " em " + QRYSEND->DTENVIO + " para operacao " + AllTrim(aOperacao[1]) + "." + ENTER + ENTER + ;
					"Aguarde pela resposta ou solicite novamente a um outro aprovador.")
		Break
	EndIf
	
	//���������������������������������������������������������������������Ŀ
	//� Cria objeto para consumir webservice                                �
	//�����������������������������������������������������������������������
	oWsSMS := WSSms_BindingImplService():New()
	
	//���������������������������������������������������������������������Ŀ
	//� Define propriedades do objeto                                       �
	//�����������������������������������������������������������������������
	oWsSMS:oWsSendSmsRequest:cAccount	:= "euroamerican.int"
	oWsSMS:oWsSendSmsRequest:cCode		:= "vYoTOG94HU"
	oWsSMS:oWsSendSmsRequest:cFrom		:= "[ " + cID + " ] " + aOperacao[1]
	oWsSMS:oWsSendSmsRequest:cMobile	:= cCelular
	oWsSMS:oWsSendSmsRequest:cMsg		:= "[ " + cID + " - " + aOperacao[1] + " ] " + aOperacao[6]
	  
	//���������������������������������������������������������������������Ŀ
	//� Executa metodo sendSMS                                              �
	//�����������������������������������������������������������������������
	lWsRet := oWsSMS:sendSms()
	
	If !lWsRet
		MsgStop("Ocorreu um erro no envio do SMS.")	
		Break                            
	EndIf
	               
	//���������������������������������������������������������������������Ŀ
	//� Grava registro do envio no banco de dados                           �
	//�����������������������������������������������������������������������
	dbSelectArea("ZZ7") 
	dbSetOrder(1)
	dbGoTop()    
	dbSeek( xFilial("ZZ7")+AllTrim(cID)+AllTrim(cCelular) )
	
	RecLock("ZZ7", IIf( ZZ7->(Found()), .F., .T. ) )
	    ZZ7->ZZ7_FILIAL	:= xFilial("ZZ7")
	    ZZ7->ZZ7_NUMERO	:= cCelular
	    ZZ7->ZZ7_ID		:= cId                      
	    ZZ7->ZZ7_OPER	:= cOperacao
	    ZZ7->ZZ7_USRENV := Upper(AllTrim(cUserName))	    
	    ZZ7->ZZ7_KEYFLD := aOperacao[2]
	    ZZ7->ZZ7_KEYVAL := aOperacao[3]  
	    ZZ7->ZZ7_METODO	:= aOperacao[4]
	    ZZ7->ZZ7_EXPIRA	:= aOperacao[5]
	    ZZ7->ZZ7_MSGENV := aOperacao[6]
	    ZZ7->ZZ7_DTENV  := DtoC(dDataBase) + " " + Time()     
	ZZ7->(MsUnlock())	
	
	If	__lSX8
		ConfirmSX8()
	EndIf
	
	EvalTrigger()		
	             
	MsgInfo("Enviado SMS para o n�mero " + RTrim(cCelular) + ".", "LIBSMS")
        
End Sequence
         
//���������������������������������������������������������������������Ŀ
//� Encerra workarea temporario                                         �
//�����������������������������������������������������������������������
If Select("QRYSEND") > 0
	QRYSEND->(dbCloseArea())
EndIf

//���������������������������������������������������������������������Ŀ
//� Restaura area anterior                                              �
//�����������������������������������������������������������������������
Restarea( aArea )
*/
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SMSReceive� Autor � Alexandre Marson   � Data � 28/03/13    ���
�������������������������������������������������������������������������͹��
���Descricao � Recebe lista de resposta ao SMS enviado                    ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
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
User Function SMSReceive()
Local aArea     := GetArea()

Local cUrl		:= "http://api.zenvia360.com.br/GatewayIntegration/msgSms.do?account=euroamerican.int&code=vYoTOG94HU&dispatch=listReceived"
Local cRet		:= ""    
Local aRet		:= {} 

Local nHdl		:= 0    
Local cArq   	:= "\system\sms_" + DtoS(dDatabase) + "_" + StrTran(Subs(Time(), 1, 5), ":", "") + "_" + AllTrim(cUserName) + ".txt"

//���������������������������������������������������������������������Ŀ
//� Executa URL                                                         �
//�����������������������������������������������������������������������
cRet := HttpGet(cUrl)  
                                  
//���������������������������������������������������������������������Ŀ
//� Verifica retorno                                                    �
//�����������������������������������������������������������������������
If Empty(cRet) .Or. Subs(cRet,1,3) != "300"
	MsgStop("Ocorreu um erro ao verificar retorno de SMS." + ENTER + ENTER + ;
	 		"Codigo: " + cRet )
	
	Return
EndIf

//���������������������������������������������������������������������Ŀ
//� Gera arquivo TXT com retorno da funcao                              �
//�����������������������������������������������������������������������
nHdl := FCreate(cArq)

If nHdl == -1
	MsgAlert("Falha na cria��o do arquivo!" , "Aten��o!")
	Return
Endif  

FWrite(nHdl, cRet, Len(cRet))      

fClose(nHdl)

//���������������������������������������������������������������������Ŀ
//� Processa arquivo                                                    �
//�����������������������������������������������������������������������
FT_FUSE(cArq)

FT_FGOTOP()

FT_FSKIP() //Despreza primeira linha do arquivo 

While !FT_FEOF()
 
	cLin := FT_FREADLN()
	
	aRet := Separa(cLin,";",.T.)
	                             
   	dbSelectArea("ZZ7")
   	dbSetOrder(1)       
   	dbGoTop()
   	dbSeek( xFilial("ZZ7") + AllTrim(aRet[4]) + AllTrim(aRet[3]) )
   	
   	If ZZ7->( Found() ) 
   		
	   		RecLock("ZZ7", .F.)
				ZZ7->ZZ7_MSGRET	:= aRet[4]
				ZZ7->ZZ7_DTRET	:= aRet[2]
			ZZ7->( MsUnlock() )
	
   	EndIf
 
	FT_FSKIP()

EndDo

FT_FUSE()   

//���������������������������������������������������������������������Ŀ
//� Exclui arquivo TXT                                                  �
//�����������������������������������������������������������������������
//fErase( cArq )

//���������������������������������������������������������������������Ŀ
//� Processa registros de retorno                                       �
//�����������������������������������������������������������������������
U_SMSExecute()

//���������������������������������������������������������������������Ŀ
//� Restaura area anterior                                              �
//�����������������������������������������������������������������������
Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MARKBRWSF2�Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Selecao de notas fiscais para composicao da carga          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function SMSMarkBrw( cOperacao, nNivel ) 

//���������������������������������������������������������������������Ŀ
//� Define variaveis                                                    �
//�����������������������������������������������������������������������
Local aArea      	:= GetArea()    

Local aOperacao     := SMSOperacao( cOperacao )                                  
                                            
Local lOk        	:= .F.

Local aSize		 	:= MsAdvSize(.F.,.T.,600)
Local aInfo  	 	:= {}             
Local aObjects	 	:= {}
Local aPos       	:= {}       
                          
Local aPos1 		:= {}
Local aPos2 		:= {}  
Local aPos3 		:= {}  
                                                   
Local cQry			:= ""
   
Local aStruMark     := {}
Local aCposMark     := {}   

Local cArqMark      := ""
Local cIndMark      := ""      

Private oDlgMark    := Nil     

Private oFont10B	:= TFont():New( "Arial",,14,,.T.,,,,,.F.)

Private oMark       := Nil
Private lInverte	:= .F.
Private cMarca		:= GetMark()    
                            
Default cOperacao	:= ""
Default nNivel		:= 0

//��������������������������������������������������������Ŀ
//� Define script SQL                                      �
//����������������������������������������������������������
cQry := "SELECT " + ENTER
cQry += "	U5_CONTAT [NOME], " + ENTER
cQry += "	ISNULL(ZZ7_USRENV,'') [USUARIO], " + ENTER
cQry += "	ISNULL(ZZ7_DTENV,'') [DTENVIO], " + ENTER
cQry += "	ISNULL(ZZ7_ID,'') [ID], " + ENTER
cQry += "	U5_CELULAR [CELULAR] " + ENTER
cQry += "FROM " + ENTER
cQry += "	" + RetSqlName("SU5") + " SU5 " + ENTER
cQry += "LEFT JOIN " + ENTER
cQry += "	" + RetSqlName("ZZ7") + " ZZ7 " + ENTER
cQry += "	ON	ZZ7.D_E_L_E_T_ = '' " + ENTER
cQry += "	AND	ZZ7_FILIAL = '" + xFilial("ZZ7") + "' " + ENTER
cQry += "	AND ZZ7_NUMERO = U5_CELULAR " + ENTER
cQry += "	AND ZZ7_KEYFLD = '" + aOperacao[2] + "' " + ENTER
cQry += "	AND ZZ7_KEYVAL = '" + aOperacao[3] + "' " + ENTER
cQry += "WHERE	SU5.D_E_L_E_T_ = '' " + ENTER
cQry += "	AND	U5_FILIAL = '" + xFilial("SU5") + "' " + ENTER
cQry += "	AND	U5_SMSOPER  = '" + cOperacao + "' " + ENTER
cQry += "	AND	U5_SMSNIVE >= " + cValToChar( nNivel ) + ENTER
cQry += "	AND	RTRIM(U5_CELULAR) <> '' " + ENTER
cQry += "ORDER BY " + ENTER
cQry += "	U5_CONTAT " + ENTER

If Select("QRYMARK") > 0
	QRYMARK->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRYMARK

//��������������������������������������������������������Ŀ
//� Define campos do arquivo temporario TRB                �
//����������������������������������������������������������
aStruMark := {}
aadd(aStruMark,{"TR_OK"	   		,"C",02,00})
aadd(aStruMark,{"TR_NOME"		,"C",30,00})
aadd(aStruMark,{"TR_USUARIO"	,"C",30,00})
aadd(aStruMark,{"TR_DTENVIO"	,"C",20,00})
aadd(aStruMark,{"TR_ID"			,"C",20,00})
aadd(aStruMark,{"TR_CELULAR"	,"C",20,00})               

//��������������������������������������������������������Ŀ
//� Define campos do MsSelect                              �
//����������������������������������������������������������
aCposMark := {}
aadd(aCposMark,{"TR_OK"			,,""			,"@!"})
aadd(aCposMark,{"TR_NOME"		,,"Nome"		,"@!"})
aadd(aCposMark,{"TR_USUARIO"	,,"Usuario"		,"@!"})
aadd(aCposMark,{"TR_DTENVIO"	,,"Data/Hora"	,"@!"})
aadd(aCposMark,{"TR_ID"			,,"ID"			,"@!"})
                                                        
//��������������������������������������������������������Ŀ
//� Cria arquivo de trabalho temporario (DBF)              �
//����������������������������������������������������������
If Select("TRBMARK") > 0
	TRBMARK->(dbCloseArea())
EndIf

cArqMark := CriaTrab(aStruMark, .T.)      
dbUseArea( .T., "DBFCDX", cArqMark, "TRBMARK",.F.,.F.)     

//��������������������������������������������������������Ŀ
//� Popula arquivo temporario                              �
//����������������������������������������������������������
dbSelectArea("QRYMARK")
dbGoTop()
While QRYMARK->(!EoF())
	             	
	RecLock("TRBMARK", .T.)    
		TRBMARK->TR_OK		:= Space(2)
		TRBMARK->TR_NOME	:= QRYMARK->NOME
		TRBMARK->TR_USUARIO	:= QRYMARK->USUARIO
		TRBMARK->TR_DTENVIO	:= QRYMARK->DTENVIO
		TRBMARK->TR_ID		:= QRYMARK->ID
		TRBMARK->TR_CELULAR	:= QRYMARK->CELULAR
	TRBMARK->( MsUnlock() )
		
	QRYMARK->(dbSkip())      
	
EndDo
    
dbSelectArea("TRBMARK")
dbGoTop()

//��������������������������������������������������������Ŀ
//� Define as areas para criacao de objetos visuais        �
//����������������������������������������������������������
aObjects := {}                          
aAdd( aObjects, { 100, 020, .T., .F. } )
aAdd( aObjects, { 100, 100, .T., .T. } )
aAdd( aObjects, { 100, 015, .T., .F. } )

aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3, 3, 3}
aPos  := MsObjSize(aInfo, aObjects)
   
aPos1 := aClone( aPos[1] )
aPos2 := aClone( aPos[2] )
aPos3 := aClone( aPos[3] )

//��������������������������������������������������������Ŀ
//� Cria objetos										   �
//����������������������������������������������������������
DEFINE MSDIALOG oDlgMark TITLE "Enviar SMS"  FROM aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd PIXEL

@ aPos1[1]+000 , aPos1[2] SAY "Selecione uma ou mais pessoas que dever�o receber o SMS:" SIZE 200,010 PIXEL OF oDlgMark COLOR CLR_BLACK
@ aPos1[1]+010 , aPos1[2] SAY aOperacao[1] FONT oFont10B SIZE 200,010 PIXEL OF oDlgMark COLOR CLR_BLUE         

oMark := MSSELECT():New("TRBMARK","TR_OK","",@aCposMark,@lInverte,@cMarca,{aPos2[1],aPos2[2],aPos2[3],aPos2[4]},,,oDlgMark)
oMark:oBrowse:lCanAllmark := .F.    
                        
oBtn1 := TButton():New( aPos3[1],aPos3[2]+000,"&Confirmar"	,oDlgMark,{|| ( lOk:=.T. , oDlgMark:End() ) },040,012,,,,.T.,,"",,,,.F. )                        
oBtn2 := TButton():New( aPos3[1],aPos3[2]+060,"&Sair"		,oDlgMark,{|| ( lOk:=.F. , oDlgMark:End() ) },040,012,,,,.T.,,"",,,,.F. )                        
                                      
oDlgMark:lCentered := .T. 
oDlgMark:ACTIVATE()                                                         

If lOk

	//���������������������������������������������������������������������Ŀ
	//|Popula aCols com registros selecionados                              |  
	//����������������������������������������������������������������������� 
	dbSelectArea("TRBMARK")
	dbGoTop()

	While !EoF()   

		If !Empty(TRBMARK->TR_OK)     
			U_SMSSend( cOperacao, AllTrim(TRBMARK->TR_CELULAR) )
		EndIf

		dbSkip()

	EndDo     
		
EndIf

//���������������������������������������������������������������������Ŀ
//|Fecha e elimina arquivos temporarios 								|  
//�����������������������������������������������������������������������                     
If Select("QRYMARK") > 0
	QRYMARK->(dbCloseArea())
EndIf

If Select("TRBMARK") > 0
	TRBMARK->(dbCloseArea())
EndIf

If File(cArqMark+GetDBExtension())
	FErase(cArqMark+GetDBExtension())
EndIf

//��������������������������������������������������������Ŀ
//� Restaura area ( Alias, Indice, Registro )              �
//����������������������������������������������������������   
Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SMSExecute�Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Processa o retorno SMS                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function SMSExecute()
Local aArea	:= GetArea()
Local cQry  := ""

//���������������������������������������������������������������������Ŀ
//� Verifica se ja foi disparado um SMS anteriormente para o numero     �
//�����������������������������������������������������������������������
cQry := "SELECT " + ENTER     
cQry += "	ZZ7_ID [ID], " + ENTER
cQry += "	ZZ7_NUMERO [NUMERO], " + ENTER
cQry += "	ZZ7_OPER [OPERACAO], " + ENTER
cQry += "	ZZ7_KEYFLD [KEYFLD], " + ENTER
cQry += "	ZZ7_KEYVAL [KEYVAL], " + ENTER
cQry += "	ZZ7_USRENV [USUARIO], " + ENTER
cQry += "	U5_CONTAT [APROVADOR] " + ENTER
cQry += "FROM " + ENTER
cQry += "	" + RetSqlName("ZZ7") + " ZZ7 " + ENTER      
cQry += "INNER JOIN" + ENTER
cQry += "	" + RetSqlName("SU5") + " SU5 " + ENTER      
cQry += "	ON	SU5.D_E_L_E_T_ = '' " + ENTER
cQry += "	AND	U5_FILIAL = '" + xFilial("SU5") + "' " + ENTER
cQry += "	AND	U5_SMSOPER = ZZ7_OPER " + ENTER
cQry += "	AND	U5_CELULAR = ZZ7_NUMERO " + ENTER
cQry += "WHERE	ZZ7.D_E_L_E_T_ = '' " + ENTER
cQry += "	AND	ZZ7_FILIAL = '" + xFilial("ZZ7") + "' " + ENTER
cQry += "	AND ZZ7_METODO = '2' " + ENTER
cQry += "	AND RTRIM(ZZ7_MSGRET) <> '' " + ENTER
cQry += "	AND RTRIM(ZZ7_DTPROC) = '' " + ENTER
cQry += "	AND ZZ7_EXPIRA >= CONVERT(VARCHAR, GETDATE(), 112) " + ENTER

If Select("QRYSMS") > 0
	QRYSMS->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRYSMS

//���������������������������������������������������������������������Ŀ
//� Processa registro                                                   �
//�����������������������������������������������������������������������
dbSelectArea("QRYSMS")
dbGoTop()        

While !EoF()

	//���������������������������������������������������������������������Ŀ
	//� Chama funcao conforme operacao                                      �
	//�����������������������������������������������������������������������	
	Do Case
		Case QRYSMS->OPERACAO == "001"
			SMSExec001( QRYSMS->KEYFLD, QRYSMS->KEYVAL, QRYSMS->APROVADOR )	

		Case QRYSMS->OPERACAO == "002"
			SMSExec002( QRYSMS->KEYFLD, QRYSMS->KEYVAL, QRYSMS->APROVADOR )	
	EndCase
	
	//���������������������������������������������������������������������Ŀ
	//� Atualiza registro como processado                                   �
	//�����������������������������������������������������������������������	
    dbSelectArea("ZZ7")
    dbSetOrder(1)
    dbGoTop()
    dbSeek( xFilial("ZZ7")+QRYSMS->ID+QRYSMS->NUMERO )
    
    If ZZ7->( Found() )
    
   		Reclock("ZZ7", .F.)
   			ZZ7->ZZ7_DTPROC := DtoC(dDataBase) + " " + Time() 
   		ZZ7->( MsUnlock() )

    EndIf
	             
	//���������������������������������������������������������������������Ŀ
	//� Avanca para o proximo registro                                      �
	//�����������������������������������������������������������������������	
	dbSelectArea("QRYSMS")       
	dbSkip()
	
EndDo            
      
//���������������������������������������������������������������������Ŀ
//|Fecha e elimina arquivos temporarios 								|  
//�����������������������������������������������������������������������                     
If Select("QRYSMS") > 0
	QRYSMS->(dbCloseArea())
EndIf

//��������������������������������������������������������Ŀ
//� Restaura area ( Alias, Indice, Registro )              �
//����������������������������������������������������������   
Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SMSExec001�Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Processa o retorno SMS                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SMSExec001( cKeyFLD, cKeyVAL, cAprovador)
Local aArea		:= GetArea()   
Local aAreaSZF	:= SZF->( GetArea() )
Local cMsg		:= ""       
Local cPath		:= "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456" 
Local cUserEXP  := "Alexandre.Marson," + U_getUserGp("EXP-X00", "C", 3, ",")    

dbSelectArea("SZF")
dbSetOrder(1)    
dbGoTop()
dbSeek( cKeyVAL )

If SZF->( Found() )

	If At("IT05", SZF->ZF_LOG) == 0		                
		                    
		//���������������������������������������������������������������������Ŀ
		//� Atualiza log do registro de cargas                                  �      
		//�����������������������������������������������������������������������
		cLog := U_FATX011H(5, cValToChar(SZF->ZF_APVPESO) + "%", cAprovador)   
	          
		RecLock("SZF", .F.)
			SZF->ZF_LOG := cLog
		SZF->( MsUnlock() )
	
		
		//���������������������������������������������������������������������Ŀ
		//� Dispara alerta via gerenciador para usuarios do grupo EXP-X00       �      
		//�����������������������������������������������������������������������
	 	cMsg := '"(Autoriza��o - Montagem de Carga)' + ENTER 
	 	cMsg += 'De: ' + AllTrim(cAprovador) + ENTER 
		cMsg += 'AVISO: A autorizacao para utilizacao da capacidade do veiculo abaixo de 80% ( ' + cValToChar(SZF->ZF_APVPESO) + '% ) foi concedida para a carga ' + SZF->ZF_NUM + '. Favor verificar!"' + ENTER 
		//WinExec(cPath + Space(1) + cUserEXP + Space(1) + cMsg, 0)		
				
	EndIf
		
EndIf

Restarea( aAreaSZF )	
Restarea( aArea )

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SMSExec002�Autor  �Alexandre Marson    � Data �  29/04/05   ���
�������������������������������������������������������������������������͹��
���Descricao � Processa o retorno SMS                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function SMSExec002( cKeyFLD, cKeyVAL, cAprovador)
Local aArea		:= GetArea()   
Local aAreaSZF	:= SZF->( GetArea() )
Local cMsg		:= ""       
Local cPath		:= "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456" 
Local cUserEXP  := "" + U_getUserGp("EXP-X00", "C", 3, ",")

dbSelectArea("SZF")
dbSetOrder(1)         
dbGoTop()
dbSeek( cKeyVAL )

If SZF->( Found() )

	If At("IT06", SZF->ZF_LOG) == 0		                

		//���������������������������������������������������������������������Ŀ
		//� Atualiza log do registro de cargas                                  �      
		//�����������������������������������������������������������������������
		cLog := U_FATX011H(6, cValToChar(SZF->ZF_APVFRET) + "% ( SMS )", cAprovador)   
	          
		RecLock("SZF", .F.)
			SZF->ZF_LOG := cLog
		SZF->( MsUnlock() )
	
	//���������������������������������������������������������������������Ŀ
	//� Dispara alerta via gerenciador para usuarios do grupo EXP-X00       �      
	//�����������������������������������������������������������������������
	 	cMsg := '"(Autoriza��o - Montagem de Carga)' + ENTER 
	 	cMsg += 'De: ' + AllTrim(cAprovador) + ENTER 
		cMsg += 'AVISO: A autorizacao para frete acima de 5% ( ' + cValToChar(SZF->ZF_APVFRET) + '% ) foi concedida para a carga ' + SZF->ZF_NUM + '. Favor verificar!"' + ENTER 
		//WinExec(cPath + Space(1) + cUserEXP + Space(1) + cMsg, 0)		
					
	EndIf
		
EndIf

Restarea( aAreaSZF )	
Restarea( aArea )
	
Return
