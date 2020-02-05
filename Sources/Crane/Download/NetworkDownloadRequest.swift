import Foundation.NSURL

public protocol NetworkDownloadRequest: RequestBase where Session: NetworkDownloadSession, Body == Void {
  /// Template for URL path used to save downloaded file.
  /// Might contain parameters that will be resolved
  /// when executing specific request.
  /// Parameters should be specified by names between `{` and `}`
  /// in path i.e. `/downloads/{id}.png` contains parameter "id".
  static var downloadDestinationPathTemplate: URLPathTemplate { get }
  
  var downloadDestinationURLParameters: URLParameters { get }
  
  static var downloadDestinationURLParameters: URLParameters { get }
  
  static func downloadDestinationURLParameters(for request: Self, in session: Session) -> Result<URLParameters, NetworkError>
  
  static func downloadDestinationURL(for request: Self, in session: Session) -> Result<URL, NetworkError>
}

public extension NetworkDownloadRequest {
  
  static var httpMethod: HTTPMethod { .get }
  
  var downloadDestinationURLParameters: URLParameters { [] }
  
  static var downloadDestinationURLParameters: URLParameters { [] }
  
  static func downloadDestinationURLParameters(
    for request: Self,
    in session: Session
  ) -> Result<URLParameters, NetworkError> {
    .success(urlParameters.updated(with: request.urlParameters))
  }
  
  static func downloadDestinationURL(
    for request: Self,
    in session: Session
  ) -> Result<URL, NetworkError> {
    downloadDestinationURLParameters(for: request, in: session)
      .flatMap { parameters in
        Self.downloadDestinationPathTemplate
          .buildLocalURL(with: parameters)
      }
  }
}
