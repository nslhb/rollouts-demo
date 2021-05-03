COLOR?=
IMAGE_NAMESPACE?=
ERROR_RATE?=
TIMESTAMP=$(shell date +%Y%m%d%H%M%S)
VERSION?=$(shell git describe --tags)

ifneq (${COLOR},)
IMAGE_TAG=${COLOR}-${TIMESTAMP}-${VERSION}
endif
ifneq (${LATENCY},)
IMAGE_TAG=slow-${COLOR}-${TIMESTAMP}-${VERSION}
endif
ifneq (${ERROR_RATE},)
IMAGE_TAG=bad-${COLOR}-${TIMESTAMP}-${VERSION}
endif

ifdef IMAGE_NAMESPACE
IMAGE_PREFIX=${IMAGE_NAMESPACE}/
endif

.PHONY: all
all: build

.PHONY: build
build:
	CGO_ENABLED=0 go build

.PHONY: image
image:
	docker buildx build --platform="linux/amd64,linux/arm64,linux/arm" --build-arg COLOR=$(COLOR) --build-arg ERROR_RATE=${ERROR_RATE} --build-arg LATENCY=${LATENCY} -t $(IMAGE_PREFIX)rollouts-demo:${IMAGE_TAG} --push .

.PHONY: load-tester-image
load-tester-image:
	cd load-tester
	docker build -t $(IMAGE_PREFIX)load-tester:latest load-tester
	@if [ "$(DOCKER_PUSH)" = "true" ] ; then docker push $(IMAGE_PREFIX)load-tester:latest ; fi

.PHONY: run
run:
	go run main.go

.PHONY: fmt
fmt:
	gofmt -s -w .

.PHONY: vet
vet:
	go vet ./...

.PHONY: lint
lint: fmt vet

.PHONY: release
release:
	./scripts/release.sh IMAGE_NAMESPACE=${IMAGE_NAMESPACE}

.PHONY: clean
clean:
	rm -f rollouts-demo

