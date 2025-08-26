-- ======================================================
-- IMDb PRACTICE QUERIES (Day 1 - Day 7)
-- ======================================================

-- DAY 1: Foundation

SELECT * 
FROM title_basics 
WHERE titleType = 'movie'
LIMIT 10;

-- Query 2: Column Selection - Movie title, year, runtime
SELECT primaryTitle, startYear, runtimeMinutes
FROM title_basics
WHERE titleType = 'movie'
LIMIT 10;

-- Query 3: WHERE Filtering - Movies released after 2015
SELECT primaryTitle, startYear
FROM title_basics
WHERE titleType = 'movie' AND startYear > 2015
ORDER BY startYear ASC;

-- Query 4: Multiple Conditions - Long action movies after 2010
SELECT primaryTitle, startYear, runtimeMinutes, genres
FROM title_basics
WHERE titleType = 'movie'
  AND startYear > 2010
  AND runtimeMinutes > 120
  AND genres LIKE '%Action%';

-- Query 5: ORDER BY - Sort movies by release year
SELECT primaryTitle, startYear
FROM title_basics
WHERE titleType = 'movie'
  AND startYear IS NOT NULL
ORDER BY startYear DESC
LIMIT 10;

-- DAY 2: Aggregation

-- Query 6: COUNT with GROUP BY - Movies per genre
SELECT genres, COUNT(*) AS movie_count
FROM title_basics
WHERE titleType = 'movie'
AND genres IS NOT NULL
GROUP BY genres
ORDER BY movie_count DESC;

-- Query 7: SUM with GROUP BY - Total votes per genre
SELECT b.genres, SUM(r.numVotes) AS total_votes
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.titleType = 'movie'
GROUP BY b.genres
ORDER BY total_votes DESC;

-- Query 8: AVG with GROUP BY - Average rating per genre
SELECT b.genres, AVG(r.averageRating) AS avg_rating
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.titleType = 'movie'
GROUP BY b.genres
ORDER BY avg_rating DESC;

-- Query 9: HAVING - Genres with >500 movies
SELECT genres, COUNT(*) AS total_movies
FROM title_basics
WHERE titleType = 'movie'
GROUP BY genres
HAVING COUNT(*) > 500
ORDER BY total_movies DESC;

-- Query 10: MAX/MIN with GROUP BY - Yearly extremes
SELECT b.startYear, 
       MAX(r.averageRating) AS highest_rating,
       MIN(r.averageRating) AS lowest_rating
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.titleType = 'movie'
AND StartYear is NOT NULL
GROUP BY b.startYear
ORDER BY b.startYear DESC;

-- DAY 3-4: Multi-Table JOINs

-- Query 11: INNER JOIN - Movies with ratings
SELECT b.primaryTitle, r.averageRating, r.numVotes
FROM title_basics b
INNER JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.titleType = 'movie'
ORDER BY r.averageRating DESC
LIMIT 10;

-- Query 12: LEFT JOIN - Movies including unrated
SELECT b.primaryTitle, r.averageRating, r.numVotes
FROM title_basics b
LEFT JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.titleType = 'movie'
ORDER BY r.averageRating NULLS LAST
LIMIT 10;

-- Query 13: RIGHT JOIN - Ratings and corresponding movies
SELECT b.primaryTitle, r.averageRating
FROM title_basics b
RIGHT JOIN title_ratings r ON b.tconst = r.tconst
ORDER BY r.averageRating DESC
LIMIT 10;

-- Query 14: Multiple JOINs - Movie, rating, actor
SELECT b.primaryTitle, r.averageRating, n.primaryName AS actor
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
JOIN title_principals p ON b.tconst = p.tconst
JOIN name_basics n ON p.nconst = n.nconst
WHERE b.titleType = 'movie'
  AND p.category = 'actor'
ORDER BY r.averageRating DESC
LIMIT 10;

-- DAY 5-6: Nested Queries & CTEs
-- Query 15a: Subquery - Above average movies
SELECT primaryTitle, averageRating
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE r.averageRating > (
    SELECT AVG(averageRating) 
    FROM title_ratings
)
ORDER BY r.averageRating DESC
LIMIT 10;

-- Query 15b: CTE - Top 5 movies per year
WITH yearly_ranked AS (
    SELECT b.startYear, b.primaryTitle, r.averageRating,
           ROW_NUMBER() OVER (PARTITION BY b.startYear ORDER BY r.averageRating DESC) AS rank_in_year
    FROM title_basics b
    JOIN title_ratings r ON b.tconst = r.tconst
    WHERE b.titleType = 'movie'
)
SELECT * FROM yearly_ranked
WHERE rank_in_year <= 5
ORDER BY startYear DESC, averageRating DESC;

-- DAY 7: Integration & Project
-- Query 16: Complex yearly report
WITH yearly_stats AS (
    SELECT b.startYear,
           COUNT(*) AS total_movies,
           AVG(r.averageRating) AS avg_rating
    FROM title_basics b
    JOIN title_ratings r ON b.tconst = r.tconst
    WHERE b.titleType = 'movie'
    GROUP BY b.startYear
),
genre_stats AS (
    SELECT b.startYear, b.genres, AVG(r.averageRating) AS genre_avg_rating,
           RANK() OVER (PARTITION BY b.startYear ORDER BY AVG(r.averageRating) DESC) AS genre_rank
    FROM title_basics b
    JOIN title_ratings r ON b.tconst = r.tconst
    WHERE b.titleType = 'movie'
    GROUP BY b.startYear, b.genres
)
SELECT y.startYear, y.total_movies, y.avg_rating, g.genres AS top_genre, g.genre_avg_rating
FROM yearly_stats y
JOIN genre_stats g ON y.startYear = g.startYear
WHERE g.genre_rank = 1
ORDER BY y.startYear DESC;