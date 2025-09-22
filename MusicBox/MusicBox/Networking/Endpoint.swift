import Foundation

enum Endpoint {

    case release(id: Int)
    case masterVersions(masterId: Int)
    case searchReleases(query: String, page: Int?, perPage: Int?)

    var host: String {
        return "api.discogs.com"
    }

    var path: String {
        switch self {
        case .release(let id):
            return "/releases/\(id)"
        case .masterVersions(let masterId):
            return "/masters/\(masterId)/versions"
        case .searchReleases:
            return "/database/search"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .release:
            return nil
        case .masterVersions:
            return nil
        case .searchReleases(let query, let page, let perPage):
            var items = [URLQueryItem(name: "q", value: query)]
            if let page = page {
                items.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            if let perPage = perPage {
                items.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
            }
            return items
        }
    }
}

extension Endpoint {
    var url: URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }
}
