# multi-stage build
#FROM golang:1.14 as gobuild
#ARG VERSION=latest
#
#WORKDIR /go/src/github.com/sachinms27/go-api
#ADD ../go.mod go.sum main.go ./
#ADD vendor ./vendor
#ADD ../pkg ./pkg
#ADD ../docs ./docs
#
#RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -mod=vendor -o go-api -ldflags "-X main.version=$VERSION" main.go
#
#FROM gcr.io/distroless/base
#
#COPY --from=gobuild /go/src/github.com/sachinms27/go-api/go-api /bin
#
#ENTRYPOINT ["/bin/go-api"]

FROM alpine:latest

RUN mkdir /app

COPY ./go-api /app

CMD [ "/app/go-api" ]

