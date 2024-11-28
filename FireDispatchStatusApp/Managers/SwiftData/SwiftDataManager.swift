//
//  SwiftDataManager.swift
//  FireDispatchStatusApp
//
//  Created by Jeong Deokho on 11/22/24.
//

import Foundation
import SwiftData

struct SwiftDataManager<T: PersistentModel> {
    private let container: ModelContainer
    private let context: ModelContext

    init() throws {
        self.container = try ModelContainer(for: T.self)
        self.context = ModelContext(container)
    }
    
    func save(item: T) throws {
        if let exstingItem = try get() {
            context.delete(exstingItem)
        }
        context.insert(item)
        try context.save()
    }
    
    func get() throws -> T? {
        let descriptor = FetchDescriptor<T>()
        let items = try context.fetch(descriptor)
        return items.first
    }

}
