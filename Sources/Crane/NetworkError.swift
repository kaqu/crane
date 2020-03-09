import CraneURL
import CraneHTTP

public enum NetworkError: Error {
  case urlError(CraneURL.URLError)
  case httpError(HTTPError)
  case timeout
  case unableToEncodeRequestBody(reason: Error)
  case unableToMakeRequest(reason: Error)
  case invalidResponseStatusCode(HTTPStatusCode)
  case unableToDecodeResponse(HTTPResponse, reason: Error)
  case internalInconsistency
  case sessionClosed
  case other(Error)
}
