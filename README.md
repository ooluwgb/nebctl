# nebctl

`nebctl` is a command line helper that wraps a collection of small scripts for day-to-day Nebius Platform operations. It provides a single entry point to common tasks such as listing resources or connecting to a Kubernetes cluster.

## Prerequisites

The scripts expect the following external tools to be installed and available in your `PATH`:

* [`npc`](https://docs.nebius.dev/en/cli/) – Nebius platform CLI
* [`kubectl`](https://kubernetes.io/docs/tasks/tools/) – for managing Kubernetes clusters
* `python3` (version **3.8 or higher**) – required to run the core CLI tool

Make sure `~/.local/bin` is in your `PATH` so the installed command is found.

## Installation

Install `nebctl` using the following commands based on your OS:

### MacOS/Linux

```bash
curl -sSL https://raw.githubusercontent.com/ooluwgb/nebctl/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/ooluwgb/nebctl/main/install.ps1 | iex
```

After installation, ensure that your `~/.local/bin` (Linux/macOS) or `%USERPROFILE%\AppData\Local\Microsoft\WindowsApps` (Windows, if applicable) is included in your system `PATH`.

Verify the installation:

```bash
nebctl --version
```

## Usage

Run the command followed by an **action** and **resource**:

```bash
nebctl <action> <resource> [options]
```

Available actions and resources:

* `get instance` – list compute instances in a project
* `get project` – list projects for a tenant
* `get grafana` – open dashboards for a compute instance
* `get bo` – open a resource in Backoffice
* `get plane` – open a resource in Plane
* `connect cluster` – configure `kubectl` for a managed Kubernetes cluster
* `describe instance` – show details of a compute instance

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
```
