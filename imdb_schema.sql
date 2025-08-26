-- Database: IMDb

-- IMDb Dataset: PostgreSQL Schema + Import Script

-- Drop if exists 
DROP TABLE IF EXISTS title_akas CASCADE;
DROP TABLE IF EXISTS title_principals CASCADE;
DROP TABLE IF EXISTS title_ratings CASCADE;
DROP TABLE IF EXISTS name_basics CASCADE;
DROP TABLE IF EXISTS title_basics CASCADE;

-- Schema Definitions

CREATE TABLE title_basics (
    tconst TEXT PRIMARY KEY,
    titleType TEXT,
    primaryTitle TEXT,
    originalTitle TEXT,
    isAdult BOOLEAN,
    startYear INT,
    endYear INT,
    runtimeMinutes INT,
    genres TEXT
);

CREATE TABLE title_akas (
    titleId TEXT,
    ordering INT,
    title TEXT,
    region TEXT,
    language TEXT,
    types TEXT,
    attributes TEXT,
    isOriginalTitle BOOLEAN,
    FOREIGN KEY (titleId) REFERENCES title_basics(tconst)
);

CREATE TABLE name_basics (
    nconst TEXT PRIMARY KEY,
    primaryName TEXT,
    birthYear INT,
    deathYear INT,
    primaryProfession TEXT,
    knownForTitles TEXT
);

CREATE TABLE title_principals (
    tconst TEXT,
    ordering INT,
    nconst TEXT,
    category TEXT,
    job TEXT,
    characters TEXT,
    FOREIGN KEY (tconst) REFERENCES title_basics(tconst),
    FOREIGN KEY (nconst) REFERENCES name_basics(nconst)
);

CREATE TABLE title_ratings (
    tconst TEXT PRIMARY KEY,
    averageRating FLOAT,
    numVotes INT,
    FOREIGN KEY (tconst) REFERENCES title_basics(tconst)
);

-- Data Import (COPY) using psql
-- NOTE: Update paths to where the TSV files are located

-- name.basics
\copy name_basics FROM 'path/to/name.basics_utf8.tsv' 
WITH (FORMAT text, DELIMITER E'\t', NULL '\N', HEADER true, ENCODING 'UTF8');

-- title.basics
\copy title_basics FROM 'path/to/title.basics_utf8.tsv' 
WITH (FORMAT text, DELIMITER E'\t', NULL '\N', HEADER true, ENCODING 'UTF8');

-- title.akas
\copy title_akas FROM 'path/to/title.akas_utf8.tsv' 
WITH (FORMAT text, DELIMITER E'\t', NULL '\N', HEADER true, ENCODING 'UTF8');

-- title.principles
\copy title_principals FROM 'path/to/title.principals_utf8.tsv' 
WITH (FORMAT text, DELIMITER E'\t', NULL '\N', HEADER true, ENCODING 'UTF8');

-- title.ratings
\copy title_ratings FROM 'path/to/title.ratings_utf8.tsv' 
WITH (FORMAT text, DELIMITER E'\t', NULL '\N', HEADER true, ENCODING 'UTF8');

-- Indexing
CREATE INDEX idx_title_basics_type ON title_basics(titleType);
CREATE INDEX idx_title_basics_year ON title_basics(startYear);
CREATE INDEX idx_title_ratings_votes ON title_ratings(numVotes);
CREATE INDEX idx_name_basics_name ON name_basics(primaryName);

-- Indexes to speed up the lookup
CREATE INDEX idx_tp_tconst ON title_principals(tconst);
CREATE INDEX idx_tp_nconst ON title_principals(nconst);
CREATE INDEX idx_tb_tconst ON title_basics(tconst);
CREATE INDEX idx_nb_nconst ON name_basics(nconst);


