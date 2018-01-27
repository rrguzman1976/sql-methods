use tsql2012;
go

if (object_id(N'dbo.SqlVariantExample',N'U') is not null) begin;
    drop table dbo.SqlVariantExample;
end;

create table dbo.SqlVariantExample 
(
    SqlVariantExampleID int identity(1,1) not null constraint PC_dbo_SqlVariantExample primary key clustered,
    ColumnVarchar50 varchar(50) null,
    ColumnSqlVariant sql_variant null
);

select
    c.column_id,
    c.name,
    type_name(c.system_type_id),
    type_name(c.user_type_id),
    c.max_length,
    c.precision,
    c.scale
from
    sys.columns c
where
    c.object_id = object_id(N'SqlVariantExample',N'U')
order by
    c.column_id;

insert dbo.SqlVariantExample (
    ColumnVarchar50,
    ColumnSqlVariant
) values 
    ('bit', cast(cast(0 as bit) as sql_variant)),
    ('binary(15)', cast(cast(newid() as binary(15)) as sql_variant)),
    ('bigint', cast(cast(-987654321 as bigint) as sql_variant)),
    ('char', cast(cast(N'CharDbaJonM' as char(11)) as sql_variant)),
    ('date', cast(CAST(SYSDATETIME() AS DATE) as sql_variant)),
    ('datetime', cast(getutcdate() as sql_variant)),
    ('datetime2', cast(cast(getutcdate() as datetime2) as sql_variant)),
    ('decimal(6,4)', cast(cast(6.5 as decimal(6,4)) as sql_variant)),
    ('float(15)', cast(cast(2552.987113 as float(15)) as sql_variant)),
    ('float(53)', cast(cast(2552.987113 as float(53)) as sql_variant)),
    ('int', cast(cast(3232323 as int) as sql_variant)),
    ('money', cast(cast($6.5 as money) as sql_variant)),
    ('null value in sql_variant', null),
    ('nchar', cast(cast(N'NcharDbaJonM' as nchar(12)) as sql_variant)),
    ('numeric(9,6)', cast(cast(6.5 as numeric(9,6)) as sql_variant)),
    ('nvarchar', cast(cast(N'nvarchar in sql_variant' as nvarchar(50)) as sql_variant)),
    ('smalldatetime', cast(cast(getutcdate() as smalldatetime) as sql_variant)),
    ('smallint', cast(cast(-2552 as smallint) as sql_variant)),
    ('smallmoney', cast(cast($16.5 as smallmoney) as sql_variant)),
    ('time', cast(cast(getutcdate() as time) as sql_variant)),
    ('tinyint', cast(cast(5 as tinyint) as sql_variant)),
    ('uniqueidentifier', cast(newid() as sql_variant)),
    ('varchar', cast(cast(N'varchar in sql_variant' as varchar(50)) as sql_variant)),
    ('varbinary(15)', cast(cast(0xff00009876 as varbinary(15)) as sql_variant))
    ;

-- image, nvarchar(max), text, varbinary(max), varchar(max), and xml are not valid for sql_variant

-- list the sql_variant properties based upon the underlying sql_variant value
select
    sve.SqlVariantExampleID,
    sve.ColumnVarchar50,
    sve.ColumnSqlVariant,
    sql_variant_property(sve.ColumnSqlVariant, 'BaseType') as SqlVariantProperty_BaseType,
    sql_variant_property(sve.ColumnSqlVariant, 'Precision') as SqlVariantProperty_Precision,
    sql_variant_property(sve.ColumnSqlVariant, 'Scale') as SqlVariantProperty_Scale,
    sql_variant_property(sve.ColumnSqlVariant, 'TotalBytes') as SqlVariantProperty_TotalBytes,
    sql_variant_property(sve.ColumnSqlVariant, 'Collation') as SqlVariantProperty_Collation,
    sql_variant_property(sve.ColumnSqlVariant, 'MaxLength') as SqlVariantProperty_MaxLength
from
    dbo.SqlVariantExample sve with (nolock);

-- the BOL entry states that the BaseType (and other properties) are sysname (or int, etc.).  In fact, they
-- all return sql_variant.  The commented out line below generates a conversion error.  The property must be
-- typecast before it can be reviewed.
select
    sve.SqlVariantExampleID,
    sve.ColumnVarchar50,
    sve.ColumnSqlVariant,
    case
--        when (sql_variant_property(sve.ColumnSqlVariant, 'BaseType') like '%binary%') then 'binary value'
        when (cast(sql_variant_property(sve.ColumnSqlVariant, 'BaseType') as sysname) like '%binary%') then 'binary value'
        else 'not binary'
        end as SqlVariantProperty_BaseType
from
    dbo.SqlVariantExample sve with (nolock);

-- SQL_VARIANT needs to be cast before being used.
select
    sve.SqlVariantExampleID,
    sve.ColumnVarchar50,
    sve.ColumnSqlVariant
	, EOMONTH(CAST(sve.ColumnSqlVariant AS DATE)) AS expr1
from
    dbo.SqlVariantExample sve with (nolock)
WHERE	sve.ColumnVarchar50 = 'date';

select
    sve.SqlVariantExampleID,
    sve.ColumnVarchar50,
    sve.ColumnSqlVariant
	, EOMONTH(CAST(sve.ColumnSqlVariant AS DATE)) AS expr1
from
    dbo.SqlVariantExample sve with (nolock)
WHERE	sve.ColumnVarchar50 = 'date'
		AND TRY_CAST(sve.ColumnSqlVariant AS DATE) = '20161201';