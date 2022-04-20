#include "rwmake.ch"
#include "topconn.ch"        
#include "tbiconn.ch"   
#include "protheus.ch"  
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GENC003   � Autor �Paulo Lopez         � Data �  11/09/09   ���
�������������������������������������������������������������������������͹��
���Descricao �FILTRO PARA CONSULTA PADRAO ( SXB ) EXIBIDAS PARA OS        ���
���          �VENDEDORES EXTERNOS DE MANEIRA QUE CADA UM VISUALIZE        ���
���          �APENAS INFORMACOES ( ORCAMENTOS, PEDIDOS, ETC ) DE          ���
���          �CLIENTES DEFINIDOS PARA SUA CARTEIRA DE ATENDIMENTO.        ���
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
User Function GENC003()                                                 

Local cFiltro  := "@#.T.@#"    
Local aArea    := GetArea()

// Or�amento de Vendas / Saidas
If Upper(Alltrim(FunName())) == "MATA415" 	//Criado filtro SA1SCJ e alterado campo

	If !cUserName  $ "Administrador#Ricardo.Barbosa#fatima.pap#Alessandra.Monea#Thiago.Monea#Robson.Moraes#Joelita.Silva#Luciana.Mota#Daiane.Gomes#Ellen.Ataide#Kely.Souza#Douglas.Moura#Eunice.Godoy#Tatiane.Paz#Marcia.Oliveira#Marina.Gama#Barbara.Reis#Cristiane.Eloy" // ! Vendedores externos 
		cFiltro := "@# A1_VEND $ '" + U_FATX008V() + "' @#"  
	EndIf          
	
EndIf                                                    

RestArea(aArea)

Return cFiltro  