-- Deliverable 1
-- Retirement Titles table that holds all the titles of employees who were born 
-- between January 1, 1952 and December 31, 1955. 
-- Retirement Titles
SELECT em.emp_no, 
em.first_name,
em.last_name,
ti.title,
ti.from_date,
ti.to_date
INTO retirement_titles
FROM employees as em
INNER JOIN titles AS ti
ON (em.emp_no = ti.emp_no)
WHERE em.birth_date BETWEEN '1952-01-01' AND '1955-12-31'
ORDER BY em.emp_no;

--- Unique titles table
--- Use Dictinct with Order by to remove duplicate rows
SELECT DISTINCT ON (emp_no) emp_no,
first_name,
last_name,
title
INTO unique_titles
FROM retirement_titles
ORDER BY emp_no, to_date DESC;

--- count of retiring titles 
SELECT COUNT(title) as count, title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY count DESC;

-- Deliverable 2
-- mentorship-eligibility table that holds the current employees who were born 
-- between January 1, 1965 and December 31, 1965.
SELECT DISTINCT ON (em.emp_no) em.emp_no, 
em.first_name,
em.last_name,
em.birth_date,
de.from_date,
de.to_date,
ti.title
INTO mentorship_eligibilty
FROM employees as em
INNER JOIN dept_emp AS de
ON (em.emp_no = de.emp_no)
INNER JOIN titles AS ti
ON (em.emp_no = ti.emp_no)
WHERE (de.to_date = '9999-01-01') AND 
	  (em.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
ORDER BY em.emp_no;

-- Deliverable 3
-- Count of mentorship empolyees by Title
SELECT COUNT(title) as count, 
title
FROM mentorship_eligibilty
GROUP BY title
ORDER BY count DESC;

-- Mentorship Eligibility by Department
SELECT me.emp_no, 
me.title, 
de.dept_no,
de.to_date,
dp.dept_name
FROM mentorship_eligibilty AS me
INNER JOIN dept_emp AS de
ON (me.emp_no = de.emp_no)
INNER JOIN departments AS dp
ON (de.dept_no = dp.dept_no)
WHERE de.to_date = (SELECT MAX(to_date) FROM dept_emp)
ORDER BY me.emp_no DESC;

--- Count of Mentorship Empolyees by Department
SELECT COUNT(dp.dept_name) as count, 
dp.dept_name
INTO mentorship_eligibilty_dept_count
FROM mentorship_eligibilty AS me
INNER JOIN dept_emp AS de
ON (me.emp_no = de.emp_no)
INNER JOIN departments AS dp
ON (de.dept_no = dp.dept_no)
WHERE de.to_date = (SELECT MAX(to_date) FROM dept_emp)
GROUP BY dp.dept_name
ORDER BY count DESC;

-- Shortfall by Titles
SELECT rt.title,
(rt.count) AS Retiring_Count,
COUNT(me.title) AS Mentorship_count,
(rt.count - COUNT(me.title)) AS title_shortfall
INTO shortfall_titles
FROM retiring_titles AS rt
LEFT JOIN mentorship_eligibilty AS me
ON (rt.title = me.title)
GROUP BY rt.count, rt.title, me.title
ORDER BY rt.count DESC;

-- Retiring Employees by Department
SELECT DISTINCT ON (rt.emp_no) rt.emp_no,
rt.first_name,
rt.last_name,
rt.title,
de.dept_no,
dp.dept_name
INTO retiring_depts
FROM retirement_titles AS rt
INNER JOIN dept_emp AS de
ON (rt.emp_no = de.emp_no)
INNER JOIN departments AS dp
ON (de.dept_no = dp.dept_no)
ORDER BY rt.emp_no, rt.to_date DESC;

-- Count of Retiring Employees by Department
SELECT COUNT(dept_name) AS count,
dept_name
INTO retiring_depts_count
FROM retiring_depts
GROUP BY dept_name
ORDER BY count DESC;

-- Shortfall by Department
SELECT (rd.dept_name) AS Retiring_Dept,
(rd.count) AS Retiring_Dept_Count, 
(me.count) AS Mentorship_Dept_Count,
(rd.count - me.count) AS dept_shortfall
INTO shortfall_department
FROM retiring_depts_count AS rd
LEFT JOIN mentorship_eligibilty_dept_count AS me
ON (rd.dept_name = me.dept_name)
GROUP BY rd.count, me.count, rd.dept_name, me.dept_name
ORDER BY rd.count DESC