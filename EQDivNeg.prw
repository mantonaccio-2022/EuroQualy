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
User Function EqDivNeg()

Private oBrowse := FwMBrowse():New()
oBrowse:SetAlias("SZJ")
oBrowse:SetDescription("Cadastro Divis�o de Neg�cios")
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
ADD OPTION aMenu TITLE 'Visualizar' ACTION 'VIEWDEF.EqDivNeg'	OPERATION 2 ACCESS 0
ADD OPTION aMenu TITLE 'Incluir' 	ACTION 'VIEWDEF.EqDivNeg'	OPERATION 3 ACCESS 0
ADD OPTION aMenu TITLE 'Alterar' 	ACTION 'VIEWDEF.EqDivNeg'	OPERATION 4 ACCESS 0
ADD OPTION aMenu TITLE 'Excluir' 	ACTION 'VIEWDEF.EqDivNeg'	OPERATION 5 ACCESS 0
ADD OPTION aMenu TITLE 'Copiar' 	ACTION 'VIEWDEF.EqDivNeg'	OPERATION 9 ACCESS 0

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

Local oStruct1 := FwFormStruct(1,"SZJ")
Local oModel

oModel := MpFormModel():New("PEDivNeg",/*Pre-Validacao*/, {|| .T.},/*Commit*/,/*Cancel*/)
oModel:AddFields("ID_MODEL_ENCH_DIVNEG",/*cOwner*/,oStruct1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"ZJ_FILIAL","ZJ_CODIGO"})
oModel:SetDescription("Cadastro Divis�o de Negocios")
oModel:GetModel("ID_MODEL_ENCH_DIVNEG"):SetDescription("Cadastro Divis�o de Negocios")

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

Local oStruct1 	:= FwFormStruct(2,"SZJ")
Local oModel 	:= FwLoadModel("EQDivNeg")
Local oView		:= FwFormView():New()

oView:SetModel(oModel)
oView:AddField("ID_VIEW_ENCH_DIVNEG",oStruct1,"ID_MODEL_ENCH_DIVNEG")

//���������������������������������������������Ŀ
//� Habilita Titulo da View 					�
//�����������������������������������������������
oView:EnableTitleView('ID_VIEW_ENCH_DIVNEG','Divis�o de Negocios')

Return(oView)