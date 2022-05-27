import Foundation
/*
 import MultipartForm
 */
import UIKit

// MARK: - HttpServer

/// HTTP-сервер
public class HttpServer
{
      /// Запрещаем создание экземпляров.
      private init() {}

      // MARK: - askRawData

      /// Инициирует запрос данных к серверу, вызывает замыкание с передачей туда результата
      public static func askRawData(
            urlRequest: URLRequest,
            then callback: @escaping CallbackWith<Data>
      ) -> Void
      {
            let urlStr = ( urlRequest.url?.description ).nilToEmpty

            debugLog( " with url = \( urlStr.quoted )." )

            // готовим и выполняем задачу с запросом:
            let task = URLSession.shared.dataTask(
                  with: urlRequest,
                  completionHandler:
                  { ( _dataMaybe: Data?, _responseMaybe: URLResponse?, errorMaybe: Error? ) -> Void in

                        let debugContext = DebugContext( callback, "URLSession_dataTask() callback", OFF: true )
                        /*
                         debugLog( "\(debugContext.callerName) \(ENTERED).")
                         */

                        // если ошибка соединения, вываливаемся:
                        guard errorMaybe == nil
                        else { return callbackDebugged( .failure( HttpServerError.UrlSessionError( urlStr, errorMaybe! ) ), debugContext ) }

                        // если ответ сервера не распознан, вываливаемся:
                        guard let _response = _responseMaybe as? HTTPURLResponse
                        else { return callbackDebugged( .failure( HttpServerError.InvalidResponse( urlStr ) ), debugContext ) }

                        // если код ответа сервера не равен удачному, вываливаемся:
                        guard _response.statusCode == 200
                        else
                        {
                              if _response.statusCode == 409
                              {
                                    return callbackDebugged( .failure( HttpServerError.InvalidLoginOrPassword ), debugContext )
                              }
                              else
                              {
                                    return callbackDebugged( .failure( HttpServerError.UnexpectedHttpCode( urlStr, _response.statusCode, HTTPURLResponse.localizedString( forStatusCode: _response.statusCode ) ) ), debugContext )
                              }
                        }

                        // если данные от сервера пустые, вываливаемся:
                        guard let _data = _dataMaybe
                        else { return callbackDebugged( .failure( HttpServerError.MissingResponseData( urlStr ) ), debugContext ) }

                        // здесь всё хорошо:
                        callbackDebugged( .success( _data ), debugContext )
                  }
            )
            task.resume()
      }

      // MARK: - askObject

      /// Запрашивает с сервера объект и передаёт его (или ошибку) в указанное замыкание
      public static func askObject<__Object: Decodable>(
            urlString: String,
            then callback: @escaping CallbackWith<__Object>
      ) -> Void
      {
            off( "\( ENTERED ) with urlString = \( urlString )." )
            defer { off( "\( EXITED )." ) } // будет вызвано в любом случае

            guard let _url = URL( string: urlString )
            else { return callback( .failure( HttpServerError.InvalidURL( urlString ) ) ) }

            var request = URLRequest( url: _url )
            request.httpMethod = "GET"
            request.timeoutInterval = 60 * 20 // секунд * минут

            // запрашиваем сырые данные
            askRawData(
                  urlRequest: request,
                  then:
                  { ( _result: ResultWith<Data> ) in

                        let debugContext = DebugContext( callback, "askRawData() callback", OFF: true )

                        off( "\( debugContext.callerName ) \( ENTERED )." )

                        _result
                              .onFailure { callbackDebugged( .failure( $0 ), debugContext ) }
                              .onSuccess // по получению сырых данных пробуем их трансформировать в объект
                              { _rawData in

                                    // если данные от сервера не преобразовать в строку, вываливаемся:
                                    guard String( data: _rawData, encoding: .utf8 ) != nil
                                    else { return callbackDebugged( .failure( HttpServerError.CannotConvertAnswerToString ), debugContext ) }

                                    // преобразуем данные от сервера в объект:
                                    let decodeResult = Result( catching: { try SmartJSONDecoder.decode( __Object.self, from: _rawData ) } )

                                    callbackDebugged( decodeResult, debugContext )
                              }
                  }
            )
      }

      // MARK: - saveObject

