//
//  NetworkClient.swift
//  ImageFeed
//

import Foundation

final class NetworkClient {
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Init
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - Main Request Method
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> URLSessionTask {
        guard let urlRequest = makeURLRequest(from: endpoint) else {
            print("[NetworkClient] ❌ Failed to create URLRequest for endpoint: \(endpoint.path)")
            completion(.failure(.invalidRequest))
            return session.dataTask(with: URLRequest(url: URL(string: "about:blank")!))
        }
        
        print("[NetworkClient] ⬆️ Sending \(endpoint.method.rawValue) request to: \(urlRequest.url?.absoluteString ?? "nil")")
        if let headers = urlRequest.allHTTPHeaderFields {
            print("[NetworkClient] 📝 Headers: \(headers)")
        }
        if let body = endpoint.body, let bodyString = String(data: body, encoding: .utf8) {
            print("[NetworkClient] 📦 Request body: \(bodyString)")
        }
        
        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.handleResponse(
                    data: data,
                    response: response,
                    error: error,
                    completion: completion
                )
            }
        }
        
        task.resume()
        return task
    }
    
    // MARK: - HTTP Methods
    func get<T: Decodable>(
        path: String,
        baseURL: URL? = nil,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> URLSessionTask {
        let endpoint = Endpoint(
            path: path,
            method: .get,
            baseURL: baseURL,
            headers: headers,
            queryItems: queryItems,
            body: nil
        )
        return request(endpoint, completion: completion)
    }
    
    func post<T: Decodable>(
        path: String,
        baseURL: URL? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> URLSessionTask {
        let endpoint = Endpoint(
            path: path,
            method: .post,
            baseURL: baseURL,
            headers: headers,
            queryItems: nil,
            body: body
        )
        return request(endpoint, completion: completion)
    }
    
    // MARK: - Private Methods
    private func makeURLRequest(from endpoint: Endpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = endpoint.baseURL?.host ?? Constants.defaultBaseURL?.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems
        
        guard let url = components.url else {
            print("[NetworkClient] ❌ Failed to create URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
    
    private func handleResponse<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: (Result<T, NetworkError>) -> Void
    ) {
        if let error = error {
            print("[NetworkClient] ❌ Connection error: \(error.localizedDescription)")
            completion(.failure(.connectionError(error)))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[NetworkClient] ❌ Invalid response: no HTTPURLResponse")
            completion(.failure(.invalidResponse))
            return
        }
        
        print("[NetworkClient] ⬇️ Received response from: \(httpResponse.url?.absoluteString ?? "nil")")
        print("[NetworkClient] 📊 Status code: \(httpResponse.statusCode)")
        
        if let headers = httpResponse.allHeaderFields as? [String: Any] {
            print("[NetworkClient] 📝 Response headers: \(headers)")
        }
        
        guard let data = data else {
            print("[NetworkClient] ❌ No data received")
            completion(.failure(.noDataReceived))
            return
        }
        
        if let responseBody = String(data: data, encoding: .utf8) {
            print("[NetworkClient] 📦 Response body: \(responseBody)")
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            do {
                let decodedObject = try decoder.decode(T.self, from: data)
                print("[NetworkClient] ✅ Successfully decoded response")
                completion(.success(decodedObject))
            } catch {
                print("[NetworkClient] ❌ Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        case 300..<400:
            print("[NetworkClient] ⚠️ Redirection status code: \(httpResponse.statusCode)")
            completion(.failure(.redirection(code: httpResponse.statusCode)))
        case 400..<500:
            print("[NetworkClient] ❌ Client error: \(httpResponse.statusCode)")
            completion(.failure(.clientError(code: httpResponse.statusCode, data: data)))
        case 500..<600:
            print("[NetworkClient] ❌ Server error: \(httpResponse.statusCode)")
            completion(.failure(.serverError(code: httpResponse.statusCode)))
        default:
            print("[NetworkClient] ❓ Unknown status code: \(httpResponse.statusCode)")
            completion(.failure(.unknownStatusCode(code: httpResponse.statusCode)))
        }
    }
}

// MARK: - Supporting Types
extension NetworkClient {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    struct Endpoint {
        let path: String
        let method: HTTPMethod
        let baseURL: URL?
        let headers: [String: String]?
        let queryItems: [URLQueryItem]?
        let body: Data?
        
        init(
            path: String,
            method: HTTPMethod,
            baseURL: URL? = nil,
            headers: [String: String]? = nil,
            queryItems: [URLQueryItem]? = nil,
            body: Data? = nil
        ) {
            self.path = path
            self.method = method
            self.baseURL = baseURL
            self.headers = headers
            self.queryItems = queryItems
            self.body = body
        }
    }
    
    enum NetworkError: Error {
        case invalidRequest
        case connectionError(Error)
        case noDataReceived
        case invalidResponse
        case decodingError(Error)
        case redirection(code: Int)
        case clientError(code: Int, data: Data?)
        case serverError(code: Int)
        case unknownStatusCode(code: Int)
        
        var localizedDescription: String {
            switch self {
            case .clientError(let code, let data):
                return "Client error \(code): \(String(data: data ?? Data(), encoding: .utf8) ?? "")"
            default:
                return "Network error occurred"
            }
        }
    }
}
