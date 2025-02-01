-- File containing all SQl queries of part 2

-- PART A. BASIC
-- A.1
UPDATE request
SET title = CONCAT(title, ' (', TO_CHAR(start_date, 'YYYY-MM-DD'), ' - ', TO_CHAR(end_date, 'YYYY-MM-DD'), ')');

-- A.2
SELECT
    va.request_id,
    va.volunteer_id,
    COALESCE(ms.matching_skills, 0) AS matching_skills
FROM
    volunteer_application va
LEFT JOIN
    (
        SELECT
            v.id AS volunteer_id,
            r.id AS request_id,
            COUNT(sa.skill_name) AS matching_skills
        FROM
            request r
        JOIN
            volunteer_application va ON r.id = va.request_id
        JOIN
            volunteer v ON va.volunteer_id = v.id
        LEFT JOIN
            request_skill rs ON r.id = rs.request_id
        LEFT JOIN
            skill_assignment sa ON v.id = sa.volunteer_id AND rs.skill_name = sa.skill_name
        WHERE
            va.is_valid = TRUE
        GROUP BY
            v.id, r.id
    ) ms ON va.volunteer_id = ms.volunteer_id AND va.request_id = ms.request_id
WHERE
    va.is_valid = TRUE
ORDER BY
    va.request_id, matching_skills DESC, va.volunteer_id;

-- A.3
SELECT
    r.id AS request_id,
    rs.skill_name,
    GREATEST(SUM(rs.min_need) - COALESCE(COUNT(va.volunteer_id), 0), 0) AS missing_volunteers
FROM
    request r
JOIN
    request_skill rs ON r.id = rs.request_id
LEFT JOIN
    volunteer_application va ON r.id = va.request_id
LEFT JOIN
    skill_assignment sa ON va.volunteer_id = sa.volunteer_id AND rs.skill_name = sa.skill_name
WHERE
    va.is_valid = TRUE
GROUP BY
    r.id, rs.skill_name
ORDER BY
    r.id, rs.skill_name;

-- A.4
SELECT
    r.id AS request_id,
    r.title AS request_title,
    r.priority_value AS request_priority,
    r.register_by_date AS register_by_date,
    b.id AS beneficiary_id,
    b.name AS beneficiary_name
FROM
    request r
JOIN
    beneficiary b ON r.beneficiary_id = b.id
ORDER BY
    r.priority_value DESC,
    ABS(EXTRACT(DAY FROM r.register_by_date - CURRENT_DATE))  ASC;

-- A.5
SELECT v.id AS volunteer_id,
       r.id AS request_id,
       r.title
FROM volunteer v
JOIN volunteer_range vr ON v.id = vr.volunteer_id
JOIN request_location rl ON vr.city_id = rl.city_id
JOIN request r ON r.id = rl.request_id
LEFT JOIN request_skill rs ON r.id = rs.request_id
WHERE (r.interest IS NULL OR r.interest IN (SELECT interest_name FROM interest_assignment WHERE volunteer_id = v.id))
  AND (rs.skill_name IS NULL OR rs.skill_name IN (SELECT skill_name FROM skill_assignment WHERE volunteer_id = v.id))
GROUP BY v.id, r.id
HAVING COUNT(rs.skill_name) >= 2 OR COUNT(rs.skill_name) = 0;

-- A.6
SELECT v.id AS volunteer_id,
       r.id AS request_id,
       r.title
FROM volunteer v
JOIN interest_assignment ia ON v.id = ia.volunteer_id
JOIN request r ON r.interest = ia.interest_name
WHERE r.register_by_date >= NOW()
ORDER BY v.id, r.id;

-- A.7
SELECT r.id AS request_id,
       v.name AS volunteer_name,
       v.email AS volunteer_email,
       v.travel_readiness
FROM volunteer_application va
JOIN request r ON va.request_id = r.id
JOIN volunteer v ON va.volunteer_id = v.id
LEFT JOIN volunteer_range vr ON v.id = vr.volunteer_id AND vr.city_id IN (SELECT city_id FROM request_location WHERE request_id = r.id)
WHERE vr.city_id IS NULL
ORDER BY v.travel_readiness DESC;

-- A.8
SELECT skill_name,
       AVG(value) AS average_importance
