BUILD_VERSION := v0.1.0
BUILD_DATE := $(shell date)
BUILD_COMMIT := $(shell git rev-parse --short HEAD)

VERSION_LINKER_FLAG := 'main.ImagePruneVersion=$(BUILD_VERSION)'
BUILD_DATE_LINKER_FLAG := 'main.ImagePruneBuildDate=$(BUILD_DATE)'
COMMIT_HASH_LINKER_FLAG := 'main.ImagePruneCommit=$(BUILD_COMMIT)'
LINKER_FLAGS := "-X $(VERSION_LINKER_FLAG) -X $(BUILD_DATE_LINKER_FLAG) -X $(COMMIT_HASH_LINKER_FLAG)"

PLATFORMS ?= darwin/amd64 darwin/arm64 windows/amd64 linux/amd64 linux/arm64 linux/ppc64le linux/s390x

build:
	for plt in $(PLATFORMS); \
	do \
		os=$${plt%%/*}; \
		arv=$${plt#*/}; \
		arch=$${arv%/*}; \
		CGO_ENABLED=0 GOOS=$${os} GOARCH=$${arch} go build \
			-o dist/image-prune-$${os}-$${arch} \
			-ldflags=$(LINKER_FLAGS) \
			-tags exclude_graphdriver_btrfs \
			./cmd; \
	done \
