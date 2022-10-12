

FROM golang:1.16-alpine AS build

COPY ./bin/ .

ENTRYPOINT [ "./k8s-ready-microservice" ]