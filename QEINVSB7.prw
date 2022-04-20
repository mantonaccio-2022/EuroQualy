#include "Colors.ch"
#include "Protheus.ch"
#include "RwMake.ch"
#Include "TOPCONN.CH" 
#Include "FWMVCDEF.CH"

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QEINVSB7  | Autor: |Fabio Carneiro | Data: | 02/10/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Importa e grava descrição do produtos tabela SB1          |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/
User Function QEINVSB7() 
                         
Local oDlg1

Private nRecs	    := 0
Private nLidos	    := 0
Private lAbre       := .F.
Private aPlanilha   := {}

Private _aCodSB1    := {}

Private mv_par01    := space(90) // diretório + arquivo a ser migrado

Private aCampos_    := {} // campos do cabecalho
Private lEnd        := .F.

Private lMsErroAuto := .F.

DEFINE FONT 	oBold NAME "Times New Roman"	SIZE 0,  20
DEFINE FONT 	oFnt  NAME "Arial"				SIZE 0, -14 BOLD	// "Times New Roman"

Define MsDialog oDlg1 From 000,000  TO 015,060 Title OemToAnsi("INVENTARIO ZERADO NA SB7") 
@ 003,005 TO 090,230

@ 001,002 Say OemToAnsi("Informe o Arquivo para importar .TXT|CSV")	Font oBold	Color CLR_HRED     

@ 035,015 Say OemToAnsi("Arquivo a ser Migrado:")				 			OF oDlg1 PIXEL	Color CLR_HBLUE     
@ 035,070 MsGet MV_PAR01 Picture "@s15"			OF oDlg1 PIXEL	Valid .t. F3 "DIR"
@ 090,140 Button OemToAnsi("_OK")	Size 40,15 Action (OkLeTxt(),oDlg1:End())
@ 090,190 Button OemToAnsi("_Sair   ")	Size 40,15 Action Close(oDlg1)
@ 090,002 Say OemToAnsi("DAVISO") Font oFnt	Color CLR_GRAY

Activate MSDialog oDlg1 Centered
Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OkLeTxt   | Autor: |Fabio Carneiro | Data: | 11/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Le o arquivo TXT                                          |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/

Static Function OkLeTxt()

LOCAL CULT	:= "000000"
local cnball	:= "00"

Private _nHdl    := fOpen(mv_par01,68) 

Private cEOL    := "CHR(13)+CHR(10)"
Private _nNum	:= 40
Private _nULT	:= 0
Private _cAtual	:= "N"
Private _nnBall	:= 0

//Close(oDlg1)

If Empty(cEOL)
     cEOL := CHR(13)+CHR(10)
Else
     cEOL := Trim(cEOL)
     cEOL := &cEOL
Endif

If _nHdl == -1
     MsgAlert("O arquivo de nome "+alltrim(mv_par01)+" nao pode ser aberto! Verifique os parametros.","Atencao!")
     Return
Endif

_nUlt := val(cult)

_nnball := val(cNBall )

Processa({|| RunCont() },"Processando...")

Return

Static Function RunCont

Local _cQuebral		:= chr(13)+chr(10)
Local _nTam			:= fseek(_nHdl,0,2)
Local _cTam			:= '/'+alltrim(str(_nTam))
Local _cHoraIni		:= time()
Local _lTemErro		:= .f.
Local _nBytesLidos	:= _RegLidos		:= 0
Local _cSaldoLinha	:= ""
Local _nTamBloco	:= 50000 // Largura a ser lida a cada acesso a disco
Local _nBytesTrat	:= 0
Local _cMen2		:= ""
Local _cSaldoLin	:= ""                        
local x := u := colini := tamcol := 0
Local ajj    := {}
local coluna := {}
LOCAL NRECX  := 0     

_cQuebral		:=chr(13)+chr(10)
_nTam			:=fseek(_nHdl,0,2)
_cTam			:='/'+alltrim(str(_nTam))
_cHoraIni		:=time()
_lTemErro		:=.f.
_nBytesLidos	:=_nRegLidos:=0
_cSaldoLinha	:=""
_nTamBloco		:=50000 // Largura a ser lida a cada acesso a disco
_nTamBloco		:=max(_nTamBloco,len(_cQuebral)+1)
_nTamBloco		:=min(_nTamBloco,64000)
fseek(_nHdl,0,0) // Posiciona o ponteiro no inicio do arquivo
_nBytesTrat		:=0
_cMen2			:=""
_cSaldoLin		:=""   

