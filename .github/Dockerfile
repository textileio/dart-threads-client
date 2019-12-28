FROM golang:1.13.1-stretch

# Install Dart
RUN apt-get update
RUN apt-get install apt-transport-https
RUN sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_unstable.list > /etc/apt/sources.list.d/dart_unstable.list'
RUN apt-get update
RUN apt-get install dart
ENV PATH "$PATH:/usr/lib/dart/bin"

# Install threadsd
ENV GOBIN /go/bin
RUN cd $GOPATH \
    && mkdir -p temp/builder \
    && cd temp/builder \
    && go mod init temp/builder \
    && go get -d -v  github.com/textileio/go-threads \
    && go install github.com/textileio/go-threads/threadsd
