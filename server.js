const express = require('express');
const app = express();
const PORT = 3001;

const HOST = '0.0.0.0';

app.use(express.json());

app.post('/register', (req, res) => {
  console.log("Received body: ", req.body)
  res.json({
    userId: 999,
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
  })
})

app.post('/login', (req, res) => {
  console.log("Received body [login]: ", req.body)
  res.json({
    userId: 999,
    name: req.body.name,
    email: req.body.email,
    password: req.body.password
  })
})

app.listen(PORT, HOST, () => {
  console.log(`Servidor rodando em http://${HOST}:${PORT}`);
});