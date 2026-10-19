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

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Delete a custom routing profile
    #
    # + profileId - The profile to delete
    # + return - A response containing the status 
    resource function delete profiles/[string profileId]() returns DeleteProfileResponse {
        return {status: "success"};
    }

    # Retrieve solution of a clustering job
    #
    # + jobId - Request solution with jobId
    # + return - returns can be any of following types 
    # http:Ok (A response containing the solution)
    # http:BadRequest (Error occurred on client side such as invalid input.)
    # http:NotFound (Requested solution could not be found.)
    # http:InternalServerError (Error occurred on server side.)
    resource function get cluster/solution/[string jobId]() returns ClusterResponse|BadRequestBadRequest|JobNotFoundErrorNotFound|http:InternalServerError {
        if jobId == "unknown" {
            return <JobNotFoundErrorNotFound>{body: {message: "Invalid job_id " + jobId, status: "finished"}};
        }
        return mockClusterResponse();
    }

    # Geocoding Endpoint
    #
    # + q - A textual description of the address you are looking for. Required for forward geocoding. Note that the `default` geocoding provider does prefix searches preferable for "autocomplete" use cases, but
    # may lead to sub-optimal results if used without user interaction. See e.g. `provider=nominatim` as an appropriate alternative for less interactive use cases
    # + locale - Display the search results for the specified `locale`. For the default geocoding provider `en`, `fr`, `es`, `de`, `pt`, `ru` and `it` are supported. Otherwise leave the locale empty
    # + 'limit - Specify the maximum number of results to return
    # + reverse - It is `required` to be `true` if you want to do a reverse geocoding request. If it is `true`, `point` must be defined as well, and `q` must not be used
    # + debug - If `true`, the output will be formatted
    # + point - _Forward geocoding_: The location bias in the format 'latitude,longitude' e.g. point=45.93272,11.58803. _Reverse geocoding_: The location to find amenities, cities
    # + provider - The provider parameter is currently under development and can fall back to `default` at any time.
    # The intend is to provide alternatives to our default geocoder. Each provider has its own strenghts and might fit better for certain scenarios, so it's worth to compare the different providers.
    # To try it append the `provider`parameter to the URL like `&provider=nominatim`,
    # the result structure should be identical in all cases - if not, please report this back to us.
    # Keep in mind that some providers do not support certain parameters or don't return some fields, for example `osm_id` and `osm_type` are not supported by every geocoding provider.
    # If you would like to use additional parameters of one of the providers, but it's not available for the GraphHopper Geocoding API, yet? Please contact us.
    # The credit costs can be different for all providers - see [here](https://support.graphhopper.com/support/solutions/articles/44000718211-what-is-one-credit-) for more information about it.
    # Currently, only the default provider and gisgraphy support autocompletion of partial search strings.
    # All providers support normal "forward" geocoding and reverse geocoding via `reverse=true`.
    # #### Default (`provider=default`)
    # This provider returns results of our internal geocoding engine. It is best suited for use cases with user interaction as it does prefix searches required for an "autocomplete" use case
    # (a user types an address into a search field).
    # In addition to the above documented parameters the following parameters are possible:
    # * `osm_tag` - you can filter `key:value` or exclude places with certain OpenStreetMap tags `!key:value`. E.g. `osm_tag=tourism:museum` or just the key `osm_tag=tourism`. To exclude multiple tags you add multiple `osm_tag` parameters.
    # * `location_bias_scale` - describes how much the prominence of a result should still be taken into account. Sensible values go from 0.0 (ignore prominence almost completely) to 1.0 (prominence has approximately the same influence as the location). The default is 0.2.
    # * `zoom` - describes the radius around the center to focus on. This is a number that should correspond roughly to the map zoom parameter of a corresponding map. The default is zoom=16.
    # * `bbox` - the expected format is `minLon,minLat,maxLon,maxLat`. This requires reverse=false.
    # * `radius` - the search radius in km for the reverse search. This requires reverse=true.
    # #### Nominatim (`provider=nominatim`)
    # The GraphHopper Directions API uses a commercially hosted Nominatim geocoder (hosted by [OpenCageData](https://opencagedata.com/)). It is best suited for use cases without or less user interaction
    # like batch processing or detailed location data retrieval. It is not suited for "autocomplete".
    # In addition to the above documented parameters we currently support the following parameters:
    # * countrycode - The country code is a two letter code as defined by the ISO 3166-1 Alpha 2 standard. E.g. gb for the United Kingdom, fr for France, us for United States.
    # * bounds - the expected format is `minLon,minLat,maxLon,maxLat`
    # #### Gisgraphy (`provider=gisgraphy`)
    # This provider returns results from the Gisgraphy geocoder which you can try [here](https://services.gisgraphy.com/static/leaflet/index.html).
    # **Limitations:** The `locale` parameter is not supported. Gisgraphy does not return OSM tags or an extent.
    # Gisgraphy has a special autocomplete API, which you can use by adding `autocomplete=true` (does not work with `reverse=true`). The autocomplete API is optimized on predicting text input, but returns less information.
    # In addition to the above documented parameters Gisgraphy allows to use the following parameters, which can be used as documented [here](https://www.gisgraphy.com/documentation/user-guide.php#geocodingservice):
    # * `radius` - radius in meters
    # * `country` - restrict search for the specified country. The value must be the ISO 3166 Alpha 2 code of the country.
    # #### OpenCage Data (`provider=opencagedata`)
    # This provider returns results from the OpenCageData geocoder which you can try [here](https://geocoder.opencagedata.com/demo).
    # The difference to the `nominatim` provider is that [other geocoders](https://opencagedata.com/credits) might be used under the hood.
    # In addition to the above documented parameters OpenCage Data allows to use the following parameters, which can be used as documented [here](https://geocoder.opencagedata.com/api#forward-opt):
    # * countrycode - The country code is a two letter code as defined by the ISO 3166-1 Alpha 2 standard. E.g. gb for the United Kingdom, fr for France, us for United States. 
    # * bounds - the expected format is `minLon,minLat,maxLon,maxLat`
    # + return - An array found locations 
    resource function get geocode(string? q, string? point, string locale = "en - for the default provider", int:Signed32 'limit = 5, boolean reverse = false, boolean debug = false, string provider = "default") returns GeocodingResponse {
        return {
            hits: [
                {
                    osmId: 240109189,
                    osmType: "N",
                    country: "Germany",
                    osmKey: "place",
                    city: "Berlin",
                    street: "Unter den Linden",
                    housenumber: "1",
                    name: "Berlin",
                    postcode: "10117",
                    state: "Berlin",
                    point: {lat: 52.5170365, lng: 13.3888599}
                },
                {
                    osmId: 62422,
                    osmType: "R",
                    country: "Germany",
                    osmKey: "boundary",
                    name: "Berlin",
                    state: "Berlin",
                    point: {lat: 52.5198535, lng: 13.4385964}
                }
            ],
            took: 4
        };
    }

    # Compute an isochrone
    #
    # + point - Specify the start coordinate
    # + timeLimit - Specify which time the vehicle should travel. In seconds
    # + distanceLimit - Specify which distance the vehicle should travel. In meters
    # + buckets - Number by which to divide the given `time_limit` to create `buckets` nested isochrones of time intervals `time_limit-n*time_limit/buckets`. Applies analogously to `distance_limit`
    # + reverseFlow - If `false` the flow goes from point to the polygon, if `true` the flow goes from the polygon "inside" to the point.
    # Example use case for `false`&#58; *How many potential customer can be reached within 30min travel time from your store* vs. `true`&#58; *How many customers can reach your store within 30min travel time.*
    # + return - Isochrone Result 
    resource function get isochrone(string point, @http:Query {name: "distance_limit"} int:Signed32? distanceLimit, @http:Query {name: "time_limit"} int:Signed32 timeLimit = 600, VehicleProfileId profile = "car", int:Signed32 buckets = 1, @http:Query {name: "reverse_flow"} boolean reverseFlow = false) returns IsochroneResponse {
        return {
            polygons: [
                {
                    properties: {bucket: 0},
                    geometry: {
                        'type: "Polygon",
                        coordinates: [[[13.3888, 52.5170], [13.4210, 52.5301], [13.4402, 52.5074], [13.3888, 52.5170]]]
                    },
                    'type: "Feature"
                }
            ]
        };
    }

    # Compute a matrix
    #
    # + point - Specify multiple points in `latitude,longitude` for which the weight-, route-, time- or distance-matrix should be calculated. In this case the starts are identical to the destinations. If there are N points, then NxN entries will be calculated. The order of the point parameter is important. Specify at least three points. Cannot be used together with from_point or to_point
    # + fromPoint - The origin points for the routes in `latitude,longitude`. E.g. if you want to calculate the three routes A-&gt;1, A-&gt;2, A-&gt;3 then you have one from_point parameter and three to_point parameters
    # + toPoint - The destination points for the routes in `latitude,longitude`
    # + pointHint - Optional parameter. Specifies a hint for each `point` parameter to prefer a certain street for the closest location lookup. E.g. if there is an address or house with two or more neighboring streets you can control for which street the closest location is looked up
    # + fromPointHint - For the from_point parameter. See point_hint
    # + toPointHint - For the to_point parameter. See point_hint
    # + snapPrevention - Optional parameter. 'Snapping' is the process of finding the closest road location for GPS coordinates provided in the `point` parameter. The `snap_prevention` parameter allows you to prevent snapping to specific types of roads. For example, if `snap_prevention` is set to bridge, the routing engine will avoid snapping to a bridge, even if it is the closest road for the given `point`. Current supported values: `motorway`, `trunk`, `ferry`, `tunnel`, `bridge` and `ford`. Multiple values are specified like `snap_prevention=ferry&snap_prevention=motorway`. Note that once snapped the routing algorithm can still route over bridges (or the other values). To avoid this you need to use the `custom_model`
    # + curbside - Optional parameter. It specifies on which side a point should be relative to the driver when she leaves/arrives at a start/target/via point. You need to specify this parameter for either none or all points. Only supported for motor vehicles and OpenStreetMap
    # + from_curbside - Curbside setting for the from_point parameter. See curbside
    # + to_curbside - Curbside setting for the to_point parameter. See curbside
    # + outArray - Specifies which arrays should be included in the response. Specify one or more of the following options 'weights', 'times', 'distances'. To specify more than one array use e.g. out_array=times&out_array=distances. The units of the entries of distances are meters, of times are seconds and of weights is arbitrary and it can differ for different vehicles or versions of this API
    # + failFast - Specifies whether or not the matrix calculation should return with an error as soon as possible in case some points cannot be found or some points are not connected. If set to `false` the time/weight/distance matrix will be calculated for all valid points and contain the `null` value for all entries that could not be calculated. The `hint` field of the response will also contain additional information about what went wrong (see its documentation)
    # + return - Matrix API response 
    resource function get matrix(string[]? point, @http:Query {name: "from_point"} string[]? fromPoint, @http:Query {name: "to_point"} string[]? toPoint, @http:Query {name: "point_hint"} string[]? pointHint, @http:Query {name: "from_point_hint"} string[]? fromPointHint, @http:Query {name: "to_point_hint"} string[]? toPointHint, @http:Query {name: "snap_prevention"} string[]? snapPrevention, ("any"|"right"|"left")[]? curbside, @http:Query {name: "from_curbside"} ("any"|"right"|"left")[]? fromCurbside, @http:Query {name: "to_curbside"} ("any"|"right"|"left")[]? toCurbside, @http:Query {name: "out_array"} string[]? outArray, VehicleProfileId profile = "car", @http:Query {name: "fail_fast"} boolean failFast = true) returns MatrixResponse {
        return mockMatrixResponse();
    }

    # Retrieve result of a matrix computation job
    #
    # + jobId - The jobId you received when you submitted the job
    # + return - A response containing the matrix 
    resource function get matrix/solution/[string jobId]() returns MatrixJobResponse {
        return {status: "finished", solution: mockMatrixResponse()};
    }

    # List your custom routing profiles
    #
    # + return - Your profiles 
    resource function get profiles() returns ProfileGetResponse {
        return [mockProfile(), {id: "ecargobike_2", profile: "ecargobike"}];
    }

    # Retrieve result of a profile creation job
    #
    # + jobId - The jobId you received when you submitted the job
    # + return - A response containing the custom profile 
    resource function get profiles/solution/[string jobId]() returns ProfileJobResponse {
        return {status: "finished", solution: mockProfile()};
    }

    # Calculate a route
    #
    # + point - The points for which the route should be calculated. Format: `latitude,longitude`. Specify at least an origin and a destination. Via points are possible.
    # The maximum number depends on your plan
    # + pointHint - The `point_hint` is typically a road name to which the associated `point` parameter should be snapped to. Specify no `point_hint` parameter or the same number as you have `point` parameters
    # + snapPrevention - Optional parameter. 'Snapping' is the process of finding the closest road location for GPS coordinates provided in the `point` parameter. The `snap_prevention` parameter allows you to prevent snapping to specific types of roads. For example, if `snap_prevention` is set to bridge, the routing engine will avoid snapping to a bridge, even if it is the closest road for the given `point`. Current supported values: `motorway`, `trunk`, `ferry`, `tunnel`, `bridge` and `ford`. Multiple values are specified like `snap_prevention=ferry&snap_prevention=motorway`. Note that once snapped the routing algorithm can still route over bridges (or the other values). To avoid this you need to use the `custom_model`
    # + curbside - Optional parameter. It specifies on which side a point should be relative to the driver when she leaves/arrives at a start/target/via point. You need to specify this parameter for either none or all points. Only supported for motor vehicles and OpenStreetMap
    # + locale - The locale of the resulting turn instructions. E.g. `pt_PT` for Portuguese or `de` for German
    # + elevation - If `true`, a third coordinate, the altitude, is included with all positions in the response.
    # This changes the format of the `points` and `snapped_waypoints` fields of the response, in both their
    # encodings. Unless you switch off the `points_encoded` parameter, you need special code on the
    # client side that can handle three-dimensional coordinates
    # + details - Optional parameter. The following path details are available: `street_name`, `street_ref`, `street_destination`, `leg_time`, `leg_distance`, `roundabout`, `country`, `time`, `distance`, `max_speed`,
    # `max_weight`, `max_width`, `toll`, `road_class`, `road_class_link`, `road_access`, `road_environment`, `hazmat`, `hazmat_tunnel`, `hazmat_water`, 
    # `lanes`, `surface`, `smoothness`, `hike_rating`, `mtb_rating`, `foot_network`, `bike_network`. Read more about the usage of path details [here](https://discuss.graphhopper.com/t/2539)
    # + optimize - Normally, the calculated route will visit the points in the order you specified them.
    # If you have more than two points, you can set this parameter to `"true"` and the points may be re-ordered to minimize the total travel time.
    # Keep in mind that the limits on the number of locations of the Route Optimization API applies, and the request costs more credits.
    # If you set it to "true" then it cannot be used with `ch.disable: true`. If you still want to use the custom model with route optimization, then you'll need to use the [Profiles API](#tag/Custom-Profiles)
    # + instructions - If instructions should be calculated and returned
    # + calcPoints - If the points for the route should be calculated at all
    # + debug - If `true`, the output will be formatted
    # + pointsEncoded - Allows changing the encoding of location data in the response. The default is polyline encoding, which is compact
    # but requires special client code to unpack. (We provide it in our JavaScript client library!)
    # Set this parameter to `false` to switch the encoding to simple coordinate pairs like `[lon,lat]`, or `[lon,lat,elevation]`.
    # See the description of the response format for more information
    # + chDisable - Use `true` to enable the flexible mode to use the `custom_model` or any of the following options below
    # + heading - Favour a heading direction for a certain point. Specify either one heading for the start point or as many as there are points.
    # In this case headings are associated by their order to the specific points. Headings are given as north based clockwise angle between 0 and 360 degree.
    # This parameter also influences the tour generated with `algorithm=round_trip` and forces the initial direction.  Requires `ch.disable=true`
    # + headingPenalty - Time penalty in seconds for not obeying a specified heading. Requires `ch.disable=true`
    # + passThrough - If `true`, u-turns are avoided at via-points with regard to the `heading_penalty`. Requires `ch.disable=true`
    # + algorithm - Rather than looking for the shortest or fastest path, this parameter lets you solve two different problems related to routing:
    # With `alternative_route`, we give you not one but several routes that are close to optimal, but
    # not too similar to each other. Limitation: works with custom_model but not with custom profiles.
    # With `round_trip`, the route will get you back to where you started. This is meant for fun (think of
    # a bike trip), so we will add some randomness.
    # You can control both of these features with additional parameters, see below. 
    # + roundTripDistance - If `algorithm=round_trip`, this parameter configures approximative length of the resulting round trip
    # + roundTripSeed - If `algorithm=round_trip`, this sets the random seed. Change this to get a different tour for each value
    # + alternativeRouteMaxPaths - If `algorithm=alternative_route`, this parameter sets the number of maximum paths which should be calculated. Increasing can lead to worse alternatives
    # + alternativeRouteMaxWeightFactor - If `algorithm=alternative_route`, this parameter sets the factor by which the alternatives routes can be longer than the optimal route. Increasing can lead to worse alternatives
    # + alternativeRouteMaxShareFactor - If `algorithm=alternative_route`, this parameter specifies how similar an alternative route can be to the optimal route. Increasing can lead to worse alternatives
    # + return - returns can be any of following types 
    # http:Ok (Routing Result)
    # http:BadRequest (Your request is not valid. For example, you specified too few or too many points.)
    # http:Unauthorized (Authentication necessary)
    # http:TooManyRequests (API limit reached.)
    # http:InternalServerError (Internal server error. We get notified automatically and fix this asap.)
    resource function get route(string[] point, @http:Query {name: "point_hint"} string[]? pointHint, @http:Query {name: "snap_prevention"} string[]? snapPrevention, ("any"|"right"|"left")[]? curbside, string[]? details, int:Signed32[]? heading, "round_trip"|"alternative_route"? algorithm, @http:Query {name: "round_trip.seed"} int? roundTripSeed, VehicleProfileId profile = "car", string locale = "en", boolean elevation = false, string optimize = "false", boolean instructions = true, @http:Query {name: "calc_points"} boolean calcPoints = true, boolean debug = false, @http:Query {name: "points_encoded"} boolean pointsEncoded = true, @http:Query {name: "ch.disable"} boolean chDisable = false, @http:Query {name: "heading_penalty"} int:Signed32 headingPenalty = 300, @http:Query {name: "pass_through"} boolean passThrough = false, @http:Query {name: "round_trip.distance"} int:Signed32 roundTripDistance = 10000, @http:Query {name: "alternative_route.max_paths"} int:Signed32 alternativeRouteMaxPaths = 2, @http:Query {name: "alternative_route.max_weight_factor"} decimal alternativeRouteMaxWeightFactor = 1.4, @http:Query {name: "alternative_route.max_share_factor"} decimal alternativeRouteMaxShareFactor = 0.6) returns RouteResponse|GHErrorBadRequest|GHErrorUnauthorized|GHErrorTooManyRequests|GHErrorInternalServerError {
        if point.length() < 2 {
            return <GHErrorBadRequest>{body: {message: "At least 2 points have to be specified, but was:" + point.length().toString()}, headers: {}};
        }
        return mockRouteResponse();
    }

    # Retrieve solution of a route optimization job
    #
    # + jobId - Request solution with jobId
    # + return - returns can be any of following types 
    # http:Ok (A response containing the solution)
    # http:BadRequest (Error occurred on client side such as invalid input.)
    # http:NotFound (Requested solution could not be found.)
    # http:InternalServerError (Error occurred on server side.)
    resource function get vrp/solution/[string jobId]() returns OptimizationResponse|BadRequestBadRequest|JobNotFoundErrorNotFound|http:InternalServerError {
        if jobId == "unknown" {
            return <JobNotFoundErrorNotFound>{body: {message: "Invalid job_id " + jobId, status: "finished"}};
        }
        return mockOptimizationResponse();
    }

    resource function post 'match(@http:Query {name: "gps_accuracy"} int? gpsAccuracy, string[]? details, @http:Payload xml payload, VehicleProfileId profile = "car", string locale = "en", boolean elevation = false, boolean instructions = true, @http:Query {name: "calc_points"} boolean calcPoints = true, @http:Query {name: "points_encoded"} boolean pointsEncoded = true) returns RouteResponseOk {
        return {body: mockRouteResponse(), headers: {}};
    }

    # Solve a clustering problem
    #
    # + payload - Request object that contains the problem to be solved 
    # + return - returns can be any of following types 
    # http:Ok (A response containing the solution)
    # http:BadRequest (Error occurred when reading the request. Request is invalid.)
    # http:InternalServerError (Error occurred on server side.)
    resource function post cluster(@http:Payload ClusterRequest payload) returns ClusterResponseOk|BadRequestBadRequest|InternalErrorMessageInternalServerError {
        return {body: mockClusterResponse(), headers: {}};
    }

    # Submit a clustering job
    #
    # + payload - Request object that contains the problem to be solved 
    # + return - returns can be any of following types 
    # http:Ok (A jobId you can use to retrieve your solution from the server - see solution endpoint)
    # http:BadRequest (Error occurred when reading client request. Request is invalid.)
    # http:InternalServerError (Error occurred on server side.)
    resource function post cluster/calculate(@http:Payload ClusterRequest payload) returns JobIdOk|BadRequestBadRequest|InternalErrorMessageInternalServerError {
        return <JobIdOk>{body: {jobId: "5f0d7c4a-3b61-4f0e-9a52-1c8e6d2b7a10"}, headers: {}};
    }

    # Compute a matrix
    #
    # + payload - Matrix calculation request with points, profile and requested outputs 
    # + return - Matrix API response 
    resource function post matrix(@http:Payload MatrixBody payload) returns MatrixResponseOk {
        return {body: mockMatrixResponse(), headers: {}};
    }

    # Submit a matrix computation job
    #
    # + payload - Matrix calculation job request with points, profile and requested outputs 
    # + return - A jobId you can use to retrieve your solution from the server 
    resource function post matrix/calculate(@http:Payload MatrixCalculateBody payload) returns JobIdOk {
        return {body: {jobId: "8a1b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d"}, headers: {}};
    }

    # Create a custom routing profile
    #
    # + payload - Custom routing profile definition with base profile and custom model 
    # + return - Profile created 
    resource function post profiles(@http:Payload ProfileRequest payload) returns ProfileResponse {
        return mockProfile();
    }

    # Submit a profile creation job
    #
    # + payload - Custom routing profile definition to be processed as a job 
    # + return - A jobId you can use to retrieve the calculated profile 
    resource function post profiles/calculate(@http:Payload ProfileRequest payload) returns JobIdOk {
        return {body: {jobId: "c0ffee00-1234-4abc-9def-0123456789ab"}, headers: {}};
    }

    # Calculate a route
    #
    # + payload - Route calculation request with points, profile and routing options 
    # + return - returns can be any of following types 
    # http:Ok (Routing Result)
    # http:BadRequest (Your request is not valid. For example, you specified too few or too many points.)
    # http:Unauthorized (Authentication necessary)
    # http:TooManyRequests (API limit reached.)
    # http:InternalServerError (Internal server error. We get notified automatically and fix this asap.)
    resource function post route(@http:Payload RouteRequest payload) returns RouteResponseOk|GHErrorBadRequest|GHErrorUnauthorized|GHErrorTooManyRequests|GHErrorInternalServerError {
        return {body: mockRouteResponse(), headers: {}};
    }

    # Solve a route optimization problem
    #
    # + payload - The request that contains the vehicle routing problem to be solved 
    # + return - returns can be any of following types 
    # http:Ok (A response containing the solution)
    # http:BadRequest (Error occurred when reading the request. Request is invalid.)
    # http:InternalServerError (Error occurred on server side.)
    resource function post vrp(@http:Payload OptimizationRequest payload) returns OptimizationResponseOk|BadRequestBadRequest|InternalErrorMessageInternalServerError {
        return {body: mockOptimizationResponse(), headers: {}};
    }

    # Submit a route optimization job
    #
    # + payload - The request that contains the problem to be solved 
    # + return - returns can be any of following types 
    # http:Ok (A jobId you can use to retrieve your solution from the server - see solution endpoint)
    # http:BadRequest (Error occurred when reading client request. Request is invalid.)
    # http:InternalServerError (Error occurred on server side.)
    resource function post vrp/optimize(@http:Payload OptimizationRequest payload) returns JobIdOk|BadRequestBadRequest|InternalErrorMessageInternalServerError {
        return <JobIdOk>{body: {jobId: "44886560-b584-4da5-b245-768151dacd8f"}, headers: {}};
    }
}

