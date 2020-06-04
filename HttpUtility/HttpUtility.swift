//
//  HttpUtility.swift
//  HttpUtility
//
//  Created by CodeCat15 on 5/17/20.
//  Copyright © 2020 CodeCat15. All rights reserved.
//

import Foundation

struct HttpMethodType {
    static let GET = "GET"
    static let POST = "POST"
}

struct HttpHeaderFields
{
    static let contentType = "content-type"
}

struct NetworkError : Error
{
    let reason: String?
    let httpStatusCode: Int?
}

struct HttpUtility
{
    private var _token: String? = nil
    private var _dateFormatter: DateFormatter? = nil
    
    init(token: String?){
        _token = token
    }
    
    init(dateFormatter: DateFormatter){
        _dateFormatter = dateFormatter
    }
    
    init(token: String, dateFormatter: DateFormatter)
    {
        _token = token
        _dateFormatter = dateFormatter
    }
    
    init(){}
    
    func getData<T:Decodable>(requestUrl: URL, resultType: T.Type, completionHandler:@escaping(Result<T?, NetworkError>)-> Void)
    {
        
        var urlRequest = createUrlRequest(requestUrl: requestUrl)
        urlRequest.httpMethod = HttpMethodType.GET
        
        URLSession.shared.dataTask(with: requestUrl) { (responseData, httpUrlResponse, error) in
            
            //todo: this code can be added into a common function
            let statusCode = (httpUrlResponse as? HTTPURLResponse)?.statusCode
            if(error == nil && responseData != nil && responseData?.count != 0)
            {
                let decoder = self.createJsonDecoder()
                do
                {
                    let result = try decoder.decode(T.self, from: responseData!)
                    completionHandler(.success(result))
                }
                catch let error
                {
                    debugPrint(error)
                    completionHandler(.failure(NetworkError(reason: error.localizedDescription, httpStatusCode: statusCode)))
                }
            }
            else
            {
                let error = NetworkError(reason: error.debugDescription,httpStatusCode: statusCode)
                completionHandler(.failure(error))
            }
            
        }.resume()
    }
    
    // MARK: - Post Api
    func postData<T:Decodable>(requestUrl: URL, requestBody: Data, resultType: T.Type, completionHandler:@escaping(Result<T?, NetworkError>)-> Void)
    {
        var urlRequest = createUrlRequest(requestUrl: requestUrl)
        urlRequest.httpMethod = HttpMethodType.POST
        urlRequest.httpBody = requestBody
        urlRequest.addValue("application/json", forHTTPHeaderField: HttpHeaderFields.contentType)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, httpUrlResponse, error) in
            let statusCode = (httpUrlResponse as? HTTPURLResponse)?.statusCode
            if(error == nil && data != nil && data?.count != 0)
            {
                do {
                    
                    let decoder = self.createJsonDecoder()
                    let response = try decoder.decode(T.self, from: data!)
                    completionHandler(.success(response))
                }
                catch let decodingError
                {
                    debugPrint(decodingError)
                    let networkError = NetworkError(reason: decodingError.localizedDescription, httpStatusCode: statusCode)
                    completionHandler(.failure(networkError))
                }
            }
            else
            {
                let error = NetworkError(reason: error.debugDescription, httpStatusCode: statusCode)
                completionHandler(.failure(error))
            }
            
        }.resume()
    }
    
    func postMultipartFormData<T:Decodable>(requestUrl: URL, multiPartRequestBody: Data, resultType: T.Type, completionHandler:@escaping(Result<T?, NetworkError>)-> Void)
    {
        var urlRequest = URLRequest(url: requestUrl)
        
        urlRequest.httpMethod = HttpMethodType.POST
        
        let boundary = "---------------------------------\(UUID().uuidString)"
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")
        urlRequest.addValue("\(multiPartRequestBody.count)", forHTTPHeaderField: "content-length")
        urlRequest.httpBody = multiPartRequestBody
        
        debugPrint("multipart form data => \(String(describing: String(data: multiPartRequestBody, encoding: .utf8)))")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, httpUrlResponse, error) in
            let statusCode = (httpUrlResponse as? HTTPURLResponse)?.statusCode
            if(error == nil && data != nil && data?.count != 0)
            {
                do {
                    let decoder = self.createJsonDecoder()
                    let response = try decoder.decode(T.self, from: data!)
                    completionHandler(.success(response))
                }
                catch let decodingError
                {
                    debugPrint(decodingError)
                    let networkError = NetworkError(reason: decodingError.localizedDescription, httpStatusCode: statusCode)
                    completionHandler(.failure(networkError))
                }
            }
            else
            {
                debugPrint(error.debugDescription)
                let networkError = NetworkError(reason: error.debugDescription, httpStatusCode: statusCode)
                completionHandler(.failure(networkError))
            }
            
        }.resume()
        
    }
    
    // MARK: - Private functions
    private func createJsonDecoder() -> JSONDecoder
    {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = _dateFormatter != nil ? .formatted(_dateFormatter!) : .iso8601
        return decoder
    }
    
    private func createUrlRequest(requestUrl: URL) -> URLRequest
    {
        var urlRequest = URLRequest(url: requestUrl)
        if(_token != nil)
        {
            urlRequest.addValue(_token!, forHTTPHeaderField: "authorization")
        }
        
        return urlRequest
    }
}
