-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 28-04-2025 a las 22:28:29
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `intitucion educativa`
--

DELIMITER $$
--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `obtener_nombre_completo` (`id` INT) RETURNS VARCHAR(511) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC BEGIN
  DECLARE nombre_completo VARCHAR(511);
  
  SELECT CONCAT(nombre, ' ', apellido) 
  INTO nombre_completo
  FROM Usuarios
  WHERE id_usuario = id;
  
  RETURN nombre_completo;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `areasinstitucion`
--

CREATE TABLE `areasinstitucion` (
  `id_area` int(11) NOT NULL,
  `nombre_area` varchar(255) DEFAULT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `areasinstitucion`
--

INSERT INTO `areasinstitucion` (`id_area`, `nombre_area`, `descripcion`) VALUES
(1, 'Laboratorio de Computación', 'Área destinada a equipos de computación'),
(2, 'Biblioteca', 'Área destinada a libros y recursos académicos'),
(3, 'Sala de Conferencias', 'Área destinada a eventos y conferencias'),
(4, 'Taller de Electrónica', 'Área destinada a prácticas de electrónica'),
(5, 'Oficinas Administrativas', 'Área destinada a personal administrativo');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `usuario_afectado` int(11) DEFAULT NULL,
  `operacion` enum('insert','update','delete') DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_operacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `usuario_realiza_operacion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria`
--

INSERT INTO `auditoria` (`id_auditoria`, `usuario_afectado`, `operacion`, `descripcion`, `fecha_operacion`, `usuario_realiza_operacion`) VALUES
(1, 1, 'insert', 'Usuario registrado', '2025-04-28 20:17:14', NULL),
(2, 2, 'update', 'Usuario actualizado', '2025-04-28 20:17:14', NULL),
(3, 3, 'delete', 'Usuario eliminado', '2025-04-28 20:17:14', NULL),
(4, 4, 'insert', 'Usuario registrado', '2025-04-28 20:17:14', NULL),
(5, 5, 'update', 'Usuario actualizado', '2025-04-28 20:17:14', NULL);

--
-- Disparadores `auditoria`
--
DELIMITER $$
CREATE TRIGGER `trg_login_bloqueo` AFTER INSERT ON `auditoria` FOR EACH ROW BEGIN
  -- PRIMERO se declaran las variables
  DECLARE intentos INT;

  -- Luego ya puedes usar SELECT, IF, etc.
  IF (NEW.operacion = 'login_failed') THEN

    SELECT COUNT(*)
    INTO intentos
    FROM Auditoria
    WHERE usuario_afectado = NEW.usuario_afectado
      AND operacion = 'login_failed'
      AND TIMESTAMPDIFF(MINUTE, fecha_operacion, NOW()) <= 3;

    IF (intentos >= 3) THEN
      INSERT INTO UsuariosBloqueados (id_usuario, razon_bloqueo, fecha_bloqueo)
      VALUES (NEW.usuario_afectado, 'Exceso de intentos fallidos', NOW());
    END IF;

  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cursos`
--

CREATE TABLE `cursos` (
  `id_curso` int(11) NOT NULL,
  `nombre_curso` varchar(255) DEFAULT NULL,
  `id_programa` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cursos`
--

INSERT INTO `cursos` (`id_curso`, `nombre_curso`, `id_programa`) VALUES
(1, 'Programación Básica', 1),
(2, 'Gestión Empresarial', 2),
(3, 'Análisis Financiero', 3),
(4, 'Circuitos Electrónicos', 4),
(5, 'Metodología de la Investigación', 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `docentecurso`
--

CREATE TABLE `docentecurso` (
  `id_docente_curso` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `docentecurso`
--

INSERT INTO `docentecurso` (`id_docente_curso`, `id_usuario`, `id_curso`) VALUES
(1, 2, 1),
(2, 5, 2),
(3, 2, 3),
(4, 5, 4),
(5, 2, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipostecnologicos`
--

CREATE TABLE `equipostecnologicos` (
  `id_equipo` int(11) NOT NULL,
  `nombre_equipo` varchar(255) DEFAULT NULL,
  `marca` varchar(255) DEFAULT NULL,
  `modelo` varchar(255) DEFAULT NULL,
  `numero_serie` varchar(255) DEFAULT NULL,
  `id_area` int(11) DEFAULT NULL,
  `estado` enum('operativo','en_reparacion','dado_de_baja') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `equipostecnologicos`
--

INSERT INTO `equipostecnologicos` (`id_equipo`, `nombre_equipo`, `marca`, `modelo`, `numero_serie`, `id_area`, `estado`) VALUES
(1, 'Computadora', 'Dell', 'Inspiron 15', 'ABC123', 1, 'operativo'),
(2, 'Proyector', 'Epson', 'X123', 'DEF456', 3, 'operativo'),
(3, 'Impresora', 'HP', 'LaserJet', 'GHI789', 2, 'en_reparacion'),
(4, 'Osciloscopio', 'Tektronix', 'TBS1052B', 'JKL012', 4, 'operativo'),
(5, 'Servidor', 'Lenovo', 'ThinkSystem', 'MNO345', 1, 'dado_de_baja');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eventos`
--

CREATE TABLE `eventos` (
  `id_evento` int(11) NOT NULL,
  `titulo_evento` varchar(255) DEFAULT NULL,
  `descripcion_evento` text DEFAULT NULL,
  `fecha_evento` date DEFAULT NULL,
  `lugar_evento` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `eventos`
--

INSERT INTO `eventos` (`id_evento`, `titulo_evento`, `descripcion_evento`, `fecha_evento`, `lugar_evento`) VALUES
(1, 'Conferencia de Tecnología', 'Evento sobre avances tecnológicos', '2023-02-15', 'Sala de Conferencias'),
(2, 'Feria de Libros', 'Exposición de libros académicos', '2023-03-10', 'Biblioteca'),
(3, 'Taller de Programación', 'Capacitación en programación básica', '2023-04-20', 'Laboratorio de Computación'),
(4, 'Seminario de Finanzas', 'Discusión sobre estrategias financieras', '2023-05-25', 'Sala de Conferencias'),
(5, 'Exposición de Proyectos', 'Presentación de proyectos estudiantiles', '2023-06-30', 'Taller de Electrónica');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inscripciones`
--

CREATE TABLE `inscripciones` (
  `id_inscripcion` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `fecha_inscripcion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inscripciones`
--

INSERT INTO `inscripciones` (`id_inscripcion`, `id_usuario`, `id_curso`, `fecha_inscripcion`) VALUES
(1, 1, 1, '2023-01-15'),
(2, 4, 1, '2023-01-16'),
(3, 1, 2, '2023-01-17'),
(4, 4, 3, '2023-01-18'),
(5, 1, 4, '2023-01-19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `notas`
--

CREATE TABLE `notas` (
  `id_nota` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `id_curso` int(11) DEFAULT NULL,
  `nota` decimal(5,2) DEFAULT NULL,
  `periodo` enum('primer','segundo','tercer','cuarto') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `notas`
--

INSERT INTO `notas` (`id_nota`, `id_usuario`, `id_curso`, `nota`, `periodo`) VALUES
(1, 1, 1, 4.50, 'primer'),
(2, 4, 1, 3.80, 'segundo'),
(3, 1, 2, 4.20, 'tercer'),
(4, 4, 3, 3.90, 'cuarto'),
(5, 1, 4, 4.70, 'primer');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personaladministrativo`
--

CREATE TABLE `personaladministrativo` (
  `id_personal` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `cargo` varchar(255) DEFAULT NULL,
  `dependencia` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `personaladministrativo`
--

INSERT INTO `personaladministrativo` (`id_personal`, `id_usuario`, `cargo`, `dependencia`) VALUES
(1, 3, 'Secretario', 'Oficinas Administrativas'),
(2, 5, 'Coordinador', 'Biblioteca'),
(3, 2, 'Director', 'Sala de Conferencias'),
(4, 4, 'Asistente', 'Laboratorio de Computación'),
(5, 1, 'Técnico', 'Taller de Electrónica');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `programas`
--

CREATE TABLE `programas` (
  `id_programa` int(11) NOT NULL,
  `nombre_programa` varchar(255) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `nivel` enum('pregrado','posgrado','tecnico') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `programas`
--

INSERT INTO `programas` (`id_programa`, `nombre_programa`, `descripcion`, `nivel`) VALUES
(1, 'Ingeniería de Sistemas', 'Programa de pregrado en ingeniería de sistemas', 'pregrado'),
(2, 'Administración de Empresas', 'Programa de pregrado en administración', 'pregrado'),
(3, 'Especialización en Finanzas', 'Programa de posgrado en finanzas', 'posgrado'),
(4, 'Técnico en Electrónica', 'Programa técnico en electrónica', 'tecnico'),
(5, 'Maestría en Educación', 'Programa de posgrado en educación', 'posgrado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(255) DEFAULT NULL,
  `apellido` varchar(255) DEFAULT NULL,
  `documento_identidad` varchar(255) DEFAULT NULL,
  `tipo_usuario` enum('estudiante','docente','administrativo') DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `estado` enum('activo','inactivo') DEFAULT NULL,
  `fecha_registro` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `apellido`, `documento_identidad`, `tipo_usuario`, `email`, `telefono`, `direccion`, `estado`, `fecha_registro`) VALUES
(1, 'Juan', 'Perez', '123456789', 'estudiante', 'juan.perez@example.com', '1234567890', 'Calle 123', 'activo', '2025-04-28 20:13:09'),
(2, 'Maria', 'Gomez', '987654321', 'docente', 'maria.gomez@example.com', '0987654321', 'Calle 456', 'activo', '2025-04-28 20:13:09'),
(3, 'Carlos', 'Lopez', '456789123', 'administrativo', 'carlos.lopez@example.com', '4567891230', 'Calle 789', 'inactivo', '2025-04-28 20:13:09'),
(4, 'Ana', 'Martinez', '321654987', 'estudiante', 'ana.martinez@example.com', '3216549870', 'Calle 321', 'activo', '2025-04-28 20:13:09'),
(5, 'Luis', 'Hernandez', '654987321', 'docente', 'luis.hernandez@example.com', '6549873210', 'Calle 654', 'activo', '2025-04-28 20:13:09');

--
-- Disparadores `usuarios`
--
DELIMITER $$
CREATE TRIGGER `trg_usuarios_delete` AFTER DELETE ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO Auditoria (usuario_afectado, operacion, descripcion, fecha_operacion, usuario_realiza_operacion)
  VALUES (OLD.id_usuario, 'delete', 'Usuario eliminado', NOW(), NULL);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_usuarios_insert` AFTER INSERT ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO Auditoria (usuario_afectado, operacion, descripcion, fecha_operacion, usuario_realiza_operacion)
  VALUES (NEW.id_usuario, 'insert', 'Usuario registrado', NOW(), NULL);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_usuarios_update` AFTER UPDATE ON `usuarios` FOR EACH ROW BEGIN
  INSERT INTO Auditoria (usuario_afectado, operacion, descripcion, fecha_operacion, usuario_realiza_operacion)
  VALUES (NEW.id_usuario, 'update', 'Usuario actualizado', NOW(), NULL);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuariosbloqueados`
--

CREATE TABLE `usuariosbloqueados` (
  `id_bloqueo` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `razon_bloqueo` text DEFAULT NULL,
  `fecha_bloqueo` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuariosbloqueados`
--

INSERT INTO `usuariosbloqueados` (`id_bloqueo`, `id_usuario`, `razon_bloqueo`, `fecha_bloqueo`) VALUES
(1, 3, 'Intentos fallidos de inicio de sesión', '2025-04-28 20:16:26'),
(2, 4, 'Incumplimiento de normas', '2025-04-28 20:16:26'),
(3, 1, 'Acceso no autorizado', '2025-04-28 20:16:26'),
(4, 2, 'Uso indebido de recursos', '2025-04-28 20:16:26'),
(5, 5, 'Comportamiento inapropiado', '2025-04-28 20:16:26');

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_auditoria`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_auditoria` (
`id_auditoria` int(11)
,`usuario_afectado` int(11)
,`operacion` enum('insert','update','delete')
,`descripcion` text
,`fecha_operacion` timestamp
,`usuario_realiza_operacion` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_equipos_por_area`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_equipos_por_area` (
`id_equipo` int(11)
,`nombre_equipo` varchar(255)
,`marca` varchar(255)
,`modelo` varchar(255)
,`nombre_area` varchar(255)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_estudiantes_activos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_estudiantes_activos` (
`id_usuario` int(11)
,`nombre` varchar(255)
,`apellido` varchar(255)
,`documento_identidad` varchar(255)
,`tipo_usuario` enum('estudiante','docente','administrativo')
,`email` varchar(255)
,`telefono` varchar(255)
,`direccion` varchar(255)
,`estado` enum('activo','inactivo')
,`fecha_registro` timestamp
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_inscripciones`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_inscripciones` (
`id_inscripcion` int(11)
,`nombre` varchar(255)
,`apellido` varchar(255)
,`nombre_curso` varchar(255)
,`fecha_inscripcion` date
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_usuarios_bloqueados`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_usuarios_bloqueados` (
`id_bloqueo` int(11)
,`nombre` varchar(255)
,`apellido` varchar(255)
,`razon_bloqueo` text
,`fecha_bloqueo` timestamp
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_auditoria`
--
DROP TABLE IF EXISTS `vista_auditoria`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_auditoria`  AS SELECT `auditoria`.`id_auditoria` AS `id_auditoria`, `auditoria`.`usuario_afectado` AS `usuario_afectado`, `auditoria`.`operacion` AS `operacion`, `auditoria`.`descripcion` AS `descripcion`, `auditoria`.`fecha_operacion` AS `fecha_operacion`, `auditoria`.`usuario_realiza_operacion` AS `usuario_realiza_operacion` FROM `auditoria` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_equipos_por_area`
--
DROP TABLE IF EXISTS `vista_equipos_por_area`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_equipos_por_area`  AS SELECT `e`.`id_equipo` AS `id_equipo`, `e`.`nombre_equipo` AS `nombre_equipo`, `e`.`marca` AS `marca`, `e`.`modelo` AS `modelo`, `a`.`nombre_area` AS `nombre_area` FROM (`equipostecnologicos` `e` join `areasinstitucion` `a` on(`e`.`id_area` = `a`.`id_area`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_estudiantes_activos`
--
DROP TABLE IF EXISTS `vista_estudiantes_activos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_estudiantes_activos`  AS SELECT `usuarios`.`id_usuario` AS `id_usuario`, `usuarios`.`nombre` AS `nombre`, `usuarios`.`apellido` AS `apellido`, `usuarios`.`documento_identidad` AS `documento_identidad`, `usuarios`.`tipo_usuario` AS `tipo_usuario`, `usuarios`.`email` AS `email`, `usuarios`.`telefono` AS `telefono`, `usuarios`.`direccion` AS `direccion`, `usuarios`.`estado` AS `estado`, `usuarios`.`fecha_registro` AS `fecha_registro` FROM `usuarios` WHERE `usuarios`.`tipo_usuario` = 'estudiante' AND `usuarios`.`estado` = 'activo' ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_inscripciones`
--
DROP TABLE IF EXISTS `vista_inscripciones`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inscripciones`  AS SELECT `i`.`id_inscripcion` AS `id_inscripcion`, `u`.`nombre` AS `nombre`, `u`.`apellido` AS `apellido`, `c`.`nombre_curso` AS `nombre_curso`, `i`.`fecha_inscripcion` AS `fecha_inscripcion` FROM ((`inscripciones` `i` join `usuarios` `u` on(`i`.`id_usuario` = `u`.`id_usuario`)) join `cursos` `c` on(`i`.`id_curso` = `c`.`id_curso`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_usuarios_bloqueados`
--
DROP TABLE IF EXISTS `vista_usuarios_bloqueados`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_usuarios_bloqueados`  AS SELECT `ub`.`id_bloqueo` AS `id_bloqueo`, `u`.`nombre` AS `nombre`, `u`.`apellido` AS `apellido`, `ub`.`razon_bloqueo` AS `razon_bloqueo`, `ub`.`fecha_bloqueo` AS `fecha_bloqueo` FROM (`usuariosbloqueados` `ub` join `usuarios` `u` on(`ub`.`id_usuario` = `u`.`id_usuario`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `areasinstitucion`
--
ALTER TABLE `areasinstitucion`
  ADD PRIMARY KEY (`id_area`);

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `usuario_afectado` (`usuario_afectado`),
  ADD KEY `usuario_realiza_operacion` (`usuario_realiza_operacion`);

--
-- Indices de la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD PRIMARY KEY (`id_curso`),
  ADD KEY `id_programa` (`id_programa`);

--
-- Indices de la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  ADD PRIMARY KEY (`id_docente_curso`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `equipostecnologicos`
--
ALTER TABLE `equipostecnologicos`
  ADD PRIMARY KEY (`id_equipo`),
  ADD KEY `id_area` (`id_area`);

--
-- Indices de la tabla `eventos`
--
ALTER TABLE `eventos`
  ADD PRIMARY KEY (`id_evento`);

--
-- Indices de la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD PRIMARY KEY (`id_inscripcion`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `notas`
--
ALTER TABLE `notas`
  ADD PRIMARY KEY (`id_nota`),
  ADD KEY `id_usuario` (`id_usuario`),
  ADD KEY `id_curso` (`id_curso`);

--
-- Indices de la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  ADD PRIMARY KEY (`id_personal`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Indices de la tabla `programas`
--
ALTER TABLE `programas`
  ADD PRIMARY KEY (`id_programa`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`);

--
-- Indices de la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  ADD PRIMARY KEY (`id_bloqueo`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD CONSTRAINT `auditoria_ibfk_1` FOREIGN KEY (`usuario_afectado`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `auditoria_ibfk_2` FOREIGN KEY (`usuario_realiza_operacion`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `cursos`
--
ALTER TABLE `cursos`
  ADD CONSTRAINT `cursos_ibfk_1` FOREIGN KEY (`id_programa`) REFERENCES `programas` (`id_programa`);

--
-- Filtros para la tabla `docentecurso`
--
ALTER TABLE `docentecurso`
  ADD CONSTRAINT `docentecurso_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `docentecurso_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `equipostecnologicos`
--
ALTER TABLE `equipostecnologicos`
  ADD CONSTRAINT `equipostecnologicos_ibfk_1` FOREIGN KEY (`id_area`) REFERENCES `areasinstitucion` (`id_area`);

--
-- Filtros para la tabla `inscripciones`
--
ALTER TABLE `inscripciones`
  ADD CONSTRAINT `inscripciones_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `inscripciones_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `notas`
--
ALTER TABLE `notas`
  ADD CONSTRAINT `notas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  ADD CONSTRAINT `notas_ibfk_2` FOREIGN KEY (`id_curso`) REFERENCES `cursos` (`id_curso`);

--
-- Filtros para la tabla `personaladministrativo`
--
ALTER TABLE `personaladministrativo`
  ADD CONSTRAINT `personaladministrativo_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `usuariosbloqueados`
--
ALTER TABLE `usuariosbloqueados`
  ADD CONSTRAINT `usuariosbloqueados_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`);

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `desbloquear_usuarios` ON SCHEDULE EVERY 1 MINUTE STARTS '2025-04-28 15:20:03' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM UsuariosBloqueados
  WHERE TIMESTAMPDIFF(MINUTE, fecha_bloqueo, NOW()) >= 3$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
