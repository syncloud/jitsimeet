import { test, expect } from '@playwright/test'
import { shoot } from '../helpers/screenshot'
import { required } from '../helpers/env'

const deviceUser = required('PLAYWRIGHT_DEVICE_USER')
const devicePassword = required('PLAYWRIGHT_DEVICE_PASSWORD')

test('index shows the welcome page', async ({ page }, testInfo) => {
  await page.goto('/')
  await expect(page.getByRole('button', { name: 'Start meeting' })).toBeVisible()
  await shoot(page, testInfo, 'index')
})

test('authenticated user starts and joins a meeting', async ({ page }, testInfo) => {
  await page.goto('/')
  await page.locator('#enter_room_field').fill('test-meeting')
  await page.getByRole('button', { name: 'Start meeting' }).click()
  await shoot(page, testInfo, 'join')

  await page.locator('#premeeting-name-input').fill('test-user')
  await shoot(page, testInfo, 'premeeting')
  await page.locator('[aria-label="Join meeting"]').click()

  await expect(page.getByText('Waiting for a moderator')).toBeVisible()
  await shoot(page, testInfo, 'waiting')

  await page.getByRole('button', { name: 'Log-in' }).click()
  await shoot(page, testInfo, 'login')

  await page.locator('#login-dialog-username').fill(deviceUser)
  await page.locator('#login-dialog-password').fill(devicePassword)
  await shoot(page, testInfo, 'credentials')
  await page.getByRole('button', { name: 'Login', exact: true }).click()

  await expect(page.getByText('Test Meeting')).toBeVisible()
  await shoot(page, testInfo, 'meeting')
})
