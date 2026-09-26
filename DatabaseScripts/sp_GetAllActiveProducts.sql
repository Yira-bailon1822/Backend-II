SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_GetAllActiveProducts]
    @method VARCHAR(100), 
    @isActive BIT = NULL,
    @SKU VARCHAR(50) = NULL,
    @KeyValue UNIQUEIDENTIFIER = NULL,
    @UserId INT = NULL,
    @ProductId INT = NULL,
    @Quantity INT = NULL,
    @Username NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @method = 'Products'
    BEGIN
        IF @isActive IS NULL
        BEGIN
            SELECT '0' AS 'code', 'No se ha especificado el parámetro isActive' AS 'message'
            RETURN
        END

        SELECT ProductId, SKU, Name, Description, Price, StockQuantity,
               '1' AS 'code', 'Success' AS 'message'
        FROM Products
        WHERE IsActive = @isActive
        ORDER BY Name ASC;
    END

    IF @method = 'GetProductBySKU'
    BEGIN
        IF @SKU IS NULL
        BEGIN
            SELECT '0' AS 'code', 'No se ha especificado el parámetro SKU' AS 'message'
            RETURN
        END

        SELECT @isActive = IsActive FROM Products WHERE SKU = @SKU

        IF @isActive = 0
        BEGIN
            SELECT '0' AS 'code', 'El producto ya no se encuentra activo' AS 'message'
            RETURN
        END

        SELECT ProductId, SKU, Name, Description, Price, StockQuantity,
               '1' AS 'code', 'Success' AS 'message'
        FROM Products
        WHERE SKU = @SKU AND IsActive = 1
        ORDER BY Name ASC;
    END

    IF @method = 'ValidateApiKey'
    BEGIN
        IF @KeyValue IS NULL
        BEGIN
            SELECT '0' AS 'code', 'No se ha especificado el parámetro KeyValue' AS 'message'
            RETURN
        END

        IF EXISTS (SELECT 1 FROM ApiKeys WHERE KeyValue = @KeyValue AND IsActive = 1)
        BEGIN
            SELECT 
                KeyName,
                '1' AS 'code',
                'Success' AS 'message'
            FROM ApiKeys
            WHERE KeyValue = @KeyValue AND IsActive = 1
        END
        ELSE
        BEGIN
            SELECT
                '0' AS 'code',
                'La API Key no es válida o no está activa' AS 'message'
        END
    END

    IF @method = 'CreateOrder'
    BEGIN
        IF @UserId IS NULL OR @ProductId IS NULL OR @Quantity IS NULL
        BEGIN
            SELECT '0' AS 'code', 'Faltan parámetros para crear la orden' AS 'message'
            RETURN
        END

        DECLARE @CurrentStock INT;
        DECLARE @UnitPrice DECIMAL(18,2);
        DECLARE @TotalAmount DECIMAL(18,2);
        DECLARE @NewOrderId INT;

        SELECT 
            @CurrentStock = StockQuantity, 
            @UnitPrice = Price
        FROM Products
        WHERE ProductId = @ProductId AND IsActive = 1;

        IF @CurrentStock IS NULL OR @CurrentStock < @Quantity
        BEGIN
            SELECT
                '0' AS 'code',
                'Stock insuficiente o producto inactivo' AS 'message'
            RETURN
        END

        SET @TotalAmount = @UnitPrice * @Quantity;

        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO Orders (UserId, TotalAmount, Status, OrderDate)
            VALUES (@UserId, @TotalAmount, 'Completed', GETDATE());

            SET @NewOrderId = SCOPE_IDENTITY();

            INSERT INTO OrderDetails (OrderId, ProductId, Quantity, UnitPrice)
            VALUES (@NewOrderId, @ProductId, @Quantity, @UnitPrice);

            UPDATE Products
            SET StockQuantity = StockQuantity - @Quantity
            WHERE ProductId = @ProductId;

            COMMIT TRANSACTION;

            SELECT
                @NewOrderId AS 'OrderId',
                '1' AS 'code',
                'Orden creada con éxito' AS 'message'
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;

            SELECT
                '0' AS 'code',
                ERROR_MESSAGE() AS 'message'
        END CATCH
    END

    IF @method = 'GetUserForLogin'
    BEGIN
        IF @Username IS NULL
        BEGIN
            SELECT '0' AS 'code', 'No se ha especificado el parámetro Username' AS 'message'
            RETURN
        END

        IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username)
        BEGIN
            SELECT 
                UserId, 
                PasswordHash, 
                Role,
                '1' AS 'code',
                'Success' AS 'message'
            FROM Users
            WHERE Username = @Username
        END
        ELSE
        BEGIN
            SELECT
                '0' AS 'code',
                'Usuario no encontrado' AS 'message'
        END
    END

END;
GO
