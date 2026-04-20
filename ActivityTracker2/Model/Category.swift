// Category.swift
// ActivityTracker2 — Remember
// Statisches Kategorie-Modell (kein SwiftData) — 100 Kategorien in 6 Clustern

import Foundation

// MARK: - Category

/// Repräsentiert eine Aktivitätskategorie.
/// Wird **nicht** in SwiftData gespeichert — `Activity` speichert nur die `id` als String.
/// Alle verfügbaren Kategorien werden zur Laufzeit aus den statischen Arrays nachgeschlagen.
///
/// Cluster-Farben:
/// - Outdoor   #1D9E75
/// - Sport     #D85A30
/// - Food      #BA7517
/// - Kultur    #7F77DD
/// - Kreativ   #378ADD
/// - Lifestyle #D4537E
struct Category: Identifiable, Hashable {

    /// Eindeutiger String-Schlüssel, entspricht `Activity.categoryId`.
    let id: String

    /// Kategoriename auf Deutsch.
    let nameDe: String

    /// Kategoriename auf Englisch.
    let nameEn: String

    /// SF-Symbol-Name für das Kategorie-Icon.
    let iconName: String

    /// Hex-Farbwert des Kategorie-Akzents, z.B. `"#1D9E75"`.
    let colorHex: String

    /// `true` wenn die Kategorie nur mit Plus-Abo verfügbar ist.
    let isPlusOnly: Bool

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

// MARK: - MVP Categories (30 — isPlusOnly: false)

extension Category {

    /// Kategorien im kostenlosen Plan — 30 Kategorien in 6 Clustern.
    static let mvpCategories: [Category] = [

        // ── OUTDOOR (5) ───────────────────────────────────────────────────────
        Category(id: "park",        nameDe: "Park",           nameEn: "Park",        iconName: "tree.fill",           colorHex: "#1D9E75", isPlusOnly: false),
        Category(id: "beach",       nameDe: "Strand",         nameEn: "Beach",       iconName: "beach.umbrella.fill", colorHex: "#1D9E75", isPlusOnly: false),
        Category(id: "picnic",      nameDe: "Picknick",       nameEn: "Picnic",      iconName: "basket.fill",         colorHex: "#1D9E75", isPlusOnly: false),
        Category(id: "campsite",    nameDe: "Camping",        nameEn: "Camping",     iconName: "tent.fill",           colorHex: "#1D9E75", isPlusOnly: false),
        Category(id: "viewpoint",   nameDe: "Aussichtspunkt", nameEn: "Viewpoint",   iconName: "scope",               colorHex: "#1D9E75", isPlusOnly: false),

        // ── SPORT (13) ────────────────────────────────────────────────────────
        Category(id: "running",     nameDe: "Laufen",         nameEn: "Running",     iconName: "figure.run",               colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "hiking",      nameDe: "Wandern",        nameEn: "Hiking",      iconName: "figure.hiking",            colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "cycling",     nameDe: "Fahrrad",        nameEn: "Cycling",     iconName: "figure.outdoor.cycle",     colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "skiing",      nameDe: "Ski",            nameEn: "Skiing",      iconName: "figure.skiing.downhill",   colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "fitness",     nameDe: "Fitness",        nameEn: "Fitness",     iconName: "figure.strengthtraining.traditional", colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "football",    nameDe: "Fussball",       nameEn: "Football",    iconName: "soccerball",               colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "climbing",    nameDe: "Klettern",       nameEn: "Climbing",    iconName: "figure.climbing",          colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "swimming",    nameDe: "Schwimmen",      nameEn: "Swimming",    iconName: "figure.pool.swim",         colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "yoga",        nameDe: "Yoga",           nameEn: "Yoga",        iconName: "figure.mind.and.body",     colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "tennis",      nameDe: "Tennis",         nameEn: "Tennis",      iconName: "figure.tennis",            colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "golf",        nameDe: "Golf",           nameEn: "Golf",        iconName: "figure.golf",              colorHex: "#D85A30", isPlusOnly: false),
        Category(id: "dancing",     nameDe: "Tanzen",         nameEn: "Dancing",     iconName: "figure.socialdance",       colorHex: "#D85A30", isPlusOnly: false),

        // ── FOOD (4) ──────────────────────────────────────────────────────────
        Category(id: "restaurant",   nameDe: "Restaurant",  nameEn: "Restaurant",   iconName: "fork.knife",          colorHex: "#BA7517", isPlusOnly: false),
        Category(id: "cafe",         nameDe: "Café",        nameEn: "Café",          iconName: "cup.and.saucer.fill", colorHex: "#BA7517", isPlusOnly: false),
        Category(id: "bar",          nameDe: "Bar & Kneipe",nameEn: "Bar",           iconName: "wineglass.fill",      colorHex: "#BA7517", isPlusOnly: false),
        Category(id: "wine_tasting", nameDe: "Weinprobe",   nameEn: "Wine Tasting",  iconName: "wineglass",           colorHex: "#BA7517", isPlusOnly: false),

        // ── KULTUR (5) ────────────────────────────────────────────────────────
        Category(id: "museum",      nameDe: "Museum",    nameEn: "Museum",   iconName: "building.columns.fill", colorHex: "#7F77DD", isPlusOnly: false),
        Category(id: "cinema",      nameDe: "Kino",      nameEn: "Cinema",   iconName: "film.fill",             colorHex: "#7F77DD", isPlusOnly: false),
        Category(id: "concert",     nameDe: "Konzert",   nameEn: "Concert",  iconName: "music.quarternote.3",   colorHex: "#7F77DD", isPlusOnly: false),
        Category(id: "theater",     nameDe: "Theater",   nameEn: "Theater",  iconName: "theatermasks.fill",     colorHex: "#7F77DD", isPlusOnly: false),
        Category(id: "festival",    nameDe: "Festival",  nameEn: "Festival", iconName: "party.popper",          colorHex: "#7F77DD", isPlusOnly: false),

        // ── KREATIV (2) ───────────────────────────────────────────────────────
        Category(id: "journal",     nameDe: "Tagebuch",  nameEn: "Journal",     iconName: "book.fill",  colorHex: "#378ADD", isPlusOnly: false),
        Category(id: "photography", nameDe: "Fotografie",nameEn: "Photography", iconName: "camera.fill",colorHex: "#378ADD", isPlusOnly: false),

        // ── LIFESTYLE (1) ─────────────────────────────────────────────────────
        Category(id: "travel",      nameDe: "Reise",     nameEn: "Travel",      iconName: "airplane",   colorHex: "#D4537E", isPlusOnly: false),
    ]
}

// MARK: - Plus Categories (70 — isPlusOnly: true)

extension Category {

