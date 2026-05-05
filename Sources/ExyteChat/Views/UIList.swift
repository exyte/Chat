//
//  UIList.swift
//  
//
//  Created by Alisa Mylnikova on 24.02.2023.
//

import SwiftUI
import Combine

public extension Notification.Name {
    static let onScrollToBottom = Notification.Name("onScrollToBottom")
}

struct UIList<MessageContent: View>: UIViewRepresentable {

    typealias MessageBuilderParamsClosure = ChatView<MessageContent, InputView, DefaultMessageMenuAction>.MessageBuilderParamsClosure

    @Environment(\.chatTheme) var theme

    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var inputViewModel: InputViewModel

    @Binding var isScrolledToBottom: Bool
    @Binding var shouldScrollToTop: () -> ()
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
    @Binding var timeViewWidth: CGFloat
    @Binding var reactionViewWidth: CGFloat

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
        tableView.backgroundColor = UIColor(theme.colors.mainBG)
        tableView.scrollsToTop = false
        tableView.isScrollEnabled = chatParams.isScrollEnabled
        tableView.keyboardDismissMode = chatParams.keyboardDismissMode
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.tableHeaderView = nil
        tableView.tableFooterView = UIView(frame: .zero)

        NotificationCenter.default.addObserver(forName: .onScrollToBottom, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                if !context.coordinator.sections.isEmpty {
                    guard tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 else { return }
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
            }
        }

