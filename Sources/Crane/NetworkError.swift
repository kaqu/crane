import CraneURL
import CraneHTTP

public enum NetworkError: Error {
  case invalidURL
  case httpError(HTTPError)
  case unableToEncodeRequestBody(reason: Error)
  case unableToMakeRequest(reason: Error)
  case invalidResponseStatusCode(HTTPStatusCode)
  case unableToDecodeResponse(HTTPResponse, reason: Error)
  case timeout
  case canceled
  case noInternet
  case sessionClosed
  case internalInconsistency
  case other(Error)
}
