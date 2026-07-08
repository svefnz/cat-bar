English | [简体中文](README.zh-CN.md)

<div align="center">

<img src="Sources/CatBar/Resources/Assets.xcassets/BrandLogo.imageset/logo.png" width="300" alt="CatBar Logo" style="border-radius: 68px;" />

# CatBar

A macOS menu bar control panel for `mihomo`, built for people who want to manage proxies, rules, connections, logs, and core operations from one place.

<p>
  <img alt="Platform" src="https://img.shields.io/badge/macOS-13%2B-111111?style=flat&logo=apple" />
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6.2-F05138?style=flat&logo=swift" />
  <img alt="Build" src="https://img.shields.io/badge/Build-SwiftPM-0A84FF?style=flat" />
  <img alt="i18n" src="https://img.shields.io/badge/i18n-zh--Hans%20%7C%20en-34C759?style=flat" />
  <img alt="Version" src="https://img.shields.io/github/v/release/QuentinHsu/cat-bar?style=flat&logo=github" />
  <img alt="Downloads" src="https://img.shields.io/github/downloads/QuentinHsu/cat-bar/total?style=flat-square&logo=dropbox&logoColor=white&color=green" />

</p>

<p>
  <img src="docs/static-resources/app-screenshot-dark.webp" alt="CatBar screenshot" width="300" style="border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);" />
</p>

</div>

## Requirements

- macOS 13 or later
- Xcode / Swift toolchain compatible with Swift 6.2 for local builds
- A compatible `mihomo` executable if you want to start the core from CatBar

## Quick Start

### Install a release build

CatBar currently publishes `no-core` DMG releases only. The app is distributed without bundling a Clash / `mihomo` core binary.

1. Download the DMG that matches your Mac from [GitHub Releases](https://github.com/QuentinHsu/cat-bar/releases).
2. Move `CatBar.app` into `Applications`.
3. Launch CatBar from `Applications`.

   > [!NOTE]
   > If macOS displays a Gatekeeper warning stating that *Apple cannot verify the app for malware* (because the app is self-signed/unsigned), you can bypass this security block by running the following command in Terminal:
   > ```sh
   > xattr -cr /Applications/CatBar.app
   > ```
   > Alternatively, you can go to **System Settings -> Privacy & Security** and click **Open Anyway** under the Security section.

4. Before first use, place an executable named `mihomo` into:

```text
~/Library/Application Support/catbar/core/
```

CatBar loads the core from that folder.

### Build from source

1. Clone the repository.
2. Build the app bundle:

```sh
make build
```

3. To build the app and DMG package together:

```sh
make dist
```

## Features

### Proxy, node, and rule inspection

- Browse proxy groups and switch nodes inline.
- Inspect provider-backed nodes, subscription usage, and expiry information.
- Search nodes and rules, expand providers, and refresh providers individually or in batches.
- Filter proxy groups by runtime mode such as `Rule`, `Global`, and `Direct`.

### Connection and log monitoring

- Monitor active connections with protocol filters, traffic sorting, and searchable host / IP fields.
- Inspect matched rules, upstream proxy chains, upload / download totals, and connection start times.
- Close one connection or all active connections.
- View CatBar and `mihomo` logs with source, level, and text filtering.

### Core lifecycle and maintenance

- Start, stop, restart, and reload the core.
- Validate selected configs with `mihomo -t` before launch.
- Clear DNS cache or FakeIP cache, check the core version, restart the core API, and update GEO data.
- Detect missing core binaries and guide users to the managed core directory.

### Menu bar workflows and settings

- Show runtime state, traffic speed, connection count, memory usage, and traffic totals in the menu bar.
- Import local YAML configs or remote subscriptions.
- Toggle system proxy and TUN mode from the popup panel.
- Configure language, appearance, launch behavior, ports, logging level, and startup options.

### Remote controller support

- Add, edit, test, and remove remote `mihomo` controllers.
- Switch between local and remote targets.
- Open the remote Web dashboard with generated connection parameters.

## Build Locally

### Common commands

```sh
make build
make dist
swift test
```

### Packaging notes

- `make build` creates `dist/CatBar.app`.
- `make dist` builds the app and DMG package.
- `WITH_CORE=1` is still supported by the build scripts for legacy bundled-core packaging, but the release workflow publishes `no-core` artifacts.
- Release automation builds separate Apple Silicon and Intel DMGs.

For release maintenance details, see [`docs/DEVELOPER.md`](docs/DEVELOPER.md).

## Acknowledgements

- CatBar is forked from [Sitoi/ClashBar](https://github.com/Sitoi/ClashBar).
- Thanks to [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) for the core runtime capabilities.

## Contributors

Thanks to everyone who has contributed to the project.

[![Contributors](https://contrib.rocks/image?repo=QuentinHsu/cat-bar)](https://github.com/QuentinHsu/cat-bar/graphs/contributors)

## Star History

[![Star History Chart](https://starchart.cc/QuentinHsu/cat-bar.svg?variant=adaptive)](https://starchart.cc/QuentinHsu/cat-bar)

## License

Licensed under [GNU GPL v3.0](LICENSE).
