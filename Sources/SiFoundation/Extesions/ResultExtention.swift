import Foundation

public typealias ResultWith<__Data> = Result<__Data, Error>
public typealias ResultWithoutData = Result<Void, Error>

public typealias CallbackWith<__Data> = ( ResultWith<__Data> ) -> Void
public typealias CallbackWithoutData = ( ResultWithoutData ) -> Void

extension Result
{
      /*
      /// Преобразует объект ошибки в подробную строку
      var /* prop */ errorString: String? // TODO: необходимость под вопросом!
      {
            switch self
            {
                  case .success:
                        return nil
                  case .failure( let _error ):
                        return ( _error.extendedDescription )
            }
      }

      var /* prop */ dataMaybe: Success? // TODO: необходимость под вопросом!
      {
            return try? self.get()
      }
      */

      @discardableResult
      public func onSuccess( _ handler: ( Success ) -> Void ) -> Self
      {
            if case .success( let _value ) = self
            {
                  handler( _value )
            }
            return self
      }

      @discardableResult
      public func onFailure( _ handler: ( Failure ) -> Void ) -> Self
      {
            if case .failure( let _error ) = self
            {
                  handler( _error )
            }
            return self
      }
}
