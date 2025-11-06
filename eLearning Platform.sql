 -- DDL SQL Server – eLearning Platform (MLD)

USE  eLearning; 
GO

SET NOCOUNT ON;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'elearning')
BEGIN
    EXEC('CREATE SCHEMA elearning');
END
GO
 
-- Table: Apprenant

CREATE TABLE elearning.Apprenant (
    id_apprenant INT IDENTITY(1,1) PRIMARY KEY,
    nom NVARCHAR(150) NOT NULL,
    email NVARCHAR(255) NOT NULL UNIQUE,
    date_inscription DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE))
);
GO
 
-- Table: Formateur
 
CREATE TABLE elearning.Formateur (
    id_formateur INT IDENTITY(1,1) PRIMARY KEY,
    nom NVARCHAR(150) NOT NULL,
    specialite NVARCHAR(150) NULL
);
GO
 
-- Table: Formation
 
CREATE TABLE elearning.Formation (
    id_formation INT IDENTITY(1,1) PRIMARY KEY,
    titre NVARCHAR(255) NOT NULL,
    niveau NVARCHAR(50) NULL,
    duree_heures INT NULL,
    montant DECIMAL(10,2) NULL
);
GO
 
-- Table: Sequence
 
CREATE TABLE elearning.Sequence (
    id_seq INT IDENTITY(1,1) PRIMARY KEY,
    id_formation INT NOT NULL,
    titre NVARCHAR(255) NOT NULL,
    duree_minutes INT NULL,
    date_derniere_modif DATE NULL,
    CONSTRAINT FK_Sequence_Formation 
        FOREIGN KEY (id_formation) REFERENCES elearning.Formation(id_formation) ON DELETE CASCADE
);
GO
 
-- Table: Animer (relation)
 
CREATE TABLE elearning.Animer (
    id_formateur INT NOT NULL,
    id_seq INT NOT NULL,
    PRIMARY KEY (id_formateur, id_seq),
    CONSTRAINT FK_Animer_Formateur FOREIGN KEY (id_formateur) REFERENCES elearning.Formateur(id_formateur),
    CONSTRAINT FK_Animer_Sequence FOREIGN KEY (id_seq) REFERENCES elearning.Sequence(id_seq)
);
GO
 
-- Table: Inscription
 
CREATE TABLE elearning.Inscription (
    id_inscription INT IDENTITY(1,1) PRIMARY KEY,
    id_apprenant INT NOT NULL,
    id_formation INT NOT NULL,
    date_inscription DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    statut NVARCHAR(30) NOT NULL DEFAULT ('active'),
    CONSTRAINT UQ_Inscription UNIQUE (id_apprenant, id_formation),
    CONSTRAINT FK_Inscription_Apprenant FOREIGN KEY (id_apprenant) REFERENCES elearning.Apprenant(id_apprenant) ON DELETE CASCADE,
    CONSTRAINT FK_Inscription_Formation FOREIGN KEY (id_formation) REFERENCES elearning.Formation(id_formation) ON DELETE CASCADE
);
GO
 
-- Table: Evaluation
 
CREATE TABLE elearning.Evaluation (
    id_eval INT IDENTITY(1,1) PRIMARY KEY,
    id_inscription INT NOT NULL,
    date_eval DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    duree_minutes INT NULL,
    seuil_reussite SMALLINT NULL,
    statut NVARCHAR(50) DEFAULT ('en_attente'),
    CONSTRAINT FK_Evaluation_Inscription FOREIGN KEY (id_inscription) REFERENCES elearning.Inscription(id_inscription) ON DELETE CASCADE
);
GO
 
-- Table: Resultat
 
CREATE TABLE elearning.Resultat (
    id_resultat INT IDENTITY(1,1) PRIMARY KEY,
    id_eval INT NOT NULL,
    note_obtenue DECIMAL(5,2) NULL,
    date_passage DATE DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT FK_Resultat_Evaluation FOREIGN KEY (id_eval) REFERENCES elearning.Evaluation(id_eval) ON DELETE CASCADE
);
GO
 
-- Table: Avis

CREATE TABLE elearning.Avis (
    id_avis INT IDENTITY(1,1) PRIMARY KEY,
    id_apprenant INT NOT NULL,
    id_formation INT NOT NULL,
    note_avis DECIMAL(3,2) CHECK (note_avis BETWEEN 0 AND 5),
    commentaire NVARCHAR(500),
    date_avis DATE DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT UQ_Avis UNIQUE (id_apprenant, id_formation),
    CONSTRAINT FK_Avis_Apprenant FOREIGN KEY (id_apprenant) REFERENCES elearning.Apprenant(id_apprenant),
    CONSTRAINT FK_Avis_Formation FOREIGN KEY (id_formation) REFERENCES elearning.Formation(id_formation)
);
GO
 
-- Table: Abonnement

CREATE TABLE elearning.Abonnement (
    id_abonnement INT IDENTITY(1,1) PRIMARY KEY,
    id_apprenant INT NOT NULL,
    type_abonnement NVARCHAR(50) NOT NULL, -- mensuel, annuel, formation_unique
    statut_abonnement NVARCHAR(30) DEFAULT ('actif'),
    date_debut DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    date_fin DATE NULL,
    montant DECIMAL(10,2) NULL,
    CONSTRAINT FK_Abonnement_Apprenant FOREIGN KEY (id_apprenant) REFERENCES elearning.Apprenant(id_apprenant)
);
GO
 
-- Table: Paiement
 
CREATE TABLE elearning.Paiement (
    id_paiement INT IDENTITY(1,1) PRIMARY KEY,
    id_apprenant INT NOT NULL,
    id_formation INT NULL,
    id_abonnement INT NULL,
    montant DECIMAL(10,2) NOT NULL CHECK (montant >= 0),
    type_paiement NVARCHAR(50) NULL,
    date_paiement DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    reference_transaction NVARCHAR(200) NULL,
    CONSTRAINT FK_Paiement_Apprenant FOREIGN KEY (id_apprenant) REFERENCES elearning.Apprenant(id_apprenant),
    CONSTRAINT FK_Paiement_Formation FOREIGN KEY (id_formation) REFERENCES elearning.Formation(id_formation),
    CONSTRAINT FK_Paiement_Abonnement FOREIGN KEY (id_abonnement) REFERENCES elearning.Abonnement(id_abonnement),
    CONSTRAINT CHK_Paiement_Lien CHECK (
        (id_formation IS NOT NULL AND id_abonnement IS NULL)
        OR (id_formation IS NULL AND id_abonnement IS NOT NULL)
    )
);
GO
 
