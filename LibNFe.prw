#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �GetIdEnt  � Autor �Eduardo Riera          � Data �18.06.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Obtem o codigo da entidade apos enviar o post para o Totvs  ���
���          �Service                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpC1: Codigo da entidade no Totvs Services                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function NFeGetId()

Local aArea  		:= GetArea()

Local cIdEnt 		:= ""
Local cURL   		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)

Local lMethodOk		:= .F.

Local oWsSPEDAdm

BEGIN SEQUENCE

	IF !( CTIsReady(cURL) )
		BREAK
	EndIF

	cURL	:= AllTrim(cURL)+"/SPEDADM.apw"

	IF !( CTIsReady(cURL) )
		BREAK
	EndIF

	oWsSPEDAdm										:= WsSPEDAdm():New()
	oWsSPEDAdm:cUSERTOKEN 							:= "TOTVS"
	oWsSPEDAdm:oWsEmpresa:cCNPJ       				:= SM0->( IF(M0_TPINSC==2 .Or. Empty(M0_TPINSC),M0_CGC,"")	 )
	oWsSPEDAdm:oWsEmpresa:cCPF        				:= SM0->( IF(M0_TPINSC==3,M0_CGC,"") )
	oWsSPEDAdm:oWsEmpresa:cIE         				:= SM0->M0_INSC
	oWsSPEDAdm:oWsEmpresa:cIM         				:= SM0->M0_INSCM		
	oWsSPEDAdm:oWsEmpresa:cNOME       				:= SM0->M0_NOMECOM
	oWsSPEDAdm:oWsEmpresa:cFANTASIA   				:= SM0->M0_NOME
	oWsSPEDAdm:oWsEmpresa:cENDERECO   				:= FisGetEnd(SM0->M0_ENDENT)[1]
	oWsSPEDAdm:oWsEmpresa:cNUM        				:= FisGetEnd(SM0->M0_ENDENT)[3]
	oWsSPEDAdm:oWsEmpresa:cCOMPL      				:= FisGetEnd(SM0->M0_ENDENT)[4]
	oWsSPEDAdm:oWsEmpresa:cUF         				:= SM0->M0_ESTENT
	oWsSPEDAdm:oWsEmpresa:cCEP        				:= SM0->M0_CEPENT
	oWsSPEDAdm:oWsEmpresa:cCOD_MUN    				:= SM0->M0_CODMUN
	oWsSPEDAdm:oWsEmpresa:cCOD_PAIS   				:= "1058"
	oWsSPEDAdm:oWsEmpresa:cBAIRRO     				:= SM0->M0_BAIRENT
	oWsSPEDAdm:oWsEmpresa:cMUN        				:= SM0->M0_CIDENT
	oWsSPEDAdm:oWsEmpresa:cCEP_CP     				:= NIL
	oWsSPEDAdm:oWsEmpresa:cCP         				:= NIL
	oWsSPEDAdm:oWsEmpresa:cDDD        				:= Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWsSPEDAdm:oWsEmpresa:cFONE       				:= AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWsSPEDAdm:oWsEmpresa:cFAX        				:= AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWsSPEDAdm:oWsEmpresa:cEMAIL      				:= UsrRetMail(RetCodUsr())
	oWsSPEDAdm:oWsEmpresa:cNIRE       				:= SM0->M0_NIRE
	oWsSPEDAdm:oWsEmpresa:dDTRE       				:= SM0->M0_DTRE
	oWsSPEDAdm:oWsEmpresa:cNIT        				:= SM0->( IF(M0_TPINSC==1,M0_CGC,"") )
	oWsSPEDAdm:oWsEmpresa:cINDSITESP  				:= ""
	oWsSPEDAdm:oWsEmpresa:cID_MATRIZ  				:= ""
	oWsSPEDAdm:oWsOutrasInscricoes:oWsInscricao		:= SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWsSPEDAdm:_URL									:= cURL
    lMethodOk                                       := oWsSPEDAdm:AdmEmpresas()

	DEFAULT lMethodOk := .F.
	IF !( lMethodOk )

		cError := IF( Empty( GetWscError(3) ) , GetWscError(1) , GetWscError(3) )

		Aviso("SPED",cError,{"OK"},3)

		BREAK

	EndIF

	cIdEnt  := oWsSPEDAdm:cAdmEmpresasResult

END SEQUENCE

RestArea(aArea)

Return( cIdEnt )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �          �Autor  �                    � Data �  01/30/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function NFeGetChv( cChaveNFe )

Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cMensagem	:= ""
Local oWS		:= Nil

Local lOK		:= .T.

/*
oWs				:= WsNFeSBra():New()
oWs:cUserToken  := "TOTVS"
oWs:cID_ENT    	:= U_NFeGetId()
ows:cCHVNFE		:= StrTran(cChaveNFe," ", '')
oWs:_URL        := AllTrim(cURL)+"/NFeSBRA.apw"

If oWs:ConsultaChaveNFE()

	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
		cMensagem += "Vers�o da Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
	EndIf

	cMensagem += "Ambiente"+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produ��o","Homologa��o")+CRLF //"Produ��o"###"Homologa��o"
	cMensagem += "Cod.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
	cMensagem += "Msg.Ret.NFe"+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF

	If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
		cMensagem += "Protocolo"+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
	EndIf

	If oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE # "100"
		//Se o retorno da consulta for diferente de 100 significa que ocorreu algum erro
		lOK := .F.
	EndIf
	
	Aviso("Consulta NF",cMensagem,{"Ok"},3)

Else

	lOK := .F.
	Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Ok"},3)

EndIf
*/

Return(lOK)    







