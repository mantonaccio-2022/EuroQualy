#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"  

#define ENTER chr(13) + chr(10)
            
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GENC006   � Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �CONSULTA DE PRODUTO                                         ���
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
User Function GENC006()                                                 

//���������������������������������������������������������������������Ŀ
//|Variaveis do sistema                                                 �
//�����������������������������������������������������������������������
Local aMat         	:= {} 
Local oPesq                 
Local cQry			:= ""

Private oDlg1
Private cIndex    	:= ""
Private cPesq      	:= Space(50)
Private nPrcLst, nSaldo, nReserva, nDisp   
Private cCondicao  	:= "@" 
Private lRet       	:= .F.       
Private aInd       	:= {}                
Private oPrn        := Nil                    

Private bUsrExtEuro	:= .T. 	//U_IsGroup("EXT-E00")

Private cProdutoIn	:= ""
Private lProdutoIn	:= .T.


//���������������������������������������������������������������������Ŀ
//|Fontes utilizadas                                                    �
//�����������������������������������������������������������������������
DEFINE FONT oFont1 NAME "Tahoma" SIZE 0,30 OF oPrn BOLD
DEFINE FONT oFont2 NAME "Tahoma" SIZE 0,20 OF oPrn BOLD

//���������������������������������������������������������������������Ŀ
//|Configura indice padrao                                              |  
//�����������������������������������������������������������������������
cIndex := "C�digo"
SB0->( dbSetOrder(1) )   

//���������������������������������������������������������������������Ŀ
//|Limpa filtro existente                                               |  
//�����������������������������������������������������������������������
EndFilBrw("SB0", aInd)
SB0->( dbClearFilter() )

//���������������������������������������������������������������������Ŀ
//|Campos do Browse                                                     |  
//�����������������������������������������������������������������������
aAdd(aMat,{"B0_COD"  , "Cod. Produto"  , "@!" , "C", 15, 0})
aAdd(aMat,{"B0_DESC" , "Desc Produto"  , "@!" , "C", 40, 0})
aAdd(aMat,{"B0_UM"   , "Unid."         , "@!" , "C", 03, 0}) 

//���������������������������������������������������������������������Ŀ
//|Teclas de Navegacao                                                  |  
//�����������������������������������������������������������������������
SetKey(VK_F9 ,{|| fOrdena()})      			  //Troca Indice
SetKey(VK_F10,{|| fPesquisa()})    	  		  //Pesquisa por indice selecionado
SetKey(VK_F11,{|| fFiltrar(1, cIndex)})      //Filtra Pesquisa
SetKey(VK_F12,{|| fFiltrar(2, cIndex)})      //Limpa Filtro
                             
//���������������������������������������������������������������������Ŀ
//|Aplica filtro quando ambiente = PDV                                  |  
//�����������������������������������������������������������������������  
If Left(cFilAnt,2) $ "01" //Alterado 02/05/2017 Alterado Emp 03 :   .Or. ( Upper(AllTrim(GetEnvServer())) $ "PDV" .And. Upper(AllTrim(cUserName)) $ "PEDIDO.JAYS#PEDIDO.QUALYCOR" ) 
	cCondicao	+= "B0_GRUPO >= '3000' AND B0_GRUPO <= '3999' AND B0_GRUPO NOT IN ('3202') "  //Alterado 09/01/2017 - Adicionado filtro grupo 3202 Impermebilizantes p/ somente Multicores

