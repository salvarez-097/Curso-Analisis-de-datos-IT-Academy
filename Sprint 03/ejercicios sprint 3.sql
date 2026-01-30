-- Nivel 1
-- Ejercicio 1
-- Tu tarea es diseñar y crear una tabla llamada "credit_card" que almacene detalles cruciales sobre las tarjetas de crédito. La nueva tabla debe ser capaz de identificar 
-- de forma única cada tarjeta y establecer una relación adecuada con las otras dos tablas ("transaction" y "company"). Después de crear la tabla será necesario que 
-- ingreses la información del documento denominado "datos_introducir_credit". Recuerda mostrar el diagrama y realizar una breve descripción del mismo.

create table if not exists credit_card (
	id varchar(255) primary key not null,
    iban varchar(255),
    pan varchar(50),
    pin varchar(20),
    cvv varchar(5),
    expiring_date varchar(20)
);

alter table transaction
add constraint fk_credit_card_id
foreign key (credit_card_id)
references credit_card(id);

-- Ejercicio 2
-- El departamento de Recursos Humanos ha identificado un error en el número de cuenta asociado a su tarjeta de crédito con ID CcU-2938. 
-- La información que debe mostrarse para este registro es: TR323456312213576817699999. Recuerda mostrar que el cambio se realizó

select * from credit_card
where id = "CcU-2938";

update credit_card
set iban = "TR323456312213576817699999"
where id = "CcU-2938";

select * from credit_card
where id = "CcU-2938";

-- Ejercicio 3
-- En la tabla "transaction" ingresa una nueva transacción con la siguiente información:
-- Id 				108B1D1D-5B23-A76C-55EF-C568E49A99DD
-- credit_card_id 	CcU-9999
-- company_id 		b-9999
-- user_id 			9999
-- lato				829.999
-- longitud 		-117.999
-- amunt 			111.11
-- declined 		0
-- HAY ALGUNOS CAMPOS MAL ESCRITOS EN LA TABLA (lato , longitud y amunt, serian lat, longitude y amount) Y FALTA timestamp
insert into transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestmp, amount, declined) values
("108B1D1D-5B23-A76C-55EF-C568E49A99DD", "CcU-9999", "b-9999", "9999", "829.999", "-117.999", "2024-08-14 12:24:25", "111.11", "0");

INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) VALUES
('CCU-9999', 'TR357681763013866195031221', '5424646668135533', '3585', '458', '09/10/23');

select * from credit_card
where id = "CcU-9999";

INSERT INTO Company (id, company_name, phone, email, country, website) VALUES
('b-9999', 'Garden Smith Corp.', '07 45 87 32 28', 'garden.smith@protonmail.couk', 'United States', 'https://gardensmith.com');

select * from company
where id = "b-9999";

insert into transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) values 
("10881010-5823-A76C-55EF-C568E49A9900", "CCU-9999", "b-9999", "9999", "829.999", "-117.999", "2024-08-14 12:24:25", "111.11", "0");

select *
from transaction
where id = "10881010-5823-A76C-55EF-C568E49A9900";

-- Ejercicio 4
-- Desde recursos humanos te solicitan eliminar la columna "pan" de la tabla credit_card. Recuerda mostrar el cambio realizado.
select *
from credit_card;

alter table credit_card drop column pan;

select *
from credit_card;

-- Nivel 2
-- Ejercicio 1
-- Elimina de la tabla transacción el registro con ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD de la base de datos.
select *
from transaction 
where id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

delete from transaction
where id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

select *
from transaction 
where id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

-- Ejercicio 2
-- La sección de marketing desea tener acceso a información específica para realizar análisis y estrategias efectivas. 
-- Se ha solicitado crear una vista que proporcione detalles clave sobre las compañías y sus transacciones. 
-- Será necesario que crees una vista llamada VistaMarketing que contenga la siguiente información: Nombre de la compañía. Teléfono de contacto. 
-- País de residencia. Media de compra realizada por cada compañía. Presenta la vista creada, ordenando los datos de mayor a menor promedio de compra.
create view VistaMarketing as
select company_name, phone, country, avg(amount) as mediaCompras
from company
join transaction 
on company.id = transaction.company_id
group by company_name, phone, country
order by mediaCompras desc;

select * from vistamarketing;

-- Ejercicio 3
-- Filtra la vista VistaMarketing para mostrar sólo las compañías que tienen su país de residencia en "Germany"
select * 
from vistamarketing
where country = "Germany";

-- Nivel 3
-- Ejercicio 1
-- La próxima semana tendrás una nueva reunión con los gerentes de marketing. Un compañero de tu equipo realizó modificaciones en la base de datos, 
-- pero no recuerda cómo las realizó. Te pide que le ayudes a dejar los comandos ejecutados para obtener el siguiente diagrama:

alter table company
drop column website;

ALTER TABLE transaction
DROP FOREIGN KEY fk_credit_card_id;

alter table credit_card
modify id varchar(20);

alter table credit_card
modify iban varchar(50);

alter table credit_card
modify pin varchar(4);

alter table credit_card
modify cvv int;

alter table credit_card
modify fecha_actual date;

CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

alter table transaction
modify user_id int;

alter table user
modify id int;

alter table transaction
modify credit_card_id varchar(20);

alter table user rename to data_user;

alter table data_user
rename column email to personal_email; 

alter table transaction
add constraint fk_credit_card_id
foreign key (credit_card_id)
references credit_card(id);

alter table transaction
add constraint fk_data_user_id
foreign key (user_id)
references data_user(id);

select *
from transaction
where user_id = "9999";

select *
from data_user
where id = "9999";




insert into data_user (id, name, surname, phone, email, birth_date, country, city, postal_code, address) VALUES 
("9999", "lzxjnvlj", ",mxsfknw", "+39-478-3548", "asgaxisdgsi@example.com", "Jan 15, 1989", "Canada", "Winnipeg", "R2C 0A1", "284 Btardzti St");

select *
from data_user
where id = "9999";

alter table transaction
add constraint fk_data_user_id
foreign key (user_id)
references data_user(id);

-- Ejercicio 2
-- La empresa también le pide crear una vista llamada "InformeTecnico" que contenga la siguiente información:
-- ID de la transacción
-- Nombre del usuario/a
-- Apellido del usuario/a
-- IBAN de la tarjeta de crédito usada.
-- Nombre de la compañía de la transacción realizada.
-- Asegúrese de incluir información relevante de las tablas que conocerá y utilice alias para cambiar de nombre columnas según sea necesario.
-- Muestra los resultados de la vista, ordena los resultados de forma descendente en función de la variable ID de transacción.

create view InformeTecnico as
select transaction.id as identificador, data_user.name as nombre_usuario, data_user.surname as apellido_usuario, credit_card.iban, company.company_name as nombre_compañia
from credit_card
join transaction
on credit_card.id = transaction.credit_card_id
join data_user
on transaction.user_id = data_user.id
join company
on transaction.company_id = company.id;

select * from informetecnico
order by identificador desc;