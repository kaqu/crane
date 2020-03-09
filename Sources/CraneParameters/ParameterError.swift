public enum ParameterError: Error {
  case missing(ParameterName)
  case invalid(ParameterName, error: Error?) // TODO: make error non optional when adding validations
  case wrongType(ParameterName, expected: Any.Type)
}
