public enum ParameterError: Error {
  case missing(ParameterName)
  case invalid(ParameterName, error: Error)
  case wrongType(Any.Type, for: ParameterName, expected: Any.Type)
}

public enum ParameterValidationError: Error {
  case missing
  case invalid
}
