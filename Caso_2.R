
################################################## Caso 2 ########################################################

setwd("/home/gustavo/Projeto de Dados/Análise_R/AP2/Caso_2")
getwd()

library(devtools)
library(vtable)
library(readxl)
library(tidyverse)
library(dplyr)
library(foreign)
library(plm)
library(stargazer)
library(MatchIt)

library(Matching)
library(ebal)

caso_2 <- read_excel("/home/gustavo/Projeto de Dados/Análise_R/AP2/Caso_2/Caso_2.xlsx")

view(caso_2)

## A - Indique o desenho adequado para se identificar o efeito da PP 

### PP #### 

pp <- as.character(caso_2$pp)

class(pp)

view(pp)

### Sexo ### 

sexo <- as.character(caso_2$sexo)
class(sexo)
view(sexo)

### idade ### 

idade <- as.character(caso_2$idade)
class(idade)
view(idade)

## Variável ficticia do efeito PP por esforco e renda_pais
vf = lm(renda_pais ~ esforco  + factor(pp), data = caso_2)
summary(vf)

## Variável ficticia do efeito PP por nota
vf_pop_nota = lm(nota_pre ~nota + factor(pp), data = caso_2)
summary(vf_pop_nota)

## Variável ficticia do efeito PP por Qi por nota e nota_pre 
vf_qi = lm(Qi ~ nota + nota_pre + factor(pp), data = caso_2)
summary(vf_qi)

## dentro do estimator de pp para sexo para comparação de Qi em notas
dentro_estimador1 = plm(Qi ~ nota + factor(sexo), index = "pp", model = "within", data = caso_2)
summary(dentro_estimador1)

## dentro do estimator de pp para sexo para comparação de Qi em notas
dentro_estimador2 = plm(Qi ~ nota_pre + factor(sexo), index = "pp", model = "within", data = caso_2)
summary(dentro_estimador2)

## dentro do estimator de pp para sexo para comparação de renda_pais em notas
dentro_estimador3 = plm(renda_pais ~ nota + factor(sexo), index = "pp", model = "within", data = caso_2)
summary(dentro_estimador3)

## dentro do estimator de pp para sexo para comparação de renda_pais em notas_pre
dentro_estimador4 = plm(renda_pais ~ nota_pre + factor(sexo), index = "pp", model = "within", data = caso_2)
summary(dentro_estimador4)

## dentro do estimator de pp para sexo para comparação de renda_pais em notas_pre
dentro_estimador5 = plm(renda_pais ~ Qi + factor(sexo), index = "pp", model = "within", data = caso_2)
summary(dentro_estimador5)

################################### Letra B ####################################

## Tabela de Balançeamento por estimação da educação e pop (Comparação entre pp, sexo, idade)

sumtable(caso_2, group = 'idade', group.test = TRUE)
sumtable(caso_2, group = 'sexo', group.test = TRUE)
sumtable(caso_2, group = 'pp', group.test = TRUE)

######### renda_Pais ########
caso_2 <- caso_2 %>% 
  mutate(attrit = is.na(renda_pais))

sumtable(caso_2, group = 'attrit', group.test = TRUE)

################################# Letra C #####################################

### Matching, apresentar a tabela de balanceamento antes e depois do pareamento

summary(lm(sexo ~ esforco + nota_pre + nota, data = caso_2))

t.test(caso_2$idade ~ caso_2$sexo, var.equal = FALSE)
ks.test(x=caso_2$idade[caso_2$sexo==1], y=caso_2$idade[caso_2$sexo==0])
plot(ecdf(caso_2$idade[caso_2$sexo==1]), verticals=TRUE, col=2, cex=0, main="Ecdfs de Sexo")
par(new=TRUE)
plot(ecdf(caso_2$idade[caso_2$sexo==0]), verticals = TRUE, col = 1, cex = 0, main="")
legend("topleft", lty=c(1,1), c("Masculino", "Feminino"), col = c(2,1))

plot(density(caso2$idade[caso2$sexo==1]), ylim=c(0,0.1), col=2, cex=0, main="Comparação de Idade em ambos sexo")
lines(density(caso2$idade[caso2$sexo==0]), col=1, cex=0, main="")
legend("topright", lty = c(1,1), c("Feminino", "Masculino"), col = c(2,1))

