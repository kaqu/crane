import Foundation

/// Errors from network client associated with network and client itself.
public enum NetworkError: Error {
  /// Provided or generated url is not a valid url
  case invalidURL
  /// Provided url template contains unresolved parameter
  case missingURLParameter(String)
  /// Provided url query is not a valid query
  case invalidURLQuery
  /// Provided http headers are not valid headers
  case invalidHTTPHeaders
  /// Request body failed to encode
  case unableToEncodeRequestBody(reason: Error)
  /// Making request failed
  case unableToMakeRequest(reason: Error)
  /// Received response is not valid/expected
  case invalidResponse
  /// Received http status code is not valid/expected
  case invalidResponseStatusCode
  /// Response failed to decode
  case unableToDecodeResponse(HTTPResponse, reason: Error)
  /// Network client internal error
  case internalInconsistency
  /// Network session became closed or killed
  case sessionClosed
  /// Other error specific to concrete operation
  case other(Error)
}
