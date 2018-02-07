USE ScratchDB;
GO

IF OBJECT_ID(N'dbo.Person', N'U') IS NOT NULL
	DROP TABLE dbo.Person;

IF OBJECT_ID(N'dbo.Restaurant', N'U') IS NOT NULL
	DROP TABLE dbo.Restaurant;

IF OBJECT_ID(N'dbo.City', N'U') IS NOT NULL
	DROP TABLE dbo.City;

IF OBJECT_ID(N'dbo.Likes', N'U') IS NOT NULL
	DROP TABLE dbo.Likes;
GO
IF OBJECT_ID(N'dbo.FriendOf', N'U') IS NOT NULL
	DROP TABLE dbo.FriendOf;
GO
IF OBJECT_ID(N'dbo.LivesIn', N'U') IS NOT NULL
	DROP TABLE dbo.LivesIn;
GO
IF OBJECT_ID(N'dbo.LocatedIn', N'U') IS NOT NULL
	DROP TABLE dbo.LocatedIn;
GO

CREATE TABLE dbo.Person
(
	ID		INT	IDENTITY(1, 1)	NOT NULL
	, Name	VARCHAR(100)		NULL
	, Age	INT					NULL
) 
AS NODE;
GO

ALTER TABLE dbo.Person
	ADD CONSTRAINT PK_PERSON_ID
		PRIMARY KEY (ID);
GO

CREATE TABLE dbo.Restaurant
(
	ID		INT IDENTITY(1, 1)	NOT NULL, 
	Name	VARCHAR(100)		NOT NULL, 
	City	VARCHAR(100)		NOT NULL
) 
AS NODE;
GO

ALTER TABLE dbo.Restaurant
	ADD CONSTRAINT PK_RESTAURANT_ID
		PRIMARY KEY (ID);
GO

CREATE TABLE dbo.City
(
	ID			INT	IDENTITY(1, 1)	NOT NULL, 
	Name		VARCHAR(100)		NOT NULL, 
	StateName	VARCHAR(100)		NOT NULL
) 
AS NODE;
GO

ALTER TABLE dbo.City
	ADD CONSTRAINT PK_CITY_ID
		PRIMARY KEY (ID);
GO

CREATE TABLE dbo.Likes
(
	ID			INT	IDENTITY(1, 1)	NOT NULL
	, Rating	INT					NOT NULL
) AS EDGE;
GO

CREATE TABLE dbo.FriendOf AS EDGE;
CREATE TABLE dbo.LivesIn AS EDGE;
CREATE TABLE dbo.LocatedIn AS EDGE;
GO

ALTER TABLE dbo.Likes
	ADD CONSTRAINT PK_LIKES_ID
		PRIMARY KEY (ID);
GO

CREATE UNIQUE NONCLUSTERED INDEX IX_LIKES_EDGE
	ON dbo.Likes ($from_id, $to_id);
GO
CREATE UNIQUE NONCLUSTERED INDEX IX_FRIENDOF_EDGE
	ON dbo.FriendOf ($from_id, $to_id);
GO
CREATE UNIQUE NONCLUSTERED INDEX IX_LIVESIN_EDGE
	ON dbo.LivesIn ($from_id, $to_id);
GO
CREATE UNIQUE NONCLUSTERED INDEX IX_LOCATEDIN_EDGE
	ON dbo.LocatedIn ($from_id, $to_id);
GO

INSERT INTO dbo.Person
VALUES ('Rick', 41)
		, ('Tony', 35)
		, ('Frank', 42)
		, ('Scott', 68)
		, ('Alice', 23);

INSERT INTO dbo.Restaurant VALUES ('Taco Dell','Bellevue');
INSERT INTO dbo.Restaurant VALUES ('Ginger and Spice','Seattle');
INSERT INTO dbo.Restaurant VALUES ('Noodle Land', 'Redmond');

INSERT INTO dbo.City VALUES ('Bellevue','wa');
INSERT INTO dbo.City VALUES ('Seattle','wa');
INSERT INTO dbo.City VALUES ('Redmond','wa');

-- Insert into edge table. While inserting into an edge table, 
-- you need to provide the $node_id from $from_id and $to_id columns.
INSERT INTO dbo.Likes 
VALUES ((SELECT $node_id FROM dbo.Person WHERE id = 1)
			, (SELECT $node_id FROM dbo.Restaurant WHERE id = 1)
			, 9)
		, ((SELECT $node_id FROM Person WHERE id = 2)
			, (SELECT $node_id FROM Restaurant WHERE id = 2)
			, 9)
		, ((SELECT $node_id FROM Person WHERE id = 3)
			, (SELECT $node_id FROM Restaurant WHERE id = 3)
			, 9)
		, ((SELECT $node_id FROM Person WHERE id = 4)
			, (SELECT $node_id FROM Restaurant WHERE id = 3)
			, 9)
		, ((SELECT $node_id FROM Person WHERE id = 5)
			, (SELECT $node_id FROM Restaurant WHERE id = 3)
			, 9);

