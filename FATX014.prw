#include "topconn.ch"        
#include "tbiconn.ch"
#include "rwmake.ch"
#include "protheus.ch"                      

#define ENTER chr(13) + chr(10)        
        
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FATX014  �Autor  �Alexandre Marson    � Data �  30/08/12   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE FRETE ( TRANSP X VEICULO X MUNICIPIO  )        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������͹��
���                     A L T E R A C O E S                               ���
�������������������������������������������������������������������������͹��
���Data      �Programador       �Alteracoes                               ���
�������������������������������������������������������������������������͹��
���          �                  �                                         ���
���          �                  �                                         ���
���          �                  �                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX014()     

//������������������������������������������������������������Ŀ
//� Declaracao de variaveis                                    �
//��������������������������������������������������������������
Private cAlias    := "ZZ9"
Private cCadastro := "Cadastro de Frete"
Private aRotina   := MenuDef()      
Private aCores    := {}

//������������������������������������������������������������Ŀ
//� Monta mBrowse                                              �
//��������������������������������������������������������������
dbSelectArea(cAlias)
dbSetOrder(1)
dbGoTop()

mBrowse(,,,,cAlias,,,,,,aCores)

Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Alexandre Marson      � Data �24/04/2012���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()    
Local aMenuDef		:= {}       

aAdd(aMenuDef, {"Pesquisar"			,"AxPesqui"		, 0, 01, 0})
aAdd(aMenuDef, {"Visualizar"		,"AxVisual"		, 0, 02, 0})
aAdd(aMenuDef, {"Incluir"			,"U_FATX014M"	, 0, 03, 0})
aAdd(aMenuDef, {"Alterar"			,"U_FATX014M"	, 0, 04, 0}) 
aAdd(aMenuDef, {"Excluir"			,"U_FATX014M"	, 0, 05, 0})   

Return (aMenuDef)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATX013M  �Autor  �Alexandre Marson    � Data �  28/05/13   ���
�������������������������������������������������������������������������͹��
���Descricao � 															  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX014M(cAlias, nReg, nOpc)              

Local aArea		:= GetArea()                                  

Do Case

	Case nOpc == 3 
		AxInclui( cAlias, nReg, nOpc,,,,"U_FATX014T()" )

	Case nOpc == 4
		AxAltera( cAlias, nReg, nOpc,,,,"U_FATX014T()" )
	
	Case nOpc == 5
		AxDeleta( cAlias, nReg, nOpc )
                 
EndCase

Restarea( aArea )        

Return                  

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATX013T  �Autor  �Alexandre Marson    � Data �  28/05/13   ���
�������������������������������������������������������������������������͹��
���Descricao �TUDOK												          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX014T()

Local lRet := .T.              
                              
//������������������������������������������������������������Ŀ
//� VALIDA DUPLICIDADE DE REGISTRO                             �
//��������������������������������������������������������������
lRet := ExistChav("ZZ9", M->ZZ9_TRANSP+M->ZZ9_VEICUL+M->ZZ9_CODMUN, 2)   

Return( lRet )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATX013T  �Autor  �Alexandre Marson    � Data �  28/05/13   ���
�������������������������������������������������������������������������͹��
���Descricao �GATILHOS											          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX014G(nOpc)
Local aArea		:= GetArea()
Local xRet		:= ""
Local cChave	:= ""

Do Case
                  
	// ZZ9_TRANSP ( REAL )
	Case nOpc == 1            
	
		cChave	:= IIf( Type("M->ZZ9_VEICUL") == "U", ZZ9->ZZ9_VEICUL, M->ZZ9_VEICUL )   
		
		DA3->( dbSetOrder(3) )
		DA3->( MsSeek( xFilial("DA3") + cChave ) )
		
		SA4->( dbSetOrder(1) )
		SA4->( dbSeek( xFilial("SA4") + DA3->DA3_TRANSP ) )
		
		If SA4->( Found() )
			xRet := AllTrim( SA4->A4_COD )
		EndIf

	// ZZ9_XTRANSP ( VIRTUAL )
	Case nOpc == 2            
	
		cChave	:= IIf( Type("M->ZZ9_VEICUL") == "U", ZZ9->ZZ9_VEICUL, M->ZZ9_VEICUL )   
		
		DA3->( dbSetOrder(3) )
		DA3->( MsSeek( xFilial("DA3") + cChave ) )
		
		SA4->( dbSetOrder(1) )
		SA4->( dbSeek( xFilial("SA4") + DA3->DA3_TRANSP ) )
		
		If SA4->( Found() )
			xRet := AllTrim( SA4->A4_NOME )
		EndIf
			 
	// ZZ9_MUN ( REAL )
	Case nOpc == 3         		
		
		cChave	:= xFilial("CC2") +;
						IIf( Type("M->ZZ9_EST") == "U", ZZ9->ZZ9_EST, M->ZZ9_EST ) +;
						IIf( Type("M->ZZ9_CODMUN") == "U", ZZ9->ZZ9_CODMUN, M->ZZ9_CODMUN )
		
		CC2->( dbSetOrder(1) )
		CC2->( dbSeek( cChave ) )
		
		If CC2->( Found() )
			xRet := AllTrim( CC2->CC2_MUN )
		EndIf

