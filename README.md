# 📚 eLearning Platform - Database Documentation

## 🎯 Project Overview
A comprehensive SQL Server database for an eLearning platform managing students, courses, instructors, payments, and analytics.

## 🗄️ Database Schema - eLearning Platform

### 📊 Core Entities

#### **👥 User Management**
- **`Apprenant`** (Students) - Learner profiles and registration
- **`Formateur`** (Instructors) - Teacher information and specialties
- **`Inscription`** (Enrollments) - Course registrations with status tracking

#### **📚 Learning Content**
- **`Formation`** (Courses) - Course catalog with levels and pricing
- **`Sequence`** (Lessons) - Course modules with duration tracking
- **`Animer`** (Teaching assignments) - Instructor-lesson relationships

#### **📈 Assessment & Feedback**
- **`Evaluation`** (Exams) - Tests with passing thresholds
- **`Resultat`** (Results) - Student scores and performance data
- **`Avis`** (Reviews) - Student ratings and feedback

#### **💰 Financial Management**
- **`Abonnement`** (Subscriptions) - Monthly/annual subscription plans
- **`Paiement`** (Payments) - Transaction records with validation
- **`Echeance`** (Payment due dates) - Subscription billing schedule

#### **📊 Analytics & Monitoring**
- **`Absence`** (Attendance) - Student presence tracking
- **`Log_Activite`** (Activity logs) - User behavior monitoring
- **Consentement_Donnees** (Data consent) - GDPR compliance

## 🛠️ Technology Stack

<div align="center">

### 🗄️ **Database**
![SQL Server](https://img.shields.io/badge/Microsoft%20SQL%20Server-CC2927?style=for-the-badge&logo=microsoft%20sql%20server&logoColor=white)

### 📊 **Features**
![DDL](https://img.shields.io/badge/DDL-Database%20Design-007ACC?style=for-the-badge)
![DML](https://img.shields.io/badge/DML-Data%20Manipulation-34A853?style=for-the-badge)
![Triggers](https://img.shields.io/badge/Triggers-Business%20Logic-FCC624?style=for-the-badge)
![Views](https://img.shields.io/badge/Views-Analytics%20%26%20Reporting-4285F4?style=for-the-badge)

### 🔒 **Security & Compliance**
![GDPR](https://img.shields.io/badge/GDPR-Compliant-4CAF50?style=for-the-badge)
![Data Anonymization](https://img.shields.io/badge/Data-Anonymization-FF6D00?style=for-the-badge)

</div>

## 🎯 Key Features

### 📋 **Core Functionality**
- ✅ Student enrollment and course management
- ✅ Instructor assignment and scheduling
- ✅ Payment processing with validation
- ✅ Assessment and grading system
- ✅ Subscription management with auto-billing

### 📊 **Advanced Analytics**
- 🎯 Student performance tracking
- 📈 Course success rate calculations
- 💰 Revenue and payment analytics
- 👥 Instructor performance rankings
- 📊 Absenteeism correlation analysis

### 🔒 **Data Management**
- 🛡️ GDPR-compliant data handling
- 🔄 Comprehensive audit trails
- 📝 Activity logging and monitoring
- ✅ Data anonymization for AI training

## 🚀 Performance Features

### ⚡ **Optimization**
```sql
-- Indexed columns for performance
CREATE INDEX IX_Inscription_Formation ON elearning.Inscription(id_formation);
CREATE INDEX IX_Paiement_Apprenant ON elearning.Paiement(id_apprenant);
CREATE INDEX IX_Resultat_Note ON elearning.Resultat(note_obtenue);
```

### 🔄 **Automated Workflows**
- Payment validation triggers
- Subscription expiration handling
- Evaluation completion tracking
- Absence alert system

## 📈 Business Intelligence

### 🎯 **Strategic Views**
- **`vue_performance`** - Course success metrics
- **`vue_top_formations`** - Course ranking by composite score
- **`vue_cashflow_mensuel`** - Monthly revenue tracking
- **`vue_ranking_formateurs`** - Instructor performance rankings

### 🤖 **AI-Ready Data**
- Anonymized datasets for machine learning
- Correlation analysis between satisfaction and performance
- Cohort analysis for student progression
- Predictive features for student success

## 🔧 Installation & Setup

### Prerequisites
- Microsoft SQL Server
- Appropriate database permissions
- SQL Server Management Studio (recommended)

### Quick Start
```sql
-- Create database
USE master;
GO
CREATE DATABASE eLearning;
GO

-- Execute the provided SQL script
-- This will create all tables, views, and stored procedures
```

## 📖 Usage Examples

### 🔍 Student Enrollment Query
```sql
SELECT 
    f.titre AS course_title,
    a.nom AS student_name,
    i.date_inscription AS enrollment_date
FROM elearning.Formation f
JOIN elearning.Inscription i ON i.id_formation = f.id_formation
JOIN elearning.Apprenant a ON a.id_apprenant = i.id_apprenant;
```

### 💰 Revenue Analysis
```sql
SELECT 
    YEAR(date_paiement) AS year,
    MONTH(date_paiement) AS month,
    SUM(montant) AS total_revenue
FROM elearning.Paiement
GROUP BY YEAR(date_paiement), MONTH(date_paiement)
ORDER BY year, month;
```

## 🛡️ Security & Compliance

### 🔐 Data Protection
- Unique constraints prevent data duplication
- Foreign key constraints maintain referential integrity
- Check constraints validate business rules
- GDPR consent tracking for data processing

### 📊 Audit Capabilities
- Comprehensive history tables
- Activity logging for user actions
- Change tracking for critical data
- Consent management system

## 🤝 Contributing

We welcome contributions to enhance the eLearning platform database! Please ensure:

1. ✅ All changes maintain data integrity
2. 🔒 Security and privacy considerations are addressed
3. 📊 Analytics views are updated accordingly
4. 🧪 Proper testing is conducted

## 📄 License

This database schema is provided for educational and commercial use. Please ensure compliance with local data protection regulations when implementing.

---

<div align="center">

### **Built with ❤️ for the future of education**

*Empowering learning through robust data management*

</div>
