// PreviewDataHelper.swift
// ActivityTracker2 — Remember
// Debug-Sample-Daten: 90 Aktivitäten auf 5 Kontinenten

#if DEBUG

import Foundation
import SwiftData

// MARK: - PreviewDataHelper

/// Fügt beim ersten App-Start im Debug-Modus 90 Sample-Activities in SwiftData ein.
/// Wird nur ausgeführt wenn der Store vollständig leer ist — keine Duplikate möglich.
///
/// Aufruf: `PreviewDataHelper.insertSampleDataIfNeeded(context: modelContext)`
/// — einmalig in `ActivityTracker2App.init()`, nach ModelContainer-Setup.
enum PreviewDataHelper {

    /// Prüft ob SwiftData leer ist und fügt ggf. 90 Sample-Activities ein.
    /// - Parameter context: Aktiver `ModelContext` aus `modelContainer.mainContext`.
    static func insertSampleDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Activity>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        for activity in sampleActivities {
            context.insert(activity)
            if let location = activity.location {
                context.insert(location)
            }
        }
        try? context.save()
    }

    // MARK: - Sample Activities (90)

    private static var sampleActivities: [Activity] {[

        // ━━━ EUROPA (25) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Activity(categoryId: "photography", date: .daysAgo(2), title: "Sonnenaufgang am Marienplatz",
            text: "Um 6 Uhr morgens fast allein auf dem Platz. Das goldene Licht auf dem Rathaus war unbeschreiblich schön.",
            isFavorite: true,
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "yoga", date: .daysAgo(3), title: "Yoga im Englischen Garten",
            text: "Morgenyoga mit Blick auf den Monopteros. Die Stadt erwacht langsam, nur Vogelgezwitscher.",
            location: Location(latitude: 48.1642, longitude: 11.6054, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cafe", date: .daysAgo(8), title: "Frühstück im Café de Flore",
            text: "Croissant, Café au lait und die Pariser Morgenluft. So muss das Leben sein.",
            isFavorite: true,
            location: Location(latitude: 48.8539, longitude: 2.3329, city: "Paris", region: "Île-de-France", country: "Frankreich")),

        Activity(categoryId: "museum", date: .daysAgo(9), title: "Louvre bei Nacht",
            text: "Die Pyramide leuchtet golden. Mona Lisa fast allein betrachten nach Museumsschluss — unvergesslich.",
            isFavorite: true,
            location: Location(latitude: 48.8606, longitude: 2.3376, city: "Paris", region: "Île-de-France", country: "Frankreich")),

        Activity(categoryId: "museum", date: .daysAgo(15), title: "Sagrada Família bei Sonnenuntergang",
            text: "Die Farben durch die Buntglasfenster haben mich sprachlos gemacht. Gaudís Genie ist zeitlos.",
            isFavorite: true,
            location: Location(latitude: 41.4036, longitude: 2.1744, city: "Barcelona", region: "Katalonien", country: "Spanien")),

        Activity(categoryId: "restaurant", date: .daysAgo(17), title: "Tapas-Bar in El Born",
            text: "Patatas bravas, Gambas al ajillo, Cava. Barcelona lebt und isst auf der Strasse.",
            location: Location(latitude: 41.3851, longitude: 2.1834, city: "Barcelona", region: "Katalonien", country: "Spanien")),

        Activity(categoryId: "restaurant", date: .daysAgo(22), title: "Pasta bei Nonna Rosa",
            text: "Hausgemachte Tagliatelle al ragù. Die beste Pasta meines Lebens, in einer kleinen Trattoria versteckt.",
            location: Location(latitude: 41.9028, longitude: 12.4964, city: "Rom", region: "Latium", country: "Italien")),

        Activity(categoryId: "hiking", date: .daysAgo(24), title: "Borghese-Gärten Rom",
            text: "Zwei Stunden durch den grössten Park Roms. Pinien, Brunnen, Stille — mitten in der ewigen Stadt.",
            location: Location(latitude: 41.9149, longitude: 12.4922, city: "Rom", region: "Latium", country: "Italien")),

        Activity(categoryId: "travel", date: .daysAgo(30), title: "Grachtenfahrt Amsterdam",
            text: "Mit dem Hausboot durch die Kanäle. Die Spiegelungen der alten Häuser im Wasser sind magisch.",
            location: Location(latitude: 52.3676, longitude: 4.9041, city: "Amsterdam", region: "Noord-Holland", country: "Niederlande")),

        Activity(categoryId: "cycling", date: .daysAgo(31), title: "Radeln entlang der Amstel",
            text: "30km entlang des Flusses bis nach Ouderkerk. Flaches Land, Windmühlen, Käsebauernhöfe — Holland pur.",
            location: Location(latitude: 52.3105, longitude: 4.9138, city: "Amsterdam", region: "Noord-Holland", country: "Niederlande")),

        Activity(categoryId: "concert", date: .daysAgo(35), title: "Wiener Philharmoniker",
            text: "Beethoven im Musikverein. Der Klang in diesem Saal ist einmalig — Gänsehaut von Anfang bis Ende.",
            isFavorite: true,
            location: Location(latitude: 48.2002, longitude: 16.3726, city: "Wien", region: "Wien", country: "Österreich")),

        Activity(categoryId: "cafe", date: .daysAgo(36), title: "Café Central Wien",
            text: "Melange und Apfelstrudel wie vor 100 Jahren. Die hohen Decken, die Marmortische — pure Nostalgie.",
            location: Location(latitude: 48.2093, longitude: 16.3658, city: "Wien", region: "Wien", country: "Österreich")),

        Activity(categoryId: "restaurant", date: .daysAgo(37), title: "Wiener Schnitzel beim Figlmüller",
            text: "Teller-übergreifendes Schnitzel, Erdäpfelsalat, Grüner Veltliner. Wien auf dem Teller.",
            isFavorite: true,
            location: Location(latitude: 48.2082, longitude: 16.3738, city: "Wien", region: "Wien", country: "Österreich")),

        Activity(categoryId: "hiking", date: .daysAgo(40), title: "Wanderung auf dem Rigi",
            text: "4 Stunden Aufstieg, Wolken unter uns, Stille über uns. Dieser Ausblick macht jeden Schritt wert.",
            isFavorite: true,
            location: Location(latitude: 47.0557, longitude: 8.4842, city: "Rigi", region: "Schwyz", country: "Schweiz")),

        Activity(categoryId: "cafe", date: .daysAgo(42), title: "Café Schober Zürich",
            text: "Hot Chocolate im ältesten Café Zürichs. Samtene Wände, Goldrahmen, Stille — wie aus einer anderen Zeit.",
            location: Location(latitude: 47.3724, longitude: 8.5422, city: "Zürich", region: "Zürich", country: "Schweiz")),

        Activity(categoryId: "skiing", date: .daysAgo(43), title: "Tiefschnee in Verbier",
            text: "Unberührter Powder auf dem Mont-Fort-Gletscher. Schweizer Skifahren auf höchstem Niveau.",
            isFavorite: true,
            location: Location(latitude: 46.0966, longitude: 7.2287, city: "Verbier", region: "Wallis", country: "Schweiz")),

        Activity(categoryId: "restaurant", date: .daysAgo(45), title: "Borough Market London",
            text: "Käse, frisches Brot, Austern und Craft Beer. London ist eine Foodie-Stadt par excellence.",
            location: Location(latitude: 51.5055, longitude: -0.0910, city: "London", region: "England", country: "Grossbritannien")),

        Activity(categoryId: "hiking", date: .daysAgo(47), title: "Hampstead Heath Sonnenaufgang",
            text: "Auf dem Parliament Hill bei Sonnenaufgang. London liegt unter einem roségoldenen Himmel.",
            location: Location(latitude: 51.5608, longitude: -0.1617, city: "London", region: "England", country: "Grossbritannien")),

        Activity(categoryId: "cycling", date: .daysAgo(50), title: "Radtour durch die Provence",
            text: "Lavendelfelder so weit das Auge reicht. 60km, Rückenwind, Rosé am Ziel.",
            isFavorite: true,
            location: Location(latitude: 43.9493, longitude: 5.1175, city: "Valensole", region: "Provence", country: "Frankreich")),

        Activity(categoryId: "skiing", date: .daysAgo(60), title: "Après-Ski in Lech",
            text: "Perfekter Pulverschnee am Morgen, Hüttengaudi am Nachmittag. So muss Skifahren sein.",
            isFavorite: true,
            location: Location(latitude: 47.2137, longitude: 10.1443, city: "Lech", region: "Vorarlberg", country: "Österreich")),

        Activity(categoryId: "concert", date: .daysAgo(70), title: "Flamenco Show in Sevilla",
            text: "Echte Flamenco-Künstler in einem kleinen Tablao. Leidenschaft pur — Tränen in den Augen.",
            isFavorite: true,
            location: Location(latitude: 37.3886, longitude: -5.9823, city: "Sevilla", region: "Andalusien", country: "Spanien")),

        Activity(categoryId: "swimming", date: .daysAgo(75), title: "Schwimmen im Gardasee",
            text: "Kristallklares Wasser, 24 Grad, Berge ringsum. Der Gardasee ist wie ein Traum.",
            location: Location(latitude: 45.6389, longitude: 10.7102, city: "Riva del Garda", region: "Trentino", country: "Italien")),

        Activity(categoryId: "festival", date: .daysAgo(78), title: "Oktoberfest München",
            text: "Wiesn-Opening: Tracht, Zelt, Mass Bier, Oompah-Band. Jedes Mal anders, jedes Mal gleich schön.",
            isFavorite: true,
            location: Location(latitude: 48.1320, longitude: 11.5498, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(82), title: "Zugspitze Gipfelsteig",
            text: "Deutschlands höchster Punkt. Der Aufstieg war hart, der Blick auf drei Länder der beste Lohn.",
            isFavorite: true,
            location: Location(latitude: 47.4211, longitude: 10.9853, city: "Garmisch-Partenkirchen", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "restaurant", date: .daysAgo(85), title: "Pintxos in San Sebastián",
            text: "Bar-Hopping durch die Altstadt. Jede Bar, zwei Pintxos — das beste Essen der Welt kostet hier 2 Euro.",
            isFavorite: true,
            location: Location(latitude: 43.3213, longitude: -1.9856, city: "San Sebastián", region: "Baskenland", country: "Spanien")),

        // ━━━ ASIEN (20) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Activity(categoryId: "hiking", date: .daysAgo(92), title: "Bambuswald Arashiyama",
            text: "Früh morgens fast allein zwischen den Bambusstämmen. Das Licht, die Stille — meditativ.",
            isFavorite: true,
            location: Location(latitude: 35.0094, longitude: 135.6694, city: "Kyoto", region: "Kyoto", country: "Japan")),

        Activity(categoryId: "hiking", date: .daysAgo(93), title: "Fushimi Inari Torii-Tore",
            text: "3000 rote Torii-Tore den Berg hinauf. Bei Sonnenaufgang fast allein — spirituell und magisch.",
            isFavorite: true,
            location: Location(latitude: 34.9671, longitude: 135.7727, city: "Kyoto", region: "Kyoto", country: "Japan")),

        Activity(categoryId: "festival", date: .daysAgo(94), title: "Kirschblüte Maruyama Park",
            text: "Hanami unter blühenden Kirschbäumen. Sakeflaschen, Lachen, rosa Blüten überall. Japan at its best.",
            isFavorite: true,
            location: Location(latitude: 35.0039, longitude: 135.7817, city: "Kyoto", region: "Kyoto", country: "Japan")),

        Activity(categoryId: "photography", date: .daysAgo(95), title: "Sonnenuntergang Ubud",
            text: "Rote Reisfelder im Abendlicht, Gamelan-Musik aus dem Tempel. Bali hat mein Herz gestohlen.",
            isFavorite: true,
            location: Location(latitude: -8.5069, longitude: 115.2625, city: "Ubud", region: "Bali", country: "Indonesien")),

        Activity(categoryId: "yoga", date: .daysAgo(96), title: "Yoga Retreat Bali",
            text: "7 Tage Yoga, Meditation und Stille in den Reisfeldern. Zurück zu mir selbst gefunden.",
            isFavorite: true,
            location: Location(latitude: -8.5069, longitude: 115.2625, city: "Ubud", region: "Bali", country: "Indonesien")),

        Activity(categoryId: "swimming", date: .daysAgo(97), title: "Surfen Kuta Beach",
            text: "Erste Surfstunde, 10 Mal gefallen, einmal gestanden. Das Stehen war es wert.",
            location: Location(latitude: -8.7215, longitude: 115.1685, city: "Kuta", region: "Bali", country: "Indonesien")),

        Activity(categoryId: "restaurant", date: .daysAgo(100), title: "Streetfood Khao San Road",
            text: "Pad Thai für 1 Euro, Mango Sticky Rice als Dessert. Bangkok ist eine Streetfood-Stadt.",
            location: Location(latitude: 13.7584, longitude: 100.4979, city: "Bangkok", region: "Bangkok", country: "Thailand")),

        Activity(categoryId: "cafe", date: .daysAgo(101), title: "Coffeeshop Thong Lo Bangkok",
            text: "Specialty Coffee in einem alten Shophouse. Die Baristas sind echte Künstler.",
            location: Location(latitude: 13.7310, longitude: 100.5836, city: "Bangkok", region: "Bangkok", country: "Thailand")),

        Activity(categoryId: "hiking", date: .daysAgo(103), title: "Doi Suthep Tempel",
            text: "300 Nagas-Treppenstufen hinauf, Blick über Chiang Mai. Der Tempel leuchtet gold in der Abendsonne.",
            location: Location(latitude: 18.8047, longitude: 98.9218, city: "Chiang Mai", region: "Chiang Mai", country: "Thailand")),

        Activity(categoryId: "restaurant", date: .daysAgo(111), title: "Nachtmarkt Singapur",
            text: "Hawker Centre Lau Pa Sat — Satay, Laksa, Chili Crab. Alle Kulturen in einem Markt.",
            location: Location(latitude: 1.2803, longitude: 103.8503, city: "Singapur", region: "Singapur", country: "Singapur")),

        Activity(categoryId: "swimming", date: .daysAgo(110), title: "Marina Bay Sands Rooftop",
            text: "Infinity Pool über dem Singapur Skyline. Eine der verrücktesten Erfahrungen meines Lebens.",
            isFavorite: true,
            location: Location(latitude: 1.2838, longitude: 103.8607, city: "Singapur", region: "Singapur", country: "Singapur")),

        Activity(categoryId: "travel", date: .daysAgo(112), title: "Shinkansen Tokyo–Kyoto",
            text: "320 km/h, Fuji durchs Fenster, Bento in der Hand. Der Shinkansen ist japanische Perfektion.",
            isFavorite: true,
            location: Location(latitude: 35.6812, longitude: 139.7671, city: "Tokyo", region: "Tokyo", country: "Japan")),

        Activity(categoryId: "concert", date: .daysAgo(115), title: "K-Pop Konzert Seoul",
            text: "40.000 Fans, perfekte Choreografie, Lightsticks soweit das Auge reicht. Energie pur.",
            isFavorite: true,
            location: Location(latitude: 37.5665, longitude: 126.9780, city: "Seoul", region: "Seoul", country: "Südkorea")),

        Activity(categoryId: "cafe", date: .daysAgo(116), title: "Kaffeezeremonie Seoul",
            text: "Traditionelle koreanische Teezeremonie in einem Hanok-Haus. Langsamkeit als Kunst.",
            location: Location(latitude: 37.5796, longitude: 126.9830, city: "Seoul", region: "Seoul", country: "Südkorea")),

        Activity(categoryId: "restaurant", date: .daysAgo(90), title: "Tsukiji Frühstück Tokyo",
            text: "Frischester Thunfisch um 5 Uhr morgens. Die Atmosphäre auf dem Markt ist einzigartig.",
            isFavorite: true,
            location: Location(latitude: 35.6654, longitude: 139.7707, city: "Tokyo", region: "Tokyo", country: "Japan")),

        Activity(categoryId: "bar", date: .daysAgo(90), title: "Sake-Bar Shinjuku",
            text: "Golden Gai — winzige Bars, 6 Sitzplätze, echter japanischer Sake. So unvergesslich.",
            isFavorite: true,
            location: Location(latitude: 35.6938, longitude: 139.7036, city: "Tokyo", region: "Tokyo", country: "Japan")),

        Activity(categoryId: "museum", date: .daysAgo(91), title: "Teamlab Planets Tokyo",
            text: "Digital Art, Spiegelräume, Licht und Wasser. Kunst die man nicht nur sieht sondern fühlt.",
            location: Location(latitude: 35.6467, longitude: 139.7838, city: "Tokyo", region: "Tokyo", country: "Japan")),

        Activity(categoryId: "restaurant", date: .daysAgo(91), title: "Ramen-Bar Fuunji Tokyo",
            text: "Tsukemen-Ramen — dicker Brühe-Dip, frische Nudeln. 45 Minuten angestanden, kein Bereuen.",
            isFavorite: true,
            location: Location(latitude: 35.6897, longitude: 139.6983, city: "Tokyo", region: "Tokyo", country: "Japan")),

        Activity(categoryId: "photography", date: .daysAgo(120), title: "Sonnenaufgang Angkor Wat",
            text: "Um 4 Uhr aufgestanden, 45 Minuten Fahrrad durch den Dschungel. Dieser Sonnenaufgang — keine Worte.",
            isFavorite: true,
            location: Location(latitude: 13.4125, longitude: 103.8670, city: "Siem Reap", region: "Siem Reap", country: "Kambodscha")),

        Activity(categoryId: "hiking", date: .daysAgo(125), title: "Wandern auf Lantau Island",
            text: "Der Lantau Trail über den Sunset Peak. Hongkong unten im Dunst, Stille oben — surreal.",
            location: Location(latitude: 22.2552, longitude: 113.9444, city: "Hongkong", region: "Lantau", country: "Hongkong")),

        // ━━━ NORD- & SÜDAMERIKA (20) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Activity(categoryId: "hiking", date: .daysAgo(130), title: "Central Park Morning Run",
            text: "6km durch den Park bei Sonnenaufgang. New York schläft noch, nur die Jogger sind wach.",
            location: Location(latitude: 40.7851, longitude: -73.9683, city: "New York", region: "New York", country: "USA")),

        Activity(categoryId: "concert", date: .daysAgo(131), title: "Jazz im Village Vanguard",
            text: "Legendärer Jazzclub in Greenwich Village. Miles Davis hat hier gespielt — man spürt die Geschichte.",
            isFavorite: true,
            location: Location(latitude: 40.7335, longitude: -74.0027, city: "New York", region: "New York", country: "USA")),

        Activity(categoryId: "cafe", date: .daysAgo(132), title: "Kaffee in Brooklyn",
            text: "Intelligentsia Coffee, Flat White, MacBook und die beste People-Watching-Terrasse New Yorks.",
            location: Location(latitude: 40.6892, longitude: -73.9442, city: "Brooklyn", region: "New York", country: "USA")),

        Activity(categoryId: "photography", date: .daysAgo(133), title: "Highline New York",
            text: "Der alte Güterzug-Viadukt als Park — Kunst, Pflanzen, Hudson River View. New York kann alles.",
            location: Location(latitude: 40.7480, longitude: -74.0048, city: "New York", region: "New York", country: "USA")),

        Activity(categoryId: "museum", date: .daysAgo(134), title: "Metropolitan Museum of Art",
            text: "Ägyptische Mumien, impressionistische Gemälde, japanische Schwerter. Das Met ist endlos.",
            isFavorite: true,
            location: Location(latitude: 40.7794, longitude: -73.9632, city: "New York", region: "New York", country: "USA")),

        Activity(categoryId: "concert", date: .daysAgo(140), title: "Tango in Buenos Aires",
            text: "Milonga in San Telmo um Mitternacht. Fremde Menschen, eine Musik, eine Sprache.",
            isFavorite: true,
            location: Location(latitude: -34.6214, longitude: -58.3731, city: "Buenos Aires", region: "Buenos Aires", country: "Argentinien")),

        Activity(categoryId: "bar", date: .daysAgo(141), title: "Bar-Crawl Buenos Aires",
            text: "Palermo Soho bei Nacht — von Bar zu Bar, Malbec und Mate, neue Freunde aus aller Welt.",
            location: Location(latitude: -34.5875, longitude: -58.4318, city: "Buenos Aires", region: "Buenos Aires", country: "Argentinien")),

        Activity(categoryId: "restaurant", date: .daysAgo(142), title: "Parrilla La Brigada",
            text: "Bestes Steak meines Lebens. Asado am offenen Feuer, Malbec aus Mendoza. Argentinien.",
            isFavorite: true,
            location: Location(latitude: -34.6218, longitude: -58.3712, city: "Buenos Aires", region: "Buenos Aires", country: "Argentinien")),

        Activity(categoryId: "festival", date: .daysAgo(143), title: "Boca Juniors im La Bombonera",
            text: "Argentinischer Fussball ist eine Religion. Die Stimmung im Stadion — unbeschreiblich.",
            isFavorite: true,
            location: Location(latitude: -34.6354, longitude: -58.3644, city: "Buenos Aires", region: "Buenos Aires", country: "Argentinien")),

        Activity(categoryId: "beach", date: .daysAgo(145), title: "Copacabana Strand",
            text: "Volleyball, Caipirinhas, Samba aus der Ferne. Rio de Janeiro lebt und atmet am Strand.",
            isFavorite: true,
            location: Location(latitude: -22.9714, longitude: -43.1823, city: "Rio de Janeiro", region: "Rio de Janeiro", country: "Brasilien")),

        Activity(categoryId: "viewpoint", date: .daysAgo(146), title: "Cristo Redentor",
            text: "Wolken um den Kopf der Statue, die Stadt unter uns. Rio von oben ist atemberaubend.",
            isFavorite: true,
            location: Location(latitude: -22.9519, longitude: -43.2105, city: "Rio de Janeiro", region: "Rio de Janeiro", country: "Brasilien")),

        Activity(categoryId: "festival", date: .daysAgo(147), title: "Carnaval Rio de Janeiro",
            text: "Samba-Schule, Kostüme, Trommeln die man im Brustkorb fühlt. Der grösste Strassenkarneval der Welt.",
            isFavorite: true,
            location: Location(latitude: -22.9035, longitude: -43.1752, city: "Rio de Janeiro", region: "Rio de Janeiro", country: "Brasilien")),

        Activity(categoryId: "hiking", date: .daysAgo(150), title: "Wanderung Grouse Mountain",
            text: "Der Grind — 2.9km straight up. Oben Blick auf Vancouver und den Pazifik. Schweissgebadet und glücklich.",
            location: Location(latitude: 49.3732, longitude: -123.0788, city: "Vancouver", region: "British Columbia", country: "Kanada")),

        Activity(categoryId: "yoga", date: .daysAgo(151), title: "Yoga Sunset Vancouver",
            text: "Outdoor Yoga im Jericho Beach Park mit Blick auf die Berge. Frieden pur.",
            location: Location(latitude: 49.2734, longitude: -123.1988, city: "Vancouver", region: "British Columbia", country: "Kanada")),

        Activity(categoryId: "skiing", date: .daysAgo(155), title: "Ski Whistler Blackcomb",
            text: "Nordamerikas grösstes Skigebiet. Powder auf dem Blackcomb Glacier — unvergesslich.",
            isFavorite: true,
            location: Location(latitude: 50.1163, longitude: -122.9574, city: "Whistler", region: "British Columbia", country: "Kanada")),

        Activity(categoryId: "cafe", date: .daysAgo(156), title: "Kafka's Coffee Vancouver",
            text: "Bester Filter-Kaffee der Stadt, in einem kleinen Laden im Commercial Drive. Regen draussen, warm drinnen.",
            location: Location(latitude: 49.2611, longitude: -123.0693, city: "Vancouver", region: "British Columbia", country: "Kanada")),

        Activity(categoryId: "museum", date: .daysAgo(160), title: "Frida Kahlo Museum",
            text: "Das Blaue Haus in Coyoacán. Fridahos Schmerz und Stärke in jedem Pinselstrich spürbar.",
            isFavorite: true,
            location: Location(latitude: 19.3554, longitude: -99.1627, city: "Mexico City", region: "CDMX", country: "Mexiko")),

        Activity(categoryId: "restaurant", date: .daysAgo(161), title: "Mercado de San Juan",
            text: "Chapulines, Mezcal, frischer Käse. Mexico City ist eine der grossen Foodie-Städte der Welt.",
            location: Location(latitude: 19.4326, longitude: -99.1332, city: "Mexico City", region: "CDMX", country: "Mexiko")),

        Activity(categoryId: "festival", date: .daysAgo(170), title: "Lollapalooza Chicago",
            text: "3 Tage, 8 Bühnen, 100 Acts. Chicago im August — Musik, Sonne und 100.000 Menschen.",
            isFavorite: true,
            location: Location(latitude: 41.8719, longitude: -87.6278, city: "Chicago", region: "Illinois", country: "USA")),

        Activity(categoryId: "travel", date: .daysAgo(175), title: "Route 66 Road Trip",
            text: "Chicago bis Santa Monica — 3940km, 14 Tage, unzählige Diners. Amerika pur.",
            isFavorite: true,
            location: Location(latitude: 34.0195, longitude: -118.4912, city: "Santa Monica", region: "Kalifornien", country: "USA")),

        // ━━━ AFRIKA (15) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Activity(categoryId: "hiking", date: .daysAgo(180), title: "Tafelberg Wanderung",
            text: "3 Stunden Aufstieg, oben liegt Kapstadt zu unseren Füssen und beide Ozeane treffen sich.",
            isFavorite: true,
            location: Location(latitude: -33.9628, longitude: 18.4098, city: "Kapstadt", region: "Westkap", country: "Südafrika")),

        Activity(categoryId: "beach", date: .daysAgo(181), title: "Camps Bay Strand",
            text: "Weisser Sand, Tafelberg als Kulisse, Atlantik-Wellen. Kapstadt hat die schönste Lage der Welt.",
            isFavorite: true,
            location: Location(latitude: -33.9494, longitude: 18.3753, city: "Kapstadt", region: "Westkap", country: "Südafrika")),

        Activity(categoryId: "concert", date: .daysAgo(183), title: "Township Jazz Kapstadt",
            text: "Live Jazz in Langa Township. Echte Musiker, echte Gemeinschaft — das wahre Kapstadt.",
            isFavorite: true,
            location: Location(latitude: -33.9432, longitude: 18.5266, city: "Langa", region: "Westkap", country: "Südafrika")),

        Activity(categoryId: "bar", date: .daysAgo(182), title: "V&A Waterfront Kapstadt",
            text: "Craft Beer mit Blick auf den Hafen. Die Atmosphäre ist einzigartig — Afrika meets Europa.",
            location: Location(latitude: -33.9042, longitude: 18.4197, city: "Kapstadt", region: "Westkap", country: "Südafrika")),

        Activity(categoryId: "cafe", date: .daysAgo(184), title: "Mintea Café Marrakesch",
            text: "Frischer Pfefferminztee auf der Dachterrasse. Unter uns das Gewirr der Medina.",
            location: Location(latitude: 31.6295, longitude: -7.9811, city: "Marrakesch", region: "Marrakesh-Safi", country: "Marokko")),

        Activity(categoryId: "restaurant", date: .daysAgo(185), title: "Dîner in Jemaa el-Fna",
            text: "Tajine unter freiem Himmel, Schlangenbeschwörer und Gnawa-Musik. Marrakesch betäubt alle Sinne.",
            isFavorite: true,
            location: Location(latitude: 31.6260, longitude: -7.9890, city: "Marrakesch", region: "Marrakesh-Safi", country: "Marokko")),

        Activity(categoryId: "yoga", date: .daysAgo(186), title: "Hammam in Fès",
            text: "Traditionelles Bad in einem 500 Jahre alten Hammam. Dampf, Arganöl, absolute Entspannung.",
            location: Location(latitude: 34.0601, longitude: -4.9936, city: "Fès", region: "Fès-Meknès", country: "Marokko")),

        Activity(categoryId: "viewpoint", date: .daysAgo(188), title: "Sonnenuntergang Sahara",
            text: "Auf einer Sanddüne sitzend, oranges Licht, absolute Stille. Die Sahara verändert einen.",
            isFavorite: true,
            location: Location(latitude: 31.0609, longitude: -4.0127, city: "Merzouga", region: "Drâa-Tafilalet", country: "Marokko")),

        Activity(categoryId: "swimming", date: .daysAgo(190), title: "Schnorcheln Sansibar",
            text: "Korallen, Schildkröten, bunte Fische — das klarste Wasser meines Lebens.",
            isFavorite: true,
            location: Location(latitude: -6.1659, longitude: 39.2026, city: "Sansibar", region: "Sansibar", country: "Tansania")),

        Activity(categoryId: "festival", date: .daysAgo(191), title: "Zanzibar Beach Party",
            text: "Sundowner am Nungwi Beach mit Einheimischen und Reisenden. Trommelrhythmen bis Mitternacht.",
            location: Location(latitude: -5.7272, longitude: 39.2985, city: "Nungwi", region: "Sansibar", country: "Tansania")),

        Activity(categoryId: "photography", date: .daysAgo(192), title: "Stone Town Sansibar",
            text: "Durch die engen Gassen der Altstadt — arabische Architektur, Gewürzgerüche, Geschichte.",
            location: Location(latitude: -6.1630, longitude: 39.1894, city: "Stone Town", region: "Sansibar", country: "Tansania")),

        Activity(categoryId: "yoga", date: .daysAgo(193), title: "Yoga Sonnenaufgang Sansibar",
            text: "Strand-Yoga bei Sonnenaufgang, warmer Wind vom Indischen Ozean. Paradiesisch.",
            location: Location(latitude: -6.1310, longitude: 39.3625, city: "Paje", region: "Sansibar", country: "Tansania")),

        Activity(categoryId: "photography", date: .daysAgo(195), title: "Safari Masai Mara",
            text: "Löwen bei Sonnenaufgang, Elefantenherde am Fluss, Millionen Gnus. Afrika pur.",
            isFavorite: true,
            location: Location(latitude: -1.5050, longitude: 35.1437, city: "Masai Mara", region: "Narok", country: "Kenia")),

        Activity(categoryId: "hiking", date: .daysAgo(196), title: "Uhuru Gardens Nairobi",
            text: "Morgenspaziergang im Herzen Nairobis. Die Stadt erwacht mit Vogelgezwitscher und Chai.",
            location: Location(latitude: -1.3031, longitude: 36.8176, city: "Nairobi", region: "Nairobi", country: "Kenia")),

        Activity(categoryId: "museum", date: .daysAgo(197), title: "Nairobi National Museum",
            text: "Geschichte Kenias und Ostafrikas. Die Fossilienabteilung mit Lucy ist weltklasse.",
            location: Location(latitude: -1.2743, longitude: 36.8167, city: "Nairobi", region: "Nairobi", country: "Kenia")),

        // ━━━ OZEANIEN (10) ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        Activity(categoryId: "hiking", date: .daysAgo(200), title: "Bondi Beach Coastal Walk",
            text: "5km von Bondi nach Coogee. Blauer Pazifik, weisser Sand, Tintenfischfelsen.",
            isFavorite: true,
            location: Location(latitude: -33.8908, longitude: 151.2743, city: "Sydney", region: "New South Wales", country: "Australien")),

        Activity(categoryId: "photography", date: .daysAgo(201), title: "Harbour Bridge Climb",
            text: "Auf die Sydney Harbour Bridge geklettert. Die Stadt liegt unter uns — unvergesslicher Ausblick.",
            isFavorite: true,
            location: Location(latitude: -33.8523, longitude: 151.2108, city: "Sydney", region: "New South Wales", country: "Australien")),

        Activity(categoryId: "concert", date: .daysAgo(202), title: "Sydney Opera House",
            text: "Beethoven 9. Symphonie im Opernhaus. Die Akustik, die Architektur — Australien kann Kultur.",
            isFavorite: true,
            location: Location(latitude: -33.8568, longitude: 151.2153, city: "Sydney", region: "New South Wales", country: "Australien")),

        Activity(categoryId: "cafe", date: .daysAgo(205), title: "Café Skye Melbourne",
            text: "Melbourne ist die Kaffeehauptstadt der Welt. Flat White im Laneway-Café — Perfektion.",
            location: Location(latitude: -37.8136, longitude: 144.9631, city: "Melbourne", region: "Victoria", country: "Australien")),

        Activity(categoryId: "beach", date: .daysAgo(206), title: "Great Ocean Road",
            text: "12 Apostel bei Sonnenuntergang. Diese Felsnadeln im Meer — Natur als Kunst.",
            isFavorite: true,
            location: Location(latitude: -38.6627, longitude: 143.1051, city: "Port Campbell", region: "Victoria", country: "Australien")),

        Activity(categoryId: "bar", date: .daysAgo(207), title: "Rooftop Bar Melbourne",
            text: "Rooftop Bar im CBD, Skyline-Blick, Shiraz aus dem Barossa Valley. Melbourne bei Nacht.",
            location: Location(latitude: -37.8136, longitude: 144.9631, city: "Melbourne", region: "Victoria", country: "Australien")),

        Activity(categoryId: "travel", date: .daysAgo(210), title: "Milford Sound Fjord",
            text: "Mit dem Boot durch den Fjord, Wasserfälle von allen Seiten. Neuseeland ist unwirklich schön.",
            isFavorite: true,
            location: Location(latitude: -44.6413, longitude: 167.8974, city: "Milford Sound", region: "Southland", country: "Neuseeland")),

        Activity(categoryId: "travel", date: .daysAgo(211), title: "Hobbiton Neuseeland",
            text: "Das echte Auenland. Grüne Hügel, runde Türen, das Green Dragon Pub. Magie pur.",
            isFavorite: true,
            location: Location(latitude: -37.8578, longitude: 175.6820, city: "Matamata", region: "Waikato", country: "Neuseeland")),

        Activity(categoryId: "festival", date: .daysAgo(215), title: "Bluesfest Byron Bay",
            text: "5 Tage Weltmusik unter freiem Himmel. Australien im Hippie-Modus.",
            isFavorite: true,
            location: Location(latitude: -28.6474, longitude: 153.6020, city: "Byron Bay", region: "New South Wales", country: "Australien")),

        Activity(categoryId: "swimming", date: .daysAgo(216), title: "Surfen Byron Bay",
            text: "Erste Surf-Session in Australien. Wellen, Sonne, Salzwasser — süchtig nach einer Stunde.",
            location: Location(latitude: -28.6474, longitude: 153.6020, city: "Byron Bay", region: "New South Wales", country: "Australien")),
    ]}
}

#endif
