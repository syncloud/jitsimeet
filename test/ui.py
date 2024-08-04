from os.path import dirname, join
from subprocess import check_output

import pytest
from selenium.webdriver.common.by import By
from syncloudlib.integration.hosts import add_host_alias

from test import lib

DIR = dirname(__file__)


TMP_DIR = '/tmp/syncloud/ui'


@pytest.fixture(scope="session")
def module_setup(request, device, artifact_dir, ui_mode, data_dir, app, domain, device_host, local):
    if not local:
        add_host_alias(app, device_host, domain)
        device.activated()
        device.run_ssh('mkdir -p {0}'.format(TMP_DIR), throw=False)     

        def module_teardown():
            device.run_ssh('journalctl > {0}/journalctl.log'.format(TMP_DIR), throw=False)
            device.run_ssh('cp -r {0}/log/*.log {1}'.format(data_dir, TMP_DIR), throw=False)
            device.scp_from_device('{0}/*'.format(TMP_DIR), join(artifact_dir, ui_mode))
            check_output('cp /videos/* {0}'.format(artifact_dir), shell=True)
            check_output('chmod -R a+r {0}'.format(artifact_dir), shell=True)
        request.addfinalizer(module_teardown)


def test_start(module_setup):
    pass


def test_index(selenium):
    selenium.open_app()
    selenium.find_by(By.XPATH, "//button[.='Start meeting']")
    selenium.screenshot('index')


def test_meeting(selenium):
    lib.test_meeting(selenium)
