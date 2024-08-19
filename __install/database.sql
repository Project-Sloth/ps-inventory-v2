create table if not exists inventory_placeables
(
    id         int auto_increment primary key,
    item       longtext                   null
);

create table if not exists inventory_preferences
(
    id         int auto_increment primary key,
    identifier  varchar(255)              null,    
    preferences longtext                  null
);

