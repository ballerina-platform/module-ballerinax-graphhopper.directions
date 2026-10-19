# Route travel planner

This example geocodes an origin and a destination address, calculates the fastest car route between them, and computes the area reachable from the origin within a given travel time. It uses the `getGeocode`, `getRoute` and `getIsochrone` operations.

## Prerequisites

- Ballerina Swan Lake 2201.12.0 or later
- Push the connector to the local repository:
  ```bash
  cd ballerina
  bal pack && bal push --repository=local
  ```
- Create a `Config.toml` in this directory:
  ```toml
  apiKey = "<Your GraphHopper API Key>"
  originQuery = "Brandenburg Gate, Berlin"
  destinationQuery = "Alexanderplatz, Berlin"
  reachableMinutes = 15
  ```

## Run the example

```bash
bal run
```