PROCREGUA(0)

do while _nBytesLidos<_nTam

	IncProc("Aguarde...")
	
    _cLinha:=""
    do while .t. // Le ate encontrar no minimo uma quebra de linha ou o final do arquivo
       _cLido:=space(_nTamBloco)
       _nBytesAgora:=FREAD(_nHdl,@_cLido,_nTamBloco)
       _cLinha+=_cLido
       _nBytesLidos+=_nBytesAgora
       if _nBytesLidos>=_nTam.or.at(_cQuebral,_cLinha)>0.or.len(_cLinha)>64000
          exit
       endif
    enddo

    _cRegistro:=""
    _cLinha:=_cSaldoLin+_cLinha
    _cSaldoLin:=""
    do while len(_cLinha)>0
       _nPosic:=at(_cQuebral,_cLinha)
       if _nPosic>0.or._nBytesLidos==_nTam
          _jjlin := left(_clinha,_nPosic-1) +";"
          _cRegistro:=left(_cLinha,_nPosic+len(_cQuebral)-1)
          _cLinha:=substr(_cLinha,_nPosic+len(_cQuebral))
	     tamcol := 0
	     colini := 0
	     coluna := {}              

	     aJJ	:= {}
	     

	     	     For x := 1 to Len(_jjLin) // tentando
	          If Substr(_jjlin,x,1) == ";"
	               aAdd(coluna,{colini+1,tamcol})
	               colini := x
	               tamcol := 0
	          ElSe
	               tamcol ++
	          EndIf
	     Next
	            

	     //tamcol := tamcol
	     aadd( aJJ , Array(len(coluna)) )
	     
	     for u = 1 to len(coluna)
	     	ajj[len(ajj)][u] := substr(_jjlin,coluna[u][1],coluna[u][2])
	     next        
	                 
	     nRecx ++       
	     
	     if nRecx == 1 // guarda o cabecalho para tentar entrar com o nome do campo
	     	acampos_ := ajj
	     end

	     
	     if nRecx > 1 // despreza 1 registro

	            SFSB7(Ajj)

	     EndIf
	       
          _nRegLidos++
          _nBytesTrat+=len(_cRegistro)
       else
          _cSaldoLin:=_cLinha
          _cLinha:=""
       endif         
    enddo   
enddo           

Aviso("Atenção !!!" ,"Registros Lidos ..: "+ Str(nLidos) +" Gravados ..: "+ Str(nRecs),{"OK"})

Processa({|| QESB101ok("Gerando relatório...")})
	
fclose(_nHdl)                          

Return                   
                                               
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | SFSB7     | Autor: |Fabio Carneiro | Data: | 11/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Grava linha por linha do arquivo após delimitador (;)     |
+------------+-----------------------------------------------------------+
| Uso:       | QUALY / EURO                                              |
+------------+-----------------------------------------------------------+
*/

Static Function SFSB7(ALINHA)

Local _lPassa1    := .T.
Local _lCtrlEnd   := .F.
Local _lCtrlLote  := .F.

// Variaveis do Produto 

Local _B7_FILIAL  := ""
Local _B7_COD     := "" 
Local _B7_LOCAL   := "" 
Local _B7_TIPO    := "" 
Local _B7_DOC     := "" 
Local _B7_LOTECTL := ""
Local _B7_LOCALIZ := ""
Local _B7_MUMDOC  := ""
Local _B7_QUANT   := 0 
Local _B1_TIPCONV := ""
Local _B1_cONV    := 0
Local _B7_DTVALID :=CTOD(" ")
Local _cErro:=" "
 
// Leitura da Linha para Gravar o Codigo na base de dados

