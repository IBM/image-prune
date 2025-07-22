VERSION := v1.0.0-alpha.2
DATE := $(shell date)
COMMIT := $(shell git rev-parse --short HEAD)

VERSION_LINKER_FLAG := 'github.com/IBM/image-prune/cmd.ImagePruneVersion=$(VERSION)'
DATE_LINKER_FLAG := 'github.com/IBM/image-prune/cmd.ImagePruneBuildDate=$(DATE)'
COMMIT_LINKER_FLAG := 'github.com/IBM/image-prune/cmd.ImagePruneCommit=$(COMMIT)'
LINKER_FLAGS := "-X $(VERSION_LINKER_FLAG) -X $(DATE_LINKER_FLAG) -X $(COMMIT_LINKER_FLAG)"

PLATFORMS ?= darwin/amd64 darwin/arm64 windows/amd64 linux/amd64 linux/arm64 linux/ppc64le linux/s390x

RELEASE_UPLOAD_URL ?=

build:
	@for plt in $(PLATFORMS); \
	do \
		os=$${plt%%/*}; \
		arv=$${plt#*/}; \
		arch=$${arv%/*}; \
		CGO_ENABLED=0 GOOS=$${os} GOARCH=$${arch} go build \
			-o dist/image-prune-$${os}-$${arch} \
			-ldflags=$(LINKER_FLAGS) \
			-tags exclude_graphdriver_btrfs \
			.; \
	done \

lint-dependencies:
	@GOBIN=/usr/local/bin/ go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.2.2

lint:
	@golangci-lint run

release:
	@bash ci/release.sh "$(RELEASE_UPLOAD_URL)" "$(PLATFORMS)"

test-setup:
	@bash ci/test/setup.sh