        DispatchQueue.main.async {
            shouldScrollToTop = {
                tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height), animated: false)
            }
        }

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

        let needToUpdateSections = context.coordinator.latestUpdateSections != sections
        let needToScroll = chatParams.scrollToParams != nil && context.coordinator.latestUpdateScrollTo != chatParams.scrollToParams

        if needToUpdateSections || needToScroll {
            updateQueue.didPerformRealUpdate = true
        } else {
            return
        }

        context.coordinator.latestUpdateSections = sections
        context.coordinator.latestUpdateScrollTo = chatParams.scrollToParams

        print("changes needToUpdateSections: \(needToUpdateSections), needToScroll: \(needToScroll), chatParams.scrollToParams: \(chatParams.scrollToParams)")

        updateQueue.createJob {
            Task { @MainActor in
                context.coordinator.updateInProgress = true
                //await updateQueue.enqueue() {
                if !transaction.animated { UIView.setAnimationsEnabled(false) }

                if needToUpdateSections {
                    // if we're gonna scroll later, then update cells without animation, and animate scrolling later
                    let animateTableUpdate = transaction.animated && chatParams.scrollToParams == nil
                    await updateIfNeeded(coordinator: context.coordinator, tableView: tableView, animated: animateTableUpdate)
                }

                let perform = {
                    if let scrollToParams = chatParams.scrollToParams {
                        performScrollTo(tableView, scrollToParams: scrollToParams)
                    }
                }

                if transaction.animated {
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

                if !transaction.animated { UIView.setAnimationsEnabled(true) }

                context.coordinator.updateInProgress = false
                context.coordinator.paginationState.olderInProgress = false
                context.coordinator.paginationState.newerInProgress = false
            }
        }
    }

    func performScrollTo(_ tableView: UITableView, scrollToParams: ScrollToParams) {
        switch scrollToParams.scrollTo {
        case .messageID(let messageID, let position, let offset):
            scrollToRow(tableView, messageID: messageID, position: position, additionalOffset: offset)
        case .tableOffset(let offset):
            tableView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
        }
    }

    @MainActor
    func scrollToRow(_ tableView: UITableView, messageID: String, position: UITableView.ScrollPosition, additionalOffset: CGFloat) {
        guard let indexPath = indexPath(for: messageID, in: sections),
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

    func indexPath(for id: String, in sections: [MessagesSection]) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            if let rowIndex = section.rows.firstIndex(where: { $0.message.id == id }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }

    @MainActor
    private func updateIfNeeded(coordinator: Coordinator, tableView: UITableView, animated: Bool) async {
        if coordinator.sections == sections {
            return
        }

        if coordinator.sections.isEmpty {
            coordinator.sections = sections

            tableView.reloadData()

            if !chatParams.isScrollEnabled {
                DispatchQueue.main.async {
                    tableContentHeight = tableView.contentSize.height
                }
            }

            return
        }

        let prevSections = coordinator.sections
        //print("0 whole sections:", runID, "\n")
        //print("whole previous:\n", formatSections(prevSections), "\n")
        let splitInfo = await performSplitInBackground(prevSections, sections)
        await applyUpdatesToTable(tableView, splitInfo: splitInfo, animated: animated) {
            coordinator.sections = $0
        }
    }

    nonisolated private func performSplitInBackground(_ prevSections: [MessagesSection], _ sections: [MessagesSection]) async -> SplitInfo {
        await withCheckedContinuation { continuation in
            Task.detached {
                let result = SplitInfo.operationsSplit(oldSections: prevSections, newSections: sections)
                continuation.resume(returning: result)
            }
        }
    }

    @MainActor
    private func applyUpdatesToTable(_ tableView: UITableView, splitInfo: SplitInfo, animated: Bool, updateContextClosure: ([MessagesSection])->()) async {
        if shouldFallbackToFullReload(splitInfo: splitInfo) {
            updateContextClosure(sections)
            UIView.performWithoutAnimation {
                tableView.reloadData()
                tableView.layoutIfNeeded()
            }

            if !chatParams.isScrollEnabled {
                tableContentHeight = tableView.contentSize.height
            }
            return
        }

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
            // delete sections and rows if necessary
            //print("1 apply deletes", runID)
            updateContextClosure(splitInfo.appliedDeletes)
            //context.coordinator.sections = appliedDeletes
            for operation in splitInfo.deleteOperations {
                applyOperation(operation, tableView: tableView, animated: animated)
            }
        }
        //print("1 finished deletes", runID)

        await performBatchTableUpdates(tableView) {
            // step 2: swaps
            // swap places for rows that moved inside the table
            // (example of how this happens. send two messages: first m1, then m2. if m2 is delivered to server faster, then it should jump above m1 even though it was sent later)
            //print("2 apply swaps", runID)
            updateContextClosure(splitInfo.appliedDeletesSwapsAndEdits) // NOTE: this array already contains necessary edits, but won't be a problem for appplying swaps
            for operation in splitInfo.swapOperations {
                applyOperation(operation, tableView: tableView, animated: animated)
            }
        }
        //print("2 finished swaps", runID)

        await performBatchTableUpdates(tableView) {
            // step 3: edits
            // check only sections that are already in the table for existing rows that changed and apply only them to table's dataSource without animation
            //print("3 apply edits", runID)
            updateContextClosure(splitInfo.appliedDeletesSwapsAndEdits)

            for operation in splitInfo.editOperations {
                applyOperation(operation, tableView: tableView, animated: false)
            }
        }
        //print("3 finished edits", runID)

        // step 4: inserts
        // apply the rest of the changes to table's dataSource, i.e. inserts
        //print("4 apply inserts", runID)
        updateContextClosure(sections)

        if animated, isScrolledToBottom || isScrolledToTop {
            await performBatchTableUpdates(tableView) {
                for operation in splitInfo.insertOperations {
                    applyOperation(operation, tableView: tableView, animated: animated)
                }
            }
        } else {
            UIView.setAnimationsEnabled(false)
            for operation in splitInfo.insertOperations {
                applyOperation(operation, tableView: tableView, animated: false)
            }
            //UIView.setAnimationsEnabled(true)
        }
        //print("4 finished inserts", runID)


        tableView.relayoutHeadersFooters()

        if !chatParams.isScrollEnabled {
            tableContentHeight = tableView.contentSize.height
        }
    }

    private func shouldFallbackToFullReload(splitInfo: SplitInfo) -> Bool {
        let hasSectionOperations =
            splitInfo.deleteOperations.contains(where: isSectionOperation)
            || splitInfo.insertOperations.contains(where: isSectionOperation)

        if hasSectionOperations {
            return true
        }

        // Diff-based row inserts are only stable at the live edges in this inverted table setup.
        if !splitInfo.insertOperations.isEmpty && !(isScrolledToBottom || isScrolledToTop) {
            return true
        }

        return false
    }

    private func isSectionOperation(_ operation: Operation) -> Bool {
        switch operation {
        case .deleteSection, .insertSection:
            return true
        case .delete, .insert, .swap, .edit:
            return false
        }
    }

    // MARK: - Operations

    enum Operation {
        case deleteSection(Int)
        case insertSection(Int)

        case delete(Int, Int) // delete with animation
        case insert(Int, Int) // insert with animation
        case swap(Int, Int, Int) // delete first with animation, then insert it into new position with animation. do not do anything with the second for now
        case edit(Int, Int) // reload the element without animation

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
            }
        }
    }

    func applyOperation(_ operation: Operation, tableView: UITableView, animated: Bool) {
        let animation: UITableView.RowAnimation = animated ? .top : .none
        switch operation {
        case .deleteSection(let section):
            tableView.deleteSections([section], with: animation)
        case .insertSection(let section):
            tableView.insertSections([section], with: animation)
        case .delete(let section, let row):
            tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: animation)
        case .insert(let section, let row):
            tableView.insertRows(at: [IndexPath(row: row, section: section)], with: animation)
        case .edit(let section, let row):
            tableView.reconfigureRows(at: [IndexPath(row: row, section: section)])
        case .swap(let section, let rowFrom, let rowTo):
            tableView.deleteRows(at: [IndexPath(row: rowFrom, section: section)], with: animation)
            tableView.insertRows(at: [IndexPath(row: rowTo, section: section)], with: animation)
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
            timeViewWidth: $timeViewWidth,
            reactionViewWidth: $reactionViewWidth,
            mainBackgroundColor: theme.colors.mainBG
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

        let chatParams: ChatCustomizationParameters
        let messageParams: MessageCustomizationParameters
        @Binding var timeViewWidth: CGFloat
        @Binding var reactionViewWidth: CGFloat
        let mainBackgroundColor: Color

        var updateInProgress: Bool = false
        /// call pagination handler when this row is reached
        /// without this there is a bug: during new cells insertion willDisplay is called one extra time for the cell which used to be the last one while it is being updated (its position in group is changed from first to middle)
        var olderPaginationTargetMessageID: String?
        var newerPaginationTargetMessageID: String?
        let paginationState = PaginationState()

        // helpers to avoid queueing same updates multiple times
        var latestUpdateSections: [MessagesSection]?
        var latestUpdateScrollTo: ScrollToParams?

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
            timeViewWidth: Binding<CGFloat>,
            reactionViewWidth: Binding<CGFloat>,
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
            self._timeViewWidth = timeViewWidth
            self._reactionViewWidth = reactionViewWidth
            self.mainBackgroundColor = mainBackgroundColor
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            sections.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            sections[section].rows.count
        }

        // MARK: - headers/footers

