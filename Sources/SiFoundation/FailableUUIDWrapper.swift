import Foundation

public struct FailableUUIDWrapper: Hashable, Equatable, CustomStringConvertible, Codable
{
      private let internalID: UUID?

      /// конструктор.
      public init( uuidString string: String )
      {
            internalID = UUID( uuidString: string )
      }

      /// конструктор.
      public init( _ id: UUID )
      {
            internalID = id
      }

      /// конструктор.
      public init( from decoder: Decoder ) throws
      {
            do
            {
                  internalID = try UUID( from: decoder )
            }
            catch DecodingError.dataCorrupted( let _context )
            {
                  let asOptStr = try? decoder.singleValueContainer().decode( String.self )

                  if let _asStr = asOptStr,
                        _asStr == "null"
                  { internalID = nil }
                  else
                  { throw DecodingError.dataCorrupted( _context ) }
            }
      }

      public func encode( to encoder: Encoder ) throws
      {
            try internalID.encode( to: encoder )
      }

      public var /* prop */ isNil: Bool
      { internalID == nil }

      public var /* prop */ id: UUID?
      { internalID }

      public var /* prop */ uuidString: String
      { ( internalID?.uuidString ).nilToEmpty }

      public var /* prop */ asString: String
      { return self.uuidString }

      public var /* prop */ description: String
      { ( internalID?.description ).nilToEmpty }

      public var /* prop */ debugDescription: String
      { ( internalID?.debugDescription ).nilToEmpty }

      public func hash( into hasher: inout Hasher )
      { internalID?.hash( into: &hasher ) }

      public static func ==( lhs: FailableUUIDWrapper, rhs: FailableUUIDWrapper ) -> Bool
      { return lhs.internalID == rhs.internalID }
}

public extension Optional where Wrapped == FailableUUIDWrapper
{
      /// опционалное число в строку
      func asString( default defaultValue: String ) -> String
      {
            switch self
            {
                  case .some( let _value ):
                        return _value.asString
                  case .none:
                        return defaultValue
            }
      }
}