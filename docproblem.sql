
SELECT
		t3.Code N'کد مرکز',
		t3.Name N'نام مرکز',
		CASE t3.Independent
			WHEN 1 THEN N'مستقل'
			ELSE N'غیرمستقل'
			END N'وضعیت مرکز',
		d.Year AS N'سال مالی',
		CAST(dr.DId AS NVARCHAR(MAX)) AS N'شناسه سند',
		dr.RowNo AS N'شماره ردیف سند',

       CASE d.DocType
			WHEN 0 THEN N'افتتاحيه حسابها'
			WHEN 1 THEN N'اختتاميه'
			WHEN 2 THEN N'سود و زيان'
			WHEN 3 THEN N'عادي'
			WHEN 4 THEN N'اصلاحي'
			WHEN 5 THEN N'سيستم اموال'
			WHEN 6 THEN N'سيستم كالا'
			WHEN 7 THEN N'سيستم بودجه و اعتبارات'
			WHEN 8 THEN N'سيستم دريافت پرداخت'
			WHEN 9 THEN N'سيستم حقوق و دستمزد'
			WHEN 10 THEN N'ايجاد سوابق اموال'
			WHEN 11 THEN N'ايجاد سوابق كالا'
			WHEN 12 THEN N'ارسالي از واحد'
			WHEN 13 THEN N'سيستم تجميع اسناد'
			END AS N'نوع سند',
			
		CASE d.state
	        
			WHEN 1 THEN N'در انتظار رسيدگی'
			WHEN 2 THEN N'واخواهی شده یا همان برگشت از رسیدگی'
			WHEN 3 THEN N'آماده تامین اعتبار'
			WHEN 4 THEN N'آماده ثبت عمليات دریافت - پرداخت'
			WHEN 5 THEN N'آماده رسیدگی نهایی'
			WHEN 6 THEN N'آماده تایيد وصول مستندات'
			WHEN 7 THEN N'آماده ارسال'
			WHEN 8 THEN N'نهایی'
			WHEN 9 THEN N'آماده تایيد مقام مجاز جهت برداشت وجه'
			WHEN 10 THEN N'آماده تایيد مقام مجاز جهت ثبت'
			WHEN 11 THEN N'آماده شناسایی کد اعتبار'
			WHEN NULL THEN N'بدون سند'
		    ELSE ''
            END AS N'وضعیت سند',

         CAST(dr.Id AS NVARCHAR(MAX)) AS N'شناسه ردیف سند',
         CASE WHEN CAST(c.Code AS NVARCHAR(MAX)) IS NULL THEN N'ندارد' ELSE CAST(c.Code AS NVARCHAR(MAX)) END AS N'کد حساب',
         c.Name N'نام حساب',
         CASE WHEN c2.HT1 = 0 THEN N'خیر' ELSE N'بله' END AS N'تفصیل یک نیاز دارد',
         dr.T1Id N'شناسه تفصیل یک',
         CASE WHEN c2.HT2 = 0 THEN N'خیر' ELSE N'بله' END AS N'تفصیل دو نیاز دارد',
         dr.T2Id AS N'شناسه تفصیل دو',
         CASE WHEN c2.HT3 = 0 THEN N'خیر' ELSE N'بله' END AS N'تفصیل سه نیاز دارد',
         dr.T3Id AS N'شناسه تفصیل سه',
         CASE WHEN c2.Hproj = 0 THEN N'خیر' ELSE N'بله' END AS N'پروژه نیاز دارد', 
         ProjectId AS N'شناسه پروژه',
         CASE WHEN c2.HasCheck = 0 THEN N'خیر' ELSE N'بله' END AS N'چک نیاز دارد', 
         dr.CheckId AS N'شناسه چک',
         dr.ChekNo AS N'شماره چک',
         dr.Document AS N'شماره فیش',
         CASE WHEN c2.HCC = 0 THEN N'خیر' ELSE N'بله' END AS N'مرکز هزینه',
         CostCenterId AS N'شناسه مرکز هزینه',
         UnitId AS N'واحد سازمانی'

FROM dbo.ACC_AccDocRow AS Dr
LEFT OUTER JOIN dbo.M_ACC_Codes2 AS c2 ON dr.CodeId = c2.MId 					
LEFT OUTER JOIN dbo.M_ACC_Codes As c ON c2.MId = c.Id
INNER JOIN ACC_AccDoc d ON dr.DId = d.Id
INNER JOIN M_ORG_T3 t3 ON t3.Id = d.T3Id
WHERE d.State NOT IN (6, 7, 8) AND
		(
			c2.MId IS NULL 
		OR 
			(c2.HT1 = 1 AND dr.T1Id IS NULL)
		OR
			(c2.HCC = 1) AND (dr.CostCenterId IS NULL or dr.UnitId IS NULL)
		OR
			(c2.HT3 = 1 AND dr.T3Id IS NULL)
		OR
			(c2.HProj = 1 AND dr.ProjectId IS NULL)
        OR
			(c2.HT2 = 1 AND dr.T2Id IS NULL)
		OR
			(c2.HasCheck = 1 AND (dr.CheckId IS NULL AND dr.ChekNo IS NULL AND dr.Document IS NULL))
		)
		AND d.Id in (70073 ,69113, 69108)
/*
کد مرکز	نام مرکز	وضعیت مرکز	سال مالی	شناسه سند	شماره ردیف سند	نوع سند	وضعیت سند	شناسه ردیف سند	کد حساب	نام حساب	تفصیل 1	شناسه تفصیل 1	تفصیل 2	شناسه تفصیل 2	تفصیل 3	شناسه تفصیل 3	پروژه	شناسه پروژه	چک نیاز دارد	شناسه چک	شماره چک	شماره فیش	مرکز هزینه	شناسه مرکز هزینه	واحد سازمانی
194	دانشگاه علوم پزشکي و خدمات درماني تربت حيدريه	مستقل	93	69108	1	ارسالي از واحد	آماده رسیدگی نهایی	7956881	180109	پيش پرداخت خريد اقلام سرمايه‌اي	بله	4839	بله	1238	خیر	300586	بله	NULL	خیر	NULL			خیر	NULL	NULL
194	دانشگاه علوم پزشکي و خدمات درماني تربت حيدريه	مستقل	93	69113	1	ارسالي از واحد	آماده رسیدگی نهایی	7957032	180109	پيش پرداخت خريد اقلام سرمايه‌اي	بله	4839	بله	1238	خیر	300586	بله	NULL	خیر	NULL			خیر	NULL	NULL
194	دانشگاه علوم پزشکي و خدمات درماني تربت حيدريه	مستقل	93	70073	2	ارسالي از واحد	آماده رسیدگی نهایی	7968658	180109	پيش پرداخت خريد اقلام سرمايه‌اي	بله	4839	بله	1238	خیر	300586	بله	NULL	خیر	NULL			خیر	NULL	NULL

*/
