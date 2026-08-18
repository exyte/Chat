//
//  UIList.swift
//  
//
//  Created by Alisa Mylnikova on 24.02.2023.
//

import SwiftUI
import Combine

struct UIList<MessageContent: View>: UIViewRepresentable {

    typealias MessageBuilderParamsClosure = ChatView<MessageContent, InputView, DefaultMessageMenuAction>.MessageBuilderParamsClosure

    @Environment(\.chatTheme) var theme

    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var inputViewModel: InputViewModel

    @Binding var pendingScrollTo: ScrollToParams?
    @Binding var isScrolledToBottom: Bool
    @Binding var tableContentHeight: CGFloat

    // MARK: - View builders

    let messageBuilder: MessageBuilderParamsClosure
    let mainHeaderBuilder: (()->AnyView)?
    let dateHeaderBuilder: ((Date)->AnyView)?

    // MARK: - Data / type

    let type: ChatType
    let sections: [MessagesSection]
    let ids: [String]

    // MARK: - Customization

    let chatParams: ChatCustomizationParameters
    let messageParams: MessageCustomizationParameters

    // MARK: - State

    @State private var isScrolledToTop = false
    @State private var updateQueue = UpdateQueue()
    @State private var transaction = TableUpdateTransaction()

    @State private var cancellables = Set<AnyCancellable>()

    func makeUIView(context: Context) -> UITableView {
        let style = mainHeaderBuilder != nil || chatParams.showDateHeaders ? UITableView.Style.grouped : .plain
        let tableView = UITableView(frame: .zero, style: style)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.transform = CGAffineTransform(rotationAngle: (type == .conversation ? .pi : 0))

        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedSectionHeaderHeight = 1
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor(theme.contentBG)
        tableView.scrollsToTop = false
        tableView.isScrollEnabled = chatParams.isScrollEnabled
        tableView.keyboardDismissMode = chatParams.keyboardDismissMode
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.tableHeaderView = nil
        tableView.tableFooterView = UIView(frame: .zero)

        transaction.updateQueue = updateQueue
        chatParams.onTransactionReady?(transaction)

        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        if !chatParams.isScrollEnabled {
            DispatchQueue.main.async {
                tableContentHeight = tableView.contentSize.height
            }
        }

        if tableView.contentInset != chatParams.contentInsets {
            tableView.contentInset = chatParams.contentInsets
        }

        context.coordinator.chatParams = chatParams

        let needToUpdateSections = context.coordinator.latestUpdateSections != sections
        let needToScroll = pendingScrollTo != nil

        //print("changes animationMode: \(animationMode) needToUpdateSections: \(needToUpdateSections), needToScroll: \(needToScroll), pendingScrollTo: \(pendingScrollTo)")

        guard needToUpdateSections || needToScroll else { return }

        context.coordinator.latestUpdateSections = sections
        context.coordinator.updateInProgress = true

        Task {
            let animationMode = await updateQueue.getAnimationMode()
            await updateQueue.markRealUpdate()

            await updateQueue.createJob {
                if needToUpdateSections {
                    if animationMode == .none
                        || context.coordinator.sections.isEmpty
                        || pendingScrollTo != nil { // if we're gonna scroll later, then update cells without animation, and animate scrolling later
                        updateTableNoAnimation(tableView, context.coordinator)
                    } else if animationMode == .natural, tableView.contentOffset == .zero {
                        await updateTableWithAnimation(tableView, context.coordinator)
                    } else {
                        // if transaction.animationMode == .keepStable
                        // || (transaction.animationMode == .natural && tableView.contentOffset != .zero) {
                        await performInsertPreservingOffset(tableView, context.coordinator)
                    }
                }

                if needToScroll, let scrollToParams = pendingScrollTo {
                    pendingScrollTo = nil // reset to only scroll once

                    let perform = {
                        performScrollTo(tableView, scrollToParams: scrollToParams)
                    }

                    if animationMode == .natural {
                        await withCheckedContinuation { continuation in
                            UIView.animate(withDuration: 0.25) {
                                perform()
                            } completion: { _ in
                                continuation.resume()
                            }
                        }
                    } else {
                        perform()
                    }
                }

                tableView.beginUpdates()
                context.coordinator.updateInProgress = false
                context.coordinator.paginationState.olderInProgress = false
                context.coordinator.paginationState.newerInProgress = false
                tableView.endUpdates()
                tableView.relayoutHeadersFooters()
            }
        }
    }

