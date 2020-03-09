//import Foundation.NSURL
//
///// Abstraction over network session, used to communicate with given host.
///// Works as context provided to all request done through it.
///// Might be used to persist data between requests.
///// Intended to use with NetworkConnectionRequest instances.
//public protocol NetworkConnectionSession: SessionContext {
//    /// Executes given request expecting connection access
//    /// according to request description in context of this session.
//    /// - parameter request: network request to make
//    /// - parameter callback: function called when result of request is available
//    func make<Request: NetworkConnectionRequest>(
//      _ request: Request,
//      _ callback: @escaping ResultCallback<NetworkConnection<Request>, NetworkError>
//    ) where Request.Session == Self
//}
