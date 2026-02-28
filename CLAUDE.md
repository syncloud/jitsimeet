# Debugging CI failures

When a CI build fails, always start by identifying the failing step:
```
curl -s "http://ci.syncloud.org:8080/api/repos/syncloud/jitsimeet/builds/{N}" | python3 -c "
import json,sys
b=json.load(sys.stdin)
for stage in b.get('stages',[]):
    for step in stage.get('steps',[]):
        if step.get('status') == 'failure':
            print(step.get('name'), '-', step.get('status'))
"
```

Then get the step log (stage=pipeline index, step=step number):
```
curl -s "http://ci.syncloud.org:8080/api/repos/syncloud/jitsimeet/builds/{N}/logs/{stage}/{step}" | python3 -c "
import json,sys; [print(l.get('out',''), end='') for l in json.load(sys.stdin)]
" | tail -80
```

# CI

http://ci.syncloud.org:8080/syncloud/jitsimeet

CI is Drone CI (JS SPA). Check builds via API:
```
curl -s "http://ci.syncloud.org:8080/api/repos/syncloud/jitsimeet/builds?limit=5"
```

## CI Artifacts

Artifacts are served at `http://ci.syncloud.org:8081` (returns JSON directory listings).

Browse the top level for a build (returns distro subdirs + snap file):
```
curl -s "http://ci.syncloud.org:8081/files/jitsimeet/{build}-{arch}/"
```

Each distro dir contains `app/`, `platform/`, and for upgrade/UI tests also `desktop/`, `refresh.journalctl.log`, `video.mkv`:
```
curl -s "http://ci.syncloud.org:8081/files/jitsimeet/{build}-{arch}/{distro}/"
curl -s "http://ci.syncloud.org:8081/files/jitsimeet/{build}-{arch}/{distro}/app/"
curl -s "http://ci.syncloud.org:8081/files/jitsimeet/{build}-{arch}/{distro}/desktop/"
```

Directory structure:
```
{build}-{arch}/
  {distro}/
    app/
      journalctl.log          # full journal from integration test teardown
      ps.log, netstat.log     # process/network state at teardown
    platform/                 # platform logs
    desktop/                  # UI test artifacts (amd64 only)
      journalctl.log
      screenshot/
        {test-name}.png
        {test-name}.html.log
      log/
    refresh.journalctl.log    # full journal from upgrade test (pre/post-refresh)
    video.mkv                 # selenium recording
```

Download a file directly:
```
curl -O "http://ci.syncloud.org:8081/files/jitsimeet/82-amd64/bookworm/app/journalctl.log"
curl -O "http://ci.syncloud.org:8081/files/jitsimeet/82-amd64/bookworm/desktop/journalctl.log"
curl -O "http://ci.syncloud.org:8081/files/jitsimeet/82-amd64/bookworm/refresh.journalctl.log"
```

# Project Structure

- **Snap app** packaging Jitsi Meet (open-source video conferencing) for Syncloud
- Components: Prosody (XMPP), Jicofo (conference focus), JVB (video bridge), Nginx, Web frontend
- Architectures: amd64, arm64
- Distros: bookworm (default), buster (test only)
- CI pipelines defined in `.drone.jsonnet`

## Key directories

- `cli/` — Go snap hooks and CLI (`install`, `configure`, `pre-refresh`, `post-refresh`, `cli`)
  - Uses `github.com/syncloud/golib` and `cobra` for commands
  - Built with `CGO_ENABLED=0` for static binaries
- `bin/` — Service launcher scripts (`service.nginx.sh`, `service.prosody.sh`, `service.jicofo.sh`, `service.jvb.sh`, `service.saslauthd.sh`)
- `config/` — Configuration templates (prosody.cfg.lua, nginx.conf, jicofo.conf, jvb.conf, etc.)
- `jvb/` — JVB build/test scripts (Java 17)
- `jicofo/` — Jicofo build/test scripts (Java 17)
- `prosody/` — Prosody build/test scripts (with Cyrus SASL)
- `nginx/` — Nginx build/test scripts
- `web/` — Web frontend build scripts
- `test/` — Python integration tests (pytest), UI tests (selenium), upgrade tests
- `snap.yaml` — Snap metadata (services: nginx, prosody, saslauthd, jicofo, jvb, cli, hooks)
- `package.sh` — Creates snap package

## Build pipeline steps (per arch)

1. `version` — writes build number
2. `jvb` / `jvb test` — build and test JVB
3. `nginx` / `nginx test` — build and test nginx
4. `web` — build web frontend
5. `prosody` / `prosody test` — build and test Prosody
6. `jicofo` / `jicofo test` — build and test Jicofo
7. `cli` — compile Go snap hooks
8. `package` — create `.snap` file
9. `test bookworm` / `test buster` — integration tests against platform service containers
10. (amd64 only) `selenium` + `test-ui` + `test-upgrade` — UI and upgrade tests

# Running Drone builds locally

Generate `.drone.yml` from jsonnet (run from project root):
```
drone jsonnet --stdout --stream > .drone.yml
```

Run a specific pipeline with selected steps:
```
drone exec --pipeline amd64 --trusted \
  --include version \
  --include jvb \
  --include "jvb test" \
  --include nginx \
  --include "nginx test" \
  --include web \
  --include prosody \
  --include "prosody test" \
  --include jicofo \
  --include "jicofo test" \
  --include cli \
  --include package \
  --include "test bookworm" \
  .drone.yml
```
