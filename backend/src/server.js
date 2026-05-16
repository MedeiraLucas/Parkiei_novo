const app = require('./app');
const sequelize = require('./config/database');
require('dotenv').config();

sequelize.sync()
  .then(() => {
    app.listen(process.env.PORT, () => {
      console.log(`Servidor rodando na porta ${process.env.PORT}`);
    });
  })
  .catch((error) => {
    console.log(error);
  });
