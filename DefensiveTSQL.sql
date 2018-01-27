USE TSQL2012;
GO

/*
 * Always use SET over SELECT for variable assignment as this protects against
 * multiple values or empty set errors.
 * Stored procedure calls with explicitly named parameters are more robust; 
 * they continue to work correctly even when the signature of the stored procedure 
 * changes, or they give explicit errors instead of silently returning incorrect 
 * results.
 * Always qualifying column names with aliases improves the robustness of our 
 * queries.
 */

/* Consider the case of an uncorrelated subquery that becomes correlated because 
 * a column from a table in the subquery is removed (or misspelled in the query), 
 * but happens to match a column in the outer query. Many developers forget that 
 * the parser will look in the outer query if it fails to find a match in the 
 * inner query.
 */

/*
 * NOT IN against a list with NULL is always NULL. IN is logically equivalent to
 * contatenated OR's.
 * Try to use NOT EXISTS in its stead as it is more robust.
 */
SELECT	CASE 
			WHEN 1 NOT IN ( 2, 3 ) THEN 'True' 
			ELSE 'Unknown or False' 
		END 
		, CASE 
			WHEN 1 NOT IN ( 2, 3, NULL ) THEN 'True' 
			ELSE 'Unknown or False' 
		END ;

/* 
 * In many cases, inline UDFs perform very well compared to scalar UDFs. Also,
 * equivalent queries without UDFs usually outperform both.
 * Be especially wary of using a multi-statement table-valued UDF in an APPLY, 
 * since that may force the optimizer to re-execute the UDF for each row in the 
 * table the UDF is applied against.
 */

 /*
  * You can use a unique, filtered constraint to limit a single unique lead
  * per team.
  */
IF OBJECT_ID(N'dbo.TeamMembers', N'U') IS NOT NULL
	DROP TABLE dbo.TeamMembers;
GO

CREATE TABLE dbo.TeamMembers 
( 
	TeamMemberID INT NOT NULL 
	, TeamID INT NOT NULL 
	, Name VARCHAR(50) NOT NULL 
	, IsTeamLead CHAR(1) NOT NULL 
	, CONSTRAINT PK_TeamMembers PRIMARY KEY ( TeamMemberID ) 
	, CONSTRAINT CHK_TeamMembers_IsTeamLead CHECK ( IsTeamLead IN ( 'Y', 'N' ) ) 
) ;

CREATE UNIQUE NONCLUSTERED INDEX TeamLeads 
	ON dbo.TeamMembers(TeamID) 
WHERE IsTeamLead='Y' ;

BEGIN TRAN;

-- Allowed
INSERT INTO dbo.TeamMembers ( TeamMemberID , TeamID , Name , IsTeamLead) 
SELECT 4 , 2 , 'Calvin Lee' , 'N' 
UNION ALL 
SELECT 5 , 2 , 'Jim Lee' , 'N' ;

-- Not Allowed
INSERT INTO dbo.TeamMembers ( TeamMemberID , TeamID , Name , IsTeamLead) 
SELECT 6 , 3 , 'Calvin Lee' , 'Y' 
UNION ALL 
SELECT 7 , 3 , 'Jim Lee' , 'Y' ;

SELECT 'dbo.TeamMembers' AS [PRE], * FROM dbo.TeamMembers;

IF @@TRANCOUNT > 0 ROLLBACK TRAN;

SELECT 'dbo.TeamMembers' AS [POST], * FROM dbo.TeamMembers;

SELECT	@@TRANCOUNT AS [@@TRANCOUNT];

/* 
 * NULLS: If a condition in a CHECK constraint evaluates to "unknown," then 
 * the row can still be inserted, but if a condition in a WHERE clause 
 * evaluates to "unknown," then the row will not be included in the result set.
 */

/*
 * Use of nullable columns in FOREIGN KEY constraints must be reserved only 
 * for the cases when it is acceptable to have rows in the child table without 
 * matching rows in the parent one.
 */

/*
 * Only when a constraint is trusted can we know for certain that all the data 
 * in the table is valid with respect to that constraint. An added advantage 
 * of trusted constraints is that they can be used by the optimizer when 
 * devising execution plans.
 */