-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
CREATE 
OR REPLACE VIEW Q1_V1 AS 
SELECT 
  id 
FROM 
  facilities 
WHERE 
  LOWER(description) = 'air-conditioned';

CREATE 
OR REPLACE VIEW Q1_V2 AS 
SELECT 
  DISTINCT room 
FROM 
  room_facilities 
WHERE 
  facility IN (
    SELECT 
      id 
    FROM 
      Q1_V1
  );

CREATE 
OR REPLACE VIEW Q1 (unswid, longname) AS 
SELECT 
  unswid, 
  longname 
FROM 
  rooms 
WHERE 
  id IN (
    SELECT 
      room 
    FROM 
      Q1_V2
  );


-- Q2:
CREATE 
OR REPLACE VIEW Q2_V1 AS 
SELECT 
  id 
FROM 
  people 
WHERE 
  LOWER(NAME) = 'hemma margareta';

CREATE 
OR REPLACE VIEW Q2_V2 AS 
SELECT 
  course 
FROM 
  course_enrolments 
WHERE 
  student IN (
    SELECT 
      id 
    FROM 
      Q2_V1
  );

CREATE 
OR REPLACE VIEW Q2_V3 AS 
SELECT 
  DISTINCT staff 
FROM 
  course_staff 
WHERE 
  course IN (
    SELECT 
      course 
    FROM 
      Q2_V2
  );

CREATE 
OR REPLACE VIEW Q2 (unswid, name) AS 
SELECT 
  unswid, 
  NAME 
FROM 
  people 
WHERE 
  id IN (
    SELECT 
      staff 
    FROM 
      Q2_V3
  );


-- Q3:
CREATE 
OR REPLACE VIEW Q3_V1 AS 
SELECT 
  id 
FROM 
  subjects 
WHERE 
  LOWER(code) = 'comp9311';

CREATE 
OR REPLACE VIEW Q3_V2 AS 
SELECT 
  id 
FROM 
  subjects 
WHERE 
  LOWER(code) = 'comp9024';

CREATE 
OR REPLACE VIEW Q3_V3 AS 
SELECT 
  DISTINCT id 
FROM 
  students 
WHERE 
  LOWER(stype) = 'intl';

CREATE 
OR REPLACE VIEW Q3_V4 AS 
SELECT 
  course_enrolments.student, 
  courses.semester 
FROM 
  course_enrolments 
  INNER JOIN courses ON course_enrolments.course = courses.id 
WHERE 
  courses.id IN (
    SELECT 
      id 
    FROM 
      courses 
    WHERE 
      subject IN (
        SELECT 
          id 
        FROM 
          Q3_V1
      )
  ) 
  AND student IN (
    SELECT 
      id 
    FROM 
      Q3_V3
  ) 
  AND LOWER(grade) = 'hd';

CREATE 
OR REPLACE VIEW Q3_V5 AS 
SELECT 
  course_enrolments.student, 
  courses.semester 
FROM 
  course_enrolments 
  INNER JOIN courses ON course_enrolments.course = courses.id 
WHERE 
  courses.id IN (
    SELECT 
      id 
    FROM 
      courses 
    WHERE 
      subject IN (
        SELECT 
          id 
        FROM 
          Q3_V2
      )
  ) 
  AND student IN (
    SELECT 
      id 
    FROM 
      Q3_V3
  ) 
  AND LOWER(grade) = 'hd';

CREATE 
OR REPLACE VIEW Q3 (unswid, name) AS 
SELECT 
  unswid, 
  name 
FROM 
  people 
WHERE 
  id IN (
    SELECT 
      Q3_V4.student 
    FROM 
      Q3_V4 
      INNER JOIN Q3_V5 ON Q3_V4.student = Q3_V5.student 
      AND Q3_V4.semester = Q3_V5.semester
  );


-- Q4:
CREATE 
OR REPLACE VIEW Q4_V1 AS 
SELECT 
  COUNT(grade) 
FROM 
  course_enrolments 
WHERE 
  mark IS NOT NULL 
  AND LOWER(grade) = 'hd';

CREATE 
OR REPLACE VIEW Q4_V2 AS 
SELECT 
  COUNT(DISTINCT student) 
FROM 
  course_enrolments 
WHERE 
  mark IS NOT NULL;

CREATE 
OR REPLACE VIEW Q4 (num_student) AS 
SELECT 
  COUNT(*) 
FROM 
  (
    SELECT 
      student, 
      COUNT(grade) 
    FROM 
      course_enrolments 
    WHERE 
      mark IS NOT NULL 
      AND LOWER(grade) = 'hd' 
    GROUP BY 
      student 
    HAVING 
      COUNT(grade) > (
        SELECT 
          count 
        FROM 
          Q4_V1
      ) / (
        SELECT 
          count 
        FROM 
          Q4_V2
      )
  ) num_student;


