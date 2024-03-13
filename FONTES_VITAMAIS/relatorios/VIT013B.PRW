#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"
#include "rwmake.ch"

User Function VIT013B()

	Private _cAlias		:= "QRYSD2"
	Private cEOL 		:= "CHR(13)+CHR(10)"
	Private _cPerg   	:= "VIT013B" // Nome do grupo de perguntas 
	Private _cBloq  	:= ""

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif
	
	//MsgBox("Entrou no VIT013B 1","AtenÃ§Ã£o","ALERT") 

	AjusSX1SD2()

	If Pergunte(_cPerg,.F.)
		MV_PAR01 := Replicate(" ", Len(SD2->D2_COD)) 
		MV_PAR02 := Replicate("Z", Len(SD2->D2_COD))
		MV_PAR03 := Replicate(" ", Len(SD2->D2_GRUPO)) 
		MV_PAR04 := Replicate("Z", Len(SD2->D2_GRUPO))
		MV_PAR05 := CTOD("01/01/1900")
		MV_PAR06 := CTOD("31/12/2049")
		MV_PAR07 := 1
		MV_PAR08 := 2					//Sempre mostrar em tela antes de imprimir
	ElseIf !Pergunte(_cPerg,.t.)	
		Return
	Endif

	//Monta arquivo de trabalho temporÃ¡rio
	MsAguarde({||MontaQuerySD2()},"Aguarde","Criando arquivos para impressão...") 

	//Verifica resultado da query
	DbSelectArea(_cAlias)
	(_cAlias)->(DbGoTop())
	
	//MsgBox("Entrou no VIT013B 2","AtenÃ§Ã£o","ALERT") 

	If (_cAlias)->(Eof())
		MsgAlert("Relatório vazio! Verifique os parâmetros.","Atenção") 
	Else
		Processa({|| ImpSD2() },"Ranking de Vendas por Produtos ","Imprimindo...") 
	EndIf
	(_cAlias)->(DbCloseArea())
Return

//********************************************************************************************
//                                          MONTA A PAGINA DE IMPRESSAO
//********************************************************************************************
Static Function ImpSD2()

Local _nCont 	:= 1
Local aAreaSM0	:= {}	 
Local cDescProd := ""
Local cDescGrup := ""
Local nConverte := 0
Local nConv     := 0

Private cBitmap	:= ""
Private cStartPath:= GetSrvProfString("Startpath","")
Private oFont08
Private oFont09
Private oFont10
Private cPosi
Private nLin
Private	nTotal1  := 0 
Private nTotal2	 := 0
Private nTotal3  := 0
Private nPag     := 0

cBitmap := "lgrl"+SM0->M0_CODIGO+SM0->M0_CODFIL+".bmp" // Empresa+Filial
If !File( cBitmap )
	cBitmap := "lgrl"+SM0->M0_CODIGO+".bmp" // Empresa
EndIf

//Fontes a serem utilizadas no relatÃ³rio
Private oFont08  	:= TFont():New( "Arial",,08,,.F.,,,,,.f.)
Private oFont08N 	:= TFont():New( "Arial",,08,,.T.,,,,,.f.)
Private oFont08I 	:= TFont():New( "Arial",,08,,.f.,,,,,.f.,.T.)
Private oFont09  	:= TFont():New( "Arial",,09,,.F.,,,,,.f.)
Private oFont09N 	:= TFont():New( "Arial",,09,,.T.,,,,,.f.)
Private oFontC9  	:= TFont():New( "Courier New",,09,,.F.,,,,,.f.)
Private oFontC9N 	:= TFont():New( "Courier New",,09,,.T.,,,,,.f.)
Private oFont10  	:= TFont():New( "Arial",,10,,.f.,,,,,.f.)
Private oFont10N 	:= TFont():New( "Arial",,10,,.T.,,,,,.f.)
Private oFont10I 	:= TFont():New( "Arial",,10,,.f.,,,,,.f.,.T.)
Private oFont11  	:= TFont():New( "Arial",,11,,.f.,,,,,.f.)
Private oFont11N 	:= TFont():New( "Arial",,11,,.T.,,,,,.f.)
Private oFont12N 	:= TFont():New( "Arial",,12,,.T.,,,,,.f.)
Private oFont12  	:= TFont():New( "Arial",,12,,.F.,,,,,.F.)
Private oFont12NS	:= TFont():New( "Arial",,12,,.T.,,,,,.T.)
Private oFont13N 	:= TFont():New( "Arial",,13,,.T.,,,,,.f.)
Private oFont17 	:= TFont():New( "Arial",,17,,.F.,,,,,.F.)
Private oFont17N 	:= TFont():New( "Arial",,17,,.T.,,,,,.F.)

