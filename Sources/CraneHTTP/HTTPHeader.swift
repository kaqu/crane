/// Structured http header field.
public struct HTTPHeader {
  /// Name of header field.
  public let name: String
  /// Value of header field.
  public var value: String
  /// - parameter name: Name of header field.
  /// - parameter value: Value of header field.
  public init(_ name: String, value: String) {
    precondition(!value.contains(where: isNewLine), "Multiline headers are not supported yet")
    self.name = name
    self.value = value
  }
}

extension HTTPHeader: ExpressibleByStringLiteral {
  public init(stringLiteral value: StaticString) {
    let value: String = value.string
    precondition(!value.contains(where: isNewLine), "Multiline headers are not supported yet")
    let name = value.prefix(while: {$0 != ":"})
    guard
      name.count < value.count,
      name.allSatisfy(isHTTPToken)
    else { fatalError("Invalid http header literal \(value)") }
    self.name = String(name)
    self.value = String(value.suffix(from: name.endIndex))
    /* TODO: it should be parsed more strictly:
     value = *( content | LWS )
     content = <the OCTETs making up the field-value
     and consisting of either *TEXT or combinations of token, separators, and quoted-string>
     */
  }
}
