// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? "https://graphhopper.com/api/1" : "http://localhost:9090";
final string apiKey = isLiveServer ? os:getEnv("GRAPHHOPPER_API_KEY") : "test_key";

final Client graphhopper = check new ({'key: apiKey}, {httpVersion: http:HTTP_1_1}, serviceUrl);

const string BERLIN_START = "52.517037,13.388860";
const string BERLIN_END = "52.525439,13.413000";

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetRoute() returns error? {
    RouteResponse response = check graphhopper->getRoute(point = [BERLIN_START, BERLIN_END], profile = "car");
    test:assertTrue(response?.paths is RouteResponsePath[]);
    test:assertTrue((response.paths ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCalculateRoute() returns error? {
    RouteResponse response = check graphhopper->calculateRoute({
        points: [[13.388860, 52.517037], [13.413000, 52.525439]],
        profile: "car",
        pointsEncoded: false
    });
    test:assertTrue((response.paths ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetIsochrone() returns error? {
    IsochroneResponse response = check graphhopper->getIsochrone(point = BERLIN_START, timeLimit = 600);
    test:assertTrue((response.polygons ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetMatrix() returns error? {
    MatrixResponse response = check graphhopper->getMatrix(point = [BERLIN_START, BERLIN_END, "52.520008,13.404954"], outArray = ["times", "distances"]);
    test:assertTrue(response?.distances is decimal[][]);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testCalculateMatrix() returns error? {
    SymmetricalMatrixRequest request = {
        points: [[13.388860, 52.517037], [13.413000, 52.525439], [13.404954, 52.520008]],
        outArrays: ["times", "distances"],
        profile: "car"
    };
    MatrixResponse response = check graphhopper->calculateMatrix(request);
    test:assertTrue(response?.times is decimal[][]);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSubmitMatrixJob() returns error? {
    SymmetricalMatrixRequest request = {
        points: [[13.388860, 52.517037], [13.413000, 52.525439], [13.404954, 52.520008]],
        outArrays: ["times"],
        profile: "car"
    };
    JobId response = check graphhopper->submitMatrixJob(request);
    test:assertTrue(response?.jobId is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetMatrixSolution() returns error? {
    MatrixJobResponse response = check graphhopper->getMatrixSolution("8a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d");
    test:assertEquals(response?.status, "finished");
    test:assertTrue(response?.solution is MatrixResponse);
}

@test:Config {groups: ["mock_tests"]}
isolated function testMatchGpx() returns error? {
    xml gpx = xml `<gpx version="1.1"><trk><trkseg><trkpt lat="52.517037" lon="13.388860"/><trkpt lat="52.525439" lon="13.413000"/></trkseg></trk></gpx>`;
    RouteResponse response = check graphhopper->matchGpx(gpx, profile = "car");
    test:assertTrue((response.paths ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testGetGeocode() returns error? {
    GeocodingResponse response = check graphhopper->getGeocode(q = "Berlin", 'limit = 2);
    test:assertTrue((response.hits ?: []).length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testSolveVrp() returns error? {
    OptimizationRequest request = {
        vehicles: [{vehicleId: "vehicle-1", startAddress: {locationId: "depot", lon: 13.388860, lat: 52.517037}}],
        services: [{id: "order-1", address: {locationId: "customer-1", lon: 13.413000, lat: 52.525439}}]
    };
    OptimizationResponse response = check graphhopper->solveVrp(request);
    test:assertTrue(response?.solution is OptimizationSolution);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSubmitVrpJob() returns error? {
    OptimizationRequest request = {
        vehicles: [{vehicleId: "vehicle-1", startAddress: {locationId: "depot", lon: 13.388860, lat: 52.517037}}],
        services: [{id: "order-1", address: {locationId: "customer-1", lon: 13.413000, lat: 52.525439}}]
    };
    JobId response = check graphhopper->submitVrpJob(request);
    test:assertTrue(response?.jobId is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetVrpSolution() returns error? {
    OptimizationResponse response = check graphhopper->getVrpSolution("44886560-b584-4da5-b245-768151dacd8f");
    test:assertEquals(response?.status, "finished");
    test:assertTrue(response?.solution is OptimizationSolution);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testSolveClustering() returns error? {
    ClusterRequest request = {
        customers: [
            {id: "c1", quantity: 1, address: {lon: 13.388860, lat: 52.517037}},
            {id: "c2", quantity: 1, address: {lon: 13.413000, lat: 52.525439}}
        ],
        clusters: [{name: "cluster-1", minQuantity: 1, maxQuantity: 2}]
    };
    ClusterResponse response = check graphhopper->solveClustering(request);
    test:assertTrue((response.clusters ?: []).length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSubmitClusteringJob() returns error? {
    ClusterRequest request = {
        customers: [{id: "c1", quantity: 1, address: {lon: 13.388860, lat: 52.517037}}],
        clusters: [{name: "cluster-1", minQuantity: 1, maxQuantity: 2}]
    };
    JobId response = check graphhopper->submitClusteringJob(request);
    test:assertTrue(response?.jobId is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetClusteringSolution() returns error? {
    ClusterResponse response = check graphhopper->getClusteringSolution("5f0d7c4a-3b61-4f0e-9a52-1c8e6d2b7a10");
    test:assertEquals(response?.status, "finished");
    test:assertTrue((response.clusters ?: []).length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testListProfiles() returns error? {
    ProfileGetResponse response = check graphhopper->listProfiles();
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateProfile() returns error? {
    ProfileResponse response = check graphhopper->createProfile({profile: "bike"});
    test:assertTrue(response?.id is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testSubmitProfileJob() returns error? {
    JobId response = check graphhopper->submitProfileJob({profile: "bike"});
    test:assertTrue(response?.jobId is string);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetProfileSolution() returns error? {
    ProfileJobResponse response = check graphhopper->getProfileSolution("c0ffee00-1234-4abc-9def-0123456789ab");
    test:assertEquals(response?.status, "finished");
    test:assertTrue(response?.solution is ProfileResponse);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteProfile() returns error? {
    ProfileResponse profile = check graphhopper->createProfile({profile: "bike"});
    string profileId = profile?.id ?: "ecargobike_1";
    DeleteProfileResponse response = check graphhopper->deleteProfile(profileId);
    test:assertEquals(response?.status, "success");
}
