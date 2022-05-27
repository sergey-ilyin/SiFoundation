import Foundation

public extension Dictionary
{
      /// usage: let value = map[optional: key]
      subscript( optional optKey: Key? ) -> Value?
      {
            return optKey.flatMap { self[ $0 ] }
      }

      /// инверсия свойства isEmpty, чтобы не вставлять везде отрицание "!"
      var /* prop */ notEmpty: Bool
      { !self.isEmpty }
}
