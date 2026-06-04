//
//  UIList+Queue.swift
//  Chat
//
//  Created by Alisa Mylnikova on 05.05.2026.
//

import Foundation

actor UpdateQueue {

    private func debug(_ prefix: String) {
//        print("""
//        \(prefix)
//          queue: \(queue.count) transactions: \(queue.map { $0.transactionContinuation != nil ? "yes" : "no" })
//          orphanTransactions: \(orphanTransactions.count) didPerformRealUpdate: \(orphanTransactions.map { $0.didPerformRealUpdate })
//        """)
    }

    private struct Job {
        let work: @Sendable @MainActor () async -> Void
        let continuation: CheckedContinuation<Void, Never>
        let transactionContinuation: CheckedContinuation<Void, Never>?
    }

    private struct PendingTransaction {
        var animationMode: TableUpdateTransaction.AnimationMode
        var continuation: CheckedContinuation<Void, Never>?
        var didPerformRealUpdate: Bool
    }

    private var queue: [Job] = []
    private var orphanTransactions: [PendingTransaction] = []
    private var isProcessing = false

    // MARK: - Transaction lifecycle

    func startTransaction(animationMode: TableUpdateTransaction.AnimationMode) {
        orphanTransactions.append(
            PendingTransaction(
                animationMode: animationMode,
                continuation: nil,
                didPerformRealUpdate: false
            )
        )
        debug("startTransaction")
    }

    func waitForTransactionToFinish() async {
        await withCheckedContinuation { continuation in

            guard let i = orphanTransactions.indices.last(where: {
                orphanTransactions[$0].continuation == nil
            }) else {
                continuation.resume()
                return
            }

            orphanTransactions[i].continuation = continuation

            debug("attachWaiter")
        }
    }

    func markRealUpdate() {
        guard let i = orphanTransactions.indices.first else { return }
        orphanTransactions[i].didPerformRealUpdate = true
        debug("markRealUpdate")
    }

    func getAnimationMode() -> TableUpdateTransaction.AnimationMode {
        guard let i = orphanTransactions.indices.first else { return .natural }
        return orphanTransactions[i].animationMode
    }

    func finishEarlyIfNeeded() {
        guard let i = orphanTransactions.indices.first else {
            debug("finishEarly skipped")
            return
        }

        if orphanTransactions[i].didPerformRealUpdate == false {
            let tx = orphanTransactions.remove(at: i)
            tx.continuation?.resume()
            debug("finishEarly")
        }
    }

    // MARK: - Job scheduling

    func createJob(_ work: @escaping @Sendable @MainActor () async -> Void) {
        Task {
            await withCheckedContinuation { jobContinuation in

                var txContinuation: CheckedContinuation<Void, Never>? = nil

                if let i = orphanTransactions.indices.first {
                    let tx = orphanTransactions.remove(at: i)
                    txContinuation = tx.continuation
                }

                queue.append(Job(
                    work: work,
                    continuation: jobContinuation,
                    transactionContinuation: txContinuation
                ))

                debug("createJob")
                processNextIfNeeded()
            }
        }
    }

    // MARK: - Execution

    private func processNextIfNeeded() {
        guard !isProcessing, !queue.isEmpty else {
            debug("processNext skipped")
            return
        }

        isProcessing = true

        Task {
            let job = queue.removeFirst()
            await job.work()
            await completeCurrentJob(job)
        }
    }

    private func completeCurrentJob(_ job: Job) async {
        job.continuation.resume()
        job.transactionContinuation?.resume()

        isProcessing = false

        debug("completeJob")

        processNextIfNeeded()
    }
}

public final class TableUpdateTransaction {
    public enum AnimationMode: Sendable {
        case none
        case keepStable // keep the visible scroll position even when cells are inserted at the beginning, effectively shifting the meaning of the current content offset
        case natural // if scrolled to bottom - insert with standard UITableView animation, if not - keep stable
    }

    var updateQueue: UpdateQueue?

    @MainActor
    public func callAsFunction(animated: Bool, _ updates: @MainActor @escaping () -> Void) async {
        await callAsFunction(animationMode: animated ? .natural : .none, updates)
    }

    @MainActor
    public func callAsFunction(animationMode: AnimationMode = .natural, _ updates: @MainActor @escaping () -> Void) async {
        //print("TableUpdateTransaction callAsFunction animationMode: \(animationMode)")
        // 1. register transaction BEFORE SwiftUI mutation
        await updateQueue?.startTransaction(animationMode: animationMode)

        // 2. perform mutation
        await MainActor.run {
            updates()
        }

        // 3. give SwiftUI a chance to call updateUIView
        DispatchQueue.main.async {
            Task {
                //print("TableUpdateTransaction finishIfNeeded")
                await self.updateQueue?.finishEarlyIfNeeded()
            }
        }

        // 4. wait until either:
        //    - job consumes transaction
        //    - or finishEarlyIfNeeded happens
        await updateQueue?.waitForTransactionToFinish()

        //print("TableUpdateTransaction completed")
    }
}
