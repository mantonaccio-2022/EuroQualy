#include "totvs.ch"
#include "FwMvcDef.ch"
#include "tbiConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � EQREspWF �Autor  �Rodrigo Sousa       � Data �  26/06/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa de inclus�o do cadastro de Unidade Gerador	  	  ���
�������������������������������������������������������������������������͹��
���Documento � 												  			  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function EQREspWF()

Private oBrowse := FwMBrowse():New()
oBrowse:SetAlias("Z17")
oBrowse:SetDescription("Respons�veis Por Tarefa WF")
oBrowse:Activate()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  �Rodrigo Sousa       � Data �  26/06/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � MenuDef BeUnidGer										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EQREspWF'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EQREspWF'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EQREspWF'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EQREspWF'	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Copiar' 	ACTION 'VIEWDEF.EQREspWF'	OPERATION 9 ACCESS 0

Return(aMenu)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef �Autor  �Rodrigo Sousa       � Data �  26/06/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � ModelDef BeUnidGer										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()

Local oStruct := FwFormStruct(1,"Z17")
Local oModel

oModel	:= MpFormModel():New("PERESPWF"/*Ponto de Entrada*/,/*Pre-Validacao*/,/*P�s-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_ENCH_RESPWF",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey( {"Z17_FILIAL","Z17_PROC","Z17_STATUS","Z17_RESP"} )
oModel:SetDescription("Responsaveis Por Tarefa WF")
oModel:GetModel("ID_ENCH_RESPWF"):SetDescription("Responsaveis Por Tarefa WF")

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef  �Autor  �Rodrigo Sousa       � Data �  26/06/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � ViewDef BeUnidGer										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oStruct 	:= FwFormStruct(2,"Z17")
Local oModel 	:= FwLoadModel("EQREspWF")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_RESPWF", oStruct, "ID_ENCH_RESPWF")
oView:CreateHorizontalBox("ID_HBOX", 100)
oView:SetOwnerView("ID_VIEW_RESPWF", "ID_HBOX")
oView:EnableTitleView("ID_VIEW_RESPWF")

Return(oView)