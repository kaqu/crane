import CraneParameters

public enum URLError: Error {
  case invalidURL
  case invalidEncoding
  case parameterError(ParameterError)
}
