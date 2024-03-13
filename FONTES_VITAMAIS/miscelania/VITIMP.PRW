
/**********************************************************************************
*               Diversos Programas para trbalhar banco de dados                   *
**********************************************************************************/
#Include "msobject.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#INCLUDE "Protheus.CH"
#include "TOTVS.ch"
************************
User Function VITIMP()
************************


//fVTM_01() // Importacao de Produtos
//fVTM_02() // Importacao de Fornecedores
//fVTM_03() // Importacao de Vendedores Representantes
//fVTM_04() // Importacao de CLientes
//fVTM_05() // Importacao de Contas a Receber
//fVTM_06() // Importacao de Contas a pagar
//fVTM_07() // Importacao de Saldo Estoque
//fVTM_08() // Importacao de Transferencia Carteria de titulos a receber
//fVTM_09() // Importacao de cliente alteracao comissao de vendedor
fVTM_10() // Importacao de ativo fixo

Return()




/**********************************************************************************
* VITMIS01.PRW  - Importacao de produtos                                          *
**********************************************************************************/
Static Function fVTM_01()
***************
Local nI 			:= 0 
Local aErroLog 		:= {}
oModel      := Nil

alert('Inicio Importacao Produto - terste SB1')
sArqSB1 := "\miscelania\prod.txt"
DbSelectArea('SB1')
DbSetOrder(1)
DBGOTOP()
if file(sArqSB1)
   If (_nHa := FT_FUse(AllTrim(sArqSB1)))== -1
      msgbox("Arquivo Aberto, Favor Fechar!")
      Return
   EndIf
   FT_FGOTOP()
   While !FT_FEOF()
		sLinha := Alltrim(FT_FREADLN())
		sLinha := StrTran(sLinha, "'", "")
		conout(sLinha)
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(";",sLinha)

			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
			//1							 2		 3		 4	   5         6       7        8         9        10
			//B1_COD,                    B1_DESC,B1_TIPO,B1_UM,B1_POSIPI,B1_PESO,B1_UREV ,B1_ORIGEM,B1_GRUPO,B1_MSBLQL
			//80703 ,EMBALAGEM TURBO VSO PREMIUM,     EM,   UN, 63053310,      0,20160307,         ,        ,1
		EndDo
		DbSelectArea('SB1')
		DbSetOrder(1)
		DbSeek(xFilial('SB1')+StrZero(val(aCampo [1,1]),06),.T.)
		If Alltrim(SB1->B1_COD) == StrZero(val(aCampo [1,1]),06)
			RecLock("SB1", .F.)
			SB1->B1_POSIPI := Alltrim(aCampo [5,1])
			MsUnlock("SB1")
		Else
			oModel  := FwLoadModel ("MATA010")
			oModel:SetOperation(3)
			oModel:Activate()
			oModel:SetValue("SB1MASTER","B1_COD"        ,StrZero(val(aCampo [1,1]),06)		)
			oModel:SetValue("SB1MASTER","B1_DESC"       ,aCampo [2,1]   	)
			oModel:SetValue("SB1MASTER","B1_TIPO"       ,aCampo [3,1]   	)
			oModel:SetValue("SB1MASTER","B1_UM"     	,aCampo [4,1]   	)
			oModel:SetValue("SB1MASTER","B1_LOCPAD" 	,"01"				)
			oModel:SetValue("SB1MASTER","B1_PICM" 		,0					)
			oModel:SetValue("SB1MASTER","B1_IPI" 		,0					)
			oModel:SetValue("SB1MASTER","B1_PESO" 		,VAL(aCampo [6,1])	)
			oModel:SetValue("SB1MASTER","B1_POSIPI"		,Alltrim(aCampo [5,1])	)
			oModel:SetValue("SB1MASTER","B1_ORIGEM"    	,aCampo [8,1]   	)
			oModel:SetValue("SB1MASTER","B1_GRUPO"     	,aCampo [9,1]   	)
			oModel:SetValue("SB1MASTER","B1_MSBLQL"    	,'2'            	)
			oModel:SetValue("SB1MASTER","B1_CONTRAT" 	,"N"				)
			oModel:SetValue("SB1MASTER","B1_LOCALIZ" 	,"N"				)
			oModel:SetValue("SB1MASTER","B1_CODBAR" 	,""					)
			oModel:SetValue("SB1MASTER","B1_IRRF" 		,"N"				)
			oModel:SetValue("SB1MASTER","B1_CONTSOC" 	,"N"				)
			oModel:SetValue("SB1MASTER","B1_MRP" 		,"N"				)
			If oModel:VldData()
				If oModel:CommitData()
					lDeuCerto := .T.
				Else
					lDeuCerto := .F.
				EndIf
			Else
				lDeuCerto := .F.
			EndIf
			If ! lDeuCerto
				aErro := oModel:GetErrorMessage()
				/*
				AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
				AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
				AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
				AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
				AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
				AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
				AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
				AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
				AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
				nI := 0
				FOR nI := 1 TO 10
					AutoGrLog("Valor Campo: "             + ' [' + AllToChar(aCampo [nI,1] ) + ']')
				Next nI
				*/
				aAdd(aErroLog, {StrZero(val(aCampo [1,1]),06)	,AllToChar(aErro[04])	, AllToChar(aErro[06])		, nil})
			EndIf
			oModel:DeActivate()
			FreeUsedCode()
		EndIf	
		FT_FSKIP()
	EndDo
EndIF

Alert('ListErro -- > ' + strZero(LEN(aErroLog),4))
sCl     := chr(13) + CHR(10)
sNomeArq:='\miscelania\erprod.txt'   //arquivo a gerar texto
If File(sNomeArq)
	Ferase(sNomeArq)
Endif
sHandle:=MsFCreate(SNomeArq)

For nI := 1 To LEN(aErroLog)
	sGrava:= 'Erro Importacao- >' + aErroLog[nI,1] + '-'  + aErroLog[nI,2] + '-' + aErroLog[nI,3] + sCl
	FWrite(sHandle,sGrava,len(sGrava))
Next X
FClose(sHandle)

alert('FINALIZADO')
Return


/**********************************************************************************
* VITMIS02.PRW  - Importacao de Fornecedores                                      *
**********************************************************************************/
Static Function fVTM_02()
***************
Local aErroLog		:= {}
Local nOpc	      	:= 3
Local lMsErroAuto 	:= .f.
Local nI			:= 0
Local lDeuCerto   	:= .F.
oModel      := Nil

