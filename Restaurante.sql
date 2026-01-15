-- Creación de la base de datos Restaurante, 
CREATE DATABASE `Restaurante BdD`;
USE `Restaurante BdD`;

-- CLIENTE
CREATE TABLE Cliente (
  id_cliente        BIGINT NOT NULL AUTO_INCREMENT,
  tipo_doc          ENUM('CC','CE','NIT','PAS', 'TI') NOT NULL,
  num_doc           VARCHAR(30) NOT NULL,
  nombre            VARCHAR(80) NOT NULL,
  apellido          VARCHAR(80) NOT NULL,
  telefono          VARCHAR(15),
  email             VARCHAR(120),
  direccion         VARCHAR(150),
  fecha_registro    DATE NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (id_cliente),
  UNIQUE KEY UQ_cliente_num_doc (num_doc),
  UNIQUE KEY UQ_cliente_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- MESA
CREATE TABLE Mesa (
  id_mesa     INT NOT NULL AUTO_INCREMENT,
  numero      INT NOT NULL,
  capacidad   INT NOT NULL,
  ubicacion_mesa   VARCHAR(50),
  estado      ENUM('disponible','ocupada','reservada','fuera_de_servicio') NOT NULL,
  PRIMARY KEY (id_mesa),
  UNIQUE KEY UQ_mesa_numero (numero),
  CHECK (capacidad > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- RESERVA
CREATE TABLE Reserva (
  id_reserva   BIGINT NOT NULL AUTO_INCREMENT,
  id_cliente   BIGINT NOT NULL,
  fecha        DATE NOT NULL,	
  estado       ENUM('pendiente','confirmada','usada','cancelada') NOT NULL,
  notas_cl        VARCHAR(200),
  PRIMARY KEY (id_reserva),
  KEY IDX_reserva_cliente_fecha (id_cliente, fecha),
  CONSTRAINT FK_reserva_cliente FOREIGN KEY (id_cliente)
    REFERENCES Cliente(id_cliente)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- MESA_RESERVA (N:M)
CREATE TABLE Mesa_Reserva (
  id_reserva  BIGINT NOT NULL,
  id_mesa     INT    NOT NULL,
  PRIMARY KEY (id_reserva, id_mesa),
  CONSTRAINT FK_mr_reserva FOREIGN KEY (id_reserva)
    REFERENCES Reserva(id_reserva)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT FK_mr_mesa FOREIGN KEY (id_mesa)
    REFERENCES Mesa(id_mesa)
    ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- EMPLEADO
CREATE TABLE Empleado (
  id_empleado  BIGINT NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(80) NOT NULL,
  apellido     VARCHAR(80) NOT NULL,
  cargo        ENUM('mesero','cajero','chef','admin','supervisor') NOT NULL,
  telefono     VARCHAR(15),
  email_corp        VARCHAR(120),
  PRIMARY KEY (id_empleado),
  UNIQUE KEY UQ_empleado_email (email_corp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- PEDIDO
CREATE TABLE Pedido (
  id_pedido      BIGINT NOT NULL AUTO_INCREMENT,
  id_cliente     BIGINT NOT NULL,
  fecha_hora     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo_servicio  ENUM('mesa','llevar','domicilio','cocina') NOT NULL,
  estado         ENUM('abierto','preparado','facturado','cancelado') NOT NULL,
  id_reserva     BIGINT NULL,
  PRIMARY KEY (id_pedido),
  KEY IDX_pedido_cliente (id_cliente),
  KEY IDX_pedido_fecha (fecha_hora),
  CONSTRAINT FK_pedido_cliente FOREIGN KEY (id_cliente)
    REFERENCES Cliente(id_cliente)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT FK_pedido_reserva FOREIGN KEY (id_reserva)
    REFERENCES Reserva(id_reserva)
    ON UPDATE RESTRICT ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- EMPLEADO_PEDIDO
CREATE TABLE Empleado_Pedido (
  id_empleado  BIGINT NOT NULL,
  id_pedido    BIGINT NOT NULL,
  rol          ENUM('toma','entrega','prepara','cobra') NOT NULL,
  PRIMARY KEY (id_empleado, id_pedido, rol),
  CONSTRAINT FK_ep_empleado FOREIGN KEY (id_empleado)
    REFERENCES Empleado(id_empleado)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT FK_ep_pedido FOREIGN KEY (id_pedido)
    REFERENCES Pedido(id_pedido)
    ON UPDATE RESTRICT ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- CATEGORIA_PLATO
CREATE TABLE Categoria_Plato (
  id_categoria  INT NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(60) NOT NULL,
  descripcion   VARCHAR(150),
  PRIMARY KEY (id_categoria),
  UNIQUE KEY UQ_categoria_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- PLATO
CREATE TABLE Plato (
  id_plato       BIGINT NOT NULL AUTO_INCREMENT,
  id_categoria   INT NOT NULL,
  nombre         VARCHAR(100) NOT NULL,
  descripcion    VARCHAR(200),
  precio_vigente DECIMAL(10,2) NOT NULL,
  activo         TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_plato),
  UNIQUE KEY UQ_plato_nombre (nombre),
  CONSTRAINT FK_plato_categoria FOREIGN KEY (id_categoria)
    REFERENCES Categoria_Plato(id_categoria)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CHECK (precio_vigente >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- DETALLE_PEDIDO
CREATE TABLE Detalle_Pedido (
  id_pedido       BIGINT NOT NULL,
  id_plato        BIGINT NOT NULL,
  cantidad        INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_pedido, id_plato),
  CONSTRAINT FK_dp_pedido FOREIGN KEY (id_pedido)
    REFERENCES Pedido(id_pedido)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT FK_dp_plato FOREIGN KEY (id_plato)
    REFERENCES Plato(id_plato)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CHECK (cantidad > 0),
  CHECK (precio_unitario >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- FACTURA 
CREATE TABLE Factura (
  id_factura   BIGINT NOT NULL AUTO_INCREMENT,
  id_pedido    BIGINT NOT NULL,
  fecha_hora   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metodo_pago  ENUM('efectivo','tarjeta','transferencia','llave') NOT NULL,
  subtotal     DECIMAL(12,2) NOT NULL,
  impuestos    DECIMAL(12,2) NOT NULL,
  total        DECIMAL(12,2) NOT NULL,
  estado       ENUM('emitida','anulada') NOT NULL,
  PRIMARY KEY (id_factura),
  UNIQUE KEY UQ_factura_pedido (id_pedido),
  KEY IDX_factura_fecha (fecha_hora),
  CONSTRAINT FK_factura_pedido FOREIGN KEY (id_pedido)
    REFERENCES Pedido(id_pedido)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CHECK (subtotal >= 0),
  CHECK (impuestos >= 0),
  CHECK (total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- RESENA (usamos 'Resena' sin ñ por compatibilidad)
CREATE TABLE Resena (
  id_resena   BIGINT NOT NULL AUTO_INCREMENT,
  id_cliente  BIGINT NOT NULL,
  id_plato    BIGINT NULL,
  id_pedido   BIGINT NULL,
  calificacion TINYINT NOT NULL,
  comentario  VARCHAR(300),
  fecha       DATE NOT NULL DEFAULT (CURRENT_DATE),
  PRIMARY KEY (id_resena),
  KEY IDX_resena_cliente (id_cliente),
  CONSTRAINT FK_resena_cliente FOREIGN KEY (id_cliente)
    REFERENCES Cliente(id_cliente)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT FK_resena_plato FOREIGN KEY (id_plato)
    REFERENCES Plato(id_plato)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  CONSTRAINT FK_resena_pedido FOREIGN KEY (id_pedido)
    REFERENCES Pedido(id_pedido)
    ON UPDATE RESTRICT ON DELETE SET NULL,
  CHECK (calificacion BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- PROVEEDOR
CREATE TABLE Proveedor (
  id_proveedor       BIGINT NOT NULL AUTO_INCREMENT,
  razon_social       VARCHAR(120) NOT NULL,
  nit                VARCHAR(30) NOT NULL,
  nombre_contacto    VARCHAR(100),
  telefono_contacto  VARCHAR(15),
  email_contacto     VARCHAR(120),
  direccion          VARCHAR(150),
  PRIMARY KEY (id_proveedor),
  UNIQUE KEY UQ_proveedor_nit (nit),
  UNIQUE KEY UQ_proveedor_email (email_contacto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- INGREDIENTE
CREATE TABLE Ingrediente (
  id_ingrediente  BIGINT NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(100) NOT NULL,
  unidad_medida   ENUM('g','kg','ml','l','und') NOT NULL,
  PRIMARY KEY (id_ingrediente),
  UNIQUE KEY UQ_ingrediente_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- INVENTARIO (una fila por ingrediente)
CREATE TABLE Inventario (
  id_inventario   BIGINT NOT NULL AUTO_INCREMENT,
  id_ingrediente  BIGINT NOT NULL,
  stock_actual    DECIMAL(12,3) NOT NULL,
  stock_minimo    DECIMAL(12,3) NOT NULL,
  PRIMARY KEY (id_inventario),
  UNIQUE KEY UQ_inventario_ingrediente (id_ingrediente),
  CONSTRAINT FK_inventario_ingrediente FOREIGN KEY (id_ingrediente)
    REFERENCES Ingrediente(id_ingrediente)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CHECK (stock_actual >= 0),
  CHECK (stock_minimo >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- COMPRA (encabezado)
CREATE TABLE Compra (
  id_compra     BIGINT NOT NULL AUTO_INCREMENT,
  id_proveedor  BIGINT NOT NULL,
  fecha         DATE NOT NULL,
  total         DECIMAL(12,2) NOT NULL,
  PRIMARY KEY (id_compra),
  KEY IDX_compra_fecha (fecha),
  CONSTRAINT FK_compra_proveedor FOREIGN KEY (id_proveedor)
    REFERENCES Proveedor(id_proveedor)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CHECK (total >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- DETALLE_COMPRA
CREATE TABLE Detalle_Compra (
  id_compra      BIGINT NOT NULL,
  id_ingrediente BIGINT NOT NULL,
  cantidad       DECIMAL(12,3) NOT NULL,
  costo_unitario DECIMAL(12,3) NOT NULL,
  PRIMARY KEY (id_compra, id_ingrediente),
  CONSTRAINT FK_dc_compra FOREIGN KEY (id_compra)
    REFERENCES Compra(id_compra)
    ON UPDATE RESTRICT ON DELETE CASCADE,
  CONSTRAINT FK_dc_ingrediente FOREIGN KEY (id_ingrediente)
    REFERENCES Ingrediente(id_ingrediente)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CHECK (cantidad > 0),
  CHECK (costo_unitario >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- SE AGREGAN LOS DATOS

-- CLIENTE
INSERT INTO Cliente (tipo_doc, num_doc, nombre, apellido, telefono, email, direccion, fecha_registro) VALUES
('CC','1012345678','Juan','Pérez','3001234567','juan.perez@gmail.com','Cra 10 #20-30','2025-09-01'),
('CC','1023456789','María','González','3012345678','maria.gonzalez@gmail.com','Cll 45 #12-18','2025-09-02'),
('TI','1034567890','Carlos','Ramírez','3023456789','carlos.ramirez@gmail.com','Cra 50 #30-25','2025-09-05'),
('CC','1045678901','Ana','López','3034567890','ana.lopez@gmail.com','Cll 70 #45-10','2025-09-07'),
('CC','1056789012','Sebastián','Ruiz','3045678901','sebastian.ruiz@gmail.com','Cra 25 #15-40','2025-09-10'),
('CC','1067890123','Isabella','Martínez','3056789012','isabella.martinez@gmail.com','Cll 33 #22-55','2025-09-12');
INSERT INTO Cliente (tipo_doc, num_doc, nombre, apellido, telefono, email, direccion, fecha_registro) VALUES
('CC','1025804566','Samuel','Lopez','3114552341','samuellop@gmail.com','calle 20 #30a-21','2025-11-09'),
('CC','430589343','Andres','Jaramillo','3023456789','andresjaramillo@gmail.com','Cra 40b #45-54','2025-11-09'),
('TI','1035706466','Juan Andres','Lopez','304325671','juandres@gmail.com','Cra 31a #40-12','2025-11-09'),
('CC','1062345399','Sofia','Villamizar','3804567891','sofiavilla@gmail.com','calle 81 #12a-31','2025-11-09');

-- MESA
INSERT INTO Mesa (numero, capacidad, ubicacion_mesa, estado) VALUES
(1,4,'Sala','disponible'),
(2,2,'Sala','disponible'),
(3,4,'Terraza','reservada'),
(4,6,'Sala','ocupada'),
(5,2,'Barra','disponible'),
(6,4,'Terraza','fuera_de_servicio');
-- terminar de agregar los 10 datos
INSERT INTO Mesa (numero, capacidad, ubicacion_mesa, estado) VALUES
(7,4,'Sala','ocupada'),
(8,4,'Terraza','disponible'),
(9,2,'Sala','disponible'),
(10,6,'Terraza','disponible');

-- RESERVA
INSERT INTO Reserva (id_cliente, fecha, estado, notas_cl) VALUES
(1,'2025-10-06','confirmada','Cumpleaños Juan'),
(2,'2025-10-06','pendiente','Mesa cerca a ventana'),
(3,'2025-10-07','usada','Llegó 15 min antes'),
(4,'2025-10-07','confirmada','Con un bebé'),
(5,'2025-10-08','cancelada','Canceló por lluvia'),
(6,'2025-10-08','pendiente','Aniversario');
-- terminar de ingresar los 10 registros
SELECT id_cliente, nombre, apellido FROM cliente; -- ver cual es el número del cliente ingresado

INSERT INTO Reserva (id_cliente, fecha, estado, notas_cl) VALUES
(47,'2025-11-20','confirmada','cumpleaños isabella'),
(48,'2025-12-30','cancelada','cancelada por situaciones externas'),
(49,'2026-01-24','pendiente','cumpleaños de ana'),
(50,'2026-01-13','confirmada','Cita para pedida de matrimonio');

SELECT id_reserva, id_cliente, fecha, estado
FROM Reserva;

SELECT id_mesa
from mesa;

-- MESA_RESERVA
INSERT INTO Mesa_Reserva (id_reserva, id_mesa) VALUES
(36,3),
(35,1),
(28,4),
(33,2),
(34,5),
(26,6),
(27,17),
(25,18),
(24,19),
(23,20);

-- EMPLEADO
INSERT INTO Empleado (nombre, apellido, cargo, telefono, email_corp) VALUES
('Luis','Gómez','mesero','3101112222','luis.gomez@gmail.com'),
('Antonia','Castaño','mesero','3102223333','antonia.castano@gmail.com'),
('Jorge','Zapata','chef','3103334444','jorge.zapata@gmail.com'),
('Paula','Mejía','cajero','3104445555','paula.mejia@gmail.com'),
('Diego','Soto','admin','3105556666','diego.soto@gmail.com'),
('Camila','Herrera','supervisor','3106667777','camila.herrera@gmail.com');

INSERT INTO Empleado (nombre, apellido, cargo, telefono, email_corp) VALUES
('Daniel','Castillo','chef','3141102431','danielcasta@gmail.com'),
('Juan Pablo','Manilla','mesero','3056778231','juanpabloherre@gmail.com'),
('Samantha','Montoya','chef','3023456782','samamontoya@gmail.com'),
('Daniela','Castro','chef','3203446123','danielacastro@gmail.com');

SELECT id_reserva, id_cliente, fecha, estado
FROM reserva;
-- PEDIDO
INSERT INTO Pedido (id_cliente, fecha_hora, tipo_servicio, estado, id_reserva) VALUES
(1,'2025-10-06 12:15:00','llevar','facturado',5),
(2,'2025-10-06 13:00:00','mesa','preparado',6),
(3,'2025-10-07 19:05:00','mesa','facturado',7),
(4,'2025-10-07 20:10:00','llevar','abierto',NULL),
(5,'2025-10-08 18:45:00','domicilio','cancelado',NULL),
(6,'2025-10-08 21:00:00','mesa','abierto',10),
(47,'2025-10-08 18:00:00','llevar','abierto',15),
(48,'2025-10-08 18:10:00','domicilio','abierto',16),
(49,'2025-10-08 18:00:00','domicilio','abierto',17),
(50,'2025-10-08 18:00:00','mesa','abierto',18);

SELECT id_empleado, nombre, apellido
FROM empleado;
SELECT id_pedido
from pedido;

-- EMPLEADO_PEDIDO
INSERT INTO Empleado_Pedido (id_empleado, id_pedido, rol) VALUES
(1,21,'toma'), 
(2,22,'prepara'),
(4,23,'cobra'),
(3,24,'toma'),
(5,27,'prepara'),
(6,30,'toma'), 
(7,28,'prepara'), 
(8,29,'cobra'),
(9,26,'toma'),
(10,25,'toma');

-- CATEGORIA_PLATO
INSERT INTO Categoria_Plato (nombre, descripcion) VALUES
('Hamburguesas','Clásicas y especiales'),
('Típicos','Platos típicos colombianos'),
('Pizzas','Horneadas'),
('Arepas','Rellenas y tradicionales'),
('Acompañamientos','Para compartir'),
('Bebidas','Gaseosas y jugos');
INSERT INTO categoria_plato (nombre, descripcion) VALUES
('Postres', 'postres tipicos'),
('licores', 'bedidas alcolicas para acompañar la comida'),
('Pastas', 'la mejor pasta italiana preparada artesanalmente'),
('Entrada', 'para antes de que llegue el fuerte');

-- PLATO
INSERT INTO Plato (id_categoria, nombre, descripcion, precio_vigente, activo) VALUES
(1,'Hamburguesa Clásica','Carne 150g, queso, lechuga, tomate',22000,1),
(2,'Bandeja Paisa','Frijoles, arroz, carne, chorizo, huevo, arepa',32000,1),
(3,'Pizza Margarita','Queso mozzarella, albahaca, tomate',28000,1),
(4,'Arepa Rellena','Arepa de maíz con queso y hogao',12000,1),
(5,'Salchipapas','Porción mediana',9000,1),
(6,'Gaseosa 400ml','Bebida embotellada',6000,1);
INSERT INTO Plato (id_categoria, nombre, descripcion, precio_vigente, activo) VALUES
(7,'turamisu','postre de tiramisu a base de cafe y galleta y queso crema',10000,1),
(8,'cerveza','corona',6000,1),
(9,'Raviolis','en salga, alfredo o pesto',27000,1),
(10,'Ceviche de chicharron','Ceviche de chicharron para compartir',24000,1);

select 	id_pedido
from pedido;
-- DETALLE_PEDIDO 
INSERT INTO Detalle_Pedido (id_pedido, id_plato, cantidad, precio_unitario) VALUES
(21,1,2,22000.00),
(21,5,1,9000.00), 
(21,6,2,6000.00),
(22,3,1,28000.00),
(22,6,2,6000.00),
(23,2,1,32000.00),
(23,4,2,12000.00),
(24,1,1,22000.00),
(25,3,1,28000.00),
(26,4,3,12000.00);

-- FACTURA 
INSERT INTO Factura (id_pedido, fecha_hora, metodo_pago, subtotal, impuestos, total, estado) VALUES
(21,'2025-10-06 12:40:00','tarjeta',   22000*2 + 9000 + 6000*2, 0.19*(22000*2 + 9000 + 6000*2), (22000*2 + 9000 + 6000*2)*1.19,'emitida'),
(23,'2025-10-07 19:45:00','efectivo',  32000 + 12000*2,         0.19*(32000 + 12000*2),         (32000 + 12000*2)*1.19,'emitida'),
(22,'2025-10-06 13:30:00','tarjeta',   28000 + 6000*2,          0.19*(28000 + 6000*2),          (28000 + 6000*2)*1.19,'emitida'),
(24,'2025-10-07 20:30:00','transferencia',22000,                0.19*22000,                      22000*1.19,'emitida'),
(25,'2025-10-08 19:10:00','llave',     28000,                   0.19*28000,                      28000*1.19,'anulada'),
(26,'2025-10-08 21:40:00','efectivo',  12000*3,                 0.19*(12000*3),                  (12000*3)*1.19,'emitida');

-- RESEÑA
select id_plato, nombre, id_pedido
from plato, pedido;

INSERT INTO Resena (id_cliente, id_plato, id_pedido, calificacion, comentario, fecha) VALUES
(1,1,28,5,'Deliciosaaa la hamburguesa','2025-10-06'),
(2,3,null,4,'La pizza muy buena, masa delgada','2025-10-06'),
(3,2,30,5,'La bandeja paisa estuvo re rica','2025-10-07'),
(4,NULL,28,4,'Buen servicio','2025-10-07'),
(5,3,29,2,'Pedido cancelado, estuvo muy maluca','2025-10-08'),
(6,4,23,5,'Arepas top, muy recomendadas, ahh si','2025-10-08');
INSERT INTO Resena (id_cliente, id_plato, id_pedido, calificacion, comentario, fecha) VALUES
(47,10,25,5,'muy rico el ceviche es un poco picante','2025-11-01'),
(48,9,24,5,'rico el relleno pero un poco dura la pasta','2025-10-30'),
(49,7,22,5,'delicioso el turamisu muy cremoso','2025-11-09'),
(50,8,29,5,'llego caliente a la mesa','2025-11-05');


-- PROVEEDOR 
INSERT INTO Proveedor (razon_social, nit, nombre_contacto, telefono_contacto, email_contacto, direccion) VALUES
('Arepitas SAS','900123001-1','Marta Ríos','3201111111','contacto@arepitas.co','Cra 1 #10-20'),
('Choricitos SA','800456002-2','Óscar Vélez','3202222222','ventas@choricitos.com','Cll 22 #34-10'),
('Frijolito LTD','700789003-3','Lina Torres','3203333333','info@frijolito.co','Cra 50 #45-15'),
('PanBurgers SAS','901234004-4','Ricardo Hoyos','3204444444','comercial@panburgers.co','Cll 70 #12-08'),
('Quesitos SA','802345005-5','Sandra Quintero','3205555555','contacto@quesitos.com','Cra 33 #55-21'),
('Salsitas Ltda','703456006-6','Andrés Cano','3206666666','ventas@salsitas.co','Cll 18 #9-77');
INSERT INTO Proveedor (razon_social, nit, nombre_contacto, telefono_contacto, email_contacto, direccion) VALUES
('Carniceria lola','183451682-3','Andrea Naranjo','3053667145','carnelola@carne.co','Cra 18 #15-20'),
('fruver','564321863-4','Isabella Lopez','3112345791','verdurasconfruver@fruver.co','Calle 14 #12a-19'),
('creme helado','100004536-7','Marta Velez','3008567431','martacream@cremehelado.co','Cra 30 #20-667'),
('issabell','800008531-9','Margarita Lopez','3124668132','especiesmarga@issabell.co','Cra 16 #44-67');



-- INGREDIENTE 
INSERT INTO Ingrediente (nombre, unidad_medida) VALUES
('Carne molida res','kg'),
('Frijol cargamanto','kg'),
('Harina de maíz','kg'),
('Queso mozzarella','kg'),
('Pan hamburguesa','und'),
('Salsa de tomate','ml'),
('Chicharron','kg'),
('Platano','und'),
('queso crema','ml'),
('cerveza', 'und');

-- INVENTARIO

INSERT INTO Inventario (id_ingrediente, stock_actual, stock_minimo) VALUES
(1,25.000,5.000),
(2,30.000,6.000),
(3,40.000,10.000),
(4,18.000,4.000),
(5,200.000,50.000),
(6,15000.000,3000.000),
(7,50.000,3000.000),
(8,20.000,10000.000),
(9,100.000,5000.000),
(10,15.000,3000.000);


-- COMPRA 
INSERT INTO Compra (id_proveedor, fecha, total) VALUES
(1,'2025-09-28', 850000.00),
(2,'2025-09-29', 520000.00),
(3,'2025-10-01', 600000.00),
(4,'2025-10-02', 300000.00),
(5,'2025-10-03', 450000.00),
(6,'2025-10-04', 200000.00);
INSERT INTO Compra (id_proveedor, fecha, total) VALUES
(7,'2025-10-06', 2000000.00),
(8,'2025-10-06', 550000.00),
(9,'2025-10-09', 800000.00),
(10,'2025-10-10', 350000.00);

-- DETALLE_COMPRA
INSERT INTO Detalle_Compra (id_compra, id_ingrediente, cantidad, costo_unitario) VALUES
-- Arepitas (harina de maíz, arepas requieren harina)
(1,3,100.000,3000.000),
-- Choricitos (no hay chorizo como ingrediente directo; asumimos carne molida para hamburguesa)
(2,1,80.000,4500.000),
-- Frijolito (frijol para bandeja paisa)
(3,2,120.000,2500.000),
-- PanBurgers (pan hamburguesa en unidades)
(4,5,500.000,400.000),
-- Quesitos (mozzarella)
(5,4,60.000,5000.000),
-- Salsitas (salsa de tomate en ml)
(6,6,20000.000,10.000),
-- chicharron (kg)
(7,7,100,14.000),
-- platano
(8,8,70,3.000),
-- queso crema
(9,9,20,5.000),
-- cerveza
(10,10,250,6.000);

delimiter $$
create procedure insertar_cliente (
	in p_tipo_doc ENUM('CC','CE','NIT','PAS','TI'),
	IN p_num_doc    VARCHAR(30),
    IN p_nombre     VARCHAR(80),
    IN p_apellido   VARCHAR(80),
    IN p_telefono   VARCHAR(15),
    IN p_email      VARCHAR(120),
    IN p_direccion  VARCHAR(150)
    )
    begin
    insert into Cliente(
    tipo_doc, num_doc, nombre, apellido, telefono, email, direccion, fecha_registro
    ) values( 
    p_tipo_doc, p_num_doc, p_nombre, p_apellido, p_telefono, p_email, p_direccion, CURRENT_DATE
    );
    end$$
    delimiter ;
    
 DELIMITER $$
DROP PROCEDURE IF EXISTS insertar_cliente $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insertar_cliente (
    IN p_tipo_doc   ENUM('CC','CE','NIT','PAS','TI'),
    IN p_num_doc    VARCHAR(30),
    IN p_nombre     VARCHAR(80),
    IN p_apellido   VARCHAR(80),
    IN p_telefono   VARCHAR(15),
    IN p_email      VARCHAR(120),
    IN p_direccion  VARCHAR(150)
)
BEGIN
    INSERT INTO Cliente (
        tipo_doc, num_doc, nombre, apellido, telefono, email, direccion, fecha_registro
    ) VALUES (
        p_tipo_doc, p_num_doc, p_nombre, p_apellido, p_telefono, p_email, p_direccion, CURRENT_DATE
    );
END$$
DELIMITER ;

CALL insertar_cliente(
    'CC',
    '1034589123',
    'Santiago',
    'Zapata',
    '3109876543',
    'santiago@gmail.com',
    'Cra 45 #20-30'
);

  
  -- delimiter de eliminado en donde elimina una reserva 
  DELIMITER $$
CREATE PROCEDURE sp_eliminar_reserva (
    IN p_id_reserva BIGINT
)
BEGIN
    DELETE FROM Reserva
    WHERE id_reserva = p_id_reserva;
END$$
DELIMITER ;

-- llamado
CALL sp_eliminar_reserva(5);


-- consulta con el parametro in aplicado en los pedidos de un cliente 
DELIMITER $$
CREATE PROCEDURE sp_pedidos_por_cliente (
    IN p_id_cliente BIGINT
)
BEGIN
    SELECT 
        p.id_pedido,
        p.fecha_hora,
        p.tipo_servicio,
        p.estado,
        p.id_reserva
    FROM Pedido p
    WHERE p.id_cliente = p_id_cliente
    ORDER BY p.fecha_hora;
END$$
DELIMITER ;

CALL sp_pedidos_por_cliente(3);

-- consulta con in y out sobre cuántos pedidos tiene un cliente
DELIMITER $$
CREATE PROCEDURE contar_pedidos_cliente (
    IN  p_id_cliente BIGINT,
    OUT p_total_pedidos INT
)
BEGIN
    SELECT COUNT(*)
    INTO p_total_pedidos
    FROM Pedido
    WHERE id_cliente = p_id_cliente;
END$$
DELIMITER ;

SET @total := 0;
CALL contar_pedidos_cliente(1, @total);
SELECT @total;

-- insertar un pedido 
DELIMITER $$
CREATE PROCEDURE insertar_pedido (
    IN p_id_cliente   BIGINT,
    IN p_tipo_servicio ENUM('mesa','llevar','domicilio','cocina'),
    IN p_estado        ENUM('abierto','preparado','facturado','cancelado'),
    IN p_id_reserva    BIGINT
)
BEGIN
    INSERT INTO Pedido (id_cliente, fecha_hora, tipo_servicio, estado, id_reserva)
    VALUES (p_id_cliente, CURRENT_TIMESTAMP, p_tipo_servicio, p_estado, p_id_reserva);
END$$
DELIMITER ;	
-- llamado 
CALL insertar_pedido(1, 'mesa', 'abierto', NULL);

-- triggers
-- trigger de insercion
-- se activa despues de que se inserte una nueva fila en la tabla factura y se actualiza de forma automatica el estado de la reserva poniendo "confirmada"
DELIMITER $$
CREATE TRIGGER tr_insertar_factura -- nombre del trigger
AFTER INSERT ON Factura
FOR EACH ROW
BEGIN
    -- Obtener el id_reserva del pedido asociado con la factura
    DECLARE t_id_reserva BIGINT;
-- asociamos el id_reserva desde la tabla pedido donde id_pedido recien insertado en factura
    SELECT id_reserva INTO t_id_reserva
    FROM Pedido
    WHERE id_pedido = NEW.id_pedido;
    
    -- Actualizar el estado de la reserva relacionada
    UPDATE reserva
    SET estado = 'confirmada'
    WHERE id_reserva = t_id_reserva;
END$$
DELIMITER ;

-- trigger de actualizacion 
DELIMITER $$
CREATE TRIGGER tr_actualizar_estado_pedido
AFTER UPDATE ON Pedido
FOR EACH ROW
BEGIN
    IF NEW.estado = 'cancelado' THEN
        UPDATE Reserva
        SET estado = 'cancelada'
        WHERE id_reserva = NEW.id_reserva;
    END IF;
END$$
DELIMITER ;

-- trigger de borrado 
DELIMITER $$
CREATE TRIGGER trg_borrar_reserva
AFTER DELETE ON Reserva
FOR EACH ROW
BEGIN
    DELETE FROM Mesa_Reserva
    WHERE id_reserva = OLD.id_reserva;
END$$
DELIMITER ;

-- trigger antes
DELIMITER $$
CREATE TRIGGER trg_before_insert_pedido
BEFORE INSERT ON Pedido
FOR EACH ROW
BEGIN
    IF NEW.tipo_servicio = 'domicilio' THEN
        SET NEW.id_reserva = NULL;
    END IF;
END$$
DELIMITER ;


-- trigger desde de la accion 

DELIMITER $$
CREATE TRIGGER tr_after_insert_plato
AFTER INSERT ON Plato
FOR EACH ROW
BEGIN
    DECLARE v_ingrediente_id BIGINT;
    DECLARE v_cantidad DECIMAL(12,3);
    
    -- Obtener ingredientes del plato (suponiendo que tienes una tabla de relación)
    SELECT id_ingrediente, cantidad
    INTO v_ingrediente_id, v_cantidad
    FROM Plato_Ingrediente
    WHERE id_plato = NEW.id_plato;
    
    -- Actualizar el inventario
    UPDATE Inventario
    SET stock_actual = stock_actual - v_cantidad
    WHERE id_ingrediente = v_ingrediente_id;
END$$
DELIMITER ;

select id_plato,comentario from resena where calificacion >=4 and fecha < '2025-10-08' limit 3;

select * from pedido where estado in ('facturado','preparado') ;

select * from resena where comentario like '%deliciosa%' or comentario like '%rica%' or comentario like '%buena%';

select e.nombre,ep.* from empleado_pedido as ep join empleado as e on e.id_empleado= ep.id_empleado;
select count(*) as total_empleados from empleado;





