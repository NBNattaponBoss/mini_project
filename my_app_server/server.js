const express = require('express');
const cors = require('cors');
const jwt = require('./libs/jwt');
const account = require('./models/account');
const dashboard = require('./models/dashboard');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/api/auth/register', async (req, res) => {
  const { full_name: fullName, username, password } = req.body;
  if (!fullName || !username || !password) return res.status(400).json({ isError: true, errorMessage: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
  if (String(password).length < 6) return res.status(400).json({ isError: true, errorMessage: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร' });
  const result = await account.register(String(fullName).trim(), String(username).trim(), String(password));
  res.status(result.isError ? 400 : 201).json(result);
});

app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).json({ isError: true, errorMessage: 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน' });
  const result = await account.login(String(username).trim(), String(password));
  if (result.isError) return res.status(401).json(result);
  const user = result.data;
  const accessToken = jwt.sign({ user_id: user.account_id, username: user.account_username });
  res.json({ isError: false, data: { access_token: accessToken, username: user.full_name || user.account_username }, errorMessage: '' });
});

async function requireLogin(req, res, next) {
  const authorization = req.headers.authorization || '';
  const token = authorization.startsWith('Bearer ') ? authorization.substring(7) : null;
  if (!token) return res.status(401).json({ isError: true, errorMessage: 'กรุณาเข้าสู่ระบบ' });
  try { req.user = await jwt.verify(token); next(); }
  catch (_) { res.status(401).json({ isError: true, errorMessage: 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่' }); }
}

app.get('/api/dashboard/summary', requireLogin, async (req, res) => {
  const result = await dashboard.getSummary(req.user.user_id);
  res.status(result.isError ? 500 : 200).json(result);
});

const port = Number(process.env.PORT || 3000);
const server = app.listen(port, '127.0.0.1', () => {
  if (server.listening) {
    console.log(`Server running at http://127.0.0.1:${port}`);
    console.log('Keep this terminal open while using the Flutter app.');
  }
});

server.on('error', (error) => {
  console.error('Unable to start server:', error.message);
  process.exit(1);
});

server.on('close', () => console.log('Server has stopped.'));
