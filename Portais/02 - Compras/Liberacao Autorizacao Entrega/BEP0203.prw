#include 'protheus.ch'
#include 'rwmake.ch'
#include 'apwebex.ch'
#include 'tbiconn.ch'
#include "topconn.ch"

/*/{Protheus.doc} BeP0203
Programa Inicial da Liberação do Pedido de Compra
@type function Processament Portal
@version  1.00
@author ??? - Alterado por mario.antonaccio
@since ??? - Alterado em 01/04/2022
@return Character, HTML da aprovação
/*/ 
User Function BeP0203()

	Local cAlias	:= GetNextAlias()
	Local cMsgHdr	:= ""
	Local cMsgBody	:= ""
	Local cRetfun	:= "u_BePLogin.apw"
	Local lSession 	:= Execblock("BePVSess",.F.,.F.) // Valida Sessão
	Local lSuperior := .F.

	Private cHtml 	:= ""

	WEB EXTENDED INIT cHtml

	cHtml += Execblock("BePHeader",.F.,.F.)

	If lSession
		dbSelectArea("SAK")
		dbSetOrder(2)
		dbSeek(xFilial("SAK")+Alltrim(HttpSession->ccodusr))

		If !Empty( SAK->AK_APROSUP )
			lSuperior := .T.
		EndIf

		If Select(cAlias) <> 0
			(cAlias)->( dbCloseArea() )
		EndIf

		BeginSql alias cAlias
			SELECT
				SC7.C7_FILIAL,
				SC7.C7_NUM,
				SC7.C7_USER,
				SCR.CR_USER,
				SAK.AK_NOME,
				SCR.CR_APROV,
				SAL.AL_COD,
				SAL.AL_DESC,
				SCR.CR_NIVEL,
				SCR.CR_EMISSAO,
				SC7.C7_FORNECE,
				SC7.C7_LOJA,
				SC7.C7_CONTATO
			FROM
				%TABLE:SCR% SCR
			INNER JOIN %Table:SC7% SC7
			ON SC7.C7_FILIAL = SCR.CR_FILIAL
				AND SC7.C7_NUM = SCR.CR_NUM
				AND SC7.C7_TIPO = 2
				AND SC7.C7_ENCER <> 'E'
				AND C7_RESIDUO <> 'S'
				AND SC7.%NotDel%
			INNER JOIN %Table:SAL% SAL
			ON SAL.AL_FILIAL = %Exp:xFilial("SAL")%
				AND SAL.AL_COD = SC7.C7_APROV
				AND SAL.AL_USER = SCR.CR_USER
				AND SAL.%NotDel%
			INNER JOIN %Table:SAK% SAK
			ON SAK.AK_FILIAL = %Exp:xFilial("SAK")%
				AND SAK.AK_USER = SCR.CR_USER
				AND SAK.AK_COD = SCR.CR_APROV
				AND SAK.%NotDel%
			WHERE
				SCR.CR_FILIAL <> '**'
				AND SCR.CR_STATUS = '02' //***Status da Aprovação {01 - Nível Bloqueado ; 02 - Aguardando Liberação ; 03 - Liberado ; 04 - Reprovado}
				AND SCR.CR_TIPO = 'AE' //--*** Tipo do Documento   {PC – Pedido de Compras ; AE – Autorização de Entrega ; **CC – Cartão Corporativo ; **A1 – Cad. Clientes ; **A2 – Cad. Fornecedores ; **A3 – Cad. Vendedores ; **A4 – Cad. Transportadora ; **B1 – Cad. Produtos ; **ED – Cad. Naturezas } "
				AND SCR.CR_USER = %Exp:HttpSession->ccodusr% //***-- Id do Usuário
				AND SCR.%NotDel%
			GROUP BY
				SC7.C7_FILIAL,
				SC7.C7_NUM,
				SC7.C7_USER,
				SCR.CR_USER,
				SAK.AK_NOME,
				SCR.CR_APROV,
				SAL.AL_COD,
				SAL.AL_DESC,
				SCR.CR_NIVEL,
				SCR.CR_EMISSAO,
				SC7.C7_FORNECE,
				SC7.C7_LOJA,
				SC7.C7_CONTATO
			ORDER BY
				SC7.C7_FILIAL,
				SC7.C7_NUM
		EndSQL

		cHtml += Execblock("BePMenus",.F.,.F.)

		cHtml += '<div class="main" style="margin-top: 50px;">'
		cHtml += '	<h2><i class="fa fa-truck fa-1x"></i> Liberação Autorização de Entrega</h2>'
		cHtml += '	<hr/>'
		cHtml += '	<p></p>
		cHtml += '	<div style="overflow-x:auto; width=100%; max-height:300px; overflow-y:auto">'
		cHtml += '  	<table id="tblscr" class="table table-striped">
		cHtml += '    		<thead>
		cHtml += '      		<tr>
		cHtml += '		  			<th>Ações</th>
		cHtml += '        			<th>Filial</th>
		cHtml += '        			<th>Numero</th>
		cHtml += '        			<th>Comprador</th>
		cHtml += '        			<th>Aprovador</th>
		cHtml += '        			<th>Contato</th>
		cHtml += '      		</tr>
		cHtml += '    		</thead>
		cHtml += '			<tbody>

		dbSelectArea(cAlias)
		
		While !(cAlias)->( Eof() )

			cHtml += '			<tr>'
			cHtml += '				<td>'
			cHtml += '					<div class="btn-group">'
			cHtml += ' 						<button type="button" class="btn btn-sm dropdown-toggle" data-toggle="dropdown">'
			cHtml += '    						<span class="caret"></span>'
			cHtml += '    						<span class="sr-only">Toggle Dropdown</span>'
			cHtml += '  					</button>'
			cHtml += '  					<ul class="dropdown-menu" role="menu">
			cHtml += '    						<li><a href="u_bep0203A.apw?filexc='+(cAlias)->C7_FILIAL+'&numped='+(cAlias)->C7_NUM+'&grpapr='+(cAlias)->AL_COD+'&codaprov='+(cAlias)->CR_USER+'&nivel='+(cAlias)->CR_NIVEL+'&nopc=1">Visualizar</a></li>
			cHtml += '    						<li><a href="u_bep0203A.apw?filexc='+(cAlias)->C7_FILIAL+'&numped='+(cAlias)->C7_NUM+'&grpapr='+(cAlias)->AL_COD+'&codaprov='+(cAlias)->CR_USER+'&nivel='+(cAlias)->CR_NIVEL+'&nopc=2">Liberar</a></li>
			If lSuperior
				cHtml += '    						<li><a href="u_bep0203A.apw?filexc='+(cAlias)->C7_FILIAL+'&numped='+(cAlias)->C7_NUM+'&grpapr='+(cAlias)->AL_COD+'&codaprov='+(cAlias)->CR_USER+'&nivel='+(cAlias)->CR_NIVEL+'&superior='+SAK->AK_APROSUP+'&nopc=3">Transferir Superior</a></li>
			EndIf
			cHtml += '    						<li><a href="u_bep0205A.apw?filexc='+(cAlias)->C7_FILIAL+'&codfor='+(cAlias)->C7_FORNECE+'&lojfor='+(cAlias)->C7_LOJA+'&nopc=3">Consultar Fornecedor</a></li>
			cHtml += '  					</ul>
			cHtml += '					</div>
			cHtml += '				</td>
			cHtml += '        		<td>'+(cAlias)->C7_FILIAL+'</td>'
			cHtml += '        		<td>'+(cAlias)->C7_NUM+'</td>'
			cHtml += '        		<td nowrap>'+UsrRetName((cAlias)->C7_USER)+'</td>'
			cHtml += '        		<td nowrap>'+(cAlias)->AK_NOME+'</td>'
			cHtml += '        		<td nowrap>'+(cAlias)->C7_CONTATO+'</td>'
			cHtml += '      	</tr>

			(cAlias)->(dbSkip())
		
		End

		cHtml += '      	<tr>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      	</tr>
		cHtml += '      	<tr>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      		<td></td>
		cHtml += '      	</tr>

		cHtml += '    		</tbody>
		cHtml += '  	</table>
		cHtml += '	</div>'
		cHtml += '</div>'

	Else
		cMsgHdr		:= "BEP0203 - Sessão não Iniciada"
		cMsgBody	:= "A sessão não foi iniciada, realize o Login!"

		cHtml +=Execblock("BePModal",.F.,.F.,{cMsgHdr,cMsgBody,cRetFun})

	EndIf

	cHtml += Execblock("BePFooter",.F.,.F.)

	WEB EXTENDED END

Return (EncodeUTF8(cHtml))