//        func hasHeaderForSection(_ section: Int) -> Bool {
//            chatParams.showDateHeaders
//            || (section == 0 && mainHeaderBuilder == nil)
//            || (section == sections.count - 1 && chatParams.olderMessagesPaginationHandler != nil)
//            || (section == 0 && chatParams.newerMessagesPaginationHandler != nil)
//        }

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

            let row = sections[indexPath.section].rows[indexPath.row]
            tableViewCell.contentConfiguration = UIHostingConfiguration {
                ChatMessageView(
                    viewModel: viewModel,
                    messageBuilder: messageBuilder,
                    row: row,
                    chatType: type,
                    messageParams: messageParams,
                    timeViewWidth: $timeViewWidth,
                    reactionViewWidth: $reactionViewWidth,
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

            lazy var message = sections[indexPath.section].rows[indexPath.row].message
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
            let message = sections[indexPath.section].rows[indexPath.row].message
            let conf = UISwipeActionsConfiguration(actions: items.actions.filter({ $0.activeFor(message) }).map { toContextualAction($0, message: message) })
            conf.performsFirstActionWithFullSwipe = items.performsFirstActionWithFullSwipe
            return conf
        }

        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let items = type == .conversation ? chatParams.listSwipeActions.leading : chatParams.listSwipeActions.trailing else { return nil }
            guard !items.actions.isEmpty else { return nil }
            let message = sections[indexPath.section].rows[indexPath.row].message
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

            if updateInProgress { return }

            if !paginationState.olderInProgress,
               let handler = chatParams.olderMessagesPaginationHandler,
               handler.hasMoreToLoad,
               case let .pixels(offset) = handler.triggerType,
               contentOffset <= offset,
               let tableView = scrollView as? UITableView {
                performOlderPagination(tableView)
            }

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
                    paginationState.olderInProgress = true
                    tableView.relayoutHeadersFooters()
                    await handler.handleClosure()
                    // set olderInProgress to false after table update is complete
                }
            }
        }

        func performNewerPagination(_ tableView: UITableView) {
            if let handler = chatParams.newerMessagesPaginationHandler {
                Task { @MainActor in
                    paginationState.newerInProgress = true
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