variaveis=c("sexo", "idade", "esforco", "nota_pre", "nota", "renda_pais")

exactmatch=c(FALSE, TRUE, TRUE, TRUE, TRUE, replicate(8, "TRUE"))
X = caso_2[, variaveis]

## Indice de desempenho dos sexos  

## Calculo do desvio Padrão e Raiz Quadrada do pp em nota
caso_2 %>% 
  group_by(sexo) %>% 
  summarise(renda_pais = n(), 
            media_nota = mean(nota), 
            std_error =  sd(esforco) / sqrt(renda_pais))

## Calculo do desvio Padrão e Raiz Quadrada do pp em nota_pre
caso_2 %>% 
  group_by(sexo) %>% 
  summarise(renda_pais = n(), 
            media_nota = mean(nota_pre), 
            std_error =  sd(esforco) / sqrt(renda_pais))

## Indice de desempenho de idade

## Calculo do desvio Padrão e Raiz Quadrada do pp em nota
caso_2 %>% 
  group_by(idade) %>% 
  summarise(renda_pais = n(), 
            media_nota = mean(nota), 
            std_error =  sd(esforco) / sqrt(renda_pais))

## Calculo do desvio Padrão e Raiz Quadrada do pp em nota_pre
caso_2 %>% 
  group_by(idade) %>% 
  summarise(renda_pais = n(), 
            media_nota = mean(nota_pre), 
            std_error =  sd(esforco) / sqrt(renda_pais))

## Indice de desempenho de pp 

## Calculo do desvio Padrão e Raiz Quadrada do pp em nota
caso_2 %>% 
  group_by(pp) %>% 
  summarise(renda_pais = n(), 
            media_nota = mean(nota), 
            std_error =  sd(esforco) / sqrt(renda_pais))

## Calculo do desvio Padrão e Raiz Quadrada do pp em nota_pre
caso_2 %>% 
  group_by(pp) %>% 
  summarise(renda_pais = n(), 
            media_nota = mean(nota_pre), 
            std_error =  sd(esforco) / sqrt(renda_pais))

## Propensity Score 

## Frequencia de Histograma para media o caso da renda_pais
caso_2 <- caso_2 %>% mutate(renda_pais = renda_pais / 1000) 
hist(caso_2$renda_pais)

## Frequencia de Histograma para media o caso da esforco
caso_2 <- caso_2 %>% mutate(esforco = esforco / 1000) 
hist(caso_2$esforco)

## Frequencia de Histograma para media o caso da nota
caso_2 <- caso_2 %>% mutate(Qi = Qi / 1000) 
hist(caso_2$Qi)

# Algoritmo de Matchit  
mod_match <- matchit(sexo ~ idade + renda_pais + esforco + Qi, method = "nearest", data = caso_2)
summary(mod_match)

## Um novo banco de dados só com os pareados
dat_m <- match.data(mod_match)
head(dat_m) 
dim(dat_m)

## Caso Pareado de Teste 

## Sexo 
with(dat_m, t.test(renda_pais ~ sexo))
with(dat_m, t.test(Qi ~ sexo))
with(dat_m, t.test(esforco ~ sexo))
with(dat_m, t.test(nota ~ sexo))
with(dat_m, t.test(nota_pre ~ sexo))

## pp 
with(dat_m, t.test(renda_pais ~ pp))
with(dat_m, t.test(Qi ~ pp))
with(dat_m, t.test(esforco ~ pp))
with(dat_m, t.test(nota ~ pp))
with(dat_m, t.test(nota_pre ~ pp))

## Regressão Linear 

## Sexo 
rl_nota_sexo <- lm(nota ~ sexo, data = dat_m)
summary(rl_nota_sexo)

rl_nota_pre_sexo <- lm(nota_pre ~ sexo, data = dat_m)
summary(rl_nota_pre_sexo)

## PP 
rl_nota_pp <- lm(nota ~ pp, data = dat_m)
summary(rl_nota_pp)

rl_nota_pre_pp<- lm(nota_pre ~ pp, data = dat_m)
summary(rl_nota_pre_pp)
