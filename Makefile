APP?=k8s-ready-microservice
PORT?=8000

export GO111MODULE=on

fmt:
	gofmt -w ./pkg/.. ./cmd/..

vet:
	go vet ./pkg/... ./cmd/...

clean:
	rm -f ./bin/${APP}

build: clean
	go mod tidy
	go build -o ./bin/${APP} -v ./cmd

run: build
	PORT=${PORT} ./bin/${APP}

test:
	go test -v -race ./...

default: clean fmt vet test run