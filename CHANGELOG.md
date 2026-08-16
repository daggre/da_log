# Changelog

## [1.0.0] - 2026-08-15

First stable release. No functional change from `0.1.0` — the version number now
reflects that the API is settled and breaking changes will be announced.

### Provides
- Level-based logging: `log.error`, `log.warn`, `log.info`, `log.verbose`, `log.debug`, `log.spam`
- Colored, resource-tagged output
- Runtime level control from the console: `log set <resource> <level>`
- Auto-detects debug mode from the `debug` convar
