## Overview

[GraphHopper Directions API](https://docs.graphhopper.com/) provides route planning, turn-by-turn navigation, route optimization, isochrone calculation, geocoding, matrix calculation, map matching, location clustering and custom routing profiles for building location-aware applications.

The GraphHopper Directions connector lets Ballerina integrations call these services through a typed client. It supports version 1.0.0 of the GraphHopper Directions API and authenticates with an API key.

### Key features

- Calculate routes between two or more points with turn-by-turn instructions
- Compute travel time and distance matrices, synchronously or as asynchronous jobs
- Solve vehicle routing and clustering problems for delivery and service fleets
- Generate isochrones that show the area reachable within a time or distance limit
- Search addresses and places with forward and reverse geocoding
- Map-match GPX tracks and manage custom routing profiles


## Setup guide

To use the GraphHopper Directions connector, you need an API key.

1. [Sign up for GraphHopper](https://graphhopper.com/dashboard/signup) or log in to your existing account.

2. Open the GraphHopper dashboard and create an API key by following the [API key guide](https://support.graphhopper.com/a/solutions/articles/44001976027).

3. Copy the generated key and keep it safe. The connector sends it as the `key` query parameter in every request.

## Quickstart

To use the `graphhopper.directions` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

```ballerina
import ballerinax/graphhopper.directions;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the obtained API key as follows:

```toml
apiKey = "<Your GraphHopper API Key>"
```

2. Create a `directions:ApiKeysConfig` and initialize the client.

```ballerina
configurable string apiKey = ?;

final directions:Client graphhopper = check new ({'key: apiKey});
```

### Step 3: Invoke the connector operation

Calculate a route between two points:

```ballerina
public function main() returns error? {
    directions:RouteResponse _ = check graphhopper->getRoute(point = ["52.517037,13.388860", "52.525439,13.413000"], profile = "car");
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `GraphHopper Directions` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](../examples/), covering the following use cases:

1. [Route travel planner](../examples/route_travel_planner/route_travel_planner.md) - Geocode two addresses, calculate the car route between them and compute the area reachable from the origin.
2. [Delivery route optimization](../examples/delivery_route_optimization/delivery_route_optimization.md) - Submit a delivery optimization job for a van and poll until the optimized route is ready.
