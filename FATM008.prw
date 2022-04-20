#include "protheus.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "rwmake.ch"    

#define ENTER chr(13) + chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FATM008  บ Autor ณTiago O Beraldi     บ Data ณ 14/10/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAJUSTA CUSTO STANDARD E PRECO DE VENDAS                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function FATM008()
      
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aArea       := GetArea()
                                            
Private cPerg     := "FATM08"
Private cTimeCur  := "00:00"
Private cTimeIni  := Time()
Private oDlg1        

 
SetPrvt("oGrp1","oGrp2","oGrp3","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSBtn1","oSBtn2","oSBtn3")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Dicionario de Perguntas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Pergunte(cPerg, .F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//| Definicao do Dialog e todos os seus componentes.                    |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oDlg1      := MSDialog():New( 000,000,120,400,"Ajusta Custo Standard e Pre็os de Venda",,,.F.,,,,,,.T.,,,.T. )   
oGrp1      := TGroup():New( 002,002,040,200,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGrp2      := TGroup():New( 042,002,060,110,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oGrp3      := TGroup():New( 042,112,060,200,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSay1      := TSay():New( 006,007,{||"Este programa tem o objetivo de ajustar o Custo Standard e Pre็os de Venda"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay2      := TSay():New( 014,007,{||"conforme cadastro de estrutura.                                           "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay3      := TSay():New( 022,007,{||"Obs.: Somente ira atualizar o Custo dos Produtos com Estrutura cadastrada."},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay4      := TSay():New( 030,007,{||"Especํfico Empresa Euroamerican.                                          "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,200,008)
oSay5      := TSay():New( 048,007,{||"Tempo Decorrido: " },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,064,008)
oSay6      := TSay():New( 048,050,{|| cTimeCur           },oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSBtn1     := SButton():New( 046,115,5,{|| Pergunte(cPerg, .T.)},oDlg1,,"", )
oSBtn2     := SButton():New( 046,143,1,{|| CursorWait(), U_FATM08E(), CursorArrow()},oDlg1,,"", )
oSBtn3     := SButton():New( 046,171,2,{|| oDlg1:End()         },oDlg1,,"", )
	
oDlg1:Activate(,,,.T.)
                   
RestArea(aArea) 

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOADCUSTD บ Autor ณTiago O Beraldi     บ Data ณ 14/10/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPROCESSA ATUALIZACAO                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function FATM08E(lBlind) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cSProc   := ""     
Local cCICPath := "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"  
Local cCICUser := "Administrator,Caroline.Monea" 
Local lCICDif   := .F.

Default lBlind    := .F.
                                            
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ 1 = Atualiza Custo Standard 2 = Atualiza Custo Teste                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !lBlind
	If mv_par03 == 1
		cMsg := "Deseja continuar a atualiza็ใo? (CUSTO STANDARD)"
	Else
		cMsg := "Deseja continuar a atualiza็ใo? (CUSTO TESTES)"
	EndIf
	
	If !ApMsgYesNo(cMsg, "Atualiza็ใo de Custos")                             
		Return                                                                
	EndIf
Else   
	Pergunte("FATM08", .F.)
EndIf	
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Executa procedure                                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cSProc := "SP_CUSTOSTD '" + mv_par01 + "','" + mv_par02 + "','B1_CUST" + Subs(DtoC(dDataBase),4,2) + "', '" + StrZero(mv_par03, 1) + "'"
TcSQLExec(cSProc)
                                                                                                            
// Atualiza Historico de Custos                                                                            
If mv_par03 == 1    

	/*cQry := " SELECT  B1_COD CODIGO, " + ENTER
	cQry += " 		  B1_CUSTD CUSTD, " + ENTER 
	cQry += "         B1_CUSTNET CUSTN, " + ENTER 
	cQry += "         CONVERT(VARCHAR, GETDATE(), 112) DATA, " + ENTER  
	cQry += "         ISNULL((SELECT ZJ_CUSTD FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND ZJ_COD = B1_COD)),0) CSTOLD, " + ENTER
	cQry += "         ISNULL((SELECT ZJ_CUSTNET FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND ZJ_COD = B1_COD)),0) CNTOLD" + ENTER
	cQry += " FROM " + RetSqlName("SB1") + " " + ENTER
	cQry += " WHERE	D_E_L_E_T_ = '' " + ENTER
	cQry += " 		AND B1_TIPO IN ('MP','ME','PI','PA','SP') " + ENTER
	cQry += " 		AND (ABS(B1_CUSTD - ISNULL((SELECT ZJ_CUSTD FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND ZJ_COD = B1_COD)),0)) >= 0.01 " + ENTER
	cQry += " 			 OR ABS(B1_CUSTNET - ISNULL((SELECT ZJ_CUSTNET FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND R_E_C_N_O_ = (SELECT MAX(R_E_C_N_O_) FROM  " + RetSqlName("SZJ") + " WHERE D_E_L_E_T_ = '' AND ZJ_COD = B1_COD)),0)) >= 0.01) " + ENTER
	cQry += " ORDER BY CODIGO "             
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf                  
	
	TCQUERY cQry NEW ALIAS QRY
	
	dbSelectArea("QRY")
	dbGoTop()
	
	If !lBlind .And. ApMsgYesNo("Envia CIC de diverg๊ncias superiores a 4,00% ?", "Atualiza็ใo de Custos") 
		lCICDif := .T.
	EndIf		
	
	While !QRY->(EOF())
		 
		RecLock("SZJ", .T.)  
			SZJ->ZJ_FILIAL  := ""
			SZJ->ZJ_COD     := QRY->CODIGO
			SZJ->ZJ_CUSTD   := QRY->CUSTD 
			SZJ->ZJ_CUSTNET := QRY->CUSTN 
			SZJ->ZJ_CSTOLD  := QRY->CSTOLD 
			SZJ->ZJ_CNTOLD  := QRY->CNTOLD 
			SZJ->ZJ_DATA    := dDataBase
		SZJ->( MsUnLock() )   
		 
		If Abs(QRY->CUSTD - QRY->CSTOLD)/QRY->CSTOLD  > 0.04  .And. lCICDif      
		
			// Avisa o responsavel pelo cadastramento via Gerenciador
			cCICMsg := '"(Workflow) ATUALIZAวรO DE CUSTOS ' + ENTER + ENTER
			cCICMsg += 'Usuario.......: ' + Upper(AllTrim(cUserName)) + ENTER
			cCICMsg += 'Emissใo.......: ' + DtoC( dDatabase ) + ENTER
			cCICMsg += 'Produto.......: ' + QRY->CODIGO + ENTER
			cCICMsg += 'Custo Anterior: ' + Transform(QRY->CSTOLD, "@E 999,999.99") + ENTER
			cCICMsg += 'Custo Atual...: ' + Transform(QRY->CUSTD, "@E 999,999.99") + ENTER
						
			WinExec(cCICPath + Space(1) + cCICUser + Space(1) + cCICMsg, 0)	
		
		EndIf			
		QRY->(dbSkip())

	EndDo              
	
	QRY->(dbCloseArea())*/
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza Tabela de Precos                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*cUpdate := "  UPDATE " + RetSqlName("DA1") 
	cUpdate += "  SET DA1_PERDES = ISNULL((SELECT B1_FATOR FROM " + RetSqlName("SB1") + " WHERE D_E_L_E_T_ = '' AND B1_COD = DA1_CODPRO), 0), " + ENTER +;                                   
	               "      DA1_DATVIG = '" + DtoS(dDataBase + 30) + "' "
	TcSQLExec(cUpdate)*/                             

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Atualiza PA tercerizados                                   ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cUpdate := "  UPDATE " + RetSqlName("SB1") + ENTER
	cUpdate += "  SET B1_CUSTD = B1_VAL1, " + ENTER                                    
	cUpdate += "      B1_VALOR4 = B1_VAL1, " + ENTER                                    		
	cUpdate += "      B1_CUST" + StrZero(Month(dDataBase), 2) + " = B1_VAL1, " + ENTER 
	//cUpdate += "      B1_PRV1 = (1.03 * B1_FATOR * B1_VAL1) " + ENTER 
	cUpdate += "      B1_PRV1 = B1_CUSTNET / ( (1 - 0.04 -  "
	cUpdate += "      				CASE WHEN B1_COD LIKE '8%' AND SUBSTRING(B1_COD,4,1) = '.' THEN 0.03 "  + ENTER //"Produtos Revenda
	cUpdate += "      					ELSE 0.155 END ) - ( 40 * 0.000421 ) - ( 0.0925 + 0.18 ) - 0.025 ) " + ENTER 
	 		//PrcVenda = B1_PRV1 / (1 - Margem%/CustosGerais )
	 		//B1_PRV1 = CustoNet / CustosGerais
	 		//CustosGerais = (1 - Frete - CustoFixo - JurosMedio40dias - Impostos18 - Comissao)
	
   	cUpdate += "  WHERE	D_E_L_E_T_ <> '*' " + ENTER                                   
   	cUpdate += "  		AND B1_TIPO = 'PA' " + ENTER                           
   	cUpdate += "  		AND NOT EXISTS (SELECT G1_COD FROM  " + RetSqlName("SG1") + "  WHERE D_E_L_E_T_ = '' AND G1_COD = B1_COD) " + ENTER
   	cUpdate += "  		AND B1_MSBLQL <> '1' "   
   	
	MemoWrite("fatm008.sql", cUpdate)                             
	TcSQLExec(cUpdate)                             
		
Endif
        
//TcSQLExec(" EXEC SP_ATUPESOS ")
                                      
If !lBlind
	cTimeCur := CalcProg(cTimeIni, Time())
	GetdRefresh()
	ApMsgInfo("Fim do Processamento!", "Atualiza็ใo de Custos")
EndIf	

Return                   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FATM008  บ Autor ณTiago O Beraldi     บ Data ณ 14/10/08    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CALCULO DE PROGRESSO                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                     A L T E R A C O E S                               บฑฑ
ฑฑฬออออออออออหออออออออออออออออออหอออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      บProgramador       บAlteracoes                               บฑฑ
ฑฑศออออออออออสออออออออออออออออออสอออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CalcProg(cTimeI, cTimeF)

Local nSegIni := Val(Subs(cTimeI,1,2)) * 3600 + Val(Subs(cTimeI,4,2)) * 60 + Val(Subs(cTimeI,7,2))
Local nSegFim := Val(Subs(cTimeF,1,2)) * 3600 + Val(Subs(cTimeF,4,2)) * 60 + Val(Subs(cTimeF,7,2))
Local nSeg    := nSegFim - nSegIni
Local nMin    := (nSeg - (nSeg % 60)) / 60

nSeg := nSeg % 60
                    
Return StrZero(nMin,2) + ":" + StrZero(nSeg,2)