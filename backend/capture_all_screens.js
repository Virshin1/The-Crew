import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const outputDir = path.resolve(__dirname, '../docs/screenshots');

if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

async function capture() {
  console.log('Fetching quick-login token for Kaelen (dev)...');
  const res = await fetch('http://localhost:3000/api/auth/quick-login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ role: 'dev' })
  });
  const data = await res.json();
  console.log('Logged in as:', data.user.display_name, 'ID:', data.user.id);

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

  // Setup localStorage with credentials
  await page.goto('http://localhost:5173/', { waitUntil: 'networkidle0' });
  await page.evaluate((token, user) => {
    localStorage.setItem('flutter.auth_token', '"' + token + '"');
    localStorage.setItem('flutter.auth_user', JSON.stringify(JSON.stringify(user)));
  }, data.token, data.user);

  const screens = [
    { name: '01_splash.png', path: '/#/splash', wait: 3000 },
    { name: '02_welcome.png', path: '/#/welcome', wait: 3500 },
    { name: '03_login.png', path: '/#/login', wait: 3500 },
    { name: '04_create_account.png', path: '/#/create-account', wait: 3500 },
    { name: '05_servers_chat.png', path: '/#/servers', wait: 4500 },
    { name: '06_voice_channel.png', path: '/#/servers/voice', wait: 4500 },
    { name: '07_member_list.png', path: '/#/servers/members', wait: 4000 },
    { name: '08_dm_inbox.png', path: '/#/messages', wait: 4500 },
    { name: '09_dm_chat.png', path: '/#/messages/chat/u2', wait: 4500 },
    { name: '10_community_discovery.png', path: '/#/discover', wait: 4000 },
    { name: '11_create_community.png', path: '/#/discover/create', wait: 3500 },
    { name: '12_notifications.png', path: '/#/activity', wait: 4000 },
    { name: '13_user_profile.png', path: '/#/profile', wait: 4000 },
    { name: '14_settings.png', path: '/#/profile/settings', wait: 3500 },
    { name: '15_customize_theme.png', path: '/#/profile/theme', wait: 3500 },
  ];

  for (const s of screens) {
    console.log(`Capturing ${s.name} at ${s.path}...`);
    await page.goto(`http://localhost:5173${s.path}`, { waitUntil: 'networkidle0', timeout: 30000 });
    await new Promise(r => setTimeout(r, s.wait));
    const filePath = path.join(outputDir, s.name);
    await page.screenshot({ path: filePath });
    console.log(`✓ Saved ${s.name}`);
  }

  await browser.close();
  console.log('🎉 All 15 mobile screenshots captured successfully in docs/screenshots/!');
}

capture().catch(err => {
  console.error('Error during capture:', err);
  process.exit(1);
});