    // MARK: scroll to

    func performScrollTo(_ tableView: UITableView, scrollToParams: ScrollToParams) {
        switch scrollToParams.scrollTo {
        case .messageID(let messageID, let position, let offset):
            scrollToRow(tableView, messageID: messageID, position: position, additionalOffset: offset)
        case .tableOffset(let offset):
            tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
        case .newestMessage:
            tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        case .oldestMessage:
            // An empty table has no section 0 to ask about: clamping the index
            // to 0 makes numberOfRows(inSection:) raise
            // "Requested the number of rows for section (0) which is out of bounds".
            guard tableView.numberOfSections > 0 else { return }

            let lastSection = tableView.numberOfSections - 1
            let lastRow = tableView.numberOfRows(inSection: lastSection) - 1

            guard lastRow >= 0 else { return }

            tableView.scrollToRow(
                at: IndexPath(row: lastRow, section: lastSection),
                at: .bottom,
                animated: false
            )
        }
    }

    @MainActor
    func scrollToRow(_ tableView: UITableView, messageID: String, position: UITableView.ScrollPosition, additionalOffset: CGFloat) {
        let indicatorIP = UIList.lastReadIndicatorIndexPath(sections: sections, enabled: chatParams.showLastReadIndicator)
        guard let indexPath = indexPath(for: messageID, in: sections, indicatorIndexPath: indicatorIP),
              let rect = tableView.rectForRow(at: indexPath) as CGRect? else { return }

        let adjustedPosition =
        (position == .middle || type == .comments) ? position
        : position == .bottom ? .top: .bottom

        let baseY: CGFloat
        switch adjustedPosition {
        case .top:
            baseY = rect.minY - tableView.adjustedContentInset.top
        case .middle:
            baseY = rect.midY - tableView.bounds.height / 2
        default:
            baseY = rect.maxY - tableView.bounds.height + tableView.adjustedContentInset.bottom
        }

        let targetY = baseY + additionalOffset

        let minOffset = -tableView.adjustedContentInset.top
        let maxOffset = tableView.contentSize.height - tableView.bounds.height + tableView.adjustedContentInset.bottom

        let clampedY = max(minOffset, min(targetY, maxOffset))

        tableView.setContentOffset(CGPoint(x: 0, y: clampedY), animated: false)
    }

    static func lastReadIndicatorIndexPath(sections: [MessagesSection], enabled: Bool) -> IndexPath? {
        guard enabled else { return nil }
        for (si, section) in sections.enumerated() {
            for (ri, row) in section.rows.enumerated() {
                if case .readBy = row.message.status, si > 0 || ri > 0 {
                    return IndexPath(row: ri, section: si)
                }
            }
        }
        return nil
    }

    func indexPath(for id: String, in sections: [MessagesSection], indicatorIndexPath: IndexPath? = nil) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            if let rowIndex = section.rows.firstIndex(where: { $0.message.id == id }) {
                if let ip = indicatorIndexPath, ip.section == sectionIndex, rowIndex >= ip.row {
                    return IndexPath(row: rowIndex + 1, section: sectionIndex)
                }
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }

    // MARK: update table

    func performInsertPreservingOffset(_ tableView: UITableView, _ coordinator: Coordinator) async {
        let oldIndicatorIP = UIList.lastReadIndicatorIndexPath(sections: coordinator.sections, enabled: chatParams.showLastReadIndicator)

        // Skip the indicator row — it has no backing message to preserve by ID
        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
        guard let firstVisibleIndexPath = visibleIndexPaths.first(where: { $0 != oldIndicatorIP }),
              let preservedVisibleRect = tableView.rectForRow(at: firstVisibleIndexPath) as CGRect? else { return }

        let dataRow = adjustedDataRow(firstVisibleIndexPath.row, section: firstVisibleIndexPath.section, indicator: oldIndicatorIP)
        let firstVisibleRow = coordinator.sections[firstVisibleIndexPath.section].rows[dataRow]
        let preservedVisibleMessageID = firstVisibleRow.message.id
        let preservedOffset = tableView.contentOffset.y

        coordinator.sections = sections

        CATransaction.setDisableActions(true)

        tableView.reloadData()
        tableView.layoutIfNeeded()

        let newIndicatorIP = UIList.lastReadIndicatorIndexPath(sections: sections, enabled: chatParams.showLastReadIndicator)
        guard let newIndexPath = indexPath(for: preservedVisibleMessageID, in: sections, indicatorIndexPath: newIndicatorIP) else { return }
        let newRectForCell = tableView.rectForRow(at: newIndexPath)
        let newOffset = preservedOffset + (newRectForCell.minY - preservedVisibleRect.minY)
        tableView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)

