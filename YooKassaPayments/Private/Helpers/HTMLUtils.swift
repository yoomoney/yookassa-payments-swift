import UIKit

enum HTMLUtils {
    /// Take html and hightlight any text between `<a></a>`
    /// - <a> tag attributes ignored, link is extracted from href, `</>` is considered as closing `</a>`
    /// - html attributes other than `<a>` are handled by default NSAttributedString behavior
    /// - Example: `<a id=1 href='?foo=bar&mid&lt=true'>some</>` will highlight `some` with .link attribute
    static func highlightHyperlinks(html: String) -> NSAttributedString {
        do {
            // Capture text between <a></a> into capture group #3
            // Range#0: full match
            // Range#1: opening tag <a>, tag attributes ignored
            // Range#2: tagged text
            // Range#3: closing </a>. missing 'a' tolerance, </> is treated as close tag
            let regex = try NSRegularExpression(
                pattern: #"(<a\s{0,}[^>]{0,}>)([^<]+)(<\/a{0,1} {0,}>)"#,
                options: .anchorsMatchLines
            )

            var matches: [(NSRange, [String])] = []

            regex.enumerateMatches(
                in: html,
                options: .withTransparentBounds,
                range: NSRange(location: 0, length: (html as NSString).length)
            ) { result, flags, ptr in
                if let result = result {
                    var captured: [String] = []
                    for rangeIndex in 0 ..< result.numberOfRanges {
                        captured.append((html as NSString).substring(with: result.range(at: rangeIndex)))
                    }

                    matches.append((result.range, captured))
                }
            }

            guard !matches.isEmpty else {
                return NSAttributedString(
                    string: htmlToPlain(html),
                    attributes: [.foregroundColor: UIColor.AdaptiveColors.secondary]
                )
            }
            var ranges: [NSRange] = []
            let plainStart = htmlToPlain(
                (html as NSString).substring(with: NSRange(location: 0, length: matches[0].0.location))
            )
            let resulting = NSMutableAttributedString(
                string: plainStart,
                attributes: [.foregroundColor: UIColor.AdaptiveColors.secondary]
            )
            ranges.append(NSRange(location: 0, length: matches[0].0.location))
            matches.forEach {
                guard let last = ranges.last else { return }
                let distance = $0.0.location - (last.location + last.length)
                if distance > 0 {
                    let range = NSRange(location: (last.location + last.length) + 1, length: distance - 1)
                    let plain = htmlToPlain((html as NSString).substring(with: range))
                    resulting.append(
                        NSAttributedString(
                            string: plain,
                            attributes: [.foregroundColor: UIColor.AdaptiveColors.secondary]
                        )
                    )
                    ranges.append(range)
                }
                ranges.append($0.0)
                let fulllMatch = $0.1[0]
                var url: String?
                if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
                    let urlMatches = detector.matches(
                        in: fulllMatch,
                        options: [],
                        range: NSRange(location: 0, length: fulllMatch.utf16.count)
                    )
                    for match in urlMatches {
                        guard let range = Range(match.range, in: fulllMatch) else { continue }
                        let found = String(fulllMatch[range])
                        url = found
                    }
                }
                resulting.append(NSAttributedString(string: $0.1[2], attributes: [.link: url ?? "yookassa://"]))
            }
            if let last = matches.last {
                let location = last.0.location + last.0.length + 1
                let lenght = (html as NSString).length - location
                // if there is any text after last </a>, append plain text to resulting
                if lenght > 0 {
                    let range = NSRange(location: location, length: lenght)
                    let plain = htmlToPlain((html as NSString).substring(with: range))
                    resulting.append(
                        NSAttributedString(
                            string: plain,
                            attributes: [.foregroundColor: UIColor.AdaptiveColors.secondary]
                        )
                    )
                }
            }

            return resulting
        } catch {
            PrintLogger.trace("regex failure", info: ["error": error.localizedDescription])
        }

        return NSAttributedString(string: html)
    }

    /// Convert <br> -> \n and other html text formatting to native `String`
    static func htmlToPlain(_ html: String) -> String {
        guard
            let data = html.data(using: .utf16),
            let converted = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
            )
        else { return html }
        return converted.string
    }
}
