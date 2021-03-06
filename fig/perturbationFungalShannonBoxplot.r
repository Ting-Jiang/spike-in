rm(list=ls())

########### setting the working directory and print it ###################
tem <- "Nature_disturbation_alpha_shannon_boxplot"
setwd("~/xiaoxuan/180213/fung/")
print(paste("Your working directory is in",getwd()))


########### to import the plotting theme() function ########################
source("plot_function.R")
# install.packages("ggplot")

library(ggpubr)
library(vegan)
library(ggplot2)
library(reshape)
# library(multcomp)
library(ggsignif)
# library(rlang)
# library(ggplot)

### output directory assigned to include the pics & tables########################
figures.dir <- paste("~/xiaoxuan/180213/fung//plot/Unoise/",tem,'/',sep = '')
table.dir <- paste("~/xiaoxuan/180213/fung/table/",tem,'/',sep = '')


fig_flag <- dir.exists(figures.dir)
if( isTRUE(!fig_flag)){
  dir.create(figures.dir)
}

tab_flag <- dir.exists(table.dir)                            
if( isTRUE(!tab_flag)){
  dir.create(table.dir)
}
####################################


#####spike-in design in this batch #####################
spike <- c("BI-OS-11-3","BI-OS-12-4","BI-OS-10-2")


#1 design Mapping file and Sample id
design = read.table("doc/design.txt", header=T, row.names= 1, sep="\t") 
design$SampleID <- row.names(design)
sample_list <- as.matrix(row.names(design))

ids <- design$Other %in% c("2:2:2","1:1:1","2:2:1")

sub_design <- design[!ids,]
# sub_design <- design[ids,]


#2 bacteria_list to filter 
# fungl_li = read.delim("doc/bacterial_list.txt",row.names = 1, header=T, sep="") 
# rownames(fungl_li)

#3 OTUs file

otu_table = read.table("result/unoise/otu_table_tax.txt", row.names= 1,  header=1, sep="\t")


id <- grep("OTU_4$",row.names(otu_table))
otu_table <- otu_table[-id,]
id <- grep("OTU_39$",row.names(otu_table))

otu_table[id,]





############################################################subSet OTU for analysis nature sample feature otu distribution ########################
sub_table <- otu_table[,colnames(otu_table) %in% rownames(sub_design)]
# sub_table <- otu_table[,colnames(otu_table) %in%  rownames(sub_design)]




############rarefraction#####################
## a consistent random seed [set.seed(21336)] was used for reproducibility

set.seed(21336)
# rrarefy The sample can be a vector giving the sample sizes for each row.so you need the transpose
##rarefy(x, sample, se = FALSE, MARGIN = 1) rrarefy(x, sample)
sub_table<- as.data.frame(t(rrarefy(t(sub_table),sample = min(colSums(sub_table)))))
### to check the size whether to be same
colSums(sub_table)


#################reorder######################
ids <- match(rownames(sub_design),colnames(sub_table))
sub_table_1 <- sub_table[,ids]
ids <- match(rownames(sub_design),colnames(otu_table))
otu_table_1 <- otu_table[,ids]

######################################Order by ZH11.Bac.BI055.01 for  Scal-BI-12-4 E05/5
sub_OTU<- sub_table_1[order(sub_table_1[,1],decreasing = T),]
sub_OTU$id <- rownames(sub_OTU)
otu_table_ca <- as.data.frame(otu_table[rownames(otu_table) %in% rownames(sub_OTU),c(1,ncol(otu_table))])
otu_table_ca$GOS.Fun.BI05.08 <- NULL
otu_table_ca$id <- rownames(otu_table_ca)
colnames(otu_table_ca)[1] <- "Taxa"

merge_OTU_taxa <- merge(sub_OTU,otu_table_ca,by ="id" )
# write.table(merge_OTU_taxa,file = "../fun_New/table/rarefied_fungal_OTU_table_taxa.txt",sep = '\t',row.names = F)

OTU<-otu_table_1[order(otu_table_1[,1],decreasing = T),]

ids <- match(row.names(OTU),row.names(otu_table))
otu_table<- otu_table[ids,]

pso <- OTU[(rownames(OTU)) %in% "OTU_6",]
# 
# 
top_10_OTU_withSpike <- sub_OTU[1:11,]

OTU_top_11 <- OTU[1:11,]
OTU_top_11_Tax <- cbind(otu_table[1:11,]$taxonomy,OTU_top_11)
colnames(OTU_top_11_Tax)[1] <- "Taxa"

OTU_top_11 <- rbind(OTU_top_11,pso)
# row.names(top_10_OTU_withSpike) <- OTU_top_11


######E05######
sub_design_1 <- sub_design[!sub_design$PlasmidID %in% "Scal-BI-mixture",]


