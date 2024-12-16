/*
Personas (dni, nombre, apellido, género, teléfono, email)
Médico (matricula, dni(FK), fechaIngreso)
Pacientes (dni(FK), fechaNacimiento, antecedentes)
Especialidad (idEspecialidad, nombreE, descripción)
MedicoEspecialidad (matrícula(FK), idEspecialidad(FK))
Atencion (nroAtencion, matrícula(FK), dni(FK), fecha, hora, motivo, diagnóstico?, tratamiento?)
// dni se refiere al DNI del paciente atendido

1. Listar matrícula, dni, nombre, apellido, teléfono y email
    de los médicos cuyo apellido sea "García".
2. Listar dni, nombre y apellido de aquellos pacientes
    que no recibieron atenciones durante 2024.
3. Listar dni, nombre y apellido de los pacientes atendidos
    por todos los médicos especializados en "Cardiología".
4. Listar para cada especialidad nombre y
    cantidad de médicos que se especializan en ella.
    Tenga en cuenta que puede haber especialidades que no
    tienen médicos especialistas.
5. Listar matrícula, dni, nombre y apellido del médico (o de los médicos)
    con más atenciones realizadas.
*/

SELECT m.matricula, p.dni, p.nombre, p.apellido, p.telefono, p.email
FROM Medico m
LEFT JOIN Persona p ON (m.dni = p.dni)
WHERE p.apellido = 'García';

SELECT pa.dni, pe.nombre, pe.apellido
FROM Paciente pa
LEFT JOIN Persona pe ON (pa.dni = pe.dni)
WHERE pa.dni NOT IN(
    SELECT a.dni
    FROM Atencion a
    WHERE a.fecha BETWEEN '2024-01-01' AND '2024-12-31'
);

SELECT pa.dni, pe.nombre, pe.apellido
FROM Paciente pa
INNER JOIN Persona pe ON (pa.dni = pe.dni)
WHERE NOT EXISTS(
    SELECT *
    FROM Medico m
    INNER JOIN MedicoEspecialidad me ON (m.matricula = me.matricula)
    INNER JOIN Especialidad e ON (me.idEspecialidad = e.idEspecialidad)
    WHERE e.nombreE = 'Cardiología' AND NOT EXISTS(
        SELECT *
        FROM Atencion a
        WHERE a.dni = pa.dni
            AND m.matricula = a.matricula
    )
)

SELECT e.nombreE, COUNT(DISTINCT me.matricula) as cantidadEspecialistas
FROM Especialidad e
LEFT JOIN MedicoEspecialidad me ON (e.idEspecialidad = me.idEspecialidad)
GROUP BY e.nombreE;

SELECT m.matricula pe.dni, pe.nombre, pe.apellido
FROM Medico m
INNER JOIN Persona pe ON (m.dni = pe.dni)
INNER JOIN Atencion a ON (m.matricula = a.matricula)
GROUP BY m.matricula, pe.dni, pe.nombre, pe.apellido
HAVING COUNT(a.nroAtencion) >= ALL(
    SELECT COUNT(a2.nroAtencion)
    FROM Atencion a2
    WHERE a2.matricula = m.matricula
    GROUP BY m.matricula
);