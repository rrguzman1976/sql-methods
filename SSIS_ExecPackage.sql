USE SSISDB;
GO

DECLARE @execution_id BIGINT;
DECLARE @use32bitruntime BIT = CAST(0 AS BIT);
DECLARE @logging_level INT = 1;
DECLARE @reference_id INT = NULL;

SELECT	@reference_id = reference_id
FROM	[catalog].environment_references
WHERE	environment_name = N'PROD';

SELECT	@reference_id AS [reference_id];

EXEC [catalog].create_execution
	@folder_name = N'QR_SSIS',
	@project_name = N'QR_SSIS',
	@package_name = N'MasterDW.dtsx',
	@use32bitruntime = @use32bitruntime,
	@reference_id = @reference_id,
	@execution_id = @execution_id OUTPUT;

SELECT	@execution_id AS [execution_id];

/*
EXEC [catalog].set_execution_parameter_value
	@execution_id,
	@object_type = 50,
	@parameter_name = N'LOGGING_LEVEL',
	@parameter_value = @logging_level;
*/
EXEC [catalog].start_execution
	@execution_id;
GO