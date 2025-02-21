//
//  CoreDataManager.swift
//  TimeStackDateCalculator
//
//  Created by Viennarz Curtiz on 2/19/25.
//


import CoreData
import Foundation
import SwiftUI

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    func fetchTimeIntervals() -> [TimeIntervalEntity] {
        let request: NSFetchRequest<TimeIntervalEntity> = TimeIntervalEntity.fetchRequest()
        do {
            let timeIntervalEntities = try viewContext.fetch(request)
            return timeIntervalEntities
        } catch {
            fatalError("Failed to fetch time intervals: \(error)")
        }
        
    }
    
}
