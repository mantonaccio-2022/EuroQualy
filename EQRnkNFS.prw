#include "protheus.ch"
#include "topconn.ch"
/*/
����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � BeRnkNFE � Autor � Rodrigo Sousa 		� Data � 24.04.14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ranking de Lan�amentos de Nota fiscal de Entrada   		   ���
���			 � por usuario												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
User Function EQRnkNFS()

Local oReport

Private cPerg	:= "EQRNFS"
Private cItemInc := ""
Private cUserInc := ""

ValidPerg()

If !Pergunte(cPerg, .T.)
	ApMsgInfo('Relat�rio Cancelado', 'Aten��o')
	Return
EndIf

LjMsgRun( "Gerando o arquivo, aguarde...", "Ranking de Lan�amentos NFS", {|| fImpExcel() } )

Return oReport

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � fImpExcel  � Autor � Rodrigo              � Data � 02.10.2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Exporta para Excel	        		  	     				���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function fImpExcel

Local lImpCab	:= .F.
Local lPrimeira	:= .T.

Local cUsrAnt	:= ""

Local nTotInc 	:= 0
Local nTotExc 	:= 0		

Local nWorkSheet := 0
Local cWorkSheet := ""
Local cTable	 := ""

Local oExcel 	:= FwMsExcel():New()

Local aRnkTot	:= {} 
Private aItens	:= {}

CarregaDados()

//�����������������������������������������������������������Ŀ
//� Ordena Por Usuario										  �
//�������������������������������������������������������������
aItens := aSort(aItens,,, {|x,y| x[9]+DtoS(x[7]) < y[9]+DtoS(y[7]) })

//�������������������������������������������������������������Ŀ
//� Imprime Relatorio Sint�tico									�
//���������������������������������������������������������������
If mv_par03 == 1

	For nX := 1 to Len(aItens)

		//�������������������������������������������������������������Ŀ
		//� Verifica aglutina��o do Item								�
		//���������������������������������������������������������������
		If cUsrAnt == aItens[nX][09]
			Loop			
		EndIf			 

		If mv_par03 == 1
			aEval( aItens, {|x| iif(x[9] == aItens[nX][09] .And. Empty(Alltrim(x[10]))	, nTotInc 	+= 1, 0 ) })
			aEval( aItens, {|x| iif(x[9] == aItens[nX][09] .And. !Empty(Alltrim(x[10]))	, nTotExc 	+= 1, 0 ) })
		
			aAdd( aRnkTot , { aItens[nX][09], nTotInc, nTotExc })

			nTotInc := 0
			nTotExc := 0		

		EndIf

		cUsrAnt := aItens[nX][09]

	Next nX

	//�����������������������������������������������������������Ŀ
	//� Ordena Por Usuario										  �
	//�������������������������������������������������������������
	aItens := aSort(aRnkTot,,, {|x,y| x[2] > y[2] })

	For nY := 1 to Len(aRnkTot)

		//�������������������������������������������������������������Ŀ
		//� Imprime Cabe�alho											�
		//���������������������������������������������������������������
		If lPrimeira

			cWorkSheet 	:= "Plan1"
			cTable		:= "Ranking de Lan�amentos de NF de Saida"
			
			oExcel:AddworkSheet(cWorkSheet)
			oExcel:AddTable(cWorkSheet,cTable)

			oExcel:AddColumn(cWorkSheet,cTable,"Usuario",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"NFs Incluidas",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"NFs Excluidas",1,1)

			lPrimeira := .F.

		EndIf	

		//�������������������������������������������������������������Ŀ
		//� Imprime Ranking												�
		//���������������������������������������������������������������
		oExcel:AddRow(cWorkSheet,cTable,{	aRnkTot[nY][01],;
											aRnkTot[nY][02],;
											aRnkTot[nY][03]})								
													
    Next nY

	oExcel:AddRow(cWorkSheet,cTable,{"","",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Emitido em: "+DtoC(ddatabase)+" "+time(),"",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Parametros","",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Filial: "+cFilAnt,"",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Da Emiss�o: "+DtoC(mv_par01),"",""})								
	oExcel:AddRow(cWorkSheet,cTable,{"At� Emiss�o: "+DtoC(mv_par02),"",""})								

Else
	//�������������������������������������������������������������Ŀ
	//� Imprime Relatorio Analitico									�
	//���������������������������������������������������������������
	nWorkSheet	+= 1
	cWorkSheet 	:= "Parametros"
	cTable		:= "Ranking de lan�amentos de NF por Usuario - Analitico"

	oExcel:AddworkSheet(cWorkSheet)
	oExcel:AddTable(cWorkSheet,cTable)

	oExcel:AddColumn(cWorkSheet,cTable,"Parametros",1,1)

	oExcel:AddRow(cWorkSheet,cTable,{""})								
	oExcel:AddRow(cWorkSheet,cTable,{"Emitido em: "+DtoC(ddatabase)+" "+time()})								
	oExcel:AddRow(cWorkSheet,cTable,{"Filial: "+cFilAnt})								
	oExcel:AddRow(cWorkSheet,cTable,{"Da Emiss�o: "+DtoC(mv_par01)})								
	oExcel:AddRow(cWorkSheet,cTable,{"At� Emiss�o: "+DtoC(mv_par02)})								

	For nX := 1 to Len(aItens)

		//�������������������������������������������������������������Ŀ
		//� Verifica aglutina��o do Item								�
		//���������������������������������������������������������������
		If cUsrAnt <> aItens[nX][09]
			nWorkSheet	+= 1
			cWorkSheet 	:= aItens[nX][09]
			cTable		:= "Ranking de lan�amentos de NFS por Usuario: "+Capital(aItens[nX][09])

			//�������������������������������������������������������������Ŀ
			//� Cria Planilha												�
			//���������������������������������������������������������������
			oExcel:AddworkSheet(cWorkSheet)
			oExcel:AddTable(cWorkSheet,cTable)

			//�������������������������������������������������������������Ŀ
			//� Imprime Cabe�alho dos Itens 								�
			//���������������������������������������������������������������
			oExcel:AddColumn(cWorkSheet,cTable,"Usuario",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Documento",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"S�rie",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Cliente",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Loja",1,1)
			oExcel:AddColumn(cWorkSheet,cTable,"Emiss�o",1,1,.F.)
			oExcel:AddColumn(cWorkSheet,cTable,"Digita��o",1,1,.F.)
			oExcel:AddColumn(cWorkSheet,cTable,"Especie",1,1,.F.)
			oExcel:AddColumn(cWorkSheet,cTable,"Deletado?",1,1,.F.)

		EndIf			 

		//�������������������������������������������������������������Ŀ
		//� Imprime Ranking												�
		//���������������������������������������������������������������
		oExcel:AddRow(cWorkSheet,cTable,{	aItens[nX][09],;
											aItens[nX][02],;
											aItens[nX][03],;
											aItens[nX][04],;
											aItens[nX][05],;
											aItens[nX][06],;
											aItens[nX][07],;
											aItens[nX][08],;
											Iif(!Empty(aItens[nX][10]),"Sim","N�o")})

		cUsrAnt := aItens[nX][09]

	Next nX
EndIf

oExcel:Activate()
oExcel:GetXMLFile(Alltrim(mv_par04)+".xml")                            

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open(Alltrim(mv_par04)+".xml" )
oExcelApp:SetVisible(.T.)

Return
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �CarregaDados� Autor � Rodrigo Sousa        � Data � 02/10/2011���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Carrega Dados . 	               		  	     				���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function CarregaDados()

Local cQuery	:= ""
Local cAlias	:= GetNextAlias()
Local lRetorno	:= .T.
Local aUser		:= FWSFALLUSERS()
Local cUserInc	:= ""

//�����������������������������������������������������������Ŀ
//� Seleciona Itens											  �
//�������������������������������������������������������������
cQuery := "SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_DTDIGIT, F2_ESPECIE, F2_USERLGI, D_E_L_E_T_ as DELET "
cQuery += "FROM "+RetSqlName("SF2")+" SF2 " 
cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND "
cQuery += "F2_EMISSAO BETWEEN '" + DtoS(mv_par01)+ "' AND '" + DtoS(mv_par02) + "'  "
	                                          
If Select((cAlias)) <> 0
	(cAlias)->( dbCloseArea() )
EndIf

dbSelectArea("SF2")
dbCloseArea()

//�����������������������������������������������������������Ŀ
//� Executa Query											  �
//�������������������������������������������������������������
TCQuery cQuery New Alias (cAlias)
TCSetField( (cAlias),"F2_EMISSAO","D")
TCSetField( (cAlias),"F2_DTDIGIT","D")

dbSelectArea(cAlias)
dbGoTop()

If (cAlias)->( Eof() )
	lRetorno := .F.
EndIf

//�����������������������������������������������������������Ŀ
//� Carrega Itens											  �
//�������������������������������������������������������������
While !(cAlias)->(Eof())

    aAdd( aItens,{	(cAlias)->F2_FILIAL,;
    				(cAlias)->F2_DOC,;
    				(cAlias)->F2_SERIE,;
    				(cAlias)->F2_CLIENTE,;
    				(cAlias)->F2_LOJA,;
    				(cAlias)->F2_EMISSAO,;
    				(cAlias)->F2_DTDIGIT,;
    				(cAlias)->F2_ESPECIE,;
    				(cAlias)->F2_USERLGI,;
    				(cAlias)->DELET})
	
	(cAlias)->(dbSkip())

EndDo

(cAlias)->(dbCloseArea())

/* Thiago 19/07/2017 - A fun��o FWLeUserlg esta retornando Nil
For nX := 1 to Len(aItens)
	cItemInc    	:= aItens[nX][09]
	cUserInc		:= FWLeUserlg("cItemInc",1) // FWLeUserlg - 1 ou branco Usuario 2 Data 
	aItens[nX][09]	:= cUserInc
Next nX
*/

