import SwiftUI

@main
struct HerzenssacheApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            HerzenssacheRootView()
                .environmentObject(model)
                .tint(HSColor.terracotta)
        }
    }
}

enum HSColor {
    static let paper = Color(red: 0.985, green: 0.975, blue: 0.955)
    static let ink = Color(red: 0.16, green: 0.17, blue: 0.15)
    static let muted = Color(red: 0.46, green: 0.47, blue: 0.43)
    static let terracotta = Color(red: 0.72, green: 0.39, blue: 0.31)
    static let blush = Color(red: 0.96, green: 0.90, blue: 0.87)
    static let sage = Color(red: 0.91, green: 0.93, blue: 0.88)
    static let gold = Color(red: 0.96, green: 0.93, blue: 0.84)
}

enum AppTab: String, CaseIterable, Identifiable {
    case home, trends, recipes, calendar, tasks, diy
    var id: String { rawValue }
    var title: String {
        switch self {
        case .home: "Heute"
        case .trends: "Trends"
        case .recipes: "Rezepte"
        case .calendar: "Kalender"
        case .tasks: "To-dos"
        case .diy: "DIY"
        }
    }
    var symbol: String {
        switch self {
        case .home: "house.fill"
        case .trends: "sparkles"
        case .recipes: "fork.knife"
        case .calendar: "calendar"
        case .tasks: "checklist"
        case .diy: "scissors"
        }
    }
}

struct HerzenssacheRootView: View {
    @State private var selected: AppTab = .home

    var body: some View {
        TabView(selection: $selected) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    Group {
                        switch tab {
                        case .home: HomeView(onSelect: { selected = $0 })
                        case .trends: IdeasView()
                        case .recipes: RecipesView()
                        case .calendar: FamilyCalendarView()
                        case .tasks: TasksView()
                        case .diy: DIYView()
                        }
                    }
                    .background(HSColor.paper.ignoresSafeArea())
                    .navigationTitle(tab.title)
                    .navigationBarTitleDisplayMode(.large)
                }
                .tabItem { Label(tab.title, systemImage: tab.symbol) }
                .tag(tab)
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var model: AppModel
    let onSelect: (AppTab) -> Void
    private var dateLine: String { Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide).locale(Locale(identifier: "de_DE"))).uppercased() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(dateLine).font(.caption.weight(.bold)).tracking(1.4).foregroundStyle(HSColor.terracotta)
                Text("Schön, dass du da bist ☀️").font(.system(.largeTitle, design: .serif, weight: .semibold)).foregroundStyle(HSColor.ink)
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DEIN IDEENMOMENT").font(.caption2.weight(.bold)).tracking(1.4).foregroundStyle(HSColor.terracotta)
                        Text("Ein bisschen Inspiration für deinen Alltag.").font(.system(.title2, design: .serif, weight: .semibold))
                        Text("Schönes, Leckeres und Praktisches für euch.").font(.subheadline).foregroundStyle(HSColor.muted)
                        Button("Ideen entdecken") { onSelect(.trends) }.buttonStyle(HSPrimaryButton())
                    }
                    Spacer(minLength: 0)
                    Text("🌼").font(.system(size: 48))
                }
                .padding(20).background(HSColor.blush, in: RoundedRectangle(cornerRadius: 24))
                SectionHeading(title: "Was heute gut tut", subtitle: "Kleine Ideen für einen schönen Tag")
                HStack(spacing: 12) {
                    QuickCard(emoji: "🥣", title: "Soulfood", caption: "Rezepte für gemütliche Tage", color: HSColor.gold) { onSelect(.recipes) }
                    QuickCard(emoji: "✂️", title: "Kreativzeit", caption: "DIY für die ganze Familie", color: HSColor.sage) { onSelect(.diy) }
                }
                SectionHeading(title: "Auf deiner Liste", subtitle: "In deinem Tempo")
                TaskListCard(limit: 3)
                Button { onSelect(.tasks) } label: { Label("Alle To-dos ansehen", systemImage: "arrow.right") }.font(.subheadline.weight(.semibold)).foregroundStyle(HSColor.terracotta)
                SectionHeading(title: "Demnächst", subtitle: "Gemeinsame Zeit im Blick")
                EventListCard(limit: 2)
                Button { onSelect(.calendar) } label: { Label("Zum Familienkalender", systemImage: "calendar") }.font(.subheadline.weight(.semibold)).foregroundStyle(HSColor.terracotta)
            }.padding(20)
        }
    }
}

