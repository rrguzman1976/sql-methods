USE ScratchDB;
GO

-- Use translate to replace multiple characters at once - instead of
-- nested REPLACE calls.
SELECT	[data]
		, translate(E.data, '0123456789', '##########') AS data2
		-- Remove char
		, replace(data,
	       replace(
			translate(E.data,'0123456789','##########'),'#',''),'') nums
		-- Remove num
		, replace(
			translate(E.data,'0123456789','##########'),'#','') chars
FROM	(
	select	CONCAT(ename,' ',deptno) as data
	from	emp) AS E
order by replace(translate(E.data,'0123456789','##########'),'#','')