      /// передаёт на сервер изменённый объект
      public static func saveObject<__Object: Encodable>(
            urlString: String,
            object: __Object,
            isNew: Bool,
            then callback: @escaping CallbackWithoutData
      ) -> Void
      {
            // если адресная строка содержит ошибки, вываливаемся:
            guard let _url = URL( string: urlString )
            else { return callback( .failure( HttpServerError.InvalidURL( urlString ) ) ) }

            off( " with url = \( _url.description.quoted )" )

            // начинаем заполнять запрос:
            var request = URLRequest( url: _url )
            request.httpMethod = isNew ? "POST" : "PUT"
            request.setValue( "application/json; charset=utf-8", forHTTPHeaderField: "Content-Type" )

            // если объект не хочет превращаться в JSON, вываливаемся:
            do { request.httpBody = try SmartJSONEncoder.encode( object ) } // — объект в виде JSON, как тело запроса
            catch let _error
            { return callback( .failure( _error ) ) }

            // показываем в отладке, что отправляем:
            debugLog( " request: \( urlString ) [\( request.httpMethod.nilToEmpty )] \( String( data: request.httpBody!, encoding: .utf8 ).default( "<unknown>" ) )" )

            // готовим и выполняем задачу с запросом:
            let task = URLSession.shared.dataTask(
                  with: request,
                  completionHandler:
                  { ( _dataMaybe: Data?, _responseMaybe: URLResponse?, errorMaybe: Error? ) -> Void in

                        let debugContext = DebugContext( callback, "URLSession_dataTask() callback" ) // , OFF: true )

                        // если ошибка соединения, вываливаемся:
                        guard errorMaybe == nil
                        else { return callbackDebugged( .failure( HttpServerError.UrlSessionError( urlString, errorMaybe! ) ), debugContext ) }

                        // если ответ сервера не распознан, вываливаемся:
                        guard let _response = _responseMaybe as? HTTPURLResponse
                        else { return callbackDebugged( .failure( HttpServerError.InvalidResponse( urlString ) ), debugContext ) }

                        // если код ответа сервера не равен удачному, вываливаемся:
                        guard _response.statusCode == 200
                        else { return callbackDebugged( .failure( HttpServerError.UnexpectedHttpCode( urlString, _response.statusCode, HTTPURLResponse.localizedString( forStatusCode: _response.statusCode ) ) ), debugContext ) }

                        do // just for debug!
                        {
                              // если данные от сервера пустые, вываливаемся:
                              guard let _data = _dataMaybe
                              else { return callbackDebugged( .failure( HttpServerError.MissingResponseData( urlString ) ), debugContext ) }

                              // если данные от сервера не преобразовать в строку, вываливаемся:
                              guard let _responseBody = String( data: _data, encoding: .utf8 )
                              else { return callbackDebugged( .failure( HttpServerError.CannotConvertAnswerToString ), debugContext ) }

                              debugLog( " Response Body: \( _responseBody.quoted )" )
                        }

                        // здесь всё хорошо:
                        callbackDebugged( .success( () ), debugContext )
                  }
            )
            task.resume()
      }

      // MARK: - uploadImage

      /// Инициирует запрос отправки фото на сервер, вызывает замыкание с передачей туда результата
      public static func uploadImage(
            urlString: String,
            image: UIImage,
            then callback: @escaping CallbackWithoutData
      ) -> Void
      {
            debugLog( "with urlString = \( urlString )." )

            guard let _url = URL( string: urlString )
            else { return callback( .failure( HttpServerError.InvalidURL( urlString ) ) ) }

            // если картинка не хочет превращаться в jpeg, вываливаемся:
            guard let _imageData = image.jpegData( compressionQuality: 1 )
            else { return callback( .failure( HttpServerError.CannotConvertImageToJpeg ) ) }

            // начинаем заполнять запрос:
            var request = URLRequest( url: _url )
            request.httpMethod = "POST"
            request.setValue( _imageData.count.asString , forHTTPHeaderField: "Content-Length" ) // TODO: проверить: возможно это не нужно

            // готовим и выполняем задачу с запросом:
            let task = URLSession.shared.uploadTask(
                  with: request,
                  from: _imageData,
                  completionHandler:
                  { ( _dataMaybe: Data?, _responseMaybe: URLResponse?, errorMaybe: Error? ) -> Void in
                        let debugContext = DebugContext( callback, "URLSession_dataTask() callback" ) // , OFF: true )

                        // если ошибка соединения, вываливаемся:
                        guard errorMaybe == nil
                        else { return callbackDebugged( .failure( HttpServerError.UrlSessionError( urlString, errorMaybe! ) ), debugContext ) }

                        // если ответ сервера не распознан, вываливаемся:
                        guard let _response = _responseMaybe as? HTTPURLResponse
                        else { return callbackDebugged( .failure( HttpServerError.InvalidResponse( urlString ) ), debugContext ) }

                        // если код ответа сервера не равен удачному, вываливаемся:
                        guard _response.statusCode == 200
                        else { return callbackDebugged( .failure( HttpServerError.UnexpectedHttpCode( urlString, _response.statusCode, HTTPURLResponse.localizedString( forStatusCode: _response.statusCode ) ) ), debugContext ) }

                        do // just for debug!
                        {
                              // если данные от сервера пустые, вываливаемся:
                              guard let _data = _dataMaybe
                              else { return callbackDebugged( .failure( HttpServerError.MissingResponseData( urlString ) ), debugContext ) }

                              // если данные от сервера не преобразовать в строку, вываливаемся:
                              guard let _responseBody = String( data: _data, encoding: .utf8 )
                              else { return callbackDebugged( .failure( HttpServerError.CannotConvertAnswerToString ), debugContext ) }

                              debugLog( " Response Body: \( _responseBody.quoted )" )
                        }

                        // здесь всё хорошо:
                        callbackDebugged( .success( () ), debugContext )
                  }
            )

            task.resume()
      }

