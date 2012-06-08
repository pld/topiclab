library(lda)

# load data file
df <- read.csv('ureport.csv', stringsAsFactors=FALSE)

# extract text from data file
text <- as.character(df['response'])

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

# params for LDA
# number of topics
K <- 10

# number of iterations
num.iterations <- 10

# Dirichlet hyperparameter for topic proportions
alpha <- 0.1

# Dirichlet hyperparameter for topic multinominals
eta <- 0.1

# form LDA topics
latent.params <- lda.collapsed.gibbs.sampler(documents, K, to.keep,
        num.iterations, alpha, eta)

# params for topic words
num.topic.words <- 5

# find most representative words for each topic
top.words <- c()
for (i in 1:K) {
    top.words <- c(top.words, to.keep[sort.list(latent.params$topics[i,],
                decreasing=TRUE)[0:num.topic.words]])
}
# TODO: only keep words unique from all others
