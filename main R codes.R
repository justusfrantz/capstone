# Preload required R librabires
library(tm)
library(ggplot2)
library(RWeka)
library(R.utils)
library(dplyr)
library(parallel)
library(wordcloud)

con1 <- file("./Coursera-Swiftkey/final/en_US/en_US.twitter.txt", open = "rb")
twitter <- readLines(con1, skipNul = TRUE, encoding="UTF-8")
close(con1)

con2 <- file("./Coursera-Swiftkey/final/en_US/en_US.news.txt", open = "rb")
news <- readLines(con2, skipNul = TRUE, encoding="UTF-8")
close(con2)

con3 <- file("./Coursera-Swiftkey/final/en_US/en_US.blogs.txt", open = "rb")
blogs <- readLines(con3, skipNul = TRUE, encoding="UTF-8")
close(con3)

sampletext <- function(textbody, portion) {
  taking <- sample(1:length(textbody), length(textbody)*portion)
  Sampletext <- textbody[taking]
  Sampletext
}

# sampling text files 
set.seed(65364)
portion <- 25/50
SampleTwitter <- sampletext(twitter, portion)
SampleBlog <- sampletext(blogs, portion)
SampleNews <- sampletext(news, portion)

# combine sampled texts into one variable
SampleAll <- c(SampleBlog, SampleNews, SampleTwitter)

# write sampled texts into text files for further analysis
writeLines(SampleAll, "./sampleall/SampleAll.txt")


##Data Cleaning

##Next, the corpus was converted to lowercase, strip white space, and removed punctuation and numbers.

cleansing <- function (textcp) {
  textcp <- tm_map(textcp, content_transformer(tolower))
  textcp <- tm_map(textcp, stripWhitespace)
  textcp <- tm_map(textcp, removePunctuation)
  textcp <- tm_map(textcp, removeNumbers)
  textcp
}

SampleAll <- VCorpus(DirSource("./sampleall", encoding = "UTF-8"))

# tokenizing sampled text 
SampleAll <- cleansing(SampleAll)

# Define function to make N grams
tdm_Ngram <- function (textcp, n) {
  NgramTokenizer <- function(x) {RWeka::NGramTokenizer(x, RWeka::Weka_control(min = n, max = n))}
  tdm_ngram <- TermDocumentMatrix(textcp, control = list(tokenizer = NgramTokenizer))
  tdm_ngram
}

# Define function to extract the N grams and sort
ngram_sorted_df <- function (tdm_ngram) {
  tdm_ngram_m <- as.matrix(tdm_ngram)
  tdm_ngram_df <- as.data.frame(tdm_ngram_m)
  colnames(tdm_ngram_df) <- "Count"
  tdm_ngram_df <- tdm_ngram_df[order(-tdm_ngram_df$Count), , drop = FALSE]
  tdm_ngram_df
}

# Calculate N-Grams
tdm_1gram <- tdm_Ngram(SampleAll, 1)
tdm_2gram <- tdm_Ngram(SampleAll, 2)
tdm_3gram <- tdm_Ngram(SampleAll, 3)
tdm_4gram <- tdm_Ngram(SampleAll, 4)


# Extract term-count tables from N-Grams and sort 
tdm_1gram_df <- ngram_sorted_df(tdm_1gram)
tdm_2gram_df <- ngram_sorted_df(tdm_2gram)
tdm_3gram_df <- ngram_sorted_df(tdm_3gram)
tdm_4gram_df <- ngram_sorted_df(tdm_4gram)

# Save data frames into r-compressed files

quadgram <- data.frame(rows=rownames(tdm_4gram_df),count=tdm_4gram_df$Count)
quadgram$rows <- as.character(quadgram$rows)
quadgram_split <- strsplit(as.character(quadgram$rows),split=" ")
quadgram <- transform(quadgram,first = sapply(quadgram_split,"[[",1),second = sapply(quadgram_split,"[[",2),third = sapply(quadgram_split,"[[",3), fourth = sapply(quadgram_split,"[[",4))
quadgram <- data.frame(unigram = quadgram$first,bigram = quadgram$second, trigram = quadgram$third, quadgram = quadgram$fourth, freq = quadgram$count,stringsAsFactors=FALSE)
write.csv(quadgram[quadgram$freq > 1,],"./ShinyApp/quadgram.csv",row.names=F)
quadgram <- read.csv("./ShinyApp/quadgram.csv",stringsAsFactors = F)
saveRDS(quadgram,"./ShinyApp/quadgram.RData")


trigram <- data.frame(rows=rownames(tdm_3gram_df),count=tdm_3gram_df$Count)
trigram$rows <- as.character(trigram$rows)
trigram_split <- strsplit(as.character(trigram$rows),split=" ")
trigram <- transform(trigram,first = sapply(trigram_split,"[[",1),second = sapply(trigram_split,"[[",2),third = sapply(trigram_split,"[[",3))
trigram <- data.frame(unigram = trigram$first,bigram = trigram$second, trigram = trigram$third, freq = trigram$count,stringsAsFactors=FALSE)
write.csv(trigram[trigram$freq > 1,],"./ShinyApp/trigram.csv",row.names=F)
trigram <- read.csv("./ShinyApp/trigram.csv",stringsAsFactors = F)
saveRDS(trigram,"./ShinyApp/trigram.RData")


bigram <- data.frame(rows=rownames(tdm_2gram_df),count=tdm_2gram_df$Count)
bigram$rows <- as.character(bigram$rows)
bigram_split <- strsplit(as.character(bigram$rows),split=" ")
bigram <- transform(bigram,first = sapply(bigram_split,"[[",1),second = sapply(bigram_split,"[[",2))
bigram <- data.frame(unigram = bigram$first,bigram = bigram$second,freq = bigram$count,stringsAsFactors=FALSE)
write.csv(bigram[bigram$freq > 1,],"./ShinyApp/bigram.csv",row.names=F)
bigram <- read.csv("./ShinyApp/bigram.csv",stringsAsFactors = F)
saveRDS(bigram,"./ShinyApp/bigram.RData")
