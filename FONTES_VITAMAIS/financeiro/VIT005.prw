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

User Function VIT005()
	Local aSays     	:= {}
	Local aButtons  	:= {}
	Local cCadastro  	:= OemToAnsi("Impressão Boletos Bancarios BANCO DO BRASIL.")
	Private cPerg		:= "BOLFINR001"
	Default lSendMail  := .F.

	AjusPerg(cPerg)
	Pergunte(cPerg,.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta tela principal                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	AAdd(aSays,OemToAnsi("Impressão de Boletos Bancarios."	))
	AAdd(aSays,OemToAnsi("Imprimir Boleto Bancario conforme banco selecionado.Deseja executa-lo agora?"))
	AAdd(aButtons, { 5,.T.	,{|| Pergunte(cPerg,.T. )				}})
	AADD(aButtons, { 1,.T.	,{|o| (ExecBol(),o:oWnd:End())}})
	AADD(aButtons, { 2,.T.	,{|o| o:oWnd:End()						}})

	FormBatch( cCadastro, aSays,aButtons )
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
Static Function ExecBol
	Local aTitulos	:= {}
	Private cStatus := 1
	Private lEnd	:= .F.

	MsgRun( "Títulos a Receber", "Selecionando registros para Impressão dos Boletos", { || CallRegs(@aTitulos)} )
	If Len(aTitulos) > 0 
		U_VIT005A(@aTitulos)
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

Static Function CallRegs(aTitulos)

	Local cQry	:= "SELECT"
	cQry	+= " SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_NATUREZ,SE1.E1_CLIENTE,SE1.E1_LOJA,"
	cQry	+= " SE1.E1_NOMCLI,SE1.E1_EMISSAO,SE1.E1_VENCTO,SE1.E1_VENCREA,SE1.E1_VALOR,SE1.E1_HIST,SE1.E1_NUMBCO,"
	cQry	+= " R_E_C_N_O_ AS E1_REGSE1"
	cQry	+= " FROM "+RetSqlName("SE1")+" SE1 "
	cQry	+= " WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
	cQry	+= " AND SE1.E1_PREFIXO BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
	cQry	+= " AND SE1.E1_NUM BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
	cQry	+= " AND SE1.E1_PARCELA BETWEEN '"+mv_par05+"' AND '"+mv_par06+"'"
	cQry	+= " AND SE1.E1_TIPO BETWEEN '"+mv_par07+"' AND '"+mv_par08+"'"
	cQry	+= " AND SE1.E1_CLIENTE BETWEEN '"+mv_par09+"' AND '"+mv_par10+"'"
	cQry	+= " AND SE1.E1_LOJA BETWEEN '"+mv_par11+"' AND '"+mv_par12+"'"
	cQry	+= " AND SE1.E1_EMISSAO BETWEEN '"+DTOS(mv_par13)+"' AND '"+DTOS(mv_par14)+"'"
	cQry	+= " AND SE1.E1_VENCTO BETWEEN '"+DTOS(mv_par15)+"' AND '"+DTOS(mv_par16)+"'"
	cQry	+= " AND SE1.E1_NATUREZ BETWEEN '"+mv_par17+"' AND '"+mv_par18+"'"
	cQry	+= " AND SE1.E1_SALDO > 0 "
//	If MV_PAR22 == 1
//		cQry	+= " AND SE1.E1_PORTADO = ''
//	Else
//		cQry	+= " AND SE1.E1_PORTADO <> '' "
//	EndIf	
	cQry	+= " AND SE1.E1_NUMBOR >= '"+MV_PAR20+"' AND SE1.E1_NUMBOR <= '"+MV_PAR21+"' "
	If MV_PAR19 == 1
		cQry	+= " AND SE1.E1_NUMBCO <> ' '"
	Else
		cQry	+= " AND SE1.E1_NUMBCO = ' '"
	EndIf
	cQry	+= " AND SE1.E1_TIPO NOT IN('"+MVABATIM+"')"
	cQry	+= " AND SE1.D_E_L_E_T_ = ' '"
	cQry	+= " ORDER BY SE1.E1_NUM,SE1.E1_PARCELA"

	If Select("FINR01A") > 0
		dbSelectArea("FINR01A")
		DbCloseArea()
	EndIf

	TCQUERY cQry NEW ALIAS "FINR01A"

	TCSETFIELD("FINR01A", "E1_EMISSAO",	"D",08,0)
	TCSETFIELD("FINR01A", "E1_VENCTO",	"D",08,0)
	TCSETFIELD("FINR01A", "E1_VENCREA",	"D",08,0)
	TCSETFIELD("FINR01A", "E1_VALOR", 	"N",14,2)
	TCSETFIELD("FINR01A", "E1_REGSE1",	"N",10,0)

	dbSelectArea("FINR01A")
	DbGotop()

	While FINR01A->(!Eof())
		aAdd(aTitulos, {	.F.,;						// 1=Mark
		FINR01A->E1_PREFIXO,;		// 2=Prefixo do Título
		FINR01A->E1_NUM,;			// 3=Número do Título
		FINR01A->E1_PARCELA,;		// 4=Parcela do Título
		FINR01A->E1_TIPO,;			// 5=Tipo do Título
		FINR01A->E1_NATUREZ,;		// 6=Natureza do Título
		FINR01A->E1_CLIENTE,;		// 7=Cliente do título
		FINR01A->E1_LOJA,;			// 8=Loja do Cliente
		FINR01A->E1_NOMCLI,;		// 9=Nome do Cliente
		FINR01A->E1_EMISSAO,;		//10=Data de Emissão do Título
		FINR01A->E1_VENCTO,;		//11=Data de Vencimento do Título
		FINR01A->E1_VENCREA,;		//12=Data de Vencimento Real do Título
		FINR01A->E1_VALOR,;			//13=Valor do Título
		FINR01A->E1_HIST,;			//14=Histótico do Título
		FINR01A->E1_REGSE1,;		//15=Número do registro no arquivo
		FINR01A->E1_NUMBCO ;		//16=Nosso Número
		})
		FINR01A->(dbSkip())
	End

	If Len(aTitulos) == 0
		aAdd(aTitulos, {.F.,"","","","","","","","","","","",0,"",0,""})
	EndIf

	If Select("FINR01A") > 0
		dbSelectArea("FINR01A")
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
USer Function VIT005A(aTitulos)
	Local oDlg
	Local oList1
	Local oMark
	Local bCancel   := {|| RFINR01A(oDlg,@lRetorno,aTitulos,.F.) }
	Local bOk       := {|| RFINR01B(oDlg,@lRetorno,aTitulos,.F.,.T.) }
	Local bSendmail := {|| RFINR01B(oDlg,@lRetorno,aTitulos,.T.,.F.) }
	Local aAreaAtu	:= GetArea()
	Local aLabel	:= {" ","Prefixo","Número","Parcela","Tipo","Natureza","Cliente","Loja","Nome Cliente","Emissão","Vencimento","Venc.Real","Valor","Histórico","Nosso Número"}
	Local aBotao    := {}
	Local lRetorno	:= .T.
	Local lMark		:= .F.
	Local cList1
	Local cTitulo   := "Boletos Bancarios"
	Local lOrdem		:= .F.

	Private oOk			:= LoadBitMap(GetResources(),"LBOK")
	Private oNo			:= LoadBitMap(GetResources(),"LBNO")

	AADD(aBotao, {"S4WB011N" 	, { || U_BOLVETIT("SE1",SE1->(aTitulos[oList1:nAt,15]),2)}, "[F12] - Visualiza Título", "Título" })
	SetKey(VK_F12,	{|| U_BOLVETIT("SE1",SE1->(aTitulos[oLis1:nAt,15]),2)})

	DEFINE MSDIALOG oDlg TITLE cTitulo From 000,000 To 420,940 OF oMainWnd PIXEL
	@ 015,005 CHECKBOX oMark VAR lMark PROMPT "Marca Todos" FONT oDlg:oFont PIXEL SIZE 80,09 OF oDlg;
		ON CLICK (aEval(aTitulos, {|x,y| aTitulos[y,1] := lMark}), oList1:Refresh() )
	@ 030,003 LISTBOX oList1 VAR cList1 Fields HEADER ;
		aLabel[1],;
		aLabel[2],;
		aLabel[3],;
		aLabel[4],;
		aLabel[5],;
		aLabel[6],;
		aLabel[7],;
		aLabel[8],;
		aLabel[9],;
		aLabel[10],;
		aLabel[11],;
		aLabel[12],;
		aLabel[13],;
		aLabel[14],;
		aLabel[15] ;
		SIZE 463,175  NOSCROLL PIXEL
	oList1:SetArray(aTitulos)
	oList1:bLine	:= {|| {	If(aTitulos[oList1:nAt,1], oOk, oNo),;
		aTitulos[oList1:nAt,2],;
		aTitulos[oList1:nAt,3],;
		aTitulos[oList1:nAt,4],;
		aTitulos[oList1:nAt,5],;
		aTitulos[oList1:nAt,6],;
		aTitulos[oList1:nAt,7],;
		aTitulos[oList1:nAt,8],;
		aTitulos[oList1:nAt,9],;
		aTitulos[oList1:nAt,10],;
		aTitulos[oList1:nAt,11],;
		aTitulos[oList1:nAt,12],;
		Transform(aTitulos[oList1:nAt,13], "@E 999,999,999.99"),;
		aTitulos[oList1:nAt,14],;
		aTitulos[oList1:nAt,16] ;
		}}

	oList1:blDblClick 	:= {|| aTitulos[oList1:nAt,1] := !aTitulos[oList1:nAt,1], oList1:Refresh() }
	oList1:cToolTip		:= "1a. Opção > Duplo click para marcar/desmarcar o títulos." + Chr(13)+Chr(10) + Chr(13)+Chr(10) + "2a. Opção > Click na Coluna e Depois Sobre o Cabeçalho para Ordenar."
	oList1:bHeaderClick := {|| oList1:Refresh() , MaOrdCab(@oList1,@lOrdem), oList1:Refresh() }
	oList1:Refresh()

	@ 15,080 BMPBUTTON TYPE 01 ACTION RFINR01B(oDlg,@lRetorno,aTitulos,.F.,.T.)
	@ 15,110 BMPBUTTON TYPE 02 ACTION RFINR01A(oDlg,@lRetorno,aTitulos,.F.)

	oEmail := TButton():New(15,150,"Enviar boleto via E-mail" ,oDlg,{|| RFINR01B(oDlg,@lRetorno,aTitulos,.T.,.F.) }, 60 , 11 ,,,.F.,.T.,.F.,,.F.,,,.F. )

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
Static Function RFINR01A(oDlg,lRetorno, aTitulos)

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
Static Function RFINR01B(oDlg,lRetorno, aTitulos,lSendMail,lView)

	Local nLoop		:= 0
	Local nContador	:= 0
	Local lFim		:= .F.

	lRetorno := .T.

	For nLoop := 1 To Len(aTitulos)
		If aTitulos[nLoop,1]
			nContador++
		EndIf
	Next

	If nContador > 0
		MsAguarde({|lFim| ImpBol(aTitulos,lView,lSendMail)},"Processamento","Aguarde a finalização do processamento...")

//		ImpBol(aTitulos,lView,lSendMail)
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
User Function BOLVETIT(cAlias, nRecAlias, nOpcEsc)

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
Static Function ImpBol(aTitulos,lView,lSendMail)

	If lSendMail
		nOpx := Aviso("Atenção","Deseja Imprimir os boletos antes de enviar ?" , {"Sim","Não"} )
		If nOpx==1
			lView := .T.
		Endif
	Endif
	If .NOT. ExistDir("\boletos")
		nRet := MakeDir("\boletos")
		if nRet != 0
			Aviso("Atenção","Não foi possível criar o diretório boletos. Erro: " + cValToChar(FError()), {"Ok"} )
			Return
		Endif
	Endif

	If lSendMail
		fImpBol(aTitulos,.F.,lSendMail) // Manda Enviar Email em unico Arquvio
	EndIf
	If lView
		fImpBol(aTitulos,lView,.F.) // Manda Imprimnir Boleto em unico Arquvio
	EndIf
Return(Nil)


// Funccao para imprimir boleto e enviar email, quando imprimir boleto imprimir tudo em unico arquivo, quando email em varios arquivos
Static Function fImpBol(aTitulos,lView,lSendMail)
	Local oPrint
	Local aEmpresa	:= {	AllTrim(SM0->M0_NOMECOM),;																//[1]Nome da Empresa
	AllTrim(SM0->M0_ENDCOB),;																//[2]Endereço
	AllTrim(SM0->M0_BAIRCOB),;																//[3]Bairro
	AllTrim(SM0->M0_CIDCOB),;																//[4]Cidade
	SM0->M0_ESTCOB,;																		//[5]Estado
	"CEP: "+Transform(SM0->M0_CEPCOB, "@R 99999-999"),;									//[6]CEP
	"PABX/FAX: "+SM0->M0_TEL,;																//[7]Telefones
	"CNPJ: "+Transform(SM0->M0_CGC, "@R 99.999.999/9999-99"),;								//[8]CGC
	"I.E.: "+Transform(SM0->M0_INSC, SuperGetMv("MV_IEMASC",.F.,"@R 999.999.999.999")) ;	//[9]I.E
	}
	Local aDadTit	:= {}
	Local aBanco	:= {}
	Local aSacado	:= {}
	Local aBolTxt	:= {"","","","","",""}
	Local aMensag	:= {}
	Local nI		:= 1
	Local nVlrAbat	:= 0
	Local nAcresc	:= 0
	Local nDecres	:= 0
	Local nSaldo	:= 0
	Local nX		:= 0
	Local nLoop		:= 0
	Local nLoop1	:= 0
	Local cNNum		:= ""
	Local cNNdig	:= ""
	Local cQry		:= ""
	Local aDadFat	:= {}
	Local nCnt		:= 0
	Local nLoop2	:= 0
	Local cFAXATU   :=""
	Local nTipo     := 2
	Local nOpx      := 0
	Local aAnexos   := {}
	Local nBols     := 1
	Local cEmail    := ""
	Local cNomCli   := ""
	Local aCB_RN_NN	:= {}
	Local nVlJuro	:= GetMv("MV_TXPER") //SuperGetMV("MV_TXPER",.T.,1)
	Local nVlMulta	:= 0//SuperGetMV("MV_YPERCMT",.T.,2)
	
	Private cNomeArq  := ""
	Private cCaminho  := Alltrim(GetMv("VS_FLDBOL",,"\boletos\"))
	Private cDirTmp   := Alltrim(GetTempPath())

	If lView
		cNomeArq := "boleto_"+StrTran(Time(),":","")+StrZero(nLoop,2)
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
	EndIf
	For nLoop := 1 To Len(aTitulos)
		If aTitulos[nLoop,1]
			dbSelectArea("SE1")
			dbGoTo(aTitulos[nLoop,15])
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
			If Empty(SA1->A1_EMAIL) .And. lSendMail
				Aviso("Atenção","Informar o e-mail do cliente no cadastro de cliente para envio, cliente: "+SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME , {"Ok"} )
			Else
				cEmail := Alltrim(SA1->A1_EMAIL)
				cNomCli:= Alltrim(SA1->A1_NOME)
			Endif
			tPassa := .T.
			
			IF TYPE ("MV_PAR22") <> "U"
				If MV_PAR22 == 1
					tPassa := .F.
					DbSelectArea("SA6")
					DbSetOrder(1)
					If !DbSeek(xFilial("SA6")+Padr(MV_PAR23,TamSx3("A6_COD")[1])+Padr(MV_PAR24,TamSx3("A6_AGENCIA")[1])+Padr(MV_PAR25,TamSx3("A6_CONTA")[1]))
						Aviso(	"Emissão do Boleto",;
							"Banco não localizado no cadastro!",;
							{"&Ok"},,;
							"Banco: "+MV_PAR23+"/"+MV_PAR24+"/"+MV_PAR25 )
						Loop
					EndIf
				EndIf
			EndIf

			If tPassa
				DbSelectArea("SA6")
				DbSetOrder(1)
				If !DbSeek(xFilial("SA6")+Padr(SE1->E1_PORTADO,TamSx3("A6_COD")[1])+Padr(SE1->E1_AGEDEP,TamSx3("A6_AGENCIA")[1])+Padr(SE1->E1_CONTA,TamSx3("A6_CONTA")[1]))
					Aviso(	"Emissão do Boleto",;
						"Banco não localizado no cadastro!",;
						{"&Ok"},,;
						"Banco: "+SE1->E1_PORTADO+"/"+SE1->E1_AGEDEP+"/"+SE1->E1_CONTA )
					Loop
				EndIf
			EndIf

			//POSICIONA SEE PARA BUSCAR MENSAGENS - SUBCONTA 001 PADRAO
			DbSelectArea("SEE")
			DbSetOrder(1)
			DbSeek(xFilial("SEE")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON + "001")

			cFAXATU:=_RetSEE(SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON,"001")

			If Empty(cFAXATU)
				Alert("Configuração dos parametros do banco não foram localizados.")
				Return
			Endif
			If lSendMail
				cNomeArq := "boleto_"+StrTran(Time(),":","")+StrZero(nLoop,2)
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
			EndIf	

			DbSelectArea("SE1")
			aBanco  := {	SA6->A6_COD,;	   												// [1]Numero do Banco
			SA6->A6_NREDUZ,;												// [2]Nome do Banco
			Alltrim(SA6->A6_AGENCIA),;  								    // [3]Agência
			Alltrim(SA6->A6_NUMCON) ,;                        			    // [4]Conta Corrente
			Alltrim(SA6->A6_DVCTA)  }			                            // [5]Dígito da conta corrente

			If Empty(SA1->A1_ENDCOB)
				aSacado   := {	iif(Alltrim(SA1->A1_PESSOA)=="J",AllTrim(/*12/11/2020 SA1->A1_NREDUZ*/SA1->A1_NOME),AllTrim(SA1->A1_NOME) ),;										// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;		    	  	// [2]Código
				AllTrim(SA1->A1_END )+" - "+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereço
				AllTrim(SA1->A1_MUN ),;										// [4]Cidade
				SA1->A1_EST,;												// [5]Estado
				SA1->A1_CEP,;												// [6]CEP
				SA1->A1_CGC,;												// [7]CGC
				SA1->A1_PESSOA }											// [8]PESSOA

			Else
				aSacado   := {	iif(Alltrim(SA1->A1_PESSOA)=="J",AllTrim(/*12/11/2020 SA1->A1_NREDUZ*/SA1->A1_NOME),AllTrim(SA1->A1_NOME) ) ,;										// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;					// [2]Código
				AllTrim(SA1->A1_ENDCOB)+" - "+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereço
				AllTrim(SA1->A1_MUNC),;										// [4]Cidade
				SA1->A1_ESTC,;												// [5]Estado
				SA1->A1_CEPC,;												// [6]CEP
				SA1->A1_CGC,;												// [7]CGC
				SA1->A1_PESSOA }											// [8]PESSOA
			Endif

			// Define o valor do título considerando Acréscimos e Decrescimos
			nSaldo	:= U_BOLFR01D(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA)[1]


			// Define o Nosso Número
			If !Empty(SE1->E1_NUMBCO)
				cNNum	:= AllTrim(SE1->E1_NUMBCO)
			Else
				Do Case
						Case SEE->EE_CODIGO = '001'
								cConvenio := '1914568'
								sMv_NN001 := GetMv("MV_NN001")
								putmv("MV_NN001",StrZero(Val(sMv_NN001)+1,10))
								cNNum  := sMv_NN001
								RecLock('SE1',.f.)
									IF TYPE ("MV_PAR22") <> "U"
										If MV_PAR22 == 1
											SE1->E1_PORTADO	:= SA6->A6_COD
											SE1->E1_AGEDEP 	:= SA6->A6_AGENCIA
											SE1->E1_CONTA	:= SA6->A6_NUMCON
										EndIf
									EndIf
									SE1->E1_NUMBCO:= cNNum
								MsUnlock('SE1')
						Case SEE->EE_CODIGO = '237' //205651 - Boleto Itau
								//09 - codigo da carteira
								cNNum := '09' + StrZero(Val(GetMv("MV_NN237")),11)
								putmv("MV_NN237",StrZero(Val(GetMv("MV_NN237"))+1,10))
								nX := 0
								nCont := 2
								nSoma := 0
								For nX := 1 to len(cNNum)
									nSoma += Val(SubStr(cNNum, nX, 1)) * nCont
									nCont -= 1
									If nCont < 2
										nCont := 7
									EndIf
								Next nX
								nDig := nSoma - (Int(nSoma/11)*11)
								If nDig == 1
									cNNdig := 'P'
								ElseIf nDig == 0
									cNNdig := '0'
								Else
									cNNdig := Alltrim(str(11 - nDig ))
								EndIf
								RecLock('SE1',.f.)
									IF TYPE ("MV_PAR22") <> "U"
										If MV_PAR22 == 1
											SE1->E1_PORTADO	:= SA6->A6_COD
											SE1->E1_AGEDEP 	:= SA6->A6_AGENCIA
											SE1->E1_CONTA	:= SA6->A6_NUMCON
										EndIf
									EndIf
									SE1->E1_NUMBCO:= cNNum+cNNdig
								MsUnlock('SE1')
				End Case
			EndIf

			dbSelectArea("SE1")

			//Monta codigo de barras
			aCB_RN_NN := Ret_cBarra(	Subs(aBanco[1],1,3),;			// [1]-Banco
			aBanco[3]	,;							// [2]-Agencia
			aBanco[4]	,;							// [3]-Conta
			aBanco[5]	,;							// [4]-Digito Conta
			cNNum		,;							// [6]-Nosso Número
			nSaldo		,;							// [7]-Valor do Título
			SE1->E1_VENCREA )					// [8]-Vencimento

			dbSelectArea("SE1")

			aDadTit	:= {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA)+Alltrim(E1_TIPO),;			// [1] Número do título
			E1_EMISSAO	,;									// [2] Data da emissão do título
			dDataBase	,;									// [3] Data da emissão do boleto
			E1_VENCREA	,;									// [4] Data do vencimento
			nSaldo		,;									// [5] Valor do título
			aCB_RN_NN[3],;									// [6] Nosso número (Ver fórmula para calculo)
			E1_PREFIXO	,;									// [7] Prefixo da NF
			""			,;									// [8] Tipo do Titulo
			""}												// [9] HISTORICO DO TITULO

			aBolTxt[1]	:= "JUROS DE R$ " + Alltrim(Transform((nSaldo  * (nVlJuro / 100)), "@E 999,999.9999"))+ " AO DIA A PARTIR DE " + DtoC(aDadTit[4]+1)
			//aBolTxt[1]	:= "JUROS DE R$ " + Alltrim(Transform((SE1->E1_SALDO*(0.000333333)), "@E 999,999.99"))+ " AO DIA A PARTIR DE " + DtoC(aDadTit[4]+1)
			//aBolTxt[2]	:= "MULTA DE " + cValTochar(nVlMulta) + " % A PARTIR DE " + DtoC(aDadTit[4]+1)
			aBolTxt[3] := SubStr(If(Empty(&(SEE->EE_FORMEN1)), '', &(SEE->EE_FORMEN1)), 1, 165)
			aBolTxt[4] := SubStr(If(Empty(&(SEE->EE_FORMEN2)), '', &(SEE->EE_FORMEN2)), 1, 165)
			aBolTxt[5] := SubStr(If(Empty(&(SEE->EE_FOREXT1)), '', &(SEE->EE_FOREXT1)), 1, 165)
			aBolTxt[6] := SubStr(If(Empty(&(SEE->EE_FOREXT2)), '', &(SEE->EE_FOREXT2)), 1, 165)

			Impress(oPrint,aEmpresa,aDadTit,aBanco,aSacado,aBolTxt,aCB_RN_NN,cNNum,nTipo, @nBols)
			If lSendMail
				oPrint:SetViewPDF(.F.)
				oPrint:Print()
				sEmailCC  := GetMv("MV_XBOLCCO")
				If !Empty(sEmailCC)
					cEmail :=  cEmail + ';' + Alltrim(sEmailCC)
				EndIf

				cSubject := "Boleto Bancário Nr.:" + SE1->E1_NUM + " / " + SE1->E1_PARCELA

				//cEmail   := cEmail

				cHtml := " Prezado cliente "+cNomCli+", "+Chr(13)+chr(10)
				cHtml += " Estamos enviando em anexo o boleto bancário para pagamento."+Chr(13)+chr(10)
				cHtml += " "+Chr(13)+chr(10)
				cHtml += " Atenciosamente, "+Chr(13)+chr(10)
				cHtml += "                 "+SM0->M0_NOMECOM+Chr(13)+chr(10)

				ATEnvMail( cHtml , cEmail , cSubject , { cNomeArq +".pdf" } )
			Endif
		EndIf
	Next nLoop
	If lView
		oPrint:SetViewPDF(.T.)
		oPrint:Print()
	EndIf
Return()

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
Static Function Impress(oPrint,aEmpresa,aDadTit,aBanco,aSacado,aBolTxt,aCB_RN_NN,cNNum,nTipo, nBols)
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

	IF aBanco[1]=="001"
		cBmp := "images\bbrasil.bmp"
	ELSEIF aBanco[1]=="422"
		cBmp := "images\safra.bmp"
	Endif
	oFont8		:= TFont():New("Arial",		9,08,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont8n		:= TFont():New("Arial",		9,08,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11c	:= TFont():New("Courier New",	9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10		:= TFont():New("Arial",		9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12		:= TFont():New("Arial",		9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14		:= TFont():New("Arial",		9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20		:= TFont():New("Arial",		9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21		:= TFont():New("Arial",		9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n	:= TFont():New("Arial",		9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15		:= TFont():New("Arial",		9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n	:= TFont():New("Arial",		9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n	:= TFont():New("Arial",		9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24		:= TFont():New("Arial",		9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	If nBols == 1
		oPrint:StartPage()   // Inicia uma nova página
		nRow := 0
	Else
		nRow := 650
	Endif

	oPrint:SayBitMap(nRow+100,100,cBmp,450,150)
	oPrint:Say  (nRow+150,1700,"Recibo do Pagador",									oFont20)	// Texto Fixo
	oPrint:Line (nRow+250,100,nRow+250,2300)													// horizontal

	oPrint:Say  (nRow+0300,120 ,"Beneficiário",										oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0330,120 ,aEmpresa[1]+" - "+aEmpresa[8],						oFont10)	// Nome + CNPJ

	oPrint:Line (nRow+250,1280,0340,1280)													// vertical

	oPrint:Say  (nRow+0300,1300,"Nosso Número",										oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0330,1300,aCB_RN_NN[3],										oFont10)	// Nosso Número

	oPrint:Line (nRow+250,1830,0340,1830)													// vertical

	oPrint:Say  (nRow+0300,1850,"Vencimento",										oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0330,1850,DtoC(aDadTit[4]),									oFont10)	// Vencimento

	oPrint:Line (nRow+340,100,nRow+340,2300)													// Quadro

	oPrint:Say  (nRow+0360,120, "Data do Documento",								oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0390,120, DtoC(aDadTit[2]),									oFont10)	// Data do Documento

	oPrint:Line (nRow+340,530,nRow+400,530)													// vertical

	oPrint:Say  (nRow+0360,550 ,"Nro.Documento",									oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0390,550 ,aDadTit[7]+"-"+aDadTit[1],							oFont10)	// Prefixo + Numero + Parcela

	oPrint:Line (nRow+340,880,nRow+400,880)													// vertical

	oPrint:Say  (nRow+0360,900 ,"Carteira",											oFont10)	// Texto Fixo
	If aBanco[1] == "001"
		oPrint:Say  (nRow+0390,900 ,"17",												oFont10)	// Carteira
	ELSE
		oPrint:Say  (nRow+0390,900 ,SEE->EE_CODCART,												oFont10)	// Carteira
	Endif
	oPrint:Line (nRow+340,1280,nRow+400,1280)													// vertical

	oPrint:Say  (nRow+0360,1300,"Agência/Cod Beneficiario",							oFont10)	// Texto Fixo
	If aBanco[1] $ "001|237"
		oPrint:Say  (nRow+0390,1300,Alltrim(aBanco[3]+"/"+aBanco[4]),					oFont10)	// Agência + Código Cedente
	else
		oPrint:Say  (nRow+0390,1300,Alltrim("01900/005821459"),					oFont10)	// Agência + Código Cedente
	Endif

	oPrint:Line (nRow+340,1830,nRow+400,1830)													// vertical

	oPrint:Say  (nRow+0360,1850,"Valor do Documento",								oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0390,1850,Transform(aDadTit[5],"@E 99,999,999.99"),			oFont10)	// Valor do Título

	oPrint:Line (nRow+400,100,nRow+400,2300)													// Quadro

	If aSacado[8] = "J"
		cString := " - CNPJ: "+TRANSFORM(aSacado[7],"@R 99.999.999/9999-99")
	Else
		cString := " - CPF: "+TRANSFORM(aSacado[7],"@R 999.999.999-99")
	EndIf

	oPrint:Say  (nRow+0420,0120,"Pagador",											oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0450,0120,"("+aSacado[2]+") "+Alltrim(aSacado[1]) + cString,	oFont10)	// Nome do Cliente + Código

	oPrint:Box (nRow+0470,0100,nRow+0540,2300)													// Quadro
	oPrint:Say  (nRow+0490,0120,"Fornecedor:" + Alltrim(aEmpresa[1]) + " " + aEmpresa[8]									 ,	oFont10)	// Texto Fixo
	oPrint:Say  (nRow+0530,0120,"Endereço:" + Alltrim(aEmpresa[2]) + " " + aEmpresa[4] + " " + aEmpresa[6] + " - " + aEmpresa[5],	oFont10)	// Texto Fixo

	oPrint:Say  (nRow+0560,1600,"Autenticação Mecanica",	oFont10)	// Texto Fixo
	oPrint:Line (nRow+0590,1500,nRow+0590,2000)

	//fim box superior - inicio box secundario

	For nI := 100 to 2300 step 50
		oPrint:Line(nRow+630, nI, nRow+630, nI+30)												// Linha Pontilhada
	Next nI

	If nBols == 1
		nRow3 := 0
	Else
		nRow3 := 700
	Endif

	oPrint:Line (nRow3+0750,100,nRow3+0750,2300)													// linhas horizontais
	oPrint:Line (nRow3+0750,500,nRow3+0670, 500)													// linhas verticais
	oPrint:Line (nRow3+0750,710,nRow3+0670, 710)													// linhas verticais

	oPrint:SayBitMap(nRow3+640,100,cBmp,350,100)
	If aBanco[1] = "001"
		oPrint:Say  (nRow3+0734,525,aBanco[1] + "-9",										oFont20)	// Numero do Banco + Dígito
	ElseIf aBanco[1] = "237" 
		oPrint:Say  (nRow3+0734,525,aBanco[1] + "-7",										oFont20)	// Numero do Banco + Dígito
	Endif
	If aBanco[1] = "001"
		oPrint:Say  (nRow3+0710,150,"BANCO DO BRASIL",											oFont10)	// Nome do Banco
	ElseIf aBanco[1] = "237" 
		oPrint:Say  (nRow3+0710,150,"   BRADESCO",											oFont10)	// Nome do Banco
	EndIF
	oPrint:Say  (nRow3+0734,755,aCB_RN_NN[2],											oFont20)	// Linha Digitavel do Codigo de Barras

	oPrint:Line (nRow3+0820,100,nRow3+0820,2300 )													// linhas horizontais
	oPrint:Line (nRow3+0890,100,nRow3+0890,2300 )													// linhas horizontais
	oPrint:Line (nRow3+0960,100,nRow3+0960,2300 )													// linhas horizontais
	oPrint:Line (nRow3+1030,100,nRow3+1030,2300 )													// linhas horizontais

	oPrint:Line (nRow3+0890,0500,nRow3+1030,0500)													// linhas verticais
	oPrint:Line (nRow3+0960,0750,nRow3+1030,0750)													// linhas verticais
	oPrint:Line (nRow3+0890,1000,nRow3+1030,1000)													// linhas verticais
	oPrint:Line (nRow3+0890,1300,nRow3+1030,1300)													// linhas verticais
	oPrint:Line (nRow3+0890,1480,nRow3+1030,1480)													// linhas verticais

	oPrint:Say  (nRow3+0763,100 ,"Local de Pagamento",									oFont8)		// Texto Fixo	
	If aBanco[1] = "001"
		oPrint:Say  (nRow3+0800,400 ,"Pagavel em qualquer Banco ",oFont14)	// Texto Fixo
	ElseIf aBanco[1] = "237" 
		oPrint:Say  (nRow3+0800,400 ,"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso.",oFont14)	// Texto Fixo
	EndIf
	oPrint:Say  (nRow3+0763,1810,"Vencimento",											oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+0800,1910,DtoC(aDadTit[4]),										oFont14)	// Vencimento

	oPrint:Say  (nRow3+0834,100 ,"Beneficiário",										oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+0880,100 ,aEmpresa[1]+" - "+aEmpresa[8]	,						oFont10)	// Nome + CNPJ

	oPrint:Say  (nRow3+0834,1810,"Agência/Cod Beneficiario",								oFont8)		// Texto Fixo
	If aBanco[1] $ "001|237"
		oPrint:Say  (nRow+0880,1910,Alltrim(aBanco[3]+"/"+aBanco[4]+"-"+aBanco[5]),		oFont10)	// Agência + Código Cedente
	else
		oPrint:Say  (nRow+0880,1910,Alltrim("01900/005821459"),					oFont10)	// Agência + Código Cedente
	Endif

	oPrint:Say  (nRow3+0905,100 ,"Data do Documento",									oFont8)		// Texto Fixo
	oPrint:Say (nRow3+0940,100, DtoC(aDadTit[2]),										oFont10)	// Vencimento

	oPrint:Say  (nRow3+0905,505 ,"Nro.Documento",										oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+0940,605 ,aDadTit[7]+aDadTit[1],									oFont10)	// Prefixo + Numero + Parcela

	oPrint:Say  (nRow3+0905,1005,"Espécie",												oFont8)		// Texto Fixo
	If aBanco[1] == '001'
		oPrint:Say  (nRow3+0940,1050,"R$",													oFont10)	//Tipo do Titulo
	Else
		oPrint:Say  (nRow3+0940,1050,"DM",													oFont10)	//Tipo do Titulo
	Endif
	oPrint:Say  (nRow3+0905,1305,"Aceite",												oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+0940,1400,"N",													oFont10)	// Texto Fixo

	oPrint:Say  (nRow3+0905,1485,"Data do Processamento",								oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+0940,1550,DtoC(aDadTit[3]),										oFont10)	// Data impressao

	oPrint:Say  (nRow3+0905,1810,"Nosso Número",										oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+0940,1910,aCB_RN_NN[3],											oFont14)	// Nosso Número

	oPrint:Say  (nRow3+0980,100 ,"Uso do Banco",										oFont8)		// Texto Fixo

	oPrint:Say  (nRow3+0980,505 ,"Carteira",											oFont8)		// Texto Fixo
	If aBanco[1] == '001'
		oPrint:Say  (nRow3+1020,555 ,"17",													oFont10)
	eLSE
		oPrint:Say  (nRow3+1020,555 ,"01",													oFont10)
	ENDIF
	oPrint:Say  (nRow3+0980,755 ,"Espécie",												oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1020,805 ,"R$",													oFont10)	// Texto Fixo

	oPrint:Say  (nRow3+0980,1005,"Quantidade",											oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+0980,1485,"Valor",												oFont8)		// Texto Fixo

	oPrint:Say  (nRow3+0980,1810,"Valor do Documento",									oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1020,1960,Transform(aDadTit[5],"@E 99,999,999.99"),				oFont14)	// Valor do Documento

	oPrint:Say  (nRow3+1050,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)", oFont8)		// Texto Fixo
	If Len(aBolTxt) > 0
		oPrint:Say  (nRow3+1080,0100,aBolTxt[1],											oFont12)	// 1a Linha Instrução
		oPrint:Say  (nRow3+1120,0100,aBolTxt[2],											oFont12)	// 2a. Linha Instrução
		oPrint:Say  (nRow3+1160,0100,aBolTxt[3],											oFont12)	// 3a. Linha Instrução
		oPrint:Say  (nRow3+1200,0100,aBolTxt[4],											oFont12)	// 4a Linha Instrução
		oPrint:Say  (nRow3+1240,0100,aBolTxt[5],											oFont12)	// 5a. Linha Instrução
		oPrint:Say  (nRow3+1280,0100,aBolTxt[6],											oFont12)	// 6a. Linha Instrução
	EndIf
	oPrint:Say  (nRow3+1050,1810,"(-)Desconto/Abatimento",								oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1120,1810,"(-)Outras Deduções",									oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1190,1810,"(+)Mora/Multa",										oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1260,1810,"(+)Outros Acréscimos",								oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1330,1810,"(=)Valor Cobrado",									oFont8)		// Texto Fixo

	oPrint:Say  (nRow3+1400+11.5,0100,"Pagador",											oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1410+11.5,0250,"("+aSacado[2]+") "+aSacado[1],						oFont10)	// Nome Cliente + Código

	If aSacado[8] = "J"
		oPrint:Say  (nRow3+1410+11.5,1305,"CNPJ: "+TRANSFORM(aSacado[7],"@R 99.999.999/9999-99"), oFont10)	// CGC
	Else
		oPrint:Say  (nRow3+1410+11.5,1305,"CPF: "+TRANSFORM(aSacado[7],"@R 999.999.999-99"),	 oFont10)	// CPF
	EndIf

	oPrint:Say  (nRow3+1460,0250,aSacado[3],											oFont10)	// Endereço
	oPrint:Say  (nRow3+1500,0250,Transform(aSacado[6],"@R 99999-999")+" - "+aSacado[4]+" - "+aSacado[5],							oFont10)	// CEP + Cidade + Estado
	oPrint:Say  (nRow3+1525,0100,"Beneficiario Final",									oFont8)		// Texto Fixo
	oPrint:Say  (nRow3+1570,1500,"Autenticação Mecânica - Ficha de Compensação",		oFont8)		// Texto Fixo

	oPrint:Line (nRow3+0750,1800,nRow3+1380,1800)													// Quadro
	oPrint:Line (nRow3+1100,1800,nRow3+1100,2300)													// Quadro
	oPrint:Line (nRow3+1170,1800,nRow3+1170,2300)													// Quadro
	oPrint:Line (nRow3+1240,1800,nRow3+1240,2300)													// Quadro
	oPrint:Line (nRow3+1310,1800,nRow3+1310,2300)													// Quadro
	oPrint:Line (nRow3+1380,0100,nRow3+1380,2300)													// Quadro
	oPrint:Line (nRow3+1540,0100,nRow3+1540,2300)													// Quadro

	oPrint:FWMsBar("INT25",37.5,1.8,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.018,1.0,Nil,Nil,"A",.F.)

	oPrint:EndPage()
/*
	IF aBanco[1]=="001"
		DbSelectArea("SE1")
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO	:= subsTr(aCB_RN_NN[3],8,10)
		MsUnlock()
	ELSEIF aBanco[1]=="422"
		DbSelectArea("SE1")
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO	:= cNNum
		MsUnlock()
	Endif
*/
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
Static Function Modulo10(cData)

	Local L,D,P := 0
	Local B     := .F.

	L := Len(cData)
	B := .T.
	D := 0

	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			EndIf
		EndIf
		D := D + P
		L := L - 1
		B := !B
	EndDo
	D := 10 - (Mod(D,10))
	If D == 10
		D := 0
	EndIf

Return(D)

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
Static Function Modulo11(cData)
	Local L := Len(cdata)
	Local D := 0
	Local P := 1

	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	EndDo

	D := 11 - (mod(D,11))

	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	EndIf

Return(D)

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
Static Function Mod11BB(cData) //Modulo 11 com base 7
	LOCAL L, D, P 	:= 0
	Local DV		:= " "
	L := Len(cdata)
	D := 0
	P := 10
	While L > 0
		P := P - 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 2   //Volta para o inicio, ou seja comeca a multiplicar por 9,8,7...
			P := 10
		End
		L := L - 1
	End
	_nResto := mod(D,11)  //Resto da Divisao
	DV:=STR(_nResto)

	If _nResto == 0
		DV := "0"
	End

	If _nResto == 10
		DV := "X"
	End

Return(DV)

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
Static Function Mod10BB(cCampoDv,cComLD)
	Local nSoma     := 0
	Local nAuxSoma  := 0
	Local nPesoDigi := 2
	Local nxY       := 0
	Local nCamDig   := 0
	Local nValCamp  := 0
	Local DV        := 0
	Local nxI		:= 0

	Do Case
	Case (cCampoDv == "1")
		nxY     := 9
		nCamDig := 10
	OtherWise
		nxY     := 10
		nCamDig := 11
	EndCase

	For nxI := 1  To nxY
		nAuxSoma := Val(Substr(cComLD,nCamDig-nxI,1)) * nPesoDigi
		If (nAuxSoma <= 9)
			nSoma := nSoma + nAuxSoma
		Else
			nSoma := nSoma + Val(SubStr(CvalToChar(nAuxSoma),1,1)) + Val(SubStr(CvalToChar(nAuxSoma),2,1))
		EndIf

		If (nPesoDigi = 2)
			nPesoDigi := 1
		Else
			nPesoDigi := 2
		EndIf
	Next nxI

	nValCamp := mod(nSoma,10)
	nxX := 10
	nxY := 1

	While (nxY <> 0)

		If (nSoma <= nxX)
			DV  := nxX - nValCamp
			nxY := 0
		EndIf
		nxX := nxX + 10

	EndDo

	Do Case
	Case (DV == 10)
		DV := 0
	Case (DV > 10)
		DV := mod(DV,10)
	EndCase

Return(DV)
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
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)
	Local bldocnufinal := ""
	Local blvalorfinal := strzero((nValor*100),10)
	Local dvnn         := 0
	Local dvcb         := 0
	Local auxdv        := 0
	Local dv           := 0
	Local NN           := ''
	Local RN           := ''
	Local CB           := ''
	Local s            := ''
	Local _cfator      := strzero(dVencto - ctod("07/10/97"),4)
	Local cMoeda       := "9"
	Local nXi		   := 0
	Local cCodCart	   := ''

	If cBanco == "422"
		bldocnufinal := FAjVari(cNroDoc,9)
		//-------- Definicao do NOSSO NUMERO NN
		dvnn := Right(Alltrim(cNroDoc),1)
		NN   := strzero(Val(Alltrim(cNroDoc)),9)
		//      -------- Definicao do CODIGO DE BARRAS CB
		s    := cBanco+cMoeda+_cfator+blvalorfinal+("7"+FAjVari("01900",5)+FAjVari(cConta,8)+AllTrim(cDacCC)+Alltrim(cNroDoc)+"2")
		dvcb := modulo11(s)
		CB   := SubStr(s,1,4)+AllTrim(Str(dvcb))+SubStr(s,5)
		//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica) RN
		//CAMPO 1
		s    := cBanco+cMoeda+"70190" //chumbei aqui o codigo da agencia que é 0019, porem no modelo estava constando 019 diferente do layout do banco
		dv   := modulo10(s)
		RN   := SubStr(s, 1, 5) + '.' + SubStr(s, 6, 4) + AllTrim(Str(dv)) + '  '
		//CAMPO 2
		s    := "0"+FAjVari(cConta,8)+AllTrim(cDacCC)
		dv   := modulo10(s)
		RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
		//CAMPO 3
		s    := Alltrim(cNroDoc) + "2"
		dv   := modulo10(s)
		RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(Str(dv)) + '  '
		//CAMPO 4
		RN   := RN + AllTrim(Str(dvcb)) + '  '
		//CAMPO 5
		RN   := RN + _cfator + StrZero(NOROUND(nValor * 100),14-Len(_cfator))
	ElseIf cBanco == "001"
		cCodCart := "17"
		dv := 0
		// -------- Definicao do CODIGO DE BARRAS
		s := cBanco+cMoeda+_cfator+blvalorfinal+"0000001914568"+FAjVari(cNroDoc,10)+FAjVari(cCodCart,2)
		nSoma     := 0
		nPesoDigi := 2
		For nxI := 1  To 44
			//If (nxI <> 40)
			nSoma     := nSoma + Val(Substr(s,44-nxI,1)) * nPesoDigi
			nPesoDigi++
			If (nPesoDigi == 10)
				nPesoDigi := 2
			EndIf
			//EndIf
		Next nxI
		dvnn := AllTrim(CvalToChar(Mod(nSoma,11)))
		dv   := CvalToChar(11-Val(dvnn))
		If (dv=='0') .or. (dv=='10') .or. (dv=='11') 
			dv := '1'
		Endif
		auxdv := dv
		CB    := cBanco+cMoeda+AllTrim(CvalToChar(dv))+_cfator+blvalorfinal+"0000001914568"+FAjVari(cNroDoc,10)+FAjVari(cCodCart,2)
		NN    := FAjVari(cNroDoc,10)
		NN    := "1914568"+FAjVari(cNroDoc,10)+"-"+alltrim(Mod11BB("1914568"+NN))

		//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
		//CAMPO 1
		s    := cBanco+cMoeda+SubStr(CB,20,5)
		dv   := Mod10BB("1",s)
		RN   := SubStr(s,1,5) + '.' + SubStr(s,6,4) + AllTrim(CvalToChar(dv)) + '  '
		//CAMPO 2
		s    := SubStr(CB,25,10)
		dv   := Mod10BB("2",s)
		RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(CvalToChar(dv)) + '  '
		//CAMPO 3
		s    := SubStr(CB,35,10)
		dv   := Mod10BB("3",s)
		RN   := RN + SubStr(s, 1, 5) + '.' + SubStr(s, 6, 5) + AllTrim(CvalToChar(dv)) + '  '
		//CAMPO 4
		RN   := RN + AllTrim(CvalToChar(auxdv)) + '  '
		//CAMPO 5
		RN   := RN + _cfator + StrZero((nValor * 100),14-Len(_cfator))
	ElseIf cBanco == "237"
		cCarteira := "09"
		bldocnufinal := Subs(cNroDoc,3,11) //strzero(val(cNroDoc),11) // jcns - 06/01/2014 - cobranca registrada usa 11 caracteres no NN
		blvalorfinal := strzero((nValor*100),10)
		dvnn         := right(cNroDoc,1)
		dvcb         := 0
		dv           := 0
		NN           := ''
		RN           := ''
		CB           := ''
		s            := ''
		dDtBase	     := CtoD("07/10/97")
		cFatorVencto := ""

		//Fator de Vencimento do Boleto
		cFatorVencto := Str(SE1->E1_VENCREA - dDtBase,4)

		//NOSSO NUMERO
		snn := cCarteira + bldocnufinal     // Carteira + Numero Gravado no SEE
		dvnn := modulo11(snn)  //Digito verificador no Nosso Numero - Base 7
		NN := cCarteira + cAgencia + bldocnufinal +'-'+ AllTrim(str(dvnn))
		//STRING PARA O CODIGO DE BARRAS
		_cLivre := cAgencia + cCarteira + bldocnufinal + StrZero(Val(cConta),7) + '0'
		scb := cBanco + "9" + cFatorVencto + blvalorfinal + _cLivre
		dvcb := mod11CB(scb)	//digito verificador do codigo de barras
		CB := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)

		//MONTAGEM DA LINHA DIGITAVEL
		srn := cBanco + "9" + Substr(_cLivre,1,5)//Codigo Banco + Codigo Moeda + 5 primeiros digitos do campo livre
		dv := modulo10(srn)
		RN := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4)+AllTrim(Str(dv))+' '
		srn := SubStr(_cLivre,6,10)	// posicao 6 a 15 do campo livre

		dv := modulo10(srn)
		RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv))+' '
		srn := SubStr(_cLivre,16,10)	// posicao 16 a 25 do campo livre

		dv := modulo10(srn)
		RN := RN + SubStr(srn,1,5)+'.'+SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '
		RN := RN + AllTrim(Str(dvcb))+' '
		RN := RN + cFatorVencto + Strzero((nValor * 100),10)
	EndIf
Return({CB,RN,NN})


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
Static Function FAjVari(cVarAju,nTamAju)
	Local cValAjuRet := ""

	cValAjuRet := StrZero(Val(Right(AllTrim(cVarAju),nTamAju)),nTamAju)

Return(cValAjuRet)

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
User Function BOLFR01D(cPrefixo,cNum,cParcela,cCliente,cLoja)

// Retorna o Saldo de um título
	Local aRet		:= {0,0,0,0}
	Local nVlrAbat	:= 0
	Local nAcresc	:= 0
	Local nDecres	:= 0
	Local nSaldo	:= 0
	Local nValRet	:= 0
	Local _nValBase	:= 0//SuperGetMV("MV_VL10925",, 5000)
	Local _nMinIrf  := GETMV("MV_VLRETIR")

// Pega os Default dos parâmetros
	cPrefixo	:= Iif(cPrefixo == Nil, SE1->E1_PREFIXO, cPrefixo)
	cNum		:= Iif(cNum == Nil, SE1->E1_NUM, cNum)
	cParcela	:= Iif(cParcela == Nil, SE1->E1_PARCELA, cParcela)
	cCliente	:= Iif(cCliente == Nil, SE1->E1_CLIENTE, cCliente)
	cLoja		:= Iif(cLoja == Nil, SE1->E1_LOJA, cLoja)

	dDtNewPCC := CtoD('01/08/15')//Data da Implantação do Novo Calculo PCC

	if SE1->E1_EMISSAO>=dDtNewPCC
		_nValBase	:= SuperGetMV("MV_VL10925",, 5000)
	else
		_nValBase	:= 5000
	endif

// Pega o valor dos abatimentos para o título
	nVlrAbat	:= SomaAbat(cPrefixo,cNum,cParcela,"R",1,,cCliente,cLoja)
// Pega valor de retencao - Vitor Aoki - 26/03/2013
	If SE1->E1_BASEPIS > _nValBase
		nValRet += SE1->E1_PIS
	EndIf
	If SE1->E1_BASECOF > _nValBase
		nValRet	+= SE1->E1_COFINS
	EndIf
	If SE1->E1_BASECSL > _nValBase
		nValRet	+= SE1->E1_CSLL
	EndIf
	if SE1->E1_IRRF > _nMinIrf
		nValRet	+= SE1->E1_IRRF
	Endif

	nVlrAbat += nValRet

// Pega o valor de acréscimos e decrescimos paa o título
	nAcresc		:= SE1->E1_ACRESC
	nDecres		:= SE1->E1_DECRESC

// Define o saldo do título
	nSaldo		:= SE1->E1_SALDO-nVlrAbat-nDecres+nAcresc

// Monta Vetor com o retorno
	aRet		:= {nSaldo,nVlrAbat,nAcresc,nDecres}

Return(aRet)

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
Static Function CriaSx1(aRegs)

	Local aAreaAtu	:= GetArea()
	Local aAreaSX1	:= SX1->(GetArea())
	Local nJ		:= 0
	Local nY		:= 0

	dbSelectArea("SX1")
	dbSetOrder(1)

	For nY := 1 To Len(aRegs)
		If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
			RecLock("SX1",.T.)
			For nJ := 1 To FCount()
				If nJ <= Len(aRegs[nY])
					FieldPut(nJ,aRegs[nY,nJ])
				EndIf
			Next nJ
			MsUnlock()
		EndIf
	Next nY

	RestArea(aAreaSX1)
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
Static Function _RetSEE(cBanco,cAgencia,cConta,cSubConta)

	Local cQuery :=  ""
	Local cFAXATU:=""

	cQuery := " SELECT EE_FAXATU "
	cQuery += " FROM "+RetSqlName("SEE")+" SEE "
	cQuery += " WHERE  SEE.D_E_L_E_T_ = ' ' "
	cQuery += " AND  EE_CODIGO ='"+cBanco+"'"
	cQuery += " AND  EE_AGENCIA ='"+cAgencia+"'"
	cQuery += " AND  EE_CONTA ='"+cConta+"'"
	cQuery += " AND  EE_SUBCTA ='"+cSubConta+"'"

	If Select("TRX") > 0
		dbSelectArea("TRX")
		dbCloseArea()
	Endif

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRX", .F., .T.)

	cFAXATU := TRX->EE_FAXATU

	TRX->(dbCloseArea())
Return cFAXATU

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
Static Function _AtuSEE(cFAXATU,cBanco,cAgencia,cConta,cSubConta)

	Local cQuery :=  ""

	cQuery := " UPDATE "+RetSqlName("SEE")
	cQuery += " SET  EE_FAXATU ='"+cFAXATU+"'"
	cQuery += "  WHERE  EE_CODIGO ='"+Alltrim(cBanco)+"'"
	cQuery += " AND  EE_AGENCIA ='"+Alltrim(cAgencia)+"'"
	cQuery += " AND  EE_CONTA ='"+Alltrim(cConta)+"'"
	cQuery += " AND  EE_SUBCTA ='"+Alltrim(cSubConta)+"'"

	TcSqlExec(cQuery)

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

	AjusPerg(cPerg)

Static Function AjusPerg(cPerg)
	Local aRegs := {}
	aTamSX3	:= TAMSX3("E1_PREFIXO")
	aAdd(aRegs,{cPerg,"01","Prefixo Inicial",		"","","mv_ch1","C",aTamSx3[1],0,0,"G","","MV_PAR01","",	"",		"",		"   ",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","","" })
	aAdd(aRegs,{cPerg,"02","Prefixo Final",			"","","mv_ch2","C",aTamSx3[1],0,0,"G","","MV_PAR02","",	"",		"",		"zzz",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","","" })
	aTamSX3	:= TAMSX3("E1_NUM")
	aAdd(aRegs,{cPerg,"03","Numero Inicial", 		"","","mv_ch3","C",aTamSx3[1],0,0,"G","","MV_PAR03","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"04","Numero Final",			"","","mv_ch4","C",aTamSx3[1],0,0,"G","","MV_PAR04","",	"",		"",		"zzzzzz",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aTamSX3	:= TAMSX3("E1_PARCELA")
	aAdd(aRegs,{cPerg,"05","Parcela Inicial",		"","","mv_ch5","C",aTamSx3[1],0,0,"G","","MV_PAR05","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"06","Parcela Final",			"","","mv_ch6","C",aTamSx3[1],0,0,"G","","MV_PAR06","",	"",		"",		"z",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"07","Tipo Inicial",			"","","mv_ch7","C",03,0,0,"G","","MV_PAR07","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"08","Tipo Final",			"","","mv_ch8","C",03,0,0,"G","","MV_PAR08","",	"",		"",		"zzz",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"09","Cliente Inicial",		"","","mv_ch9","C",06,0,0,"G","","MV_PAR09","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","SA1",	"","","",""})
	aAdd(aRegs,{cPerg,"10","Cliente Final",			"","","mv_cha","C",06,0,0,"G","","MV_PAR10","",	"",		"",		"zzzzzz",		"","",		"",		"",		"","","","","","","","","","","","","","","","","SA1",	"","","",""})
	aAdd(aRegs,{cPerg,"11","Loja Inicial",			"","","mv_chb","C",02,0,0,"G","","MV_PAR11","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"12","Loja Final",			"","","mv_chc","C",02,0,0,"G","","MV_PAR12","",	"",		"",		"zz",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"13","Emissao Inicial",		"","","mv_chd","D",08,0,0,"G","","MV_PAR13","",	"",		"",		"01/01/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"14","Emissao Final",			"","","mv_che","D",08,0,0,"G","","MV_PAR14","",	"",		"",		"31/12/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"15","Vencimento Inicial",	"","","mv_chf","D",08,0,0,"G","","MV_PAR15","",	"",		"",		"01/01/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"16","Vencimento Final",		"","","mv_chg","D",08,0,0,"G","","MV_PAR16","",	"",		"",		"31/12/05",		"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"17","Natureza Inicial",		"","","mv_chh","C",10,0,0,"G","","MV_PAR17","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"18","Natureza Final",		"","","mv_chi","C",10,0,0,"G","","MV_PAR18","",	"",		"",		"zzzzzzzzzz",	"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"19","Re-Impressao",			"","","mv_chj","N",01,0,0,"C","","MV_PAR19","Sim",	"Si",	"Yes",	"",				"","Nao",	"No",	"No",	"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"20","Bordero Inicial",		"","","mv_chk","C",06,0,0,"G","","MV_PAR20","",	"",		"",		"",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"21","Bordero Final"  ,		"","","mv_chl","C",06,0,0,"G","","MV_PAR21","",	"",		"",		"",			"","",		"",		"",		"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"22","Incluir Portador",		"","","mv_chj","N",01,0,0,"C","","MV_PAR22","Sim",	"Si",	"Yes",	"",				"","Nao",	"No",	"No",	"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"23","Banco",					"","","mv_chk","C",03,0,0,"G","","MV_PAR23","",	"",		"",		"",				"","",		"",		"",		"","","","","","","","","","","","","","","","","SA6",	"","","",""})
	aAdd(aRegs,{cPerg,"24","Agencia",				"","","mv_chl","C",05,0,0,"G","","MV_PAR24","",	"",	"",	"",				"","",	"",	"",	"","","","","","","","","","","","","","","","","",		"","","",""})
	aAdd(aRegs,{cPerg,"25","Incluir Portador",		"","","mv_chm","C",10,0,0,"G","","MV_PAR25","",	"",	"",	"",				"","",	"",	"",	"","","","","","","","","","","","","","","","","",		"","","",""})
	CriaSx1(aRegs)
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
Static Function MaOrdCab(oList1,lOrdem)

	Local nPos := oList1:nColPos

	lOrdem := !lOrdem
	IF lOrdem
		aSort( oList1:aArray ,,, {|x,y| x[nPos] > y[nPos] } )
	Else
		aSort( oList1:aArray ,,, {|x,y| x[nPos] < y[nPos] } )
	EndIF

	oList1:Refresh()

Return(.T.)

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

Static Function ATEnvMail(cHtml,cEmail,cSubject,aAnexos)

	Local lResult    	:= .T.
	Local cError     	:= ""
	Local cTo      		:= ""
	Local lAuth    		:= GetMv("MV_RELAUTH")
	Local nTimeout		:= 240
	Local cMailConta	:= Alltrim(GetMv("MV_RELACNT"))
	Local cMailServer	:= Alltrim(GetMv("MV_RELSERV"))
	Local cMailSenha 	:= Alltrim(GetMv("MV_RELPSW"))
	Local cFileSrv      := "\boletos"
	Local cAnexos		:= ""
	Local nI:=1

	Default aAnexos     := {}
//	cEmail := 'marcio.ssilva@totvs.com.br'

	cTo	:= RTrim(cEmail)

	If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha)

		CONNECT SMTP SERVER cMailServer ACCOUNT cMailSenha PASSWORD cMailSenha RESULT lResult

		If lResult
			If lAuth
				lResult := MailAuth(cMailConta,cMailSenha)
			EndIf
			If lResult
				If Len(aAnexos)>0
					cAnexos:=''
					For nI:=1 to Len(aAnexos)
						CpyT2S( cDirTmp+aAnexos[nI] , cCaminho , .F. )
						cAnexos += If(!Empty(cAnexos),",","")+cCaminho+aAnexos[nI]
					Next
				Endif

				SEND MAIL  				;
					FROM       cMailConta	;
					TO		   cTo			;
					SUBJECT	   cSubject		;
					BODY	   cHtml		;
					ATTACHMENT cAnexos      ;
					RESULT	   lResult
				If !lResult
					GET MAIL ERROR cError
					cError := cError+".Falha no Envio do e-mail."
					If (!IsBlind())
						ALERT(cError)
					Else
						Conout(cError)
					Endif
				EndIf
			Else
				//Erro na autenticacao da conta
				GET MAIL ERROR cError
				cError := cError+".Falha no Envio do e-mail."
				If (!IsBlind())
					ALERT(cError)
				Else
					Conout(cError)
				Endif
			Endif
		Else
			GET MAIL ERROR cError
			cError := cError+".Falha no Envio do e-mail."
			If (!IsBlind())
				ALERT(cError)
			Else
				Conout(cError)
			Endif
		Endif
	Endif

Return()

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
Static Function CalcDg(cNumBCO,cOper)
/*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
Função : Calcula Digito Verificador usando modulo 11
*///////////////////////////////////////////////////////////////////////////////////////////
	Local cData
	Local D

    /*MODULO DE 11 - PARA CALCULO DO NOSSO NUMERO*/
	If cOper="1"

		cData := ("09" + Alltrim(cValTochar(cNumBCO)))

		//######################################################################################
		//####################### Banco do Bradesco - D.V. Nosso Numero ########################
		//######################################################################################
		L := Len(cData)
		D := 0
		P := 1
		While L > 0
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 7
				P := 1
			End
			L := L - 1
		End
		R := mod(D,11)
		If (R == 1)
			D := "P"
		ElseIf (R == 0)
			D := 0
		Else
			D := (11 - R)
		End
		CValToChar(D)

    /*MODULO DE 11 - PARA O DÍGITO DO CODIGO DE BARRAS*/
	Elseif cOper="2"

		cData := Alltrim(cValTochar(cNumBCO))

		//######################################################################################
		//####################### Banco do Bradesco - D.V. Cod. Barras #########################
		//######################################################################################
		L := Len(cdata)
		D := 0
		P := 1
		While L > 0
			P := P + 1
			D := D + (Val(SubStr(cData, L, 1)) * P)
			If P = 9
				P := 1
			End
			L := L - 1
		End
		D := mod(D,11)
		D := 11 - D
		If (D == 0 .Or. D == 1 .Or. D > 9)
			D := 1
		End
		cValTochar(D)
	Endif
Return(cValTochar(D))

// Número de parcelas
Static Function NumParcela(_cParcela)
	Local _cRet := ""
	If ASC(Alltrim(_cParcela)) >= 65 .And. ASC(Alltrim(_cParcela)) <= 90      // Caso seja em letras, dá continuidade ao número de parcelas
		_cRet := Strzero(9+(Asc(Alltrim(_cParcela))-64),2)                    // Retorna A=1, B=2, C=3...Z=26, e soma com a última parcela numérica.
	Else                                                                      // Parcelas = 01,02,03..09,10,11..35
		_cRet := Strzero(Val(_cParcela),2)
	Endif
Return(_cRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  BOL237  ³ Autor ³                       ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO BRADESCO COM CODIGO DE BARRAS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mod11CB(cData) // Modulo 11 com base 9
LOCAL CBL, CBD, CBP := 0
CBL := Len(cdata)
CBD := 0
CBP := 1

While CBL > 0
	CBP := CBP + 1
	CBD := CBD + (Val(SubStr(cData, CBL, 1)) * CBP)
	If CBP = 9    //Volta para o inicio, ou seja comeca a multiplicar por 2,3,4...
		CBP := 1
	End
	CBL := CBL - 1
End
_nCBResto := mod(CBD,11)  //Resto da Divisao
CBD := 11 - _nCBResto
If (CBD == 0 .Or. CBD == 1 .Or. CBD > 9)
	CBD := 1
End

Return(CBD)