-- Table: Absence
    
CREATE TABLE elearning.Absence (
    id_absence INT IDENTITY(1,1) PRIMARY KEY,
    id_inscription INT NOT NULL,
    id_seq INT NOT NULL,
    statut_absence BIT DEFAULT (1),
    date_absence DATE DEFAULT (CAST(GETDATE() AS DATE)),
    commentaire NVARCHAR(255) NULL,
    CONSTRAINT UQ_Absence UNIQUE (id_inscription, id_seq, date_absence),
    CONSTRAINT FK_Absence_Inscription FOREIGN KEY (id_inscription) REFERENCES elearning.Inscription(id_inscription),
    CONSTRAINT FK_Absence_Sequence FOREIGN KEY (id_seq) REFERENCES elearning.Sequence(id_seq)
);
GO

--Indexes
 
CREATE INDEX IX_Inscription_Formation ON elearning.Inscription(id_formation);
CREATE INDEX IX_Paiement_Apprenant ON elearning.Paiement(id_apprenant);
CREATE INDEX IX_Resultat_Note ON elearning.Resultat(note_obtenue);
CREATE INDEX IX_Avis_Apprenant ON elearning.Avis(id_apprenant);
CREATE INDEX IX_Abonnement_Apprenant ON elearning.Abonnement(id_apprenant);
GO
 

 ------------------------------------------------------------
-- Data for eLearning Platform (SQL Server Compatible)
 

 
-- Apprenants
INSERT INTO elearning.Apprenant (nom, email)
VALUES 
('Sofia Ben', 'sofia@example.com'),
('Youssef El', 'youssef@example.com'),
('Amal R', 'amal@example.com');
GO

-- Formateurs
INSERT INTO elearning.Formateur (nom, specialite)
VALUES 
('Karim H', 'Data Science'),
('Leila M', 'Frontend');
GO

-- Formations
INSERT INTO elearning.Formation (titre, niveau, duree_heures, montant)
VALUES 
('Intro Data Science', 'Débutant', 40, 300.00),
('React Avancé', 'Intermédiaire', 30, 250.00);
GO

-- Sequences
INSERT INTO elearning.Sequence (id_formation, titre, duree_minutes)
VALUES 
(1, 'Notions de Python', 90),
(1, 'Statistiques de base', 120),
(2, 'Hooks avancés', 90);
GO

-- Animer (relation Formateur ↔ Séquence)
INSERT INTO elearning.Animer (id_formateur, id_seq)
VALUES
(1, 1),
(1, 2),
(2, 3);
GO

-- Inscriptions
INSERT INTO elearning.Inscription (id_apprenant, id_formation)
VALUES
(1, 1),
(2, 1),
(3, 2);
GO

-- Evaluations
INSERT INTO elearning.Evaluation (id_inscription, duree_minutes, seuil_reussite, statut)
VALUES
(1, 60, 50, 'valide'),
(2, 60, 50, 'valide');
GO

-- Resultats
INSERT INTO elearning.Resultat (id_eval, note_obtenue)
VALUES
(1, 68.5),
(2, 45.0);
GO

-- Avis
INSERT INTO elearning.Avis (id_apprenant, id_formation, note_avis, commentaire)
VALUES
(1, 1, 4.5, 'Très clair'),
(2, 1, 3.8, 'Bon contenu');
GO

-- Abonnements
INSERT INTO elearning.Abonnement (id_apprenant, type_abonnement, date_debut, date_fin, montant)
VALUES
(3, 'mensuel', '2025-10-01', '2025-10-31', 29.90);
GO

-- Paiements (lié à l’abonnement)
INSERT INTO elearning.Paiement (id_apprenant, id_abonnement, montant, type_paiement)
VALUES
(3, 1, 29.90, 'carte');
GO

-- Absences 
INSERT INTO elearning.Absence (id_inscription, id_seq, statut_absence, commentaire)
VALUES
(1, 1, 1, 'Absent au premier cours');
GO

------------------------------------------------------------
--Lister les apprenants inscrits à chaque formation
------------------------------------------------------------
SELECT 
    f.id_formation,
    f.titre,
    a.id_apprenant,
    a.nom,
    i.date_inscription
FROM elearning.Formation AS f
JOIN elearning.Inscription AS i ON i.id_formation = f.id_formation
JOIN elearning.Apprenant AS a ON a.id_apprenant = i.id_apprenant
ORDER BY f.id_formation, i.date_inscription;
GO


------------------------------------------------------------
--Trouver les formations sans inscription active
------------------------------------------------------------
SELECT 
    f.id_formation,
    f.titre
FROM elearning.Formation AS f
LEFT JOIN elearning.Inscription AS i 
    ON i.id_formation = f.id_formation 
    AND i.statut = 'active'
WHERE i.id_inscription IS NULL;
GO


------------------------------------------------------------
-- Compter le nombre de séquences par formation
------------------------------------------------------------
SELECT 
    f.id_formation,
    f.titre,
    COUNT(s.id_seq) AS nb_sequences
FROM elearning.Formation AS f
LEFT JOIN elearning.Sequence AS s ON s.id_formation = f.id_formation
GROUP BY f.id_formation, f.titre
ORDER BY nb_sequences DESC;
GO


------------------------------------------------------------
-- Lister les formateurs les plus actifs 
-- par nombre de séquences animées 
------------------------------------------------------------
SELECT 
    fr.id_formateur,
    fr.nom,
    COUNT(a.id_seq) AS nb_sequences
FROM elearning.Formateur AS fr
LEFT JOIN elearning.Animer AS a ON a.id_formateur = fr.id_formateur
GROUP BY fr.id_formateur, fr.nom
ORDER BY nb_sequences DESC;
GO


------------------------------------------------------------
-- Trouver les apprenants sans paiement
------------------------------------------------------------
SELECT 
    a.id_apprenant,
    a.nom
FROM elearning.Apprenant AS a
LEFT JOIN elearning.Paiement AS p ON p.id_apprenant = a.id_apprenant
GROUP BY a.id_apprenant, a.nom
HAVING COUNT(p.id_paiement) = 0;
GO


