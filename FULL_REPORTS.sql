SELECT LEFT(T3.CODE, 3) AS N'کد ستاد',
       T3.CODE AS N'کد مرکز',
	   D.Year N'سال مالی',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '1%' or B.Code like '2%' AND D.ID=A.DID
	   ) N'جمع کل دارایی‌ها',
	   --N'دارايي هاي جاري :',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '11%' AND B.Code like '10%' AND D.ID=A.DID
	   ) N'موجودی نقد',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '13%' AND D.ID=A.DID
	   ) N'سرمایه گذاری های کوتاه مدت',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '14%'AND D.ID=A.DID
	   ) N'حساب ها و اسناد دریافتنی',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '15%' AND D.ID=A.DID
	   ) N'سایر حساب ها و اسناد دریافتنی',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '16%' AND B.Code like '209801' AND D.ID=A.DID
	   ) N'موجودی کالا',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '17%' AND B.Code like '18%' AND D.ID=A.DID
	   ) N'سفارشات و پیش پرداخت ها',
	   (
	   SELECT SUM(A.Bed+A.NBed-A.Bes-A.NBes)
	   FROM ACC_AccDocRow AS A
	   LEFT JOIN M_ACC_Codes AS B ON A.CodeId = B.Id
	   WHERE B.Code like '1%' AND D.ID=A.DID
	   ) N'جمع دارایی‌های جاری'


FROM M_ORG_T3 AS T3
     LEFT JOIN ACC_AccDoc AS D ON T3.ID = D.T3Id
     LEFT JOIN ACC_AccDocRow AS DR ON D.ID = DR.DID
     LEFT JOIN M_ACC_Codes AS C ON DR.CodeId = C.Id
     LEFT JOIN CRDT_T2 AS T2 ON DR.T2ID = T2.ID
WHERE T3.Code = '255110' 

GROUP BY LEFT(T3.CODE, 3),T3.CODE, D.Year

