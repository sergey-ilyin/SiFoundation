import Foundation

public extension URL
{
      func appendingDirs( _ pathComponents: [ String ] ) -> URL
      {
            var tempURL = self
            pathComponents.forEach
            {
                  tempURL = tempURL.appendingPathComponent( $0, isDirectory: true )
            }
            return tempURL
      }
}