------------------------------------------------------------
-- Identifier les apprenants en retard de paiement
-- abonnement mensuel expiré
------------------------------------------------------------
SELECT 
    ab.id_apprenant,
    ap.nom,
    ab.type_abonnement,
    ab.date_fin,
    ab.statut_abonnement
FROM elearning.Abonnement AS ab
JOIN elearning.Apprenant AS ap ON ap.id_apprenant = ab.id_apprenant
WHERE ab.statut_abonnement = 'actif'
  AND ab.date_fin IS NOT NULL
  AND ab.date_fin < CAST(GETDATE() AS DATE);
GO


------------------------------------------------------------
--Calculer le taux de réussite moyen par formation
--réussite = note_obtenue >= seuil_reussite
------------------------------------------------------------
SELECT 
    f.id_formation,
    f.titre,
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN r.note_obtenue >= ISNULL(e.seuil_reussite, 0) THEN 1 
                ELSE 0 
            END
        ) / NULLIF(COUNT(r.id_resultat), 0), 2
    ) AS taux_reussite_moyen
FROM elearning.Formation AS f
LEFT JOIN elearning.Inscription AS i ON i.id_formation = f.id_formation
LEFT JOIN elearning.Evaluation AS e ON e.id_inscription = i.id_inscription
LEFT JOIN elearning.Resultat AS r ON r.id_eval = e.id_eval
GROUP BY f.id_formation, f.titre
ORDER BY taux_reussite_moyen DESC;
GO


------------------------------------------------------------
--Moyenne des notes par formateur
--agrège les résultats liés aux formations animées
------------------------------------------------------------
SELECT 
    fr.id_formateur,
    fr.nom,
    ROUND(AVG(r.note_obtenue), 2) AS moyenne_notes
FROM elearning.Formateur AS fr
JOIN elearning.Animer AS an ON an.id_formateur = fr.id_formateur
JOIN elearning.Sequence AS s ON s.id_seq = an.id_seq
JOIN elearning.Formation AS fo ON fo.id_formation = s.id_formation
JOIN elearning.Inscription AS i ON i.id_formation = fo.id_formation
JOIN elearning.Evaluation AS e ON e.id_inscription = i.id_inscription
JOIN elearning.Resultat AS r ON r.id_eval = e.id_eval
GROUP BY fr.id_formateur, fr.nom
ORDER BY moyenne_notes DESC;
GO


------------------------------------------------------------
--Taux de satisfaction moyen par formation
------------------------------------------------------------
SELECT 
    f.id_formation,
    f.titre,
    ROUND(AVG(a.note_avis), 2) AS satisfaction_moyenne
FROM elearning.Formation AS f
LEFT JOIN elearning.Avis AS a ON a.id_formation = f.id_formation
GROUP BY f.id_formation, f.titre
ORDER BY satisfaction_moyenne DESC;
GO


------------------------------------------------------------
--Total des montants payés par apprenant
------------------------------------------------------------
SELECT 
    ap.id_apprenant,
    ap.nom,
    COALESCE(SUM(p.montant), 0) AS total_payes
FROM elearning.Apprenant AS ap
LEFT JOIN elearning.Paiement AS p ON p.id_apprenant = ap.id_apprenant
GROUP BY ap.id_apprenant, ap.nom
ORDER BY total_payes DESC;
GO


------------------------------------------------------------
--Classement des formations selon satisfaction moyenne
------------------------------------------------------------
SELECT 
    f.id_formation,
    f.titre,
    ROUND(AVG(av.note_avis), 2) AS note_moy
FROM elearning.Formation AS f
LEFT JOIN elearning.Avis AS av ON av.id_formation = f.id_formation
GROUP BY f.id_formation, f.titre
ORDER BY note_moy DESC;
GO

-- Classement des formations selon score composite

WITH metrics AS (
    SELECT 
        f.id_formation, 
        f.titre,
        ISNULL(
            100.0 * SUM(CASE WHEN r.note_obtenue >= ISNULL(e.seuil_reussite,0) THEN 1 ELSE 0 END) 
            / NULLIF(COUNT(r.id_resultat),0), 0
        ) AS taux_reussite,
        ISNULL(AVG(av.note_avis), 0) AS satisfaction,
        ISNULL(cnt.total_inscrits,0) AS volume
    FROM elearning.Formation AS f
    LEFT JOIN elearning.Inscription AS ins ON ins.id_formation = f.id_formation
    LEFT JOIN elearning.Evaluation AS e ON e.id_inscription = ins.id_inscription
    LEFT JOIN elearning.Resultat AS r ON r.id_eval = e.id_eval
    LEFT JOIN elearning.Avis AS av ON av.id_formation = f.id_formation
    LEFT JOIN (
        SELECT id_formation, COUNT(*) AS total_inscrits
        FROM elearning.Inscription
        GROUP BY id_formation
    ) AS cnt ON cnt.id_formation = f.id_formation
    GROUP BY f.id_formation, f.titre, cnt.total_inscrits
)
SELECT 
    id_formation,
    titre,
    taux_reussite,
    satisfaction,
    volume,
    ROUND(
        (0.4 * taux_reussite) + 
        (0.4 * (satisfaction * 20)) + 
        (0.2 * CASE WHEN volume > 100 THEN 100 ELSE volume END),
        2
    ) AS score_composite
FROM metrics
ORDER BY score_composite DESC;
GO

--Classer les formateurs avec `RANK()` selon performance

SELECT 
    id_formateur, 
    nom, 
    moyenne_notes,
    RANK() OVER (ORDER BY moyenne_notes DESC) AS rang
FROM (
    SELECT 
        fr.id_formateur, 
        fr.nom, 
        AVG(r.note_obtenue) AS moyenne_notes
    FROM elearning.Formateur AS fr
    JOIN elearning.Animer AS an ON an.id_formateur = fr.id_formateur
    JOIN elearning.Sequence AS s ON s.id_seq = an.id_seq
    JOIN elearning.Formation AS fo ON fo.id_formation = s.id_formation
    JOIN elearning.Inscription AS i ON i.id_formation = fo.id_formation
    JOIN elearning.Evaluation AS e ON e.id_inscription = i.id_inscription
    JOIN elearning.Resultat AS r ON r.id_eval = e.id_eval
    GROUP BY fr.id_formateur, fr.nom
) AS t;
GO
--Vue `vue_performance` (taux réussite, satisfaction, régularité paiement)

