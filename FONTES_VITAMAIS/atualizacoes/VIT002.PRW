#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#Include 'FWMVCDef.ch'
/*
+----------------------------------------------------------------------------+
!Descricao         ! Lista De Comissao Gerente Comercial                     !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Da Silva                                         !
+------------------+---------------------------------------------------------+
!Empresa           ! TOTVS                                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/10/2022                                              !
+------------------+---------------------------------------------------------+
*/
  
//Variáveis Estáticas
Static cTitulo := "Lista De Comissao Gerente Comercial"
 
User Function VIT002()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()


	SetFunName("VIT002")

    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de CDs
    oBrowse:SetAlias("ZA3")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

	//Filtrando
    //oBrowse:SetFilterDefault("SA3->A3_TPVINC = '00'")
     

	 
    //Ativa a Browse
    oBrowse:Activate()
    SetFunName(cFunBkp) 
    RestArea(aArea)
Return Nil	
	
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Marcio Da Silva                                              |
 | Data:  25/10/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRot := {}
	
	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VIT002' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VIT002' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VIT002' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VIT002' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot
/*---------------------------------------------------------------------*
 | Func:  modelDef                                                     |
 | Autor: Marcio Da Silva                                              |
 | Data:  25/10/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel   := Nil
	Local oStTmp   := FWFormModelStruct():New()
	Local oStFilho := FWFormStruct(1, 'ZA3')
	Local bVldPos  := {|| fVLDZA3()}
	Local bVldCom  := {|| fGravaZA3()}
	Local aZA3Rel  := {}
	
	
	//Adiciona a tabela na estrutura temporária
	oStTmp:AddTable('ZA3', {'ZA3_FILIAL', 'ZA3_GERSA3','ZA3_NM_GER','ZA3_REPSA3', 'ZA3_NM_REP', 'ZA3_COMIS'}, "Cabecalho ZA3")
	
	//Adiciona o campo de Filial
	oStTmp:AddField(;
		"Filial",;                                                                                  // [01]  C   Titulo do campo
		"Filial",;                                                                                  // [02]  C   ToolTip do campo
		"ZA3_FILIAL",;                                                                               // [03]  C   Id do Field
		"C",;                                                                                       // [04]  C   Tipo do campo
		TamSX3("ZA3_FILIAL")[1],;                                                                    // [05]  N   Tamanho do campo
		0,;                                                                                         // [06]  N   Decimal do campo
		Nil,;                                                                                       // [07]  B   Code-block de validação do campo
		Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
		{},;                                                                                        // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
		Nil,;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                                        // [14]  L   Indica se o campo é virtual
	
	//Adiciona o campo de Código da Tabela
	oStTmp:AddField(;
		"Cd Lista",;                                                                    // [01]  C   Titulo do campo
		"Cd Lista",;                                                                    // [02]  C   ToolTip do campo
		"ZA3_CDLIST",;                                                                  // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZA3_CDLIST")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,GETSXENUM('ZA3','ZA3_CDLIST'),'')"),;    // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual
	//Adiciona o campo de Código da Tabela

	oStTmp:AddField(;
		"Gerente",;                                                                    // [01]  C   Titulo do campo
		"Gerente",;                                                                    // [02]  C   ToolTip do campo
		"ZA3_GERSA3",;                                                                  // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZA3_GERSA3")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA3->ZA3_GERSA3,'')" ),;    // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual
	
	//Adiciona o campo de Descrição
	oStTmp:AddField(;
		"Nome Gerente",;                                                                // [01]  C   Titulo do campo
		"Nome Gerente",;                                                                // [02]  C   ToolTip do campo
		"ZA3_NM_GER",;                                                                 	// [03]  C   Id do Field
		"C",;                                                                         	// [04]  C   Tipo do campo
		TamSX3("ZA3_NM_GER")[1],;                                                      	// [05]  N   Tamanho do campo
		0,;                                                                           	// [06]  N   Decimal do campo
		Nil,;                      														// [07]  B   Code-block de validação do campo
		Nil,;                      														// [08]  B   Code-block de validação When do campo
		{},;                                                                          	// [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         	// [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, 'Iif(!INCLUI,Posicione("SA3",1,xFilial("SA3")+ZA3->ZA3_GERSA3,"A3_NOME"),"")' ),;    // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         	// [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         	// [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.)                                                                          	// [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Código da Tabela
	oStTmp:AddField(;
		"Representante",;                                                             // [01]  C   Titulo do campo
		"Representante",;                                                             // [02]  C   ToolTip do campo
		"ZA3_REPSA3",;                                                                // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZA3_REPSA3")[1],;                                                     // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                        // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA3->ZA3_REPSA3,'')" ),;  // [11]  B   Code-block de inicializacao do campo
		.T.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual
	


	//Adiciona o campo de Descrição
	oStTmp:AddField(;
		"Nome Representante",;                                                                 // [01]  C   Titulo do campo
		"Nome Representante",;                                                                 // [02]  C   ToolTip do campo
		"ZA3_NM_REP",;                                                                 // [03]  C   Id do Field
		"C",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZA3_NM_REP")[1],;                                                      // [05]  N   Tamanho do campo
		0,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,'111' ,'22222')" ),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.)                                                                          // [14]  L   Indica se o campo é virtual

	//Adiciona o campo de Descrição
	oStTmp:AddField(;
		"Comissao",;                                                                 // [01]  C   Titulo do campo
		"Comissao",;                                                                 // [02]  C   ToolTip do campo
		"ZA3_COMIS",;                                                                 // [03]  C   Id do Field
		"N",;                                                                         // [04]  C   Tipo do campo
		TamSX3("ZA3_COMIS")[1],;                                                      // [05]  N   Tamanho do campo
		2,;                                                                           // [06]  N   Decimal do campo
		Nil,;                                                                         // [07]  B   Code-block de validação do campo
		Nil,;                                                                         // [08]  B   Code-block de validação When do campo
		{},;                                                                          // [09]  A   Lista de valores permitido do campo
		.F.,;                                                                         // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZA3->ZA3_COMIS,0)" ),;   // [11]  B   Code-block de inicializacao do campo
		.F.,;                                                                         // [12]  L   Indica se trata-se de um campo chave
		.F.,;                                                                         // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.F.)                                                                          // [14]  L   Indica se o campo é virtual


	
	//Setando as propriedades na grid, o inicializador da Filial e Tabela, para não dar mensagem de coluna vazia
	oStFilho:SetProperty('ZA3_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	oStFilho:SetProperty('ZA3_GERSA3', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	oStFilho:SetProperty('ZA3_COMIS', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '0'))
	oStFilho:SetProperty('ZA3_NM_REP', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Iif(!INCLUI,Posicione("SA3",1,xFilial("SA3")+ZA3->ZA3_REPSA3,"A3_NOME"),"")'))
    oStFilho:SetProperty('ZA3_CDLIST', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Iif(!INCLUI,GETSXENUM("ZA3","ZA3_CDLIST"),"")'))

	oStTmp:SetProperty('ZA3_GERSA3', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "u_VIT002VG(),.T."))
		

	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("VIT002M", , bVldPos, bVldCom) 
	oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
	oModel:AddGrid('ZA3DETAIL','FORMCAB',oStFilho)
	
	//Adiciona o relacionamento de Filho, Pai
	aAdd(aZA3Rel, {'ZA3_FILIAL', 'Iif(!INCLUI, ZA3->ZA3_FILIAL, FWxFilial("ZA3"))'} )
	aAdd(aZA3Rel, {'ZA3_CDLIST', 'Iif(!INCLUI, ZA3->ZA3_CDLIST,  "")'} ) 
	aAdd(aZA3Rel, {'ZA3_GERSA3', 'Iif(!INCLUI, ZA3->ZA3_GERSA3,  "")'} ) 
	
	//Criando o relacionamento
	oModel:SetRelation('ZA3DETAIL', aZA3Rel, ZA3->(IndexKey(1)))
	
	//Setando o campo único da grid para não ter repetição
	oModel:GetModel('ZA3DETAIL'):SetUniqueLine({"ZA3_REPSA3"})
	
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
	oModel:SetPrimaryKey({})
	oModel:GetModel("FORMCAB"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Marcio Da Silva                                              |
 | Data:  25/10/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("VIT002")
	Local oStTmp     := FWFormViewStruct():New()
	Local oStFilho   := FWFormStruct(2, 'ZA3')
	Local oView      := Nil
	
	//Adicionando o campo Chave para ser exibido
	oStTmp:AddField(;
		"ZA3_GERSA3",;                // [01]  C   Nome do Campo
		"01",;                      // [02]  C   Ordem
		"Gerente",;                  // [03]  C   Titulo do campo
		X3Descric('ZA3_GERSA3'),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("ZA3_GERSA3"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		"SA3GER",;                  // [09]  C   Consulta F3
		Nil,;     // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		Nil,;                       // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                   // [18]  L   Indica pulo de linha após o campo
	
	//Adicionando o campo Chave para ser exibido
	oStTmp:AddField(;
		"ZA3_NM_GER",;                // [01]  C   Nome do Campo
		"02",;                      // [02]  C   Ordem
		"Nome Gerente",;                  // [03]  C   Titulo do campo
		X3Descric('ZA3_NM_GER'),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("ZA3_NM_GER"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.F.,; 					    // [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		'',;                        // [15]  C   Inicializador de Browse
		.T.,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
	
	//Adicionando o campo Chave para ser exibido
	oStTmp:AddField(;
		"ZA3_COMIS",;                // [01]  C   Nome do Campo
		"03",;                      // [02]  C   Ordem
		"Comissao",;                  // [03]  C   Titulo do campo
		X3Descric('ZA3_COMIS'),;    // [04]  C   Descricao do campo
		Nil,;                       // [05]  A   Array com Help
		"C",;                       // [06]  C   Tipo do campo
		X3Picture("ZA3_COMIS"),;    // [07]  C   Picture
		Nil,;                       // [08]  B   Bloco de PictTre Var
		Nil,;                       // [09]  C   Consulta F3
		.T.,;     					// [10]  L   Indica se o campo é alteravel
		Nil,;                       // [11]  C   Pasta do campo
		Nil,;                       // [12]  C   Agrupamento do campo
		Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
		Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
		M->ZA3_GERSA3,;             // [15]  C   Inicializador de Browse
		Nil,;                       // [16]  L   Indica se o campo é virtual
		Nil,;                       // [17]  C   Picture Variavel
		Nil)                        // [18]  L   Indica pulo de linha após o campo
	

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
	oView:AddGrid('VIEW_ZA3',oStFilho,'ZA3DETAIL')

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',30)
	oView:CreateHorizontalBox('GRID',70)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB','CABEC')
	oView:SetOwnerView('VIEW_ZA3','GRID')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Cabeçalho - Tabela Genérica')
	oView:EnableTitleView('VIEW_ZA3','Itens - Tabela Genérica')
	
	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk({||.T.})
	
	//Remove os campos de Filial e Tabela da Grid
	oStFilho:RemoveField('ZA3_FILIAL')
	oStFilho:RemoveField('ZA3_GERSA3')
	oStFilho:RemoveField('ZA3_COMIS')
	oStFilho:RemoveField('ZA3_NM_GER')
	oStFilho:RemoveField('ZA3_CDLIST')
Return oView
/*---------------------------------------------------------------------*
 | Func:  fVLDZA3                                                      |
 | Autor: Marcio Da Silva                                              |
 | Data:  25/10/2022                                                   |
 | Desc:  Funcao validacao de inclusao de registros                    |
 *---------------------------------------------------------------------*/