_B7_FILIAL  := AllTrim(StrTran(Alinha[1][01],";",""))
_B7_COD     := AllTrim(StrTran(Alinha[1][02],";","")) 
_B7_LOCAL   := AllTrim(StrTran(Alinha[1][03],";","")) 
_B7_TIPO    := AllTrim(StrTran(Alinha[1][04],";","")) 
_B7_DOC     := AllTrim(StrTran(Alinha[1][05],";","")) 
_B7_LOTECTL := AllTrim(StrTran(Alinha[1][06],";",""))
_B7_LOCALIZ := AllTrim(StrTran(Alinha[1][07],";",""))
_B7_MUMDOC  := AllTrim(StrTran(Alinha[1][08],";",""))
_B7_QUANT   := Val(StrTran(StrTran(Alinha[1][09],";",""),",", ".")) 

nLidos++

If AllTrim(Posicione("SB1",1, xFilial("SB1")+_B7_COD,"B1_COD")) == AllTrim(_B7_COD)
 	_lPassa1 := .T.
Else 
  	_lPassa1 := .F.
    _cErro:="Produto Nao Encontrado"  
EndIf 

If AllTrim(Posicione("SB1",1, xFilial("SB1")+_B7_COD,"B1_LOCALIZ")) == 'S'

	If AllTrim(Posicione("SBE",1, xFilial("SBE")+_B7_LOCAL+_B7_LOCALIZ+"      ","BE_LOCALIZ")) == AllTrim(_B7_LOCALIZ)
		lPassa1   := .T.
		_lCtrlEnd := .T.
	Else 
		_lPassa1  := .F.
        _cErro:="Endereco nao Encontrado"
	EndIf 

EndIf 

If AllTrim(Posicione("SB1",1, xFilial("SB1")+_B7_COD,"B1_RASTRO")) == 'L'
	_lCtrlLote := .T.
EndIf 

_B1_TIPCONV := Posicione("SB1",1, xFilial("SB1")+_B7_COD,"B1_TIPCONV")
_B1_CONV    := Posicione("SB1",1, xFilial("SB1")+_B7_COD,"B1_CONV")

If _lPassa1  

	DbSelectArea("SB7")
	DbSetOrder(3) // B7_FILIAL+B7_DOC+B7_COD+B7_LOCAL
	DbSeek(xFilial("SB7")+_B7_DOC+_B7_COD+_B7_LOCAL)
		
    If _lCtrlLote   
        If SELECT("XSB8") > 0
            XSB8->(dbCloseArea())
       End     
       cQuery := "SELECT B8_PRODUTO,B8_LOCAL,B8_LOTECTL,B8_DTVALID FROM " + RetSqlName("SB8") 
       cQuery += " WHERE B8_FILIAL = '" + xFilial("SB8") + "' "
       cQuery += " AND B8_PRODUTO = '" +_B7_COD + "' "
       cQuery += " AND B8_LOCAL = '" +_B7_LOCAL + "' "
       cQuery += " AND B8_LOTECTL = '" +_B7_LOTECTL + "' "
       cQuery += " AND D_E_L_E_T_ = ' ' "
       TCQuery cQuery New Alias "XSB8"
       If XSB8->(!EOF()) .or. XSB8->(!BOF())
          _B7_DTVALID :=STOD(XSB8->B8_DTVALID)
          XSB8->(dbCloseArea())
       Else
         _B7_DTVALID:= CTOD(" ")      
         _cErro:="Data Validade Lote em Branco"
       End     
    End

	RecLock("SB7",.T.)

		SB7->B7_FILIAL  := _B7_FILIAL
		SB7->B7_COD     := _B7_COD 
		SB7->B7_LOCAL   := _B7_LOCAL 
		SB7->B7_TIPO    := _B7_TIPO
		SB7->B7_DOC     := _B7_DOC 
		SB7->B7_QUANT   := _B7_QUANT
		If _B1_TIPCONV=="M"
			SB7->B7_QTSEGUM := (_B7_QUANT*_B1_CONV)
		ElseIf _B1_TIPCONV=="D"  	 
			SB7->B7_QTSEGUM := (_B7_QUANT/_B1_CONV)
		EndIf
		SB7->B7_DATA    := CTOD("07/12/2021")
	
    	If 	_lCtrlLote 
			SB7->B7_LOTECTL := _B7_LOTECTL
            SB7->B7_DTVALID := _B7_DTVALID
            SB7->B7_NUMDOC  := _B7_LOTECTL
    	Else 
			SB7->B7_NUMDOC  := _B7_DOC
	    EndIf
	
    	IF _lCtrlEnd 
			SB7->B7_LOCALIZ := _B7_LOCALIZ
		EndIf 		 
	
    	SB7->B7_CONTAGE := "097"
		SB7->B7_STATUS  := "1"
		SB7->B7_ORIGEM  := "MATA270"

    SB7->(MsUnlock())
		
	aAdd(aPlanilha,{"REGISTRO INCLUIDO",;
				AllTrim(_B7_COD),;
  			    AllTrim(_B7_LOCALIZ),;
   				AllTrim(_B7_LOCAL),;
				AllTrim(_B7_LOTECTL),;
				AllTrim(_cErro)})

	nRecs++	
	
