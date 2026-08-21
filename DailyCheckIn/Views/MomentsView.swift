////
//  MomentsView.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
//

import SwiftUI

struct MomentsView: View {
    
    @StateObject private var viewModel: MomentsViewModel
    
    @State private var showingCreateSheet = false
    @State private var momentToEdit: Moment?
    
    init(viewModel: MomentsViewModel = MomentsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.section
                ) {
                    
                    // MARK: - Header
                    VStack(
                        alignment: .leading,
                        spacing: AppSpacing.small
                    ) {
                        Text("Moments")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Text("What would you like to make time for today?")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    
                    // MARK: - Moments List
                    if viewModel.moments.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: AppSpacing.standard) {
                            ForEach(viewModel.moments) { moment in
                                momentCard(moment: moment)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.standard)
            }
            .background(AppColors.warmCanvas)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.primaryAction)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateMomentView { newMoment in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.addMoment(newMoment)
                    }
                }
            }
            .sheet(item: $momentToEdit) { moment in
                CreateMomentView(momentToEdit: moment) { updatedMoment in
                    withAnimation {
                        viewModel.updateMoment(updatedMoment)
                    }
                }
            }
        }
    }
    
    // MARK: - Moment Card View
    private func momentCard(moment: Moment) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            HStack {
                Image(systemName: moment.iconName.isEmpty ? "sparkles" : moment.iconName)
                    .font(.title2)
                    .foregroundStyle(AppColors.accentMint)
                
                Spacer()
                
                Text(moment.period.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, AppSpacing.extraSmall)
                    .background(AppColors.surfaceSecondary.opacity(0.5))
                    .clipShape(Capsule())

                Menu {
                    Button {
                        momentToEdit = moment
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        withAnimation {
                            viewModel.deleteMoment(moment)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.leading, AppSpacing.extraSmall)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(moment.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                if !moment.subtitle.isEmpty {
                    Text(moment.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleCompletion(for: moment)
                }
            } label: {
                Text(moment.isCompleted ? "Completed" : "Complete")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: moment.isCompleted ? AppColors.accentMint : AppColors.primaryAction
                )
            )
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.standard) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textSecondary)
            
            Text("No moments planned yet")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            
            Text("Tap the plus icon in the top right corner to pick from preset activities or create your own.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.standard)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.extraLarge)
        .appCardStyle(backgroundColor: AppColors.warmSurface)
    }
}
// MARK: - Preview
#Preview("Default State") {
    MomentsView()
}

#Preview("Dark Mode") {
    MomentsView()
        .preferredColorScheme(.dark)
}
