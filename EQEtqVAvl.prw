#include "rwmake.ch"
#include "protheus.ch"

#define XNCLIFOR	1
#define XEND		2
#define XCEP		3
#define XBAIRRO		4
#define XMUN		5
#define XEST		6
#define XNTRANSP	7

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ACDE013E  � Autor � Totvs                 � Data �11/08/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de impressao de etiqueta de Volume de Nota Fiscal ���
���          �especifico para a Beraca	                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAACD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EQEtqVAvl()
Local cPerg := If(IsTelNet(),'VTPERGUNTE','PERGUNTE')

//AjustaSX1()

//CBChkTemplate()
IF ! &(cPerg)("EQACD1",.T.)
	Return
EndIF
If IsTelNet()
	VtMsg("IMPRIMINDO") //'Imprimindo'
	EQImpEtq(MV_PAR01)
Else
	Processa({|| EQImpEtq(MV_PAR01)})
EndIf

Return
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
//Funcao de impressao de etiqueta de Volume.//////////
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////


Static Function EQImpEtq(cOrdSep)

Local nVolumes := 0
Local sConteudo
Local cDescVol	:= ""
Local lUsaFor	:= .F.
Local lRedesp	:= .F.
Local aEndRem	:= Array(7)
Local nX		:= 0

//���������������������������������������������������������������������Ŀ
//� Posiciona na Nota Fiscal de Saida - SF2                             �
//�����������������������������������������������������������������������
dbSelectArea("CB7")
dbSetOrder(1)
If dbSeek(xFilial("CB7")+cOrdSep)

	If CB7->CB7_ORIGEM == "2"
		
		DbSelectArea("SF2")
		DbSetOrder(1)
		If DbSeek(xFilial("SF2")+CB7->CB7_NOTA+CB7->CB7_SERIE)
			
			dbSelectArea("SC5")
			dbOrderNickName("EQSC5NF")
			dbSeek(xFilial("SC5")+CB7->CB7_NOTA+CB7->CB7_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	
			//���������������������������������������������������������������������Ŀ
			//� Posiciona no Cadastro de Clientes ou Fornecedores					�
			//�����������������������������������������������������������������������
			If !SF2->F2_TIPO $ "D|B"
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		
				aEndRem[XNCLIFOR] := Alltrim(SA1->A1_NOME)
		
			Else
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA)
		
				aEndRem[XNCLIFOR] := Alltrim(SA2->A2_NOME)
				lUsaFor	:= .T.
			EndIf

			If MV_PAR02 > 0
				nVolumes := MV_PAR02 
			Else
				nVolumes := Iif(SF2->F2_VOLUME1 > 0,SF2->F2_VOLUME1 +;
													SF2->F2_VOLUME2 +;
													SF2->F2_VOLUME3 +;
													SF2->F2_VOLUME4 +;
													SF2->F2_VOLUME5, 1)		
			EndIf                    
		
		EndIf			

	ElseIf CB7->CB7_ORIGEM == "1"

		dbSelectArea("SC5")
		dbSetOrder(1)
		dbSeek(xFilial("SC5")+CB7->CB7_PEDIDO)

		//���������������������������������������������������������������������Ŀ
		//� Posiciona no Cadastro de Clientes ou Fornecedores					�
		//�����������������������������������������������������������������������
		If !SC5->C5_TIPO $ "D|B"
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	
			aEndRem[XNCLIFOR] := Alltrim(SA1->A1_NOME)
	
		Else
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	
			aEndRem[XNCLIFOR] := Alltrim(SA2->A2_NOME)
			lUsaFor	:= .T.
		EndIf

		If MV_PAR02 > 0
			nVolumes := MV_PAR02 
		Else

			nVolumes := Iif(SC5->C5_VOLUME1 > 0,SC5->C5_VOLUME1 + ;
												SC5->C5_VOLUME2 + ;
												SC5->C5_VOLUME3 + ;
												SC5->C5_VOLUME4 + ;
												SC5->C5_VOLUME5, 1)		
		EndIf                    
                                
	EndIf

	cDescVol	:= "" //SF2->F2_ESPECI1

	//���������������������������������������������������������������������Ŀ
	//� Carrega Informa��es da Remessa - aEndRem							�
	//�����������������������������������������������������������������������
	dbSelectArea("SA4")
	dbSetOrder(1)
	dbSeek(xFilial("SA4")+SC5->C5_TRANSP)
	
	If !lUsaFor
				
		If !Empty(SC5->C5_CLIENT+SC5->C5_LOJAENT)
		
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT)
					
			aEndRem[XEND] 		:= Alltrim(SA1->A1_END)
			aEndRem[XCEP] 		:= Transform(SA1->A1_CEP,PesqPict("SA1","A1_CEP"))
			aEndRem[XBAIRRO] 	:= Alltrim(SA1->A1_BAIRRO)
			aEndRem[XMUN] 		:= Alltrim(SA1->A1_MUN)
			aEndRem[XEST] 		:= Alltrim(SA1->A1_EST)

		Else
			aEndRem[XEND] 		:= Alltrim(SA1->A1_END)
			aEndRem[XCEP] 		:= Transform(SA1->A1_CEP,PesqPict("SA1","A1_CEP"))
			aEndRem[XBAIRRO] 	:= Alltrim(SA1->A1_BAIRRO)
			aEndRem[XMUN] 		:= Alltrim(SA1->A1_MUN)
			aEndRem[XEST] 		:= Alltrim(SA1->A1_EST)
   		EndIf

		aEndRem[XNTRANSP] 	:= Iif(SA4->(Found()), Alltrim(SA4->A4_NREDUZ),"")

	Else

		aEndRem[XEND] 		:= Alltrim(SA2->A2_END)
		aEndRem[XCEP] 		:= Transform(SA2->A2_CEP,PesqPict("SA2","A2_CEP"))
		aEndRem[XBAIRRO] 	:= Alltrim(SA2->A2_BAIRRO)
		aEndRem[XMUN] 		:= Alltrim(SA2->A2_MUN)
		aEndRem[XEST] 		:= Alltrim(SA2->A2_EST)
		aEndRem[XNTRANSP] 	:= iIF(SA4->(Found()),Alltrim(SA4->A4_NREDUZ),"")

	EndIf	

	If ! CB5SetImp(Alltrim(GetMV("MV_IACD01")))
		Return .F.
	EndIf
	
	For nX := 1 To nVolumes

		//���������������������������������������������������������������������Ŀ
		//� Inicia Impress�o													�
		//�����������������������������������������������������������������������
		MSCBBEGIN(1,4)

		If CB7->CB7_ORIGEM == "1"
			MSCBSAY(005,003,"PEDIDO "+SC5->C5_NUM,"N","0","110,080")
			MSCBSAY(005,018,"O.S. "+CB7->CB7_ORDSEP,"N","0","110,080")
			MSCBSAY(005,032,Alltrim(aEndRem[XNCLIFOR]),"N","0","030,030")
		
		Else
			MSCBSAY(005,005,"NF "+CB7->CB7_NOTA+"-"+Alltrim(CB7->CB7_SERIE),"N","0","110,080")
			MSCBSAY(005,025,Alltrim(aEndRem[XNCLIFOR]),"N","0","030,030")
        EndIf
		/*
		MSCBSAY(005,005,"NF :. "+cNota+" "+cSerie,"N","0","032,032")
		MSCBSAY(005,010,Alltrim(aEndRem[XNCLIFOR]),"N","0","025,025")

		MSCBSAY(005,015,"TRANSP :. "+Alltrim(aEndRem[XNTRANSP]),"N","0","022,022")
		MSCBSAY(005,018,"END :. " + Alltrim(aEndRem[XEND])+" - "+Alltrim(aEndRem[XCEP]),"N","0","022,022")
		MSCBSAY(005,021,Alltrim(aEndRem[XBAIRRO])+" - "+Alltrim(aEndRem[XMUN])+" - "+Alltrim(aEndRem[XEST]),"N","0","022,022")
		MSCBSAY(005,024,"CEP :. "+Alltrim(aEndRem[XCEP]),"N","0","022,022")
		MSCBSAY(005,027,"PEDIDO :. "+ SC5->C5_NUM,"N","0","022,022")

		If MV_PAR04 == 0
			MSCBSAY(005,030,StrZero(nX,3)+" de "+StrZero(nVolumes,3) ,"N","0","022,022")
		Endif
        */
		MSCBInfoEti("Vol.Avl.Exp","80x35")
		
		sConteudo:= MSCBEND()
	Next nX

	MSCBCLOSEPRINTER()
	
