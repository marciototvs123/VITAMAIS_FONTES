**********************************************************************************
*               Diversos Programas para trbalhar banco de dados                   *
* Data 03/01/2023 - Alteracao solicitada por Eder								  *
* mais de uma tabela de frete Por cliente, podendo o cliente selecionar outra tabe-*
* quando montar o pedido de vendas                                                *
* Campos Criados: 
**********************************************************************************
#Include "msobject.ch"
#Include "rwmake.ch"
#Include "topconn.ch"



**************************
User Function VITMIS01()   // Verifica se Valor do pedido com desconto esta correto
*************
	Local nC6_XFRTIT	:= 0
	Local sRet 			:= ''
	Local tRet 			:= .T.
	Local nC6_UNSVEN	:= 0
	Local nC6_PRUNIT	:= 0 
	Local nI            := 0 
	If M->C5_XPEDCOM == 'S' // verifica se pedido for comercial ou sem calculo comercial
		// Busca Valor Do Frete
		DbSelectArea('SA1')
		DbSetOrder(1)
		iF !DbSeek(xFilial('SA1')+M->C5_CLIENTE+M->C5_LOJACLI)
			sRet := 'Cliente Nao Encontrado!'
		EndIf
		If Empty(sRet)
			// Posiciona do registro veinculado na tabel a de precos
			DbSelectArea('ZA2')
			DbSetOrder(1)
			iF !DbSeek(xFilial('ZA2')+M->C5_XCDZA1)
				sRet := 'Regiao De Cliente Nao Esta Cadastrada!'
			EndIf
		EndIf
		If Empty(sRet)
			For nI := 1 To Len(aCols)
				IF aCols[nI,len(aHeader)+1] == .f.
					nC6_UNSVEN	+= aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_UNSVEN"})]  
				EndIf	
			Next nI
			While !Eof() .And. xFilial('ZA2')+M->C5_XCDZA1 == ZA2->ZA2_FILIAL+ZA2->ZA2_CODZA1 .And. nC6_XFRTIT == 0 
				If nC6_UNSVEN >= ZA2->ZA2_DEKG .And. nC6_UNSVEN <= ZA2->ZA2_ATEKG  	
					nC6_XFRTIT 	:= ZA2->ZA2_VALOR
				EndIf
				DbSkip()
			EndDo
		EndIf
		If Empty(sRet) .And. nC6_XFRTIT == 0 .And. M->C5_TPFRETE == 'C'
			sRet := 'Faixa de KG de Frete no Cadastro de Fretes por Regiao Nao encontrado! ' 
		Else
			For nI := 1 To Len(aCols)
				IF aCols[nI,len(aHeader)+1] == .f.
					nC6_XFRTIT	 := (nC6_XFRTIT/30) * aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XCONV"})]
					nC6_XFRTIT   := Round(nC6_XFRTIT,2)
					aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XFRTIT"})] := IIF(M->C5_TPFRETE == 'F',0,nC6_XFRTIT)
				EndIf	
			Next nI
			nC6_PRUNIT 	:= aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRUNIT"})]
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRSFRT"})] := nC6_PRUNIT //- nC6_XFRTIT		aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})] := aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRCVEN"})] * aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})]
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VITICM"})] 	:= 0
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALDESC"})] 	:= 0
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_DESCONT"})] 	:= 0
		EndIf	
		If !Empty(sRet)
			MessageBox(sRet,"",16)
			tRet := .F.
		EndIf 
	EndIf
Return(tRet)	


**************************
User Function VITMIS02()   // Verifica CGC CLiente e Gera A1_COD, A1_LOJA
*************
	sCgc := M->A1_CGC
	sA1_COD := IIF(GetSx8Num("SA1","A1_COD") > GetSxENum("SA1","A1_COD"),GetSx8Num("SA1","A1_COD"),GetSxENum("SA1","A1_COD"))
	iF M->A1_PESSOA == 'F'
		nA1_loja	:= 1 
		DbSelectArea('SA1')
		DbSetOrder(3)
		DbSeek(xFilial('SA1')+Alltrim(sCgc),.T.)
		While !Eof() .And. Alltrim(SA1->A1_CGC) == Alltrim(sCgc)
			sA1_COD  := SA1->A1_COD
			nA1_LOJA := IIF(Val(SA1->A1_LOJA) >= nA1_LOJA,Val(SA1->A1_LOJA) + 1, nA1_LOJA) 
			DbSkip()
		EndDo
	Else
		nA1_LOJA := Val(Subs(Alltrim(sCgc),9,4)) 
		DbSelectArea('SA1')
		DbSetOrder(3)
		DbSeek(xFilial('SA1')+Left(Alltrim(sCgc),8),.T.)
		If Left(SA1->A1_CGC,8) == Left(Alltrim(sCgc),8)
			sA1_COD := SA1->A1_COD
		EndIF
	EndIf	
	M->A1_COD := sA1_COD
	M->A1_LOJA := StrZero(nA1_LOJA,4)
Return(.T.)


**************************
User Function VITMIS03()   // Verifica CGC Fornecedor e Gera A2_COD, A2_LOJA
*************
	sCgc := M->A2_CGC
	sA2_COD := IIF(GetSx8Num("SA2","A2_COD") > GetSxENum("SA2","A2_COD"),GetSx8Num("SA2","A2_COD"),GetSxENum("SA2","A2_COD"))
	iF Len(Alltrim(sCgc)) > 0 .And. Len(Alltrim(sCgc)) <= 12
		nA2_loja	:= 1 
		DbSelectArea('SA2')
		DbSetOrder(3)
		DbSeek(xFilial('SA2')+Alltrim(sCgc),.T.)
		While !Eof() .And. Alltrim(SA2->A2_CGC) == Alltrim(sCgc)
			sA2_COD  := SA2->A2_COD
			nA2_LOJA := IIF(Val(SA2->A2_LOJA) >= nA2_LOJA,Val(SA2->A2_LOJA) + 1, nA2_LOJA) 
			DbSkip()
		EndDo
	ElseIF Len(Alltrim(sCgc)) == 14
			nA2_LOJA := Val(Subs(Alltrim(sCgc),9,4)) 
			DbSelectArea('SA2')
			DbSetOrder(3)
			DbSeek(xFilial('SA2')+Left(Alltrim(sCgc),8),.T.)
			If left(Alltrim(SA2->A2_CGC),8) == Left(Alltrim(sCgc),8)
				sA2_COD  := SA2->A2_COD
			EndIF
	EndIf	
	M->A2_COD := sA2_COD
	M->A2_LOJA := StrZero(nA2_LOJA,4)
Return(.T.)

