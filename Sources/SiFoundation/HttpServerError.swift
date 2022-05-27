import Foundation

/// Коды ошибок сервера
public enum HttpServerError: Swift.Error
{
      case UrlSessionError( String, Error )
      case InvalidURL( String )
      case InvalidResponse( String )
      case InvalidLoginOrPassword
      case UnexpectedHttpCode( String, Int, String )
      case MissingResponseData( String )
      case CannotConvertImageToJpeg
      case CannotConvertAnswerToString
      case CannotGetVideoData
}

extension HttpServerError: LocalizedError
{
      public var errorDescription: String?
      {
            switch self
            {
                  case .UrlSessionError( let urlString, let error ):
                        return "Не удалось подключиться к серверу по адресу %@, сообщение: %@".localizedWith( urlString.quoted, error.extendedDescription.quoted )

                  case .InvalidURL( let urlString ):
                        return "Неправильный URL-адрес = %@".localizedWith( urlString.quoted )

                  case .InvalidResponse( let urlString ):
                        return "Сервер вернул неверный HTTP-ответ на запрос: %@".localizedWith( urlString.quoted )

                  case .InvalidLoginOrPassword:
                        return "Неверное имя пользователя или пароль".localized

                  case .UnexpectedHttpCode( let urlString, let code, let statusString ):
                        return "Сервер вернул HTTP-код = %d (%@) на запрос: %@".localizedWith( code, statusString, urlString )

                  case .MissingResponseData( let urlString ):
                        return "Отсутствуют данные в ответе сервера на запрос: %@".localizedWith( urlString.quoted )

                  case .CannotConvertImageToJpeg:
                        return "Не удалось сконвертировать изображение в jpeg-формат".localized

                  case .CannotConvertAnswerToString:
                        return "Не удалось сконвертировать ответ сервера в строку".localized

                  case .CannotGetVideoData:
                        return "Не удалось извлечь видео-данные".localized
            }
      }
}
