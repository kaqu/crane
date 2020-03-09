import CraneParameters

public enum URLError: Error {
  case invalidURL
  case invalidEncoding
  case missingParameter(ParameterName)
  case invalidParameter(ParameterName, error: Error?)
}
