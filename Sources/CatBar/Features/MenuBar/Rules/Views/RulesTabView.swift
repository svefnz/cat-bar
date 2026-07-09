import SwiftUI

// swiftlint:disable:next type_name
private typealias T = MenuBarLayoutTokens

private struct RuleProviderStats {
    let count: Int
    let updatedText: String?
}

extension MenuBarRootView {
    var rulesTabBody: some View {
        let groups = self.rulesViewModel.policyGroups
        let providerLookup = self.rulesViewModel.providerLookup
        let providerStats = self.makeRuleProviderStatsLookup(providerLookup: providerLookup)
        let groupConcreteCounts = self.makeRuleGroupConcreteCounts(groups: groups, providerStats: providerStats)
        let totalConcreteCount = groupConcreteCounts.values.reduce(0, +)

        return VStack(alignment: .leading, spacing: T.space6) {
            HStack(spacing: 0) {
                self.rulesStatChip(title: tr("ui.rule.stats.rules"), value: "\(totalConcreteCount)")

                Spacer(minLength: 0)
                self.rulesRefreshButton
            }
            .padding(.top, T.space6)

            if self.remoteMachineStore.activeTarget.isLocal {
                self.rulesSearchSection
            }

            if groups.isEmpty {
                Text(tr("ui.empty.rules"))
                    .font(.app(size: T.FontSize.body, weight: .regular))
                    .foregroundStyle(nativeSecondaryLabel)
                    .padding(.horizontal, T.space4)
                    .padding(.vertical, T.space8)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            } else {
                VStack(spacing: 0) {
                    ForEach(groups) { group in
                        self.rulePolicyGroupSection(
                            group: group,
                            providerStats: providerStats,
                            concreteCount: groupConcreteCounts[group.id] ?? group.rules.count)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var rulesSearchSection: some View {
        VStack(alignment: .leading, spacing: T.space4) {
            HStack(spacing: T.space4) {
                NonActivatingTextField(
                    placeholder: tr("ui.rules.search_placeholder"),
                    text: $rulesViewModel.searchText,
                    style: .plain,
                    font: NSFont.monospacedSystemFont(ofSize: T.FontSize.body, weight: .regular),
                    onChange: {
                        if self.rulesViewModel.searchText.trimmed.isEmpty {
                            self.rulesViewModel.clearSearchResult()
                        }
                    },
                    onSubmit: {
                        Task { await self.searchCurrentLocalRules() }
                    })

                if !rulesViewModel.searchText.isEmpty {
                    Button {
                        self.rulesViewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.app(size: T.FontSize.caption, weight: .semibold))
                            .foregroundStyle(nativeTertiaryLabel)
                    }
                    .buttonStyle(.plain)
                }

                self.compactTopIcon(
                    "magnifyingglass",
                    label: tr("ui.rules.search_action"),
                    toneOverride: nativeInfo,
                    isLoading: self.rulesViewModel.searchState == .searching)
                {
                    await self.searchCurrentLocalRules()
                }
                .help(tr("ui.rules.search_action"))
                .disabled(self.rulesViewModel.searchText.trimmed.isEmpty)
            }
            .padding(.horizontal, T.space6)
            .menuBarTextInputSurface(
                horizontalPadding: 0,
                verticalPadding: T.space4,
                cornerRadius: T.cornerRadius)
            .padding(.horizontal, T.space4)

            if self.rulesViewModel.searchState != .idle {
                self.rulesSearchResultCard
            }
        }
    }

    @ViewBuilder
    private var rulesSearchResultCard: some View {
        switch self.rulesViewModel.searchState {
        case .idle:
            EmptyView()
        case .searching:
            self.rulesSearchInfoCard(
                title: tr("ui.rules.search_status.searching"),
                tone: nativeSecondaryLabel,
                lines: [])
        case .invalidInput:
            self.rulesSearchInfoCard(
                title: tr("ui.rules.search_status.invalid"),
                tone: nativeWarning,
                lines: [])
        case .missingConfig:
            self.rulesSearchInfoCard(
                title: tr("ui.rules.search_status.no_config"),
                tone: nativeWarning,
                lines: [])
        case let .noMatch(subject):
            self.rulesSearchInfoCard(
                title: tr(
                    "ui.rules.search_status.no_match",
                    self.rulesSearchSubjectLabel(subject),
                    subject.normalizedInput),
                tone: nativeSecondaryLabel,
                lines: [])
        case let .matched(result):
            self.rulesSearchInfoCard(
                title: tr(
                    "ui.rules.search_status.matched",
                    self.rulesSearchSubjectLabel(result.subject),
                    result.subject.normalizedInput),
                tone: nativePositive,
                lines: self.rulesSearchLines(for: result))
        case let .failed(message):
            self.rulesSearchInfoCard(
                title: tr("ui.rules.search_status.failed"),
                tone: nativeCritical,
                lines: [message])
        }
    }

    private func rulesSearchInfoCard(title: String, tone: Color, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: T.space4) {
            Text(title)
                .font(.app(size: T.FontSize.caption, weight: .semibold))
                .foregroundStyle(tone)

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.app(size: T.FontSize.caption, weight: .regular))
                    .foregroundStyle(nativePrimaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .menuRowPadding(vertical: T.space4)
        .background(
            RoundedRectangle(cornerRadius: T.cornerRadius, style: .continuous)
                .fill(nativeControlFill.opacity(isDarkAppearance ? 0.32 : 0.22)))
        .padding(.horizontal, T.space4)
    }

    private func rulesSearchSubjectLabel(_ subject: RuleSearchSubject) -> String {
        switch subject.kind {
        case .domain:
            tr("ui.rules.search_subject.domain")
        case .ip:
            tr("ui.rules.search_subject.ip")
        }
    }

    private func rulesSearchLines(for result: LocalRuleSearchResult) -> [String] {
        guard let match = result.effectiveMatch else { return [] }

        var lines = [
            tr("ui.rules.search_result.effective"),
            tr("ui.rules.search_result.policy", match.policy),
            tr(
                "ui.rules.search_result.rule",
                match.matchedRuleType,
                match.matchedRulePayload?.nonEmpty ?? tr("ui.common.na")),
        ]

        if let providerName = match.providerName?.trimmedNonEmpty {
            lines.append(tr("ui.rules.search_result.provider", providerName))
        }

        if let providerRuleType = match.providerRuleType?.trimmedNonEmpty {
            lines.append(tr(
                "ui.rules.search_result.provider_rule",
                providerRuleType,
                match.providerRulePayload?.nonEmpty ?? tr("ui.common.na")))
        }

        if let providerPath = match.providerPath?.trimmedNonEmpty {
            lines.append(tr("ui.rules.search_result.provider_path", providerPath))
        }

        let shadowedMatches = result.shadowedMatches
        if !shadowedMatches.isEmpty {
            lines.append(tr("ui.rules.search_result.also_matched", shadowedMatches.count))
            lines.append(contentsOf: shadowedMatches.map { self.rulesSearchSummaryLine(for: $0) })
        }

        return lines
    }

    private func rulesSearchSummaryLine(for match: LocalRuleSearchMatch) -> String {
        if let providerName = match.providerName?.trimmedNonEmpty,
           let providerRuleType = match.providerRuleType?.trimmedNonEmpty,
           let providerRulePayload = match.providerRulePayload?.trimmedNonEmpty
        {
            return tr(
                "ui.rules.search_result.shadowed_provider",
                match.policy,
                providerName,
                providerRuleType,
                providerRulePayload)
        }

        return tr(
            "ui.rules.search_result.shadowed_rule",
            match.policy,
            match.matchedRuleType,
            match.matchedRulePayload?.nonEmpty ?? tr("ui.common.na"))
    }

    private func rulePolicyGroupSection(
        group: RulePolicyGroup,
        providerStats: [String: RuleProviderStats],
        concreteCount: Int) -> some View
    {
        let isExpanded = expandedRuleGroups.contains(group.policy)
        let policyText = group.policy.isEmpty ? tr("ui.common.na") : group.policy
        let hovered = hoveredRuleGroup == group.policy

        return VStack(spacing: 0) {
            Button {
                if isExpanded {
                    expandedRuleGroups.remove(group.policy)
                } else {
                    expandedRuleGroups.insert(group.policy)
                }
            } label: {
                HStack(spacing: T.space4) {
                    Image(systemName: "chevron.right")
                        .font(.app(size: T.FontSize.caption, weight: .semibold))
                        .foregroundStyle(nativeTertiaryLabel)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .frame(width: 14, alignment: .center)

                    Text(policyText)
                        .font(.app(size: T.FontSize.body, weight: .semibold))
                        .foregroundStyle(nativePrimaryLabel)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text("\(concreteCount)")
                        .font(.app(size: T.FontSize.caption, weight: .bold))
                        .foregroundStyle(nativeSecondaryLabel)
                        .frame(minWidth: 32, alignment: .trailing)
                }
                .padding(.horizontal, T.space4)
                .frame(height: T.rowHeight)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(nativeHoverRowBackground(hovered))
            .onHover { hoveredRuleGroup = self.nextHovered(
                current: hoveredRuleGroup, target: group.policy, isHovering: $0) }

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.rules) { rule in
                        self.rulesRow(rule: rule, providerStats: providerStats)
                    }
                }
            }
        }
    }

    func rulesStatChip(title: String, value: String) -> some View {
        HStack(spacing: T.space4) {
            Text(title.uppercased())
                .font(.app(size: T.FontSize.caption, weight: .semibold))
                .foregroundStyle(nativeTertiaryLabel)
            Text(value)
                .font(.app(size: T.FontSize.body, weight: .bold))
                .foregroundStyle(nativePrimaryLabel)
        }
        .padding(.horizontal, T.space6)
        .padding(.vertical, T.space2)
    }

    var rulesRefreshButton: some View {
        self.compactTopIcon(
            "arrow.clockwise",
            label: tr("ui.action.refresh"),
            toneOverride: nativeInfo,
            isLoading: appSession.isRuleProvidersRefreshing)
        {
            await appSession.refreshRuleProviders()
        }
        .help(tr("ui.action.refresh"))
        .opacity(appSession.isRuleProvidersRefreshing ? 0.6 : 1)
    }

    fileprivate func rulesRow(rule: RuleItem, providerStats: [String: RuleProviderStats]) -> some View {
        let typeText = (rule.type.trimmedNonEmpty ?? tr("ui.common.na")).uppercased()
        let targetText = rule.payload.trimmedNonEmpty ?? tr("ui.common.na")
        let stats = self.ruleStats(payload: targetText, providerStats: providerStats)

        return HStack(spacing: T.space4) {
            Color.clear.frame(width: 14)

            Text(targetText)
                .font(.app(size: T.FontSize.body, weight: .regular))
                .foregroundStyle(nativePrimaryLabel)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(typeText)
                .font(.app(size: T.FontSize.caption, weight: .regular))
                .foregroundStyle(nativeTertiaryLabel)
                .frame(width: 80, alignment: .leading)

            Text(stats.updatedText ?? "")
                .font(.app(size: T.FontSize.caption, weight: .regular))
                .foregroundStyle(nativeTertiaryLabel)
                .lineLimit(1)
                .frame(width: 36, alignment: .trailing)

            Text(stats.hasProvider ? "\(stats.count)" : "")
                .font(.app(size: T.FontSize.caption, weight: .regular))
                .foregroundStyle(nativeSecondaryLabel)
                .frame(minWidth: 32, alignment: .trailing)
        }
        .padding(.horizontal, T.space4)
        .frame(height: T.rowHeight)
    }

    fileprivate func ruleStats(
        payload: String,
        providerStats: [String: RuleProviderStats]) -> (count: Int, updatedText: String?, hasProvider: Bool)
    {
        let payloadTrimmed = payload.trimmed
        guard !payloadTrimmed.isEmpty, payloadTrimmed != tr("ui.common.na") else {
            return (count: 0, updatedText: nil, hasProvider: false)
        }

        if let provider = providerStats[payloadTrimmed.lowercased()] {
            return (
                count: provider.count,
                updatedText: provider.updatedText,
                hasProvider: true)
        }
        return (count: 0, updatedText: nil, hasProvider: false)
    }

    private func makeRuleProviderStatsLookup(
        providerLookup: [String: ProviderDetail]) -> [String: RuleProviderStats]
    {
        guard !providerLookup.isEmpty else { return [:] }

        var stats: [String: RuleProviderStats] = [:]
        stats.reserveCapacity(providerLookup.count)

        for (key, provider) in providerLookup {
            stats[key] = RuleProviderStats(
                count: max(0, provider.ruleCount ?? 0),
                updatedText: ValueFormatter.relativeTime(from: provider.updatedAt, language: language))
        }

        return stats
    }

    private func makeRuleGroupConcreteCounts(
        groups: [RulePolicyGroup],
        providerStats: [String: RuleProviderStats]) -> [String: Int]
    {
        guard !groups.isEmpty else { return [:] }

        var counts: [String: Int] = [:]
        counts.reserveCapacity(groups.count)

        for group in groups {
            var count = 0
            for rule in group.rules {
                let payload = rule.payload?.trimmed ?? ""
                if let stats = providerStats[payload.lowercased()], stats.count > 0 {
                    count += stats.count
                } else {
                    count += 1
                }
            }
            counts[group.id] = count
        }

        return counts
    }

    func refreshVisibleRules() {
        self.rulesViewModel.updateVisibleRules(
            items: self.appSession.ruleItems,
            providers: self.appSession.ruleProviders)
    }

    func searchCurrentLocalRules() async {
        let configPath = await self.appSession.resolveSelectedConfigPath()
        await self.rulesViewModel.searchCurrentLocalRules(configPath: configPath)
    }
}
