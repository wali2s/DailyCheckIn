//
//  CheckInView.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI

struct CheckInView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CheckinViewModel
    
    let onSave: (CheckIn) -> Void
    
    init(space: JournalSpace,
         onSave: @escaping (CheckIn) -> Void
    ){
        _viewModel = StateObject(wrappedValue: CheckinViewModel(space: space))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: viewModel.space.iconName)
                            .foregroundStyle(.blue)
                        
                        Text(viewModel.space.title)
                            .font(.headline)
                    }
                }
                
                Section ("How are you feeling?") {
                    Picker("Mood",selection: $viewModel.mood) {
                        ForEach(Mood.allCases) { mood in
                            Text("\(mood.emoji) \(mood.title)").tag(mood)
                        }
                    }
                }
                
                Section("How is your energy?") {
                    Stepper(
                        "Stress: \(viewModel.stressLevel)/5",
                        value: $viewModel.stressLevel,
                        in: 1...5
                    )
                }
                
                Section("Your Thoughts") {
                    TextField(
                        "Write a short note ...",
                        text: $viewModel.note,
                        axis: .vertical
                    )
                    .lineLimit(4...8)
                }
            }
            .navigationTitle("New Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let checkIn = viewModel.makeCheckin()
                        onSave(checkIn)
                        dismiss()
                    }
                }
            }
        }
    }
}