    /// Zusätzliche Kategorien, die nur mit aktivem Plus-Abo verfügbar sind — 70 Kategorien.
    static let plusCategories: [Category] = [

        // ── OUTDOOR PLUS (12) ─────────────────────────────────────────────────
        Category(id: "camping",       nameDe: "Zelten",           nameEn: "Camping",       iconName: "tent.fill",                        colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "fishing",       nameDe: "Angeln",           nameEn: "Fishing",       iconName: "fish.fill",                        colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "surfing",       nameDe: "Surfen",           nameEn: "Surfing",       iconName: "figure.surfing",                   colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "kayaking",      nameDe: "Kajak",            nameEn: "Kayaking",      iconName: "figure.rowing",                    colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "sailing",       nameDe: "Segeln",           nameEn: "Sailing",       iconName: "sailboat.fill",                    colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "horse_riding",  nameDe: "Reiten",           nameEn: "Horse Riding",  iconName: "figure.equestrian.sports",         colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "gardening",     nameDe: "Gärtnern",         nameEn: "Gardening",     iconName: "leaf.fill",                        colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "foraging",      nameDe: "Sammeln",          nameEn: "Foraging",      iconName: "leaf.circle.fill",                 colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "bird_watching", nameDe: "Vogelbeobachtung", nameEn: "Bird Watching", iconName: "bird.fill",                        colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "stargazing",    nameDe: "Sternegucken",     nameEn: "Stargazing",    iconName: "moon.stars.fill",                  colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "paragliding",   nameDe: "Paragliding",      nameEn: "Paragliding",   iconName: "wind",                             colorHex: "#1D9E75", isPlusOnly: true),
        Category(id: "canoeing",      nameDe: "Kanufahren",       nameEn: "Canoeing",      iconName: "oar.2.crossed",                    colorHex: "#1D9E75", isPlusOnly: true),

        // ── SPORT PLUS (12) ───────────────────────────────────────────────────
        Category(id: "basketball",    nameDe: "Basketball",       nameEn: "Basketball",    iconName: "basketball.fill",                  colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "volleyball",    nameDe: "Volleyball",       nameEn: "Volleyball",    iconName: "volleyball.fill",                  colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "boxing",        nameDe: "Boxen",            nameEn: "Boxing",        iconName: "figure.boxing",                    colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "martial_arts",  nameDe: "Kampfsport",       nameEn: "Martial Arts",  iconName: "figure.martial.arts",              colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "badminton",     nameDe: "Badminton",        nameEn: "Badminton",     iconName: "figure.badminton",                 colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "ice_skating",   nameDe: "Eislaufen",        nameEn: "Ice Skating",   iconName: "figure.skating",                   colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "skateboarding", nameDe: "Skateboarden",     nameEn: "Skateboarding", iconName: "figure.skateboarding",             colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "table_tennis",  nameDe: "Tischtennis",      nameEn: "Table Tennis",  iconName: "figure.table.tennis",              colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "archery",       nameDe: "Bogenschiessen",   nameEn: "Archery",       iconName: "figure.archery",                   colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "pilates",       nameDe: "Pilates",          nameEn: "Pilates",       iconName: "figure.core.training",             colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "rugby",         nameDe: "Rugby",            nameEn: "Rugby",         iconName: "rugby.ball.fill",                  colorHex: "#D85A30", isPlusOnly: true),
        Category(id: "ice_hockey",    nameDe: "Eishockey",        nameEn: "Ice Hockey",    iconName: "figure.hockey",                    colorHex: "#D85A30", isPlusOnly: true),

        // ── FOOD PLUS (9) ─────────────────────────────────────────────────────
        Category(id: "cocktail_bar",   nameDe: "Cocktailbar",    nameEn: "Cocktail Bar",   iconName: "wineglass.fill",                   colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "brewery",        nameDe: "Brauerei",       nameEn: "Brewery",        iconName: "mug.fill",                         colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "food_market",    nameDe: "Markt",          nameEn: "Food Market",    iconName: "cart.fill",                        colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "street_food",    nameDe: "Street Food",    nameEn: "Street Food",    iconName: "takeoutbag.and.cup.and.straw.fill", colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "tea_house",      nameDe: "Teehaus",        nameEn: "Tea House",      iconName: "cup.and.saucer.fill",              colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "rooftop_bar",    nameDe: "Rooftop Bar",    nameEn: "Rooftop Bar",    iconName: "building.2.fill",                  colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "cooking_class",  nameDe: "Kochkurs",       nameEn: "Cooking Class",  iconName: "frying.pan.fill",                  colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "bakery",         nameDe: "Bäckerei",       nameEn: "Bakery",         iconName: "birthday.cake.fill",               colorHex: "#BA7517", isPlusOnly: true),
        Category(id: "ice_cream_shop", nameDe: "Eiscafé",        nameEn: "Ice Cream Shop", iconName: "birthday.cake.fill",               colorHex: "#BA7517", isPlusOnly: true),

        // ── KULTUR PLUS (14) ──────────────────────────────────────────────────
        Category(id: "opera",            nameDe: "Oper",          nameEn: "Opera",             iconName: "music.quarternote.3",          colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "comedy_show",      nameDe: "Comedy",        nameEn: "Comedy Show",       iconName: "face.smiling.fill",            colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "art_gallery",      nameDe: "Kunstgalerie",  nameEn: "Art Gallery",       iconName: "paintpalette.fill",            colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "book_fair",        nameDe: "Buchmesse",     nameEn: "Book Fair",         iconName: "books.vertical.fill",          colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "escape_room",      nameDe: "Escape Room",   nameEn: "Escape Room",       iconName: "lock.fill",                    colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "board_game_cafe",  nameDe: "Spielecafé",    nameEn: "Board Game Café",   iconName: "puzzlepiece.fill",             colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "magic_show",       nameDe: "Zaubershow",    nameEn: "Magic Show",        iconName: "theatermasks.fill",            colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "circus",           nameDe: "Zirkus",        nameEn: "Circus",            iconName: "star.circle.fill",             colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "karaoke",          nameDe: "Karaoke",       nameEn: "Karaoke",           iconName: "mic.fill",                     colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "gaming",           nameDe: "Gaming",        nameEn: "Gaming",            iconName: "gamecontroller.fill",          colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "casino",           nameDe: "Casino",        nameEn: "Casino",            iconName: "dollarsign.circle.fill",       colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "live_sport_event", nameDe: "Sportevent",    nameEn: "Live Sport Event",  iconName: "trophy.fill",                  colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "amusement_park",   nameDe: "Freizeitpark",  nameEn: "Amusement Park",    iconName: "ferriswheel",                  colorHex: "#7F77DD", isPlusOnly: true),
        Category(id: "fotospot",         nameDe: "Fotospot",      nameEn: "Photo Spot",        iconName: "mappin.circle.fill",           colorHex: "#7F77DD", isPlusOnly: true),

        // ── KREATIV PLUS (14) ─────────────────────────────────────────────────
        Category(id: "reading",           nameDe: "Lesen",         nameEn: "Reading",           iconName: "book.fill",                        colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "writing",           nameDe: "Schreiben",     nameEn: "Writing",           iconName: "pencil",                           colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "painting",          nameDe: "Malen",         nameEn: "Painting",          iconName: "paintbrush.fill",                  colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "drawing",           nameDe: "Zeichnen",      nameEn: "Drawing",           iconName: "pencil.tip",                       colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "pottery",           nameDe: "Töpfern",       nameEn: "Pottery",           iconName: "cylinder.fill",                    colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "knitting",          nameDe: "Stricken",      nameEn: "Knitting",          iconName: "scissors",                         colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "calligraphy",       nameDe: "Kalligraphie",  nameEn: "Calligraphy",       iconName: "pencil.and.outline",               colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "coding",            nameDe: "Programmieren", nameEn: "Coding",            iconName: "laptopcomputer",                   colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "language_learning", nameDe: "Sprache lernen",nameEn: "Language Learning", iconName: "bubble.left.and.bubble.right.fill", colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "podcast",           nameDe: "Podcast",       nameEn: "Podcast",           iconName: "mic.circle.fill",                  colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "film_making",       nameDe: "Filmdreh",      nameEn: "Film Making",       iconName: "video.fill",                       colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "music_listening",   nameDe: "Musik hören",   nameEn: "Music Listening",   iconName: "headphones",                       colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "puzzles",           nameDe: "Puzzle",        nameEn: "Puzzles",           iconName: "puzzlepiece.fill",                 colorHex: "#378ADD", isPlusOnly: true),
        Category(id: "crafting",          nameDe: "Basteln",       nameEn: "Crafting",          iconName: "scissors.fill",                    colorHex: "#378ADD", isPlusOnly: true),

        // ── LIFESTYLE PLUS (9) ────────────────────────────────────────────────
        Category(id: "shopping",         nameDe: "Shopping",       nameEn: "Shopping",          iconName: "bag.fill",                         colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "spa",              nameDe: "Spa",            nameEn: "Spa",               iconName: "sparkles",                         colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "massage",          nameDe: "Massage",        nameEn: "Massage",           iconName: "hand.raised.fill",                 colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "sauna",            nameDe: "Sauna",          nameEn: "Sauna",             iconName: "thermometer.sun.fill",             colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "volunteering",     nameDe: "Ehrenamt",       nameEn: "Volunteering",      iconName: "hands.and.sparkles.fill",          colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "flea_market",      nameDe: "Flohmarkt",      nameEn: "Flea Market",       iconName: "tag.fill",                         colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "road_trip",        nameDe: "Road Trip",      nameEn: "Road Trip",         iconName: "car.fill",                         colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "city_trip",        nameDe: "Städtetrip",     nameEn: "City Trip",         iconName: "building.2.crop.circle.fill",      colorHex: "#D4537E", isPlusOnly: true),
        Category(id: "wellness_retreat", nameDe: "Wellness",       nameEn: "Wellness Retreat",  iconName: "leaf.fill",                        colorHex: "#D4537E", isPlusOnly: true),
    ]

    /// Alle 100 Kategorien als flache Liste (MVP + Plus).
    static var all: [Category] { mvpCategories + plusCategories }
}
