from selenium.webdriver.common.by import By


def meeting(selenium, device_user, device_password):
    selenium.find_by(By.ID, "enter_room_field").send_keys('test-meeting')
    selenium.click_by(By.XPATH, "//button[.='Start meeting']")
    selenium.screenshot('join')
    selenium.find_by(By.ID, "premeeting-name-input").send_keys('test-user')
    selenium.screenshot('premeeting')
    selenium.click_by(By.XPATH, "//div[@aria-label='Join meeting']")
    selenium.find_by(By.XPATH, "//h1[.='Waiting for a moderator...']")
    selenium.screenshot('waiting')
    selenium.click_by(By.XPATH, "//button[.='Log-in']")
    selenium.screenshot('login')
    selenium.find_by(By.ID, "login-dialog-username").send_keys(device_user)
    selenium.find_by(By.ID, "login-dialog-password").send_keys(device_password)
    selenium.screenshot('credentials')
    selenium.click_by(By.XPATH, "//button[.='Login']")
    selenium.find_by(By.XPATH, "//div[.='Test Meeting']")

    selenium.screenshot('meeting')
