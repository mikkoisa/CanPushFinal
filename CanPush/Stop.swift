
import Foundation
import MapKit

class Stop: NSObject, MKAnnotation {
    var identifier = "stop"
    var title: String?
    var coordinate: CLLocationCoordinate2D
    private let routes: [Route]
    var mode: String?
    var subtitle: String?
    var id: String
    var departures: String?
    
    init(coordinate: CLLocationCoordinate2D, name: String, routes: [Route], mode: String, id: String) {
        self.coordinate = coordinate
        self.title = name
        self.routes = routes
        self.mode = mode
        self.id = id
    }
    
    public func getRoutes() -> [Route]{
        return routes
    }
    
    public func routeShortNames() -> String {
        var names: String = ""
        for var i in (0..<routes.count) {
            names += "\(routes[i].shortName)"
            
            if (i<routes.count-1) {
                names += ", "
            }
        }
        //print(names)
        return names
    }
    struct Route {
        var mode: String
        var shortName: String
    }
}

