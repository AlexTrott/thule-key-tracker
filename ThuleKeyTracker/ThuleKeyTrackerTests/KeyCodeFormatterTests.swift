import Testing
@testable import ThuleKeyTracker

struct KeyCodeFormatterTests {

    // MARK: - Normalisation

    @Test func normalisesPlainNumber() {
        #expect(KeyCodeFormatter.normalise("125") == "N125")
    }

    @Test func normalisesPrefixedUppercase() {
        #expect(KeyCodeFormatter.normalise("N125") == "N125")
    }

    @Test func normalisesPrefixedLowercase() {
        #expect(KeyCodeFormatter.normalise("n125") == "N125")
    }

    @Test func normalisesWithSpace() {
        #expect(KeyCodeFormatter.normalise("N 125") == "N125")
    }

    @Test func normalisesPadsToThreeDigits() {
        #expect(KeyCodeFormatter.normalise("1") == "N001")
        #expect(KeyCodeFormatter.normalise("42") == "N042")
    }

    @Test func normalisesAlreadyPadded() {
        #expect(KeyCodeFormatter.normalise("N001") == "N001")
    }

    @Test func normalisesReturnsNilForEmpty() {
        #expect(KeyCodeFormatter.normalise("") == nil)
    }

    @Test func normalisesReturnsNilForNonNumeric() {
        #expect(KeyCodeFormatter.normalise("abc") == nil)
        #expect(KeyCodeFormatter.normalise("N") == nil)
        #expect(KeyCodeFormatter.normalise("NNN") == nil)
    }

    @Test func normalisesReturnsNilForZero() {
        #expect(KeyCodeFormatter.normalise("0") == nil)
        #expect(KeyCodeFormatter.normalise("000") == nil)
    }

    @Test func normalisesTrimsWhitespace() {
        #expect(KeyCodeFormatter.normalise("  125  ") == "N125")
        #expect(KeyCodeFormatter.normalise(" N 42 ") == "N042")
    }

    // MARK: - Validation

    @Test func isValidForValidCodes() {
        #expect(KeyCodeFormatter.isValid("N125"))
        #expect(KeyCodeFormatter.isValid("125"))
        #expect(KeyCodeFormatter.isValid("n001"))
    }

    @Test func isValidForInvalidCodes() {
        #expect(!KeyCodeFormatter.isValid(""))
        #expect(!KeyCodeFormatter.isValid("abc"))
        #expect(!KeyCodeFormatter.isValid("0"))
    }

    // MARK: - Standard Range

    @Test func isInStandardRange() {
        #expect(KeyCodeFormatter.isInStandardRange("N001"))
        #expect(KeyCodeFormatter.isInStandardRange("N125"))
        #expect(KeyCodeFormatter.isInStandardRange("N250"))
    }

    @Test func isOutsideStandardRange() {
        #expect(!KeyCodeFormatter.isInStandardRange("N000"))
        #expect(!KeyCodeFormatter.isInStandardRange("N251"))
        #expect(!KeyCodeFormatter.isInStandardRange("N999"))
    }

    @Test func isInStandardRangeHandlesUnnormalisedInput() {
        #expect(KeyCodeFormatter.isInStandardRange("125"))
        #expect(!KeyCodeFormatter.isInStandardRange("999"))
    }

    // MARK: - Display Formatting

    @Test func displayFormatting() {
        #expect(KeyCodeFormatter.displayString(for: "125") == "N125")
        #expect(KeyCodeFormatter.displayString(for: "invalid") == "---")
    }
}
