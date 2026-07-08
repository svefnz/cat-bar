import SwiftUI

// swiftlint:disable:next type_name
private typealias T = MenuBarLayoutTokens

private struct SystemSettingsSectionCard<HeaderTrailing: View, Content: View>: View {
    let title: String
    let headerTint: Color
    @ViewBuilder let headerTrailing: () -> HeaderTrailing
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(self.title)
                    .font(.app(size: T.FontSize.body, weight: .bold))
                    .foregroundStyle(self.headerTint)
                    .textCase(.uppercase)
                Spacer(minLength: 0)
                self.headerTrailing()
            }
            .menuRowPadding(vertical: T.space2)

            self.content()
        }
    }
}

private extension SystemSettingsSectionCard where HeaderTrailing == EmptyView {
    init(
        title: String,
        headerTint: Color,
        @ViewBuilder content: @escaping () -> Content)
    {
        self.init(
            title: title,
            headerTint: headerTint,
            headerTrailing: { EmptyView() },
            content: content)
    }
}

extension MenuBarRootView {
    private var coreNetworkHealthRow: NetworkHealthRowState {
        SystemTabViewModel.networkHealthRows(session: appSession).first { $0.id == "core" }
            ?? NetworkHealthRowState(
                id: "core",
                title: tr("ui.network_health.row.core"),
                statusText: tr("ui.network_health.status.unavailable"),
                detail: nil,
                symbol: "bolt.horizontal.circle",
                kind: .info)
    }

    private var systemProxyControlState: ProxyFeatureControlState {
        SystemTabViewModel.systemProxyControlState(session: appSession)
    }

    private var tunControlState: ProxyFeatureControlState {
        SystemTabViewModel.tunControlState(session: appSession)
    }

    private var domesticAccessHealthRow: NetworkHealthRowState {
        SystemTabViewModel.networkHealthRows(session: appSession).first { $0.id == "domestic_access" }
            ?? NetworkHealthRowState(
                id: "domestic_access",
                title: tr("ui.network_health.row.domestic_access"),
                statusText: tr("ui.network_health.status.unavailable"),
                detail: nil,
                symbol: "flag.pattern.checkered.2.crossed",
                kind: .info)
    }

    private var globalAccessHealthRow: NetworkHealthRowState {
        SystemTabViewModel.networkHealthRows(session: appSession).first { $0.id == "global_access" }
            ?? NetworkHealthRowState(
                id: "global_access",
                title: tr("ui.network_health.row.global_access"),
                statusText: tr("ui.network_health.status.unavailable"),
                detail: nil,
                symbol: "globe.asia.australia",
                kind: .info)
    }

    private var pathNetworkHealthRow: NetworkHealthRowState {
        let summary = SystemTabViewModel.networkHealthSummary(session: appSession)
        return NetworkHealthRowState(
            id: "path",
            title: tr("ui.network_health.row.path"),
            statusText: summary.message,
            detail: nil,
            symbol: summary.symbol,
            kind: summary.kind)
    }

    private func networkHealthColor(for kind: SystemFeedbackKind) -> Color {
        switch kind {
        case .error:
            self.nativeCritical.opacity(T.Opacity.solid)
        case .warning:
            self.nativeWarning.opacity(T.Opacity.solid)
        case .success:
            self.nativePositive.opacity(T.Opacity.solid)
        case .info:
            self.nativeInfo.opacity(T.Opacity.solid)
        }
    }

