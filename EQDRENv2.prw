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
User Function EqDreNv2()

Private oBrowse := FwMBrowse():New()
oBrowse:SetAlias("SZI")
oBrowse:SetDescription("Cadastro DRE Nivel 2")
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
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EqDreNv2'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EqDreNv2'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EqDreNv2'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EqDreNv2'	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Copiar' 	ACTION 'VIEWDEF.EqDreNv2'	OPERATION 9 ACCESS 0

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

Local oStruct1 := FwFormStruct(1,"SZI")
Local oModel

oModel := MpFormModel():New("PEDreNv2",/*Pre-Validacao*/, {|| .T.},/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_MODEL_ENCH_DRENV2",/*cOwner*/,oStruct1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"ZI_FILIAL","ZI_CODIGO"})
oModel:SetDescription("Cadastro DRE Nivel 2")
oModel:GetModel("ID_MODEL_ENCH_DRENV2"):SetDescription("Cadastro DRE Nivel 2")

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

Local oStruct1 	:= FwFormStruct(2,"SZI")
Local oModel 	:= FwLoadModel("EQDreNv2")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_ENCH_DRENV2",oStruct1,"ID_MODEL_ENCH_DRENV2")

//���������������������������������������������Ŀ
//� Habilita Titulo da View 					�
//�����������������������������������������������
oView:EnableTitleView('ID_VIEW_ENCH_DRENV2','DRE Nivel 2')

Return(oView)
