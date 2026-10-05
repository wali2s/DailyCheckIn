//
//  ShareSheet.swift
//  DailyCheckIn
//
//  Created by Wahid on 04.09.26.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    let onCompletion: ((Bool) -> Void)?

    init(
        items: [Any],
        onCompletion: ((Bool) -> Void)? = nil
    ) {
        self.items = items
        self.onCompletion = onCompletion
    }

    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController {
        let activityViewController =
            UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )

        activityViewController.completionWithItemsHandler = {
            _, completed, _, _ in

            onCompletion?(completed)
        }

        return activityViewController
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