CREATE OR ALTER VIEW elearning.vue_performance AS
SELECT 
    f.id_formation,
    f.titre,
    ISNULL(cnt.total_inscrits,0) AS total_inscrits,
    ISNULL(reu.taux_reussite,0) AS taux_reussite,
    ISNULL(sat.satisfaction_moy,0) AS satisfaction_moyenne,
    ISNULL(p.regularite_paiement,0) AS regularite_paiement
FROM elearning.Formation AS f
LEFT JOIN (
    SELECT id_formation, COUNT(*) AS total_inscrits
    FROM elearning.Inscription
    GROUP BY id_formation
) AS cnt ON cnt.id_formation = f.id_formation
LEFT JOIN (
    SELECT 
        i.id_formation,
        100.0 * SUM(CASE WHEN r.note_obtenue >= ISNULL(e.seuil_reussite,0) THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(r.id_resultat),0) AS taux_reussite
    FROM elearning.Resultat AS r
    JOIN elearning.Evaluation AS e ON e.id_eval = r.id_eval
    JOIN elearning.Inscription AS i ON i.id_inscription = e.id_inscription
    GROUP BY i.id_formation
) AS reu ON reu.id_formation = f.id_formation
LEFT JOIN (
    SELECT id_formation, AVG(note_avis) AS satisfaction_moy
    FROM elearning.Avis
    GROUP BY id_formation
) AS sat ON sat.id_formation = f.id_formation
LEFT JOIN (
    SELECT 
        i.id_formation,
        100.0 * COUNT(DISTINCT p.id_apprenant) 
        / NULLIF(COUNT(DISTINCT i.id_apprenant),0) AS regularite_paiement
    FROM elearning.Inscription AS i
    LEFT JOIN elearning.Paiement AS p ON p.id_apprenant = i.id_apprenant
    GROUP BY i.id_formation
) AS p ON p.id_formation = f.id_formation;
GO
 
USE [YourDatabaseName]; -- Replace with your DB name
GO

------------------------------------------------------------
-- 1. Evaluation integrity
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys WHERE name = 'FK_Evaluation_Inscription'
)
ALTER TABLE elearning.Evaluation
ADD CONSTRAINT FK_Evaluation_Inscription
FOREIGN KEY (id_inscription)
REFERENCES elearning.Inscription(id_inscription)
ON DELETE CASCADE;
GO

------------------------------------------------------------
-- 2. Unique Reviews
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.indexes WHERE name = 'UQ_Avis'
)
ALTER TABLE elearning.Avis
ADD CONSTRAINT UQ_Avis UNIQUE (id_apprenant, id_formation);
GO

------------------------------------------------------------
-- 3. Payment validation
------------------------------------------------------------
-- 3a. Check positive amounts
IF NOT EXISTS (
    SELECT * FROM sys.check_constraints WHERE name = 'CHK_Paiement_Montant'
)
ALTER TABLE elearning.Paiement
ADD CONSTRAINT CHK_Paiement_Montant CHECK (montant >= 0);
GO

-- 3b. Trigger to validate payments against active inscriptions
IF OBJECT_ID('elearning.trg_Paiement_Validation','TR') IS NOT NULL
    DROP TRIGGER elearning.trg_Paiement_Validation;
GO

CREATE TRIGGER elearning.trg_Paiement_Validation
ON elearning.Paiement
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN elearning.Inscription ins
            ON ins.id_apprenant = i.id_apprenant
            AND ins.id_formation = i.id_formation
            AND ins.statut = 'active'
        WHERE i.id_formation IS NOT NULL
          AND ins.id_inscription IS NULL
    )
    BEGIN
        RAISERROR('Paiement impossible : aucune inscription active correspondante',16,1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Explicitly list columns, excluding identity
    INSERT INTO elearning.Paiement (id_apprenant, id_formation, id_abonnement, montant, type_paiement, date_paiement, reference_transaction)
    SELECT id_apprenant, id_formation, id_abonnement, montant, type_paiement, date_paiement, reference_transaction
    FROM inserted;
END;
GO

------------------------------------------------------------
-- 4. Unique Inscription
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.indexes WHERE name = 'UQ_Inscription'
)
ALTER TABLE elearning.Inscription
ADD CONSTRAINT UQ_Inscription UNIQUE (id_apprenant, id_formation);
GO

------------------------------------------------------------
-- 5. Subscription management
------------------------------------------------------------
-- 5a. Check valid subscription types
IF NOT EXISTS (
    SELECT * FROM sys.check_constraints WHERE name = 'CHK_TypeAbonnement'
)
ALTER TABLE elearning.Abonnement
ADD CONSTRAINT CHK_TypeAbonnement 
CHECK (type_abonnement IN ('mensuel','annuel','formation_unique'));
GO

-- 5b. Echeance table
IF OBJECT_ID('elearning.Echeance','U') IS NULL
BEGIN
    CREATE TABLE elearning.Echeance (
        id_echeance INT IDENTITY(1,1) PRIMARY KEY,
        id_abonnement INT NOT NULL,
        date_echeance DATE NOT NULL,
        statut_paiement NVARCHAR(20) DEFAULT 'non_regle',
        CONSTRAINT FK_Echeance_Abonnement FOREIGN KEY (id_abonnement) 
            REFERENCES elearning.Abonnement(id_abonnement) ON DELETE CASCADE
    );
END;
GO

------------------------------------------------------------
-- 6. Absence tracking uniqueness
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.indexes WHERE name = 'UQ_Absence'
)
ALTER TABLE elearning.Absence
ADD CONSTRAINT UQ_Absence UNIQUE (id_inscription, id_seq, date_absence);
GO

------------------------------------------------------------
-- 7. Trigger to mark evaluation as 'termine'
------------------------------------------------------------
IF OBJECT_ID('elearning.trg_Evaluation_Completion','TR') IS NOT NULL
    DROP TRIGGER elearning.trg_Evaluation_Completion;
GO

CREATE TRIGGER elearning.trg_Evaluation_Completion
ON elearning.Resultat
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE e
    SET statut = 'termine'
    FROM elearning.Evaluation e
    INNER JOIN inserted i ON i.id_eval = e.id_eval;
END;
GO