EndCase

Restarea( aArea )

Return( xRet )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FATX013T  �Autor  �Alexandre Marson    � Data �  28/05/13   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao utilizada para calcular o valor do frete conforme a  ���
���          �regra da transportadora                                     ���
�������������������������������������������������������������������������͹��
���Uso       � GENERICO                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function FATX014F(cTransp, cVeiculo, cCodMun, cEst, nValorCG, nPesoCG, nQtdeEnt)

Local aArea		:= GetArea()   
Local aAreaSA4	:= SA4->(GetArea())
Local aAreaCC2	:= CC2->(GetArea())

Local nRet		:= 0           

Local cCICPath	:= "\\srv-004\pub\utils\tools\CICMsg.exe srv-004 workflow 123456"
Local cCICUser	:= ""	//IIf( AllTrim(FilAnt) == "0107", U_GetUserGp("VEN-D07"), IIf( AllTrim(cFilAnt) == "0108", U_GetUserGp("VEN-D08"), "REGIANE.TAQUETTE" ) )
Local cCICMsg	:= ""    

Local cQry		:= ""
Local cTipo		:= ""

Begin Sequence
                         
	// Regra de Frete
	cQry := "SELECT	ZZ9_TIPO, ZZ9_VALOR " + ENTER
	cQry += "FROM 	" + RetSqlName("ZZ9") + ENTER
	cQry += "WHERE	D_E_L_E_T_ = '' " + ENTER
	cQry += "AND	ZZ9_FILIAL = '" + xFilial("ZZ9") + "' " + ENTER
	cQry += "AND	ZZ9_TRANSP = '" + Trim(cTransp) + "' " + ENTER
	cQry += "AND	ZZ9_VEICUL = '" + Trim(cVeiculo) + "' " + ENTER
	cQry += "AND	ZZ9_CODMUN = '" + Trim(cCodMun) + "' " + ENTER
	cQry += "AND	ZZ9_EST = '" + Trim(cEst) + "' " + ENTER	
	
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	        
	TCQUERY cQry NEW ALIAS QRY	
	
	If QRY->( !EoF() )  
	   
		// Calcula Frete Normal
		Do Case
			
			Case QRY->ZZ9_TIPO == "T"
				nRet := ( ( nPesoCG / 1000 ) * QRY->ZZ9_VALOR )
	
			Case QRY->ZZ9_TIPO == "P"
				nRet := ( ( nValorCG * QRY->ZZ9_VALOR ) / 100 )
	
			Case QRY->ZZ9_TIPO == "F"
				nRet := QRY->ZZ9_VALOR
	
		EndCase   
		
		// Calcula Frete Adicional
		If .Not. ( AllTrim(cFilAnt) $ "0107#0108" ) .And. QRY->ZZ9_TIPO != "P" .And. nQtdeEnt > 3 
				 
			nRet := nRet + ( ( nQtdeEnt - 3 ) * 10 )

		EndIf 
		
	Else                            
	
		// Posiciona na tabela de transportadora
		SA4->( dbSetOrder(1) )
		SA4->( dbSeek(xFilial("SA4")+cTransp) ) 		
				
		// Posiciona na tabela de municipios
		CC2->( dbSetOrder(1) )
		CC2->( dbSeek(xFilial("CC2")+cEst+cCodMun) )	

		// Avisa o utilizador do programa via Protheus
		MsgStop("Regra de frete n�o cadastrada para o ve�culo " + cVeiculo + " da transportadora " + AllTrim(SA4->A4_NOME) + " com destino a " + AllTrim(CC2->CC2_MUN) + " / " + AllTrim(cEst) + "." +;
		                    ENTER + ENTER +;
		                    "Solicite o cadastramento junto ao respons�vel.")		
		                                 
		// Avisa o responsavel pelo cadastramento via Gerenciador
		cCICMsg := '"(Workflow) INCLUSAO DE REGRA PARA FRETE' + ENTER + ENTER
		cCICMsg += 'Usuario.......: ' + Upper(AllTrim(cUserName)) + ENTER
		cCICMsg += 'Emiss�o.......: ' + DtoC( dDatabase ) + ENTER
		cCICMsg += 'Transportadora: ' + SA4->A4_COD + " - " + AllTrim(SA4->A4_NOME) + ENTER
		cCICMsg += 'Placa/Veiculo.: ' + cVeiculo + ENTER
		cCICMsg += 'Municipio.....: ' + CC2->CC2_CODMUN + " - " + AllTrim(CC2->CC2_MUN) + ENTER
		cCICMsg += 'Estado........: ' + cEst + ENTER
		
		//WinExec(cCICPath + Space(1) + cCICUser + Space(1) + cCICMsg, 0)	
	
	EndIf
	           
	// Fecha workarea temporario
	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	          
End Sequence	
	             
RestArea( aAreaSA4 )
RestArea( aAreaCC2 )
Restarea( aArea )

Return( nRet )