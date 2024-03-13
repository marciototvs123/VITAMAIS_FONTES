#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"
#Include "ApWebSrv.ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "shell.ch"
#Include "TbiConn.ch"

/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	

User Function VIT004()
	Private cPerg		:= "VIT004"
	Default lSendMail  	:= .F.
	
	oPerg := TPergunta():New(cPerg)
	oPerg:AddGet  ("De  Lote  ?"	, "C", 10	, 0, Nil, "SB8PES"	, "@!", "")
	oPerg:AddGet  ("De  Emissao ?"	, "D", 8	, 0, Nil, ""	, "@!", "")
	oPerg:AddGet  ("Ate Emissao ?"	, "D", 8	, 0, Nil, ""	, "@!", "")
	oPerg:AddGet  ("Numero de copias ?"	, "N", 2, 0, Nil, ""	, "99", "")
	oPerg:Update()
	If oPerg:Execute(.T.)
		aLotes	:= {}
		MsgRun( "Capa De Lote", "Selecionando registros para Impressão", { || CallRegs(@aLotes)} )
		CallTela(@aLotes)
	EndIf
Return


/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	

Static Function CallRegs(aLotes)
	cQry	:= "SELECT SB1.B1_COD, SB1.B1_DESC, SB8.B8_LOTECTL, SB8.B8_DATA,SB8.B8_DTVALID,SB8.B8_SALDO "
	cQry	+= " FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SB8")+" SB8 "
	cQry	+= " WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB8.B8_FILIAL = '"+xFilial("SB8")+"' "
	cQry	+= " AND SB1.B1_COD =  SB8.B8_PRODUTO "
	cQry	+= " AND SB8.B8_LOTECTL = '" + Alltrim(mv_par01) + "' "
	cQry	+= " AND SB8.B8_DATA BETWEEN '" + Dtos(mv_par02) + "' AND '" + Dtos(mv_par03) + "'"
	cQry	+= " AND SB8.D_E_L_E_T_ = ' '"
	cQry	+= " ORDER BY SB1.B1_COD,SB8.B8_LOTECTL"

	If Select("SB8TMP") > 0
		dbSelectArea("SB8TMP")
		DbCloseArea()
	EndIf

	TCQUERY cQry NEW ALIAS "SB8TMP"

	dbSelectArea("SB8TMP")
	DbGotop()

	While SB8TMP->(!Eof())
		aAdd(aLotes, {	.F.,;						// 1=Mark
		SB8TMP->B1_COD,;		
		SB8TMP->B1_DESC,;		
		SB8TMP->B8_LOTECTL,;	
		STOD(SB8TMP->B8_DATA),;	
		STOD(SB8TMP->B8_DTVALID),;	
		TRANSF(SB8TMP->B8_SALDO,"@E 999,999.99")})
		SB8TMP->(dbSkip())
	End

	If Len(aLotes) == 0
		aAdd(aLotes, {"","","","","",0})
	EndIf

	If Select("SB8TMP") > 0
		dbSelectArea("SB8TMP")
		DbCloseArea()
	EndIf

Return(Nil)

