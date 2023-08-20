-- drop views
DROP VIEW naturalspecimenarticle;
DROP VIEW naturalspecimenspecies;
DROP VIEW artworkarticle;
DROP VIEW textarticle;
DROP VIEW photoarticle;
DROP VIEW artifactarticle;

-- drop tables
DROP TABLE pertainsto;
DROP TABLE writes;
DROP TABLE displays;
DROP TABLE sells;
DROP TABLE examines;
DROP TABLE contains;
DROP TABLE collection;
DROP TABLE attends;
DROP TABLE admits;
DROP TABLE ticket;
DROP TABLE visitor;
DROP TABLE ticketprice;
DROP TABLE frontdesk;
DROP TABLE archivist;
DROP TABLE activities;
DROP TABLE exhibit;
DROP TABLE curator;
DROP TABLE employee;
DROP TABLE artwork;
DROP TABLE text;
DROP TABLE photo;
DROP TABLE naturalspecimen;
DROP TABLE species;
DROP TABLE artifact;
DROP TABLE article;
DROP TABLE contract;
DROP TABLE owner;
DROP TABLE postalcode;

-- create tables
CREATE TABLE visitor (
    visitor_id INT PRIMARY KEY,
    name VARCHAR(50), 
    email VARCHAR(50)
);

CREATE TABLE ticketprice (
    ticket_type VARCHAR(50) PRIMARY KEY,
    price INT DEFAULT 25 NOT NULL
);

CREATE TABLE ticket (
    ticket_id INT PRIMARY KEY,
    issue_date DATE,
    ticket_type VARCHAR(50) DEFAULT 'General Admission' NOT NULL,
    visitor_id INT NOT NULL,
    FOREIGN KEY(ticket_type) REFERENCES ticketprice,
    FOREIGN KEY(visitor_id) REFERENCES visitor
);

