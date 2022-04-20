#include 'protheus.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'

// Tela Inicial de Login
User Function BePLogin()

Local cEnvServer := AllTrim( Upper( GetEnvServer() ) )

Private cHtml := ""

If Select("SX5") > 0
	RpcClearEnv()
EndIf			

WEB EXTENDED INIT cHtml

HttpSession->lLoginOK	:= .F.
HttpSession->cEnvServer := GetEnvServer()
HttpSession->cDataPC 	:= MsDate()
HttpSession->cEmpFil	:= Iif(Valtype(HttpSession->cEmpFil)<>"U",HttpSession->cEmpFil,"")
HttpSession->username	:= Iif(Valtype(HttpSession->username)<>"U",HttpSession->username,"")
HttpSession->ccodusr	:= ""
HttpSession->Password	:= ""

cHtml += '<!DOCTYPE html>'+CRLF
cHtml += '<html>'+CRLF
cHtml += '<head>'+CRLF
cHtml += '  <meta name="viewport" content="width=device-width, initial-scale=1">'+CRLF
cHtml += '  <link rel="stylesheet" href="xfiles/css/bootstrap.min.css">'+CRLF
cHtml += '  <script src="xfiles/js/jquery.min.js"></script>'+CRLF
cHtml += '  <script src="xfiles/js/bootstrap.min.js"></script>'+CRLF
//If cEnvServer == "PORTAL_EURO"
	cHtml += '	<link rel="icon" href="img/favicon_euro.ico" type="image/x-icon"><title>Portal Grupo Euroamerican</title>'+CRLF
	cHtml += '	'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="57x57"     href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="114x114"   href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="72x72"     href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="144x144"   href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="60x60"     href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="120x120"   href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="76x76"     href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="152x152"   href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_euroamerican.png" />'+CRLF
	cHtml += '</head>'+CRLF
/*
Else
	If cEnvServer == "PORTAL_QUALY"
		cHtml += '	<link rel="icon" href="img/favicon_qualy.ico" type="image/x-icon"><title>Portal Qualycril</title>'+CRLF
	ElseIf cEnvServer == "PORTAL_METROPOLE"
		cHtml += '	<link rel="icon" href="img/favicon_qualy.ico" type="image/x-icon"><title>Portal Metropole</title>'+CRLF
	ElseIf cEnvServer == "PORTAL_JAYS"
		cHtml += '	<link rel="icon" href="img/favicon_qualy.ico" type="image/x-icon"><title>Portal Jays</title>'+CRLF
	Else
		cHtml += '	<link rel="icon" href="img/favicon_qualy.ico" type="image/x-icon"><title>Portal Qualyvinil</title>'+CRLF
	EndIf
	cHtml += '	'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="57x57"     href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="114x114"   href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="72x72"     href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="144x144"   href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="60x60"     href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="120x120"   href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="76x76"     href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="apple-touch-icon-precomposed" sizes="152x152"   href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '	<link rel="icon" type="image/png"                          href="img/favicon_qualycril.png" />'+CRLF
	cHtml += '</head>'+CRLF
EndIf
*/
cHtml += '<style class="cp-pen-styles">'+CRLF
cHtml += '	body {'+CRLF
cHtml += '		background: #15224f !important;	'+CRLF
cHtml += '	}'+CRLF
cHtml += '	'+CRLF
cHtml += '	.wrapper {	'+CRLF
cHtml += '		margin-top: 20px;'+CRLF
cHtml += '  	margin-bottom: 80px;'+CRLF
cHtml += '	}'+CRLF
cHtml += '	'+CRLF
cHtml += '	.form-signin {'+CRLF
cHtml += '  	max-width: 380px;'+CRLF
cHtml += '  	padding: 15px 35px 45px;'+CRLF
cHtml += '  	margin: 0 auto;'+CRLF
cHtml += '  	background-color: #fff;'+CRLF
cHtml += '  	border: 1px solid rgba(0,0,0,0.1);  '+CRLF
cHtml += '	'+CRLF
cHtml += '		.form-control {'+CRLF
cHtml += '	  		position: relative;'+CRLF
cHtml += '	  		font-size: 16px;'+CRLF
cHtml += '	  		height: auto;'+CRLF
cHtml += '	  		padding: 10px;'+CRLF
cHtml += '			@include box-sizing(border-box);'+CRLF
cHtml += '			'+CRLF
cHtml += '				&:focus {'+CRLF
cHtml += '		  			z-index: 2;'+CRLF
cHtml += '				}'+CRLF
cHtml += '			}'+CRLF
cHtml += '			'+CRLF
cHtml += '			input[type="text"] {'+CRLF
cHtml += '	  			margin-bottom: -1px;'+CRLF
cHtml += '	  			border-bottom-left-radius: 0;'+CRLF
cHtml += '	  			border-bottom-right-radius: 0;'+CRLF
cHtml += '			}'+CRLF
cHtml += '			'+CRLF
cHtml += '			input[type="password"] {'+CRLF
cHtml += '	  			margin-bottom: 20px;'+CRLF
cHtml += '	  			border-top-left-radius: 0;'+CRLF
cHtml += '	  			border-top-right-radius: 0;'+CRLF
cHtml += '			}'+CRLF
cHtml += '		}'+CRLF
cHtml += '	</style>'+CRLF
cHtml += '<body>'+CRLF
cHtml += ''+CRLF
cHtml += '	<div class="container-fluid">'+CRLF
cHtml += '		<div class="wrapper">'+CRLF
cHtml += '			<form method="POST" class="form-signin" action="u_BePVlLog.apw" >'+CRLF
cHtml += '			'+CRLF
cHtml += '				<div class="login-icon" align="center">'+CRLF
If cEnvServer == "PORTAL_EURO"
	cHtml += '					<img alt="" style="width:220px;height:73px;" class="centerlogo" src="img/logo_euroamerican.png" >'+CRLF