Else 

	aAdd(aPlanilha,{"REGISTRO NAO INCLUIDO",;
				AllTrim(_B7_COD),;
  			    AllTrim(_B7_LOCALIZ),;
   				AllTrim(_B7_LOCAL),;
				AllTrim(_B7_LOTECTL),;
				AllTrim(_cErro)})


EndIf 
_cErro:=""
SB7->(dbCloseArea())

Return
/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | QESB101oK | Autor: | QUALY         | Data: | 29/07/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - QESB101ok                                    |
+------------+-----------------------------------------------------------+
*/
Static Function QESB101ok()

	Local cArqDst     := "C:\TOTVS\QESB7001_EMP_" + SM0->M0_CODIGO + "_" + Dtos(dDataBase) + StrTran(Time(),":","") + ".XML"
	Local oExcel      := FWMsExcelEX():New()
		
	Local nPlan       := 0
	
	Local cNomPla     := "Empresa_1" + Rtrim(SM0->M0_NOME)
	Local cTitPla     := "Relatorio conferencia de carga de dados "
	Local cNomWrk     := "Empresa_1" + Rtrim(SM0->M0_NOME)
		
	MakeDir("C:\TOTVS")

	oExcel:AddworkSheet(cNomWrk)
	oExcel:AddTable(cNomPla, cTitPla)
	oExcel:AddColumn(cNomPla, cTitPla, "Status do registro"    , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Codigo Produto"    , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Endereço"        , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Armazem"        , 1, 1, .F.)     //01
	oExcel:AddColumn(cNomPla, cTitPla, "Lote"     , 1, 1, .F.)     //02
	oExcel:AddColumn(cNomPla, cTitPla, "Motivo"     , 1, 1, .F.)     //02
		
	// preenche as informações na planilha de acordo com o Array aPlanilha 
	For nPlan:=1 To Len(aPlanilha)
		
		lAbre := .T.

		oExcel:AddRow(cNomPla,cTitPla,{aPlanilha[nPlan][01],;
									   aPlanilha[nPlan][02],;
									   aPlanilha[nPlan][03],;
									   aPlanilha[nPlan][04],;
									   aPlanilha[nPlan][05],; 
									   aPlanilha[nPlan][06]}) 
    Next nPlan
	
	
If lAbre
	oExcel:Activate()
	oExcel:GetXMLFile(cArqDst)
	OPENXML(cArqDst)
	oExcel:DeActivate()
Else
		MsgInfo("Não existe dados para serem impressos.", "SEM DADOS")
EndIf

Return

/*
+------------+-----------+--------+---------------+-------+--------------+
| Programa:  | OPENXML   | Autor: | QUALY         | Data: | 13/02/21     |
+------------+-----------+--------+---------------+-------+--------------+
| Descrição: | Manutenção - OPENXML                                      |
+------------+-----------------------------------------------------------+
*/

Static Function OPENXML(cArq)

	Local cDirDocs := MsDocPath()
	Local cPath	   := AllTrim(GetTempPath())

	If !ApOleClient("MsExcel")
		Aviso("Atencao", "O Microsoft Excel nao esta instalado.", {"Ok"}, 2)
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cArq)
		oExcelApp:SetVisible(.T.)
		oExcelApp:Destroy()
	EndIf

Return





