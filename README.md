# Crane

Crane is a Swift library that allows you to build compact network clients in a declarative way.

**Work in progress... public api is yet subject to change.**

## Example - Parameters version

Declare:

```swift
enum TestCall: NetworkCall {
  struct Request: NetworkRequest {
    typealias Body = Void
    var parameters: Parameters
    
    init(userID: Int) {
      parameters = [%(userID, for: "userID")]
    }
    
    static var path: URLPath = ["/anything", %("userID", of: Int.self, validator: { $0 > 99 })]
    static var query: URLQuery = ["some": %("some", of: String.self, default: "None")]
  }

  enum Response: NetworkResponse {
    case string(String)
    static func from(_ response: HTTPResponse) -> Result<TestCall.Response, NetworkError> {
      .success(.string("\(response.statusCode.rawValue): " + (String(data: response.body, encoding: .utf8) ?? "N/A")))
    }
  }
}
```

Then use:

```swift
let session: URLNetworkSession = .init(host: "httpbin.org")
session.make(TestCall.self, .init(userID: 100)) { result in
  print(result)
}
```