**************************
User Function VITMIS04()   // Verifica CGC Fornecedor e Gera A2_COD, A2_LOJA
*************
	Local tRet 			:= .T.
	Local Ni			:= 0 
	Local nValProd		:= 0 
	Local sC6_XCDTAB	:= ""
	If M->C5_XPEDCOM == 'S' // verifica se pedido for comercial ou sem calculo comercial	
		tRet 			:= .T.
		DbSelectArea('SA1')
		DbSetOrder(1)
		DbSeek(xFilial('SA1')+M->C5_CLIENTE+M->C5_LOJACLI,.T.)

		DbSelectArea('SE4')
		DbSetOrder(1)
		iF !DbSeek(xFilial('SE4')+M->C5_CONDPAG,)
			Alert('Condicao De Pagamento Nao Encontrado!')
			tRet := .F.
		Else
			sC6_PRODUTO  := aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRODUTO"})]  
			IF Left(Alltrim(SM0->M0_CODFIL),2) == "02"
				cString := Alltrim(SA3->A3_XCDDA0)  //"02,03,04,05,06,07,08,09,10,11,12,13"
				aString := strtokarr (cString, ",")
				For Ni := 1 to Len(aString)
					If nValProd == 0 
						DbSelectArea('DA1') 
						DbSetOrder(1)
						DbSeek(xFilial('DA1')+PADR(Alltrim(aString[Ni]),3)+Alltrim(sC6_PRODUTO),.T.)
						If xFilial('DA1')+PADR(Alltrim(aString[Ni]),3)+Alltrim(sC6_PRODUTO) ==;
						DA1->DA1_FILIAL  +DA1->DA1_CODTAB             +Alltrim(DA1->DA1_CODPRO)
							If !Empty(SA1->A1_SUFRAMA)
								If DA1->DA1_PRCSUF > 0 
									nValProd := IIF(SE4->E4_XACRP > 0,(DA1->DA1_PRCSUF / ((100-SE4->E4_XACRP)/100)),DA1->DA1_PRCSUF) 	
									sC6_XCDTAB	:= Alltrim(aString[Ni])
								Else
									Alert('Valor Suframa nao Cadastrado Na Tabela De Precos!')
									tRet := .F.
								EndIf		
							Else
								nValProd 	:= IIF(SE4->E4_XACRP > 0,(DA1->DA1_PRCVEN / ((100-SE4->E4_XACRP)/100)),DA1->DA1_PRCVEN) 	
								sC6_XCDTAB	:= Alltrim(aString[Ni])
							EndIf
						EndIf	
					EndIf	
				Next Ni
				If nValProd == 0 
					Alert('Produto Nao Encontrado em Tabelas De Precos!')
					tRet := .F.
				Else
					aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XCDTAB"})] := sC6_XCDTAB
				EndIf	
			Else
				DbSelectArea('DA1') 
				DbSetOrder(2)
				DbSeek(xFilial('DA1')+Alltrim(sC6_PRODUTO),.T.)
				If xFilial('DA1') + Alltrim(sC6_PRODUTO) == DA1->DA1_FILIAL + Alltrim(DA1->DA1_CODPRO)
					If !Empty(SA1->A1_SUFRAMA)
						If DA1->DA1_PRCSUF > 0 
							nValProd := IIF(SE4->E4_XACRP > 0,(DA1->DA1_PRCSUF / ((100-SE4->E4_XACRP)/100)),DA1->DA1_PRCSUF) 	
						Else
							Alert('Valor Suframa nao Cadastrado Na Tabela De Precos!')
							tRet := .F.
						EndIf		
					Else
						nValProd := IIF(SE4->E4_XACRP > 0,(DA1->DA1_PRCVEN / ((100-SE4->E4_XACRP)/100)),DA1->DA1_PRCVEN) 	
					EndIf
				Else
					Alert('Produto Nao Encontrado Na Tabela De Precos Selecionado!')
					tRet := .F.
				EndIf
			EndIf
			IF tRet
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRCVEN"})] := nValProd
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRSFRT"})] := nValProd
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRUNIT"})] := nValProd
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRUNIT"})] := nValProd
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})]  := aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})] * nValProd
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALDESC"})]  := 0
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XDESC"})]  := 0
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_DESCONT"})]  := 0
				aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VITICM"})] := 0
			EndIf
		EndIf
	EndIf
Return(tRet)

************************
User Function VITMIS05()   //Calculo de frete
*************   
	Local tRet 			:= .T.
	If M->C5_XPEDCOM == 'S' // verifica se pedido for comercial ou sem calculo comercial
		u_VITMIS07(N,M->C6_XPRSFRT,aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VITICM"})])
	Else
		aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRCVEN"})] := round(M->C6_XPRSFRT,6)
		aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRUNIT"})] := round(M->C6_XPRSFRT,6)
		aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})]  :=round((M->C6_XPRSFRT * aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})]),2)
	EndIf
Return(tRet)	