------------------------------------------------------------
-- 8.other integrity and rules
------------------------------------------------------------
PRINT 'All integrity constraints, triggers, and checks have been applied successfully.';

--Option A – Simple Approach

SELECT *
FROM elearning.Abonnement
WHERE type_abonnement = 'mensuel'
  AND statut_abonnement = 'actif'
  AND date_fin < CAST(GETDATE() AS DATE);

--Option B – Robust Approach
 
------------------------------------------------------------
-- 1. Ensure subscription types are valid
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.check_constraints WHERE name = 'CHK_TypeAbonnement'
)
ALTER TABLE elearning.Abonnement
ADD CONSTRAINT CHK_TypeAbonnement 
CHECK (type_abonnement IN ('mensuel','annuel','formation_unique'));
GO

------------------------------------------------------------
-- 2. Create Echeance table
------------------------------------------------------------
IF OBJECT_ID('elearning.Echeance', 'U') IS NULL
BEGIN
    CREATE TABLE elearning.Echeance (
        id_echeance INT IDENTITY(1,1) PRIMARY KEY,
        id_abonnement INT NOT NULL,
        date_echeance DATE NOT NULL,
        statut_paiement NVARCHAR(20) DEFAULT 'non_regle',
        CONSTRAINT FK_Echeance_Abonnement FOREIGN KEY (id_abonnement)
            REFERENCES elearning.Abonnement(id_abonnement)
            ON DELETE CASCADE
    );
END;
GO

------------------------------------------------------------
-- 3. Trigger to generate monthly Echeances upon subscription insert
------------------------------------------------------------
IF OBJECT_ID('elearning.trg_GenerateEcheance', 'TR') IS NOT NULL
    DROP TRIGGER elearning.trg_GenerateEcheance;
GO

CREATE TRIGGER elearning.trg_GenerateEcheance
ON elearning.Abonnement
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @months INT;
    DECLARE @i INT;
    DECLARE @start DATE;
    DECLARE @end DATE;
    DECLARE @id_abonnement INT;

    DECLARE ab_cursor CURSOR LOCAL FOR
    SELECT id_abonnement, date_debut, date_fin
    FROM inserted
    WHERE type_abonnement = 'mensuel';

    OPEN ab_cursor;
    FETCH NEXT FROM ab_cursor INTO @id_abonnement, @start, @end;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Default: one month increments until date_fin
        SET @i = 0;

        WHILE @start <= @end
        BEGIN
            INSERT INTO elearning.Echeance (id_abonnement, date_echeance)
            VALUES (@id_abonnement, @start);

            -- Next month
            SET @start = DATEADD(MONTH, 1, @start);
            SET @i = @i + 1;
        END

        FETCH NEXT FROM ab_cursor INTO @id_abonnement, @start, @end;
    END

    CLOSE ab_cursor;
    DEALLOCATE ab_cursor;
END;
GO

------------------------------------------------------------
-- 4. Query example – unpaid months
------------------------------------------------------------
-- Shows all monthly subscription dues not yet paid
SELECT e.id_echeance, ab.id_abonnement, ap.id_apprenant, ap.nom, e.date_echeance
FROM elearning.Echeance e
JOIN elearning.Abonnement ab ON ab.id_abonnement = e.id_abonnement
JOIN elearning.Apprenant ap ON ap.id_apprenant = ab.id_apprenant
WHERE e.statut_paiement = 'non_regle'
ORDER BY ap.id_apprenant, e.date_echeance;
GO

------------------------------------------------------------
-- 5. Optional: Mark Echeance as paid upon payment
------------------------------------------------------------
-- You can add a trigger on Paiement to update Echeance
IF OBJECT_ID('elearning.trg_UpdateEcheanceOnPaiement','TR') IS NOT NULL
    DROP TRIGGER elearning.trg_UpdateEcheanceOnPaiement;
GO

CREATE TRIGGER elearning.trg_UpdateEcheanceOnPaiement
ON elearning.Paiement
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Only handle abonnement payments
    UPDATE e
    SET statut_paiement = 'regle'
    FROM elearning.Echeance e
    JOIN inserted i ON i.id_abonnement = e.id_abonnement
    WHERE e.statut_paiement = 'non_regle'
      AND e.date_echeance <= CAST(GETDATE() AS DATE);
END;
GO

PRINT 'Monthly subscription management (Option B) successfully implemented.';

------------------------------------------------------------
-- 1. Ensure Absence table uniqueness (already included)
------------------------------------------------------------
-- Prevent duplicate absences for the same student, sequence, and date
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'UQ_Absence'
)
BEGIN
    ALTER TABLE elearning.Absence
    ADD CONSTRAINT UQ_Absence UNIQUE (id_inscription, id_seq, date_absence);
END
GO

------------------------------------------------------------
-- 2. Calculate absenteeism rate per student
------------------------------------------------------------
-- Percentage of sequences missed by a student
SELECT a.id_apprenant, a.nom, 
       COUNT(abs.id_absence) AS total_absences,
       COUNT(s.id_seq) AS total_sequences,
       ROUND(100.0 * COUNT(abs.id_absence) / NULLIF(COUNT(s.id_seq),0),2) AS taux_absenteisme
FROM elearning.Apprenant a
JOIN elearning.Inscription i ON i.id_apprenant = a.id_apprenant
JOIN elearning.Sequence s ON s.id_formation = i.id_formation
LEFT JOIN elearning.Absence abs 
       ON abs.id_inscription = i.id_inscription AND abs.id_seq = s.id_seq
GROUP BY a.id_apprenant, a.nom
ORDER BY taux_absenteisme DESC;
GO

------------------------------------------------------------
-- 3. Calculate absenteeism rate per formation
------------------------------------------------------------
SELECT f.id_formation, f.titre,
       COUNT(abs.id_absence) AS total_absences,
       COUNT(i.id_inscription * s.id_seq) AS total_expected_attendances,
       ROUND(100.0 * COUNT(abs.id_absence) / NULLIF(COUNT(i.id_inscription * s.id_seq),0),2) AS taux_absenteisme
FROM elearning.Formation f
JOIN elearning.Inscription i ON i.id_formation = f.id_formation
JOIN elearning.Sequence s ON s.id_formation = f.id_formation
LEFT JOIN elearning.Absence abs 
       ON abs.id_inscription = i.id_inscription AND abs.id_seq = s.id_seq
