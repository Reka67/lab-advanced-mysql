use publications;

-- Challenge1: who are the top 3 most profiting authors

/* In table sales, a title can appear several times. The royalties need to be calculated for each sale.
Despite a title can have multiple sales records, the advance must be calculated only once for each title.
In your eventual solution, you need to sum up the following profits for each individual author:
-All advances, which are calculated exactly once for each title.
-All royalties in each sale.
*/
select title_id, count(*) as n_sales from sales
group by title_id
order by n_sales desc;

select count(*) from titles;
select count(distinct(au_ord)) from titleauthor;


select * from roysched;

select *
from titleauthor ta
left join titles t 
on ta.title_id = t.title_id
right join sales s
on ta.title_id = s.title_id;

select title_id, count(au_id) as n_au from titleauthor
group by title_id
order by n_au desc;
/* Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication*/

create temporary table roy_adv;
select ta.title_id as title_id, ta.au_id as au_id, 
round(t.advance * ta.royaltyper / 100) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
from titleauthor ta
left join titles t 
on ta.title_id = t.title_id
right join sales s
on ta.title_id = s.title_id;

select * from roy_adv;

/*Step 2: Aggregate the total royalties for each title and author */

select ta.title_id as title_id, ta.au_id as au_id, sum(t.royalty)
from titleauthor ta
left join titles t 
on ta.title_id = t.title_id
group by au_id, title_id;


select au_id, title_id,sum(sales_royalty) from 
(select ta.title_id as title_id, ta.au_id as au_id, 
round(t.advance * ta.royaltyper / 100) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
from titleauthor ta
left join titles t 
on ta.title_id = t.title_id
right join sales s
on ta.title_id = s.title_id) aud_roy
group by au_id, title_id;

select ta.title_id as title_id, ta.au_id as au_id, 
round(t.advance * ta.royaltyper / 100) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
from titleauthor ta
left join titles t 
on ta.title_id = t.title_id
right join sales s
on ta.title_id = s.title_id;


select au_id, title_id,sum(sales_royalty) as sum_royal from 
(select ta.title_id as title_id, ta.au_id as au_id, 
round(t.advance * ta.royaltyper / 100) as advance,
round(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
from titleauthor ta
left join titles t 
on ta.title_id = t.title_id
right join sales s
on ta.title_id = s.title_id) aud_roy
group by au_id, title_id;


-- Final with subqueries


select ta.au_id, ta.title_id,
round(t.advance * ta.royaltyper / 100) as advance
from titles t
join titleauthor ta
on ta.title_id = t.title_id;

select ta.au_id, ta.title_id,
sum(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
from titles t
join sales s
on t.title_id = s.title_id
right join titleauthor ta
on ta.title_id = t.title_id
group by ta.au_id, ta.title_id;

select 
advances.au_id,
sum(advance+sales_royalty) as total
from (
(select ta.au_id, ta.title_id,
round(t.advance * ta.royaltyper / 100) as advance
from titles t
join titleauthor ta
on ta.title_id = t.title_id) advances
join 
(select ta.au_id, ta.title_id,
sum(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) as sales_royalty
from titles t
join sales s
on t.title_id = s.title_id
right join titleauthor ta
on ta.title_id = t.title_id
group by ta.au_id, ta.title_id) royalties
on advances.au_id = royalties.au_id and  advances.title_id = royalties.title_id)
group by advances.au_id
order by total desc
limit 3;


-- Final with tables

create temporary table advances
SELECT 
    ta.au_id,
    ta.title_id,
    ROUND(t.advance * ta.royaltyper / 100) AS advance
FROM
    titles t
        JOIN
    titleauthor ta ON ta.title_id = t.title_id;


create temporary table royalties
SELECT 
    ta.au_id,
    ta.title_id,
    SUM(t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100) AS sales_royalty
FROM
    titles t
        JOIN
    sales s ON t.title_id = s.title_id
        RIGHT JOIN
    titleauthor ta ON ta.title_id = t.title_id
group by ta.au_id, ta.title_id;

SELECT 
    advances.au_id, SUM(advance + sales_royalty) AS total
FROM
    advances
        JOIN
    royalties ON advances.au_id = royalties.au_id
        AND advances.title_id = royalties.title_id
GROUP BY au_id
ORDER BY total DESC
LIMIT 3;




