require(reshape2) || install.packages("reshape2")
require(ggplot2)  || install.packages("ggplot2")
require(plyr)     || install.packages("plyr")
require(xts)      || install.packages("xts")

minutes = 30

DF <- data.frame(read.csv("~/dev/brewlab/party-data/drinks.csv"))

# bucket each drink into a window.  window timestamp indicates the beginning of the window
DF$bucket = align.time(as.POSIXct(DF$timestamp) - (60 * minutes), n = 60 * minutes)

# aggregate average drinking time for a beer
DF$posixct = sapply(DF$timestamp, as.POSIXct)
aggs = aggregate(DF$posixct, list(BeerName=DF$beer_name),mean)
names(aggs) = c('beer_name', 'avg_time')
DF =merge(DF, aggs, by='beer_name')

# factor beer_name levels by average drinking time, for the stacked line chart
aggs.by.time = aggs[with(aggs, order(avg_time)),]
DF$beer_name <- factor(DF$beer_name, levels = aggs.by.time$beer_name)

beers.in.buckets = count(DF, vars = c("beer_name","bucket"))

gg.bars <-
  ggplot(data = beers.in.buckets) +
  geom_bar(aes(x=bucket,y=freq,fill=beer_name),stat="identity",position="dodge") +
  xlab(sprintf("%i-minute segments", minutes)) +
  ylab(sprintf("Pours per beer during each %i-minute segment", minutes))

ggsave(sprintf("gg.bars.%i.pdf", minutes),  plot=gg.bars,  height=8,  width=16)

gg.lines <-
  ggplot(data = beers.in.buckets) +
  geom_line(aes(x = bucket, y = freq)) +
  facet_wrap(~ beer_name, ncol = 1) +
  xlab(sprintf("Pours per %i minutes", minutes))

ggsave(sprintf("gg.lines.%i.pdf", minutes), plot=gg.lines, height=48, width=16)

just.pours.in.buckets = count(DF, vars = c("bucket"))
gg.overall.lines <-
  ggplot(data = just.pours.in.buckets) +
  geom_line(aes(x = bucket, y = freq)) +
  xlab("") +
  ylab(sprintf("Pours per %i minutes", minutes))
ggsave(sprintf("gg.overall.lines.%i.pdf", minutes), plot=gg.overall.lines,height=8, width=16)

bn_table <- table(DF$beer_name)
bn_levels <- names(bn_table)[order(bn_table)]
DF$beer_by_pour <- factor(DF$beer_name, levels=rev(bn_levels))
gg.beers.by.pour <-
  ggplot(DF, aes(beer_by_pour, fill=beer_by_pour)) +
  geom_bar() +
  xlab("Beer") +
  ylab("Pours") +
  theme(axis.text.x=element_text(angle=90,hjust=1))
ggsave("gg.beers.by.pour.pdf", plot=gg.beers.by.pour, height=8, width=16)

# beer-beer correlation
# library(ggplot2)
# library(reshape2)
# ct <- table(DF$rfid_tag_id, DF$beer_name)
# 
# qplot(x=Var1, y=Var2, data=melt(cor(ct)), fill=log(value), geom="tile") +
#   scale_fill_continuous(low="green",high="red") +
#   theme(axis.text.x=element_text(angle=90,hjust=0))
# 
# qplot(x=Var1, y=Var2, data=melt(cor(ct)), fill=value, geom="tile") +
#   scale_fill_continuous(low="green",high="red") +
#   theme(axis.text.x=element_text(angle=90,hjust=0))
