//
//  UIList.swift
//  
//
//  Created by Alisa Mylnikova on 24.02.2023.
//

import SwiftUI

public extension Notification.Name {
    static let onScrollToBottom = Notification.Name("onScrollToBottom")
}

struct UIList<MessageContent: View, InputView: View>: UIViewRepresentable {

    typealias MessageBuilderClosure = ChatView<MessageContent, InputView, DefaultMessageMenuAction>.MessageBuilderClosure

    @Environment(\.chatTheme) var theme

    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var inputViewModel: InputViewModel

    @Binding var isScrolledToBottom: Bool
    @Binding var shouldScrollToTop: () -> ()
    @Binding var tableContentHeight: CGFloat

    var messageBuilder: MessageBuilderClosure?
    var mainHeaderBuilder: (()->AnyView)?
    var headerBuilder: ((Date)->AnyView)?
    var inputView: InputView

    let type: ChatType
    let showDateHeaders: Bool
    let isScrollEnabled: Bool
    let avatarSize: CGFloat
    let showMessageMenuOnLongPress: Bool
    let tapAvatarClosure: ChatView.TapAvatarClosure?
    let paginationHandler: PaginationHandler?
    let messageStyler: (String) -> AttributedString
    let shouldShowLinkPreview: (URL) -> Bool
    let showMessageTimeView: Bool
    let messageLinkPreviewLimit: Int
    let messageFont: UIFont
    let sections: [MessagesSection]
    let ids: [String]
    let listSwipeActions: ListSwipeActions
    let keyboardDismissMode: UIScrollView.KeyboardDismissMode

    @State var isScrolledToTop = false
    @State var updateQueue = UpdateQueue()

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
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
        tableView.isScrollEnabled = isScrollEnabled
        tableView.keyboardDismissMode = keyboardDismissMode
        // Reduced content inset for tighter spacing (becomes bottom due to 180° rotation)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)

        NotificationCenter.default.addObserver(forName: .onScrollToBottom, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                if !context.coordinator.sections.isEmpty {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
            }
        }

        DispatchQueue.main.async {
            shouldScrollToTop = {
                tableView.contentOffset = CGPoint(x: 0, y: tableView.contentSize.height - tableView.frame.height)
            }
        }

        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        if !isScrollEnabled {
            DispatchQueue.main.async {
                tableContentHeight = tableView.contentSize.height
            }
        }

        if context.coordinator.sections == sections {
            return
        }

