#Include "protheus.ch"
#Include "totvs.ch"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE01NFESEFAZºAutor  ³ Eder França        º Data ³  14/12/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada, geracao do XML NFESEFAZ.                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Totvs - Mt       |                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PE01NFESEFAZ()

	Local aArea      := GetArea()
    Local aProd     := PARAMIXB[1]
    Local cMensCli  := PARAMIXB[2]
    Local cMensFis  := PARAMIXB[3]
    Local aDest     := PARAMIXB[4]
    Local aNota     := PARAMIXB[5]
    Local aInfoItem := PARAMIXB[6]
    Local aDupl     := PARAMIXB[7]
    Local aTransp   := PARAMIXB[8]
    Local aEntrega  := PARAMIXB[9]
    Local aRetirada := PARAMIXB[10]
    Local aVeiculo  := PARAMIXB[11]
    Local aReboque  := PARAMIXB[12]
    Local aNfVincRur:= PARAMIXB[13]
    Local aEspVol   := PARAMIXB[14]
    Local aNfVinc   := PARAMIXB[15]
    Local AdetPag   := PARAMIXB[16]
    Local aObsCont  := PARAMIXB[17]
    Local aProcRef  := PARAMIXB[18]
    Local aRetorno  := {}
    Local cMenPed   := ""
    Local sp1       := 0

    Local cTipo      := If(Len(aNota) >  0,aNota[04],"")

    //Posicionando no Pedido
    //Buscando informações de mensagem no Cabeçalho do Pedido de Vendas
    //MsgBox("Entrou no PE(PE01NFESEFAZ) 1: ","AtenÃ§Ã£o","ALERT") 
    
    DbSelectArea("SC5")
    DbSetOrder(1)
    If DbSeek(xFilial("SC5")+SD2->D2_PEDIDO)
        cMenPed := Alltrim(SC5->C5_XMENNOT)
        If !Empty(cMenPed)
            cMensCli += " | PV: "+SD2->D2_PEDIDO+" | "+cMenPed
        else
            cMensCli += " | PV: "+SD2->D2_PEDIDO+" | "+cMensCli
        Endif
    EndIf

	If cTipo == "0"	//TIPO = ENTRADA

        cAliasD1 := GetNextAlias()

	    BeginSql Alias cAliasD1
	        COLUMN D1_EMISSAO AS DATE
		    SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_ITEM,D1_FORNECE,D1_LOJA,D1_COD,D1_TES,D1_NFORI,D1_SERIORI,D1_ITEMORI,D1_TIPO, D1_LOTECTL, D1_DTVALID
		    FROM %Table:SD1% SD1
		    WHERE
		    SD1.D1_FILIAL  = %xFilial:SD1% AND
		    SD1.D1_SERIE   = %Exp:SF1->F1_SERIE% AND
		    SD1.D1_DOC     = %Exp:SF1->F1_DOC% AND
		    SD1.D1_FORNECE = %Exp:SF1->F1_FORNECE% AND
		    SD1.D1_LOJA    = %Exp:SF1->F1_LOJA% AND
		    SD1.%NotDel%
		    ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM,D1_COD
	    EndSql

        nCont := 1
	
        while !(cAliasD1)->( Eof() ) .and. xFilial("SD1") == (cAliasD1)->D1_FILIAL .And.;
	        SF1->F1_SERIE == (cAliasD1)->D1_SERIE .And.;
		    SF1->F1_DOC == (cAliasD1)->D1_DOC .And. SF1->F1_FORNECE == (cAliasD1)->D1_FORNECE .And.;
		    SF1->F1_LOJA == (cAliasD1)->D1_LOJA

            SB1->(dbSetOrder(1))
		    SB1->(DbSeek(xFilial("SB1")+(cAliasD1)->D1_COD)) // posiciona SB1

		    SD1->(dbSetOrder(1))
		    SD1->(DbSeek(xFilial("SD1")+(cAliasD1)->D1_DOC+(cAliasD1)->D1_SERIE+(cAliasD1)->D1_FORNECE+(cAliasD1)->D1_LOJA+(cAliasD1)->D1_COD+(cAliasD1)->D1_ITEM))   // Posiciona Item do Pedido 07/08/2007

            //DOC + SERIE + CLIENTE + LOJA + CODIGO + ITEM

		    //--- Posiciona Item
		    nCont := val((cAliasD1)->D1_ITEM)

            If !Empty(SD1->D1_LOTECTL)

                sp1 := 50 - (Len(Alltrim(SB1->B1_DESC)))

			    cDescProd := SB1->B1_DESC+space(sp1)+" Lote: "+Alltrim(SD1->D1_LOTECTL)+" Data Val: "+dtoc(SD1->D1_DTVALID)
				
                aProd[nCont][04] := cDescProd
        
            endif

		    (cAliasD1)->( DbSkip() )

        enddo
	    
        (cAliasD1)->( DbCloseArea() )
    
    Else	//Fim ENTRADA

        *********** 
        // Tratamentos dos Impostos para destaque em dados adicionais da DANFE
        ***********

        If SF2->F2_VALFAC <> 0
	        cMensCli := cMensCli + " IAGRO: R$ "+Alltrim( Str(SF2->F2_VALFAC, 14, 2) )
        EndIf
        If SF2->F2_VALFET <> 0
	        cMensCli := cMensCli + " FETHAB: R$ "+Alltrim( Str(SF2->F2_VALFET, 14, 2) )
	        //MsgBox("Entrou no PE(PE01NFESEFAZ) apÃ³s acionamento do botÃ£o de OK, passando valor FETHAB: "+Alltrim( Str(SF2->F2_VALFET, 14, 2) ),"AtenÃ§Ã£o","ALERT") 
        EndIf
        //If SF2->F2_CONTSOC <> 0
            //	cMensCli := cMensCli + " FUNRURAL: R$"+Alltrim( Str(SF2->F2_CONTSOC, 14, 2) )
        //EndIf
        If SF2->F2_VALFMD  <> 0
	        cMensCli := cMensCli + " FAMAD: R$ "+Alltrim( Str(SF2->F2_VALFMD, 14, 2) )
        EndIf
        //If SF2->F2_VALIMA  <> 0 // Parado por divergencia de casas decimais em 21/01/21
        //	cMensCli := cMensCli + " IMA-MT: R$"+Alltrim( Str(SF2->F2_VALIMA, 14, 2) )
        //EndIf
        If SF2->F2_VALFASE  <> 0
	        cMensCli := cMensCli + " FASE-MT: R$ "+Alltrim( Str(SF2->F2_VALFASE, 14, 2) )
        EndIf
        If SF2->F2_VALFAB   <> 0
	        cMensCli := cMensCli + " FABOV: R$ "+Alltrim( Str(SF2->F2_VALFAB, 14, 2) )
        EndIf
        If SF2->F2_VLSENAR   <> 0
	        cMensCli := cMensCli + " SENAR: R$ "+Alltrim( Str(SF2->F2_VLSENAR, 14, 2) )
        EndIf
    
        /****************************
        * Tratamento para buscar o Número do Lote
        ****************************/

        cAliasD2 := GetNextAlias()
	    BeginSql Alias cAliasD2
	        COLUMN D2_ENTREG AS DATE
		    SELECT D2_FILIAL,D2_SERIE,D2_DOC,D2_CLIENTE,D2_LOJA,D2_COD,D2_TES,D2_NFORI,D2_SERIORI,D2_ITEMORI,D2_TIPO,D2_ITEM,D2_CF,
		    D2_QUANT,D2_TOTAL,D2_DESCON,D2_VALFRE,D2_SEGURO,D2_PEDIDO,D2_ITEMPV,D2_DESPESA,D2_VALBRUT,D2_VALISS,D2_PRUNIT,
		    D2_CLASFIS,D2_PRCVEN,D2_IDENTB6,D2_CODISS,D2_DESCZFR,D2_PREEMB,D2_DESCZFC,D2_DESCZFP,D2_LOTECTL,D2_NUMLOTE,D2_ICMSRET,D2_VALPS3,
		    D2_ORIGLAN,D2_VALCF3,D2_VALIPI,D2_VALACRS,D2_PICM,D2_PDV
		    FROM %Table:SD2% SD2
		    WHERE
		    SD2.D2_FILIAL  = %xFilial:SD2% AND
		    SD2.D2_SERIE   = %Exp:SF2->F2_SERIE% AND
		    SD2.D2_DOC     = %Exp:SF2->F2_DOC% AND
		    SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND
		    SD2.D2_LOJA    = %Exp:SF2->F2_LOJA% AND
		    SD2.%NotDel%
		    ORDER BY D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM,D2_COD
	    EndSql
	
        nCont := 1
	
        while !(cAliasD2)->( Eof() ) .and. xFilial("SD2") == (cAliasD2)->D2_FILIAL .And.;
	        SF2->F2_SERIE == (cAliasD2)->D2_SERIE .And.;
		    SF2->F2_DOC == (cAliasD2)->D2_DOC .And. SF2->F2_CLIENTE == (cAliasD2)->D2_CLIENTE .And.;
		    SF2->F2_LOJA == (cAliasD2)->D2_LOJA

		    SB1->(dbSetOrder(1))
		    SB1->(DbSeek(xFilial("SB1")+(cAliasD2)->D2_COD)) // posiciona SB1

		    SD2->(dbSetOrder(3))
		    SD2->(DbSeek(xFilial("SD2")+(cAliasD2)->D2_DOC+(cAliasD2)->D2_SERIE+(cAliasD2)->D2_CLIENTE+(cAliasD2)->D2_LOJA+(cAliasD2)->D2_COD+(cAliasD2)->D2_ITEM))   // Posiciona Item do Pedido 07/08/2007

            //DOC + SERIE + CLIENTE + LOJA + CODIGO + ITEM

		    //--- Posiciona Item
		    nCont := val((cAliasD2)->D2_ITEM)

            If !Empty(SD2->D2_LOTECTL)

                sp1 := 50 - (Len(Alltrim(SB1->B1_DESC)))

			    cDescProd := SB1->B1_DESC+space(sp1)+" Lote: "+Alltrim(SD2->D2_LOTECTL)+" Data Val: "+dtoc(SD2->D2_DTVALID)
				
                aProd[nCont][04] := cDescProd
        
            endif

		    (cAliasD2)->( DbSkip() )

	    enddo
	    (cAliasD2)->( DbCloseArea() )
    
        /****************************
        * Fim tratamento para buscar o Número do Lote
        ****************************/
    
    Endif

    aAdd(aRetorno,aProd)
    aAdd(aRetorno,cMensCli)
    aAdd(aRetorno,cMensFis)
    aAdd(aRetorno,aDest)
    aAdd(aRetorno,aNota)
    aAdd(aRetorno,aInfoItem)
    aAdd(aRetorno,aDupl)
    aAdd(aRetorno,aTransp)
    aAdd(aRetorno,aEntrega)
    aAdd(aRetorno,aRetirada)
    aAdd(aRetorno,aVeiculo)
    aAdd(aRetorno,aReboque)
    aAdd(aRetorno,aNfVincRur)
    aAdd(aRetorno,aEspVol)
    aAdd(aRetorno,aNfVinc)
    aAdd(aRetorno,AdetPag)
    aAdd(aRetorno,aObsCont)
    aAdd(aRetorno,aProcRef)

    RestArea(aArea)

RETURN aRetorno
