import CraneParameters

public enum URLError: Error {
  case invalidURL
  case missingParameter(ParameterName)
  case invalidParameter(ParameterName)
}
