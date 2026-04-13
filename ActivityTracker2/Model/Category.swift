// Category.swift
// ActivityTracker2 — Remember
// Statisches Kategorie-Modell (kein SwiftData)

import Foundation

// MARK: - Category

/// Repräsentiert eine Aktivitätskategorie.
/// Wird **nicht** in SwiftData gespeichert — `Activity` speichert nur die `id` als String.
/// Alle verfügbaren Kategorien werden zur Laufzeit aus den statischen Arrays nachgeschlagen.
struct Category: Identifiable, Hashable {

    /// Eindeutiger String-Schlüssel, entspricht `Activity.categoryId`.
    let id: String

    /// Kategoriename auf Deutsch.
    let nameDe: String

    /// Kategoriename auf Englisch.
    let nameEn: String

    /// SF-Symbol-Name für das Kategorie-Icon.
    let iconName: String

    /// Hex-Farbwert des Kategorie-Akzents, z.B. `"#27AE60"`.
    let colorHex: String

    // MARK: Lokalisierung

    /// Gibt den Kategorienamen für die angegebene Sprache zurück.
    /// - Parameter language: `"de"`, `"en"` oder `"system"` (folgt iOS-Systemsprache).
    func localizedName(for language: String) -> String {
        switch language {
        case "de": return nameDe
        case "en": return nameEn
        default:
            let langCode = Locale.current.language.languageCode?.identifier ?? "en"
            return langCode == "de" ? nameDe : nameEn
        }
    }
}

// MARK: - MVP Categories

extension Category {

    /// Kategorien im kostenlosen Plan (~20 Kategorien).
    static let mvpCategories: [Category] = [
        Category(id: "hiking",        nameDe: "Wandern",           nameEn: "Hiking",          iconName: "figure.hiking",               colorHex: "#27AE60"),
        Category(id: "running",       nameDe: "Laufen",            nameEn: "Running",         iconName: "figure.run",                  colorHex: "#E74C3C"),
        Category(id: "cycling",       nameDe: "Radfahren",         nameEn: "Cycling",         iconName: "bicycle",                     colorHex: "#3498DB"),
        Category(id: "restaurant",    nameDe: "Restaurant",        nameEn: "Restaurant",      iconName: "fork.knife",                  colorHex: "#E67E22"),
        Category(id: "cafe",          nameDe: "Café",              nameEn: "Café",            iconName: "cup.and.saucer.fill",         colorHex: "#8B4513"),
        Category(id: "bar",           nameDe: "Bar & Kneipe",      nameEn: "Bar",             iconName: "wineglass.fill",              colorHex: "#9B59B6"),
        Category(id: "museum",        nameDe: "Museum",            nameEn: "Museum",          iconName: "building.columns.fill",       colorHex: "#2C3E50"),
        Category(id: "cinema",        nameDe: "Kino",              nameEn: "Cinema",          iconName: "film.fill",                   colorHex: "#E91E63"),
        Category(id: "concert",       nameDe: "Konzert",           nameEn: "Concert",         iconName: "music.note",                  colorHex: "#FF5722"),
        Category(id: "theater",       nameDe: "Theater",           nameEn: "Theater",         iconName: "theatermasks.fill",           colorHex: "#673AB7"),
        Category(id: "festival",      nameDe: "Festival",          nameEn: "Festival",        iconName: "sparkles",                    colorHex: "#FF9800"),
        Category(id: "art",           nameDe: "Kunst & Galerie",   nameEn: "Art & Gallery",   iconName: "paintpalette.fill",           colorHex: "#F39C12"),
        Category(id: "fitness",       nameDe: "Fitness",           nameEn: "Fitness",         iconName: "dumbbell.fill",               colorHex: "#1ABC9C"),
        Category(id: "skiing",        nameDe: "Skifahren",         nameEn: "Skiing",          iconName: "snowflake",                   colorHex: "#00BCD4"),
        Category(id: "travel",        nameDe: "Reise",             nameEn: "Travel",          iconName: "airplane",                    colorHex: "#3F51B5"),
        Category(id: "journal",       nameDe: "Tagebuch",          nameEn: "Journal",         iconName: "book.fill",                   colorHex: "#607D8B"),
        Category(id: "personal_note", nameDe: "Persönliche Notiz", nameEn: "Personal Note",   iconName: "note.text",                   colorHex: "#795548"),
        Category(id: "photography",   nameDe: "Fotografie",        nameEn: "Photography",     iconName: "camera.fill",                 colorHex: "#455A64"),
        Category(id: "shopping",      nameDe: "Shopping",          nameEn: "Shopping",        iconName: "bag.fill",                    colorHex: "#E91E63"),
        Category(id: "wellness",      nameDe: "Wellness & Spa",    nameEn: "Wellness & Spa",  iconName: "leaf.fill",                   colorHex: "#4CAF50"),
        Category(id: "park",          nameDe: "Park & Natur",      nameEn: "Park & Nature",   iconName: "tree.fill",                   colorHex: "#2ECC71"),
        Category(id: "beach",         nameDe: "Strand & See",      nameEn: "Beach & Lake",    iconName: "beach.umbrella.fill",         colorHex: "#00ACC1")
    ]
}

// MARK: - Plus Categories

extension Category {

    /// Zusätzliche Kategorien, die nur mit aktivem Plus-Abo verfügbar sind.
    static let plusCategories: [Category] = [
        Category(id: "climbing",       nameDe: "Klettern",         nameEn: "Climbing",        iconName: "figure.climbing",             colorHex: "#FF5722"),
        Category(id: "swimming",       nameDe: "Schwimmen",        nameEn: "Swimming",        iconName: "figure.pool.swim",            colorHex: "#03A9F4"),
        Category(id: "yoga",           nameDe: "Yoga",             nameEn: "Yoga",            iconName: "figure.mind.and.body",        colorHex: "#8BC34A"),
        Category(id: "cooking",        nameDe: "Kochen",           nameEn: "Cooking",         iconName: "cooktop.fill",                colorHex: "#FF8F00"),
        Category(id: "reading",        nameDe: "Lesen",            nameEn: "Reading",         iconName: "books.vertical.fill",         colorHex: "#5C6BC0"),
        Category(id: "music_practice", nameDe: "Musik üben",       nameEn: "Music Practice",  iconName: "guitars.fill",                colorHex: "#AB47BC"),
        Category(id: "meditation",     nameDe: "Meditation",       nameEn: "Meditation",      iconName: "brain.head.profile",          colorHex: "#26C6DA"),
        Category(id: "gaming",         nameDe: "Gaming",           nameEn: "Gaming",          iconName: "gamecontroller.fill",         colorHex: "#EF5350"),
        Category(id: "writing",        nameDe: "Schreiben",        nameEn: "Writing",         iconName: "pencil.and.outline",          colorHex: "#78909C"),
        Category(id: "picnic",         nameDe: "Picknick",         nameEn: "Picnic",          iconName: "fork.knife.circle.fill",      colorHex: "#66BB6A")
    ]
}
