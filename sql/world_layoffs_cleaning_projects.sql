-- Database creation and data importation

CREATE DATABASE world_layoffs;

-- Imported datafile

SELECT count(*)
FROM layoffs;


SELECT *
FROM layoffs
ORDER BY 1;

-- Staged the raw dataset to preseve the original

CREATE TABLE layoffs_new like layoffs;


SELECT *
FROM layoffs_new;


INSERT INTO layoffs_new
SELECT *
FROM layoffs;

-- USing row_number(), we removed duplicates

SELECT *
FROM layoffs_new;


SELECT *,
       row_number() over(PARTITION BY company, LOCATION, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_new ;

-- create a new table to filter duplicates

CREATE TABLE `layoffs_dedup` (`company` text, `location` text, `industry` text, `total_laid_off` int DEFAULT NULL,
                                                                                                             `percentage_laid_off` text, `date` text, `stage` text, `country` text, `funds_raised_millions` int DEFAULT NULL,
                                                                                                                                                                                                                        `row_num` int) ENGINE=InnoDB DEFAULT
CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_dedup ;


INSERT INTO layoffs_dedup
SELECT *,
       row_number() over(PARTITION BY company, LOCATION, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_new ;

-- removing duplicates

SELECT *
FROM layoffs_dedup
WHERE row_num >1;


DELETE
FROM layoffs_dedup
WHERE row_num >1;

-- STANDARDIZATION AND FORMATING (Standardizing all the columns)

CREATE TABLE `layoffs_standard` (`company` text, `location` text, `industry` text, `total_laid_off` int DEFAULT NULL,
                                                                                                                `percentage_laid_off` text, `date` date DEFAULT NULL,
                                                                                                                                                                `stage` text, `country` text, `funds_raised_millions` int DEFAULT NULL,
                                                                                                                                                                                                                                  `row_num` int DEFAULT NULL) ENGINE=InnoDB DEFAULT
CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_standard;


INSERT INTO layoffs_standard
SELECT *
FROM layoffs_dedup ;

-- Standardizing & Formating 'Company' colum

SELECT DISTINCT company,
                trim(company)
FROM layoffs_standard;


UPDATE layoffs_standard
SET company = trim(company) ;

-- Standardizing & Formating 'location' colum

SELECT DISTINCT LOCATION,
                count(LOCATION)
FROM layoffs_standard
GROUP BY LOCATION;


SELECT *
FROM layoffs_standard
WHERE LOCATION like 'malm%';


UPDATE layoffs_standard
SET LOCATION = 'Malmo'
WHERE LOCATION like 'malm%';

-- Standardizing & Formating 'industry' colum

SELECT DISTINCT industry,
                count(industry)
FROM layoffs_standard
GROUP BY industry;


SELECT DISTINCT industry,
                count(industry)
FROM layoffs_standard
WHERE industry like 'cryp%'
GROUP BY industry;


UPDATE layoffs_standard
SET industry = 'Crypto'
WHERE industry like 'cryp%';

-- Standardizing & Formating 'Country' colum

SELECT DISTINCT country,
                count(country)
FROM layoffs_standard
GROUP BY country ;


UPDATE layoffs_standard
SET country = 'United States'
WHERE country like 'United States%';

-- Standardizing & Formating 'Date' colum

SELECT `date`
FROM layoffs_standard ;


UPDATE layoffs_standard
SET `date` = str_to_date(`date`, '%m/%d/%Y') ;


ALTER TABLE layoffs_standard MODIFY COLUMN `date` date ;


SELECT *
FROM layoffs_standard;

-- Populating Null & Missing values

CREATE TABLE `layoffs_null` (`company` text, `location` text, `industry` text, `total_laid_off` int DEFAULT NULL,
                                                                                                            `percentage_laid_off` text, `date` date DEFAULT NULL,
                                                                                                                                                            `stage` text, `country` text, `funds_raised_millions` int DEFAULT NULL,
                                                                                                                                                                                                                              `row_num` int DEFAULT NULL) ENGINE=InnoDB DEFAULT
CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_null;


INSERT INTO layoffs_null
SELECT *
FROM layoffs_standard;

/* Firstly, let us set all '' to null
To maintain uniformity in our filters */
UPDATE layoffs_null
SET company = nullif(trim(company), ''),
    LOCATION = nullif(trim(LOCATION), ''),
               industry = nullif(trim(industry), ''),
               country = nullif(trim(country), '')
WHERE company = ''
  OR LOCATION = ''
  OR industry = ''
  OR country = '';

-- Null 'company' values

SELECT *
FROM layoffs_null
WHERE company IS NULL;

-- No null company values
 -- Null 'location' values

SELECT *
FROM layoffs_null
WHERE LOCATION IS NULL;

-- Null 'industry' values

SELECT *
FROM layoffs_null
WHERE industry IS NULL;


SELECT company,
       industry
FROM layoffs_null
WHERE company like 'ball%';


SELECT t1.industry,
       t2.industry
FROM layoffs_null t1
JOIN layoffs_null t2 ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Used a self join to populate the null values for companies with the same name
UPDATE layoffs_null t1
JOIN layoffs_null t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


SELECT *
FROM layoffs_null
WHERE total_laid_off IS NULL
ORDER BY 1;


SELECT *
FROM layoffs_null
WHERE percentage_laid_off IS NULL
ORDER BY 1;


SELECT *
FROM layoffs_null
WHERE percentage_laid_off IS NULL
  OR total_laid_off IS NULL
ORDER BY 1;


SELECT *
FROM layoffs_null
WHERE percentage_laid_off IS NULL
  AND total_laid_off IS NULL
ORDER BY 1;

/*Since this table does not have total_laid_off nor percentage_laid_off
We can assume that it is a wrong data and the companies didnt lay anybody off.
Hence we can delete the columns for companies without layoffs */
DELETE
FROM layoffs_null
WHERE percentage_laid_off IS NULL
  AND total_laid_off IS NULL;

-- Removing unnecessary columns and final data presentation

CREATE TABLE `layoffs_clean` (`company` text, `location` text, `industry` text, `total_laid_off` int DEFAULT NULL,
                                                                                                             `percentage_laid_off` text, `date` date DEFAULT NULL,
                                                                                                                                                             `stage` text, `country` text, `funds_raised_millions` int DEFAULT NULL) ENGINE=InnoDB DEFAULT
CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_clean;


INSERT INTO layoffs_clean
SELECT company,
       LOCATION,
       industry,
       total_laid_off,
       percentage_laid_off,
       `date`,
       stage,
       country,
       funds_raised_millions
FROM layoffs_null;

-- Sanity Check
SELECT COUNT(*) AS final_row_count
FROM layoffs_clean;

/* The row_num column was only used to assist in removing duplicates,
and it has been removed.
We now have a clean table to work with */
