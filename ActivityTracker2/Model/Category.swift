// Category.swift
// ActivityTracker2 — Remember
// Kategorie-Modell

import Foundation
import SwiftData

// MARK: - Category

@Model
final class Category {

    var id:         String
    var nameDe:     String
    var nameEn:     String
    var iconName:   String
    var colorHex:   String
    var isPlusOnly: Bool
    var cluster:    String

    init(id: String, nameDe: String, nameEn: String,
         iconName: String, colorHex: String,
         isPlusOnly: Bool, cluster: String) {
        self.id         = id
        self.nameDe     = nameDe
        self.nameEn     = nameEn
        self.iconName   = iconName
        self.colorHex   = colorHex
        self.isPlusOnly = isPlusOnly
        self.cluster    = cluster
    }

    /// Lokalisierter Kategoriename anhand des Sprachcodes.
    func localizedName(for code: String) -> String {
        code == "de" ? nameDe : nameEn
    }
}

// MARK: - MVP Categories (Free — isPlusOnly: false)

extension Category {

    static let mvpCategories: [Category] = [

        // Outdoor
        Category(id: "park",       nameDe: "Park",     nameEn: "Park",    iconName: "leaf.fill",           colorHex: "3A7D44", isPlusOnly: false, cluster: "outdoor"),
        Category(id: "beach",      nameDe: "Strand",   nameEn: "Beach",   iconName: "beach.umbrella.fill", colorHex: "3A7D44", isPlusOnly: false, cluster: "outdoor"),
        Category(id: "picnic",     nameDe: "Picknick", nameEn: "Picnic",  iconName: "basket.fill",         colorHex: "3A7D44", isPlusOnly: false, cluster: "outdoor"),
        Category(id: "camping",    nameDe: "Camping",  nameEn: "Camping", iconName: "tent.fill",           colorHex: "3A7D44", isPlusOnly: false, cluster: "outdoor"),

        // Sport
        Category(id: "running",     nameDe: "Laufen",     nameEn: "Running",    iconName: "figure.run",                          colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "hiking",      nameDe: "Wandern",    nameEn: "Hiking",     iconName: "figure.hiking",                       colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "cycling",     nameDe: "Fahrrad",    nameEn: "Cycling",    iconName: "figure.outdoor.cycle",                colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "skiing",      nameDe: "Ski",        nameEn: "Skiing",     iconName: "figure.skiing.downhill",              colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "fitness",     nameDe: "Fitness",    nameEn: "Fitness",    iconName: "figure.strengthtraining.traditional", colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "football",    nameDe: "Fussball",   nameEn: "Soccer",     iconName: "soccerball",                          colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "climbing",    nameDe: "Klettern",   nameEn: "Climbing",   iconName: "figure.climbing",                     colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "swimming",    nameDe: "Schwimmen",  nameEn: "Swimming",   iconName: "figure.pool.swim",                    colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "yoga",        nameDe: "Yoga",       nameEn: "Yoga",       iconName: "figure.yoga",                         colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "tennis",      nameDe: "Tennis",     nameEn: "Tennis",     iconName: "figure.tennis",                       colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "golf",        nameDe: "Golf",       nameEn: "Golf",       iconName: "figure.golf",                         colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "sailing",     nameDe: "Segeln",     nameEn: "Sailing",    iconName: "sailboat.fill",                       colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "kitesurfing", nameDe: "Kitesurfen", nameEn: "Kitesurfing",iconName: "wind",                                colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),
        Category(id: "diving",      nameDe: "Tauchen",    nameEn: "Diving",     iconName: "figure.open.water.swim",              colorHex: "D85A30", isPlusOnly: false, cluster: "sport"),

        // Food
        Category(id: "restaurant",   nameDe: "Restaurant",  nameEn: "Restaurant",  iconName: "fork.knife",          colorHex: "E8A838", isPlusOnly: false, cluster: "food"),
        Category(id: "cafe",         nameDe: "Café",        nameEn: "Café",        iconName: "cup.and.saucer.fill", colorHex: "E8A838", isPlusOnly: false, cluster: "food"),
        Category(id: "bar",          nameDe: "Bar & Kneipe",nameEn: "Bar & Pub",   iconName: "wineglass.fill",      colorHex: "E8A838", isPlusOnly: false, cluster: "food"),
        Category(id: "wine_tasting", nameDe: "Weinprobe",   nameEn: "Wine Tasting",iconName: "wineglass",           colorHex: "E8A838", isPlusOnly: false, cluster: "food"),

        // Kultur
        Category(id: "museum",  nameDe: "Museum",  nameEn: "Museum",  iconName: "building.columns.fill", colorHex: "7F77DD", isPlusOnly: false, cluster: "kultur"),
        Category(id: "cinema",  nameDe: "Kino",    nameEn: "Cinema",  iconName: "film.fill",             colorHex: "7F77DD", isPlusOnly: false, cluster: "kultur"),
        Category(id: "concert", nameDe: "Konzert", nameEn: "Concert", iconName: "music.quarternote.3",   colorHex: "7F77DD", isPlusOnly: false, cluster: "kultur"),
        Category(id: "theater", nameDe: "Theater", nameEn: "Theater", iconName: "theatermasks.fill",     colorHex: "7F77DD", isPlusOnly: false, cluster: "kultur"),

        // Kreativ
        Category(id: "journal",    nameDe: "Tagebuch", nameEn: "Journal",    iconName: "book.fill",   colorHex: "378ADD", isPlusOnly: false, cluster: "kreativ"),
        Category(id: "photo_spot", nameDe: "Fotospot", nameEn: "Photo Spot", iconName: "camera.fill", colorHex: "378ADD", isPlusOnly: false, cluster: "kreativ"),

        // Lifestyle
        Category(id: "travel", nameDe: "Reise", nameEn: "Travel", iconName: "airplane", colorHex: "9B59B6", isPlusOnly: false, cluster: "lifestyle"),
    ]
}