GROUP BY f.id_formation, f.titre
ORDER BY taux_absenteisme DESC;
GO

------------------------------------------------------------
-- 4. Trigger example – alert after N absences
------------------------------------------------------------
-- Example: send alert if student misses 3 or more sequences
IF OBJECT_ID('elearning.trg_AlertAbsence','TR') IS NOT NULL
    DROP TRIGGER elearning.trg_AlertAbsence;
GO

CREATE TRIGGER elearning.trg_AlertAbsence
ON elearning.Absence
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @N INT = 3;

    -- Count total absences for affected student
    DECLARE @id_inscription INT, @id_apprenant INT;
    SELECT @id_inscription = id_inscription FROM inserted;
    SELECT @id_apprenant = i.id_apprenant 
    FROM elearning.Inscription i 
    WHERE i.id_inscription = @id_inscription;

    DECLARE @total_absences INT;
    SELECT @total_absences = COUNT(*) 
    FROM elearning.Absence 
    WHERE id_inscription IN (SELECT id_inscription FROM elearning.Inscription WHERE id_apprenant = @id_apprenant);

    IF @total_absences >= @N
    BEGIN
        PRINT 'ALERT: Apprenant ID ' + CAST(@id_apprenant AS NVARCHAR(10)) 
              + ' has reached ' + CAST(@total_absences AS NVARCHAR(10)) + ' absences.';
        -- Optional: insert into an Alert table or send email/notification
    END
END;
GO

PRINT 'Absence management implemented successfully.';

-- 1. Monthly Success Rate per Formation
 
CREATE OR ALTER VIEW elearning.vue_taux_reussite_mensuel AS
SELECT 

    f.id_formation,
    f.titre,
    YEAR(e.date_eval) AS annee,
    MONTH(e.date_eval) AS mois,
    CASE WHEN COUNT(r.id_resultat) = 0 THEN 0
         ELSE 100.0 * SUM(CASE WHEN r.note_obtenue >= ISNULL(e.seuil_reussite,0) THEN 1 ELSE 0 END) / COUNT(r.id_resultat)
    END AS taux_reussite
FROM elearning.Formation f
LEFT JOIN elearning.Inscription i ON i.id_formation = f.id_formation
LEFT JOIN elearning.Evaluation e ON e.id_inscription = i.id_inscription
LEFT JOIN elearning.Resultat r ON r.id_eval = e.id_eval
GROUP BY f.id_formation, f.titre, YEAR(e.date_eval), MONTH(e.date_eval);
GO
 
-- 2. Satisfaction per Formation
 
CREATE OR ALTER VIEW elearning.vue_satisfaction_formation AS
SELECT 
    f.id_formation, 
    f.titre, 
    ROUND(AVG(a.note_avis),2) AS satisfaction_moyenne
FROM elearning.Formation f
LEFT JOIN elearning.Avis a ON a.id_formation = f.id_formation
GROUP BY f.id_formation, f.titre;
GO
 
-- 3. Satisfaction per Formateur
 
CREATE OR ALTER VIEW elearning.vue_satisfaction_formateur AS
SELECT 
    fr.id_formateur,
    fr.nom,
    ROUND(AVG(r.note_obtenue),2) AS satisfaction_moyenne
FROM elearning.Formateur fr
JOIN elearning.Animer an ON an.id_formateur = fr.id_formateur
JOIN elearning.Sequence s ON s.id_seq = an.id_seq
JOIN elearning.Inscription i ON i.id_formation = s.id_formation
JOIN elearning.Evaluation e ON e.id_inscription = i.id_inscription
JOIN elearning.Resultat r ON r.id_eval = e.id_eval
GROUP BY fr.id_formateur, fr.nom;
GO
 
-- 4. Payment Regularity per Formation
 
CREATE OR ALTER VIEW elearning.vue_regularite_paiement AS
SELECT 
    f.id_formation,
    f.titre,
    CASE WHEN COUNT(DISTINCT i.id_apprenant) = 0 THEN 0
         ELSE 100.0 * COUNT(DISTINCT p.id_apprenant) / COUNT(DISTINCT i.id_apprenant)
    END AS regularite_paiement
FROM elearning.Formation f
LEFT JOIN elearning.Inscription i ON i.id_formation = f.id_formation
LEFT JOIN elearning.Paiement p ON p.id_apprenant = i.id_apprenant AND p.id_formation = i.id_formation
GROUP BY f.id_formation, f.titre;
GO
 
-- 5. Cash Flow Monthly
 
CREATE OR ALTER VIEW elearning.vue_cashflow_mensuel AS
SELECT 
    YEAR(p.date_paiement) AS annee,
    MONTH(p.date_paiement) AS mois,
    SUM(p.montant) AS total_paiements
FROM elearning.Paiement p
GROUP BY YEAR(p.date_paiement), MONTH(p.date_paiement);
GO

-- 6. Top Formations (Score Composite)
 
CREATE OR ALTER VIEW elearning.vue_top_formations AS
WITH metrics AS (
    SELECT f.id_formation, f.titre,
        ISNULL(100.0 * SUM(CASE WHEN r.note_obtenue >= ISNULL(e.seuil_reussite,0) THEN 1 ELSE 0 END) / NULLIF(COUNT(r.id_resultat),0),0) AS taux_reussite,
        ISNULL(AVG(av.note_avis),0) AS satisfaction,
        ISNULL(cnt.total_inscrits,0) AS volume
    FROM elearning.Formation f
    LEFT JOIN elearning.Inscription ins ON ins.id_formation = f.id_formation
    LEFT JOIN elearning.Evaluation e ON e.id_inscription = ins.id_inscription
    LEFT JOIN elearning.Resultat r ON r.id_eval = e.id_eval
    LEFT JOIN elearning.Avis av ON av.id_formation = f.id_formation
    LEFT JOIN (SELECT id_formation, COUNT(*) AS total_inscrits FROM elearning.Inscription GROUP BY id_formation) cnt
        ON cnt.id_formation = f.id_formation
    GROUP BY f.id_formation, f.titre, cnt.total_inscrits
)
SELECT id_formation, titre, taux_reussite, satisfaction, volume,
    ROUND((0.4 * taux_reussite) + (0.4 * (satisfaction*20)) + (0.2 * CASE WHEN volume>100 THEN 100 ELSE volume END),2) AS score_composite
