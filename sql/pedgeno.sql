# do we want to enforce only one result per marker per person here?
# I will say yes for now

CREATE TABLE result (
   personid  integer(11) NOT NULL REFERENCES person (personid),
   markerid  integer(11) NOT NULL REFERENCES marker (markerid),
   allele1   char(10) NOT NULL,
   allele2   char(10) NOT NULL,
      
   PRIMARY KEY pk_result ( personid, markerid)   
);

CREATE TABLE person (
   personid  integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
   displayid char(10)	 NOT NULL,
   fatherid  integer(11) NULL DEFAULT '0',
   motherid  integer(11) NULL DEFAULT '0',
   gender    char(1)	 NULL DEFAULT 'U',
   
   KEY i_id ( displayid )
);

CREATE TABLE family (
  familyid  integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  center    char(12)	NOT NULL,
  number    integer(8)  NOT NULL,
  type	    char(8)	NULL DEFAULT 'FAMILY',

  UNIQUE KEY i_ctr_num ( center, number ) 
);

CREATE TABLE family_person (
  familyid    integer(11) NOT NULL REFERENCES family ( familyid ),
  personid    integer(11) NOT NULL REFERENCES person ( personid ),
  PRIMARY KEY pk_fam_person ( familyid, personid)
);

CREATE TABLE markertype (
  type        smallint	NOT NULL PRIMARY KEY,
  name        char(12)	NOT NULL,
  description varchar(128) NOT NULL,
  UNIQUE KEY i_name ( name )
);

CREATE TABLE marker (
  markerid   integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name	     char(24)	 NOT NULL,
  type	     smallint	 NOT NULL REFERENCES markertype ( type),
  UNIQUE KEY i_name ( name )
);

create table variation_marker (
  markerid      integer(11) NOT NULL PRIMARY KEY REFERENCES marker (markerid),
  chrom	        char(8)	 NOT NULL,
  upstreamflank varchar(128) NULL,
  dnstreamflank varchar(128) NULL,

# more HGBASE stuff here
  
  KEY i_chrom (chrom),
  UNIQUE KEY i_primers ( upstreamflank, dnstreamflank )
);

CREATE TABLE allele (
  alleleid   integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,   
  markerid   integer(11) NOT NULL REFERENCES marker (markerid),
  name	     char(8)	 NOT NULL,  
  UNIQUE KEY pk_allele (markerid, name) 
);

CREATE TABLE population (
  popid	       integer(9) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name	       varchar(24) NOT NULL,
  description  varchar(64) NULL,  
  UNIQUE KEY i_name ( name )
);

CREATE TABLE allele_frequency (
  popid	     integer(9) NOT NULL REFERENCES population (popid),	
  alleleid   integer(11) NOT NULL REFERENCES allele ( alleleid ),
  frequency  float(8,6) NOT NULL,
  
  PRIMARY KEY pk_allele_freq (popid, alleleid)
);


INSERT INTO markertype ( type, name, description ) VALUES ( 1, 'DX', 'Disease Marker');
INSERT INTO markertype ( type, name, description ) VALUES ( 2, 'VNTR', 'VNTR Marker');
INSERT INTO markertype ( type, name, description ) VALUES ( 3, 'Band', 'Banded Marker (microsattelite)');
INSERT INTO markertype ( type, name, description ) VALUES ( 4, 'Numbered', 'NUmbered (Binned) Alleles' );
INSERT INTO markertype ( type, name, description ) VALUES ( 5, 'Quantitative', 'Quantitative Trait Markers' );
INSERT INTO markertype ( type, name, description ) VALUES ( 6, 'RFLP', 'RFLP Marker');

