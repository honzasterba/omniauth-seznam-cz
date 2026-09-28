# Changelog
All notable changes to this project will be documented in this file.

## 2.0.0 - 2026-09-28

### Changed
- Require oauth2 `~> 2.0` and omniauth-oauth2 `~> 1.8`.
- Upgrade rubocop to 1.x and fix the offenses that it reports.

### Fixed
- The user info request uses `snaky: false`, so `raw_info` keeps the original keys from Seznam.cz, such as `contact-phone` and `avatar-url`.

## 1.1.0 - 2024-02-17

### Changed
- Allow any oauth2 version below 2 (was `~> 1.1`).
- Allow any omniauth-oauth2 version below 2 (was `~> 1.7.1`).
- Remove the version limits from the development dependencies.

## 1.0.0 - 2022-01-12

### Added
- copied from https://github.com/zquestz/omniauth-google-oauth2

### Deprecated
- Nothing.

### Removed
- Nothing.

### Fixed
- Nothing.
