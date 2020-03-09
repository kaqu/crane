import CraneParameters

public enum HTTPError: Error {
  case invalidHeader
  case invalidRequest
  case invalidResponse
  
  case missingParameter(ParameterName)
  case invalidParameter(ParameterName, value: String)
}
