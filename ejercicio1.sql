/*Ejercicio 1
Cliente(idCliente, nombre, apellido, DNI, telefono, direccion)
Factura (nroTicket, total, fecha, hora,idCliente (fk))
Detalle(nroTicket, idProducto, cantidad, preciounitario)
Producto(idProducto, descripcion, precio, nombreP, stock)*/

/*1. Listar datos personales de clientes cuyo apellido comience con el string ‘Pe’. Ordenar por DNI*/

SELECT c.nombre, c.apellido, c.DNI, c.teléfono, c.dirección
FROM Cliente c
WHERE (apellido LIKE "Pe%");

/*2. Listar nombre, apellido, DNI, teléfono y dirección de clientes que realizaron compras solamente durante 2017.*/

SELECT c.nombre, c.apellido, c.DNI, c.teléfono, c.dirección
FROM Cliente c INNER JOIN Factura f ON (c.idCliente = f.idCliente)
WHERE (f.fecha BETWEEN 01/01/2017 and 31/12/2017)
EXCEPT ( 
SELECT c.nombre, c.apellido, c.DNI, c.teléfono, c.dirección
FROM Cliente c INNER JOIN Factura f ON (c.idCliente = f.idCliente)
WHERE (f.fecha < 01/01/2017 and f.fecha > 31/12/2017)
);

/*3. Listar nombre, descripción, precio y stock de productos 
vendidos al cliente con DNI:45789456, pero que no fueron vendidos a clientes de apellido ‘Garcia’.*/

SELECT p.nombreP, p.descripcion, p.precio, p.stock
FROM Producto p 
INNER JOIN Detalle d ON (p.idProducto = d.idProducto)
INNER JOIN Factura f ON (d.nroTicket = f.nroTicket) 
INNER JOIN Cliente c ON (f.idCliente =  c.idCliente)
WHERE (c.DNI = 45789456)
EXCEPT  (
SELECT p.nombreP, p.descripcion, p.precio, p.stock
FROM Producto p 
INNER JOIN Detalle d ON (p.idProducto = d.idProducto)
INNER JOIN Factura f ON (d.nroTicket = f.nroTicket) 
INNER JOIN Cliente c ON (f.idCliente =  c.idCliente)
WHERE (c.apellido = "Garcia")
);

/*4. Listar nombre, descripción, precio y stock de productos no vendidos a clientes que tengan 
teléfono con característica: 221 (La característica está al comienzo del teléfono). Ordenar por nombre.*/

SELECT nombreP, descripcion, precio, stock
FROM Producto p
WHERE idProducto NOT IN (
SELECT p.idProducto
FROM Producto p 
INNER JOIN Detalle d ON (p.idProducto = d.idProducto)
INNER JOIN Factura f ON (d.nroTicket = f.nroTicket) 
INNER JOIN Cliente c ON (f.idCliente =  c.idCliente)
WHERE (c.telefono LIKE "221%")
)
ORDER BY p.nombreP, p.idProducto;

/*5. Listar para cada producto nombre, descripción, precio y cuantas veces fue vendido. Tenga en
cuenta que puede no haberse vendido nunca el producto.*/

SELECT p.nombreP, p.descripcion, p.precio, SUM (d.cantidad) as cantidad
FROM Producto p LEFT JOIN Detalle d ON (p.idProducto = d.idProducto)
GROUP BY p.nombreP, p.descripcion, p.precio;

/*6. Listar nombre, apellido, DNI, teléfono y dirección de clientes que compraron los productos con
nombre ‘prod1’ y ‘prod2’ pero nunca compraron el producto con nombre ‘prod3’*/

SELECT c.nombre
FROM Cliente c
INNER JOIN Factura f ON (c.idCliente = f.idCliente )
INNER JOIN Detalle d ON (f.nroTicket = d.nroTicket)
INNER JOIN Producto p ON (d.idProducto = p.idProducto)
WHERE p.nombreP IN ("prod1", "prod2")
GROUP BY c.idCliente
HAVING COUNT (DISTINCT p.nombreP) = 2 AND c.idCliente NOT IN(
    SELECT c2.idCliente
    FROM Cliente c2
    INNER JOIN Factura f2 ON (c2.idCliente = f2.idCliente )
    INNER JOIN Detalle d2 ON (f2.nroTicket = d2.nroTicket)
    INNER JOIN Producto p2 ON (d2.idProducto = p2.idProducto)
    WHERE p2.nombreP = "prod3"
);

/*7. Listar nroTicket, total, fecha, hora y DNI del cliente, de aquellas facturas donde se haya
comprado el producto ‘prod38’ o la factura tenga fecha de 2019.¨*/

SELECT f.nroTicket, f.total, f.fecha, f.hora, c.DNI
INNER JOIN Factura f ON (c.idCliente = f.idCliente )
INNER JOIN Detalle d ON (f.nroTicket = d.nroTicket)
INNER JOIN Producto p ON (d.idProducto = p.idProducto)
WHERE p.nombreP = "prod38" OR f.fecha BETWEEN 2019-01-01 AND 2019-12-31;

/*8. Agregar un cliente con los siguientes datos: nombre:’Jorge Luis’, apellido:’Castor’, DNI:
40578999, teléfono: ‘221-4400789’, dirección:’11 entre 500 y 501 nro:2587’ y el id de cliente:
500002. Se supone que el idCliente 500002 no existe.*/

INSERT IGNORE INTO Cliente (idCliente, nombre, apellido, DNI, telefono, direccion)
VALUES (500002, "Jorge Luis", "Castor", 40578999, "221-4400789", "11 entre 500 y 501 nro:2587");

/*9. Listar nroTicket, total, fecha, hora para las facturas del cliente ´Jorge Pérez´ donde no haya
comprado el producto ´Z´.*/

SELECT f.nroTicket, f.total, f.fecha, f.hora
FROM Cliente c
INNER JOIN Factura f ON (c.idCliente = f.idCliente )
INNER JOIN Detalle d ON (f.nroTicket = d.nroTicket)
INNER JOIN Producto p ON (d.idProducto = p.idProducto)
WHERE c.nombre = "Jorge" AND c.apellido = "Pérez" AND f.nroTicket NOT IN (
    SELECT f2.nroTicket
    FROM Factura f2
    INNER JOIN Detalle d2 ON (f2.nroTicket = d2.nroTicket)
    INNER JOIN Producto p2 ON (d2.idProducto = p2.idProducto)
    WHERE p2.nombreP = "Z"
);

/*10. Listar DNI, apellido y nombre de clientes donde el monto total comprado, teniendo en cuenta
todas sus facturas, supere $10.000.000*/

SELECT c.DNI, c.apellido, c.nombre
FROM Cliente c
INNER JOIN Factura f ON (c.idCliente = f.idCliente)
GROUP BY c.DNI, c.apellido, c.nombre
HAVING SUM(f.total)>10000000;