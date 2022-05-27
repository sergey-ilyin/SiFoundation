import Foundation

public extension Date
{
      var /* prop */ mediumString: String
      {
            return DateFormatter.sharedMediumDateFormatter.string( from: self )
      }

      var /* prop */ shortString: String
      {
            return DateFormatter.sharedShortDateFormatter.string( from: self )
      }

      var /* prop */ year: Int
      {
            return Calendar.current.component( .year, from: self )
      }
}
