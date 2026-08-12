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
                minHeight: 50
            )
            .background(backgroundColor)
            .clipShape(
                Capsule()
            )
            .opacity(
                configuration.isPressed ? 0.82 : 1.0
            )
            .scaleEffect(
                configuration.isPressed ? 0.98 : 1.0
            )
            .animation(
                .easeOut(duration: 0.15),
                value: configuration.isPressed
            )
    }
}