FROM request_skill
GROUP BY skill_name
ORDER BY average_importance DESC;


-- A.9
SELECT
    rs.skill_name,
    COUNT(rs.request_id) AS demand_count
FROM
    request_skill rs
GROUP BY
    rs.skill_name
ORDER BY
    demand_count DESC;

-- A.10
SELECT
    EXTRACT(YEAR FROM va.modified) AS year,
    EXTRACT(MONTH FROM va.modified) AS month,
    COUNT(va.id) AS total_applications,
    COUNT(CASE WHEN va.is_valid = TRUE THEN 1 END) AS approved_applications,
    ROUND(COUNT(CASE WHEN va.is_valid = TRUE THEN 1 END)::NUMERIC / COUNT(va.id) * 100, 2) AS approval_rate
FROM
    volunteer_application va
GROUP BY
    EXTRACT(YEAR FROM va.modified), EXTRACT(MONTH FROM va.modified)
ORDER BY
    year DESC, month DESC;

-- A.11
SELECT
    v.id AS volunteer_id,
    v.name AS volunteer_name,
    sa.skill_name,
    r.id AS request_id,
    r.start_date
FROM
    volunteer v
JOIN
    skill_assignment sa ON v.id = sa.volunteer_id
JOIN
    request_skill rs ON sa.skill_name = rs.skill_name
JOIN
    request r ON rs.request_id = r.id
WHERE
    r.start_date > CURRENT_DATE
ORDER BY
    r.start_date ASC, v.id ASC;

-- A.12
SELECT b.id, b.name, SUM(EXTRACT(EPOCH FROM (r.end_date - r.start_date)) / 3600 * va.valid_volunteer_count) AS total_volunteer_hours
FROM beneficiary b
JOIN request r ON b.id = r.beneficiary_id
JOIN (
    SELECT va.request_id, COUNT(va.id) AS valid_volunteer_count
    FROM volunteer_application va
    WHERE va.is_valid = TRUE
    GROUP BY va.request_id
) va ON r.id = va.request_id
GROUP BY b.id, b.name
ORDER BY total_volunteer_hours desc;


-- PART B. ADVANCED

-- a) Views
-- a.1
CREATE VIEW beneficiary_statistics AS
SELECT
    b.id AS beneficiary_id,
    b.name AS beneficiary_name,
    ROUND(applications_per_request.avg_applications::numeric,3) AS avg_number_volunteers_applied,
    ROUND(AVG(volunteer_ages.age)::numeric,3) AS avg_age_applied,
    ROUND(AVG(rq.number_of_volunteers)::numeric,3) AS avg_number_volunteers_needed
FROM
    beneficiary b
JOIN
    request rq ON b.id = rq.beneficiary_id
JOIN
    (SELECT
			sub.beneficiary_id,
			AVG(sub.count) as avg_applications
	FROM
		(SELECT
				r.beneficiary_id ,
				r.id ,
				COUNT(va.volunteer_id )
		 FROM
				volunteer_application va
		 JOIN
				request r on r.id = va.request_id
		 GROUP BY r.id
		 ORDER BY r.beneficiary_id,r.id
		) as sub
		GROUP BY sub.beneficiary_id
    ) AS applications_per_request ON b.id = applications_per_request.beneficiary_id
JOIN
    (
        SELECT
            va.request_id,
            EXTRACT(YEAR FROM AGE(v.birthdate)) AS age
        FROM
            volunteer_application va
        JOIN
            volunteer v ON va.volunteer_id = v.id
    ) AS volunteer_ages ON rq.id = volunteer_ages.request_id
GROUP BY
    b.id,applications_per_request.avg_applications
ORDER BY
    b.id;

-- a.2
CREATE VIEW city_request_stats AS
SELECT
    c.id AS city_id,
    c.name AS city_name,
    COUNT(r.id) AS num_requests,
    AVG(fulfilled.volunteer_count / r.number_of_volunteers::FLOAT) AS avg_fulfill_rate
FROM
    city c
JOIN
    request_location rl ON c.id = rl.city_id
JOIN
    request r ON rl.request_id = r.id
