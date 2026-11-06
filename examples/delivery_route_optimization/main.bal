import ballerina/io;
import ballerina/lang.runtime;
import ballerinax/graphhopper.directions;

configurable string apiKey = ?;
configurable decimal depotLat = ?;
configurable decimal depotLon = ?;
configurable json customerLocations = ?;
configurable int maxPollAttempts = 20;

public function main() returns error? {
    directions:Client graphhopper = check new ({'key: apiKey});

    // Step 1: Describe the fleet and the delivery stops.
    decimal[][] locations = check customerLocations.fromJsonWithType();
    directions:Address depot = {locationId: "depot", lat: depotLat, lon: depotLon};
    directions:Service[] stops = [];
    foreach int i in 0 ..< locations.length() {
        decimal[] location = locations[i];
        if location.length() != 2 {
            return error(string `customerLocations[${i.toString()}] must be [lat, lon]`);
        }
        stops.push({id: string `order-${(i + 1).toString()}`, address: {locationId: string `customer-${(i + 1).toString()}`, lat: location[0], lon: location[1]}});
    }
    directions:OptimizationRequest request = {
        vehicles: [{vehicleId: "van-1", startAddress: depot, returnToDepot: true}],
        services: stops
    };

    // Step 2: Submit the optimization as an asynchronous job.
    directions:JobId job = check graphhopper->submitVrpJob(request);
    string? jobId = job?.jobId;
    if jobId is () {
        return error("The optimization job was not accepted");
    }
    io:println("Submitted job: ", jobId);

    // Step 3: Poll until the solution is ready.
    foreach int attempt in 0 ..< maxPollAttempts {
        directions:OptimizationResponse result = check graphhopper->getVrpSolution(jobId);
        if result?.status == "finished" {
            directions:OptimizationSolution? solution = result?.solution;
            if solution is () {
                return error("The finished job returned no solution");
            }
            io:println(string `Distance: ${(solution?.distance ?: 0).toString()} m, unassigned stops: ${(solution?.noUnassigned ?: 0).toString()}`);
            return;
        }
        runtime:sleep(3);
    }
    return error("The optimization job did not finish in time");
}
