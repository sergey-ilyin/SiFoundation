import Foundation

public extension DateFormatter
{
      static let sharedMediumDateFormatter: DateFormatter =
      {
            let formatter = DateFormatter()

            formatter.dateStyle = .medium
            formatter.locale = .current
            return formatter
      }()

      static let sharedShortDateFormatter: DateFormatter =
      {
            let formatter = DateFormatter()

            formatter.dateStyle = .short
            formatter.locale = .current
            return formatter
      }()

      //    public static func mediumString(from date: Date) -> String
      //    {
//        return Self.sharedMediumDateFormatter.string(from: date)
      //    }
}
