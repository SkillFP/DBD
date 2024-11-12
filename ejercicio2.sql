/*Localidad = (codigoPostal, nombreL, descripcion, #habitantes)
Arbol = (nroArbol, especie, años, calle, nro, codigoPostal(fk))
Podador = (DNI, nombre, apellido, telefono, fnac, codigoPostalVive(fk))
Poda = (codPoda, fecha, DNI(fk), nroArbol(fk))*/

/*1. Listar especie, años, calle, nro y localidad de árboles podados por el podador ‘Juan Perez’ y por
el podador ‘Jose Garcia’.*/

SELECT especie, años, calle, nro, nombreL
FROM Arbol a
INNER JOIN Poda p ON (a.nroArbol = p.nroArbol)
INNER JOIN Podador pp ON (p.DNI = pp.DNI)
WHERE pp.nombre = "Juan" AND pp.apellido = "Pérez"
INTERSECT (
    SELECT especie, años, calle, nro, nombreL
    FROM Arbol a2
    INNER JOIN Poda p2 ON (a2.nroArbol = p2.nroArbol)
    INNER JOIN Podador pp2 ON (p2.DNI = pp2.DNI)
    WHERE pp2.nombre = "Jose" AND pp2.apellido = "García"
);

/*2. Reportar DNI, nombre, apellido, fecha de nacimiento y localidad donde viven de aquellos
podadores que tengan podas realizadas durante 2023.*/

SELECT DISTINCT pp.DNI, pp.nombre, pp.apellido, pp.fnac, l.nombreL
FROM Podador pp
INNER JOIN Localidad l ON (l.codigoPostal = pp.codigoPostalVive)
INNER JOIN Poda p ON (pp.DNI = p.DNI)
WHERE p.fecha BETWEEN '2023-01-01' AND '2023-12-31';

/*3. Listar especie, años, calle, nro y localidad de árboles que no fueron podados nunca.*/

SELECT especie, años, calle, nro, nombreL
FROM Arbol a
INNER JOIN Localidad l ON a.codigoPostal=l.codigoPostal
LEFT JOIN Poda p ON a.nroArbol=p.nroArbol
WHERE p.codPoda IS NULL;