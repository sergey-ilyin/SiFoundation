import Foundation

/// Наша замена для энкодера в json-формат, которая правильно сохраяняет даты.
public class SmartJSONEncoder: JSONEncoder
{
      // TODO: распознавать поле TimeZone

      /// Запрещаем создание экземпляров.
      override private init() {}

      /// Единый энкодер (создаётся при первом обращении к классу).
      private static let encoder: JSONEncoder =
      {
            let RFC3339DateFormatter = DateFormatter()

            RFC3339DateFormatter.calendar = Calendar( identifier: .iso8601 )
            RFC3339DateFormatter.locale = Locale( identifier: "en_US_POSIX" )
            RFC3339DateFormatter.timeZone = TimeZone( secondsFromGMT: 0 ) // TODO: maybe TimeZone(identifier: "UTC") ?

            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted( RFC3339DateFormatter )

            return encoder
      }()

      /// Возвращает  json-данные на основе объекта
      public static func encode<__Object>( _ data: __Object ) throws -> Data where __Object: Encodable
      {
            return try encoder.encode( data )
      }
}
