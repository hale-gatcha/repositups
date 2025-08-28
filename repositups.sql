-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 27, 2025 at 04:57 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `repositups`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddKeyword` (IN `keywordName` VARCHAR(255))   BEGIN
    INSERT INTO Keyword (keywordName) VALUES (keywordName);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddKeywordToResearch` (IN `rID` INT, IN `keywordID` INT)   BEGIN
    INSERT IGNORE INTO ResearchKeyword (researchID, keywordID)
    VALUES (rID, keywordID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddResearchEntry` (IN `uploaderID` INT, IN `title` VARCHAR(255), IN `adviserID` VARCHAR(50), IN `program` ENUM('Bachelor of Science in Information Technology','Bachelor of Science in Computer Science','Bachelor of Library and Information Science','Master of Library and Information Science','Master in Information Technology'), IN `month` TINYINT, IN `year` YEAR, IN `abstract` TEXT, IN `approvalSheet` LONGBLOB, IN `manuscript` LONGBLOB)   BEGIN
    INSERT INTO Research (
        uploadedBy, researchTitle, researchAdviser, program,
        publishedMonth, publishedYear, researchAbstract,
        researchApprovalSheet, researchManuscript
    ) VALUES (
        uploaderID, title, adviserID, program, month, year,
        abstract, approvalSheet, manuscript
    );
    
    SET @last_id = LAST_INSERT_ID();
    
    INSERT INTO ResearchEntryLog (
        performedBy, actionType, researchID, timestamp
    ) VALUES (
        uploaderID, 'create', @last_id, NOW()
    );
    
    -- Return the inserted ID
    SELECT @last_id AS researchID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddResearcher` (IN `rID` INT, IN `fname` VARCHAR(255), IN `mname` VARCHAR(255), IN `lname` VARCHAR(255), IN `email` VARCHAR(255))   BEGIN
    INSERT INTO Researcher (
        researchID, firstName, middleName, lastName, email
    ) VALUES (
        rID, fname, mname, lname, email
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AssignPanelist` (IN `rID` INT, IN `fID` INT)   BEGIN
    INSERT INTO Panel (researchID, facultyID) VALUES (rID, fID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteKeyword` (IN `keywordID` INT)   BEGIN
    DELETE FROM Keyword WHERE keywordID = keywordID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteResearcher` (IN `rID` INT)   BEGIN
    DELETE FROM Researcher WHERE researcherID = rID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllFacultyProductivity` ()   BEGIN
    SELECT 
        f.facultyID, 
        f.firstName, 
        f.lastName,
        COUNT(DISTINCT r.researchID) AS advisedCount,
        COUNT(DISTINCT p.researchID) AS paneledCount
    FROM Faculty f
    LEFT JOIN Research r ON r.researchAdviser = f.facultyID
    LEFT JOIN Panel p ON p.facultyID = f.facultyID
    GROUP BY f.facultyID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFacultyProductivityReport` (IN `facultyID` INT)   BEGIN
    SELECT f.facultyID, f.firstName, f.lastName,
        (SELECT COUNT(*) FROM Research r WHERE r.researchAdviser = f.facultyID) AS advisedCount,
        (SELECT COUNT(*) FROM Panel p WHERE p.facultyID = f.facultyID) AS paneledCount
    FROM Faculty f
    WHERE f.facultyID = facultyID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RemoveKeywordFromResearch` (IN `rID` INT, IN `keywordID` INT)   BEGIN
    DELETE FROM ResearchKeyword 
    WHERE researchID = rID AND keywordID = keywordID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RemovePanelist` (IN `rID` INT, IN `fID` INT)   BEGIN
    DELETE FROM Panel WHERE researchID = rID AND facultyID = fID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddFaculty` (IN `p_facultyID` VARCHAR(50), IN `p_firstName` VARCHAR(255), IN `p_middleName` VARCHAR(255), IN `p_lastName` VARCHAR(255), IN `p_position` VARCHAR(100), IN `p_designation` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_ORCID` VARCHAR(50), IN `p_contactNumber` VARCHAR(50), IN `p_educAttainment` VARCHAR(255), IN `p_specialization` VARCHAR(255), IN `p_researchInterest` VARCHAR(255), IN `p_isPartOfCIC` BOOLEAN)   BEGIN
    INSERT INTO Faculty (
        facultyID, firstName, middleName, lastName,
        position, designation, email, ORCID,
        contactNumber, educationalAttainment,
        fieldOfSpecialization, researchInterest,
        isPartOfCIC
    )
    VALUES (
        p_facultyID, p_firstName, p_middleName, p_lastName,
        p_position, p_designation, p_email, p_ORCID,
        p_contactNumber, p_educAttainment,
        p_specialization, p_researchInterest,
        p_isPartOfCIC
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddUser` (IN `p_studentID` VARCHAR(50), IN `p_firstName` VARCHAR(255), IN `p_middleName` VARCHAR(255), IN `p_lastName` VARCHAR(255), IN `p_contactNumber` VARCHAR(15), IN `p_email` VARCHAR(255), IN `p_role` ENUM('Administrator','MCIIS Staff','Faculty','Student'), IN `p_password` VARCHAR(255))   BEGIN
    INSERT INTO User (
        studentID, firstName, middleName, lastName, contactNumber, email, role, password
    ) VALUES (
        p_studentID, p_firstName, p_middleName, p_lastName, p_contactNumber, p_email, p_role, p_password
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DeleteFaculty` (IN `p_facultyID` INT)   BEGIN
    DELETE FROM Faculty WHERE facultyID = p_facultyID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DeleteUser` (IN `p_userID` INT)   BEGIN
    DELETE FROM User WHERE userID = p_userID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_FilterResearch` (IN `p_adviserID` VARCHAR(50), IN `p_program` VARCHAR(100), IN `p_year` YEAR)   BEGIN
    SELECT * FROM vw_ResearchFullInfo
    WHERE 
        (p_adviserID IS NULL OR researchAdviser = p_adviserID)
        AND (p_program IS NULL OR program = p_program)
        AND (p_year IS NULL OR publishedYear = p_year);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SearchResearch` (IN `p_title` VARCHAR(255), IN `p_keyword` VARCHAR(255))   BEGIN
    SELECT * FROM vw_ResearchFullInfo
    WHERE 
    (p_title IS NULL OR researchTitle LIKE CONCAT('%', p_title, '%'))
    OR
    (p_keyword IS NULL OR keywords LIKE CONCAT('%', p_keyword, '%'));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateFaculty` (IN `p_facultyID` VARCHAR(50), IN `p_firstName` VARCHAR(255), IN `p_middleName` VARCHAR(255), IN `p_lastName` VARCHAR(255), IN `p_position` VARCHAR(100), IN `p_designation` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_ORCID` VARCHAR(50), IN `p_contactNumber` VARCHAR(50), IN `p_educAttainment` VARCHAR(255), IN `p_specialization` VARCHAR(255), IN `p_researchInterest` VARCHAR(255), IN `p_isPartOfCIC` BOOLEAN, IN `p_modifiedByUserID` INT)   BEGIN
    DECLARE v_old_firstName VARCHAR(255);
    DECLARE v_old_middleName VARCHAR(255);
    DECLARE v_old_lastName VARCHAR(255);
    DECLARE v_old_position VARCHAR(100);
    DECLARE v_old_designation VARCHAR(100);
    DECLARE v_old_email VARCHAR(255);
    DECLARE v_old_ORCID VARCHAR(50);
    DECLARE v_old_contactNumber VARCHAR(50);
    DECLARE v_old_educAttainment VARCHAR(255);
    DECLARE v_old_specialization VARCHAR(255);
    DECLARE v_old_researchInterest VARCHAR(255);
    DECLARE v_old_isPartOfCIC BOOLEAN;

    -- Fetch current values before update
    SELECT firstName, middleName, lastName, position, designation,
           email, ORCID, contactNumber, educationalAttainment,
           fieldOfSpecialization, researchInterest, isPartOfCIC
    INTO v_old_firstName, v_old_middleName, v_old_lastName, v_old_position,
         v_old_designation, v_old_email, v_old_ORCID, v_old_contactNumber,
         v_old_educAttainment, v_old_specialization, v_old_researchInterest, v_old_isPartOfCIC
    FROM Faculty
    WHERE facultyID = p_facultyID;

    -- Perform the update
    UPDATE Faculty
    SET firstName = p_firstName,
        middleName = p_middleName,
        lastName = p_lastName,
        position = p_position,
        designation = p_designation,
        email = p_email,
        ORCID = p_ORCID,
        contactNumber = p_contactNumber,
        educationalAttainment = p_educAttainment,
        fieldOfSpecialization = p_specialization,
        researchInterest = p_researchInterest,
        isPartOfCIC = p_isPartOfCIC
    WHERE facultyID = p_facultyID;

    -- Log the update if anything changed
    IF v_old_firstName != p_firstName OR
       v_old_middleName != p_middleName OR
       v_old_lastName != p_lastName OR
       v_old_position != p_position OR
       v_old_designation != p_designation OR
       v_old_email != p_email OR
       v_old_ORCID != p_ORCID OR
       v_old_contactNumber != p_contactNumber OR
       v_old_educAttainment != p_educAttainment OR
       v_old_specialization != p_specialization OR
       v_old_researchInterest != p_researchInterest OR
       v_old_isPartOfCIC != p_isPartOfCIC THEN

        INSERT INTO UserFacultyAuditLog (
            modifiedBy,
            targetUserID,
            actionType
        )
        VALUES (
            p_modifiedByUserID,
            p_facultyID,
            'update faculty'
        );
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateUser` (IN `p_userID` INT, IN `p_studentID` VARCHAR(50), IN `p_firstName` VARCHAR(255), IN `p_middleName` VARCHAR(255), IN `p_lastName` VARCHAR(255), IN `p_contactNumber` VARCHAR(15), IN `p_email` VARCHAR(255), IN `p_role` ENUM('Administrator','MCIIS Staff','Faculty','Student'), IN `p_password` VARCHAR(255), IN `p_modifiedByUserID` INT)   BEGIN
    -- Update user
    UPDATE User
    SET 
        studentID = CASE WHEN p_role = 'Student' THEN p_studentID ELSE NULL END,
        firstName = p_firstName,
        middleName = p_middleName,
        lastName = p_lastName,
        contactNumber = p_contactNumber,
        email = p_email,
        role = p_role,
        password = p_password
    WHERE userID = p_userID;

    -- Always log the update
    INSERT INTO UserFacultyAuditLog (
        modifiedBy, targetUserID, actionType
    )
    VALUES (
        p_modifiedByUserID, p_userID, 'update user'
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateResearchEntry` (IN `rID` INT, IN `updaterID` INT, IN `title` VARCHAR(255), IN `adviserID` VARCHAR(50), IN `program` ENUM('Bachelor of Science in Information Technology','Bachelor of Science in Computer Science','Bachelor of Library and Information Science','Master of Library and Information Science','Master in Information Technology'), IN `month` TINYINT, IN `year` YEAR, IN `abstract` TEXT, IN `approvalSheet` LONGBLOB, IN `manuscript` LONGBLOB)   BEGIN
    UPDATE Research
    SET researchTitle = title,
        researchAdviser = adviserID,
        program = program,
        publishedMonth = month,
        publishedYear = year,
        researchAbstract = abstract,
        researchApprovalSheet = approvalSheet,
        researchManuscript = manuscript
    WHERE researchID = rID;
    
    INSERT INTO ResearchEntryLog (
        performedBy, actionType, researchID, timestamp
    ) VALUES (
        updaterID, 'modify', rID, NOW()
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateResearcher` (IN `researcherID` INT, IN `fname` VARCHAR(255), IN `mname` VARCHAR(255), IN `lname` VARCHAR(255), IN `email` VARCHAR(255), IN `newResearchID` INT)   BEGIN
    UPDATE Researcher
    SET firstName = fname,
        middleName = mname,
        lastName = lname,
        email = email,
        researchID = newResearchID
    WHERE researcherID = researcherID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `contact`
--

CREATE TABLE `contact` (
  `contactID` int(11) NOT NULL,
  `userID` int(11) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message` varchar(1000) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `facultyID` varchar(50) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) NOT NULL,
  `position` varchar(100) DEFAULT NULL,
  `designation` varchar(100) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ORCID` varchar(50) DEFAULT NULL,
  `contactNumber` varchar(50) DEFAULT NULL,
  `educationalAttainment` varchar(255) DEFAULT NULL,
  `fieldOfSpecialization` varchar(255) DEFAULT NULL,
  `researchInterest` varchar(255) DEFAULT NULL,
  `isPartOfCIC` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faculty`
--

INSERT INTO `faculty` (`facultyID`, `firstName`, `middleName`, `lastName`, `position`, `designation`, `email`, `ORCID`, `contactNumber`, `educationalAttainment`, `fieldOfSpecialization`, `researchInterest`, `isPartOfCIC`) VALUES
('1', 'Hobert', 'A.', 'Abrigana', 'Instructor', 'BSCS Program Head', 'haabrigana@usep.edu.ph', NULL, '(082) 227-8192 local 249', 'Bachelor of Science in Computer Science (BSCS), Master in Information Management (MIM)', 'Database Management System, Software Application, Development of IS plan', 'Business Data Modeling', 1),
('10', 'Tamara Cher', 'R.', 'Mercado', 'Professor', 'Vice President for Planning and Quality Assurance', 'tammy@usep.edu.ph', '009-0001-9731-9987', '(082) 227-8192 local 249', 'Bachelor of Science in Computer Engineering, Master of Science in Information Science, PhD in Information Technology', 'Information Technology', 'Information Systems, Knowledge Management, eLearning, Digital Processing', 1),
('11', 'Cindy', 'S.', 'Moldes', 'Instructor', 'Faculty Librarian', 'cindy.moldes@usep.edu.ph', NULL, '(082) 227-8192 local 249', 'Bachelor of Science in Library and Information Science, Master of Science in Library and Information Science', 'Library and Information Science', 'Library and Information Science', 1),
('12', 'Nancy', 'S.', 'Mozo', 'Assistant Professor', 'BSIT Program Head', 'nancy.mozo@usep.edu.ph', '0009-0005-5074-4651', '(082) 227-8192 local 249', 'Bachelor of Science in Information Technology, Master of Information Technology', 'Mobile Frameworks and Development, Computer, Networks, Database Management', 'Networking, Web Development, Multimedia Design', 1),
('13', 'Eula Mae', 'N.', 'Templa', 'Instructor', 'Head, College of Technology LRC and STLRC', 'eula.nabong@usep.edu.ph', '0000-0003-1323-9742', '(082) 227-8192 local 249', 'Bachelor of Library and Information Science, Master of Science in Library and Information Science', 'Archives and Preservation, Record Management, Archival Science', 'Cultural Informatics and Heritage, Information Retrieval, Libraries and Librarianship, Organization of Knowledge and Information, Youth Literature, Culture, and Services', 1),
('14', 'Leah', 'O.', 'Pelias', 'Assistant Professor', 'Associate Dean / Graduate School Head', 'leah.pelias@usep.edu.ph', '0000-0002-5279-1268', '(082) 227-8192 local 249', 'Bachelor of Science in Information Technology, Master in Information Technology, Doctor in Business Management specialized in Information Systems', 'Multimedia, Design and Development, Identity Management, Recommender System, Business Technology Management', 'Information Systems, Computer Systems Organization, Computer Systems Application', 1),
('15', 'Ariel Roy', 'L.', 'Reyes', 'Associate Professor', NULL, 'ariel.reyes@usep.edu.ph', '0000-0001-6234-6099', '(082) 227-8192 local 249', 'Bachelor of Science in Computer Engineering, Master’s in Engineering Program - Electronics and Communications Engineering (MEP-ECE), Doctor in Information Technology (DIT)', 'Computer and Information Security, Computer Networks and Administration, Information Systems Management, Computer Engineering', 'Information Security, Cybersecurity, Computer Network and Security, Cryptography, Authentication Systems', 1),
('16', 'Jamal Kay', 'B.', 'Rogers', 'Associate Professor', 'Deputy Director, ICT Unit (SDMD)', 'jamalkay.rogers@usep.edu.ph', '0000-0001-5839-0791', '(082) 227-8192 local 249', 'Bachelor of Science in Electronics Engineering, Master of Engineering Program major in Electronics and Communication Engineering', 'Electronics Engineering, Data Science', 'Predictive Analytics, Machine Learning', 1),
('17', 'Francis Andrain', 'S.', 'Sanico', 'Instructor', 'Head, College of Business Administration - LRC', 'francis.sanico@usep.edu.ph', NULL, '(082) 227-8192 local 249', 'Bachelor of Library and Information Science, Master of Science in Library and Information Science', 'Management of Libraries, Collection Development, Reference, and Information Services, Indexing and Abstracting, Cataloging and Classification', 'Basic IT in Libraries', 1),
('18', 'Vera Kim', 'S.', 'Tequin', 'Instructor', 'Head, Research and Center Manager, Mindanao Center for Informatics and Intelligent Systems (MCIIS)', 'vkstequin@usep.edu.ph', '0009-0006-7409-8989', '(082) 227-8192 local 249', 'Bachelor of Science in Computer Science, Master in Information Management', 'Application Development, Database Management, Programming, Database Design and Development', 'Application Development, Database Management, Programming, Database Design and Development', 1),
('19', 'Hermoso', 'J.', 'Tupas Jr.', 'Instructor', NULL, 'hermoso.tupas@usep.edu.ph', '0000-0003-0353-9987', '(082) 227-8192 local 249', 'Bachelor of Science in Information Technology, Master in Information Technology', 'Software Development', 'Systems and Informatics, Internet of Things, Disaster Risk and Reduction Management', 1),
('2', 'Cheryl', 'R.', 'Amante', 'Instructor', 'Extension Head', 'cramante@usep.edu.ph', '0000-0002-5686-2684', '(082) 227-8192 local 249', 'Bachelor of Science in Computer Science (BSCS), Master in Information Management (MIM)', 'Database Management System, Software Application, Development of IS plan', 'Business Data Modeling', 1),
('20', 'Maureen', 'M.', 'Villamor', 'Professor', NULL, 'maui@usep.edu.ph', '0000-0001-5051-3646', '(082) 227-8192 local 249', 'Bachelor of Science in Computer Science, Master of Science in Information Science, Graduate Diploma in Interaction Design, PhD in Computer Science', 'Computer Science', 'Eye Tracking, Pair Programming, Machine Learning', 1),
('21', 'Philip', 'R.', 'Navarez', 'Instructor', 'PAD and Student Coordinator', 'prnavarez@usep.edu.ph', NULL, '(082) 227-8192 local 249', 'Bachelor of Science in Information Technology', 'Web Application Development', 'Web Application Development, IoT, AI', 1),
('22', 'Josephine', 'D.', 'Magada', 'Administrative Aide I', NULL, 'josephine.magada@usep.edu.ph', NULL, '(082) 227-8192 local 249', NULL, NULL, NULL, 1),
('23', 'Marjorie', 'G.', 'Inocando', 'MCIIS Staff', NULL, 'mginocando@usep.edu.ph', NULL, '(082) 227-8192 local 249', NULL, NULL, NULL, 1),
('24', 'Lloyd', 'C.', 'Merafuentes', 'Laboratory Aide/Technician', NULL, NULL, NULL, '(082) 227-8192 local 249', NULL, NULL, NULL, 1),
('25', 'Kiana', 'G.', 'Macan', 'Technical Staff', NULL, 'kgmacan@usep.edu.ph', NULL, '(082) 227-8192 local 249', NULL, NULL, NULL, 1),
('26', 'Eric', 'P.', 'Ricablanca', NULL, NULL, 'epricablanca@usep.edu.ph', NULL, NULL, NULL, NULL, NULL, 0),
('27', 'Michael Anthony', 'R.', 'Jandayan', NULL, NULL, 'michaelanthony.jandayan@usep.edu.ph', NULL, NULL, NULL, NULL, NULL, 0),
('28', 'Franch Maverick', 'A.', 'Lorilla', NULL, NULL, 'franch@usep.edu.ph', NULL, NULL, NULL, NULL, NULL, 0),
('29', 'Val', 'A.', 'Quimno', NULL, NULL, 'val@usep.edu.ph', NULL, NULL, NULL, NULL, NULL, 0),
('3', 'Annacel', 'B.', 'Delima', 'Instructor', 'Head, CED and SOL Library', 'annacel.delima@usep.edu.ph', '0000-0003-0091-3929', '(082) 227-8192 local 249', 'Bachelor of Library and Information Science (BLIS), Master of Science in Library and Information Science (MSLIS)', 'Library Science', 'Library and Information Science', 1),
('30', 'Maychelle', 'M.', 'Nugas', NULL, NULL, 'maychellenugas@usep.edu.ph', NULL, NULL, NULL, NULL, NULL, 0),
('4', 'Cristina', 'E.', 'Dumdumaya', 'Professor', 'Director, PMMED', 'cedumdumaya@usep.edu.ph', '0000-0003-2148-5003', '(082) 227-8192 local 249', 'Bachelor of Science in Computer Engineering, Master of Arts in Teaching College Physics, Master’s in Information Technology, Graduate Diploma in Computer Science, PhD in Computer Science', 'Artificial Intelligence in Education, Data Science, Digital Image Processing, Software Engineering', 'Machine Learning, Data Mining, Systems Analysis and Design', 1),
('5', 'Gresiel', 'E.', 'Ferrando', 'Assistant Professor', 'BLIS Program Head / MLIS Program Head', 'gresielferrando@usep.edu.ph', NULL, '(082) 227-8192 local 249', 'Bachelor of Arts in Literature, Bachelor of Library and Information Science – earned units, Master of Science in Library and Information Science', 'Information Literacy, Collection Development, Information Resources and Services, Web Technologies, Library Quality Assurance, LIS Education', 'Collection Analysis, Document Management, Research, Indexing, Abstracting', 1),
('6', 'Randy', 'S.', 'Gamboa', 'Professor', 'CIC Faculty Association President', 'rsgamboa@usep.edu.ph', '0000-0002-1098-7772', '(082) 227-8192 local 249', 'Master in Environmental Planning, Master Science in Computer Science, PhD in Educational Leadership', 'Information Systems Leadership and Governance, Educational Technology, Data Privacy and Security', 'Data Privacy and Security, Information Systems', 1),
('7', 'Marvin', 'S.', 'Lagmay', 'Instructor', NULL, 'marvin@usep.edu.ph', '0000-0002-0090-3045', '(082) 227-8192 local 249', 'Bachelor in Computer Technology, Teacher Certificate for Non-Education Professionals', 'Educational Technology, Instructional Design, Interaction Design', 'Educational Technology Integration', 1),
('8', 'Ivy Kim', 'D.', 'Machica', 'Associate Professor', 'Dean', 'ikmachica@usep.edu.ph', '0000-0002-2708-6305', '(082) 227-8192 local 249', 'Bachelor of Science in Computer Science, Master of Science in Information Science, Doctor in Information Technology', 'Computer Science, Information Technology', 'Artificial Intelligence and Internet of Things (IoT)', 1),
('9', 'Michael', 'V.', 'Machica', 'Associate Professor', 'Deputy Director, IPMU', 'michael.machica@usep.edu.ph', NULL, '(082) 227-8192 local 249', NULL, NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `keyword`
--

CREATE TABLE `keyword` (
  `keywordID` int(11) NOT NULL,
  `keywordName` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `keyword`
--

INSERT INTO `keyword` (`keywordID`, `keywordName`) VALUES
(421, '10-Fold Cross-Validation'),
(498, 'Academic Libraries'),
(499, 'Accessibility'),
(500, 'Accessibility Accommodations'),
(50, 'Accident-prone areas'),
(306, 'Accuracy'),
(340, 'Accuracy Improvement'),
(363, 'Accuracy Score'),
(93, 'Accurate treatment'),
(501, 'ADDIE Model'),
(435, 'Adolescents'),
(36, 'Aerofree app'),
(151, 'African Swine Fever'),
(440, 'Age Groups'),
(94, 'Agile development cycle'),
(95, 'Agile software development'),
(134, 'agricultural commodities'),
(460, 'Agricultural Technology'),
(365, 'AIC Value'),
(483, 'Algorithm'),
(282, 'Amazon Dataset'),
(96, 'Amperes'),
(502, 'Analytic'),
(97, 'Android Studio'),
(342, 'Anthropogenic Risks'),
(371, 'Aquaculture Industry'),
(379, 'Aquaculture Management'),
(372, 'Aquatic Products'),
(503, 'Archiving and Metadata Management'),
(98, 'Arduino'),
(99, 'Arduino current sensor'),
(100, 'Arduino IDE'),
(35, 'Arduino-based LPG sensor'),
(359, 'ARIMA'),
(101, 'ARIMA model'),
(475, 'ARIMA-NBeats'),
(75, 'Artificial drying machine'),
(392, 'Artificial Intelligence (AI)'),
(504, 'Assistive Learning Tool'),
(102, 'Assistive technology'),
(26, 'Asthma monitoring'),
(221, 'Augmented Reality'),
(229, 'authentication'),
(104, 'Autism Spectrum Disorder'),
(10, 'Automated detection system'),
(464, 'Automated Trading'),
(103, 'Automatic trap'),
(176, 'awareness'),
(478, 'Backtesting'),
(470, 'Bagging'),
(412, 'Banana Maturity'),
(427, 'Barangays'),
(473, 'Base Learner Models'),
(240, 'Basketball analytics'),
(468, 'Binance'),
(403, 'Binary Cross Entropy'),
(153, 'biosecurity'),
(467, 'Bitcoin'),
(159, 'blacklist database'),
(69, 'Body temperature monitoring'),
(505, 'Book Collection Reports'),
(506, 'Book Ordering and Exhibiting System'),
(471, 'Boosting'),
(245, 'boredom detection'),
(297, 'Boxers'),
(296, 'Boxing'),
(310, 'Boxing Styles'),
(106, 'BPM'),
(105, 'Braille'),
(164, 'brand building'),
(388, 'Breast Cancer'),
(398, 'Breast Mammogram Images'),
(41, 'Breastfeeding culture'),
(40, 'Breastmilk donation'),
(208, 'browser extension'),
(477, 'Buy-Low-Sell-High Strategy'),
(250, 'cacao farming'),
(107, 'Camera'),
(397, 'Cancerous Cell Segmentation'),
(331, 'Carbon Dioxide'),
(507, 'Career Aspirations'),
(420, 'Cavendish Banana'),
(219, 'CCD waste'),
(508, 'Chat'),
(30, 'Chronic disease control'),
(108, 'Circuit breaker'),
(109, 'Circuit overloading'),
(485, 'Classical Statistical Models'),
(355, 'Classification Machine Learning'),
(415, 'Classification Models'),
(19, 'Classroom distractions'),
(249, 'Climate change'),
(110, 'Cloud database'),
(268, 'Cloud Server'),
(309, 'Clustering Model'),
(422, 'CNN-Based Model'),
(241, 'coach decision-making'),
(298, 'Coaches'),
(337, 'Coastal Areas'),
(317, 'Coastal Communities'),
(161, 'coffee startups'),
(63, 'Cognitive and psychomotor activities'),
(509, 'Collection Mapping'),
(111, 'Communicative openness'),
(510, 'Community Engagement'),
(38, 'Community safety awareness'),
(196, 'commuter assistance'),
(511, 'Competency Level'),
(305, 'CompuBox Data'),
(112, 'Conductance'),
(512, 'Conspectus'),
(215, 'Construction waste'),
(277, 'Context'),
(113, 'Contracted Braille (Grade 2)'),
(74, 'Copra drying automation'),
(513, 'Copyright'),
(24, 'Cordova framework'),
(291, 'Coronavirus'),
(292, 'COVID-19'),
(514, 'COVID-19 Pandemic'),
(114, 'Crime density mapping'),
(115, 'Crime incident'),
(271, 'Crime Prevention'),
(515, 'Critical Appraisal'),
(227, 'crop bidding'),
(116, 'Crowdsourced market data'),
(461, 'Cryptocurrency'),
(516, 'Cultural Heritage Preservation'),
(517, 'Curriculum Development'),
(212, 'customer-to-customer marketing'),
(173, 'cybersecurity'),
(496, 'Dashboard Application'),
(320, 'Data Attributes'),
(405, 'Data Augmentation'),
(339, 'Data Collection'),
(139, 'data encryption'),
(172, 'Data privacy'),
(276, 'Data Retrieval'),
(205, 'data security'),
(518, 'Data Visualization'),
(162, 'Davao City'),
(135, 'Davao Food Terminal Complex'),
(488, 'Davao Gulf'),
(519, 'Davao Region Libraries'),
(269, 'DC Motor'),
(117, 'Decibel analysis'),
(182, 'Decision support'),
(385, 'Decision Tree Algorithm'),
(442, 'Decision-Making'),
(167, 'demand forecasting'),
(216, 'demolition recycling'),
(433, 'Dense Layer'),
(520, 'Design Prototype'),
(393, 'Diagnostic Precision'),
(233, 'diary app'),
(402, 'DICE Score'),
(118, 'Digital Image Processing'),
(521, 'Digital Learning Support'),
(522, 'Digital Library System'),
(523, 'Digital Repository System'),
(524, 'Digital Rights Management'),
(177, 'digital security'),
(85, 'Digital trade'),
(166, 'digital transformation'),
(83, 'Direct market'),
(119, 'DO sensors'),
(2, 'Double encoding'),
(5, 'Driver\'s license scanning'),
(430, 'Drug Prevention'),
(451, 'DurI0-an'),
(444, 'Durian'),
(449, 'Durian Diseases'),
(447, 'Durian Industry'),
(452, 'Durio Zibethinus'),
(23, 'Dynamic Systems Development Method (DSDM)'),
(60, 'Dyslexia intervention'),
(273, 'E-commerce'),
(64, 'Early childhood education'),
(457, 'Early Detection'),
(14, 'Economically marginalized students'),
(62, 'Educational learning application'),
(281, 'Elasticsearch'),
(237, 'electricity theft detection'),
(236, 'emotional well-being'),
(187, 'Employee attrition'),
(239, 'energy security'),
(525, 'Enhanced Reading Program'),
(465, 'Ensemble Learning'),
(220, 'environmental sustainability'),
(120, 'ESP32-cam'),
(121, 'ESP8266'),
(469, 'Ethereum'),
(209, 'Event planning'),
(526, 'Evidence-Based Medicine'),
(18, 'Executable scripts'),
(263, 'Eye Blink Detection'),
(122, 'Eye blink sensor'),
(307, 'F1-Score'),
(261, 'Facial Detection'),
(264, 'Facial Landmark'),
(266, 'Facial Recognition'),
(529, 'Fair Use'),
(290, 'Fake News'),
(286, 'False Positives'),
(89, 'Farmer assistance'),
(322, 'Feature Engineering'),
(354, 'Feature Importance'),
(323, 'Feature Scaling'),
(321, 'Feature Selection'),
(527, 'Feature Suggestions'),
(146, 'feedback system'),
(528, 'Filipino Language for Foreign Students'),
(389, 'Filipino Women'),
(123, 'Filtration media'),
(462, 'Financial Investment'),
(381, 'Financial Loss'),
(407, 'Fine-Tuning'),
(34, 'Fire prevention'),
(352, 'Fish Catch Forecasting'),
(367, 'Fish Catch Seasonality'),
(8, 'Fish disease'),
(9, 'Fish farm management'),
(374, 'Fish Health'),
(124, 'Fish mortality'),
(486, 'Fish Production'),
(345, 'Fish Shoals'),
(341, 'Fisheries'),
(370, 'Fishing Community'),
(497, 'Fishing Efficiency'),
(487, 'Fishing Techniques'),
(283, 'Flask'),
(125, 'Flood levels'),
(126, 'Flood monitoring'),
(127, 'Food donors'),
(168, 'food retailers'),
(128, 'Food waste awareness'),
(129, 'Food waste prevention'),
(366, 'Forecasting'),
(142, 'fraud prevention'),
(130, 'Freshwater'),
(131, 'Freshwater environment'),
(425, 'Fruit Classification'),
(246, 'frustration analysis'),
(530, 'Functionality Testing and User Evaluation'),
(253, 'future climate projections'),
(132, 'Fuzzy logic method'),
(133, 'Galvanic Skin Response (GSR)'),
(174, 'game-based learning'),
(33, 'Gas leak detection'),
(439, 'Gender Ratio'),
(29, 'Geo-tagging'),
(437, 'Geographic Maps'),
(489, 'Geospatial Data Science'),
(218, 'geotagging'),
(454, 'GLCM + UNet'),
(226, 'Google API'),
(338, 'Google Earth'),
(185, 'Google Safe Browsing'),
(43, 'GPS-based donor matching'),
(436, 'Graphical Analysis'),
(531, 'Graphical Representation of Library Resources'),
(330, 'Greenhouse Gases'),
(386, 'GridSearchCV'),
(414, 'Growers'),
(262, 'Haar Cascade'),
(257, 'Hardware'),
(429, 'Health Care Programs'),
(532, 'Health Sciences Librarian'),
(28, 'Heart rate tracking'),
(73, 'Heat protection'),
(68, 'Heatstroke and heat exhaustion'),
(67, 'Heatwave prevention'),
(346, 'High Cost'),
(533, 'Higher Education'),
(534, 'Historical and Cultural Artifacts'),
(300, 'Historical Data Analysis'),
(141, 'hotel industry'),
(190, 'HR management'),
(48, 'Human error in accidents'),
(373, 'Human Population Growth'),
(535, 'Human Resource Capability'),
(293, 'Hybrid Algorithm'),
(396, 'Hybrid Model'),
(22, 'Hybrid voice distribution'),
(324, 'Hyperparameter Tuning'),
(406, 'Hyperparameters'),
(206, 'identity protection'),
(143, 'identity theft'),
(265, 'Image Capture'),
(92, 'Improved crop yield'),
(536, 'Inclusive Libraries'),
(537, 'Inclusive Library Services'),
(538, 'Indexinator'),
(358, 'India'),
(539, 'Information and Computing Students'),
(540, 'Institutional Digital Repository'),
(91, 'Integrated pest management'),
(223, 'intellectual disability'),
(541, 'Intellectual Property'),
(278, 'Intent'),
(542, 'Interactive Learning System'),
(543, 'Interactive Resource Sharing Platform'),
(336, 'Interactive Visualization'),
(493, 'Interpolation Models'),
(401, 'Intersection Over Union (IOU)'),
(165, 'inventory management'),
(481, 'Investment Returns'),
(59, 'Ionic Framework and Java'),
(148, 'IoT'),
(456, 'IoU Score'),
(194, 'jeepneys'),
(234, 'journaling'),
(304, 'K-Means Clustering'),
(247, 'keystrokes'),
(445, 'King of Fruits'),
(384, 'KNN (K-Nearest Neighbors)'),
(202, 'KNN Algorithm'),
(252, 'land suitability'),
(13, 'Laptops and smartphones'),
(200, 'Leaf Color Chart'),
(61, 'Learning disability'),
(544, 'Librarian Competencies'),
(545, 'Librarians\' Preferences'),
(546, 'Library Accommodations'),
(547, 'Library and Information Science'),
(548, 'Library Collection Assessment'),
(549, 'Library Marketing'),
(550, 'Library Modifications'),
(551, 'Library Online Access'),
(552, 'Library Programs'),
(553, 'Library Resources'),
(554, 'Library Service Delivery'),
(555, 'Library Service Design Model'),
(556, 'Library Services'),
(56, 'Live video feed'),
(557, 'Lived Experiences'),
(428, 'Local Government'),
(424, 'Locally Sourced Dataset'),
(347, 'Low Profit'),
(476, 'LR-NBeats'),
(31, 'Lung function monitoring'),
(152, 'machine learning'),
(382, 'Machine Learning Models'),
(156, 'malicious URLs'),
(390, 'Mammography'),
(558, 'Mandaya-English Translation'),
(163, 'market access'),
(413, 'Marketability'),
(559, 'Marketing Strategies'),
(217, 'marketplace'),
(301, 'Match Prediction'),
(327, 'Mean Absolute Error (MAE)'),
(328, 'Mean Squared Error (MSE)'),
(231, 'Mental health'),
(235, 'mental illness'),
(332, 'Methane'),
(42, 'Milk-sharing platform'),
(560, 'Mixed-Methods Research'),
(49, 'Mobile alert system'),
(197, 'mobile application'),
(20, 'Mobile device usage'),
(16, 'Mobile IDE'),
(66, 'Mobile learning technology'),
(158, 'mobile security'),
(90, 'Mobile solution'),
(55, 'Mobile-based application'),
(408, 'Model Accuracy'),
(417, 'Model Efficiency'),
(325, 'Model Performance'),
(561, 'Modified Iterative and Incremental Development (IID)'),
(562, 'Modified Rapid Application Development (RAD)'),
(76, 'Moisture content monitoring'),
(12, 'Mortality rate monitoring'),
(45, 'Mother and child health'),
(260, 'Motion Detection'),
(254, 'Motorcycle Theft'),
(248, 'mouse movements'),
(563, 'Multi-Channel Support (Chat, Email, Web Form)'),
(474, 'Naïve-LR-NBeats'),
(279, 'Natural Language Processing (NLP)'),
(224, 'navigation'),
(400, 'Nested UNet (UNet++)'),
(251, 'neural network modeling'),
(432, 'Neural Networks'),
(284, 'Ngrok'),
(199, 'nitrogen fertilization'),
(86, 'No middlemen'),
(343, 'Oceanic Destruction'),
(17, 'OCR technology'),
(564, 'ODILO database'),
(565, 'Offline Translation System'),
(566, 'Online Library Book Fair'),
(567, 'Online Library Services'),
(140, 'Online reservation'),
(568, 'Online Survey'),
(289, 'Ontologies'),
(313, 'Outboxer'),
(409, 'Overfitting'),
(81, 'Palay bidding'),
(411, 'Pathological Ground Truth Masks'),
(47, 'Pedestrian and driver safety'),
(72, 'Peltier module technology'),
(314, 'Performance Improvement'),
(204, 'Personal aliasing'),
(569, 'Personal Skill Set'),
(377, 'pH Level'),
(295, 'Philippines'),
(184, 'phishing attacks'),
(570, 'PHP and MySQL-Based System'),
(149, 'pig cough detection'),
(571, 'PLAI-DRLC Library Consortium'),
(426, 'Población District'),
(448, 'Post-Harvest Losses'),
(44, 'Postpartum support'),
(349, 'Potential Fishing Zones (PFZs)'),
(404, 'Pre-Processing'),
(333, 'Prediction'),
(387, 'Prediction Models'),
(188, 'predictive analytics'),
(318, 'Predictive Model'),
(351, 'Predictors'),
(179, 'Privacy Impact Assessment'),
(443, 'Proactive Measures'),
(288, 'Product Categorization'),
(572, 'Professional Core Competency'),
(394, 'Prognosis'),
(243, 'Programming education'),
(15, 'Programming logic'),
(255, 'Property Crime'),
(573, 'Public Library'),
(574, 'Public School Libraries'),
(192, 'Public transportation'),
(183, 'QR code security'),
(79, 'Quality control in copra production'),
(575, 'Quantitative Descriptive Study'),
(335, 'R Shiny'),
(326, 'R-Squared Score'),
(65, 'R.A.S.E. Model'),
(362, 'Random Forest'),
(189, 'Random Forest Algorithm'),
(319, 'Random Forest Regression'),
(37, 'Rapid Application Development (RAD)'),
(259, 'Raspberry Pi'),
(145, 'ratings'),
(576, 'Reading Comprehension'),
(160, 'real-time detection'),
(57, 'Real-time location tracking'),
(71, 'Real-time mobile application'),
(154, 'real-time monitoring'),
(39, 'Real-time notifications'),
(193, 'real-time tracking'),
(25, 'Real-time voice broadcasting'),
(431, 'Rehabilitation'),
(577, 'Remote Access'),
(578, 'Ren\'py Visual Novel Engine'),
(399, 'ResNet-152'),
(419, 'ResNet-18 Architecture'),
(368, 'Resource Management'),
(579, 'Resource Sharing'),
(150, 'respiratory diseases'),
(170, 'restock planning'),
(455, 'RGB + GLCM + UNet'),
(453, 'RGB + UNet'),
(201, 'RGB color extraction'),
(198, 'Rice farming'),
(82, 'Rice law impact'),
(87, 'Rice pest detection'),
(181, 'Risk assessment'),
(46, 'Road traffic accidents'),
(329, 'Root Mean Squared Error (RMSE)'),
(171, 'sales data analysis'),
(360, 'Salinity'),
(580, 'School Library'),
(84, 'Scrum method'),
(213, 'SCRUM methodology'),
(361, 'Sea Chlorophyll'),
(350, 'Sea Features'),
(316, 'Sea Level Rise'),
(492, 'Sea Surface Chlorophyll-a Concentration (SSCC)'),
(490, 'Sea Surface Temperature (SST)'),
(287, 'Search Accuracy'),
(353, 'Seasonal Fish Catch Behavior'),
(195, 'seat vacancy'),
(356, 'Secondary Data'),
(207, 'secure login'),
(137, 'security'),
(270, 'Security System'),
(391, 'Self-Examinations'),
(232, 'self-monitoring'),
(280, 'Semantic Search Engine'),
(275, 'Semantic Searching'),
(178, 'serious games'),
(214, 'service promotion'),
(459, 'Severity Index Estimation'),
(495, 'Simple Additive Weighting (SAW)'),
(169, 'Simple Moving Average'),
(225, 'simulation-based learning'),
(479, 'Simulations'),
(581, 'Skill Assessment'),
(312, 'Slugger'),
(80, 'Small-scale coconut farmers'),
(228, 'small-scale farmers'),
(238, 'smart meter'),
(32, 'Smartphone sensors'),
(210, 'SMEs'),
(155, 'Smishing'),
(230, 'SMS OTP'),
(157, 'SMS phishing'),
(256, 'SNAPDRIVE'),
(582, 'Social Acceptability'),
(348, 'Socio-Economic Status'),
(258, 'Software'),
(446, 'Southeast Asia'),
(267, 'Sparse Local Binary Pattern Histogram'),
(583, 'Special Needs Patrons'),
(584, 'Speech, Photo, and Audio Integration'),
(51, 'Speed limit awareness'),
(242, 'sports technology'),
(147, 'SSL certification'),
(472, 'Stacking'),
(438, 'Statistical Reports'),
(88, 'Stem borer & leaf blast'),
(378, 'Stress in Fish'),
(244, 'student engagement'),
(585, 'Student Motivation'),
(434, 'Substance Abuse'),
(395, 'Survival Rates'),
(383, 'SVM (Support Vector Machine)'),
(303, 'SVM Algorithm'),
(311, 'Swarmer'),
(480, 'Swing Trading'),
(586, 'System Development Life Cycle (SDLC) - Spiral Model'),
(587, 'System Development Life Cycle (SDLC) - Waterfall Model'),
(588, 'TAM'),
(175, 'teenagers'),
(376, 'Temperature'),
(589, 'Text, Photo, and Audio Integration'),
(491, 'Thermal Front'),
(590, 'Three-Phase Development Strategy'),
(364, 'Threshold Values'),
(466, 'Trading Bot'),
(484, 'Trading Strategies'),
(274, 'Traditional Keyword-Based Search'),
(78, 'Traditional vs. artificial drying'),
(1, 'Traffic citations'),
(53, 'Traffic congestion'),
(58, 'Traffic enforcement technology'),
(6, 'Traffic management'),
(52, 'Traffic safety technology'),
(3, 'Traffic ticket issuance'),
(54, 'Traffic violations'),
(299, 'Training Plans'),
(416, 'Training Time'),
(136, 'transaction tracking'),
(418, 'Transfer Learning'),
(441, 'Trend Analysis'),
(294, 'Twitter'),
(138, 'Two-Factor Authentication'),
(7, 'Ultrasonic sensor'),
(308, 'Unbalanced Dataset'),
(369, 'Uncertainties'),
(410, 'Underfitting'),
(494, 'Universal Kriging'),
(591, 'University Museum'),
(592, 'University of Southeastern Philippines'),
(593, 'University of the Immaculate Conception'),
(423, 'Unseen Data'),
(594, 'User Acceptance Level'),
(595, 'User Acceptance Testing and Evaluation'),
(144, 'user verification'),
(596, 'Utilization'),
(597, 'UVDesk and MySQL Integration'),
(186, 'VirusTotal API'),
(357, 'Visayan Sea'),
(450, 'Visual Inspection'),
(191, 'visualization'),
(598, 'Vocational Education'),
(21, 'VOIP-enabled application'),
(463, 'Volatility'),
(11, 'Water contamination'),
(375, 'Water Quality'),
(272, 'Waterfall Methodology'),
(222, 'wayfinding'),
(70, 'Wearable cooling device'),
(27, 'Wearable device'),
(344, 'Weather Changes'),
(203, 'weather forecasting'),
(285, 'Web Application'),
(599, 'Web Portal Design'),
(180, 'web-based assessment tool'),
(600, 'Web-Based Indexing Tool'),
(77, 'Web-based monitoring system'),
(211, 'web-based platform'),
(4, 'Web-based record system'),
(601, 'Web-Based Support Service Ticketing System'),
(458, 'Wilcoxon Signed Rank Test'),
(482, 'Win-Loss Ratios'),
(302, 'Winning Conditions'),
(315, 'Winning Tactics'),
(334, 'Year 2100'),
(380, 'Yield Reduction'),
(602, 'Youth Development');

-- --------------------------------------------------------

--
-- Table structure for table `keywordsearchlog`
--

CREATE TABLE `keywordsearchlog` (
  `searchLogID` int(11) NOT NULL,
  `keywordID` int(11) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `searchTimestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `panel`
--

CREATE TABLE `panel` (
  `panelID` int(11) NOT NULL,
  `facultyID` varchar(50) DEFAULT NULL,
  `researchID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `research`
--

CREATE TABLE `research` (
  `researchID` int(11) NOT NULL,
  `uploadedBy` int(11) DEFAULT NULL,
  `researchTitle` varchar(255) NOT NULL,
  `researchAdviser` varchar(50) DEFAULT NULL,
  `program` enum('Bachelor of Science in Information Technology','Bachelor of Science in Computer Science','Bachelor of Library and Information Science','Master of Library and Information Science','Master in Information Technology') DEFAULT NULL,
  `publishedMonth` tinyint(4) DEFAULT NULL,
  `publishedYear` year(4) DEFAULT NULL,
  `researchAbstract` text DEFAULT NULL,
  `researchApprovalSheet` longblob DEFAULT NULL,
  `researchManuscript` longblob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `research`
--

INSERT INTO `research` (`researchID`, `uploadedBy`, `researchTitle`, `researchAdviser`, `program`, `publishedMonth`, `publishedYear`, `researchAbstract`, `researchApprovalSheet`, `researchManuscript`) VALUES
(1, 2, 'COPTURE: AUTOMATION OF TRAFFIC TICKET ISSUANCE USING PDF417 BARCODE SCANNER', '7', 'Bachelor of Science in Information Technology', 5, '2020', 'Double encoding of traffic citations became a significant problem for the Apprehension Unit in the City Transport and Traffic Management Office. Every day, they have to encode the endorsed traffic tickets into an excel sheet, and they have even experienced a month\'s worth of backlog due to the increase in citation tickets. CopTure was developed to solve the agency\'s problem in double encoding and to enhance the process of issuing a traffic ticket. The researchers designed and developed a mobile application that will automate the issuance of traffic citations by scanning and obtaining data from a driver\'s license. They also developed a web-based record system that will allow authorized employees to monitor traffic citations. To achieve this, the researchers followed the Rapid Application Development method. The researchers conducted an interview at the CTTMO to thoroughly understand the problem and established a set of objectives to solve it. The objectives served as a guide in implementing all the features needed to complete the project. The mobile application and web-based system went through rapid prototyping and iterative delivery until all the objectives were met. A validation test was also conducted to ensure that both the application and the system are fully functioning. Overall, this project paints a picture of the future traffic ticketing system and encourages the acceptance of technology as a new way of implementing traffic management. The project would not be feasible without the unwavering commitment and cooperation that each of the researchers showed to successfully finish the project. The whole project might be finished and thrived, but it is still open for future improvements and additional features based on users\' future needs.', NULL, NULL),
(2, 2, 'FINnish Na: AN IOT APPLICATION SYSTEM FOR FISH MORTALITY RATE MONITORING USING ULTRASONIC SENSORS', '10', 'Bachelor of Science in Information Technology', 5, '2020', 'Fish mortality is a natural occurrence that can happen when cultivating a fish farm. It is undeniable that fish deaths transpire now and then. Problems that contribute to fish mortality include weather that causes oxygen depletion, fish disease, as well as dead fish/es itself, among other things. These dead fishes, if not retrieved and left to rot, pose an even greater threat within a farm, especially when these carcasses sink instead of floating. If cultivators aren\'t careful enough, these rotting fish may release harmful chemicals that can contaminate the fishpond\'s water and compromise other healthy fishes. An interview was conducted among fish farmers in Matina Aplaya to find out how they address such issues. Collectively, they responded by having scheduled underwater checking for dead fish that sank at the bottom of the pond, which is time-consuming and inefficient. Hence, the proponents developed a system, FINnish Na, to reduce and address this specific fish farmer problem. Primarily using an ultrasonic sensor placed at the bottom of a basin, the proponents have simulated a miniature fishpond. When the sensor detects the presence of dead fish in the pond, the system will notify fish farmers through a notification in the app. The app can also provide the mortality rate of the fish and gives a daily and monthly report of the number of dead fish that the fish farm has so far. After testing the system for four (4) days, split between two pond conditions: with live fish and without, the proponents made comparisons of each day\'s result. It was evident that there was variability among the results. Significantly, however, there is a slight inconsistency of sensor readings when live fishes are present and if they are constantly moving. Based on the results of this study, the proponents recommend that an advanced type of ultrasonic sensor is utilized, as well as improve the sensor detection function, where constant interferences such as fish movement are ignored.', NULL, NULL),
(3, 2, 'CODE CAPTURE: MOBILE IDE FOR ENHANCING PROGRAMMING LOGIC BY CAPTURING PSEUDOCODES INTO READILY EXECUTABLE SCRIPTS USING OCR TECHNOLOGY', '26', 'Bachelor of Science in Information Technology', 7, '2020', 'Laptops and smartphones are used by almost everyone in this current era. These devices are popularly used at home, school, and work environments. Students, in particular, prefer using laptops because they are more efficient to be used for notetaking, writing, editing, and studying. Having said that, several economically marginalized students may not experience the convenience that these devices could offer. This financial instability could be a big issue especially for technology-related students since laptops play a crucial role in learning the basics of computer programming. Therefore, the researchers have conducted this study, \"Code Capture: Mobile IDE for Enhancing Programming Logic By Capturing Pseudocodes Into Readily Executable Scripts Using OCR Technology\", a solution that could improve the current situation of students with financial difficulties of providing themselves laptops. This study created a dedicated mobile application to be used by students who have computer-related courses. It could serve as a compiler and decoder for computer programs. Following a Rapid Application Development (RAD) model, we used an effective and fair design to cater to the needs of different users.', NULL, NULL),
(4, 2, 'HEEDER: A VOIP-BASED HYBRID MOBILE APPLICATION FOR CLASSROOM INSTRUCTION DELIVERY', '12', 'Bachelor of Science in Information Technology', 6, '2020', 'Two of the most common sources of distractions inside the classroom include noise and uncontrollable use of technology, specifically mobile devices, among students. Studies have shown that noise has a direct negative effect on student learning with language and reading development particularly affected. Moreover, technology is one of the factors which negatively affects the learning process of the students. The usage of mobile phones causes disturbance in the classroom affecting academic performances. However, due to the proliferating use of technology in classrooms, the researchers used this opportunity to utilize rather than restrict the students in using mobile devices as an effective tool for learning. Heeder is a mobile VOIP-enabled and hybrid voice distribution application that aims to provide an alternative tool for classroom instruction delivery. The purpose of this study was to provide convenience to learners who are easily distracted caused by noise and extensive use of mobile devices. Through the said application, teachers and students had the opportunity to better communicate with each other. The application established connections within users through creating channels, broadcasts real-time voice data, and monitors student users on the teachers\' side. Dynamic Systems Development Method was used to allow the researchers to create the application which requires flexible requirements in early phases. Upon fulfillment of this project, the proponents were able to develop a hybrid mobile application using Cordova framework that provides a tool for students in promoting learning through intent listening. For obvious reasons, network speed has an impact on the voice data quality of the application. Thus, the proponents have recommended creating an API that would not require the use of the internet for the reliability of voice data and localize the use of the application inside the campus. However, the application did not guarantee a total noise-free environment rather it enhanced the voice; thus, studies must consider eliminating the unpleasant noise especially in classroom settings.', NULL, NULL),
(5, 2, 'SMARTASTH: A MOBILE APPLICATION FOR REAL-TIME MONITORING OF ASTHMATIC PATIENTS USING WEARABLE DEVICE FOR HEART RATE AND GEO-TAGGING', '16', 'Bachelor of Science in Information Technology', 6, '2020', 'Asthma is a lifetime chronic disease taking off to anomalous lung functions and difficulty in breathing. Asthma influences more than 300 million individuals around the world. Asthmatic patients have trouble breathing and airflow obstruction caused by inflammation and constriction of the airways. Home monitoring of lung function is the preferred course of action to give physicians and asthma patients a chance to control the disease jointly. Thus, it is important to develop accurate and efficient asthma monitoring devices that are easy for patients to use. \n\nObserving on our own is the preliminary course of action to monitor, treat, and control chronic disease. Self-checking mutually causes doctors and patients to have authority over ongoing observing and to give on-time treatment. A classical spirometry test is currently the preeminent way to diagnose the severity of lung functions and their response to treatment, but it requires supervision. Currently, portable devices are available to monitor Peak Expiratory Flow, but it is expensive and inconvenient to use. \n\nPrediction of severe exacerbation triggered by uncontrolled asthma is highly important for patients suffering from asthma, as avoiding maleficent symptoms that could need special treatment or even hospitalization, can protect patients from the aftereffects of bronchodilation. As of late, there has been an increased use of wireless sensor networks and embedded systems in the medical sector. Healthcare providers are now attempting to use these devices to monitor patients in a more accurate and automated way. This would permit healthcare providers to have up-to-date patient information without physical interaction, allowing for more accurate diagnoses and better treatment. \n\nIn this study, we present work in progress on an application scenario where a smartphone is used to detect and quantitatively index early signs of asthma attack triggers. Here, the embedded microphone in the smartphone records the user\'s breath sound while motion-sensor-heart rate changes. \n\nThis will overcome the shortcomings of the existing system by home monitoring the lung functions and patient\'s environmental parameters over time without any supervision as in standard spirometry tests. Our design and results show that using only built-in sensors in smartphones, mobile phones can sufficiently and reliably monitor the health status of patients with long-term respiratory conditions such as asthma.', NULL, NULL),
(6, 2, 'AEROFREE: AN IOT-ENABLED LPG LEAK DETECTION SYSTEM WITH PROXIMITY MAP', '27', 'Bachelor of Science in Information Technology', 4, '2020', 'This study was conducted to prevent unnoticed gas leaks that might cause fire, increase awareness to the community, and help quicken the response time of the local fire department. The study drew attention to the fact that many fire incidents involving gas leaks resulted in massive explosions, human injuries, and even death. Furthermore, this research reveals that proper awareness, information, and prompt action are crucial to prevent such incidents. Aerofree app is a mobile application that uses an Arduino-based LPG leak sensor to help users detect dangerous levels of propane and butane gases. It notifies household owners and nearby households of a possible gas leak in the area. The Rapid Application Development (RAD) model was adopted, enabling early system integration and immediate troubleshooting. The application successfully activates actuators when LPG levels are high, sends alerts via SMS and app notifications, and provides a proximity heat map within a 100-meter radius of the device. This contributes to community safety and fire prevention.', NULL, NULL),
(7, 2, 'IMONGMOTHER: AN ANDROID-BASED COMMUNITY BREAST MILK SHARING APPLICATION USING GEOTAGGING AND CROWDSOURCING IN DAVAO CITY', '7', 'Bachelor of Science in Information Technology', 5, '2020', 'In the Philippines, statistics have shown that many women are unable to exclusively breastfeed for six months due to insufficient breastmilk supply, while others produce excess. This study aims to connect these two groups through a mobile application that facilitates breastmilk sharing. The platform enables women with surplus milk to post donations, while those in need can request nearby donors using GPS filtering. The proponents utilized the Rapid Application Development (RAD) model to ensure timely system delivery and integration. The app fosters a breastfeeding culture, promotes maternal support, and helps alleviate postpartum challenges. The system met its objectives and opens opportunities for future improvements.', NULL, NULL),
(8, 2, 'CAREFUL: A MOBILE-BASED ROAD ALERT APPLICATION FOR ROAD SAFETY PRECAUTIONS USING GEOFENCING API', '12', 'Bachelor of Science in Information Technology', 6, '2020', 'Road traffic accidents are rising due to increased vehicle usage and various human errors such as jaywalking, overspeeding, and distracted walking or driving. This project addresses pedestrian and driver safety through a mobile application that utilizes geofencing to send real-time alerts about nearby pedestrian lanes and accident-prone areas. It encourages safer behavior among both pedestrians and drivers. Drivers receive warnings near intersections, blind curves, and crowded zones, promoting speed control and attentiveness. The application contributes to road safety awareness and highlights the potential of mobile technology in minimizing accidents and improving public safety.', NULL, NULL),
(9, 2, 'TRAVIL: A MOBILE APPLICATION COMPLAINT TOOL FOR TRAFFIC VIOLATIONS AND INCIDENTS USING LIVE VIDEO FEED AND REAL-TIME LOCATION TRACKING', '26', 'Bachelor of Science in Information Technology', 6, '2020', 'The rapidly increasing number of vehicles also raises traffic congestion that impacts the quality of life and productivity in every developing country. Aside from that, it also increases the number of traffic violations and traffic incidents. CCTVs and traffic enforcers are no longer enough to manage this underlying problem because there are too few traffic enforcers for the number of vehicles. The purpose of this study is to create a mobile-based application that will help traffic enforcers in dealing with traffic violations and incidents happening around Davao City. A mobile-based application was made that will serve as a complaint tool for traffic enforcers using live video feed and real-time location tracking. Live video feed was used to help the traffic enforcer to immediately validate the report and real-time location tracking to guide traffic enforcers to reach the location of the violator or the area of the incident. This application, implemented in the android platform using Visual Studio Code, Ionic Framework, and Java, allows the proponents to achieve the goal. Keywords: Traffic congestion, Traffic violations, Mobile-based application, Live video feed, Real-time location tracking, Traffic enforcement technology, Ionic Framework and Java', NULL, NULL),
(10, 2, 'LEARNDYS: AN EDUCATIONAL LEARNING APPLICATION FOR DYSLEXIC CHILDREN USING R.A.S.E. MODEL', '7', 'Bachelor of Science in Information Technology', 12, '2020', 'One type of learning disability caused by a neurological disorder is dyslexia and the lack of intervention for dyslexic students is one of the major reasons why learners are frequently neglected and judged in society particularly by their peers. The importance of early intervention is vital. Although kids indeed learn in different ways and at different rates, it seems individuals with dyslexia are pretty much bom with special conditions in their brains. The earlier they receive an intervention, the higher the chance they may become better at learning words and reading. LearnDys was developed to help solve the problem of a lack of early intervention. The researchers designed and developed an educational learning application that provides cognitive and psychomotor activities intended for ages 3 to 6. The specific activities given by the application are only helpful for children with this condition. To achieve this, the researchers used the R.A.S.E. Model based on what is considered essential for ensuring quality in learning by using mobile applications to enhance the learning ability and ensure the entire achievement of the learning outcome. Based on the activities given, cognitive and psychomotor is part of the learning objective. Cognitive as the most common domain in learning that deals with the intellectual side, and psychomotor as a domain that focuses on motor skills and action requires physical coordination. The objective serves to complete and achieve the project and ensure that all the features must be present in the application. The researchers also seek help from the College of Education expert that handles children with this condition. Overall, this project would help the target users and address the problem with the help of technology. The project would not have been attainable without the researchers\' cooperation, hard work, and dedication. We hope that this project will improve more in the future and be able to deploy successfully. Keywords: Dyslexia intervention, Learning disability, Educational learning application, Cognitive and psychomotor activities, Early childhood education, R.A.S.E. Model, Mobile learning technology', NULL, NULL),
(11, 2, 'PACOOL: A WEARABLE DEVICE PROVIDING COOLING EFFECT TO PREVENT HEAT-RELATED ILLNESSES USING PELTIER MODULE', '26', 'Bachelor of Science in Information Technology', 6, '2020', 'An extreme heat wave is dangerous to people who are exposed directly to the heat, especially to elderly people who slowly absorb heat in the body that may lead to heatstroke. According to the World Health Organization, 70,000 people died in Europe because of the June-August event in 2003 and in 2010, 56,000 excess deaths occurred during a 44-day heat wave in the Russian Federation. Heat exhaustion may lead to heatstroke. If one has symptoms of heat exhaustion, it is necessary to get inside or find a cool shady place to cool down. Prevention is always better than cure. The fastest and most effective way of alleviating heatstroke or heat exhaustion is cooling the whole body. With the primary solution in preventing heatstroke, PaCool aims to develop a device that provides a cooling effect to help the users cool their bodies whenever their body temperature increases above normal body temperatures caused by the heat waves and a real-time mobile application that lets the user monitor their body temperature from time to time. The device of this project is attached in the wrist and the uppermost of the arm near the armpit where the temperature sensor can detect the body temperature of the user. The device located in the wrist releases a cooling sensation that enables to cool the whole body. The researchers used the Peltier module to produce cooling effects. Keywords: Heatwave prevention, Heatstroke and heat exhaustion, Body temperature monitoring, Wearable cooling device, Real-time mobile application, Peltier module technology, Heat protection', NULL, NULL),
(12, 2, 'COPIoT: A Web Based Monitoring System for Automated Copra Drying Process', '28', 'Bachelor of Science in Information Technology', 6, '2020', 'Copra is produced using sun drying or smoke methods traditionally done by small-scale coconut farmers, and both methods of drying have adverse effects on the quality of copra. The study aims to aid the copra industry by producing an artificial drying machine for copra, to automate the drying process and gather real-time data. The web-based monitoring system integrated with the drying machine visualizes the drying process of copra, which guarantees the quality of copra produced by small-scale coconut farmers.', NULL, NULL),
(13, 2, 'E-MONGANI: A Mobile Application for Marketing Rice Through a Bidding System', '7', 'Bachelor of Science in Information Technology', 6, '2022', 'This research presents an e-commerce mobile application for palay marketing that bridges the gap between local farmers and buyers. It includes a bidding feature that allows farmers to set a minimum price for their palay, helping them to accumulate fair value for their product. The system provides a strategy for rice farmers to sell their product directly to buyers, circumventing middlemen, and ensuring higher profit margins.', NULL, NULL),
(14, 2, 'DamageXpert: A Mobile-Based Application for the Identification of Damages Caused by Rice Leaf Blast and Rice Stem Borer with Control Measures', '27', 'Bachelor of Science in Information Technology', 7, '2022', 'The DamageXpert mobile application helps farmers detect and identify damages caused by rice leaf blast and rice stem borer. It aids farmers in differentiating the symptoms and managing these infestations through Integrated Pest Management (IPM). This tool provides a practical and efficient solution to minimize crop damage and improve rice yield by offering accurate pest control measures.', NULL, NULL),
(15, 2, 'QualitAire: An IoT-Based Air Quality Monitoring System with Forecasting Capability Through Time Series Model Analysis', '2', 'Bachelor of Science in Information Technology', 6, '2022', 'Air pollution is defined as contamination of the indoor or outdoor environment by any chemical, physical, or biological agent that alters the inherent properties of the atmosphere. Particulate matter, carbon monoxide, ozone, nitrogen dioxide, and sulfur dioxide are all serious public health concerns. Air pollution, both indoor and outdoor, causes respiratory and other illnesses and is a major cause of morbidity and mortality. This study aims to create a system with forecasting capability by constantly updating the current air concentrations and predicting the next numbers of the Air Quality Index or AQI. This study intends to make practical and effective use of the Internet of Things (IoT) concept. This study consists of a device with sensors, namely, DSM501A PM Sensor, MQ7 CO Sensor, and MQ131 03 Sensor. A mobile-responsive web application and a cloud database. These sensors will be connected to the Arduino UNO microcontroller and then to the NODEMCU WiFi module. The microcontroller will send the data from the sensors to the cloud database. The data stored on the cloud database can be viewed on the mobile-responsive web application. This provides accurate time information on the actual air concentrations and their AQI, along with a table of the latest data of its previous readings. As shown in the line graph, the prediction feature can be observed at every 30-minute interval. Using the Time Series Model, particularly the ARIMA model of getting prediction. Lastly, the system has an archive feature so that all the data sent by the device can be seen for future reference.', NULL, NULL),
(16, 2, 'DESIGN AND DEVELOPMENT OF A MOBILE-BASED MALICIOUS URL DETECTION APPLICATION', '19', 'Bachelor of Science in Information Technology', 6, '2022', 'Year over year, communication tools such as social media are highly targeted by cybercriminals. Their schemes include the distribution of malicious URLs. A malicious URL is a URL that facilitates scams, frauds, and a cyberattack. By clicking on a malicious URL, a person can automatically download a malware program or a virus that can take over their devices or trick them into disclosing sensitive information on a fake website. End users who lack a fundamental understanding of information security are easier to be exploited by cybercriminals. One of the solutions for this kind of problem is using blocklist lookup; though effective, blocklists have a significant false-negative rate and lack the ability to detect newly generated malicious URLs. To address this problem, the researchers developed a mobile application called Mal Where, which can detect website links from image data. MalWhere also utilizes and combines the two known URL classification approaches: blocklisting and machine learning. With the blocklist service, MalWhere has access to a large number of Malicious URLs around the world. With machine learning, MalWhere can predict the classification of a URL, whether it is benign or malicious. The classification model was trained using 39 features and a supervised machine learning classifier called XGBoost. The classification ability of the model is mainly used to classify unknown and benign URLs to the blocklist service. Based on the conducted testing, MalWhere has an 88% accuracy rate in predicting the classification of a URL-whether it is benign or malicious.', NULL, NULL),
(17, 2, 'STUDYMATE: A STUDY PEER RECOMMENDER APP USING RECIPROCAL RECOMMENDATION ALGORITHM', '4', 'Bachelor of Science in Information Technology', 6, '2022', 'When organizing a study group, finding and selecting a good study partner is essential because it increases the relevance and productivity of group discussions. Most of the time, students form study groups with peers with similar characteristics and interests. However, finding a suitable study mate takes time and effort. This work focused on creating a study peer recommender system that uses a reciprocal recommendation algorithm to help students find like-minded study partners and foster informal learning communities among students. The peer recommendation approach uses student traits, communicative openness, and Personality as matching factors. The modified waterfall model was utilized as the core methodology to implement the system for its flexibility in requirement evolution and iteration, which helped the proponents deliver the project on schedule.', NULL, NULL),
(18, 2, 'STRESSSENSE: A STRESS LEVEL DETECTOR FOR DETERMINATION OF STRESS LEVEL THROUGH THE COMBINATION OF PHYSIOLOGICAL DATA OF GALVANIC SKIN RESPONSE AND PULSE RATE', '15', 'Bachelor of Science in Information Technology', 2, '2022', 'Stress is generally experienced in our daily lives. It is also inescapable. Stress is a response to a particular event or situation. It is the way that our body prepares to face difficult situations which require focus, strength, and heightened alertness. If an individual experiences stress, the body will react to respond to the causes or factors of stress. The body responds through sweat glands which produce electrical flow (conductance) and pulse rate as well. In this paper, a device was developed to be able to determine the stress level of an individual, particularly for the tertiary students at the University of Southeastern Philippines. Galvanic Skin Response (GSR) detects strong emotions and electrical flow through the skin and the pulse sensor detects the fluctuation of the blood pumped by the human heart (beats-per-minute/BMP). The gathered data will be interpreted to its corresponding level based on the stress parameters and will provide the final stress level output based on the table formulated from the fuzzy logic method. The testing was conducted alongside the ten (10) respondents; five (5) male and five (5) female students at the said university and their final stress level was displayed through the serial monitor of Arduino.', NULL, NULL),
(19, 2, 'ATONGSECRET: A WEB-BASED FILE SHARING AND MESSAGING APPLICATION USING IMAGE STEGANOGRAPHY', NULL, 'Bachelor of Science in Information Technology', 6, '2022', 'Steganography is concealing user data in various file types, such as photographs. The primary goal of steganography is to conceal private data; therefore, it should be treated with care. The security of Steganography is based on the invisibility of secret information in the stego picture, allowing the information to remain undetectable. The researchers developed a web application using Least Significant Bit Steganography in this capstone project. The project results showed that the web app successfully sent messages, concealed files in images, verified the receiver with a stego key, and displayed push notifications for received messages and files. The researchers used PHP, CSS, HTML, MYSQL, AJAX, JQUERY, and Hostinger web hosting to test and develop the web application. The application developed in this project became a medium where users safely send messages, was able to conceal files, deliver the stego key to the intended receiver and showed push notifications to its users.', NULL, NULL),
(20, 2, 'lsdaCulture An IoT - Based Water Temperature and Dissolved Oxygen Level Monitoring System for Milkfish Farming', '8', 'Bachelor of Science in Information Technology', 8, '2021', 'In aquaculture, the main cause of fish mortality is an increase in water temperature that causes oxygen loss. The amount of dissolved oxygen in the water reduces as the temperature rises. The research aimed to design and develop an improved smart fish pond monitoring system for milkfish farming. It will notify the farmers whenever the water temperature or dissolved oxygen levels change. The system was designed to monitor pond water using temperature and dissolved oxygen level sensors. Sensors send pre-processed data to a server through the built-in WIFI module of the microcontroller. The mobile application generates significant pond parameters to generate significant parameters and activates actuators to maintain water temperature. The researchers used the Rapid Application Development (RAD) methodology as the development model to keep track of progress and give real-time updates on any problems or modifications that emerge. The devices used in this research were two sensors, three actuators, a mobile application, and a server. The testing process includes using pre-processed data that was sent to a local server. The server analyzes water temperature and dissolved oxygen levels. The app then displays the data in various places of the app once it has been processed. It also includes a series of conditional statements to identify the pond\'s state. The sensors detect changes in water temperature and alert the owner or caretaker by sending push notifications about temperature fluctuations after gathering and processing the data. It uses a microcontroller to analyze a sequence of conditional statements before activating the specific actuators. The study concluded that the microcontroller generated important parameters and data logs that indicated the pond and fish condition. A push notification was sent to the smartphone, informing it of the current state of the pond in real-time. The actuators will automatically turn on and off after regulating the water temperatures and dissolved oxygen levels.', NULL, NULL),
(21, 2, 'UVwearloT: AN IoT BASED WEARABLE DEVICE COMPOSE OF TWO SMART SENSORS TO MONITOR ULTRAVIOLET INDEX (UVI) LEVEL (UV SENSOR) AND PULSE RATE MONITORING (PULSE SENSOR) TO TRACKDOWN ACTIVITIES', '19', 'Bachelor of Science in Information Technology', 6, '2021', 'There are two types of UV light that are proven to contribute to the risk for skin cancer: Ultraviolet A (UVA) and Ultraviolet B (UVB). This study developed a wearable device with UV and pulse rate sensors connected to a mobile app to notify the user about UV radiation risks and abnormal pulse rate. The system was developed using Android Studio and Arduino IDE for real-time monitoring and notifications for user safety.', NULL, NULL),
(22, 2, 'EMPATHYVR: A LEARNING COMMUNICATION PLATFORM FOR CHILDREN WITH AUTISM', '19', 'Bachelor of Science in Information Technology', 1, '2021', 'This research aimed to develop an assistive technology using virtual reality to improve the communication skills of children with autism. The system is designed as a game-based learning platform that helps users progress through levels to enhance communication abilities, with data monitored to track their development. Despite the challenges posed by the COVID-19 pandemic, the study showed that virtual reality can be an effective method for autistic children.', NULL, NULL),
(23, 2, 'SOS\'IoT: A Noise Monitoring and Warning Tool for Barangay', '20', 'Bachelor of Science in Information Technology', 6, '2021', 'This study developed a noise monitoring system to help barangay officials promote peace and order by monitoring noise levels in their area. The system utilized the Rapid Application Development (RAD) methodology, and despite challenges due to the COVID-19 pandemic, the researchers developed a noise detection simulator using an ESP8266 and KY-038 microphone. The mobile app developed showed the retrieved data for analysis.', NULL, NULL),
(24, 2, 'RedPing: An IoT-Based Flood Detection System for Urban Areas', '19', 'Bachelor of Science in Information Technology', 10, '2021', 'Flooding is an imminent phenomenon mostly in equatorial regions. Risk and challenges occur from flooding when it involves endangering lives and damage to properties. Traditional studies and solutions to flooding often involve monitoring inland bodies of water such as rivers, dams, and lowly elevated areas. However, there is little attention given to street flooding, its effects on transportation, and its solutions. The paper investigated the effects of street flooding in transportation and the current solutions available. RedPing is an IoT-based solution to monitor street floods using sonar technology housed in a pole structure to measure flood levels. Data is sent to a server that serves as the database for the application.', NULL, NULL),
(25, 2, 'IoTae: A Web Based Monitoring System for Harmful Algal Bloom Growth in Ponds Using Water Temperature, Ph and Dissolved Oxygen Sensors', '15', 'Bachelor of Science in Information Technology', 12, '2021', 'The proposed project IoTae is a web-based system that monitors the presence of harmful algal bloom growth in ponds using temperature, pH and dissolved oxygen (DO) sensors. The project aims to raise awareness and provide early warnings to pond owners, government organizations, and LGUs to take actions before it becomes critical. The system provides notifications when the indicators reach or exceed the optimum level, triggering the aeration process.', NULL, NULL),
(26, 2, 'Project T-RAT: An IoT Based Smart-Trapper for Rats', '15', 'Bachelor of Science in Information Technology', 12, '2021', 'The project T-RAT was developed to help household and business owners capture rats in their establishments. The device uses sensors (weight sensor, infrared sensor, and camera) to ensure accurate rat capture. The system notifies users through a mobile application when a rat is captured. The system underwent several phases of development, including testing the accuracy of the device, notification speed, and safety features for handling the trap.', NULL, NULL),
(27, 2, 'HAPPAG: A MOBILE APPLICATION CONNECTING FOOD DONORS AND DONEES TO PREVENT FOOD WASTES', '29', 'Bachelor of Science in Information Technology', 6, '2021', 'The following was a proposal for a mobile application that helps prevent food wastage. The goal was to help reduce food wastes being thrown into landfills that would cause serious issues to the environment such as climate change. Generally, this application helps connect food-related establishments, charitable organizations, and food composting facilities by allowing food-related establishments such as restaurants, supermarkets, cafeterias, and fast-food chains to donate their food waste and encourage them not to throw away food. Additionally, to make use of inedible food waste that can be used for composting. The application had undergone four phases of development using an agile software development methodology due to the amount of time given for the completion of this project. The proponents focused on prototype iterations with less planning time and measured progress and communicated real-time on evolving issues. The application displays a geographical representation of nearby donors and recipients that matches their needs using Google Map API. Furthermore, the proponents used a library called Socket.IO that was used for in-app messaging, allowing both users to interact or communicate real-time through the mobile application and react native chart kits plugin to display through visualization the donated food wastes to provide donors a decision support by analyzing the data to help them assess the reduction or increase of their food wastes. The project aimed to raise awareness of the impacts of food wastes and encouraged food-related establishments, including households to avoid throwing edible foods considering that there are some people who don\'t have enough food on their table. After thorough research and development, the objectives of the project were met, and results showed that the application developed was able to help donors donate their food wastes to recipients easily and conveniently, leading towards food waste prevention.', NULL, NULL),
(28, 2, 'DIPRICE: A RICE QUALITY IDENTIFIER USING DIGITAL IMAGE PROCESSING', '6', 'Bachelor of Science in Information Technology', 5, '2021', 'Rice the staple food in the country and determining the current quality state of it is hard for many consumers. Consumers may rely on a proxy characteristic such as brand or establish relationships with the seller. This practice may result in deceiving consumers from sellers who take advantage of consumers who have little knowledge on the quality of rice. The main objective of this paper is to develop a mobile application that uses digital image processing to identify the impurities and overall quality of rice-based on premium quality, medium quality, and low-quality rice samples stated on the standards of the study of R.C Custodio. The methodology used in this paper is RAD Rapid Application Development which is an iterative incremental model that is designed for developing software in a short period where projects can be delivered by dividing it into a series of smaller and manageable pieces called components/modules, thus reducing the overall project risks. In this study, the researchers used the tool questionnaire and gathered all the answers from respondents to develop a dataset that was used as a basis of the mobile application in determining the quality state of the rice. The first objective of the study is to acquire and enhance an image to be used as a data set that was met when the researchers were able to acquire an image sample and create this image as a dataset. The second objective was to identify rice impurities present in the sample of rice, this objective was also met when the proponents were able to sort rice samples according to premium quality, medium quality, and low-quality rice in the data set. And the last objective was to identify the quality state of rice according to the dataset recorded on the first and second objective, this objective met when the proponents were able to produce a working application that can scan and identify the quality state of rice. To test the mobile application, the proponent scan different sample of Premium, Medium, and Low-quality rice and run them 10 times per sample, the result shows that the application has an accuracy rate of 60% on premium rice, 80% on medium quality rice and 90% on low-quality rice and the overall accuracy ofthe application is 77%.', NULL, NULL),
(29, 2, 'HeHaSpot: A Human Health Hazard Web and a Mobile Surveillance Application', '14', 'Bachelor of Science in Information Technology', 12, '2021', 'Awareness of health issues is important for visibility and community. One of the basic health awareness is to maintain your surroundings clean and green. But some people face problems related to disposing of their garbage and unaware of segregating their garbage that may create hazardous and possibly affect human health. It can possibly cause acute or chronic illness and some serious health problems. This problem not just applies for the people in a certain area but also in a community or barangay who are lacking knowledge about the negative effects of hazardous substances in human health. The proponents HeHa Spot: Human Health Hazard surveillance. This study aims to provide a mobile application that convenient and hassle free to the end-user to report hazard substances on their respective barangay. Using the HeHa Spot the end-user able to report any hazardous waste on their surroundings and it connected to the admin or the barangay health worker and classifying the reported hazardous waste using the severity of colors. The proponents use the Rapid Application Development (RAD) as a method in making the project possible. This Methodology helps the team to develop the application faster and understanding its each function. The said methodology helps the team to identify their requirements planning, prototyping, testing and cut over. After thorough research and development, the proponents were able to meet the objectives of the application. Using the android studio, the proponent able to make the mobile application, the adobe XD is for designing, and Visual Studio code for the web or in the admin side. Also, the proponent prepared the user manual for the users have a guide on how to use the mobile application.', NULL, NULL),
(30, 2, 'SPEEDISOR: A WEB AND MOBILE-BASED APPLICATION TO MONITOR TAXI DRIVER SPEED LIMIT VIOLATION USING A REAL-TIME LOCATOR', '26', 'Bachelor of Science in Information Technology', 7, '2021', 'A traffic violation is one of the causes of road accidents. The number of speed- related crashes has shown an upward trend in recent years, most of which occur because of breaking speed limits. In Davao, around 40% of accidents occurred from 2013 to 2014, and by the years 2017 to 2018, there were also accidents, but not as fatal. The main objective of this project is to develop a web and mobile-based application of speed monitoring to check the real-time speed of all taxis traveling in highways. It will send data to the server when vehicles exceed the maximum speed limit. This will also serve as a disciplinary ground for drivers once their number of violations go beyond the maximum range set by their operator. In the future, this research will aid taxi operators in monitoring their drivers. The system is accurately able to measure vehicles\' current speed within every location that applies a speed limit and check for violations using the said speed limit information.', NULL, NULL),
(31, 2, 'HALINON: A CROWDSOURCED PRODUCT TRENDS AND COMPETITION INFORMATION WEBSITE', '20', 'Bachelor of Science in Information Technology', 8, '2021', 'Micro, Small, and Medium Enterprises (MSMEs) are an essential part of the Philippine economy. However, even with government programs and existing solutions, these businesses still lack market knowledge compared to more giant corporations. Aside from having little to no access to technology, most of these entrepreneurs do not have the financial ability to hire market analysts or use expensive services. Accordingly, this leads the researchers to develop a localized market trend analysis website for MSME operators. The website analyzes crowdsourced market data and processes them into easy-to-understand information about product popularity and level of competition in different areas. Also, the system displays these results into a highly accessible webpage that\'s free for every MSME operator to use. In developing the system, the researchers used the modified waterfall model as the project management technique. Moreover, since results must reflect actual human selling/buying transactions, the system utilizes and processes data only from the simulated marketplace database. In order to ensure that the target users know how to use the system, the researchers conducted usability testing with a group of MSME operators. Furthermore, the researchers used and analyzed the simulated marketplace database\'s item descriptions, tags, \"buy\" button statistics, and user location records to generate results. After completing the system, the researchers concluded that it is possible to identify the popularity and rate of competition of a product in a location and recommend areas for a particular item using a specific algorithm, the PHP language, and processing an online marketplace\'s data. Finally, the researchers recommend future studies/development to make the website more responsive, offer language translation features, and use a premium or more reliable geolocation API.', NULL, NULL),
(32, 2, 'BreakApp: A WEB AND MOBILE BASED APPLICATION FOR CIRCUIT BREAKER MONITORING AND TRACKING USING ARDUINO CURRENT SENSOR FOR UNIVERSITY OF SOUTHEASTERN PHILPIINES - COLLEGE OF ENGINEERING', '6', 'Bachelor of Science in Information Technology', 6, '2021', 'Circuit overloading is the most common problem experienced by circuit breakers, according to a university electrician from the University of Southeastern Philippines (USEP) in an interview regarding the concerns with circuit breakers. Furthermore, he noted that one of the university\'s issues is discovering and tracing a malfunctioning circuit breaker. The designated workers must manually monitor and examine each college and office to see whether a circuit breaker is malfunctioning. With the help of an Arduino current sensor attached to a microcontroller and a circuit breaker, the researchers were able to record data on electric current (Amperes) that is expected to travel through the circuit breaker in the Engineering building of the USeP. The current sensor in a circuit breaker was linked to a microprocessor that determined the current state. The sensor\'s data was promptly saved to a local database, evaluated, and presented on the web and on mobile devices for viewing, and a particular circuit breaker that went into warning or critical mode was quickly recognized and discovered.', NULL, NULL),
(33, 2, 'DRIVECARE: A WEARABLE DEVICE TO DETECT DRIVER DROWSINESS BASED ON EYEBLINK ANALYSIS', '8', 'Bachelor of Science in Information Technology', 6, '2021', 'In recent years, the casualties of traffic accidents caused by driving cars have gradually increased. According to various research, drowsy drivers are responsible for roughly 20% of traffic accidents. The researchers present DriveCare, a wearable device to detect drowsiness. This paper intended to design an automated device for the safety of drivers from improper driving. The device designed such that it will detects the eye blink. The goal was to provide a platform that detects driver drowsiness and has a potential to reduce drowsiness related crashes. The proponents used an Agile method in making the project possible. This methodology helped the team provide faster development and identify errors through testing and development. The results showed that the device accuracy was 88%. The system using an eye blink sensor is beneficial in measuring the factors that contribute to a driver\'s drowsiness to reduce high risk of being involved on road accidents. Future performance improvements could be achieved and expanded to include field data parameters and new approaches.', NULL, NULL),
(34, 2, 'TransBraille: A MOBILE-BASED APPLICATION FOR BRAILLE TRANSLATION USING DIGITAL IMAGE PROCESSING', '10', 'Bachelor of Science in Information Technology', 6, '2021', 'Reading braille symbols has been an enormous problem of teachers who has blind students. Braille has two levels which are Uncontracted Braille (Grade 1) and Contracted Braille (Grade 2), the process of translating these braille symbols is made by moving the fingertips from left to right across the lines of dots. With this method of reading, translating the braille symbols demands much time to be exerted to find out the right transcription. In addition to this, due to the fact that Braille has two levels, the capacity of an individual to memorize and remember all of the braille symbols cell translation for each letter and word is another factor to consider. This project focuses on creating a mobile application that helps the teachers in translating both Uncontracted and Contracted braille symbol into ABC text by just capturing the document with a cell then immediately provides the correct translation. The application offers a translation for two different languages: English and Filipino. Furthermore, this application has an online database that enables it to store a large number of data that can hold all of the translation of each braille symbol cells in two languages and two levels of braille. Trials and errors had occurred multiple times during the development of the project. One limitation of the developed application is its sensitivity to light, that is, if the camera and the document that will be captured is not placed in a well-lit area and the shadowing were not properly checked, then the accuracy rate of the translation will not be as high as it is expected. In addition to this, the application captures the cells one- by-one for a reason that in capturing the whole document affects the proper alignment of the cells towards the camera. The farther the cells are from the camera lens, the distorted they become, which results to erroneous translation. The future researchers can use different techniques and logics in making the braille application easier and even more accessible, such as capturing a whole braille paper and be able to transcribe it correctly.', NULL, NULL);
INSERT INTO `research` (`researchID`, `uploadedBy`, `researchTitle`, `researchAdviser`, `program`, `publishedMonth`, `publishedYear`, `researchAbstract`, `researchApprovalSheet`, `researchManuscript`) VALUES
(35, 2, 'FINDING SAFETY IN TECHNOLOGY: A SYSTEM FOR CRIME INCIDENT REPORTING VIA LIVE VIDEO FEED AND LOCATION PINNING', '16', 'Bachelor of Science in Information Technology', 7, '2021', 'With the ongoing rise of criminal activity, help from the police must be just one call away. However, because of the factors that affect police response time, sometimes this is not the case. Hence, more centralized and direct police reporting could improve response time and on-scene arrests. The study concluded that certain strategies could achieve this goal with the use of a system that alerts the police during a crime incident. It will provide the police with the victim\'s whereabouts through the user\'s coordinates and the current status of the situation. Using a surveillance camera (ESP32-cam), two mobile applications for the civilian and the police, as well as a web application to map the density of crime incidents in a certain area, the system was able to utilize an algorithm derived from the Haversine Formula to pinpoint civilian report and send it to the authorities, along with the video live feed of the current incident. The received reports will be displayed to the web application, using the Google Map API to map out the crimes reported. Videos received by the police, along with their metadata (i.e., civilian name, location of the crime, time and date of the report, etc.), will be stored in the police\'s smartphone in case the victims want to pursue a court case against their assailants.', NULL, NULL),
(36, 2, 'SAFE210T: AN AUTOMATED WATER QUALITY FILTRATION SYSTEM USING IOT', '12', 'Bachelor of Science in Information Technology', 6, '2021', 'Freshwater is considered to be a renewable resource. However, the world\'s supply of groundwater is observed to be constantly decreasing, with depletion seen in various continents. High demand and continued misuse of water resources have increased the widespread risk of water stress. The purpose of this system is to help the common households and building comfort rooms identify the safety of greywater and reduce the usage of water by using a clean and safe alternative. For the development of Safe21oT, the researchers agreed to follow the processes portrayed in the Rapid Application Development (RAD) namely: Analysis and Quick Design Phase, Iterative Prototyping Cycle, Testing Phase, and Implementation Phase. The results of the study showed that the developed system is capable of distinguishing collected greywater from blackwater and filters the reusable water while providing a database for the viewing of the water quality collected by the IoT device. The system underwent multiple functionality testing by using various water solutions for identifying the accuracy of the detection of the used sensors. Based on the results through the development of the project, the researchers observed that by utilizing the concept of \"Internet of Things\" and wireless sensor networks, the project has a huge potential in guaranteeing the safety and recyclability of the collected greywater and the constructed filtration media was capable on improving the physical quality of the collected greywater. The researchers recommend that the catch basin and storage tank should be properly fit the range of the detection of the ultrasonic sensor and install proper piping for the catch basin to avoid water getting near the wirings of the system.', NULL, NULL),
(37, 2, 'NailScanner: A Non-invasive Fingernail Disease Classifier Mobile Application', '19', 'Bachelor of Science in Information Technology', 1, '2021', 'Health awareness failed short for much of the world\'s populace; health is said to be the biggest wealth. If money goes out of hand then, it can be recovered. But once health has deteriorated, it is very difficult to bring it into its former condition. That is why sensible people take care of their health carefully. This problem does not just apply to patients but also for health care professionals who lack the knowledge about certain diseases. The researchers present Nail Scanner, a non-invasive fingernail disease classifier. This study aims to provide a mobile application convenient for both patients and healthcare professionals who are lacking in the area of classifying health diseases. This study also aims to eliminate the clinical and educational gap for both sides as it provides necessary health information. Through real-time tracking of fingernails, the proposed application will eliminate unnecessary objects, aside from fingernails, from being processed, thus improving accuracy of classifying the diseases. The proponents used Rapid Application Development as a method in making the project possible. This methodology helped the team give faster development and produce high quality systems, identifying the errors through testing and going back to the design and development to fix and find the errors to avoid application failure during the testing. After a thorough research and development, the proponents were able to meet the objectives of the application. Using TensorFlow Lite, the application was able to classify fingernail diseases into three (Onychomycosis, Melanonychia, and Leukonychia). The proponents also provided health warnings and guidelines for the users to follow on how to use the application.', NULL, NULL),
(38, 2, 'AgrE: A SECURED E-COMMERCE PLATFORM FOR TRADING AGRICULTURAL COMMODITIES IN THE DFTC', '18', 'Bachelor of Science in Information Technology', 8, '2023', 'The Davao Food Terminal Complex is a project initiated by the City Agriculture\'s Office. This facility serves as a \"Bagsakan\" for the farmers\' commodities. It also serves as a transaction site where buyers and sellers meet each other for buy-and-sell purposes. Regarding the main problem, DFTC Staff often has a hard time finding buyers to purchase their sellers\' commodities. Their only option for that matter is posting the available products on social media and relying on some of their connections to buy the products. Another issue is the manual inputting of transactions during the buyer and seller transaction phase. That is why the proponents have developed a secured e-commerce system to address this matter. This system allows users such as buyers and sellers to create transactions online and enables DFTC Staff to track transactions automatically and view sales and stocks per month. Regarding the security measures of the system, the proponents employ 2FA or Two-Factor Authentication for user authentication which act as another layer of security in case anonymous login attempts occur. Another measure is data encryption, particularly for passwords, to prevent leaks. Through the implementation of these security features, the proponents ensure the security of the system and all associated data. In summary, the proponents developed a system that targets the main problem of the end-users in terms of finding buyers, managing buyer and seller transactions, and track sales and stock. The proponents implement security features that resolve the issue of anonymous logins and leaking of data.', NULL, NULL),
(39, 2, 'PaReserve: A COSTUMIZABLE RESERVATION PLATFORM FOR MEDIUM-SIZE HOTEL OWNERS AND CUSTOMERS WITH FRAUD AND THEFT PREVENTION', '14', 'Bachelor of Science in Information Technology', 8, '2023', 'One of the major consumer groups nowadays is made up of internet users. As a direct result of the widespread usage of online apps, many establishments in the tourism sector, including hotels, airlines, and travel agencies, have integrated internet technology into their marketing and communication strategies. Since online reservation was done through internet, hotel industry faces online data breaches particularly fraud and identity theft. The researchers developed PaReserve, a customizable reservation platform for medium-size hotel owners and customers with fraud and theft prevention. User verification, feedback and ratings on merchants, and the chance to report merchants are the three strands that make up the platform. These phases were developed so that the platform could address identity theft and fraud. These ensure that any information that is published on their accounts is legitimate, including any personal information that may be shared. User verification where the documents are validated for its authenticity. Feedback and ratings are the basis on the reviews. Clients\' report is visible on admin and merchants end and that\'s the basis of the admin in suspending and unsuspending of merchant\'s listing and products. The project met its objectives, but there is still room for improvement especially during live production. First, it should also be available in mobile platforms. Second, it needs to have more available payment options such a debit/credit card, third party payment processors (Paymaya, Paypal) for the convenience of the users. Third, the integrated account in paymongo must be updated to production setup for a seamless payment transaction. Lastly, it needs to have SSL certification. It is vital to maintain trust between the website and the clients. That\'s why it needs to have security to protect important clients\' data from cyber criminals.', NULL, NULL),
(40, 2, 'PIGGYWEARIOT: A PIG COUGH SURVEILLANCE SYSTEM USING: AN IOT-ENABLED WEARABLE DEVICE', '16', 'Bachelor of Science in Information Technology', 8, '2023', 'The project aimed to design an IoT-based pig cough surveillance system to address the significant threats posed by respiratory diseases and African Swine Fever (ASF) to pig health and the industry, resulting in high mortality, reduced productivity, and increased antimicrobial use. Robust biosecurity programs were deemed essential to prevent and control these diseases, but their implementation remained a challenge for pig farms. The system\'s objectives included building a cough detection machine learning model, creating a wearable device for capturing pig cough sounds, building a web application for information presentation, and integrating push notifications. The proposed system aimed to enhance biosecurity by enabling early detection of disease symptoms through individual monitoring. This facilitated personalized treatment plans, reducing antimicrobial usage. The wearable device and cough detection model offered reliable pig monitoring, while the web application facilitated information presentation and timely push notifications for immediate responses. The project achieved a total accuracy rate of 91.30%, with 85.7% accuracy for cough and 93.8% for non-cough using the machine learning model. The web application was successfully developed, enabling users to monitor their pig farms virtually or remotely. The wearable device prototype could be simulated and worn around the pig\'s neck. Also, providing real-time push notifications when a cough occurrence was detected. To further enhance model accuracy, the researchers recommended utilizing a larger and more diverse dataset and conducting real-world testing on pig farms for commercial feasibility assessment. Implementing this innovative system had the potential to easily distinguish pig cough from other pig noises, improve biosecurity in pig farms through automating the monitoring process, and alleviate the impact of respiratory diseases and ASF in pig industry.', NULL, NULL),
(41, 2, 'ANALINK: A MOBILE-BASED APPLICATION FOR DETECTING MALICIOUS URL BY CHECKING SMS CONTENT', '15', 'Bachelor of Science in Information Technology', 6, '2023', 'The rapid advancements in information technology have led to a significant rise in smartphone usage, with individuals increasingly relying on their devices to store sensitive information such as usernames, passwords, and financial details like credit card and debit card information. However, this reliance on smartphones also exposes users to potential security risks, particularly smishing attacks. Smishing, which combines SMS and phishing, poses a significant threat wherein attackers send deceptive messages containing potentially harmful URLs to unsuspecting individuals. These URLs can direct users to phishing websites, immediate malware downloads, or facilitate other malicious activities, compromising personal information and digital security. To address these pressing issues, the proponents have developed Analink, a mobile application designed to detect potentially malicious URLs embedded in SMS messages in real time. Operating seamlessly in the background, Analink continuously scans incoming SMS messages for embedded links. Once a link is detected, the application promptly pushes a notification to alert the user. Analink leverages a dedicated blacklist database and a cross-reference API to evaluate the detected URL\'s potential threat. Notably, the blacklist method employed by Analink has achieved an impressive accuracy rate of 89% in identifying potentially malicious URLs within SMS messages. In summary, the proponents have developed Analink, a mobile application to mitigate the risks of smishing attacks. By proactively scanning and analyzing incoming SMS messages for potentially harmful URLS, Analink serves as a reliable safeguard, promptly notifying users of potential threats.', NULL, NULL),
(42, 2, 'KAPETa: DESIGN AND DEVELOPMENT OF WEB-BASED E-COMMERCE APPLICATION FOR COFFEE STARTUPS IN DAVAO CITY', '19', 'Bachelor of Science in Information Technology', 8, '2023', 'Coffee, a beloved beverage, stands as one of the world\'s most popular and profitable commodities. With an annual consumption of 500 billion cups, the Philippines has had a rich coffee farming tradition over the years. Despite the pandemic-induced challenges leading to a decline in sales in 2020, the dynamic coffee industry in the Philippines has demonstrated resilience by embracing innovative approaches, especially through e-commerce platforms. This study focuses on the context of Davao City within the Philippines, aiming to explore the development of a digital strategy to uplift local coffee businesses. As part of the research, a survey was conducted among small coffee shop owners in Davao City, yielding valuable insights that guided the design and development of an e-commerce platform tailored to enhance the success of these businesses. The proposed e-commerce solution addresses various critical aspects. It can streamline product management, improve market access for small businesses, facilitate brand building, enhance inventory management, and allow easy monitoring of day-to-day transactions. By leveraging the power of technology, local coffee businesses can break free from traditional constraints, leading to increased profitability and sustainable growth. The findings from this study emphasize the pressing need for the coffee industry in the Philippines, particularly in Davao City, to embrace e-commerce solutions. By doing so, these businesses can tap into a broader market, overcome pandemic-induced challenges, and thrive in a digital era. The insights gathered from small coffee shop owners served as a cornerstone in the development of an e-commerce platform, ensuring that it is tailored to meet the unique needs of the local coffee industry, most especially the small businesses. The transformation from traditional storefronts to a digital platform holds the promise of revitalizing the coffee business landscape in the Philippines and ensuring its vibrant future.', NULL, NULL),
(43, 2, 'STOCKWISE: An Inventory Management and Demand Forecasting System for Food Retailers', '12', 'Bachelor of Science in Information Technology', 5, '2023', 'Food retailers face significant challenges in managing their inventory effectively. Inaccurate demand forecasting often leads to overstocking or stockouts, resulting in increased costs and customer dissatisfaction. Manual inventory tracking and the lack of integration of demand forecasting in inventory systems make it difficult for retailers to make informed decisions, leading to inefficiencies and lost revenue opportunities. According to an article featuring Aiko Reyes, co-founder of Peddlr, the continuous use of manual stock management remains problematic in the industry. The project developed an Inventory Management and Demand Forecasting System specifically designed for food retailers, leveraging historical sales data and a Simple Moving Average (SMA) technique to generate demand forecasts. The system includes restock planning that considers budget, product price, and forecasted demand, dynamically improving inventory levels, replenishment processes, and reducing the risk of stockouts or excess stock. The Rapid Application Development (RAD) methodology was employed to support close collaboration with food retail owners and address their specific stock management constraints. The final system presents an innovative solution to inventory management problems, aiming to increase profitability, enhance customer satisfaction, and gain a competitive advantage in the food retail industry.', NULL, NULL),
(44, 2, 'PRIVACY QUEST: A Data Privacy Awareness Game for Teenagers', '6', 'Bachelor of Science in Information Technology', 5, '2023', 'The public\'s understanding of personal data privacy is poor, despite numerous efforts by the government and media to educate people on protecting their data online. Teenagers are especially vulnerable to data breaches, phishing, and identity theft due to overreliance on weak device security and a general disregard for internet safety. The Philippines also lacks sufficient data security training resources for youth. To address this, the project used game-based learning and Yusoff\'s serious games framework to develop a 2D simulation game that raises data privacy awareness among teenagers. The interactive and engaging environment helps bridge the gap in resources, offering an effective and educational way for youth to understand the importance of digital security and personal data protection.', NULL, NULL),
(45, 2, 'Design and Development of Web-Based Data Privacy Assessment Tool for the University of Southeastern Philippines', '19', 'Bachelor of Science in Information Technology', 6, '2023', 'In the era of rapid technological advancement, safeguarding data privacy has become a vital concern for global organizations, including educational institutions. This capstone initiative introduces a Web-Based Data Privacy Assessment Tool for the University of Southeastern Philippines to address this crucial need. The project aims to create a Privacy Impact Assessment system for access to authorized personnel, enabling risk analysis for personally identifying information. The tool generates comprehensive reports, offers data flow visualizations, and supports decision-making for data management. Interviews with the Data Protection Officer helped shape the tool to align with the university\'s privacy standards. The completed tool allows users to initiate assessments, analyze data lifecycle, evaluate risks, and suggest privacy enhancements. The Data Protection Officer can validate assessments and generate Privacy Impact Assessment reports, fostering data protection and compliance within the university\'s operations. This project successfully equips the university with a robust privacy tool, ensuring information security, regulatory adherence, and proactive privacy measures.', NULL, NULL),
(46, 2, 'BOXDOTS++: QUICK RESPONSE CODE SCANNER WITH MALICIOUS, SAFE, AND DEAD URL DETECTION', '12', 'Bachelor of Science in Information Technology', 12, '2023', 'QR code refers to Quick Response Code, which has revolutionized information accessibility, creating an immediate and seamless data exchange paradigm. The increasing prevalence of smartphones and online transactions has fueled a significant surge in QR code usage. Recently, users have increasingly relied on QR codes for various online transactions and payments. This popularity, however, has attracted cybercriminals who exploit them for cyberattacks and the spread of malicious content. QR code phishing attacks are on the rise, with attackers targeting unsuspecting individuals through malicious content embedded in QR codes. By synthesizing related literature, the proponents observed that there is a lack of reliable tools for detecting malicious URLs in QR codes, generally in the evaluation of the security of QR codes, leaving users vulnerable.\nTo address this growing threat and the lack of tools, BoxDots, a mobile application designed to detect potentially malicious URLs embedded within QR codes in real time, has been developed. BoxDots integrates the APIs VirusTotal and Google Safe Browsing to cover a diverse range of malicious URLS, which allows for effective scanning and analysis of URLS. The study specifically aims to integrate the Quick Response code scanning library to detect URLS from QR codes, integrate the Google Safe Browsing API and the VirusTotal API into the application to validate extracted URLs in QR codes, and develop a secondary repository or database to store a new list of malicious URLs. Once a QR code is scanned, the application instantly displays the result, allowing users to make informed decisions about clicking on the embedded link. What sets BoxDots apart from existing solutions is that it doesn\'t only identify malicious links but also safe and dead links. Following successful verification of its functionalities, BoxDots secures users from potentially harmful links in QR codes. BoxDots was designed as a simple and intuitive interface for a seamless user experience.\nThe developers developed the application using the Rapid Application Development methodology, building it iteratively and incorporating valuable user feedback. To guarantee its functionality, the proponents performed rigorous system testing, ensuring each component and data flow worked flawlessly. Benchmarking against similar applications and using industry-standard techniques to assess its performance. To compare the two applications, the proponents tested both applications using a list of similar links and compared their results. Finally, the System Usability Scale measured the application\'s ease of use and user satisfaction, ensuring an intuitive and user-friendly application. Through this comprehensive evaluation, the developers delivered an application that was not only functional but also user-friendly.\nThe result of the system\'s testing presented exceptional performance, demonstrating its capacity to scan and evaluate URLS with consistent reliability and correctness. The benchmarking test showed a slightly higher overall accuracy in detecting expected links across all categories, particularly dead links, compared to an existing scanner application. The results of the System Usability Scale (76.71), which surpassed 68, which is the average SUS score, only indicate that the application design and functionality have successfully met or exceeded user expectations. The findings of the study emphasize the performance, reliability, usability, and user-friendly design of BoxDots, which meet the ever-evolving needs of users.\nBoxDots offers a reliable and secure solution to mitigate QR code phishing risks, empower users, and advance safer digital interactions. However, to maximize its efficacy and overall user experience, additional research involving diverse datasets and optimization of scanning speed are essential. Researchers may explore the incorporation of a wider range of malicious QR codes to diversify datasets, ultimately boosting the application\'s performance. Aside from that, they might also consider optimizing scanning speed as crucial, as observed by findings indicating limitations in certain APIs\' ability to analyze URLs. Improvements in this aspect can significantly enhance the efficiency and user experience of the application.\nIn summary, BoxDots emerges as a reliable and secure tool for URL detector applications, mitigating the risks associated with phishing attacks by scanning the links embedded in QR codes for potentially malicious URLs. It empowers users to embrace the convenience and efficiency of QR codes while safeguarding themselves from malicious content. As QR code technology continues to evolve, BoxDots stands as a testament to the importance of prioritizing security and fostering a safer digital future.', NULL, NULL),
(47, 2, 'PREDICTALYST: A HUMAN RESOURCE MANAGEMENT SYSTEM FOR PREDICTING EMPLOYEE ATTRITION USING PREDICTIVE ANALYTICS', '16', 'Bachelor of Science in Information Technology', 5, '2023', 'This capstone study is about developing a system that can predict employee attrition through developing a predictive analytics model and gathered datasets to train machine learning to predict employee attrition by utilizing Random Forest Algorithm via Application Programming Interfaces (API). This study also provides real-time updates using visualization to have an accessible way to see and understand the data and patterns and to help the human resource management system to enhance and improve their decision-making process and large, complex dataset.\nThe proponents utilized the rapid Application Development (RAD) approach to develop the project. This methodology was employed primarily due to its adaptability and focus on ongoing designs and modifications, which helped integrate updates that improved the application\'s performance. The result was that the developers could provide quick revisions that improved the system\'s quality while decreasing development timelines simultaneously, making the Predictalyst development method more effective.\nAt the end of the study, the proponents successfully created a web application for the system to predict employee attrition that used Predictive Analytics Model, Random Forest Algorithm via Application Programming Interfaces (API) and to provide a real- time update using visualization. The development outcome led to the accomplishment of the study\'s implied aims.\nSucceeding research should improve the effectiveness and efficiency of the Employee Attrition application to enhance the creation of an accessible system prediction. Additionally, the proponents recommend integrating a geological map to get a more accurate distance from home, utilizing questionnaires to evaluate employees to get the average performance rating, developing individual real-time visualizations, and trying to find more datasets based in the Philippines.', NULL, NULL),
(48, 2, 'PARAQUEUE: A REAL-TIME PUBLIC UTILITY VEHICLE INFORMATION TRACKING SYSTEM', '16', 'Bachelor of Science in Information Technology', 5, '2023', 'This capstone study is about a developed system that can track the real-time information of PUVs to assist drivers in managing their trips and alleviate the commuting difficulties of commuters. The focus of the study was on PUVs that have routes within Davao City, wherein the testing was limited to 5 routes only. The researchers aimed to address traditional jeepneys specifically as the type of PUVS to be monitored. The development objective was to distinguish between the different routes of PUVs, hence the scope of the project.\nThe researchers opted to utilize the Rapid Application Development (RAD) approach in developing the project. This methodology was chosen for its agility and focus on iterative development and prototyping. By adopting RAD, the researchers were able to incorporate updates that improved the application\'s performance throughout the development process. This approach enabled swift iterations that enhanced the system\'s quality while simultaneously reducing development timelines, resulting in a more efficient ParaQueue development process.\nAt the end of the study, the proponents were able to have successfully developed a web application for the registration of the drivers and vehicles into the system, a mobile application for the real-time monitoring of the commuters, a classification feature to differentiate the routes, a real-time location detector using mobile phone tracking technology, and a seat vacancy provider feature. The output of the development resulted to achieve the objectives indicated for the study.\nSubsequent research should prioritize improving the effectiveness and efficiency of the PUV tracking application to enhance the creation of a convenient transportation queueing system. Additionally, the researchers recommend expanding the scope of the study to encompass a wider range of routes and include all PUVS operating within Davao City. This expansion would contribute to a more comprehensive and comprehensive understanding of the application\'s capabilities.', NULL, NULL),
(49, 2, 'LAON: LEAF COLOR CHART (LCC) APPLICATION FOR N FERTILIZATION N MANAGEMENT IN RICE', '16', 'Bachelor of Science in Information Technology', 7, '2023', 'In rice farming, the reason why farmers apply much fertilizer to their yields is to further grow and develop their plants, swiftly. Thus, nitrogen fertilizer is considered to be the primary source of yield-limiting nutrients in rice production. As this limits the production of rice whenever farmers input a lot of N release in the field. Farmers employed the use of LCC and its instructions to ease the use of nitrogen in the field, without even sacrificing their yield in order to know nitrogen requirement in real-time management. Despite its widespread use in agricultural research institutes, farmers were still unfamiliar with this tool. Technology researchers stressed the need for more significant research on the Leaf Color Chart, which enables the need for more computer science and technology research and the digitization of agricultural science. Farmers could still make mistakes when comparing the plant\'s leaf color with the LCC; but, errors are still possible. Therefore, various farmers claimed that they are more likely to adopt the technology. If technology is presented to them, there is a need to further explain on how they will be able to utilize it. The LAON application was designed to automate the IRRI and PhilRice\'s Leaf Color Chart. Farmers typically gather ten photos of uniform rice leaf sizes from the chosen field. The nitrogen content of the rice plant will be determined by assessing and comparing the sample images of rice leaves. Furthermore, weather forecasting is launching in response to the application. The researchers used Modified Waterfall Model as part of the methodology, and the development model retracts progress and problems or modifications that emerge in the process. This study has conducted for the application to extract RGB colors from the uploaded rice leaf image, and then internally transform it into HEX code. In which, the KNN Algorithm is used to identify the color that is closest to the LCC colors. Therefore, a user can \'enable\' a push notification button for its \'initial rice leaf reading\', and for its \'next reading\', as a notification. Then, able to create a task via N management result within seven days, as well as notification for DSR and DAT.', NULL, NULL),
(50, 2, 'ELIAS: A PERSONAL ALIASING MANAGEMENT SYSTEM', '7', 'Bachelor of Science in Information Technology', 5, '2023', 'The annual occurrence of personal data breaches has shown a minimal decline over time. In recent years, personal data breaches have increased by 70% globally. In 2021, the number of reported cases of personal data intrusions in the Philippines increased significantly, reaching 4.59 million instances. Among these occurrences, there were instances of personal information leaking. By using exact names, fraudulent messages masquerading as legitimate business communications were able to acquire the trust of unwary victims. The National Privacy Commission states that fraudsters obtain sensitive information via popular payment, mobile wallets, and messaging applications. Websites on a global scale have also been compromised by unauthorized data intrusions, with hackers frequently targeting sites that store accurate personal data. The proponents developed a personal aliasing management system responding to the growing demand for online security and convenience. The system uses aliasing techniques to generate unique aliases to protect personal information. The system includes creating a secure sign-up and sign-in system, a web-based aliasing system, a user-friendly alias administration system, and a browser extension for automated auto-filling and login activity recording. The significance of the study rests in its potential to address the difficulties of managing login credentials, improve online security, and offer an efficient solution to users. Rapid Application Development (RAD) is the methodology for the project\'s development due to its emphasis on user-centricity throughout the process. The developers have effectively created a personal aliasing management system that generates aliased user credentials during account creation on online platforms that do not require truthful information. This system provides an additional security layer, alleviating worries about data intrusions and identity theft.', NULL, NULL),
(51, 2, 'E-PAGDIWANG A CUSTOMIZABLE WEB-BASED REFERRAL PLATFORM FOR EVENT ORGANIZERS OF MICRO, SMALL, AND MEDIUM-SIZED ENTERPRISES (SMEs)', '8', 'Bachelor of Science in Information Technology', 6, '2023', 'Business owners and marketers are relying more and more on their capacity to capitalize on customer-to-customer interactions as the business environment becomes progressively more competitive and the entire world is now transformed into a possible market for enterprises. The event-organizing industry in Davao City has grown significantly for four years ago. This is most likely due to the city receiving national attention. Because of social media, people have grown more interested in and receptive to new products and experiences. As a result, the researchers established the creation of a platform named E-Pagdiwang, which helps people have or plan successful events or celebrations through the promotion and deployment of various event organizers and planners in Davao City. E-Pagdiwang is tackled to easily find an event organizer, help communicate with the client almost instantaneously, and help promote the services of the event organizer, wherein the study would benefit both the client and the event organizer. The project is unified with its methodology during its development process, which the researchers used to implement the SCRUM method for software development. SCRUM methodology is a flexible framework that follows the principles of agile methodology for software projects during their software development stage. After thorough research and development, the proponents were able to meet the objectives of the system. Extensive research allowed them to gain in-depth knowledge of the problem domain and user requirements, enabling them to make informed decisions during the development process. The researchers meticulously designed and implemented the system, ensuring that each objective was addressed and integrated into the final product. Rigorous testing and iterative refinement further validated the system\'s performance and functionality. The proponents\' commitment to thorough research and development has culminated in the realization of a solution that aligns with the intended objectives, providing a robust and effective system that meets the needs of its users.', NULL, NULL),
(52, 2, 'RECONSTRUCT: A WEB-BASED MARKETPLACE AND GEO-FINDER OF CONSTRUCTION AND DEMOLITION RECYCLABLE MATERIALS', '12', 'Bachelor of Science in Information Technology', 5, '2023', 'In construction or demolition activities, such as road building, bridge construction, renovations, and similar projects, waste is inevitably generated. This waste comprises mainly non-biodegradable and inert materials like concrete, plaster, metal, wood, and polymers. Around 30% of the solid waste generated by the construction industry ends up in landfills. To address this issue, the researchers aim to develop reConstruct, a web-based marketplace for recycled construction and demolition (CCD) waste. Most of the CCD waste is recyclable. reConstruct can help encourage recycling and, at the same time, make this waste profitable. reConstruct is a user-friendly marketplace for budget-conscious buyers, sellers of recycled CCD materials, and local architectural antique dealers. In the development of this study, the researchers employed RAD (Rapid Application Development), a methodology that emphasizes rapid prototyping and the integration of user feedback to meet user expectations. The study yielded various components, such as a management dashboard for administrators, buyers, and sellers, a platform for buying and selling of recycled CCD waste, a subscription-based business model, an inter-messaging feature, a Geotagging method for pinpointing locations on the map, visualization of saved CCD waste, and the display of data reports. During the user acceptance test, it demonstrated high satisfaction and usability, confirming the successful implementation of the platform features. The integration of a marketplace for buying and selling recycled construction and demolition (CCD) waste offers substantial benefits to both the construction sector and the environment. By providing a centralized platform, it facilitates connections between buyers and sellers, thereby increasing the demand for recycled materials and establishing an efficient and cost-effective supply chain. Additionally, the platform serves as an alternative solution for the disposal of CCD waste, preventing it from ending up in landfills and providing environmental benefit.', NULL, NULL),
(53, 2, 'AEGUIDE: AN AUGMENTED REALITY AND SIMULATION BASED WAYFINDING FOR MILD INTELLECTUAL INDIVIDUALS', '19', 'Bachelor of Science in Information Technology', 6, '2023', 'This capstone project helped people with mild intellectual disability who are specifically struggling with their navigational skills and taught them how to master wayfinding in public spaces. The researchers have found that it is vital that they are taught basic navigation so that over time they can become completely independent in public and confident with their wayfinding skills. The researchers have developed a mobile application that served as a navigation tool that assisted users with mild intellectual disability on how to navigate in public areas. Navigation is taught to them through the augmented reality and simulation features that are available in the app. The person with mild intellectual disability only has to choose whether they would like to use the augmented reality arrow or the street simulation to aid them with their planned trip. The augmented reality arrow directs the user where to turn until they get to their destination. The street simulation showed the street names and buildings that the user will encounter in their journey. All of these features are possible with the use of Google API services. The parents, legal guardians or primary caregivers are also users of the app. They are able to monitor in real-time the location of the child with mild intellectual disability under their care, and the app also has a push notification feature that notifies the parent once their child has arrived at their destination. With the shared efforts and patience, the researchers were able to develop the proposed mobile application. The mobile application can be developed further or updated to improve and provide more assistance towards people with mild intellectual disability here in the Philippines.', NULL, NULL),
(54, 2, 'BAGSAKAN: AN ANTI-E-COMMERCE FRAUD PLATFORM FOR CROP BIDDING TRANSACTIONS OF SMALL-SCALE FARMER AND VENDOR', '14', 'Bachelor of Science in Information Technology', 6, '2023', 'Farmers play a vital role in our economy, but many small-scale farmers struggle to generate sufficient income to cover their capital expenses. Additionally, they often face challenges such as crop spoilage and wastage. To address these issues, the proponents have developed a secure e-commerce application based on a bidding process. This platform allows end-users to post and bid on wholesale products, providing them with higher profit opportunities. To ensure the integrity of the developed bidding application, the proponents have identified and addressed key e-commerce frauds that have the potential to disrupt the process. Specifically, the application focuses on countering pagejacking, supplier identity fraud, and bait and switch fraud. By recognizing the critical components where fraud is likely to occur, the proponents have implemented security measures and functionalities to mitigate these risks. In summary, the proponents have developed a secure e-commerce application that aims to support small-scale farmers by offering a bidding platform for wholesale products. Through the process of gathering data and pilot testing of common e-commerce frauds such as pagejacking, supplier identity fraud, and bait and switch fraud, the application incorporates security measures and countermeasures such as authentication using an SMS OTP through an API call, report method, and name duplication detection in registration and profile info editing to ensure an efficient environment for users.', NULL, NULL),
(55, 2, 'DAYR: A MENTAL HEALTH SELF-MONITORING APPLICATION', '1', 'Bachelor of Science in Information Technology', 8, '2023', 'Mental health affects 13% of the world\'s population. Mental health disorders or illnesses are complicated and can manifest themselves in various ways. Including depression, anxiety, eating disorders, bipolar disorder, and schizophrenia. Mental Health plays a crucial role in achieving global development goals, as indicated by the inclusion of mental health in recent years. Despite improvements in some nations, people with mental illnesses are frequently subjected to severe human rights breaches, discrimination, and stigma. Mental health issues can be adequately treated at a low cost. A technique to release any tension that keeps a person from feeling happy is to write in a diary or journal. The researchers aim to develop a mobile application that will act as a trusted friend or companion for people suffering from mental health illnesses. Individuals can use the application to write about their anxieties, burdens, and feelings like traditional journals do. It has also been thoroughly explored how writing can be therapeutic, both for evoking personal reflection and for self-help knowledge.', NULL, NULL),
(56, 2, 'PROJECT TAPPERWARE: A SYSTEM FOR DETECTION OF UNAUTHORIZED ELECTRICITY CONNECTION BASED ON IOT-ENABLED ELECTRICITY METER', '1', 'Bachelor of Science in Information Technology', 5, '2023', 'Illegal electrical tapping refers to stealing electrical consumption not to have to pay the bills for electrical utilization. It does not just impose a risk of physical consequences but also violates the security of the data involved in the electricity metering process. These illegal electrical connections are not detected immediately; hence, risks are not mitigated as soon as possible. This project is concerned with developing a faster illegal electrical connection detection technology to strengthen information security in the subject matter and prevent its physical consequences. With the Internet-of-Things, this project involves the development of an IoT-enabled electricity meter with an illegal electrical connection detection feature that allows a user to monitor consumption remotely. A residential miniature with simulated theft initiation was developed to test the project\'s effectiveness in reaching the goal. Comparative current data method was utilized to identify theft, and fundamentals of electricity consumption computing were utilized to monitor usage. System outputs were shown on the mobile application, including a theft detection report and real-time graphical representations of electrical consumption.', NULL, NULL),
(57, 2, 'E-CRUNCH: A MOBILE APPLICATION OF BASKETBALL COACH\'S ASSISTANT DECISION SUPPORT SYSTEM', '29', 'Bachelor of Science in Computer Science', 6, '2020', 'Basketball is a standout amongst the most prominent games on the planet, which conveys a ton of satisfaction to individuals in their day-to-day life. It\'s a sport where the coach\'s decisions play a fundamental role in the game and which in turn creates pressure on the coach\'s decision-making capability. Since data is available almost everywhere, utilizing available data can be a gateway to new solutions and opportunities. Our dissertation addresses the question of how utilizing data can help the coach in the court where a lot of potential helpful data is available, data driven coaching is a solution that can significantly help the coach on his/her decisions especially at crunch time where the pressure might affect a coach\'s mentality and decisions. The mobile application, E-Crunch, suggests basketball plays and displays the probability of success of the said play, which helps the coach in creating a data backed decision.', NULL, NULL),
(58, 2, 'KeyMouTion: A WINDOWS-BASED PROGRAMMING TOOL FOR DETECTING BOREDOM AND FRUSTRATION WHILE PROGRAMMING IN ASSESSING TEACHER-STUDENT RELATIONSHIP', '20', 'Bachelor of Science in Computer Science', 5, '2020', 'Programming is challenging for novices. Hence, it is important that help must be provided once the students get discouraged. The lack of intervention from the teacher is one of the reasons why students choose to disengage from their programming task and eventually drop out from the course. It is for this reason that the proponents aimed to develop a programming tool that collects data every 10 minutes and after an hour detects student frustration and boredom in real-time, where teachers can be given a cue when to provide immediate feedback to the students. Keystrokes and mouse movements are collected and analyzed as studies have shown that student affect can be reflected from them. The Circumplex model was used as the framework to determine which quadrant of arousal and valence does boredom and frustration belong to. Due to the COVID-19 pandemic, no actual student testers were gathered so the proponents were left with no actual data to run the model. Instead, a proposed framework was used to determine whether the keystroke combinations, mouse behaviors, and other activities tantamount to boredom or frustration. A user interface was designed for teachers where they can monitor the student keyboard and mouse activities. The interface includes a display that indicates if the student needs to be monitored or if the student needs help already as indicated by his/her boredom and frustration levels. To acquire valid results, it is recommended that the experiment is conducted in actual programming laboratory settings. The system can be installed on the students\' computers and be run in the background as they work on their programming tasks. The teacher\'s module can be installed in the teacher\'s computer so that they can completely monitor their student activities. It is also recommended that camera devices be installed as well as correctly validating the effect experienced by the students.', NULL, NULL),
(59, 2, 'ON THE SUITABILITY OF CACAO UNDER FUTURE CLIMATIC CONDITION IN THE PHILIPPINES: A NEURAL NETWORK MODELLING', '19', 'Bachelor of Science in Computer Science', 7, '2020', 'This study was conducted to investigate the effect of climate change in relation with the cacao suitability in the Philippines. Climatic data are extracted under near-current periods (1970-2000), 2030s (2020-2049), and 2050s (2040-2069), and changes in cacao suitability were assessed using Artificial Neural Network (ANN) modelling approach. The best model indicated that the land index for cacao suitability is between 49.51 to 79.31 for near-current; 48.36 to 75.86 for 2030s and 48.00 to 74.34 for 2050s. This categorizes the suitability class of cacao into marginally suitable (S3) to highly suitable (S1) for the near-current and 2030s periods while dropping to only marginally suitable (S3) to moderately suitable (S2) by 2050s. Specifically, across the high suitability (S1) areas in the Philippines, there is a projected decrease from 65,853 km2 (near-current) to 31,357 km2 by 2030s and 23,458 km2 by 2050s; a change by -9.84% and -12.1% for the future periods, respectively. Regions of Luzon (excluding Palawan), Palawan, Visayas, Western Mindanao, and Southern Mindanao will experience a decrease in its S1 areas which is primarily attributed to the projected increase in mean and max temperature and rainfall variability in the future. The most pronounced change is measured in Western Mindanao with -84.26% followed by Luzon with -80.18% by 2050s. Moreover, the results indicated that ANN approach was able to perform cacao suitability prediction with satisfactory results of a Mean Square Error (MSE) of 3.74e-6 and correlation of determination of 0.99981414.', NULL, NULL);
INSERT INTO `research` (`researchID`, `uploadedBy`, `researchTitle`, `researchAdviser`, `program`, `publishedMonth`, `publishedYear`, `researchAbstract`, `researchApprovalSheet`, `researchManuscript`) VALUES
(60, 2, 'SNAPDRIVE: AN ALTERNATIVE SECURITY SYSTEM FOR MOTORCYCLE THEFT PREVENTION VIA FACE RECOGNITION USING A MODIFIED LOCAL BINARY PATTERN HISTOGRAM ALGORITHM WITH BLINK DETECTION ON RASPBERRY PI', '27', 'Bachelor of Science in Computer Science', 3, '2021', 'The problem of motorcycle theft has been never-ending and is regarded as a property crime with one of the highest occurrences, primarily due to characteristics that make motorcycles easy to steal. Many methods have been introduced, yet they have proven insufficient to prevent motorcycle theft. Therefore, the proponents seized this opportunity to propose a study and develop the SNAPDRIVE device and mobile application. SNAPDRIVE consists of two main components: hardware and software. The hardware component includes various peripherals, such as a camera, all attached to a Raspberry Pi, which serves as the central processing unit. By detecting motion, the system activates and begins facial detection using Haar Cascade. Once a blink is detected via Eye Blink Detection using Facial Landmark, an image is captured and undergoes facial recognition using Sparse Local Binary Pattern Histogram. If the face is recognized, the motorcycle is enabled. Otherwise, the owner is notified of the attempt through the software component, a mobile application linked to the device in real time. The mobile application serves as a dynamic and vital tool for inputting and viewing relevant data, as well as receiving notifications transmitted through a cloud server. However, for testing purposes, the proponents used a DC motor instead of an actual motorcycle. The purpose of this system is to provide both proactive and reactive measures to prevent motorcycle theft. With such a system in place to secure the motorcycle from being enabled, it will help deter thieves from pursuing the criminal act. Additionally, this research aligns with the government\'s efforts to reduce criminality. The proponents employed the Waterfall methodology in the development of SNAPDRIVE, as this project required a sequential process to accomplish. Ultimately, the objectives of the proponents were met.', NULL, NULL),
(61, 2, 'SEMANTIC SEARCH ENGINE OF E-COMMERCE USING NATURAL LANGUAGE PROCESSING', '20', 'Bachelor of Science in Computer Science', 6, '2022', 'Most e-commerce platforms today still use traditional keyword-based search engines on their websites. With a wide variety of products available online, retrieving relevant and appropriate products from a database has become a challenge. This issue can be addressed through a technique called semantic searching, a data retrieval method that considers the meaning of words, substance, context, intent, and concept of the query. In this study, the researchers aimed to develop a semantic search engine, apply Natural Language Processing (NLP) methods to improve product searching, and deploy the search engine over the Internet. The Amazon dataset was used in the study, preprocessed, and loaded into the Elasticsearch database, where users could conduct semantic searches. Flask was used to create a web application, while Ngrok was utilized to deploy the application online. Fifteen respondents from various universities participated in testing the semantic search engine and completed a survey. Each respondent performed five semantic search queries and counted the false positives in the search results. Upon testing and evaluation, the search engine achieved an accuracy of 87.3%. The study identified inadequate product titles and product categorization issues as primary causes of high false positive counts for certain search queries. Additionally, the lack of product images may have influenced respondents\' perceptions of the relevance of search results. For future research, the researchers suggested refining product categorization by incorporating additional NLP techniques, such as ontologies, and exploring Machine Learning Classification to further enhance search accuracy.', NULL, NULL),
(62, 2, 'DETECTING COVID-19 FAKE NEWS INFODEMIC USING HYBRID ALGORITHM', '2', 'Bachelor of Science in Computer Science', 6, '2022', 'Fake news on social media and other forms of media is widespread and remains a primary concern due to its potential to cause significant social and national harm. This phenomenon persisted amid the COVID-19 pandemic, where public opinions and attitudes played a crucial role in shaping appropriate public health responses. Despite the major challenges posed by the pandemic, the infodemic—the rapid spread of misinformation—continued to be a serious issue. This study aims to develop a hybrid model to distinguish fake news from legitimate news regarding COVID-19-related issues on Twitter. The proposed hybrid model was implemented with a 50/50 weighted average of knowledge-based news content and stance-based social context models. To evaluate the performance of the models, accuracy, F1-score, and AUC curve were used as key indicators. The detection accuracy of 66.93% demonstrated that the proposed LR-RF model outperformed all other baseline models in identifying fake news.', NULL, NULL),
(63, 2, 'A HYBRID MACHINE LEARNING MODEL USING COMPUBOX DATA FOR PREDICTING BOXING FIGHT OUTCOME AND WINNING CONDITION WITH BOXER STYLE CLUSTERING', '16', 'Bachelor of Science in Computer Science', 6, '2022', 'The Philippines has excellent potential in boxing, but in recent years, it has faced more disappointments than victories, primarily due to the lack of resources invested in its boxers. To address this issue, boxers must enhance their performance and gain enough popularity to attract investments from private organizations. As a solution, this study aimed to assist boxers and coaches by developing a model that helps create optimal training plans through historical data analysis. By analyzing both the boxer and their opponents, the model predicts match outcomes and winning conditions using the Support Vector Machine (SVM) algorithm and identifies boxing styles through the K-means clustering algorithm. The prediction models demonstrated strong performance despite an unbalanced and incomplete dataset from CompuBox. The fine-tuned models achieved 97% accuracy in predicting winning conditions and an 88% F1-score for match outcomes. For validation, the model attained 90% accuracy in predicting winning conditions and a 69% F1-score for match outcomes. Among 173 data points, the clustering model identified 55 boxers and their respective styles. The results revealed that boxers use a variety of styles throughout their careers. The study categorized boxing styles into Swarmer, Slugger, and Outboxer. These findings provide coaches with valuable insights into their boxers\' aptitude and style, enabling them to strategically plan and develop winning tactics. By leveraging this model, boxers and coaches can enhance training programs, ultimately improving a boxer\'s chances of success in matches.', NULL, NULL),
(64, 2, 'A PREDICTIVE MODEL FOR SEA LEVEL RISE IN PHILIPPINE URBAN AREAS WITH AN INTERACTIVE MAP VISUALIZATION', '20', 'Bachelor of Science in Computer Science', 5, '2023', 'Sea levels in the Philippines are rising three times faster than the global average, posing a significant threat to coastal communities. To address this issue, a predictive model was developed using the Random Forest Regression Algorithm, which processes various data attributes contributing to sea level rise. To optimize the data, different preprocessing techniques were applied, including feature selection, feature engineering, feature scaling, and hyperparameter tuning. The model\'s performance was evaluated using several metrics, achieving an R-Squared score of 0.88, a Mean Absolute Error (MAE) of 2.9, a Mean Squared Error (MSE) of 10.90, and a Root Mean Squared Error (RMSE) of 3.30. The model identified that greenhouse gases—particularly carbon dioxide and methane—are the most significant factors in predicting sea level rise. The prediction results concluded that sea levels are expected to rise by over one foot (0.33 meters) in urban areas by 2050. To support policymakers and researchers, the results were visualized in an interactive map that displays projected sea level changes in selected Philippine coastal urban regions.', NULL, NULL),
(65, 2, 'DETECTING POTENTIAL FISHING ZONES WITH PROBABLE TOTAL CATCH USING FEATURE EXPLORATION AND MACHINE LEARNING', '20', 'Bachelor of Science in Computer Science', 5, '2023', 'Fisheries are exposed to anthropogenic risks, oceanic destruction, and various weather changes, making the process of locating fish shoals time-consuming and resource-intensive. This results in high costs, low profits for fishermen, and adverse effects on their socio-economic status. Hence, researchers were encouraged to adopt machine learning in detecting Potential Fishing Zones (PFZs). This study aimed to develop a predictive model for detecting PFZs by analyzing various sea features as potential predictors, forecasting probable fish catch quantity, and identifying seasonal fish catch behavior patterns along with visual representations. The study employed a feature importance function to determine the significance of different predictors, and classification machine learning algorithms were used to construct the models. Secondary data from India were utilized for training, while data from the Visayan Sea, Philippines, were used for testing the models. The researchers applied the ARIMA model to forecast probable fish catch quantity, seasonal variations, and trends. According to the feature importance scores, Salinity and Sea Chlorophyll were identified as the most significant sea features, with optimal threshold values of 32.6 parts per thousand (ppt) and 0.18 milligrams per cubic meter (mg/m3), respectively. Among the machine learning models, Random Forest demonstrated the highest accuracy score of 80.56% in predicting PFZs. The ARIMA model parameters were set to p = 5, d = 0, and q = 4, as this configuration resulted in the lowest AIC value of 1458.217, making it the best fit for forecasting. The ARIMA model successfully forecasted probable fish catch quantities on a quarterly basis for the years 2021–2026, highlighting the seasonality and trend of fish catch. The study\'s findings can contribute to improving fishing methods and resource management. However, the forecasted fish catch exhibited a declining trend over time due to potential sources of uncertainty. Despite this limitation, the researchers successfully met their objectives of detecting PFZs, forecasting probable fish catch, identifying seasonal trends, and providing valuable insights for the fishing community.', NULL, NULL),
(66, 2, 'PREDICTING WATER QUALITY USING MACHINE LEARNING IN AN AQUACULTURED ENVIRONMENT', '18', 'Bachelor of Science in Computer Science', 5, '2023', 'Over the course of recent decades, the aquaculture industry has been growing at an exponential rate with their annual production. The overly increasing growth in human population has also increased the demand for consumption of aquatic products. As a result, several countries have resorted to aquaculture to meet their aquatic product needs. Fish just like any other animals have such specific physical and chemical needs that if these needs aren\'t supplied, the animals become stressed, and their health and survival are threatened. Water quality is composed of different components such as temperature and pH level and sudden changes on these variables proves to cause stress to fishes, can slow their growth, delay their reproduction and in the worst case scenario can cause death. A comprehensive study of the effects of stress in aquaculture management is crucial to grasp how it can result in reduced yield and subsequent financial loss. This study aims to know the condition of the aquacultured environment by determining the quality of water where the fishes are living. The researchers in this study developed three models that determined if the water quality is fitting for the aquacultured fish using SVM, KNN, and Decision Tree algorithm. The dataset was split by 70/30 and all the models were fine tuned using gridsearchCV for the model to have the best parameter for training. The DT performed best with a 98.17% accuracy and F-Score of 98%, while SVM placed second with a 82.83% accuracy and F-Score of 69% and the K-NN model had he worst performance among the three with a 76.66% accuracy and F-Score of 62%. This study concluded that the three prediction models were able to perform well but the decision tree model was the best performing one, thus contradicting other research studies that had SVM as the best performing model.', NULL, NULL),
(67, 2, 'AUTOMATED SEMANTIC SEGMENTATION OF CANCEROUS CELLS IN MAMMOGRAM IMAGE USING NOVEL HYBRID CONVOLUTIONAL NEUTRAL NETWORK TECHNIQUES', '18', 'Bachelor of Science in Computer Science', 6, '2023', 'In the Philippines, breast cancer holds the distinction of being the most prevalent cancer among women [92]. As per data from the PSA and the Department of Health, roughly 3% of Filipino women are likely to receive a breast cancer diagnosis during their lifetime. Remarkably, in February 2017, the Philippine Obstetrical and Gynecological Society reported the highest incidence of breast cancer in the Philippines among 197 countries [95]. Mammography has proven effective in identifying even early-stage breast cancers [3], making annual screenings crucial, particularly for women over 40. However, the accuracy of mammograms can be compromised due to variations in breast tissue, occasionally leading to false- negative results [94]. Consequently, monthly self-examinations remain vital. Artificial Intelligence (AI) can enhance the diagnostic precision of mammograms. The ability of AI to process and interpret complex patterns in imaging data makes it a powerful tool for detecting subtle abnormalities often missed in manual screenings [96]. AI\'s potential to reduce false negatives could significantly improve early breast cancer detection, complementing mammography and monthly self-examinations, thereby improving prognosis and survival rates. This study attempted to construct a novel hybrid model that segments cancerous cells in breast mammogram images. The researchers exhausted all the resources and searched all research databases and concluded this approach is novel as of this writing. The proposed hybrid model, substituting Resnet 152 on the Encoder block of Nested Unet (Unet++) model, was implemented. Intersection Over Union, DICE, and Binary Cross Entropy with Logits loss are used as indicators to measure the segmentation performance of the model. Custom Pre-Processing, Data Augmentation, Hyperparameters, and Fine Tuning was utilized in the study. The researchers achieved an accuracy as high as 95% with a mean and median detection score of IOU (67.57%) and DICE (68.40%), experimental results showed that the proposed model did great with limited dataset and did not overfit or underfit according to Koehrsen [85]. In future work, the researchers recommend the following: adding more high-quality Data of Mammogram Images with Verified Pathological Ground Truth Masks could be used. To further improve the IOU and DICE scores of the model, a more thorough tweaking plus experiments should be conducted of the hyperparameters or Fine tuning to see what the best practices for this type of problem is. Try using more simpler Data Augmentation Techniques and experiment if it will achieve higher segmentation accuracy without the risk of Overfitting. Not every photo will behave properly for the model. Different DICE or IoU scores tell the researchers that every image has a different degree of variability and could impact on how well the model performs. The researchers recognize these outliers and ascertain the reason for them. Are they the result of inadequate annotation, or does the model struggle with specific types of images? Such inquiries may help future researchers.', NULL, NULL),
(68, 2, 'CLASSIFYING CAVENDISH BANANA MATURITY STAGE USING RESNET-18 ARCHITECTURE AND TRANSFER LEARNING', '4', 'Bachelor of Science in Computer Science', 5, '2023', 'Banana maturity is vital in determining the fruit\'s marketability. Hence, growers must carefully identify mature banana fruits to maximize profit. There have been attempts to automate the classification of banana maturity stages; however, the current models require a long time to train the dataset, harming the model\'s efficiency. Recent studies applied transfer learning in classification models to improve model efficiency regarding training time and accuracy. Anchored on these works, this research utilizes transfer learning in the ResNet-18 architecture to build a model recognizing the various stages of Cavendish banana maturity. In the 10-fold cross-validation, the model\'s accuracy was higher than that of a CNN-based model; however, its training time is higher. When evaluated on unseen data, the model performed better than the CNN-based model. Furthermore, a basic web-based app was developed to evaluate the model using a locally sourced dataset. Results show that the ResNet-18-based model outperformed the CNN-based model in identifying the Cavendish bananas\' maturity stages. This demonstrates that a classification model based on ResNet-18 architecture with transfer learning was an efficient approach to fruit classification.', NULL, NULL),
(69, 2, 'DeVICE: PREDICTION AND ANALYSIS ON THE SUBSTANCE ABUSE OF ADOLESCENTS IN POBLACION DISTRICT, DAVAO CITY', '19', 'Bachelor of Science in Computer Science', 5, '2023', 'The study focuses on providing predictions and analysis for the local government in the Poblacion District barangays, aiming to raise awareness and facilitate health care programs, drug prevention, and rehabilitation efforts. By utilizing neural networks, specifically the Dense layer, the study aims to predict future trends in substance abuse among adolescents. The results have been presented graphically, allowing for easier understanding, and geographic maps were generated to visually depict substance abuse intensity across different regions. Statistical reports, including charts and graphs, have been compiled based on provided datasets, covering factors such as gender ratio, rates among different age groups, and the progression of substance abuse among young individuals in recent years. Overall, this study provides valuable insights and tools for informed decision-making and proactive measures against adolescent substance abuse for the local government and society.', NULL, NULL),
(70, 2, 'DURIO: AN API-BASED ANDROID MOBILE APPLICATION FOR DETECTING INFECTED AREAS IN DURIO ZIBETHINUS PODS', '20', 'Bachelor of Science in Computer Science', 5, '2023', 'Durio: An API-based Android mobile application for detecting infected areas in Durio Zibethinus pods. Three models were created and compared: RGB + UNet, GLCM + UNet, and RGB + GLCM + UNet model. Among these models, the RGB + UNet model demonstrated the highest proficiency in identifying the infected area with an IoU score of 85.46%. Notably, the model also exhibited its potential for early detection of durian diseases, as the results found that it was able to identify the disease before the expert did. Thus, it was selected as the final model to be integrated into the API-based mobile application. Moreover, the researchers also performed the Wilcoxon Signed Rank Test, which indicates the differences between the severity index estimates of the model and the expert. The result shows a p-value of 0.1152 which indicates that the annotations are aligned in terms of identifying the infection level. A second level of testing was also conducted to evaluate the mobile application\'s severity index estimation. The results revealed that the severity index estimation provided by the application was comparable to the estimations made by the human expert.', NULL, NULL),
(71, 2, 'AUTOMATED CRYPTOCURRENCY TRADING BOT USING MACHINE LEARNING MODEL ENSEMBLE', '2', 'Bachelor of Science in Computer Science', 5, '2023', 'Cryptocurrency has emerged as an influential force in the global financial system and has become a popular financial investment due to its decentralized and secure digital transactions. However, its volatile nature rendered it a complex asset to manage. Using statistical models and recent machine learning algorithms, automated trading strategies were employed to assist investors in managing volatility while mitigating the influence of human bias and sentiment. This study uses ensemble learning techniques to develop a bot for automated trading for leading cryptocurrencies, such as Bitcoin, Binance, and Ethereum. Three kinds of ensemble models (i.e., Bagging, Boosting, and Stacking) were tested for significance against sixteen different base learner models through conventional performance metrics. Analysis showed that the Naive-LR-NBeats stacking combination achieved the highest performance for Bitcoin with 3.14% MAPE, while ARIMA-NBeats and LR-NBeats combination had the highest performance of 2.72% and 3.51% MAPE for Binance and Ethereum, respectively. The selected ensemble models were then associated with the Buy-Low-Sell-High strategy to develop the trading bot. Backtesting and simulations were carried out using historical price data to determine the performance and profitability of the bot in a trading scenario. In general, the trading bot for the three currencies had a satisfactory performance suited for swing traders who capitalize on small-scale market opportunities and capture short-term gains, generating 3–17% investment returns and above-average win-loss ratios.', NULL, NULL),
(72, 2, 'DETECTION POTENTIAL FISHING ZONES IN DAVAO GULF: AN APPLICATION OF GEOSPATIAL MODELING ON REMOTELY SENSED DATA', '10', 'Bachelor of Science in Computer Science', 5, '2023', 'The Philippines contributes significantly to global fish production, producing over 4 million metric tons in 2018 and 2019, benefiting the economy and people\'s way of life. The Philippines uses a variety of fishing techniques to capture various fish species. However, traditional methods are being used with little focus on maximizing efficiency. This study provides a theoretical and scientific approach to selecting fishing locations in the premises of Davao Gulf through the application and utilization of Geospatial Data Science. Davao Gulf is split into ten different sectors for ease of locating the different potential fishing zones (PFZ). The variables within this study are Sea Surface Temperature (SST), which determines how suitable a fish\'s habitat is, Thermal front, and Sea Surface Chlorophyll-a Concentration (SSCC) which determines the suitability of a fish\'s habitat. The researchers used interpolation models, including Nearest ND, Inverse Distance Weighting, Ordinary Kriging, and Universal Kriging, to analyze the data. The results of the model evaluation show that Universal Kriging is the best model based on Root Mean Square Error, Mean Standard Error, and Mean Absolute Error values. Simple Additive Weighting was used to calculate Potential Fishing Zones (PFZ) values, which were utilized to map the points and clusters of the PFZ within Davao Gulf. The study identified that January and May have the largest area of High PFZ. The result indicates that sector 10 encompasses the largest area based on annual aggregated data in square kilometers. The study also communicates the results through a dashboard application. Fishermen can use this information to improve catch and efficiency by choosing better fishing locations.', NULL, NULL),
(73, 2, 'IDENTIFYING LIBRARY SERVICE DESIGN MODELS OF PUBLIC LIBRARY FOR YOUTH DEVELOPMENT', '5', 'Bachelor of Library and Information Science', 5, '2020', 'This study deducted different public library resources, services, and programs which was anchored on library service design model that is applied and practiced by a public library. Library service design model is a setting or approaches specifically devoted towards serving the masses. Limited studies have engrossed on library service model, and discovering this facet of public libraries provided a thorough understanding on how certain public libraries contribute towards progressing youth development in the surface of their learning, academe, reducing juvenile offenders and out-of-campus youth or individuals, which are primarily the motivations for the researchers\' subject matter. This paper also detailed different library resources including books, databases, electronic and audiovisual materials among other resources; services such as internet, information, lending, and reference services; and programs including reading programs, trivia, podcasts, online ready references, and others, anchored from the results gathered among the youth ages thirteen to nineteen, their preferences, and the Tagum City Library and Learning Commons general data on these variables present in the library space. This paper concluded that the existing library service design model must continually be improved and alleviated and must be enabled in serving different people in all walks of life, especially the youth in the community, and it must be conforming to the changing world and literacy.', NULL, NULL),
(74, 2, 'THE CHANGING ROLES OF LIBRARIANS TOWARDS PATRONS WITH SPECIAL NEEDS: THE CASE OF SELECTED LIBRARIES IN DAVAO REGION', '17', 'Bachelor of Library and Information Science', 6, '2022', 'As the purpose of libraries changed over the years due to tremendous changes in the field, the capabilities of librarians have compounded to serve all patrons, including those with special needs. This study sought to examine the librarians\' existing strengths and indicate areas with challenges to provide an opportunity for success in dealing with patrons with special needs. This study utilized a quantitative-descriptive design and employed an adapted survey questionnaire. The researchers collected data from the respondents of the selected libraries in the Davao region to determine their current roles, skills, knowledge, accommodations, modifications, and services, as well as their perceived proficiency in facilitating patrons with special needs. The results of this study showed that the majority of the current roles of the respondents are librarian, which consisted mostly of both licensed librarians and those with only a degree in library and information science. Most respondents indicated that they offer large print books, wide aisles for wheelchair access, and repetition of instruction for patrons with special needs. All respondents surveyed had perceived sufficient skills and knowledge in serving these patrons. Lastly, the respondents believe that their duty to competently practice the best in serving patrons with special needs is sometimes this competent.', NULL, NULL),
(75, 2, 'DIGITAL RIGHTS MANAGEMENT ON THE ONLINE DATABASE OF THE USEP LIBRARY: A CHALLENGE FOR LIBRARIANS', '13', 'Bachelor of Library and Information Science', 6, '2022', 'Library online database is one of the essential tools for online library support for patrons\' educational and research needs. However, librarians and students are challenged with the corresponding access limitations of online databases according to the Digital Rights Management (DRM) guidelines. This research identifies the restrictions and limitations of ODILO. Specifically, it discusses the challenges of librarians in providing information needs and demands with the constraints imposed by the DRM guidelines. The study employed a qualitative research method conducted through Google Forms and adopted the connectivism theory by George Siemens. The results show that the ODILO database consists of four significant restrictions and limitations in accessing library online collections. Additionally, the study shows that using the ODILO system has both positive and negative effects on librarians. The positive side of the response reflects their personal preferences when accessing the system, while the opposing side represents how the library must follow DRM guidelines. Lastly, the study indicates that the restrictions and limitations of the ODILO database are ineffective in preventing the illegal reproduction of materials. To successfully integrate ODILO in the library, librarians should choose implementation schemes based on functionality and effectiveness of the ODILO database.', NULL, NULL),
(76, 2, 'InProperR: INTELLECTUAL PROPERTY RIGHTS OF UNPUBLISHED MATERIALS', '3', 'Bachelor of Library and Information Science', 6, '2022', 'This qualitative study explores the factors that contributed to the Intellectual Property rights on copyright and fair use practices of graduate students of the University of Southeastern Philippines, College of Education Graduate School. This study was conducted to identify awareness and knowledge levels on Intellectual Property practices, determine the library\'s approach in enforcing fair use and copyright according to the degree of access to materials, and enumerate significant purposes for accessing unpublished materials. This study adopted the steps of design and implementation, which are composed of processing and recording the data, data analysis, data presentation, and verifying and conclusion drawing. These steps help in attaining the results of this study. Furthermore, this study utilizes non-probability sampling on a sample in which the data are collected, specifically a purposive sampling that is more appropriate for the study. Using a self-made questionnaire administered through Google form, the study shows that library exercises, balance copyright, and fair use were conducted on fifteen (15) respondents, which is relevant to the target sample size of the study. All the responses to the survey were answered by graduate school bonafide students from the College of Education of the University of Southeastern Philippines, Main Campus. Four (4) of the respondents were from the Master of Education Program, and the eleven (11) were from the Doctor of Education Program. Given the library\'s policy of ten percent (10%) accessibility of the work for online and electronic copies of theses and dissertations gives the user the rights and balances copyright and fair use. In contrast, some respondents are not in favor and are not satisfied with having a limited portion of materials accessible since the materials are available in the library. On the other hand, all respondents clearly and concisely understand how copyright and Fair Use works based on the ideal concept and definition of copyright and fair use from an international governing organization for intellectual property. They thought that the nature of almost all theses and dissertations were published, therefore, should be highly accessible to the library user. Lastly, significant factors of accessing the unpublished resources in the library are solely for academic, scholarly, and commercial purposes. The study concludes that Participants awareness of the intellectual property of unpublished materials was considerable assenting to the relevance of both fair use and copyright policy concepts.', NULL, NULL),
(77, 2, 'ACCEPTABILITY LEVEL OF COLLEGE OF INFORMATION AND COMPUTING STUDENTS ON ONLINE LIBRARY SERVICES AT UNIVERSITY OF SOUTHESTERN PHILIPPINES IN TIMES OF COVID 19 PANDEMIC', '11', 'Bachelor of Library and Information Science', 6, '2022', 'COVID-19 forced almost all colleges and universities in the Philippines to go online in the spring of 2020, making it difficult for academic libraries to continue providing vital services to students. The key purpose of this study is to determine whether online library services are available to College of Information and Computing students to assist them during the COVID-19 pandemic and to determine if the services are meeting the demands of their students during a period of social isolation that is due to COVID-19 and social distancing laws. Quantitative data was examined using the Statistical Package for the Social Sciences (SPSS) program. The result showed that it improves academic productivity, research education and learning saves time, and uses and gets reliable information. This service is provided to users to obtain information resources from the library through remote access, pick-up, and face-to-face delivery of printed and non-print materials. Furthermore, the study determined the usefulness and social acceptability of online library services. The findings of this study might be used to inspire more research, as well as upgrades to universities\' existing online library services and implementation instructions for this digital online library service.', NULL, NULL),
(78, 2, 'AN EXPLORATORY STUDY INVESTIGATING STUDENTS OUTLOOK IN PURSUING LIBRARY AND INFORMATION SCIENCE', '13', 'Bachelor of Library and Information Science', 5, '2023', 'This abstract presents the findings of an exploratory study conducted at the University of Southeastern Philippines, which aimed to investigate the outlook of students pursuing a Bachelor of Library and Information Science (LIS) course. To gain a deeper understanding of their motivation and perception, interpret and evaluate students\' career goals and expectations after completing the LIS course. The study focused on undergraduate students enrolled in the Bachelor of Library and Information Science program, specifically third-year students and fourth-year students. To gather data, a mixed-methods survey questionnaire was utilized, incorporating both closed-ended and open-ended questions. To ensure the validity of the results, several steps were followed. First, the questionnaire was developed based on a thorough review of relevant literature, which provided a theoretical framework for the study. The questionnaire was then reviewed by a panel of experts in the field of LIS to ensure its content validity. The data collected from the survey questionnaire were analyzed using both quantitative and qualitative techniques. Quantitative data analysis involved the use of descriptive statistics to summarize the closed-ended responses, while qualitative data analysis involved the identification of themes and patterns in the open-ended responses. The study identified factors influencing students\' motivation in pursuing LIS, including university contribution, course usefulness, vocational aspect, social consideration, and surrounding influence. Students faced challenges but perceived advantages in personal growth, job prospects, skills development, and diverse industry opportunities. Career goals focused on libraries and related roles. These findings provide valuable insights into students\' motivations and aspirations, emphasizing the importance of understanding preferences to enhance curriculum and support. The study contributes to a deeper understanding of students\' outlook in the LIS field.', NULL, NULL),
(79, 2, 'USeP DIGITAL LIBRARY: AN ANALYSIS OF USER ACCEPTANCE AND COMPETENCY LEVEL', '17', 'Bachelor of Library and Information Science', 5, '2023', 'This study is conducted to assess the user acceptance and competency level of the USEP Digital Library System by utilizing the Technology Acceptance Model (TAM). Using a quantitative approach, this study employed an explanatory design in gathering information from the 171 undergraduate, graduate students, and faculty respondents who have utilized the digital library system of the University of Southeastern Philippines, which were selected through the snowball sampling technique. Survey questionnaires were given to the respondents and analyzed using frequency and percentage distribution, Kruskal-Wallis test, and Spearman correlation coefficient. The results showed that the USEP Digital Library System is regarded as moderately accepted by its users, with an overall mean of 3.18 in perceived usefulness and 2.68 in perceived ease of use which denotes that the users find the digital library useful in their academic works and considered as easy to use and navigate thus enhances their academic performance. In addition, the competency level of the USeP Digital Library System is moderately competent, with a mean score of 2.30, which signifies that users have adequate knowledge of using the digital library system. The results also show that there is a significant difference on the user acceptance when grouped according to the demographic profile of the respondents and a significant relationship between the user acceptance level and the competency level of the USEP Digital Library System. However, system visibility is noticed to be partially competent which means the respondents did not consider the USeP Digital Library System to be known enough. Hence, it has been recommended that the ULRC should consider developing a Digital Library Marketing and Utilization Plan with the goal of increasing the visibility and utilization of the USeP Digital Library system.', NULL, NULL),
(80, 2, 'INDEXINATOR: DESIGNING A PROTOTYPE WEB-BASED INDEXING TOOL FOR THE UNIVERSITY LEARNING RESOURCE CENTER', '5', 'Bachelor of Library and Information Science', 5, '2023', 'This study aims to design a prototype web-based indexing tool for the ULRC\'s journal and periodical collection, with a specific focus on user interface and visual aspects. A modified Software Prototyping model guided the prototyping process, which involved three phases: design, prototyping, and user evaluation. The study employed two sets of data collection-both utilized survey questionnaires. Design ideas for the prototype\'s user interface were obtained during the first survey. The second survey served as the user evaluation of the created prototype. The survey respondents are the library community in USEP, including library users, librarians, and library staff. The first survey identified the user interface designs for the login page, user and admin account pages, bibliographic entry page, and bibliographic record page. An online prototyping tool called Figma was used in creating the prototype. The obtained user interface designs are linked together for the Indexinator prototype\'s system flow. Following the development of the interactive prototype indexing tool, a survey was once again conducted to evaluate the user interface designs based on the following aspects: navigation, color, and consistency. The study concluded with a prototype that showcases the user interface and intended features of the proposed indexing tool for the ULRC. This prototype serves as a proof of concept for the future development of a full-blown digital indexing system. The insights gained from the study contribute to the overall goal of enhancing the indexing service at the USeP ULRC.', NULL, NULL),
(81, 2, 'MANAGING THE USEP MUSEUM: A SKILL ASSESSMENT FOR ULRC PERSONNEL', '11', 'Bachelor of Library and Information Science', 5, '2023', 'The study focuses on the capability of the University of Southeastern Philippines Learning Resource Center (USeP-LRC) in managing a university museum. To determine the ULRC\'s capability in museum management, a skill assessment among library personnel is carried out. The targeted respondents are the USeP-LRC librarians and library staff assigned from Obrero, Mintal, Tagum, Mabini, and Malabog campuses. The researchers employed a descriptive correlational research design in accordance with the variables involved. Sociodemographic profile including age, sex, no. of years in service, and eligibility, and the library personnel\'s competency and skills in museum management are the data collected. A survey questionnaire was constructed and disseminated based on the museum\'s Professional Core Competency and Personal Skill Set. Among ULRC\'s library personnel, a total of 29 respondents were recorded. Study results show that in terms of Professional Core Competency, there is an overall mean of 3.598 indicating a very competent level of capability. Also, results show that in terms of Personal Skill Set, there is an overall mean of 3.230 indicating a skilled level of capability. It is concluded that ULRC personnel are capable of managing a university museum based on the combined assessment results from the two indicators with an overall mean of 3.414. Furthermore, results show that in the areas of Preservation, Digital literacy, and Diversity when grouped according to age indicates that there is a significant difference. On the other hand, results show that in terms of sex, experience, and eligibility there is no significant difference among the remaining competency and skills assessed. The ULRC with the coordination of its parent institution should consider developing plans for the establishment of a university museum. However, the plan should also consider conducting training in advancing the museological skills of librarians and library staff as preparation for museum management.', NULL, NULL),
(82, 2, 'EFFECTIVENESS OF MARKETING STRATEGIES IN PROMOTING PUBLIC SCHOOL LIBRARY SERVICES IN DAVAO CITY', '3', 'Bachelor of Library and Information Science', 5, '2023', 'This study focuses on the effectiveness of marketing strategies used by Davao City\'s public-school libraries in promoting their services. The study\'s focus was narrowed down to F. Bangoy National High School, Sta. Ana National High School, and Davao City National High School. The aim of this research is to identify the relevance of librarian\'s demographic profile and skills in promoting library services, the most effective strategies in promoting library for students, and the factors that affect the effectiveness of marketing strategies used by the three identified public-school libraries. The study uses the marketing mix theory and develops an IPO model suited for the study as its conceptual framework. The study used a descriptive research method and designed two different sets of structured survey questionnaire. The first set is designed for the assessment on the student\'s level of knowledge in terms of services, and their demographic profile. The second set is for librarians, which divide into: (1) the librarian\'s profile and level of knowledge in terms of ICT skills and library management, and (2) the services in the library that are available to market as well as the marketing strategies used by libraries. The librarian\'s questionnaire also included the factors that affect in promoting library services. The target population of the study included the following: a total of two library in-charge and a total of 350 students in F. Bangoy Nation High School, a total of two library in-charge and a total of 200 students in Sta. Ana National High School, and a total of two librarians and a total of 600 students in Davao City National High School. This study incorporated two methods in its sampling method: a survey of the entire population was conducted for the librarian-respondents, while the student-respondents were selected using clustered sampling technique. The student\'s population sample consisted of 5% of the population from the three public schools in Davao City that were part of this study. Major findings in the study shows that librarian\'s demographic profile affects the level of knowledge and skills in promoting library services; social media as the most effective method in marketing services and reader services as the most used library service for students; and lack of funding, lack of skills in marketing, and inadequate ICT are top issues to address to improve the effectiveness of library marketing strategies. Recommendations are given to enhance the effectiveness in marketing.', NULL, NULL),
(83, 2, 'THE LIVED EXPERIENCEs OF HEALTH SCIENCES LIBRARANS IN EVIDENCE-BASED MEDICINE', '5', 'Bachelor of Library and Information Science', 5, '2023', 'This study aimed to know and describe the lived experiences of health sciences librarians in evidence-based medicine. The motivation for conducting this study stems from the researchers\' on-the-job training. It employs a phenomenological method where semi-structured interviews through Google Forms were used to generate rich, detailed descriptions of the phenomenon. Data analysis from written responses illuminated three themes across respondents: (1) Managing healthcare information and resources effectively, (2) Perceptions, challenges, and responsibilities, and (c) Skills necessary to effectively navigate the challenges of evidence-based medicine. The study concludes that lived experiences of Health Sciences Librarians are imbued with relevance as they assist healthcare professionals or medical practitioners in locating and providing reliable resources C facilitating access, and retrieving information needed for the research studies. It was also evident that health sciences librarians were passionate about giving direct assistance and exercising patience, especially looking for references. To further stress out, they answered queries with strong critical thinking and analytical skills to satisfy the health care professional clinical questions. The study recommends the following: related healthcare disciplines can make use of the service a health sciences librarian can offer in their medical research, develop activities related to strengthening the evidence-based medicine skills of students, and eventually form part of the BLIS curriculum, establish a library service for evidence-based medicine, and there will be awareness of health sciences librarian\'s roles, duties, and responsibilities in a healthcare setting. However, future research to explore the possible impacts of gender dynamics on various aspects of librarians\' professional growth in evidence-based medicine are required.', NULL, NULL),
(84, 2, 'THE LEVEL OF UTILIZATION AND ACCESS OF SCHOOL LIBRARY: BASIS FOR AN ENHANCED READING PROGRAM', '5', 'Bachelor of Library and Information Science', 5, '2023', 'The library\'s role inside the basic education premises is to provide library resources and assistance to the pupils and teachers. The school library contains various formats of library resources and materials provided to its users. Access and utilization are aligned to the availability of school library resources, including the time the library opens and the frequency of users visiting the library. Pupils who constantly visit and utilize library resources are developing their reading skills and comprehension. Reading comprehension is vital to pupils, as their reading skills and understanding are developing and improving as they progress. The motivation for this study came from the researchers\' on-the-job training experience. A survey questionnaire instrument was used to gather data, analyze and examine the significant relationship between two variables of the quantitative correlational. Pupils\' level of utilization and access to the school library was rated as always, very often, sometimes, rarely, and never, and their reading comprehension level was rated as very proficient, proficient, moderately proficient, less proficient, and not proficient. The study shows that the availability of school library program and services influence the number of utilized and accessed library resources. Pupils who are constantly accessing and using library resources are shown to have more proficient reading comprehension than those who do not. The evidence shows a slightly positive correlation (0.264), which means there is a weak relationship between these variables. The p-value suggests accepting the null hypothesis and concluding that there is no significant relationship between variables, but it doesn\'t mean that there is no relationship at all. In the future, it suggests continuing to explore other potential factors that may influence reading comprehension and consider study\'s limitations in interpreting the results.', NULL, NULL);
INSERT INTO `research` (`researchID`, `uploadedBy`, `researchTitle`, `researchAdviser`, `program`, `publishedMonth`, `publishedYear`, `researchAbstract`, `researchApprovalSheet`, `researchManuscript`) VALUES
(85, 2, 'DATA VISUALIZATION OF BOOK COLLECTION FOR THE UNIVERSITY OF SOUTHEASTERN PHILIPPINES', '30', 'Master of Library and Information Science', 6, '2020', 'The Data Visualization of Book Collection is a web-based system intended for the University of Southeastern Philippines Librarian and Library Staff, Faculty, Student, and other stakeholders. It is a tool to identify the strengths and weaknesses of every subject in the program, serves as a monitoring system in the selection and acquisition of library resources, and assists in the conduct of collection assessment. Furthermore, this study intends to develop a data visualization of book collection through a) development of module to build a library collection per program and college; b) generate data visualization reports in term of date of publication, number of volumes, and titles, resources not used, and per program; and c) generate library collection reports classified by course. This study is anchored on the use of Modified Rapid Application Development (RAD) as a methodology that includes the planning, design and development, and implementation and testing. The system developer used the following tools in the development namely: Laravel, Pusher, GMAIL SMTP, and REST API as the backend development tools; Element UI, Bootstrap, Vue-Chart JS, ChartJs as the frontend development tools; Heroku as cloud web hosting; MySQL as server; and the other tools used are Axios, CSS, Javascript, HTML 5, and PHP. Using backend and frontend development tools, cloud web hosting, server, and other tools, the system was able to generate reports in terms of date of publication, number of titles and volumes, resources not used, and resources in specific programs in graphical format. Moreover, the system also provides an additional function, such as exporting a list of library resources per program in word format. A functionality test was conducted to fifteen (15) randomly selected respondents participated by library staff, students, and faculty of the University of Southeastern Philippines. The assessment revealed that the majority of the end-users were extremely satisfied with the system in terms of its usefulness in finding library resources per subject, generation of reports by number of volumes and titles, resources not used, by program. usefulness, and reliability of the system, systems functionalities, and capabilities, and the way the system facilitates and process data effectively.', NULL, NULL),
(86, 2, 'DESIGNING COLINET WEB PORTAL: AN ONLINE SURVEY', '20', 'Master of Library and Information Science', 12, '2020', 'The study on \"Designing COLINet Web Portal: An Online Survey\" primarily aimed to propose design features of a Web portal for COLINet. An online instrument was administered to identify the desired features of the librarians in designing the COLINet Web Portal. There were 36 (67.92%) out of 53 total COLINet members that served as respondents of the study. They responded through the online survey via a link sent to them. Their responses were consolidated and analyzed using frequency, percentage, and weighted mean. Hence, it concludes that the COLINet members agreed to include all features in Personal Services, Information Services, and Search Services of the study in creating the Web portal for COLINet. The COLINet members suggested the following additional features: calling, profile, contact, directory, notification, privacy, editing, and links in creating a Web Portal. Further, it recommends that in creating a web portal, the COLINet officers should use and includes all features in personal, information, and search services features; they should also consider the additional suggested features in creating the portal; other group of librarians should also use this study as guide in selecting features to be included in creating a portal for their organization for dissemination of information, linkages and communication; and Web portal creator and editor for COLINet should use and refer to this study as guide in creating and designing a web portal.', NULL, NULL),
(87, 2, 'MANDIA APP: AN ASSISTIVE TOOL FOR MANDAYA TO ENGLISH TRANSLATION', '5', 'Master of Library and Information Science', 12, '2020', '\"ManDia App: An Assistive Tool for Mandaya-English Translation\" is a prototype system that serves as an assistive tool that creates a text corpus for use to translate Mandaya dialect to English. The researcher\'s inspiration is that no existing tool serves as an alternative in teaching the Mother Tongue subject. This Mandaya dialect is dominant in the Eastern Coast part of the Davao Region. The development of an alternative translation tool featured text translations and included photos and audio recordings embedded in the system to enhance learners\' learning experience. The system is an offline platform that allows the learner to access the database without an internet connection locally hosted in the windows machine. Modified Iterative and Incremental Development (IID) include planning, system analysis, and design, development, and testing, and created the system can be flexible for further use. The system was created using the freeware prototyping tool called \"Justinmind\", a tool responsible for its overall features. Other tools used in the development of the system are Java programming language, NetBeans IDE, MySQL database, and PHP. During the hands-on testing, the participants responded to be satisfied with the functionality. The system is a learning reference tool for the students with added photos and audio recordings to support understanding, specially building vocabulary. The recommendations were drawn according to the specific objectives, creating a translation system that executes an assistive device with operational elements such as photos and audio for translation and interactivity. The system can be modified for future development, especially to integrate other digital assets and open for additional inputs as the system\'s content is like a dictionary for another dialect. The system can also be improved for online access and upgraded to features saving, printing, downloading capacity, and email for reproduction and distribution.', NULL, NULL),
(88, 2, 'PLAIBRARY: AN ONLINE RESOURCE SHARING OF PLAI-DRLC LIBRARY CONSORTIUM', '29', 'Master of Library and Information Science', 6, '2021', 'Over the years, resource sharing has already existed and yet it has been underutilized because of issues related to supervision, personnel requirements, and time-consuming process of the resource sharing activity. This study aspires to strengthen the way of maximizing the resource sharing capability of the Philippine Librarians Association, Inc. in Davao Region. The purpose of this study is to build an integrated electronic union catalog database from participating member libraries of the consortium, develop an interactive resource sharing platform for library consortium collection, and generate resource sharing statistics. The researcher used the Modified Random Application Development process model to design and build the system. This study conducts a sequence of analysis, prototyping and testing of the system tools, requirements, and its architecture to be used while building the system through an iterative and agile cooperation of the system developer. After the development of the system, the researcher gathered participants from the consortium for the study and because of the limited access during the pandemic there were only three schools who participated. After the approval of the three libraries, the researcher collected librarians\' profile, library collection and started to run through the system for the three participating libraries. The result of the study showed that librarians can create book collection using the platform for electronic access of union cataloging. The system also allowed to have book reservation process from students and librarian that creates an actual interaction. Further, librarians and administrators can easily generate statistics for reporting and utilization monitoring purposes. In conclusion, the study showed that resource sharing can be built from the ground up to enhance the capability of the consortium. The system was divided into three modules to determine the specific roles and privileges while using the system to manage and unify the process for actual resource sharing. Finally, the study recommends that the system will be most effective when it is used and shared by the different locations and library consortium for the Philippine Librarians Association, Inc.', NULL, NULL),
(89, 2, 'FROM MEMORY TO WEB: AN INSTITUTIONAL DIGITAL REPOSITORY FOR THE PRESERVATION OF HISTORICAL AND CULTURAL ARTIFACTS OF THE UNIVERSITY OF THE IMMACULATE CONCEPTION', '29', 'Master of Library and Information Science', 6, '2021', 'Applications to preserve resources on cultural heritage have gained new momentum these days. Archiving is the most common and effective practice in providing tremendous historical and social value in every organization worldwide. The traditional archive has experienced different challenges in managing and preserving collections. With the advent of the digital age, many of our libraries, archives, and other institutional stewards began supplementing their traditional role of preserving physical objects with new responsibilities connected with digital preservation. Despite the technology present, international, national, and local institutions are practicing traditional record management and archiving techniques. One of which is the University of the Immaculate Conception which practices a traditional way of managing its archives. This study aspires to provide support in developing a digital repository to preserve the historical and cultural artifacts of the university. This study aims to establish a digital repository system that can manage digital content and metadata for historical and cultural artifacts preservation. The designed system provides a venue for users to browse, download needed data, and generate reports and statistics modules to analyze users\' system utilization. The researcher uses the System Development Life Cycle Spiral model to design and build the system. This study conducts a sequence of planning, analysis, design, and implementation of the system tools, requirements, and architecture to be used while building the system through iterative and agile cooperation of the system developer. After the development of the system, the researcher sent a request letter to the UIC director of libraries for the gathering of non-highly classified archive records to be used for testing. Then the researcher and programmer tested the system online and provided revision on the terms of data used based on standard archive practices. The study showed that the archive administrator could manage the digital content and metadata for historical and cultural artifacts preservation. The system allowed the users to browse, view, and download the data needed. Furthermore, archive administrators can quickly generate statistics for reporting, utilization, and monitoring purposes. In conclusion, the study showed that a digital repository system could provide significant support in managing the archive. The system was divided into three modules to determine the specific roles and privileges while using the system to manage and utilize the metadata contained in the database. Finally, the study recommends that the system be most effective and used by the stakeholders when integrated with the university archive page.', NULL, NULL),
(90, 2, 'DEVELOPMENT OF AN ALTERNATIVE AND INTERACTIVE LEARNING SYSTEM IN TEACHING FILIPINO LANGUAGE TO FOREIGN STUDENTS', '4', 'Master of Library and Information Science', 6, '2022', 'Nelson Mandela said, \"If you talk to a man in a language he understands, that goes to his head. If you talk to him in his own language, that goes to his heart\". Thus, communication between people equates to the significance of language being the most important means of communication. The study aims to develop an alternative and interactive learning system for teaching the Filipino language to foreign students. Specifically, the study intends to (1) identify the material that can be used in a learning system for teaching the Filipino language to foreign students; (2) implement a systematic approach to integrating instructional materials into an interactive learning platform; and (3) achieve an acceptable level of usability for the developed interactive learning platform. ADDIE model was adopted to select the instructional material and integrate it into an interactive learning platform. The book Tagalog for Beginners: An Introduction to Filipino, the National Language of the Philippines is the basis for the interactive learning system. It got the highest rating in Book Citation and Book Review Analyses. Ren\'py, a visual novel engine, was utilized to convert the learning material into an interactive story. The integration process included downloading images and sounds from the web and converting the book\'s content to new assets through PowerPoint. After preparing images, words, and sounds, the book content was encoded in Ren\'py. The usability testing results revealed that the system was easy to use, graphics were found appealing, audio was appropriate, and the book was well-integrated into the system. Also, the interactive learning system presentation was suitable for the students and was not difficult to maneuver. Hence, it is recommended for use as a special library service.', NULL, NULL),
(91, 2, 'DEVELOPMENT OF ONLINE LIBRARY BOOK FAIR SYSTEM', '6', 'Master of Library and Information Science', 6, '2022', 'The development of the online library book fair is a system intended for users and exhibitors that will hasten the process of ordering and exhibiting books. This system gives several benefits to universities and colleges, exhibitors, teachers, students, librarians, and library staff which aid the procedure of acquiring books. Furthermore, this study aims explicitly to a) provide a module for encoding of book and dealer details; b) provide a module that allows users to browse for available books and resources; c) provide a module that will allow adding to the cart; d) generate reports such as a list of books ordered by clients, a list of bookstores, and a list of books per Book store; and e) display book fair floor plan. This study is anchored using the Three- Phase Development Strategy, which includes the project initiation, analysis and design, and testing. The developer of this system uses PHP native as back-end programming for the web application. Also, the system uses JQuery, Bootstrap 4, AdminLTE Components for the front-end, SketchUp 3D for the development of floor plans, Database Management System: MySQL, XAMPP for the local web server, and GoDaddy for the hosting and domain. The system includes a user and administration account. The system\'s architectural design is based on a three-tier architecture composed of 1) Front End (Client View) that uses HTML, CSS, and AdminLTE platform components; 2) Middle tier (Back-End) that uses PHP programming language, and 3) Data tier that uses MySQL Database. This enables the system to be flexible and manage several inputs and data stored in the system. The validity of the system\'s functionality is done by conducting functionality testing to ten (10) randomly selected users composed of teachers, librarians, students, and book dealers. The testing revealed that the system actualized its objectives in developing an online library book fair. Moreover, the system provides an alternative solution to the issues brought in terms of the number of attendees in the physical book fair, as well as minimizes the time spent when attending the actual book fair.', NULL, NULL),
(92, 2, 'DEVELOPMENT OF WEB-BASED SUPPORT SERVICE TICKETING SYSTEM OF ATENEO DE DAVAO UNIVERSITY LIBRARY JACINTO CAMPUS', '6', 'Master of Library and Information Science', 8, '2023', 'This study was intended to develop a web-based support service ticketing system of Ateneo de Davao University Library Jacinto Campus as a virtual help desk, enabling students, faculty, and staff of the university to submit requests and Inquiries regarding library services. The objectives of the study were as follows: implement a web-based support service ticketing system that has multi-channel support capability (Online Chat, Email, Web Form); generate automatic notifications that will give updates on every action of the clients, support staff, and ticket updates: design and develop a reporting module that will generate comprehensive reports that will aid individual evaluations and effort reporting, and Provide a knowledge base module including FAQ that will help clients find the answers they need. The strategy used for this study was the modified System Development Life Cycle (SDLC) - Waterfall Model which consists of the following elements: project initiation, ticketing system analysis and design, and testing and deployment. The ADDU web-based support service ticketing system was thoughtfully designed using UVDesk as the underlying database, offering a comprehensive set of features and functionalities. To support the database, MySQL, PHP version 8.028. and Apache were incorporated into the system. The online chat feature is facilitated through the integration of the ChatWhizz communication tool. For email notifications, the system utilizes the Gmail mailbox from the open-source helpdesk. Configuration is in place for SMTP/Imap to enable sending and transferring of emails through the support email ID, as well as fetching emails within the helpdesk platform. The system was introduced to and tested by Librarians, Administrative Associates (AAs) and random students of Ateneo De Davao University. The user acceptance form was provided and accomplished after the orientation and testing. The user acceptance test result proved that the web-based support service ticketing system is an excellent platform that enables the Ateneo De Davao University Library to manage customer inquiries and support requests efficiently and effectively.', NULL, NULL),
(93, 2, 'C-MAP ANALYTICS: A WEB-BASED APPLICATION OF COLLECTION MAPPING FOR UNIVERSITY OF IMMACULATE CONCEPTION - LEARNING RESOURCE CENTER GRADUATE SCHOOL LIBRARY', '6', 'Master of Library and Information Science', 1, '2024', 'Nowadays, days are part of the growing technological advance wherein online resources can be found and easily accessed by the users. Enhance services using different kinds of monitoring and online user surveys that can be used to gather data quickly. Collection mapping tools are only one of the assessment tools that can be evaluated. The collection provides reports that could help the librarian\'s decision-making regarding the acquisition of books, curriculum book re-alignment, and curriculum collection balance. The general purpose of this study is to develop c-map analytics: a web-based application of collection mapping for the university of Immaculate Conception learning resource center graduate school library. The graduate school library is struggling in terms of conducting collection mapping, several problems are encountered during the traditional way of doing the process. Lack of human resource to focus on doing the assessment, time-consuming in which it takes much more time to finish the process and lastly the University is undergoing PAASCU accreditation this year including the graduate school library with corresponding recommendation to conduct library collection mapping. Through the c-map analytics system, the processes are already automated and integrated the extracted data file from the existing library management system and provide seamless data interaction and report visualization by generating reports on data analytics visualization, remarks, and collection figures. The study was anchored to the development of IFLA conspectus method of conducting collection assessment using conspectus level of collection. The researcher also recommends innovating and upgrading into higher development in which the user can used the system in online and offline mode status, adopting the data mining process for advance gathering of data and unique features.', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `researchaccesslog`
--

CREATE TABLE `researchaccesslog` (
  `accessLogID` int(11) NOT NULL,
  `researchID` int(11) DEFAULT NULL,
  `userID` int(11) DEFAULT NULL,
  `accessTimestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `researchentrylog`
--

CREATE TABLE `researchentrylog` (
  `entryLogID` int(11) NOT NULL,
  `performedBy` int(11) DEFAULT NULL,
  `actionType` varchar(50) NOT NULL,
  `researchID` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `researchentrylog`
--

INSERT INTO `researchentrylog` (`entryLogID`, `performedBy`, `actionType`, `researchID`, `timestamp`) VALUES
(1, 2, 'create', 1, '2025-08-27 14:56:56'),
(2, 2, 'create', 2, '2025-08-27 14:56:56'),
(3, 2, 'create', 3, '2025-08-27 14:56:56'),
(4, 2, 'create', 4, '2025-08-27 14:56:56'),
(5, 2, 'create', 5, '2025-08-27 14:56:56'),
(6, 2, 'create', 6, '2025-08-27 14:56:56'),
(7, 2, 'create', 7, '2025-08-27 14:56:56'),
(8, 2, 'create', 8, '2025-08-27 14:56:56'),
(9, 2, 'create', 9, '2025-08-27 14:56:56'),
(10, 2, 'create', 10, '2025-08-27 14:56:56'),
(11, 2, 'create', 11, '2025-08-27 14:56:56'),
(12, 2, 'create', 12, '2025-08-27 14:56:56'),
(13, 2, 'create', 13, '2025-08-27 14:56:56'),
(14, 2, 'create', 14, '2025-08-27 14:56:56'),
(15, 2, 'create', 15, '2025-08-27 14:56:56'),
(16, 2, 'create', 16, '2025-08-27 14:56:56'),
(17, 2, 'create', 17, '2025-08-27 14:56:56'),
(18, 2, 'create', 18, '2025-08-27 14:56:56'),
(19, 2, 'create', 19, '2025-08-27 14:56:56'),
(20, 2, 'create', 20, '2025-08-27 14:56:56'),
(21, 2, 'create', 21, '2025-08-27 14:56:56'),
(22, 2, 'create', 22, '2025-08-27 14:56:56'),
(23, 2, 'create', 23, '2025-08-27 14:56:56'),
(24, 2, 'create', 24, '2025-08-27 14:56:56'),
(25, 2, 'create', 25, '2025-08-27 14:56:56'),
(26, 2, 'create', 26, '2025-08-27 14:56:56'),
(27, 2, 'create', 27, '2025-08-27 14:56:56'),
(28, 2, 'create', 28, '2025-08-27 14:56:56'),
(29, 2, 'create', 29, '2025-08-27 14:56:56'),
(30, 2, 'create', 30, '2025-08-27 14:56:56'),
(31, 2, 'create', 31, '2025-08-27 14:56:56'),
(32, 2, 'create', 32, '2025-08-27 14:56:56'),
(33, 2, 'create', 33, '2025-08-27 14:56:56'),
(34, 2, 'create', 34, '2025-08-27 14:56:56'),
(35, 2, 'create', 35, '2025-08-27 14:56:56'),
(36, 2, 'create', 36, '2025-08-27 14:56:56'),
(37, 2, 'create', 37, '2025-08-27 14:56:56'),
(38, 2, 'create', 38, '2025-08-27 14:56:56'),
(39, 2, 'create', 39, '2025-08-27 14:56:56'),
(40, 2, 'create', 40, '2025-08-27 14:56:56'),
(41, 2, 'create', 41, '2025-08-27 14:56:56'),
(42, 2, 'create', 42, '2025-08-27 14:56:56'),
(43, 2, 'create', 43, '2025-08-27 14:56:56'),
(44, 2, 'create', 44, '2025-08-27 14:56:56'),
(45, 2, 'create', 45, '2025-08-27 14:56:56'),
(46, 2, 'create', 46, '2025-08-27 14:56:56'),
(47, 2, 'create', 47, '2025-08-27 14:56:56'),
(48, 2, 'create', 48, '2025-08-27 14:56:56'),
(49, 2, 'create', 49, '2025-08-27 14:56:56'),
(50, 2, 'create', 50, '2025-08-27 14:56:56'),
(51, 2, 'create', 51, '2025-08-27 14:56:56'),
(52, 2, 'create', 52, '2025-08-27 14:56:56'),
(53, 2, 'create', 53, '2025-08-27 14:56:57'),
(54, 2, 'create', 54, '2025-08-27 14:56:57'),
(55, 2, 'create', 55, '2025-08-27 14:56:57'),
(56, 2, 'create', 56, '2025-08-27 14:56:57'),
(57, 2, 'create', 57, '2025-08-27 14:56:57'),
(58, 2, 'create', 58, '2025-08-27 14:56:57'),
(59, 2, 'create', 59, '2025-08-27 14:56:57'),
(60, 2, 'create', 60, '2025-08-27 14:56:57'),
(61, 2, 'create', 61, '2025-08-27 14:56:57'),
(62, 2, 'create', 62, '2025-08-27 14:56:57'),
(63, 2, 'create', 63, '2025-08-27 14:56:57'),
(64, 2, 'create', 64, '2025-08-27 14:56:57'),
(65, 2, 'create', 65, '2025-08-27 14:56:57'),
(66, 2, 'create', 66, '2025-08-27 14:56:57'),
(67, 2, 'create', 67, '2025-08-27 14:56:57'),
(68, 2, 'create', 68, '2025-08-27 14:56:57'),
(69, 2, 'create', 69, '2025-08-27 14:56:57'),
(70, 2, 'create', 70, '2025-08-27 14:56:57'),
(71, 2, 'create', 71, '2025-08-27 14:56:57'),
(72, 2, 'create', 72, '2025-08-27 14:56:57'),
(73, 2, 'create', 73, '2025-08-27 14:56:57'),
(74, 2, 'create', 74, '2025-08-27 14:56:57'),
(75, 2, 'create', 75, '2025-08-27 14:56:57'),
(76, 2, 'create', 76, '2025-08-27 14:56:57'),
(77, 2, 'create', 77, '2025-08-27 14:56:57'),
(78, 2, 'create', 78, '2025-08-27 14:56:57'),
(79, 2, 'create', 79, '2025-08-27 14:56:57'),
(80, 2, 'create', 80, '2025-08-27 14:56:57'),
(81, 2, 'create', 81, '2025-08-27 14:56:57'),
(82, 2, 'create', 82, '2025-08-27 14:56:57'),
(83, 2, 'create', 83, '2025-08-27 14:56:57'),
(84, 2, 'create', 84, '2025-08-27 14:56:57'),
(85, 2, 'create', 85, '2025-08-27 14:56:57'),
(86, 2, 'create', 86, '2025-08-27 14:56:57'),
(87, 2, 'create', 87, '2025-08-27 14:56:57'),
(88, 2, 'create', 88, '2025-08-27 14:56:57'),
(89, 2, 'create', 89, '2025-08-27 14:56:57'),
(90, 2, 'create', 90, '2025-08-27 14:56:57'),
(91, 2, 'create', 91, '2025-08-27 14:56:57'),
(92, 2, 'create', 92, '2025-08-27 14:56:57'),
(93, 2, 'create', 93, '2025-08-27 14:56:57');

-- --------------------------------------------------------

--
-- Table structure for table `researcher`
--

CREATE TABLE `researcher` (
  `researcherID` int(11) NOT NULL,
  `researchID` int(11) DEFAULT NULL,
  `firstName` varchar(255) NOT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `researcher`
--

INSERT INTO `researcher` (`researcherID`, `researchID`, `firstName`, `middleName`, `lastName`, `email`) VALUES
(1, 1, 'Carl Stephen', 'G.', 'Caya', 'csgcaya@usep.edu.ph'),
(2, 1, 'Merra Elaiza', 'T.', 'Espinosa', NULL),
(3, 1, 'Mice Dianne', 'M.', 'Moria', NULL),
(4, 2, 'Lovely Roze', 'N.', 'Amandy', NULL),
(5, 2, 'Theona', 'F.', 'Aton', NULL),
(6, 2, 'Andrea Gail', 'N.', 'Balcom', NULL),
(7, 3, 'Martkneil Jan', 'L.', 'Javier', 'mjljavier@usep.edu.ph'),
(8, 3, 'Christian', 'C.', 'Lavilla', NULL),
(9, 3, 'Matt Jacob', 'C.', 'Rulona', 'mjcrulona@usep.edu.ph'),
(10, 4, 'Reymart', 'C.', 'Casas', NULL),
(11, 4, 'Paola', 'R.', 'Concubierta', NULL),
(12, 4, 'Elvina', 'B.', 'Garcia', NULL),
(13, 5, 'Nica', 'C.', 'Carcallas', NULL),
(14, 5, 'Sim Japhet', 'C.', 'Delos Reyes', NULL),
(15, 5, 'Jan Enrico', 'V.', 'Quinamot', NULL),
(16, 6, 'Jude Norbert', 'D.', 'Barsal', NULL),
(17, 6, 'Ian James', 'V.', 'Gaspar', NULL),
(18, 6, 'Francis Lloyd', 'P.', 'Ripalda', NULL),
(19, 7, 'Pauline Marie', 'J.', 'Dumagan', NULL),
(20, 7, 'Kiarrah', 'R.', 'Menil', NULL),
(21, 7, 'Ma. Mitchie', 'N.', 'Sampani', NULL),
(22, 8, 'Daryl Kate', 'T.', 'Good', NULL),
(23, 8, 'Shenny Maree', 'C.', 'Ormo', NULL),
(24, 9, 'Frances Mae', 'G.', 'Dimaano', NULL),
(25, 9, 'Rio Jessa Mae', 'N.', 'Florida', NULL),
(26, 10, 'Jonell', 'P.', 'Jumang-it', NULL),
(27, 10, 'Aira Camille', 'H.', 'Lamberte', 'achlamberte@usep.edu.ph'),
(28, 10, 'Amanda Jane', 'L.', 'Ruelo', 'ajlaruelo@usep.edu.ph'),
(29, 11, 'Jhon Vincent', NULL, 'Bañaga', 'jvcbanaga@usep.edu.ph'),
(30, 11, 'Ara Noreen', 'S.', 'Manito', NULL),
(31, 11, 'Corsiga George', 'C.', 'Caturza Jr.', NULL),
(32, 12, 'Noemi Andreyanne', 'L.', 'Canlog', 'nalcanlog@usep.edu.ph'),
(33, 12, 'Leonel', NULL, 'Torrefiel', 'ltorrefiel@usep.edu.ph'),
(34, 12, 'Cleo', 'B.', 'Pantinople', 'cbpantinople@usep.edu.ph'),
(35, 13, 'Ina', 'P.', 'Alegrado', 'ipalegrado@usep.edu.ph'),
(36, 13, 'Trisha Marie', 'V.', 'Hagunob', 'tmvhagunob@usep.edu.ph'),
(37, 13, 'Angelika Mari', 'O.', 'Robles', 'amorobles@usep.edu.ph'),
(38, 14, 'Kenneth King Jones', 'M.', 'Celocia', NULL),
(39, 14, 'Rona', 'P.', 'Licera', NULL),
(40, 14, 'Roxan', 'S.', 'Tiu', NULL),
(41, 15, 'Kristian Rebb', NULL, 'Escaño', 'kraescano@usep.edu.ph'),
(42, 15, 'Dean', NULL, 'Siapno', 'dpsiapno@usep.edu.ph'),
(43, 16, 'Leah', 'C.', 'Juarez', 'lcjuarez@usep.edu.ph'),
(44, 16, 'Sydney', 'P.', 'Ricafort', 'spricafort@usep.edu.ph'),
(45, 17, 'Lawrence Christopher', 'G.', 'Rosario', 'lcgrosario@usep.edu.ph'),
(46, 17, 'John Eric Paolo', 'R.', 'Gubaton', 'jeprgubaton@usep.edu.ph'),
(47, 17, 'Richard', 'B.', 'Peligor', 'rbpeligor@usep.edu.ph'),
(48, 18, 'Arvin Garret', 'A.', 'Arbizo', 'agaarbizo@usep.edu.ph'),
(49, 18, 'Marc Louie', 'L.', 'Balansag', 'mllbalansag@usep.edu.ph'),
(50, 18, 'Christy Hyacinth', 'C.', 'Carpesano', 'chccarpesano@usep.edu.ph'),
(51, 19, 'Bryle', 'G.', 'Alfanta', 'bgalfanta@usep.edu.ph'),
(52, 19, 'Joshua Chris', 'M.', 'Duran', 'jcmduran@usep.edu.ph'),
(53, 19, 'Brad Ford', 'D.', 'Rosal', 'bfdrosal@usep.edu.ph'),
(54, 20, 'Angelica Mae', 'G.', 'Betonio', 'amgbetonio@usep.edu.ph'),
(55, 20, 'Jomari', 'D.', 'Ondap', 'jdondap@usep.edu.ph'),
(56, 21, 'Carmilla', NULL, 'Benalet', 'ccbenalet@usep.edu.ph'),
(57, 21, 'May Flor', NULL, 'Lape', 'mfflape@usep.edu.ph'),
(58, 21, 'Reno Roy', NULL, 'Sorima', NULL),
(59, 22, 'Dionne Evony', 'M.', 'Diola', 'demdiola@usep.edu.ph'),
(60, 22, 'Bebe Mae', 'J.', 'Roxas', 'bmjroxas@usep.edu.ph'),
(61, 22, 'Audrey Marie', 'M.', 'Taghoy', NULL),
(62, 23, 'Chuzelyn', 'D.', 'Maxino', 'cdmaxino@usep.edu.ph'),
(63, 23, 'Judelyn', 'N.', 'Rubia', 'jnrubia@usep.edu.ph'),
(64, 23, 'Vidal', NULL, 'Johanna Mae', NULL),
(65, 24, 'Eugene', 'L.', 'Cortes', 'elcortes@usep.edu.ph'),
(66, 24, 'Shareld Rose', 'A.', 'Baobao', 'srabaobao@usep.edu.ph'),
(67, 24, 'Dyesebel', 'T.', 'Centillas', 'dtcentillas@usep.edu.ph'),
(68, 25, 'Jay Mark', 'H.', 'Taganahan', NULL),
(69, 25, 'Quenie Marie', 'D.', 'Penanueva', NULL),
(70, 25, 'Mark', 'B.', 'Lumen', NULL),
(71, 26, 'Jay Ar', NULL, 'Drilon', NULL),
(72, 26, 'Romel', 'M.', 'Hermoso', NULL),
(73, 27, 'Mary Rose', 'C.', 'Adorable', NULL),
(74, 27, 'Faye Hazel', 'V.', 'Remis', NULL),
(75, 27, 'Aries Dominic', 'H.', 'Mahinay', NULL),
(76, 28, 'Raymund', 'F.', 'Ontolan', NULL),
(77, 28, 'Jazzy Bert', 'S.', 'Viernes', NULL),
(78, 29, 'Vil Marie', 'A.', 'Agcol', NULL),
(79, 29, 'Ellen Mae', 'G.', 'Calzada', NULL),
(80, 29, 'Junard John', 'C.', 'Clenista', NULL),
(81, 30, 'Pauline Grace', 'C.', 'Albutra', NULL),
(82, 30, 'Rennjo', 'D.', 'Buquia', NULL),
(83, 30, 'Darleen', 'S.', 'Lungay', NULL),
(84, 31, 'Jumar', 'H.', 'Dulay', NULL),
(85, 31, 'Jehoiakim Jade', 'C.', 'Esgana', NULL),
(86, 31, 'John Jay', 'A.', 'Rivera', NULL),
(87, 32, 'Harris', 'B.', 'Carreon', NULL),
(88, 32, 'Kent Charles', NULL, 'Cutamora', NULL),
(89, 32, 'Hyacinth Faye', 'A.', 'Tabasa', NULL),
(90, 33, 'Allen Grace', 'S.', 'Decierdo', NULL),
(91, 33, 'Queenie', 'L.', 'Dumangas', NULL),
(92, 33, 'Kristine Mae', 'D.', 'Merecuelo', NULL),
(93, 34, 'Angelica', 'B.', 'Coquilla', NULL),
(94, 34, 'Jeelenee Jayson', 'L.', 'De Claro', NULL),
(95, 34, 'Kyle Matthew', 'C.', 'Martinez', NULL),
(96, 35, 'Jahmicah Nissi', 'F.', 'Boo', NULL),
(97, 35, 'Mary Elisse', 'G.', 'Gonzales', NULL),
(98, 35, 'Maruela Angela', 'A.', 'Regalado', NULL),
(99, 36, 'Joshua Antonio', 'N.', 'Castro', NULL),
(100, 36, 'Elnathan Timothy', 'C.', 'Dela Cruz', NULL),
(101, 36, 'Jawad', 'L.', 'Agantal', NULL),
(102, 37, 'Raven', 'M.', 'Alinsonorin', NULL),
(103, 37, 'Joshuaa', 'S.', 'Barinan', NULL),
(104, 38, 'Daniel', 'R.', 'Sabal', 'drsabal@usep.edu.ph'),
(105, 38, 'Justin Jade', 'F.', 'Saligumba', 'jjfsaligumba@usep.edu.ph'),
(106, 39, 'Lonivel John', 'C.', 'Canizares', 'ljccanizares@usep.edu.ph'),
(107, 39, 'Christian Jason', 'N.', 'Dimpas', 'cndimpas@usep.edu.ph'),
(108, 39, 'Jason Ray', 'D.', 'Uy', 'jrduy@usep.edu.ph'),
(109, 40, 'Jian Luigi', 'C.', 'Bollanday', 'jlcbollanday@usep.edu.ph'),
(110, 40, 'Richie Floyd', 'C.', 'Borleo', 'rfcborleo@usep.edu.ph'),
(111, 40, 'John Loyd', 'A.', 'Lao', 'jlalao@usep.edu.ph'),
(112, 41, 'Katherine Joy', 'S.', 'Cajetas', 'kjscajetas@usep.edu.ph'),
(113, 41, 'Arman Rex', 'L.', 'Lee', 'arllee@usep.edu.ph'),
(114, 42, 'Richelle Anne', 'S.', 'Serbo', 'rasserbo@usep.edu.ph'),
(115, 42, 'Angel Menrica', 'B.', 'Tubal', 'ambtubal@usep.edu.ph'),
(116, 43, 'Kassandra Mariz', 'S.', 'Libron', 'kslibron@usep.edu.ph'),
(117, 43, 'Bazty', 'Z.', 'Atanoso', 'bcatanoso@usep.edu.ph'),
(118, 43, 'Andrea', 'S.', 'Cosgapa', 'ascosgapa@usep.edu.ph'),
(119, 44, 'Vincent Karl Jofferson', 'D.', 'Bunsay', 'vkjdbunsay@usep.edu.ph'),
(120, 44, 'Clark Jasper', 'B.', 'Montebon II', 'cjbmontebon@usep.edu.ph'),
(121, 44, 'Ron Angelo', 'N.', 'Piad', 'ranpiad@usep.edu.ph'),
(122, 45, 'Edjery Gabriel', 'C.', 'Gumbao', 'egcgumbao@usep.edu.ph'),
(123, 45, 'Reyjet', 'R.', 'Sandoval', 'rrsandoval@usep.edu.ph'),
(124, 46, 'Jainah Marie', 'C.', 'Dabuan', 'jmcdabuan@usep.edu.ph'),
(125, 46, 'Cindy Mae', NULL, 'Pueblos', 'cmpueblos197@usep.edu.ph'),
(126, 47, 'Hector', 'M.', 'Mataflorida', 'hmmataflorida@usep.edu.ph'),
(127, 47, 'Johndell Laurence', 'B.', 'Pelale', 'jlbpelale@usep.edu.ph'),
(128, 48, 'Elijah James', 'E.', 'Elacion', 'ejeelacion@usep.edu.ph'),
(129, 48, 'Francis Dave', NULL, 'Maranan', 'fdymaranan@usep.edu.ph'),
(130, 48, 'Justin John', 'O.', 'Mesajon', 'jjomesajon@usep.edu.ph'),
(131, 49, 'Emma Mae', 'H.', 'Canete', 'emccanete@usep.edu.ph'),
(132, 49, 'Shaira', 'B.', 'Celerian', 'sbcelerian@usep.edu.ph'),
(133, 49, 'Joeben', 'P.', 'Engalan', 'jpengalan@usep.edu.ph'),
(134, 50, 'Julius', 'B.', 'Alivio', 'jbalivio@usep.edu.ph'),
(135, 50, 'Francis Riedel', 'T.', 'Escoton', 'frtescoton@usep.edu.ph'),
(136, 50, 'Donewill Christian', 'D.', 'Misal', 'dcdmisal@usep.edu.ph'),
(137, 51, 'John Kelvin', 'M.', 'Calunsag', 'jkmcalunsag@usep.edu.ph'),
(138, 51, 'Robie Bryan', 'B.', 'Jacaban', 'rbbjacaban@usep.edu.ph'),
(139, 51, 'Ricci Dee', 'R.', 'Tolento', 'rdrtolento@usep.edu.ph'),
(140, 52, 'Trishia Mae', 'P.', 'Cabaobao', 'tmpcabaobao@usep.edu.ph'),
(141, 52, 'Ivy Alexist', 'P.', 'Daguplo', 'iapdaguplo@usep.edu.ph'),
(142, 52, 'Kailah Shane', 'S.', 'Torres', 'ksstorres@usep.edu.ph'),
(143, 53, 'Guia Anne', 'G.', 'Cubelo', 'gaccubelo@usep.edu.ph'),
(144, 53, 'Jonah Mae', 'A.', 'Gomez', 'jmagomez@usep.edu.ph'),
(145, 54, 'Kenneth Joseph', 'V.', 'Booc', NULL),
(146, 54, 'Justine Alec', 'A.', 'Go', NULL),
(147, 54, 'Allen Ray', 'P.', 'Siega', NULL),
(148, 55, 'Hersie Jean', 'R.', 'Caparas', 'hjrcaparas@usep.edu.ph'),
(149, 55, 'Josephine', 'P.', 'Muana', 'jpmuana@usep.edu.ph'),
(150, 56, 'Chris Earl', 'S.', 'Amar', 'cesamar@usep.edu.ph'),
(151, 56, 'Joel Miller', 'M.', 'Go', NULL),
(152, 56, 'Neuqian Rhys', 'S.', 'Salvador', NULL),
(153, 57, 'Donell', 'D.', 'Abenoja', NULL),
(154, 57, 'Lorenzo Lolek', 'R.', 'Mateo', NULL),
(155, 58, 'Niebby Jen', 'B.', 'Barez', NULL),
(156, 58, 'Mae Amor', 'C.', 'Galleto', NULL),
(157, 58, 'Kim Clarizze', 'R.', 'Remolta', NULL),
(158, 59, 'Jonel', 'C.', 'Getigan', NULL),
(159, 59, 'Exceed Renz', 'M.', 'Ramos', NULL),
(160, 59, 'Benser Jan', 'P.', 'Villanueva', NULL),
(161, 60, 'Joven Rey', NULL, 'Anden', NULL),
(162, 60, 'Ray Neal', NULL, 'Badalo', NULL),
(163, 60, 'Michael', 'P.', 'Sy', NULL),
(164, 61, 'Andrei', 'P.', 'Mangaron', 'apmangaron@usep.edu.ph'),
(165, 61, 'Nico', 'M.', 'Mangasar', 'nmmangasar@usep.edu.ph'),
(166, 61, 'Vanne Moelle', 'V.', 'Valdez', 'vmvvaldez@usep.edu.ph'),
(167, 62, 'Yvonne Grace', 'F.', 'Arandela', 'ygfarandela@usep.edu.ph'),
(168, 62, 'Raschelle', 'L.', 'Cossid', 'rlcossid@usep.edu.ph'),
(169, 62, 'Graciella Marian', 'M.', 'Pacilan', 'gmmpacilan@usep.edu.ph'),
(170, 63, 'Earll', 'J.', 'Abule', 'ejabule@usep.edu.ph'),
(171, 63, 'Eugene Louis', 'D.', 'Rapal', 'eldprapal@usep.edu.ph'),
(172, 63, 'Christian Ken', 'A.', 'Tayco', 'ckatayco@usep.edu.ph'),
(173, 64, 'Marc Jules', 'B.', 'Coquilla', 'mjbcoquilla@usep.edu.ph'),
(174, 64, 'Joma Ray', 'A.', 'Quinones', 'jraquinones@usep.edu.ph'),
(175, 64, 'Haus Christian', 'C.', 'Salibio', NULL),
(176, 65, 'Bezalel', 'O.', 'Delos Reyes', 'bodelosreyes@usep.edu.ph'),
(177, 65, 'Joseven', 'R.', 'Francisco', 'jrfrancisco@usep.edu.ph'),
(178, 65, 'Meichell Jynein', 'J.', 'Managing', 'mjjmanaging@usep.edu.ph'),
(179, 66, 'Nickel Snow', NULL, 'Apique', NULL),
(180, 66, 'Samuel', NULL, 'Domingo III', 'sgdomingo@usep.edu.ph'),
(181, 66, 'Elijah James', NULL, 'Uytico', 'ejsuytico@usep.edu.ph'),
(182, 67, 'Isidro', 'P.', 'Ampig', 'ipampig@usep.edu.ph'),
(183, 67, 'Zuriel Jett', 'M.', 'Leung', 'zjmleung@usep.edu.ph'),
(184, 68, 'Fritzie', 'B.', 'Lor', 'fblor@usep.edu.ph'),
(185, 68, 'Brylle James', NULL, 'Sanoy', 'bjsanoy@usep.edu.ph'),
(186, 68, 'Syramae', 'F.', 'Siva', 'sfsiva@usep.edu.ph'),
(187, 69, 'Vann Rijn', 'D.', 'Amarillo', 'vrdamarillo@usep.edu.ph'),
(188, 69, 'John Emmanuel', 'G.', 'Gapuz', 'jeggapuz@usep.edu.ph'),
(189, 70, 'Rovic Jade', 'P.', 'Rivas', 'rovic.rivas@usep.edu.ph'),
(190, 70, 'Armand Louise', 'S.', 'Jusayan', 'armand.jusayan@usep.edu.ph'),
(191, 70, 'Matthew Gabriel', 'B.', 'Silvosa', 'matthew.silvosa@usep.edu.ph'),
(192, 71, 'Charles Andrew', 'P.', 'Balbin', 'charles.balbin@usep.edu.ph'),
(193, 71, 'Joshua Jay', 'G.', 'Ungab', 'joshua.ungab@usep.edu.ph'),
(194, 71, 'Justine Riva', 'F.', 'Unson', 'justine.unson@usep.edu.ph'),
(195, 72, 'Denver Fred', 'A.', 'De Gracia', 'denver.degracia@usep.edu.ph'),
(196, 72, 'Andrew Kenan', 'A.', 'Songahid', 'andrew.songahid@usep.edu.ph'),
(197, 72, 'Nikko', 'L.', 'Maniwang', 'nikko.maniwang@usep.edu.ph'),
(198, 73, 'Chinee Lois', NULL, 'Bergonio', NULL),
(199, 73, 'Dave', 'M.', 'Veroy', NULL),
(200, 74, 'James Harley', 'L.', 'Pacaldo', NULL),
(201, 74, 'Edward Dave', 'T.', 'Almojera', NULL),
(202, 75, 'Chrystel Kaye', 'H.', 'Tabanao', NULL),
(203, 75, 'Jenicel', 'E.', 'Tambis', NULL),
(204, 76, 'Cristy Jane', 'D.', 'Madanlo', NULL),
(205, 76, 'Carlo Rey', 'G.', 'Pasinabo', NULL),
(206, 77, 'Lucky Mae', 'M.', 'Omega', NULL),
(207, 77, 'CJ Nicole', NULL, 'Suriaga', NULL),
(208, 78, 'Ella Aira Gen', 'A.', 'Ajos', NULL),
(209, 78, 'Riodelmar', 'G.', 'Amboc', NULL),
(210, 78, 'Dennis', 'C.', 'Alonde', NULL),
(211, 79, 'Jamaeca', 'I.', 'Delos Cientos', NULL),
(212, 79, 'Melanie', 'B.', 'Pamaong', NULL),
(213, 79, 'Janeth', 'R.', 'Sepada', NULL),
(214, 79, 'Mikaela Ellen Mae', 'B.', 'Villocino', NULL),
(215, 80, 'Kyle Jobert', 'Y.', 'Bullian', NULL),
(216, 80, 'Gerald Kenn', 'I.', 'Latonio', NULL),
(217, 80, 'Ardemer', 'E.', 'Tac-an', NULL),
(218, 81, 'Shane Kimberly', 'Z.', 'Andrade', NULL),
(219, 81, 'Alan Joseph', 'O.', 'Mapinguez', NULL),
(220, 81, 'Catherine Joy', 'L.', 'Masinading', NULL),
(221, 81, 'Regine', 'C.', 'Remulta', NULL),
(222, 82, 'Gerald', 'D.', 'Basalo', NULL),
(223, 82, 'Charisse Angeli', 'A.', 'Compacion', NULL),
(224, 82, 'Christianne Dave', 'P.', 'Granaderos', NULL),
(225, 83, 'Aubrey', 'C.', 'Adarlo', NULL),
(226, 83, 'Aira', 'M.', 'Mordeno', NULL),
(227, 84, 'John Kenth', 'P.', 'Arsolon', NULL),
(228, 84, 'Kurt Michael', 'G.', 'Israel', NULL),
(229, 84, 'Aldrich Ley', 'G.', 'Cuizon', NULL),
(230, 84, 'Garjev', 'M.', 'Dupla', NULL),
(231, 85, 'Annacel', 'B.', 'Delima', NULL),
(232, 86, 'Jehoney', 'V.', 'Alboroto', NULL),
(233, 87, 'Peter', 'M.', 'Cainglet', NULL),
(234, 88, 'Etel Ella Mae', 'H.', 'Cajilig', NULL),
(235, 89, 'Anthony', 'P.', 'Cañete', NULL),
(236, 90, 'Khristine Elaiza', 'D.', 'Ruiz', NULL),
(237, 91, 'Fretsy Glen', 'P.', 'Matalum', NULL),
(238, 92, 'Rutchel', 'T.', 'Quinte', NULL),
(239, 93, 'Jayson', 'R.', 'Alibango', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `researchkeyword`
--

CREATE TABLE `researchkeyword` (
  `researchID` int(11) NOT NULL,
  `keywordID` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `researchkeyword`
--

INSERT INTO `researchkeyword` (`researchID`, `keywordID`) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 37),
(2, 7),
(2, 8),
(2, 9),
(2, 10),
(2, 11),
(2, 12),
(2, 124),
(3, 13),
(3, 14),
(3, 15),
(3, 16),
(3, 17),
(3, 18),
(3, 37),
(4, 19),
(4, 20),
(4, 21),
(4, 22),
(4, 23),
(4, 24),
(4, 25),
(5, 26),
(6, 33),
(6, 34),
(6, 35),
(6, 36),
(6, 37),
(6, 38),
(6, 39),
(7, 37),
(7, 40),
(7, 41),
(7, 42),
(7, 43),
(7, 44),
(7, 45),
(8, 46),
(8, 47),
(8, 48),
(8, 49),
(8, 50),
(8, 51),
(8, 52),
(9, 53),
(9, 54),
(9, 55),
(9, 56),
(9, 57),
(9, 58),
(9, 59),
(10, 60),
(10, 61),
(10, 62),
(10, 63),
(10, 64),
(10, 65),
(10, 66),
(11, 67),
(11, 68),
(11, 69),
(11, 70),
(11, 71),
(11, 72),
(11, 73),
(12, 74),
(12, 75),
(12, 76),
(12, 77),
(12, 78),
(12, 79),
(12, 80),
(13, 81),
(13, 82),
(13, 83),
(13, 84),
(13, 85),
(13, 86),
(13, 273),
(14, 87),
(14, 88),
(14, 89),
(14, 90),
(14, 91),
(14, 92),
(14, 93),
(15, 101),
(15, 110),
(15, 366),
(16, 197),
(17, 111),
(18, 98),
(18, 112),
(18, 132),
(18, 133),
(21, 97),
(21, 100),
(22, 102),
(22, 104),
(22, 174),
(23, 37),
(23, 98),
(23, 117),
(23, 121),
(24, 125),
(24, 126),
(25, 119),
(25, 131),
(26, 94),
(26, 103),
(26, 107),
(27, 95),
(27, 127),
(27, 128),
(27, 129),
(28, 118),
(29, 37),
(30, 54),
(31, 116),
(32, 96),
(32, 99),
(32, 108),
(32, 109),
(33, 122),
(34, 105),
(34, 113),
(34, 118),
(35, 56),
(35, 114),
(35, 115),
(35, 120),
(36, 7),
(36, 37),
(36, 123),
(36, 130),
(36, 148),
(37, 37),
(37, 197),
(38, 134),
(38, 135),
(38, 136),
(38, 137),
(38, 138),
(38, 139),
(38, 273),
(39, 140),
(39, 141),
(39, 142),
(39, 143),
(39, 144),
(39, 145),
(39, 146),
(39, 147),
(40, 27),
(40, 148),
(40, 149),
(40, 150),
(40, 151),
(40, 152),
(40, 153),
(40, 154),
(41, 155),
(41, 156),
(41, 157),
(41, 158),
(41, 159),
(41, 160),
(42, 161),
(42, 162),
(42, 163),
(42, 164),
(42, 165),
(42, 166),
(42, 273),
(43, 165),
(43, 167),
(43, 168),
(43, 169),
(43, 170),
(43, 171),
(44, 172),
(44, 173),
(44, 174),
(44, 175),
(44, 176),
(44, 177),
(44, 178),
(45, 172),
(45, 179),
(45, 180),
(45, 181),
(45, 182),
(46, 156),
(46, 160),
(46, 183),
(46, 184),
(46, 185),
(46, 186),
(47, 152),
(47, 187),
(47, 188),
(47, 189),
(47, 190),
(47, 191),
(48, 192),
(48, 193),
(48, 194),
(48, 195),
(48, 196),
(48, 197),
(49, 148),
(49, 198),
(49, 199),
(49, 200),
(49, 201),
(49, 202),
(49, 203),
(50, 142),
(50, 204),
(50, 205),
(50, 206),
(50, 207),
(50, 208),
(51, 209),
(51, 210),
(51, 211),
(51, 212),
(51, 213),
(51, 214),
(52, 215),
(52, 216),
(52, 217),
(52, 218),
(52, 219),
(52, 220),
(53, 221),
(53, 222),
(53, 223),
(53, 224),
(53, 225),
(53, 226),
(54, 142),
(54, 227),
(54, 228),
(54, 229),
(54, 230),
(54, 273),
(55, 231),
(55, 232),
(55, 233),
(55, 234),
(55, 235),
(55, 236),
(56, 148),
(56, 154),
(56, 237),
(56, 238),
(56, 239),
(57, 197),
(57, 240),
(57, 241),
(57, 242),
(58, 243),
(58, 244),
(58, 245),
(58, 246),
(58, 247),
(58, 248),
(59, 249),
(59, 250),
(59, 251),
(59, 252),
(59, 253),
(60, 197),
(60, 254),
(60, 255),
(60, 256),
(60, 257),
(60, 258),
(60, 259),
(60, 260),
(60, 261),
(60, 262),
(60, 263),
(60, 264),
(60, 265),
(60, 266),
(60, 267),
(60, 268),
(60, 269),
(60, 270),
(60, 271),
(60, 272),
(61, 273),
(61, 274),
(61, 275),
(61, 276),
(61, 277),
(61, 278),
(61, 279),
(61, 280),
(61, 281),
(61, 282),
(61, 283),
(61, 284),
(61, 285),
(61, 286),
(61, 287),
(61, 288),
(61, 289),
(62, 152),
(62, 290),
(62, 291),
(62, 292),
(62, 293),
(62, 294),
(63, 295),
(63, 296),
(63, 297),
(63, 298),
(63, 299),
(63, 300),
(63, 301),
(63, 302),
(63, 303),
(63, 304),
(63, 305),
(63, 306),
(63, 307),
(63, 308),
(63, 309),
(63, 310),
(63, 311),
(63, 312),
(63, 313),
(63, 314),
(63, 315),
(63, 407),
(64, 295),
(64, 316),
(64, 317),
(64, 318),
(64, 319),
(64, 320),
(64, 321),
(64, 322),
(64, 323),
(64, 324),
(64, 325),
(64, 326),
(64, 327),
(64, 328),
(64, 329),
(64, 330),
(64, 331),
(64, 332),
(64, 333),
(64, 334),
(64, 335),
(64, 336),
(64, 337),
(64, 338),
(64, 339),
(64, 340),
(65, 152),
(65, 341),
(65, 342),
(65, 343),
(65, 344),
(65, 345),
(65, 346),
(65, 347),
(65, 348),
(65, 349),
(65, 350),
(65, 351),
(65, 352),
(65, 353),
(65, 354),
(65, 355),
(65, 356),
(65, 357),
(65, 358),
(65, 359),
(65, 360),
(65, 361),
(65, 362),
(65, 363),
(65, 364),
(65, 365),
(65, 366),
(65, 367),
(65, 368),
(65, 369),
(65, 370),
(66, 306),
(66, 325),
(66, 371),
(66, 372),
(66, 373),
(66, 374),
(66, 375),
(66, 376),
(66, 377),
(66, 378),
(66, 379),
(66, 380),
(66, 381),
(66, 382),
(66, 383),
(66, 384),
(66, 385),
(66, 386),
(66, 387),
(68, 306),
(68, 412),
(68, 413),
(68, 414),
(68, 415),
(68, 416),
(68, 417),
(68, 418),
(68, 419),
(68, 420),
(68, 421),
(68, 422),
(68, 423),
(68, 424),
(68, 425),
(69, 333),
(69, 426),
(69, 427),
(69, 428),
(69, 429),
(69, 430),
(69, 431),
(69, 432),
(69, 433),
(69, 434),
(69, 435),
(69, 436),
(69, 437),
(69, 438),
(69, 439),
(69, 440),
(69, 441),
(69, 442),
(69, 443),
(70, 197),
(70, 295),
(70, 444),
(70, 445),
(70, 446),
(70, 447),
(70, 448),
(70, 449),
(70, 450),
(70, 451),
(70, 452),
(70, 453),
(70, 454),
(70, 455),
(70, 456),
(70, 457),
(70, 458),
(70, 459),
(70, 460),
(71, 152),
(71, 461),
(71, 462),
(71, 463),
(71, 464),
(71, 465),
(71, 466),
(71, 467),
(71, 468),
(71, 469),
(71, 470),
(71, 471),
(71, 472),
(71, 473),
(71, 474),
(71, 475),
(71, 476),
(71, 477),
(71, 478),
(71, 479),
(71, 480),
(71, 481),
(71, 482),
(71, 483),
(71, 484),
(71, 485),
(72, 295),
(72, 486),
(72, 487),
(72, 488),
(72, 489),
(72, 490),
(72, 491),
(72, 492),
(72, 493),
(72, 494),
(72, 495),
(72, 496),
(72, 497),
(73, 510),
(73, 552),
(73, 553),
(73, 555),
(73, 556),
(73, 573),
(73, 602),
(74, 499),
(74, 519),
(74, 536),
(74, 544),
(74, 546),
(74, 556),
(74, 575),
(74, 583),
(75, 524),
(75, 551),
(75, 564),
(76, 513),
(76, 529),
(76, 541),
(78, 507),
(78, 517),
(78, 533),
(78, 560),
(78, 585),
(78, 592),
(78, 598),
(79, 511),
(79, 522),
(79, 588),
(79, 594),
(80, 520),
(80, 538),
(80, 600),
(81, 535),
(81, 569),
(81, 572),
(81, 581),
(81, 591),
(82, 549),
(82, 559),
(82, 574),
(84, 525),
(84, 576),
(84, 580),
(84, 596),
(85, 505),
(85, 518),
(85, 531),
(85, 548),
(85, 562),
(86, 527),
(86, 545),
(86, 568),
(86, 599),
(87, 504),
(87, 558),
(87, 561),
(87, 565),
(87, 589),
(88, 543),
(88, 562),
(88, 579),
(89, 503),
(89, 516),
(89, 523),
(89, 534),
(90, 501),
(90, 528),
(90, 542),
(90, 578),
(91, 506),
(91, 530),
(91, 566),
(91, 570),
(91, 590),
(92, 563),
(92, 587),
(92, 595),
(92, 597),
(92, 601),
(93, 191),
(93, 502),
(93, 509),
(93, 512);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `userID` int(11) NOT NULL,
  `studentID` varchar(50) DEFAULT NULL,
  `firstName` varchar(255) NOT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) NOT NULL,
  `contactNumber` varchar(15) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `role` enum('Administrator','MCIIS Staff','Faculty','Student') NOT NULL,
  `password` varchar(255) NOT NULL,
  `createdTimestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`userID`, `studentID`, `firstName`, `middleName`, `lastName`, `contactNumber`, `email`, `role`, `password`, `createdTimestamp`) VALUES
(1, NULL, 'Elah Marvinelie', 'D.', 'Menil', '09123456789', 'emdmenil00759@usep.edu.ph', 'Administrator', '$2y$10$jZ9V3SMucfltztLzhC1upe1w7KNjC7tMpiKXBR40.2cjXrGqbflkS', '2025-08-27 14:56:34'),
(2, NULL, 'Gloren Joy', 'E.', 'Roque', '09987654321', 'gjeroque00800@usep.edu.ph', 'MCIIS Staff', '$2y$10$SKfQ91cOkjZNxN2Q5R3wQeQW2bQp/ofFF7l43..03Ddsj9N7tt5Tq', '2025-08-27 14:56:34');

-- --------------------------------------------------------

--
-- Table structure for table `userfacultyauditlog`
--

CREATE TABLE `userfacultyauditlog` (
  `auditLogID` int(11) NOT NULL,
  `modifiedBy` int(11) DEFAULT NULL,
  `targetUserID` int(11) DEFAULT NULL,
  `targetFacultyID` varchar(50) DEFAULT NULL,
  `actionType` enum('update user','update faculty') NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_facultyprofiles`
-- (See below for the actual view)
--
CREATE TABLE `vw_facultyprofiles` (
`facultyID` varchar(50)
,`fullName` text
,`position` varchar(100)
,`designation` varchar(100)
,`email` varchar(255)
,`ORCID` varchar(50)
,`contactNumber` varchar(50)
,`educationalAttainment` varchar(255)
,`fieldOfSpecialization` varchar(255)
,`researchInterest` varchar(255)
,`isPartOfCIC` tinyint(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_recentuserregistrations`
-- (See below for the actual view)
--
CREATE TABLE `vw_recentuserregistrations` (
`recentRegistrations` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_researchcountperprogram`
-- (See below for the actual view)
--
CREATE TABLE `vw_researchcountperprogram` (
`program` enum('Bachelor of Science in Information Technology','Bachelor of Science in Computer Science','Bachelor of Library and Information Science','Master of Library and Information Science','Master in Information Technology')
,`researchCount` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_researchcountperyear`
-- (See below for the actual view)
--
CREATE TABLE `vw_researchcountperyear` (
`publishedYear` year(4)
,`researchCount` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_researchfullinfo`
-- (See below for the actual view)
--
CREATE TABLE `vw_researchfullinfo` (
`researchID` int(11)
,`researchTitle` varchar(255)
,`program` enum('Bachelor of Science in Information Technology','Bachelor of Science in Computer Science','Bachelor of Library and Information Science','Master of Library and Information Science','Master in Information Technology')
,`publishedMonth` tinyint(4)
,`publishedYear` year(4)
,`researchAbstract` text
,`researchApprovalSheet` longblob
,`researchManuscript` longblob
,`researchAdviser` varchar(50)
,`adviserName` varchar(511)
,`researchers` mediumtext
,`panelists` mediumtext
,`keywords` mediumtext
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_topaccessedresearches`
-- (See below for the actual view)
--
CREATE TABLE `vw_topaccessedresearches` (
`researchID` int(11)
,`researchTitle` varchar(255)
,`accessCount` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_topadvisers`
-- (See below for the actual view)
--
CREATE TABLE `vw_topadvisers` (
`researchAdviser` varchar(50)
,`adviserName` varchar(511)
,`totalAdvised` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_toppanelists`
-- (See below for the actual view)
--
CREATE TABLE `vw_toppanelists` (
`facultyID` varchar(50)
,`panelistName` varchar(511)
,`totalPaneled` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_topsearchedkeywords`
-- (See below for the actual view)
--
CREATE TABLE `vw_topsearchedkeywords` (
`keywordID` int(11)
,`searchCount` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_userroledistribution`
-- (See below for the actual view)
--
CREATE TABLE `vw_userroledistribution` (
`role` varchar(13)
,`totalUsers` bigint(21)
);

-- --------------------------------------------------------

--
-- Structure for view `vw_facultyprofiles`
--
DROP TABLE IF EXISTS `vw_facultyprofiles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_facultyprofiles`  AS SELECT `faculty`.`facultyID` AS `facultyID`, concat(`faculty`.`firstName`,' ',`faculty`.`middleName`,' ',`faculty`.`lastName`) AS `fullName`, `faculty`.`position` AS `position`, `faculty`.`designation` AS `designation`, `faculty`.`email` AS `email`, `faculty`.`ORCID` AS `ORCID`, `faculty`.`contactNumber` AS `contactNumber`, `faculty`.`educationalAttainment` AS `educationalAttainment`, `faculty`.`fieldOfSpecialization` AS `fieldOfSpecialization`, `faculty`.`researchInterest` AS `researchInterest`, `faculty`.`isPartOfCIC` AS `isPartOfCIC` FROM `faculty` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_recentuserregistrations`
--
DROP TABLE IF EXISTS `vw_recentuserregistrations`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_recentuserregistrations`  AS SELECT count(0) AS `recentRegistrations` FROM `user` WHERE `user`.`createdTimestamp` >= current_timestamp() - interval 30 day ;

-- --------------------------------------------------------

--
-- Structure for view `vw_researchcountperprogram`
--
DROP TABLE IF EXISTS `vw_researchcountperprogram`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_researchcountperprogram`  AS SELECT `research`.`program` AS `program`, count(0) AS `researchCount` FROM `research` GROUP BY `research`.`program` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_researchcountperyear`
--
DROP TABLE IF EXISTS `vw_researchcountperyear`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_researchcountperyear`  AS SELECT `research`.`publishedYear` AS `publishedYear`, count(0) AS `researchCount` FROM `research` GROUP BY `research`.`publishedYear` ORDER BY `research`.`publishedYear` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `vw_researchfullinfo`
--
DROP TABLE IF EXISTS `vw_researchfullinfo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_researchfullinfo`  AS SELECT `r`.`researchID` AS `researchID`, `r`.`researchTitle` AS `researchTitle`, `r`.`program` AS `program`, `r`.`publishedMonth` AS `publishedMonth`, `r`.`publishedYear` AS `publishedYear`, `r`.`researchAbstract` AS `researchAbstract`, `r`.`researchApprovalSheet` AS `researchApprovalSheet`, `r`.`researchManuscript` AS `researchManuscript`, `r`.`researchAdviser` AS `researchAdviser`, concat(`f`.`firstName`,' ',`f`.`lastName`) AS `adviserName`, group_concat(distinct concat(`re`.`firstName`,' ',`re`.`lastName`) separator ', ') AS `researchers`, group_concat(distinct concat(`pf`.`firstName`,' ',`pf`.`lastName`) separator ', ') AS `panelists`, group_concat(distinct `k`.`keywordName` separator ', ') AS `keywords` FROM ((((((`research` `r` left join `faculty` `f` on(`r`.`researchAdviser` = `f`.`facultyID`)) left join `researcher` `re` on(`r`.`researchID` = `re`.`researchID`)) left join `panel` `p` on(`r`.`researchID` = `p`.`researchID`)) left join `faculty` `pf` on(`p`.`facultyID` = `pf`.`facultyID`)) left join `researchkeyword` `rk` on(`r`.`researchID` = `rk`.`researchID`)) left join `keyword` `k` on(`rk`.`keywordID` = `k`.`keywordID`)) GROUP BY `r`.`researchID` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_topaccessedresearches`
--
DROP TABLE IF EXISTS `vw_topaccessedresearches`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_topaccessedresearches`  AS SELECT `r`.`researchID` AS `researchID`, `r`.`researchTitle` AS `researchTitle`, count(`al`.`accessLogID`) AS `accessCount` FROM (`research` `r` join `researchaccesslog` `al` on(`r`.`researchID` = `al`.`researchID`)) GROUP BY `r`.`researchID`, `r`.`researchTitle` ORDER BY count(`al`.`accessLogID`) DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Structure for view `vw_topadvisers`
--
DROP TABLE IF EXISTS `vw_topadvisers`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_topadvisers`  AS SELECT `r`.`researchAdviser` AS `researchAdviser`, concat(`f`.`firstName`,' ',`f`.`lastName`) AS `adviserName`, count(0) AS `totalAdvised` FROM (`research` `r` join `faculty` `f` on(`r`.`researchAdviser` = `f`.`facultyID`)) GROUP BY `r`.`researchAdviser`, concat(`f`.`firstName`,' ',`f`.`lastName`) ORDER BY count(0) DESC LIMIT 0, 10 ;

-- --------------------------------------------------------

--
-- Structure for view `vw_toppanelists`
--
DROP TABLE IF EXISTS `vw_toppanelists`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_toppanelists`  AS SELECT `p`.`facultyID` AS `facultyID`, concat(`f`.`firstName`,' ',`f`.`lastName`) AS `panelistName`, count(`p`.`researchID`) AS `totalPaneled` FROM (`panel` `p` join `faculty` `f` on(`p`.`facultyID` = `f`.`facultyID`)) GROUP BY `p`.`facultyID`, concat(`f`.`firstName`,' ',`f`.`lastName`) ORDER BY count(`p`.`researchID`) DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Structure for view `vw_topsearchedkeywords`
--
DROP TABLE IF EXISTS `vw_topsearchedkeywords`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_topsearchedkeywords`  AS SELECT `keywordsearchlog`.`keywordID` AS `keywordID`, count(0) AS `searchCount` FROM `keywordsearchlog` GROUP BY `keywordsearchlog`.`keywordID` ORDER BY count(0) DESC LIMIT 0, 5 ;

-- --------------------------------------------------------

--
-- Structure for view `vw_userroledistribution`
--
DROP TABLE IF EXISTS `vw_userroledistribution`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_userroledistribution`  AS WITH AllRoles AS (SELECT 'Administrator' AS `role` UNION SELECT 'MCIIS Staff' AS `MCIIS Staff` UNION SELECT 'Faculty' AS `Faculty` UNION SELECT 'Student' AS `Student`) SELECT `ar`.`role` AS `role`, count(`u`.`userID`) AS `totalUsers` FROM (`allroles` `ar` left join `user` `u` on(`ar`.`role` = `u`.`role`)) GROUP BY `ar`.`role` ORDER BY CASE `ar`.`role` WHEN 'Administrator' THEN 1 WHEN 'MCIIS Staff' THEN 2 WHEN 'Faculty' THEN 3 WHEN 'Student' THEN 4 END AS `ASCend` ASC  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `contact`
--
ALTER TABLE `contact`
  ADD PRIMARY KEY (`contactID`),
  ADD KEY `idx_userID` (`userID`);

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`facultyID`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `keyword`
--
ALTER TABLE `keyword`
  ADD PRIMARY KEY (`keywordID`),
  ADD UNIQUE KEY `keywordName` (`keywordName`);

--
-- Indexes for table `keywordsearchlog`
--
ALTER TABLE `keywordsearchlog`
  ADD PRIMARY KEY (`searchLogID`),
  ADD KEY `keywordID` (`keywordID`),
  ADD KEY `userID` (`userID`);

--
-- Indexes for table `panel`
--
ALTER TABLE `panel`
  ADD PRIMARY KEY (`panelID`),
  ADD KEY `facultyID` (`facultyID`),
  ADD KEY `researchID` (`researchID`);

--
-- Indexes for table `research`
--
ALTER TABLE `research`
  ADD PRIMARY KEY (`researchID`),
  ADD UNIQUE KEY `researchTitle` (`researchTitle`),
  ADD KEY `uploadedBy` (`uploadedBy`),
  ADD KEY `researchAdviser` (`researchAdviser`);

--
-- Indexes for table `researchaccesslog`
--
ALTER TABLE `researchaccesslog`
  ADD PRIMARY KEY (`accessLogID`),
  ADD KEY `researchID` (`researchID`),
  ADD KEY `userID` (`userID`);

--
-- Indexes for table `researchentrylog`
--
ALTER TABLE `researchentrylog`
  ADD PRIMARY KEY (`entryLogID`),
  ADD KEY `performedBy` (`performedBy`),
  ADD KEY `researchID` (`researchID`);

--
-- Indexes for table `researcher`
--
ALTER TABLE `researcher`
  ADD PRIMARY KEY (`researcherID`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `researchID` (`researchID`);

--
-- Indexes for table `researchkeyword`
--
ALTER TABLE `researchkeyword`
  ADD PRIMARY KEY (`researchID`,`keywordID`),
  ADD KEY `keywordID` (`keywordID`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`userID`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `studentID` (`studentID`);

--
-- Indexes for table `userfacultyauditlog`
--
ALTER TABLE `userfacultyauditlog`
  ADD PRIMARY KEY (`auditLogID`),
  ADD KEY `modifiedBy` (`modifiedBy`),
  ADD KEY `targetUserID` (`targetUserID`),
  ADD KEY `targetFacultyID` (`targetFacultyID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `contact`
--
ALTER TABLE `contact`
  MODIFY `contactID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `keyword`
--
ALTER TABLE `keyword`
  MODIFY `keywordID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=603;

--
-- AUTO_INCREMENT for table `keywordsearchlog`
--
ALTER TABLE `keywordsearchlog`
  MODIFY `searchLogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `panel`
--
ALTER TABLE `panel`
  MODIFY `panelID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `research`
--
ALTER TABLE `research`
  MODIFY `researchID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `researchaccesslog`
--
ALTER TABLE `researchaccesslog`
  MODIFY `accessLogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `researchentrylog`
--
ALTER TABLE `researchentrylog`
  MODIFY `entryLogID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `researcher`
--
ALTER TABLE `researcher`
  MODIFY `researcherID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=240;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `userID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `userfacultyauditlog`
--
ALTER TABLE `userfacultyauditlog`
  MODIFY `auditLogID` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `contact`
--
ALTER TABLE `contact`
  ADD CONSTRAINT `contact_ibfk_1` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE;

--
-- Constraints for table `keywordsearchlog`
--
ALTER TABLE `keywordsearchlog`
  ADD CONSTRAINT `keywordsearchlog_ibfk_1` FOREIGN KEY (`keywordID`) REFERENCES `keyword` (`keywordID`) ON DELETE CASCADE,
  ADD CONSTRAINT `keywordsearchlog_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE;

--
-- Constraints for table `panel`
--
ALTER TABLE `panel`
  ADD CONSTRAINT `panel_ibfk_1` FOREIGN KEY (`facultyID`) REFERENCES `faculty` (`facultyID`) ON DELETE CASCADE,
  ADD CONSTRAINT `panel_ibfk_2` FOREIGN KEY (`researchID`) REFERENCES `research` (`researchID`) ON DELETE CASCADE;

--
-- Constraints for table `research`
--
ALTER TABLE `research`
  ADD CONSTRAINT `research_ibfk_1` FOREIGN KEY (`uploadedBy`) REFERENCES `user` (`userID`) ON DELETE SET NULL,
  ADD CONSTRAINT `research_ibfk_2` FOREIGN KEY (`researchAdviser`) REFERENCES `faculty` (`facultyID`) ON DELETE SET NULL;

--
-- Constraints for table `researchaccesslog`
--
ALTER TABLE `researchaccesslog`
  ADD CONSTRAINT `researchaccesslog_ibfk_1` FOREIGN KEY (`researchID`) REFERENCES `research` (`researchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `researchaccesslog_ibfk_2` FOREIGN KEY (`userID`) REFERENCES `user` (`userID`) ON DELETE CASCADE;

--
-- Constraints for table `researchentrylog`
--
ALTER TABLE `researchentrylog`
  ADD CONSTRAINT `researchentrylog_ibfk_1` FOREIGN KEY (`performedBy`) REFERENCES `user` (`userID`),
  ADD CONSTRAINT `researchentrylog_ibfk_2` FOREIGN KEY (`researchID`) REFERENCES `research` (`researchID`) ON DELETE CASCADE;

--
-- Constraints for table `researcher`
--
ALTER TABLE `researcher`
  ADD CONSTRAINT `researcher_ibfk_1` FOREIGN KEY (`researchID`) REFERENCES `research` (`researchID`) ON DELETE CASCADE;

--
-- Constraints for table `researchkeyword`
--
ALTER TABLE `researchkeyword`
  ADD CONSTRAINT `researchkeyword_ibfk_1` FOREIGN KEY (`researchID`) REFERENCES `research` (`researchID`) ON DELETE CASCADE,
  ADD CONSTRAINT `researchkeyword_ibfk_2` FOREIGN KEY (`keywordID`) REFERENCES `keyword` (`keywordID`) ON DELETE CASCADE;

--
-- Constraints for table `userfacultyauditlog`
--
ALTER TABLE `userfacultyauditlog`
  ADD CONSTRAINT `userfacultyauditlog_ibfk_1` FOREIGN KEY (`modifiedBy`) REFERENCES `user` (`userID`),
  ADD CONSTRAINT `userfacultyauditlog_ibfk_2` FOREIGN KEY (`targetUserID`) REFERENCES `user` (`userID`) ON DELETE SET NULL,
  ADD CONSTRAINT `userfacultyauditlog_ibfk_3` FOREIGN KEY (`targetFacultyID`) REFERENCES `faculty` (`facultyID`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