        tableView.relayoutHeadersFooters()
    }

    private func adjustedDataRow(_ tableRow: Int, section: Int, indicator: IndexPath?) -> Int {
        guard let ip = indicator, ip.section == section, tableRow > ip.row else { return tableRow }
        return tableRow - 1
    }

    @MainActor
    private func updateTableNoAnimation(_ tableView: UITableView, _ coordinator: Coordinator) {
        coordinator.sections = sections

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        UIView.performWithoutAnimation {
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }

        CATransaction.commit()
    }

    @MainActor
    private func updateTableWithAnimation(_ tableView: UITableView, _ coordinator: Coordinator) async {
        let prevSections = coordinator.sections
        let splitInfo = await performSplitInBackground(prevSections, sections)
        await applyOperations(tableView, splitInfo: splitInfo, prevSections: prevSections) {
            coordinator.sections = $0
        }
    }

    nonisolated private func performSplitInBackground(_ prevSections: [MessagesSection], _ sections: [MessagesSection]) async -> SplitInfo {
        await Task.detached {
            SplitInfo.operationsSplit(oldSections: prevSections, newSections: sections)
        }.value
    }

    @MainActor
    private func applyOperations(_ tableView: UITableView, splitInfo: SplitInfo, prevSections: [MessagesSection], updateContextClosure: ([MessagesSection])->()) async {
        // step 0: preparation
        // prepare intermediate sections and operations
//        print("whole appliedDeletes:\n", formatSections(splitInfo.appliedDeletes), "\n")
//        print("whole appliedDeletesSwapsAndEdits:\n", formatSections(splitInfo.appliedDeletesSwapsAndEdits), "\n")
//        print("whole final sections:\n", formatSections(sections), "\n")
//
//        print("operations delete:\n", splitInfo.deleteOperations.map { $0.description })
//        print("operations swap:\n", splitInfo.swapOperations.map { $0.description })
//        print("operations edit:\n", splitInfo.editOperations.map { $0.description })
//        print("operations insert:\n", splitInfo.insertOperations.map { $0.description })

        await performBatchTableUpdates(tableView) {
            // step 1: deletes
            let deleteIndicatorIP = UIList.lastReadIndicatorIndexPath(sections: prevSections, enabled: chatParams.showLastReadIndicator)
            updateContextClosure(splitInfo.appliedDeletes)
            for operation in splitInfo.deleteOperations {
                applyOperation(operation, tableView: tableView, indicatorIndexPath: deleteIndicatorIP)
            }
        }

        await performBatchTableUpdates(tableView) {
            // step 2: swaps
            let swapIndicatorIP = UIList.lastReadIndicatorIndexPath(sections: splitInfo.appliedDeletes, enabled: chatParams.showLastReadIndicator)
            updateContextClosure(splitInfo.appliedDeletesSwapsAndEdits)
            for operation in splitInfo.swapOperations {
                applyOperation(operation, tableView: tableView, indicatorIndexPath: swapIndicatorIP)
            }
        }

        await performBatchTableUpdates(tableView) {
            // step 3: edits
            let editIndicatorIP = UIList.lastReadIndicatorIndexPath(sections: splitInfo.appliedDeletesSwapsAndEdits, enabled: chatParams.showLastReadIndicator)
            updateContextClosure(splitInfo.appliedDeletesSwapsAndEdits)
            for operation in splitInfo.editOperations {
                applyOperation(operation, tableView: tableView, indicatorIndexPath: editIndicatorIP)
            }
        }

        // step 4: inserts
        let prevIndicatorIP = UIList.lastReadIndicatorIndexPath(sections: splitInfo.appliedDeletesSwapsAndEdits, enabled: chatParams.showLastReadIndicator)
        let insertIndicatorIP = UIList.lastReadIndicatorIndexPath(sections: sections, enabled: chatParams.showLastReadIndicator)
        updateContextClosure(sections)

        let animated = isScrolledToBottom || isScrolledToTop
        await performBatchTableUpdates(tableView) {
            for operation in splitInfo.insertOperations {
                applyOperation(operation, tableView: tableView, animateInserts: animated, indicatorIndexPath: insertIndicatorIP)

                // When a section is inserted, UITableView uses its cached row counts as "before".
                // If the indicator moves away from an existing section to the new one (or disappears),
                // that section silently loses a virtual row — UITableView sees this as inconsistent.
                // Explicitly delete the virtual indicator row so the before→after counts stay valid.
                if case .insertSection(let newSection) = operation, let oldIP = prevIndicatorIP {
                    let shiftedSection = newSection <= oldIP.section ? oldIP.section + 1 : oldIP.section
                    if insertIndicatorIP?.section != shiftedSection {
                        tableView.deleteRows(at: [IndexPath(row: oldIP.row, section: oldIP.section)], with: .none)
                    }
                }
            }
        }
        //print("4 finished inserts")

        tableView.relayoutHeadersFooters()

        if !chatParams.isScrollEnabled {
            tableContentHeight = tableView.contentSize.height
        }
    }

    private func isSectionOperation(_ operation: Operation) -> Bool {
        switch operation {
        case .deleteSection, .insertSection:
            return true
        case .delete, .insert, .swap, .edit, .editChangingHeight:
            return false
        }
    }

    // MARK: - Operations

    enum Operation {
        case deleteSection(Int)
        case insertSection(Int)

        case delete(Int, Int)
        case insert(Int, Int)
        case swap(Int, Int, Int)

        case edit(Int, Int) // reload the element without animation (otherwise it blinks)
        case editChangingHeight(Int, Int) // reload the element with simple animation

        var description: String {
            switch self {
            case .deleteSection(let int):
                return "deleteSection \(int)"
            case .insertSection(let int):
                return "insertSection \(int)"
            case .delete(let int, let int2):
                return "delete section \(int) row \(int2)"
            case .insert(let int, let int2):
                return "insert section \(int) row \(int2)"
            case .swap(let int, let int2, let int3):
                return "swap section \(int) rowFrom \(int2) rowTo \(int3)"
            case .edit(let int, let int2):
                return "edit section \(int) row \(int2)"
            case .editChangingHeight(let int, let int2):
                return "editChangingHeight section \(int) row \(int2)"
            }
        }
    }

    func applyOperation(_ operation: Operation, tableView: UITableView, animateInserts: Bool = true, indicatorIndexPath: IndexPath? = nil) {
        func tableRow(_ section: Int, _ row: Int) -> Int {
            guard let ip = indicatorIndexPath, ip.section == section, row >= ip.row else { return row }
            return row + 1
        }

        switch operation {
        case .deleteSection(let section):
            tableView.deleteSections([section], with: .automatic)
        case .insertSection(let section):
            tableView.insertSections([section], with: .top)
        case .delete(let section, let row):
            tableView.deleteRows(at: [IndexPath(row: tableRow(section, row), section: section)], with: .top)
        case .insert(let section, let row):
            tableView.insertRows(at: [IndexPath(row: tableRow(section, row), section: section)], with: animateInserts ? .top : .none)
        case .swap(let section, let rowFrom, let rowTo):
            tableView.deleteRows(at: [IndexPath(row: tableRow(section, rowFrom), section: section)], with: .top)
            tableView.insertRows(at: [IndexPath(row: tableRow(section, rowTo), section: section)], with: .top)
        case .edit(let section, let row):
            tableView.reconfigureRows(at: [IndexPath(row: tableRow(section, row), section: section)])
        case .editChangingHeight(let section, let row):
            tableView.reloadRows(at: [IndexPath(row: tableRow(section, row), section: section)], with: .automatic)
        }
    }

    // MARK: - Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator(
            viewModel: viewModel,
            inputViewModel: inputViewModel,
            isScrolledToBottom: $isScrolledToBottom,
            isScrolledToTop: $isScrolledToTop,

            messageBuilder: messageBuilder,
            mainHeaderBuilder: mainHeaderBuilder,
            dateHeaderBuilder: dateHeaderBuilder,

            type: type,
            sections: sections,
            ids: ids,

            chatParams: chatParams,
            messageParams: messageParams,
            mainBackgroundColor: theme.contentBG
        )
    }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {

        @ObservedObject var viewModel: ChatViewModel
        @ObservedObject var inputViewModel: InputViewModel

        @Binding var isScrolledToBottom: Bool
        @Binding var isScrolledToTop: Bool

        // MARK: - View builders

        let messageBuilder: MessageBuilderParamsClosure
        let mainHeaderBuilder: (()->AnyView)?
        let dateHeaderBuilder: ((Date)->AnyView)?

        // MARK: - Data / type

        let type: ChatType
        var sections: [MessagesSection] {
            didSet {
                if let id = sections.last?.rows.last?.message.id {
                    olderPaginationTargetMessageID = id
                }
                if let id = sections.first?.rows.first?.message.id {
                    newerPaginationTargetMessageID = id
                }
            }
        }
        let ids: [String]

        // MARK: - Customization

        var chatParams: ChatCustomizationParameters
        let messageParams: MessageCustomizationParameters
        let mainBackgroundColor: Color

        var updateInProgress: Bool = false
        /// call pagination handler when this row is reached
        /// without this there is a bug: during new cells insertion willDisplay is called one extra time for the cell which used to be the last one while it is being updated (its position in group is changed from first to middle)
        var olderPaginationTargetMessageID: String?
        var newerPaginationTargetMessageID: String?
        let paginationState = PaginationState()

        // helpers to avoid queueing same updates multiple times
        var latestUpdateSections: [MessagesSection] = []

        private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)

        init(
            viewModel: ChatViewModel,
            inputViewModel: InputViewModel,
            isScrolledToBottom: Binding<Bool>,
            isScrolledToTop: Binding<Bool>,

            messageBuilder: @escaping MessageBuilderParamsClosure,
            mainHeaderBuilder: (() -> AnyView)?,
            dateHeaderBuilder: ((Date) -> AnyView)?,

            type: ChatType,
            sections: [MessagesSection],
            ids: [String],

            chatParams: ChatCustomizationParameters,
            messageParams: MessageCustomizationParameters,
            mainBackgroundColor: Color
        ) {
            self.viewModel = viewModel
            self.inputViewModel = inputViewModel
            self._isScrolledToBottom = isScrolledToBottom
            self._isScrolledToTop = isScrolledToTop

            self.messageBuilder = messageBuilder
            self.mainHeaderBuilder = mainHeaderBuilder
            self.dateHeaderBuilder = dateHeaderBuilder

            self.type = type
            self.sections = sections
            self.ids = ids

            self.chatParams = chatParams
            self.messageParams = messageParams
            self.mainBackgroundColor = mainBackgroundColor
        }

        var lastReadIndicatorIndexPath: IndexPath? {
            UIList.lastReadIndicatorIndexPath(sections: sections, enabled: chatParams.showLastReadIndicator)
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            sections.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let base = sections[section].rows.count
            if let ip = lastReadIndicatorIndexPath, ip.section == section {
                return base + 1
            }
            return base
        }

        private func messageRow(at indexPath: IndexPath) -> MessageRow? {
            let indicatorIP = lastReadIndicatorIndexPath
            guard indexPath != indicatorIP else { return nil }
            let dataRow: Int
            if let ip = indicatorIP, ip.section == indexPath.section, indexPath.row > ip.row {
                dataRow = indexPath.row - 1
            } else {
                dataRow = indexPath.row
            }
            return sections[indexPath.section].rows[dataRow]
        }

        // MARK: - headers/footers

        // small optimization: exclude sections that can't possibly have a header/footer
        func hasSectionView(_ section: Int) -> Bool {
            chatParams.showDateHeaders || section == 0 || section == sections.count - 1
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            hasSectionView(section) ? UITableView.automaticDimension : 0
        }

        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            hasSectionView(section) ? UITableView.automaticDimension : 0
        }

        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            hasSectionView(section) ? makeHostingView { sectionHeaderView(section) } : nil
        }

        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            hasSectionView(section) ? makeHostingView { sectionFooterView(section) } : nil
        }

        // table's section header: on top of table for .comments, bottom for .conversation
        func sectionHeaderView(_ section: Int) -> some View {
            HeaderView(
                paginationState: paginationState,
                isFirst: section == 0,
                type: type,
                handler: chatParams.newerMessagesPaginationHandler,
                topContent: { self.sectionTopView(section) }
            )
        }

        // table's section footer: at the bottom of table for .comments, top for .conversation
        func sectionFooterView(_ section: Int) -> some View {
            FooterView(
                paginationState: paginationState,
                isLast: section == sections.count - 1,
                type: type,
                handler: chatParams.olderMessagesPaginationHandler,
                topContent: { self.sectionTopView(section) }
            )
        }

        // is on top for both chat styles
        func sectionTopView(_ section: Int) -> some View {
            VStack(spacing: 0) {
                if let mainHeaderBuilder,
                    (section == 0 && type == .comments) ||
                    (section == sections.count - 1 && type == .conversation) {
                    mainHeaderBuilder()
                }
                if chatParams.showDateHeaders {
                    dateViewBuilder(section)
                }
            }
        }

        @ViewBuilder
        func dateViewBuilder(_ section: Int) -> some View {
            if let dateHeaderBuilder {
                dateHeaderBuilder(sections[section].date)
            } else {
                Text(sections[section].formattedDate)
                    .font(.system(size: 11))
                    .padding(.top, 30)
                    .padding(.bottom, 8)
                    .foregroundColor(.gray)
            }
        }

        func makeHostingView<Content: View>(@ViewBuilder _ content: () -> Content) -> UIView? {
            let view = UIHostingController(rootView:
                content().rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
            ).view
            view?.backgroundColor = UIColor(mainBackgroundColor)
            return view
        }

        // MARK: - cells

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            tableViewCell.selectionStyle = .none
            tableViewCell.backgroundColor = UIColor(mainBackgroundColor)

            if indexPath == lastReadIndicatorIndexPath {
                tableViewCell.contentConfiguration = UIHostingConfiguration {
                    LastReadIndicatorView()
                        .rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
                }
                .minSize(width: 0, height: 0)
                .margins(.all, 0)
                return tableViewCell
            }

            let row = messageRow(at: indexPath)!
            tableViewCell.contentConfiguration = UIHostingConfiguration {
                ChatMessageView(
                    viewModel: viewModel,
                    messageBuilder: messageBuilder,
                    row: row,
                    chatType: type,
                    messageParams: messageParams,
                    isDisplayingMessageMenu: false
                )
                .background(MessageMenuPreferenceViewSetter(id: row.id))
                .rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
                .applyIf(chatParams.showMessageMenuOnLongPress) {
                    $0.simultaneousGesture(
                        TapGesture().onEnded { } // add empty tap to prevent iOS17 scroll breaking bug (drag on cells stops working)
                    )
                    .onLongPressGesture {
                        // Trigger haptic feedback
                        self.impactGenerator.impactOccurred()
                        // Launch the message menu
                        self.viewModel.messageMenuRow = row
                    }
                }
            }
            .minSize(width: 0, height: 0)
            .margins(.all, 0)

            return tableViewCell
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if updateInProgress { return }

            guard let row = messageRow(at: indexPath) else { return }
            lazy var message = row.message

            if let onWillDisplayCell = chatParams.onWillDisplayCell {
                onWillDisplayCell(message)
            }

            if !paginationState.olderInProgress,
               let messageID = olderPaginationTargetMessageID,
               message.id == messageID,
               let handler = chatParams.olderMessagesPaginationHandler,
               handler.hasMoreToLoad,
               case .cellIndex(_) = handler.triggerType {
                performOlderPagination(tableView)
            }

            if !paginationState.newerInProgress,
               let messageID = newerPaginationTargetMessageID,
               message.id == messageID,
               let handler = chatParams.newerMessagesPaginationHandler,
               handler.hasMoreToLoad,
               case .cellIndex(_) = handler.triggerType {
                performNewerPagination(tableView)
            }
        }

        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let items = type == .conversation ? chatParams.listSwipeActions.trailing : chatParams.listSwipeActions.leading else { return nil }
            guard !items.actions.isEmpty else { return nil }
            guard let row = messageRow(at: indexPath) else { return nil }
            let message = row.message
            let conf = UISwipeActionsConfiguration(actions: items.actions.filter({ $0.activeFor(message) }).map { toContextualAction($0, message: message) })
            conf.performsFirstActionWithFullSwipe = items.performsFirstActionWithFullSwipe
            return conf
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let items = type == .conversation ? chatParams.listSwipeActions.leading : chatParams.listSwipeActions.trailing else { return nil }
            guard !items.actions.isEmpty else { return nil }
            guard let row = messageRow(at: indexPath) else { return nil }
            let message = row.message
            let conf = UISwipeActionsConfiguration(actions: items.actions.filter({ $0.activeFor(message) }).map { toContextualAction($0, message: message) })
            conf.performsFirstActionWithFullSwipe = items.performsFirstActionWithFullSwipe
            return conf
        }

        private func toContextualAction(_ item: SwipeActionable, message: Message) -> UIContextualAction {
            let ca = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
                item.action(message, self.viewModel.messageMenuAction())
                completionHandler(true)
            }
            ca.image = item.render(type: type)

            let bgColor = item.background ?? mainBackgroundColor
            ca.backgroundColor = UIColor(bgColor)

            return ca
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let contentOffset = scrollView.contentOffset.y
            let maxTopOffset = scrollView.contentSize.height - scrollView.frame.height - 1

            chatParams.onContentOffsetChange?(contentOffset)
            isScrolledToBottom = contentOffset <= 0
            isScrolledToTop = contentOffset >= maxTopOffset

            guard !sections.isEmpty, !updateInProgress else { return }

            if !paginationState.olderInProgress,
               let handler = chatParams.olderMessagesPaginationHandler,
               handler.hasMoreToLoad,
               case let .pixels(offset) = handler.triggerType,
               contentOffset >= maxTopOffset,
               let tableView = scrollView as? UITableView {
                performOlderPagination(tableView)
            }

            //print(contentOffset, sections.count)

            if !paginationState.newerInProgress,
               let handler = chatParams.newerMessagesPaginationHandler,
               handler.hasMoreToLoad,
               case let .pixels(offset) = handler.triggerType,
               contentOffset <= offset,
               let tableView = scrollView as? UITableView {
                performNewerPagination(tableView)
            }
        }

        func performOlderPagination(_ tableView: UITableView) {
            if let handler = chatParams.olderMessagesPaginationHandler {
                Task { @MainActor in
                    tableView.beginUpdates()
                    paginationState.olderInProgress = true
                    tableView.endUpdates()
                    tableView.relayoutHeadersFooters()
                    await handler.handleClosure()
                    // set olderInProgress to false after table update is complete
                }
            }
        }

        func performNewerPagination(_ tableView: UITableView) {
            if let handler = chatParams.newerMessagesPaginationHandler {
                paginationState.newerInProgress = true
                Task { @MainActor in
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    tableView.relayoutHeadersFooters()
                    await handler.handleClosure()
                    // set newerInProgress to false after table update is complete
                }
            }
        }
    }

    func formatRow(_ row: MessageRow) -> String {
        String(
            "id: \(row.id) text: \(String(row.message.attributedText.characters)) status: \(row.message.status ?? .none) date: \(row.message.createdAt) position in user group: \(row.positionInUserGroup) position in messages section: \(row.positionInMessagesSection) trigger: \(row.message.triggerRedraw)"
        )
    }

    func formatSections(_ sections: [MessagesSection]) -> String {
        var res = "(\(sections.count))(\(sections.map{$0.rows.count})){\n"
        for section in sections.reversed() {
            res += String("\t{\n")
            for row in section.rows {
                res += String("\t\t\(formatRow(row))\n")
            }
            res += String("\t}\n")
        }
        res += String("}")
        return res
    }
}
