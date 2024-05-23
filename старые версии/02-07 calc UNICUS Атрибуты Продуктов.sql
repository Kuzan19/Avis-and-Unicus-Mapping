/**********
Расчет и сборка таблиц общего пользования

Формирование таблицы с атрибутами страховых продуктов в привязке к варианту договора - "UNICUS Атрибуты Продуктов"

**********/

--TRUNCATE TABLE T2_COMMON."UNICUS Атрибуты Продуктов";

INSERT INTO T2_COMMON."UNICUS Атрибуты Продуктов"
WITH PA AS (
SELECT
	PRODUCT_ADD_ID, 
	PRODUCT_ADD_NAME, 
	REGISTER_LIST_ID, 
	PRODUCT_ADD_CODE,
	PRODUCT_ID
FROM STG_UNC.PRODUCT_ADD
WHERE UPPER(PRODUCT_ADD_NAME) IN (
'ID РАСЧЕТА ИЗ ILOG',
'IMEI БЛОКА, 15 ИЛИ 17 ЦИФР',
'01.ПОВЫШЕННЫЕ РИСКИ',
'03.ТЕРРИТОРИЯ СТРАХОВАНИЯ',
'№ БЛАНКА БСО',
'АГЕНТ ПО СОПРОВОЖДЕНИЮ',
'АССИСТАНС',
'БАНК/ЛИЗИНГ',
'БЕЗБУМАЖНЫЙ ПОЛИС',
'БИЗНЕС-ГРУППА',
'БРОКЕР',
'ВАРИАНТ ВЫПЛАТЫ ПО РИСКУ "ВРЕМЕННАЯ УТС"',
'ВАРИАНТ ВЫПЛАТЫ ПО РИСКУ ТРАВМА ОТ НС',
'ВАРИАНТ СТРАХОВАНИЯ ДЛЯ МЕД. РАСХОДОВ',
'ВАРИАНТ СТРАХОВАНИЯ ДЛЯ ОТКАЗА ОТ ПОЕЗДКИ',
'ВЕЛИЧИНА ФРАНШИЗЫ',
'ВИД ТРАНСПОРТА (ПРИ ТРАНСПОРТИРОВКЕ)',
'ВРЕМЕННАЯ ФРАНШИЗА, ДНЕЙ',
'ВЫПЛАТА НА ОСНОВАНИИ КАЛЬКУЛЯЦИИ СТРАХОВЩИКА /НЕЗАВИСИМОЙ ЭКСПЕРТИЗЫ -  ДА/НЕТ',
'ВЫПЛАТА ТОЛЬКО НА ОСНОВАНИИ КАЛЬКУЛЯЦИИ СТРАХОВЩИКА/НЕЗАВИСИМОЙ ЭКСПЕРТИЗЫ - ДА/НЕТ',
'ДАТА ЗАКЛЮЧЕНИЯ КРЕДИТНОГО ДОГОВОРА',
'ДОГОВОР КАСКО = ДАТА ОТ',
'ДОГОВОР КАСКО = НОМЕР ДОГОВОРА',
'ДОГОВОР КАСКО = СТРАХОВЩИК ПО ДОГОВОРУ',
'ДОПОЛНИТЕЛЬНЫЙ ПАКЕТ УСЛУГ',
'ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ',
'ЕГАРАНТ',
'ЗНАЧЕНИЕ ФРАНШИЗЫ',
'ИСКЛЮЧЕНИЯ: БОЙ СТЕКОЛ',
'КАТЕГОРИЯ РИСКА GAP',
'КЛАСС НА НАЧАЛО СРОКА СТРАХОВАНИЯ',
'КОЛ-ВО ДНЕЙ MULTI',
'КОЛИЧЕСТВО ДНЕЙ MULTI',
'КОЛИЧЕСТВО ПАССАЖИРОВ',
'КОЛИЧЕСТВО ПРОИЗОШЕДШИХ СТРАХОВЫХ СЛУЧАЕВ С ТРАНСПОРТНЫМ СРЕДСТВОМ ЗА ВРЕМЯ ДЕЙСТВИЯ ПРЕДЫДУЩЕГО ДОГОВОРА СТРАХОВАНИЯ',
'ЛИЦА, ДОПУЩЕННЫЕ К УПРАВЛЕНИЮ',
'МУЛЬТИДРАЙВ_СТАЖ',
'МУЛЬТИДРАЙВ_ВОЗРАСТ',
'МАКСИМАЛЬНО ВОЗМОЖНЫЙ УБЫТОК (PML) В ВАЛЮТЕ ДОГОВОРА ',
'МАРКА МОДЕЛЬ МОДИФИКАЦИЯ ТС',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ ПРОДУКТА',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ ПРОДУКТА (143)',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ ПРОДУКТА НС',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ_212',
'МАРШРУТ ПЕРЕВОЗКИ',
'МЕСТОНАХОЖДЕНИЕ: АДРЕС',
'МЕСТО СТРАХОВАНИЯ',
'НАИМЕНОВАНИЕ ГРУЗА',
'НАИМЕНОВАНИЕ ДИСКОНТНОЙ ПРОГРАММЫ',
'НАИМЕНОВАНИЕ КОНТРАГЕНТА',
'НАИМЕНОВАНИЕ СПЕЦИАЛЬНОЙ ПРОГРАММЫ',
'НАЛИЧИЕ ГАРАНТИИ',
'НАЛИЧИЕ ГРУБЫХ НАРУШЕНИЙ ПРАВИЛ СТРАХОВАНИЯ',
'НАЧАЛЬНЫЙ ПРОБЕГ',
'НОМЕР ЗАКЛАДНОЙ',
'НОМЕР КРЕДИТНОГО ДОГОВОРА',
--'НАИМЕНОВАНИЯ ПРОГРАММ СТРАХОВАНИЯ АВТО',
'НАИМЕНОВАНИЕ СРО (СПРАВОЧНИК)',
--'НАИМЕНОВАНИЕ САМОРЕГУЛИРУЕМОЙ ОРГАНИЗАЦИИ',
'(НЕ ИСП.) НАИМЕНОВАНИЕ СРО',
'ОБЩАЯ АКВИЗИЦИЯ',
'ОГРАНИЧЕНИЕ ПРОБЕГА',
'ОЖИДАЕМАЯ ПРЕМИЯ, РУБ.',
'ОТРАСЛИ СПЕЦТЕХНИКИ',
'ПЕРИОД ИСПОЛЬЗОВАНИЯ ТС',
'ПЕРИОДИЧНОСТЬ ОПЛАТЫ',
'ПОЛИС ВСТУПАЕТ В ДЕЙСТВИЕ С МОМЕНТА ОПЛАТЫ СТРАХОВОЙ ПРЕМИИ- ДА/НЕТ',
'ПРЕДЫДУЩИЙ ДОГОВОР',
'ПРЕДЫДУЩИЙ СТРАХОВЩИК',
'ПРИЗНАК СТРАХОВАНИЯ',
'ПРОГРАММА АБ',
'ПРОГРАММА РБ',
'РЕМОНТ НА СТОА ДИЛЕРА – В ТЕЧЕНИЕ СРОКА ГАРАНТИЙНОГО ОБСЛУЖИВАНИЯ ТС, УСТАНОВЛЕННОГО ЗАВОДОМ-ИЗГОТОВИТЕЛЕМ',
'РЕМОНТ НА СТОА ДИЛЕРА - ДА/НЕТ',
'РЕМОНТ НА СТОА ПО ВЫБОРУ СТРАХОВАТЕЛЯ - ДА/НЕТ',
'РЕМОНТ НА СТОА, РЕКОМЕНДОВАННОЙ СТРАХОВЩИКОМ - ДА/НЕТ',
'СЕГМЕНТ АВИАТРАНСПОРТА',
'СЕТЬ ПРОДАЖ',
'СЛЕДОВАНИЕ К МЕСТУ РЕГИСТРАЦИИ',
'СПЕЦИАЛЬНАЯ ПРОГРАММА РАССРОЧКИ ПЛАТЕЖЕЙ (НАИМЕНОВАНИЕ)',
'СПЕЦИАЛЬНЫЕ ПРОГРАММЫ GAP',
'СТРАНА',
'СТРАНА РЕГИСТРАЦИИ ТС',
'ТЕРРИТОРИЯ ПРЕИМУЩЕСТВЕННОГО ИСПОЛЬЗОВАНИЯ ТС',
'ТЕРРИТОРИЯ ПРЕИМУЩЕСТВЕННОГО ИСПОЛЬЗОВАНИЯ ТС ПО ФИАС',
'ТЕРРИТОРИЯ СТРАХОВАНИЯ',
'ТИП ФРАНШИЗЫ',
'ТРАНСПОРТНОЕ СРЕДСТВО СДАЕТСЯ В АРЕНДУ',
'ТС ИСПОЛЬЗУЕТСЯ С ПРИЦЕПОМ',
'ЦЕЛЬ ИСПОЛЬЗОВАНИЯ ТС',
'1.ЖД: ДАЛЬНЕЕ СЛЕДОВАНИЕ',
'2.ЖД: ПРИГОРОДНОЕ НАПРАВЛЕНИЕ',
'3.ВОЗДУХ: ВСЕ ВИДЫ ПЕРЕВОЗОК',
'4.ВОДНЫЙ (МОРЕ): ВСЕ ВИДЫ ПЕРЕВОЗОК',
'5.ВОДНЫЙ (КАБОТАЖНЫЙ): ПРИГОРОД, ЭКСКУРСИОННЫЙ, МЕСТНЫЕ',
'6.ВОДНЫЙ (КАБОТАЖНЫЙ): ТУРИСТИЧЕСКИЕ ПЕРЕВОЗКИ',
'7.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ (МЕЖГОРОД И МЕЖДУНАРОДН.)',
'8.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ (ПРИГОРОД)',
'9.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ(ГОР. ПЕРЕВОЗКИ ПО ЗАКАЗАМ И РЕГ. С ПОСАД./ВЫСАД. В РАЗРЕШ. ПДД МЕСТАХ ПО РЕГ. МАРШРУТАМ)',
'10.ГОРОДСКОЙ НАЗЕМНЫЙ ЭЛЕКТРОТРАНСПОРТ: ТРОЛЛЕЙБУСЫ',
'11.ГОРОДСКОЙ НАЗЕМНЫЙ ЭЛЕКТРОТРАНСПОРТ: ТРАМВАЙ',
'12.ВНЕУЛИЧНЫЙ ТРАНСПОРТ: ВСЕ ВИДЫ ПЕРЕВОЗОК',
'13.АВТО: АВТОБУСНЫЕ РЕГУЛ. ВНУТРИ ГОРОДА ПЕРЕВОЗКИ(С ПОСАДКОЙ И ВЫСАДКОЙ В УСТАН. ОСТАН. ПУНКТАХ)',
'14.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ (МЕЖДУНАРОД.) ',
'15.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ (ГОРОД, ПО ЗАКАЗАМ)',
'16.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ (МЕЖГОРОД) ',
'17.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ(ГОР. ПЕРЕВОЗКИ РЕГ. С ПОСАД./ВЫСАД. В РАЗРЕШ. ПДД МЕСТАХ ПО РЕГ. МАРШРУТАМ)',
'18.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ (МЕЖГОРОД И МЕЖДУНАРОДН.; А ТАКЖЕ ПРИГОРОД И ГОРОД ПО ЗАКАЗАМ)',
'19.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ(ПРИГОРОД;А ТАКЖЕ ГОР.ПО ЗАКАЗ. И ГОР.РЕГ.ПЕРЕВОЗКИ С ПОСАД./ВЫСАД. В УСТ.ОСТ.ПУНКТАХ)',
'20.АВТО: АВТОБУСНЫЕ ПЕРЕВОЗКИ(ГОРОД,С ПОСАД./ВЫСАД. В РАЗР. МЕСТАХ;А ТАКЖЕ ПРИГОРОД И ГОРОД ПО ЗАКАЗАМ)',
'21.АВТО: АВТОБУСНЫЕ РЕГ. ВНУТРИ ГОР. ПЕРЕВОЗКИ(С ПОСАД./ВЫСАД. В УСТ.ОСТ.ПУНКТАХ);А ТАКЖЕ ГОР. ПО ЗАКАЗАМ'
)
)
SELECT
	CADD.CONTRACT_VARIANT_ID, 
	REGEXP_REPLACE(NVL(PANMAP.NEW_NAME, PA.PRODUCT_ADD_NAME), '[<>:"/\|?*'';]', '') PRODUCT_ADD_NAME,
	NVL(RD.NAME, NVL(CADD.VALUE_NAME, CADD.VALUE_TEXT)) PRODUCT_ADD_VALUE
