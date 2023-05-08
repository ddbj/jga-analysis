args <- commandArgs(trailingOnly=TRUE)
df = read.table(args[1],skip=6,header=TRUE,stringsAsFactors=FALSE,sep='\t',nrows=1)
write.table(floor(df[,"MEAN_COVERAGE"]), "mean_coverage.txt", quote=F, col.names=F, row.names=F)
