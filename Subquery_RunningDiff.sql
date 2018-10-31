USE ScratchDB;
GO

select	empno
		, ename
		, sal
		, sum(case 
				when rn = 1 then sal 
				else -sal -- continue adding negative
			end)
			over (order by sal, empno) as running_diff
from (
	select	empno, ename, sal
			, row_number() over (order by sal, empno) as rn -- rank by salary
	from	emp
	where	deptno = 10
       ) x