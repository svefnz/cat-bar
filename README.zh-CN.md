[English](README.md) | 简体中文

<div align="center">

<img src="Sources/CatBar/Resources/Assets.xcassets/BrandLogo.imageset/logo.png" width="300" alt="CatBar Logo" style="border-radius: 68px;" />

# CatBar

面向 macOS 的 `mihomo` 菜单栏控制面板，适合希望在一个入口内完成代理、规则、连接、日志与核心操作管理的用户。

<p>
  <img alt="Platform" src="https://img.shields.io/badge/macOS-13%2B-111111?style=flat&logo=apple" />
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6.2-F05138?style=flat&logo=swift" />
  <img alt="Build" src="https://img.shields.io/badge/Build-SwiftPM-0A84FF?style=flat" />
  <img alt="i18n" src="https://img.shields.io/badge/i18n-zh--Hans%20%7C%20en-34C759?style=flat" />
  <img alt="Version" src="https://img.shields.io/github/v/release/svefnz/cat-bar?style=flat&logo=github" />
  <img alt="Downloads" src="https://img.shields.io/github/downloads/svefnz/cat-bar/total?style=flat-square&logo=dropbox&logoColor=white&color=green" />
</p>

<p>
  <img src="docs/static-resources/app-screenshot-dark.webp" alt="CatBar 截图" width="300" style="border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);" />
</p>

</div>

## 环境要求

- macOS 13 及以上版本
- 本地构建需要兼容 Swift 6.2 的 Xcode / Swift 工具链
- 若要在 CatBar 中启动核心，需要准备兼容的 `mihomo` 可执行文件

## 快速开始

### 安装发布版本

CatBar 当前只发布 `no-core` 版 DMG，不会随应用附带 Clash / `mihomo` 核心二进制。

1. 从 [GitHub Releases](https://github.com/svefnz/cat-bar/releases) 下载与你设备架构匹配的 DMG。
2. 将 `CatBar.app` 拖入 `Applications`。
3. 从 `Applications` 启动 CatBar。

   > [!NOTE]
   > 如果 macOS 提示“无法验证开发者，无法打开 CatBar.app”，这是因为该应用未进行 Apple 付费签名和公证。您可以通过在终端中运行以下命令来快速绕过该安全限制：
   > ```sh
   > xattr -cr /Applications/CatBar.app
   > ```
   > 或者，前往 Mac 的 **系统设置 -> 隐私与安全 -> 安全性** 区域，点击 **仍要打开** 即可。

4. 首次使用前，将名为 `mihomo` 的可执行文件放入：

```text
~/Library/Application Support/catbar/core/
```

CatBar 会从该目录加载核心。

### 从源码构建

1. 克隆仓库。
2. 构建应用包：

```sh
make build
```

3. 如需同时构建应用和 DMG：

```sh
make dist
```

## 功能概览

### 代理、节点与规则浏览

- 浏览代理分组并在组内切换节点。
- 查看提供者节点、订阅流量用量与到期信息。
- 搜索节点和规则，展开或折叠提供者，并支持单独或批量刷新。
- 按 `Rule`、`Global`、`Direct` 等运行模式过滤代理分组。

### 连接与日志监控

- 实时查看活跃连接，支持协议过滤、流量排序，以及主机 / IP 搜索。
- 查看命中规则、上游代理链路、上传 / 下载流量与连接开始时间。
- 支持关闭单个连接或关闭全部连接。
- 查看 CatBar 与 `mihomo` 日志，并按来源、级别和关键字过滤。

### 核心生命周期与维护

- 启动、停止、重启与重新加载核心。
- 启动前使用 `mihomo -t` 校验当前配置。
- 清空 DNS 缓存或 FakeIP 缓存、检查核心版本、重启核心 API，并更新 GEO 数据。
- 能检测核心缺失，并提示用户前往受管核心目录完成安装。

### 菜单栏快捷操作与设置

- 在菜单栏中显示运行状态、实时速度、连接数、内存占用与流量统计。
- 导入本地 YAML 配置或远程订阅。
- 在弹出面板中切换系统代理与 TUN 模式。
- 配置语言、外观、启动行为、端口、日志级别与开机启动等选项。

### 远程控制器支持

- 添加、编辑、检测与删除远程 `mihomo` 控制器。
- 在本地与远程目标之间切换。
- 使用自动拼接的连接参数打开远程 Web 面板。

## 本地构建

### 常用命令

```sh
make build
make dist
swift test
```

### 打包说明

- `make build` 会生成 `dist/CatBar.app`。
- `make dist` 会同时构建应用与 DMG 安装包。
- 构建脚本仍支持通过 `WITH_CORE=1` 生成历史兼容的 bundled-core 包，但当前发布工作流输出的是 `no-core` 制品。
- 发布流程会分别构建 Apple Silicon 与 Intel 两套 DMG。

发布维护细节可参考 [`docs/DEVELOPER.md`](docs/DEVELOPER.md)。

## 致谢

- 此独立维护发行版基于 [QuentinHsu/cat-bar](https://github.com/QuentinHsu/cat-bar) 开发。
- 上游项目源自 [Sitoi/ClashBar](https://github.com/Sitoi/ClashBar)。
- 感谢 [MetaCubeX/mihomo](https://github.com/MetaCubeX/mihomo) 提供核心运行时能力。

## 贡献者

感谢所有参与本项目的贡献者。

[![Contributors](https://contrib.rocks/image?repo=svefnz/cat-bar)](https://github.com/svefnz/cat-bar/graphs/contributors)

## Star 趋势

[![Star History Chart](https://starchart.cc/svefnz/cat-bar.svg?variant=adaptive)](https://starchart.cc/svefnz/cat-bar)

## 许可证

本项目基于 [GNU GPL v3.0](LICENSE) 许可发布。
