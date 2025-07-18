WORKDIR=$(pwd)

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "GITHUB_TOKEN environment variable must be set"
    exit 1
fi

# GitHub API constants
GITHUB_API_DOMAIN="github.com"
GITHUB_REPO_SHORT_NAME="IBM/image-prune"

# Platforms built
VERSION=$($1:-"v0.1.0")
PLATFORMS=${$2:-"darwin/amd64 darwin/arm64 windows/amd64 linux/amd64 linux/arm64 linux/ppc64le linux/s390x"}

### Add release assets
#
# Given the upload url, loop through the platform binaries built and add
# them to the created release
#
# Args:
# 1. upload_url: The url to upload the release assets to
#
# Returns:
# None
function add_release_assets() {
    local upload_url=$1
    for platform in $PLATFORMS; do
        local platform_suffix=$(echo $platform | sed 's|/|-|g')
        create_release_asset \
            "${upload_url}" \
            "${WORKDIR}/dist/image-prune-${platform_suffix}"
    done
}

### Get release description
#
# Given the build version, format the release description for the release
#
# Args:
# 1. build_version: The build version being released
#
# Returns:
# The formatted release description markdown
function get_release_description() {
    local build_version=$1
    local release_notes=$(
        cat "${WORKDIR}/ci/release.md" | \
            sed "s/<IMAGE_PRUNE_VERSION>/$build_version/g"
    )
    echo "$release_notes"
}

### Create release
#
# Given a repository tag name, create a corresponding release
#
# Args:
# 1. build_version: The build version being released
#
# Returns:
# The cURL response from the GitHub API for creating the release
function create_release() {
    local build_version=$1

    # Construct the request body
    local req_body=$(
        jq -n \
            --arg tag_name "${build_version}" \
            --arg name "${build_version}" \
            --arg body "$(get_release_description ${build_version})" \
            --argjson generate_release_notes true \
            '$ARGS.named'
    )

    # Send the request & capture the response
    local res_body=$(
        curl -s -L \
            -X POST \
            -H "Authorization: Bearer $GITHUB_TOKEN" \
            https://api.${GITHUB_API_DOMAIN}/repos/${GITHUB_REPO_SHORT_NAME}/releases \
            -d "$req_body"
    )
    echo "$res_body"
}

### Create release asset
#
# Given a release asset upload URL, upload a release asset at a given path
#
# Args:
# 1. upload_url: The release asset upload URL from the release creation
#                response
# 2. asset_path: The path to the release asset file
#
# Returns:
# The cURL response from the GitHub API for creating the release asset
function create_release_asset() {
    local upload_url=$1
    local asset_path=$2

    # Extract the asset name from the path
    local asset_name=${asset_path##*/}

    # Create the release asset
    local asset_res=$(
        curl -s -L \
            -H "Authorization: Bearer ${GITHUB_TOKEN}"  \
            -H "Content-Type: application/octet-stream" \
            --data-binary "@${asset_path}"  \
            "${upload_url}?name=${asset_name}&label=${asset_name}"
    )
    echo $asset_res
}

### Release image-prune
#
# Release the image-prune binaries
#
# Args:
# None
#
# Returns:
# None
function release_image_prune() {
    echo "Creating release $VERSION"
    local release_res=$(create_release "$VERSION")
    local upload_url="$(echo $release_res | jq -r '.upload_url')"
    upload_url="${upload_url%\{*}"
    add_release_assets "$VERSION" "$upload_url"
}

release_image_prune
