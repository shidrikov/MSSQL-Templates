
-- Column values to line

DECLARE @result NVARCHAR(MAX);

SELECT @result = COALESCE(@result + ', ', '') + [PaymentMethodName]
FROM [$(WWI)].[Application].[PaymentMethods];

SELECT @result;