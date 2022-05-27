import Foundation
import SwiftUI

public extension Binding
{
      /// Execute block when value is changed.
      func didSet( execute callback: @escaping ( Value ) -> Void ) -> Binding
      {
            return Binding(
                  get: { return self.wrappedValue },
                  set:
                  {
                        callback( $0 )
                        self.wrappedValue = $0
                  }
            )
      }
}

//
// Example:
//
//    Slider(value: $amount.didSet { print($0) }, in: 0...10)
