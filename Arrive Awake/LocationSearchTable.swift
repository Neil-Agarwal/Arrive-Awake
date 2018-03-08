//
//  LocationSearchTable.swift
//  Arrive Awake
//
//  Created by Neil Agarwal on 2018-01-11.
//  Copyright © 2018 Neil Agarwal. All rights reserved.
//

import UIKit
import MapKit
import os.log

class LocationSearchTable : UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate:HandleMapSearch? = nil
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        // put a space between number and street
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/tate
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // province
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
}
extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}
extension LocationSearchTable {
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
}

extension LocationSearchTable {
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        handleMapSearchDelegate?.drawRadius(placemark: selectedItem, radius: -1.0)
        dismiss(animated: true, completion: nil)
    }
}
