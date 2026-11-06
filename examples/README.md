# Examples

The `ballerinax/graphhopper.directions` connector provides practical examples illustrating usage in various scenarios.

1. [Route travel planner](./route_travel_planner/route_travel_planner.md) - Geocode two addresses, calculate the car route between them and compute the area reachable from the origin.
2. [Delivery route optimization](./delivery_route_optimization/delivery_route_optimization.md) - Submit a delivery optimization job for a van and poll until the optimized route is ready.

## Prerequisites

Create a `Config.toml` in the example directory with your GraphHopper API key. Each example's guide lists the configuration it needs.

```toml
apiKey = "<Your GraphHopper API Key>"
```

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```

## Building the examples with the local module

**Warning**: Due to the absence of support for reading local repositories for single Ballerina files, the Bala of the module is manually written to the central repository as a workaround. Consequently, the bash script may modify your local Ballerina repositories.

Execute the following commands to build all the examples against the changes you have made to the module locally:

* To build all the examples:

    ```bash
    ./build.sh build
    ```

* To run all the examples:

    ```bash
    ./build.sh run
    ```
