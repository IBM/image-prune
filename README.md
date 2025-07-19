# image-prune

A command-line interface for pruning container images in bulk from a container image distribution registry

> [!WARNING]
> Please be aware of this known issue.
> - [Skopeo delete command deletes by reference even when we provide tag](https://github.com/containers/skopeo/issues/1432)
>
> The `image-prune` CLI is built on the same foundational library as `skopeo`, and thus is impacted by this issue as well.  Please use this tool at your own risk.

## Install

TODO: Create a release of the CLI

## Demo

> For more demos, see [doc/demos.md](./doc/demos.md)

![image-prune prune --before-version](./doc/img/prune-before-version-tag.gif)
