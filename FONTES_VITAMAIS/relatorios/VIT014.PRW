#Include 'Protheus.ch'
#Include 'Protheus.ch'
#INCLUDE 'TOPCONN.CH'

User Function VIT014()
	Local oReport := nil
	Local cPerg:= Padr("VIT014",10)
	
	//Incluo/Altero as perguntas na tabela SX1
	AjustaSX1(cPerg)	
	//gero a pergunta de modo oculto, ficando disponível no botão ações relacionadas
	Pergunte(cPerg,.F.)	          
		
	oReport := RptDef(cPerg)
	oReport:PrintDialog()
Return

Static Function RptDef(cNome)
	Local oReport := Nil
	Local oSection2:= Nil
	Local oSection2:= Nil
	Local oBreak
	Local oFunction
	
	/*Sintaxe: TReport():New(cNome,cTitulo,cPerguntas,bBlocoCodigo,cDescricao)*/
	oReport := TReport():New(cNome,"Relatorio de Venda Futura",cNome,{|oReport| ReportPrint(oReport)},"Descrição do Relatório")
	oReport:SetPortrait()    
	oReport:SetTotalInLine(.F.)
	
	//Monstando a primeira seção
	//Neste exemplo, a primeira seção será composta por duas colunas, código da NCM e sua descrição
	//Iremos disponibilizar para esta seção apenas a tabela SYD, pois quando você for em personalizar
	//e entrar na primeira seção, você terá todos os outros campos disponíveis, com isso, será
	//permitido a inserção dos outros campos
	//Neste exemplo, também, já deixarei definido o nome dos campos, mascara e tamanho, mas você
	//terá toda a liberdade de modificá-los via relatorio. 
	oSection1:= TRSection():New(oReport, "SC6", {"SB1","SC5TRB"}, , .F., .T.)
	TRCell():New(oSection1,"CC6_PRODUTO"	,/*Tabela*/	,"Produto"		         ,PesqPict("SC6","C6_PRODUTO"	),TamSx3("C6_PRODUTO"		)[1],/*lPixel*/,{|| cC6_PRODUTO	})
	TRCell():New(oSection1,"CB1_DESC"		,/*Tabela*/	,RetTitle("B1_DESC"	)	 ,PesqPict("SB1","B1_DESC"		),TamSx3("B1_DESC"			)[1],/*lPixel*/,{|| cB1_DESC 	})

	oSection2:= TRSection():New(oReport, "SC5", {"SC5","SC5TRB"}, , .F., .T.)
	TRCell():New(oSection2,"Cespaco"		,/*Tabela*/	,""		     			 ,PesqPict("SC5","C5_NUM"		),30							,/*lPixel*/,{|| Cespaco		})
	TRCell():New(oSection2,"CC5_NUM"		,/*Tabela*/	,"Pedido MAE"		     ,PesqPict("SC5","C5_NUM"		),TamSx3("C5_NUM"			)[1],/*lPixel*/,{|| cC5_NUM		})
	TRCell():New(oSection2,"CC5_EMISSAO"	,/*Tabela*/	,RetTitle("C5_EMISSAO"	),PesqPict("SC5","C5_EMISSAO"	),TamSx3("C5_EMISSAO"		)[1],/*lPixel*/,{|| cC5_EMISSAO })
	TRCell():New(oSection2,"CC5_CLIENTE"	,/*Tabela*/	,RetTitle("C5_CLIENTE"	),PesqPict("SC5","C5_CLIENTE"	),TamSx3("C5_CLIENTE"		)[1],/*lPixel*/,{|| cC5_CLIENTE	})
	TRCell():New(oSection2,"CC5_LOJACLI"	,/*Tabela*/	,RetTitle("C5_LOJACLI"	),PesqPict("SC5","C5_LOJACLI"	),TamSx3("C5_LOJACLI"		)[1],/*lPixel*/,{|| cC5_LOJACLI	})
	TRCell():New(oSection2,"CA1_NOME"		,/*Tabela*/	,RetTitle("A1_NOME"		),PesqPict("SA1","A1_NOME"		),TamSx3("A1_NOME"			)[1],/*lPixel*/,{|| cA1_NOME	})
	TRCell():New(oSection2,"NTOTPEDIDO"		,/*Tabela*/	,"Qtde Total"            ,PesqPict("SC6","C6_QTDVEN"	),TamSx3("C6_QTDVEN"		)[1],/*lPixel*/,{|| nTotPedido	})
	TRCell():New(oSection2,"NTOTREMESSA"	,/*Tabela*/	,"Qtde Remessa"          ,PesqPict("SC6","C6_QTDVEN"	),TamSx3("C6_QTDVEN"		)[1],/*lPixel*/,{|| nTotRemessa	})
	TRCell():New(oSection2,"NTOTSALDO"		,/*Tabela*/	,"Qtde Saldo"            ,PesqPict("SC6","C6_QTDVEN"	),TamSx3("C6_QTDVEN"		)[1],/*lPixel*/,{|| nTotSaldo	})


	oBreak1 := TRBreak():New( oSection2, "", "Saldo Geral -->", .f. ) //"Total dos Contratos -->"

	TRFunction():New(oSection2:Cell( "NTOTPEDIDO" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell( "NTOTREMESSA" )	, Nil, "SUM"		, oBreak1, , , , .f., .f. )
	TRFunction():New(oSection2:Cell( "NTOTSALDO" )		, Nil, "SUM"		, oBreak1, , , , .f., .f. )


//	oReport:SetTotalInLine(.F.)
        //Aqui, farei uma quebra  por seção
//	oSection2:SetPageBreak(.T.)
//	oSection2:SetTotalText(" ")				
Return(oReport)

Static Function ReportPrint(oReport)
	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)	 
	Local cQuery    := ""		
	Local sPrdIni	:= mv_par01
	Local sPrdFin	:= mv_par02
	Local dDataDe	:= mv_par03
	Local dDataAte	:= mv_par04
	Local cCliDe	:= mv_par05
	Local cCliAte	:= mv_par06
	Local cCodRep	:= mv_par07
	Local nSalRet	:= mv_par08


	//Monto minha consulta conforme parametros passado


	cQuery := "	SELECT SC6PM.C6_PRODUTO SC6PM_C6_PRODUTO, B1_DESC, SC5PM.C5_NUM SC5PM_C5_NUM, "
	cQuery += "	SC5PM.C5_CLIENTE SC5PM_C5_CLIENTE, SC5PM.C5_LOJACLI SC5PM_C5_LOJACLI, SC5PM.C5_EMISSAO SC5PM_C5_EMISSAO, SA1.A1_NOME A1_NOME,  SC6PM.C6_QTDVEN SC6PM_C6_QTDVEN, "
	cQuery += "	(SELECT SUM(C6_QTDVEN) FROM "+RETSQLNAME("SC6")+" SC6PR, "+RETSQLNAME("SC5")+" SC5PR "
	cQuery += "	WHERE SC6PR.C6_FILIAL = SC5PR.C5_FILIAL AND SC6PR.C6_NUM = SC5PR.C5_NUM"
	cQuery += "	AND SC5PM.C5_FILIAL = SC5PR.C5_FILIAL AND SC5PM.C5_NUM = SC5PR.C5_XPEDVF  AND SC5PR.C5_XVENFUT = '3'"
	cQuery += "	AND SC6PR.C6_PRODUTO = SC6PM.C6_PRODUTO "
	cQuery += "	AND SC5PR.D_E_L_E_T_ = '' AND SC6PR.D_E_L_E_T_ = '') SC6PR_C6_REMESSA"	
	cQuery += "	FROM "+RETSQLNAME("SC5")+" SC5PM "	
	cQuery += "	INNER JOIN "+RETSQLNAME("SC6")+" SC6PM ON  SC6PM.C6_FILIAL = SC5PM.C5_FILIAL AND SC6PM.C6_NUM = SC5PM.C5_NUM AND SC6PM.D_E_L_E_T_='' "	
	cQuery += "	INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_COD = SC6PM.C6_PRODUTO AND SC6PM.D_E_L_E_T_='' "	
	cQuery += "	INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON  SA1.A1_COD = SC5PM.C5_CLIENTE AND  SA1.A1_LOJA = SC5PM.C5_LOJACLI AND SA1.D_E_L_E_T_='' "
	cQuery += "	WHERE SC5PM.C5_XVENFUT = '2' AND SC5PM.C5_FILIAL >= '" + xFilial("SC5") + "' "
	cQuery += "	And SC6PM.C6_PRODUTO >= '" + Alltrim(sPrdIni) + "' And SC6PM.C6_PRODUTO <= '" + Alltrim(sPrdFin) + "' "
	cQuery += "	And SC5PM.C5_EMISSAO >= '" + DtoS( dDataDe ) + "' And SC5PM.C5_EMISSAO <= '" + DtoS( dDataAte ) + "' "
	cQuery += "	And SC5PM.C5_CLIENTE >= '" + cCliDe + "' And SC5PM.C5_CLIENTE <= '" + cCliAte + "' "
	cQuery += "	And SC5PM.D_E_L_E_T_='' "

	If !Empty(cCodRep)
		cQuery += "	And SC5PM.C5_VEND1 = '"+Alltrim(cCodRep)+"'"
	EndIF
	If nSalRet == 1
		cQuery += " AND SC6PM.C6_QTDVEN > (SELECT SUM(C6_QTDVEN) FROM "+RETSQLNAME("SC6")+" SC6PR, "+RETSQLNAME("SC5")+" SC5PR "
		cQuery += "	WHERE SC6PR.C6_FILIAL = SC5PR.C5_FILIAL AND SC6PR.C6_NUM = SC5PR.C5_NUM"
		cQuery += "	AND SC5PM.C5_FILIAL = SC5PR.C5_FILIAL AND SC5PM.C5_NUM = SC5PR.C5_XPEDVF  AND SC5PR.C5_XVENFUT = '3'"
		cQuery += "	AND SC6PR.C6_PRODUTO = SC6PM.C6_PRODUTO "
		cQuery += "	AND SC5PR.D_E_L_E_T_ = '' AND SC6PR.D_E_L_E_T_ = '')
	EndIF
	cQuery += "	ORDER BY SC6PM.C6_PRODUTO, SC5PM.C5_NUM"

	//Se o alias estiver aberto, irei fechar, isso ajuda a evitar erros
	IF Select("SC5TRB") <> 0
		DbSelectArea("SC5TRB")
		DbCloseArea()
	ENDIF
	//crio o novo alias
	TCQUERY cQuery NEW ALIAS "SC5TRB"	
	
	dbSelectArea("SC5TRB")
	SC5TRB->(dbGoTop())
	
	oReport:SetMeter(LastRec())	
	oSection1:Init()
	
	//Irei percorrer todos os meus registros
	While !Eof()
		
		If oReport:Cancel()
			Exit
		EndIf

		//inicializo a primeira seção



		oReport:IncMeter()
					
		IncProc("Imprimindo ")

		//imprimo a primeira seção				

		oSection1:Cell("CC6_PRODUTO"):SetValue(SC5TRB->SC6PM_C6_PRODUTO)
		oSection1:Cell("CB1_DESC"):SetValue(SC5TRB->B1_DESC)
		oSection1:Printline()

		DbSelectArea("SC5TRB")
		CC6_PRODUTO := SC5TRB->SC6PM_C6_PRODUTO
		oSection2:init()

		While !Eof() .And. CC6_PRODUTO == SC5TRB->SC6PM_C6_PRODUTO

			oSection2:Cell("Cespaco"):SetValue('')
			oSection2:Cell("CC5_NUM"):SetValue(SC5TRB->SC5PM_C5_NUM)
			oSection2:Cell("CC5_EMISSAO"):SetValue(SC5TRB->SC5PM_C5_EMISSAO)
			oSection2:Cell("CC5_CLIENTE"):SetValue(SC5TRB->SC5PM_C5_CLIENTE)
			oSection2:Cell("CC5_LOJACLI"):SetValue(SC5TRB->SC5PM_C5_LOJACLI)
			oSection2:Cell("CA1_NOME"):SetValue(SC5TRB->A1_NOME)
			oSection2:Cell("NTOTPEDIDO"):SetValue(SC5TRB->SC6PM_C6_QTDVEN)
			oSection2:Cell("NTOTREMESSA"):SetValue(SC5TRB->SC6PR_C6_REMESSA)
			oSection2:Cell("NTOTSALDO"):SetValue(SC5TRB->SC6PM_C6_QTDVEN - SC5TRB->SC6PR_C6_REMESSA)
			oSection2:Printline()

			DbSelectArea("SC5TRB")
			DbSkip()
		EndDo
		oSection2:Finish()

	EndDo
	oSection1:Finish()

Return

static function ajustaSx1(cPerg)
	//Aqui utilizo a função putSx1, ela cria a pergunta na tabela de perguntas
	oPerg := TPergunta():New(cPerg)
	oPerg:AddGet  ("De  Produto       ?",            "C", 15, 0, Nil, "SB1", "")
	oPerg:AddGet  ("Ate Produto       ?",            "C", 15, 0, Nil, "SB1", "")
	oPerg:AddGet  ("De  Periodo       ?",            "D", 08, 0, Nil, "", "")
	oPerg:AddGet  ("Ate Periodo       ?",            "D", 08, 0, Nil, "", "")
	oPerg:AddGet  ("De  Cliente       ?",            "C", 06, 0, Nil, "SA1", "")
	oPerg:AddGet  ("Ate Cliente       ?",            "C", 06, 0, Nil, "SA1", "")
	oPerg:AddGet  ("Representane      ?",            "C", 06, 0, Nil, "SA1", "")
	oPerg:AddCombo("Saldo a Retirar   ?", { "Sim", "Nao" }   , 2)
	oPerg:Update()
	oPerg:Execute(.F.)	
return