ElseIf Left(cFilAnt,2) $ "02"	                            
            
	//���������������������������������������������������������������������Ŀ
	//|Recupera produto(s) comprado pelo cliente                            |  
	//�����������������������������������������������������������������������  
	cQry := "SELECT		D2_COD [PRODUTO] " + ENTER
	cQry += "FROM		" + RetSqlName("SD2") + ENTER
	cQry += "WHERE		D_E_L_E_T_ = '' " + ENTER
	cQry += "AND		D2_FILIAL = '" + xFilial("SD2") + "' " + ENTER
	cQry += "AND		D2_CLIENTE = '" + M->CJ_CLIENTE + "' " + ENTER
	cQry += "AND		D2_LOJA = '" + M->CJ_LOJA + "' " + ENTER            
	cQry += "GROUP BY	D2_COD " + ENTER
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	        
	TCQUERY cQry NEW ALIAS QRY
    
	If QRY->( !EoF() )
                          
		Do While QRY->( !EoF() )
		                     
			cProdutoIn += "'" + RTrim(QRY->PRODUTO) + "',"
			QRY->( dbSkip() )
		
		EndDo
		
		cProdutoIn += "''"

	EndIf

	QRY->(dbCloseArea())
	
	If Left(cFilAnt,2) $ "02"
		cCondicao += "B0_GRUPO >= '1000' AND B0_GRUPO <= '1999' " + IIf( !Empty(cProdutoIn), " AND B0_COD IN (" + cProdutoIn + ") ", "" ) 
	//ElseIf Left(cFilAnt,2) $ "08"
		//cCondicao	+= " B0_GRUPO >= '3000' AND B0_GRUPO <= '3999' AND B0_GRUPO IN ('3202')  " + IIf( !Empty(cProdutoIn), " AND B0_COD IN (" + cProdutoIn + ") ", "" )  //Alterado 09/01/2017 - Adicionado filtro grupo 3202 Impermebilizantes p/ somente Multicores
	EndIF

//ElseIf Left(cFilAnt,2) $ "03"	////Alterado 02/05/2017 Faturamento somente Multicores
	//cCondicao	+= "B0_GRUPO > '9999' "

ElseIf Left(cFilAnt,2) $ "03#08"	
	cCondicao	+= "B0_GRUPO >= '3000' AND B0_GRUPO <= '3999' "	//Alterado 02/05/2017 Faturamento somente Multicores
	//cCondicao	+= " B0_GRUPO IN ('3202') "		//Alterado 09/01/2017 - Adicionado filtro grupo 3202 Impermebilizantes p/ somente Multicores
EndIf  
    
bFiltraBrw	:= {||FilBrowse("SB0", @aInd, @cCondicao, .F.)}    
Eval(bFiltraBrw)

//���������������������������������������������������������������������Ŀ
//|Monta Tela                                                           |  
//�����������������������������������������������������������������������
oDlg1:=MSDialog():New()
oDlg1:nTop      := 050
oDlg1:nLeft     := 004
oDlg1:nBottoM   := 506
oDlg1:nRight    := 502
oDlg1:cTitle    := "Consulta de Produtos"
oDlg1:lCentered := .T.

@ 020.0, 006.0 TO 160, 239 BROWSE "SB0" FIELDS aMat OBJECT oBrow 
				oBrow:oBrowse:bChange  := {|| fPrcEstoq()}  
				oBrow:oBrowse:bLDblClick := {|| fConfirma(), dbSelectArea("SB0"), dbClearFilter(), M->CK_PRODUTO := SB0->B0_COD, GetdRefresh()}  
@ 000.5, 001.1 SAY "ESC = Sair   F9  = �ndice   F10 = Pesquisa   F11 = Filtra   F12 = Limpa Filtro   ENTER = Confirma" 
@ 001.0, 002.0 TO 180,243 LABEL "" OF oDlg1 PIXEL
@ 012.5, 005.0 MSGET oPesq VAR cPesq PICTURE "@!" SIZE 120, 13                
@ 012.7, 001.0 SAY "Pesquisar: " 
@ 012.7, 020.0 SAY "  por " + cIndex 

//Posiciona Get
oPesq:SetFocus()
oPesq:bLostFocus := {|| fFiltrar(1, "C") }


@ 014.2, 001.0 SAY "Saldo"     
@ 014.8, 001.0 MSGET oSaldo VAR nSaldo PICTURE "@E 999,999.99" WHEN .F. SIZE 50, 20 FONT oFont2 

