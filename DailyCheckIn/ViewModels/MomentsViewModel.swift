//
//  MomentsViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 21.08.26.
//

import Foundation
import Combine

final class MomentsViewModel: ObservableObject {
    
    @Published private(set) var moments: [Moment] = []
    
    private let storageService: MomentStorageService
    
    init(storageService: MomentStorageService = UserDefaultsMomentStorageService()) {
        self.storageService = storageService
        self.moments = storageService.loadMoments()
    }
    
    // MARK: - Filters
    
    func moments(for period: MomentPeriod) -> [Moment] {
        moments.filter { $0.period == period }
    }
    
    // MARK: - CRUD Actions
    
    func addMoment(_ moment: Moment) {
        moments.insert(moment, at: 0)
        saveMoments()
    }
    
    func updateMoment(_ updatedMoment: Moment) {
        guard let index = moments.firstIndex(where: { $0.id == updatedMoment.id }) else {
            return
        }
        moments[index] = updatedMoment
        saveMoments()
    }
    
    func deleteMoment(_ moment: Moment) {
        moments.removeAll { $0.id == moment.id }
        saveMoments()
    }
    
    func toggleCompletion(for moment: Moment) {
        guard let index = moments.firstIndex(where: { $0.id == moment.id }) else {
            return
        }
        moments[index].isCompleted.toggle()
        saveMoments()
    }
    
    private func saveMoments() {
        storageService.saveMoments(moments)
    }
}
