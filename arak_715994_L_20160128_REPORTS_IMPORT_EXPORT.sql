
			Select T3.Code N'کد مرکز',T3.NAME N'نام مرکز',T1.CODE N'کد انبار',T1.NAME N'نام انبار',E.Id N'شناسه حواله', E.YY N'سال مالی حواله',E.MM N'ماه',E.Serial N'سریال حواله', 
			CASE
				WHEN E.Serial = 0 then N'حواله‌های تایید نشده'
				when E.Serial > 0 and E.DocId = 0 then N'حواله‌های بدون سند' 
				else 'حواله‌های تایید شده' 
			END N'وضعیت حواله', 
			d.Id N'شناسه سند', d.DocNo N'شماره سند', d.Year N' سال مالی سند',
			CASE
				WHEN d.State is null then N'بدون سند'
				when d.State = 10  then N'پیش‌نویس'
				WHEN d.State IN (1,5) then N'رسیدگی اسناد'
				when d.State = 11 then N' شناسایی کداعتبار '
				when d.State = 4 then N' صدور چک/ثبت فیش '
				when d.State = 9 then N' مجوز صدور چک '
				else 'سایر' 
			END N'وضعیت سند',
			CASE 
				WHEN E.GoodsExportKindIndex=0 THEN N'توزیع/مصرف'
				WHEN E.GoodsExportKindIndex=6 THEN N'جابجایی کالا'
				WHEN E.GoodsExportKindIndex=7 THEN N'مرجوعی'
				WHEN E.GoodsExportKindIndex=10 THEN N'ارسال به واحد تابعه'
				WHEN E.GoodsExportKindIndex=11 THEN N'ارسالی به ستاد'
				WHEN E.GoodsExportKindIndex=12 THEN N'کسر انبار'
				WHEN E.GoodsExportKindIndex=14 THEN N'اصلاح تعداد/مقدار'
				else 'هدایا' 
			END N'نوع حواله'
			FROM dbo.STK_GoodsExport E
			join M_ORG_T3 T3 on T3.Id = E.T3Id
			LEFT OUTER JOIN dbo.ACC_AccDoc d ON d.Id = E.DocId
			left JOIN STK_Stock S ON E.StockId=S.ID
			left join  ACC_T1 T1 ON S.t1Id=T1.ID
			WHERE
			T3.code='161119'		and
			(d.Id IS NULL OR d.DocNo = 0)
			and e.yy<94
order by 1 











			select t3.Code N'کد مرکز',T3.NAME N'نام مرکز',T1.CODE N'کد انبار',T1.NAME N'نام انبار',i.Id N'شناسه رسید', i.YY N'سال مالی رسید',i.MM N'ماه',i.Serial N'سریال رسید', 
			CASE
				WHEN i.Serial = 0 then N'رسیدهای تایید نشده'
				when i.Serial > 0 and i.State = 0 then N'رسیدهای نرخ‌گذاری نشده' 
				when i.Serial > 0 and i.State = 1 and I.accdocid is null then N'رسیدهای آماده صدور سند'
				when i.Serial > 0 and i.State = 1 and I.accdocid is not null and d.DocNo = 0 then N'رسیدهای با اسناد بدون شماره'
				else 'سایر' 
			END N'وضعیت رسید', 
			d.Id N'شناسه سند', d.DocNo N'شماره سند', d.Year N'سال مالی سند',
			CASE
				WHEN d.State is null then N'بدون سند'
				when d.State = 10  then N'پیش‌نویس'
				WHEN d.State IN (1,5) then N'رسیدگی اسناد'
				when d.State = 11 then  N' شناسایی کداعتبار '
				when d.State = 4 then N' صدور چک/ثبت فیش '
				when d.State = 9 then N' مجوز صدور چک '
				when d.State in (6,7,8) then N' nahai '
				else 'سایر' 
			END N'وضعیت سند',
			CASE
				WHEN I.ImportKindIndex=0 THEN N'خرید کالا'
				WHEN I.ImportKindIndex=1 THEN N'ایجاد سوابق کالا'
				WHEN I.ImportKindIndex=6 THEN N'جابجایی کالا'
				WHEN I.ImportKindIndex=7 THEN N'برگشت از توزیع/مصرف'
				WHEN I.ImportKindIndex=9 THEN N'هدایا و کمک‌های دریافتی'
				WHEN I.ImportKindIndex=10 THEN N'دریافتی از ستاد'
				WHEN I.ImportKindIndex=11 THEN N'دریافتی از واحد'
				WHEN I.ImportKindIndex=12 THEN N'اضافه انبار'
				WHEN I.ImportKindIndex=14 THEN N'تحویل مستقیم'
				WHEN I.ImportKindIndex=15 THEN N'تحویل مستقیم به واحد'
				else 'سایر' 
			END N'نوع رسید'

			FROM dbo.STK_GoodsImport i
			join M_ORG_T3 t3 on t3.Id = i.T3Id
			LEFT OUTER JOIN dbo.ACC_AccDoc d ON d.Id = i.AccDocId
			left join  STK_Stock S ON I.StockId=S.ID
			left join  ACC_T1 T1 ON S.t1Id=T1.ID
			WHERE
			t3.code='161119' and
			(d.Id IS NULL OR d.DocNo = 0)	 
		
			and i.yy<94
			order by 1 
			
			
			
			