struct IdeasView: View {
    private let ideas: [(String, String, String)] = [
        ("🍁", "Der langsame Herbstsonntag", "Gemeinsam backen, rausgehen und den Tag ohne großen Plan genießen."),
        ("🧺", "Weniger suchen, mehr finden", "Kleine Körbe für Alltagsdinge bringen Ruhe in Flur und Kinderzimmer."),
        ("🍵", "Die Fünf-Minuten-Pause", "Tee aufgießen, kurz durchatmen und den Moment ganz für dich haben."),
        ("🌱", "Kleine Helfer im Alltag", "Gemeinsam den Tisch decken macht aus einer Aufgabe ein Ritual."),
        ("📚", "Eine Geschichte zum Tagesende", "Ein ruhiger Abschluss schenkt Nähe und lässt den Tag sanft ausklingen."),
        ("🌷", "Ein freundlicher Blick auf dich", "Was heute schon gut war, darf genauso zählen wie das, was noch offen ist.")
    ]
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 14) {
            Text("Schöne Ideen für Zuhause, Familie und deine kleine Auszeit.").foregroundStyle(HSColor.muted).padding(.bottom, 6)
            ForEach(ideas, id: \.1) { item in
                HStack(alignment: .top, spacing: 14) {
                    Text(item.0).font(.largeTitle).frame(width: 54, height: 60).background(HSColor.gold, in: RoundedRectangle(cornerRadius: 16))
                    VStack(alignment: .leading, spacing: 6) { Text(item.1).font(.headline); Text(item.2).font(.subheadline).foregroundStyle(HSColor.muted) }
                    Spacer()
                }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
        }.padding(20) }
    }
}

struct RecipesView: View {
    private let recipes: [(String, String, String, String)] = [
        ("🥘", "Cremige Kürbissuppe", "Mild gewürzt und in 30 Minuten auf dem Tisch.", "30 Min."),
        ("🍝", "One-Pot-Tomatenpasta", "Alles in einen Topf, wenig Abwasch und ganz viel Geschmack.", "20 Min."),
        ("🥞", "Apfel-Pancakes", "Mit Zimt und geriebenem Apfel für den Wochenendmorgen.", "25 Min."),
        ("🥗", "Ofengemüse-Bowl", "Saisonales Gemüse mit cremigem Joghurtdip.", "35 Min."),
        ("🍪", "Haferkekse mit Schokolade", "Unkomplizierter Teig zum gemeinsamen Backen.", "25 Min."),
        ("🍲", "Sanftes Linsen-Dal", "Wärmend, sättigend und ideal zum Vorbereiten.", "35 Min.")
    ]
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 14) {
            Text("Einfache Lieblingsgerichte für kleine und große Esser.").foregroundStyle(HSColor.muted)
            ForEach(recipes, id: \.1) { recipe in
                HStack(alignment: .top, spacing: 15) {
                    Text(recipe.0).font(.system(size: 34)).frame(width: 64, height: 68).background(HSColor.blush, in: RoundedRectangle(cornerRadius: 16))
                    VStack(alignment: .leading, spacing: 5) { Text(recipe.1).font(.headline); Text(recipe.2).font(.subheadline).foregroundStyle(HSColor.muted); Label(recipe.3, systemImage: "clock").font(.caption).foregroundStyle(HSColor.terracotta).padding(.top, 2) }
                    Spacer(minLength: 0)
                }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
        }.padding(20) }
    }
}

