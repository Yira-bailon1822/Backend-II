IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'e_commerce')
BEGIN
    CREATE DATABASE e_commerce;
END
GO

USE e_commerce;
GO

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL DEFAULT 'User',
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE ApiKeys (
    ApiKeyId INT IDENTITY(1,1) PRIMARY KEY,
    KeyName NVARCHAR(50) NOT NULL,
    KeyValue UNIQUEIDENTIFIER NOT NULL UNIQUE DEFAULT NEWID(),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    SKU NVARCHAR(50) NOT NULL UNIQUE,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    Price DECIMAL(18,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Orders (
    OrderId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(UserId),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending'
);

CREATE TABLE OrderDetails (
    OrderDetailId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderId),
    ProductId INT NOT NULL FOREIGN KEY REFERENCES Products(ProductId),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL
);
GO

INSERT INTO Users (Username, PasswordHash, Role) VALUES 
('admin_user', 'hash_simulado_123', 'Admin'),
('employee_01', 'hash_simulado_456', 'User');

INSERT INTO ApiKeys (KeyName, KeyValue) VALUES 
('ERP_Logistica', NEWID()),
('Proveedor_Webhooks', NEWID());

INSERT INTO Products (SKU, Name, Description, Price, StockQuantity) VALUES 
('LAP-001', 'Laptop Pro 15', 'Laptop alto rendimiento 15 pulgadas', 1200.00, 50),
('LAP-002', 'Laptop Basic 14', 'Laptop uso diario 14 pulgadas', 600.00, 100),
('MON-001', 'Monitor 4K 27', 'Monitor resolución 4K de 27 pulgadas', 350.00, 30);
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetAllActiveProducts]
    @method VARCHAR(100), 
    @isActive BIT = NULL,
    @SKU VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @method = 'Products'
    BEGIN
        IF @isActive IS NULL
        BEGIN
            SELECT '0' AS [code], 'No se ha especificado el parámetro isActive' AS [message];
            RETURN;
        END

        SELECT ProductId, SKU, Name, Description, Price, StockQuantity, '1' AS [code], 'Success' AS [message]
        FROM Products
        WHERE IsActive = @isActive
        ORDER BY Name ASC;
    END
END;
GO
