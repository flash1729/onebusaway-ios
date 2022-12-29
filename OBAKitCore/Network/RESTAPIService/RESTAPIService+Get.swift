//
//  RESTAPIService+Get.swift
//  OBAKitCore
//
//  Created by Alan Chu on 12/28/22.
//

import MapKit

extension RESTAPIService {
    // MARK: - Vehicle with ID

    /// Provides information on the vehicle with the specified ID.
    ///
    /// API Endpoint: `/api/where/vehicle/{id}.json`
    ///
    /// - important: Vehicle IDs are seldom identical to the IDs that are physically printed
    /// on buses. For example, in Puget Sound, a KC Metro bus that has the number `1234`
    /// printed on its side will likely have the vehicle ID `1_1234` to ensure that the vehicle ID
    /// is unique across the Puget Sound region with all of its agencies.
    ///
    /// - parameter vehicleID: Vehicle ID string
    /// - throws: ``APIError`` or other errors.
    /// - returns: The ``RESTAPIResponse`` for [``VehicleStatus``].
    public nonisolated func getVehicle(vehicleID: String) async throws -> RESTAPIResponse<VehicleStatus> {
        return try await getData(
            for: urlBuilder.getVehicleURL(vehicleID),
            decodeRESTAPIResponseAs: VehicleStatus.self
        )
    }

    // MARK: - Current Time
    /// Retrieves the current system time of the OneBusAway server.
    ///
    /// - API Endpoint: `/api/where/current-time.json`
    /// - [View REST API documentation](http://developer.onebusaway.org/modules/onebusaway-application-modules/current/api/where/methods/current-time.html)
    ///
    /// - throws: ``APIError`` or other errors.
    /// - returns: ``CoreRESTAPIResponse``.
    public nonisolated func getCurrentTime() async throws -> CoreRESTAPIResponse {
        return try await getData(
            for: urlBuilder.getCurrentTime(),
            decodeAs: CoreRESTAPIResponse.self
        )
    }

    // MARK: - Stops
    /// Retrieves stops near the provided `coordinate`.
    ///
    /// - API Endpoint: `/api/where/stops-for-location.json`
    /// - [View REST API documentation](http://developer.onebusaway.org/modules/onebusaway-application-modules/current/api/where/methods/stops-for-location.html)
    ///
    /// - parameter coordinate: The coordinate around which to search for stops.
    /// - throws: ``APIError`` or other errors.
    /// - returns: The ``RESTAPIResponse`` for [``Stop``].
    public nonisolated func getStops(coordinate: CLLocationCoordinate2D) async throws -> RESTAPIResponse<[Stop]> {
        return try await getData(
            for: urlBuilder.getStops(coordinate: coordinate),
            decodeRESTAPIResponseAs: [Stop].self
        )
    }

    /// Retrieves stops within `region`.
    ///
    /// - API Endpoint: `/api/where/stops-for-location.json`
    /// - [View REST API documentation](http://developer.onebusaway.org/modules/onebusaway-application-modules/current/api/where/methods/stops-for-location.html)
    ///
    /// - important: Depending on the number of stops located within `region`, you may only receive back
    /// a subset of the total list of stops within `region`. Zoom in (i.e. provide a smaller region) to
    /// better guarantee that you will receive a full list.
    ///
    /// - parameter region: A coordinate region from which to search for stops.
    /// - throws: ``APIError`` or other errors.
    /// - returns: The ``RESTAPIResponse`` for [``Stop``].
    public nonisolated func getStops(region: MKCoordinateRegion) async throws -> RESTAPIResponse<[Stop]> {
        return try await getData(
            for: urlBuilder.getStops(region: region),
            decodeRESTAPIResponseAs: [Stop].self
        )
    }

    /// Retrieves stops within `circularRegion`.
    ///
    /// - API Endpoint: `/api/where/stops-for-location.json`
    /// - [View REST API documentation](http://developer.onebusaway.org/modules/onebusaway-application-modules/current/api/where/methods/stops-for-location.html)
    ///
    /// - important: Depending on the number of stops located within `circularRegion`, you may only receive back
    /// a subset of the total list of stops within `circularRegion`. Zoom in (i.e. provide a smaller region) to
    /// better guarantee that you will receive a full list.
    ///
    /// - parameter circularRegion: A circular region from which to search for stops.
    /// - parameter query: A search query for a specific stop code.
    /// - throws: ``APIError`` or other errors.
    /// - returns: The ``RESTAPIResponse`` for [``Stop``].
    public nonisolated func getStops(circularRegion: CLCircularRegion, query: String) async throws -> RESTAPIResponse<[Stop]> {
        return try await getData(
            for: urlBuilder.getStops(circularRegion: circularRegion, query: query),
            decodeRESTAPIResponseAs: [Stop].self
        )
    }

    /// Retrieves the stop with the specified ID.
    ///
    /// - API Endpoint: `/api/where/stop/{id}.json`
    /// - [View REST API documentation](http://developer.onebusaway.org/modules/onebusaway-application-modules/current/api/where/methods/stop.html)
    ///
    /// - parameter id: The full, agency-prefixed ID of the stop.
    /// - throws: ``APIError`` or other errors.
    /// - returns: The ``RESTAPIResponse`` for ``Stop``.
    public nonisolated func getStop(id: String) async throws -> RESTAPIResponse<Stop> {
        return try await getData(
            for: urlBuilder.getStop(stopID: id),
            decodeRESTAPIResponseAs: Stop.self
        )
    }
}