@ 014.2, 007.5 SAY "Reserva"     
@ 014.8, 007.5 MSGET oReserva VAR nReserva PICTURE "@E 999,999.99" WHEN .F. SIZE 50, 20 FONT oFont2 

@ 014.2, 014.0 SAY "Dispon�vel"     
@ 014.8, 014.0 MSGET oDisp VAR nDisp PICTURE "@E 999,999.99" WHEN .F. SIZE 50, 20 FONT oFont2 COLOR CLR_BLUE

@ 014.2, 020.5 SAY "Pre�o (R$) "     
@ 014.8, 020.5 MSGET oPrcLst VAR nPrcLst PICTURE "@E 999,999.99" WHEN .F. SIZE 75, 20 FONT oFont1 COLOR CLR_GREEN
  
oDlg1:Activate(,,,.T.)                           
     
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fOrdena   � Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �SELECAO DE INDICE SB0                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/       
Static Function fOrdena()

If Alltrim(cIndex) == "Descri��o"
	cIndex := "C�digo"
	dbSelectArea("SB0")
	dbSetOrder(1)
Else  
	cIndex := "Descri��o"
	dbSelectArea("SB0")
	dbSetOrder(2)
EndIf       

//���������������������������������������������������������������������Ŀ
//|Atualiza oDlg1                                                       |  
//�����������������������������������������������������������������������
oBrow:oBrowse:Refresh()  
                 
Return  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fFiltrar  � Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �FILTRO DO CADASTRO SB0                                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/  
Static Function fFiltrar(nOpcao, cIndex)    
Local cCondicao	:= "@"     
Local aInd      := {}

EndFilBrw("SB0", aInd)
SB0->(dbClearFilter())

If nOpcao == 1             
	
	cCondicao:= "@( B0_COD LIKE '%" + AllTrim(cPesq) + "%' OR B0_DESC LIKE '%" + AllTrim(cPesq) + "%' )"
	
	If Left(cFilAnt,2) $ "01#03#08" .Or. ( Upper(AllTrim(GetEnvServer())) $ "PDV" .And. Upper(AllTrim(cUserName)) $ "PEDIDO.JAYS#PEDIDO.QUALYCOR" )  //Alterado 09/01/17 - Alteardo 02/05/17 Fat somente Multicores
		cCondicao	+= " AND B0_GRUPO >= '3000' AND B0_GRUPO <= '3999' " // AND B0_GRUPO NOT IN ('3202') AND SUBSTRING(B0_COD,1,8) NOT IN ('0500.001','0600.001') "  //Alterado 09/01/2017 - Adicionado filtro grupo 3202 Impermebilizantes p/ somente Multicores
	ElseIf Left(cFilAnt,2) $ "02"	
		cCondicao	+= " AND B0_GRUPO >= '1000' AND B0_GRUPO <= '1999' " //Alterado 09/01/2017  + IIf( lProdutoIn, " AND B0_COD IN (" + cProdutoIn + ") ", "" ) 
	//ElseIf Left(cFilAnt,2) $ "03"
		//cCondicao	+= " AND B0_GRUPO > '9999' "
	
	//ElseIf Left(cFilAnt,2) $ "08"	
		//cCondicao += " AND B0_GRUPO IN ('3202') OR SUBSTRING(B0_COD,1,8) IN ('0500.001','0600.001') "
		//cCondicao	+= " AND ((B0_GRUPO >= '3000' AND B0_GRUPO <= '3999') OR ( B0_GRUPO >= '1000' AND B0_GRUPO <= '1999' )) "  //Alterado 09/01/2017 - Adicionado filtro grupo 3202 Impermebilizantes p/ somente Multicores
	EndIf

    /*    
	If Upper(AllTrim(GetEnvServer())) == "PDV" .And. AllTrim(cFilAnt) $ "0200#0201#0204#0205" .And. bUsrExtEuro
		cCondicao	+= "Left(SB0->B0_COD,3) $ '329#337#508#539#605#614#346#706#502'" 
	EndIf
	*/

	bFiltraBrw := {||FilBrowse("SB0", @aInd, @cCondicao, .F.)}
	Eval(bFiltraBrw)       
	oBrow:oBrowse:Refresh()   	

