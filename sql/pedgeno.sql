-- do we want to enforce only one result per marker per person here?
-- I will say yes for now

CREATE TABLE result (
   person_id  integer(11) NOT NULL REFERENCES person (person_id),
   marker_id  integer(11) NOT NULL REFERENCES marker (marker_id),
   allele1   char(10) NOT NULL,
   allele2   char(10) NOT NULL,
      
   PRIMARY KEY pk_result ( person_id, marker_id)   
);

CREATE TABLE person (
   person_id  integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
   display_id char(10)	 NOT NULL,
   father_id  integer(11) NULL DEFAULT '0',
   mother_id  integer(11) NULL DEFAULT '0',
   gender    char(1)	 NULL DEFAULT 'U',
   
   KEY i_id ( display_id )
);

CREATE TABLE family (
  family_id  integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  center    char(12)	NOT NULL,
  number    integer(8)  NOT NULL,
  type	    char(8)	NULL DEFAULT 'FAMILY',

  UNIQUE KEY i_ctr_num ( center, number ) 
);

CREATE TABLE family_person (
  family_id    integer(11) NOT NULL REFERENCES family ( family_id ),
  person_id    integer(11) NOT NULL REFERENCES person ( person_id ),
  PRIMARY KEY pk_fam_person ( family_id, person_id)
);

-- take this from map tables for pedmaps

CREATE TABLE markertype (
  type        smallint	NOT NULL PRIMARY KEY,
  name        char(12)	NOT NULL,
  description varchar(128) NOT NULL,
  UNIQUE KEY i_name ( name )
);

CREATE TABLE marker (
  marker_id  integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name	     char(24)	 NOT NULL,
  type	     smallint	 NOT NULL REFERENCES markertype ( type),
  UNIQUE KEY i_name ( name )
);

create table variation_marker (
  marker_id     integer(11) NOT NULL PRIMARY KEY REFERENCES marker (marker_id),
  chrom	        char(8)	 NOT NULL,
  upstreamflank varchar(128) NULL,
  dnstreamflank varchar(128) NULL,

-- more HGBASE stuff to be added here
  
  KEY i_chrom (chrom),
  UNIQUE KEY i_primers ( upstreamflank, dnstreamflank )
);

CREATE TABLE population (
   population_id    integer(9) NOT NULL AUTO_INCREMENT PRIMARY KEY,
   name		    varchar(32)	NOT NULL,
   description	    varchar(128) NOT NULL,
   UNIQUE KEY (name)
);

CREATE TABLE population_assignment (
   population_id    integer(9)  NOT NULL REFERENCES population (population_id),
   person_id	    integer(11)	NOT NULL REFERENCES person (person_id),
   PRIMARY KEY pk_pop_person ( population_id, person_id)
);


CREATE TABLE allele (
  allele_id   integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,   
  marker_id   integer(11) NOT NULL REFERENCES marker (marker_id),
  name	      char(8)	 NOT NULL,  
  UNIQUE KEY i_allele (marker_id, name) 
);


CREATE TABLE allele_frequency (
  population_id integer(9) NOT NULL REFERENCES population (population_id),
  allele_id	integer(11) NOT NULL REFERENCES allele ( allele_id ),
  frequency	float(8,6) NOT NULL,
  
  PRIMARY KEY pk_allele_freq (population_id, allele_id)
);


INSERT INTO markertype ( type, name, description ) 
       VALUES ( 1, 'DX', 'Disease Marker');
INSERT INTO markertype ( type, name, description ) 
       VALUES ( 2, 'VNTR', 'VNTR Marker');
INSERT INTO markertype ( type, name, description ) 
       VALUES ( 3, 'Band', 'Banded Marker (microsatellite)');
INSERT INTO markertype ( type, name, description ) 
       VALUES ( 4, 'Numbered', 'Numbered (Binned) Alleles' );
INSERT INTO markertype ( type, name, description ) 
       VALUES ( 5, 'Quantitative', 'Quantitative Trait Markers' );
INSERT INTO markertype ( type, name, description ) 
       VALUES ( 6, 'RFLP', 'RFLP Marker');
