import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outputDir = path.resolve(__dirname, '../docs/screenshots');

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

async function run() {
  const browser = await puppeteer.launch({
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();
  await page.setViewport({
    width: 390,
    height: 844,
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true
  });

  console.log('--- 1. Capturing Unauthenticated Screens ---');

  // Clear localStorage
  await page.goto('http://localhost:5173/', { waitUntil: 'networkidle0' });
  await page.evaluate(() => localStorage.clear());

  // 01. Splash
  console.log('Capturing 01_splash.png...');
  await page.goto('http://localhost:5173/#/splash', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: path.join(outputDir, '01_splash.png') });

  // 02. Welcome
  console.log('Capturing 02_welcome.png...');
  await page.goto('http://localhost:5173/#/welcome', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  await page.screenshot({ path: path.join(outputDir, '02_welcome.png') });

  // 03. Login
  console.log('Capturing 03_login.png...');
  await page.goto('http://localhost:5173/#/login', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  await page.screenshot({ path: path.join(outputDir, '03_login.png') });

  // 04. Create Account
  console.log('Capturing 04_create_account.png...');
  await page.goto('http://localhost:5173/#/create-account', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  await page.screenshot({ path: path.join(outputDir, '04_create_account.png') });

  console.log('--- 2. Performing One-Click Quick Login as Kaelen ---');
  await page.goto('http://localhost:5173/#/login', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  // Click Kaelen pill (x: 100, y: 580)
  await page.mouse.click(100, 580);
  await new Promise(r => setTimeout(r, 4500));

  // 05. Main Chat / Servers Hub
  console.log('Capturing 05_servers_chat.png...');
  await page.screenshot({ path: path.join(outputDir, '05_servers_chat.png') });

  // 06. Voice Channel
  console.log('Capturing 06_voice_channel.png...');
  await page.goto('http://localhost:5173/#/servers/voice', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 4000));
  await page.screenshot({ path: path.join(outputDir, '06_voice_channel.png') });

  // 07. Member List
  console.log('Capturing 07_member_list.png...');
  await page.goto('http://localhost:5173/#/servers/members', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3500));
  await page.screenshot({ path: path.join(outputDir, '07_member_list.png') });

  // Return to main and tap bottom nav
  await page.goto('http://localhost:5173/#/servers', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));

  // 08. DM Inbox
  console.log('Capturing 08_dm_inbox.png...');
  await page.mouse.click(120, 815);
  await new Promise(r => setTimeout(r, 3500));
  await page.screenshot({ path: path.join(outputDir, '08_dm_inbox.png') });

  // 09. DM Chat (Tap the Nyx conversation around y: 270)
  console.log('Capturing 09_dm_chat.png...');
  await page.mouse.click(200, 270);
  await new Promise(r => setTimeout(r, 3500));
  await page.screenshot({ path: path.join(outputDir, '09_dm_chat.png') });

  // 10. Community Discovery
  console.log('Capturing 10_community_discovery.png...');
  await page.goto('http://localhost:5173/#/discover', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3500));
  await page.screenshot({ path: path.join(outputDir, '10_community_discovery.png') });

  // 11. Create Community
  console.log('Capturing 11_create_community.png...');
  await page.goto('http://localhost:5173/#/discover/create', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3000));
  await page.screenshot({ path: path.join(outputDir, '11_create_community.png') });

  // 12. Activity / Notifications
  console.log('Capturing 12_notifications.png...');
  await page.goto('http://localhost:5173/#/activity', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3500));
  await page.screenshot({ path: path.join(outputDir, '12_notifications.png') });

  // 13. User Profile
  console.log('Capturing 13_user_profile.png...');
  await page.goto('http://localhost:5173/#/profile', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3500));
  await page.screenshot({ path: path.join(outputDir, '13_user_profile.png') });

  // 14. Settings
  console.log('Capturing 14_settings.png...');
  await page.goto('http://localhost:5173/#/profile/settings', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3000));
  await page.screenshot({ path: path.join(outputDir, '14_settings.png') });

  // 15. Customize Theme
  console.log('Capturing 15_customize_theme.png...');
  await page.goto('http://localhost:5173/#/profile/theme', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3000));
  await page.screenshot({ path: path.join(outputDir, '15_customize_theme.png') });

  await browser.close();
  console.log('🚀 ALL 15 PERFECT MOBILE SCREENSHOTS CAPTURED!');
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
