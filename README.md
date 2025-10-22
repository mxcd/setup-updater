# setup-updater

A GitHub Action to install the [mxcd/updater](https://github.com/mxcd/updater) binary as a CI Pipeline tool.

## Usage

### Basic Usage

```yaml
- uses: mxcd/setup-updater@v1
```

This will install the default version (v0.2.1) of the updater binary.

### Specify Version

```yaml
- uses: mxcd/setup-updater@v1
  with:
    version: 'v0.2.1'
```

### Complete Workflow Example

```yaml
name: Use Updater
on: [push]

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Updater
        uses: mxcd/setup-updater@v1
        with:
          version: 'v0.2.1'
      
      - name: Run Updater
        run: updater version
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `version` | Version of mxcd/updater to install | No | `v0.2.1` |

## Outputs

| Output | Description |
|--------|-------------|
| `version` | The installed version of updater |

## Supported Platforms

This action supports the following platforms:
- Linux (amd64, arm64, arm, 386)
- macOS (amd64, arm64)
- Windows (amd64, arm64, 386)

## License

MIT