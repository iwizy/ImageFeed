//
//  NetworkClient.swift
//  ImageFeed
//
// Сетевой клиент

import Foundation

final class NetworkClient {
    // MARK: - Private properties
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Init
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    // MARK: - Main Request Method
    func objectTask<T: Decodable>(
        for request: Endpoint,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> URLSessionTask {
        guard let urlRequest = makeURLRequest(from: request) else {
            print("[NetworkClient] ❌ Failed to create URLRequest for request: \(request.path)")
            completion(.failure(.invalidRequest))
            return URLSessionDataTask() // fallback task
        }
        
        print("[NetworkClient] ⬆️ Sending \(request.method.rawValue) request to: \(urlRequest.url?.absoluteString ?? "nil")")
        
        let task = session.dataTask(with: urlRequest) { _, _, _ in }
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let (data, response) = try await session.data(for: urlRequest)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.handleResponse(
                        data: data,
                        response: response,
                        error: nil,
                        completion: completion
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    print("[NetworkClient] ❌ Connection error: \(error.localizedDescription)")
                    completion(.failure(.connectionError(error)))
                }
            }
        }
        
        task.resume()
        return task
    }
    
    // MARK: - Private Methods
    private func makeURLRequest(from request: Endpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = request.baseURL?.host ?? Constants.defaultBaseURL?.host
        components.path = request.path
        components.queryItems = request.queryItems
        
        guard let url = components.url else {
            print("[NetworkClient] ❌ Failed to create URL from components")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        
        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        print("[NetworkClient] Request headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
        return urlRequest
    }
    
    // Обработка HTTP статус-кодов
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
        
        guard let data = data else {
            print("[NetworkClient] ❌ No data received")
            completion(.failure(.noDataReceived))
            return
        }
        
        let statusCode = httpResponse.statusCode
        
        switch statusCode {
        case 200..<300:
            do {
                let decodedObject = try decoder.decode(T.self, from: data)
                print("[NetworkClient] ✅ Successfully decoded response")
                completion(.success(decodedObject))
            } catch {
                let responseBody = String(data: data, encoding: .utf8) ?? "nil"
                print("""
                [NetworkClient] ❌ Decoding error:
                - Error: \(error.localizedDescription)
                - Data: \(responseBody)
                """)
                completion(.failure(.decodingError(error)))
            }
            
        case 300..<400:
            completion(.failure(.redirection(code: statusCode)))
        case 400..<500:
            completion(.failure(.clientError(code: statusCode, data: data)))
        case 500..<600:
            completion(.failure(.serverError(code: statusCode)))
        default:
            completion(.failure(.unknownStatusCode(code: statusCode)))
        }
    }
}

// MARK: - Supporting Types
extension NetworkClient {
    enum HTTPMethod: String {
        case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
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
        case invalidRequest, connectionError(Error), noDataReceived, invalidResponse
        case decodingError(Error), redirection(code: Int), clientError(code: Int, data: Data?)
        case serverError(code: Int), unknownStatusCode(code: Int)
    }
}

// Структура для парсинга ошибок API
struct APIError: Decodable {
    let error: String
    let errorDescription: String
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
    }
}
