select * from project.dbo.Data1
select * from project.dbo.Data2

--number of rows in the data set

select count(*) from project..Data1

select count(*) from project..Data2


select * from project..Data2 where State  in('Bihar','Jharkhand')


--total polpulation 
select sum(Population) as totalPopulation from project..Data2

--average growth of india 

select avg(Growth)*100 as growthcountry from project..Data1

-- Avg growth rate state wise

select state, avg(growth)*100 as growthofState from project..data1 group by state

-- Avg sex ratio
select state, round(avg(Sex_Ratio),0) as AvgSexRatio from project..data1 group by state order by AvgSexRatio  DESC


--avg literacy rate 

select state, round(avg(Literacy),0) as Avgliteracy from project..data1 
group by state  Having round(avg(Literacy),0)>90 order by Avgliteracy  DESC 


--top three state showing percentage growth ratio 

select  Top 3 state, avg(growth)*100 as growthofState from project..data1 group by state order by growthofState desc

--bottom three states showing lowest growth ratio 
select  top 3 state, avg(growth)*100 as growthofState from project..data1 group by state order by growthofState asc 


--top 3 and bottom 3 literacy rate

drop table if exists #tostates
drop table if exists #topstates 
create table #topstates
( state nvarchar(255),
  topstates float
)

insert into #topstates

select   state, round(avg(Literacy),0) as literacy from project..data1 group by state order by literacy desc

select  top 3 * from #topstates order by #topstates.topstates desc 




drop table if exists #bottomstates 
create table #bottomstates
( state nvarchar(255),
  bottomstates float

)



insert into #bottomstates
select   state, round(avg(Literacy),0) as literacy from project..data1 group by state order by literacy desc

select  top 3 * from #bottomstates order by #bottomstates.bottomstates asc 


--union of top 3 and bottom 3 

select * from (
select  top 3 * from #topstates order by #topstates.topstates desc ) a
union 
select * from (
select  top 3 * from #bottomstates order by #bottomstates.bottomstates asc ) b


select state  from project..data1 where state like 'a%' or state like  'b%'

select state  from project..data1 where state like 'a%' or state like  '%d'




--join both the table 
--total males and females
select e.State, sum(e.Males) as Total_Male , sum (e.Females) as Total_Females from 
(select c.State,c.District,  (c.population)/(c.sex_ratio+1) Males, (c.population*c.sex_ratio)/(c.sex_ratio+1) Females   from 
(select a.State,a.District,a.Sex_Ratio/100 as sex_ratio ,b.Population from project..Data1 a inner join project..data2 b on a.district=b.district) c) e
group by e.state


--total literacy rate 
select d.state,sum(d.literate) as total_literate,sum(d.illiterate) as total_illiterate from 
(select c.state,c.district,round((c.population)*(c.literacy_ratio),0) as  literate ,round(c.population-((c.literacy_ratio)*(c.population)),0) as illiterate from 
(select a.State,a.District,a.literacy/100 literacy_ratio, b.Population from project..Data1 a inner join project..data2 b on a.district=b.district) c) d
group by d.state


--population in the previous census 

select g.total_area/g.total_previous_population  as total_previous_population_vs_area,g.total_area/total_current_population as total_current_population_vs_area from
(
select q.*,r.total_area from(

select '1' as keyy,n.* from
(select sum(m.previous_census) total_previous_population,sum(m.current_census) total_current_population from 
(select e.state,sum(e.previous_census) previous_census,sum(e.current_census) current_census from
(select c.State,c.District,round((c.population)/(1+c.growth),0) as previous_census,c.Population as current_census from
(select a.State,a.District,a.growth as growth,b.Population from project..Data1 a inner join project..data2 b on a.district=b.district) c)e
group by e.state)m)n) q inner join (


--population vs area 
select '1' as keyy,z.*from
(select sum(area_km2) total_area  from project..data2)z) r on  q.keyy=r.keyy)g


--top3 districts from each states having hing literacy rate 
select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..data1)a

where rnk in (1,2,3)
