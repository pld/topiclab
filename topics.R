library(lda)

# load data file
df <- read.csv('ureport.csv', stringsAsFactors=FALSE)

# extract text from data file
text <- as.character(df['response'])

# build corpus from relevant data file column
corpus <- lexicalize(text, lower=TRUE)

# only keep words that appear at least twice
to.keep <- corpus$vocab[word.counts(corpus$documents, corpus$vocab) >= 2]
documents <- lexicalize(text, lower=TRUE, vocab=to.keep)

/* params for LDA */

# number of topics
K <- 10

# number of iterations
num.iterations <- 10

# Dirichlet hyperparameter for topic proportions
alpha <- 0.1

# Dirichlet hyperparameter for topic multinominals
eta <- 0.1

/* end params for LDA */

# form LDA topics
latent.params <- lda.collapsed.gibbs.sampler(documents, K, to.keep,
        num.iterations, alpha, eta)

/* params for topic words */
num.topic.words <- 5

# find most representative words for each topic
top.words <- c()
for (i in 1:K) {
    top.words <- c(top.words, to.keep[sort.list(latent.params$topics[i,],
                decreasing=TRUE)[0:num.topic.words]])
}
