const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

class AuthController {
  async register(req, res) {
    try {
      const { name, email, password } = req.body;

      const userExists = await User.findOne({ where: { email } });

      if (userExists) {
        return res.status(400).json({
          message: 'Usuário já existe'
        });
      }

      const hashPassword = await bcrypt.hash(password, 10);

      const user = await User.create({
        name,
        email,
        password: hashPassword
      });

      return res.status(201).json(user);
    } catch (error) {
      return res.status(500).json(error);
    }
  }

  async login(req, res) {
    try {
      const { email, password } = req.body;

      const user = await User.findOne({ where: { email } });

      if (!user) {
        return res.status(404).json({
          message: 'Usuário não encontrado'
        });
      }

      const passwordMatch = await bcrypt.compare(password, user.password);

      if (!passwordMatch) {
        return res.status(401).json({
          message: 'Senha inválida'
        });
      }

      const token = jwt.sign(
        { id: user.id },
        process.env.JWT_SECRET,
        { expiresIn: '1d' }
      );

      return res.json({
        user,
        token
      });
    } catch (error) {
      return res.status(500).json(error);
    }
  }
}

module.exports = new AuthController();
