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
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 12,
                x: 0,
                y: 6
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
