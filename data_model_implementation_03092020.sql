
-- DROP DATABASE IF EXISTS -- done  

    DROP DATABASE bpl_atlas;
    CREATE DATABASE bpl_atlas;

-- DROP TABLES IF EXIST -- done 

    DROP TABLE IF EXISTS parcel_to_building;
    DROP TABLE IF EXISTS plates;
    DROP TABLE IF EXISTS atlas;
    DROP TABLE IF EXISTS streets;
    DROP TABLE IF EXISTS f_hydrants;
    DROP TABLE IF EXISTS wards;
    DROP TABLE IF EXISTS hydrology;
    DROP TABLE IF EXISTS w_mains;
    DROP TABLE IF EXISTS s_mains;
    DROP TABLE IF EXISTS parcels;
    DROP TABLE IF EXISTS buildings;

-- ATLAS table -- done

CREATE TABLE atlas(
    atlas_no INT, -- id for atlas within leventhal center library -- 
    name VARCHAR(10), -- human readable name 
    geom geometry(POLYGON, 0, 2),
    plate_no INTEGER,
    CONSTRAINT atlas_key PRIMARY KEY (atlas_no)
    );

    -- populate ATLAS table --

    -- update spatial reference ID for ATLAS -- 
SELECT UpdateGeometrySRID('public', 'atlas', 'geom', 4326);

-- PLATES table -- done 

CREATE TABLE plates(
    plate_no INTEGER,
    geom geometry(POLYGON, 0, 2), -- spatial geometry
    area FLOAT(8), -- numeric area of parcel
    surveyor VARCHAR(10), -- name of surveyor
    survey_f DATE, -- first year surveyed
    survey_l DATE, -- most recent year surveyed
    corrected DATE, -- most recent "correction"
    atlas INT,

    CONSTRAINT plate_key PRIMARY KEY (plate_no),
    FOREIGN KEY (atlas) REFERENCES atlas(atlas_no)
    );

    -- update spatial reference ID for plates -- 
SELECT UpdateGeometrySRID('public', 'plates', 'geom', 4326); -- update (schema, table, column, specify SRID)

-- STREETS table -- done

CREATE TABLE streets (
    street_id INTEGER,
    geom geometry(POLYGON, 0, 2),
    plate_no INTEGER,
    name VARCHAR(10),
    ownership VARCHAR(7),
    pavement VARCHAR(7),
    FOREIGN KEY (plate_no) REFERENCES plates(plate_no), -- specify FK
    CONSTRAINT owner_type CHECK (ownership IN ('public', 'private')), -- specify the types of values that go into owner column
    CONSTRAINT pavement CHECK (pavement IN ('gravel', 'earth', 'paved')), -- specify street types.
    CONSTRAINT street_key PRIMARY KEY (street_id) -- set PK.
    );

    -- populate STREETS Table -- 

    -- update spatial reference ID for STREETS -- 

    -- update spatial reference ID for streets -- 
SELECT UpdateGeometrySRID('public', 'streets', 'geom', 4326); -- update (schema, table, column, specify SRID)

-- FIRE HYDRANTS table -- done 

CREATE TABLE f_hydrants(
    id INTEGER,
    geom geometry(POINT, 0),
    street_id INTEGER,
    plate_no INTEGER,
    FOREIGN KEY (street_id) REFERENCES streets(street_id),
    FOREIGN KEY (plate_no) REFERENCES plates(plate_no),
    CONSTRAINT id_key PRIMARY KEY (id) 
    );

    -- update spatial reference ID for FIRE HYDRANTS -- 

SELECT UpdateGeometrySRID('public', 'f_hydrants', 'geom', 4326); -- update (schema, table, column, specify SRID)

-- WARDS table -- done 

CREATE TABLE wards (
    ward_no INTEGER,
    plate_no INTEGER,
    ward_name VARCHAR(15),
    geom geometry(POLYGON, 0, 2),
    area FLOAT(8), 
    FOREIGN KEY (plate_no) REFERENCES plates(plate_no),
    CONSTRAINT ward_key PRIMARY KEY (ward_no)
    );

    -- update spatial reference ID for WARDS  -- 