INSERT INTO dbo.LivesIn 
VALUES ((SELECT $node_id FROM Person WHERE id = 1)
			, (SELECT $node_id FROM City WHERE id = 1))
		, ((SELECT $node_id FROM Person WHERE id = 2)
			, (SELECT $node_id FROM City WHERE id = 2))
		, ((SELECT $node_id FROM Person WHERE id = 3)
			, (SELECT $node_id FROM City WHERE id = 3))
		, ((SELECT $node_id FROM Person WHERE id = 4)
			, (SELECT $node_id FROM City WHERE id = 3))
		, ((SELECT $node_id FROM Person WHERE id = 5)
			, (SELECT $node_id FROM City WHERE id = 1));

INSERT INTO dbo.LocatedIn 
VALUES ((SELECT $node_id FROM Restaurant WHERE id = 1)
			, (SELECT $node_id FROM City WHERE id = 1))
		, ((SELECT $node_id FROM Restaurant WHERE id = 2)
			, (SELECT $node_id FROM City WHERE id =2))
		, ((SELECT $node_id FROM Restaurant WHERE id = 3)
			, (SELECT $node_id FROM City WHERE id =3));

-- Insert data into the friendof edge.
INSERT INTO dbo.FriendOf 
VALUES ((SELECT $NODE_ID FROM person WHERE ID = 1), (SELECT $NODE_ID FROM person WHERE ID = 2))
		, ((SELECT $NODE_ID FROM person WHERE ID = 2), (SELECT $NODE_ID FROM person WHERE ID = 3))
		, ((SELECT $NODE_ID FROM person WHERE ID = 3), (SELECT $NODE_ID FROM person WHERE ID = 1))
		, ((SELECT $NODE_ID FROM person WHERE ID = 4), (SELECT $NODE_ID FROM person WHERE ID = 2))
		, ((SELECT $NODE_ID FROM person WHERE ID = 5), (SELECT $NODE_ID FROM person WHERE ID = 4));

SELECT	'Person', $node_id, ID, Name, Age
FROM	dbo.Person;

SELECT	'Restaurant', *
FROM	dbo.Restaurant;

SELECT	'City', *
FROM	dbo.City;

SELECT	'Likes', *
FROM	dbo.Likes;

SELECT	'LivesIn', *
FROM	dbo.LivesIn;

SELECT	'LocatedIn', *
FROM	dbo.LocatedIn;

SELECT	'FriendOf', *
FROM	dbo.FriendOf;

-- Find Restaurants that John likes
SELECT	Restaurant.Name
FROM	dbo.Person AS p, dbo.Likes, dbo.Restaurant
WHERE	MATCH (p-(Likes)->Restaurant)
		AND p.Name = 'Rick';

-- Find Restaurants that Rick's friends like
SELECT	p1.Name, p2.Name, Restaurant.Name 
FROM	dbo.Person AS p1, dbo.Person AS p2, dbo.Likes, dbo.FriendOf, dbo.Restaurant
WHERE	MATCH(p1-(FriendOf)->p2-(Likes)->Restaurant)
		AND p1.Name = 'Rick';

-- Or
SELECT	p1.Name, p2.Name, Restaurant.Name 
FROM	dbo.Person AS p1, dbo.Person AS p2, dbo.Likes, dbo.FriendOf, dbo.Restaurant
WHERE	MATCH(p1-(FriendOf)->p2
			AND p2-(Likes)->Restaurant)
		AND p1.Name = 'Rick';

-- Find people who like a restaurant in the same city they live in
SELECT	p.Name, r.*, c.*
FROM	dbo.Person AS p, dbo.Likes, dbo.Restaurant AS r, dbo.LivesIn, dbo.City AS c, dbo.LocatedIn
WHERE	MATCH (p-(Likes)->r-(LocatedIn)->c AND p-(LivesIn)->c);

-- Or
SELECT	p.Name, r.*, c.*
FROM	dbo.Person AS p, dbo.Likes, dbo.Restaurant AS r, dbo.LivesIn, dbo.City AS c, dbo.LocatedIn
WHERE	MATCH (p-(Likes)->r
			AND r-(LocatedIn)->c 
			AND p-(LivesIn)->c);