create database mysql_test;

use mysql_test;

-- -----------------------------------------------------------------------
-- Table with all kinds of numeric columns
-- -----------------------------------------------------------------------
CREATE TABLE table1 (
  table1_id int NOT NULL,
  
  column1 TINYINT,

  column2 SMALLINT,

  column3 MEDIUMINT NOT NULL,

  column4 INT,

  column5 BIGINT,

  column6 DECIMAL(10,5),

  column7 FLOAT NOT NULL,

  column8 DOUBLE,
  
  column9 BIT(8),

  CONSTRAINT PK_table1 PRIMARY KEY(table1_id),
  CONSTRAINT UQ_table1 UNIQUE( column3, column7 )
);


-- -----------------------------------------------------------------------
-- Table with all kinds of string columns
-- -----------------------------------------------------------------------
CREATE TABLE table2 (
  table2_id int NOT NULL,
  
  table1_id int NOT NULL,

  column1 CHAR(10),

  column2 VARCHAR(10),

  column3 BINARY(100) NOT NULL,

  column4 VARBINARY(100),

  column5 TINYBLOB,

  column6 BLOB,

  column7 MEDIUMBLOB,

  column8 LONGBLOB,
  
  column9 TINYTEXT,

  column10 TEXT,

  column11 MEDIUMTEXT,

  column12 LONGTEXT,

  CONSTRAINT PK_table2 PRIMARY KEY(table2_id),
  CONSTRAINT UQ_table2 UNIQUE( column2, column3 ),
  CONSTRAINT FK_table2_table1
    FOREIGN KEY (table1_id) REFERENCES table1(table1_id)
    ON DELETE CASCADE
);

-- -----------------------------------------------------------------------
-- Table with all kinds of enum and date columns
-- -----------------------------------------------------------------------
CREATE TABLE table3 (
  table3_id int NOT NULL,
  
  table2_id int NOT NULL,

  column1 enum('ABC', 'DEF', 'HIJ', 'KLM', 'OPQ') NOT NULL,

  column2 DATE,

  column3 TIME,

  column4 DATETIME NOT NULL,

  column5 TIMESTAMP NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,

  column6 YEAR,
  
  column7 enum('ABC', 'DEF', 'HIJ', 'KLM', 'OPQ') NOT NULL,

  CONSTRAINT PK_table3 PRIMARY KEY(table3_id),
  CONSTRAINT UQ_table3 UNIQUE( column4, column5 ),
  CONSTRAINT FK_table3_table2
    FOREIGN KEY (table2_id) REFERENCES table2(table2_id)
    ON DELETE CASCADE
);

-- -----------------------------------------------------------------------
-- Bridge table between table2 and table3
-- -----------------------------------------------------------------------
CREATE TABLE table4(

  table4_id int NOT NULL,

  -- Reference to table2
  table2_id int NOT NULL,

  -- Reference to table3
  table3_id int NOT NULL,

  column1 enum('ABC', 'DEF', 'HIJ', 'KLM', 'OPQ') NOT NULL,
  
  column2 VARCHAR(10),

  CONSTRAINT PK_table4
    PRIMARY KEY (table2_id, table3_id, column1),
  CONSTRAINT UQ_table4_id UNIQUE(table4_id),
  CONSTRAINT FK_table4_table2
    FOREIGN KEY (table2_id) REFERENCES table2(table2_id)
    ON DELETE CASCADE,
  CONSTRAINT FK_table4_table3
    FOREIGN KEY (table3_id) REFERENCES table3(table3_id)
    ON DELETE CASCADE
);

