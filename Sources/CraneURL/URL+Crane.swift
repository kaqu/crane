import struct Foundation.NSURL.URL
import struct Foundation.NSURL.URLComponents

public extension URL {
  init?(
    scheme: String = "https",
    host: String,
    port: Int? = nil,
    path: URLPath = [],
    query: URLQuery = []
  ) {
    guard
      let url = URLComponents(
        scheme: scheme,
        host: host,
        port: port,
        path: path,
        query: query
      ).url
    else { return nil }
    self = url
  }
}

public extension URLComponents {
  init(
    scheme: String = "https",
    host: String,
    port: Int? = nil,
    path: URLPath = [],
    query: URLQuery = []
  ) {
    self.init()
    self.scheme = scheme
    self.host = host
    self.port = port
    self.percentEncodedPath = path.percentEncodedString
    self.query = query.queryString
  }
}
