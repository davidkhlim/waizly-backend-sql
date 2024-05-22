-- INITIALIZE DATA
-- public.employees definition

-- Drop table

-- DROP TABLE public.employees;

CREATE TABLE public.employees (
	employee_id bigserial NOT NULL,
	"name" varchar NULL,
	job_title varchar NULL,
	salary int8 NULL,
	department varchar NULL,
	joined_date timestamptz NULL,
	CONSTRAINT employees_pk PRIMARY KEY (employee_id)
);

-- delete all
delete from employees
;

insert into
  employees (employee_id, name, job_title, salary, department, joined_date)
values
  (1, 'John Smith', 'Manager', 60000, 'Sales', '2022-01-15')
, (2, 'Jane Doe', 'Analyst', 45000, 'Marketing', '2022-02-01')
, (3, 'Mike Brown', 'Developer', 55000, 'IT', '2022-03-10')
, (4, 'Anna Lee', 'Manager', 65000, 'Sales', '2021-12-05')
, (5, 'Mark Wong', 'Developer', 50000, 'IT', '2023-05-20')
, (6, 'Emily Chen', 'Analyst', 48000, 'Marketing', '2023-06-02')
;

-- public.sales_data definition

-- Drop table

-- DROP TABLE public.sales_data;

CREATE TABLE public.sales_data (
	sales_id int8 NOT NULL DEFAULT nextval('newtable_sales_id_seq'::regclass),
	employee_id int8 NOT NULL,
	sales int8 NULL,
	CONSTRAINT sales_data_pk PRIMARY KEY (sales_id)
);

-- delete all
delete from sales_data
;

insert into
  sales_data (sales_id, employee_id, sales)
values
  (1, 1, 15000)
, (2, 2, 12000)
, (3, 3, 18000)
, (4, 1, 20000)
, (5, 4, 22000)
, (6, 5, 19000)
, (7, 6, 13000)
, (8, 2, 14000)



-- QUESTIONS
-- Soal 1 = Tampilkan seluruh data dari tabel "employees" (5 Points)
select * from employees e 

-- Soal 2 = Berapa banyak karyawan yang memiliki posisi pekerjaan (job title) "Manager"? (5 Points)
select
	count(*) as manager_count
from
	employees e
where
	e.job_title = 'Manager'

-- Soal 3 = Tampilkan daftar nama dan gaji (salary) dari karyawan yang bekerja di departemen "Sales" atau "Marketing" (10 Points)
select
	e.name,
	e.salary,
	e.department
from
	employees e
where
	e.department in ('Sales', 'Marketing') 
	
-- Soal 4 = Hitung rata-rata gaji (salary) dari karyawan yang bergabung (joined) dalam 5 tahun terakhir (berdasarkan kolom "joined_date") (10 Points)
select
	avg(salary) as avg_salary
from
	employees e
where
	e.joined_date between (CURRENT_DATE - interval '5 years') and CURRENT_DATE
	
-- Soal 5 = Tampilkan 5 karyawan dengan total penjualan (sales) tertinggi dari tabel "employees" dan "sales_data" (10 Points)
select 
	e."name" ,
	sum(sd.sales) as total_sales
from
	sales_data sd
inner join employees e
on
	sd.employee_id = e.employee_id
group by
	e."name"
order by
	total_sales desc
limit 5

-- Soal 6 = Tampilkan nama, gaji (salary), dan rata-rata gaji (salary) dari semua karyawan yang bekerja di departemen yang memiliki rata-rata gaji lebih tinggi dari gaji rata-rata di semua departemen (15 Points)
with cte_avg_sal_per_dep as (
select
	e.department,
	avg(salary) as avg_salary_per_department
from
	employees e
group by
	e.department
),
cte_avg_sal as (
select
	avg(salary) as avg_salary
from
	employees
)
select
	e.name,
	e.salary,
	e.department,
	caspd.avg_salary_per_department,
	cas.avg_salary
from
	employees e
inner join cte_avg_sal_per_dep caspd 
on
	caspd.department = e.department
full join cte_avg_sal cas on
	true
where
	caspd.avg_salary_per_department > cas.avg_salary
	
-- Soal 7 = Tampilkan nama dan total penjualan (sales) dari setiap karyawan, bersama dengan peringkat (ranking) masing-masing karyawan berdasarkan total penjualan. Peringkat 1 adalah karyawan dengan total penjualan tertinggi (25 Points)
select 
	e."name" ,
	sum(sd.sales) as total_sales,
	row_number () over (
		order by
			sum(sd.sales) desc
		  )
from
	sales_data sd
inner join employees e
on
	sd.employee_id = e.employee_id
group by
	e."name"
order by
	total_sales desc
	
-- Soal 8 = Buat sebuah stored procedure yang menerima nama departemen sebagai input, dan mengembalikan daftar karyawan dalam departemen tersebut bersama dengan total gaji (salary) yang mereka terima (20 Points)
create or replace
function public.get_employee_salary_by_department(department varchar)
returns table("name" varchar,
salary int8)
language sql
as $$
begin
  select
	e."name" as "name",
	e.salary as salary
from
	employees e
where
	e.department = department;

return QUERY;
end;

$$;


