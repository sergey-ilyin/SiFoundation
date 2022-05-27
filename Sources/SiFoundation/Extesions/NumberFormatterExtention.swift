import Foundation

/// добавляем закешированные глобальные форматтеры, чтобы не создавались какждый раз новые экземпляры
public extension NumberFormatter
{
      static let Int: NumberFormatter =
      {
            let formatter = NumberFormatter()

            formatter.numberStyle = .none
            formatter.usesGroupingSeparator = false

            return formatter
      }()

      static let FloatRoundedTo: [ NumberFormatter ] =
      {
            return [
                  NumberFormatter.floatNumberFormatter( roundedBy: 0 ),
                  NumberFormatter.floatNumberFormatter( roundedBy: 1 ),
                  NumberFormatter.floatNumberFormatter( roundedBy: 2 ),
            ]
      }()

      static let Percent: NumberFormatter =
      {
            let formatter = NumberFormatter()

            formatter.numberStyle = .percent

            return formatter
      }()

      private static func floatNumberFormatter( roundedBy places: Int ) -> NumberFormatter
      {
            let formatter = NumberFormatter()

            formatter.numberStyle = .decimal
            formatter.usesGroupingSeparator = false
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = places

            return formatter
      }
}
