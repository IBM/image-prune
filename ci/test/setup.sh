WORKDIR=$(pwd)
TEST_REGISTRY=${TEST_REGISTRY:-"ghcr.io/IBM"}
TEST_IMAGE=${TEST_IMAGE:-"test-image-$RANDOM"}

function build_test_image() {
    local version=$1
    local image="${TEST_REGISTRY}/${TEST_IMAGE}:${version}"
    echo "Building $image"
    podman build \
        -t $image \
        -f ${WORKDIR}/ci/test/Containerfile \
        --build-arg "VERSION=${version}" \
        --no-cache \
        ${WORKDIR}
}

function push_test_image() {
    local version=$1
    local image="${TEST_REGISTRY}/${TEST_IMAGE}:${version}"
    echo "Pushing $image"
    podman push $image
}

function build_test_images() {
    for ((i = 0; i < 3; ++i)); do
        for ((j = 0; j < 3; j++)); do
            for ((k = 0; k < 3; k++)); do
                local version="v${i}.${j}.${k}"
                build_test_image "$version"
                push_test_image "$version"
            done
        done
    done
}

build_test_images
