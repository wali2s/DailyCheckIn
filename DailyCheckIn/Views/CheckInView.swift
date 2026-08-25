//
//  CheckInView.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI

struct CheckInView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: CheckInViewModel
    
    @State private var currentStep = 0
    @State private var moodScrollPosition: Mood?
    
    // Die Timer-Variablen 'showDots' und 'hideDotsTask' werden entfernt,
    // da wir die Sichtbarkeit geometrisch steuern.
    
    let isEditing: Bool
    let onSave: (CheckIn) -> Void
    
    private let totalSteps = 4
    
    init(
        space: JournalSpace,
        existingCheckIn: CheckIn? = nil,
        onSave: @escaping (CheckIn) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: CheckInViewModel(
                space: space,
                existingCheckIn: existingCheckIn
            )
        )
        
        self.isEditing = existingCheckIn != nil
        self.onSave = onSave
    }
    
    private var accentColor: Color {
        switch viewModel.space {
        case .personal:
            return AppColors.accentMint
        case .professional:
            return AppColors.accentBlue
        }
    }
    
    private var isLastStep: Bool {
        currentStep == totalSteps - 1
    }
    
    var body: some View {
        NavigationStack {
            VStack(
                spacing: 0
            ) {
                progressIndicator

                ScrollView {
                    stepContent
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.section)
                        .padding(.bottom, AppSpacing.standard)
                }
                .scrollIndicators(.hidden)

                navigationControls
            }
            .background {
                viewModel.mood.backgroundColor
                    .ignoresSafeArea()
                    .opacity(0.7)
            }
            .animation(
                .easeInOut(duration: 0.45),
                value: viewModel.mood
            )
            .navigationTitle(
                isEditing
                ? "Edit Check-In"
                : "New Check-In"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(
            spacing: 6
        ) {
            ForEach(
                0..<totalSteps,
                id: \.self
            ) { step in
                Capsule()
                    .fill(step == currentStep ? AppColors.primaryAction.opacity(0.8) : AppColors.surfaceSecondary.opacity(0.9))
                    
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.small)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "Check-In progress"
        )
        .accessibilityValue(
            "Step \(currentStep + 1) of \(totalSteps)"
        )
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            moodStep
            
        case 1:
            metricsStep
            
        case 2:
            energyLevelStep
            
        case 3:
            reflectionStep
            
        default:
            EmptyView()
        }
    }
    
    private var moodStep: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.section
        ) {
            stepHeader(
                title: "How do you feel today?",
                subtitle: "Swipe vertically and choose the mood that fits you best.",
                systemImage: "face.smiling"
            )

            horizontalMoodCarousel
        }
    }
    
    private var horizontalMoodCarousel: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.72
            let cardHeight: CGFloat = 330
            let cardSpacing: CGFloat = 12
            let viewportWidth = geometry.size.width

            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(Mood.allCases) { mood in
                        GeometryReader { cardGeometry in
                            let cardMidX = cardGeometry.frame(in: .named("moodCarousel")).midX
                            let viewportMidX = viewportWidth / 2
                            let distance = abs(cardMidX - viewportMidX)

                            // 0 = Perfekt in der Mitte (eingerastet)
                            // 1 = Außerhalb der Mitte (wird gerade gewischt)
                            let progress = min(distance / (cardWidth + cardSpacing), 1)

                            let scale = 1 - (progress * 0.20)
                            let opacity = 1 - (progress * 0.48)

                            verticalMoodCard(
                                mood: mood,
                                isSelected: mood == viewModel.mood,
                                dragProgress: progress
                            )
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .animation(.easeOut(duration: 0.18), value: progress)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    viewModel.mood = mood
                                    moodScrollPosition = mood
                                }
                            }
                        }
                        .frame(width: cardWidth, height: cardHeight)
                        .id(mood)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, (viewportWidth - cardWidth) / 2)
            }
            .coordinateSpace(name: "moodCarousel")
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $moodScrollPosition)
            .onAppear {
                moodScrollPosition = viewModel.mood
            }
            .onChange(of: moodScrollPosition) { _, mood in
                guard let mood else { return }
                withAnimation(.easeInOut(duration: 0.35)) {
                    viewModel.mood = mood
                }
            }
        }
        .frame(height: 360)
    }
    
    // Die Timer-gesteuerte Hilfsmethode 'triggerDotsAutoDisappear' wird entfernt.
    
    
    private func verticalMoodCard(
        mood: Mood,
        isSelected: Bool,
        dragProgress: CGFloat
    ) -> some View {
       
        let dotsOpacity: Double = 1.0

        return VStack(spacing: 14) {
            Spacer()

            ZStack {
                Circle()
                    .fill(mood.backgroundColor.opacity(0.42))
                    .frame(width: 260, height: 260)
                    .blur(radius: 22)

                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 290, height: 290)
                    .mask {
                        RadialGradient(
                            colors: [
                                .black,
                                .black,
                                .black.opacity(0.42),
                                .black.opacity(0.15),
                                .clear
                            ],
                            center: .center,
                            startRadius: 90,
                            endRadius: 190
                        )
                    }
                    .cornerRadius(333)
                    .opacity(0.8)
            }
            .frame(width: 260, height: 250)

            Text(mood.title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(mood.titleColor)
                .opacity(isSelected ? 1.0 : 0.72)

            // Paginierungs-Punkte
            HStack(spacing: 6) {
                ForEach(Mood.allCases) { item in
                    Circle()
                        .fill(
                            item == mood
                            ? mood.titleColor
                            : mood.titleColor.opacity(0.25)
                        )
                        .frame(
                            width: item == mood ? 8 : 6,
                            height: item == mood ? 8 : 6
                        )
                }
            }
            .padding(.top, -6)
            .opacity(dotsOpacity) // Steuerung über dotsOpacity statt (isSelected && showDots)
            .animation(.easeInOut(duration: 0.4), value: dotsOpacity) // Sanftes Verblassen beim Anhalten

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }
    
    
    private var energyLevelStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.section){
            stepHeader(
                title: "How are you doing?",
                subtitle: "Rate your energy and stress level.",
                systemImage: "chart.bar.fill"
            )
            
            Spacer()
            
            ratingCard(
                title: "Energy",
                systemImage: "bolt.fill",
                value: $viewModel.energyLevel
            )
            
            Spacer()
            
            ratingCard(
                title: "Stress",
                systemImage: "waveform.path.ecg",
                value: $viewModel.stressLevel
            )
        }
    }
    
    private var metricsStep: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.section
        ) {
            Spacer()
            stepHeader(
                title: factorsTitle,
                subtitle: factorsSubtitle,
                systemImage: factorsSystemImage
            )
            
            FlowLayout(
                spacing: 10,
                rowSpacing: 10
            ) {
                switch viewModel.space {
                case .personal:
                    ForEach(viewModel.availablePersonalFactors) { factor in
                        personalFactorButton(factor)
                    }
                    
                case .professional:
                    ForEach(ProfessionalFactor.allCases) { factor in
                        professionalFactorButton(factor)
                    }
                }
            }
        }
    }
    
    private var factorsTitle: String {
        switch viewModel.space {
        case .personal:
            return personalFactorsTitle

        case .professional:
            return "What influenced your workday?"
        }
    }

    private var factorsSubtitle: String {
        switch viewModel.space {
        case .personal:
            return personalFactorsSubtitle

        case .professional:
            return "Select everything that applied today."
        }
    }

    private var factorsSystemImage: String {
        switch viewModel.space {
        case .personal:
            return "heart.text.square.fill"

        case .professional:
            return "briefcase.fill"
        }
    }

    private var personalFactorsTitle: String {
        switch viewModel.mood {
        case .calm:
            return "What helped you feel calm?"

        case .good:
            return "What made your day good?"

        case .happy:
            return "What contributed to your happiness?"

        case .neutral:
            return "What influenced your mood today?"

        case .sad, .angry:
            return "What is affecting you today?"
        }
    }

    private var personalFactorsSubtitle: String {
        switch viewModel.mood {
        case .calm, .good, .happy:
            return "Select everything that contributed to this feeling."

        case .neutral:
            return "Select everything that influenced your day."

        case .sad, .angry:
            return "Select everything that feels relevant right now."
        }
    }
    
    private func personalFactorButton(
        _ factor: PersonalFactor
    ) -> some View {
        let isSelected = viewModel.personalFactors.contains(factor)

        return Button {
            togglePersonalFactor(factor)
        } label: {
            factorButtonLabel(
                title: factor.title,
                systemImage: factor.systemImage,
                isSelected: isSelected,
            )
            .animation(.easeInOut(duration: 0.25), value: viewModel.mood)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(factor.title)
        .accessibilityValue(
            isSelected
            ? "Selected"
            : "Not selected"
        )
    }

    private func professionalFactorButton(
        _ factor: ProfessionalFactor
    ) -> some View {
        let isSelected = viewModel.professionalFactors.contains(factor)

        return Button {
            toggleProfessionalFactor(factor)
        } label: {
            factorButtonLabel(
                title: factor.title,
                systemImage: factor.systemImage,
                isSelected: isSelected,
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(factor.title)
        .accessibilityValue(
            isSelected
            ? "Selected"
            : "Not selected"
        )
    }

    private func factorButtonLabel(
        title: String,
        systemImage: String,
        isSelected: Bool
    ) -> some View {
        HStack(
            spacing: AppSpacing.large
        ) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(
                    isSelected
                    ? .white
                    : AppColors.primaryAction
                )

            Text(title)
                .font(.subheadline)
                .fontWeight(
                    isSelected
                    ? .bold
                    : .semibold
                )
                .foregroundStyle(
                    isSelected
                    ? .white
                    : AppColors.textPrimary
                )
                .multilineTextAlignment(.leading)

            Spacer(
                minLength: 0
            )
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 28,
            alignment: .leading
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 15)
        .background(
            isSelected
            ? AppColors.primaryAction
            : Color.white.opacity(0.7)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.pill,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: AppCornerRadius.pill,
                style: .continuous
            )
            .stroke(
                isSelected
                ? AppColors.primaryAction.opacity(0.92)
                : Color.black.opacity(0.05),
                lineWidth: 1
            )
        }
        .shadow(
            color: isSelected
            ? AppColors.primaryAction.opacity(0.18)
            : .clear,
            radius: 7,
            x: 0,
            y: 3
        )
        .animation(
            .easeInOut(duration: 0.20),
            value: isSelected
        )
    }

    private func togglePersonalFactor(
        _ factor: PersonalFactor
    ) {
        if viewModel.personalFactors.contains(factor) {
            viewModel.personalFactors.remove(factor)
        } else {
            viewModel.personalFactors.insert(factor)
        }
    }

    private func toggleProfessionalFactor(
        _ factor: ProfessionalFactor
    ) {
        if viewModel.professionalFactors.contains(factor) {
            viewModel.professionalFactors.remove(factor)
        } else {
            viewModel.professionalFactors.insert(factor)
        }
    }
    
    private var reflectionStep: some View {
        VStack(alignment: .leading, spacing: AppSpacing.section) {
            stepHeader(
                title: "How do you feel in detail?",
                subtitle: "Use the sliders for a quick check-in or write a short note.",
                systemImage: "slider.horizontal.3"
            )
            
            Picker("Input Method", selection: $viewModel.reflectionType) {
                ForEach(ReflectionInputType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)

            // Dynamische Anzeige basierend auf der Auswahl
            if viewModel.reflectionType == .sliders {
                sentimentSlidersCard
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                thoughtsCard
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.reflectionType)
    }

    private var sentimentSlidersCard: some View {
        VStack(spacing: AppSpacing.standard) {
            singleSliderRow(
                title: "Focus",
                systemImage: "brain.head.profile",
                value: $viewModel.focusLevel,
                lowLabel: "Distracted",
                highLabel: "Focused"
            )
            
            Divider().opacity(0.3)
            
            singleSliderRow(
                title: "Social Battery",
                systemImage: "battery.100.bolt",
                value: $viewModel.socialBattery,
                lowLabel: "Empty",
                highLabel: "Full"
            )
            
            Divider().opacity(0.3)
            
            singleSliderRow(
                title: "Physical Tension",
                systemImage: "figure.walk",
                value: $viewModel.physicalTension,
                lowLabel: "Tense/Tired",
                highLabel: "Relaxed"
            )
        }
        .appCardStyle(
            backgroundColor: AppColors.surface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }

    private func singleSliderRow(
        title: String,
        systemImage: String,
        value: Binding<Double>,
        lowLabel: String,
        highLabel: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(Int(value.wrappedValue.rounded()))/5")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textSecondary)
            }
            
            Slider(value: value, in: 1...5, step: 1)
                .tint(AppColors.primaryAction.opacity(0.8))
            
            HStack {
                Text(lowLabel)
                Spacer()
                Text(highLabel)
            }
            .font(.caption2)
            .foregroundStyle(AppColors.textSecondary)
        }.appCardStyle(backgroundColor: viewModel.mood.backgroundColor.opacity(0.2))
    }

    private var thoughtsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.standard) {
            Label("GDetailed Check", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            
            TextField("What's on your mind? (optional)", text: $viewModel.note, axis: .vertical)
                .font(.body)
                .textFieldStyle(.plain)
                .lineLimit(3...6)
                .padding(12)
                .background(reflectionFieldColor.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous))
                .submitLabel(.done)
        }
        .appCardStyle(
            backgroundColor: AppColors.warmCanvas,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private var reflectionPrompt: String {
        switch viewModel.mood {
        case .calm:
            return "What helped you feel calm today?"

        case .good:
            return "What went well for you today?"

        case .happy:
            return "What made you happiest today?"

        case .neutral:
            return "What stood out about your day?"

        case .sad:
            return "What do you need most right now?"

        case .angry:
            return "What would help you release some tension?"
        }
    }
    
    private var reflectionPromptCard: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Label(
                "Reflection Prompt",
                systemImage: "sparkles"
            )
            .font(.headline)
            .foregroundStyle(
                AppColors.textPrimary.opacity(0.8)
            )
            .fontWeight(.bold)
            
            Text(
                reflectionPrompt
            )
            .font(.body)
            .foregroundStyle(
                AppColors.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .appCardStyle(
            backgroundColor: viewModel.mood.backgroundColor.opacity(0.82),
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
        .frame(maxWidth: .infinity)
        .overlay {
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
            .stroke(
                viewModel.mood.titleColor.opacity(0.02),
                lineWidth: 1
            )
        }
        .shadow(
            color: viewModel.mood.titleColor.opacity(0.10),
            radius: 10,
            x: 0,
            y: 5
        )
        .animation(
            .easeInOut(duration: 0.35),
            value: viewModel.mood
        )
    }
    
    
    private func stepHeader(
        title: String,
        subtitle: String,
        systemImage: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {
            Label(
                title,
                systemImage: systemImage
            )
            .font(.system(
                size: 28,
                weight: .bold,
                design: .rounded
            ))
            .foregroundStyle(
                AppColors.textPrimary
            )
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(
                    AppColors.textSecondary
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    private func moodButton(
        _ mood: Mood
    ) -> some View {
        let isSelected = viewModel.mood == mood
        
        return Button {
            viewModel.mood = mood
        } label: {
            HStack(
                spacing: AppSpacing.small
            ) {
                Image(mood.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                    )
                
                Text(mood.title)
                    .font(.subheadline)
                    .fontWeight(
                        isSelected
                        ? .semibold
                        : .regular
                    )
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(
                isSelected
                ? accentColor.opacity(0.38)
                : AppColors.surfaceSecondary
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
                .stroke(
                    isSelected
                    ? accentColor.opacity(0.8)
                    : Color.clear,
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            mood.title
        )
        .accessibilityValue(
            isSelected
            ? "Selected"
            : "Not selected"
        )
        .accessibilityHint(
            "Selects this mood for your check-in."
        )
    }
    
    private func ratingCard(
        title: String,
        systemImage: String,
        value: Binding<Int>
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            HStack {
                Label(
                    title,
                    systemImage: systemImage
                )
                .font(.headline)
                .foregroundStyle(
                    .black.opacity(0.8)
                )

                Spacer()

                Text("\(value.wrappedValue)/5")
                    .font(.headline)
                    .foregroundStyle(
                        .black.opacity(0.8)
                    )
            }

            HStack(
                spacing: AppSpacing.small
            ) {
                ForEach(
                    1...5,
                    id: \.self
                ) { level in
                    Button {
                        value.wrappedValue = level
                    } label: {
                        Text("\(level)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                value.wrappedValue >= level
                                ? .white
                                : AppColors.textSecondary
                            )
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 36
                            )
                            .background(
                                value.wrappedValue >= level
                                ? AppColors.primaryAction.opacity(0.9)
                                : viewModel.mood.backgroundColor.opacity(0.65)
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: AppCornerRadius.large,
                                    style: .continuous
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCardStyle(
            backgroundColor: viewModel.mood.backgroundColor.opacity(0.82),
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
            .stroke(
                viewModel.mood.titleColor.opacity(0.12),
                lineWidth: 1
            )
        }
        .shadow(
            color: viewModel.mood.titleColor.opacity(0.08),
            radius: 10,
            x: 0,
            y: 5
        )
        .animation(
            .easeInOut(duration: 0.35),
            value: viewModel.mood
        )
    }
    
    private var navigationControls: some View {
        VStack(
            spacing: AppSpacing.small
        ) {
            Button {
                if isLastStep {
                    saveCheckIn()
                } else {
                    withAnimation(.easeInOut) {
                        currentStep += 1
                    }
                }
            } label: {
                Text(
                    isLastStep
                    ? "Save Check-In"
                    : "Continue"
                )
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: AppColors.primaryAction
                        .opacity(0.9)
                )
            )
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.5)
            .accessibilityIdentifier(
                isLastStep
                ? "saveCheckInButton"
                : "continueCheckInButton.step\(currentStep + 1)"
            )
            
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut) {
                        currentStep -= 1
                    }
                }
                .font(.system(
                    size: 17,
                    weight: .semibold,
                    design: .rounded
                ))
                .foregroundStyle(AppColors.textPrimary)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 48
                )
                .background(AppColors.surface).opacity(0.9)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(
                            AppColors.textPrimary.opacity(0.10),
                            lineWidth: 1
                        )
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.standard)
        .background {
            viewModel.mood.backgroundColor
                .opacity(0.7)
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: -3
                )
        }
        .animation(
            .easeInOut(duration: 0.45),
            value: viewModel.mood
        )
    }
    
    private func saveCheckIn() {
        let checkIn = viewModel.makeCheckIn()
        onSave(checkIn)
        dismiss()
    }
    
    private var canContinue: Bool {
        switch currentStep {
        case 0:
            return true
            
        case 1:
            return true
            
        case 2:
            return viewModel.energyLevel >= 1 &&
            viewModel.energyLevel <= 5 &&
            viewModel.stressLevel >= 1 &&
            viewModel.stressLevel <= 5
        case 3:
            return true
            
        default:
            return false
        }
    }
    
    private var reflectionFieldColor: Color {
        viewModel.mood.backgroundColor.opacity(0.62)
    }
}

#Preview("New Check-In - Step 1") {
    CheckInView(
        space: .personal
    ) { checkIn in
        print(checkIn)
    }
}
