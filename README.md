# citygml-tools Docker

Minimal Docker packaging for the `citygml-tools` CLI with preinstalled dependencies.

## Table of Contents

- [Requirements](#requirements)
- [Image](#image)
- [Quick Start](#quick-start)
- [Run with PowerShell (Windows)](#run-with-powershell-windows)
- [Run with Shell (Linuxmacos)](#run-with-shell-linuxmacos)
- [Direct Docker One-Liner](#direct-docker-one-liner)
- [Release Versioning](#release-versioning)

## Requirements

- Docker installed and running
- Commands executed from the repository root (where `Dockerfile` is located)

## Image

Prebuilt image on GHCR:

```sh
docker pull ghcr.io/csi-foxbyte/citygml-tools-docker:latest
```

## Quick Start

Use the helper scripts to build and run against `test_data`.

## Run with PowerShell (Windows)

Default smoke test:

```powershell
.\run-test.ps1
```

Pass custom CLI args:

```powershell
.\run-test.ps1 validate /data/720_5432.gml
```

Build once, then run faster:

```powershell
.\run-test.ps1
.\run-test.ps1 -SkipBuild stats --no-json-report /data
```

## Run with Shell (Linux/macOS)

Make script executable once:

```sh
chmod +x ./run-test.sh
```

Default smoke test:

```sh
./run-test.sh
```

Pass custom CLI args:

```sh
./run-test.sh validate /data/720_5432.gml
```

Build once, then run faster:

```sh
./run-test.sh --skip-build stats --no-json-report /data
```

## Direct Docker One-Liner

Run the image directly on your own work folder (image must already exist).

Linux/macOS:

```sh
docker run --rm -v "$PWD:/work" ghcr.io/csi-foxbyte/citygml-tools-docker:latest validate /work/your-file.gml
```

PowerShell:

```powershell
docker run --rm -v "${PWD}:/work" ghcr.io/csi-foxbyte/citygml-tools-docker:latest validate /work/your-file.gml
```

## Release Versioning

- Publish is triggered by Git tags matching `v*`.
- Use tag format `vX.Y.Z` (for example `v2.4.0`).
- CI strips the leading `v` and sets `CITYGML_TOOLS_VERSION=X.Y.Z` for the image build.
- The Git tag is the single source of truth for the included `citygml-tools` version.
