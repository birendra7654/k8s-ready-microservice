APP?=k8s-ready-microservice
PORT?=8000
RELEASE?=0.0.1
COMMIT?=$(shell git rev-parse --short HEAD)
BUILD_TIME?=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
PROJECT?=github.com/birendra7654/k8s-ready-microservice/pkg
GOOS?=linux
GOARCH?=amd64
CONTAINER_IMAGE?=harbor-repo.vmware.com/tmcinterop/${APP}

export GO111MODULE=on

fmt:
	gofmt -w ./pkg/.. ./cmd/..

vet:
	go vet ./pkg/... ./cmd/...

clean:
	rm -f ./bin/${APP}

build: clean
	go mod tidy
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} ENV GO111MODULE=on \
	go build \
		-ldflags "-s -w -X ${PROJECT}/version.Release=${RELEASE} \
		-X ${PROJECT}/version.Commit=${COMMIT} -X ${PROJECT}/version.BuildTime=${BUILD_TIME}" \
		-o ./bin/${APP} -v ./cmd

container: build
	docker build -t $(CONTAINER_IMAGE):$(RELEASE) .

run: container
	docker stop $(APP):$(RELEASE) || true && docker rm $(APP):$(RELEASE) || true
	docker run --name $(APP) -p ${PORT}:${PORT} --rm \
                             		-e "PORT=${PORT}" \
                             		$(APP):$(RELEASE)
push: container
	docker push $(CONTAINER_IMAGE):$(RELEASE)

minikube: push

test:
	go test -v -race ./...

default: clean fmt vet test run