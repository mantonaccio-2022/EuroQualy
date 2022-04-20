#include "totvs.ch"
#include "FwMvcDef.ch"
#include "tbiConn.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �  �Autor  �       � Data �                                  ���
�������������������������������������������������������������������������͹��
���Desc.     �  	  	  	                                              ���
���     	 �                                                            ���
�������������������������������������������������������������������������͹��
���Documento � 												  			  ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function EqGrpDre()

Private oBrowse := FwMBrowse():New()
oBrowse:SetAlias("SZH")
oBrowse:SetDescription("Cadastro Grupos DRE")
oBrowse:Activate()

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � MenuDef 										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aMenu := {}

ADD OPTION aMenu TITLE 'Pesquisar' 	ACTION 'PesqBrw'			OPERATION 1 ACCESS 0
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EqGrpDre'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EqGrpDre'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EqGrpDre'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EqGrpDre'	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Copiar' 	ACTION 'VIEWDEF.EqGrpDre'	OPERATION 9 ACCESS 0

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

Local oStruct1 := FwFormStruct(1,"SZH")
Local oModel

oModel := MpFormModel():New("PEGrpDre",/*Pre-Validacao*/, {|| .T.},/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_MODEL_ENCH_GRPDRE",/*cOwner*/,oStruct1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"ZH_FILIAL","ZH_CODIGO"})
oModel:SetDescription("Cadastro Grupo DRE")
oModel:GetModel("ID_MODEL_ENCH_GRPDRE"):SetDescription("Cadastro Grupo DRE")

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef  �Autor  �                    � Data �             ���
�������������������������������������������������������������������������͹��
���Desc.     � ViewDef          										  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef()

Local oStruct1 	:= FwFormStruct(2,"SZH")
Local oModel 	:= FwLoadModel("EQGrpDre")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_ENCH_GRPDRE",oStruct1,"ID_MODEL_ENCH_GRPDRE")

//���������������������������������������������Ŀ
//� Habilita Titulo da View 					�
//�����������������������������������������������
oView:EnableTitleView('ID_VIEW_ENCH_GRPDRE','Grupo Cont�bil')

Return(oView)