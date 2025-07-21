WORKDIR=$(pwd)

# Ensure GITHUB_TOKEN is set
if [ -z "$GITHUB_TOKEN" ]; then
    echo "[ERROR] GITHUB_TOKEN environment variable must be set"
    exit 1
fi

# GitHub API constants
GITHUB_API_DOMAIN="github.com"
GITHUB_REPO_SHORT_NAME="IBM/image-prune"

# Input parameters
UPLOAD_URL=${1%%\{*}
PLATFORMS=${2:-"darwin/amd64 darwin/arm64 windows/amd64 linux/amd64 linux/arm64 linux/ppc64le linux/s390x"}

# Display release script usage
function display_usage() {
    echo "
Usage:
  <sh | bash> release.sh <upload-url> [platforms]

Example:
  sh release.sh \"https://uploads.github.com/...\" \"darwin/amd64 linux/amd64\"
"
}

# Ensure UPLOAD_URL is set
if [ -z "$UPLOAD_URL" ]; then
    echo "[ERROR] UPLOAD_URL must be set"
    display_usage
    exit 1
fi

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

add_release_assets "${UPLOAD_URL}"
