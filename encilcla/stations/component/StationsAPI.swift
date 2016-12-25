import RxSwift
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

protocol StationsAPI {
  func stations() -> Observable<[Station]>
}

class DefaultStationsAPI: StationsAPI {

  private let URL = "http://www.encicla.gov.co/status/"

  internal func stations() -> Observable<[Station]> {
    return Observable.create {
      observer in
      let request = Alamofire.request(self.URL);
      request.responseObject {
        (response: DataResponse<BikeServerResponse>) in
        observer.on(.next(response.result.value!.value()))
        observer.on(.completed)
      };
      return Disposables.create(with: { request.cancel() })
    }
  }
}

private class BikeServerResponse: Mappable {
  private var stations: [BikeResponseStation]?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    stations <- map["stations"]
  }

  func value() -> [Station] {
    return stations!.flatMap { $0.items!.flatMap { $0 } }
                    .filter { $0.bikes! > 0 }
                    .map { map(item: $0) }
  }

  private func map(item: BikeResponseItem) -> Station {
    return Station(name: item.name!,
                   lat: Double(item.lat!)!,
                   lon: Double(item.lon!)!,
                   bikes: item.bikes!)
  }
}

private class BikeResponseStation: Mappable {
  var items: [BikeResponseItem]?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    items <- map["items"]
  }
}

private class BikeResponseItem: Mappable {
  var lat: String?
  var lon: String?
  var name: String?
  var capacity: Int?
  var bikes: Int?

  required init?(map: Map) {}

  internal func mapping(map: Map) {
    lat <- map["lat"]
    lon <- map["lon"]
    name <- map["name"]
    capacity <- map["capacity"]
    bikes <- map["bikes"]
  }
}
