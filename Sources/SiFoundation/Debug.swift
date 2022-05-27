import Foundation

/// для использования в отладочной печати
public let ENTERED = "🛩"
/// для использования в отладочной печати
public let EXITED = "✈️"

// MARK: - DEBUGLOG

/// Отладочная печать строки, выводит вместе с именем функции и именем файла (обычно совпадает с именем класса)
public func debugLog(
//      OFF off: Bool = false,
      _ message: String = "",
      fileName: String = #file,
      funcName: String = #function
)
{
      #if DEBUG
            let threadDescr = ( Thread.current.description as NSString ).components( separatedBy: ">" )[ 0, default: "" ].components( separatedBy: ":" )[ 1, default: "" ]

            let fileName = ( ( ( fileName as NSString ).lastPathComponent as NSString ).deletingPathExtension )

            DispatchQueue.main.async
            {
                  print( "💡\( threadDescr )  @  \( fileName ).\( funcName ) \t\t \( message )" )
            }
      #endif
}

public func off(
      _: String = "",
      _: String = #file,
      _: String = #function
)
{}

/// стурктура, помогающая отлаживать колбэки
public struct DebugContext<__Data, __Error: Error>
{
      public var callback: ( Result<__Data, __Error> ) -> Void
      public var callerName: String
      public var off: Bool = false

      /// конструктор.
      public init(
            _ callback: @escaping ( Result<__Data, __Error> ) -> Void,
            _ callerName: String,
            OFF off: Bool = false
      )
      {
            self.callback = callback
            self.callerName = callerName
            self.off = off
      }
}

// MARK: - CALLBACK_DEBUGGED

/// Помогает вклиниться между вызовом колбэка и распечатать результат, передаваемый ему параметром
public func callbackDebugged<__Data, __Error: Error>(
      _ result: Result<__Data, __Error>,
      _ debugContext: DebugContext<__Data, __Error>,
      fileName: String = #file,
      funcName: String = #function
) -> Void
{
      defer // будет вызвано в любом случае
      {
            DispatchQueue.main.async // чтобы действия с UI вызывались в главном потоке
            {
                  debugContext.callback( result )
            }
      }
      #if DEBUG
            if debugContext.off
            { return }

            result
                  .onFailure
                  { _error in
                        debugLog( "\( debugContext.callerName ) \( EXITED ) with error \( _error.extendedDescription.quoted ).", fileName: fileName, funcName: funcName )
                  }
                  .onSuccess
                  { _ in
                        debugLog( "\( debugContext.callerName ) \( EXITED ) with success.", fileName: fileName, funcName: funcName )
                  }

      #endif
}

// MARK: - OBJECT_AS_SOURCE_CODE

/// Превращает структуру объекта в строку с исходным текстом  создания этой структуры
public func objectAsSourceCode( _ someObject: Any ) -> String
{
      guard let _any = deepUnwrap( someObject )
      else
      {
            return "nil"
      }

      if _any is Void
      {
            return "Void"
      }

      if let _int = _any as? Int
      {
            return String( _int )
      }
      else if let _double = _any as? Double
      {
            return String( _double )
      }
      else if let _float = _any as? Float
      {
            return String( _float )
      }
      else if let _bool = _any as? Bool
      {
            return String( _bool )
      }
      else if let _string = _any as? UUID
      {
            return "UUID(uuidString:\"\( _string )\")"
      }
      else if let _string = _any as? String
      {
            return "\"\( _string )\""
      }

      let indentedString: ( String ) -> String =
      {
            $0.components( separatedBy: .newlines ).map { $0.isEmpty ? "" : "\r    \( $0 )" }.joined( separator: "" )
      }

      let mirror = Mirror( reflecting: _any )

      let properties = Array( mirror.children )

      guard let _displayStyle = mirror.displayStyle
      else
      {
            return String( describing: _any )
      }

      switch _displayStyle
      {
            case .tuple:
                  if properties.isEmpty { return "()" }

                  var string = "("

                  for ( index, property ) in properties.enumerated()
                  {
                        if property.label!.first! == "."
                        {
                              string += objectAsSourceCode( property.value )
                        }
                        else
                        {
                              string += "\( property.label! ): \( objectAsSourceCode( property.value ) )"
                        }

                        string += ( index < properties.count - 1 ? ", " : "" )
                  }

                  return string + ")"

            case .collection, .set:
                  if properties.isEmpty { return "[]" }

                  var string = "["

                  for ( index, property ) in properties.enumerated()
                  {
                        string += indentedString( objectAsSourceCode( property.value ) + ( index < properties.count - 1 ? ",\r" : "" ) )
                  }

                  return string + "\r]"

            case .dictionary:
                  if properties.isEmpty { return "[:]" }

                  var string = "["

                  for ( index, property ) in properties.enumerated()
                  {
                        let pair = Array( Mirror( reflecting: property.value ).children )

                        string += indentedString( "\( objectAsSourceCode( pair[ 0 ].value ) ): \( objectAsSourceCode( pair[ 1 ].value ) )" + ( index < properties.count - 1 ? ",\r" : "" ) )
                  }

                  return string + "\r]"

            case .enum:
                  if let _any = _any as? CustomDebugStringConvertible
                  {
                        return _any.debugDescription
                  }

                  if properties.isEmpty { return "\( mirror.subjectType )." + String( describing: _any ) }

                  var string = "\( mirror.subjectType ).\( properties.first!.label! )"

                  let associatedValueString = objectAsSourceCode( properties.first!.value )

                  if associatedValueString.first! == "("
                  {
                        string += associatedValueString
                  }
                  else
                  {
                        string += "(\( associatedValueString ))"
                  }

                  return string

            case .struct, .class:
                  if let _any = _any as? CustomDebugStringConvertible
                  {
                        return _any.debugDescription
                  }

                  if properties.isEmpty { return String( describing: _any ) }

                  var string = "\( mirror.subjectType )("

                  for ( index, property ) in properties.enumerated()
                  {
                        string += indentedString( "\( property.label! ): \( objectAsSourceCode( property.value ) )" + ( index < properties.count - 1 ? ",\r" : "" ) )
                  }

                  return string + "\r)"

            case .optional:
                  fatalError( "deepUnwrap must have failed..." )
            @unknown default:
                  fatalError( "@unknown default..." )
      }
}

/// всмомогательная ф-я для objectAsSourceCode()
func deepUnwrap( _ someObject: Any ) -> Any?
{
      let mirror = Mirror( reflecting: someObject )

      if mirror.displayStyle != .optional
      {
            return someObject
      }

      if let _child = mirror.children.first,
         _child.label == "some"
      {
            return deepUnwrap( _child.value )
      }

      return nil
}
