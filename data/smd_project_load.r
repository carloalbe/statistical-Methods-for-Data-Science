###########
# AIDA data loading
###########

# clean all
rm(list=ls())



install.packages("tidyverse")
# to reload the whole dataset at once, run
install.packages("magrittr") # package installations are only needed the first time you use it
install.packages("dplyr")    # alternative installation of the %>%
library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)

load(file="data/aida.RData")
View(aida)

# summaries
table(aida$`Registered office address - Region`)
table(aida$`Legal status`)
table(aida$'Legal form')
#table(aida$`Company name`)

aida.column_list
lapply(aida,function(x) { length(which(is.na(x)))})
sum(is.na(aida))

df = aida

names(aida)


#DELETING NULL ROW FROM IMPORTANT COLUMNS

df <- df[!(is.na(df$'ATECO 2007code') | is.na(df$'Legal form')),] 

df <- df[!(is.na(df$'Incorporation year') | is.na(df$"Last accounting closing date")),]   

df <- df[!(is.na(df$'Total assetsth EURLast avail. yr') | is.na(df$'Number of employeesLast avail. yr')),] 

#from merger or demerger we cannot know if the company is failed or not
df = df[!(df$`Legal status`=="Dissolved (demerger)"),]
df = df[!(df$`Legal status`=="Dissolved (merger)"),]


df['age'] = df['Last accounting closing date']-df['Incorporation year']
table(df$`age`)
df=df[!(df$age < 0), ]


#size calculated as (micro impresa, piccola impresa, media imprese, grande impresa)
df['size'] = 0
df$`size`[df$`Number of employeesLast avail. yr`>10 | df$`Total assetsth EURLast avail. yr`>2000000] = 1
df$`size`[df$`Number of employeesLast avail. yr`>50 | df$`Total assetsth EURLast avail. yr`>10000000] = 2
df$`size`[df$`Number of employeesLast avail. yr`>250 | df$`Total assetsth EURLast avail. yr`>43000000] = 3



#########################
####### ATECO CODES #####
#########################

#Take the first to digits 
df$`ATECO10` = substr(df$`ATECO 2007code`, start = 1, stop = 2)




df$ATECO[df$ATECO10 == "01" | 
                               df$ATECO10 == "02" |
                               df$ATECO10 == "03"] <- "(A)Pesca e Agricoltura"

df$ATECO[df$ATECO10 == "05" | 
                               df$ATECO10 == "06" |
                               df$ATECO10 == "07"|
                               df$ATECO10 == "08"|
                               df$ATECO10 == "09"] <- "(B)Estrazione Minerali"

df$ATECO[df$ATECO10 >= "10" & 
                               df$ATECO10 <= "33"] <- "(C)Manifattura"

df$ATECO[df$ATECO10 == "35"] <- "(D)Fornitura Gas/Ele"

df$ATECO[df$ATECO10 >= "36" & 
                               df$ATECO10 <= "39"] <- "(E)Gestione Fogne e Rifiuti"

df$ATECO[df$ATECO10 >= "41" & 
                               df$ATECO10 <= "43"] <- "(F)Costruzioni"

df$ATECO[df$ATECO10 >= "45" & 
                               df$ATECO10 <= "47"] <- "(G)Commercio"

df$ATECO[df$ATECO10 >= "49" & 
                               df$ATECO10 <= "53"] <- "(H)Trasporti e Magazzinaggio"

df$ATECO[df$ATECO10 >= "55" & 
                               df$ATECO10 <= "56"] <- "(I)Servizi: Alloggio e Ristorazione"

df$ATECO[df$ATECO10 >= "58" & 
                               df$ATECO10 <= "63"] <- "(J)Servizi: ICT"

df$ATECO[df$ATECO10 >= "64" & 
                               df$ATECO10 <= "66"] <- "(K)Servizi: Finanza e Assic."

df$ATECO[df$ATECO10 == "68"] <- "(L)Servizi: Immobiliari"

df$ATECO[df$ATECO10 >= "69" & 
                               df$ATECO10 <= "75"] <- "(M)Servizi: Consulenza e attività scientifiche"

df$ATECO[df$ATECO10 >= "77" & 
                               df$ATECO10 <= "82"] <- "(N)Servizi: Viaggi e Noleggio"

df$ATECO[df$ATECO10 == "84"] <- "(O)Servizi: Amm. Pubblica e Difesa"

df$ATECO[df$ATECO10 == "85"] <- "(P)Servizi: IStruzione"

df$ATECO[df$ATECO10 >= "86" & 
                               df$ATECO10 <= "88"] <- "(Q)Servizi: Sanità e Ass. Sociale"

df$ATECO[df$ATECO10 >= "90" & 
                               df$ATECO10 <= "93"] <- "(R)Attività sportive, artistiche e intratt."

df$ATECO[df$ATECO10 >= "94" & 
                               df$ATECO10 <= "96"] <- "(S)Altre attività"

df$ATECO[df$ATECO10 >= "97" & 
                               df$ATECO10 <= "98"] <- "(T)Personale Domestico"

df$ATECO[df$ATECO10 == "99"] <- "(U)Organismi extra territoriali"

df<-df[!(df$ATECO10=="00"),]


table(df$`ATECO10`)
table(df$`ATECO`)

#ACTIVED OR FAILED
df$`active` = 0
df$`active`[df$`Legal status`== "Active"] = 1
df$`active`[df$`Legal status`== "Active (default of payments)"] = 1
df$`active`[df$`Legal status`== "Active (receivership)"] = 1

table(df$`active`)

df$status = "active"
df$status[df$active == 0] = "failed"

#Rename
df$'region' = df$'Registered office address - Region'
df$'year' = df$'Last accounting closing date'
df$'ateco' = df$'ATECO10'


table(df$'Legal form')

df$`Legal form`[
                  df$'Legal form'!= "S.C.A.R.L." &
                  df$'Legal form'!= "S.C.A.R.L.P.A." & 
                  df$'Legal form'!= "S.R.L. one-person" &
                  df$'Legal form'!= "S.R.L. simplified" &
                  df$'Legal form'!= "S.P.A." &
                  df$'Legal form'!= "S.R.L." &
                  df$'Legal form'!= "Social cooperative company" &
                  df$'Legal form'!= "S.N.C." &
                  df$'Legal form'!= "S.A.S."  &
                  df$'Legal form'!= "Consortium"] = 'Other'

names(aida)


rownames(df) = df$`Tax code number` #set tax code as index
dfAB = df[, c("Legal form", "active", "age", "region", "ateco","status","ATECO","ATECO10", "size", "year","Incorporation year")]


write.csv(dfAB,"dfAB.csv")



ggplot(aida, aes(x="Cash Flowth EURLast avail. yr", fill="Legal Form")) + geom_density(alpha=0.4)
