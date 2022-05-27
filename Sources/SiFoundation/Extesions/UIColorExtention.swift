

import Foundation
import SwiftUI

public extension UIColor
{
      /// конструктор из строки
      convenience init( hex: String, removeAlpha: Bool = false )
      {
            let hex = hex.trimmingCharacters( in: CharacterSet.alphanumerics.inverted )
            var int: UInt64 = 0
            Scanner( string: hex ).scanHexInt64(&int )
            let a, r, g, b: UInt64
            switch hex.count
            {
                  case 3: // RGB (12-bit)
                        ( a, r, g, b ) = ( 255, ( int >> 8 ) * 17, ( int >> 4 & 0xF ) * 17, ( int & 0xF ) * 17 )
                  case 6: // RGB (24-bit)
                        ( a, r, g, b ) = ( 255, int >> 16, int >> 8 & 0xFF, int & 0xFF )
                  case 8: // ARGB (32-bit)
                        ( a, r, g, b ) = ( int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF )
                  default:
                        ( a, r, g, b ) = ( 1, 1, 1, 0 )
            }

            self.init(
                  red: CGFloat( r ) / 255,
                  green: CGFloat( g ) / 255,
                  blue: CGFloat( b ) / 255,
                  alpha: removeAlpha ? 1 : ( CGFloat( a ) / 255 )
            )
      }

      /// преобразование в hex-строку
      var /* prop */ asHexString: String
      {
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0

            getRed(&r, green: &g, blue: &b, alpha: &a )

            let rgb: Int = ( Int )( r * 255 ) << 16 | ( Int )( g * 255 ) << 8 | ( Int )( b * 255 ) << 0

            return NSString( format: "#%06x", rgb ) as String
      }

      ///
      var /* prop */ isTooLight: Bool
      {
            var white: CGFloat = 0
            getWhite(&white, alpha: nil )
            return white > 0.7
      }

      ///
      var /* prop */ darkedVersion: UIColor
      {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

            if self.getRed(&r, green: &g, blue: &b, alpha: &a )
            {
                  let darkFactor: CGFloat = 0.4
                  return UIColor(
                        red: max( r - darkFactor, 0.0 ),
                        green: max( g - darkFactor, 0.0 ),
                        blue: max( b - darkFactor, 0.0 ),
                        alpha: a
                  )
            }

            return .black
      }
}
