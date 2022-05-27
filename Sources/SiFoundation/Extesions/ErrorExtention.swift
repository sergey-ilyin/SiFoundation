import Foundation

public extension Error
{
      /// предоставляем более читабельную информацию об ошибке
      var /* prop */ extendedDescription: String
      {
            if let _error = self as? DecodingError
            {
                  return _error.extendedDescription
            }
            else
            {
                  return self.localizedDescription
            }
      }
}
