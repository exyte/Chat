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

struct UIList<MessageContent: View>: UIViewRepresentable {

    typealias MessageBuilderClosure = ChatView<MessageContent, EmptyView>.MessageBuilderClosure

    @Environment(\.chatTheme) private var theme

    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var paginationState: PaginationState

    @Binding var showScrollToBottom: Bool

    var messageBuilder: MessageBuilderClosure?

    let avatarSize: CGFloat
    let messageUseMarkdown: Bool
    let sections: [MessagesSection]
    let ids: [String]

    private let updatesQueue = DispatchQueue(label: "updatesQueue")
    @State private var updateSemaphore = DispatchSemaphore(value: 1)
    @State private var tableSemaphore = DispatchSemaphore(value: 0)

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.transform = CGAffineTransform(rotationAngle: .pi)

        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor(theme.colors.mainBackground)

        NotificationCenter.default.addObserver(forName: .onScrollToBottom, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                if !context.coordinator.sections.isEmpty {
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
            }
        }

        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        updatesQueue.async {
            updateSemaphore.wait()

            let prevSections = context.coordinator.sections
            var editedSections = [MessagesSection]()

            DispatchQueue.main.async {
                tableView.performBatchUpdates {
                    // step 1
                    // check only sections that are already in the table for existing rows that changed and apply only them to table's dataSource without animation
                    editedSections = applyEdits(tableView: tableView, prevSections: prevSections)
                    context.coordinator.sections = editedSections
                } completion: { _ in
                    tableSemaphore.signal()
                }
            }
            tableSemaphore.wait()

            if !showScrollToBottom {
                DispatchQueue.main.sync {
                    // step 2
                    // apply the rest of the changes to table's dataSource
                    context.coordinator.sections = sections
                    context.coordinator.ids = ids
                    // insert new rows/sections and remove old ones with animation
                    tableView.beginUpdates()
                    applyInserts(tableView: tableView, prevSections: editedSections)
                    tableView.endUpdates()

                    updateSemaphore.signal()
                }
            } else {
                updateSemaphore.signal()
            }
        }
    }

    func applyEdits(tableView: UITableView, prevSections: [MessagesSection]) -> [MessagesSection] {
        var result = [MessagesSection]()
        let prevDates = prevSections.map { $0.date }
        for iPrevDate in 0..<prevDates.count {
            let prevDate = prevDates[iPrevDate]
            guard let section = sections.first(where: { $0.date == prevDate } ),
                  let prevSection = prevSections.first(where: { $0.date == prevDate } ) else { continue }

            var resultRows = [MessageRow]()
            for iPrevRow in 0..<prevSection.rows.count {
                let prevRow = prevSection.rows[iPrevRow]
                guard let row = section.rows.first(where: { $0.message.id == prevRow.message.id } ) else { continue }
                resultRows.append(row)

                if row != prevRow {
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [IndexPath(row: iPrevRow, section: iPrevDate)], with: .none)
                    }
                }
            }
            result.append(MessagesSection(date: prevDate, rows: resultRows))
        }
        return result
    }

    func applyInserts(tableView: UITableView, prevSections: [MessagesSection]) {
        // compare sections without comparing messages inside them, just dates
        let dates = sections.map { $0.date }
        let coordinatorDates = prevSections.map { $0.date }

        let dif = dates.difference(from: coordinatorDates)
        for change in dif {
            switch change {
            case let .remove(offset, _, _):
                tableView.deleteSections([offset], with: .top)
            case let .insert(offset, _, _):
                tableView.insertSections([offset], with: .top)
            }
        }

        // compare rows for each section
        for section in sections {
            guard let index = prevSections.firstIndex(where: { $0.date == section.date } ) else { continue }
            let dif = section.rows.difference(from: prevSections[index].rows)

            // animate insertions and removals
            for change in dif {
                switch change {
                case let .remove(offset, _, _):
                    tableView.deleteRows(at: [IndexPath(row: offset, section: index)], with: .top)
                case let .insert(offset, _, _):
                    tableView.insertRows(at: [IndexPath(row: offset, section: index)], with: .top)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator<MessageContent> {
        Coordinator(viewModel: viewModel, paginationState: paginationState, showScrollToBottom: $showScrollToBottom, messageBuilder: messageBuilder, avatarSize: avatarSize, messageUseMarkdown: messageUseMarkdown, sections: sections, ids: ids, mainBackgroundColor: theme.colors.mainBackground)
    }

    class Coordinator<MessageContent: View>: NSObject, UITableViewDataSource, UITableViewDelegate {

        @ObservedObject var viewModel: ChatViewModel
        @ObservedObject var paginationState: PaginationState

        @Binding var showScrollToBottom: Bool

        var messageBuilder: MessageBuilderClosure?

        let avatarSize: CGFloat
        let messageUseMarkdown: Bool
        var sections: [MessagesSection]
        var ids: [String]

        let mainBackgroundColor: Color

        init(viewModel: ChatViewModel, paginationState: PaginationState, showScrollToBottom: Binding<Bool>, messageBuilder: MessageBuilderClosure?, avatarSize: CGFloat, messageUseMarkdown: Bool, sections: [MessagesSection], ids: [String], mainBackgroundColor: Color) {
            self.viewModel = viewModel
            self.paginationState = paginationState
            self._showScrollToBottom = showScrollToBottom
            self.messageBuilder = messageBuilder
            self.avatarSize = avatarSize
            self.messageUseMarkdown = messageUseMarkdown
            self.sections = sections
            self.ids = ids
            self.mainBackgroundColor = mainBackgroundColor
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            sections.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            sections[section].rows.count
        }

        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let header = UIHostingController(rootView:
                Text(sections[section].formattedDate)
                    .rotationEffect(Angle(degrees: 180))
                    .padding(10)
                    .foregroundColor(.gray)
            ).view
            header?.backgroundColor = UIColor(mainBackgroundColor)
            return header
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            0.1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            tableViewCell.selectionStyle = .none
            tableViewCell.backgroundColor = UIColor(mainBackgroundColor)

            let row = sections[indexPath.section].rows[indexPath.row]
            tableViewCell.contentConfiguration = UIHostingConfiguration {
                ChatMessageView(viewModel: viewModel, messageBuilder: messageBuilder, row: row, avatarSize: avatarSize, messageUseMarkdown: messageUseMarkdown, isDisplayingMessageMenu: false)
                    .background(MessageMenuPreferenceViewSetter(id: row.id))
                    .rotationEffect(Angle(degrees: 180))
                    .onTapGesture { }
                    .onLongPressGesture {
                        self.viewModel.messageMenuRow = row
                    }
            }
            .minSize(width: 0, height: 0)
            .margins(.all, 0)

            return tableViewCell
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let row = sections[indexPath.section].rows[indexPath.row]
            paginationState.handle(row.message, ids: ids)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            showScrollToBottom = scrollView.contentOffset.y > 0
        }
    }
}
