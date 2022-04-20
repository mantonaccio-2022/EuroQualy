#include "totvs.ch"
#include "FwMvcDef.ch"
#include "tbiConn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EQCtrAExp �Autor  � Fabio Sousa        � Data �  02/03/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Programa de inclus�o de usuarios ao processo de workflow   ���
�������������������������������������������������������������������������͹��
���Documento � 												  			  ���
�������������������������������������������������������������������������͹��
���Uso       � Euroamerican...                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EQCtrAExp()

Private oBrowse := FwMBrowse():New()
oBrowse:SetAlias("Z14")
oBrowse:SetDescription("Controle de Acessos Expedi��o")
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
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EQCtrAExp'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EQCtrAExp'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EQCtrAExp'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EQCtrAExp'	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Copiar' 	ACTION 'VIEWDEF.EQCtrAExp'	OPERATION 9 ACCESS 0

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

Local oStruct := FwFormStruct(1,"Z14")
Local oModel

oModel	:= MpFormModel():New("PECTREXP"/*Ponto de Entrada*/,/*Pre-Validacao*/,/*P�s-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_ENCH_CTREXP",/*cOwner*/,oStruct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey( {"Z14_FILIAL","Z14_USERID","Z14_GRUPO"} )
oModel:SetDescription("Controle de Acesso Expedi��o")
oModel:GetModel("ID_ENCH_CTREXP"):SetDescription("Controle de Acesso Expedi��o")

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef  �Autor  �Rodrigo Sousa       � Data �  26/06/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     � ViewDef          										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oStruct 	:= FwFormStruct(2,"Z14")
Local oModel 	:= FwLoadModel("EQCtrAExp")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_CTREXP", oStruct, "ID_ENCH_CTREXP")
oView:CreateHorizontalBox("ID_HBOX", 100)
oView:SetOwnerView("ID_VIEW_CTREXP", "ID_HBOX")
oView:EnableTitleView("ID_VIEW_CTREXP")

Return(oView)