#Include "Totvs.ch"

User Function M415GRV

Local aArea		:= GetArea()

RecLock('SCJ',.F.)
SCJ->CJ_TIPLIB := '2'
SCJ->( MsUnlock() )

RestArea( aArea )

Return