/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function CallTela(aLotes)
	Local oDlg
	Local oList1
	Local oMark
	Local bCancel   := {|| RSB8TMP(oDlg,@lRetorno,aLotes,.F.) }
	Local bOk       := {|| RFINR01B(oDlg,@lRetorno,aLotes,.F.) }
	Local bSendmail := {|| RFINR01B(oDlg,@lRetorno,aLotes,.T.) }
	Local aAreaAtu	:= GetArea()
	Local aLabel	:= {" ","Produto","Descricao","Lote","Data Emissao","Vencimento","Saldo"}
	Local aBotao    := {}
	Local lRetorno	:= .T.
	Local lMark		:= .F.
	Local cList1
	Local cTitulo   := "Capa De Lote"
	Local lOrdem		:= .F.

	Private oOk			:= LoadBitMap(GetResources(),"LBOK")
	Private oNo			:= LoadBitMap(GetResources(),"LBNO")

	AADD(aBotao, {"S4WB011N" 	, { || U_VIT00401("SE1",SE1->(aLotes[oList1:nAt,15]),2)}, "[F12] - Visualiza Título", "Título" })
	SetKey(VK_F12,	{|| U_VIT00401("SE1",SE1->(aLotes[oLis1:nAt,15]),2)})

	DEFINE MSDIALOG oDlg TITLE cTitulo From 000,000 To 420,940 OF oMainWnd PIXEL
	@ 015,005 CHECKBOX oMark VAR lMark PROMPT "Marca Todos" FONT oDlg:oFont PIXEL SIZE 80,09 OF oDlg;
		ON CLICK (aEval(aLotes, {|x,y| aLotes[y,1] := lMark}), oList1:Refresh() )
	@ 030,003 LISTBOX oList1 VAR cList1 Fields HEADER ;
		aLabel[1],;
		aLabel[2],;
		aLabel[3],;
		aLabel[4],;
		aLabel[5],;
		aLabel[6],;
		aLabel[7];
		SIZE 463,175  NOSCROLL PIXEL
	oList1:SetArray(aLotes)
	oList1:bLine	:= {|| {	If(aLotes[oList1:nAt,1], oOk, oNo),;
		aLotes[oList1:nAt,2],;
		aLotes[oList1:nAt,3],;
		aLotes[oList1:nAt,4],;
		aLotes[oList1:nAt,5],;
		aLotes[oList1:nAt,6],;
		Transform(aLotes[oList1:nAt,7], "@E 999,999,999.99");
		}}

	oList1:blDblClick 	:= {|| aLotes[oList1:nAt,1] := !aLotes[oList1:nAt,1], oList1:Refresh() }
	oList1:cToolTip		:= "1a. Opção > Duplo click para marcar/desmarcar o Lotes." + Chr(13)+Chr(10) + Chr(13)+Chr(10) + "2a. Opção > Click na Coluna e Depois Sobre o Cabeçalho para Ordenar."
	oList1:bHeaderClick := {|| oList1:Refresh() , MaOrdCab(@oList1,@lOrdem), oList1:Refresh() }
	oList1:Refresh()

	@ 15,080 BMPBUTTON TYPE 01 ACTION RFINR01B(oDlg,@lRetorno,aLotes,.F.)
	@ 15,110 BMPBUTTON TYPE 02 ACTION RSB8TMP(oDlg,@lRetorno,aLotes,.F.)

//	oEmail := TButton():New(15,150,"Enviar boleto via E-mail" ,oDlg,{|| RFINR01B(oDlg,@lRetorno,aLotes,.T.) }, 60 , 11 ,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg CENTERED //ON INIT EnchoiceBar(oDlg,bOk,bcancel,,aBotao)

	SetKey(VK_F12,	Nil)

Return(lRetorno)


/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function RSB8TMP(oDlg,lRetorno, aLotes)

	lRetorno := .F.

	oDlg:End()

Return(lRetorno)

/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function RFINR01B(oDlg,lRetorno, aLotes,lSendMail)

	Local nLoop		:= 0
	Local nContador	:= 0

	lRetorno := .T.

	For nLoop := 1 To Len(aLotes)
		If aLotes[nLoop,1]
			nContador++
		EndIf
	Next

	If nContador > 0
		ImpLote(aLotes,lSendMail)
	Else
		lRetorno := .F.
	EndIf

	oDlg:End()

Return(lRetorno)


/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
User Function VIT00401(cAlias, nRecAlias, nOpcEsc)

	Local aAreaAtu	:= GetArea()
	Local aAreaAux	:= (cAlias)->(GetArea())

	If !Empty(nRecAlias)
		dbSelectArea(cAlias)
		dbSetOrder(1)
		dbGoTo(nRecAlias)
		AxVisual(cAlias,nRecAlias,nOpcEsc)
	EndIf

	RestArea(aAreaAux)
	RestArea(aAreaAtu)

Return(Nil)

