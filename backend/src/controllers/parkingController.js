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

  async index(_req, res) {
    try {
      const parkings = await Parking.findAll();
      return res.json(parkings);
    } catch (error) {
      return res.status(500).json(error);
    }
  }

  async show(req, res) {
    try {
      const parking = await Parking.findByPk(req.params.id);
      if (!parking) return res.status(404).json({ error: 'Estacionamento não encontrado' });
      return res.json(parking);
    } catch (error) {
      return res.status(500).json(error);
    }
  }

  async updateOccupancy(req, res) {
    try {
      const parking = await Parking.findByPk(req.params.id);
      if (!parking) return res.status(404).json({ error: 'Estacionamento não encontrado' });

      const { occupiedSpots } = req.body;
      if (typeof occupiedSpots !== 'number' || occupiedSpots < 0) {
        return res.status(400).json({ error: 'occupiedSpots deve ser um número >= 0' });
      }

      await parking.update({ occupiedSpots });
      return res.json({ id: parking.id, occupiedSpots: parking.occupiedSpots });
    } catch (error) {
      return res.status(500).json(error);
    }
  }
}

module.exports = new ParkingController();
