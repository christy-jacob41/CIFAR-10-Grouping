library(h2o)
Sys.unsetenv("http_proxy")
h2o.init()
localH2O <- h2o.init(nthreads = -1, max_mem_size = '2g')

download.file("http://www.cs.utoronto.ca/~kriz/cifar-10-binary.tar.gz",destfile="tmp.tar.gz")
untar("tmp.tar.gz",list=TRUE)  ## check contents
untar("tmp.tar.gz")

labels <- read.table("cifar-10-batches-bin/batches.meta.txt")
images.rgb <- list()
images.lab <- list()
num.images = 10000 # Set to 10000 to retrieve all images per file to memory

for (f in 1:5) {
  to.read <- file(paste("cifar-10-batches-bin/data_batch_", f, ".bin", sep=""), "rb")
  for(i in 1:num.images) {
    l <- readBin(to.read, integer(), size=1, n=1, endian="big")
    r <- as.integer(readBin(to.read, raw(), size=1, n=1024, endian="big"))
    g <- as.integer(readBin(to.read, raw(), size=1, n=1024, endian="big"))
    b <- as.integer(readBin(to.read, raw(), size=1, n=1024, endian="big"))
    index <- num.images * (f-1) + i
    images.rgb[[index]] = data.frame(r, g, b)
    images.lab[[index]] = l+1
  }
  close(to.read)
  remove(l,r,g,b,f,i,index, to.read)
}

df <- data.frame(matrix(unlist(images.rgb), nrow=length(images.rgb), byrow=TRUE))
#df$y <- dfl



train_data <- df[1:40000,]
train_data$y <- dfl[1:40000,]
test_data <- df[40001:50000,]
test_data$y <- df[40001:50000,]

dfll <- as.data.frame(dfl)
typeof(df)

h2odf <- as.h2o(df)
cifar.split <- h2o.splitFrame(data = h2odf, ratios = 0.75)
cifar_train <- cifar.split[[1]]
cifar_test <- cifar.split[[2]]

dfl <- data.frame(matrix(unlist(images.lab), nrow=length(images.lab), byrow=TRUE))
names(dfl)[1]<-paste("y")