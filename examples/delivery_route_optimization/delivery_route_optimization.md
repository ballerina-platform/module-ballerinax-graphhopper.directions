# Delivery route optimization

This example describes a single delivery van and a list of customer stops, submits them to GraphHopper as an asynchronous route optimization job, and polls the job until the optimized solution is available. It uses the `submitVrpJob` and `getVrpSolution` operations.

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
  depotLat = 52.517037
  depotLon = 13.38886
  customerLocations = [[52.525439, 13.413], [52.520008, 13.404954], [52.5075, 13.3904]]
  maxPollAttempts = 20
  ```

## Run the example

```bash
bal run
```
