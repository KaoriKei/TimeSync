import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // サンプルデータを追加
        let sampleEntry = TimeEntryEntity(context: viewContext)
        sampleEntry.id = UUID()
        sampleEntry.taskName = "資料作成"
        sampleEntry.category = "work"
        sampleEntry.plannedDuration = 30 * 60
        sampleEntry.actualDuration = 25 * 60
        sampleEntry.isCompleted = true
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TimeSync")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func deleteTimeEntry(_ timeEntry: TimeEntryEntity) {
        container.viewContext.delete(timeEntry)
        save()
    }
}

extension TimeEntryEntity {
    func toTimeEntry() -> TimeEntry {
        return TimeEntry(
            taskName: self.taskName ?? "",
            category: TaskCategory(rawValue: self.category ?? "other") ?? .other,
            plannedDuration: self.plannedDuration,
            actualDuration: self.actualDuration == 0 ? nil : self.actualDuration,
            startTime: self.startTime ?? Date(),
            endTime: self.endTime,
            isCompleted: self.isCompleted
        )
    }
    
    func updateFrom(_ timeEntry: TimeEntry) {
        self.taskName = timeEntry.taskName
        self.category = timeEntry.category.rawValue
        self.plannedDuration = timeEntry.plannedDuration
        self.actualDuration = timeEntry.actualDuration ?? 0
        self.startTime = timeEntry.startTime
        self.endTime = timeEntry.endTime
        self.isCompleted = timeEntry.isCompleted
    }
}
