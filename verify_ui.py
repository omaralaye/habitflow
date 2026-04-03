import asyncio
from playwright.async_api import async_playwright
import os

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        context = await browser.new_context(
            viewport={'width': 400, 'height': 800}
        )
        page = await context.new_page()

        print("Navigating to app...")
        await page.goto('http://localhost:3000')

        # Wait for Flutter to load
        await asyncio.sleep(10)

        # Take screenshot of onboarding
        os.makedirs('screenshots', exist_ok=True)
        await page.screenshot(path='screenshots/onboarding.png')
        print("Onboarding screenshot saved.")

        # Click "Next" on onboarding (approximate position)
        await page.mouse.click(200, 700)
        await asyncio.sleep(1)
        await page.mouse.click(200, 700)
        await asyncio.sleep(1)
        await page.mouse.click(200, 700)
        await asyncio.sleep(2)

        # Now should be on Login/Signup selection or first screen
        await page.screenshot(path='screenshots/auth_selection.png')

        # Click "Log In" (approximate position if it's the text at bottom)
        # In onboarding_screen.dart:
        # Already have an account? Log In
        await page.mouse.click(200, 750)
        await asyncio.sleep(2)

        await page.screenshot(path='screenshots/login_screen.png')
        print("Login screen screenshot saved.")

        # Go back to onboarding and click "Get Started" to see signup
        await page.goto('http://localhost:3000')
        await asyncio.sleep(5)
        await page.mouse.click(200, 700)
        await asyncio.sleep(1)
        await page.mouse.click(200, 700)
        await asyncio.sleep(1)
        await page.mouse.click(200, 700)
        await asyncio.sleep(2)
        # Click "Get Started" button
        await page.mouse.click(200, 700)
        await asyncio.sleep(2)

        await page.screenshot(path='screenshots/signup_screen.png')
        print("Signup screen screenshot saved.")

        # Perform login to see main screens
        await page.goto('http://localhost:3000')
        await asyncio.sleep(5)
        # Skip onboarding
        for _ in range(3):
            await page.mouse.click(200, 700)
            await asyncio.sleep(0.5)
        # Click "Log In" at bottom
        await page.mouse.click(200, 750)
        await asyncio.sleep(1)
        # Click "Log In" button on login screen (approx position)
        await page.mouse.click(200, 600)
        await asyncio.sleep(2)

        await page.screenshot(path='screenshots/home_screen.png')
        print("Home screen screenshot saved.")

        await browser.close()

if __name__ == '__main__':
    asyncio.run(run())