************************
User Function VITMIS06(nXCols)   //Calculo ICMS
*************   
Local nValIcm 		:= 0
Local nAlqIcm 		:= 0
Local nC6_VALOR 	:= 0 
Local nC6_VITICM	:= 0
Local sC6_TES		:= ''
Local nLinha        := nXCols //IIF(TYPE ("nXCols") == "U",n,nXCols)
If M->C5_XPEDCOM == 'S' // verifica se pedido for comercial ou sem calculo comercial
	If SF4->F4_MOTICMS  <> ''
		MaFisIni(M->C5_CLIENTE,M->C5_LOJACLI,"C","N",M->C5_TIPOCLI,MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700")
		sC6_TES		:= IIF(!Empty(M->C6_TES),M->C6_TES,aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_TES"})])
		nValCalculo := aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XFRTIT"})] + aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRUNIT"})]
		MaFisAdd( 	aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRODUTO"})],;
					sC6_TES,;
					aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})],;
					nValCalculo,;
					0,;
					"",;
					"",;
					0,;
					0,;
					0,;
					0,;
					0,;
					aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})] * nValCalculo ,;
					0,;
					0,;
					0)
					nValIcm := MaFisRet(1,"IT_VALICM")
					nAlqIcm := MaFisRet(1,"IT_ALIQICM")

		//							_BASEICM    := MaFisRet(nItem,"IT_BASEICM")
		//				_IT_ALIQICM    := MaFisRet(nItem,"IT_ALIQICM")
		//				_QUANTIDADE := MaFisRet(nItem,"IT_QUANT")
		//				_VALICM     := MaFisRet(nItem,"IT_VALICM")
		//				_FRETE      := MaFisRet(nItem,"IT_FRETE")
		//				_VALICMFRETE:= MaFisRet(nItem,"IT_ICMFRETE")
		//				_DESCONTO   := MaFisRet(nItem,"IT_DESCONTO")		   

		MaFisEnd()
		If nAlqIcm > 0 	
			nC6_VALOR	:=  round(aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRSFRT"})],6)
			If M->C5_TPFRETE == 'C'
				nC6_VALOR	+=  round(aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XFRTIT"})],2) 
			EndIF
			nC6_VALOR := round(nC6_VALOR,6) * round(aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})],6)
			nTotVal   := nC6_VALOR 
			nC6_VALOR := round(nC6_VALOR/((100-nAlqIcm)/100),6)
			If SF4->F4_BASEICM > 0 
				nRed := round((100-((nAlqIcm*(100-SF4->F4_BASEICM))/100))/100,6)
				nC6_VALOR := round(nTotVal / nRed,6)
			EndIf
			nC6_VITICM	:= nC6_VALOR - nTotVal
		EndIF

	EndIf
	aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VITICM"})] := nC6_VITICM
	u_VITMIS07(nLinha,aCols[nLinha][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRSFRT"})],nC6_VITICM)
EndIf
Return(.T.)	
	
************************
User Function VITMIS07(nXCols,nC6_XPRSFRT,nC6_VITICM)   //Calculo de frete
*************   
	Local tRet 			:= .T.
	Local nC6_XPRUNIT	:= 0 
	nC6_XPRUNIT :=  aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRUNIT"})]
nC6_PRCVEN	:=  nC6_XPRSFRT//aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XFRTIT"})] 
	If M->C5_TPFRETE == 'C'
		nC6_PRCVEN	+=  aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XFRTIT"})] 
	EndIF
	If nC6_VITICM > 0 
		nC6_PRCVEN := nC6_PRCVEN + (nC6_VITICM / aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})])
	EndIf
	aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRCVEN"})] := round(nC6_PRCVEN,6)
	aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRUNIT"})] := round(nC6_PRCVEN,6)
	aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})]  := round(round(nC6_PRCVEN,6) * round(aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})],6),2)
	nC6_QTDVEN  	:= aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})]
	If nC6_XPRUNIT > nC6_XPRSFRT
		// Pega posicao de campos no ACOLS		
		// os calculos para preencher o campos simulando quando o usuario digita o % do desconto ou valor do desconto
		nValDesc := (nC6_XPRUNIT - nC6_XPRSFRT) * nC6_QTDVEN
		aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XDESC"})] := 100-((nC6_XPRSFRT/nC6_XPRUNIT)*100)
		aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_DESCONT"})] := 0
	Else
		// No caso de digitacao de valor = ao valor total,   zerado as variaveis de desconto.
		aCols[nXCols][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XDESC"})] := 0
	EndIf	
Return(tRet)	


**************************
User Function VITMIS08()   // Verifica CGC CLiente e Gera A1_COD, A1_LOJA
*************
tRet := .T.
If M->C5_XPEDCOM == 'S' // verifica se pedido for comercial ou sem calculo comercial
	iF M->C5_XTBFRAX == '1' // Verifica se no cliente foi selecionado opcao de mais de uma tabela de frete por cliente
		iF SA1->A1_XALTFRT <> 'S' .And.  Alltrim(M->C5_XCDZA1) <> Alltrim(SA1->A1_CODZA1)
			msgbox("Tabela De Frete Diferente Da Cadatrada No CLiente!")
			tRet := .F.
		EndIf
	EndIf
EndIf
Return(tRet)

**************************
User Function VITMIS09()   // Verifica CGC CLiente e Gera A1_COD, A1_LOJA
*************
tRet := .T.
If M->C5_XPEDCOM == 'S' // verifica se pedido for comercial ou sem calculo comercial
	sC5_XCDZA1 := ''
	iF M->C5_XTBFRAX == '1' // verifica se no pedido de venda selecionada opcao de tabela de frete normal
		iF Empty(SA1->A1_CODZA1)
			msgbox("Tabela De Frete Nao Informada!")
			tRet := .F.
		Else
			sC5_XCDZA1 := SA1->A1_CODZA1
		ENdIf
	ElseiF M->C5_XTBFRAX == '2'  // verifica se no pedido de venda selecionada opcao de tabela de frete especial cidade diferente da cadastrada no cliente
		iF Empty(SA1->A1_XCDZA1)
			msgbox("Tabela De Frete Especial de Entrega Nao Informada!")
			tRet := .F.
		Else
			sC5_XCDZA1 := SA1->A1_XCDZA1
		ENdIf
	EndIf
	If tRet
		DbSelectArea('ZA1')
		DbSetOrder(1)
		iF DbSeek(xFilial('ZA1')+sC5_XCDZA1)
			M->C5_XCDZA1  := sC5_XCDZA1
			M->C5_XESTCL  := ZA1->ZA1_ESTCC2
			M->C5_XCDCC2  := ZA1->ZA1_CODCC2
		EndIf
	EndIf
EndIf
Return(tRet)




************************
USer Function M410LIOK() // PEDIDO DE VENDA LINHA A LINHA
*************   
	Local nI 			:= 0 
	Local nC6_UNSVEN	:= 0 
	Local nC5_XVLFRT	:= 0 
	Local sRet 			:= ''
	Local sVend1 		:= ''
	Local nComis1		:= 0
	Local sVend2 		:= ''
	Local nComis2		:= 0
	Local sVend3 		:= ''
	Local nComis3		:= 0
	Local sVend4 		:= ''
	Local nComis4		:= 0
	Local sVend5 		:= ''
	Local nComis5		:= 0
	Local nTotPed		:= 0 
	Local nC5_VLFRKG	:= 0
	Local nBasComis		:= 0
	Local nComAtu		:= 0  
	Local tRet			:= .T.
	If M->C5_XPEDCOM == 'S'
		If Empty(sRet)
			DbSelectArea('ZA2')
			DbSetOrder(1)
			iF !DbSeek(xFilial('ZA2')+M->C5_XCDZA1)
				sRet := 'Regiao De Cliente Nao Esta Cadastrada!'
			EndIf
		EndIf
		If Empty(sRet) .And. M->C5_TPFRETE == 'C'
			For nI := 1 To Len(aCols)
				IF aCols[nI,len(aHeader)+1] == .f.
					nC6_UNSVEN	+= aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_UNSVEN"})]  
				EndIf	
			Next nI
			iF nC6_UNSVEN > 0 
				While !Eof() .And. xFilial('ZA2')+M->C5_XCDZA1 == ZA2->ZA2_FILIAL+ZA2->ZA2_CODZA1
					If nC6_UNSVEN >= ZA2->ZA2_DEKG .And. nC6_UNSVEN <= ZA2->ZA2_ATEKG  			
						nC5_VLFRKG 	:= ZA2->ZA2_VALOR
					EndIf
					DbSkip()
				EndDo
				For nI := 1 To Len(aCols)
					IF aCols[nI,len(aHeader)+1] == .f.
						nC5_XVLFRT  += ((nC5_VLFRKG/30)*aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XCONV"})])	 * aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})]
						nC5_XVLFRT  := Round(nC5_XVLFRT,2)
						aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XFRTIT"})] := Round(((nC5_VLFRKG/30)*aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XCONV"})]),2)
					EndIf	
				Next nI
			EndIf	
		EndIf	
		If Empty(sRet) .And. M->C5_TPFRETE == 'C'
			For nI := 1 To Len(aCols)
				IF aCols[nI,len(aHeader)+1] == .f.
					If Alltrim(SF4->F4_MOTICMS)  <> ''
						u_VITMIS06(nI) // Busca calcula valor do ICMS
						If aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VITICM"})] == 0 .And. aCols[nI,len(aHeader)+1] == .f. .And. SF4->F4_MOTICMS  <> '' .And. xFilial("SC5") == "010101"
							sRet := 'ICMS Nao Calculado!, Verifique a TES.'
						EndIf
					EndIf
				EndIf
			Next nI	
		EndIf
		If Empty(sRet)
			For nI := 1 To Len(aCols)
				IF aCols[nI,len(aHeader)+1] == .f.
					nC6_UNSVEN	+= aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_UNSVEN"})]  
					nTotPed		+= aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})]  
				EndIf	
			Next nI
			DbSelectArea('SA1')
			DbSetOrder(1)
			iF !DbSeek(xFilial('SA1')+M->C5_CLIENTE+M->C5_LOJACLI)
				sRet := 'Cliente Nao Encontrado!'
			EndIf
		EndIf
		If Empty(sRet) .And. aCols[n,len(aHeader)+1] == .f.
			iF Left(xFilial("SC6"),4) == '0201'
				sC6_XCDTAB  := aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XCDTAB"})]
				DbSelectArea('DA1') 
				DbSetOrder(1)
				DbSeek(xFilial('DA1')+Alltrim(sC6_XCDTAB),.T.)
				If !xFilial('DA1') + Alltrim(sC6_XCDTAB) == DA1->DA1_FILIAL + Alltrim(DA1->DA1_CODTAB)
					sRet := 'Tabela De Frete Nao Encontrada!'
				EndIf
			Else  
				sC6_PRODUTO  := aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_PRODUTO"})]  
				DbSelectArea('DA1') 
				DbSetOrder(2)
				DbSeek(xFilial('DA1')+Alltrim(sC6_PRODUTO),.T.)
				If !xFilial('DA1') + Alltrim(sC6_PRODUTO) == DA1->DA1_FILIAL + Alltrim(DA1->DA1_CODPRO)
					sRet := 'Tabela De Frete Nao Encontrada!'
				EndIf
			EndIF
		EndIf 
		If Empty(sRet)  .And. aCols[n,len(aHeader)+1] == .f.
			DbSelectArea('DA0') 
			DbSetOrder(1)
			iF !DbSeek(xFilial('DA0')+DA1->DA1_CODTAB)
				sRet := 'Tabela De Frete Nao Encontrada!'
			EndIf
		EndIf 
		If Empty(sRet)  .And. aCols[n,len(aHeader)+1] == .f.		
			iF DA0->DA0_CON_DC == 0
				sRet := 'Conversao De Desconto de Comissao Na Tabela De Precos Nao Informada!'
			EndIf
			iF DA0->DA0_COMIS1 == 0
				sRet := 'Comissao Na Tabela De Precos Nao Informada!'
			EndIf
			iF DA0->DA0_COMISM == 0
				sRet := 'Comissao Minima Na Tabela De Precos Nao Informada!'
			EndIf
		EndIf
		If Empty(sRet)	 .And. aCols[n,len(aHeader)+1] == .f.	
			sVend1 		:= M->C5_VEND1
			nComis1		:= DA0->DA0_COMIS1
		EndIf
		If Empty(sRet)  .And. aCols[n,len(aHeader)+1] == .f.
			// Posiciona do registro veinculado na tabel a de vendedores
			DbSelectArea('SA3')
			DbSetOrder(1)
			iF !DbSeek(xFilial('SA3') + M->C5_VEND1)
				sRet := 'Vendedor Invalido!'
			EndIf
		EndIf
		If Empty(sRet) .And. aCols[n,len(aHeader)+1] == .f. .And. aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XDESC"})] > 0 
			nComAtu := nComis1 - (aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XDESC"})]*(DA0->DA0_CON_DC/100))
			If nComAtu <= DA0->DA0_COMISM
				nComAtu := 0 		
				nComis1 := 0 
			EndIf
		EndIf	
		If Empty(sRet)  .And. aCols[n,len(aHeader)+1] == .f. .And. !SA3->A3_TPVINC $ '06|07'
			sRet := 'Pela regrta de comissao s  Vendedor Cadastrado com tipo Represente pode fazer Pedidos de Venda!'				
		EndIF
		If Empty(sRet)  .And. aCols[n,len(aHeader)+1] == .f.
			nTotSac		:= aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})]  
			nBasComis	+= (aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_XPRSFRT"})] * aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_QTDVEN"})])
			sC6_ALTCOM 	:= aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_ALTCOM"})]
			If sC6_ALTCOM == 'S'
				nComis1 := aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS1"})] 
			Else
				nComis1			:= IIF(nComAtu > 0 ,nComAtu, nComis1)
			EndIf	

			DbSelectArea('SA3')
			nA3_Recno := recno()
			//CLIENTE 000252 - PRODUTO - 009087         

			//M->C5_VEND1	-> REPRESENTANTE
			//M->C5_VEND2	-> GER COMERCIAL
			//M->C5_VEND3	-> GER TECNICO
			//M->C5_VEND4	-> TECNICO
			//M->C5_VEND5	-> PREPOSTO
			DbSelectArea('ZA3')
			DbSetOrder(3)
			iF DbSeek(xFilial('ZA3') + SA3->A3_COD)
				sVend2   := ZA3->ZA3_GERSA3
				nValCRep := (nComis1/100)*nBasComis
				nValCRep := (ZA3->ZA3_COMIS/100)*nValCRep
				nComis2  := (nValCRep/nBasComis)*100
			EndIf 
			If !Empty(SA3->A3_GEREN)
				DbSelectArea('SA3')
				DbSetOrder(1)
				iF DbSeek(xFilial('SA3')+SA3->A3_GEREN) .And. SA3->A3_TPVINC=='05'
					sVend3   := SA3->A3_COD
					nComis3 := ((SA3->A3_COMSAC*nTotSac)/nBasComis)*100
				EndIf
			EndIF 
			DbSelectArea('SA3')
			DbGoto(nA3_Recno)
			If !Empty(SA3->A3_XCDTEC)
				DbSetOrder(1)
				iF DbSeek(xFilial('SA3')+SA3->A3_XCDTEC) .And. SA3->A3_TPVINC=='04'
					sVend4   := SA3->A3_COD
					nComis4 := ((SA3->A3_COMSAC*nTotSac)/nBasComis)*100
				EndIf
			EndIF 
			DbGoto(nA3_Recno)
			If !Empty(SA3->A3_XCDPREP)
				nA3_COMIS  := SA3->A3_COMIS // comissao do representante do preposto estara no preposto.
				DbSetOrder(1)
				iF DbSeek(xFilial('SA3')+SA3->A3_XCDPREP) .And. SA3->A3_TPVINC$'07|06'
					sVend5   := SA3->A3_COD
					nComis5  := nA3_COMIS
				EndIf
			EndIF 

			M->C5_VEND1		:= sVend1
			M->C5_VEND2		:= sVend2
			M->C5_VEND3		:= sVend3
			M->C5_VEND4		:= sVend4
			M->C5_VEND5		:= sVend5
		EndIf
		M->C5_XVLFRT 	:= nC5_XVLFRT
		M->C5_VLFRKG	:= nC5_VLFRKG
		IF aCols[n,len(aHeader)+1] == .f.
			// grava na tela os campos calculados..
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS1"})] := nComis1
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS2"})] := nComis2
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS3"})] := nComis3
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS4"})] := nComis4
			aCols[n][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS5"})] := nComis5
		EndIf
		If !Empty(sRet)
			MessageBox(sRet,"",16)
			tRet     := .F.
		Else	
			nC6_VITICM := 0 
			nC6_VALOR  := 0 
			For nI := 1 To Len(aCols)
				IF aCols[nI,len(aHeader)+1] == .f.
					nC6_VITICM += aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VITICM"})]				
					nC6_VALOR  += aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})]				
				EndIf	
			Next nI
			M->C5_XTOTAL := nC6_VALOR-nC6_VITICM
		EndIf
		If Type("oGetDad") <> "U"
			oGetDad:oBrowse:Refresh()	
		EndIf	
	EndIf
