const { DataTypes } = require('sequelize');
const sequelize = require('../config/db');

const Diagnosis = sequelize.define('Diagnosis', {
    diagnosis_id: { 
        type: DataTypes.BIGINT.UNSIGNED, 
        autoIncrement: true, 
        primaryKey: true 
    },
    name: { 
        type: DataTypes.STRING(255), // ⭐ Changed from ENUM to VARCHAR
        allowNull: false,
        unique: true // ⭐ لمنع التكرار
    },
    name_ar: {
        type: DataTypes.STRING(255), // ⭐ الاسم بالعربي
        allowNull: true
    },
    description: { 
        type: DataTypes.TEXT,
        allowNull: true
    },
    category: {
        type: DataTypes.ENUM(
            'Developmental',  // تأخر نمائي
            'Neurological',   // عصبي
            'Genetic',        // جيني
            'Sensory',        // حسي
            'Learning',       // تعليمي
            'Behavioral',     // سلوكي
            'Physical',       // جسدي
            'Multiple'        // متعدد
        ),
        allowNull: true,
        defaultValue: 'Developmental'
    },
    is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    }
}, { 
    tableName: 'Diagnoses', 
    timestamps: false 
});

module.exports = Diagnosis;
