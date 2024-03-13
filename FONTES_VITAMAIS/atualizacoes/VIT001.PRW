#Include 'FWMVCDef.ch'
 
/*
+----------------------------------------------------------------------------+
!Descricao         ! Programas Valor De Frete Por Regiao                     !
+------------------+---------------------------------------------------------+
!Autor             ! Marcio Da Silva                                         !
+------------------+---------------------------------------------------------+
!Empresa           ! TOTVS                                                   !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 18/10/2022                                              !
+------------------+---------------------------------------------------------+
*/
  
//Variáveis Estáticas
Static cTitulo := "Valor de Frete"
 
User Function VIT001()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de CDs
    oBrowse:SetAlias("ZA1")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: MArcio Da Silva                                              |
 | Data:  18/10/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VIT001' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VIT001' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VIT001' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VIT001' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot
 
************************** 
Static Function ModelDef()
***************
    Local oModel         := Nil
    Local oStPai         := FWFormStruct(1, 'ZA1')
    Local oStFilho       := FWFormStruct(1, 'ZA2')
    Local aVIT001        := {}

    //Definições dos campos
    //oStPai:SetProperty('ZA1_CODREG',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
    //oStPai:SetProperty('ZA1_CODREG',    MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZA1", "ZA1_CODREG")'))       //Ini Padrão
    //oStFilho:SetProperty('ZA2_CODZA1',  MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                                 //Modo de Edição
    
    //Define os modelos que vao ser Field Ou Grid
	oModel := MPFormModel():New('zModel3M')
    oModel:AddFields('ZA1MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('ZA2DETAIL','ZA1MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

     
    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aVIT001, {'ZA2_FILIAL',	'ZA1_FILIAL'} )
    aAdd(aVIT001, {'ZA2_CODZA1',   	'ZA1_CODREG'} )
  
    oModel:SetRelation('ZA2DETAIL', aVIT001, ZA2->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    //oModel:GetModel('ZA2DETAIL'):SetUniqueLine({"ZA2_CODZA1"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})

    //Descricao do Modelo
    oModel:SetDescription("Tabela De Fretes")
    oModel:GetModel('ZA1MASTER'):SetDescription('Grupo De Regioes')
    oModel:GetModel('ZA2DETAIL'):SetDescription('Valor Frete')
    //oModelFilho:GetModel('oStFilho')
	//oStFilho:SetValue( 'ZA2_FILIAL',xFilial("ZA2"))

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: MArcio Da Silva                                              |
 | Data:  18/10/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
 Static Function ViewDef()
    Local oView         := Nil
    Local oModel        := FWLoadModel('VIT001')
    Local oStPai        := FWFormStruct(2,'ZA1')
    Local oStFilho    	:= FWFormStruct(2,'ZA2')
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_ZA1',oStPai,'ZA1MASTER')
    oView:AddGrid('VIEW_ZA2',oStFilho,'ZA2DETAIL')

    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)

	//AutoIncrement
	//oView:AddIncrementField( 'VIEW_ZA2', 'ZA2_ITEM' )

    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_ZA1','CABEC')
    oView:SetOwnerView('VIEW_ZA2','GRID')	
     
    //Habilitando título
    oView:EnableTitleView('VIEW_ZA1','Grupo De Regioes')
    oView:EnableTitleView('VIEW_ZA2','Tabela De Fretes')
     
    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //Remove os campos de Código do Artista e CD
    oStFilho:RemoveField('ZA2_CODZA1')

Return oView
