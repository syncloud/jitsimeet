import { ssh, scpFrom } from './helpers/ssh'
import { required } from './helpers/env'
import * as path from 'node:path'
import * as fs from 'node:fs'
import { execSync } from 'node:child_process'

const TMP_DIR = '/tmp/syncloud/jitsimeet-ui'
const DATA_DIR = '/var/snap/jitsimeet/current'
const artifactRoot = required('PLAYWRIGHT_ARTIFACT_DIR')

export default async function () {
  const out = path.join(artifactRoot, 'playwright')
  fs.mkdirSync(out, { recursive: true })

  ssh(`mkdir -p ${TMP_DIR}`, { throw: false })
  ssh(`journalctl > ${TMP_DIR}/journalctl.log`, { throw: false })
  ssh(`snap services jitsimeet > ${TMP_DIR}/services.log 2>&1`, { throw: false })
  ssh(`cp -r ${DATA_DIR}/log ${TMP_DIR}/app-log`, { throw: false })
  scpFrom(`${TMP_DIR}/*`, out, { throw: false })
  try { execSync(`chmod -R a+r ${out}`) } catch {}
}
