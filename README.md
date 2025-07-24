# nebctl

`nebctl` is a lightweight command‑line helper for common Nebius Platform operations. It wraps a collection of small Python scripts so you can manage resources with a single, consistent command.

## Features

- **List resources** – view instances, projects or monitoring dashboards.
- **Describe resources** – inspect compute instances or Kubernetes clusters in detail.
- **Connect clusters** – configure `kubectl` for a managed Kubernetes cluster.
- **Open Backoffice/Plane** – quickly jump to the web consoles for a resource.
- **Update** – fetch the latest version of `nebctl` with one command.

## Prerequisites

- [`npc`](https://docs.nebius.dev/en/cli/) – Nebius platform CLI
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/) – manage Kubernetes clusters
- `python3` (version **3.8 or higher**)

Make sure `~/.local/bin` is in your `PATH` so the installed command can be found.

## Installation

### macOS & Linux

```bash
curl -sSL https://raw.githubusercontent.com/ooluwgb/nebctl/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
iwr -useb https://raw.githubusercontent.com/ooluwgb/nebctl/main/install.ps1 | iex
```

After installation ensure `~/.local/bin` (Linux/macOS) or `%USERPROFILE%\AppData\Local\Microsoft\WindowsApps` (Windows) is in your `PATH`.

Check the installed version:

```bash
nebctl --version
```

## Usage

The general syntax is:

```bash
nebctl <action> <resource> [options]
```

| Action      | Resource  | Description                                          |
|-------------|-----------|------------------------------------------------------|
| `get`       | `instance`| List compute instances in a project                  |
|             | `project` | List projects for a tenant                           |
|             | `grafana` | Open monitoring dashboards for an instance          |
|             | `bo`      | Open a resource in Backoffice                        |
|             | `plane`   | Open a resource in Plane                             |
| `describe`  | `instance`| Show details of a compute instance                   |
|             | `cluster` | Show details of a managed Kubernetes cluster         |
| `connect`   | `cluster` | Configure `kubectl` for a MK8s cluster               |
| `update`    | *(none)*  | Update `nebctl` to the latest version                |

Run `nebctl --help` at any time for full reference and examples.

## Examples

List instances in a project:

```bash
nebctl get instance -n project-1234abcd
```

Describe a compute instance:

```bash
nebctl describe instance computeinstance-abcd1234
```

Describe a Kubernetes cluster:

```bash
nebctl describe cluster mk8scluster-e00cyj7dam4srnjvtw
```

Connect to a managed Kubernetes cluster:

```bash
nebctl connect cluster mk8scluster-e00sax3qcb30hds269 --force
```

---

`nebctl` is intentionally lightweight. Explore the `scripts` directory to see how each command works and adjust them for your own workflow.