--Q5:
CREATE 
OR REPLACE VIEW Q5_V1 AS 
SELECT 
  course, 
  MAX(mark) 
FROM 
  course_enrolments 
WHERE 
  mark IS NOT NULL 
GROUP BY 
  course 
HAVING 
  COUNT(mark IS NOT NULL) >= 20;

CREATE 
OR REPLACE VIEW Q5_V2 AS 
SELECT 
  Q5_V1.max,
  Q5_V1.course,
  courses.semester,
  courses.subject 
FROM 
  Q5_V1 
  INNER JOIN courses ON courses.id = Q5_V1.course;

CREATE 
OR REPLACE VIEW Q5_V3 AS 
SELECT 
  course, 
  max, 
  semester, 
  subject 
FROM 
  Q5_V2 
  INNER JOIN semesters ON semesters.id = Q5_V2.semester;

CREATE 
OR REPLACE VIEW Q5_V4 AS 
SELECT 
  semester, 
  MIN(max) 
FROM 
  Q5_V3 
GROUP BY 
  semester;

CREATE 
OR REPLACE VIEW Q5_V5 AS 
SELECT 
  Q5_V4.semester, 
  Q5_V3.subject 
FROM 
  Q5_V3 
  INNER JOIN Q5_V4 ON Q5_V3.semester = Q5_V4.semester 
  AND Q5_V3.max = Q5_V4.min;

CREATE 
OR REPLACE VIEW Q5 (code, name, semester) AS 
SELECT 
  subjects.code, 
  subjects.name, 
  semesters.name 
FROM 
  subjects, 
  semesters, 
  Q5_V5 
WHERE 
  subjects.id = Q5_V5.subject 
  AND semesters.id = Q5_V5.semester;


-- Q6:
CREATE 
OR REPLACE VIEW Q6_V1 AS 
SELECT 
  program_enrolments.id, 
  program_enrolments.student, 
  program_enrolments.semester, 
  program_enrolments.program, 
  stream_enrolments.stream 
FROM 
  program_enrolments, 
  stream_enrolments, 
  streams 
WHERE 
  program_enrolments.id = stream_enrolments.partof 
  AND stream_enrolments.stream = streams.id 
  AND LOWER(streams.name) = 'management';

CREATE 
OR REPLACE VIEW Q6_V2 AS 
SELECT 
  student 
FROM 
  Q6_V1 
  INNER JOIN semesters ON Q6_V1.semester = semesters.id 
WHERE 
  semesters.year = '2010' 
  AND LOWER(semesters.term) = 's1' 
  AND student NOT IN (
    SELECT 
      student 
    FROM 
      course_enrolments, 
      courses, 
      subjects, 
      orgUnits 
    WHERE 
      course_enrolments.course = courses.id 
      AND courses.subject = subjects.id 
      AND subjects.offeredBy = orgUnits.id 
      AND LOWER(orgUnits.name) = 'faculty of engineering'
  );

CREATE 
OR REPLACE VIEW Q6_V3 AS 
SELECT 
  student 
FROM 
  Q6_V2 
  INNER JOIN students ON Q6_V2.student = students.id 
WHERE 
  LOWER(students.stype) = 'local';

CREATE 
OR REPLACE VIEW Q6 (num) AS 
SELECT 
  COUNT(DISTINCT unswid) 
FROM 
  Q6_V3 
  INNER JOIN people ON Q6_V3.student = people.id 
WHERE 
  people.unswid IS NOT NULL;


-- Q7:
CREATE 
OR REPLACE VIEW Q7_V1 AS 
SELECT 
  id 
FROM 
  subjects 
WHERE 
  LOWER(name) = 'database systems';

CREATE 
OR REPLACE VIEW Q7_V2 AS 
SELECT 
  id 
FROM 
  courses 
WHERE 
  subject IN (
    SELECT 
      id 
    FROM 
      Q7_V1
  );

CREATE 
OR REPLACE VIEW Q7_V3 AS 
SELECT 
  semester, 
  CAST(
    AVG(mark) AS NUMERIC(4, 2)
  ) 
FROM 
  course_enrolments 
  INNER JOIN courses ON course_enrolments.course = courses.id 
WHERE 
  courses.id IN (
    SELECT 
      id 
    FROM 
      Q7_V2
  ) 
  AND mark IS NOT NULL 
GROUP BY 
  semester;

CREATE 
OR REPLACE VIEW Q7 (year, term, average_mark) AS 
SELECT 
  year, 
  term, 
  avg 
FROM 
  semesters 
  INNER JOIN Q7_V3 ON semesters.id = Q7_V3.semester;


-- Q8:
CREATE 
OR REPLACE VIEW Q8_V1 AS 
SELECT 
  subject, 
  semester 
FROM 
  courses 
