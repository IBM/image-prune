# User input
VERSION=${1:-"v1.0.0-alpha.1"}
OPERATING_SYSTEM=${2:-"$(go env GOOS 2>/dev/null)"}
ARCHITECTURE=${3:-"$(go env GOARCH 2>/dev/null)"}

# Display install script usage
function display_usage() {
    echo "
Usage:
  <sh | bash> install.sh <version> [os] [arch]

Example:
  sh install.sh v1.0.0-alpha.1 linux amd64
"
}

# Fetch the release assets URL from the Github release
function get_release_assets_url() {
    local assets_url=$(
        curl -sL \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${GITHUB_TOKEN}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/repos/IBM/image-prune/releases/tags/${VERSION} \
            | jq -r .assets_url
    )
    echo "$assets_url"
}

# Fetch the release assets using the GitHub release assets URL
function list_release_assets() {
    local assets_url=$1
    local assets=$(
        curl -sL \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer ${GITHUB_TOKEN}" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "$assets_url"
    )
    echo "$assets"
}

# Fetch the release asset matching the given OS and architecture
function get_platform_release_asset() {
    local assets=$1
    echo "$assets" | jq -c '.[]' | while read i; do
        asset_name=$(echo $i | jq -r '.name')
        asset_url=$(echo $i | jq -r '.url')
        if [[ "$asset_name" == *"${OPERATING_SYSTEM}-${ARCHITECTURE}" ]]; then
            asset_path="$(pwd)/image-prune"
            echo "Downloading $asset_name to temporary path $asset_path"
            curl -sL \
                -H "Accept: application/octet-stream" \
                -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                -o "$(pwd)/image-prune" \
                "${asset_url}"
        fi
    done
}

# Move the downloaded release asset onto the PATH and make executable
function add_asset_to_path() {
    local asset_path=$1
    local new_asset_path="/usr/local/bin/image-prune"
    echo "Moving onto PATH $asset_path -> $new_asset_path"
    mv "$asset_path" "$new_asset_path"
    chmod +x "$new_asset_path"
}

# Ensure required env vars are set
if [[ -z "$OPERATING_SYSTEM" ]]; then
    echo "
[ERROR] No os given

Hint: Set environment variable: OPERATING_SYSTEM
"
    display_usage
    exit 1
fi
if [[ -z "$ARCHITECTURE" ]]; then
    echo "
[ERROR] No arch given

Hint: Set environment variable: ARCHITECTURE
"
    display_usage
    exit 1
fi
if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "
[ERROR] No github token given

Hint: Set environment variable: GITHUB_TOKEN
"
fi

# Get the release corresponding to the given version
release_assets_url=$(get_release_assets_url)
if [[ "$release_assets_url" == "null" ]]; then
    echo "[ERROR] image-prune version ${VERSION} does not exist"
    exit 1
fi

# List the release assets corresponding to the given version
release_assets=$(list_release_assets "$release_assets_url")

# Get the release asset matching the given os/arch
get_platform_release_asset "$release_assets"
asset_path="$(pwd)/image-prune"
if [ ! -f "$asset_path" ]; then
    echo "[ERROR] image-prune does not support platform ${OPERATING_SYSTEM}/${ARCHITECTURE}"
    exit 1
fi

# Add the asset to the path, make executable
add_asset_to_path "$asset_path"
