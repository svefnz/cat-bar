## v1.0.5

> 本次更新重点覆盖 `changelog`、`preference`、`proxy`，主要提升交互表现并修复稳定性问题。

### 🚀 优化改进

- **changelog**：release 1.0.4

### 🐞 问题修复

- **preference**：fix system proxy and TUN preference loss on app restart
- **proxy**：add real-time system proxy preference persistence to survive crash and force-quit

## v1.0.4

> 本次更新重点覆盖 `changelog`、`tun`，主要提升交互表现并修复稳定性问题。

### 🚀 优化改进

- **changelog**：
  - release 1.0.3
  - release 1.0.4
- use macos-latest runner to resolve GitHub Actions hanging issue

### 🐞 问题修复

- **tun**：fix AppSession initialization timing and safeguard TUN user preference

## v1.0.3

> 本次更新重点覆盖 `changelog`、`ui`、`tun`，同时包含能力补齐、交互整理和稳定性修复。

### ✨ 新增功能

- **ui**：display execution states on FakeIP and DNS cache flush buttons

### 🚀 优化改进

- **changelog**：release 1.0.3
- use macos-latest runner to resolve GitHub Actions hanging issue

### 🐞 问题修复

- **tun**：preserve isTunEnabled preference when stopping core

## v1.0.2

> 本次更新重点覆盖 `performance`、`ui`，主要提升交互表现并修复稳定性问题。

### 🚀 优化改进

- **performance**：optimize log persistence, remote auto-update timing, and icon caching concurrent safety

### 🐞 问题修复

- **ui**：use minWidth instead of fixed width for rule counts to prevent wrapping

## v1.0.1

> 本次更新重点覆盖 `changelog`、`readme`、`lifecycle`，同时包含能力补齐、交互整理和稳定性修复。

### ✨ 新增功能

- **maintenance**：add one-click Geo database update
- **proxy**：add proxy group icon cache with NSCache + disk fallback
- **system-proxy**：add proxy bypass (exception) management
- **config**：add remote subscription management

### 🚀 优化改进

- **changelog**：release 1.0.0
- **readme**：add Gatekeeper warning bypass note for macOS users

### 🐞 问题修复

- **lifecycle**：disable runtime TUN before network loss stop

## v1.0.0

> 本次更新重点覆盖 `readme`、`persistence`、`changelog`，主要补齐能力并整理交互体验。

### ✨ 新增功能

- **persistence**：implement log file size rotation and backup capping

### 🚀 优化改进

- **readme**：rewrite bilingual readme content
- **changelog**：release 1.0.0

## v0.11.1

> 本次更新优化了核心停止后的清理与恢复处理，并收紧了菜单栏系统页布局，使整体使用体验更稳定、界面更清爽。

### 🚀 优化改进

- **session**：extract core stop cleanup and recovery planning
- **menu-bar**：tighten system tab layout

## v0.11.0

> 本次更新带来本地规则匹配搜索，并进一步提升了远程目标控制、核心升级与启动恢复、代理流量展示和界面细节的一致性与稳定性。

### ✨ 新增功能

- **rules**：add local rule match search

### 🚀 优化改进

- **changelog**：
  - release 0.9.0
  - release 0.10.0
  - release 0.10.1
- **rules**：align Chinese proxy group terminology
- **menu-bar**：unify core mode switcher styling

### 🐞 问题修复

- **system**：stabilize network control cards for remote targets
- **core**：restart core after successful upgrade
- **remote-machine**：build Web UI URL from config
- **session**：restore previous local core running state on launch
- **menu-bar**：unify text input styling and placeholder alignment
- **proxy**：refine traffic overview layout and compact speed format

## v0.10.1

> 本次更新统一了中文代理分组术语，修复了核心升级后未自动重启和远程机器 Web UI 地址生成不正确的问题，让使用体验更加顺畅可靠。

### 🚀 优化改进

- **rules**：align Chinese proxy group terminology

### 🐞 问题修复

- **core**：restart core after successful upgrade
- **remote-machine**：build Web UI URL from config

## v0.10.0

> 本次更新为本地规则匹配新增搜索能力，帮助你更快定位和查看目标规则。

### ✨ 新增功能

- **rules**：add local rule match search

