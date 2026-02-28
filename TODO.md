# Future Improvements

## Stop compiling Cyrus SASL from source

Currently `prosody/build.sh` downloads and compiles cyrus-sasl-2.1.28 from source to bake in snap-specific paths (`--prefix`, `--with-saslauthd`, `--with-configdir`, `--with-plugindir`).

This is unnecessary — all paths can be overridden at runtime:
- `SASL_PATH` env var — plugin directory
- `SASL_CONF_PATH` / `SASL_CONFDIR` env var — config directory
- `saslauthd_path` option in SASL config file — socket path
- `saslauthd -m` flag — socket path (already used in service script)

**To fix:** Use the system SASL library from the prosody Docker image and set these env vars in the service launcher scripts (`bin/service.prosody.sh`, `bin/service.saslauthd.sh`). Remove the compile block from `prosody/build.sh`.

References:
- https://www.cyrusimap.org/sasl/sasl/options.html
- https://www.cyrusimap.org/sasl/sasl/installation.html
