#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � VIT009B 	       � Autor � Eder Franca   � Data � 06/01/22  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Trazer o Doc de Origem do documento vinculado              ���
���Descri��o � Documento de Entrada - BROWSER Tabela SF1             	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function VIT009B

Local _cdoc := " "

If SF1->F1_TIPO=="N"
	_cdoc := Posicione("SF8",2,XFILIAL("SF8")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"SF8->F8_NFDIFRE")	
Elseif SF1->F1_TIPO=="C"
	_cdoc := Posicione("SF8",1,XFILIAL("SF8")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"SF8->F8_NFORIG")	
Endif

Return(_cdoc)


