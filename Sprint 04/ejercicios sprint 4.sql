-- Nivel 1
-- Descarga los archivos CSV, estudialos y diseña una base de datos con un esquema de estrella que contenga, al menos 4 tablas de las que puedas realizar 
-- las siguientes consultas:
-- Ejercicio 1
-- Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.

-- Se crea la tabla internationalmarket y se usa como principal
create database internationalmarket; 
use internationalmarket;

-- Se crea la tabla companies
create table companies (
	company_id varchar(255) primary key,
	company_name varchar(255),
	phone varchar(255),
	email varchar(255),
	country varchar(255),
	website varchar(255)
    );

-- Se crea la tabla users
create table users (
	id varchar(255) primary key,
	name varchar(255),
	surname varchar(255),
	phone varchar(255),
	email varchar(255),
	birth_date varchar(255),
	country varchar(255),
	city varchar(255),
	postal_code varchar(255),
	address varchar(255),
    user_continent enum('EU', 'USA') not null
    );
    
-- Se crea la tabla products    
create table products (
	id varchar(255) primary key, 
	product_name varchar(255),
	Price varchar(255),
	color varchar(255),
	weight varchar(255),
	warehouse_id varchar(255)
    ); 

-- Se crea la tabla credit_cards    
create table credit_cards (
	id varchar(255) primary key,
	user_id varchar(255),
	iban varchar(255),
	pan varchar(255),
	pin varchar(255),
	cvv varchar(255),
	track1 varchar(255),
	track2 varchar(255),
	expiring_date varchar(255)
    );

-- Se crea la tabla transactions    
create table transactions (
	id varchar(255) primary key,
	card_id varchar(255),
	business_id varchar(255),
	timestamp varchar(255),
	amount varchar(255),
	declined varchar(255),
	product_ids varchar(255),
	user_id varchar(255),
    lat varchar(255),
	longitude varchar(255),
    
    -- Se definen las claves foraneas
    constraint fk_credit_card
    foreign key (card_id)
    references credit_cards(id)
    on delete cascade
    on update cascade,
    
    constraint fk_companies
    foreign key (business_id)
    references companies(company_id)
    on delete cascade
    on update cascade,
    
    constraint fk_products
    foreign key (product_ids)
    references products(id)
    on delete cascade
    on update cascade,
    
    constraint fk_users_transactions
    foreign key (user_id)
    references users(id)
    on delete cascade
    on update cascade
    );

-- Se cargan los datos de todas las tablas
load data local infile 'E:/informacion y documentos/Curso analisis de datos IT Academy/MYSQL/Especializacion/Sprint 04/companies.csv'
into table companies
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

-- Permisos activos para poder cargar con local infile
show variables like 'local_infile';

set global local_infile = 1;

show variables like 'local_infile';

-- Se cargan los datos en la tabla companies
load data local infile 'E:/informacion y documentos/Curso analisis de datos IT Academy/MYSQL/Especializacion/Sprint 04/companies.csv'
into table companies
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(company_id, company_name, phone, email, country, website);

-- Verificación insercion correcta de datos en companies
select *
from companies;

-- Se cargan los datos en la tabla users y se verifica la correcta insercion de los datos en la tabla users
load data local infile 'E:/informacion y documentos/Curso analisis de datos IT Academy/MYSQL/Especializacion/Sprint 04/european_users.csv'
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
set user_continent = 'EU';

select *
from users;

load data local infile 'E:/informacion y documentos/Curso analisis de datos IT Academy/MYSQL/Especializacion/Sprint 04/american_users.csv'
into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(id, name, surname, phone, email, birth_date, country, city, postal_code, address)
set user_continent = 'USA';

select *
from users;

-- Se cargan los datos en la tabla products y se verifica la correcta inserción
load data local infile 'E:/informacion y documentos/Curso analisis de datos IT Academy/MYSQL/Especializacion/Sprint 04/products.csv'
into table products
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(id, product_name, price, color, weight, warehouse_id);

select *
from products;

-- Se cargan los datos en la tabla credit_card y se verifica la correcta insercion de los datos
load data local infile 'E:/informacion y documentos/Curso analisis de datos IT Academy/MYSQL/Especializacion/Sprint 04/credit_cards.csv'
into table credit_cards
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(id, user_id, iban, pan, pin, cvv, track1, track2, expiring_date);

