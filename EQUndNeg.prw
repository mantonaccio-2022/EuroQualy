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
User Function EqUndNeg()

Private oBrowse := FwMBrowse():New()
oBrowse:SetAlias("SZK")
oBrowse:SetDescription("Cadastro Unidade de Neg�cios")
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
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EqUndNeg'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EqUndNeg'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EqUndNeg'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EqUndNeg'	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Copiar' 	ACTION 'VIEWDEF.EqUndNeg'	OPERATION 9 ACCESS 0

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

Local oStruct1 := FwFormStruct(1,"SZK")
Local oModel

oModel := MpFormModel():New("PEUndNeg",/*Pre-Validacao*/, {|| .T.},/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_MODEL_ENCH_UNDNEG",/*cOwner*/,oStruct1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"ZK_FILIAL","ZK_CODIGO"})
oModel:SetDescription("Cadastro Unidade de Negocios")
oModel:GetModel("ID_MODEL_ENCH_UNDNEG"):SetDescription("Cadastro Unidade de Negocios")

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

Local oStruct1 	:= FwFormStruct(2,"SZK")
Local oModel 	:= FwLoadModel("EQUndNeg")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_ENCH_UNDNEG",oStruct1,"ID_MODEL_ENCH_UNDNEG")

//���������������������������������������������Ŀ
//� Habilita Titulo da View 					�
//�����������������������������������������������
oView:EnableTitleView('ID_VIEW_ENCH_UNDNEG','Unidade de Negocios')

Return(oView)