pos <-  colnames(OTU_top_11)%in% rownames(sub_design_1)
E5_mo <- OTU[,pos]
# rownames(E5_mo) <- OTU_top_11_Tax$Taxa

gra_group <- unique(design$PlasmidID)               # plasmid id 
# gra_group <- unique(design$Description)
mix_ratio_group <- unique(design$Other)
cl_group <- unique(design$Description)                 # Concentration



#-----------------------------------------------------------------------------------------------------------------------------------------------
# spike 
rownames(E5_mo)[1] <- "BI-OS-12-4"
idx <- match(spike[2],row.names(E5_mo))
# sub_table_1 <- sub_table[,sub_table[idx,]>160]
E5_mo$id <- rownames(E5_mo)


# mapping spike 12-4
# idx1 <- match(spike[1],row.names(E5_mo))
sub_table_2 <- E5_mo
# sub_table_2 <- E5_mo[-idx1,]

# idx1 <- match(spike[3],row.names(sub_table_2))
sub_table_2 <- sub_table_2



len <- length(sub_table_2[1,])
idx <- match(spike[2],row.names(sub_table_2))
col_sums <- colSums(sub_table_2[-idx,-len])


sub_table_nor_t <- t(sub_table_2[-idx,-len])/col_sums
sub_table_nor <- t(sub_table_nor_t)

spikeAbun <- sub_table_2[idx,-len]/colSums(sub_table_2[,-len])
row.names(spikeAbun) <- "spike-in_Abundance"

delta <- col_sums/sub_table_2[idx,-len]
row.names(delta) <- "delta_value"

total_table<- t(rbind(sub_table_nor,spikeAbun,delta))
t_table <- as.data.frame(total_table)
t_table$id <- row.names(total_table)

idx2 <- match("spike-in_Abundance",colnames(t_table))
index <- cbind(total_table[, idx2], design[match(t_table[,length(t_table[1,])], design$SampleID), ])
colnames(index)[1] <- "value"




colors <- data.frame(group=cl_group,
                     color=c(c_red, c_dark_brown,c_black,c_orange,c_blue,c_sea_green,c_yellow))

shapes <- data.frame(group=mix_ratio_group,
                     shape=c(19, 0, 24))

index$Other <- factor(index$Other, levels=shapes$group)
index$Description <- factor(index$Description, levels=colors$group)
index$Mix_Ratio <- index$Other
# reorder boxplots

# l <- c("soil", "rhizosphere", "root", "pooled_nodules")
# index$compartment <- factor(index$compartment, levels=l)
# colors <- colors[match(l, colors$group), ]


detailName <- paste("Natural_fungal_Community_Concentration",spike[2],sep = '_')


#plot RA 

colors <- data.frame(group=cl_group,
                     color=c(c_red, c_dark_brown,c_black,c_orange,c_sea_green,c_yellow,c_green))


shapes <- data.frame(group=mix_ratio_group,
                     shape=c(19, 0, 24))


#### alpha diversity comparison 

shannon <- as.data.frame(diversity(sub_table_2[-1,-ncol(sub_table_2)],index = "shannon",MARGIN = 2))
colnames(shannon)[1] <- "shannon_value"

index <- cbind(sub_design_1,shannon)


##rep usage each and times
index$Other <- rep(c("One_fold_plant","Two_fold_plant","Fun_spike_perturbation"),each=3,4)
df <- melt(index)

com_t<- compare_means( value ~ Description, data = df[!df$Description %in% "E04",], method = "wilcox.test" ,group.by = "Other", paired = FALSE)
head(com_t)

write.table(com_t,file = "./table/fun_alpha_shannon_pvalue.txt",sep = '\t',row.names = T)

my_comparisons <- list(c("E05/5", "E00"), c("E03", "E00"))


p <- ggplot(df[!df$Description %in% "E04"&df$Other %in% "One_fold_plant",], aes(x=Description, y=value)) +
  geom_boxplot(alpha=1, outlier.size=0, size=0.7, width=0.5, fill=rep(c(c_black, c_black,c_black),1)) +
  geom_jitter(aes(shape=Description,color=Description), position=position_jitter(0.17), size=1, alpha=0.7) +
  labs(x="Spike-in amounts (copies/reaction)", y="Fungal shannon index") +
  scale_colour_manual(values=c(c_red,"purple",c_dark_brown)) +
  scale_shape_manual(values=c(19,3,24)) +
  main_theme



a_p<- p + stat_compare_means(method = "wilcox.test", comparisons = my_comparisons,
                             label.y=c(5,7,9))

ggsave( "/mnt/bai/xiaoning/xiaoxuan/180213/180731_fun_pert/plot/perturbationFungalShannonBoxplot.pdf",  a_p)