WHERE 
  subject in (
    SELECT 
      id 
    FROM 
      subjects 
    WHERE 
      code LIKE 'COMP93%'
  );

CREATE 
OR REPLACE VIEW Q8_V2 AS 
SELECT 
  Q8_V1.subject, 
  semesters.year, 
  semesters.term 
FROM 
  Q8_V1, 
  semesters 
WHERE 
  Q8_V1.semester = semesters.id;

CREATE 
OR REPLACE VIEW Q8_V3 AS 
SELECT 
  year, 
  term 
FROM 
  semesters 
WHERE 
  year >= 2004 
  AND year <= 2013 
  AND term IN ('S1', 'S2');

CREATE 
OR REPLACE VIEW Q8_V4 AS 
SELECT 
  DISTINCT subject 
FROM 
  Q8_V2 a 
WHERE 
  NOT EXISTS (
    (
      SELECT 
        year, 
        term 
      FROM 
        Q8_V3
    ) 
    EXCEPT 
      (
        SELECT 
          year, 
          term 
        FROM 
          Q8_V2 b 
        WHERE 
          b.subject = a.subject
      )
  );

CREATE 
OR REPLACE VIEW Q8_V5 AS 
SELECT 
  course_enrolments.student, 
  course_enrolments.course, 
  course_enrolments.mark, 
  Q8_V4.subject 
FROM 
  course_enrolments, 
  courses, 
  Q8_V4 
WHERE 
  course_enrolments.course = courses.id 
  AND courses.subject = Q8_V4.subject 
  AND course_enrolments.mark < 50;

CREATE 
OR REPLACE VIEW Q8_V6 AS 
SELECT 
  id 
FROM 
  courses 
WHERE 
  subject IN (
    SELECT 
      subject 
    FROM 
      Q8_V4
  );

CREATE 
OR REPLACE VIEW Q8_V7 AS 
SELECT 
  Q8_V5.student, 
  Q8_V5.subject 
FROM 
  Q8_V5, 
  Q8_V6 
WHERE 
  Q8_V5.course = Q8_V6.id;

CREATE 
OR REPLACE VIEW Q8_V8 AS 
SELECT 
  DISTINCT student 
FROM 
  Q8_V7 a 
WHERE 
  NOT EXISTS (
    (
      SELECT 
        subject 
      FROM 
        Q8_V4
    ) 
    EXCEPT 
      (
        SELECT 
          subject 
        FROM 
          Q8_V7 b 
        WHERE 
          b.student = a.student
      )
  );

CREATE 
OR REPLACE VIEW Q8(zid, name) AS 
SELECT 
  CONCAT(
    'z', 
    CAST(unswid AS VARCHAR)
  ), 
  name 
FROM 
  People 
WHERE 
  id IN (
    SELECT 
      student 
    FROM 
      Q8_V8
  );


-- Q9:
CREATE 
OR REPLACE VIEW Q9_V1 AS 
SELECT 
  program_enrolments.student, 
  program_enrolments.program, 
  program_enrolments.semester 
FROM 
  program_enrolments, 
  program_degrees 
WHERE 
  program_enrolments.program = program_degrees.program 
  AND LOWER(program_degrees.abbrev) = 'bsc' 
GROUP BY 
  program_enrolments.student, 
  program_enrolments.program, 
  program_enrolments.semester 
ORDER BY 
  program_enrolments.student;

CREATE 
OR REPLACE VIEW Q9_V2 AS 
SELECT 
  course_enrolments.student, 
  course_enrolments.course, 
  course_enrolments.mark, 
  courses.semester 
FROM 
  course_enrolments, 
  courses, 
  semesters 
WHERE 
  course_enrolments.course = courses.id 
  AND courses.semester = semesters.id 
  AND semesters.year = 2010 
  AND LOWER(semesters.term) = 's2' 
  AND course_enrolments.mark >= 50;

CREATE 
OR REPLACE VIEW Q9_V3 AS 
SELECT 
  Q9_V2.student, 
  Q9_V2.course, 
  Q9_V2.mark, 
  Q9_V2.semester, 
  Q9_V1.program 
FROM 
  Q9_V2, 
  Q9_V1 
WHERE 
  Q9_V2.student = Q9_V1.student 
  AND Q9_V2.semester = Q9_V1.semester 
ORDER BY 
  Q9_V2.student;

CREATE 
OR REPLACE VIEW Q9_V4 AS 
SELECT 
  DISTINCT student 
FROM 
  Q9_V3;

CREATE 
OR REPLACE VIEW Q9_V5 AS 
SELECT 
  course_enrolments.student, 
  course_enrolments.course, 
  course_enrolments.mark, 
  courses.semester, 
  courses.subject 
FROM 
  course_enrolments, 
  courses, 
  semesters 
WHERE 
  course_enrolments.course = courses.id 
  AND courses.semester = semesters.id 
  AND semesters.year < 2011 
  AND course_enrolments.mark >= 50;

