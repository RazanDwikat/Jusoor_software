const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    host: process.env.DB_HOST,
    dialect: 'mysql',
    
    // ⭐ Connection Pool Settings - يحافظ على الاتصال نشط
    pool: {
      max: 10,              // الحد الأقصى للاتصالات
      min: 2,               // الحد الأدنى للاتصالات
      acquire: 30000,       // 30 ثانية timeout لمحاولة الاتصال
      idle: 10000,          // 10 ثواني قبل إغلاق اتصال غير نشط
      evict: 5000           // 5 ثواني للتحقق من الاتصالات الميتة
    },
    
    retry: {
      max: 3,               
      timeout: 3000         
    },
    
    logging: false,       
    
    // ⭐ Timezone
    timezone: '+02:00',    
    
    // ⭐ Query timeout
    dialectOptions: {
      connectTimeout: 60000  
    }
  }
);

// ⭐ Test connection و auto-reconnect
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connection has been established successfully.');
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error.message);
    
    console.log('🔄 Retrying in 5 seconds...');
    setTimeout(testConnection, 5000);
  }
};

setInterval(async () => {
  try {
    await sequelize.query('SELECT 1');
  } catch (err) {
    console.error('⚠️  Database keep-alive failed:', err.message);
  }
}, 60000); 

module.exports = sequelize;