CREATE TABLE employee (
    sin INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE frontdesk (
    sin INT PRIMARY KEY,
    FOREIGN KEY (sin) REFERENCES employee(sin)
        ON DELETE CASCADE
);

CREATE TABLE archivist (
    sin INT PRIMARY KEY,
    FOREIGN KEY (sin) REFERENCES employee(sin)
        ON DELETE CASCADE
);

CREATE TABLE curator (
    sin INT PRIMARY KEY,
    FOREIGN KEY (sin) REFERENCES employee(sin)
        ON DELETE CASCADE
);

CREATE TABLE exhibit (
    exhibit_id INT PRIMARY KEY,
    exhibit_name VARCHAR(50) NOT NULL,
    start_date DATE,
    end_date DATE,
    sin INT NOT NULL,
    FOREIGN KEY(sin) REFERENCES curator(sin)
);

CREATE TABLE activities (
    exhibit_id INT,
    name VARCHAR(50),
    schedule VARCHAR(255),
    PRIMARY KEY(exhibit_id, name),
    FOREIGN KEY(exhibit_id) REFERENCES exhibit(exhibit_id)
        ON DELETE CASCADE
);

CREATE TABLE article (
    article_id INT PRIMARY KEY,
    article_name VARCHAR(255) NOT NULL,
    date_aquired TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    article_condition VARCHAR(50) NOT NULL,
    storage_location VARCHAR(50) NOT NULL,
    uv_protection CHAR(1) NOT NULL,
    temp_control CHAR(1) NOT NULL,
    humidity_control CHAR(1) NOT NULL
);

CREATE TABLE artwork (
    article_id INT PRIMARY KEY,
    artist VARCHAR(50),
    year_made INT,
    medium VARCHAR(50),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE
);

CREATE TABLE text (
    article_id INT PRIMARY KEY,
    author VARCHAR(50),
    year_published INT,
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE
);

CREATE TABLE photo (
    article_id INT PRIMARY KEY,
    year_taken INT,
    location_taken VARCHAR(50),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE
);

CREATE TABLE artifact (
    article_id INT PRIMARY KEY,
    estimated_year VARCHAR(50),
    region_of_origin VARCHAR(60),
    material VARCHAR(50),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE
);

CREATE TABLE species (
    species_name VARCHAR(50) PRIMARY KEY,
    native_to VARCHAR(50) NOT NULL
);

CREATE TABLE naturalspecimen (
    article_id INT PRIMARY KEY,
    species_name VARCHAR(50),
    time_period VARCHAR(50),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE,
    FOREIGN KEY(species_name) REFERENCES species(species_name)
);

CREATE TABLE contract (
    contract_id INT PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    text VARCHAR(200) NOT NULL
);

CREATE TABLE postalcode (
    postal_ZIP_Code CHAR(7) PRIMARY KEY,
    city VARCHAR(50) NOT NULL
);

CREATE TABLE owner (
    owner_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    building_num INT,
    street VARCHAR(50) NOT NULL,
    postal_ZIP_Code CHAR(7) NOT NULL,
    country VARCHAR(50) NOT NULL,
    phone_num VARCHAR(20) NOT NULL,
    FOREIGN KEY(postal_ZIP_Code) REFERENCES postalcode(postal_ZIP_Code)
);

CREATE TABLE admits (
    ticket_id INT,
    exhibit_id INT,
    PRIMARY KEY(ticket_id, exhibit_id),
    FOREIGN KEY(ticket_id) REFERENCES ticket(ticket_id),
    FOREIGN KEY(exhibit_id) REFERENCES exhibit(exhibit_id)
);

CREATE TABLE attends (
    visitor_id INT,
    name VARCHAR(50),
    exhibit_id INT,
    PRIMARY KEY(visitor_id, name, exhibit_id),
    FOREIGN KEY(visitor_id) REFERENCES visitor(visitor_id),
    FOREIGN KEY(exhibit_id, name) REFERENCES activities(exhibit_id, name)
);

CREATE TABLE collection (
    collection_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    sin INT NOT NULL,
    FOREIGN KEY (sin) REFERENCES curator(sin)
);

CREATE TABLE contains (
    article_id INT,
    collection_id INT,
    PRIMARY KEY (article_id, collection_id),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE,
    FOREIGN KEY(collection_id) REFERENCES collection(collection_id)
);

CREATE TABLE examines (
    article_id INT,
    sin INT,
    PRIMARY KEY (article_id, sin),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE,
    FOREIGN KEY(sin) REFERENCES archivist(sin)
);

CREATE TABLE sells (
    ticket_id INT,
    sin INT,
    PRIMARY KEY (ticket_id, sin),
    FOREIGN KEY(ticket_id) REFERENCES ticket(ticket_id),
    FOREIGN KEY(sin) REFERENCES frontdesk(sin)
);

CREATE TABLE displays (
    exhibit_id INT,
    article_id INT,
    PRIMARY KEY(exhibit_id, article_id),
    FOREIGN KEY(exhibit_id) REFERENCES exhibit(exhibit_id),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE
);

CREATE TABLE writes (
    owner_id INT,
    contract_id INT,
    PRIMARY KEY(owner_id, contract_id),
    FOREIGN KEY(owner_id) REFERENCES owner(owner_id),
    FOREIGN KEY(contract_id) REFERENCES contract(contract_id)
);

CREATE TABLE pertainsto (
    contract_id INT,
    article_id INT,
    PRIMARY KEY(contract_id, article_id),
    FOREIGN KEY(contract_id) REFERENCES contract(contract_id),
    FOREIGN KEY(article_id) REFERENCES article(article_id)
        ON DELETE CASCADE
);

-- create views
CREATE VIEW naturalspecimenspecies AS
    SELECT ns.article_id, ns.species_name, s.native_to, ns.time_period
    FROM naturalspecimen ns, species s
    WHERE ns.species_name = s.species_name;

CREATE VIEW artworkarticle AS
    SELECT
        a.article_id, a.article_name, a.article_condition,
        art.artist, art.year_made, art.medium
    FROM article a, artwork art
    WHERE a.article_id = art.article_id;

CREATE VIEW textarticle AS
    SELECT
        a.article_id, a.article_name, a.article_condition,
        t.author, t.year_published
    FROM article a, text t
    WHERE a.article_id = t.article_id;

CREATE VIEW photoarticle AS
    SELECT
        a.article_id, a.article_name, a.article_condition,
        p.year_taken, p.location_taken
    FROM article a, photo p
    WHERE a.article_id = p.article_id;

CREATE VIEW artifactarticle AS
    SELECT
        a.article_id, a.article_name, a.article_condition,
        f.estimated_year, f.region_of_origin, f.material
    FROM article a, artifact f
    WHERE a.article_id = f.article_id;

CREATE VIEW naturalspecimenarticle AS
    SELECT
        a.article_id, a.article_name, a.article_condition,
        ns.species_name, ns.native_to, ns.time_period
    FROM article a, naturalspecimenspecies ns
    WHERE a.article_id = ns.article_id;


-- populate tables
INSERT ALL
    INTO visitor (visitor_id, name, email)
    VALUES (1010, 'Bruce Wayne', 'batman@gmail.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1011, 'Clark Kent', 'superman@gmail.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1012, 'Lois Lane', 'lois@outlook.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1013, 'Diana Prince', 'wonderwoman@gmail.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1014, 'Barry Allen', 'flash@gmail.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1015, 'Arthur Curry', 'aquaman@gmail.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1016, 'Lex Luthor', 'lex@outlook.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1017, 'Alfred Pennyworth', 'alfred@outlook.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1018, 'Wally West', 'kidflash@gmail.com')
    INTO visitor (visitor_id, name, email)
    VALUES (1019, 'Dick Grayson', 'robin@gmail.com')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO ticketprice (ticket_type, price) VALUES ('General Admission', 25)
    INTO ticketprice (ticket_type, price) VALUES ('Family', 57)
    INTO ticketprice (ticket_type, price) VALUES ('Child', 15)
    INTO ticketprice (ticket_type, price) VALUES ('Staff', 12)
    INTO ticketprice (ticket_type, price) VALUES ('Senior', 17)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2001, TO_DATE('2023-05-31', 'YYYY-MM-DD'), 'General Admission', 1010)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2002, TO_DATE('2023-05-31', 'YYYY-MM-DD'), 'General Admission', 1011)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2003, TO_DATE('2023-05-31', 'YYYY-MM-DD'), 'General Admission', 1012)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2004, TO_DATE('2023-06-01', 'YYYY-MM-DD'), 'Staff', 1013)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2005, TO_DATE('2023-06-02', 'YYYY-MM-DD'), 'General Admission', 1014)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2006, TO_DATE('2023-06-02', 'YYYY-MM-DD'), 'General Admission', 1015)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2007, TO_DATE('2023-06-03', 'YYYY-MM-DD'), 'General Admission', 1016)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2008, TO_DATE('2023-06-04', 'YYYY-MM-DD'), 'Senior', 1017)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2009, TO_DATE('2023-06-05', 'YYYY-MM-DD'), 'Child', 1018)
    INTO ticket (ticket_id, issue_date, ticket_type, visitor_id)
    VALUES (2010, TO_DATE('2023-06-05', 'YYYY-MM-DD'), 'Child', 1019)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO employee (sin, name) VALUES (111111111, 'John Cena')
    INTO employee (sin, name) VALUES (222222222, 'Roman Reigns')
    INTO employee (sin, name) VALUES (333333333, 'Becky Lynch')
    INTO employee (sin, name) VALUES (444444444, 'Seth Rollins')
    INTO employee (sin, name) VALUES (555555555, 'Charlotte Flair')
    INTO employee (sin, name) VALUES (666666666, 'Brock Lesnar')
    INTO employee (sin, name) VALUES (777777777, 'Bayley')
    INTO employee (sin, name) VALUES (888888888, 'AJ Styles')
    INTO employee (sin, name) VALUES (999999999, 'Sasha Banks')
    INTO employee (sin, name) VALUES (101010101, 'Drew McIntyre')
    INTO employee (sin, name) VALUES (121212121, 'Asuka')
    INTO employee (sin, name) VALUES (131313131, 'Randy Orton')
    INTO employee (sin, name) VALUES (141414141, 'Alexa Bliss')
    INTO employee (sin, name) VALUES (151515151, 'Braun Strowman')
    INTO employee (sin, name) VALUES (161616161, 'Rhea Ripley')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO frontdesk (sin) VALUES (666666666)
    INTO frontdesk (sin) VALUES (777777777)
    INTO frontdesk (sin) VALUES (888888888)
    INTO frontdesk (sin) VALUES (999999999)
    INTO frontdesk (sin) VALUES (101010101)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO archivist (sin) VALUES (121212121)
    INTO archivist (sin) VALUES (131313131)
    INTO archivist (sin) VALUES (141414141)
    INTO archivist (sin) VALUES (151515151)
    INTO archivist (sin) VALUES (161616161)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO curator (sin) VALUES (111111111)
    INTO curator (sin) VALUES (222222222)
    INTO curator (sin) VALUES (333333333)
    INTO curator (sin) VALUES (444444444)
    INTO curator (sin) VALUES (555555555)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1500, 'Ancient Egypt', TO_DATE('2021-02-27', 'YYYY-MM-DD'), TO_DATE('2024-06-28', 'YYYY-MM-DD'), 444444444)
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1501, 'The Invention of the Printing Press', TO_DATE('2022-11-27', 'YYYY-MM-DD'), TO_DATE('2023-06-20', 'YYYY-MM-DD'), 222222222)
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1502, 'Dinosaurs', TO_DATE('2022-12-26', 'YYYY-MM-DD'), TO_DATE('2023-08-14', 'YYYY-MM-DD'), 111111111)
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1503, 'History of Vancouver', TO_DATE('2023-02-03', 'YYYY-MM-DD'), TO_DATE('2023-10-05', 'YYYY-MM-DD'), 333333333)
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1504, 'The Ice Age', TO_DATE('2023-04-21', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'), 111111111)
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1505, 'Famous Artwork', TO_DATE('2023-04-27', 'YYYY-MM-DD'), TO_DATE('2026-09-25', 'YYYY-MM-DD'), 555555555)
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1506, 'Ancient Maya', TO_DATE('2023-05-30', 'YYYY-MM-DD'), TO_DATE('2026-11-25', 'YYYY-MM-DD'), 555555555)
    INTO exhibit(exhibit_id, exhibit_name, start_date, end_date, sin) 
    VALUES (1507, 'Sea Creatures', TO_DATE('2023-07-14', 'YYYY-MM-DD'), TO_DATE('2027-03-22', 'YYYY-MM-DD'), 333333333)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO activities(exhibit_id, name, schedule) 
    VALUES (1500, 'Tour', 'Days: Monday, Wednesday, Friday; Times: 1030-1200, 1400-1530')
    INTO activities(exhibit_id, name, schedule) 
    VALUES (1502, 'Animated Video', 'Days: Monday, Tuesday, Wednesday, Thursday, Friday; Times: Hourly')
    INTO activities(exhibit_id, name, schedule) 
    VALUES (1503, 'Storytime', 'Days: Monday, Wednesday, Friday; Times: 0930-1030, 1230-1330, 1430-1530')
    INTO activities(exhibit_id, name, schedule) 
    VALUES (1505, 'Tour', 'Days: Tuesday, Thursday; Times: 0900-1030, 1230-1400, 1530-1700')
    INTO activities(exhibit_id, name, schedule) 
    VALUES (1506, 'Tour', 'Days: Monday, Wednesday, Friday; Times: 0900-1030, 1230-1400, 1530-1700')
    INTO activities(exhibit_id, name, schedule) 
    VALUES (1507, 'Puppet Show', 'Days: Tuesday, Thursday; Times: 0900-1030, 1230-1400, 1530-1700')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11111, 'Forest, British Columbia', TO_TIMESTAMP('2021-11-05 21:45:59', 'YYYY-MM-DD HH24:MI:SS'), 'Excellent', 'Storage room 1', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11112, 'William Shakespeares Comedies, Histories, and Tragedies', TO_TIMESTAMP('2022-01-12 13:45:31', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'Storage room 5', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11114, 'Tutankhamuns Mask', TO_TIMESTAMP('2022-07-16 03:15:50', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11115, 'Blue whale skeleton', TO_TIMESTAMP('2022-10-25 09:20:18', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'N', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11116, 'Woolly mammoth replica', TO_TIMESTAMP('2021-10-20 06:35:19', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'N', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11117, 'IBM cheese slicer', TO_TIMESTAMP('2023-02-09 12:00:12', 'YYYY-MM-DD HH24:MI:SS'), 'Excellent', 'Storage room 1', 'N', 'N', 'N')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11118, 'Jade Death Mask of Kinich Janaab Pakal', TO_TIMESTAMP('2017-03-25 14:40:49', 'YYYY-MM-DD HH24:MI:SS'), 'Excellent', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11119, 'Ancient Egyptian flint arrowhead', TO_TIMESTAMP('2023-11-08 18:45:05', 'YYYY-MM-DD HH24:MI:SS'), 'Fair', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11120, 'Neolithic Painted Pottery', TO_TIMESTAMP('2018-07-06 08:05:56', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'Storage room 3', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11121, 'Ancient Sumerian chisel', TO_TIMESTAMP('2021-09-13 03:25:59', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'Storage room 3', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11122, 'Ammonite fossil', TO_TIMESTAMP('2019-07-20 12:30:15', 'YYYY-MM-DD HH24:MI:SS'), 'Excellent', 'on display', 'N', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11123, 'T. rex skeleton', TO_TIMESTAMP('2017-03-25 14:40:49', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'N', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11124, 'Ancient Mosquito in Burmese amber', TO_TIMESTAMP('2011-04-26 18:30:37', 'YYYY-MM-DD HH24:MI:SS'), 'Excellent', 'on display', 'N', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11125, 'Mona Lisa', TO_TIMESTAMP('2021-09-13 03:25:59', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11126, 'Starry Night', TO_TIMESTAMP('2020-07-02 12:30:15', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11127, 'The Scream', TO_TIMESTAMP('2023-03-12 14:40:49', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11128, 'The Thinker replica', TO_TIMESTAMP('2015-03-15 18:30:37', 'YYYY-MM-DD HH24:MI:SS'), 'Excellent', 'Storage room 5', 'N', 'N', 'N')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11129, 'The Vancouver Court House under construction', TO_TIMESTAMP('2018-08-17 14:12:32', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11130, 'The terminus of the Canadian Pacific Railway', TO_TIMESTAMP('2018-08-17 14:12:32', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11131, 'A picnic in newly opened Stanley Park', TO_TIMESTAMP('2018-08-17 14:12:32', 'YYYY-MM-DD HH24:MI:SS'), 'Fair', 'Fair', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11132, 'Rebuilding Cordova Street after the Great Vancouver Fire', TO_TIMESTAMP('2018-08-17 14:12:32', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11133, 'UBCs Main Library - now Irving K. Barber Learning Centre - under construction', TO_TIMESTAMP('2018-08-17 14:12:32', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'Storage room 1', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11134, 'Papyrus of Ani - Book of the Dead', TO_TIMESTAMP('2022-07-16 03:15:50', 'YYYY-MM-DD HH24:MI:SS'), 'Fair', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11135, 'Original Manuscript of Alice in Wonderland', TO_TIMESTAMP('2013-08-07 18:55:41', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'Storage room 2', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11136, 'Gutenberg Bible - The Earliest Printed Book', TO_TIMESTAMP('2014-09-28 01:25:26', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'on display', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11137, 'Magna Carta Libertatum - Latin for "Great Charter of Freedoms"', TO_TIMESTAMP('2019-05-22 11:15:09', 'YYYY-MM-DD HH24:MI:SS'), 'Fair', 'Storage room 5', 'Y', 'Y', 'Y')
    INTO article(article_id, article_name, date_aquired, article_condition, storage_location, uv_protection, temp_control, humidity_control)
    VALUES (11138, 'Common Sense', TO_TIMESTAMP('2016-03-09 10:05:08', 'YYYY-MM-DD HH24:MI:SS'), 'Good', 'Storage room 2', 'Y', 'Y', 'Y')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO artwork(article_id, artist, year_made, medium) VALUES (11111, 'Emily Carr', 1931, 'Oil on canvas')
    INTO artwork(article_id, artist, year_made, medium) VALUES (11125, 'Leonardo da Vinci', 1503, 'Oil on poplar panel')
    INTO artwork(article_id, artist, year_made, medium) VALUES (11126, 'Vincent van Gogh', 1889, 'Oil on canvas')
    INTO artwork(article_id, artist, year_made, medium) VALUES (11127, 'Edvard Munch', 1893, 'Tempera and pastels on cardboard')
    INTO artwork(article_id, artist, year_made, medium) VALUES (11128, 'Auguste Rodin', 1904, 'Bronze cast')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO text(article_id, author, year_published) VALUES (11112, 'William Shakespeare', 1623)
    INTO text(article_id, author, year_published) VALUES (11135, 'Lewis Carroll', 1864)
    INTO text(article_id, author, year_published) VALUES (11136, NULL, 1450)
    INTO text(article_id, author, year_published) VALUES (11137, 'Archbishop of Canterbury', 1215)
    INTO text(article_id, author, year_published) VALUES (11138, 'Thomas Paine', 1766)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO photo(article_id, year_taken, location_taken) VALUES (11129, 1907, 'Vancouver, BC')
    INTO photo(article_id, year_taken, location_taken) VALUES (11130, 1889, 'Vancouver, BC')
    INTO photo(article_id, year_taken, location_taken) VALUES (11131, 1888, 'Vancouver, BC')
    INTO photo(article_id, year_taken, location_taken) VALUES (11132, 1886, 'Vancouver, BC')
    INTO photo(article_id, year_taken, location_taken) VALUES (11133, 1925, 'Vancouver, BC')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11114, '1323 BCE', 'Tomb of Tutankhamun, Valley of the Kings, Luxor, Egypt', 'Gold inlay of colored glass and gemstones')
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11118, '683 CE', 'Palenque, Mexico', 'Carved jadeite')
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11119, '1200 BCE', 'Nile River, Egypt', 'flint')
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11120, '3000 BCE', 'China, probably Gansu Province', 'earthenware')
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11121, '2500 BCE', 'Mesopotamia (present-day Iraq)', 'copper')
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11134, '1250 BCE', 'Tomb of Ani, Egypt', 'Papyrus')
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11136, '1450', 'Germany', 'Paper and vellum')
    INTO artifact(article_id, estimated_year, region_of_origin, material) VALUES (11137, '1215', 'England', 'Parchment made from sheepskin')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO species(species_name, native_to) VALUES ('Balaenoptera musculus', 'all major oceans')
    INTO species(species_name, native_to) VALUES ('Mammuthus primigenius', 'Northern Eurasia and North America')
    INTO species(species_name, native_to) VALUES ('Pleuroceras solare', 'Canada and Europe')
    INTO species(species_name, native_to) VALUES ('Tyrannosaurus rex', 'North America')
    INTO species(species_name, native_to) VALUES ('Burmaculex antiquus', 'Canada')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO naturalspecimen(article_id, species_name, time_period) VALUES (11115, 'Balaenoptera musculus', 'Holocene epoch (Present)')
    INTO naturalspecimen(article_id, species_name, time_period) VALUES (11116, 'Mammuthus primigenius', 'Pleistocene epoch')
    INTO naturalspecimen(article_id, species_name, time_period) VALUES (11122, 'Pleuroceras solare', 'lower Jurassic, upper Pliensbachian period')
    INTO naturalspecimen(article_id, species_name, time_period) VALUES (11123, 'Tyrannosaurus rex', 'Late Cretaceous period')
    INTO naturalspecimen(article_id, species_name, time_period) VALUES (11124, 'Burmaculex antiquus', 'Cretaceous period')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1000, TO_DATE('2021-10-25', 'YYYY-MM-DD'), TO_DATE('2024-10-25', 'YYYY-MM-DD'), 'The Vancouver Art Gallery will loan Forest, British Columbia to the museum from 2021-10-25 to 2024-10-25.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1001, TO_DATE('2022-01-03', 'YYYY-MM-DD'), TO_DATE('2025-01-23', 'YYYY-MM-DD'), 'The University of British Columbia will loan William Shakespeares Comedies, Histories, and Tragedies to the museum from 2022-01-03 to 2025-01-23.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1002, TO_DATE('2022-07-02', 'YYYY-MM-DD'), TO_DATE('2025-07-02', 'YYYY-MM-DD'), 'The Egyptian Museum will loan Tutankhamuns Mask and Papyrus of Ani - Book of the Dead to the museum from 2022-07-02 to 2025-07-02.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1003, TO_DATE('2021-10-15', 'YYYY-MM-DD'), TO_DATE('2026-10-15', 'YYYY-MM-DD'), 'The Royal BC Museum will loan Woolly mammoth replica to the museum from 2021-10-15 to 2026-10-15.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1004, TO_DATE('2023-02-04', 'YYYY-MM-DD'), TO_DATE('2026-02-04', 'YYYY-MM-DD'), 'The Burnaby Village Museum will loan IBM cheese slicer to the museum from 2023-02-04 to 2026-02-04.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1005, TO_DATE('2023-10-28', 'YYYY-MM-DD'), TO_DATE('2024-10-28', 'YYYY-MM-DD'), 'Richie Rich will loan Ancient Egyptian flint arrowhead to the museum from 2023-10-28 to 2024-10-28.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1006, TO_DATE('2021-09-07', 'YYYY-MM-DD'), TO_DATE('2025-09-07', 'YYYY-MM-DD'), 'The Louvre Museum will loan Mona Lisa to the museum from 2021-09-07 to 2025-09-07.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1007, TO_DATE('2020-06-20', 'YYYY-MM-DD'), TO_DATE('2024-06-20', 'YYYY-MM-DD'), 'The Museum of Modern Art will loan Starry Night replica to the museum from 2020-06-20 to 2024-06-20.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1008, TO_DATE('2023-03-05', 'YYYY-MM-DD'), TO_DATE('2027-03-15', 'YYYY-MM-DD'), 'The National Museum of Art will loan The Scream replica to the museum from 2023-03-05 to 2027-03-15.')
    INTO contract(contract_id, start_date, end_date, text) 
    VALUES (1009, TO_DATE('2022-10-17', 'YYYY-MM-DD'), TO_DATE('2025-10-17', 'YYYY-MM-DD'), 'The University of British Columbia will loan Blue whale skeleton to the museum from 2022-10-17 to 2025-10-17.')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO postalcode(postal_ZIP_Code, city) VALUES ('V6Z 2H7', 'Vancouver')
    INTO postalcode(postal_ZIP_Code, city) VALUES ('V6T 1Z2', 'Vancouver')
    INTO postalcode(postal_ZIP_Code, city) VALUES ('4272083', 'Cairo')
    INTO postalcode(postal_ZIP_Code, city) VALUES ('V8W 9W2', 'Victoria')
    INTO postalcode(postal_ZIP_Code, city) VALUES ('V5G 3T6', 'Burnaby')
    INTO postalcode(postal_ZIP_Code, city) VALUES ('V6K 1A7', 'Vancouver')
    INTO postalcode(postal_ZIP_Code, city) VALUES ('75001', 'Paris')
    INTO postalcode(postal_ZIP_Code, city) VALUES ('10019', 'New York City')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1111, 'Vancouver Art Gallery', 750, 'Hornby St', 'V6Z 2H7', 'Canada', '(604) 662-4700')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1112, 'University of British Columbia: Library Special Collections Division', 1956, 'Main Mall', 'V6T 1Z2', 'Canada', '(604) 822-2521')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1113, 'Egyptian Museum', NULL, 'El-Tahrir Square', '4272083', 'Egypt', '+20 2 25796948')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1114, 'Royal BC Museum', 675, 'Belleville St', 'V8W 9W2', 'Canada', '(250) 356-7226')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1115, 'Burnaby Village Museum', 6501, 'Deer Lake Ave', 'V5G 3T6', 'Canada', '(604) 297-4565')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1116, 'Richie Rich', 3085, 'Point Grey Road', 'V6K 1A7', 'Canada', '(604) 987-6543')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1117, 'Louvre Museum', NULL, 'Rue de Rivoli', '75001', 'France', '+33 1 40 20 53 17')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1118, 'The Museum of Modern Art', 11, 'W 53rd St', '10019', 'United States', '(212) 708-9400')
    INTO owner(owner_id, name, building_num, street, postal_ZIP_Code, country, phone_num) 
    VALUES (1119, 'The National Museum of Art', 675, 'Belleville St', 'V8W 9W2', 'Canada', '(250) 356-7226')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO admits(ticket_id, exhibit_id) VALUES (2002, 1504)
    INTO admits(ticket_id, exhibit_id) VALUES (2003, 1500)
    INTO admits(ticket_id, exhibit_id) VALUES (2005, 1500)
    INTO admits(ticket_id, exhibit_id) VALUES (2006, 1502)
    INTO admits(ticket_id, exhibit_id) VALUES (2007, 1500)
    INTO admits(ticket_id, exhibit_id) VALUES (2008, 1500)
    INTO admits(ticket_id, exhibit_id) VALUES (2009, 1507)
    INTO admits(ticket_id, exhibit_id) VALUES (2010, 1507)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1500)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1501)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1502)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1503)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1504)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1505)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1506)
    INTO admits(ticket_id, exhibit_id) VALUES (2001, 1507)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1500)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1501)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1502)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1503)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1504)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1505)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1506)
    INTO admits(ticket_id, exhibit_id) VALUES (2004, 1507)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO attends(visitor_id, exhibit_id, name) VALUES (1012, 1500, 'Tour')
    INTO attends(visitor_id, exhibit_id, name) VALUES (1013, 1500, 'Tour')
    INTO attends(visitor_id, exhibit_id, name) VALUES (1014, 1500, 'Tour')
    INTO attends(visitor_id, exhibit_id, name) VALUES (1010, 1502, 'Animated Video')
    INTO attends(visitor_id, exhibit_id, name) VALUES (1015, 1502, 'Animated Video')
    INTO attends(visitor_id, exhibit_id, name) VALUES (1018, 1507, 'Puppet Show')
    INTO attends(visitor_id, exhibit_id, name) VALUES (1019, 1507, 'Puppet Show')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO collection (collection_id, name, sin) VALUES (1, 'Ancient Artifacts', 111111111)
    INTO collection (collection_id, name, sin) VALUES (2, 'Natural History', 111111111)
    INTO collection (collection_id, name, sin) VALUES (3, 'Modern Art Gallery', 222222222)
    INTO collection (collection_id, name, sin) VALUES (4, 'Historical Documents', 222222222)
    INTO collection (collection_id, name, sin) VALUES (5, 'Sculpture and Statue', 333333333)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO contains (article_id, collection_id) VALUES (11116, 1)
    INTO contains (article_id, collection_id) VALUES (11115, 2)
    INTO contains (article_id, collection_id) VALUES (11112, 3)
    INTO contains (article_id, collection_id) VALUES (11111, 3)
    INTO contains (article_id, collection_id) VALUES (11119, 3)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO examines (article_id, sin) VALUES (11121, 121212121)
    INTO examines (article_id, sin) VALUES (11125, 121212121)
    INTO examines (article_id, sin) VALUES (11122, 151515151)
    INTO examines (article_id, sin) VALUES (11131, 151515151)
    INTO examines (article_id, sin) VALUES (11129, 161616161)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO sells (ticket_id, sin) VALUES (2003, 666666666)
    INTO sells (ticket_id, sin) VALUES (2004, 777777777)
    INTO sells (ticket_id, sin) VALUES (2005, 888888888)
    INTO sells (ticket_id, sin) VALUES (2006, 101010101)
    INTO sells (ticket_id, sin) VALUES (2007, 101010101)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO writes(owner_id, contract_id) VALUES (1111, 1000)
    INTO writes(owner_id, contract_id) VALUES (1112, 1001)
    INTO writes(owner_id, contract_id) VALUES (1113, 1002)
    INTO writes(owner_id, contract_id) VALUES (1114, 1003)
    INTO writes(owner_id, contract_id) VALUES (1115, 1004)
    INTO writes(owner_id, contract_id) VALUES (1116, 1005)
    INTO writes(owner_id, contract_id) VALUES (1117, 1006)
    INTO writes(owner_id, contract_id) VALUES (1118, 1007)
    INTO writes(owner_id, contract_id) VALUES (1119, 1008)
    INTO writes(owner_id, contract_id) VALUES (1111, 1009)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO pertainsto(contract_id, article_id) VALUES (1000, 11111)
    INTO pertainsto(contract_id, article_id) VALUES (1001, 11112)
    INTO pertainsto(contract_id, article_id) VALUES (1002, 11114)
    INTO pertainsto(contract_id, article_id) VALUES (1002, 11134)
    INTO pertainsto(contract_id, article_id) VALUES (1003, 11116)
    INTO pertainsto(contract_id, article_id) VALUES (1004, 11117)
    INTO pertainsto(contract_id, article_id) VALUES (1005, 11119)
    INTO pertainsto(contract_id, article_id) VALUES (1006, 11125)
    INTO pertainsto(contract_id, article_id) VALUES (1007, 11126)
    INTO pertainsto(contract_id, article_id) VALUES (1008, 11127)
    INTO pertainsto(contract_id, article_id) VALUES (1009, 11115)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO displays(exhibit_id, article_id) VALUES (1500, 11119)
    INTO displays(exhibit_id, article_id) VALUES (1500, 11134)
    INTO displays(exhibit_id, article_id) VALUES (1500, 11114)
    INTO displays(exhibit_id, article_id) VALUES (1502, 11123)
    INTO displays(exhibit_id, article_id) VALUES (1502, 11124)
    INTO displays(exhibit_id, article_id) VALUES (1507, 11115)
    INTO displays(exhibit_id, article_id) VALUES (1507, 11122)
    INTO displays(exhibit_id, article_id) VALUES (1503, 11129)
    INTO displays(exhibit_id, article_id) VALUES (1503, 11130)
    INTO displays(exhibit_id, article_id) VALUES (1503, 11132)
    INTO displays(exhibit_id, article_id) VALUES (1505, 11125)
    INTO displays(exhibit_id, article_id) VALUES (1505, 11126)
    INTO displays(exhibit_id, article_id) VALUES (1505, 11127)
    INTO displays(exhibit_id, article_id) VALUES (1501, 11136)
    INTO displays(exhibit_id, article_id) VALUES (1504, 11116)
    INTO displays(exhibit_id, article_id) VALUES (1506, 11118)
SELECT 1 FROM DUAL;

COMMIT;