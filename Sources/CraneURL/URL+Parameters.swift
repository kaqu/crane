import Foundation.NSURL
import CraneParameters

public extension URL {
  static func using(
    scheme: String = "https",
    host: String,
    port: Int? = nil,
    path: URLPath = [],
    query: URLQuery = [],
    with parameters: Parameters = []
  ) -> Result<URL, URLError> {
    path
    .resolve(using: parameters)
    .flatMap { path in
      query
      .resolve(using: parameters)
      .flatMap { query in
        var components: URLComponents = .init()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path
        components.query = query
        return components.url.map { .success($0) } ?? .failure(.invalidURL)
      }
    }
  }
  
  static func local(
    path: URLPath,
    with parameters: Parameters = []
  ) -> Result<URL, URLError> {
    path
    .resolve(using: parameters)
    .flatMap { path in
      var components: URLComponents = .init()
      components.scheme = "file"
      components.path = path
      return components.url.map { .success($0) } ?? .failure(.invalidURL)
    }
  }
}
