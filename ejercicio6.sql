/*
Tecnico = (codTec, nombre, especialidad) // técnicos
Repuesto = (codRep, nombre, stock, precio) // repuestos
RepuestoReparacion = (nroReparac (fk), codRep (fk), cantidad, precio)
    // repuestos utilizados en reparaciones.
Reparacion (nroReparac, codTec (fk), precio_total, fecha)
    // reparaciones realizadas.

1. Listar los repuestos, informando el nombre, stock y precio. Ordenar el resultado por precio.
2. Listar nombre, stock y precio de repuestos que se usaron en reparaciones durante 2023 y que no
se usaron en reparaciones del técnico ‘José Gonzalez’.
3. Listar el nombre y especialidad de técnicos que no participaron en ninguna reparación. Ordenar
por nombre ascendentemente.
4. Listar el nombre y especialidad de los técnicos que solamente participaron en reparaciones
durante 2022.
5. Listar para cada repuesto nombre, stock y cantidad de técnicos distintos que lo utilizaron. Si un
repuesto no participó en alguna reparación igual debe aparecer en dicho listado.
6. Listar nombre y especialidad del técnico con mayor cantidad de reparaciones realizadas y el
técnico con menor cantidad de reparaciones.
7. Listar nombre, stock y precio de todos los repuestos con stock mayor a 0 y que dicho repuesto
no haya estado en reparaciones con un precio total superior a $10000.
8. Proyectar número, fecha y precio total de aquellas reparaciones donde se utilizó algún repuesto
con precio en el momento de la reparación mayor a $10000 y menor a $15000.
9. Listar nombre, stock y precio de repuestos que hayan sido utilizados por todos los técnicos.
10. Listar fecha, técnico y precio total de aquellas reparaciones que necesitaron al menos 10
repuestos distintos.
*/

SELECT codRep, nombre, stock, precio
FROM Repuesto
ORDER BY precio;

SELECT r.nombre, r.stock, r.precio
FROM Repuesto r
INNER JOIN RepuestoReparacion rp ON (r.codRep = rp.codRep)
INNER JOIN Reparacion r2 ON (r2.nroReparac = rp.nroReparac)
WHERE r2.fecha BETWEEN '2023-01-01' AND '2023-12-31'
    AND r.codRep NOT IN(
        SELECT repuesto.codRep
        FROM Repuesto repuesto
        INNER JOIN RepuestoReparacion rp2 ON (repuesto.codRep = rp2.codRep)
        INNER JOIN Reparacion reparacion ON (reparacion.nroReparac = repuesto.nroReparac)
        INNER JOIN Tecnico t ON (t.codTec = reparacion.codTec)
        WHERE t.nombre = 'José Gonzalez'
    );

SELECT t.nombre, t.especialidad
FROM Tecnico t
WHERE t.codTec NOT IN (
    SELECT r.codTec
    FROM Reparacion r
)
ORDER BY t.nombre ASC;

SELECT t.nombre, t.especialidad
FROM Tecnico t
INNER JOIN Reparacion repa ON (t.codTec = repa.codTec)
WHERE repa.fecha BETWEEN '2022-01-01' AND '2022-12-31'
AND t.codTec NOT IN (
    SELECT repa2.codTec
    FROM Reparacion repa2
    WHERE repa2.fecha < '2022-01-01' OR repa2.fecha > '2022-12-31'
)
GROUP BY t.codTec, t.nombre, t.especialidad;

SELECT repu.nombre, repu.stock, COUNT(DISTINCT repa.codTec) as usosTecnicosUnicos
FROM Repuesto repu
LEFT JOIN RepuestoReparacion rp ON (repu.codRep = rp.codRep)
LEFT JOIN Reparacion repa ON (rp.nroReparac = repa.nroReparac)
GROUP BY repu.codRep, repu.nombre, repu.stock

SELECT t.nombre, t.especialidad
FROM Tecnico t
INNER JOIN Reparacion r
GROUP BY t.codTec, t.nombre, t.especialidad
HAVING COUNT(r.nroReparac) = (
    SELECT MAX(cantidad)
    FROM (
        SELECT COUNT(repa2.nroReparac) AS cantidad
        FROM Reparacion repa2
        GROUP BY repa2.codTec
    ) as MAXIMO
)
OR (
    SELECT MIN (cantidad)
    FROM(
        SELECT COUNT(repa3.nroReparac) AS cantidad
        FROM Reparacion repa3
        GROUP BY repa3.codTec
    ) as MINIMO
)

SELECT repu.nombre, repu.stock, repu.precio
FROM Repuesto repu
WHERE repu.precio > 0 AND repu.codRep NOT IN(
    SELECT rp.codRep
    FROM RepuestoReparacion rp
    INNER JOIN Reparacion repa ON (repa.nroReparac = rp.nroReparac)
    WHERE repa.precio_total > 10000
)

SELECT repa.nroReparac, repa.fecha, repa.precio_total
FROM Reparacion repa
WHERE repa.nroReparac IN (
    SELECT rp.nroReparac
    FROM RepuestoReparacion rp
    INNER JOIN Repuesto repu ON (rp.codRep = repu.codRep)
    WHERE rp.precio / rp.cantidad > 10000 AND rp.precio / rp.cantidad < 15000 
)

SELECT repu.nombre, repu.stock, repu.precio
FROM Repuesto repu
WHERE NOT EXISTS(
    SELECT *
    FROM Tecnico t
    WHERE NOT EXISTS(
        SELECT *
        FROM Reparacion repa
        INNER JOIN RepuestoReparacion rp ON (repa.nroReparac = rp.nroReparac)
        WHERE repa.codTec=t.codTec AND repu.codRep=rp.codRep
    )
);

SELECT repa.fecha, t.nombre, repa.precio_total
FROM Reparacion repa
INNER JOIN Tecnico t ON repa.codTec = t.codTec
INNER JOIN RepuestoReparacion rp ON repa.nroReparac = rp.nroReparac
GROUP BY repa.nroReparac, repa.fecha, t.nombre, repa.precio_total
HAVING COUNT(DISTINCT rp.codRep) >= 10;