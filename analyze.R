require(ggplot2) || install.packages("ggplot2")
require(plyr)    || install.packages("plyr")
require(xts)     || install.packages("xts")

minutes = 15

DF <- data.frame(read.csv("~/dev/brewlab/party-data/drinks.csv"))
DF$bucket = align.time(as.POSIXct(DF$timestamp), n = 60 * minutes)
beers.in.buckets = count(DF, vars = c("beer_name","bucket"))

gg.bars <-
  ggplot(data = beers.in.buckets) +
  geom_bar(aes(x=bucket,y=freq,fill=beer_name),stat="identity",position="dodge") +
  xlab(sprintf("%i-minute segments", minutes)) +
  ylab(sprintf("Pours per beer durint each %i-minute segment", minutes))

gg.lines <-
  ggplot(data = beers.in.buckets) +
  geom_line(aes(x = bucket, y = freq)) +
  facet_wrap(~ beer_name, ncol = 1) +
  xlab(sprintf("Pours per %i minutes", minutes))

ggsave(sprintf("gg.bars.%i.pdf", minutes),  plot=gg.bars,  height=8,  width=16)
ggsave(sprintf("gg.lines.%i.pdf", minutes), plot=gg.lines, height=48, width=16)


# _____________________________________________________________________________________________

# just.pours.in.buckets = count(DF, vars = c("bucket"))
# gg.overall.lines <-
#   ggplot(data = just.pours.in.buckets) +
#   geom_line(aes(x = bucket, y = freq)) +
#   xlab(sprintf("Pours per %i minutes", minutes))
# ggsave(sprintf("gg.overall.lines.%i.pdf", minutes), plot=gg.overall.lines,height=8, width=16)

#people.in.buckets = count(DF, vars = c("rfid_tag_id", "bucket"))
#gg.plines <-ggplot(data = people.in.buckets) + geom_line(aes(x = bucket, y = freq)) + facet_wrap(~ rfid_tag_id, ncol = 1) + theme(strip.background = element_blank(), strip.text.x = element_blank(), strip.text.y = element_blank())
#ggsave("gg.plines.pdf", plot=gg.plines,height=48,width=16)
