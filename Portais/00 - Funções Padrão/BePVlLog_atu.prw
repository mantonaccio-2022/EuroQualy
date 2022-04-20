#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'

// Fun��o de Valida��o do Login
/*
Histrico :
Corre��o em 26/11/2021 projeto release 12.1.33 para banco de dados 
Realizado por : Fabio Carneiro dos Santos 
*/

User Function BePVlLog()

Local aPswRet	:= {}

Local cCEmpPar	:= ""
Local cCFilPar	:= ""
Local cMsgHdr	:= ""
Local cMsgBody	:= ""
Local cRetfun	:= "u_BePLogin.apw"
Local aAllGrp   := PswID()
Local aGrp	    := {}
Public lLogin 	:= .T.
Private cHtml := ""

WEB EXTENDED INIT cHtml

HttpSession->cEmpFil 	:= HttpPost->cEmpFil
HttpSession->username 	:= HttpPost->username
HttpSession->password 	:= HttpPost->password

ConOut( HttpPost->cEmpFil )
ConOut( HttpPost->username )
ConOut( HttpPost->password )

PswOrder(2) //Nome do Usuario
If !(PswSeek(HttpPost->username,.T.) .And. PswName(HttpPost->password))

	lLogin 	:= .F. 
	cMsgBody	:= "Usuario ou Senha Invalido!"

Else
	aPswRet := PswRet(1)
	If aPswRet[1][17] = .T.
		lLogin := .F. 
		cMsgBody	:= "Usuario Bloqueado"
	ElseIf !Empty(aPswRet[1][6])
    	If DTOC(aPswRet[1][6]) < DTOC(MsDate())
			lLogin := .F. 
			cMsgBody	:= "Usuario Expirado!"
    	EndIf
   	EndIf

	aPswRet := PswRet(2)
	If Len(aPswRet) > 0 .and. aScan(aPswRet[2][6][1], {|x| x == "@@@@"}) == 0//Se nao tiver acesso a todas filiais, verifica
		If aScan(aPswRet[2][6][1], {|x| Substr(x,1,4) == Trim(HttpSession->cEmpFil) }) == 0
			lLogin := .F. 
			cMsgBody	:= "Usuario sem acesso a Empresa / Filial!"
		Endif
	Endif

Endif	

If lLogin
	HttpSession->lLoginOK	:= .T.
	HttpSession->ccodusr 	:= PswID()

	__cUserId 	:= PswID()

	dDataBase := HttpSession->cDataPC

	cHtml += '<script type="text/javascript">window.parent.location = "u_BePIndex.apw"</script>'+CRLF
Else
	
	cHtml += Execblock("BePHeader",.F.,.F.)
	
	cMsgHdr		:= "Login Inv�lido"
	cMsgBody	:= "Login Inv�lido"
	
	cHtml 	+=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun}) 
	cHtml 	+= Execblock("BePFooter",.F.,.F.)


EndIf

WEB EXTENDED END

Return (EncodeUTF8(cHtml))