LEFT JOIN
    (
        SELECT
            ra.id,
            COUNT(va.id) AS volunteer_count
        FROM
            request ra
        LEFT JOIN
            volunteer_application va ON ra.id = va.request_id
        WHERE
            va.is_valid = TRUE
        GROUP BY
            ra.id
    ) fulfilled ON r.id = fulfilled.id
GROUP BY
    c.id, c.name;

-- b) Triggers and Functions
-- b.1
CREATE OR REPLACE FUNCTION validate_ID(id VARCHAR) RETURNS BOOLEAN AS $$
DECLARE
    date_part VARCHAR(6);
    individual_part VARCHAR(3);
    control_character CHAR(1);
    separator CHAR(1);
    numeric_part BIGINT;
    expected_control CHAR(1);
    control_characters CONSTANT VARCHAR(31) := '0123456789ABCDEFHJKLMNPRSTUVWXY';
BEGIN
    IF LENGTH(id) <> 11 THEN
        RETURN FALSE;
    END IF;

    date_part := SUBSTRING(id FROM 1 FOR 6);
    separator := SUBSTRING(id FROM 7 FOR 1);
    individual_part := SUBSTRING(id FROM 8 FOR 3);
    control_character := SUBSTRING(id FROM 11 FOR 1);

    IF separator NOT IN ('+', '-', 'A', 'B', 'C', 'D', 'E', 'F', 'X', 'Y', 'W', 'V', 'U') THEN
        RETURN FALSE;
    END IF;

    IF date_part !~ '^[0-9]+$' OR individual_part !~ '^[0-9]+$' THEN
        RETURN FALSE;
    END IF;

    numeric_part := CAST(date_part || individual_part AS BIGINT);

    expected_control := SUBSTRING(control_characters FROM (numeric_part % 31)::integer + 1 FOR 1);

    IF control_character = expected_control THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

ALTER TABLE volunteer
ADD CONSTRAINT check_id_validity
CHECK (validate_ID(id));

-- b.2
CREATE OR REPLACE FUNCTION adjust_volunteers_needed() RETURNS TRIGGER AS $$
DECLARE
    difference INT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        difference := NEW.min_need;
    ELSIF TG_OP = 'UPDATE' THEN
        difference := NEW.min_need - OLD.min_need;
    ELSIF TG_OP = 'DELETE' THEN
        difference := - OLD.min_need;
    END IF;

    UPDATE request
    SET number_of_volunteers = number_of_volunteers + difference
    WHERE id = COALESCE(NEW.request_id, OLD.request_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_adjust_volunteers_needed
after INSERT OR UPDATE OR DELETE ON request_skill
FOR EACH ROW
EXECUTE FUNCTION adjust_volunteers_needed();

-- c) Transaction
-- c.2

BEGIN;
-- Temporary table to hold swapped values
CREATE TEMP TABLE temp_skill_swap AS
SELECT rs.request_id, rs.skill_name, rs.value
FROM request_skill rs
JOIN request r ON rs.request_id = r.id
WHERE r.beneficiary_id = 1
  AND rs.skill_name IN ('HealthCareOrFirstAid', 'TrainPeople');

-- Swap HealthCareOrFirstAid with TrainPeople
UPDATE request_skill
SET value = (SELECT value FROM temp_skill_swap WHERE request_id = request_skill.request_id AND skill_name = 'TrainPeople')
WHERE skill_name = 'HealthCareOrFirstAid'
  AND request_id IN (SELECT request_id FROM temp_skill_swap);

-- Swap TrainPeople with HealthCareOrFirstAid
UPDATE request_skill
SET value = (SELECT value FROM temp_skill_swap WHERE request_id = request_skill.request_id AND skill_name = 'HealthCareOrFirstAid')
WHERE skill_name = 'TrainPeople'
  AND request_id IN (SELECT request_id FROM temp_skill_swap);

DROP TABLE temp_skill_swap;

COMMIT;

-- d) Analysis
-- d.1
SELECT
    c.name AS city_name,
    COUNT(DISTINCT vr.volunteer_id) AS volunteers_available
FROM
    volunteer_range vr
JOIN
    city c ON vr.city_id = c.id
GROUP BY
    c.name;

SELECT
    c.name AS city_name,
    COUNT(DISTINCT va.volunteer_id) AS volunteers_applied
