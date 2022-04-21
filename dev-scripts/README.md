How to do releases
==================

- Commit, tag (tag name = version number, e.g. `0.2.0`) and push a commit that changes the version number in `generate-module`.
- `zef install --deps-only .` in `dev-scripts/`
- Run `generate-module`.
- `zef install --deps-only .` in `gen/`
- Run `fez upload` in `gen/`.