        Task {
            await updateQueue.enqueue() {
                await updateIfNeeded(coordinator: context.coordinator, tableView: tableView)
            }
        }
    }

    @MainActor
    private func updateIfNeeded(coordinator: Coordinator, tableView: UITableView) async {
        if coordinator.sections == sections {
            return
        }

        if coordinator.sections.isEmpty {
            coordinator.sections = sections
            tableView.reloadData()
            if !isScrollEnabled {
                DispatchQueue.main.async {
                    tableContentHeight = tableView.contentSize.height
                }
            }
            return
        }
        
        // PERFORMANCE FIX: Fast path for single message addition (most common case)
        let oldTotalRows = coordinator.sections.reduce(0) { $0 + $1.rows.count }
        let newTotalRows = sections.reduce(0) { $0 + $1.rows.count }
        
        if newTotalRows == oldTotalRows + 1 && sections.count >= coordinator.sections.count {
            if sections.count == coordinator.sections.count {
                // New message in existing section
                if sections[0].rows.count == coordinator.sections[0].rows.count + 1 {
                    coordinator.sections = sections
                    if let lastSection = sections.last {
                        coordinator.paginationTargetIndexPath = IndexPath(row: lastSection.rows.count - 1, section: sections.count - 1)
                    }
                    
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                    tableView.endUpdates()
                    
                    if isScrolledToBottom {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if !coordinator.sections.isEmpty {
                                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                            }
                        }
                    }
                    
                    if !isScrollEnabled {
                        tableContentHeight = tableView.contentSize.height
                    }
                    return
                }
            } else if sections.count == coordinator.sections.count + 1 {
                // New date section created
                coordinator.sections = sections
                if let lastSection = sections.last {
                    coordinator.paginationTargetIndexPath = IndexPath(row: lastSection.rows.count - 1, section: sections.count - 1)
                }
                
                tableView.beginUpdates()
                tableView.insertSections([0], with: .top)
                tableView.endUpdates()
                
                if isScrolledToBottom {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if !coordinator.sections.isEmpty {
                            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                        }
                    }
                }
                
                if !isScrollEnabled {
                    tableContentHeight = tableView.contentSize.height
                }
                return
            }
        }

        if let lastSection = sections.last {
            coordinator.paginationTargetIndexPath = IndexPath(row: lastSection.rows.count - 1, section: sections.count - 1)
        }

        let prevSections = coordinator.sections
        let splitInfo = await performSplitInBackground(prevSections, sections)
        await applyUpdatesToTable(tableView, splitInfo: splitInfo) {
            coordinator.sections = $0
        }
    }

    nonisolated private func performSplitInBackground(_  prevSections:  [MessagesSection], _ sections: [MessagesSection]) async -> SplitInfo {
        await withCheckedContinuation { continuation in
            Task.detached {
                let result = operationsSplit(oldSections: prevSections, newSections: sections)
                continuation.resume(returning: result)
            }
        }
    }

    @MainActor
    private func applyUpdatesToTable(_ tableView: UITableView, splitInfo: SplitInfo, updateContextClosure: ([MessagesSection])->()) async {
        // step 0: preparation
        // prepare intermediate sections and operations
        //print("whole appliedDeletes:\n", formatSections(splitInfo.appliedDeletes), "\n")
        //print("whole appliedDeletesSwapsAndEdits:\n", formatSections(splitInfo.appliedDeletesSwapsAndEdits), "\n")
        //print("whole final sections:\n", formatSections(sections), "\n")

        //print("operations delete:\n", splitInfo.deleteOperations.map { $0.description })
        //print("operations swap:\n", splitInfo.swapOperations.map { $0.description })
        //print("operations edit:\n", splitInfo.editOperations.map { $0.description })
        //print("operations insert:\n", splitInfo.insertOperations.map { $0.description })

        await performBatchTableUpdates(tableView) {
            // step 1: deletes
            // delete sections and rows if necessary
            //print("1 apply deletes", runID)
            updateContextClosure(splitInfo.appliedDeletes)
            //context.coordinator.sections = appliedDeletes
            for operation in splitInfo.deleteOperations {
                applyOperation(operation, tableView: tableView)
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
                applyOperation(operation, tableView: tableView)
            }
        }
        //print("2 finished swaps", runID)

        UIView.setAnimationsEnabled(false)
        await performBatchTableUpdates(tableView) {
            // step 3: edits
            // check only sections that are already in the table for existing rows that changed and apply only them to table's dataSource without animation
            //print("3 apply edits", runID)
            updateContextClosure(splitInfo.appliedDeletesSwapsAndEdits)

            for operation in splitInfo.editOperations {
                applyOperation(operation, tableView: tableView)
            }
        }
        UIView.setAnimationsEnabled(true)
        //print("3 finished edits", runID)

        if isScrolledToBottom || isScrolledToTop {
            // step 4: inserts
            // apply the rest of the changes to table's dataSource, i.e. inserts
            //print("4 apply inserts", runID)
            updateContextClosure(sections)

            tableView.beginUpdates()
            for operation in splitInfo.insertOperations {
                applyOperation(operation, tableView: tableView)
            }
            tableView.endUpdates()
            //print("4 finished inserts", runID)

            if !isScrollEnabled {
                tableContentHeight = tableView.contentSize.height
            }
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

    func applyOperation(_ operation: Operation, tableView: UITableView) {
        let animation: UITableView.RowAnimation = .top
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

    private nonisolated func operationsSplit(oldSections: [MessagesSection], newSections: [MessagesSection]) -> SplitInfo {
        var appliedDeletes = oldSections // start with old sections, remove rows that need to be deleted
        var appliedDeletesSwapsAndEdits = newSections // take new sections and remove rows that need to be inserted for now, then we'll get array with all the changes except for inserts
        // appliedDeletesSwapsEditsAndInserts == newSection

        var deleteOperations = [Operation]()
        var swapOperations = [Operation]()
        var editOperations = [Operation]()
        var insertOperations = [Operation]()

        // 1 compare sections

        let oldDates = oldSections.map { $0.date }
        let newDates = newSections.map { $0.date }
        let commonDates = Array(Set(oldDates + newDates)).sorted(by: >)
        for date in commonDates {
            let oldIndex = appliedDeletes.firstIndex(where: { $0.date == date } )
            let newIndex = appliedDeletesSwapsAndEdits.firstIndex(where: { $0.date == date } )
            if oldIndex == nil, let newIndex {
                // operationIndex is not the same as newIndex because appliedDeletesSwapsAndEdits is being changed as we go, but to apply changes to UITableView we should have initial index
                if let operationIndex = newSections.firstIndex(where: { $0.date == date } ) {
                    appliedDeletesSwapsAndEdits.remove(at: newIndex)
                    insertOperations.append(.insertSection(operationIndex))
                }
                continue
            }
            if newIndex == nil, let oldIndex {
                if let operationIndex = oldSections.firstIndex(where: { $0.date == date } ) {
                    appliedDeletes.remove(at: oldIndex)
                    deleteOperations.append(.deleteSection(operationIndex))
                }
                continue
            }
            guard let newIndex, let oldIndex else { continue }

            // 2 compare section rows
            // isolate deletes and inserts, and remove them from row arrays, leaving only rows that are in both arrays: 'duplicates'
            // this will allow to compare relative position changes of rows - swaps

            var oldRows = appliedDeletes[oldIndex].rows
            var newRows = appliedDeletesSwapsAndEdits[newIndex].rows
            let oldRowIDs = oldRows.map { $0.id }
            let newRowIDs = newRows.map { $0.id }
            let rowIDsToDelete = oldRowIDs.filter { !newRowIDs.contains($0) }.reversed()
            let rowIDsToInsert = newRowIDs.filter { !oldRowIDs.contains($0) }
            for rowId in rowIDsToDelete {
                if let index = oldRows.firstIndex(where: { $0.id == rowId }) {
                    oldRows.remove(at: index)
                    deleteOperations.append(.delete(oldIndex, index)) // this row was in old section, should not be in final result
                }
            }
            for rowId in rowIDsToInsert {
                if let index = newRows.firstIndex(where: { $0.id == rowId }) {
                    // this row was not in old section, should add it to final result
                    insertOperations.append(.insert(newIndex, index))
                }
            }

            for rowId in rowIDsToInsert {
                if let index = newRows.firstIndex(where: { $0.id == rowId }) {
                    // remove for now, leaving only 'duplicates'
                    newRows.remove(at: index)
                }
            }

            // 3 isolate swaps and edits

            for i in 0..<oldRows.count {
                let oldRow = oldRows[i]
                let newRow = newRows[i]
                if oldRow.id != newRow.id { // a swap: rows in same position are not actually the same rows
                    if let index = newRows.firstIndex(where: { $0.id == oldRow.id }) {
                        if !swapsContain(swaps: swapOperations, section: oldIndex, index: i) ||
                            !swapsContain(swaps: swapOperations, section: oldIndex, index: index) {
                            swapOperations.append(.swap(oldIndex, i, index))
                        }
                    }
                } else if oldRow != newRow { // same ids om same positions but something changed - reload rows without animation
                    editOperations.append(.edit(oldIndex, i))
                }
            }

            // 4 store row changes in sections

            appliedDeletes[oldIndex].rows = oldRows
            appliedDeletesSwapsAndEdits[newIndex].rows = newRows
        }

        return SplitInfo(appliedDeletes: appliedDeletes, appliedDeletesSwapsAndEdits: appliedDeletesSwapsAndEdits, deleteOperations: deleteOperations, swapOperations: swapOperations, editOperations: editOperations, insertOperations: insertOperations)
    }

    private nonisolated func swapsContain(swaps: [Operation], section: Int, index: Int) -> Bool {
        swaps.filter {
            if case let .swap(section, rowFrom, rowTo) = $0 {
                return section == section && (rowFrom == index || rowTo == index)
            }
            return false
        }.count > 0
    }

    // MARK: - Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator(
            viewModel: viewModel, inputViewModel: inputViewModel,
            isScrolledToBottom: $isScrolledToBottom, isScrolledToTop: $isScrolledToTop,
            messageBuilder: messageBuilder, mainHeaderBuilder: mainHeaderBuilder,
            headerBuilder: headerBuilder, type: type, showDateHeaders: showDateHeaders,
            avatarSize: avatarSize, showMessageMenuOnLongPress: showMessageMenuOnLongPress,
            tapAvatarClosure: tapAvatarClosure, paginationHandler: paginationHandler,
            messageStyler: messageStyler, shouldShowLinkPreview: shouldShowLinkPreview,
            showMessageTimeView: showMessageTimeView,
            messageLinkPreviewLimit: messageLinkPreviewLimit, messageFont: messageFont,
            sections: sections, ids: ids, mainBackgroundColor: theme.colors.mainBG,
            listSwipeActions: listSwipeActions,
            keyboardDismissMode: keyboardDismissMode)
    }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {

        @ObservedObject var viewModel: ChatViewModel
        @ObservedObject var inputViewModel: InputViewModel

        @Binding var isScrolledToBottom: Bool
        @Binding var isScrolledToTop: Bool

        let messageBuilder: MessageBuilderClosure?
        let mainHeaderBuilder: (()->AnyView)?
        let headerBuilder: ((Date)->AnyView)?

        let type: ChatType
        let showDateHeaders: Bool
        let avatarSize: CGFloat
        let showMessageMenuOnLongPress: Bool
        let tapAvatarClosure: ChatView.TapAvatarClosure?
        let paginationHandler: PaginationHandler?
        let messageStyler: (String) -> AttributedString
        let shouldShowLinkPreview: (URL) -> Bool
        let showMessageTimeView: Bool
        let messageLinkPreviewLimit: Int
        let messageFont: UIFont
        var sections: [MessagesSection] {
            didSet {
                if let lastSection = sections.last {
                    paginationTargetIndexPath = IndexPath(row: lastSection.rows.count - 1, section: sections.count - 1)
                }
            }
        }
        let ids: [String]
        let mainBackgroundColor: Color
        let listSwipeActions: ListSwipeActions
        let keyboardDismissMode: UIScrollView.KeyboardDismissMode

        private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)

        init(
            viewModel: ChatViewModel, inputViewModel: InputViewModel,
            isScrolledToBottom: Binding<Bool>, isScrolledToTop: Binding<Bool>,
            messageBuilder: MessageBuilderClosure?, mainHeaderBuilder: (() -> AnyView)?,
            headerBuilder: ((Date) -> AnyView)?, type: ChatType, showDateHeaders: Bool,
            avatarSize: CGFloat, showMessageMenuOnLongPress: Bool,
            tapAvatarClosure: ChatView.TapAvatarClosure?, paginationHandler: PaginationHandler?,
            messageStyler: @escaping (String) -> AttributedString,
            shouldShowLinkPreview: @escaping (URL) -> Bool, showMessageTimeView: Bool,
            messageLinkPreviewLimit: Int, messageFont: UIFont, sections: [MessagesSection],
            ids: [String], mainBackgroundColor: Color, paginationTargetIndexPath: IndexPath? = nil,
            listSwipeActions: ListSwipeActions, keyboardDismissMode: UIScrollView.KeyboardDismissMode
        ) {
            self.viewModel = viewModel
            self.inputViewModel = inputViewModel
            self._isScrolledToBottom = isScrolledToBottom
            self._isScrolledToTop = isScrolledToTop
            self.messageBuilder = messageBuilder
            self.mainHeaderBuilder = mainHeaderBuilder
            self.headerBuilder = headerBuilder
            self.type = type
            self.showDateHeaders = showDateHeaders
            self.avatarSize = avatarSize
            self.showMessageMenuOnLongPress = showMessageMenuOnLongPress
            self.tapAvatarClosure = tapAvatarClosure
            self.paginationHandler = paginationHandler
            self.messageStyler = messageStyler
            self.shouldShowLinkPreview = shouldShowLinkPreview
            self.showMessageTimeView = showMessageTimeView
            self.messageLinkPreviewLimit = messageLinkPreviewLimit
            self.messageFont = messageFont
            self.sections = sections
            self.ids = ids
            self.mainBackgroundColor = mainBackgroundColor
            self.paginationTargetIndexPath = paginationTargetIndexPath
            self.listSwipeActions = listSwipeActions
            self.keyboardDismissMode = keyboardDismissMode
        }

        /// call pagination handler when this row is reached
        /// without this there is a bug: during new cells insertion willDisplay is called one extra time for the cell which used to be the last one while it is being updated (its position in group is changed from first to middle)
        var paginationTargetIndexPath: IndexPath?

        func numberOfSections(in tableView: UITableView) -> Int {
            sections.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            sections[section].rows.count
        }

        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            if type == .comments {
                return sectionHeaderView(section)
            }
            return nil
        }

        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            if type == .conversation {
                return sectionHeaderView(section)
            }
            return nil
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            if !showDateHeaders && (section != 0 || mainHeaderBuilder == nil) {
                return 0.1
            }
            return type == .conversation ? 0.1 : UITableView.automaticDimension
        }

        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            if !showDateHeaders && (section != 0 || mainHeaderBuilder == nil) {
                return 0.1
            }
            return type == .conversation ? UITableView.automaticDimension : 0.1
        }

        func sectionHeaderView(_ section: Int) -> UIView? {
            if !showDateHeaders && (section != 0 || mainHeaderBuilder == nil) {
                return nil
            }

            let header = UIHostingController(rootView:
                sectionHeaderViewBuilder(section)
                    .rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
            ).view
            header?.backgroundColor = UIColor(mainBackgroundColor)
            return header
        }
        
        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let items = type == .conversation ? listSwipeActions.trailing : listSwipeActions.leading else { return nil }
            guard !items.actions.isEmpty else { return nil }
            let message = sections[indexPath.section].rows[indexPath.row].message
            let conf = UISwipeActionsConfiguration(actions: items.actions.filter({ $0.activeFor(message) }).map { toContextualAction($0, message: message) })
            conf.performsFirstActionWithFullSwipe = items.performsFirstActionWithFullSwipe
            return conf
        }
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            guard let items = type == .conversation ? listSwipeActions.leading : listSwipeActions.trailing else { return nil }
            guard !items.actions.isEmpty else { return nil }
            let message = sections[indexPath.section].rows[indexPath.row].message
            let conf = UISwipeActionsConfiguration(actions: items.actions.filter({ $0.activeFor(message) }).map { toContextualAction($0, message: message) })
            conf.performsFirstActionWithFullSwipe = items.performsFirstActionWithFullSwipe
            return conf
        }
        
        private func toContextualAction(_ item: SwipeActionable, message:Message) -> UIContextualAction {
            let ca = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
                item.action(message, self.viewModel.messageMenuAction())
                completionHandler(true)
            }
            ca.image = item.render(type: type)
            
            let bgColor = item.background ?? mainBackgroundColor
            ca.backgroundColor = UIColor(bgColor)
            
            return ca
        }
        
        @ViewBuilder
        func sectionHeaderViewBuilder(_ section: Int) -> some View {
            if let mainHeaderBuilder, section == 0 {
                VStack(spacing: 0) {
                    mainHeaderBuilder()
                    dateViewBuilder(section)
                }
            } else {
                dateViewBuilder(section)
            }
        }

        @ViewBuilder
        func dateViewBuilder(_ section: Int) -> some View {
            if showDateHeaders {
                if let headerBuilder {
                    headerBuilder(sections[section].date)
                } else {
                    Text(sections[section].formattedDate)
                        .font(.system(size: 11))
                        .padding(.top, 30)
                        .padding(.bottom, 8)
                        .foregroundColor(.gray)
                }
            }
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            tableViewCell.selectionStyle = .none
            tableViewCell.backgroundColor = UIColor(mainBackgroundColor)

            let row = sections[indexPath.section].rows[indexPath.row]
            
            // Check if this is a system message (e.g., "User joined the clan")
            if row.message.user.type == .system {
                tableViewCell.contentConfiguration = UIHostingConfiguration {
                    systemMessageView(for: row.message)
                        .rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
                }
                .minSize(width: 0, height: 0)
                .margins(.all, 0)
            } else {
                tableViewCell.contentConfiguration = UIHostingConfiguration {
                    ChatMessageView(
                        viewModel: viewModel, messageBuilder: messageBuilder, row: row, chatType: type,
                        avatarSize: avatarSize, tapAvatarClosure: tapAvatarClosure,
                        messageStyler: messageStyler, shouldShowLinkPreview: shouldShowLinkPreview,
                        isDisplayingMessageMenu: false, showMessageTimeView: showMessageTimeView,
                        messageLinkPreviewLimit: messageLinkPreviewLimit, messageFont: messageFont
                    )
                    .transition(.scale)
                    .background(MessageMenuPreferenceViewSetter(id: row.id))
                    .rotationEffect(Angle(degrees: (type == .conversation ? 180 : 0)))
                    .applyIf(showMessageMenuOnLongPress) {
                        $0                        .simultaneousGesture(
                            TapGesture().onEnded { } // add empty tap to prevent iOS17 scroll breaking bug (drag on cells stops working)
                        )
                        .onLongPressGesture(minimumDuration: 0.05) {
                            // Trigger haptic feedback
                            self.impactGenerator.impactOccurred()
                            // Launch the message menu
                            self.viewModel.messageMenuRow = row
                        }
                    }
                }
                .minSize(width: 0, height: 0)
                .margins(.all, 0)
            }

            return tableViewCell
        }
        
        // System message view builder (centered, no bubble, like date headers)
        @ViewBuilder
        func systemMessageView(for message: Message) -> some View {
            let parsedMessage = parseSystemMessage(message.text)
            
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                
                if parsedMessage.hasUsername {
                    // System message with username highlighting - allow wrapping but keep words together
                    (Text(parsedMessage.username)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0, green: 0x78/255.0, blue: 1.0), // #0078FF (lighter)
                                    Color(red: 0, green: 0, blue: 1.0)           // #0000FF (darker)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    +
                    Text(parsedMessage.action)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    +
                    (parsedMessage.hasSecondUsername && parsedMessage.secondUsername != nil ?
                        Text(parsedMessage.secondUsername!)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0, green: 0x78/255.0, blue: 1.0), // #0078FF (lighter)
                                        Color(red: 0, green: 0, blue: 1.0)           // #0000FF (darker)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        : Text("")
                    )
                    +
                    (parsedMessage.remainingText != nil ?
                        Text(parsedMessage.remainingText!)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        : Text("")
                    ))
                    .multilineTextAlignment(.center)
                } else {
                    // Regular system message without username
                    Text(message.text)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
        
        // Parse system messages to extract username and action
        private func parseSystemMessage(_ text: String) -> (username: String, action: String, hasUsername: Bool, secondUsername: String?, hasSecondUsername: Bool, remainingText: String?) {
            print("🔍 EXYTE PARSING: '\(text)'")
            
            // Special handling for promotion/demotion messages: "Actor promoted/demoted Target to Role"
            if let promotedRange = text.range(of: " promoted ") {
                let actor = String(text[..<promotedRange.lowerBound])
                let afterPromoted = String(text[promotedRange.upperBound...])
                print("🔍 EXYTE PROMOTED: actor='\(actor)', afterPromoted='\(afterPromoted)'")
                
                // Find " to " to extract the target username and role
                if let toRange = afterPromoted.range(of: " to ") {
                    let target = String(afterPromoted[..<toRange.lowerBound])
                    let role = String(afterPromoted[toRange.lowerBound...]) // Include " to RoleName"
                    print("🔍 EXYTE PROMOTED RESULT: actor='\(actor)', target='\(target)', role='\(role)'")
                    
                    return (actor, " promoted ", !actor.isEmpty, target, !target.isEmpty, role)
                }
            }
            
            if let demotedRange = text.range(of: " demoted ") {
                let actor = String(text[..<demotedRange.lowerBound])
                let afterDemoted = String(text[demotedRange.upperBound...])
                print("🔍 EXYTE DEMOTED: actor='\(actor)', afterDemoted='\(afterDemoted)'")
                
                // Find " to " to extract the target username and role
                if let toRange = afterDemoted.range(of: " to ") {
                    let target = String(afterDemoted[..<toRange.lowerBound])
                    let role = String(afterDemoted[toRange.lowerBound...]) // Include " to RoleName"
                    print("🔍 EXYTE DEMOTED RESULT: actor='\(actor)', target='\(target)', role='\(role)'")
                    
                    return (actor, " demoted ", !actor.isEmpty, target, !target.isEmpty, role)
                }
            }
            
            // Standard single-username patterns
            let patterns = [
                " joined the clan",
                " left the clan",
                " was promoted",
                " was demoted",
                " was kicked",
                " created the clan",
                " accepted an invitation and joined the clan",
                " accepted a clan invite",
                " left the clan. Clan disbanded.",
                " is already in a clan",
                " has reached the maximum of",
                " is already a member"
            ]
            
            for pattern in patterns {
                if let range = text.range(of: pattern) {
                    let username = String(text[..<range.lowerBound])
                    let action = String(text[range.lowerBound...])
                    
                    // Only highlight if there's actually a username
                    let hasUsername = !username.isEmpty &&
                                    !username.lowercased().contains("a member") &&
                                    !username.lowercased().contains("member") &&
                                    username.trimmingCharacters(in: .whitespaces).count > 0
                    
                    return (username, action, hasUsername, nil, false, nil)
                }
            }
            
            return ("", text, false, nil, false, nil)
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let paginationHandler = self.paginationHandler, let paginationTargetIndexPath, indexPath == paginationTargetIndexPath else {
                return
            }

            let row = self.sections[indexPath.section].rows[indexPath.row]
            Task.detached {
                await paginationHandler.handleClosure(row.message)
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            isScrolledToBottom = scrollView.contentOffset.y <= 0
            isScrolledToTop = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height - 1
        }
    }

    func formatRow(_ row: MessageRow) -> String {
        String(
            "id: \(row.id) text: \(row.message.text) status: \(row.message.status ?? .none) date: \(row.message.createdAt) position in user group: \(row.positionInUserGroup) position in messages section: \(row.positionInMessagesSection) trigger: \(row.message.triggerRedraw)"
        )
    }

    func formatSections(_ sections: [MessagesSection]) -> String {
        var res = "{\n"
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

extension UIList {
    struct SplitInfo: @unchecked Sendable {
        let appliedDeletes: [MessagesSection]
        let appliedDeletesSwapsAndEdits: [MessagesSection]
        let deleteOperations: [Operation]
        let swapOperations: [Operation]
        let editOperations: [Operation]
        let insertOperations: [Operation]
    }
}

actor UpdateQueue {
    private var isProcessing = false

    func enqueue(_ work: @escaping @Sendable () async -> Void) async {
        while isProcessing {
            await Task.yield() // Wait for previous task to finish
        }

        isProcessing = true
        await work()
        isProcessing = false
    }
}
