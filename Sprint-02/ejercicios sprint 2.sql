-- Nivel 1
-- Ejercicio 1
-- A partir de los documentos adjuntos (estructura_dades y dades_introduir), importa las dos tablas. Muestra las características principales del esquema creado y explica las 
-- diferentes tablas y variables que existen. Asegúrate de incluir un diagrama que ilustre la relación entre las diferentes tablas y variables.
-- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );

    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );

-- Ejercicio 2
-- Utilizando JOIN realizarás las siguientes consultas:
-- • Listado de los países que están generando ventas. 
select distinct country 
from company
join transaction
on company.id = transaction.company_id;

-- • Desde cuántos países se generan las ventas.
select count(distinct country)
from company
join transaction
on company.id = transaction.company_id;

-- • Identifica la compañía con la mayor media de ventas.
select company_name, round(avg(transaction.amount), 2) as MayortMediaVentas
from company
join transaction
on company.id = transaction.company_id
where declined = 0
group by company.id, company_name
order by MayortMediaVentas desc
limit 1;



-- Ejercicio 3
-- Utilizando sólo subconsultas (sin utilizar JOIN):
-- • Muestra todas las transacciones realizadas por empresas de Alemania.
select *
from transaction
where company_id in (select id
						from company
						where country = "Germany");
                        
-- • Lista las empresas que han realizado transacciones por un amount superior a la media de todas las transacciones.
select id, company_name
from company
where exists (select company_id
				from transaction
				where amount > (select avg(amount) as mediaTransacciones
								from transaction)
                                and company.id = transaction.company_id);
                
-- • Eliminarán del sistema las empresas que no tienen transacciones registradas, entrega el listado de estas empresas.
select id, company_name
from company
where not exists (select company_id
					from transaction);

-- Nivel 2
-- Ejercicio 1
-- Identifica los cinco días que se generó la mayor cantidad de ingresos en la empresa por ventas. Muestra la fecha de cada transacción junto con el total de las ventas

select * from transaction;

select date(timestamp) as Fecha, sum(amount) as VentasTotales
from transaction
where declined = 0
group by Fecha
order by VentasTotales desc
limit 5;

-- Ejercicio 2
-- ¿Cuál es el promedio de ventas por país? Presenta los resultados ordenados de mayor a menor medio.
select company.country, round(avg(transaction.amount), 2) as promedioVentas
from company
join transaction
on company.id = transaction.company_id
where declined = 0
group by company.country
order by promedioVentas desc;



-- Ejercicio 3
-- En tu empresa, se plantea un nuevo proyecto para lanzar algunas campañas publicitarias para hacer competencia a la compañía "Non Institute". 
-- Para ello, te piden la lista de todas las transacciones realizadas por empresas que están situadas en el mismo país que esta compañía.
-- • Muestra el listado aplicando JOIN y subconsultas.

select transaction.*, company.company_name, company.country
from company
join transaction
on company.id = transaction.company_id
where company.country = (select country
							from company
							where company_name = "Non Institute");

-- • Muestra el listado aplicando solamente subconsultas.
select transaction.*, (select company.company_name 
						from company 
                        where company.id = transaction.company_id) as NombreEmpresa, 
					  (select company.country 
						from company 
                        where company.id = transaction.company_id) as Pais
from transaction
where exists (select id
				from company 
				where company.id = transaction.company_id AND 
                country = (select company2.country
									from company as company2
									where company2.company_name = "Non Institute"));

-- Nivel 3                                    
-- Ejercicio 1
-- Presenta el nombre, teléfono, país, fecha y amount, de aquellas empresas que realizaron transacciones con un valor comprendido entre 350 y 400 euros 
-- y en alguna de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024. Ordena los resultados de mayor a menor cantidad.
select company.company_name, company.phone, company.country, date(timestamp) as fecha, round(transaction.amount, 2) as Ventas
from company
join transaction
on company.id = transaction.company_id
where transaction.amount between 350 and 400 and date(timestamp) in ("2015-04-29", "2024-03-13", "2018-07-20")
order by Ventas desc;



-- Ejercicio 2
-- Necesitamos optimizar la asignación de los recursos y dependerá de la capacidad operativa que se requiera, por lo que te piden la información sobre la cantidad 
-- de transacciones que realizan las empresas, pero el departamento de recursos humanos es exigente y quiere un listado de las empresas donde especifiques 
-- si tienen más de 400 transacciones o menos.
select transaction.company_id, company.company_name, count(transaction.amount) as conteoTransacciones, case 
																											when count(transaction.amount) >= 400 then "Mayor 400" 
                                                                                                            else "Menor 400" end as Varemo
from company
join transaction
on company.id = transaction.company_id
group by company.company_name, transaction.company_id
order by conteoTransacciones desc;