      // MARK: - uploadVideo

      public class VideoUploadResult: Codable
      {
            public var url: String
            public var hash: String
            public var thumbnailAvailable: Bool
      }

      /// Инициирует запрос отправки фото на сервер, вызывает замыкание с передачей туда результата
      public static func uploadVideo(
            urlString: String,
            fileURL: URL,
            then callback: @escaping CallbackWith<VideoUploadResult>
      ) -> Void
      {
            debugLog( "with urlString = \( urlString.lowercased() )." )

            guard let _url = URL( string: urlString.lowercased() ) // без .lowercased() возвращается 403 (forbidden)
            else { return callback( .failure( HttpServerError.InvalidURL( urlString ) ) ) }

            let task = try! URLSession.shared.uploadMultipartTask(
                  with: _url,
                  parameters: [: ],
                  fileKeyName: "",
                  fileURLs: [ fileURL ],
                  completionHandler:
                  { ( _dataMaybe: Data?, _responseMaybe: URLResponse?, errorMaybe: Error? ) -> Void in
                        let debugContext = DebugContext( callback, "URLSession_dataTask() callback" ) // , OFF: true )

                        // если ошибка соединения, вываливаемся:
                        guard errorMaybe == nil
                        else { return callbackDebugged( .failure( HttpServerError.UrlSessionError( urlString, errorMaybe! ) ), debugContext ) }

                        // если ответ сервера не распознан, вываливаемся:
                        guard let _response = _responseMaybe as? HTTPURLResponse
                        else { return callbackDebugged( .failure( HttpServerError.InvalidResponse( urlString ) ), debugContext ) }

                        // если код ответа сервера не равен удачному, вываливаемся:
                        guard _response.statusCode == 200
                        else { return callbackDebugged( .failure( HttpServerError.UnexpectedHttpCode( urlString, _response.statusCode, HTTPURLResponse.localizedString( forStatusCode: _response.statusCode ) ) ), debugContext ) }

                        // если данные от сервера пустые, вываливаемся:
                        guard let _data = _dataMaybe
                        else { return callbackDebugged( .failure( HttpServerError.MissingResponseData( urlString ) ), debugContext ) }

                        // если данные от сервера не преобразовать в строку, вываливаемся:
                        guard let _responseBody = String( data: _data, encoding: .utf8 )
                        else { return callbackDebugged( .failure( HttpServerError.CannotConvertAnswerToString ), debugContext ) }

                        debugLog( " Response Body: \( _responseBody.quoted )" )

                        // преобразуем данные от сервера в объект:
                        let decodeResult = Result( catching: { try SmartJSONDecoder.decode( [ VideoUploadResult ].self, from: _data ) } )

                        decodeResult
                              .onFailure { callbackDebugged( .failure( $0 ), debugContext ) }
                              .onSuccess
                              {
                                    guard $0.notEmpty
                                    else { return callbackDebugged( .failure( HttpServerError.InvalidResponse( _responseBody ) ), debugContext ) } // TODO: более корректное сообщение

                                    callbackDebugged( .success( $0[ 0 ] ) , debugContext )
                              }

                        /*
                         guard decodeResult.notEmpty
                         else { return callbackDebugged( .failure( HttpServerError.InvalidResponse( _responseBody ) ), debugContext ) }

                         // здесь всё хорошо:
                         callbackDebugged( decodeResult, debugContext )
                         */
                  }
            )

            task.resume()
      }

      // MARK: - delete

      /// удаляет на сервере объект с заданным в запросе id
      public static func delete(
            urlString: String,
            then callback: @escaping CallbackWithoutData
      ) -> Void
      {
            // если адресная строка содержит ошибки, вываливаемся:
            guard let _url = URL( string: urlString )
            else { return callback( .failure( HttpServerError.InvalidURL( urlString ) ) ) }

            debugLog( " with url = \( _url.description.quoted )" )

            // начинаем заполнять запрос:
            var request = URLRequest( url: _url )
            request.httpMethod = "DELETE"

            HttpServer.askRawData(
                  urlRequest: request,
                  then:
                  { ( _result: ResultWith<Data> ) in

                        let debugContext = DebugContext( callback, "HttpServer.askRawData() callback", OFF: true )

                        _result
                              .onFailure { callbackDebugged( .failure( $0 ), debugContext ) }
                              .onSuccess { _ in callbackDebugged( .success( () ), debugContext ) } // ответное тело значения не имеет.
                  }
            )
      }
}
