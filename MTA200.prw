#Include 'Protheus.Ch'

User Function MTA200()

Local lRet   := .T.
Local cOper  := AllTrim( ParamIXB )
Local aArea  := GetArea()
Local cTipos := GetMV( "MV_BE_ESTP",, "'PI','MP','MO','GG','EM','SP','EM','BN','MC'")

If !(cOper == "E")
	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->( dbSeek( xFilial("SB1") + cCodPai ) )
		If !(AllTrim( SB1->B1_TIPO ) $ "PA/PI/KT/PP/BN")
			Aviso("MTA200 / Código Pai!","Tipo Produto: " + SB1->B1_TIPO + " Não Permitido para Código Pai de Estrutura de Produtos!",{"Cancela"})
			lRet := .F.
		EndIf
	EndIf

	//dbSelectArea("SB1")
	//dbSetOrder(1)
	//If SB1->( dbSeek( xFilial("SB1") + M->G1_COMP ) )
	//	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
	//		Aviso("MTA200 / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " Não Permitido para Componente de Estrutura de Produtos!",{"Cancela"})
	//		lRet := .F.
	//	EndIf
	//EndIf

	dbSelectArea("SB1")
	dbSetOrder(1)
	If SB1->( dbSeek( xFilial("SB1") + cCodPai ) )
		If AllTrim( SB1->B1_TIPO ) <> "KT"
			dbSelectArea("SB1")
			dbSetOrder(1)
			If SB1->( dbSeek( xFilial("SB1") + M->G1_COMP ) )
				If AllTrim( SB1->B1_TIPO ) == "PA"
					Aviso("MTA200 / Componente!","Não permitido componente PA se Código Pai não for tipo KT!",{"Cancela"})
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return lRet