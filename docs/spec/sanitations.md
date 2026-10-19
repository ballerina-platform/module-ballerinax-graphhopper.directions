_Author_:  @DimuthuMadushan \
_Created_: 2026/10/19 \
_Updated_: 2026/10/19 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from GraphHopper Directions.
The OpenAPI specification is obtained from [GraphHopper Directions API 1.0.0](https://github.com/wso2/api-specs/blob/main/openapi/graphhopper/directions/1.0.0/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. Changed the `openapi` version from `3.1.0` to `3.0.1`. `bal openapi flatten` drops the `type` of every schema, property and parameter from a 3.1.0 document, which turns the generated client into `anydata` types and causes duplicate field names. The specification uses no 3.1-only features. This change was made in the original specification `docs/spec/openapi.yaml`.

2. Replaced the single-description `allOf` wrappers on the `points` and `snapped_waypoints` properties of `RouteResponsePath`, and on the `items` of the route `points` array in the route optimization response, with a `description` beside the `anyOf` of `EncodedLineString` and `LineString`. The wrapper produced the invalid record `RoutePoints` (`*PointsAllOf1; *PointsPointsAllOf12;`), which failed to compile because one of its members is not a record. This change was made in the original specification `docs/spec/openapi.yaml`.

3. Renamed operations to intent-revealing names (for example `postRoute` to `calculateRoute`, `asyncVRP` to `submitVrpJob`, `getSolution` to `getVrpSolution`, `postProfile` to `createProfile`, `getProfile` to `listProfiles`) and removed the HTTP verbs from the names, and renamed generic schemas (`InlineResponse200` to `MatrixJobResponse`, `InlineResponse2001` to `ProfileJobResponse`, `InlineResponse2002` to `DeleteProfileResponse`, `InlineResponse404` to `JobNotFoundError`, `Request` to `OptimizationRequest`, `Response` to `OptimizationResponse` and `Solution` to `OptimizationSolution`). These decisions are stored in `docs/spec/ai-mappings.json` and are reapplied on every regeneration.

4. Replaced the long `info.description` (sign-up steps, pricing, rate-limit headers, client libraries, workflows and performance tips) with a one-sentence summary of the API. The description becomes the doc comment of the generated `Client` class, where that material is noise. This change was made in the original specification `docs/spec/openapi.yaml`.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --client-methods remote --license docs/license.txt
```
Note: The license year is hardcoded to 2024, change if necessary.

Note: The generated client copies each typed queries record into a plain map (`{...queries}`) to add the `key` query parameter. The copy drops the `@http:Query` name annotations, so renamed parameters such as `timeLimit` are sent under their Ballerina names instead of their wire names (`time_limit`). After generating the client, replace every `map<anydata> queryParam = {...queries};` in `ballerina/client.bal` with `map<anydata> queryParam = {...http:getQueryMap(queries)};`. `tooling/postfix.py` does this in its `query names` step.
