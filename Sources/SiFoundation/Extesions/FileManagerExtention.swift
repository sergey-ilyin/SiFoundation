import Foundation

public extension FileManager
{
      func createSubdirs( for folderURL: URL ) throws
      {
            do
            {
                  try self.createDirectory( at: folderURL, withIntermediateDirectories: true, attributes: nil )
            }
            catch CocoaError.fileWriteFileExists
            {} // игнорируем ошибку уже существующей папки
            catch let _error
            { throw _error } // выталкиваем дальше остальные ошибки    }
      }
}