//Start de impressÃ£o
Private oPrn:= TMSPrinter():New()

oPrn:SetPortrait()  // SetPortrait() - Formato retrato   SetLandscape() - Formato Paisagem

//cabecalho da pagina
nPag := 1
CabSD2(.T.)

While (_cAlias)->(!Eof())
	
	If _nCont >= 50 
		RodSD2()
		oPrn :EndPage()
		_nCont := 1 
		CabSD2()
	Endif
	
	cDescProd := Posicione("SB1",1,XFILIAL("SB1")+(_cAlias)->D2_COD,"SB1->B1_DESC")
	cDescGrup := Posicione("SBM",1,XFILIAL("SBM")+(_cAlias)->D2_GRUPO,"SBM->BM_DESC")
	nConv     := Posicione("SB1",1,XFILIAL("SB1")+(_cAlias)->D2_COD,"SB1->B1_CONV")

	oPrn:say(nLin,0045,dToc((_cAlias)->D2_EMISSAO), oFont08)		  							//item
	oPrn:say(nLin,0200,(_cAlias)->D2_GRUPO, oFont08)
	oPrn:say(nLin,0280,cDescGrup, oFont08)		  							//item
	oPrn:say(nLin,0960,(_cAlias)->D2_COD, oFont08)	
	oPrn:say(nLin,1100,cDescProd, oFont08)
	oPrn:say(nLin,1800,(_cAlias)->D2_UM, oFont08)	
	oPrn:say(nLin,1800,Transform((_cAlias)->QUANT,"@E 999,999,999.99"),oFont08)	
	oPrn:say(nLin,2000,(_cAlias)->D2_SEGUM, oFont08)	
	oPrn:say(nLin,2100,Transform(nConv,"@E 999"), oFont08)	
	
	nConverte := (_cAlias)->QUANT * nConv

	oPrn:say(nLin,2120,Transform(nConverte,"@E 999,999,999.99"),oFont08)	
	
	oPrn:say(nLin,2300,Transform(((_cAlias)->DEVOL*nConv),"@E 999,999,999.99"),oFont08)	 							//item

	nTotal1 += nConverte		  // Total em Quilos 
	nTotal2 += ((_cAlias)->DEVOL*nConv)   // Total Devoluções

	nLin += 50   //pula linha
	
	_nCont ++

	(_cAlias)->(dBskip())

EndDo

oPrn:line(nLin,0035,nLin,2500)    //Linha Horizontal Cabecalho Inferior
nLin += 50   //pula linha
oPrn:say(nLin,1100,"Total em (KG) : ",oFont10N)
oPrn:say(nLin,1500,Transform(nTotal1,"@E 999,999,999.99"),oFont08)
nLin += 50   //pula linha
oPrn:say(nLin,1100,"Total Devolução (KG) : ",oFont10N)
oPrn:say(nLin,1500,Transform(nTotal2,"@E 999,999,999.99"),oFont08)
nLin += 50   //pula linha
oPrn:say(nLin,1100,"Total Líquido (KG) : ",oFont10N)

nTotal3 := nTotal1 - nTotal2

oPrn:say(nLin,1500,Transform(nTotal3,"@E 999,999,999.99"),oFont08)
nLin += 50   //pula linha
oPrn:line(nLin,0035,nLin,2500)    //Linha Horizontal Cabecalho Inferior
nLin += 50   //pula linha

If _nCont <= 53
	(_cAlias)->(DbGoTop())

Else
	(_cAlias)->(DbGoTop())
	oPrn :EndPage()
	CabSD2(.F.)

EndIF

If(mv_par08 == 1)
  oPrn:Print()
Else
  oPrn:Preview() //Preview DO RELATORIO
EndIf

Return

