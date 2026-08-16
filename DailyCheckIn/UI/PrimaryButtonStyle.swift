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
            .font(.system(
                size: 17,
                weight: .semibold,
                design: .rounded
            ))
            .foregroundStyle(.white)
            .frame(
                maxWidth: .infinity,
                minHeight: 54
            )
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(
                        Color.black.opacity(0.04),
                        lineWidth: 1
                    )
            }
            .opacity(
                configuration.isPressed ? 0.88 : 1.0
            )
            .scaleEffect(
                configuration.isPressed ? 0.985 : 1.0
            )
            .animation(
                .easeOut(duration: 0.16),
                value: configuration.isPressed
            )
    }
}
