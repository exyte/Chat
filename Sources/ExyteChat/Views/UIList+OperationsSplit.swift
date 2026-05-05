//
//  UIList+Split.swift
//  Chat
//
//  Created by Alisa Mylnikova on 05.05.2026.
//

extension UIList {
    struct SplitInfo: @unchecked Sendable {
        let appliedDeletes: [MessagesSection]
        let appliedDeletesSwapsAndEdits: [MessagesSection]
        let deleteOperations: [Operation]
        let swapOperations: [Operation]
        let editOperations: [Operation]
        let insertOperations: [Operation]

        static func operationsSplit(oldSections: [MessagesSection], newSections: [MessagesSection]) -> SplitInfo {
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

        static func swapsContain(swaps: [Operation], section: Int, index: Int) -> Bool {
            swaps.filter {
                if case let .swap(section, rowFrom, rowTo) = $0 {
                    return section == section && (rowFrom == index || rowTo == index)
                }
                return false
            }.count > 0
        }
    }
}
