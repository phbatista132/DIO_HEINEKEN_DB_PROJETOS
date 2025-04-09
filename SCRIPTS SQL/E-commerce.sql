-- Criação do banco de dados
CREATE DATABASE ecommerce;
USE ecommerce;

-- Criação da tabela Cliente
CREATE TABLE Clients (
    idClient INT AUTO_INCREMENT PRIMARY KEY,
    Fname VARCHAR(13) NOT NULL,
    Minit VARCHAR(3),
    Lname VARCHAR(10),
    AccountType ENUM('CPF', 'CNPJ') NOT NULL,
    DocumentNumber VARCHAR(14) NOT NULL,
    Address VARCHAR(45),
    Birthdate DATE,
    CONSTRAINT unique_document_num UNIQUE (DocumentNumber)
);
-- Criação da tabela Fornecedor
CREATE TABLE Supplier (
    idSupplier INT AUTO_INCREMENT PRIMARY KEY,
    Razao_social VARCHAR(45) NOT NULL,
    CNPJ VARCHAR(18) NOT NULL,
	Contact CHAR(11),
    CONSTRAINT unique_cnpj_supplier UNIQUE (CNPJ)
);

-- Tabela terceiros
CREATE TABLE ThirdPartySeller (
    idThirdSeller INT AUTO_INCREMENT PRIMARY KEY, 
    CNPJ CHAR(14) NOT NULL,
    BusinessName VARCHAR(45) NOT NULL,
    Location VARCHAR(45),
    CONSTRAINT unique_cnpj_seller UNIQUE (CNPJ)
);

-- Criação da tabela Estoque
CREATE TABLE Stock (
    idStock INT AUTO_INCREMENT PRIMARY KEY,
    Quantity INT,
    Address VARCHAR(45)
);

-- Criação da tabela Produto
CREATE TABLE Product (
    idProduct INT AUTO_INCREMENT PRIMARY KEY,
    Pname VARCHAR(20),
    Category ENUM('Eletronicos', 'Vestuario', 'Alimentos', 'Jardinagem') NOT NULL,
    Price FLOAT NOT NULL,
    Avaluation FLOAT DEFAULT 0
);

-- Criação da tabela Pedido
CREATE TABLE Orders (
    idOrder INT AUTO_INCREMENT PRIMARY KEY,
    OrderStatus ENUM('Cancelado', 'Confirmado', 'Processando') DEFAULT 'Processando',
    OrdDescription VARCHAR(200),
    idOrderClient INT NOT NULL,
    CONSTRAINT fk_order_client FOREIGN KEY (idOrderClient) REFERENCES Clients(idClient)
    );
    
-- Criação da tabela Pagamento
CREATE TABLE Payment(
	idPayment INT AUTO_INCREMENT PRIMARY KEY,
    Total_value FLOAT,
    Status_Pay ENUM('Confirmado','Em Processamento','Cancelado') DEFAULT 'Em Processamento',
    Dt_Payment DATE,
    Freight_value FLOAT,
    idOrderPay INT NOT NULL,
    CONSTRAINT fk_payment_order FOREIGN KEY (idOrderPay) REFERENCES Orders(idOrder)
		ON DELETE CASCADE 				ON UPDATE CASCADE
);

CREATE TABLE PaymentMethods (
    idPaymentMethod INT AUTO_INCREMENT PRIMARY KEY,
    idPayment INT NOT NULL,
    Mtd_Payment ENUM('Debito', 'Credito', 'Boleto') NOT NULL,
    CONSTRAINT fk_payment_method FOREIGN KEY (idPayment) REFERENCES Payment(idPayment) ON DELETE CASCADE
);


-- criação da tabela frete
CREATE TABLE Freight(
	idFreight INT AUTO_INCREMENT PRIMARY KEY,
    Mtd_freight ENUM('Comum','Expresso') DEFAULT 'Comum',
    Distance FLOAT NOT NULL,
    Freight_value FLOAT NOT NULL,
	idOrdfreight INT NOT NULL,
    CONSTRAINT Distance_chk CHECK (Distance > 0),
    CONSTRAINT fk_freight_ord FOREIGN KEY (idOrdfreight) REFERENCES Orders(idOrder)
);

