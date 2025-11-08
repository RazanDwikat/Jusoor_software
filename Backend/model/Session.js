const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');
const User = require('./User');
const Child = require('./Child');
const Institution = require('./Institution');
const SessionType = require('./SessionType');

const Session = sequelize.define('Session', {
  session_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  child_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
  specialist_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
  institution_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: false },
  session_type_id: { type: DataTypes.INTEGER, allowNull: false },
  date: { type: DataTypes.DATEONLY, allowNull: false },
  time: { type: DataTypes.TIME, allowNull: false },
  session_type: { type: DataTypes.ENUM('Online', 'Onsite'), defaultValue: 'Onsite' },
  status: { 
    type: DataTypes.ENUM(
      'Pending Manager Approval',  
      'Pending Specialist Approval', 
      'Approved',                   
      'Pending Payment',    
      'Confirmed',         
      'Scheduled',          
      'Completed',         
      'Cancelled',       
      'Rejected',                   
      'Refunded'           
    ), 
    defaultValue: 'Pending Manager Approval' 
  },
  requested_by_parent: { type: DataTypes.BOOLEAN, defaultValue: false }, 
  parent_notes: { type: DataTypes.TEXT, allowNull: true },
  is_first_booking: { type: DataTypes.BOOLEAN, defaultValue: false }, 
  approved_by_manager_id: { type: DataTypes.BIGINT.UNSIGNED, allowNull: true }, 
  manager_approval_date: { type: DataTypes.DATE, allowNull: true }, 
  manager_notes: { type: DataTypes.TEXT, allowNull: true } 
}, { 
  tableName: 'Sessions', 
  timestamps: false 
});

Session.belongsTo(User, { foreignKey: 'specialist_id', as: 'specialist' });
Session.belongsTo(Child, { foreignKey: 'child_id', as: 'child' });
Session.belongsTo(Institution, { foreignKey: 'institution_id', as: 'institution' });
Session.belongsTo(SessionType, { foreignKey: 'session_type_id' });

module.exports = Session;