Return(tRet)


**************************
User Function MTA410()
*************
	Local tRet     	:= .T.
	Local nI 	   	:= 0
	Local nBasComis	:= 0 
	Local ntComis1  := 0 
	Local ntComis2  := 0 
	Local ntComis3  := 0 
	Local ntComis4  := 0 
	Local ntComis5  := 0 
	If M->C5_XPEDCOM == 'S' // verifica se pedido for comercial ou sem calculo comercial
		//busca total de sacos no pedido de venda
		For nI := 1 to Len(aCols)
			IF aCols[nI,len(aHeader)+1] == .f.
				nBasComis	+= aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})] 
				ntComis1  	+= (aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})] * aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS1"})]) / 100
				ntComis2  	+= (aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})] * aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS2"})]) / 100
				ntComis3  	+= (aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})] * aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS3"})]) / 100
				ntComis4  	+= (aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})] * aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS4"})]) / 100
				ntComis5  	+= (aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_VALOR"})] * aCols[nI][aSCAN(aHEADER, {|x| AllTrim(Upper(X[2])) == "C6_COMIS5"})]) / 100
			ENdIf
		Next nI
		M->C5_COMIS1 := iif(ntComis1 > 0 .And. nBasComis> 0, ((ntComis1/nBasComis) * 100),0)
		M->C5_COMIS2 := iif(ntComis2 > 0 .And. nBasComis> 0, ((ntComis2/nBasComis) * 100),0)
		M->C5_COMIS3 := iif(ntComis3 > 0 .And. nBasComis> 0, ((ntComis3/nBasComis) * 100),0)
		M->C5_COMIS4 := iif(ntComis4 > 0 .And. nBasComis> 0, ((ntComis4/nBasComis) * 100),0)
		M->C5_COMIS5 := iif(ntComis5 > 0 .And. nBasComis> 0, ((ntComis5/nBasComis) * 100),0)
	EndIf
Return(tRet)

************************
User Function M410STTS() // Executado Apos Gravacao do Pedido De Venda
*************
Local sC5_BLQ := ''
iF Empty(SC5->C5_BLQ) .And. SC5->C5_XPEDCOM == 'S'
	DbSelectArea('ACT') 
	DbSetOrder(3)
	DbSeek(xFilial('ACT')+Alltrim(SC5->C5_CONDPAG),.T.)
	iF xFilial('ACT')+Alltrim(SC5->C5_CONDPAG) == ACT->ACT_FILIAL + Alltrim(ACT->ACT_CONDPG) .And. ACT->ACT_TPRGNG == '1' .And. Empty(ACT->ACT_CODTAB)
		sC5_BLQ := fVITM02(ACT->ACT_CODREG)
	EndIf
	iF Empty(SC5->C5_BLQ) 
		dbSelectArea("SC6")
		dbSetOrder(1)
		DbSeek(xFilial('SC6')+SC5->C5_NUM,.T.)
		While !Eof() .And. xFilial('SC6')+SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
			DbSelectArea('ACN') 
			DbSetOrder(4)
			DbSeek(xFilial('ACN') + SC6->C6_XCDTAB,.T.)
			iF xFilial('ACN') + SC6->C6_XCDTAB == ACN->ACN_FILIAL + Alltrim(ACN->ACN_XCDDA0)
				If SC6->C6_XDESC >= ACN->ACN_XDESC
					sC5_BLQ := fVITM02(ACN->ACN_CODREG)
				EndIf	
			EndIf	
			dbSelectArea("SC6")
			DbSkip()
		EndDo
	EndIf
EndIF
RecLock('SC5', .F.)
	SC5->C5_BLQ := sC5_BLQ
MsUnlock('SC5')
Return()


/*/{Protheus.doc} fVITM02
	(fAZ VERIFICACAO SE REGISTRO SERA BLOQUEADO)
	@type  Static Function
	@author MArcio Da Silva
	@since 08/02/2023
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function fVITM02(sACS_CODREG)
	Local sRetASC := ''
	DbSelectArea('ACS') 
	DbSetOrder(1)
	DbSeek(xFilial('ACS')+sACS_CODREG,.T.)
	iF xFilial('ACS')+sACS_CODREG == ACS->ACS_FILIAL+ACS->ACS_CODREG 
		If DToS(DDataBase) >= Dtos(ACS->ACS_DATDE) .And. dTos(DDataBase) <= Dtos(ACS->ACS_DATATE)
			If !Empty(ACS->ACS_CODCLI)
				If ACS->ACS_CODCLI == SC6->C6_CLI .And. ACS->ACS_LOJA == SC6->C6_LOJA
					sRetASC := '1'
				EndIf 
			Else 
				sRetASC := '1'
			EndIf
		EndIf 
	EndIf
Return sRetASC



************************
User Function OM200QRY()        // Antes gerar query para selecionar os pedidos de venda para query
*************
    Local cQuery      := PARAMIXB[1] //Query para a manuten  o
    //Local aArrayTipo := PARAMIXB[2] //Tipos de carga selecionados
    //Local aArrayMod  := PARAMIXB[3] //Modelos de carga
    //Local nQuery      := PARAMIXB[4] //N mero da query no UNION (1,2)
	cQuery := StrTran(cQuery, "AND SC9.C9_BLEST    = '  '", "")
Return cQuery


************************
User Function OM200CAR()        // apos selecionar os pedidos para carga faz revalidacao
*************
Local cQuery := PARAMIXB[1]
cQuery := StrTran(cQuery, "AND SC9.C9_BLEST  = '  '", "")
Return cQuery


************************
User Function FA740BRW()        // USada Funcao FINA740 FUNCOES CONTAS A RECBER - Criacao de menu para impressao de BOleto
*************
Local aMen001 := {}
Local aMen002 := {}
aAdd(aMen002, {'Imprimir Boleto',"U_VIT005",   0 , 3 })
aAdd(aMen001, {'Boleto',aMen002,   0 , 3    })
Return(aMen001)



***********************
User Function MTA455P() // grava numero de carga e sequencia no item do pedido, para depois voltar no ponto de entrada apos a liberacao de estoque do pedido
*************
Local aAreaSalva 	:= GetArea()
DbSelectArea('SC6')
DbSetOrder(1)
iF DbSeek(xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM)
	If PARAMIXB[1] == 2
		RecLock('SC6', .F.)
			SC6->C6_XCARGA := SC9->C9_CARGA
			SC6->C6_XITECG := SC9->C9_SEQCAR
			SC6->C6_XSEQCE := SC9->C9_SEQENT
		MsUnlock('SC6')
		RecLock('SC9', .F.)
			SC9->C9_CARGA	:= ''
			SC9->C9_SEQCAR	:= ''
			SC9->C9_SEQENT	:= ''
		MsUnlock('SC9')
	EndIf
EndIf
RestArea(aAreaSalva)
return(.T.)


************************
User Function MTA440C9()  // verifica se o pedido liberado estava com carga, tendo a carga volta ao item inicial do sc9 o numero da carga
*************
Local aAreaSalva := GetArea() // tirar while
DbSelectArea('SC6')
DbSetOrder(1)
iF DbSeek(xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM) .And. !Empty(SC6->C6_XCARGA)
	RecLock('SC9', .F.)
		SC9->C9_CARGA	:= SC6->C6_XCARGA
		SC9->C9_SEQCAR	:= SC6->C6_XITECG
		SC9->C9_SEQENT	:= SC6->C6_XSEQCE
	MsUnlock('SC9')
EndIf
RestArea(aAreaSalva)
return(.T.)


************************
User Function MTA455I()  // Apos gravacao ou erro no SC9 LIBERACAO DE ESTOQUE VOLTA CARGA
*************
Local aAreaSalva := GetArea()
Local nRecnoSC9  	:= SC9->(Recno())
Local sReg 			:= xFilial('SC9')+SC9->C9_PEDIDO+SC9->C9_ITEM
DbSelectArea('SC9')
While !Eof() .And. 	sReg == xFilial('SC9')+SC9->C9_PEDIDO+SC9->C9_ITEM			
	DbSelectArea('SC6')
	DbSetOrder(1)
	iF DbSeek(xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM) .And. !Empty(SC6->C6_XCARGA)
		RecLock('SC9', .F.)
			SC9->C9_CARGA	:= SC6->C6_XCARGA
			SC9->C9_SEQCAR	:= SC6->C6_XITECG
			SC9->C9_SEQENT	:= SC6->C6_XSEQCE
		MsUnlock('SC9')
	EndIf
	DbSelectArea('SC9')
	DbSkip()
EndDo
SC9->(dbGoto(nRecnoSC9))
RestArea(aAreaSalva)
return(.T.)


************************
User Function DL200BRW() // criacao de campo para Browse
*************
    Local aRet  := PARAMIXB
    aAdd(aRet,{"PED_ENTREG", ,"Dt Entrega"})
Return aRet


************************
User Function DL200TRB() // DSefinicao dos Campos
*************
    Local aRet  := PARAMIXB
    aAdd(aRet,{"PED_ENTREG", "D", 8, 0})
Return aRet

************************
User Function OM200GRV() //Grava dados nos campos criados
*************
    TRBPED->(DbGoTop())
    Do While TRBPED->(!Eof())
        cTrDesc := ""
        SC6->(DbSetOrder(1))
        If SC6->(DbSeek(FwxFilial("SC6") + TRBPED->PED_PEDIDO + TRBPED->PED_ITEM))
			If RecLock("TRBPED", .F.)
				TRBPED->PED_ENTREG := SC6->C6_ENTREG 
				TRBPED->(MsUnlock())
			EndIf
        EndIf
        TRBPED->(DbSkip())
    EndDo
Return


************************ 
User Function M460FIM() //Grava  o dos dados ap s gerar NF de Sa da
*************
    Local cPedido  		:= ''
    Local aAreaSF2 := SF2->(GetArea())
    Local aAreaSD2 := sd2->(GetArea())
    Local aAreaSC5 := sc5->(GetArea())
    Local aAreaSE1 := sE1->(GetArea())
    Local aAreaSA1 := sA1->(GetArea())
    //Pega o pedido
    DbSelectArea("SD2")
    SD2->(DbSetorder(3))
    If SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
        cPedido 	:= SD2->D2_PEDIDO
    Endif          
    //Se tiver pedido
    If !Empty(cPedido)
        DbSelectArea("SC5")
        SC5->(DbSetorder(1))
        If SC5->(DbSeek(FWxFilial('SC5')+cPedido)) .And. SC5->C5_XGERBOL == 'S'
			//Filtra t tulos dessa nota
			cSql := "SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SE1")
			cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND D_E_L_E_T_<>'*' "
			cSql += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"' "
			cSql += " AND E1_PEDIDO  = '"+SC5->C5_NUM+"' "
			TcQuery ChangeQuery(cSql) New Alias "_QRY"
			
			//Enquanto tiver dados na query
			While !_QRY->(eof())
				DbSelectArea("SE1")
				SE1->(DbGoTo(_QRY->REC))
				//Se tiver dado, altera o tipo de pagamento
				If !SE1->(EoF())
					RecLock("SE1",.F.)
					SE1->E1_PORTADO	:= SC5->C5_XCDSA6
					SE1->E1_AGEDEP 	:= SC5->C5_XAGENC
					SE1->E1_CONTA	:= SC5->C5_XNUMCON
					MsUnlock()
				EndIf
				_QRY->(DbSkip())
			Enddo
			_QRY->(DbCloseArea())
        Endif
    Endif     
    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
    RestArea(aAreaSC5)
    RestArea(aAreaSE1)
    RestArea(aAreaSA1)
Return

***********************
User Function MSE3440() // Ponto De entrada Apos a Gravacao da COmissao e recalcular a Base da Comissao
*************
Local aDados := {}
Local nDescont := PARAMIXB[1]
Local nJurios := PARAMIXB[2]
Local corigem := PARAMIXB[3]
Local nX      := 0 

IF TYPE ("Paramlxb") == "A"
	aDados := aClone(Paramlxb)
endif
If !Empty(SE3->E3_PEDIDO)
	DbSelectArea('SC5') 
	DbSetOrder(1)
	iF DbSeek(xFilial('SC5')+Alltrim(SE3->E3_PEDIDO))
		iF SC5->C5_XVLFRT > 0 
		/*
			nValPed := 0
			DbSelectArea('SC6') 
			DbSetOrder(1)
			DbSeek(xFilial('SC6')+SC5->C5_NUM,.T.)
			While !Eof() .And. xFilial('SC6')+SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM
				nValPed += SC6->C6_VALOR
				DbSkip()
			EndDo
			nFrtPerc := SC5->C5_XVLFRTSC6->C6_VALOR/

			nNroParc := 1
			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4")+SC5->C5_CONDPAG,.T.)
			iF SC5->C5_CONDPAG == SE4->E4_CODIGO
				nX := 0 
				For nX:= 1 To Len(alltrim(SE4->E4_COND))
					If Subs(SE4->E4_COND,nX,1) == ","
						nNroParc := nNroParc + 1
					EndIf
				Next nX
			EndIf

		*/
//			nFrtPerc := (SC5->C5_XVLFRT / SC6->C6_VALOR) * 100

			nNroParc := 1
			dbSelectArea("SE4")
			dbSetOrder(1)
			dbSeek(xFilial("SE4")+SC5->C5_CONDPAG,.T.)
			iF SC5->C5_CONDPAG == SE4->E4_CODIGO
				For nX:= 1 To Len(alltrim(SE4->E4_COND))
					If Subs(SE4->E4_COND,nX,1) == ","
						nNroParc := nNroParc + 1
					EndIf
				Next nX
			EndIf
			nValFrtP := SC5->C5_XVLFRT/nNroParc
			nFrtPerc := (nValFrtP / SE1->E1_VALOR) * 100
			nE3_BASE := SE3->E3_BASE - ((SE3->E3_BASE * nFrtPerc) / 100)
			nE3_COMIS := (nE3_BASE * SE3->E3_PORC)/100
			RecLock('SE3', .F.)
				SE3->E3_BASE  := nE3_BASE
				SE3->E3_COMIS := nE3_COMIS
			MsUnlock('SE3')
		EndIf
	EndIf
EndIf
Return aDados

*************************
User Function FISENVNFE() //Apos a Trsnmissao da NFE Sefaz
*************
Local aIdNfe    := PARAMIXB[1]
Local cIdsNfe   := ""
Local nX        := 0
If Len(aIdNfe) > 0
	aTitulos	:= {}
	For nX := 1 To Len(aIdNfe)
		DbSelectArea('SF2')
		sF2_SERIE 	:= LEFT(aIdNfe[Nx],3)
		sF2_DOC	 	:= RIGHT(aIdNfe[Nx],len(aIdNfe[Nx])-3)
//		cIdsNfe += aIdNfe[Nx]
		DbSetOrder(1)
		iF DbSeek(xFilial('SF2')+sF2_DOC+sF2_SERIE)
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC,.T.)
			While !Eof() .And. xFilial("SE1") + SF2->F2_PREFIXO + SF2->F2_DOC == SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM
				If !Empty(SE1->E1_PORTADO)
					aAdd(aTitulos, {	.F.,;						// 1=Mark
					SE1->E1_PREFIXO,;		// 2=Prefixo do T tulo
					SE1->E1_NUM,;			// 3=N mero do T tulo
					SE1->E1_PARCELA,;		// 4=Parcela do T tulo
					SE1->E1_TIPO,;			// 5=Tipo do T tulo
					SE1->E1_NATUREZ,;		// 6=Natureza do T tulo
					SE1->E1_CLIENTE,;		// 7=Cliente do t tulo
					SE1->E1_LOJA,;			// 8=Loja do Cliente
					SE1->E1_NOMCLI,;		// 9=Nome do Cliente
					SE1->E1_EMISSAO,;		//10=Data de Emiss o do T tulo
					SE1->E1_VENCTO,;		//11=Data de Vencimento do T tulo
					SE1->E1_VENCREA,;		//12=Data de Vencimento Real do T tulo
					SE1->E1_VALOR,;			//13=Valor do T tulo
					SE1->E1_HIST,;			//14=Hist tico do T tulo
					Recno(),;		//15=N mero do registro no arquivo
					SE1->E1_NUMBCO ;		//16=Nosso N mero
					})
				EndIf	
				DbSkip()
			EndDo
		EndIf
	Next nX    
	If Len(aTitulos) > 0
		U_VIT005A(aTitulos)
	EndIf