-- Se elimina el campo user_id de la tabla credit card    
alter table credit_cards
drop column user_id;

select *
from credit_cards;

-- Se elimina la clave foranea de products en la tabla transactions
alter table transactions
drop foreign key fk_products;

-- Se cargan los datos en la tabla transactions
load data local infile 'E:/informacion y documentos/Curso analisis de datos IT Academy/MYSQL/Especializacion/Sprint 04/transactions.csv'
into table transactions
fields terminated by ';'
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(id, card_id, business_id, timestamp, amount, declined, product_ids, user_id, lat, longitude);

-- Se verifica la correcta inserción de los datos en la tabla transactions
select *
from transactions;

-- Se crea la tabla intermedia entre transactions y el campo product_ids para normalizar los id del campo product_ids y poder relacionar las tablas transactions y products
create table products_transactions (
	transactions_id varchar(36),
    products_id varchar(10),
    primary key (transactions_id, products_id),
    
    constraint fk_transactions
    foreign key (transactions_id)
    references transactions(id),
    
    constraint fk_products
    foreign key (products_id)
    references products(id));

-- Se insertan los id de transactions y product_ids para normalizar una relacion muchos a muchos
INSERT INTO products_transactions (transactions_id, products_id) 
SELECT transactions.id, trim(jasonTable.products_id)
FROM transactions
JOIN JSON_TABLE(
				CONCAT('["', REPLACE(transactions.product_ids, ',', '", "'), '"]'), '$[*]' 
                COLUMNS (products_id varchar(10) PATH '$')) as jasonTable
JOIN products
ON products.id = trim(jasonTable.products_id)
WHERE transactions.product_ids IS NOT NULL
AND transactions.product_ids <> '';

alter table products
modify id varchar(10);

-- Comprobacion longitud campos tabla companies

select max(length(company_id)) as idCompañia from companies;

select max(length(company_name)) as nombreCompañia from companies;

select max(length(phone)) as telefonoCompañia from companies;

select max(length(email)) as emailCompañia from companies;

select max(length(country)) as paisCompañia from companies;

select max(length(website)) webCompañia from companies;

alter table companies
modify company_id int;

-- Eliminacion claves foraneas

alter table products_transactions
drop foreign key fk_transactions;

alter table products_transactions
drop foreign key fk_products;

alter table transactions
drop foreign key fk_credit_card;

alter table transactions
drop foreign key fk_companies;

alter table transactions
drop foreign key fk_products;

alter table transactions
drop foreign key fk_users_transactions;

-- Cambio tipo de dato y longitud dato tabla companies

alter table companies
modify company_id varchar(8);

alter table companies
modify company_name varchar(40);

alter table companies
modify phone varchar(14);

alter table companies
modify email varchar(100);

alter table companies
modify country varchar(20);

alter table companies
modify website varchar(50);

-- Tabla credit_cards

select max(length(id)) as id from credit_cards;

select max(length(iban)) as iban from credit_cards;

select max(length(pan)) as pan from credit_cards;

select max(length(pin)) as pin from credit_cards;

select max(length(cvv)) as cvv from credit_cards;

select max(length(track1)) as track1 from credit_cards;

select max(length(track2)) as track2 from credit_cards;

select max(length(expiring_date)) as expiring_date from credit_cards;

-- Cambio datos tabla credit cards

alter table credit_cards
modify id varchar(10);

alter table credit_cards
modify iban varchar(31);

alter table credit_cards
modify pan varchar(19);

alter table credit_cards
modify pin varchar(4);

alter table credit_cards
modify cvv varchar(3);

alter table credit_cards
modify track1 varchar(52);

alter table credit_cards
modify track2 varchar(36);

UPDATE credit_cards
SET credit_cards.expiring_date =
    LAST_DAY(
        STR_TO_DATE(credit_cards.expiring_date, '%m/%d/%y')
    )
limit 6000; -- No es buena practica utilizar un limit a la hora de actualizar datos, seria mejor utilizar set global

