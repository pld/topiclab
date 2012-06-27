library(lda)

# load data file
df <- read.csv('ureport.csv', stringsAsFactors=FALSE)

# remove non-English, remove short yes/no answers
text <- df$response[intersect(which(df$language == 'en'),
        which(nchar(df$response) > 3))]

# remove non alphanumeric
text <- apply(as.array(text), 1, function(x) gsub('[",\\*\n._!?&()]', ' ', x))

# build corpus from relevant data file column
corpus <- lexicalize(text, lower=TRUE)

# only keep words that appear at least twice
to.keep <- corpus$vocab[word.counts(corpus$documents, corpus$vocab) >= 2]

# remove words less than 4 characters
to.keep <- to.keep[apply(as.array(to.keep), 1, nchar) > 3]

# remove stop words
library(tm)
stop.words = c("coz", "bse", "b'se", "gov't", "you", "think", "government",
        "has", "done", "enough", "promote", "inclusive", "education", "for",
        "children", "and", "youth", "living", "with", "disabilities", "school",
        "schools", "disabled", "disability", "bcoz", "becoz", "esp", "dem",
        "govt", "facilities", "special", "people", "becouse", "help")
to.keep <- to.keep[!apply(as.array(to.keep), 1, '%in%', c(stop.words,
            stopwords('english')))]
documents <- lexicalize(text, lower=TRUE, vocab=to.keep)

################
# params for LDA
# number of topics
K <- 10

# number of iterations
num.iterations <- 10

# Dirichlet hyperparameter for topic proportions
alpha <- 0.1

# Dirichlet hyperparameter for topic multinominals
eta <- 0.1
################

# form LDA topics
latent.params <- lda.collapsed.gibbs.sampler(documents, K, to.keep,
        num.iterations, alpha, eta)

num.topic.docs <- 5
num.topic.words <- 50

top.words <- vector()
top.documents <- vector()

for (i in 1:K) {
    # find most representative words for each topic
    top.words <- rbind(top.words, to.keep[sort.list(latent.params$topics[i,],
            decreasing=TRUE)[1:num.topic.words]])
    # TODO: only keep words unique from all others

    # find most representative documents for each topic
    top.indices <- sort(latent.params$document_sum[i,], decreasing=TRUE,
            index.return=TRUE)$ix[1:num.topic.docs]

    top.documents <- rbind(top.documents, text[top.indices])
}

top.words.unique <- vector()
num.topic.words <- 5

library(rjson)
json.string <- 'var data = ['
#topic.cloud.strings <- c()

for (i in 1:K) {
    # calculate unique words per topic
    row <- c()
    for (j in 1:dim(top.words)[2]) {
        if (!(top.words[i, j] %in% top.words[-i,])) {
            row <- c(row, top.words[i, j])
        }
        if (length(row) >= num.topic.words) {
            break
        }
    }
    top.words.unique <- rbind(top.words.unique, row)

    # build word cloud strings

#    string <- ''
    for (word in top.words.unique[i,]) {
        json.string <- paste(c(json.string,
                toJSON(latent.params$topics[i, word]),
                ','), collapse='')
#        string <- paste(c(string, rep(word, latent.params$topics[i, word])),
#                collapse=' ')
    }
#    topic.cloud.strings <- c(topic.cloud.strings, string)
}

json.string <- paste(c(substr(json.string, 1, nchar(json.string) - 1), ']'),
        collapse='')
cat(json.string, file='data.js')
