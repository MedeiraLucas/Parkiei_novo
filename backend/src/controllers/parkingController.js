const Parking = require('../models/Parking');

class ParkingController {
  async create(req, res) {
    try {
      const parking = await Parking.create(req.body);
      return res.status(201).json(parking);
    } catch (error) {
      return res.status(500).json(error);
    }
  }

  async index(req, res) {
    try {
      const parkings = await Parking.findAll();
      return res.json(parkings);
    } catch (error) {
      return res.status(500).json(error);
    }
  }
}

module.exports = new ParkingController();
