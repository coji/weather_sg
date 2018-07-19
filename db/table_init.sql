
create table if not exists weather_log(
  type varchar2(64),
  ts varchar2(64),
  station_id integer,
  value varchar2(32)
);

create table if not exists station (
  station_id varchar(8) PRIMARY KEY,
  name varchar(255),
  latitude float,
  longitude float);