Else
	Aviso('EQETQVAVL','Ordem de Separa��o n�o existe',{'OK'})
EndIf


Return .T.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1 �Autor  �                    �Data  �             ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para incluir os grupos de perguntas OMSC01           ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function AjustaSX1()
Local aHelp	   := {}
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

/*
AAdd(aHelp,{{"Informe o Local de Impressao"   ,""},{"",""},{""}})
AAdd(aHelp,{{"Informe o Numero da Nota Fiscal",""},{"",""},{""}})
AAdd(aHelp,{{"Informe o Serie da Nota Fiscal" ,""},{"",""},{""}})
AAdd(aHelp,{{"Indica se sera impresso algum volume especifico"   ,""},{"",""},{""}})

PutSx1('ACDE013E' ,'01' ,'Local de Impressao?' ,'Local de Impressao?' ,'Local de impressao?' ,'mv_ch1' ,'C' ,6 ,0 ,0 ,'G' ,'' ,'CB5' ,'' ,'' ,'mv_par01' ,'Sim'       ,'Si'        ,'Yes'        ,'' ,'Nao'           ,'No'        ,'No'       ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,aHelp[1][1]  ,aHelp[1][2]  ,aHelp[1][3])
PutSx1('ACDE013E' ,'02' ,'Nota Fiscal       ?' ,'Nota Fiscal     ?'   ,'Nota Fiscal       ?' ,'mv_ch2' ,'C' ,9 ,0 ,0 ,'G' ,'' ,'SF2' ,'' ,'' ,'mv_par02' ,'Sim'       ,'Si'        ,'Yes'        ,'' ,'Nao'           ,'No'        ,'No'       ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,aHelp[2][1]  ,aHelp[2][2]  ,aHelp[2][3])
PutSx1('ACDE013E' ,'03' ,'Serie             ?' ,'Serie           ?'   ,'Serie             ?' ,'mv_ch3' ,'C' ,3 ,0 ,0 ,'G' ,'' ,'   ' ,'' ,'' ,'mv_par03' ,'Sim'       ,'Si'        ,'Yes'        ,'' ,'Nao'           ,'No'        ,'No'       ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,aHelp[3][1]  ,aHelp[3][2]  ,aHelp[3][3])
PutSx1('ACDE013E' ,'04' ,'Volume Especifico ?' ,'Volume Especifico?'  ,'Volume Especifico ?' ,'mv_ch4' ,'N' ,3 ,0 ,0 ,'G' ,'' ,'   ' ,'' ,'' ,'mv_par04' ,'Sim'       ,'Si'        ,'Yes'        ,'' ,'Nao'           ,'No'        ,'No'       ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,aHelp[4][1]  ,aHelp[4][2]  ,aHelp[4][3])
*/
AAdd(aHelp,{{"Informe a Ordem de Separa��o",""},{"",""},{""}})
AAdd(aHelp,{{"Indica se sera impresso algum volume especifico"   ,""},{"",""},{""}})

PutSx1('EQACD1' ,'01' ,'Ord. Separa��o?' ,'Ord. Separa��o?'   ,'Ord. Separa��o?' ,'mv_ch1' ,'C' ,6 ,0 ,0 ,'G' ,'' ,'CB7' ,'' ,'' ,'mv_par01' ,'Sim'       ,'Si'        ,'Yes'        ,'' ,'Nao'           ,'No'        ,'No'       ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,aHelp[2][1]  ,aHelp[2][2]  ,aHelp[2][3])
PutSx1('EQACD1' ,'02' ,'Volume Especifico ?' ,'Volume Especifico?'  ,'Volume Especifico ?' ,'mv_ch2' ,'N' ,3 ,0 ,0 ,'G' ,'' ,'   ' ,'' ,'' ,'mv_par02' ,'Sim'       ,'Si'        ,'Yes'        ,'' ,'Nao'           ,'No'        ,'No'       ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,'' ,aHelp[4][1]  ,aHelp[4][2]  ,aHelp[4][3])


Return
