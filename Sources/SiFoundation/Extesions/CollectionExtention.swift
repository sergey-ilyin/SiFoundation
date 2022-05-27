import Foundation

public extension Optional where Wrapped: Collection
{
      /// проверить: опционал пуст или заполнен, но равен пустой коллекции
      var /* prop */ isNilOrEmpty: Bool
      {
            return self?.isEmpty ?? true
      }

      /// инверсия свойства isNilOrEmpty, чтобы не вставлять везде отрицание "!"
      var /* prop */ notNilNorEmpty: Bool
      {
            return !isNilOrEmpty
      }
}