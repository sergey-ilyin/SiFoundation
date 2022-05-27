import Foundation

public extension Calendar
{
      /// возвращает текущий год
      /// использовать: Calendar.current.year
      var /* prop */ year: Int { return self.component( .year, from: Date() ) }
}
