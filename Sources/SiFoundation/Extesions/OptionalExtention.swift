import Foundation

public func nilCompare<__SomeType: Comparable>(
      _ lhs: __SomeType?,
      _ rhs: __SomeType?,
      nilIsLess: Bool = true
) -> Bool
{
      switch ( lhs, rhs )
      {
            case ( nil, nil ): return true
            case ( nil, _? ): return nilIsLess
            case ( _?, nil ): return !nilIsLess
            case ( let a?, let b? ): return a < b
      }
}

public extension Optional
{
      /// example: let file = try loadFile(at: path).orThrow(MissingFileError())
      func orThrow( _ errorExpression: @autoclosure () -> Error ) throws -> Wrapped
      {
            switch self
            {
                  case .some( let value ):
                        return value
                  case .none:
                        throw errorExpression()
            }
      }

      /// если опционал пуст , то вернуть заданное параметром значение, иначе вернуть развёрнутое содержимое
      func `default`( _ defaultValue: Wrapped ) -> Wrapped
      {
            switch self
            {
                  case .some( let _value ):
                        return _value
                  case .none:
                        return defaultValue
            }
      }
}

// для удобства проверок сразу без разыменования, в стиле:
// if workItemRef.isCancelled { return }
public extension Optional where Wrapped == DispatchWorkItem
{
      var /* prop */ isCancelled: Bool
      { return ( self?.isCancelled ).default( true ) }
}
