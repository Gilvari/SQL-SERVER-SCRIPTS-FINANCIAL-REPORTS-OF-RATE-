select distinct d.DocNo,d.DocType,d.t3id,d.id,t1.id t1id,t1.code t1code,t1.name t1name,t1.T3Id, dr.Id drid , dr.T1Id
from ACC_AccDoc d
inner join ACC_AccDocRow dr on dr.DId=d.Id
inner join ACC_T1 t1 on t1.Id=dr.T1Id
where d.T3Id<> t1.t3id and DocType<>12 and docno <900000 and YEAR in (94,95) and DocNo!=1 
and d.Id not in 
(select f.id from ACC_AccDoc f join ACC_AccDocRow fr on f.id=fr.did where f.DocType=13 and fr.T3Id is not null and 
f.T3Id in (select id from M_ORG_T3 where Code='362' )) 