alert('Inicio Importacao FORNECEDOR - SA2')
sArq := "\miscelania\fornece.txt"
nA2_LOJA := 0 
DbSelectArea('SA2')
DbSetOrder(1)
DBGOTOP()
if file(sArq)
	If (_nHa := FT_FUse(AllTrim(sArq)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	nA2_COD  :=0
	tLaco := .T.

	FT_FGOTOP()
	While !FT_FEOF() .And. tLaco
		sLinha := Alltrim(FT_FREADLN())
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(",",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
//			1       2        3           4                                                 5        6         7           8                                  9          10         11      12          13      14       15      16           17       18         19        20
//			A2_COD, A2_LOJA, A2_XCODLEG, A2_NOME,                                          A2_TIPO, A2_INSCR, A2_CONTRIB ,A2_END                           , A2_NREDUZ, A2_BAIRRO, A2_EST, A2_COD_MUN, A2_DDD ,A2_TEL,  A2_FAX ,A2_CGC     , A2_PAIS, A2_INSCRM, A2_EMAIL, A2_MSBLQL
//			87112 ,       1, 7205      , AC DIGITAL SERVICOS DE CERTIFICACAO DIGITAL LTDA, J      , ISENTO,   2          ,RUA GENERAL ANDRADE NEVES  N. SN , ACERTCON,  CENTRO,    RS,     14902,      51     ,30257600,       ,87112000121, 105    ,          ,         , 1
		EndDo

		sA2_CGC	:= StrZero(Val(aCampo[16,1]),14)

		DbSelectArea('SA2')
		DbSetOrder(3)
		DbSeek(xFilial('SA2')+Alltrim(sA2_CGC),.T.)
		If !Alltrim(SA2->A2_CGC) == Alltrim(sA2_CGC)
			nA2_COD  += 1
			nA2_LOJA := 1 
			sA2_COD := StrZero(nA2_COD,6)
			//sA2_COD := IIF(GetSx8Num("SA2","A2_COD") > GetSxENum("SA2","A2_COD"),GetSx8Num("SA2","A2_COD"),GetSxENum("SA2","A2_COD"))
			iF Len(Alltrim(sA2_CGC)) > 5 .And. Len(Alltrim(sA2_CGC)) <= 12
				DbSelectArea('SA2')
				DbSetOrder(3)
				DbSeek(xFilial('SA2')+Alltrim(sA2_CGC),.T.)
				While !Eof() .And. Alltrim(SA2->A2_CGC) == Alltrim(sA2_CGC)
					sA2_COD  := SA2->A2_COD
					nA2_LOJA += 1 
					DbSkip()
				EndDo
			ElseIF Len(Alltrim(sA2_CGC)) == 14
					nA2_LOJA := Val(Subs(Alltrim(sA2_CGC),9,4)) 
					DbSelectArea('SA2')
					DbSetOrder(3)
					DbSeek(xFilial('SA2')+Left(Alltrim(sA2_CGC),8),.T.)
					If left(Alltrim(SA2->A2_CGC),8) == Left(Alltrim(sA2_CGC),8)
						sA2_COD  := SA2->A2_COD
					EndIF
			EndIf	
			lDeuCerto := .F.
			oModel  := FwLoadModel ("MATA020M")
			oModel:SetOperation(3)
			oModel:Activate()
			oSA2Mod:= oModel:getModel("SA2MASTER")
			oSA2Mod:setValue("A2_COD"		,sA2_COD                    ) 
			oSA2Mod:setValue("A2_LOJA"		,StrZero(nA2_LOJA,4) ) // Codigo 
			oSA2Mod:setValue("A2_XCODLEG"	,aCampo [3,1]   	)
			oSA2Mod:setValue("A2_NOME"		,aCampo [4,1]   	)
			oSA2Mod:setValue("A2_TIPO"		,Alltrim(aCampo [5,1])   	)
			//oSA2Mod:setValue("A2_INSCR"		,StrZero(val(aCampo [6,1]),14)   	)
			oSA2Mod:setValue("A2_INSCR"		,''   	)
			oSA2Mod:setValue("A2_CONTRIB"	,aCampo [7,1]   	)
			oSA2Mod:setValue("A2_END"		,aCampo [8,1]   	)
			oSA2Mod:setValue("A2_NREDUZ"	,Left(aCampo [9,1],20)   	)
			oSA2Mod:setValue("A2_BAIRRO"	,aCampo [10,1]   	)
			oSA2Mod:setValue("A2_EST"		,aCampo [11,1]   	)
			oSA2Mod:setValue("A2_COD_MUN"	,StrZero(Val(aCampo [12,1]),5)   	)               
			oSA2Mod:setValue("A2_DDD"		,aCampo [13,1]   	)               
			oSA2Mod:setValue("A2_TEL"		,aCampo [14,1]   	)               
			oSA2Mod:setValue("A2_FAX"		,aCampo [15,1]   	)               
			oSA2Mod:setValue("A2_CGC"		,StrZero(Val(aCampo [16,1]),14)   	)               
			oSA2Mod:setValue("A2_PAIS"		,aCampo [17,1]   	)               
			oSA2Mod:setValue("A2_INSCRM"	,aCampo [18,1]   	)               
			oSA2Mod:setValue("A2_EMAIL"		,aCampo [19,1]   	)               
			oSA2Mod:setValue("A2_MSBLQL"	,'2'   	)               

			If oModel:VldData()
				If oModel:CommitData()
					lDeuCerto := .T.
				Else
					lDeuCerto := .F.
				EndIf
			Else
				lDeuCerto := .F.
			EndIf
			If ! lDeuCerto
				aErro := oModel:GetErrorMessage()
	///*
				AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
				AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
				AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
				AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
				AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
				AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
				AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
				AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
				AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
				nI := 0
//		tLaco := .F.

				FOR nI := 1 TO 20
					AutoGrLog("Valor Campo: "             + ' [' + AllToChar(aCampo [nI,1] ) + ']')
				Next nI
				MostraErro()
	//*/
				aAdd(aErroLog, {aCampo [16,1],AllToChar(aErro[04])	, AllToChar(aErro[06])		, nil})
			EndIf
			oModel:DeActivate()
			FreeUsedCode()
		EndIf	
		FT_FSKIP()
	EndDo
EndIF
/*
Alert('ListErro -- > ' + strZero(LEN(aErroLog),4))
sCl     := chr(13) + CHR(10)
sNomeArq:='\miscelania\erfornece.txt'   //arquivo a gerar texto
If File(sNomeArq)
	Ferase(sNomeArq)
Endif
sHandle:=MsFCreate(SNomeArq)
For nI := 1 To LEN(aErroLog)
	sGrava:= 'Erro Importacao- >' + aErroLog[nI,1] + '-'  + aErroLog[nI,2] + '-' + aErroLog[nI,3] + sCl
	FWrite(sHandle,sGrava,len(sGrava))
Next X
FClose(sHandle)
*/
alert('FINALIZADO')
Return





/**********************************************************************************
* VITMIS02.PRW  - Importacao de Vendedores                                      *
**********************************************************************************/
Static Function fVTM_03()
***************
local aErroLog		:= {}
Local aProduto    	:= {}
Local nOpc	      	:= 3
Local lMsErroAuto 	:= .f.
Local nI			:= 0 
Local lDeuCerto   	:= .F.
oModel      := Nil
alert('Inicio Importacao VENDEDORES - SA3')
sArq := "\micelania\vende.txt"
DbSelectArea('SA3')
DbSetOrder(1)
DBGOTOP()
if file(sArq)
	If (_nHa := FT_FUse(AllTrim(sArq)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	FT_FGOTOP()
	While !FT_FEOF()
		sLinha := Alltrim(FT_FREADLN())
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(",",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
// 			A3_XCODLEG, A3_COD, A3_NOME                                 , A3_NREDUZ
//			006588    , 000001, FABRICIO XAVIER BAIER                   , FABRICIO BAIER           
		EndDo
		lMsErroAuto := .F.
		aDados 		:= {}
		aAdd(aDados, {"A3_FILIAL"	, xFilial("SA3")		, nil})
		aAdd(aDados, {"A3_XCODLEG"  , aCampo [1,1]	        , nil})
		aAdd(aDados, {"A3_COD"  	, StrZero(val(aCampo [2,1]),6)      , nil})
		aAdd(aDados, {"A3_NOME"  	, aCampo [3,1]	        , nil})
		aAdd(aDados, {"A3_NREDUZ"  	, aCampo [4,1]	        , nil})
		MSExecAuto({|x,y|mata040(x,y)},aDados,3) 	
		If lMsErroAuto		
			aAdd(aErroLog, {StrZero(val(aCampo [2,1]),6)	,'erro inclusao'		, nil})
		EndIf
		FreeUsedCode()
		FT_FSKIP()
	EndDo
EndIF

Alert('ListErro -- > ' + strZero(LEN(aErroLog),4))
sCl     := chr(13) + CHR(10)
sNomeArq:='\miscelania\ervende.txt'   //arquivo a gerar texto
If File(sNomeArq)
	Ferase(sNomeArq)
Endif
sHandle:=MsFCreate(SNomeArq)
For nI := 1 To LEN(aErroLog)
	sGrava:= 'Erro Importacao- >' + aErroLog[nI,1] + '-'  + aErroLog[nI,2] + '-' + aErroLog[nI,3] + sCl
	FWrite(sHandle,sGrava,len(sGrava))
Next X
FClose(sHandle)
Return



/**********************************************************************************
* VITMIS04.PRW  - Importacao de Clientes                                          *
**********************************************************************************/
Static Function fVTM_04()
***************
Local aErroLog	:= {}
Local aProduto    := {}
Local nOpc	      := 3
Local nI	      := 3
Local lMsErroAuto := .f.
Local lDeuCerto   := .F.

oModel      := Nil

nA1_COD  	:= 0
alert('Inicio Importacao CLIENTES - SA1')
sArq := "\miscelania\cliente.txt"
DbSelectArea('SA1')
DbSetOrder(1)
DBGOTOP()
if file(sArq)
	If (_nHa := FT_FUse(AllTrim(sArq)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	tLaco := .T.

	FT_FGOTOP()
	While !FT_FEOF() .And. 	tLaco
		sLinha := Alltrim(FT_FREADLN())
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(",",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
		EndDo
		nA1_COD += 1
		nA1_LOJA := 1 
		sA1_COD := StrZero(nA1_COD,6)
		iF Len(Alltrim(aCampo[19,1])) > 5 .And. Len(Alltrim(aCampo[19,1])) <= 12
			DbSelectArea('SA1')
			DbSetOrder(3)
			DbSeek(xFilial('SA1')+Alltrim(aCampo[19,1]),.T.)
			While !Eof() .And. Alltrim(SA1->A1_CGC) == Alltrim(aCampo[19,1])
				sA1_COD  := SA1->A1_COD
				nA1_LOJA += 1 
				DbSkip()
			EndDo
		ElseIF Len(Alltrim(aCampo[19,1])) >12
			nA1_LOJA := Val(Subs(Alltrim(sCgc),9,4)) 
			DbSelectArea('SA2')
			DbSetOrder(3)
			DbSeek(xFilial('SA2')+Left(Alltrim(sCgc),8),.T.)
			If left(Alltrim(SA2->A2_CGC),8) == Left(Alltrim(sCgc),8)
				sA1_COD  := SA2->A2_COD
			EndIF
		EndIf	
		lDeuCerto := .F.
		oModel := FWLoadModel("MATA030")
		oModel:SetOperation(3)
		oModel:Activate()
		oSA1Mod:= oModel:getModel("MATA030_SA1")
		oSA1Mod:setValue("A1_COD"		,sA1_COD) 
		oSA1Mod:setValue("A1_LOJA"		,StrZero(nA1_LOJA,4)) // Codigo 
		oSA1Mod:setValue("A1_XCODLEG"	,aCampo [3,1]   	)
		oSA1Mod:setValue("A1_NOME"		,aCampo [4,1]   	)
		oSA1Mod:setValue("A1_PESSOA"	,aCampo [5,1]   	)
		oSA1Mod:setValue("A1_TIPO"		,aCampo [6,1]   	)
		oSA1Mod:setValue("A1_INSCR"		,aCampo [7,1]   	)
		oSA1Mod:setValue("A1_CONTRIB"	,aCampo [8,1]   	)
		oSA1Mod:setValue("A1_END"		,aCampo [9,1]   	)
		oSA1Mod:setValue("A1_NREDUZ"	,aCampo [10,1]   	)
		oSA1Mod:setValue("A1_BAIRRO"	,aCampo [11,1]   	)
		oSA1Mod:setValue("A1_EST"		,aCampo [12,1]   	)
		oSA1Mod:setValue("A1_COD_MUN"	,StrZero(Val(aCampo [13,1]),5)   	)               
		oSA1Mod:setValue("A1_REGIAO"	,aCampo [14,1]   	)
		oSA1Mod:setValue("A1_DDD"		,aCampo [15,1]   	)
		oSA1Mod:setValue("A1_TEL"		,aCampo [16,1]   	)
		oSA1Mod:setValue("A1_FAX"		,aCampo [17,1]   	)               
		oSA1Mod:setValue("A1_CONTATO"	,left(aCampo [18,1],25)   	)               
		oSA1Mod:setValue("A1_CGC"		,aCampo [19,1]   	)               
		oSA1Mod:setValue("A1_PAIS"		,aCampo [20,1]   	)               
		oSA1Mod:setValue("A1_INSCRM"	,aCampo [21,1]   	)               
		oSA1Mod:setValue("A1_SUFRAMA"	,aCampo [22,1]   	)               
		oSA1Mod:setValue("A1_EMAIL"		,aCampo [23,1]   	)               
		oSA1Mod:setValue("A1_MSBLQL"	,'2'   	)               
		oSA1Mod:setValue("A1_BLEMAIL"	,aCampo [25,1]   	)               
		oSA1Mod:setValue("A1_LC"		,Val(aCampo [26,1])   	)               
		oSA1Mod:setValue("A1_DTCAD"		,STOD(aCampo [27,1]))               
		oSA1Mod:setValue("A1_DTNASC"	,STOD(aCampo [28,1]))               
		//oSA1Mod:setValue("A1_ULTCOM"	,STOD(aCampo [29,1]))               
		oSA1Mod:setValue("A1_VEND"		,IIF(Len(aCampo)>29,aCampo [len(aCampo),1],'')		)               
		If oModel:VldData()
			If oModel:CommitData()
				lDeuCerto := .T.
			Else
				lDeuCerto := .F.
			EndIf
		Else
			lDeuCerto := .F.
		EndIf
/*
		If ! lDeuCerto
			aErro := oModel:GetErrorMessage()
			AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
			AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
			AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
			AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
			AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
			AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
			AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
			AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
			AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
			MostraErro()
			tLaco := .F.
alert('erro')
		EndIf
*/
		oModel:DeActivate()
		FreeUsedCode()
		FT_FSKIP()
	EndDo
EndIF

Alert('ListErro -- > ' + strZero(LEN(aErroLog),4))
sCl     := chr(13) + CHR(10)
sNomeArq:='\miscelania\erclient.txt'   //arquivo a gerar texto
If File(sNomeArq)
	Ferase(sNomeArq)
Endif
sHandle:=MsFCreate(SNomeArq)

For nI := 1 To LEN(aErroLog)
	sGrava:= 'Erro Importacao- >' + aErroLog[nI,1] + '-'  + aErroLog[nI,2] + '-'  + aErroLog[nI,3] + '-'  + aErroLog[nI,4]  + sCl
	FWrite(sHandle,sGrava,len(sGrava))
Next X
FClose(sHandle)
Return




/**********************************************************************************
* VITMIS05.PRW  - Importacao de Clientes/Contas a Receber                         *
**********************************************************************************/
Static Function fVTM_05()
***************
Local nI 			:= 0 
Local aErroLog 		:= {}
local tLaco := .T.
oModel      := Nil
alert('Importacao Contas Receber')
Procregua(1252)
sArqSB1 := "\miscelania\exp_rec.txt"
if file(sArqSB1)
	If (_nHa := FT_FUse(AllTrim(sArqSB1)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	FT_FGOTOP()
	While !FT_FEOF() .And. tLaco
        Incproc()
		sLinha := Alltrim(FT_FREADLN())
		sLinha := StrTran(sLinha, "'", "")
		sLinha := StrTran(sLinha, ",", ".")
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(";",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
		EndDo
		If len(Alltrim(aCampo[6,1])) == 6
			DbSelectArea('SA1')
			DbSetorder(1)
			DbSeek(xFilial('SA1')+aCampo[6,1] + aCampo[7,1] ,.t.)
			If xFilial('SA1')+aCampo[6,1] + aCampo[7,1] == SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA
				DbSelectArea('SE1')
				DbSetorder(1)
				DbSeek(xFilial('SE1')+aCampo[1,1] + aCampo[2,1] + aCampo[3,1] + aCampo[4,1],.t.)
				If SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+Alltrim(SE1->E1_TIPO) <> xFilial('SE1')+aCampo[1,1]    +aCampo[2,1]+aCampo[3,1]    +Alltrim(aCampo[4,1])
//1           2         3       4        5           6         7       8          9        10         11         12       13     14         15
//E1_PREFIXO;E2_NUM;E1_PARCELA;E1_TIPO;E1_NATUREZ;E1_CLIENTE;E1_LOJA;E1_EMISSAO;E1_VENCTO;E1_VENCREA;E1_XPREVPG;E1_VALOR;E1_HIST;CNPJ_CPF;A1_XCODLEG
//IMP;000322794;001;NF;108002;004605;0001;20161130;20161130;20161130;20161130;500;;34790152200   ;004490
//IMP;000689471;003;NF;108002;009577;0001;20190917;20200316;20200316;20200316;310,41;ANDRADE E BASTOS 30/03/2020;90162463200   ;010606
//E1_PREFIXO;E2_NUM;E1_PARCELA;E1_TIPO_2;E1_NATUREZ;E1_CLIENTE;E1_LOJA;E1_EMISSAO;E1_VENCTO;E1_VENCREA;E1_XPREVPG;E1_VALOR;E1_HIST;CNPJ_CPF;A1_XCODLEG;BANCO;AGENCIA;CONTA
//IMP;000032443;001;BOL;301001;006387;0001;20131118;20131218;20131218;20200531;672,58;VENC ORIGINAL 18/12/13 - INCLUSAO SERASA;53109678268   ;002370;    ;     ;               
//IMP;000032443;002;BOL;301001;006387;0001;20131118;20140117;20140117;20200531;992,57; VENC ORIGINAL 17/01/14 - INCLUSAO SERAS;53109678268   ;002370;    ;     ;               



					If Alltrim(aCampo[5,1]) == '108002'
						aCampo[5,1] := '101006'
					EndIf
					aVetSE1 := {}
					aAdd(aVetSE1, {"E1_FILIAL"	,xFilial("SE1") ,Nil})  
					aAdd(aVetSE1, {"E1_NUM"		,STRZERO(VAL(aCampo[2,1]),9)      ,Nil})   
					aAdd(aVetSE1, {"E1_PREFIXO"	,aCampo[1,1]          ,Nil})  
					aAdd(aVetSE1, {"E1_PARCELA"	,STRZERO(VAL(aCampo[3,1]),3)  ,Nil})  //Padl(cDados, 6, '0')
					aAdd(aVetSE1, {"E1_TIPO"    ,aCampo[4,1]           ,Nil})
					aAdd(aVetSE1, {"E1_NATUREZ"	,aCampo[5,1],Nil})  
					aAdd(aVetSE1, {"E1_CLIENTE"	,SA1->A1_COD    ,Nil})  
					aAdd(aVetSE1, {"E1_LOJA"	,SA1->A1_LOJA   ,Nil}) 
					aAdd(aVetSE1, {"E1_NOMCLI"	,SA1->A1_NOME   ,Nil}) 
					aAdd(aVetSE1, {"E1_HIST"	,Left(aCampo[13,1],39)   ,Nil}) 
					aAdd(aVetSE1, {"E1_EMISSAO"	,stod(aCampo[8,1]) ,Nil}) 
					aAdd(aVetSE1, {"E1_VENCTO"	,stod(aCampo[9,1]),Nil}) 
					aAdd(aVetSE1, {"E1_VENCREA"	,DataValida(stod(aCampo[9,1]),.T.),Nil}) 
					aAdd(aVetSE1, {"E1_XPREVPG"	,stod(aCampo[11,1]),Nil}) 
					aAdd(aVetSE1, {"E1_VALOR"	,VAL(aCampo[12,1]),Nil}) 
					aAdd(aVetSE1, {"E1_MOEDA"	,1              ,Nil}) 
					iF Alltrim(aCampo[4,1]) == 'RA'
						aAdd(aVetSE1, {"CBCOAUTO"	,'CX1' 				,Nil})  
						aAdd(aVetSE1, {"CAGEAUTO"	,'00001'			,Nil})   
						aAdd(aVetSE1, {"CCTAAUTO"	,'0000000001'       ,Nil})  
					EndIf	
					//Inicia o controle de transação
					Begin Transaction
						//Chama a rotina automática
						lMsErroAuto := .F.
						MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)
						If lMsErroAuto
							MostraErro()
							alert('-'+SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+'='+xFilial('SE1')+aCampo[1,1]    +aCampo[2,1]+aCampo[3,1]    +aCampo[4,1]+'-')
							if MsgBox ("Deseja Sair do Programa apos o Erro?","Escolha","YESNO")
								tLaco := .F.
							EndIf

						EndIf
					End Transaction
				EndIf	
			else
				alert('nao achou' + xFilial('SA1')+aCampo[6,1] + aCampo[7,1])	
				if MsgBox ("Deseja Sair do Programa apos o Erro?","Escolha","YESNO")
					tLaco := .F.
				EndIf

			EndIf
		EndIf
		FT_FSKIP()
	EndDo
EndIf
alert('acabou')
Return()


/**********************************************************************************
* VITMIS06.PRW  - Importacao de Fornecedores/Contas a Pagar                       *
**********************************************************************************/
Static Function fVTM_06()
***************
oModel      		:= Nil
alert('Importacao PAGAR ')
sArqSB1 := "\miscelania\exp_pag.txt"
tLaco := .T.
if file(sArqSB1)
	If (_nHa := FT_FUse(AllTrim(sArqSB1)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	FT_FGOTOP()
	While !FT_FEOF() .And. tLaco
		sLinha := Alltrim(FT_FREADLN())
		sLinha := StrTran(sLinha, "'", "")
		sLinha := StrTran(sLinha, ",", ".")
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(";",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
// 1           2       3        4         5        6          7         8        9         10         11       12       13        14
//E2_PREFIXO;E2_NUM;E2_PARCELA;E2_TIPO;E2_NATUREZ;E2_FORNECE;E2_LOJA;E2_EMISSAO;E2_VENCTO;E2_VENCREA;E2_VALOR;E2_HIST;CNPJ_CPF;A2_XCODLEG
//IMP;000933975;001;PA;101003;001140;0001;20220519;20220519;20220519;674,13;IMPULSIONAMNETO FACEBOOK;25021356000132;014252
//IMP;000979219;001;PA;101003;001143;0001;20221003;20221003;20221003;1700;ADIANTAMENTO DE COMPRA DE TAPETES;91501833000191;018379

//E2_PREFIXO;E2_NUM;E2_PARCELA;E2_TIPO;E2_NATUREZ;E2_FORNECE;E2_LOJA;E2_EMISSAO;E2_VENCTO;E2_VENCREA;E2_VALOR;E2_HIST;CNPJ_CPF;A2_XCODLEG
//IMP;000922417;001;PA;101004; ; ;20220412;20220412;20220412;17339,61;REF ADIANTAMENTO  SALARIO PARA SER DESCO;61817112287;002291
//IMP;000933975;001;PA;101003;001140;0001;20220519;20220519;20220519;674,13;IMPULSIONAMNETO FACEBOOK;25021356000132;014252

		EndDo
		DbSelectArea('SA2')
		DbSetorder(11)
		DbSeek(xFilial('SA2')+StrZero(Val(aCampo[14,1]),6),.t.)
		If SA2->A2_XCODLEG == StrZero(Val(aCampo[14,1]),6)
			RecLock('SA2', .F.)
			SA2->A2_MSBLQL = '2'
			MsUnlock('SA2')

			DbSelectArea('SED')
			DbSetorder(1)
			DbSeek(xFilial('SED')+Alltrim(aCampo[5,1]),.t.)
			iF xFilial('SED')+Alltrim(aCampo[5,1]) <> SED->ED_FILIAL + Alltrim(SED->ED_CODIGO)
				aCampo[5,1] := 'OUTROS'
			EndIf	
			cParcela := IIF(Alltrim(aCampo[3,1])=='','001',STRZERO(VAL(aCampo[3,1]),3))
			DbSelectArea('SE2')
			DbSetOrder(6)
			DbSeek(xFilial('SE2')+ SA2->A2_COD + SA2->A2_LOJA + aCampo[1,1] + STRZERO(VAL(aCampo[2,1]),9) + 'ZZZ',.T.)
			DbSkip(-1)
			If xFilial('SE2')  + SA2->A2_COD     + SA2->A2_LOJA + aCampo[1,1]        + STRZERO(VAL(aCampo[2,1]),9) == ;
				SE2->E2_FILIAL + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM
				cParcela := STRZERO(VAL(SE2->E2_PARCELA)+1,3)
			EndIf
			aVetSE2 := {}
			aAdd(aVetSE2, {"E2_FILIAL"	,xFilial("SE1") ,Nil})  
			aAdd(aVetSE2, {"E2_NUM"		,STRZERO(VAL(aCampo[2,1]),9)      ,Nil})   
			aAdd(aVetSE2, {"E2_PREFIXO"	,aCampo[1,1]          ,Nil})  
			aAdd(aVetSE2, {"E2_PARCELA"	,cParcela  ,Nil})  //Padl(cDados, 6, '0')
			aAdd(aVetSE2, {"E2_TIPO"    ,Alltrim(aCampo[4,1])          ,Nil})
			//aAdd(aVetSE2, {"E2_TIPO"    ,aCampo[4,1]           ,Nil})
			aAdd(aVetSE2, {"E2_NATUREZ"	,aCampo[5,1],Nil})  
			aAdd(aVetSE2, {"E2_FORNECE"	,SA2->A2_COD    ,Nil})  
			aAdd(aVetSE2, {"E2_LOJA"	,SA2->A2_LOJA   ,Nil}) 
			aAdd(aVetSE2, {"E2_NOMFOR"	,SA2->A2_NOME   ,Nil}) 
			aAdd(aVetSE2, {"E2_HIST"	,Left(aCampo[12,1],39)   ,Nil}) 
			aAdd(aVetSE2, {"E2_EMISSAO"	,stod(aCampo[8,1]) ,Nil}) 
			aAdd(aVetSE2, {"E2_VENCTO"	,stod(aCampo[9,1]),Nil}) 
			aAdd(aVetSE2, {"E2_VENCREA"	,DataValida(stod(aCampo[9,1]),.T.),Nil}) 
			aAdd(aVetSE2, {"E2_VALOR"	,val(aCampo[11,1]) ,Nil}) 
			aAdd(aVetSE2, {"E2_MOEDA"	,1              ,Nil}) 
			iF Alltrim(aCampo[4,1]) == 'PA'
				aAdd(aVetSE2, {"AUTBANCO"	,'CX1' 				,Nil})  
				aAdd(aVetSE2, {"AUTAGENCIA"	,'00001'			,Nil})   
				aAdd(aVetSE2, {"AUTCONTA"	,'0000000001'       ,Nil})  
			EndIf	

			//Inicia o controle de transação
			Begin Transaction
				//Chama a rotina automática
				lMsErroAuto := .F.
				MSExecAuto({|x,y| FINA050(x,y)}, aVetSE2, 3)
				If lMsErroAuto
					MostraErro()
					if MsgBox ("Deseja Sair do Programa apos o Erro?","Escolha","YESNO")
						tLaco := .F.
					EndIf
				EndIf
			End Transaction
		else
			alert('nao achou' + aCampo[14,1])	
			if MsgBox ("Deseja Sair do Programa apos o Erro?","Escolha","YESNO")
				tLaco := .F.
			EndIf
		EndIf
		FT_FSKIP()
	EndDo
EndIf
alert('acabou')
Return()


/**********************************************************************************
* VITMIS07.PRW  - Importacao de produtos                       *
**********************************************************************************/
Static Function fVTM_07()
*************************
Local X := 0 
alert('Importacao estoque')
sMsg := ''
sArqSB1 := "\miscelania\exp_est.txt"
cLocPad := '01'
if file(sArqSB1)
	If (_nHa := FT_FUse(AllTrim(sArqSB1)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	FT_FGOTOP()
	aIniSB9 := {}
	aIniSD5 := {}
	wLaco   := .T.
	While !FT_FEOF() .And. Empty(sMsg)
		sLinha := Alltrim(FT_FREADLN())
		sLinha := StrTran(sLinha, "'", "")
		sLinha := StrTran(sLinha, ",", ".")
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(";",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
		EndDo
		nPos := aScan(aIniSB9, {|x|x[1]==Alltrim(aCampo[1,1])})
		If nPos > 0 
			aIniSB9[nPos,3] += Val(aCampo[6,1])
		Else
			AADD(aIniSB9,{Alltrim(aCampo[1,1]),cLocPad,Val(aCampo[6,1]),Val(aCampo[7,1])})
		EndIf
		AADD(aIniSD5,{Alltrim(aCampo[1,1]),cLocPad,STRZERO(VAL(aCampo[4,1]),10),dDataBase,Val(aCampo[6,1]) ,STOD(aCampo[5,1])})
		FT_FSKIP()
	EndDo
//1        2       3      4         5          6         7
//D3_COD;D3_DESC;D3_TIPO;D3_LOTECTL;D3_DTVALID;D3_QUANT;D3_CUSTO1
//090971;CIO EXTRA PREPARACAO CAMPARINO;PA;0000000054;20230826;42;97,6391
//080703;EMBALAGEM TURBO VSO PREMIUM;EM;0000002541;20250508;3018;3,4305

	For X := 1 to Len(aIniSB9)	
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+Alltrim(aIniSB9[X,1]),.t.)
		If xFilial('SB1')+Alltrim(aIniSB9[X,1]) == SB1->B1_FILIAL + Alltrim(SB1->B1_COD)
			dbSelectArea('SB9')
			dbSetOrder(1)
			dbSeek(xFilial('SB9')+Alltrim(aIniSB9[X,1]),.t.)
			If !xFilial('SB9')+Alltrim(aIniSB9[X,1]) == SB9->B9_FILIAL + Alltrim(SB9->B9_COD)
				sB1_COD := ''
				If 	SB1->B1_MSBLQL == '1'
					sB1_COD := SB1->B1_COD
					RecLock("SB1", .F.)
					SB1->B1_MSBLQL := '2'
					MsUnlock("SB1")
				EndIf
				lMsErroAuto := .F.
				aRotAuto := {{"B9_COD",SB1->B1_COD ,NIL},;
				{"B9_LOCAL",cLocPad,NIL},;
				{"B9_QINI" ,aIniSB9[x,3],NIL},;
				{"B9_VINI1" ,ROUND(aIniSB9[x,3]*aIniSB9[x,4],6),NIL}}
				MSExecAuto({|x,y| mata220(x,y)},aRotAuto,3) //Inclusão
				If lMsErroAuto
					MostraErro()
				EndIf
				If !Empty(sB1_COD) 
					RecLock("SB1", .F.)
					SB1->B1_MSBLQL := '1'
					MsUnlock("SB1")
				EndIf
			EndIf
		Else
			Alert(aIniSB9[X,1] + '- Produto  SB9 Nao Encontrado!')	
		EndIf
	Next X
	For X := 1 to Len(aIniSD5)	
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+Alltrim(aIniSD5[X,1]),.t.)
		If xFilial('SB1')+Alltrim(aIniSD5[X,1]) == SB1->B1_FILIAL + Alltrim(SB1->B1_COD)
			dbSelectArea('SD5')
			dbSetOrder(2)
			dbSeek(xFilial('SD5')+SB1->B1_COD+cLocPad+Alltrim(aIniSD5[X,3]),.t.)
			If !xFilial('SD5')+SB1->B1_COD+cLocPad+Alltrim(aIniSD5[X,3]) == SD5->D5_FILIAL + SD5->D5_PRODUTO + SD5->D5_LOCAL + Alltrim(SD5->D5_LOTECTL)
				sB1_COD := ''
				If 	SB1->B1_MSBLQL == '1'
					sB1_COD := SB1->B1_COD
					RecLock("SB1", .F.)
					SB1->B1_MSBLQL := '2'
					MsUnlock("SB1")
				EndIf
				aVetor 			:= {}
				nOpc			:= 3
				lMsErroAuto 	:= .F.
				DbSelectArea("SD5")
				aadd(aVetor,{"D5_PRODUTO" 	,SB1->B1_COD 					,NIL})
				aadd(aVetor,{"D5_LOCAL" 	,cLocPad 						,NIL})
				aadd(aVetor,{"D5_LOTECTL" 	,aIniSD5[X,3]  					,NIL})
				aadd(aVetor,{"D5_DATA" 		,dDataBase						,NIL})
				aadd(aVetor,{"D5_QUANT" 	,aIniSD5[x,5]	 				,NIL})
				aadd(aVetor,{"D5_DTVALID" 	,aIniSD5[x,6]	 				,NIL})
				MSExecAuto({|x,y| Mata390(x,y)},aVetor,nOpc)
				If lMsErroAuto
					MostraErro()
					alert('produto - saldo--' + SB1->B1_COD )
				EndIf
				If !Empty(sB1_COD) 
					RecLock("SB1", .F.)
					SB1->B1_MSBLQL := '1'
					MsUnlock("SB1")
				EndIf
			EndIf
		Else
			Alert(aIniSD5[X,1] + '- Produto SD5 Nao Encontrado!')	
		EndIf
	Next X
EndIf
alert('acabou')
return()







/*
banco = '001'
agencai = '4205'
conta := '26262'
237
0457
44775
   Local aTit          := {}
    Local cPrefixo      := "001"
    Local cNumero       := "000000001"
    Local cParcela      := "001"
    Local cTipo         := "NF"
    Local cBanco        := "001"
    Local cAgencia      := "001"
    Local cConta        := "001"
    Local cSituaca      := "1"
    Local cNumBco       := "132456"
    Local dDataMov      := CToD("29/03/2019")
 
    //-- Variáveis utilizadas para o controle de erro da rotina automática
    Local aErroAuto     := {}
    Local cErroRet      := ""
    Local nCntErr       := 0
 
    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
 
    PREPARE ENVIRONMENT EMPRESA "XX" FILIAL "XX" USER "admin" 
 
    //Para retornar o título para carteira é necessário informar o banco em "branco"
    If cSituaca == "0"
        cBanco      := ""
        cAgencia    := ""
        cConta      := ""
        cNumBco     := ""
    EndIf
 
    //Chave do título
 
    AAdd(aTit, {"E1_PREFIXO",   PadR(cPrefixo,  TamSX3("E1_PREFIXO")[1]),   Nil})
    AAdd(aTit, {"E1_NUM",       PadR(cNumero,   TamSX3("E1_NUM")[1]),       Nil})
    AAdd(aTit, {"E1_PARCELA",   PadR(cParcela,  TamSX3("E1_PARCELA")[1]),   Nil})
    AAdd(aTit, {"E1_TIPO",      PadR(cTipo,     TamSX3("E1_TIPO")[1]),      Nil})
 
    //Informações bancárias
 
    AAdd(aTit, {"AUTDATAMOV",   dDataMov,       Nil})
    AAdd(aTit, {"AUTBANCO",     PadR(cBanco,    TamSX3("A6_COD")[1]),       Nil})
    AAdd(aTit, {"AUTAGENCIA",   PadR(cAgencia,  TamSX3("A6_AGENCIA")[1]),   Nil})
    AAdd(aTit, {"AUTCONTA",     PadR(cConta,    TamSX3("A6_NUMCON")[1]),    Nil})
    AAdd(aTit, {"AUTSITUACA",   PadR(cSituaca,  TamSX3("E1_SITUACA")[1]),   Nil})
    AAdd(aTit, {"AUTNUMBCO",    PadR(cNumBco,   TamSX3("E1_NUMBCO")[1]),    Nil})
    AAdd(aTit, {"AUTGRVFI2",    .T.,            Nil})
 
    //Carteira descontada deve ser encaminhado o valor de crédito, desconto e IOF já calculados
    If cSituaca $ "2|7"
        AAdd(aTit, {"AUTDESCONT",   090,    Nil})
        AAdd(aTit, {"AUTCREDIT",    750,    Nil})
        AAdd(aTit, {"AUTIOF",       010,    Nil})
    EndIf
 
    MsExecAuto({|operacao, titulo| FINA060(operacao, titulo)}, 2, aTit)
 
    If lMsErroAuto
        aErroAuto := GetAutoGRLog()
         
        For nCntErr := 1 To Len(aErroAuto)
            cErroRet += aErroAuto[nCntErr]
        Next nCntErr
 
        Conout(cErroRet)
    EndIf
 
    RESET ENVIRONMENT
 
Return Nil
*/

*************************
Static Function fVTM_08()
***************
Local nI 			:= 0 
Local aErroLog 		:= {}
local tLaco := .T.
Local nCntErr := 0 
oModel      := Nil
alert('Importacao Contas Receber')
Procregua(1252)
sArqSB1 := "\miscelania\exp_rec.txt"
if file(sArqSB1)
	If (_nHa := FT_FUse(AllTrim(sArqSB1)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	FT_FGOTOP()
	While !FT_FEOF() .And. tLaco
        Incproc()
		sLinha := Alltrim(FT_FREADLN())
		sLinha := StrTran(sLinha, "'", "")
		sLinha := StrTran(sLinha, ",", ".")
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(";",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
		EndDo
		If len(Alltrim(aCampo[6,1])) == 6
			DbSelectArea('SA1')
			DbSetorder(1)
			DbSeek(xFilial('SA1')+aCampo[6,1] + aCampo[7,1] ,.t.)
			If xFilial('SA1')+aCampo[6,1] + aCampo[7,1] == SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA
				DbSelectArea('SE1')
				DbSetorder(1)
				DbSeek(xFilial('SE1')+aCampo[1,1] + aCampo[2,1] + aCampo[3,1] + aCampo[4,1],.t.)
				If SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+Alltrim(SE1->E1_TIPO) == xFilial('SE1')+aCampo[1,1]    +aCampo[2,1]+aCampo[3,1]    +Alltrim(aCampo[4,1])
					lMsErroAuto     := .F.
					lMsHelpAuto     := .T.
					lAutoErrNoFile  := .T.
					aErroAut		:= {}
					cErroRet		:= ''
					cBanco      := ""
					cAgencia    := ""
					cConta      := ""
					cNumBco     := ""
					If !Empty(Alltrim(aCampo[16,1]))
						DbSelectArea('SA6')
						DbSetorder(1)
						DbSeek(xFilial('SA6')+aCampo[16,1],.t.)
						If xFilial('SA6')+aCampo[16,1] == SA6->A6_FILIAL + SA6->A6_COD
							cBanco      := SA6->A6_COD
							cAgencia    := SA6->A6_AGENCIA
							cConta      := SA6->A6_NUMCON
							cNumBco     := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
							aTit		:= {}

							AAdd(aTit, {"E1_PREFIXO",   PadR(SE1->E1_PREFIXO,  TamSX3("E1_PREFIXO")[1]),   Nil})
							AAdd(aTit, {"E1_NUM",       PadR(SE1->E1_NUM	,  TamSX3("E1_NUM")[1]),       Nil})
							AAdd(aTit, {"E1_PARCELA",   PadR(SE1->E1_PARCELA,  TamSX3("E1_PARCELA")[1]),   Nil})
							AAdd(aTit, {"E1_TIPO",      PadR(SE1->E1_TIPO	,  TamSX3("E1_TIPO")[1]),      Nil})

							AAdd(aTit, {"AUTDATAMOV",   dDataBase			,  			Nil})
							AAdd(aTit, {"AUTBANCO",     PadR(cBanco			,  TamSX3("A6_COD")[1]),       Nil})
							AAdd(aTit, {"AUTAGENCIA",   PadR(cAgencia		,  TamSX3("A6_AGENCIA")[1]),   Nil})
							AAdd(aTit, {"AUTCONTA",     PadR(cConta			,  TamSX3("A6_NUMCON")[1]),    Nil})
							AAdd(aTit, {"AUTSITUACA",   PadR('1'			,  TamSX3("E1_SITUACA")[1]),   Nil})
							AAdd(aTit, {"AUTNUMBCO",    PadR(cNumBco		,  TamSX3("E1_NUMBCO")[1]),    Nil})
							AAdd(aTit, {"AUTGRVFI2",    .T.					,            Nil})
			
							//Carteira descontada deve ser encaminhado o valor de crédito, desconto e IOF já calculados
							//If cSituaca $ "2|7"
							//	AAdd(aTit, {"AUTDESCONT",   090,    Nil})
							//	AAdd(aTit, {"AUTCREDIT",    750,    Nil})
							//	AAdd(aTit, {"AUTIOF",       010,    Nil})
							//EndIf
						
							MsExecAuto({|operacao, titulo| FINA060(operacao, titulo)}, 2, aTit)
			
							If lMsErroAuto
								aErroAuto := GetAutoGRLog()
								nCntErr   := 0 
								For nCntErr := 1 To Len(aErroAuto)
									cErroRet += aErroAuto[nCntErr]
								Next nCntErr
								alert(cErroRet)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		FT_FSKIP()
	EndDo
EndIf
alert('acabou')
Return()




*************************
Static Function fVTM_09()
***************
Local nI 			:= 0 
Local aErroLog 		:= {}
local tLaco := .T.
oModel      := Nil
alert('Importacao COmissao')
Procregua(1252)
sArqSB1 := "\miscelania\exp_com.txt"
if file(sArqSB1)
	If (_nHa := FT_FUse(AllTrim(sArqSB1)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	FT_FGOTOP()
	While !FT_FEOF() .And. tLaco
        Incproc()
		sLinha := Alltrim(FT_FREADLN())
		sLinha := StrTran(sLinha, "'", "")
		sLinha := StrTran(sLinha, ",", ".")
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(";",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
		EndDo
//1          2      3          4          5       6
//E1_PREFIXO;E2_NUM;E1_PARCELA;E1_CLIENTE;E1_LOJA;E1_COMIS1
//IMP;000032443;001;006387;0001;8,00008
//IMP;000032443;002;006387;0001;8,00008
		If len(aCampo) > 5
			DbSelectArea('SE1')
			DbSetorder(1)
			DbSeek(xFilial('SE1')+aCampo[1,1] + aCampo[2,1] + aCampo[3,1],.t.)
			If SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA == xFilial('SE1')+aCampo[1,1]    +aCampo[2,1]+aCampo[3,1]
				RecLock("SE1", .F.)
				SE1->E1_COMIS1 := VAL(aCampo[6,1])
				SE1->E1_BASCOM1 := SE1->E1_VALOR
				SE1->E1_VALCOM1 := (SE1->E1_COMIS1 * SE1->E1_VALOR) /100
				MsUnlock("SB1")
			EndIf
		EndIf
		FT_FSKIP()
	EndDo
EndIf
alert('acabou')
Return()


*************************
Static Function fVTM_10()
***************
Local nI 		:= 0 
Local aErroLog 	:= {}
local tLaco 	:= .T.
local aCab 		:= {}
local aItens 	:= {}
Local aParam 	:= {}

oModel      := Nil
alert('Importacao Ativo Fixo')
Procregua(1252)
sArqSB1 := "\miscelania\ativo_fixo.txt"
if file(sArqSB1)
	If (_nHa := FT_FUse(AllTrim(sArqSB1)))== -1
		msgbox("Arquivo Aberto, Favor Fechar!")
		Return
	EndIf
	FT_FGOTOP()
	While !FT_FEOF() .And. tLaco
        Incproc()
		sLinha := Alltrim(FT_FREADLN())
		sLinha := StrTran(sLinha, "'", "")
		sLinha := StrTran(sLinha, ",", ".")
		sCampo := ''
		aCampo := {}
		While Len(sLinha) > 0 
			nPos := AT(";",sLinha)
			If nPos > 0 
				sCampo := Left(sLinha,nPos - 1)
				steste := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := steste
			Else
				sCampo := Subs(sLinha,nPos + 1, len(sLinha))
				sLinha := ''
			EndIf
			Aadd(aCampo,{Alltrim(sCampo)} ) 
		EndDo
// 1        2        3        4        5         6                                                            7        8         9       0         1          2         3       4         5         6          17         18          19       20         21        22        23         24         25 
//N1_GRUPO;N1_CBASE;N1_ITEM;N1_AQUISIC;N1_QUANTD;N1_DESCRIC                                                 ;N1_CHAPA;N1_FORNEC;N1_LOJA;N1_NSERIE;N1_NFISCAL;N1_DTBLOQ;N3_TIPO;N3_HISTOR;N3_TPDEPR;N3_CUSTBEM;N3_CCONTAB;N3_CDEPREC;N3_CCUSTO;N3_CCDEPR;N3_DINDEPR;N3_VORIG1;N3_TXDEPR1;N3_VRDACM1;N3_AQUISIC
//0001    ;000001  ;0001   ;30/12/2015;1        ;SALDO TRANSF. IMOB. EM ANDAMENTO (AMP. FABRICA - BANHEIRO E;000001;000007;0001;001;000000001;30/12/2050;01;Import;1;80201;10203001002         ;40102007002         ;80201               ;40102007002         ;30/12/2015;484698,92;4;138947,03;30/12/2015

		lMsErroAuto := .F.
		lMsHelpAuto := .T.

        nTamBase := TamSX3("N3_CBASE")[1]
        nTamChapa := TamSX3("N3_CBASE")[1]
        aCab := {}
        AAdd(aCab,{"N1_GRUPO" 	, 	aCampo[1,1] ,NIL})
        AAdd(aCab,{"N1_CBASE" 	, 	aCampo[2,1] ,NIL})
        AAdd(aCab,{"N1_ITEM" 	, 	aCampo[3,1] ,NIL})
        AAdd(aCab,{"N1_AQUISIC"	, 	ctod(aCampo[4,1]) ,NIL})
        AAdd(aCab,{"N1_QUANTD" 	, 	val(aCampo[5,1]) ,NIL})
        AAdd(aCab,{"N1_DESCRIC"	, 	Left(aCampo[6,1],39) ,NIL})
        AAdd(aCab,{"N1_CHAPA" 	, 	aCampo[7,1] ,NIL})
        //AAdd(aCab,{"N1_FORNEC" 	, 	aCampo[8,1] ,NIL})
        //AAdd(aCab,{"N1_LOJA" 	, 	aCampo[9,1] ,NIL})
        //AAdd(aCab,{"N1_NSERIE" 	, 	aCampo[10,1] ,NIL})
        //AAdd(aCab,{"N1_NFISCAL" , 	aCampo[11,1] ,NIL})
        //AAdd(aCab,{"N1_DTBLOQ" 	, 	ctod(aCampo[12,1]) ,NIL})
        aItens := {}

// 1        2        3        4        5         6                                                            7        8         9       0         1          2         3       4         5         6          17         18          19       20         21        22        23         24         25 
//N1_GRUPO;N1_CBASE;N1_ITEM;N1_AQUISIC;N1_QUANTD;N1_DESCRIC                                                 ;N1_CHAPA;N3_TIPO;N3_HISTOR;N3_TPDEPR;N3_CUSTBEM;N3_CCONTAB;N3_CDEPREC;N3_CCUSTO;N3_CCDEPR;N3_DINDEPR;N3_VORIG1;N3_TXDEPR1;N3_VRDACM1;N3_AQUISIC
//0001    ;000001  ;0001   ;30/12/2015;1        ;SALDO TRANSF. IMOB. EM ANDAMENTO (AMP. FABRICA - BANHEIRO E;000001  ;     01;Import   ;1;80201;10203001002         ;40102007002         ;80201               ;40102007002         ;30/12/2015;484698,92;4;138947,03;30/12/2015


        AAdd(aItens,{;
        {"N3_CBASE" , aCampo[2,1] ,NIL},;
        {"N3_ITEM" , aCampo[3,1] ,NIL},;
        {"N3_TIPO" , aCampo[8,1] ,NIL},;
        {"N3_HISTOR" , aCampo[9,1] ,NIL},;
        {"N3_TPDEPR" ,'1' ,NIL},;               //// aCampo[10,1] ,NIL},;        //{"N3_CUSTBEM" , aCampo[11,1] ,NIL},;
        {"N3_CCONTAB" , Alltrim(aCampo[12,1]) ,NIL},;
        {"N3_CDEPREC" , Alltrim(aCampo[13,1]) ,NIL},;
        {"N3_CCUSTO" , "80201" ,NIL},;
        {"N3_CCDEPR" , Alltrim(aCampo[15,1]) ,NIL},;
        {"N3_DINDEPR" , ctod("30/06/2023") ,NIL},;
        {"N3_VORIG1" , val(aCampo[17,1]) ,NIL},;
        {"N3_TXDEPR1" , Val(aCampo[18,1]) ,NIL},;
        {"N3_VRDACM1" , Val(aCampo[19,1]) ,NIL},;
        {"N3_AQUISIC" , ctod(aCampo[4,1]) ,NIL}})

        Begin Transaction

            MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
            If lMsErroAuto 
			alert(aCampo[2,1])
            MostraErro()
                DisarmTransaction()
            Endif
        End Transaction

		FT_FSKIP()
	EndDo
EndIf
alert('acabou')
Return()
