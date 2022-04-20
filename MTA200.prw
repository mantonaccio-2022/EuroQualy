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
			Aviso("MTA200 / C�digo Pai!","Tipo Produto: " + SB1->B1_TIPO + " N�o Permitido para C�digo Pai de Estrutura de Produtos!",{"Cancela"})
			lRet := .F.
		EndIf
	EndIf

	//dbSelectArea("SB1")
	//dbSetOrder(1)
	//If SB1->( dbSeek( xFilial("SB1") + M->G1_COMP ) )
	//	If !(AllTrim( SB1->B1_TIPO ) $ cTipos)
	//		Aviso("MTA200 / Tipo de Produto!","Tipo Produto: " + SB1->B1_TIPO + " N�o Permitido para Componente de Estrutura de Produtos!",{"Cancela"})
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
					Aviso("MTA200 / Componente!","N�o permitido componente PA se C�digo Pai n�o for tipo KT!",{"Cancela"})
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return lRet