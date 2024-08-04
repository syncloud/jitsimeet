from selenium.webdriver.common.by import By


def login(selenium, ui_mode):
    selenium.click_by(By.XPATH, "//button[text()='Sign in']")

    selenium.find_by(By.XPATH, "//input[@type='email']").send_keys('{0}@example.com'.format(ui_mode))
    selenium.find_by(By.XPATH, "//input[@type='password']").send_keys('pass1234')
    selenium.click_by(By.XPATH, "//button[text()='Sign in']")
    selenium.invisible_by(By.XPATH, "//button[text()='Sign in']")
    selenium.screenshot('test-1')
    selenium.click_by(By.XPATH, "(//footer//button)[1]")
    selenium.find_by(By.XPATH, "//div[contains(text(), 'signed in as')]")
    selenium.screenshot('test-2')
    #selenium.find_by(By.XPATH, "//div[contains(text(), 'signed in as')]")


def test_meeting(selenium):
    selenium.find_by(By.ID, "enter_room_field").send_keys('test-meeting')
    selenium.click_by(By.XPATH, "//button[.='Start meeting']")
    selenium.screenshot('join')
    selenium.find_by(By.ID, "premeeting-name-input").send_keys('test-user')
    selenium.click_by(By.XPATH, "//div[contains(.,'Join meeting')]")
    selenium.find_by(By.XPATH, "//div[contains(@class, 'audio-preview')]")
    selenium.screenshot('meeting')
