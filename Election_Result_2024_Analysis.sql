
CREATE DATABASE IF NOT EXISTS Election_Result;
USE Election_Result;


SELECT * FROM election_result_2024;


SELECT COUNT(*) AS Total_Records
FROM election_result_2024;


SELECT COUNT(*) AS Total_Null_Candidate
FROM election_result_2024
WHERE candidate_name IS NULL OR candidate_name = '';


SELECT COUNT(*) AS Null_EVM_Votes
FROM election_result_2024
WHERE EVM_votes IS NULL;


SELECT COUNT(*) AS Null_Total_Votes
FROM election_result_2024
WHERE total_votes IS NULL;


DELETE FROM election_result_2024
WHERE EVM_votes IS NULL AND total_votes IS NULL;


SELECT COUNT(DISTINCT constituency_name) AS Total_Constituencies
FROM election_result_2024;


SELECT COUNT(DISTINCT party_name) AS Total_Parties
FROM election_result_2024;


SELECT state_name, COUNT(DISTINCT constituency_name) AS Total_Constituencies
FROM election_result_2024
GROUP BY state_name
ORDER BY Total_Constituencies DESC;


SELECT state_name, COUNT(DISTINCT party_name) AS Total_Parties
FROM election_result_2024
GROUP BY state_name
ORDER BY Total_Parties DESC;


SELECT state_name, constituency_name, COUNT(DISTINCT party_name) AS Total_Parties
FROM election_result_2024
GROUP BY state_name, constituency_name
ORDER BY Total_Parties DESC;


SELECT party_name, COUNT(DISTINCT candidate_name) AS Total_Candidates
FROM election_result_2024
GROUP BY party_name
ORDER BY Total_Candidates DESC;


SELECT party_name, state_name, COUNT(*) AS Total_Seats
FROM election_result_2024
GROUP BY party_name, state_name
ORDER BY party_name, Total_Seats DESC;


SELECT party_name, state_name, COUNT(*) AS Total_Seats
FROM election_result_2024
WHERE party_name = 'Bharatiya Janata Party'
GROUP BY party_name, state_name
ORDER BY Total_Seats DESC;


SELECT 
    SUM(EVM_votes) AS Total_EVM_Votes,
    SUM(postal_votes) AS Total_Postal_Votes,
    SUM(total_votes) AS Total_Votes,
    ROUND(SUM(EVM_votes) * 100.0 / NULLIF(SUM(total_votes),0), 2) AS Percentage_EVM_Voting,
    ROUND(SUM(postal_votes) * 100.0 / NULLIF(SUM(total_votes),0), 2) AS Percentage_Postal_Voting
FROM election_result_2024;


SELECT party_name, COUNT(*) AS Seat_Won
FROM election_result_2024
WHERE `rank` = 1
GROUP BY party_name
ORDER BY Seat_Won DESC
LIMIT 5;


SELECT COUNT(*) AS Independent_Candidates
FROM election_result_2024
WHERE party_name = 'Independent';


SELECT candidate_name, SUM(total_votes) AS Total_Votes
FROM election_result_2024
WHERE candidate_name IN ('AMIT SHAH', 'NARENDRA MODI')
GROUP BY candidate_name
ORDER BY Total_Votes DESC;


SELECT party_name, COUNT(*) AS Constituencies_Contested
FROM election_result_2024
GROUP BY party_name
HAVING COUNT(*) > 10
ORDER BY Constituencies_Contested DESC;


SELECT state_name, party_name, COUNT(*) AS Seat_Won
FROM election_result_2024
WHERE `rank` = 1
GROUP BY state_name, party_name
ORDER BY Seat_Won DESC;


SELECT 
    party_name,
    SUM(total_votes) AS Total_Votes,
    ROUND(SUM(total_votes) * 100.0 / NULLIF((SELECT SUM(total_votes) FROM election_result_2024),0), 2) AS Vote_Share_Percentage
FROM election_result_2024
GROUP BY party_name
ORDER BY Vote_Share_Percentage DESC;


SELECT party_name, SUM(total_votes) AS Total_Votes
FROM election_result_2024
WHERE state_name = 'Andhra Pradesh'
GROUP BY party_name
ORDER BY Total_Votes DESC
LIMIT 3;


SELECT party_name, SUM(total_votes) AS Total_Votes
FROM election_result_2024
WHERE state_name = 'Bihar'
GROUP BY party_name
ORDER BY Total_Votes DESC
LIMIT 3;


WITH RankedVotes AS (
    SELECT 
        state_name,
        constituency_name,
        total_votes,
        RANK() OVER (PARTITION BY constituency_name ORDER BY total_votes DESC) AS Vote_Rank
    FROM election_result_2024
)
SELECT 
    A.state_name,
    A.constituency_name,
    (A.total_votes - B.total_votes) AS Vote_Margin,
    ROUND((A.total_votes - B.total_votes) * 100.0 / NULLIF(A.total_votes,0), 2) AS Percentage_Margin
FROM RankedVotes A
JOIN RankedVotes B
    ON A.constituency_name = B.constituency_name
   AND A.Vote_Rank = 1 AND B.Vote_Rank = 2
ORDER BY Percentage_Margin DESC;


WITH Rank_CTE AS (
    SELECT 
        state_name,
        constituency_name,
        candidate_name,
        total_votes,
        RANK() OVER (PARTITION BY constituency_name ORDER BY total_votes DESC) AS Vote_Rank
    FROM election_result_2024
)
SELECT 
    A.constituency_name,
    A.state_name,
    A.candidate_name AS Winner,
    B.candidate_name AS Runner_Up,
    (A.total_votes - B.total_votes) AS Margin
FROM Rank_CTE A
JOIN Rank_CTE B
    ON A.constituency_name = B.constituency_name
   AND A.Vote_Rank = 1 AND B.Vote_Rank = 2
WHERE (A.total_votes - B.total_votes) < 1000;


WITH Election_CTE AS (
    SELECT 
        state_name,
        constituency_name,
        party_name,
        candidate_name,
        total_votes,
        RANK() OVER (PARTITION BY constituency_name ORDER BY total_votes DESC) AS Vote_Rank
    FROM election_result_2024
)
SELECT 
    A.constituency_name,
    A.state_name,
    A.party_name AS Winner_Party,
    B.party_name AS Runner_Up_Party,
    (A.total_votes - B.total_votes) AS Vote_Margin,
    ROUND((A.total_votes - B.total_votes) * 100.0 / NULLIF(A.total_votes,0), 2) AS Percentage_Margin,
    A.candidate_name AS Winner_Candidate
FROM Election_CTE A
JOIN Election_CTE B
    ON A.constituency_name = B.constituency_name
   AND A.Vote_Rank = 1 AND B.Vote_Rank = 2
ORDER BY Percentage_Margin DESC;