    private func networkHealthGridCard(_ row: NetworkHealthRowState) -> some View {
        VStack(alignment: .leading, spacing: T.space2) {
            HStack(alignment: .center, spacing: T.space4) {
                Text(row.title)
                    .font(.app(size: T.FontSize.body, weight: .medium))
                    .foregroundStyle(nativePrimaryLabel)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer(minLength: 0)
            }

            HStack(alignment: .center, spacing: T.space4) {
                if let statusText = row.statusText?.trimmedNonEmpty {
                    Text(statusText)
                        .font(.app(size: T.FontSize.caption, weight: .semibold))
                        .foregroundStyle(self.networkHealthColor(for: row.kind))
                        .lineLimit(1)
                }

                if let detail = row.detail?.trimmedNonEmpty {
                    Text(detail)
                        .font(.app(size: T.FontSize.caption, weight: .regular))
                        .foregroundStyle(nativeTertiaryLabel)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .menuRowPadding(vertical: T.space2)
    }

    private func proxyFeatureControlCard(
        _ state: ProxyFeatureControlState,
        isOn: Binding<Bool>,
        isDisabled: Bool,
        hint: String? = nil) -> some View
    {
        VStack(alignment: .leading, spacing: T.space4) {
            self.settingsCompactToggleCell(
                state.title,
                isOn: isOn,
                isDisabled: isDisabled)

            if let hint = hint?.trimmedNonEmpty {
                self.settingsInlineHintRow(
                    text: hint,
                    color: self.nativeCritical.opacity(T.Opacity.solid),
                    symbol: "exclamationmark.triangle.fill")
            }
        }
    }

    var networkHealthSectionCard: some View {
        return SystemSettingsSectionCard(
            title: tr("ui.section.network_health"),
            headerTint: nativeTertiaryLabel,
            headerTrailing: {
                self.compactAsyncIconButton(
                    symbol: "arrow.clockwise",
                    label: tr("ui.action.refresh"),
                    tint: nativeInfo.opacity(T.Opacity.solid),
                    baseTint: nativeTertiaryLabel,
                    isLoading: appSession.isRuntimeNetworkHealthRefreshing,
                    size: 16,
                    fontSize: T.FontSize.caption)
                {
                    await appSession.manuallyRefreshRuntimeNetworkHealth()
                }
            })
        {
            VStack(alignment: .leading, spacing: T.space4) {
                if appSession.isRemoteTarget {
                    HStack(alignment: .top, spacing: T.space8) {
                        self.networkHealthGridCard(self.domesticAccessHealthRow)
                        self.networkHealthGridCard(self.globalAccessHealthRow)
                    }
                } else {
                    HStack(alignment: .top, spacing: T.space8) {
                        self.networkHealthGridCard(self.pathNetworkHealthRow)
                        self.networkHealthGridCard(self.coreNetworkHealthRow)
                    }

                    HStack(alignment: .top, spacing: T.space8) {
                        self.networkHealthGridCard(self.domesticAccessHealthRow)
                        self.networkHealthGridCard(self.globalAccessHealthRow)
                    }
                }
            }
            .menuRowPadding(vertical: T.space4)
        }
    }

    var systemCoreToggleItems: [(id: String, title: String, isOn: Binding<Bool>)] {
        [
            (
                AppSession.EditableCoreSetting.allowLan.id,
                tr("ui.settings.allow_lan"),
                self.editableCoreSettingBinding(.allowLan)),
            (
                AppSession.EditableCoreSetting.ipv6.id,
                tr("ui.settings.ipv6"),
                self.editableCoreSettingBinding(.ipv6)),
            (
                AppSession.EditableCoreSetting.tcpConcurrent.id,
                tr("ui.settings.tcp_concurrent"),
                self.editableCoreSettingBinding(.tcpConcurrent)),
        ]
    }

    var systemMaintenanceActions: [(titleKey: String, action: @MainActor () async -> Void)] {
        [
            ("ui.action.flush_fakeip_cache", { await appSession.flushFakeIPCache() }),
            ("ui.action.flush_dns_cache", { await appSession.flushDNSCache() }),
            ("ui.action.update_geo_database", { await appSession.upgradeGeo() }),
        ]
    }

    var selectedCoreLogLevel: String {
        appSession.stringValue(for: .logLevel)
    }

    var proxyControlSettingsSectionCard: some View {
        SystemSettingsSectionCard(
            title: tr("ui.section.proxy_control"),
            headerTint: nativeTertiaryLabel)
        {
            if !appSession.isRemoteTarget {
                HStack(spacing: T.space8) {
                    self.settingsRowLabel(tr("ui.quick.switch_config"))
                        .layoutPriority(1)
                    Spacer(minLength: 0)
                    AttachedPopoverMenu(
                        onWillPresent: {
                            self.appSession.refreshRemoteConfigMenuStates()
                        },
                        label: { _ in
                            HStack(spacing: T.space2) {
                                Text(appSession.selectedConfigName)
                                    .foregroundStyle(nativeSecondaryLabel)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Image(systemName: "chevron.right")
                                    .font(.app(size: T.FontSize.caption, weight: .semibold))
                                    .foregroundStyle(nativeTertiaryLabel)
                            }
                            .font(.app(size: T.FontSize.caption, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        },
                        content: { dismiss in
                            self.configMenuContent(dismiss: dismiss)
                        })
                        .frame(width: self.settingsMenuControlWidth, alignment: .trailing)
                        .appBorderedButtonStyle()
                        .controlSize(.small)
                }
                .menuRowPadding(vertical: T.space4)
            }

            if !appSession.isRemoteTarget {
                HStack(alignment: .top, spacing: T.space8) {
                    self.proxyFeatureControlCard(
                        self.systemProxyControlState,
                        isOn: Binding(
                            get: { appSession.isSystemProxyEnabled },
                            set: { value in
                                Task { await appSession.toggleSystemProxy(value) }
                        }),
                        isDisabled: appSession.isProxySyncing,
                        hint: appSession.systemProxyOpenFailureHint.map { "\(tr("app.system_proxy.alert.title")): \($0)" })

                    self.proxyFeatureControlCard(
                        self.tunControlState,
                        isOn: Binding(
                            get: { appSession.isTunEnabled },
                            set: { value in
                                Task { await appSession.toggleTunMode(value) }
                            }),
                        isDisabled: !appSession.isTunToggleEnabled)
                }
                .menuRowPadding(vertical: T.space2)
            } else {
                self.settingsTwoColumnRow(verticalPadding: T.space2) {
                    self.proxyFeatureControlCard(
                        self.tunControlState,
                        isOn: Binding(
                            get: { appSession.isTunEnabled },
                            set: { value in
                                Task { await appSession.toggleTunMode(value) }
                            }),
                        isDisabled: !appSession.isTunToggleEnabled)
                } trailing: {
                    self.settingsEmptyColumn()
                }
            }

            self.settingsCopyProxyCommandRow
        }
    }

    var appSettingsSectionCard: some View {
        SystemSettingsSectionCard(
            title: tr("ui.section.app_settings"),
            headerTint: nativeTertiaryLabel)
        {
            if !appSession.isRemoteTarget {
                self.settingsTwoColumnRow(verticalPadding: T.space2) {
                    self.settingsCompactToggleCell(
                        tr("ui.settings.launch_at_login"),
                        isOn: Binding(
                            get: { appSession.launchAtLoginEnabled },
                            set: { appSession.applyLaunchAtLogin($0) }))
                } trailing: {
                    self.settingsCompactToggleCell(
                        tr("ui.settings.auto_core_network_recovery"),
                        isOn: Binding(
                            get: { appSession.autoManageCoreOnNetworkChangeEnabled },
                            set: { appSession.autoManageCoreOnNetworkChangeEnabled = $0 }))
                }
            } else {
                self.settingsSingleCompactToggleRow(
                    tr("ui.settings.launch_at_login"),
                    isOn: Binding(
                        get: { appSession.launchAtLoginEnabled },
                        set: { appSession.applyLaunchAtLogin($0) }))
            }

            self.settingsSelectionRow(.init(
                title: tr("ui.settings.menu_bar_style"),
                valueText: self.statusBarModeLabel(appSession.statusBarDisplayMode),
                options: StatusBarDisplayMode.allCases,
                optionTitle: self.statusBarModeLabel,
                isSelected: { appSession.statusBarDisplayMode == $0 },
                onSelect: { appSession.statusBarDisplayMode = $0 }))
            self.settingsSelectionRow(.init(
                title: tr("ui.settings.language"),
                valueText: appSession.uiLanguage == .zhHans ? tr("ui.language.zh_hans") : tr("ui.language.en"),
                options: AppLanguage.allCases,
                optionTitle: { $0 == .zhHans ? tr("ui.language.zh_hans") : tr("ui.language.en") },
                isSelected: { appSession.uiLanguage == $0 },
                onSelect: appSession.setUILanguage))
            self.settingsSelectionRow(.init(
                title: tr("ui.settings.appearance"),
                valueText: self.appearanceModeLabel(appSession.appearanceMode),
                options: AppAppearanceMode.allCases,
                optionTitle: self.appearanceModeLabel,
                isSelected: { appSession.appearanceMode == $0 },
                onSelect: appSession.setAppearanceMode))
        }
    }

    var coreSettingsSectionCard: some View {
        SystemSettingsSectionCard(
            title: tr("ui.section.core_settings"),
            headerTint: nativeTertiaryLabel)
        {
            self.settingsTwoColumnRow(verticalPadding: T.space2) {
                let item = self.systemCoreToggleItems[0]
                self.settingsCompactToggleCell(
                    item.title,
                    isOn: item.isOn,
                    isDisabled: appSession.isCoreSettingSyncing)
            } trailing: {
                let item = self.systemCoreToggleItems[1]
                self.settingsCompactToggleCell(
                    item.title,
                    isOn: item.isOn,
                    isDisabled: appSession.isCoreSettingSyncing)
            }
            self.settingsTwoColumnRow(verticalPadding: T.space2) {
                let tcpConcurrentItem = self.systemCoreToggleItems[2]
                self.settingsCompactToggleCell(
                    tcpConcurrentItem.title,
                    isOn: tcpConcurrentItem.isOn,
                    isDisabled: appSession.isCoreSettingSyncing)
            } trailing: {
                self.settingsEmptyColumn()
            }
            self.settingsSelectionRow(.init(
                title: tr("ui.settings.log_level"),
                valueText: self.selectedCoreLogLevel,
                options: ConfigLogLevel.allCases,
                optionTitle: \.rawValue,
                isSelected: { self.selectedCoreLogLevel.caseInsensitiveCompare($0.rawValue) == .orderedSame },
                onSelect: { level in
                    Task { await appSession.applyEditableCoreSetting(.logLevel, to: level.rawValue) }
                }))
        }
    }

    var proxyPortsSectionCard: some View {
        SystemSettingsSectionCard(
            title: tr("ui.section.proxy_ports"),
            headerTint: nativeTertiaryLabel)
        {
            if appSession.isRemoteTarget {
                Text(tr("ui.machine.remote_readonly"))
                    .font(.app(size: T.FontSize.caption, weight: .regular))
                    .foregroundStyle(nativeTertiaryLabel)
                    .padding(.trailing, T.space8)
            }
        } content: {
            VStack(alignment: .leading, spacing: T.space2) {
                self.settingsTwoColumnRow(verticalPadding: T.space2) {
                    self.settingsCompactPortFieldCell(
                        tr("ui.settings.port.port"),
                        text: $appSession.settingsPort)
                } trailing: {
                    self.settingsCompactPortFieldCell(
                        tr("ui.settings.port.socks"),
                        text: $appSession.settingsSocksPort)
                }
                self.settingsTwoColumnRow(verticalPadding: T.space2) {
                    self.settingsCompactPortFieldCell(
                        tr("ui.settings.port.mixed"),
                        text: $appSession.settingsMixedPort)
                } trailing: {
                    self.settingsCompactPortFieldCell(
                        tr("ui.settings.port.redir"),
                        text: $appSession.settingsRedirPort)
                }
                self.settingsTwoColumnRow(verticalPadding: T.space2) {
                    self.settingsCompactPortFieldCell(
                        tr("ui.settings.port.tproxy"),
                        text: $appSession.settingsTProxyPort)
                } trailing: {
                    self.settingsEmptyColumn()
                }
            }
            .disabled(appSession.isRemoteTarget)
        }
    }

    var maintenanceSectionCard: some View {
        SystemSettingsSectionCard(
            title: tr("ui.section.maintenance"),
            headerTint: nativeTertiaryLabel)
        {
            VStack(alignment: .leading, spacing: T.space4) {
                HStack(spacing: T.space6) {
                    ForEach(self.systemMaintenanceActions, id: \.titleKey) { item in
                        self.maintenanceActionButton(tr(item.titleKey)) {
                            await item.action()
                        }
                    }
                }

                HStack(spacing: T.space6) {
                    self.maintenanceCoreUpgradeButton()

                    if !appSession.isRemoteTarget {
                        Button {
                            appSession.showCoreDirectoryInFinder()
                        } label: {
                            Text(tr("ui.action.open_core_directory"))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .appBorderedButtonStyle()
                        .controlSize(.small)
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                    }
                }

                if let feedback = self.maintenanceCoreUpgradeFeedbackState {
                    self.settingsFeedbackBanner(
                        text: feedback.message,
                        color: feedback.color,
                        symbol: feedback.symbol,
                        isLoading: feedback.isLoading)
                }
            }
            .menuRowPadding(vertical: T.space4)
        }
    }
}