struct TasksView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showingAdd = false
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 16) {
            Text("Alles, was dir durch den Kopf geht, darf hier einen Platz finden.").foregroundStyle(HSColor.muted)
            TaskListCard()
            Button { showingAdd = true } label: { Label("Aufgabe hinzufügen", systemImage: "plus") }.buttonStyle(HSPrimaryButton())
            Text("Deine Liste bleibt auf diesem Gerät gespeichert.").font(.caption).foregroundStyle(HSColor.muted)
        }.padding(20) }
        .sheet(isPresented: $showingAdd) { AddTaskSheet() }
    }
}

struct TaskListCard: View {
    @EnvironmentObject private var model: AppModel
    var limit: Int? = nil
    private var visibleTasks: [TaskItem] { Array(model.tasks.prefix(limit ?? model.tasks.count)) }
    var body: some View {
        VStack(spacing: 0) {
            if visibleTasks.isEmpty { Text("Noch nichts auf der Liste. 🌿").foregroundStyle(HSColor.muted).padding(18) }
            ForEach(visibleTasks) { task in
                HStack(spacing: 12) {
                    Button { model.toggle(task) } label: { Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle").font(.title3).foregroundStyle(task.isDone ? HSColor.terracotta : HSColor.muted) }
                    Text(task.title).strikethrough(task.isDone).foregroundStyle(task.isDone ? HSColor.muted : HSColor.ink)
                    Spacer()
                    Button(role: .destructive) { model.remove(task) } label: { Image(systemName: "xmark").font(.caption.weight(.bold)).foregroundStyle(HSColor.muted) }
                }.padding(.vertical, 13)
                if task.id != visibleTasks.last?.id { Divider() }
            }
        }.padding(.horizontal, 16).background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct AddTaskSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    var body: some View {
        NavigationStack {
            Form { TextField("Was möchtest du erledigen?", text: $title).submitLabel(.done).onSubmit(save) }
                .navigationTitle("Neue Aufgabe")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Hinzufügen", action: save).disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) } }
        }.presentationDetents([.medium])
    }
    private func save() { model.addTask(title); dismiss() }
}

struct FamilyCalendarView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showingAdd = false
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 16) {
            Text(Date.now.formatted(.dateTime.month(.wide).year().locale(Locale(identifier: "de_DE")))).font(.system(.title2, design: .serif, weight: .semibold))
            Text("Termine und gemeinsame Zeit an einem Ort.").foregroundStyle(HSColor.muted)
            EventListCard()
            Button { showingAdd = true } label: { Label("Termin hinzufügen", systemImage: "plus") }.buttonStyle(HSPrimaryButton())
            Text("Termine werden in Herzenssache auf diesem Gerät gespeichert.").font(.caption).foregroundStyle(HSColor.muted)
        }.padding(20) }
        .sheet(isPresented: $showingAdd) { AddEventSheet() }
    }
}