EndIf
Return Nil

*************************
User Function FISTRFNFE()  // inclusao de rotina no MENU DO SEFAZ
*************  
aadd(aRotina,{'Impressao De Boleto','U_VIT005' , 0 , 3,0,NIL})
Return Nil 

*************************
User Function M440STTS()  // Apos Liberacao do pedido de venda manual, apos a gravacao do SC9
//REAGRA SOLICITADA PELA EMPRESA PARA BLOQUEAR NO FINANCEIRO TODOS OS PEDIDO COM A CONDICAO DE PAGAMENTO = 000
*************  
DbSelectArea('SC9') 
DbSetOrder(1)
DbSeek(xFilial('SC9')+Alltrim(SC5->C5_NUM),.T.)
While !Eof() .And. xFilial('SC9')+Alltrim(SC5->C5_NUM) == SC9->C9_FILIAL + SC9->C9_PEDIDO 
	If Empty(SC9->C9_NFISCAL) 
		dbSelectArea("SC6")
		dbSetOrder(1)
		DbSeek(xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO,.T.)
		iF xFilial('SC6')+SC9->C9_PEDIDO+ SC9->C9_ITEM + SC9->C9_PRODUTO == ;
		   SC6->C6_FILIAL+SC6->C6_NUM   + SC6->C6_ITEM + SC6->C6_PRODUTO
			RecLock('SC6', .F.)
				SC6->C6_XCARGA := ''
				SC6->C6_XITECG := ''
				SC6->C6_XSEQCE := ''
				SC6->C6_LOTECTL := ''
				SC6->C6_NUMLOTE := ''
				SC6->C6_DTVALID := CTOD('  /  /  ')
			MsUnlock('SC6')
		EndIf  	
		DbSelectArea('SC9') 
		RecLock('SC9', .F.)
			SC9->C9_CARGA  := ''
			SC9->C9_SEQCAR := ''
			SC9->C9_SEQENT := ''
			iF SC5->C5_CONDPAG == '000'
				SC9->C9_BLCRED := '01'
			EndIf	
		MsUnlock('SC9')
	EndIf
	DbSkip()
