// from  https://gist.github.com/BenLeggiero/120fe68857703107881e7f33a88111f2
import Foundation
import UIKit

/// Allows you to use Swift encoders and decoders to process UIColor
public struct CodableColor
{
      /// The color to be (en/de)coded
      public let value: UIColor
}

extension CodableColor: Encodable
{
      public func encode( to encoder: Encoder ) throws
      {
            let nsCoder = NSKeyedArchiver( requiringSecureCoding: true )
            value.encode( with: nsCoder )
            var container = encoder.unkeyedContainer()
            try container.encode( nsCoder.encodedData )
      }
}

extension CodableColor: Decodable
{
      public init( from decoder: Decoder ) throws
      {
            var container = try decoder.unkeyedContainer()
            let decodedData = try container.decode( Data.self )
            let nsCoder = try NSKeyedUnarchiver( forReadingFrom: decodedData )

            guard let _color = UIColor( coder: nsCoder )
            else
            {
                  struct UnexpectedlyFoundNilError: Error {}

                  throw UnexpectedlyFoundNilError()
            }

            self.value = _color
      }
}

public extension UIColor
{
      func codable() -> CodableColor
      {
            return CodableColor( value: self )
      }
}