function mockRouteResponse() returns RouteResponse => {
    paths: [
        {
            distance: 2087.4,
            time: 276000,
            ascend: 12.5,
            descend: 9.8,
            pointsEncoded: false,
            bbox: [13.3888, 52.5170, 13.4130, 52.5254],
            points: <LineString>{coordinates: [[13.3888, 52.5170], [13.3990, 52.5201], [13.4130, 52.5254]]},
            snappedWaypoints: <LineString>{coordinates: [[13.3888, 52.5170], [13.4130, 52.5254]]},
            instructions: [
                {distance: 1200.2, time: 160000, text: "Continue onto Unter den Linden", streetName: "Unter den Linden"},
                {distance: 887.2, time: 116000, text: "Arrive at destination"}
            ]
        }
    ],
    info: {copyrights: ["GraphHopper", "OpenStreetMap contributors"], took: 12}
};

function mockMatrixResponse() returns MatrixResponse => {
    distances: [[0, 2087.4, 4310.9], [2102.1, 0, 2540.3], [4325.6, 2551.7, 0]],
    times: [[0, 276, 601], [280, 0, 340], [606, 345, 0]],
    info: {copyrights: ["GraphHopper", "OpenStreetMap contributors"], took: 5}
};

function mockProfile() returns ProfileResponse => {
    id: "ecargobike_1",
    profile: "bike",
    customModel: {distanceInfluence: 70}
};