EndDo
Return()



*************************
User Function FR650FIL()  // Seta no banco o Registro que veio do CNAB
*************  
Local aValores := PARAMIXB
Local lRet     := .F.
Local cArea	   := Alias()
Local nOrdem   := indexOrd()
If Mv_PAR07 == 1 
	If SEE->EE_CODIGO == '237' .Or.  SEE->EE_CODIGO == '001'
		DbSelectArea('SE1') 
		DbSetOrder(30)
		DbSeek(xFilial("SE1")+Alltrim(aValores[1,4]),.T.)
		iF xFilial("SE1")+Alltrim(aValores[1,4]) == SE1->E1_FILIAL+Alltrim(SE1->E1_NUMBCO)
			lRet     := .T.
		EndIf
	EndIf
EndIF
If Mv_PAR07 == 2 
	If SEE->EE_CODIGO == '237'
		DbSelectArea('SE2') 
		DbSetOrder(11)
		DbSeek(xFilial("SE2")+Alltrim(aValores[1,4]),.T.)
		iF xFilial("SE2")+Alltrim(aValores[1,4]) == SE2->E2_FILIAL+Alltrim(SE2->E2_IDCNAB)
			lRet     := .T.
		EndIf
	EndIf
EndIF
DbSelectArea(cArea) 
DbSetOrder(nOrdem)
Return(lRet)


************************
USER FUNCTION FA200POS() // Posiciona no registro do SE1 BANCO BRADESCO
*************
LOCAL _cNsNum   := Padr(Alltrim(cNsNum),15) 
LOCAL aAreaSE1  := GetArea()
LOCAL nIndex    := IndexOrd()
LOCAL tRet      := .F.
If SEE->EE_CODIGO == '237' .Or. SEE->EE_CODIGO == '001'
	DbSelectArea('SE1') 
	DbSetOrder(30)
	DbSeek(xFilial("SE1")+Alltrim(_cNsNum),.T.)
	iF xFilial("SE1")+Alltrim(_cNsNum) == SE1->E1_FILIAL+Alltrim(SE1->E1_NUMBCO)
		cNumTit  := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
		cEspecie := SE1->E1_TIPO
		tRet	 := .T.
	EndIf
EndIf//000136
DbSelectArea(aAreaSE1) 
DbSetOrder(nIndex)
Return(tRet)


************************
USER FUNCTION FA200FIL() // Posiciona no registro do SE1 BANCO BRADESCO
*************
LOCAL _cNsNum   := Padr(Alltrim(cNsNum),15) 
LOCAL aAreaSE1  := GetArea()
LOCAL nIndex    := IndexOrd()
If SEE->EE_CODIGO == '237' .Or. SEE->EE_CODIGO == '001'
	DbSelectArea('SE1') 
	DbSetOrder(30)
	DbSeek(xFilial("SE1")+Alltrim(_cNsNum),.T.)
	iF xFilial("SE1")+Alltrim(_cNsNum) == SE1->E1_FILIAL+Alltrim(SE1->E1_NUMBCO)
		cNumTit  := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA
		cEspecie := SE1->E1_TIPO
	EndIf
EndIf
DbSelectArea(aAreaSE1) 
DbSetOrder(nIndex)
Return


************************
User FUNCTION FA60FIL() // FILTRO BORDERO A RECEBER FINA060
*************
PRIVATE _FIL := "E1_PORTADO == '"+Alltrim(CPORT060)+"'"
RETURN(_FIL)//cport060


**************************
User Function VITMIS10()   // Verifica CGC CLiente e Gera A1_COD, A1_LOJA
*************
Local _ni   	:= 0 
Local sErro 	:= ''
Local tPassou 	:= .F.
Local tRet 		:= .T.

sC5_NUM 	:= M->C5_NUM

