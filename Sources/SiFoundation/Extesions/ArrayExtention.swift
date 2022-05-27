import Foundation

public extension Array
{
      subscript( _ index: Int, default defaultValue: @autoclosure () -> Element ) -> Element
      {
            guard index >= 0, index < endIndex
            else
            { return defaultValue() }

            return self[ index ]
      }

      subscript( safeIndex index: Int ) -> Element?
      {
            guard index >= 0, index < endIndex
            else { return nil }

            return self[ index ]
      }

      /// инверсия свойства isEmpty, чтобы не вставлять везде отрицание "!"
      var /* prop */ notEmpty: Bool
      { !self.isEmpty }
}

