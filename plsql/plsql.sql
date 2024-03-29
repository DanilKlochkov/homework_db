-- 1
DO language plpgsql $$
BEGIN
  RAISE NOTICE 'hello, world!';
END
$$;

-- 2
DO language plpgsql $$
BEGIN
  RAISE NOTICE '%', now()::date;
END
$$;

-- 3
DO language plpgsql $$
DECLARE
  x int := 10;
  y int := 2;
BEGIN
  RAISE NOTICE 'x + y = %', (x+y);
  RAISE NOTICE 'x - y = %', (x-y);
  RAISE NOTICE 'x * y = %', (x*y);
  RAISE NOTICE 'x / y = %', (x/y);
  RAISE NOTICE 'x mod y = %', (x%y);
END
$$;

-- 4
DO language plpgsql $$
DECLARE
  x int := ?;
BEGIN
  IF x = 5 THEN RAISE NOTICE 'Отлично!';
  	ELSIF x = 4 THEN RAISE NOTICE 'Хорошо';
  	ELSIF x = 3 THEN RAISE NOTICE 'Удовлетворительно';
	  ELSIF x = 2 THEN RAISE NOTICE 'Неуд';
  	ELSE RAISE NOTICE 'Введенная оценка не верна';
  END IF;
END
$$;

DO language plpgsql $$
DECLARE
  x int := ?;
BEGIN
  CASE x
  	WHEN 5 THEN RAISE NOTICE 'Отлично!';
	  WHEN 4 THEN RAISE NOTICE 'Хорошо';
	  WHEN 3 THEN RAISE NOTICE 'Удовлетворительно';
	  WHEN 2 THEN RAISE NOTICE 'Неуд';
	  ELSE RAISE NOTICE 'Введенная оценка не верна';
  END CASE;
END
$$;

-- 5
DO language plpgsql $$
DECLARE 
	n int := 20;
BEGIN
	WHILE n < 31 LOOP
		RAISE NOTICE '%^2 = %', n, n^2;
		n = n + 1;
	END LOOP;
END;
$$;

DO language plpgsql $$
BEGIN
	FOR i IN 20..30 LOOP
		RAISE NOTICE '%^2 = %', i, i^2;
	END LOOP;
END;
$$;

DO language plpgsql $$
DECLARE 
	n int := 20;
BEGIN
	LOOP
		RAISE NOTICE '%^2 = %', n, n^2;
		n = n + 1;
		IF(n = 31) THEN
			EXIT;
		END IF;
	END LOOP;
END;
$$;

-- 6
DO language plpgsql $$
DECLARE 
	n int := 12;
BEGIN
	WHILE n <> 1 LOOP
		IF n % 2 == 0 THEN
			n = n / 2;
			RAISE NOTICE '%', num;
		ELSE
			n = n * 3 + 1;
			RAISE NOTICE '%', num;
		END IF;
	END LOOP;
END;
$$;

-- 7
CREATE OR REPLACE FUNCTION lucs_numbers(n int) RETURNS int
AS $$
DECLARE
	L0 int := 2;
	L1 int := 1;
	temp int := 0;
BEGIN
	WHILE n <> 2 LOOP
		temp = L0 + L1;
		L0 = L1;
		L1 = temp;
		n = n - 1;
	END LOOP;
	RETURN L1;
END
$$ LANGUAGE plpgsql;

-- 8
CREATE OR REPLACE FUNCTION count_people_by_year(year int) RETURNS int
AS $$
DECLARE
people_count int;
BEGIN
	SELECT COUNT(id) INTO people_count
	FROM people
	WHERE EXTRACT(YEAR FROM people.birth_date) = count_people_by_year.year;
	RETURN people_count;
END
$$ LANGUAGE plpgsql;


-- 9
CREATE OR REPLACE FUNCTION count_people_by_eyes(eyes varchar) RETURNS int
AS $$
DECLARE
people_count int;
BEGIN
	SELECT COUNT(id) INTO people_count
	FROM people
	WHERE people.eyes = count_people_by_eyes.eyes;
	RETURN people_count;
END
$$ LANGUAGE plpgsql;

-- 10
CREATE OR REPLACE FUNCTION get_id_the_youngest() RETURNS int
AS $$
DECLARE
id_y int;
BEGIN
	SELECT id INTO id_y
	FROM people
	ORDER BY birth_date DESC
	LIMIT 1;
	RETURN id_y;
END
$$ LANGUAGE plpgsql;


-- 11
CREATE OR REPLACE PROCEDURE get_people_by_bwi(IN x real)
LANGUAGE plpgsql
AS $$
DECLARE
	p people%ROWTYPE;
BEGIN
	FOR p IN 
		SELECT * FROM people
		WHERE people.weight / ((people.growth / 100) ^ 2) > x
	LOOP
		RAISE NOTICE 'id: %, name: %, surname: %', p.id, p.name, p.surname;
	END LOOP;
END;
$$;

-- 12
BEGIN;
CREATE TABLE family_ties (
	id SERIAL PRIMARY KEY,
	human_id INTEGER NOT NULL REFERENCES people(id),
	relation_id INTEGER NOT NULL REFERENCES people(id),
	relationship_type VARCHAR(255)
);
COMMIT;
END;

-- 13
CREATE OR REPLACE PROCEDURE get_people_by_bwi(IN new_name varchar, new_surname varchar, new_birth_date DATE, 
											  new_growth real, new_weight real, new_eyes varchar, new_hair varchar,
											  r_id integer, r_type varchar)
LANGUAGE plpgsql
AS $$
DECLARE
	pers_id int;
BEGIN
	INSERT INTO people (name, surname, birth_date, growth, weight, eyes, hair, family_ties)
	VALUES (new_name, new_surname, new_birth_date, new_growth, new_weight, new_eyes, new_hair)
	RETURNING people.id INTO pers_id;

	INSERT INTO family_ties(human_id, relation_id, relationship_type)
	VALUES (pers_id, r_id, r_type);
	RAISE NOTICE 'Success insert at %', current_timestamp;
END;
$$;

-- 14
BEGIN;
ALTER TABLE people ADD COLUMN updated_at TIMESTAMP DEFAULT current_timestamp;
COMMIT;
END;

-- 15
CREATE OR REPLACE PROCEDURE update_characters(new_id int, new_growth real, new_weight real)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE people SET growth = new_growth,
					  weight = new_weight,
					  update_at = now()
					  WHERE id = new_id;
	RAISE NOTICE 'Success update at %', up;
END;
$$;
