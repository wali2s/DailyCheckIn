//
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
            Group {
                if viewModel.moments.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.section) {
                            headerView
                            emptyStateView
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.vertical, AppSpacing.standard)
                    }
                } else {
                    List {
                        Section {
                            headerView
                                .padding(.bottom, AppSpacing.small)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: AppSpacing.standard, leading: AppSpacing.screenHorizontal, bottom: 0, trailing: AppSpacing.screenHorizontal))
                        .listRowBackground(Color.clear)
                        
                        ForEach(viewModel.moments) { moment in
                            momentCard(moment: moment)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    // Löschen Aktion (Rot)
                                    Button(role: .destructive) {
                                        withAnimation {
                                            viewModel.deleteMoment(moment)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }

                                    Button {
                                        momentToEdit = moment
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: AppSpacing.extraSmall, leading: AppSpacing.screenHorizontal, bottom: AppSpacing.extraSmall, trailing: AppSpacing.screenHorizontal))
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
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
    
    // MARK: - Header Subview
    private var headerView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Moments")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            Text("What would you like to make time for today?")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
    
    // MARK: - Moment Card View
    private func momentCard(moment: Moment) -> some View {
        HStack(spacing: AppSpacing.standard) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                
                HStack {
                    Image(systemName: moment.iconName.isEmpty ? "sparkles" : moment.iconName)
                        .font(.title3)
                        .foregroundStyle(AppColors.accentMint)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(moment.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        
                        if !moment.subtitle.isEmpty {
                            Text(moment.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                
                HStack {
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundStyle(AppColors.primaryAction)
                        

                    Text("\(moment.targetMinutes) Min")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColors.textSecondary)
                    
                    Text(moment.period.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, AppSpacing.small)
                        .padding(.vertical, AppSpacing.extraSmall)
                        .background(AppColors.surfaceSecondary.opacity(0.5))
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            HStack(spacing: 6) {
              
            }
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    viewModel.toggleCompletion(for: moment)
                }
            } label: {
                Image(systemName: moment.isCompleted ? "pause.fill" : "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(moment.isCompleted ? AppColors.warmSurface : AppColors.primaryAction)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(moment.isCompleted ? AppColors.accentMint : AppColors.primaryAction.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)
            
            // Visual Indicator für Swipe-Geste
            Image(systemName: "chevron.left")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textSecondary.opacity(0.3))
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
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
