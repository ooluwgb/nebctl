# nebctl

`nebctl` is a command line helper that wraps a collection of small scripts for day to day Nebius Platform operations.  It provides a single entry point to common tasks such as listing resources or connecting to a Kubernetes cluster.

## Prerequisites

The scripts expect the following external tools to be installed and on your `PATH`:

- [`npc`](https://docs.nebius.dev/en/cli/) – Nebius platform CLI
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/) – for managing Kubernetes clusters

`nebctl` itself is a Python script and requires **Python 3.8+**.
Make sure `~/.local/bin` is in your `PATH` so the installed command is found.

## Installation

Run the `install` script from this repository to install `nebctl` locally:

```bash
./install
```

The script verifies your Python version, installs required tools, and symlinks
`nebctl` into `~/.local/bin`. Ensure that `~/.local/bin` is on your `PATH` so the
command is discoverable.
@@ -33,26 +30,43 @@ Verify the installation:
nebctl --version
```

## Usage

Run the command followed by an **action** and **resource**:

```bash
nebctl <action> <resource> [options]
```

Available actions and resources:

- `get instance` – list compute instances in a project
- `get project` – list projects for a tenant
- `get grafana` – open dashboards for a compute instance
- `get bo` – open a resource in Backoffice
- `get plane` – open a resource in Plane
- `connect cluster` – configure `kubectl` for a managed Kubernetes cluster
- `describe instance` – show details of a compute instance

Use `nebctl --help` to view a detailed help message with all flags and examples.

## Examples

List instances in a project:

```bash
nebctl get instance --project-id <project-id>
```

Describe a compute instance:

```bash
nebctl describe instance <instance-id>
```

Connect to a managed Kubernetes cluster:

```bash
nebctl connect cluster <cluster-id>
