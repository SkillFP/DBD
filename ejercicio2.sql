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

/*4. Reportar especie, años,calle, nro y localidad de árboles que fueron podados durante 2022 y no
fueron podados durante 2023.*/

SELECT DISTINCT especie, años, calle , nro, nombreL
FROM Arbol a
INNER JOIN Localidad l ON a.codigoPostal=l.codigoPostal
INNER JOIN Poda p ON p.nroArbol=a.nroArbol
WHERE p.fecha BETWEEN '2022-01-01' AND '2022-12-31'
EXCEPT (
    SELECT DISTINCT especie, años, calle , nro, nombreL
    FROM Arbol a
    INNER JOIN Localidad l ON a.codigoPostal=l.codigoPostal
    INNER JOIN Poda p ON p.nroArbol=a.nroArbol
    WHERE p.fecha BETWEEN '2023-01-01' AND '2023-12-31'
);

/*5. Reportar DNI, nombre, apellido, fecha de nacimiento y localidad donde viven de aquellos
podadores con apellido terminado con el string ‘ata’ y que tengan al menos una poda durante
2024. Ordenar por apellido y nombre*/

SELECT DISTINCT pp.DNI, pp.nombre, pp.apellido, pp.fnac, l.nombreL
FROM Podador pp
INNER JOIN Localidad l ON pp.codigoPostalVive=l.codigoPostal
INNER JOIN Poda p ON pp.DNI=p.DNI
WHERE pp.apellido LIKE '%ata' AND p.fecha BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY pp.apellido, pp.nombre;

/*6. Listar DNI, apellido, nombre, teléfono y fecha de nacimiento de podadores que solo podaron
árboles de especie ‘Coníferas’.*/

SELECT pp.DNI, pp.apellido, pp.nombre, pp.telefono, pp.fnac
FROM Podador pp
INNER JOIN Poda p ON p.DNI=pp.DNI
INNER JOIN Arbol a ON p.nroArbol=a.nroArbol
WHERE a.especie = 'Coníferas' AND NOT EXISTS (
    SELECT 1
    FROM Podador pp2
    INNER JOIN Poda p2 ON p2.DNI = pp2.DNI
    INNER JOIN Arbol a2 ON a2.nroArbol=p2.nroArbol
    WHERE a.especie != 'Coníferas'
);