For nX := 1 to Len(aItens)
	cUserInc		:= (SUBSTR(EMBARALHA(aItens[nX][09],1),3,6))
	aItens[nX][09]	:= (aUser[aScan(aUser,{|x|x[2]==cUserInc})][3])
Next nX

Return lRetorno
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �ValidPerg � Autor � Rodrigo Sousa  		� Data � 15.08.12  ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Parametros da rotina.                					   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function ValidPerg()

Local aArea := GetArea()
Local aPerg := {}

cPerg := cPerg + Space(4)

Aadd(aPerg, {cPerg, "01", "Da Digita��o        	?", "MV_CH1" , 	"D", 08	, 0	, "G"	, "MV_PAR01", ""	,""				,""					,"","",""})
Aadd(aPerg, {cPerg, "02", "At� a Digita��o     	?", "MV_CH2" , 	"D", 08	, 0	, "G"	, "MV_PAR02", ""	,""				,""					,"","",""})
Aadd(aPerg, {cPerg, "03", "Tipo					?", "MV_CH3" , 	"N", 01	, 0	, "C"	, "MV_PAR03", ""	,"Sint�tico"	,"Anal�tico"		,"","",""})
Aadd(aPerg, {cPerg, "04", "Diret�rio   			?", "MV_CH4" , 	"C", 30	, 0	, "G"	, "MV_PAR04", "DIR"	,""				,""					,"","",""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 To Len(aPerg)
	IF  !DbSeek(aPerg[i,1]+aPerg[i,2])
		RecLock("SX1",.T.)
	Else
		RecLock("SX1",.F.)
	EndIF
	Replace X1_GRUPO   with aPerg[i,01]
	Replace X1_ORDEM   with aPerg[i,02]
	Replace X1_PERGUNT with aPerg[i,03]
	Replace X1_VARIAVL with aPerg[i,04]
	Replace X1_TIPO	   with aPerg[i,05]
	Replace X1_TAMANHO with aPerg[i,06]
	Replace X1_PRESEL  with aPerg[i,07]
	Replace X1_GSC	   with aPerg[i,08]
	Replace X1_VAR01   with aPerg[i,09]
	Replace X1_F3	   with aPerg[i,10]
	Replace X1_DEF01   with aPerg[i,11]
	Replace X1_DEF02   with aPerg[i,12]
	Replace X1_DEF03   with aPerg[i,13]
	Replace X1_DEF04   with aPerg[i,14]
	Replace X1_DEF05   with aPerg[i,15]
	MsUnlock()
Next i

RestArea(aArea)

Return(.T.)
