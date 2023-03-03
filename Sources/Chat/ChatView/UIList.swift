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

struct UIList: UIViewRepresentable {

    @ObservedObject var viewModel: ChatViewModel
    let avatarSize: CGFloat
    let messageUseMarkdown: Bool

    let sections: [MessagesSection]

    let updatesQueue = DispatchQueue(label: "updatesQueue")
    @State var updateSemaphore = DispatchSemaphore(value: 1)
    @State var tableSemaphore = DispatchSemaphore(value: 0)

    func makeUIView(context: Context) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.transform = CGAffineTransform(rotationAngle: .pi)

        // these lines fix jumping of footer
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom:  0, right: 0)
        tableView.backgroundColor = .white

        NotificationCenter.default.addObserver(forName: .onScrollToBottom, object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
            }
        }

        return tableView
    }

    func updateUIView(_ tableView: UITableView, context: Context) {
        updatesQueue.async {
            updateSemaphore.wait()

            let prevSections = context.coordinator.sections
            DispatchQueue.main.async {
                tableView.performBatchUpdates {
                    // step 1
                    // check only sections that are already in the table for existing rows that changed and apply only them to table's dataSource without animation
                    applyEdits(tableView: tableView, prevSections: prevSections)
                } completion: { _ in
                    tableSemaphore.signal()
                }
            }
            tableSemaphore.wait()

            DispatchQueue.main.sync {
                // step 2
                // apply the rest of the changes to table's dataSource
                context.coordinator.sections = sections
                // insert new rows/sections and remove old ones with animation
                tableView.beginUpdates()
                applyInserts(tableView: tableView, prevSections: prevSections)
                tableView.endUpdates()

                updateSemaphore.signal()
            }
        }
    }

    func applyEdits(tableView: UITableView, prevSections: [MessagesSection]) {
        let prevDates = prevSections.map { $0.date }
        for iPrevDate in 0..<prevDates.count {
            let prevDate = prevDates[iPrevDate]
            guard let section = sections.first(where: { $0.date == prevDate } ),
                  let prevSection = prevSections.first(where: { $0.date == prevDate } ) else { continue }

            for iPrevRow in 0..<prevSection.rows.count {
                let prevRow = prevSection.rows[iPrevRow]
                guard let row = section.rows.first(where: { $0.message.id == prevRow.message.id } ) else { continue }
                if row != prevRow {
                    prevSection.rows[iPrevRow] = row

                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [IndexPath(row: iPrevRow, section: iPrevDate)], with: .none)
                    }
                }
            }
        }
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
            print()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, avatarSize: avatarSize, messageUseMarkdown: messageUseMarkdown)
    }

    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {

        @ObservedObject var viewModel: ChatViewModel
        let avatarSize: CGFloat
        let messageUseMarkdown: Bool

        var sections: [MessagesSection] = []

        init(viewModel: ChatViewModel, avatarSize: CGFloat, messageUseMarkdown: Bool) {
            self.viewModel = viewModel
            self.avatarSize = avatarSize
            self.messageUseMarkdown = messageUseMarkdown
        }

        func numberOfSections(in tableView: UITableView) -> Int {
            sections.count
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            sections[section].rows.count
        }

        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            UIHostingController(rootView:
                                    Text(sections[section].formattedDate)
                .rotationEffect(Angle(degrees: 180))
                .padding(10)
                .foregroundColor(.gray)
            ).view
        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            0.1
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            tableViewCell.selectionStyle = .none

            let row = sections[indexPath.section].rows[indexPath.row]
            tableViewCell.contentConfiguration = UIHostingConfiguration {
                MessageView(
                    viewModel: viewModel,
                    message: row.message,
                    positionInGroup: row.positionInGroup,
                    avatarSize: avatarSize,
                    messageUseMarkdown: messageUseMarkdown)
                .rotationEffect(Angle(degrees: 180))
            }
            .margins(.all, 0)

            return tableViewCell
        }
    }
}
