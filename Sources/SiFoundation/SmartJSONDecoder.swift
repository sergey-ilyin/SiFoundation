import Foundation

/// Наша замена для декодера из json-формата, которая умеет распознавать правильно различные даты.
public class SmartJSONDecoder: JSONDecoder
{
      // TODO: распознавать поле TimeZone

      /// Запрещаем создание экземпляров.
      override private init() {}

      /// Единый декодер (создаётся при первом обращении к классу).
      private static let decoder: JSONDecoder =
      {
            let decoder = JSONDecoder()

            decoder.dateDecodingStrategy = .custom(
                  { ( decoder ) -> Date in
                        let container = try decoder.singleValueContainer()

                        if let _dateStr = try? container.decode( String.self )
                        {
                              guard let _date = SmartDateExtractor.parse( from: _dateStr )
                              else { throw DecodingError.typeMismatch( Date.self, DecodingError.Context( codingPath: decoder.codingPath, debugDescription: "Не удаётся прочитать дату из строки %@".localizedWith( _dateStr.quoted ) ) ) }

                              return _date
                        }
                        else // возможно, это число
                        {
                              let number = try container.decode( Double.self )

                              return Date( timeIntervalSinceReferenceDate: number )
                        }
                        // DateError.invalidDate
                  } )

            return decoder
      }()

      /// Возвращает экземпляр объекта заданного типа. Генерит исключение при неудаче.
      public static func decode<__Object>( _ type: __Object.Type, from data: Data ) throws -> __Object
            where __Object: Decodable
      {
            // TODO: разбирать детально исключение и выдавать своё с более толковой инфой
            return try self.decoder.decode( type, from: data )
      }
}
