const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const parkingRoutes = require('./routes/parkingRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/auth', authRoutes);
app.use('/parkings', parkingRoutes);

module.exports = app;