function mockClusterResponse() returns ClusterResponse => {
    status: "finished",
    waitingTimeInQueue: 0,
    processingTime: 118,
    copyrights: ["GraphHopper", "OpenStreetMap contributors"],
    clusters: [
        {quantity: 2, ids: ["c1", "c2"]},
        {quantity: 1, ids: ["c3"]}
    ]
};

function mockOptimizationResponse() returns OptimizationResponse => {
    status: "finished",
    waitingTimeInQueue: 0,
    processingTime: 357,
    copyrights: ["GraphHopper", "OpenStreetMap contributors"],
    solution: {
        distance: 12450,
        transportTime: 1860,
        completionTime: 2460,
        noVehicles: 1,
        noUnassigned: 0,
        routes: [
            {
                vehicleId: "vehicle-1",
                distance: 12450,
                transportTime: 1860,
                completionTime: 2460,
                activities: [
                    {'type: "start", locationId: "depot", address: {locationId: "depot", lon: 13.3888, lat: 52.5170}, endTime: 0},
                    {'type: "service", id: "order-1", locationId: "customer-1", address: {locationId: "customer-1", lon: 13.4130, lat: 52.5254}, arrTime: 900, endTime: 1200},
                    {'type: "end", locationId: "depot", address: {locationId: "depot", lon: 13.3888, lat: 52.5170}, arrTime: 2460}
                ]
            }
        ]
    }
};

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type BadRequestBadRequest record {|
    *http:BadRequest;
    BadRequest body;
|};

public type ClusterResponseOk record {|
    *http:Ok;
    ClusterResponse body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type GHErrorBadRequest record {|
    *http:BadRequest;
    GHError body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type GHErrorInternalServerError record {|
    *http:InternalServerError;
    GHError body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type GHErrorTooManyRequests record {|
    *http:TooManyRequests;
    GHError body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type GHErrorUnauthorized record {|
    *http:Unauthorized;
    GHError body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type InternalErrorMessageInternalServerError record {|
    *http:InternalServerError;
    InternalErrorMessage body;
|};

public type JobIdOk record {|
    *http:Ok;
    JobId body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type JobNotFoundErrorNotFound record {|
    *http:NotFound;
    JobNotFoundError body;
|};

public type MatrixResponseOk record {|
    *http:Ok;
    MatrixResponse body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type OptimizationResponseOk record {|
    *http:Ok;
    OptimizationResponse body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type RouteResponseOk record {|
    *http:Ok;
    RouteResponse body;
    record {|int X\-RateLimit\-Credits?; int X\-RateLimit\-Remaining?; int X\-RateLimit\-Reset?; int X\-RateLimit\-Limit?;|} headers;
|};

public type BadRequest record {
    # Optional error information
    ErrorMessage[] hints?;
    # Short error message
    string message?;
    # status
    string status = "finished";
};

public type GHError record {
    # Optional error information
    GHErrorHints[] hints?;
    string message?;
};

public type InternalErrorMessage record {
    int:Signed32 code = 500;
    # Details
    string message?;
};

public type JobNotFoundError record {
    # Error message
    string message?;
    # status
    string status = "finished";
};

public type ErrorMessage record {
    # Details
    string details?;
    # error message
    string message?;
};

public type GHErrorHints record {
    string message?;
};