alter table credit_cards
modify expiring_date date;

-- Tabla products
select max(length(id)) as id from products;

select max(length(product_name)) as nombre_producto from products;

select max(length(Price)) as precio from products;

select max(length(color)) as color from products;

select max(length(weight)) as peso from products;

select max(length(warehouse_id)) as warehouse_id from products;

alter table products
modify id int;

alter table products
modify product_name varchar(40);

-- Se renombra la columna con el simbolo de la moneda
alter table products
rename column Price to price$;

-- Se elimina el simbolo $ para tener solo los numeros y poder realizar operaciones matematicas y se define el campo como decimal con dos decimales
UPDATE products
SET price$ =
    CAST(
        REPLACE(price$, '$', '')
        AS DECIMAL(10,2)
    ) where id > 0;
    
alter table products
modify price$ decimal(10,2);

alter table products
modify color varchar(7);

alter table products
modify weight varchar(4);

alter table products
modify weight varchar(8);

-- Tabla transactions
select max(length(id)) as id from transactions;

select max(length(card_id)) as card_id from transactions;

select max(length(business_id)) as companies_id from transactions;

select max(length(timestamp)) as timestamp from transactions;

select max(length(amount)) as amount from transactions;

select max(length(declined)) as declinada from transactions;

select max(length(product_ids)) as products_id from transactions;

select max(length(user_id)) as user_id from transactions;

select max(length(lat)) as latitud from transactions;

select max(length(longitude)) as longitud from transactions;

-- Se modifica la longitud y el tipo de dato.
alter table transactions
modify id varchar(36);

alter table transactions
modify card_id varchar(10); -- igual que id en la tabla credit_cards

alter table transactions
modify business_id varchar(8); -- igual que id en la tabla companies

alter table transactions
modify timestamp timestamp;

UPDATE transactions
SET `timestamp` = STR_TO_DATE(`timestamp`, '%d/%m/%Y %H:%i')
WHERE `timestamp` IS NOT NULL;

UPDATE transactions
SET `timestamp` = STR_TO_DATE(`timestamp`, '%d/%m/%Y %H:%i')
WHERE id > 0;

UPDATE transactions
SET `timestamp` = STR_TO_DATE(`timestamp`, '%d/%m/%Y %H:%i')
LIMIT 1000000;

ALTER TABLE transactions
MODIFY `timestamp` TIMESTAMP; -- Se renombra la columna ya que timestamp es una palabra reservada

alter table transactions
modify amount decimal(10,2);

alter table transactions
modify declined tinyint;

alter table transactions
modify product_ids varchar(19); -- es varchar(19) porque los id no estan separados de uno en uno, hay varios en un mismo registro

alter table transactions
modify user_id int;

alter table transactions
modify lat varchar(22);

alter table transactions
modify longitude varchar(24);

-- Tabla users
select max(length(id)) as id from users;

select max(length(name)) as nombre from users;

select max(length(surname)) as apellido from users;

select max(length(phone)) as telefono from users;

select max(length(email)) as email from users;

select max(length(birth_date)) as birth_date from users;

select max(length(country)) as pais from users;

select max(length(city)) as ciudad from users;

select max(length(postal_code)) as codigo_postal from users;

select max(length(address)) as direccion from users;

select max(length(user_continent)) as continente_usuario from users;

alter table users
modify id int; -- Igual que en tranasctions

alter table users
modify name varchar(12);

alter table users
modify surname varchar(12);

alter table users
modify phone varchar(16);

alter table users
modify email varchar(50);

-- Esto no funciona ya que la fecha esta como Nov 17, 1985 por ejemplo
alter table users
modify birth_date date;

-- En vez de poner %m, %d, %y, se pone %b por tener el mes como nov, esto solo funcionara si la abreviatura esta en ingles
UPDATE users
SET birth_date = STR_TO_DATE(birth_date, '%b %d, %Y')
limit 6000;

alter table users
modify birth_date date;

alter table users
modify country varchar(16);

alter table users
modify city varchar(16);

alter table users
modify postal_code varchar(8);

alter table users
modify address varchar(40);

alter table users
rename column user_continent to user_region;

