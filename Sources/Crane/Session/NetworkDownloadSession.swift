//import Foundation.NSURL
//
///// Abstraction over network session, used to communicate with given host.
///// Works as context provided to all request done through it.
///// Might be used to persist data between requests.
///// Intended to use with NetworkDownloadRequest instances.
//public protocol NetworkDownloadSession: SessionContext {
//    /// Executes given request expecting URL for downloaded file
//    /// according to request description in context of this session.
//    /// - parameter request: network request to make
//    /// - parameter callback: function called when result of request is available
//    func make<Request: NetworkDownloadRequest>(
//      _ request: Request,
//      _ callback: @escaping ResultCallback<URL, NetworkError>
//    ) where Request.Session == Self
//}
