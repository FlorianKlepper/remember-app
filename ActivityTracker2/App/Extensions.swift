// Extensions.swift
// ActivityTracker2 — Remember
// App-weite Extensions auf Foundation-, SwiftUI- und CoreLocation-Typen

import Foundation
import SwiftUI
import CoreLocation

// MARK: - Date

extension Date {

    /// Gibt ein Datum zurück, das `days` Tage in der Vergangenheit liegt.
    /// Nützlich für Debug-Sample-Daten.
    static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    /// Gibt das Datum im deutschen Langformat zurück, z.B. "6. Feb 2026".
    var formattedActivityDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d. MMM yyyy"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: self)
    }

    /// Gibt die Uhrzeit im 24-Stunden-Format zurück, z.B. "14:30".
    var formattedActivityTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

// MARK: - Color

extension Color {

    /// Erstellt eine `Color` aus einem Hex-String.
    /// Akzeptiert sowohl `"#2ECC71"` als auch `"2ECC71"`.
    /// Fällt bei ungültigem Wert auf `Color.gray` zurück.
    init(hex: String) {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16) else {
            self = .gray
            return
        }

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >>  8) & 0xFF) / 255.0
        let b = Double( value        & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - View

extension View {

    /// Wendet einen Transform-Closure nur dann an, wenn die Bedingung erfüllt ist.
    ///
    /// ```swift
    /// Text("Hallo")
    ///     .if(isBold) { $0.bold() }
    /// ```
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - CLLocationCoordinate2D

extension CLLocationCoordinate2D: @retroactive Equatable {

    /// Zwei Koordinaten gelten als gleich, wenn Breiten- und Längengrad identisch sind.
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    /// Berechnet die Entfernung zur übergebenen Koordinate in Metern.
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to   = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return from.distance(from: to)
    }
}

// MARK: - String

extension String {

    /// `true` wenn der String leer oder nur Whitespace/Newlines enthält.
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