-- Se crea la nueva tabla para almacenar las regiones y facilitar la insercion de nuevas regiones
create table user_regions (
	id int auto_increment primary key,
    code_region char(3) unique, 
    name_region varchar(50)
);

insert into user_regions (code_region, name_region) values
("EU", "Europe"),
("USA", "United State");

alter table users
add id_user_regions int;

update users
join user_regions
on users.user_region = user_regions.code_region
set users.id_user_regions = user_regions.id
where users.id > 0;

SELECT COUNT(*) FROM users WHERE id_user_regions IS NULL; -- comprobacion de que se han migrado bien los datos

alter table users
add constraint fk_id_user_regions
foreign key (id_user_regions)
references user_regions(id);

SELECT *
FROM users
JOIN user_regions
ON users.id_user_regions = user_regions.id;

-- Tabla products_transactions
alter table products_transactions
modify transactions_id varchar(36);

alter table products_transactions
modify products_id int;

alter table users
drop column user_region;

-- Declaracion claves foraneas transactions 
alter table transactions
add constraint fk_credit_card
foreign key (card_id)
references credit_cards(id)
on delete cascade
on update cascade;
   
alter table transactions
add constraint fk_companies
foreign key (business_id)
references companies(company_id)
on delete cascade
on update cascade;
    
alter table transactions
add constraint fk_users_transactions
foreign key (user_id)
references users(id)
on delete cascade
on update cascade;

-- Declaracion claves foraneas products_transactions 
alter table products_transactions
add constraint fk_transactions
foreign key (transactions_id)
references transactions(id);
    
alter table products_transactions
add constraint fk_products
foreign key (products_id)
references products(id);

----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Ejercicio 1
-- Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas.
SELECT *
FROM users u
where exists (
    SELECT 1
    FROM transactions t
    where t.user_id = u.id and declined = 0
    GROUP BY user_id
    HAVING COUNT(id) > 80
);

-- Ejercicio 2
-- Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas.
select *
from companies
where company_name = 'Donec Ltd';

select c.company_id, c.company_name, cc.iban, round(avg(t.amount),2) as mediaVentas
from companies c
join transactions t
on c.company_id = t.business_id
join credit_cards cc
on t.card_id = cc.id
where company_name = 'Donec Ltd' and declined = 0
group by c.company_id, c.company_name, cc.iban;

-- Nivel 2
-- Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las tres últimas transacciones
-- han sido declinadas entonces es inactivo, si al menos una no es rechazada entonces es activo . Partiendo de esta tabla responde:
create table credit_card_status (
    card_id varchar(10) primary key,
    status enum('ACTIVE', 'INACTIVE') not null,
    updated_at timestamp default current_timestamp
);

-- Se insetan los datos en credit_card_status para saber si una tarjeta esta activa o inactiva
insert into credit_card_status (card_id, status)
select sub.card_id, case
						when SUM(sub.declined) = 3 then 'INACTIVE'
						else 'ACTIVE'
					end as status
from (select transactions.card_id, transactions.declined, row_number() over (
																				partition by transactions.card_id
																				order by transactions.timestamp desc) as rowNumber
	  from transactions) as sub
where rowNumber <= 3
group by sub.card_id
on duplicate key update
status = values(status),
updated_at = current_timestamp;

-- Comprobacion tabla credit_card_status
select *
from credit_card_status;

-- Se declara clave foranea el id de la tabla credit_card_status
alter table credit_card_status
add constraint fk_credit_card_id
foreign key (card_id)
references credit_cards(id)
on delete cascade
on update cascade;

alter table credit_card_status
add constraint uq_credit_card_status_card
unique (card_id);

-- Ejercicio 1
-- ¿Cuántas tarjetas están activas?
select * from credit_card_status
where status = 'active';

-- Nivel 3
-- Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:
-- La tabla se creó al inicio de todo

-- Ejercicio 1
-- Necesitamos conocer el número de veces que se ha vendido cada producto.
select p.id as idProducto, p.product_name as nombreProducto, count(t.id) as conteoVentas
from products p
join products_transactions pt
on p.id = pt.products_id
join transactions t
on pt.transactions_id = t.id
where t.declined = 0
group by idProducto, nombreProducto;

