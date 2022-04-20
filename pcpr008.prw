#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "rwmake.ch"

#define ENTER chr(13) + chr(10)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCPR008  � Autor �Tiago O. Beraldi    � Data �  16/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �EMISSAO DE ETIQUETAS PARA SEPARACAO ALMOXARIFADO            ���
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
User Function PCPR008()

//��������������������������������������������������������������Ŀ
//� Declaracao de variaveis                                      �
//����������������������������������������������������������������
Private titulo  := "Etiquetas de OP's"
Private cDesc1  := "Este programa ir� emitir as Etiquetas de identifica��o de MP's"
Private cDesc2  := "da OP conforme parametros especificados."
Private cDesc3  := ""
Private cString := "SC2"
Private aReturn := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PCPR008"
Private nLastKey:= 0
Private Lin     := 1
Private Tamanho := "P"
Private NomeProg:= "PCPCR008"
Private wnrel   :="PCPR008"

//���������������������������������������������Ŀ
//� Variaveis utilizadas para parametros        �
//� mv_par01            // Da OP                �
//� mv_par02            // Ate OP               �
//�����������������������������������������������
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//fCriaSX1(cPerg)
Pergunte(cPerg, .F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT.                       �
//����������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,"P")

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

RptStatus({|| RptDetail()})

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RPTDETAIL � Autor �Tiago O. Beraldi    � Data �  16/03/08   ���
�������������������������������������������������������������������������͹��
���Descricao �PROCESSA IMPRESSAO                                          ���
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
Static Function RptDetail()

Local cQry
Local cOp, cCod1, cCod2, nQuant1, nQuant2

//��������������������������������������������������������������Ŀ
//� Query                                                        �
//����������������������������������������������������������������
cQry := " SELECT (SUBSTRING(D4_OP, 1, 6) + '.' + SUBSTRING(D4_OP, 7, 2) + '.' + SUBSTRING(D4_OP, 9, 3)) ORDEM, " + ENTER
cQry += "        D4_COD PRODUTO, " + ENTER
cQry += "        D4_TRT SEQUEN, " + ENTER
cQry += "        SUM(D4_QUANT) QUANT " + ENTER
cQry += " FROM " + RetSqlName("SD4") + ENTER
cQry += " WHERE D_E_L_E_T_ = '' " + ENTER
cQry += "       AND D4_FILIAL = '" + xFilial("SD4") + "' "	 + ENTER
cQry += "           AND D4_OP BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' " + ENTER
//cQry += "           AND SUBSTRING(D4_OP, 7, 2) = '01' " + ENTER		Alterado 30/05/2016
cQry += "           AND ( SELECT B1_TIPO FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.D_E_L_E_T_ = '' AND B1_COD = D4_COD ) IN ('MP','PI','PP') " + ENTER	//Alterado 30/05/2016
cQry += "           AND D4_COD != '" + mv_par03 + "' " + ENTER
cQry += "           AND SUBSTRING(D4_COD, 1, 2) != 'ME' " + ENTER
cQry += " GROUP BY D4_OP, D4_TRT, D4_COD, D4_TRT " + ENTER
cQry += " ORDER BY D4_OP, D4_TRT, D4_COD " + ENTER

MemoWrite("pcpr008.sql", cQry)

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQUERY cQry NEW ALIAS QRY

//��������������������������������������������������������������Ŀ
//� Impressao                                                    �
//����������������������������������������������������������������
dbSelectArea("QRY")
dbGoTop()

cOP := QRY->ORDEM

@000,000 PSAY Chr(15)                        // Compressao de Impressao

While !EOF("QRY")

	If nLastKey == 286 .or. nLastKey == 27
		@Prow()+1,001 PSAY "CANCELADO PELO OPERADOR"
		Exit
	EndIf

  	cOP := QRY->ORDEM

	cCod1   := AllTrim(QRY->PRODUTO)
	nQuant1 := QRY->QUANT

	dbSkip()

	If QRY->ORDEM == cOp

		cCod2   := AllTrim(QRY->PRODUTO)
		nQuant2 := QRY->QUANT

		dbSkip()

	Else

		cCod2   := "---------------"
		nQuant2 := 0

	Endif

	@ Lin,03 PSAY "NUM. DA OP.....: " + cOP
	@ Lin,50 PSAY "NUM. DA OP.....: " + cOP
    Lin+=1
	@ Lin,03 PSAY "PRODUTO..........: " + cCod1
	@ Lin,50 PSAY "PRODUTO..........: " + cCod2
	Lin+=1
	@ Lin,03 PSAY "QUANTIDADE.....: " + Transform(nQuant1,"@E 99,999.99") + " " + Posicione("SB1",1,xFilial("SB1") + cCod1, "B1_UM")
	@ Lin,50 PSAY "QUANTIDADE.....: " + Transform(nQuant2,"@E 99,999.99") + " " + Posicione("SB1",1,xFilial("SB1") + cCod2, "B1_UM")

  	Lin := Lin + 4

Enddo

@ Lin, 000 PSAY chr(18)                                //Descompressao de Impressao

//������������������������������������������������������������������Ŀ
//� Se impressao em Disco, chama Spool.                              �
//��������������������������������������������������������������������
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	ourspool(wnrel)
Endif

//������������������������������������������������������������������Ŀ
//� Libera relatorio para Spool da Rede.                             �
//��������������������������������������������������������������������
QRY->(dbCloseArea())
MS_FLUSH()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FCRIASX1  � Autor �Tiago O Beraldi     � Data �  06/08/08   ���
�������������������������������������������������������������������������͹��
���Descricao �GERA DICIONARIO DE PERGUNTAS                                ���
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
Static Function fCriaSX1(cPerg)

//���������������������������������������������������������������������Ŀ
//|Declaracao de variaveis                                              �
//�����������������������������������������������������������������������
Local cKey := ""
Local aHelpEng := {}
Local aHelpPor := {}
Local aHelpSpa := {}

PutSX1(cPerg,"01","O.P. De       ?","","","mv_ch1","C",13,0,0,"G","" ,"SC2","","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"02","O.P. At�      ?","","","mv_ch2","C",13,0,0,"G","" ,"SC2","","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","")
PutSX1(cPerg,"03","Produto       ?","","","mv_ch3","C",24,0,0,"G","" ,""   ,"","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","")

cKey     := "P." + cPerg + "01."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a O.P. inicial.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "02."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe a O.P. final.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

cKey     := "P." + cPerg + "03."
aHelpEng := {}
aHelpPor := {}
aHelpSpa := {}
aAdd(aHelpEng,"")
aAdd(aHelpEng,"")
aAdd(aHelpPor,"Informe Mat�ria Prima a n�o ser Impressa.")
aAdd(aHelpPor,"")
aAdd(aHelpSpa,"")
aAdd(aHelpSpa,"")
PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

Return Nil