dbSelectarea("SC5")
DbSetOrder(1)
If (DbSeek(xFilial("SC5")+M->C5_XPEDVF))
    iF SC5->C5_XVENFUT <> '2'
		sErro := 'Favor selecionar Pedido que seja configurado como PAI da venda Futura!'
	EndIf 
	IF Empty(sErro)
		cQuery := " SELECT SC6P.R_E_C_N_O_  AS SC6P_REG,  SC6P.C6_PRODUTO, SC6P.C6_QTDVEN  C6_QTD_P, "

		cQuery += " (SELECT SUM(SC6F.C6_QTDVEN) FROM " + RetSqlName("SC5") + " SC5F, " + RetSqlName("SC6") + " SC6F "
		cQuery += " WHERE SC5F.C5_FILIAL = SC6F.C6_FILIAL AND SC5F.C5_NUM = SC6F.C6_NUM  "
		cQuery += " AND SC5F.C5_XPEDVF = SC5P.C5_NUM AND SC6P.C6_PRODUTO = SC6F.C6_PRODUTO  AND SC6F.D_E_L_E_T_ = '') C6_QTD_F "

		cQuery += " FROM " + RetSqlName("SC5") + " SC5P " 
		cQuery += " INNER JOIN " + RetSqlName("SC6") + " SC6P ON SC5P.C5_FILIAL = SC6P.C6_FILIAL AND SC5P.C5_NUM = SC6P.C6_NUM AND SC6P.D_E_L_E_T_ = '' "
		cQuery += " WHERE SC5P.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5P.C5_NUM ='"+SC5->C5_NUM+"' AND C5_XVENFUT = '2' AND SC5P.D_E_L_E_T_ = '' "
		If ( Select ( "TRBCSC5" ) <> 0 )
			dbSelectArea ( "TRBCSC5" )
			dbCloseArea ()
		EndIf
		TCQUERY cQuery NEW ALIAS "TRBCSC5"

		DbSelectArea("TRBCSC5")
		DbGotop()
		nItem 		:= 0 
		nC6_VALOR	:= 0 

		While !Eof()
			If TRBCSC5->C6_QTD_P > TRBCSC5->C6_QTD_F
				If !tPassou
					tPassou:= .T.
					dbSelectArea("SX3")
					dbSetOrder(1)
					dbSeek('SC5',.t.)
					While !Eof() .And. SX3->X3_ARQUIVO == 'SC5'
						If X3USO(x3_usado) .And. Alltrim(X3_CAMPO) <> 'C5_NUM' .And. Alltrim(X3_CAMPO) <> 'C5_XVENFUT' .And. X3_CONTEXT<>'V'
							sVar_F  := 'M->'+Alltrim(X3_CAMPO)
							sVar_P  := 'SC5->'+Alltrim(X3_CAMPO)
							&sVar_F := &sVar_P
						EndIF
						dbSelectArea("SX3")
						DbSkip()
					EndDo
					M->C5_NUM 		:= sC5_NUM 	
					M->C5_XPEDVF  	:= SC5->C5_NUM
					M->C5_XVENFUT 	:= '3'
					M->C5_CONDPAG 	:= '999'
				EndIF	
				sC6_TES := IIF(SA1->A1_EST == 'RO','601','610')
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial("SF4") + sC6_TES,.t.)


				dbSelectArea("SC6")
				DbGoto(TRBCSC5->SC6P_REG)
				nItem += 1 
				If nItem >= 2
					oGetDad:AddLine()
				EndIf
				For _ni:=1 to Len(aHEADER)
					If Alltrim(aHeader[_ni,2]) == "C6_ITEM"
						aCols[Len(aCols),_ni]	:=	StrZero(nItem,2)
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_QTDVEN"
						aCols[Len(aCols),_ni]	:=	TRBCSC5->C6_QTD_P - TRBCSC5->C6_QTD_F
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_PRCVEN"
						aCols[Len(aCols),_ni]	:=	FieldGet(FieldPos(aHeader[_ni,2]))
						nC6_VALOR				:=  FieldGet(FieldPos(aHeader[_ni,2])) * (TRBCSC5->C6_QTD_P - TRBCSC5->C6_QTD_F)
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_VALOR"
						aCols[Len(aCols),_ni]	:=	nC6_VALOR
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_TES"
						aCols[Len(aCols),_ni]	:=	IIF(SA1->A1_EST == 'RO','601','610')
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_CF"
						aCols[Len(aCols),_ni]	:=	IIF(SA1->A1_EST == 'RO','5116','6116')
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_CLASFIS"
						aCols[Len(aCols),_ni]	:=	'0'+SF4->F4_SITTRIB
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_OPER"
						aCols[Len(aCols),_ni]	:=	'02'
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_UNSVEN"
						aCols[Len(aCols),_ni]	:=	(TRBCSC5->C6_QTD_P - TRBCSC5->C6_QTD_F) * 30
					ElseIf Alltrim(aHeader[_ni,2]) == "C6_XCONV"
						aCols[Len(aCols),_ni]	:=	aCols[len(aCols),_ni]
					Else	
						aCols[Len(aCols),_ni]	:=	FieldGet(FieldPos(aHeader[_ni,2]))
					EndIF	
				Next
			EndIf	
			DbSelectArea("TRBCSC5")
			DbSkip()
		EndDo
		If !tPassou .And. Empty(sErro)
			sErro := "Pedido Mae Sem Saldo Para Gerar Remessa!"
		EndIf
	EndIf	
EndIF
IF !Empty(sErro)
	ALERT(sErro)
	tRet 		:= .F.
EndIF
Return(tRet)

************************
User Function OS200EST()//no estorno da carga
*************
    Local aArea   := GetArea()
    Local cCarga  := PARAMIXB[1]
    Local cSeqCar := PARAMIXB[2]
    Local cQry    := ""
     
    DbSelectArea('SC5')
    SC5->(DbSetOrder(1))
     
    //Seleciona os pedidos conforme a carga
    cQry := " SELECT SC6.R_E_C_N_O_ C6_REG, SC9.R_E_C_N_O_ C9_REG, SC5.R_E_C_N_O_ C5_REG, SB2.R_E_C_N_O_ B2_REG, SB8.R_E_C_N_O_ B8_REG "
    cQry += " FROM "
    cQry += "    "+RetSQLName('SC9')+" SC9 "
	cQry += " INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial('SC5')+"' AND C5_NUM      = C9_PEDIDO AND  SC5.D_E_L_E_T_ = '' "
	cQry += " INNER JOIN "+RetSqlName("SC6")+" SC6 ON C6_FILIAL = '"+xFilial('SC6')+"' AND C6_NUM      = C9_PEDIDO AND C6_ITEM = C9_ITEM AND C6_PRODUTO = C9_PRODUTO AND  SC6.D_E_L_E_T_ = '' "
    cQry += " INNER JOIN "+RetSqlName("SB8")+" SB8 ON B8_FILIAL = '"+xFilial('SB8')+"' AND B8_LOCAL = C9_LOCAL AND B8_PRODUTO = C9_PRODUTO AND B8_LOTECTL = C9_LOTECTL AND B8_EMPENHO > 0 AND  SB8.D_E_L_E_T_ = '' "
    cQry += " INNER JOIN "+RetSqlName("SB2")+" SB2 ON B2_FILIAL = '"+xFilial('SB2')+"' AND B2_LOCAL = C9_LOCAL AND B2_COD = C9_PRODUTO AND  SB2.D_E_L_E_T_ = '' "
    cQry += " WHERE "
    cQry += "    C9_FILIAL     = '"+FWxFilial('SC9')+"' "
    cQry += "    AND C9_CARGA  = '"+cCarga+"' "
    cQry += "    AND C9_SEQCAR = '"+cSeqCar+"' "
    cQry += "    AND SC9.D_E_L_E_T_ = ' ' "

	If ( Select ( "TRBDAK" ) <> 0 )
		dbSelectArea("TRBDAK")
		dbCloseArea ()
	EndIf

    TCQuery cQry New Alias "TRBDAK"
    //Enquanto houver pedidos
    While ! TRBDAK->(EoF())
        //Se conseguir posicionar, zera os campos
		DbSelectArea("SC9")
		DbGoTo(TRBDAK->C9_REG)
		RecLock("SC9",.F.)
			SC9->C9_LOTECTL := ''
			SC9->C9_NUMLOTE := ''
			SC9->C9_DTVALID := CTOD('  /  /  ')
			SC9->C9_BLEST   := '02'
		MsUnlock("SC9")

		DbSelectArea("SC5")
		DbGoTo(TRBDAK->C5_REG)
		RecLock("SC5",.F.)
			SC5->C5_TRANSP  := ''
		MsUnlock("SC5")

  		DbSelectArea("SB8")
		DbGoTo(TRBDAK->B8_REG)
		RecLock("SB8",.F.)
			SB8->B8_EMPENHO  -= SC9->C9_QTDLIB
			SB8->B8_EMPENH2  -= SC9->C9_QTDLIB2
		MsUnlock("SB8")

  		DbSelectArea("SB2")
		DbGoTo(TRBDAK->B2_REG)
		RecLock("SB2",.F.)
			SB2->B2_RESERVA  -= SC9->C9_QTDLIB
			SB2->B2_RESERV2  -= SC9->C9_QTDLIB2
		MsUnlock("SB2")

		DbSelectArea("SC6")
		DbGoTo(TRBDAK->C6_REG)
		RecLock("SC6",.F.)
		SC6->C6_XCARGA := ''
		SC6->C6_XITECG := ''
		SC6->C6_XSEQCE := ''
		SC6->C6_LOTECTL := ''
		SC6->C6_NUMLOTE := ''
		SC6->C6_DTVALID := CTOD('  /  /  ')
		MsUnlock("SC6")

        TRBDAK->(DbSkip())
    EndDo
    TRBDAK->(DbCloseArea())
    RestArea(aArea)
