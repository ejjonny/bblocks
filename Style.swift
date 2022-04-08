import SwiftUI

public extension Color {
    static let main: Self = .init(light: .init(rgb: 0x000000), dark: .init(rgb: 0xffffff))
    static let alternate: Self = .init(light: .init(rgb: 0xffffff), dark: .init(rgb: 0x000000))
    static let accent1: Self = .init(light: .init(rgb: 0x03a9fc), dark: .init(rgb: 0x03a9fc))
    static let accent2: Self = .init(light: .init(rgb: 0xd303fc), dark: .init(rgb: 0xd303fc))
    static let accent3: Self = .init(light: .init(rgb: 0xd1ffad), dark: .init(rgb: 0xd1ffad))
    static let accent4: Self = .init(light: .init(rgb: 0xfaffad), dark: .init(rgb: 0xfaffad))
}
public extension Color {
    init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0)
    }
    
    init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

#if canImport(UIKit)
extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return light
            case .dark:
                return dark
            @unknown default:
                return light
            }
        }
    }
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
}
#else
extension NSColor {
    convenience init(light: NSColor, dark: NSColor) {
        self.init(name: nil) { appearance in
            switch appearance.name {
            case .aqua:
                return light
            default:
                return dark
            }
        }
    }
}

extension Color {
    init(light: Color, dark: Color) {
        self.init(NSColor(light: NSColor(light), dark: NSColor(dark)))
    }
}
#endif

extension Text {
    func appText() -> some View {
        bold()
        .font(.system(.title, design: .rounded))
    }
    func appText2() -> some View {
        bold()
            .font(.system(.body, design: .rounded))
    }
    func appText3() -> some View {
        bold()
            .font(.system(.footnote, design: .rounded))
    }
}
extension View {
    func section() -> some View {
        frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.alternate)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.accent1, lineWidth: 1)
                    )
            )
            .padding([.leading, .trailing])
    }
}
