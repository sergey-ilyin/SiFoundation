import Foundation

extension Bool
{
      /// конструктор из опциональной строки, возможно содержащей булево
      init?( fromString: String? )
      {
            guard let _s = fromString
            else
            { return nil }

            guard let _b = Bool( _s )
            else
            { return nil }

            self = _b
      }

      var /* prop */ asString: String
      {
            return self ? "Да".localized : "Нет".localized
      }
}

public extension Optional where Wrapped == Bool
{
      /// опционалное булево в строку
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
}