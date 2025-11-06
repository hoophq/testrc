#!/bin/bash
set -eo pipefail

: "${VERSION:?env is required}"
: "${PRE_RELEASE:-"false"}"

gh auth status

# pull latest tags from remote
LATEST_TAG=$(gh release list --exclude-drafts -L 1 |awk {'print $3'})

echo "=> fetching tags from remote ..."
git fetch origin
echo ""

NOTE_FILE="$(mktemp).md"
GIT_COMMIT=$(git log ${LATEST_TAG}..HEAD --pretty=format:"%h %s (%an)")

cat - >$NOTE_FILE <<EOF
# Changelog

$GIT_COMMIT
EOF

NOTE_CONTENT=$(cat $NOTE_FILE)
cat - >$NOTE_FILE <<EOF
$NOTE_CONTENT

## Assets

- [hoop-darwin-arm64](https://releases.hoop.dev/release/${VERSION}/hoop_${VERSION}_Darwin_arm64.tar.gz)
- [hoop-darwin-amd64](https://releases.hoop.dev/release/${VERSION}/hoop_${VERSION}_Darwin_x86_64.tar.gz)
- [hoop-linux-arm64](https://releases.hoop.dev/release/${VERSION}/hoop_${VERSION}_Linux_arm64.tar.gz)
- [hoop-linux-amd64](https://releases.hoop.dev/release/${VERSION}/hoop_${VERSION}_Linux_x86_64.tar.gz)
- [hoop-windows-arm64](https://releases.hoop.dev/release/${VERSION}/hoop_${VERSION}_Windows_arm64.tar.gz)
- [hoop-windows-amd64](https://releases.hoop.dev/release/${VERSION}/hoop_${VERSION}_Windows_x86_64.tar.gz)
- [checksums.txt](https://releases.hoop.dev/release/${VERSION}/checksums.txt)

## Docker Images

- [hoophq/hoop:latest](https://hub.docker.com/repository/docker/hoophq/hoop)
- [hoophq/hoop:${VERSION}](https://hub.docker.com/repository/docker/hoophq/hoop)

### Agent Image | amd64

- [hoophq/hoopdev:latest](https://hub.docker.com/repository/docker/hoophq/hoopdev)
- [hoophq/hoopdev:${VERSION}](https://hub.docker.com/repository/docker/hoophq/hoopdev)

## Helm Chart

- [hoop-chart-${VERSION}](https://releases.hoop.dev/release/${VERSION}/hoop-chart-${VERSION}.tgz)
- [hoopagent-chart-${VERSION}](https://releases.hoop.dev/release/${VERSION}/hoopagent-chart-${VERSION}.tgz)

EOF


gh release create $VERSION -F $NOTE_FILE --title $VERSION --prerelease=$PRE_RELEASE
