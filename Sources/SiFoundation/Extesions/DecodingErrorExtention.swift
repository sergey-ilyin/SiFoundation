import Foundation

public extension DecodingError
{
      /// предоставляем более читабельную информацию об ошибке декодирования
      var /* prop */ extendedDescription: String
      {
            let mainMessage = "\( self.localizedDescription )"

            switch self
            {
                  case DecodingError.dataCorrupted( let _context ):
                        let fieldNames = _context.codingPath.map(\.stringValue.quoted ).joined( separator: ", " )
                        return "%@ Подробности: поля: [%@], сообщение: %@".localizedWith( mainMessage, fieldNames, _context.debugDescription.quoted )

                  case DecodingError.keyNotFound( let _key, let _context ):
                        return "%@ Подробности: поле: %@, сообщение: %@".localizedWith( mainMessage, _key.stringValue.quoted, _context.debugDescription.quoted )

                  case DecodingError.typeMismatch( let _type, let _context ),
                       DecodingError.valueNotFound( let _type, let _context ):
                        let fieldNames = _context.codingPath.map(\.stringValue.quoted ).joined( separator: ", " )
                        return "%@ Подробности: поля: [%@], тип: %@, сообщение: %@".localizedWith( mainMessage, fieldNames, String( describing: _type ), _context.debugDescription.quoted )

                  @unknown default:
                        return mainMessage
            }
      }
}
