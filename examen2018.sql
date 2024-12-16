/*
Álgebra Relacional y SQL

AGENCIA = (RAZONSOCIAL, dirección, teléfono, e-mail)
CIUDAD = (CODIGOPOSTAL, nombreCiudad, anioCreación)
CLIENTE = (DNI, nombre, apellido, teléfono, dirección, cpLocalidad (FK))
VIAJE = (FECHA, HORA, DNI (FK), cpOrigen (FK), cpDestino (FK), razonSocial (FK), descripción)

- Listar apellido y nombre de clientes que viajaron con ciudad destino “San Miguel del Monte” pero no viajaron con ciudad destino “Las Flores”. En SQL ordenar por apellido y nombre.
- Listar DNI, apellido y nombre de los clientes que realizaron viajes durante 2017 o que hayan viajado por la agencia ubicada en la dirección 50 y 120. En SQL ordenar por apellido y nombre.
- Eliminar la agencia con nombre “Los Tilos”.
- Listar apellido, nombre, teléfono y ciudad de clientes que hayan viajado a “Mar del Plata” y a “Carlos Paz”.
- Listar las ciudades que no poseen viajes (tanto origen como destino) durante el año 2017.
En SQL ordenar por nombre de ciudad.
- Reportar nombre, apellido, dirección y teléfono de clientes con más de 10 viajes.
Ordenar por apellido y nombre.
- Listar razón social, dirección y teléfono de las agencias que registren viajes
(tener en cuenta solo los destinos) a todas las ciudades.*/

SELECT c.nombre, c.apellido
FROM Cliente c
LEFT JOIN Viaje v ON (c.dni = v.dni)
WHERE v.cpDestino = "San Miguel del Monte" AND c.dni NOT IN (
    SELECT c2.dni
    FROM Cliente c2
    LEFT JOIN Viaje v2 ON (c2.dni = v2.dni)
    WHERE v.cpDestino = 'Las Flores'
)
ORDER BY c.nombre, c.apellido;

SELECT c.dni, c.nombre, c.apellido
FROM Cliente c
LEFT JOIN Viaje v ON (v.dni = c.dni)
LEFT JOIN Agencia a ON (a.razonSocial = v.razonSocial)
WHERE (v.FECHA > '2016-12-31' AND v.FECHA < '2018-01-01') OR (a.dirección = '50 y 120')
ORDER BY c.apellido, c.nombre;

DELETE FROM Agencia WHERE (RAZONSOCIAL = 'Los Tilos');

SELECT c.nombre, c.apellido, c.telefono, c.cpLocalidad
FROM Cliente c
INNER JOIN Viaje v ON (c.dni = v.dni)
INNER JOIN Ciudad ciudad ON (v.cpDestino = ciudad.CODIGOPOSTAL)
WHERE ciudad.nombreCiudad = 'Mar del Plata' AND c.dni IN (
    SELECT c2.dni
    FROM Cliente c2
    INNER JOIN Viaje v2 ON (c2.dni = v2.dni)
    INNER JOIN Ciudad ciudad2 ON (v2.cpDestino = ciudad2.CODIGOPOSTAL)
    WHERE ciudad.nombreCiudad = "Carlos Paz"
)
ORDER BY c.nombre, c.apellido;

SELECT c.nombreCiudad
FROM Ciudad c
LEFT JOIN Viaje origenViaje 
    ON (origenViaje.cpOrigen = c.CODIGOPOSTAL) 
    AND (origenViaje.FECHA BETWEEN '2017-01-01' AND '2017-12-31')
LEFT JOIN Viaje destinoViaje 
    ON (destinoViaje.cpDestino = c.CODIGOPOSTAL) 
    AND (destinoViaje.FECHA BETWEEN '2017-01-01' AND '2017-12-31')
WHERE origenViaje.cpOrigen IS NULL AND destinoViaje.cpDestino IS NULL
ORDER BY c.nombreCiudad;

SELECT c.nombre, c.apellido, c.direccion, c.telefono
FROM Cliente c
INNER JOIN Viaje v ON (c.dni = v.DNI)
GROUP BY c.dni, c.nombre, c.apellido, c.direccion, c.telefono
HAVING COUNT(v.DNI) > 10
ORDER BY c.apellido, c.nombre;

SELECT a.RAZONSOCIAL, a.direccion, a.telefono /* Datos que me interesan. */
FROM Agencia a
WHERE NOT EXISTS (
    SELECT *
    FROM Ciudad c /* Tabla de la que quiero verificar el "TODOS" .*/
    WHERE /* c.nombreCiudad LIKE 'M%' AND */ NOT EXISTS(
        SELECT *
        FROM Viaje v
        WHERE a.RAZONSOCIAL = v.razonSocial
            AND c.CODIGOPOSTAL = v.cpDestino /* """Conecto""" las tablas. */
    )
);