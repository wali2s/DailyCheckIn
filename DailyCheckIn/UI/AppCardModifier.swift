//
//  AppCardModifier.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct AppCardModifier: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let padding: CGFloat

    init(
        backgroundColor: Color = AppColors.surface,
        cornerRadius: CGFloat = AppCornerRadius.standard,
        padding: CGFloat = AppSpacing.cardPadding
    ) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    func body(
        content: Content
    ) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: cornerRadius,
                    style: .continuous
                )
                .stroke(
                    Color.white.opacity(0.72),
                    lineWidth: 1
                )
            }
            .shadow(
                color: Color(
                    red: 0.42,
                    green: 0.35,
                    blue: 0.25
                )
                .opacity(0.055),
                radius: 14,
                x: 0,
                y: 7
            )
            .shadow(
                color: Color.white.opacity(0.80),
                radius: 2,
                x: 0,
                y: -1
            )
    }
}

extension View {
    func appCardStyle(
        backgroundColor: Color = AppColors.surface,
        cornerRadius: CGFloat = AppCornerRadius.standard,
        padding: CGFloat = AppSpacing.cardPadding
    ) -> some View {
        modifier(
            AppCardModifier(
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                padding: padding
            )
        )
    }
}