FROM
    volunteer_application va
JOIN
    request_location rl ON va.request_id = rl.request_id
JOIN
    city c ON rl.city_id = c.id
WHERE
    va.is_valid = TRUE
GROUP BY
    c.name;

-- d.2
SELECT
    va.volunteer_id,
    va.request_id,
    SUM(rs.value) AS matched_skill_score,
    total_request_score.total_score AS total_possible_score,
    ROUND(
        CASE
            WHEN total_request_score.total_score = 0 THEN 0
            ELSE SUM(rs.value)::FLOAT / total_request_score.total_score::FLOAT
        END::NUMERIC, 2
    ) AS score_ratio
FROM
    volunteer_application va
JOIN
    skill_assignment sa ON va.volunteer_id = sa.volunteer_id
JOIN
    request_skill rs ON va.request_id = rs.request_id AND sa.skill_name = rs.skill_name
JOIN (
    SELECT
        request_id,
        SUM(value) AS total_score
    FROM
        request_skill
    GROUP BY
        request_id
) total_request_score ON va.request_id = total_request_score.request_id
GROUP BY
    va.volunteer_id, va.request_id, total_request_score.total_score;


SELECT
    va.volunteer_id,
    va.request_id,
    COUNT(DISTINCT vr.city_id) AS matched_cities_count,
    total_request_cities.total_city_count AS total_request_cities_count,
    ROUND(
        CASE
            WHEN total_request_cities.total_city_count = 0 THEN 0
            ELSE CAST(COUNT(DISTINCT vr.city_id) AS NUMERIC) / CAST(total_request_cities.total_city_count AS NUMERIC)
        END, 2
    ) AS city_match_ratio
FROM
    volunteer_application va
JOIN
    volunteer_range vr ON va.volunteer_id = vr.volunteer_id
JOIN
    request_location rl ON va.request_id = rl.request_id AND vr.city_id = rl.city_id
JOIN (
    SELECT
        request_id,
        COUNT(DISTINCT city_id) AS total_city_count
    FROM
        request_location
    GROUP BY
        request_id
) total_request_cities ON va.request_id = total_request_cities.request_id
GROUP BY
    va.volunteer_id, va.request_id, total_request_cities.total_city_count;


SELECT
    va.volunteer_id,
    va.request_id,
    CASE
        WHEN req.interest IN (
            SELECT interest_name
            FROM interest_assignment
            WHERE volunteer_id = va.volunteer_id
        ) THEN 1
        ELSE 0
    END AS interest_matched,
    v.travel_readiness,
    ROUND(
        min_travel_readiness.min_travel_readiness/CAST(v.travel_readiness AS NUMERIC), 2
    ) AS normalized_travel_readiness
FROM
    volunteer_application va
JOIN
    request req ON va.request_id = req.id
JOIN
    volunteer v ON va.volunteer_id = v.id
JOIN (
    SELECT
        va.request_id,
        MIN(v.travel_readiness) AS min_travel_readiness
    FROM
        volunteer_application va
    JOIN
        volunteer v ON va.volunteer_id = v.id
    GROUP BY
        va.request_id
) min_travel_readiness ON va.request_id = min_travel_readiness.request_id;

-- d.3
SELECT TO_CHAR(va.modified, 'MM') AS month,
    COUNT(va.id) AS valid_volunteer_applications
FROM volunteer_application va
WHERE va.is_valid
GROUP BY month;

SELECT TO_CHAR(r.start_date, 'MM') AS month,
    COUNT(r.id) AS valid_requests
FROM request r
GROUP BY month;

-- d.4
SELECT 
    EXTRACT(YEAR FROM va.modified) AS year,
    EXTRACT(MONTH FROM va.modified) AS month,
    COUNT(va.id) AS total_applications,
    COUNT(CASE WHEN va.is_valid = TRUE THEN 1 END) AS approved_applications,
    ROUND(COUNT(CASE WHEN va.is_valid = TRUE THEN 1 END)::NUMERIC / COUNT(va.id) * 100, 2) AS approval_rate
FROM 
    volunteer_application va
GROUP BY 
    EXTRACT(YEAR FROM va.modified), EXTRACT(MONTH FROM va.modified)
ORDER BY 
    year DESC, month DESC;

