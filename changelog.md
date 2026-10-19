# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Regenerated the connector from the GraphHopper Directions OpenAPI specification covering routing, route matrix, isochrone, geocoding, map matching, route optimization, clustering and custom profiles.

### Changed

- All client methods are now remote methods named after the API operation (for example `calculateRoute`, `submitVrpJob`, `getVrpSolution`).
