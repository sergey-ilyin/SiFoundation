import Foundation

public extension Decimal
{
      /// конструктор из опциональной строки, возможно содержащей целое число
      init?( _ source: String?, roundedBy places: Int )
      {
            guard let _s = source
            else
            { return nil }

            guard let _d = Self( string: _s )
            else
            { return nil }

            self = _d.rounded( by: places )
      }

      private func rounded(
            by places: Int // ,
            //            _ roundingMode: NSDecimalNumber.RoundingMode = .plain
      ) -> Decimal
      {
            var result = Decimal()
            var localCopy = self
            NSDecimalRound( &result, &localCopy, places, .plain ) // roundingMode )
            return result
      }

      func asString( roundedBy places: Int ) -> String
      {
            // по-идее форматтер не должен возвращать nil в нормальных ситуациях
            return NumberFormatter.FloatRoundedTo[ places ].string( for: self )
                  .default( "0" ) // просто перестраховываемся
      }
}

public extension Optional where Wrapped == Decimal
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