FROM metrics;
GO
 
-- 7. Absenteeism vs Failure
 
CREATE OR ALTER VIEW elearning.vue_absenteisme_echec AS
SELECT 
    f.id_formation,
    f.titre,
    CASE WHEN COUNT(a.id_absence) = 0 THEN 0
         ELSE 100.0 * COUNT(a.id_absence) / COUNT(DISTINCT i.id_inscription)
    END AS taux_absenteisme,
    CASE WHEN COUNT(r.id_resultat) = 0 THEN 0
         ELSE 100.0 * SUM(CASE WHEN r.note_obtenue >= ISNULL(e.seuil_reussite,0) THEN 0 ELSE 1 END) / COUNT(r.id_resultat)
    END AS taux_echec
FROM elearning.Formation f
LEFT JOIN elearning.Inscription i ON i.id_formation = f.id_formation
LEFT JOIN elearning.Absence a ON a.id_inscription = i.id_inscription
LEFT JOIN elearning.Evaluation e ON e.id_inscription = i.id_inscription
LEFT JOIN elearning.Resultat r ON r.id_eval = e.id_eval
GROUP BY f.id_formation, f.titre;
GO
 
-- 8. Ranking Formateurs
 
CREATE OR ALTER VIEW elearning.vue_ranking_formateurs AS
SELECT 
    fr.id_formateur,
    fr.nom,
    AVG(r.note_obtenue) AS moyenne_notes,
    RANK() OVER (ORDER BY AVG(r.note_obtenue) DESC) AS rang
FROM elearning.Formateur fr
JOIN elearning.Animer an ON an.id_formateur = fr.id_formateur
JOIN elearning.Sequence s ON s.id_seq = an.id_seq
JOIN elearning.Inscription i ON i.id_formation = s.id_formation
JOIN elearning.Evaluation e ON e.id_inscription = i.id_inscription
JOIN elearning.Resultat r ON r.id_eval = e.id_eval
GROUP BY fr.id_formateur, fr.nom;
GO

PRINT 'Director dashboard views created successfully.';
 
--ANALYTIQUE – SATISFACTION VS PERFORMANCE
  
--Vue : Moyennes satisfaction et performance par apprenant et formation
IF OBJECT_ID('elearning.vue_satisfaction_performance') IS NOT NULL 
    DROP VIEW elearning.vue_satisfaction_performance;
GO
CREATE VIEW elearning.vue_satisfaction_performance AS
SELECT 
    a.id_apprenant,
    f.id_formation,
    f.titre AS titre_formation,
    AVG(av.note_avis) AS moyenne_satisfaction,
    AVG(r.note_obtenue) AS moyenne_performance,
    COUNT(DISTINCT r.id_resultat) AS nb_resultats
FROM elearning.Apprenant a
JOIN elearning.Inscription i ON a.id_apprenant = i.id_apprenant
JOIN elearning.Formation f ON i.id_formation = f.id_formation
LEFT JOIN elearning.Avis av 
    ON av.id_formation = f.id_formation 
   AND av.id_apprenant = a.id_apprenant
LEFT JOIN elearning.Resultat r 
    ON r.id_eval IN (
        SELECT e.id_eval
        FROM elearning.Evaluation e
        WHERE e.id_inscription = i.id_inscription
    )
GROUP BY a.id_apprenant, f.id_formation, f.titre;
GO
--Vue : Corrélation (coefficient de Pearson) entre satisfaction et performance
IF OBJECT_ID('elearning.vue_correlation_satisfaction_performance') IS NOT NULL 
    DROP VIEW elearning.vue_correlation_satisfaction_performance;
GO
CREATE VIEW elearning.vue_correlation_satisfaction_performance AS
SELECT
    f.id_formation,
    f.titre AS titre_formation,
    COUNT(*) AS n,
    SUM(
        (sp.moyenne_satisfaction - stats.moy_satisfaction) * 
        (sp.moyenne_performance - stats.moy_performance)
    ) /
    NULLIF(
        SQRT(SUM(POWER(sp.moyenne_satisfaction - stats.moy_satisfaction, 2))) *
        SQRT(SUM(POWER(sp.moyenne_performance - stats.moy_performance, 2))),
        0
    ) AS coefficient_pearson
FROM elearning.vue_satisfaction_performance sp
JOIN (
    SELECT 
        id_formation,
        AVG(moyenne_satisfaction) AS moy_satisfaction,
        AVG(moyenne_performance) AS moy_performance
    FROM elearning.vue_satisfaction_performance
    GROUP BY id_formation
) stats 
    ON sp.id_formation = stats.id_formation
JOIN elearning.Formation f 
    ON f.id_formation = sp.id_formation
GROUP BY f.id_formation, f.titre;
GO
--Vue : Performance et satisfaction par cohorte (année d’inscription)
IF OBJECT_ID('elearning.vue_performance_cohorte') IS NOT NULL 
    DROP VIEW elearning.vue_performance_cohorte;
GO
CREATE VIEW elearning.vue_performance_cohorte AS
SELECT 
    YEAR(i.date_inscription) AS annee_cohorte,
    f.id_formation,
    f.titre AS titre_formation,
    COUNT(DISTINCT a.id_apprenant) AS nb_apprenants,
    AVG(r.note_obtenue) AS performance_moyenne,
    AVG(av.note_avis) AS satisfaction_moyenne
FROM elearning.Inscription i
JOIN elearning.Apprenant a ON i.id_apprenant = a.id_apprenant
JOIN elearning.Formation f ON i.id_formation = f.id_formation
LEFT JOIN elearning.Avis av 
    ON av.id_formation = f.id_formation 
   AND av.id_apprenant = a.id_apprenant
LEFT JOIN elearning.Resultat r 
    ON r.id_eval IN (
        SELECT e.id_eval FROM elearning.Evaluation e WHERE e.id_inscription = i.id_inscription
    )
GROUP BY YEAR(i.date_inscription), f.id_formation, f.titre;
GO
--Vue : Interprétation qualitative du coefficient de corrélation
IF OBJECT_ID('elearning.vue_interpretation_correlation') IS NOT NULL 
    DROP VIEW elearning.vue_interpretation_correlation;