## v0.9.0

> 本次更新让配置编辑与远程机器管理更顺手，网络健康状态展示也更清晰准确。

### ✨ 新增功能

- **config**：add VSCode shortcut for config editing
- **remote-machine**：improve remote machine editor usability

### 🚀 优化改进

- **system**：refine network health with grid cards

### 🐞 问题修复

- **system**：correct network health rendering for remote targets

## v0.8.1

> 本次更新修复了符号链接配置路径的处理问题，让通过软链接管理配置时的加载与使用更加稳定。

### 🚀 优化改进

- **release**：switch DMG publishing to gh CLI

### 🐞 问题修复

- **config**：handle symlinked config paths correctly

## v0.8.0

> 本次更新新增运行时网络健康检查，帮助你更及时发现连接异常并更稳妥地使用 CatBar。

### ✨ 新增功能

- add runtime network health checks (#3)

## v0.7.2

> 本次更新将来源管理迁移至独立窗口、修复了本地节点列表误含远程节点的问题，并通过减少临时内存分配与引入索引查找优化了代理分组的运行效率。

### 🚀 优化改进

- **source-manager**：move source management into a dedicated window
- **menu-bar**：reduce transient allocations in tab filtering
- **session**：replace proxy group cache with index lookup
- **changelog**：normalize changelog grouping and tool log cleanup

### 🐞 问题修复

- **nodes**：exclude provider-backed remote leaf nodes from local list

## v0.7.1

> 本次更新将应用会话决策与菜单栏展示逻辑分离，使状态管理更清晰，为后续功能扩展奠定更稳固的基础。

### 🚀 优化改进

- split AppSession decisions and menu bar presentation (#2)

## v0.7.0

> 本次更新优化了代理分组与节点管理的交互体验，支持批量延迟测试与核心更新入口，同时修复了规则模式下分组过滤异常、远程目标系统代理设置误显示等多处问题，整体运行更加稳定可靠。

### ✨ 新增功能

- **view**：
  - enhance MenuBarNodeRow with metric action display and refactor proxy group handling
  - enhance TrafficSparklineView with improved path drawing and control point calculations
  - introduce NonActivatingTextField for improved focus handling in text fields
- **nodes**：support batch latency tests in remote node popovers
- **remote-machine**：add configurable web ui entry for remote sources
- **system**：add core update entry to maintenance panel

### 🚀 优化改进

- **ui**：unify latency test button styling
- **readme**：rewrite README with bilingual entry points

### 🐞 问题修复

- **viewmodel**：filter out GLOBAL entries in rule mode for proxy groups
- **view**：
  - remove unused icon handling in connections and proxy group views
  - simplify sorting icon and label handling in proxy groups section
  - dismiss popover on disappearance of AttachedPopoverMenu
- **system**：hide system proxy settings for remote targets

## v0.6.2

> 本次更新修复了本地节点列表中保留条目被错误显示的问题。

### 🐞 问题修复

- **nodes**：filter reserved entries from local node list

## v0.6.1

> 本次更新对核心逻辑进行了重新实现，进一步提升了整体运行的稳定性与可靠性。

### 🚀 优化改进

- **global**：reimplement (#1)

## v0.6.0

> 本次更新修复了代理布局、列表显示及设置自动保存等多项体验问题，并在核心重启期间以灰色状态栏图标明确反馈运行状态，同时统一了系统代理图标风格，使整体交互更加稳定流畅。

### ✨ 新增功能

- **ui**：gray out status bar icon and speed display during core restart

### 🚀 优化改进

- **github**：standardize app name to CatBar in bug template
- **guide**：optimize beginner guide and add mihomo template
- **ui**：unify system proxy icon style and remove dynamic colors
- **readme**：replace broken star history API with starchart.cc

### 🐞 问题修复

- **settings**：prevent auto-save triggering without actual content modification
- **proxy**：
  - fix layout truncation and incorrect height measurement
  - optimize helper recovery and offline proxy toggling
  - force connection drop on network or proxy mode switch
- **ui**：prevent bottom clipping and missing scroll on long lists

## v0.5.2

> 本次更新完成了品牌重命名、优化了退出流程以彻底消除界面卡顿，并同步升级了 CI 依赖。

### 🚀 优化改进

- **actions**：bump versions for core github actions
- **branding**：rename ClashBar to CatBar across codebase
- **lifecycle**：completely refactor app termination to resolve UI freezing

## v0.5.1

> 本次更新优化了品牌视觉形象并重构了更新日志的生成方式，使项目呈现更加规范统一。

### 🚀 优化改进

- **release**：restructure changelog format and generation logic
- **branding**：replace brand logo and optimize static images

## v0.5.0

> 本次更新优化了批量延迟测试的去重与分组逻辑，使代理测速结果更准确，同时简化了发布流程并升级了 Actions 运行环境，提升整体稳定性与维护效率。

### ✨ 新增功能

- **release**：simplify changelog generation and add Copilot summaries

### 🚀 优化改进

- **actions**：force JavaScript actions to run on Node 24
- **proxy**：refactor batch latency testing with deduplication and per-group completion

## v0.4.0

> 本次更新重点覆盖 `menu-bar`、`remote`、`core`，主要补齐功能并修复关键问题。

### ✨ 新增功能

- **menu-bar**：move local network mode toggles into settings
- **remote**：allow switching to offline sources and unify status colors
- **core**：default releases to no-core packaging

### 🐞 问题修复

- **settings**：avoid spurious proxy port autosaves

## v0.3.1

> 本次更新重点覆盖 `menu-bar`，主要是一次体验与交互整理。

### 🚀 优化改进

- **menu-bar**：tighten source manager modal and stabilize source refresh

## v0.3.0

> 本次更新重点覆盖 `menu-bar`、`proxy`、`rules`，同时包含能力补齐、交互整理和稳定性修复。

### ✨ 新增功能

- **proxy**：show proxy command targets inline；support batch and single-node speed testing in proxy groups
- **menu-bar**：add thin scroll indicator for tab content；move provider updates to context menus
- **remote-machine**：support web panel entry for remote machines
- **nodes**：add dedicated nodes tab for raw proxies management；add provider refresh actions and sync update time
- **system**：add core restart and geo update actions；reorganize terminal proxy command actions
- **rules**：support group-based remote ruleset updates
- **update**：add Sparkle-based in-app updates
- **release**：automate changelog updates for stable releases

### 🚀 优化改进

- **proxy**：remove proxy providers section from proxy tab；redesign traffic overview layout
- **menu-bar**：cap list samples during panel height measurement；optimize rules and connections tab rendering；unify pinned header and optimize row rendering；move tun mode and proxy commands to system tab
- **system**：reorganize system settings sections
- **rules**：align rules tab naming
- **formatter**：unify speed formatting logic and adjust display precision
- **connections**：extract connection row into standalone Equatable view
- **settings**：prevent redundant proxy port auto-saves；merge proxy ports into core settings
- **session**：prevent redundant view updates on identical polling payloads
- **ui**：remove redundant leading icons；unify core upgrade feedback and normalize version display

### 🐞 问题修复

- **proxy**：unify icon for latency test actions；resolve latency display for referenced proxy groups
- **menu-bar**：restore source-aware state and panel behavior；adjust footer bar spacing；prevent blank flash on first rules/connections tab switch；rebuild rules tab and trim rules view pipeline；align collapse toggles on nodes and rules tabs
- **remote-machine**：guard offline switching and improve proxy host copy；sync statusText on target switch for speed display
- **nodes**：correct panel sizing after expanding remote providers
- **system**：sync launch-at-login state after approval
- **rules**：stabilize rule list item identifiers；show rule types in Clash-native format；unify rule type display formatting；align refresh icon with nodes tab
- **release**：handle releases without Sparkle keys；pass Sparkle private key through stdin
- **settings**：avoid autosave on system tab init
- **ui**：remove source labels from settings
- **popover**：stabilize menu bar panel height calculation
- **status-bar**：reset first responder when opening panel
- **package**：avoid reserved variable name in awk
- **i18n**：normalize labels for mode and port settings
- **providers**：correct provider update success handling

## v0.2.1

> 本次更新补齐了远程机器管理与远程感知界面，同时重做菜单栏顶部交互，并加强系统代理恢复链路，让多端点场景下的状态展示与操作反馈更可靠。

### ✨ 新增功能

- **remote-machine**：
  - add remote machine management to the menu bar
  - support local and remote target switching
  - make remote-only and local-only settings explicit in remote sessions
- **header**：show current target and connectivity status across tabs

### 🚀 优化改进

- **menu-bar**：
  - redesign segmented mode and tab controls
  - refine proxy details, connection summaries, and list layouts
- **system-proxy**：surface helper status, background permission state, and effective proxy address
- **architecture**：reorganize the app into clearer layered modules and improve beta packaging flow

### 🐞 问题修复

- **system-proxy**：
  - restore proxy state more reliably after startup, wake, and target switches
  - warm up the helper proactively and improve recovery behavior
  - add clearer guidance for installation, permission, and helper registration failures
- **remote-machine**：
  - keep page state and quick actions consistent while switching targets
  - adapt proxy command, TUN, and system proxy actions for remote usage

## v0.2.0

> 本次更新主要聚焦菜单栏交互稳定性与性能修复，减少代理分组悬停带来的高占用，并修正 Popover、System 页和 TUN 状态同步等一系列体验问题。

### 🚀 优化改进

- **menu-bar**：
  - cache derived activity data to reduce repeated recomputation
  - isolate live connection stream handling from page state updates
  - continue refining spacing, headers, and sparkline presentation

### 🐞 问题修复

- **proxy**：
  - fix excessive CPU usage while hovering proxy groups
  - stabilize fallback group ordering after refresh
- **popover**：stabilize hover detection for attached popovers
- **system**：prevent feedback banners from shifting the System tab layout
- **tun**：sync persisted TUN state with the actual runtime state
- **system-proxy**：improve tolerance for helper recovery races

## v0.1.9

> 本次更新集中修正状态栏显示稳定性，将速度文本改为模板图像渲染，并修复状态栏宽度与弹出面板尺寸在切换场景下的抖动问题。

### ✨ 新增功能

- **status-bar**：render speed text with cached template images

### 🚀 优化改进

- **status-bar**：clean up rendering helpers and simplify width calculation
- **popover**：use a more stable sizing path and respond faster to height changes

### 🐞 问题修复

- **status-bar**：fix width jitter while switching icon and speed display modes
- **popover**：stabilize panel sizing across screen changes and content updates

## v0.1.8

> 本次更新提升了代理页面的信息展示与排序控制，新增代理组顺序切换，并重新设计订阅行摘要；同时修复状态栏图标模板化和 Helper XPC 认证问题。

### ✨ 新增功能

- **proxy**：add a proxy group ordering toggle for latency and default order
- **status-bar**：introduce dedicated running and sleeping icons

### 🚀 优化改进

- **providers**：
  - redesign provider rows to show update time, refresh state, expiry, and usage progress
  - remove redundant node-level state tracking to keep provider summaries lightweight

### 🐞 问题修复

- **status-bar**：enable template rendering so icons dim correctly with system focus changes
- **helper**：replace PID-based XPC verification with code-signing requirement checks

## v0.1.7

> 本次更新补齐了系统代理状态恢复这条关键链路，避免应用重启后无故掉代理；同时新增 System 页快捷键，并在启动后自动触发分组延迟测试。

### ✨ 新增功能

- **system**：add a keyboard shortcut to open the System tab
- **proxy**：auto-test proxy group latencies after core startup

### 🚀 优化改进

- **lifecycle**：clear system proxy state proactively during app shutdown

### 🐞 问题修复

- **system-proxy**：restore the previous proxy state automatically after relaunch

## v0.1.6

> 本次更新把 Mihomo 内核升级入口直接放进菜单栏底部，运行中也能一键检查和执行升级；同时补齐升级反馈、版本刷新与新版检测时机，减少升级过程中的黑盒感。

### ✨ 新增功能

- **core**：add a one-click Mihomo upgrade action to the menu bar footer

### 🚀 优化改进

- **core**：
  - add clearer in-progress, success, up-to-date, and failure feedback during upgrades
  - refresh the displayed Mihomo version after upgrade completes
  - check for app updates when the panel opens instead of relying on background polling

### 🐞 问题修复

- **core**：improve compatibility with different `/upgrade` response formats and correctly detect already-up-to-date results
