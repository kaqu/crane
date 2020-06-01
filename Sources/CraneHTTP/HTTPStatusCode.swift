/// HTTP status code.
public enum HTTPStatusCode {
  // MARK: - 100..<200
  case `continue`
  case switchingProtocols
  case processing
  // MARK: - 200..<300
  case ok
  case created
  case accepted
  case nonAuthoritativeInformation
  case noContent
  case resetContent
  case partialContent
  case multiStatus
  case alreadyReported
  // MARK: - 300..<400
  case multipleChoices
  case movedPermanently
  case found
  case seeOther
  case notModified
  case useProxy
  case temporaryRedirect
  case permanentRedirect
  // MARK: - 400..<500
  case badRequest
  case unauthorized
  case paymentRequired
  case forbidden
  case notFound
  case methodNotAllowed
  case notAcceptable
  case proxyAuthenticationRequired
  case requestTimeout
  case conflict
  case gone
  case lengthRequired
  case preconditionFailed
  case payloadTooLarge
  case uriTooLong
  case unsupportedMediaType
  case rangeNotSatisfiable
  case expectationFailed
  case imATeapot
  case misdirectedRequest
  case unprocessableEntity
  case locked
  case failedDependency
  case upgradeRequired
  case preconditionRequired
  case tooManyRequests
  case requestHeaderFieldsTooLarge
  case unavailableForLegalReasons
  // MARK: - 500..<600
  case internalServerError
  case notImplemented
  case badGateway
  case serviceUnavailable
  case gatewayTimeout
  case httpVersionNotSupported
  case variantAlsoNegotiates
  case insufficientStorage
  case loopDetected
  case notExtended
  case networkAuthenticationRequired
  // MARK: - custom
  case custom(Int)
}

extension HTTPStatusCode: Equatable {}

extension HTTPStatusCode: RawRepresentable {
  
  public init?(rawValue: Int) {
    switch rawValue {
      // MARK: - 100..<200
      case 100: self = .continue
      case 101: self = .switchingProtocols
      case 102: self = .processing
      // MARK: - 200..<300
      case 200: self = .ok
      case 201: self = .created
      case 202: self = .accepted
      case 203: self = .nonAuthoritativeInformation
      case 204: self = .noContent
      case 205: self = .resetContent
      case 206: self = .partialContent
      case 207: self = .multiStatus
      case 208: self = .alreadyReported
      
      // MARK: - 300..<400
      case 300: self = .multipleChoices
      case 301: self = .movedPermanently
      case 302: self = .found
      case 303: self = .seeOther
      case 304: self = .notModified
      case 305: self = .useProxy
      case 307: self = .temporaryRedirect
      case 308: self = .permanentRedirect
      // MARK: - 400..<500
      case 400: self = .badRequest
      case 401: self = .unauthorized
      case 402: self = .paymentRequired
      case 403: self = .forbidden
      case 404: self = .notFound
      case 405: self = .methodNotAllowed
      case 406: self = .notAcceptable
      case 407: self = .proxyAuthenticationRequired
      case 408: self = .requestTimeout
      case 409: self = .conflict
      case 410: self = .gone
      case 411: self = .lengthRequired
      case 412: self = .preconditionFailed
      case 413: self = .payloadTooLarge
      case 414: self = .uriTooLong
      case 415: self = .unsupportedMediaType
      case 416: self = .rangeNotSatisfiable
      case 417: self = .expectationFailed
      case 418: self = .imATeapot
      case 421: self = .misdirectedRequest
      case 422: self = .unprocessableEntity
      case 423: self = .locked
      case 424: self = .failedDependency
      case 426: self = .upgradeRequired
      case 428: self = .preconditionRequired
      case 429: self = .tooManyRequests
      case 431: self = .requestHeaderFieldsTooLarge
      case 451: self = .unavailableForLegalReasons
        // MARK: - 500..<600
      case 500: self = .internalServerError
      case 501: self = .notImplemented
      case 502: self = .badGateway
      case 503: self = .serviceUnavailable
      case 504: self = .gatewayTimeout
      case 505: self = .httpVersionNotSupported
      case 506: self = .variantAlsoNegotiates
      case 507: self = .insufficientStorage
      case 508: self = .loopDetected
      case 510: self = .notExtended
      case 511: self = .networkAuthenticationRequired
      // MARK: - custom
      case let code: self = .custom(code)
    }
  }

  public var rawValue: Int {
    switch self {
      // MARK: - 100..<200
      case .continue: return 100
      case .switchingProtocols : return 101
      case .processing : return 102
      // MARK: - 200..<300
      case .ok: return 200
      case .created : return 201
      case .accepted : return 202
      case .nonAuthoritativeInformation : return 203
      case .noContent : return 204
      case .resetContent : return 205
      case .partialContent : return 206
      case .multiStatus : return 207
      case .alreadyReported : return 208
      // MARK: - 300..<400
      case .multipleChoices : return 300
      case .movedPermanently : return 301
      case .found : return 302
      case .seeOther : return 303
      case .notModified : return 304
      case .useProxy : return 305
      case .temporaryRedirect : return 307
      case .permanentRedirect : return 308
      // MARK: - 400..<500
      case .badRequest : return 400
      case .unauthorized : return 401
      case .paymentRequired : return 402
      case .forbidden : return 403
      case .notFound : return 404
      case .methodNotAllowed : return 405
      case .notAcceptable : return 406
      case .proxyAuthenticationRequired : return 407
      case .requestTimeout : return 408
      case .conflict : return 409
      case .gone : return 410
      case .lengthRequired : return 411
      case .preconditionFailed : return 412
      case .payloadTooLarge : return 413
      case .uriTooLong : return 414
      case .unsupportedMediaType : return 415
      case .rangeNotSatisfiable : return 416
      case .expectationFailed : return 417
      case .imATeapot : return 418
      case .misdirectedRequest : return 421
      case .unprocessableEntity : return 422
      case .locked : return 423
      case .failedDependency : return 424
      case .upgradeRequired : return 426
      case .preconditionRequired : return 428
      case .tooManyRequests : return 429
      case .requestHeaderFieldsTooLarge : return 431
      case .unavailableForLegalReasons : return 451
      // MARK: - 500..<600
      case .internalServerError : return 500
      case .notImplemented : return 501
      case .badGateway : return 502
      case .serviceUnavailable : return 503
      case .gatewayTimeout : return 504
      case .httpVersionNotSupported : return 505
      case .variantAlsoNegotiates : return 506
      case .insufficientStorage : return 507
      case .loopDetected : return 508
      case .notExtended : return 510
      case .networkAuthenticationRequired : return 511
      // MARK: - custom
      case let .custom(code): return code
    }
  }
}
