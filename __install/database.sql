create table if not exists inventories
(
    id         int          auto_increment primary key,
    identifier varchar(50),
    items      longtext     default '[]' null
)

create table if not exists inventory_placeables
(
    id         int auto_increment primary key,
    item       longtext                   null
);