/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/			
Static Function ImpLote(aLotes,lSendMail)
	Local oPrint
	local nLoop := 0 
	local Nx := 0 
	Private cNomeArq  := ""
	Private cCaminho  := Alltrim(GetMv("VS_FLDBOL",,"\caplote\"))
	Private cDirTmp   := Alltrim(GetTempPath())

	cNomeArq := "cplote_"+StrTran(Time(),":","")

	If File(cCaminho+cNomeArq+".pdf")
		FErase( cCaminho+cNomeArq+".pdf" )
	Endif

	If File(cDirTmp+cNomeArq+".pdf")
		FErase( cCaminho+cNomeArq+".pdf" )
	Endif

	oPrint := FwMSPrinter():New( cNomeArq, 6 , .T. , cDirTmp , .T., , , , , .F., ,.F. )
	oPrint:cPathPDF := cDirTmp
	oPrint:SetPortrait()					// Modo retrato
	oPrint:SetPaperSize(9)					// Papel A4
	oPrint:lInJob:= .T.

	If .NOT. ExistDir("\caplote")
		nRet := MakeDir("\caplote")
		if nRet != 0
			Aviso("Atenção","Não foi possível criar o diretório boletos. Erro: " + cValToChar(FError()), {"Ok"} )
			Return
		Endif
	Endif
	
	nX := 0
	For Nx := 1 to MV_PAR04
		For nLoop := 1 To Len(aLotes)
			If aLotes[nLoop,1]
				Impress(oPrint,aLotes[nLoop,2],aLotes[nLoop,3],aLotes[nLoop,4],aLotes[nLoop,5],aLotes[nLoop,6],aLotes[nLoop,7])
			EndIf
		Next nLoop
	Next nX

	If !lSendMail
		oPrint:SetViewPDF(.T.)
	Else
		If lView
			oPrint:SetViewPDF(.T.)
		Else
			oPrint:SetViewPDF(.F.)
		Endif
	Endif

	oPrint:Print()
	if lSendMail
		cSubject := "Boleto Bancário"

		cEmail   := cEmail

		cHtml := " Prezado cliente "+cNomCli+", "+Chr(13)+chr(10)
		cHtml += " Estamos enviando em anexo o boleto bancário para pagamento."+Chr(13)+chr(10)
		cHtml += " "+Chr(13)+chr(10)
		cHtml += " Atenciosamente, "+Chr(13)+chr(10)
		cHtml += "                 "+SM0->M0_NOMECOM+Chr(13)+chr(10)

		ATEnvMail( cHtml , cEmail , cSubject , { cNomeArq +".pdf" } )
	Endif

Return(Nil)

/*/{Protheus.doc}''
''
@author Julio Nobre
@since ''
@version ''
@type function
@see ''
@obs ''
@param ''
@return ''
/*/	
Static Function Impress(oPrint,sB1_COD,sB1_DESC,sB8_LOTECTL,dB8_DATA,dB8_DTVALID,nB8_SALDO)
	LOCAL oFont8
	LOCAL oFont8n
	LOCAL oFont11c
	LOCAL oFont10
	LOCAL oFont14
	LOCAL oFont16n
	LOCAL oFont15
	LOCAL oFont14n
	LOCAL oFont24
	LOCAL nI 		:= 0
	Local nRow		:= 0
	Local cBmp		:= ""

	oFont8		:= TFont():New("Arial",		9,08,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont8n		:= TFont():New("Arial",		9,08,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11c	:= TFont():New("Courier New",	9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10		:= TFont():New("Arial",		9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12		:= TFont():New("Arial",		9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14		:= TFont():New("Arial",		9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20		:= TFont():New("Arial",		9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont25		:= TFont():New("Courier New",		9,25,.T.,.T.,6,.T.,6,.T.,.F.)
	oFont21		:= TFont():New("Arial",		9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n	:= TFont():New("Arial",		9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15		:= TFont():New("Arial",		9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n	:= TFont():New("Arial",		9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n	:= TFont():New("Arial",		9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24		:= TFont():New("Arial",		9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:StartPage()   // Inicia uma nova página
	nRow := 0
	nC1 := 100
// 	                oPrint:SayBitmap(2115,0100,aDadosBanco[7],060,060)


	oPrint:SayBitMap(nRow+100,100,"lgrl01.bmp",450,150)
	oPrint:Line (nRow+nC1,0600,nRow+nC1,2300)													// horizontal
	oPrint:Line (nRow+nC1,0600,nRow+0280,0600)													// vertical
	oPrint:Line (nRow+nC1,2300,nRow+0280,2300)													// vertical
	oPrint:Line (nRow+0280,0600,nRow+0280,2300)													// vertical
	
	oPrint:Say  (nRow+200,1000,"Identificacao do Produto",									oFont25)	// Texto Fixo
	
	oPrint:Line (nRow+0300,nC1,nRow+0300,2300)													// horizontal
	//oPrint:Line (nRow+0300,nC1,nRow+0500,nC1)													// vertical
	//oPrint:Line (nRow+0300,2300,nRow+0500,2300)													// vertical
	oPrint:Line (nRow+0500,nC1,nRow+0500,2300)													// vertical
	oPrint:Say  (nRow+0350,0120 ,"PRODUTO",										oFont20)	// Texto Fixo
	oPrint:Say  (nRow+0450,0120 ,"ACABADO",										oFont20)	// Texto Fixo
	oPrint:Line (nRow+0300,0600,nRow+0500,0600)													// vertical
	oPrint:Line (nRow+0500,nC1,nRow+0500,2300)													// vertical
	oPrint:Say  (nRow+0430,0800 ,Left(sB1_DESC,40),										oFont20)	// Texto Fixo
	
	nl1 := 530
	nl2 := 730
	nC2 := 1100

	oPrint:Line (nRow+nl1,nC1,nRow+nl1,nC2)													// horizontal
	oPrint:Line (nRow+nl1,nC2,nRow+nl2,nC2)													// vertical
	oPrint:Line (nRow+nl2,nC1,nRow+nl2,nC2)													// vertical
	oPrint:Line (nRow+nl1,nC1+500,nRow+nl2,nC1+500)													// vertical
	oPrint:Say  (nRow+nl1+100,nC1+20  ,"CÓDIGO",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+100,nC1+600 ,sB1_COD,	  									oFont20)	// Texto Fixo
	
	nl1 := 530
	nl2 := 730
	nC2 := 2300
	nC1 := 1200

	oPrint:Line (nRow+nl1,nC1,nRow+nl1,nC2)													// horizontal
	oPrint:Line (nRow+nl1,nC1,nRow+nl2,nC1)													// vertical
	oPrint:Line (nRow+nl2,nC1,nRow+nl2,nC2)													// vertical
	oPrint:Line (nRow+nl1,nC1+500,nRow+nl2,nC1+500)													// vertical
	oPrint:Say  (nRow+nl1+100,nC1+20  ,"LOTE",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+100,nC1+600 ,sB8_LOTECTL,	  									oFont20)	// Texto Fixo

    nl1 := 760
	nl2 := 900
	nC2 := 2300
	nC1 := 100

	oPrint:Line (nRow+nl1,nC1,nRow+nl1,nC2)													// horizontal
	oPrint:Line (nRow+nl2,nC1,nRow+nl2,nC2)													// vertical
	oPrint:Line (nRow+nl1,nC1+1100,nRow+nl2,nC1+1100)													// vertical
	oPrint:Say  (nRow+nl1+90,nC1+100  ,"DATA DA PRODUCAO",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+90,nC1+1700 ,DTOC(dB8_DATA),	  									oFont20)	// Texto Fixo

    nl1 := 930
	nl2 := 1070
	nC2 := 2300
	nC1 := 100

	oPrint:Line (nRow+nl1,nC1,nRow+nl1,nC2)													// horizontal
	oPrint:Line (nRow+nl2,nC1,nRow+nl2,nC2)													// vertical
	oPrint:Line (nRow+nl1,nC1+1100,nRow+nl2,nC1+1100)													// vertical
	oPrint:Say  (nRow+nl1+90,nC1+100  ,"DATA DO VENCIMENTO",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+90,nC1+1700 ,DTOC(dB8_DTVALID),	  									oFont20)	// Texto Fixo

    nl1 := 1100
	nl2 := 1240
	nC2 := 2300
	nC1 := 100

	oPrint:Line (nRow+nl1,nC1,nRow+nl1,nC2)													// horizontal
	oPrint:Line (nRow+nl2,nC1,nRow+nl2,nC2)													// vertical
	oPrint:Say  (nRow+nl1+90,nC1+700  ,"SITUAÇÃO DO PRODUTO",	  									oFont25)	// Texto Fixo

    nl1 := 1270
	nl2 := 1530
	nC1 := 100
	nC2 := 2300

	oPrint:Line (nRow+nl1,nC1,nRow+nl1,nC2)													// horizontal
	oPrint:Line (nRow+nl2,nC1,nRow+nl2,nC2)													// vertical
	oPrint:Say  (nRow+nl1+070,nC1+20  ,"[       ]   EM ANALISE ",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+140,nC1+20  ,"[       ]    LIBERADO ",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+210,nC1+20  ,"[       ]   REPROVADO ",	  									oFont20)	// Texto Fixo
	oPrint:Line (nRow+nl1,nC1+1100,nRow+nl2,nC1+1100)													// vertical

	oPrint:Say  (nRow+nl1+070,nC1+1100+20,"[       ]   REPROCESSAR ",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+140,nC1+1100+20,"[       ]    DESCARTAR  ",	  									oFont20)	// Texto Fixo
	oPrint:Say  (nRow+nl1+210,nC1+1100+20,"[       ]   PRODUTO NAO CONFORME ",	    						oFont20)	// Texto Fixo


	nl1 := 1560
	nl2 := 1700
	nC2 := 2300
	nC1 := 100

	oPrint:Line (nRow+nl1,nC1,nRow+nl1,nC2)													// horizontal
	oPrint:Line (nRow+nl2,nC1,nRow+nl2,nC2)													// vertical
	oPrint:Say  (nRow+nl1+90,nC1+20  ,"RESPONSAVEL:",	  									oFont25)	// Texto Fixo
	oPrint:Line (nRow+nl1,nC1+1100,nRow+nl2,nC1+1100)													// vertical
	oPrint:Say  (nRow+nl1+070,nC1+1100+20,UsrRetName(__cUserId),	  									oFont20)	// Texto Fixo
	

	nl1 := 0
	nl2 := 1700
	nC2 := 2300
	nC1 := 100

	oPrint:Line (nRow+300,nC1,nRow+nl2,nC1)													// horizontal
	oPrint:Line (nRow+300,nC2,nRow+nl2,nC2)													// horizontal

	oPrint:EndPage()
Return