Static Function fVLDZA3()
	Local aArea      := GetArea()
	Local lRet       := .T.
	Local oModelDad  := FWModelActive()
	Local sGerSA3    := oModelDad:GetValue('FORMCAB', 'ZA3_GERSA3')
	Local nOpc       := oModelDad:GetOperation()
	Local nComis     := oModelDad:GetValue('FORMCAB', 'ZA3_COMIS')
	Local oModelGrid := oModelDad:GetModel('ZA3DETAIL')
	Local nAtual     := 0 
	If nOpc == 3 .Or. nOpc == 4
		If nComis == 0
			Aviso('Atenção', 'Valor Comissao Invalida!', {'OK'}, 02)
			lRet := .F.
		Else	
			For nAtual := 1 to oModelGrid:length()
				oModelGrid:GoLine(nAtual)
				If !oModelGrid:isDeleted()
					sZA3_REP := oModelGrid:getvalue("ZA3_REPSA3")
					sZA3_CDLIST := oModelGrid:getvalue("ZA3_CDLIST")
					DbSelectArea('ZA3')
					DbSetOrder(3)
					iF DbSeek(xFilial('ZA3')+sZA3_REP+sGerSA3) .And. ZA3->ZA3_CDLIST <> sZA3_CDLIST
						Aviso('Atenção', 'Código de Gerente:'+Alltrim(sGerSA3)+ ', Codigo De Vendedor:'+Alltrim(sZA3_REP)+' Ja Existe!', {'OK'}, 02)
						lRet := .F.
						nAtual := oModelGrid:length()
					EndIf 
				EndIf 
			Next nAtual
		EndIf
	EndIf
	RestArea(aArea)
