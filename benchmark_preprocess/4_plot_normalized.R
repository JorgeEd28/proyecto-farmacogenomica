plot(crlmmResult[["SNR"]][,], pch=as.numeric(scanbatch), xlab="Array", ylab="SNR",
     main="Signal-to-noise ratio per array",las=2)
hist(crlmmResult[["SNR"]][,])
plot(density(crlmmResult[["SNR"]][,]))