-- Criação da tabela entrega
CREATE TABLE Delivery(
	idDelivery INT PRIMARY KEY,
    Status_Delivery ENUM('A caminho','Entregue','Postado','Em processamento') DEFAULT 'Em processamento',
    TrackingCode VARCHAR(10) UNIQUE,
    Postdate DATE,
    Deliverydate DATE,
    idFreight INT NOT NULL,
    Clients_id INT NOT NULL,
	CONSTRAINT Dt_check_delivery CHECK (Deliverydate >= Postdate),
    CONSTRAINT fk_clientsid_clients FOREIGN KEY (Clients_id) REFERENCES Clients(idClient) ON UPDATE CASCADE,
    CONSTRAINT fk_freight_delivery FOREIGN KEY (idFreight) REFERENCES Freight(idFreight) 
);

-- Relacionamentos n:m
-- Realação pedido produto
CREATE TABLE Ord_product(
	idProduct INT,
    idOrder INT,
    Qtd INT CHECK (Qtd > 0),
    PRIMARY KEY (idProduct, idOrder),
    CONSTRAINT fk_ord_product FOREIGN KEY (idProduct) REFERENCES Product(idProduct),
    CONSTRAINT fk_product_ord FOREIGN KEY (idOrder) REFERENCES Orders(idOrder)
);

-- Relação produto por fornecedor
CREATE TABLE Product_Supplies (
    idSupplier INT NOT NULL,
    idProduct INT NOT NULL,
    QuantitySupplied INT NOT NULL,
    PRIMARY KEY (idSupplier, idProduct),
    CONSTRAINT fk_supplier_product FOREIGN KEY (idSupplier) REFERENCES Supplier(idSupplier),
    CONSTRAINT fk_product_supplier FOREIGN KEY (idProduct) REFERENCES Product(idProduct)
);

CREATE TABLE Product_seller (
    idThirdSeller INT,
    idProduct INT,
    QuantitySellers INT NOT NULL,
    PRIMARY KEY (idThirdSeller, idProduct),
    CONSTRAINT fk_seller_product FOREIGN KEY (idThirdSeller) REFERENCES ThirdPartySeller(idThirdSeller),
    CONSTRAINT fk_product_seller FOREIGN KEY (idProduct) REFERENCES Product(idProduct)
);

-- Relação produto por estoque
CREATE TABLE Product_Stock (
    idProduct INT,
    idStock INT,
    Quantity INT NOT NULL,
    PRIMARY KEY (idProduct, idStock),
    CONSTRAINT fk_product_stock FOREIGN KEY (idProduct) REFERENCES Product(idProduct),
    CONSTRAINT fk_stock_product FOREIGN KEY (idStock) REFERENCES Stock(idStock)
);


SELECT concat(c.Fname,' ',c.Lname) as Complete_name, count(*) as Total_Order
FROM Clients c INNER JOIN Orders o ON o.idOrderClient = c.idClient
GROUP BY Complete_name;


SELECT sum(Total_value) AS Soma_total_mes, MONTH(Dt_Payment) AS mes 
FROM Payment
GROUP BY mes
ORDER BY mes;



SELECT round(avg(Total_value),2) AS Media_ano, YEAR(Dt_Payment) AS ano
FROM Payment
GROUP BY ano
ORDER BY ano;

SELECT p.idProduct, p.Pname, s.Razao_social, ps.QuantitySupplied
	FROM Product_Supplies AS ps
		JOIN Product AS p ON ps.idProduct = p.idProduct
		JOIN Supplier AS s ON ps.idSupplier = s.idSupplier
ORDER BY 
    p.idProduct;


SELECT o.idOrder, o.OrderStatus, o.OrdDescription, concat(Fname,' ', Lname) as nome, COUNT(op.idProduct) AS Qtd_Produtos
	FROM Orders as o INNER JOIN  Clients as C ON idOrderClient = idClient
		LEFT JOIN Ord_product AS op ON o.idOrder = op.idOrder
		GROUP BY o.idOrder, o.OrderStatus, o.OrdDescription, nome
        HAVING nome = 'Carlos Silva';