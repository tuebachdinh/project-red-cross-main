# Volunteer Matching System (VMS)

## Overview
The Volunteer Matching System (VMS) is a database-driven application designed to match volunteers with volunteering opportunities based on their skills, interests, and travel readiness. This project is developed at **Aalto University** in collaboration with the **Finnish Red Cross (FRC).**

## Team Members
- Xuan Loc Le
- Tue Bach Dinh
- Nam Khanh Thieu

## Project Components
### 1. UML Diagram
The system is structured using Unified Modeling Language (UML) to define entities and relationships in the database. The main entities include:
- **Beneficiary**: Represents organizations or individuals requesting volunteer help.
- **Request**: A request made by a beneficiary specifying the number of volunteers, required skills, priority, and timeframe.
- **Volunteer**: Represents individuals willing to provide volunteer services.
- **Skill**: A defined competency that volunteers can possess and requests can require.
- **City**: Locations where volunteering activities take place.
- **Interest**: Areas of interest for volunteers and requesters.
- **Volunteer Application**: Tracks volunteer applications to requests.

### 2. Relational Data Model
The system's relational schema is derived from the UML diagram and includes:
- **Beneficiary (beneficiaryID, name, address, cityID)**
- **Request (requestID, title, beneficiaryID, numberOfVolunteers, priorityValue, startDate, endDate, registerByDate, interestName)**
- **Skill (skillName, description)**
- **City (cityID, name, geolocation)**
- **Interest (name, description)**
- **Volunteer Application (applicationID, requestID, volunteerID, modifiedTime, validity)**
- **Volunteer (volunteerID, birthdate, cityID, name, email, address, travel_readiness)**
- **Request Skill (skillName, requestID, minimumNeed, value)**
- **Request Location (requestID, cityID)**
- **Volunteer Range (volunteerID, cityID)**
- **Interest Assignment (interestName, volunteerID)**
- **Skill Assignment (volunteerID, skillName)**

### 3. Functional Dependencies
The system ensures data integrity and avoids redundancy using functional dependencies. Some key dependencies include:
- **beneficiaryID → name, address, cityID**
- **requestID → title, beneficiaryID, numberOfVolunteers, priorityValue, startDate, endDate, registerByDate, interestName**
- **volunteerID → birthdate, cityID, name, email, address, travel_readiness**
- **skillName → description**

### 4. SQL Implementation
The database is implemented using SQL with:
- **Table creation scripts**
- **Data insertion scripts**
- **Views**: Including aggregated views for analyzing request fulfillment rates.
- **Triggers and Functions**: Ensuring database integrity and automating updates.
- **Transactions**: Implementing data consistency mechanisms.

### 5. Query Examples
- **Sorting Requests by Priority**: Retrieves requests in order of highest priority and closest deadline.
- **Tracking Volunteer Applications**: Monitors application and approval rates over time.
- **Matching Volunteers to Requests**: Generates matching scores based on skill, range, interest, and travel readiness.

## Matching Algorithm
The volunteer-to-request matching algorithm assigns scores based on:
1. **Skill Match (35%)**
2. **Location Match (35%)**
3. **Interest Match (20%)**
4. **Travel Readiness (10%)**

## Setup and Usage
### Prerequisites
- PostgreSQL or MySQL database
- Python (for data analysis and visualization)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/vms.git
   cd vms
   ```
2. Setup the database:
   ```sql
   source schema.sql;
   ```
3. Run Python scripts for analysis:
   ```bash
   python data_analysis.py
   ```

## Analysis & Insights
The project also includes visualization and analysis of:
- Volunteer distribution across cities
- Approval trends over time
- Predictive analytics for volunteer demand

## Deliverables
- **UML Diagram**
- **Relational Data Model**
- **SQL Queries and Implementation**
- **Data Analysis and Visualizations**
- **Presentation Slides**

## Acknowledgments
Special thanks to **Professor Nitin Sawhney** and **the Finnish Red Cross** for their guidance in designing this project.