// MARK: - Plus Categories (isPlusOnly: true)

extension Category {

    static let plusCategories: [Category] = [

        // Sport PLUS
        Category(id: "basketball",        nameDe: "Basketball",     nameEn: "Basketball",    iconName: "basketball.fill",           colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "dancing",           nameDe: "Tanzen",         nameEn: "Dancing",       iconName: "figure.socialdance",        colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "surfing",           nameDe: "Surfen",         nameEn: "Surfing",       iconName: "figure.surfing",            colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "kayaking",          nameDe: "Kajak",          nameEn: "Kayaking",      iconName: "figure.water.fitness",      colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "horse_riding",      nameDe: "Reiten",         nameEn: "Horse Riding",  iconName: "figure.equestrian.sports",  colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "paragliding",       nameDe: "Paragliding",    nameEn: "Paragliding",   iconName: "bird.fill",                 colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "canoeing",          nameDe: "Kanu",           nameEn: "Canoeing",      iconName: "oar.2.crossed",             colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "volleyball",        nameDe: "Volleyball",     nameEn: "Volleyball",    iconName: "volleyball.fill",           colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "boxing",            nameDe: "Boxen",          nameEn: "Boxing",        iconName: "figure.boxing",             colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "martial_arts",      nameDe: "Kampfsport",     nameEn: "Martial Arts",  iconName: "figure.martial.arts",       colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "badminton",         nameDe: "Badminton",      nameEn: "Badminton",     iconName: "figure.badminton",          colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "ice_skating",       nameDe: "Eislaufen",      nameEn: "Ice Skating",   iconName: "figure.skating",            colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "skateboarding",     nameDe: "Skateboarden",   nameEn: "Skateboarding", iconName: "figure.skateboarding",      colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "table_tennis",      nameDe: "Tischtennis",    nameEn: "Table Tennis",  iconName: "figure.table.tennis",       colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "archery",           nameDe: "Bogenschiessen", nameEn: "Archery",       iconName: "figure.archery",            colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "pilates",           nameDe: "Pilates",        nameEn: "Pilates",       iconName: "figure.pilates",            colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "rugby",             nameDe: "Rugby",          nameEn: "Rugby",         iconName: "figure.rugby",              colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "ice_hockey",        nameDe: "Eishockey",      nameEn: "Ice Hockey",    iconName: "figure.ice.hockey",         colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "baseball",          nameDe: "Baseball",       nameEn: "Baseball",      iconName: "figure.baseball",           colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "american_football", nameDe: "Football",       nameEn: "Football",      iconName: "football.fill",             colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "cross_country",     nameDe: "Langlaufen",     nameEn: "Cross-Country", iconName: "figure.skiing.crosscountry",colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "fishing",           nameDe: "Angeln",         nameEn: "Fishing",       iconName: "figure.fishing",            colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "billiards",         nameDe: "Billard",        nameEn: "Billiards",     iconName: "circle.grid.3x3.fill",      colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),
        Category(id: "bouldering",        nameDe: "Bouldern",       nameEn: "Bouldering",    iconName: "figure.climbing",           colorHex: "D85A30", isPlusOnly: true, cluster: "sport"),

        // Outdoor PLUS
        Category(id: "viewpoint",    nameDe: "Aussichtspunkt",  nameEn: "Viewpoint",    iconName: "binoculars.fill",   colorHex: "3A7D44", isPlusOnly: true, cluster: "outdoor"),
        Category(id: "camping_wild", nameDe: "Zelten",          nameEn: "Wild Camping", iconName: "tent.2.fill",       colorHex: "3A7D44", isPlusOnly: true, cluster: "outdoor"),
        Category(id: "foraging",     nameDe: "Sammeln",         nameEn: "Foraging",     iconName: "leaf.circle.fill",  colorHex: "3A7D44", isPlusOnly: true, cluster: "outdoor"),
        Category(id: "birdwatching", nameDe: "Vogelbeobachtung",nameEn: "Birdwatching", iconName: "binoculars",        colorHex: "3A7D44", isPlusOnly: true, cluster: "outdoor"),
        Category(id: "geocaching",   nameDe: "Geocaching",      nameEn: "Geocaching",   iconName: "map.fill",          colorHex: "3A7D44", isPlusOnly: true, cluster: "outdoor"),
        Category(id: "sightseeing",  nameDe: "Sehenswürdigkeit",nameEn: "Sightseeing",  iconName: "camera.viewfinder", colorHex: "3A7D44", isPlusOnly: true, cluster: "outdoor"),

        // Food PLUS
        Category(id: "cocktail_bar", nameDe: "Cocktailbar", nameEn: "Cocktail Bar", iconName: "wineglass.fill",         colorHex: "E8A838", isPlusOnly: true, cluster: "food"),
        Category(id: "market",       nameDe: "Markt",       nameEn: "Market",       iconName: "bag.fill",               colorHex: "E8A838", isPlusOnly: true, cluster: "food"),
        Category(id: "street_food",  nameDe: "Street Food", nameEn: "Street Food",  iconName: "fork.knife.circle.fill", colorHex: "E8A838", isPlusOnly: true, cluster: "food"),
        Category(id: "rooftop_bar",  nameDe: "Rooftop Bar", nameEn: "Rooftop Bar",  iconName: "building.2.fill",        colorHex: "E8A838", isPlusOnly: true, cluster: "food"),
        Category(id: "ice_cream",    nameDe: "Eiscafé",     nameEn: "Ice Cream",    iconName: "birthday.cake.fill",     colorHex: "E8A838", isPlusOnly: true, cluster: "food"),
        Category(id: "beer_garden",  nameDe: "Biergarten",  nameEn: "Beer Garden",  iconName: "mug.fill",               colorHex: "E8A838", isPlusOnly: true, cluster: "food"),

        // Kultur PLUS
        Category(id: "festival",      nameDe: "Festival",     nameEn: "Festival",       iconName: "party.popper",        colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "opera",         nameDe: "Oper",         nameEn: "Opera",          iconName: "theatermasks.fill",           colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "comedy",        nameDe: "Comedy",       nameEn: "Comedy",         iconName: "face.smiling.fill",   colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "art_gallery",   nameDe: "Kunstgalerie", nameEn: "Art Gallery",    iconName: "photo.artframe",      colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "circus",        nameDe: "Zirkus",       nameEn: "Circus",         iconName: "star.circle.fill",    colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "karaoke",       nameDe: "Karaoke",      nameEn: "Karaoke",        iconName: "mic.fill",            colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "gaming",        nameDe: "Gaming",       nameEn: "Gaming",         iconName: "gamecontroller.fill", colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "casino",        nameDe: "Casino",       nameEn: "Casino",         iconName: "dice.fill",           colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "amusement_park",nameDe: "Freizeitpark", nameEn: "Amusement Park", iconName: "sparkles",            colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),
        Category(id: "jazz",          nameDe: "Jazz",         nameEn: "Jazz",           iconName: "music.note",          colorHex: "7F77DD", isPlusOnly: true, cluster: "kultur"),

        // Kreativ PLUS
        Category(id: "writing",         nameDe: "Schreiben",   nameEn: "Writing", iconName: "pencil",           colorHex: "378ADD", isPlusOnly: true, cluster: "kreativ"),
        Category(id: "painting",        nameDe: "Malen",       nameEn: "Painting",iconName: "paintbrush.pointed.fill",  colorHex: "378ADD", isPlusOnly: true, cluster: "kreativ"),
        Category(id: "drawing",         nameDe: "Zeichnen",    nameEn: "Drawing", iconName: "pencil.tip",       colorHex: "378ADD", isPlusOnly: true, cluster: "kreativ"),
        Category(id: "podcast",         nameDe: "Podcast",     nameEn: "Podcast", iconName: "mic.circle.fill",  colorHex: "378ADD", isPlusOnly: true, cluster: "kreativ"),
        Category(id: "filming",         nameDe: "Filmdreh",    nameEn: "Filming", iconName: "video.fill",       colorHex: "378ADD", isPlusOnly: true, cluster: "kreativ"),
        Category(id: "music_listening", nameDe: "Musik hören", nameEn: "Music",   iconName: "headphones",       colorHex: "378ADD", isPlusOnly: true, cluster: "kreativ"),
        Category(id: "reading",         nameDe: "Lesen",       nameEn: "Reading", iconName: "book.closed.fill", colorHex: "378ADD", isPlusOnly: true, cluster: "kreativ"),

        // Lifestyle PLUS
        Category(id: "shopping",     nameDe: "Shopping",    nameEn: "Shopping",    iconName: "bag.fill",                    colorHex: "9B59B6", isPlusOnly: true, cluster: "lifestyle"),
        Category(id: "spa",          nameDe: "Spa",         nameEn: "Spa",         iconName: "sparkles",                    colorHex: "9B59B6", isPlusOnly: true, cluster: "lifestyle"),
        Category(id: "flea_market",  nameDe: "Flohmarkt",   nameEn: "Flea Market", iconName: "tag.fill",                    colorHex: "9B59B6", isPlusOnly: true, cluster: "lifestyle"),
        Category(id: "city_trip",    nameDe: "Städtetrip",  nameEn: "City Trip",   iconName: "building.2.crop.circle.fill", colorHex: "9B59B6", isPlusOnly: true, cluster: "lifestyle"),
        Category(id: "vintage_shop", nameDe: "Vintage Shop",nameEn: "Vintage Shop",iconName: "tshirt.fill",                 colorHex: "9B59B6", isPlusOnly: true, cluster: "lifestyle"),
    ]

    /// Alle Kategorien als flache Liste (MVP + Plus).
    static var all: [Category] { mvpCategories + plusCategories }
}