//********************************************************************************************
//										ImpressÃ£o do RelatÃ³rio
//********************************************************************************************
//Static Function  CabSD2(_lCabec)
Static Function  CabSD2()

	_nCont := 1

	oPrn:StartPage()	//Inicia uma nova pagina
	_cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap

	oPrn:SayBitmap(0045,0060,_cFileLogo,0400,0125)

	oPrn:say(0270,0900, "Ranking de Vendas por Produtos ",oFont17) 
	oPrn:say(0090,2100, "Emissão: "+dToc(ddatabase),oFont08) 
	oPrn:say(0130,2100, "Horario: "+TIME(),oFont08) 
	oPrn:say(0170,2100, "Pagina : "+Transform(nPag,"@E 99"),oFont08) 

	oPrn:say(0455,0035, "Periodo: "+dToc(mv_par05)+" a "+dToc(mv_par06),oFont08N) 

	//         Li  Co   Li  Co
	//oPrn:line(180,1250,430,1250) 	//Linha Vertical Cabecalho   
	                                            '
	oPrn:line(495,0035,495,2500)    //2560Linha Horizontal Cabecalho Inferior
	oPrn:line(555,0035,555,2500)    //Linha Horizontal Cabecalho Inferior

	nPag ++

//********************************************************************************************
//										cabecalho
//********************************************************************************************

	// Primeira coluna do cabecalho
	nLin := 205
	oPrn:say (nLin,0035, SM0->M0_NOMECOM ,oFont08)
	nLin += 50
	oPrn:say (nLin,0035, "Licenciada dos Produtos Vitasal" ,oFont08)
	nLin += 50
	oPrn:say (nLin,0035,"CNPJ: "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")+"  -  "+"I.E:"+" "+Alltrim(SM0->M0_INSC) ,oFont08)  
	nLin += 50
	oPrn:say (nLin,0035,Alltrim(SM0->M0_ENDCOB)+" "+ Alltrim(SM0->M0_BAIRCOB)+" - "+Alltrim(SM0->M0_CIDCOB)+" /"+Alltrim(SM0->M0_ESTCOB)+" "+"CEP:"+" "+(SM0->M0_CEPENT),oFont08) 
	nLin += 50
	oPrn:say (nLin,0035,"TEL.:"+" "+Alltrim(SM0->M0_TEL), oFont08) 


//********************************************************************************************
//										Corpo
//********************************************************************************************
nLin := 500
// Subtitulo do Corpo
oPrn:say (nLin,0035,"Dt Emis.",oFont08N) 
oPrn:say (nLin,0190,"Grp",oFont08N) //EF 
oPrn:say (nLin,0280,"Descrição Grupo",oFont08N) //EF 300 
oPrn:say (nLin,0960,"Cod.",oFont08N) //EF 300 
oPrn:say (nLin,1100,"Descrição do Produto",oFont08N) 
oPrn:say (nLin,1780,"1UM",oFont08N)
oPrn:say (nLin,1865,"Qt.1UM",oFont08N)
oPrn:say (nLin,1980,"2UM",oFont08N)
oPrn:say (nLin,2090,"Conv",oFont08N)
oPrn:say (nLin,2190,"Qt.2UM",oFont08N)
oPrn:say (nLin,2350,"Qt.DevKG",oFont08N) 
nLin := 560

Return

*/
//********************************************************************************************
//										Rodape
//********************************************************************************************
Static Function RodSD2()

oPrn:line(nLin,0035,nLin,2500)    //Linha Horizontal Cabecalho Inferior
nLin += 50
oPrn:say (nLin,0035, "Continua na próxima página........................." ,oFont08)
oPrn :EndPage()

Return

//********************************************************************************************
// 										   		QUERY
//********************************************************************************************
Static Function MontaQuerySD2

Local cQuery  

cQuery := " SELECT SD2.D2_EMISSAO, SD2.D2_GRUPO, SD2.D2_COD, SD2.D2_UM, SD2.D2_SEGUM, SUM(SD2.D2_QUANT) QUANT, SUM(SD2.D2_QTDEDEV) DEVOL "
cQuery += " FROM "+RetSqlName("SD2")+" SD2 "
cQuery += " INNER JOIN SC5010 C5 (NOLOCK) ON C5.C5_NUM = SD2.D2_PEDIDO "
cQuery += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
cQuery += " AND SD2.D2_COD BETWEEN '"+(MV_PAR01)+"' AND '"+(MV_PAR02)+" '
cQuery += " AND SD2.D2_GRUPO BETWEEN '"+(MV_PAR03)+"' AND '"+(MV_PAR04)+" '
cQuery += " AND SD2.D2_EMISSAO BETWEEN '"+Dtos(MV_PAR05)+"' AND '"+Dtos(MV_PAR06)+" '
cQuery += " AND C5.C5_XPEDCOM = 'S' "
cQuery += " AND SD2.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY SD2.D2_EMISSAO, SD2.D2_GRUPO, SD2.D2_COD, SD2.D2_UM, SD2.D2_SEGUM "

If Upper(TcGetDb()) $ "ORACLE.INFORMIX"
	cQuery += "   ORDER BY 1,2"
Else
	If(mv_par07 == 1)
		cQuery += "   ORDER BY SD2.D2_EMISSAO, QUANT DESC"
	Else
		cQuery += "   ORDER BY QUANT DESC"
	Endif
Endif

MemoWrite("C:\TEMP\VIT013B.txt",cQuery)				

//Criar alias temporÃ¡rio
TCQUERY cQuery NEW ALIAS (_cAlias)

tCSetField((_cAlias), "D2_EMISSAO", "D")

Return

//********************************************************************************************
// 										   		Grupo de perguntas
//********************************************************************************************
Static Function AjusSX1SD2()
Local i 		:= 0
Local aArea	:= GetArea()
dbSelectArea("SX1")
dbSetOrder(1)
_cPerg := PADR("VIT013B",10)
aRegs:={}
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
AADD(aRegs,{_cPerg,"01","Do  Produto ?","De proveedor	 ?","From Supplier 		?","mv_ch1","C",15,0,0,"G","","mv_par01",""        ,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SB1","S"})
AADD(aRegs,{_cPerg,"02","Até Produto ?","De proveedor 	 ?","To Supplier		?","mv_ch2","C",15,0,0,"G","","mv_par02",""        ,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SB1","S"})
AADD(aRegs,{_cPerg,"03","Do  Grupo ?","De proveedor		 ?","From Supplier 		?","mv_ch3","C",04,0,0,"G","","mv_par03",""        ,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SBM","S"})
AADD(aRegs,{_cPerg,"04","Até Grupo ?","De proveedor 		 ?","To Supplier		?","mv_ch4","C",04,0,0,"G","","mv_par04",""        ,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","","SBM","S"})
AADD(aRegs,{_cPerg,"05","Da  Data ?","De proveedor		 ?","From Supplier 		?","mv_ch5","D",08,0,0,"G","","mv_par05",""        ,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","",""   ,"S"})
AADD(aRegs,{_cPerg,"06","Até Data ?","De proveedor 		 ?","To Supplier		?","mv_ch6","D",08,0,0,"G","","mv_par06",""        ,""				,""         ,"","",""      ,""			,""			,"","",""       ,"","","","",""       ,"","","","",""        ,"","","",""   ,"S"})
AADD(aRegs,{_cPerg,"07","Ordem ?"   ,"Ordem               ?","Ordem	            ?","mv_ch7","N",01,0,1,"C","","mv_par07","Diario", "Diario" , "Diario","","", "Periodo", "Periodo"	, "Periodo"	,"","",""		 ,"","","","",""		 ,"","","","",""		   ,"","","",""  ,"S" })
AADD(aRegs,{_cPerg,"08","Tp Impro ?","Tipo de impressão  ?","type of printing	?","mv_ch8","N",01,0,1,"C","","mv_par08","Impressora", "Impresora" , "Printer","","", "Tela", "Pantalla"	, "Screen"	,"","",""		 ,"","","","",""		 ,"","","","",""		   ,"","","",""  ,"S" })

For i:=1 to Len(aRegs)
	If !dbSeek(_cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
			X1_GRUPO  	:= aRegs[i,1]
			X1_ORDEM  	:= aRegs[i,2]
			X1_PERGUNT	:= aRegs[i,3]
			X1_PERSPA	:= aRegs[i,4]
			X1_PERENG	:= aRegs[i,5]
			X1_VARIAVL	:= aRegs[i,6]
			X1_TIPO  	:= aRegs[i,7]
			X1_TAMANHO	:= aRegs[i,8]
			X1_DECIMAL	:= aRegs[i,9]
			X1_PRESEL	:= aRegs[i,10]
			X1_GSC		:= aRegs[i,11]
			X1_VAR01	:= aRegs[i,13]
			X1_DEF01	:= aRegs[i,14]
			X1_DEFSPA1	:= aRegs[i,15]
			X1_DEFENG1	:= aRegs[i,16]
			X1_DEF02	:= aRegs[i,19]
			X1_DEFSPA2	:= aRegs[i,20]
			X1_DEFENG2	:= aRegs[i,21]
			X1_F3		:= aRegs[i,38]
			X1_PYME	:= aRegs[i,39]
		SX1->(MsUnlock())
	Endif
Next
RestArea(aArea)
Return

