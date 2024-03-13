#Include "Protheus.ch"
#Include "FWMVCDef.ch"
/*---------------------------------------------------------------------------------------------------------------------------*
 | P.E.:  CRMA980                                                                                                           |
 | Autor: MArcio Da Silva                                                                                                    |
 | Data:  09/05/2023                                                                                                         |
 | Desc:  Ponto de entrada MVC no cadastro de Clientes                                                                        |
 *---------------------------------------------------------------------------------------------------------------------------*/
User Function CRMA980()
	Local aParam    := PARAMIXB
	Local oModel    := ""
	Local cIdPonto  := ""
	Local cIdModel  := ""
	Local cItemCtb  := ""
	Local lIsGrid   := .F.
	Local xRet      := .T.
	If aParam <> Nil
		oModel   := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid  := (Len(aParam) > 3)
		//Pega informações dos parâmetros
		If cIdPonto == "MODELCOMMITTTS"
			//Se for inclusão e/ou alteração
			If (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
                /* Funcao usada para validar a inclusao do Item Contabil do Cliente. */
				If ExistBlock("CTBA001A")
					cItemCtb:= U_CTBA001A("C"+SubStr(SA1->A1_COD,1,6)+SA1->A1_LOJA, SA1->A1_NOME)
					If	!Empty(cItemCtb)
						If	RecLock("SA1", .F.)
							Replace SA1->A1_XITEMCC	With cItemCtb
							SA1->(MsUnLock())
						EndIf
					EndIf
				EndIf
			EndIf
		ElseIf cIdPonto == 'FORMPOS' .And. cIdModel == 'SA1MASTER'
			iF !M->A1_XCDZA1 == SA1->A1_XCDZA1 .Or. !M->A1_CODZA1 == SA1->A1_CODZA1
					oModelPad:=FWModelActive()
					oModelPad:SetValue(cIdModel,'A1_X_EXPO', "") 		
			EndIf
		EndIf
	EndIf
Return xRet