Else              

	lProdutoIn := .F.

	If Upper(AllTrim(GetEnvServer())) $ "PDV" 

		If Left(cFilAnt,2) $ "01#03#08" .Or. Upper(AllTrim(cUserName)) $ "PEDIDO.JAYS#PEDIDO.QUALYCOR"
			cCondicao	+= " B0_GRUPO >= '3000' AND B0_GRUPO <= '3999' " //Retirado 02/05/17 AND B0_GRUPO NOT IN ('3202') AND SUBSTRING(B0_COD,1,8) NOT IN ('0500.001','0600.001') " 
		ElseIf Left(cFilAnt,2) $ "02"	
			cCondicao	+= " B0_GRUPO >= '1000' AND B0_GRUPO <= '1999' "
		//ElseIf Left(cFilAnt,2) $ "03"
			//cCondicao	+= " AND B0_GRUPO > '9999' "		
		//ElseIf Left(cFilAnt,2) $ "08"  --Retirado 02/05/17
			//cCondicao	+= " B0_GRUPO IN ('3202') OR SUBSTRING(B0_COD,1,8) IN ('0500.001','0600.001')  "
		EndIf
	    
		bFiltraBrw := {||FilBrowse("SB0", @aInd, @cCondicao, .F.)}
		Eval(bFiltraBrw)       
		oBrow:oBrowse:Refresh()   	

	Else
		EndFilBrw("SB0", @aInd)
	EndIf
	
    /*    
	If Upper(AllTrim(GetEnvServer())) == "PDV" .And. AllTrim(cFilAnt) $ "0200#0201#0204#0205" .And. bUsrExtEuro
		cCondicao	+= "Left(SB0->B0_COD,3) $ '329#337#508#539#605#614#346#706#502'" 
	EndIf
	*/


EndIf

//���������������������������������������������������������������������Ŀ
//|Atualiza oDlg1                                                       |  
//�����������������������������������������������������������������������
GetdRefresh()

Return                         

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fPesquisa � Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �PESQUISA SB0                                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
Static Function fPesquisa()

SB0->(dbSeek(xFilial("SB0") + AllTrim(cPesq))) 
fPrcEstoq()

Return      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fConfirma � Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �CONFIRMA PRODUTO                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
Static Function fConfirma()

//���������������������������������������������������������������������Ŀ
//|Confirma produto selecionado                                         | 
//�����������������������������������������������������������������������
lRet := .T.                  //Confirma retorno do produto            

//���������������������������������������������������������������������Ŀ
//|Teclas de Navegacao                                                  |  
//�����������������������������������������������������������������������
SetKey(VK_F9 ,Nil)   //Troca Indice
SetKey(VK_F10,Nil)   //Pesquisa por indice selecionado
SetKey(VK_F11,Nil)   //Filtra Pesquisa
SetKey(VK_F12,Nil)   //Limpa Filtro    

SB0->(dbSetOrder(1)) //Ordena SB0

Close(oDlg1)                                       

Return   

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fPrcEstoq � Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �ATUALIZA DADOS DE PRECO E ESTOQUE                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
Static Function fPrcEstoq()    

//���������������������������������������������������������������������Ŀ
//|Atualiza Preco                                                       |  
//�����������������������������������������������������������������������
nPrcLst := 0            

//���������������������������������������������������������������������Ŀ
//|Atualiza Saldos em Estoque                                           |  
//�����������������������������������������������������������������������
SB2->(dbSeek(xFilial("SB2") +SB0->B0_COD + "08"))  
nSaldo   := SB2->B2_QATU
nReserva := SB2->B2_RESERVA
nDisp    := SB2->B2_QATU - SB2->B2_RESERVA

oPrcLst:Refresh()
oSaldo:Refresh()
oReserva:Refresh()
oDisp:Refresh()

