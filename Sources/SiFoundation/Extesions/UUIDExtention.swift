import Foundation

public extension UUID
{
      var /* prop */ asString: String
      { return self.uuidString }
}

public extension Optional where Wrapped == UUID
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
}