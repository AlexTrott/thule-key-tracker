import Foundation

enum KeyCodeFormatter: Sendable {

    static func normalise(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let stripped = trimmed
            .replacingOccurrences(of: " ", with: "")
            .uppercased()

        let digits: String
        if stripped.hasPrefix("N") {
            digits = String(stripped.dropFirst())
        } else {
            digits = stripped
        }

        guard !digits.isEmpty,
              digits.allSatisfy(\.isNumber),
              let number = Int(digits),
              number > 0 else {
            return nil
        }

        return "N\(String(format: "%03d", number))"
    }

    static func isValid(_ input: String) -> Bool {
        normalise(input) != nil
    }

    static func isInStandardRange(_ input: String) -> Bool {
        guard let normalised = normalise(input),
              let number = Int(normalised.dropFirst()) else {
            return false
        }
        return (1...250).contains(number)
    }

    static func displayString(for input: String) -> String {
        normalise(input) ?? "---"
    }
}
