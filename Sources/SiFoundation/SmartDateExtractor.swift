import Foundation

/// Класс для попытки чтения даты из строки с применением нескольких различных форматов.
public class SmartDateExtractor
{
      /// Запрещаем создание экземпляров.
      private init() {}

      /// Единый форматтер дат (создаётся при первом обращении к классу).
      private static let sharedDateFormatter: DateFormatter =
      {
            let formatter = DateFormatter()

            // Настраиваем для распознавания дат в нулевой тайм-зоне и в стандартном формате
            formatter.calendar = Calendar( identifier: .iso8601 )
            formatter.locale = Locale( identifier: "en_US_POSIX" )
            formatter.timeZone = TimeZone( secondsFromGMT: 0 ) // TODO: maybe TimeZone(identifier: "UTC") ?
            return formatter
      }()

      /// Возвращает экземпляр даты выделенной из строки или nil при неудаче.
      public static func parse( from dateStr: String ) -> Date?
      {
            // Перебираем все допустимые форматы:
            for _format in [ // TODO: дополнить список
                  "yyyy-MM-dd",
                  "yyyy-MM-dd'T'HH:mm:ss",
                  "yyyy-MM-dd'T'HH:mm:ss'Z'",
                  "yyyy-MM-dd'T'HH:mm:ssXXXXX",
                  "yyyy-MM-dd'T'HH:mm:ss.SSS",
                  "yyyy-MM-dd'T'HH:mm:ss.SSSS",
                  "yyyy-MM-dd'T'HH:mm:ss.SSSSS",
                  "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                  "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
                  "yyyy-MM-dd'T'HH:mm:ss.SSSSXXXXX",
                  "yyyy-MM-dd'T'HH:mm:ss.SSSSSXXXXX",
                  "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX",
            ]
            {
                  sharedDateFormatter.dateFormat = _format

                  // Преобразование удалось — выскакиваем из цикла и функции:
                  if let _date = sharedDateFormatter.date( from: dateStr )
                  {
                        return _date
                  }
            }

            if let _number = Double( dateStr )
            {
                  return Date( timeIntervalSinceReferenceDate: _number )
            }

            return nil // — значит, преобразование не удалось ни в один из форматов...
      }
}
