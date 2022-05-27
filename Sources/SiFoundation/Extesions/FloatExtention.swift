import Foundation

infix operator &/: MultiplicationPrecedence

public extension Float
{
      /// конструктор из опциональной строки, возможно содержащей плавающее число
      init?( fromString: String? )
      {
            guard let _s = fromString
            else
            { return nil }

            guard let _f = Float( _s )
            else
            { return nil }

            self = _f
      }

      // возможно, не нужна
      /// Rounds the double to decimal places value
      func rounded( to places: Int ) -> Float
      {
            let divisor = pow( 10.0, Float( places ) )
            return ( self * divisor ).rounded() / divisor
      }

      /// возвращает строку представляющую число в виде процентов (1.0 == 100%)
      var /* prop */ asPercentString: String
      {
            NumberFormatter.Percent.string( from: NSNumber( value: self ) ).nilToEmpty
      }

      /// число в строку
      func asString( roundedBy places: Int ) -> String
      {
            // по-идее форматтер не должен возвращать nil в нормальных ситуациях
            return NumberFormatter.FloatRoundedTo[ places ].string( for: self )
                  .default( "0" ) // просто перестраховываемся
      }

      /// деление, безопасное при делителе == 0
      static func &/( lhs: Float, rhs: Float ) -> Float
      {
            if rhs == 0
            {
                  return 0
            }
            return lhs / rhs
      }
}

public extension Optional where Wrapped == Float
{
      /// опционалное число в строку
      func asString( roundedBy places: Int, default defaultValue: String ) -> String
      {
            switch self
            {
                  case .some( let _value ):
                        return _value.asString( roundedBy: places )
                  case .none:
                        return defaultValue
            }
      }
}
