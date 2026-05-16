const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Parking = sequelize.define('Parking', {
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false
  },
  vacancies: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
});

module.exports = Parking;
