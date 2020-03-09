//import Foundation

public protocol NetworkSession {
  func make(
    _ request: HTTPRequest,
    _ callback: @escaping ResultCallback<HTTPResponse, NetworkError>
  )
}

extension NetworkSession {
  func make<Call: NetworkCall>(
    _ call: Call.Type = Call.self,
    _ request: Call.Request,
    _ callback: @escaping ResultCallback<Call.Response, NetworkError>
  ) {
    fatalError()
  }
}
