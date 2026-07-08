import SwiftUI

// swiftlint:disable:next type_name
private typealias T = MenuBarLayoutTokens

extension MenuBarRootView {
    func handleCopyProxyCommand(_ target: ProxyCommandCopyTarget, action: () -> Void) {
        action()

        self.proxyCommandCopyResetTask?.cancel()
        self.proxyCommandCopyResetTask = nil

        withAnimation(.snappy(duration: 0.16)) {
            self.copiedProxyCommandTarget = target
        }

        self.proxyCommandCopyResetTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 1_600_000_000)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.16)) {
                self.copiedProxyCommandTarget = nil
            }
            self.proxyCommandCopyResetTask = nil
        }
    }

    var quickRowTrailingColumnWidth: CGFloat {
        min(170, max(126, contentWidth * 0.44))
    }

    func isRemoteConfigFile(_ name: String) -> Bool {
        self.appSession.remoteConfigSources[name] != nil
    }

    func configMenuLeadingSymbol(for name: String) -> String {
        self.isRemoteConfigFile(name) ? "link" : "doc.text"
    }

    func configMenuLeadingTint(for name: String) -> Color {
        self.isRemoteConfigFile(name)
            ? self.nativePurple.opacity(T.Opacity.solid)
            : self.nativeInfo.opacity(T.Opacity.solid)
    }

    func configMenuSubtitle(state: RemoteConfigMenuState?) -> String? {
        guard let state else { return nil }
        return state.updatedAt.map(ValueFormatter.dateTime) ?? "--"
    }

    @ViewBuilder
    func configMenuContent(dismiss: @escaping () -> Void) -> some View {
        ForEach(appSession.availableConfigFileNames, id: \.self) { name in
            let remoteState = self.appSession.remoteConfigMenuState(for: name)

            ConfigMenuItemView(
                title: name,
                subtitle: self.configMenuSubtitle(state: self.isRemoteConfigFile(name) ? remoteState : nil),
                leadingSymbol: self.configMenuLeadingSymbol(for: name),
                leadingTint: self.configMenuLeadingTint(for: name),
                selected: name == appSession.selectedConfigName,
                refreshPhase: self.isRemoteConfigFile(name) ? remoteState.phase : nil,
                refreshHelpText: tr("ui.action.refresh"),
                refreshingAccessibilityLabel: tr("ui.quick.remote.refreshing"),
                refreshFailedHelpText: tr("ui.quick.remote.refresh_failed"))
            {
                dismiss()
                Task { await appSession.selectConfigFile(named: name) }
            } onRefresh: {
                Task { await appSession.refreshRemoteConfigFile(named: name) }
            }

            if self.isRemoteConfigFile(name) {
                self.remoteConfigSubscriptionControls(for: name)
            }
        }
        AttachedPopoverMenuDivider()
        AttachedPopoverMenuItem(
            title: tr("ui.quick.reload_config_list"),
            leadingSymbol: "arrow.clockwise",
            leadingTint: self.nativeInfo.opacity(T.Opacity.solid))
        {
            dismiss()
            appSession.reloadConfigFileList()
        }
        AttachedPopoverMenuItem(
            title: tr("ui.quick.import_local_config"),
            leadingSymbol: "square.and.arrow.down",
            leadingTint: self.nativePositive.opacity(T.Opacity.solid))
        {
            dismiss()
            appSession.importLocalConfigFile()
        }
        AttachedPopoverMenuItem(
            title: tr("ui.quick.import_remote_config"),
            leadingSymbol: "link.badge.plus",
            leadingTint: self.nativePurple.opacity(T.Opacity.solid))
        {
            dismiss()
            Task { await appSession.importRemoteConfigFile() }
        }
        AttachedPopoverMenuItem(
            title: tr("ui.quick.update_remote_configs"),
            leadingSymbol: "arrow.triangle.2.circlepath",
            leadingTint: self.nativeWarning.opacity(T.Opacity.solid))
        {
            dismiss()
            Task { await appSession.updateAllRemoteConfigFiles() }
        }
        AttachedPopoverMenuItem(
            title: tr("ui.quick.edit_config"),
            leadingSymbol: "chevron.left.forwardslash.chevron.right",
            leadingTint: self.nativeInfo.opacity(T.Opacity.solid))
        {
            dismiss()
            appSession.editConfigDirectoryInVSCode()
        }
        AttachedPopoverMenuItem(
            title: tr("ui.quick.show_in_finder"),
            leadingSymbol: "folder",
            leadingTint: self.nativeSecondaryLabel)
        {
            dismiss()
            appSession.showSelectedConfigInFinder()
        }
    }

    var proxyTabBody: some View {
        VStack(alignment: .leading, spacing: T.space6) {
            self.trafficOverview
            proxyGroupsSection
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    var trafficOverview: some View {
        let sparklineHeight: CGFloat = 64
        let sparklineHorizontalInset = T.space4

        return ZStack {
            TrafficSparklineView(
                upValues: appSession.trafficHistoryUp,
                downValues: appSession.trafficHistoryDown)
                .frame(height: sparklineHeight)
                .padding(.horizontal, sparklineHorizontalInset)

            VStack(spacing: 0) {
                HStack(spacing: T.space6) {
                    self.metricCell(
                        symbol: "link",
                        value: "\(connectionsStore.connectionsCount)",
                        color: nativeIndigo,
                        alignment: .leading)
                        .frame(maxWidth: .infinity)

                    self.metricCell(
                        symbol: "arrow.up.circle",
                        value: ValueFormatter.bytesCompactNoSpace(appSession.displayUpTotal),
                        color: nativeInfo,
                        alignment: .trailing)
                        .frame(maxWidth: .infinity)

                    self.metricCell(
                        symbol: "arrow.up.circle.fill",
                        value: ValueFormatter.speedCompactNoSpace(appSession.traffic.up),
                        color: nativeInfo,
                        alignment: .trailing)
                        .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)

                HStack(spacing: T.space6) {
                    self.metricCell(
                        symbol: "memorychip",
                        value: ValueFormatter.bytesInteger(appSession.memory.inuse),
                        color: nativeTeal,
                        alignment: .leading)
                        .frame(maxWidth: .infinity)

                    self.metricCell(
                        symbol: "arrow.down.circle",
                        value: ValueFormatter.bytesCompactNoSpace(appSession.displayDownTotal),
                        color: nativePositive.opacity(T.Opacity.solid),
                        alignment: .trailing)
                        .frame(maxWidth: .infinity)

                    self.metricCell(
                        symbol: "arrow.down.circle.fill",
                        value: ValueFormatter.speedCompactNoSpace(appSession.traffic.down),
                        color: nativePositive.opacity(T.Opacity.solid),
                        alignment: .trailing)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, T.space4)
            .padding(.vertical, T.space2)
        }
        .frame(height: sparklineHeight)
        .padding(.top, T.space2)
    }

    func metricCell(
        symbol: String,
        value: String,
        color: Color,
        alignment: Alignment) -> some View
    {
        let icon = Image(systemName: symbol)
            .font(.app(size: T.FontSize.caption, weight: .semibold))
            .foregroundStyle(color)
        let text = Text(value)
            .font(.app(size: T.FontSize.body, weight: .regular))
            .foregroundStyle(nativeSecondaryLabel)
            .lineLimit(1)
            .minimumScaleFactor(T.minimumScale)

        return HStack(spacing: T.space2) {
            icon
            text
        }
        .frame(maxWidth: .infinity, alignment: alignment)
    }


    @ViewBuilder
    func remoteConfigSubscriptionControls(for fileName: String) -> some View {
        if let subscription = appSession.remoteConfigSubscriptions[fileName] {
            let autoUpdateBinding = Binding<Bool>(
                get: { subscription.autoUpdateEnabled },
                set: { newValue in
                    var updated = subscription
                    updated.autoUpdateEnabled = newValue
                    appSession.upsertRemoteConfigSubscription(for: fileName, subscription: updated)
                    appSession.scheduleRemoteConfigAutoUpdateIfNeeded()
                })

            let intervalBinding = Binding<Int>(
                get: { subscription.autoUpdateIntervalHours },
                set: { newValue in
                    var updated = subscription
                    updated.autoUpdateIntervalHours = newValue
                    appSession.upsertRemoteConfigSubscription(for: fileName, subscription: updated)
                })

            VStack(alignment: .leading, spacing: T.space2) {
                Toggle(isOn: autoUpdateBinding) {
                    Text(tr("ui.settings.auto_update"))
                        .font(.app(size: T.FontSize.caption, weight: .regular))
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                .padding(.leading, T.space6)

                if subscription.autoUpdateEnabled {
                    HStack(spacing: T.space2) {
                        Text(tr("ui.settings.auto_update_interval"))
                            .font(.app(size: T.FontSize.caption, weight: .regular))
                            .foregroundStyle(nativeSecondaryLabel)

                        Stepper(value: intervalBinding, in: 1...72) {
                            Text("\(subscription.autoUpdateIntervalHours)h")
                                .font(.app(size: T.FontSize.caption, weight: .regular))
                                .monospacedDigit()
                                .foregroundStyle(nativeSecondaryLabel)
                        }
                        .controlSize(.small)
                    }
                    .padding(.leading, T.space6)

                    if let nextUpdate = subscription.nextUpdateAt() {
                        Text(tr("ui.settings.next_update", ValueFormatter.dateTime(nextUpdate)))
                            .font(.app(size: T.FontSize.caption, weight: .regular))
                            .foregroundStyle(nativeSecondaryLabel)
                            .padding(.leading, T.space6)
                    }
                }
            }
            .padding(.vertical, T.space1)
        }
    }
}

private struct ConfigMenuItemView: View {
    let title: String
    let subtitle: String?
    let leadingSymbol: String?
    let leadingTint: Color
    let selected: Bool
    let refreshPhase: RemoteConfigRefreshPhase?
    let refreshHelpText: String
    let refreshingAccessibilityLabel: String
    let refreshFailedHelpText: String
    let onSelect: () -> Void
    let onRefresh: (() -> Void)?

    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .center, spacing: T.space6) {
            Button(action: self.onSelect) {
                HStack(alignment: .center, spacing: T.space6) {
                    if let leadingSymbol {
                        Image(systemName: leadingSymbol)
                            .font(.app(size: T.FontSize.caption, weight: .semibold))
                            .foregroundStyle(self.leadingSymbolForeground)
                            .frame(width: 12, alignment: .center)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(self.title)
                            .font(.app(size: T.FontSize.body, weight: self.selected ? .semibold : .medium))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(self.primaryTextColor)

                        if let subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.app(size: T.FontSize.caption, weight: .regular))
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .monospacedDigit()
                                .foregroundStyle(self.secondaryTextColor)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let refreshPhase, let onRefresh {
                self.refreshControl(phase: refreshPhase, onRefresh: onRefresh)
            }
        }
        .padding(.horizontal, T.space6)
        .padding(.vertical, T.space2)
        .background(
            RoundedRectangle(cornerRadius: T.cornerRadius, style: .continuous)
                .fill(self.rowBackground))
        .contentShape(Rectangle())
        .onHover { self.isHovered = $0 }
    }

    private func refreshControl(
        phase: RemoteConfigRefreshPhase,
        onRefresh: @escaping () -> Void) -> some View
    {
        let failureTint = Color(nsColor: .systemRed)
        let helpText: String
        let tint: Color
        let baseTint: Color
        let isLoading = phase == .refreshing

        switch phase {
        case .idle:
            helpText = self.refreshHelpText
            tint = Color(nsColor: .controlAccentColor)
            baseTint = self.secondaryTextColor
        case .refreshing:
            helpText = self.refreshingAccessibilityLabel
            tint = self.secondaryTextColor
            baseTint = self.secondaryTextColor
        case .failed:
            helpText = self.refreshFailedHelpText
            tint = failureTint
            baseTint = failureTint.opacity(0.92)
        }

        return CompactAsyncIconButton(
            symbol: "arrow.clockwise",
            tint: tint,
            baseTint: baseTint,
            role: nil,
            isLoading: isLoading,
            size: 20,
            fontSize: T.FontSize.body,
            hierarchicalSymbol: false,
            action: { onRefresh() })
            .help(helpText)
            .accessibilityLabel(helpText)
    }

    private var primaryTextColor: Color {
        if self.isHovered {
            return Color(nsColor: .selectedMenuItemTextColor)
        }
        return .primary
    }

    private var secondaryTextColor: Color {
        if self.isHovered {
            return Color(nsColor: .selectedMenuItemTextColor).opacity(0.88)
        }
        return self.selected ? .primary.opacity(0.72) : .secondary
    }

    private var leadingSymbolForeground: Color {
        if self.isHovered {
            return Color(nsColor: .selectedMenuItemTextColor)
        }
        return self.leadingTint
    }

    private var rowBackground: Color {
        if self.isHovered {
            return Color(nsColor: .selectedContentBackgroundColor)
        }
        if self.selected {
            return Color(nsColor: .selectedContentBackgroundColor).opacity(0.34)
        }
        return .clear
    }
}
