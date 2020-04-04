import CraneParameters

public enum HTTPError: Error {
  case invalidHeader
  case invalidRequest
  case invalidResponse
  
  case parameterError(ParameterError)
}
