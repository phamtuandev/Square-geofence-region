//
//  RegionProtocolDelegate.swift
//  Square geofence region
//
//  Created by Yves Songolo on 2/8/19.
//  Copyright © 2019 Yves Songolo. All rights reserved.
//
import Foundation

public protocol RegionProtocol: class {


    func updateRegion(location: CLLocation)

    func didEnterRegion(region: CKSquareRegion)
    func didExitRegion(region: CKSquareRegion)
    func addRegionToMonitor(region: CKSquareRegion)
    func removeRegionFromMonitor(identifier: String)
}

public extension RegionProtocol{

    //    TODO: get the location and check weither the user was already in or out, If the user was marked in the region, when exited mark the user out of the region, also, keep track of user when they still inside or outside


    /// Method to check wether the user user walk in or out of the square region
    func updateRegion(location: CLLocation){

        // check if the current location is within the square region

        if let regions = retrieveRegions(){

            regions.forEach { (region) in

                let RegionLocation = CLLocation.init(latitude: region.latitude, longitude: region.longitude)
                let distance = location.distance(from: RegionLocation)
                print("\(distance.rounded())m to \(region.identifierR)")

                let sqRegion = CKSquareRegion.init(ckregion: region)

                // enter in the region
                if sqRegion.contains(location.coordinate){


                    let defaults = UserDefaults.standard

                    // retrieve the last state
                    if let inSide = defaults.value(forKey: sqRegion.identifier) as? Bool {

                        if !inSide{
                            didEnterRegion(region: region)
                            defaults.set(true, forKey: sqRegion.identifier)
                        }
                    }

                    else{
                        //didEnterRegion(region: region)
                        defaults.set(true, forKey: sqRegion.identifier)
                    }

                }
                else{

                    let defaults = UserDefaults.standard
                    if let inSide = defaults.value(forKey: sqRegion.identifier) as? Bool {
                        if inSide{
                            didExitRegion(region: region)
                            defaults.set(false, forKey: sqRegion.identifier)
                        }
                    }
                    else{
                        //didExitRegion(region: region)
                        defaults.set(false, forKey: sqRegion.identifier)
                    }
                }
            }
        }
         print("\n ------------------------------")
    }

    private func retrieveRegions() -> [SquaredRegion]?{
        if let data = UserDefaults.standard.value(forKey: "regionData") as? Data{
            do{
                let regions = try JSONDecoder().decode([SquaredRegion].self, from: data)
                return regions
            }
            catch{
                return nil
            }
        }
        return nil
    }
    /// Method to add new region to monitor
    func addRegionToMonitor(region: CKSquareRegion) {
        // TODO: - retrieve all the region from user default
        //       - if not exist create a new list
        // TODO: add new the region to the list of identifiers
         let newRegion = SquaredRegion.init(region: region)
        if var regions = retrieveRegions(){

            regions.append(newRegion)

            let data =  try! JSONEncoder().encode(regions)
            UserDefaults.standard.set( data, forKey: "regionData")
        }
        else {
            let newRegion = SquaredRegion.init(region: region)
            let data = try! JSONEncoder().encode([newRegion])
            UserDefaults.standard.set( data, forKey: "regionData")
        }
    }

    /// Method to remove region from monitoring
    func removeRegionFromMonitor(identifier: String){

        // TODO: - Retrieve all region from userDefault
        //       - remove the region that correspond to the identifier

        if var regions = UserDefaults.standard.value(forKey: "regions") as? [CKSquareRegion]{

            if let index = regions.firstIndex(where: {$0.identifier == identifier}){
                regions.remove(at: index)
                UserDefaults.standard.set(regions, forKey: "Regions")
            }

        }
    }
}

public class SquaredRegion: CKSquareRegion, Codable{

    public var longitude: Double
    public var latitude: Double
    public var identifierR: String
    public let sideLenghR: CLLocationDistance

    override init!(regionWithCenter center: CLLocationCoordinate2D, sideLength: CLLocationDistance, identifier: String!) {
         identifierR = identifier
        sideLenghR = 0.0
        longitude = center.longitude
        latitude = center.latitude
        super.init(regionWithCenter: center, sideLength: sideLength, identifier: identifier)

    }
    public init(region: CKSquareRegion) {

        //centerR = region.center
        sideLenghR = region.sideLengh
        identifierR = region.identifier
        longitude = region.center.longitude
        latitude = region.center.latitude

        super.init(regionWithCenter: region.center, sideLength: region.sideLengh, identifier: region.identifier)

    }
}

extension CKSquareRegion{
    public convenience init(ckregion: SquaredRegion) {
       let center = CLLocationCoordinate2D.init(latitude: ckregion.latitude, longitude: ckregion.longitude)
        self.init(regionWithCenter: center, sideLength: ckregion.sideLenghR, identifier: ckregion.identifierR)
    }
}