CREATE 
OR REPLACE VIEW Q9_V6 AS 
SELECT 
  Q9_V5.student, 
  Q9_V5.course, 
  Q9_V5.mark, 
  Q9_V5.semester, 
  Q9_V5.subject 
FROM 
  Q9_V5, 
  Q9_V4 
WHERE 
  Q9_V5.student = Q9_V4.student;

CREATE 
OR REPLACE VIEW Q9_V7 AS 
SELECT 
  Q9_V6.student, 
  Q9_V6.course, 
  Q9_V6.mark, 
  Q9_V6.subject, 
  Q9_V1.program 
FROM 
  Q9_V6, 
  Q9_V1 
WHERE 
  Q9_V6.student = Q9_V1.student 
  AND Q9_V6.semester = Q9_V1.semester 
ORDER BY 
  Q9_V6.student;

CREATE 
OR REPLACE VIEW Q9_V8 AS 
SELECT 
  student, 
  program, 
  AVG(mark) 
FROM 
  Q9_V7 
GROUP BY 
  student, 
  program 
ORDER BY 
  student;

CREATE 
OR REPLACE VIEW Q9_V9 AS 
SELECT 
  DISTINCT student 
FROM 
  Q9_V8 
WHERE 
  avg >= 80 
  AND student NOT IN (
    SELECT 
      student 
    FROM 
      Q9_V8 
    WHERE 
      avg < 80
  );

CREATE 
OR REPLACE VIEW Q9_V10 AS 
SELECT 
  Q9_V7.student, 
  Q9_V7.subject, 
  subjects.uoc, 
  Q9_V7.program 
FROM 
  Q9_V7, 
  subjects, 
  programs 
WHERE 
  Q9_V7.subject = subjects.id 
  AND Q9_V7.program = programs.id;

CREATE 
OR REPLACE VIEW Q9_V11 AS 
SELECT 
  student, 
  program, 
  sum(uoc) 
FROM 
  Q9_V10 
GROUP BY 
  student, 
  program;

CREATE 
OR REPLACE VIEW Q9_V12 AS 
SELECT 
  Q9_V11.student, 
  Q9_V11.program, 
  Q9_V11.sum, 
  programs.uoc 
FROM 
  Q9_V11, 
  programs 
WHERE 
  Q9_V11.program = programs.id;

CREATE 
OR REPLACE VIEW Q9_V13 AS 
SELECT 
  Q9_V11.student, 
  Q9_V11.program, 
  Q9_V11.sum, 
  programs.uoc 
FROM 
  Q9_V11, 
  programs 
WHERE 
  Q9_V11.program = programs.id;

CREATE 
OR REPLACE VIEW Q9_V14 AS 
SELECT 
  DISTINCT student 
FROM 
  Q9_V13 
WHERE 
  sum >= uoc 
  AND student NOT IN (
    SELECT 
      student 
    FROM 
      Q9_V12 
    WHERE 
      sum < uoc
  );

CREATE 
OR REPLACE VIEW Q9_V15 AS 
SELECT 
  DISTINCT Q9_V9.student 
FROM 
  Q9_V9, 
  Q9_V14 
WHERE 
  Q9_V9.student = Q9_V14.student;

CREATE 
OR REPLACE VIEW Q9 (unswid, name) AS 
SELECT 
  people.unswid, 
  people.name 
FROM 
  people, 
  Q9_V15 
WHERE 
  people.id = Q9_V15.student;


-- Q10:
CREATE 
OR REPLACE VIEW Q10_V1 AS 
SELECT 
  * 
FROM 
  rooms 
WHERE 
  rtype IN (
    SELECT 
      id 
    FROM 
      room_types 
    WHERE 
      LOWER(description) = 'lecture theatre'
  );

CREATE 
OR REPLACE VIEW Q10_V2 AS 
SELECT 
  room, 
  COUNT(room) 
FROM 
  classes 
WHERE 
  course IN (
    SELECT 
      id 
    FROM 
      courses 
    WHERE 
      (
        semester IN (
          SELECT 
            id 
          FROM 
            semesters 
          WHERE 
            LOWER(term) = 's1' 
            AND year = 2011
        )
      )
  ) 
GROUP BY 
  room;

CREATE 
OR REPLACE VIEW Q10_V3 AS 
SELECT 
  * 
FROM 
  Q10_V1 
  LEFT JOIN Q10_V2 ON Q10_V1.id = Q10_V2.room;

CREATE 
OR REPLACE VIEW Q10 (unswid, longname, num, rank) AS 
SELECT 
  unswid, 
  longname, 
  COALESCE(count, 0), 
  RANK() OVER (
    ORDER BY 
      COALESCE(count, 0) DESC
  ) 
FROM 
  Q10_V3;