SELECT UpdateGeometrySRID('public', 'wards', 'geom', 4326); -- update (schema, table, column, specify SRID)

-- HYDROLOGY TABLE  -- done 
CREATE TABLE hydrology(
    obj_id INTEGER,
    plate_no INTEGER,
    geom geometry(POLYGON, 0, 2),
    area FLOAT(8),
    details TEXT,
    water_type VARCHAR(10),
    CONSTRAINT obj_key PRIMARY KEY (obj_id),
    FOREIGN KEY (plate_no) REFERENCES plates(plate_no),
    CONSTRAINT water_check CHECK(water_type IN ('salt', 'fresh'))
    );

SELECT UpdateGeometrySRID('public', 'hydrology', 'geom', 4326); -- update (schema, table, column, specify SRID)

-- WATER MAINS -- done 

CREATE TABLE w_mains(
        obj_id INTEGER,
        plate_no INTEGER,
        geom geometry(MULTILINESTRING),
        diam_in INTEGER, -- diameter in inches
        height_in INTEGER, -- height above or below ground 
        owner VARCHAR, -- name of owner
        class VARCHAR, 

        CONSTRAINT oid_key PRIMARY KEY (obj_id),
        FOREIGN KEY (plate_no) REFERENCES plates(plate_no)
    );
    -- update spatial reference ID for WATER MAINS -- 

SELECT UpdateGeometrySRID('public', 'water_mains', 'geom', 4326); -- update (schema, table, column, specify SRID)

-- SEWER MAINS -- done 

 CREATE TABLE s_mains(
        obj_id INTEGER,
        plate_no INTEGER,
        geom geometry(MULTILINESTRING),
        diam_in INTEGER, -- diameter in inches
        height_in INTEGER, -- height above or below ground 
        owner VARCHAR, -- name of owner
        class VARCHAR, 
        CONSTRAINT obj_id_key PRIMARY KEY (obj_id),
        FOREIGN KEY (plate_no) REFERENCES plates(plate_no)
        );

    -- update spatial reference ID for SEWER MAINS-- 

SELECT UpdateGeometrySRID('public', 's_mains', 'geom', 4326); -- update (schema, table, column, specify SRID)

-- PARCELS -- done 

CREATE TABLE parcels (
    parcel_id INTEGER,
    plate_no INT,
    geom geometry(POLYGON, 0, 2),
    area FLOAT(8),
    land_use VARCHAR,
    owner VARCHAR(10),
    FOREIGN KEY (plate_no) REFERENCES plates(plate_no), --
    CONSTRAINT parcel_key PRIMARY KEY (parcel_id),
    CONSTRAINT land_use_check CHECK (land_use IN ('commercial', 'residential', 'industrial', 'public space', 'vacant'))
    );
    -- update spatial reference ID for PARCELS -- 

SELECT UpdateGeometrySRID('public', 'parcels', 'geom', 4326); -- update (schema, table, column, specify SRID)

--BUILDINGS -- done 

CREATE TABLE buildings (
    building_id INTEGER,
    geom geometry(POLYGON, 0, 2),
    area FLOAT(8),
    material VARCHAR(10),
    parcel_id INTEGER,
    use VARCHAR(30),
    CONSTRAINT material_check CHECK (material IN ('wood', 'brick', 'stone')),
    CONSTRAINT building_key PRIMARY KEY (building_id),
    FOREIGN KEY (parcel_id) REFERENCES parcels(parcel_id)
    );

-- update spatial reference ID for BUILDINGS -- 

SELECT UpdateGeometrySRID('public', 'buildings', 'geom', 4326); -- update (schema, table, column, specify SRID)
-- Create Parcel - Building Junction Table -- 

CREATE TABLE building_by_parcel (
    id SERIAL NOT NULL,
    building_id INT,
    parcel_id INT,
    CONSTRAINT b_by_p_pkey PRIMARY KEY (id), -- set primary key
    FOREIGN KEY (building_ID) REFERENCES buildings(building_id), -- foreign key 1 
    FOREIGN KEY (parcel_id) REFERENCES parcels(parcel_id) -- foreign key 2
    );
