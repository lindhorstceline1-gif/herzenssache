import Foundation
import Combine

struct TaskItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isDone = false
}

struct FamilyEvent: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
}

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] { didSet { save(tasks, key: "herzenssache.tasks") } }
    @Published private(set) var events: [FamilyEvent] { didSet { save(events, key: "herzenssache.events") } }

    init() {
        tasks = Self.load([TaskItem].self, key: "herzenssache.tasks") ?? [
            TaskItem(title: "Einkaufsliste für die Woche schreiben"),
            TaskItem(title: "Lieblingsrezept fürs Abendessen aussuchen"),
            TaskItem(title: "Eine kleine Pause für mich einplanen", isDone: true)
        ]
        let firstDate = Calendar.current.date(byAdding: .day, value: 2, to: .now) ?? .now
        let secondDate = Calendar.current.date(byAdding: .day, value: 4, to: .now) ?? .now
        events = Self.load([FamilyEvent].self, key: "herzenssache.events") ?? [
            FamilyEvent(title: "Gemeinsam kochen", date: firstDate),
            FamilyEvent(title: "Kreativzeit", date: secondDate)
        ]
    }

    func addTask(_ title: String) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        tasks.insert(TaskItem(title: clean), at: 0)
    }

    func toggle(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
    }

    func remove(_ task: TaskItem) { tasks.removeAll { $0.id == task.id } }

    func addEvent(_ title: String, date: Date) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        events.append(FamilyEvent(title: clean, date: date))
    }

    func remove(_ event: FamilyEvent) { events.removeAll { $0.id == event.id } }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

