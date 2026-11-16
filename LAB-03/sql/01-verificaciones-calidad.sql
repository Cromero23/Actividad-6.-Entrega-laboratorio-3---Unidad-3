
-- ============================================================
-- LAB-03: Politicas practicas, gobierno de datos y evidencias
-- Actividad 1: Calidad de datos desde la operacion
-- Base: comercial
-- Motor: PostgreSQL 16
-- Fecha: 16 de noviembre de 2026
-- ============================================================
--
-- INSERT INTO public.clientes
-- (nombre, correo, telefono, rfc, edad, ciudad, codigo_postal)
-- VALUES
-- ('Ana Lopez', '[CORREO_REDACTADO]',
--  '6671234567', 'LOAA850315AB', 41, 'Culiacan', '80000'),
-- ('Jorge Díaz', 'sin-correo',
--  '667', NULL, -3, 'Culiacán', '8000');


-- 1. Posibles duplicados por correo electronico
SELECT
    lower(correo) AS correo_normalizado,
    count(*) AS registros,
    string_agg(id::text, ', ') AS ids
FROM public.clientes
GROUP BY lower(correo)
HAVING count(*) > 1;

-- Resultado observado:
-- [CORREO_REDACTADO] | 2 | 1, 7


-- 2. RFC con formato incorrecto o ausente
SELECT id, nombre, rfc
FROM public.clientes
WHERE rfc IS NULL
   OR rfc !~ '^[A-ZÑ&]{3,4}[0-9]{6}[A-Z0-9]{3}$';

-- Resultado observado:
-- 7 | Ana Lopez  | LOAA850315AB
-- 8 | Jorge Díaz | NULL


-- 3. Correo electronico con formato incorrecto
SELECT id, nombre, correo
FROM public.clientes
WHERE correo !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$';

-- Resultado observado:
-- 8 | Jorge Díaz | sin-correo


-- 4. Edad fuera del rango permitido
SELECT id, nombre, edad
FROM public.clientes
WHERE edad IS NOT NULL
  AND (edad < 18 OR edad > 120);

-- Resultado observado:
-- 8 | Jorge Díaz | -3


-- 5. Completitud de la informacion
SELECT
    count(*) AS total,
    count(*) FILTER (WHERE telefono IS NULL) AS sin_telefono,
    count(*) FILTER (WHERE rfc IS NULL) AS sin_rfc
FROM public.clientes;

-- Resultado observado:
-- total = 7
-- sin_telefono = 0
-- sin_rfc = 1


-- ============================================================
-- CONCLUSION
-- ============================================================
-- Se identificaron problemas de unicidad, formato,
-- completitud y validez de datos.
--
-- No se modificaron ni eliminaron registros durante
-- las verificaciones.
--
-- La correccion debe ser aprobada por el propietario
-- de los datos, Gerencia Comercial.
-- ============================================================
