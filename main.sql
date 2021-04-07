-- EX1
-- script
CREATE TABLE parts
(
    partno      VARCHAR(4) PRIMARY KEY,
    description VARCHAR(15) NOT NULL,
    qonhand     NUMERIC(5) DEFAULT 0
        CONSTRAINT ChkOnHandQty CHECK (qonhand >= 0),
    qonorder    NUMERIC(5) DEFAULT 0,
    CONSTRAINT ChkOnOrderQty CHECK (qonhand = 0 OR qonorder <= qonhand * 2)
);

INSERT INTO parts
VALUES ('P207', 'Gear', 75, 20);
INSERT INTO parts
VALUES ('P209', 'Cam', 0, 10);
INSERT INTO parts
VALUES ('P221', 'Big Bolt', 650, 200);
INSERT INTO parts
VALUES ('P222', 'Small Bolt', 1250, 0);
INSERT INTO parts
VALUES ('P231', 'Big Nut', 0, 200);
INSERT INTO parts
VALUES ('P232', 'Small Nut', 1100, 0);
INSERT INTO parts
VALUES ('P250', 'Big Gear', 5, 3);
INSERT INTO parts
VALUES ('P285', 'WheelBelt', 350, 0);
INSERT INTO parts
VALUES ('P295', 'Belt', 0, 25);

COMMIT;

create or replace function nbParts()
    returns integer as
$$
DECLARE
    n integer;
BEGIN
    select count(*) into n from parts;

    if (n) > 6
    then
        raise exception 'nombre (%) > 6' , n;
    end if;

    return n;
END;

$$ LANGUAGE plpgsql;

select nbParts();


-- EX2

-- script
CREATE TABLE EMP
(
    EMPNO    NUMERIC(4) PRIMARY KEY,
    ENAME    VARCHAR(10),
    JOB      VARCHAR(9),
    MGR      NUMERIC(4),
    HIREDATE DATE,
    SAL      NUMERIC(6, 2),
    COMM     NUMERIC(6, 2),
    DEPTNO   NUMERIC(2)
);

INSERT INTO EMP
VALUES (7369, 'SMITH', 'CLERK', 7902, '12/17/1980', 800, NULL, 20);
INSERT INTO EMP
VALUES (7499, 'ALLEN', 'SALESMAN', 7698, '02/20/1981', 1600, 300, 30);
INSERT INTO EMP
VALUES (7521, 'WARD', 'SALESMAN', 7698, '02/22/1981', 1250, 500, 30);
INSERT INTO EMP
VALUES (7566, 'JONES', 'MANAGER', 7839, '04/02/1981', 2975, NULL, 20);
INSERT INTO EMP
VALUES (7654, 'MARTIN', 'SALESMAN', 7698, '9/28/1981', 1250, 1400, 30);
INSERT INTO EMP
VALUES (7698, 'BLAKE', 'MANAGER', 7839, '05/01/1981', 2850, NULL, 30);
INSERT INTO EMP
VALUES (7782, 'CLARK', 'MANAGER', 7839, '06/09/1981', 2450, NULL, 10);
INSERT INTO EMP
VALUES (7839, 'KING', 'PRESIDENT', NULL, '11/17/1981', 5000, NULL, 10);
INSERT INTO EMP
VALUES (7844, 'TURNER', 'SALESMAN', 7698, '09/08/1981', 1500, 0, 30);
INSERT INTO EMP
VALUES (7900, 'JAMES', 'CLERK', 7698, '12/03/1981', 950, NULL, 30);
INSERT INTO EMP
VALUES (7902, 'FORD', 'ANALYST', 7566, '12/03/1981', 3000, NULL, 20);
INSERT INTO EMP
VALUES (7934, 'MILLER', 'CLERK', 7782, '01/23/1982', 1300, NULL, 10);


create or replace function propMgr()
    returns float as
$$
DECLARE
    n integer ; n2 integer ; n3 float ;
BEGIN
    select count(*) into n from emp;
    select count(*) into n2 from emp E where E.job like 'MANAGER';

    if (n) = 0
    then
        return null;
    end if;

    n3 = ((n2 * 1.0) / n) * 100;

    return n3;
END;

$$ LANGUAGE plpgsql;

select propMgr();


-- EX3
create or replace function cat() returns varchar[] as
$$
declare
    curs1 CURSOR for SELECT tablename
                     FROM pg_tables
                     WHERE tableowner = 'postgres';
    result varchar;
    c      varchar := ' ';
begin
    for uplet in curs1
        LOOP
            result = concat(result, c, uplet);
        end loop;
    return string_to_array(result, c);
end;
$$ language plpgsql;

select cat();



-- EX4
create or replace function aug1000(dep_num int) returns void as
$$
declare
    curs1 CURSOR for SELECT *
                     from EMP e
                     where e.DEPTNO = dep_num
                       and e.SAL > 1500;
    maxSal numeric;
begin
    select max(e.SAL) into maxSal from EMP e;
    for employee in curs1
        LOOP
            update EMP
            set SAL = SAL + 1000
            where current of curs1;
            if (employee.SAL >= maxSal) then
                RAISE EXCEPTION 'Le salaire de % dépasse le salaire maximum ', employee.ENAME;
            end if;
        end loop;
end;
$$ language plpgsql;

select aug1000(20);
select *
from EMP e
where e.DEPTNO = 20;
drop table EMP;





 