Return    


***********************
User Function SF2520E()        // Exclusao Da Nf De Saida
*************
dbSelectArea("SC9")
dbSetOrder(6)
dbSeek(xFilial("SC9")+SF2->F2_SERIE+SF2->F2_DOC,.T.)
While !Eof() .And. xFilial("SC9")+SF2->F2_SERIE+SF2->F2_DOC == SC9->C9_FILIAL + SC9->C9_SERIENF + SC9->C9_NFISCAL
	dbSelectArea("DAK")
	dbSetOrder(1)
	dbSeek(xFilial("DAK")+SC9->C9_CARGA,.T.)
	iF xFilial("DAK")+SC9->C9_CARGA == DAK->DAK_FILIAL + DAK->DAK_COD 
		RecLock("DAK",.F.)
		DAK->DAK_FEZNF := '2'
		MsUnlock("DAK")
	EndIf
	DbSelectArea("SC5")
	DbsetOrder(1)
	DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.t.)
	If xFilial("SC5")+SC9->C9_PEDIDO == SC5->C5_FILIAL + SC5->C5_NUM
		RecLock("SC5",.F.)
		SC5->C5_TRANSP := ''
		MsUnlock("SC5")
	EndIf

	DbSelectArea("SC6")
	DbsetOrder(1)
	DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO,.t.)
	If xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO == SC6->C6_FILIAL + SC6->C6_NUM + SC6->C6_ITEM + SC6->C6_PRODUTO
		RecLock("SC6",.F.)
		SC6->C6_XCARGA := ''
		SC6->C6_XITECG := ''
		SC6->C6_XSEQCE := ''
		MsUnlock("SC6")
	EndIf

	dbSelectArea("SC9")
	DbSkip()
EndDo
Return()





User Function MT241SD3()
Local cProd  := SD3->D3_COD
Local nRecno := SD3->(Recno())
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local nY     := 0
Local cDoc   := ""
Local lOk    := .T.         
Private lMsHelpAuto := .T.
PRIVATE lMsErroAuto := .F.


DbSelectArea("SB2")
DbSetOrder(1)
DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL,.T.)
DbSelectArea("SB1")
DbSetOrder(1)
If SB1->(MsSeek(xFilial("SB1")+SD3->D3_COD))	
	If SB1->B1_ESTSEG > SB2->B2_QATU

		alert('gerar solicitacao')
		//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SC1","SB1"
		//                                                              ?
		//| Verificacao do ambiente para teste                           |
		//                                                                
		aCabec := {}		
		aItens := {}		
		//                             ?		
		//| Verifica numero da SC       |		
		//                               		
		cDoc := GetSXENum("SC1","C1_NUM")		
		SC1->(dbSetOrder(1))		
		While SC1->(dbSeek(xFilial("SC1")+cDoc))			
			ConfirmSX8()			
			cDoc := GetSXENum("SC1","C1_NUM")		
		EndDo					
		aadd(aCabec,{"C1_NUM"    ,cDoc})		
		aadd(aCabec,{"C1_SOLICIT","Administrador"})		
		aadd(aCabec,{"C1_EMISSAO",dDataBase})		
//		For nX := 1 To 2			
			aLinha := {}			
			aadd(aLinha,{"C1_ITEM"   ,StrZero(nx,len(SC1->C1_ITEM)),Nil})			
			aadd(aLinha,{"C1_PRODUTO",SB2->B2_COD,Nil})			
			aadd(aLinha,{"C1_QUANT"  ,SB1->B1_LE   ,Nil})			
			aadd(aItens,aLinha)		
//		Next nX		
		//                                                              ?		
		//| Teste de Inclusao                                            |		
		//                                                                		
		MSExecAuto({|x,y| mata110(x,y)},aCabec,aItens)		
		If !lMsErroAuto			
			ALERT(OemToAnsi("Solicita  o De Compra Incluida com sucesso! ")+cDoc)		
		Else		
			MostraErro()	
			ALERT(OemToAnsi("Erro na inclusao!"))		
		EndIf	
	EndIf
EndIf

Return



**************************
User Function VITMIS11()   // Msexecauto MATA410
*************
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local nY     := 0
Local cDoc   := ""
Local lOk    := .T.
PRIVATE lMsErroAuto := .F.


dbSelectArea("SB1")
dbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"008070"))
	lOk := .F.
	ALERT("Cadastrar produto: 000002")
EndIf
dbSelectArea("SF4")
dbSetOrder(1)
If !SF4->(MsSeek(xFilial("SF4")+"501"))
	lOk := .F.
	ALERT("Cadastrar TES: 501")
EndIf
dbSelectArea("SE4")
dbSetOrder(1)
If !SE4->(MsSeek(xFilial("SE4")+"000"))
	lOk := .F.
	ALERT("Cadastrar condicao de pagamento: 001")
EndIf
dbSelectArea("SA3")
dbSetOrder(1)
If !SA3->(MsSeek(xFilial("SA3")+"000011"))
	lOk := .F.
	ALERT("Cadastrar VENDEDOR: 000001")
EndIf
dbSelectArea("SA1")
dbSetOrder(1)
If !SA1->(MsSeek(xFilial("SA1")+"000076"))
	lOk := .F.
	ALERT("Cadastrar cliente: 000001")
EndIf
If lOk
	cDoc := GetSxeNum("SC5","C5_NUM")
	RollBAckSx8()
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"C5_NUM"   ,cDoc,Nil})
	aadd(aCabec,{"C5_TIPO" ,"N",Nil})
	aadd(aCabec,{"C5_CLIENTE",SA1->A1_COD,Nil})
	aadd(aCabec,{"C5_XPEDCOM","S",Nil})
	aadd(aCabec,{"C5_XGERBOL","S",Nil})
	aadd(aCabec,{"C5_XTBFRAX","1",Nil})
	aadd(aCabec,{"C5_XCDZA1","00122B",Nil})
	aadd(aCabec,{"C5_VEND1",SA3->A3_COD,Nil})
	aadd(aCabec,{"C5_TPFRETE","C",Nil})
	aadd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
	aadd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})
	aadd(aCabec,{"C5_CONDPAG",SE4->E4_CODIGO,Nil})
	For nX := 1 To 1
		aLinha := {}
		aadd(aLinha,{"C6_ITEM",StrZero(nX,2),Nil})
		aadd(aLinha,{"C6_PRODUTO",SB1->B1_COD,Nil})
		aadd(aLinha,{"C6_XPRSFRT",95,Nil})
		aadd(aLinha,{"C6_QTDVEN",200,Nil})
		aadd(aLinha,{"C6_PRCVEN",117.575758,Nil})
		aadd(aLinha,{"C6_PRUNIT",117.575758,Nil})   
		aadd(aLinha,{"C6_VALOR",23515.15,Nil})
		aadd(aLinha,{"C6_TES","501",Nil})
		aadd(aItens,aLinha)
	Next nX
	MATA410(aCabec,aItens,3)
	If !lMsErroAuto
		ALERT("Incluido com sucesso! "+cDoc) 
	Else
	MostraErro()
		ALERT("Erro na inclusao!")
	EndIf
EndIf
//RESET ENVIRONMENT
Return(.T.)
