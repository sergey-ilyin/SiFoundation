import Foundation

extension Int: Identifiable
{
      /// делаем Int самоидентифицирующимся для использования, например, в .sheet(item:)
      public var /* prop */ id: Int
      { self }
}

public extension Int
{
      /// ограничивает число диапазоном (default не обязательно должно в него входить)
      func enclosed( in range: Range<Int>, default defaultValue: Int ) -> Int
      {
            if range.contains( self )
            { return self }
            else
            { return defaultValue }
      }

      /// ограничивает число диапазоном, берёт ближайшее к границе диапазона
      func enclosed( in range: Range<Int> ) -> Int
      {
            if range.contains( self )
            {
                  return self
            }
            else
            {
                  if self < range.lowerBound
                  { return range.lowerBound }
                  else
                  { return range.upperBound - 1 }
            }
      }

      /// ограничивает число верхней границей (default не обязательно должно в него входить)
      func limitted( by top: Int, default defaultValue: Int = 0 ) -> Int
      {
            return self.enclosed( in: 0 ..< top, default: defaultValue )
      }

      /// ограничивает число верхней границей, берёт ближайшее к границе диапазона
      func limitted( by top: Int ) -> Int
      {
            return self.enclosed( in: 0 ..< top )
      }

      /// конструктор из опциональной строки, возможно содержащей целое число
      init?( fromString: String? )
      {
            guard let _s = fromString
            else
            { return nil }

            guard let _i = Int( _s )
            else
            { return nil }

            self = _i
      }

      var /* prop */ asString: String
      {
            return String( self )
      }

      var /* prop */ negativeToNil: Int?
      {
            return self < 0 ? nil : self
      }
}

public extension Optional where Wrapped == Int
{
      /// опционалное число в строку
      func asString( default defaultValue: String ) -> String
      {
            switch self
            {
                  case .some( let _value ):
                        return _value.asString
                  case .none:
                        return defaultValue
            }
      }

      /// ограничивает число диапазоном (default не обязательно должно в него входить)
      func enclosed( in range: Range<Int>, default defaultValue: Int ) -> Int
      {
            switch self
            {
                  case .some( let _value ):
                        return _value.enclosed( in: range, default: defaultValue )
                  case .none:
                        return defaultValue
            }
      }

      /// ограничивает число диапазоном, берёт ближайшее к границе диапазона (но если Optional пустой, берёт нижнюю границу)
      func enclosed( in range: Range<Int> ) -> Int
      {
            switch self
            {
                  case .some( let _value ):
                        return _value.enclosed( in: range )
                  case .none:
                        return range.lowerBound
            }
      }

      /// ограничивает число верхней границей (default не обязательно должно входить в диапазон 0 .. top-1 )
      func limitted( by top: Int, default defaultValue: Int = 0 ) -> Int
      {
            return self.enclosed( in: 0 ..< top, default: defaultValue )
      }

      /// ограничивает число верхней границей, берёт ближайшее к границе диапазона (но если Optional пустой, берёт нижнюю границу)
      func limitted( by top: Int ) -> Int
      {
            return self.enclosed( in: 0 ..< top )
      }
}
