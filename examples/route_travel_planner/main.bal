import ballerina/io;
import ballerinax/graphhopper.directions;

configurable string apiKey = ?;
configurable string originQuery = ?;
configurable string destinationQuery = ?;
configurable int reachableMinutes = 15;

public function main() returns error? {
    directions:Client graphhopper = check new ({'key: apiKey});

    // Step 1: Resolve both addresses to coordinates.
    directions:GeocodingResponse originHits = check graphhopper->getGeocode(q = originQuery, 'limit = 1);
    directions:GeocodingResponse destinationHits = check graphhopper->getGeocode(q = destinationQuery, 'limit = 1);
    directions:GeocodingLocation[] origins = originHits.hits ?: [];
    directions:GeocodingLocation[] destinations = destinationHits.hits ?: [];
    if origins.length() == 0 || destinations.length() == 0 {
        return error("Could not geocode the origin or the destination");
    }
    directions:GeocodingPoint? originPoint = origins[0].point;
    directions:GeocodingPoint? destinationPoint = destinations[0].point;
    if originPoint is () || destinationPoint is () {
        return error("Geocoding result has no coordinates");
    }
    string origin = string `${originPoint?.lat.toString()},${originPoint?.lng.toString()}`;
    string destination = string `${destinationPoint?.lat.toString()},${destinationPoint?.lng.toString()}`;

    // Step 2: Calculate the fastest car route between the two points.
    directions:RouteResponse route = check graphhopper->getRoute(point = [origin, destination], profile = "car", pointsEncoded = false);
    directions:RouteResponsePath[] paths = route.paths ?: [];
    if paths.length() == 0 {
        return error("No route found between the two locations");
    }
    decimal distanceMeters = paths[0].distance ?: 0d;
    int travelTimeMillis = paths[0].time ?: 0;
    io:println(string `Route: ${(distanceMeters / 1000).toString()} km, ${(<decimal>travelTimeMillis / 60000).toString()} minutes`);

    // Step 3: Compute the area reachable from the origin within the given travel time.
    if reachableMinutes <= 0 || reachableMinutes > int:SIGNED32_MAX_VALUE / 60 {
        return error(string `reachableMinutes must be between 1 and ${int:SIGNED32_MAX_VALUE / 60}`);
    }
    directions:IsochroneResponse isochrone = check graphhopper->getIsochrone(point = origin, timeLimit = <int:Signed32>(reachableMinutes * 60), profile = "car");
    io:println(string `Reachable areas within ${reachableMinutes.toString()} minutes: ${(isochrone.polygons ?: []).length().toString()}`);
}