Return                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AtualizaSB� Autor �Tiago O. Beraldi    � Data �  23/07/07   ���
�������������������������������������������������������������������������͹��
���Descricao �ATUALIZA DADOS DE PRECO E ESTOQUE                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 
User Function GENC006A

If Left(cFilAnt,2) $ "01#08"  // Multicores, Qualyvinil Comercial, Qualycor e Jays Tintas       Alterado 02/05/17 Faturamento retirado Qualyvinil, somente Multicores   

		cQry := " DELETE FROM " + RetSqlName("SB0") + " WHERE  B0_FILIAL = '" + AllTrim(cFilAnt) + "' "  
		TcSqlExec(cQry)
		
		cQry := " INSERT	INTO " + RetSqlName("SB0") + " (B0_FILIAL, B0_COD, B0_DESC, B0_UM, R_E_C_N_O_, B0_GRUPO) " + ENTER
		cQry += " SELECT	'" + AllTrim(cFilAnt) + "' FILIAL, " + ENTER
		cQry += " 			B1_COD CODIGO, " + ENTER
		cQry += " 			B1_DESC DESCRICAO, " + ENTER
		cQry += " 			B1_UM UND, " + ENTER
		cQry += " 			(ISNULL((SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("SB0") + "), 0) + (RANK() OVER (ORDER BY B1_COD))) RECNO, " + ENTER
		cQry += " 			B1_GRUPO GRUPO " + ENTER
		cQry += " FROM 		 " + RetSqlName("SB1") + "  " + ENTER
		cQry += " WHERE		D_E_L_E_T_ = '' " + ENTER
		cQry += " 			AND B1_TIPO = 'PA' " + ENTER
		cQry += " 			AND B1_MSBLQL != '1' " + ENTER
		cQry += " 			AND (SUBSTRING(B1_GRUPO, 1, 1) = '3' OR SUBSTRING(B1_GRUPO, 1, 2) = '13') " + ENTER

		//+----------------------------------------------------------------------------
		//| Desconsidera codigos de produtos DICICO
		//+----------------------------------------------------------------------------
		cQry += " 			AND SUBSTRING(B1_COD, 1, 8) NOT IN ('0500.001', '0600.001', '0650.002') " + ENTER 

		TcSqlExec(cQry)
		TcRefresh(RetSqlName("SB0"))
	
ElseIf Left(cFilAnt,2) $ "02" // Euroamerican Industria, Multicores, Revenda e Consumo
	
		cQry := " DELETE FROM " + RetSqlName("SB0") + " WHERE  B0_FILIAL = '" + AllTrim(cFilAnt) + "' "  
		TcSqlExec(cQry)
		
		cQry := " INSERT	INTO " + RetSqlName("SB0") + " (B0_FILIAL, B0_COD, B0_DESC, B0_UM, R_E_C_N_O_, B0_GRUPO) " + ENTER
		cQry += " SELECT	'" + AllTrim(cFilAnt) + "' FILIAL, " + ENTER
		cQry += " 			B1_COD CODIGO, " + ENTER
		cQry += " 			B1_DESC DESCRICAO, " + ENTER
		cQry += " 			B1_UM UND, " + ENTER
		cQry += " 			(ISNULL((SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("SB0") + "), 0) + (RANK() OVER (ORDER BY B1_COD))) RECNO, " + ENTER
		cQry += " 			B1_GRUPO GRUPO " + ENTER
		cQry += " FROM 		 " + RetSqlName("SB1") + "  " + ENTER
		cQry += " WHERE		D_E_L_E_T_ = '' " + ENTER
		cQry += " 			AND B1_TIPO = 'PA' " + ENTER
		cQry += " 			AND B1_MSBLQL != '1' " + ENTER
		cQry += " 			AND ( SUBSTRING(B1_GRUPO, 1, 1) = '1' OR SUBSTRING(B1_GRUPO, 1, 1) = '3' OR SUBSTRING(B1_GRUPO, 1, 2) = '13' )   " + ENTER

		TcSqlExec(cQry)
		TcRefresh(RetSqlName("SB0"))
	
EndIf

Return      