GO
CREATE VIEW elearning.vue_interpretation_correlation AS
SELECT 
    titre_formation,
    coefficient_pearson,
    CASE 
        WHEN coefficient_pearson > 0.6 THEN 'Corrélation positive forte'
        WHEN coefficient_pearson BETWEEN 0.3 AND 0.6 THEN 'Corrélation modérée'
        WHEN coefficient_pearson BETWEEN -0.3 AND 0.3 THEN 'Corrélation faible'
        ELSE 'Corrélation négative forte'
    END AS interpretation
FROM elearning.vue_correlation_satisfaction_performance;
GO
 
--Sécurité - suppression si déjà existant
IF OBJECT_ID('Resultat', 'U') IS NOT NULL DROP TABLE Resultat;
IF OBJECT_ID('Apprenant', 'U') IS NOT NULL DROP TABLE Apprenant;
IF OBJECT_ID('Absence', 'U') IS NOT NULL DROP TABLE Absence;
IF OBJECT_ID('Paiement', 'U') IS NOT NULL DROP TABLE Paiement;
IF OBJECT_ID('Log_Activite', 'U') IS NOT NULL DROP TABLE Log_Activite;
IF OBJECT_ID('Consentement_Donnees', 'U') IS NOT NULL DROP TABLE Consentement_Donnees;
IF OBJECT_ID('Historique_Resultats', 'U') IS NOT NULL DROP TABLE Historique_Resultats;
IF OBJECT_ID('Historique_Paiements', 'U') IS NOT NULL DROP TABLE Historique_Paiements;
IF OBJECT_ID('Historique_Absences', 'U') IS NOT NULL DROP TABLE Historique_Absences;
GO
 
-- Création des tables de base  
 
CREATE TABLE Apprenant (
    id_apprenant INT IDENTITY PRIMARY KEY,
    nom NVARCHAR(100),
    prenom NVARCHAR(100),
    email NVARCHAR(255)
);

CREATE TABLE Resultat (
    id_resultat INT IDENTITY PRIMARY KEY,
    id_apprenant INT,
    note_obtenue FLOAT,
    date_evaluation DATETIME,
    FOREIGN KEY (id_apprenant) REFERENCES Apprenant(id_apprenant)
);

CREATE TABLE Absence (
    id_absence INT IDENTITY PRIMARY KEY,
    id_apprenant INT,
    date_absence DATE,
    motif NVARCHAR(255),
    FOREIGN KEY (id_apprenant) REFERENCES Apprenant(id_apprenant)
);

CREATE TABLE Paiement (
    id_paiement INT IDENTITY PRIMARY KEY,
    id_apprenant INT,
    montant DECIMAL(10,2),
    date_paiement DATETIME,
    FOREIGN KEY (id_apprenant) REFERENCES Apprenant(id_apprenant)
);
 
-- Historisation + Logs + Consentement
 
CREATE TABLE Historique_Resultats (
    id_historique INT IDENTITY PRIMARY KEY,
    id_resultat INT,
    id_apprenant INT,
    note_obtenue FLOAT,
    date_enregistrement DATETIME DEFAULT GETDATE()
);

CREATE TABLE Historique_Paiements (
    id_historique INT IDENTITY PRIMARY KEY,
    id_paiement INT,
    id_apprenant INT,
    montant DECIMAL(10,2),
    date_paiement DATETIME
);

CREATE TABLE Historique_Absences (
    id_historique INT IDENTITY PRIMARY KEY,
    id_absence INT,
    id_apprenant INT,
    date_absence DATE,
    motif NVARCHAR(255)
);

CREATE TABLE Log_Activite (
    id_log INT IDENTITY PRIMARY KEY,
    id_apprenant INT,
    action NVARCHAR(255),
    duree_session INT,
    timestamp DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_apprenant) REFERENCES Apprenant(id_apprenant)
);

CREATE TABLE Consentement_Donnees (
    id_consentement INT IDENTITY PRIMARY KEY,
    id_apprenant INT,
    consentement BIT DEFAULT 1,
    date_consentement DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (id_apprenant) REFERENCES Apprenant(id_apprenant)
);
GO 
-- Création des vues analytiques IA
 

-- Vue 1 : moyenne mobile des notes (fenêtre sur 3 évaluations)
IF OBJECT_ID('vue_moyenne_mobile_notes', 'V') IS NOT NULL DROP VIEW vue_moyenne_mobile_notes;
GO
CREATE VIEW vue_moyenne_mobile_notes AS
SELECT 
    r.id_apprenant,
    AVG(r.note_obtenue) OVER (
        PARTITION BY r.id_apprenant 
        ORDER BY r.date_evaluation 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moyenne_mobile_3
FROM Resultat r;
GO

-- Vue 2 : features IA agrégées
IF OBJECT_ID('vue_features_apprenant', 'V') IS NOT NULL DROP VIEW vue_features_apprenant;
GO
CREATE VIEW vue_features_apprenant AS
SELECT 
    a.id_apprenant,
    COUNT(DISTINCT r.id_resultat) AS nb_evaluations,
    AVG(r.note_obtenue) AS moyenne_notes,
    COUNT(DISTINCT ab.id_absence) AS nb_absences,
    SUM(p.montant) AS total_paye,
    COUNT(DISTINCT l.id_log) AS nb_sessions,
    AVG(l.duree_session) AS duree_moyenne
FROM Apprenant a
LEFT JOIN Resultat r ON r.id_apprenant = a.id_apprenant
LEFT JOIN Absence ab ON ab.id_apprenant = a.id_apprenant
LEFT JOIN Paiement p ON p.id_apprenant = a.id_apprenant
LEFT JOIN Log_Activite l ON l.id_apprenant = a.id_apprenant
GROUP BY a.id_apprenant;
GO

-- Vue 3 : données IA anonymisées
IF OBJECT_ID('vue_donnees_IA_anonymisees', 'V') IS NOT NULL DROP VIEW vue_donnees_IA_anonymisees;
GO
CREATE VIEW vue_donnees_IA_anonymisees AS
SELECT 
    CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', CAST(f.id_apprenant AS NVARCHAR(50))), 2) AS id_anonyme,
    f.nb_evaluations,
    f.moyenne_notes,
    f.nb_absences,
    f.total_paye,
    f.nb_sessions,
    f.duree_moyenne
FROM vue_features_apprenant f
JOIN Consentement_Donnees c ON c.id_apprenant = f.id_apprenant
WHERE c.consentement = 1;
GO
