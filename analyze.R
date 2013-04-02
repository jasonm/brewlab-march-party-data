require(ggplot2) || install.packages("ggplot2")
require(plyr)    || install.packages("plyr")
require(xts)     || install.packages("xts")

DF <- data.frame(read.csv("~/dev/brewlab/party-data/drinks.csv"))
DF$bucket = align.time(as.POSIXct(DF$timestamp), n = 60 * 15)
beers.in.buckets = count(DF, vars = c("beer_name","bucket"))

gg.bars <- ggplot(data = beers.in.buckets) + geom_bar(aes(x=bucket,y=freq,fill=beer_name),stat="identity",position="dodge")

gg.lines <- ggplot(data = beers.in.buckets) + geom_line(aes(x = bucket, y = freq)) + facet_wrap(~ beer_name, ncol = 1) + xlab("Pours per 15 minutes")

ggsave("gg.bars.10.pdf", plot=gg.bars,height=8,width=16)

gg.overall.lines <- ggplot(data = just.pours.in.buckets) + geom_line(aes(x = bucket, y = freq)) + xlab("Pours per 15 minutes")

#ggsave("gg.lines.pdf", plot=gg.lines,height=48,width=16)
ggsave("gg.overall.lines.15.pdf", plot=gg.overall.lines,height=8,width=16)




#people.in.buckets = count(DF, vars = c("rfid_tag_id", "bucket"))
#gg.plines <-ggplot(data = people.in.buckets) + geom_line(aes(x = bucket, y = freq)) + facet_wrap(~ rfid_tag_id, ncol = 1) + theme(strip.background = element_blank(), strip.text.x = element_blank(), strip.text.y = element_blank())
#ggsave("gg.plines.pdf", plot=gg.plines,height=48,width=16)