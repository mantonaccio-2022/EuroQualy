//Ponto entrada relat�rio retorno CNAB para resolver casos de E1_TIPO = NF
#include "protheus.ch"

//cNumTit -> N�mero do t�tulo  
//dBaixa -> Data da Baixa  
//cTipo -> Tipo do t�tulo         
//cNsNum -> Nosso N�mero      
//nDespes -> Valor da despesa
//nDescont -> Valor do desconto         
//nAbatim -> Valor do abatimento        
//nValRec -> Valor recebidos                                                             
//nJuros -> Juros                   
//nMulta -> Multa                  
//nOutrDesp -> Outras despesas     
//nValCc -> Valor do cr�dito           
//dDataCred -> Data do cr�dito       
//cOcorr -> Ocorrencia                
//cMotBai -> Motivo da baixa   
//xBuffer -> Linha inteira     
//dDtVc -> Data do vencimento  

User Function F650VAR()

cTipo := "01"

Return