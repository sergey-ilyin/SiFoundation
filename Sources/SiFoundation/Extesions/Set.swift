import Foundation

public extension Set
{
      /// вычисляет какие элементы нужно добавить, какие удалить, чтобы получить значение, как у параметра
      func diff( with after: Set ) -> ( Set,Set )
      {
            let toKeep = self.intersection( after )
            let toAdd = after.subtracting( toKeep )
            let toRemove = self.subtracting( after )
            return ( toRemove,toAdd )
      }
}
