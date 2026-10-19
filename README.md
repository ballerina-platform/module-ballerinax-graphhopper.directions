# Ballerina GraphHopper Directions connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-graphhopper.directions/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-graphhopper.directions/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-graphhopper.directions.svg)](https://github.com/ballerina-platform/module-ballerinax-graphhopper.directions/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/graphhopper.directions.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fgraphhopper.directions)

## Overview

[GraphHopper Directions API](https://docs.graphhopper.com/) provides route planning, turn-by-turn navigation, route optimization, isochrone calculation, geocoding, matrix calculation, map matching, location clustering and custom routing profiles for building location-aware applications.

The GraphHopper Directions connector lets Ballerina integrations call these services through a typed client. It supports version 1.0.0 of the GraphHopper Directions API and authenticates with an API key.

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

The `GraphHopper Directions` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](examples/), covering the following use cases:

1. [Route travel planner](examples/route_travel_planner/route_travel_planner.md) - Geocode two addresses, calculate the car route between them and compute the area reachable from the origin.
2. [Delivery route optimization](examples/delivery_route_optimization/delivery_route_optimization.md) - Submit a delivery optimization job for a van and poll until the optimized route is ready.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`graphhopper.directions` package](https://central.ballerina.io/ballerinax/graphhopper.directions/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
