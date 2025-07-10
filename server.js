const express = require('express');
const app = express();
const PORT = 3001;

const HOST = '0.0.0.0';

app.use(express.json());

app.post('/register', (req, res) => {
  console.log("Received body [register]: ", req.body)
  res.json({
    nome: req.body.nome,
    email: req.body.email,
    senha: req.body.senha,
  })
})

app.post('/login', (req, res) => {
  console.log("Received body [login]: ", req.body)
  res.json({
    nome: req.body.nome,
    email: req.body.email,
    senha: req.body.senha
  })
})

app.listen(PORT, HOST, () => {
  console.log(`Servidor rodando em http://${HOST}:${PORT}`);
});
