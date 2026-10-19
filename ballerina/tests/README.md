# Running Tests

## Prerequisites

The tests run against a mock GraphHopper server (`tests/mock_service.bal`) that starts automatically on port 9090 when `bal test` runs. No credentials are needed.

To run the tests against the live GraphHopper API, set these environment variables:

```bash
export IS_LIVE_SERVER=true
export GRAPHHOPPER_API_KEY=<Your GraphHopper API Key>
```

## Test groups

- `mock_tests` - all 20 operations, served by the mock server.
- `live_tests` - the read-only and synchronous operations (routing, isochrone, matrix, geocoding, route optimization and clustering), which can run against the live API.

## Running the tests

```bash
# Mock server (default)
bal test --groups mock_tests

# Live API
IS_LIVE_SERVER=true bal test --groups live_tests
```
