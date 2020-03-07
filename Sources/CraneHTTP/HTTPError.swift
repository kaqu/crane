import CraneParameters

public enum HTTPError: Error {
  case invalidHeader
  case invalidResponse
  case invalidRequest
  case missingParameter(ParameterName)
  case invalidParameter(ParameterName, value: String)
}