struct EventListCard: View {
    @EnvironmentObject private var model: AppModel
    var limit: Int? = nil
    private var visibleEvents: [FamilyEvent] { Array(model.events.sorted { $0.date < $1.date }.prefix(limit ?? model.events.count)) }
    var body: some View {
        VStack(spacing: 0) {
            if visibleEvents.isEmpty { Text("Noch keine Termine geplant.").foregroundStyle(HSColor.muted).padding(18) }
            ForEach(visibleEvents) { event in
                HStack(spacing: 13) {
                    VStack(spacing: 2) { Text(event.date.formatted(.dateTime.day())).font(.title3.bold()); Text(event.date.formatted(.dateTime.month(.abbreviated).locale(Locale(identifier: "de_DE")))).font(.caption2.weight(.bold)).textCase(.uppercase) }
                        .foregroundStyle(HSColor.terracotta).frame(width: 48, height: 52).background(HSColor.blush, in: RoundedRectangle(cornerRadius: 13))
                    VStack(alignment: .leading, spacing: 4) { Text(event.title).font(.headline); Text(event.date.formatted(.dateTime.weekday(.wide).hour().minute().locale(Locale(identifier: "de_DE")))).font(.caption).foregroundStyle(HSColor.muted) }
                    Spacer()
                    Button(role: .destructive) { model.remove(event) } label: { Image(systemName: "xmark").font(.caption.weight(.bold)).foregroundStyle(HSColor.muted) }
                }.padding(.vertical, 12)
                if event.id != visibleEvents.last?.id { Divider() }
            }
        }.padding(.horizontal, 16).background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct AddEventSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date = Calendar.current.date(byAdding: .hour, value: 2, to: .now) ?? .now
    var body: some View {
        NavigationStack {
            Form { TextField("Zum Beispiel: Gemeinsam kochen", text: $title); DatePicker("Datum und Uhrzeit", selection: $date, in: Date.now...) }
                .navigationTitle("Neuer Termin")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Hinzufügen", action: save).disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) } }
        }.presentationDetents([.medium, .large])
    }
    private func save() { model.addEvent(title, date: date); dismiss() }
}

struct DIYView: View {
    private let projects: [(String, String, String)] = [
        ("🍂", "Blätter-Mobile", "Bunte Blätter sammeln, trocknen und mit Faden an einen schönen Ast knoten. Material: Ast, Faden, Blätter."),
        ("🫙", "Glas voller Glücksmomente", "Schöne Momente auf Zettel schreiben und am Jahresende gemeinsam lesen. Material: Glas, Papier."),
        ("🕯️", "Windlicht mit Fundstücken", "Ein Glas mit Blättern und Zapfen schmücken. Material: Glas, Naturfunde, Teelicht."),
        ("🎨", "Stempeln mit Herbstgemüse", "Aus Kartoffeln einfache Stempel schnitzen und bunte Bilder gestalten."),
        ("🌿", "Duftendes Kräutersalz", "Getrocknete Kräuter mit grobem Salz mischen und hübsch in ein Glas füllen."),
        ("💌", "Komplimente für unterwegs", "Kleine liebe Botschaften schreiben und in Tasche oder Jacke verstecken.")
    ]
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 14) {
            Text("Kreative Kleinigkeiten, die Freude machen – ganz ohne großen Aufwand.").foregroundStyle(HSColor.muted).padding(.bottom, 6)
            ForEach(projects, id: \.1) { item in
                HStack(alignment: .top, spacing: 14) {
                    Text(item.0).font(.largeTitle).frame(width: 56, height: 60).background(HSColor.sage, in: RoundedRectangle(cornerRadius: 16))
                    VStack(alignment: .leading, spacing: 6) { Text(item.1).font(.headline); Text(item.2).font(.subheadline).foregroundStyle(HSColor.muted) }
                    Spacer()
                }.padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
        }.padding(20) }
    }
}

struct SectionHeading: View {
    let title: String
    let subtitle: String
    var body: some View { VStack(alignment: .leading, spacing: 4) { Text(title).font(.system(.title2, design: .serif, weight: .semibold)).foregroundStyle(HSColor.ink); Text(subtitle).font(.subheadline).foregroundStyle(HSColor.muted) } }
}

struct QuickCard: View {
    let emoji: String
    let title: String
    let caption: String
    let color: Color
    let action: () -> Void
    var body: some View { Button(action: action) { VStack(alignment: .leading, spacing: 8) { Text(emoji).font(.title); Text(title).font(.headline).foregroundStyle(HSColor.ink); Text(caption).font(.caption).foregroundStyle(HSColor.muted).multilineTextAlignment(.leading) }.frame(maxWidth: .infinity, minHeight: 126, alignment: .leading).padding(14).background(color, in: RoundedRectangle(cornerRadius: 18)) }.buttonStyle(.plain) }
}

struct HSPrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View { configuration.label.font(.subheadline.weight(.semibold)).foregroundStyle(.white).padding(.horizontal, 16).padding(.vertical, 11).background(HSColor.ink.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 12)) }
}