FROM "STG_UNC".CONTRACT_ADD CADD
	JOIN PA ON PA.PRODUCT_ADD_ID = CADD.PRODUCT_ADD_ID
	JOIN STG_UNC.CONTRACT_VARIANT CV ON CV.CONTRACT_VARIANT_ID = CADD.CONTRACT_VARIANT_ID AND CV.PRODUCT_ID = PA.PRODUCT_ID
		LEFT JOIN "STG_UNC".REGISTER_DATA RD ON RD.REGISTER_LIST_ID = PA.REGISTER_LIST_ID AND RD.CODE = CADD.VALUE_TEXT
		LEFT JOIN (
			SELECT 'Кол-во дней MULTI' OLD_NAME, 'Количество дней MULTI' NEW_NAME
			UNION
			SELECT 'Маркетинговое наименование продукта (143)' OLD_NAME, 'Маркетинговое наименование продукта' NEW_NAME
			UNION
			SELECT 'Маркетинговое наименование продукта НС' OLD_NAME, 'Маркетинговое наименование продукта' NEW_NAME
			UNION
			SELECT 'Маркетинговое наименование_212' OLD_NAME, 'Маркетинговое наименование продукта' NEW_NAME
		) PANMAP ON PANMAP.OLD_NAME = PA.PRODUCT_ADD_NAME;

