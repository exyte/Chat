//
//  UIList+Queue.swift
//  Chat
//
//  Created by Alisa Mylnikova on 05.05.2026.
//

import Foundation

actor UpdateQueue {
    private struct Job {
        let work: @Sendable @MainActor () async -> Void
        let continuation: CheckedContinuation<Void, Never>
        var transactionContinuation: CheckedContinuation<Void, Never>?
    }

    private var queue: [Job] = []
    private var isProcessing = false

    var didPerformRealUpdate = false

    // MARK: - Debug

    private func debug(_ prefix: String) {
//        print("""
//        \(prefix)
//          queue.count = \(queue.count)
//          isProcessing = \(isProcessing)
//          didPerformRealUpdate = \(didPerformRealUpdate)
//        """)
    }

    // MARK: - Transaction

    func beginTransaction() {
        print("UpdateQueue beginTransaction")
        didPerformRealUpdate = false
        debug("after beginTransaction")
    }

    func waitForTransactionToFinish() async {
        print("UpdateQueue waitForTransactionToFinish")

        await withCheckedContinuation { continuation in
            Task { await self.attachToLastJob(continuation) }
        }
    }

    private func attachToLastJob(_ continuation: CheckedContinuation<Void, Never>) {
        print("UpdateQueue attachToLastJob")

        if !queue.isEmpty {
            let index = queue.count - 1
            queue[index].transactionContinuation = continuation
            debug("attached transaction to job \(index)")
        } else {
            // nothing yet → wait until job appears
            Task {
                while true {
                    if !self.queue.isEmpty {
                        await self.attachToLastJob(continuation)
                        return
                    }
                    await Task.yield()
                }
            }
        }
    }

    func finishEarlyIfNeeded() {
        print("UpdateQueue finishEarlyIfNeeded \(didPerformRealUpdate)")
        debug("before finishEarlyIfNeeded")

        if didPerformRealUpdate == false {
            didPerformRealUpdate = true
        }
    }

    // MARK: - Job creation (THIS is where continuation is created)

    func createJob(_ work: @escaping @Sendable () async -> Void) {
        print("UpdateQueue createJob")

        Task {
            await withCheckedContinuation { continuation in
                let job = Job(
                    work: work,
                    continuation: continuation,
                    transactionContinuation: nil
                )

                queue.append(job)

                debug("after createJob")

                processNextIfNeeded()
            }
        }
    }

    // MARK: - Processing

    private func processNextIfNeeded() {
        guard !isProcessing, !queue.isEmpty else {
            debug("processNextIfNeeded skipped")
            return
        }

        isProcessing = true

        print("UpdateQueue start job")
        debug("before job")

        Task {
            let work = await self.queue[0].work

            await work()

            await self.completeCurrentJob()
        }
    }

    private func completeCurrentJob() {
        print("UpdateQueue completeCurrentJob")

        var job = queue.removeFirst()

        // ✅ resume job continuation
        job.continuation.resume()

        // ✅ resume ONLY this job's transaction
        if let transaction = job.transactionContinuation {
            print("UpdateQueue → resuming transaction")
            transaction.resume()
        }

        didPerformRealUpdate = true
        isProcessing = false

        debug("after completeCurrentJob")

        processNextIfNeeded()
    }
}

public final class TableUpdateTransaction {
    var updateQueue: UpdateQueue?
    var animated: Bool = true

    @MainActor
    public func callAsFunction(animated: Bool = true, _ updates: @MainActor @escaping () -> Void) async {
        self.animated = animated
        //print("TableUpdateTransaction callAsFunction")
        await updateQueue?.beginTransaction()

        await MainActor.run {
            updates()
        }

        // This runs AFTER SwiftUI had a chance to react
        DispatchQueue.main.async {
            Task {
                //print("TableUpdateTransaction finishIfNeeded sssssss")
                await self.updateQueue?.finishEarlyIfNeeded()
            }
        }

        await updateQueue?.waitForTransactionToFinish()

        //print("TableUpdateTransaction completed")
    }
}
