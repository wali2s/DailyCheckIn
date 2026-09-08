//
//  HistoryCalendarView.swift
//  DailyCheckIn
//
//  Created by Wahid on 06.09.26.
//

import SwiftUI

struct HistoryCalendarView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()
    @State private var selectedCheckIn: CheckIn?
    @State private var selectedSpace: JournalSpace = .personal
    @State private var checkInPendingDeletion: CheckIn?
    @State private var isShowingDeleteConfirmation: Bool = false

    private var calendar: Calendar {
        Calendar.current
    }
    

    private var calendarDays: [Date?] {
        guard
            let monthInterval = calendar.dateInterval(
                of: .month,
                for: displayedMonth
            ),
            let dayRange = calendar.range(
                of: .day,
                in: .month,
                for: displayedMonth
            )
        else {
            return []
        }

        let monthStart = monthInterval.start

        let leadingEmptyDays =
            (
                calendar.component(
                    .weekday,
                    from: monthStart
                )
                - calendar.firstWeekday
                + 7
            ) % 7

        var days: [Date?] = Array(
            repeating: nil,
            count: leadingEmptyDays
        )

        days += dayRange.compactMap { day in
            calendar.date(
                byAdding: .day,
                value: day - 1,
                to: monthStart
            )
        }

        return days
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1

        return Array(symbols[firstIndex...])
            + Array(symbols[..<firstIndex])
    }

    private var selectedDayCheckIns: [CheckIn] {
        guard let checkIn = checkIn(
            for: selectedSpace,
            on: selectedDate
        ) else {
            return []
        }

        return [checkIn]
    }
    
    var body: some View {
        List {
            Section {
                monthNavigation
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                spaceCalendarPager
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            Section {
                if selectedDayCheckIns.isEmpty {
                    Text(
                        "No \(selectedSpace.title.lowercased()) "
                        + "check-in on this day."
                    )
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .listRowBackground(AppColors.warmSurface)
                } else {
                    ForEach(selectedDayCheckIns) { checkIn in
                        NavigationLink {
                            CheckInDetailView(
                                checkIn: checkIn
                            ) {
                                selectedCheckIn = checkIn
                            }
                        } label: {
                            checkInRow(checkIn)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(
                            edge: .trailing,
                            allowsFullSwipe: true
                        ) {
                            Button(role: .destructive) {
                                checkInPendingDeletion = checkIn
                                isShowingDeleteConfirmation = true
                            } label: {
                                Label(
                                    "Delete",
                                    systemImage: "trash"
                                )
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(AppColors.warmSurface)
                    }
                }
            } header: {
                selectedDayHeader
            }

            Section {
                futureInsightsSection
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppColors.warmCanvas.ignoresSafeArea())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedCheckIn) { checkIn in
            CheckInView(
                space: checkIn.space,
                existingCheckIn: checkIn
            ) { updatedCheckIn in
                viewModel.addCheckIn(updatedCheckIn)
            }
        }
        .confirmationDialog(
            "Delete Check-In?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Check-In", role: .destructive) {
                guard let checkInPendingDeletion else {
                    return
                }

                viewModel.deleteCheckIn(
                    checkInPendingDeletion
                )

                self.checkInPendingDeletion = nil
            }

            Button("Cancel", role: .cancel) {
                checkInPendingDeletion = nil
            }
        } message: {
            Text("This check-in will be permanently deleted.")
        }
    }
    
    private var monthNavigation: some View {
        HStack(spacing: AppSpacing.standard) {
            Button {
                changeDisplayedMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryAction)
                    .frame(width: 38, height: 38)
                    .background(
                        AppColors.warmCanvas
                    )
                    .clipShape(Circle())
            }
            .buttonStyle(.borderless)

            Spacer()

            VStack(spacing: 5) {
                Text(
                    displayedMonth.formatted(
                        .dateTime.month(.wide).year()
                    )
                )
                .font(
                    .system(
                        size: 20,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(AppColors.textPrimary)

                Button("Today") {
                    displayedMonth = Date()
                    selectedDate = Date()
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.primaryAction)
                .disabled(
                    calendar.isDate(
                        displayedMonth,
                        equalTo: Date(),
                        toGranularity: .month
                    )
                )
                .opacity(
                    calendar.isDate(
                        displayedMonth,
                        equalTo: Date(),
                        toGranularity: .month
                    )
                        ? 0.4
                        : 1
                )
                .buttonStyle(.borderless)
            }

            Spacer()

            Button {
                changeDisplayedMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.primaryAction)
                    .frame(width: 38, height: 38)
                    .background(
                        AppColors.warmCanvas
                    )
                    .clipShape(Circle())
            }
        }
        .padding(AppSpacing.standard)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
        .buttonStyle(.borderless)
    }
    
    private var selectedDayHeader: some View {
        HStack {
            Text(
                selectedDate.formatted(
                    .dateTime.weekday(.wide).day().month(.wide)
                )
            )

            Spacer()

            Label(
                selectedSpace.title,
                systemImage: selectedSpace.iconName
            )
        }
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(AppColors.textPrimary)
    }
    
    private var spaceCalendarPager: some View {
        VStack(spacing: AppSpacing.small) {
            TabView(selection: $selectedSpace) {
                ForEach(JournalSpace.allCases) { space in
                    calendarCard(for: space)
                        .tag(space)
                }
            }
            .tabViewStyle(
                .page(indexDisplayMode: .never)
            )
            .frame(height: 430)
            .accessibilityIdentifier("historyCalendarSpacePager")

            HStack(spacing: 6) {
                ForEach(JournalSpace.allCases) { space in
                    Capsule()
                        .fill(
                            space == selectedSpace
                                ? AppColors.primaryAction
                                : AppColors.surfaceSecondary
                        )
                        .frame(
                            width: space == selectedSpace ? 18 : 6,
                            height: 6
                        )
                }
            }.accessibilityElement(children: .ignore)
                .accessibilityIdentifier(
                    "historyCalendarSelectedSpace"
                )
                .accessibilityLabel(selectedSpace.title)
                .accessibilityValue(
                    selectedSpace == .personal
                        ? "1 of 2"
                        : "2 of 2"
                )

            Text("Swipe between Private and Work")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
    
    private func calendarCard(
        for space: JournalSpace
    ) -> some View {
        VStack(spacing: AppSpacing.standard) {
            HStack {
                Label(
                    space.title,
                    systemImage: space.iconName
                )
                .font(.headline)
                .foregroundStyle(
                    space == .personal
                        ? AppColors.accentMint
                        : AppColors.accentBlue
                )
                .accessibilityIdentifier("historyCalendarSpaceTitle")
                
                Spacer()

                Text(
                    monthCheckInCountText(
                        for: space
                    )
                )
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(AppColors.warmCanvas)
                .clipShape(Capsule())
            }

            HStack {
                ForEach(
                    Array(weekdaySymbols.enumerated()),
                    id: \.offset
                ) { _, symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(
                columns: Array(
                    repeating: GridItem(
                        .flexible(),
                        spacing: 4
                    ),
                    count: 7
                ),
                spacing: 8
            ) {
                ForEach(
                    Array(calendarDays.enumerated()),
                    id: \.offset
                ) { _, date in
                    calendarDayCell(
                        date: date,
                        for: space
                    )
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
    }
    
    private func monthCheckInCountText(
        for space: JournalSpace
    ) -> String {
        let count = checkInCount(
            for: space,
            in: displayedMonth
        )

        return count == 1
            ? "1 check-in"
            : "\(count) check-ins"
    }

    private func checkInCount(
        for space: JournalSpace,
        in month: Date
    ) -> Int {
        guard let monthInterval = calendar.dateInterval(
            of: .month,
            for: month
        ) else {
            return 0
        }

        return viewModel.checkIns.filter {
            $0.space == space
                && monthInterval.contains($0.date)
        }
        .count
    }
    
    @ViewBuilder
    private func calendarDayCell(
        date: Date?,
        for space: JournalSpace
    ) -> some View {
        if let date {
            let dayCheckIn = checkIn(
                for: space,
                on: date
            )
            let isSelected = calendar.isDate(
                date,
                inSameDayAs: selectedDate
            )
            
            let tint = space == .personal
                ? AppColors.accentMint
                : AppColors.accentBlue

            let isToday = calendar.isDateInToday(date)
            let isFuture = date > calendar.startOfDay(for: Date())

            Button {
                selectedDate = date
            } label: {
                VStack(spacing: 5) {
                    Text(
                        "\(calendar.component(.day, from: date))"
                    )
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        isSelected
                            ? Color.white
                            : AppColors.textPrimary
                    )

                    Circle()
                        .fill(
                            dayCheckIn == nil
                                ? Color.clear
                                : (isSelected ? Color.white : tint)
                        )
                        .frame(width: 6, height: 6)
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.small,
                        style: .continuous
                    )
                    .fill(
                        isSelected
                            ? tint
                            : (isToday ? tint.opacity(0.12) : Color.clear)
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.small,
                        style: .continuous
                    )
                    .stroke(
                        isToday && !isSelected
                            ? tint.opacity(0.7)
                            : Color.clear,
                        lineWidth: 1
                    )
                )
            }
            .buttonStyle(.plain)
            .disabled(isFuture)
            .opacity(isFuture ? 0.3 : 1)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                date.formatted(
                    .dateTime.weekday(.wide).day().month(.wide)
                )
            )
            .accessibilityValue(
                dayCheckIn == nil
                    ? "No \(space.title) check-in"
                    : "\(space.title) check-in: "
                        + dayCheckIn!.mood.title
            )
            .accessibilityHint(
                isFuture
                    ? "Future date"
                    : "Shows the check-in for this date"
            )
        } else {
            Color.clear
                .frame(height: 48)
        }
    }

    
    private var futureInsightsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.standard) {
            Label("Future AI insights",
                  systemImage: "sparkles"
            )
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)
            
            Text("Your personal weekly and monthly reflections will apear here.")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            
            HStack(spacing: AppSpacing.standard) {
                insightPreviewCard(
                    title: "Weekly",
                    subtitle: "A short reflection",
                    systemImage: "calendar"
                )

                insightPreviewCard(
                    title: "Monthly",
                    subtitle: "A deeper pattern review",
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            }
            
            Text("Coming later with DailyCheckIn prime")
                .font(.caption)
                .foregroundStyle(AppColors.warmSurface)
        }
        .padding(AppSpacing.cardPadding)
        .foregroundStyle(AppColors.textSecondary)
        .clipShape(
            RoundedRectangle(cornerRadius: AppCornerRadius.large,
                             style: .continuous
                            )
                        )
    }
    
    private func insightPreviewCard(
        title: String,
        subtitle: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.standard) {
            HStack {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.primaryAction)
                    .frame(width: 30, height: 30)
                    .background(
                        AppColors.primaryAction.opacity(0.12)
                    )
                    .clipShape(Circle())

                Spacer()

                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textPrimary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(AppSpacing.standard)
        .background(AppColors.warmCanvas)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard,
                style: .continuous
            )
        )
    }

    private func checkInRow(
        _ checkIn: CheckIn
    ) -> some View {
        let accentColor = checkIn.space == .personal
            ? AppColors.accentMint
            : AppColors.accentBlue

        return HStack(spacing: AppSpacing.standard) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.standard,
                    style: .continuous
                )
                .fill(accentColor.opacity(0.14))
                .frame(width: 48, height: 48)

                Image(checkIn.mood.chartImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Image(systemName: checkIn.space.iconName)
                        .font(.caption)
                        .foregroundStyle(accentColor)

                    Text(checkIn.space.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textPrimary)
                }

                Text(
                    checkIn.date.formatted(
                        date: .omitted,
                        time: .shortened
                    )
                )
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)

                if !checkIn.note.isEmpty {
                    Text(checkIn.note)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(checkIn.mood.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.12))
                    .clipShape(Capsule())

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.5)
                    )
            }
        }
        .padding(12)
        .background(AppColors.warmCanvas)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard,
                style: .continuous
            )
        )
    }

    private func calendarLegend(
        color: Color,
        title: String
    ) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func checkIn(
        for space: JournalSpace,
        on date: Date
    ) -> CheckIn? {
        viewModel.checkIns.first {
            $0.space == space
                && calendar.isDate(
                    $0.date,
                    inSameDayAs: date
                )
        }
    }

    private func changeDisplayedMonth(
        by amount: Int
    ) {
        guard let newMonth = calendar.date(
            byAdding: .month,
            value: amount,
            to: displayedMonth
        ) else {
            return
        }

        displayedMonth = newMonth

        guard let monthInterval = calendar.dateInterval(
            of: .month,
            for: newMonth
        ) else {
            return
        }

        selectedDate = monthInterval.start
    }
}
