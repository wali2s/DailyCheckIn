//
//  PrimaryButtonStyle.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    let backgroundColor: Color
    
    init(
        backgroundColor: Color = AppColors.accentBlue
    ) {
        self.backgroundColor = backgroundColor
    }
    
    func makeBody(
        configuration: Configuration
    ) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black)
            .frame(
                maxWidth: .infinity,
                minHeight: 52
            )
            .background(backgroundColor)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.pill,
                    style: .continuous
                )
            )
            .scaleEffect(
                configuration.isPressed ? 0.97 : 1.0
            )
            .opacity(
                configuration.isPressed ? 0.85 : 1.0
            )
            .animation(
                .easeOut(duration: 0.15),
                value: configuration.isPressed
            )
    }
}