Return lRet

/*---------------------------------------------------------------------*
 | Func:  fVLDZA3                                                      |
 | Autor: Marcio Da Silva                                              |
 | Data:  25/10/2022                                                   |
 | Desc:  Funcao Gravacao de registros                                 |
 *---------------------------------------------------------------------*/
Static Function fGravaZA3()
	Local aArea      := GetArea()
	Local lRet       := .F.
	Local oModelDad  := FWModelActive()
	Local cGerSA3    := oModelDad:GetValue('FORMCAB', 'ZA3_GERSA3')
	Local nComis     := oModelDad:GetValue('FORMCAB', 'ZA3_COMIS')
	Local nOpc       := oModelDad:GetOperation()
	Local oModelGrid := oModelDad:GetModel('ZA3DETAIL')
	Local nAtual     := 0 
	Local sZA3_CDLIST:= '' 


	DbSelectArea('ZA3')
	ZA3->(DbSetOrder(1)) //ZA3_FILIAL + X5_TABELA + X5_CHAVE

	For nAtual := 1 To oModelGrid:length()
		oModelGrid:GoLine(nAtual)
		If !oModelGrid:isDeleted()
			If nOpc == 3 
				sZA3_CDLIST := IIF(Empty(sZA3_CDLIST),GETSXENUM("ZA3","ZA3_CDLIST"),sZA3_CDLIST)
			Else
				sZA3_CDLIST:= oModelGrid:getvalue("ZA3_CDLIST")
			EndIf	
			sZA3_REP   := oModelGrid:getvalue("ZA3_REPSA3")
			lRet     := .T.
			DbSeek(xFilial('ZA3')+sZA3_CDLIST+Alltrim(cGerSA3)+Alltrim(sZA3_REP) ,.T.)
			If nOpc == 3 .Or. nOpc == 4
				If 	xFilial('ZA3')  + sZA3_CDLIST   + Alltrim(cGerSA3) +Alltrim(sZA3_REP) == ;
					ZA3->ZA3_FILIAL +ZA3->ZA3_CDLIST+ ZA3->ZA3_GERSA3  +ZA3->ZA3_REPSA3
					RecLock('ZA3', .F.)
				Else
					RecLock('ZA3', .T.)
					ZA3->ZA3_CDLIST := sZA3_CDLIST
				EndIf
				ZA3->ZA3_FILIAL := xFilial('ZA3')
				ZA3->ZA3_GERSA3	:= Alltrim(cGerSA3)
				ZA3->ZA3_COMIS	:= nComis
				ZA3->ZA3_REPSA3	:= sZA3_REP
				MsUnlock('ZA3')
			Else
				If xFilial('ZA3')+sZA3_CDLIST    +Alltrim(cGerSA3)+Alltrim(sZA3_REP) == ;
				ZA3->ZA3_FILIAL  +ZA3->ZA3_CDLIST+ZA3->ZA3_GERSA3 +ZA3->ZA3_REPSA3
					RecLock('ZA3', .F.)
						DbDelete()
					MsUnlock('ZA3')
				EndIf	
			EndIf
		EndIf
	Next nAtual
	RestArea(aArea)
Return lRet

/*---------------------------------------------------------------------*
 | Func:  VIT002VG                                                       |
 | Autor: Marcio Da Silva                                              |
 | Data:  25/10/2022                                                   |
 | Desc:  Funcao validacao de Gerente                                  |
 *---------------------------------------------------------------------*/

USer Function VIT002VG()
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local oModelDad  := FWModelActive()
	Local cGerSA3    := oModelDad:GetValue('FORMCAB', 'ZA3_GERSA3')
	DbSelectArea('SA3')
    DbSetOrder(1) //A3_FILIAL + A3_COD
	If (DbSeek(xFilial('SA3')+cGerSA3))
		lOK := oModelDad:SetValue('FORMCAB',"ZA3_NM_GER",SA3->A3_NOME)
	Else
		Aviso('Atenção', 'Representante Invalido!', {'OK'}, 02)
		lRet       := .F.
	EndIf
	RestArea(aArea)
Return lRet


