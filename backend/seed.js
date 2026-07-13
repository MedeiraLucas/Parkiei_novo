require('dotenv').config();
const sequelize = require('./src/config/database');
const Parking = require('./src/models/Parking');

async function seed() {
  await sequelize.sync();

  const [parking, created] = await Parking.findOrCreate({
    where: { id: 1 },
    defaults: {
      name: 'Estacionamento Principal',
      location: 'Joinville, SC',
      vacancies: 1,
      occupiedSpots: 0,
    },
  });

  if (!created) {
    await parking.update({ vacancies: 1, occupiedSpots: 0 });
    console.log('Estacionamento atualizado:', parking.name);
  } else {
    console.log('Estacionamento criado:', parking.name);
  }

  console.log('→ ID:', parking.id);
  console.log('→ Vagas totais:', parking.vacancies);
  console.log('→ Vagas ocupadas:', parking.occupiedSpots);

  await sequelize.close();
}

seed().catch((err) => {
  console.error('Erro ao executar seed:', err.message);
  process.exit(1);
});
