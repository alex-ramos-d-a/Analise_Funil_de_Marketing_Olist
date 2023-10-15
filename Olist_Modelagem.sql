--------------------------------------------------------------------------------------------------------------------
# 												Olist_Funil de Marketing
--------------------------------------------------------------------------------------------------------------------

# criando banco de dados
Create database olist_mark;
use olist_mark;

# importando dados
create table df_mqk
(
	first_contact_date		date,
    origin 					varchar(50) not null,
    mql_id 					int not null auto_increment,
    constraint pk_mql primary key (mql_id)
);
select * from df_mqk;
desc df_mqk;

create table df_close
(
	won_date				date,
    business_segmento		varchar(70),
    lead_type			    varchar(70),
    lead_behavior_profiel 	varchar(70),
    business_type		    varchar(70),
    id_close                int not null auto_increment,
    constraint pk_close primary key (id_close)
);
select * from df_close;
select * from df_mqk;
--------------------------------------------------------------------------------------------------------------------
# 												Modelagem
--------------------------------------------------------------------------------------------------------------------
# MQL
create table canal (id_canal int primary key auto_increment)
select distinct 
	origin
from df_mqk;
												select * from canal;


create table MQL (id_mql int primary key auto_increment) -- Criando fato 
select 
	origin,
    first_contact_Date
from df_mqk;
												select * from mql;


create table MQL_1 (id_mql int primary key auto_increment) -- add FK na fato 
select 
	m.origin,
    m.first_contact_Date,
    id_tempo as id_dim_tempo,
    id_canal as id_dim_canal
from mql m
	join tempo_m t on t.first_contact_Date = m.first_contact_Date
    join canal c on c.origin = m.origin;
												select * from mql_1;

select origin, first_contact_Date, count(origin) from mql_1 group by 1,2;

-------------------------------------------
# 				Fechamento
-------------------------------------------
create table persona (id_persona int primary key auto_increment)
select distinct 
	business_segmento,
    lead_behavior_profiel as lead_behavior,
    business_type
from df_close
where business_segmento is not null;
												select * from persona;

create table fechamento (id_close int primary key auto_increment) -- Criando fato 
select 
	won_date,
    business_segmento,
    lead_behavior_profiel as lead_behavior,
    business_type
from df_close;
												select * from fechamento;


create table fechamento_1 (id_close int primary key auto_increment) -- add FK na fato 
select 
	f.won_date,
    f.business_segmento,
    f.lead_behavior,
    f.business_type,
    id_tempo as id_dim_tempo,
    id_persona as id_dim_canal
from fechamento f
	join tempo_f t on t.won_date = f.won_Date
    join persona p on p.business_segmento = f.business_segmento;
select * from mql_1;

-------------------------------------------
# 					Tempo
-------------------------------------------
create table tempo (id_tempo int primary key auto_increment)
select
	won_date as tempo
from fechamento_1 f 
union 
select 
	first_contact_Date as tempo
from mql;
select * from tempo;

--------------------------------------------------------------------------------------------------------------------
# 											    View
--------------------------------------------------------------------------------------------------------------------
create view olist_mark as 
select 
	id_mql,
    id_close,
    origin,
	tempo, 
	business_segmento, 
	lead_behavior,
	business_type,
    first_contact_Date,
    won_date,
    TIMESTAMPDIFF(day, won_date, first_contact_Date) as contato_primeiro_ate_fechamento
from fechamento_1 f 
		join tempo t on t.id_tempo = f.id_dim_tempo -- tab. fechamento e tempo conectado com tempo
join mql_1 q on q.id_dim_tempo = t.id_tempo; -- limitação dados de ate 6 meses

select * from olist_mark;