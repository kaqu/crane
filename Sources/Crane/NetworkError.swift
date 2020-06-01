import CraneURL
import CraneHTTP

public enum NetworkError: Error {
  case invalidURL
  case unableToEncodeRequestBody(reason: Error)
  case invalidResponseStatusCode(HTTPResponse)
  case unableToDecodeResponse(HTTPResponse, reason: Error)
  case timeout
  case canceled
  case noInternet
  case sessionClosed
  case internalInconsistency
  case other(Error)
}
