import Foundation

public extension String
{
      /// Окружает строку заданными символами
      func surrounded( by prefix: String, and suffix: String ) -> String
      {
            if self.isEmpty { return "" }
            else { return "\( prefix )\( self )\( suffix )" }
      }

      /// Обрамляет строку заданным символом
      func wrapped( by wrapper: String ) -> String
      {
            surrounded( by: wrapper, and: wrapper )
      }

      /// Обрамляет строку кавычками
      var /* prop */ quoted: String
      {
            return self.wrapped( by: "\"" )
      }

      /// Обрамляет строку угловыми (французскими) кавычками
      var /* prop */ angleQuoted: String
      {
            if self.isEmpty { return "" }
            else { return "«\( self )»" }
      }

      /// Обрамляет строку скобками
      var /* prop */ enveloped: String
      {
            if self.isEmpty { return "" }
            else { return "(\( self ))" }
      }

      /// Завершает строку заданным символом
      func suffixed( by suffix: String ) -> String
      {
            if self.isEmpty { return "" }
            else { return "\( self )\( suffix )" }
      }

      /// Предваряет строку заданным символом
      func prefixed( by prefix: String ) -> String
      {
            if self.isEmpty { return "" }
            else { return "\( prefix )\( self )" }
      }

      /// Удаляет префих
      func deletePrefix( _ prefix: String ) -> String
      {
            guard self.hasPrefix( prefix )
            else { return self }

            return String( self.dropFirst( prefix.count ) )
      }

      /// Удаляет суффикс
      func deleteSuffix( _ suffix: String ) -> String
      {
            guard self.hasSuffix( suffix )
            else { return self }

            return String( self.dropLast( suffix.count ) )
      }

      /// Капитализирует первую букву первого слова.
      var /* prop */ sentenceCased: String
      {
            return self.prefix( 1 ).capitalized + self.dropFirst()
      }

      /// // Убирает наружние и повторяющиеся внутренние пробелы.
      var /* prop */ unspaced: String
      {
            return self.trimmingCharacters( in: .whitespacesAndNewlines )
      }

      /// для удобства локализации
      var /* prop */ localized: String
      {
            NSLocalizedString( self, comment: "" )
      }

      /// для удобства локализации с форматированием
      func localizedWith( _ arguments: CVarArg... ) -> String
      {
            return String( format: self.localized, arguments: arguments )
      }

      // TODO: удалить, когда избавимся от всех использований этого вызова:
       /// конструктор из опционального целого числа
       init?( fromInt: Int? )
       {
             guard let _i = fromInt
             else { return nil }

             self = String( _i )
       }

      // TODO: удалить, когда избавимся от всех использований этого вызова:
       /// конструктор из опционального плавающего числа
       init?( fromFloat: Float? )
       {
             guard let _f = fromFloat
             else { return nil }

             self = String( _f )
       }
       

      /// если строка пустая, то вернуть nil, иначе вернуть содержимое
      var /* prop */ emptyToNil: String?
      {
            if self.isEmpty
            { return nil }
            else
            { return self }
      }

      /// если строка пустая, то вернуть defaultValue, иначе вернуть содержимое
      func substEmpty( by defaultValue: String ) -> String
      {
            if self.isEmpty
            { return defaultValue }
            else
            { return self }
      }

      /// инверсия свойства isEmpty, чтобы не вставлять везде отрицание "!"
      var /* prop */ notEmpty: Bool
      { !self.isEmpty }
}

public extension Optional where Wrapped == String
{
      /// проверить: опционал пуст или заполнен, но равен пустой строке
      var /* prop */ isNilOrEmpty: Bool
      {
            return self?.isEmpty ?? true
      }

      /// инверсия свойства isNilOrEmpty, чтобы не вставлять везде отрицание "!"
      var /* prop */ notNilNorEmpty: Bool
      {
            return !isNilOrEmpty
      }

      /// если опционал пуст или заполнен, но равен пустой строке, то вернуть заданную, иначе вернуть развёрнутое содержимое
      func substNilOrEmpty( by defaultValue: String ) -> String
      {
            switch self
            {
                  case .some( let _value ):
                        return ( _value.isEmpty ) ? defaultValue : _value
                  case .none:
                        return defaultValue
            }
      }

      /// если опционал пуст, то вернуть пустую строку, иначе вернуть развёрнутое содержимое
      var /* prop */ nilToEmpty: String
      {
            switch self
            {
                  case .some( let _value ):
                        return _value
                  case .none:
                        return ""
            }
      }
}

