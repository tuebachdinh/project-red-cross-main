-- Table: city
CREATE TABLE city (
    name VARCHAR(255),
    id INT PRIMARY KEY,
    geolocation VARCHAR(255)
);

-- Table: volunteer
CREATE TABLE volunteer (
    id VARCHAR(255) PRIMARY KEY,
    birthdate DATE,
    city_id INT,
    name VARCHAR(255),
    email VARCHAR(255),
    address VARCHAR(255),
    travel_readiness INT,
    FOREIGN KEY (city_id) REFERENCES city(id)
);

-- Table: volunteer_range
CREATE TABLE volunteer_range (
    volunteer_id VARCHAR(255),
    city_id INT,
    FOREIGN KEY (volunteer_id) REFERENCES volunteer(id),
    FOREIGN KEY (city_id) REFERENCES city(id),
    PRIMARY KEY (volunteer_id, city_id)
);

-- Table: skill
CREATE TABLE skill (
    name VARCHAR(255) PRIMARY KEY,
    description TEXT
);

-- Table: skill_assignment
CREATE TABLE skill_assignment (
    volunteer_id VARCHAR(255),
    skill_name VARCHAR(255),
    FOREIGN KEY (volunteer_id) REFERENCES volunteer(id),
    FOREIGN KEY (skill_name) REFERENCES skill(name),
    PRIMARY KEY (volunteer_id, skill_name)
);

-- Table: interest
CREATE TABLE interest (
    name VARCHAR(255) PRIMARY KEY
);

-- Table: interest_assignment
CREATE TABLE interest_assignment (
    volunteer_id VARCHAR(255),
    interest_name VARCHAR(255),
    FOREIGN KEY (volunteer_id) REFERENCES volunteer(id),
    FOREIGN KEY (interest_name) REFERENCES interest(name),
    PRIMARY KEY (volunteer_id, interest_name)
);

-- Table: beneficiary
CREATE TABLE beneficiary (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES city(id)
);

-- Table: request
CREATE TABLE request (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    beneficiary_id INT,
    number_of_volunteers INT,
    priority_value INT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    register_by_date TIMESTAMP,
    interest VARCHAR(255),
    FOREIGN KEY (interest) REFERENCES interest(name),
    FOREIGN KEY (beneficiary_id) REFERENCES beneficiary(id)
);

-- Table: request_skill
CREATE TABLE request_skill (
    request_id INT,
    skill_name VARCHAR(255),
    min_need INT,
    value INT,
    FOREIGN KEY (request_id) REFERENCES request(id),
    FOREIGN KEY (skill_name) REFERENCES skill(name),
    PRIMARY KEY (request_id, skill_name)
);

-- Table: request_location
CREATE TABLE request_location (
    request_id INT,
    city_id INT,
    FOREIGN KEY (request_id) REFERENCES request(id),
    FOREIGN KEY (city_id) REFERENCES city(id),
    PRIMARY KEY (request_id, city_id)
);

-- Table: volunteer_application
CREATE TABLE volunteer_application (
    id INT PRIMARY KEY,
    request_id INT,
    volunteer_id VARCHAR(255),
    modified TIMESTAMP,
    is_valid BOOLEAN,
    FOREIGN KEY (request_id) REFERENCES request(id),
    FOREIGN KEY (volunteer_id) REFERENCES volunteer(id)
);
