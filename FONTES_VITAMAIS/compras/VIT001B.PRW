#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � VIT001B 	       � Autor � Eder Franca   � Data � 11/10/22  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trazer a Descri��o do Fornecedor ou Cliente na Tabela de   ���
���Descri��o � Documento de Entrada - BROWSER Tabela SF1             	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VIT001B

Local _cnome := " "

If SF1->F1_TIPO=="D" .OR. SF1->F1_TIPO=="B"		
	_cnome := Posicione("SA1",1,XFILIAL("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA1->A1_NOME")	
Else
	_cnome := Posicione("SA2",1,XFILIAL("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"SA2->A2_NOME")
Endif

Return(_cnome)