Else
	cHtml += '					<img alt="" style="width:220px;height:73px;" class="centerlogo" src="img/logo_qualycril.png" >'+CRLF
EndIf
cHtml += '					<Br>'+CRLF
cHtml += '					<Hr>'+CRLF
//cHtml += '					<Br>'+CRLF
cHtml += '				</div>	'+CRLF
cHtml += '				'+CRLF
//cHtml += '				<div class="login-icon" align="center">'+CRLF
//cHtml += '      	    	<h1 class="text-center login-title">Portal Protheus</h1>'+CRLF
//cHtml += '				</div>	'+CRLF
cHtml += '				'+CRLF
cHtml += '				<div class="form-signin-group">'+CRLF
cHtml += '					<input type="text" class="form-control" name="dtbase" placeholder="Data-Base" value="'+DtoC(HttpSession->cDataPC)+'"  required />'+CRLF
cHtml += '				</div>'+CRLF
cHtml += '				<br>'+CRLF
cHtml += '				<div class="form-signin-group">'+CRLF
cHtml += '					<input type="text" class="form-control" name="username" placeholder="Usuario Protheus" value="'+HttpSession->username+'" required autofocus="" />'+CRLF
cHtml += '				</div>'+CRLF
cHtml += '				<br>'+CRLF
cHtml += '				<div class="form-signin-group">'+CRLF
cHtml += '					<input type="password" class="form-control" name="password" placeholder="Senha Protheus" required=""/>'+CRLF
cHtml += '				</div>'+CRLF
cHtml += '				<br>'+CRLF
cHtml += '				<div class="form-signin-group">'+CRLF
cHtml += '					<select name="cEmpFil" class="form-control" data-width="auto" value="'+HttpSession->cEmpFil+'">'+CRLF
/*
If cEnvServer == "PORTAL_EURO"
	cHtml += '						<option value="0200">02 - Euroamerican / 00 - Matriz Jandira</option>'+CRLF
ElseIf cEnvServer == "PORTAL_QUALY"
	cHtml += '						<option value="0803">08 - Qualycril / 03 - Matriz Jandira</option>'+CRLF
ElseIf cEnvServer == "PORTAL_METROPOLE"
	cHtml += '						<option value="0601">06 - Metropole / 02 - Filial 02</option>'+CRLF
ElseIf cEnvServer == "PORTAL_JAYS"
	cHtml += '						<option value="0107">01 - Jays / 07 - CD Ribeir�o Preto</option>'+CRLF
Else
	cHtml += '						<option value="0300">03 - Qualyvinil / 00 - Matriz Jandira</option>'+CRLF
EndIf
*/
cHtml += '						<option value="100200">10 - Grupo Euroamerican / 0200 - Euroamerican Matriz Jandira</option>'+CRLF
cHtml += '						<option value="100803">10 - Grupo Euroamerican / 0803 - Qualycril Matriz Jandira</option>'+CRLF
cHtml += '						<option value="100602">10 - Grupo Euroamerican / 0602 - Metropole Filial 02</option>'+CRLF
cHtml += '						<option value="100107">10 - Grupo Euroamerican / 0107 - Jays CD Ribeir�o Preto</option>'+CRLF
cHtml += '						<option value="100300">10 - Grupo Euroamerican / 0300 - Qualyvinil Matriz Jandira</option>'+CRLF
cHtml += '						<option value="100901">10 - Grupo Euroamerican / 0901 - Phoenix Ibitinga</option>'+CRLF
cHtml += '					</select>'+CRLF 
cHtml += '				</div>'+CRLF
cHtml += '				<br>'+CRLF
cHtml += '				'+CRLF
cHtml += '				<div class="form-signin-group">'+CRLF
cHtml += '					<input type="text" class="form-control" name="environment" placeholder="Ambiente" value="'+HttpSession->cEnvServer+'" readonly required/>'+CRLF
cHtml += '				</div>	'+CRLF
cHtml += '				<br>'+CRLF
cHtml += '      	      <div class="form-signin-group">'+CRLF
cHtml += '					<button class="btn btn-lg btn-primary btn-block" type="submit" >Login</button>'+CRLF
cHtml += '				</div>'+CRLF
cHtml += '			</form>'+CRLF
cHtml += '  	</div>'+CRLF
cHtml += '	</div>'+CRLF
cHtml += '</body>'+CRLF 
cHtml += '</html>'+CRLF

WEB EXTENDED END

Return(cHtml)