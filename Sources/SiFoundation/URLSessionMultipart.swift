//  Initialy created by Robert Ryan on 10/6/14.
//  Modified by Sergey Ilyin 22.11.2021.

import Foundation
import MobileCoreServices

public extension URLSession
{


      /// Create multipart upload task.
      ///
      /// This should not be used with background sessions. Use the rendition without
      /// `completionHandler` if using background sessions.
      ///
      /// - parameter URL:                The `URL` for the web service.
      /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
      /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
      /// - parameter fileURLs:           An optional array of `URL` for local files to be included in `Data`.
      /// - parameter completionHandler:  The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
      ///
      /// - returns:                      The `URLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.

      func uploadMultipartTask( with url: URL, parameters: [ String: AnyObject ]?, fileKeyName: String?, fileURLs: [ URL ]?, completionHandler: @escaping ( Data?, URLResponse?, Error? ) -> Void ) throws -> URLSessionUploadTask
      {
            let ( request, data ) = try createMultipartRequest( with: url, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs )
            return uploadTask( with: request, from: data, completionHandler: completionHandler )
      }

      /// Create multipart data task.
      ///
      /// This should not be used with background sessions. Use `uploadMultipartTaskWithURL` with
      /// `localFileURL` and without `completionHandler` if using background sessions.
      ///
      /// - parameter URL:                The `URL` for the web service.
      /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
      /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
      /// - parameter fileURLs:           An optional array of `URL` for local files to be included in `Data`.
      ///
      /// - returns:                      The `URLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.

      func dataMultipartTask( with url: URL, parameters: [ String: AnyObject ]?, fileKeyName: String?, fileURLs: [ URL ]? ) throws -> URLSessionDataTask
      {
            var ( request, data ) = try createMultipartRequest( with: url, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs )
            request.httpBody = data
            return dataTask( with: request )
      }

      /// Create multipart data task.
      ///
      /// This should not be used with background sessions. Use `uploadMultipartTaskWithURL` with
      /// `localFileURL` and without `completionHandler` if using background sessions.
      ///
      /// - parameter URL:                The `URL` for the web service.
      /// - parameter parameters:         The optional dictionary of parameters to be passed in the body of the request.
      /// - parameter fileKeyName:        The name of the key to be used for files included in the request.
      /// - parameter fileURLs:           An optional array of `URL` for local files to be included in `Data`.
      /// - parameter completionHandler:  The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
      ///
      /// - returns:                      The `URLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.

      func dataMultipartTask( url: URL, parameters: [ String: AnyObject ]?, fileKeyName: String?, fileURLs: [ URL ]?, completionHandler: @escaping ( Data?, URLResponse?, Error? ) -> Void ) throws -> URLSessionDataTask
      {
            var ( request, data ) = try createMultipartRequest( with: url, parameters: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs )
            request.httpBody = data
            return dataTask( with: request, completionHandler: completionHandler )
      }

      /// Create upload request.
      ///
      /// With upload task, we return separate `URLRequest` and `Data` to be passed to `uploadTaskWithRequest(fromData:)`.
      ///
      /// - parameter URL:          The `URL` for the web service.
      /// - parameter parameters:   The optional dictionary of parameters to be passed in the body of the request.
      /// - parameter fileKeyName:  The name of the key to be used for files included in the request.
      /// - parameter fileURLs:     An optional array of `URL` for local files to be included in `Data`.
      ///
      /// - returns:                The `URLRequest` that was created. This throws error if there was problem opening file in the `fileURLs`.

      func createMultipartRequest( with url: URL, parameters: [ String: AnyObject ]?, fileKeyName: String?, fileURLs: [ URL ]? ) throws -> ( URLRequest, Data )
      {
            let boundary = URLSession.generateBoundaryString()

            var request = URLRequest( url: url )
            request.httpMethod = "POST"
            request.setValue( "multipart/form-data; boundary=\( boundary )", forHTTPHeaderField: "Content-Type" )

            let data = try createData( with: parameters, fileKeyName: fileKeyName, fileURLs: fileURLs, boundary: boundary )

            return ( request, data )
      }

      /// Create body of the multipart/form-data request
      ///
      /// - parameter parameters:   The optional dictionary of parameters to be included.
      /// - parameter fileKeyName:  The name of the key to be used for files included in the request.
      /// - parameter boundary:     The multipart/form-data boundary.
      ///
      /// - returns:                The `Data` of the body of the request. This throws error if there was problem opening file in the `fileURLs`.

      private func createData( with parameters: [ String: AnyObject ]?, fileKeyName: String?, fileURLs: [ URL ]?, boundary: String ) throws -> Data
      {
            var body = Data()

            if let _parameters = parameters
            {
                  for ( key, value ) in _parameters
                  {
                        body.appendString( "--\( boundary )\r\n" )
                        body.appendString( "Content-Disposition: form-data; name=\"\( key )\"\r\n\r\n" )
                        body.appendString( "\( value )\r\n" )
                  }
            }

            if let _fileURLs = fileURLs
            {
                  guard let _fileKeyName = fileKeyName
                  else {
                        throw NSError( domain: Bundle.main.bundleIdentifier ?? "URLSession+Multipart", code: -1, userInfo: [ NSLocalizedDescriptionKey: "If fileURLs supplied, fileKeyName must not be nil" ] )
                  }

                  for _fileURL in _fileURLs
                  {
                        let fileExt = _fileURL.pathExtension
                        let filename = UUID().asString + "." + fileExt // имена закачиваемых файлов должны быть каждый раз разные, иначе сервер выдаёт ошибку...
                        
                        guard let _data = try? Data( contentsOf: _fileURL )
                        else
                        {
                              throw NSError( domain: Bundle.main.bundleIdentifier ?? "URLSession+Multipart", code: -1, userInfo: [ NSLocalizedDescriptionKey: "Unable to open \( _fileURL.path )" ] )
                        }

                        let mimetype = URLSession.mimeType( for: _fileURL.path )

                        body.appendString( "--\( boundary )\r\n" )
                        body.appendString( "Content-Disposition: form-data; name=\"\( _fileKeyName )\"; filename=\"\( filename )\"\r\n" )
                        body.appendString( "Content-Type: \( mimetype )\r\n\r\n" )
                        body.append( _data )
                        body.appendString( "\r\n" )
                  }
            }

            body.appendString( "--\( boundary )--\r\n" )
            return body
      }

      /// Create boundary string for multipart/form-data request
      ///
      /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.

      private class func generateBoundaryString() -> String
      {
            return "Boundary-\( UUID().asString )"
      }

      /// Determine mime type on the basis of extension of a file.
      ///
      /// This requires MobileCoreServices framework.
      ///
      /// - parameter path:         The path of the file for which we are going to determine the mime type.
      ///
      /// - returns:                Returns the mime type if successful. Returns application/octet-stream if unable to determine mime type.

      internal class func mimeType( for path: String ) -> String
      {
            let url = URL( fileURLWithPath: path )
            let pathExtension = url.pathExtension

            if let uti = UTTypeCreatePreferredIdentifierForTag( kUTTagClassFilenameExtension, pathExtension as NSString, nil )?.takeRetainedValue()
            {
                  if let mimetype = UTTypeCopyPreferredTagWithClass( uti, kUTTagClassMIMEType )?.takeRetainedValue()
                  {
                        return mimetype as String
                  }
            }
            return "application/octet-stream";
      }
}

extension Data
{
      mutating func appendString( _ string: String )
      {
            let data = string.data( using: String.Encoding.utf8, allowLossyConversion: true )
            append( data! )
      }
}
