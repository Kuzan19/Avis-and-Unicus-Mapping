--// Формируем таблицу на основе таблицы STG_FILES."092_Эталон ЮНИКУС_ИТОГ"//--
CREATE OR REPLACE TABLE IDM_MGMT_MAP.UNC_UU_MAP_ETALON (
    "Корневой Полис ID" DECIMAL(36,10),
    "Корневой Договор Номер" VARCHAR(64),
    "АВС" VARCHAR(8),
    "ЦФО" VARCHAR(8),
    "КП" VARCHAR(8),
    "Продукт OEBS" CHAR(7),
    "Год Договора OEBS" CHAR(7),
    "Код ПП" VARCHAR(16),
    "Эталон" CHAR(1)
);

/**********
Скрипт для обновления данных в таблице ETALON

--// Добавляем данные в таблицу UNC_UU_MAP_ETALON//--
INSERT INTO IDM_MGMT_MAP.UNC_UU_MAP_ETALON
SELECT
    CONTRACT_NUMBER_005 "Корневой Договор Номер",
    POLICY_UNIQUE_ID_036 "Корневой Полис ID",
    "АВС 2011 мэп" "АВС",
    "ЦФО 2012 мэп" "ЦФО",
    "КП 2011 мэп" "КП",
    "Код ПП",
    "Продукт OEBS",
    "Год договора OEBS",
    '1' "Эталон"
FROM STG_FILES."092_Эталон ЮНИКУС_ИТОГ"
;

**********/

--// Формируем таблицу эквивалент "Доп Мэппинг 2011"//--
CREATE OR REPLACE TABLE IDM_MGMT_MAP.UNC_UU_MAP_ADDON (
    "Корневой Полис ID" DECIMAL(36,10),
    "Корневой Договор Номер" VARCHAR(64),
    "АВС" VARCHAR(8),
    "ЦФО" VARCHAR(8),
    "КП" VARCHAR(8),
    "Продукт OEBS" CHAR(7),
    "Год Договора OEBS" CHAR(7),
    "Код ПП" VARCHAR(16),
    "Эталон" CHAR(1)
);

--// Формируем таблицу эквивалент "Итого Мэппинг 2011" //--
CREATE OR REPLACE TABLE IDM_MGMT_MAP.UNC_UU_MAP_POLICY (
    "Корневой Полис ID" DECIMAL(36,10),
    "Корневой Договор Номер" VARCHAR(64),
    "АВС" VARCHAR(8),
    "ЦФО" VARCHAR(8),
    "КП" VARCHAR(8),
    "Продукт OEBS" CHAR(7),
    "Год Договора OEBS" CHAR(7),
    "Код ПП" VARCHAR(16),
    "Эталон" CHAR(1)
);

--// Формируем таблицу эквивалент "Итого Мэппинг" //--
CREATE OR REPLACE TABLE IDM_MGMT_MAP.UNC_UU_MAP_CONTRACT (
    "Корневой Полис ID" DECIMAL(36,10),
    "Корневой Договор Номер" VARCHAR(64),
    "АВС" VARCHAR(8),
    "ЦФО" VARCHAR(8),
    "КП" VARCHAR(8),
    "Продукт OEBS" CHAR(7),
    "Год Договора OEBS" CHAR(7),
    "Код ПП" VARCHAR(16),
    "Уникальный" VARCHAR(2)
);

--// Добавляем данные в таблицу UNC_UU_MAP_ADDON//--
INSERT INTO IDM_MGMT_MAP.UNC_UU_MAP_ADDON (
    "Корневой Полис ID",
    "Корневой Договор Номер",
    "АВС",
    "ЦФО",
    "КП",
    "Продукт OEBS",
    "Год Договора OEBS",
    "Код ПП",
    "Эталон"
)

WITH INN_CODE AS (
SELECT
    SUBJECT_ID,
    INN "Страхователь ИНН"
FROM STG_UNC.JURIDICAL_PERSON

UNION ALL

SELECT
    SUBJECT_ID,
    INN
FROM STG_UNC.PHYSICAL_PERSON PP
WHERE NOT EXISTS(SELECT 1 FROM STG_UNC.JURIDICAL_PERSON JP WHERE JP.SUBJECT_ID = PP.SUBJECT_ID)
),

BASE AS (
SELECT
	RZ.POLICY_UNIQUE_ID_036,
	RZ.ENTRY_ID,
	RZ.POLICY_ID_100,
	CON.CONTRACT_VARIANT_ID
FROM STG_UNC.XX_ALFA_RZ_CONTRACT RZ
    LEFT JOIN STG_FILES."092_Эталон ЮНИКУС_ИТОГ" ET ON ET.POLICY_UNIQUE_ID_036 = RZ.POLICY_UNIQUE_ID_036
    LEFT JOIN STG_UNC.INSURANCE_OBJECT IO ON IO.INSURANCE_OBJECT_ID = RZ.POLICY_ID_100
        LEFT JOIN STG_UNC.CONTRACT_CONDITION CON ON CON.CONTRACT_CONDITION_ID = IO.CONTRACT_CONDITION_ID
WHERE RZ.PREMIUM_CHARGE_DATE_051 >= DATE '2024-01-01 01:00:00.0' AND ET."АВС 2011 мэп" IS NULL
),

LAST_POLICY AS (
SELECT
	POLICY_UNIQUE_ID_036,
	MAX(ENTRY_ID) ENTRY_ID
FROM BASE
WHERE POLICY_UNIQUE_ID_036 = POLICY_ID_100
GROUP BY POLICY_UNIQUE_ID_036

UNION ALL

SELECT
	POLICY_UNIQUE_ID_036,
	MAX(ENTRY_ID)
FROM BASE T1
WHERE NOT EXISTS (SELECT
                	1
                FROM BASE T2
                WHERE T2.POLICY_UNIQUE_ID_036 = T1.POLICY_ID_100 AND T2.POLICY_UNIQUE_ID_036 = T2.POLICY_ID_100
                )
GROUP BY POLICY_UNIQUE_ID_036
),

PA AS (
SELECT
	PRODUCT_ADD_ID,
	PRODUCT_ADD_NAME,
	REGISTER_LIST_ID,
	PRODUCT_ADD_CODE,
	PRODUCT_ID
FROM STG_UNC.PRODUCT_ADD
WHERE UPPER(PRODUCT_ADD_NAME) IN (
'БАНК/ЛИЗИНГ',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ ПРОДУКТА',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ ПРОДУКТА (143)',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ ПРОДУКТА НС',
'МАРКЕТИНГОВОЕ НАИМЕНОВАНИЕ_212',
'НАИМЕНОВАНИЕ ДИСКОНТНОЙ ПРОГРАММЫ',
'СПЕЦИАЛЬНОЕ УСЛОВИЕ'
)),

PROD_ATTR AS (
SELECT
    CASE
        WHEN PRODUCT_ADD_NAME ='БанкЛизинг' THEN PRODUCT_ADD_VALUE
    END 'Атр ПРД Банк/Лизинг',

    CASE
        WHEN PRODUCT_ADD_NAME ='Наименование дисконтной программы' THEN PRODUCT_ADD_VALUE
    END 'Атр ПРД Наименование дисконтной программы',

    CASE
        WHEN PRODUCT_ADD_NAME ='Маркетинговое наименование продукта' THEN PRODUCT_ADD_VALUE
    END 'Атр ПРД Маркетинговое наименование продукта',

    CASE
        WHEN PRODUCT_ADD_NAME ='Специальное условие' THEN PRODUCT_ADD_VALUE
    END 'Атр ПРД Специальное условие'
FROM (
    SELECT
    	CADD.CONTRACT_VARIANT_ID,
    	REGEXP_REPLACE(NVL(PANMAP.NEW_NAME, PA.PRODUCT_ADD_NAME), '[<>:"/\|?*'';]', '') PRODUCT_ADD_NAME,
    	NVL(RD.NAME, NVL(CADD.VALUE_NAME, CADD.VALUE_TEXT)) PRODUCT_ADD_VALUE,
    	BASE.POLICY_ID_100
    FROM "STG_UNC".CONTRACT_ADD CADD
        JOIN BASE ON BASE.CONTRACT_VARIANT_ID = CADD.CONTRACT_VARIANT_ID
    	JOIN PA ON PA.PRODUCT_ADD_ID = CADD.PRODUCT_ADD_ID
    	JOIN STG_UNC.CONTRACT_VARIANT CV ON CV.CONTRACT_VARIANT_ID = CADD.CONTRACT_VARIANT_ID AND CV.PRODUCT_ID = PA.PRODUCT_ID
    		LEFT JOIN "STG_UNC".REGISTER_DATA RD ON RD.REGISTER_LIST_ID = PA.REGISTER_LIST_ID AND RD.CODE = CADD.VALUE_TEXT
    		LEFT JOIN (
    			SELECT 'Маркетинговое наименование продукта (143)' OLD_NAME, 'Маркетинговое наименование продукта' NEW_NAME
    			UNION
    			SELECT 'Маркетинговое наименование продукта НС' OLD_NAME, 'Маркетинговое наименование продукта' NEW_NAME
    			UNION
    			SELECT 'Маркетинговое наименование_212' OLD_NAME, 'Маркетинговое наименование продукта' NEW_NAME
    		) PANMAP ON PANMAP.OLD_NAME = PA.PRODUCT_ADD_NAME
))

--PROD_ATTR AS (
--SELECT DISTINCT
--    BASE.POLICY_ID_100,
--    AP_1.PRODUCT_ADD_VALUE "Атр ПРД Банк/Лизинг",
--    AP_2.PRODUCT_ADD_VALUE "Атр ПРД Наименование дисконтной программы",
--    AP_3.PRODUCT_ADD_VALUE "Атр ПРД Маркетинговое наименование продукта",
--    AP_4.PRODUCT_ADD_VALUE "Атр ПРД Специальное условие"
--FROM BASE
--    LEFT JOIN PROD_UNICUS AP_1 ON AP_1.CONTRACT_VARIANT_ID = BASE.CONTRACT_VARIANT_ID AND AP_1.PRODUCT_ADD_NAME = 'БанкЛизинг'
--    LEFT JOIN PROD_UNICUS AP_2 ON AP_2.CONTRACT_VARIANT_ID = BASE.CONTRACT_VARIANT_ID AND AP_2.PRODUCT_ADD_NAME = 'Наименование дисконтной программы'
--    LEFT JOIN PROD_UNICUS AP_3 ON AP_3.CONTRACT_VARIANT_ID = BASE.CONTRACT_VARIANT_ID AND AP_3.PRODUCT_ADD_NAME = 'Маркетинговое наименование продукта'
--    LEFT JOIN PROD_UNICUS AP_4 ON AP_4.CONTRACT_VARIANT_ID = BASE.CONTRACT_VARIANT_ID AND AP_4.PRODUCT_ADD_NAME = 'Специальное условие'
--)

SELECT
    LP.POLICY_UNIQUE_ID_036 "Корневой Полис ID",
    RZ.CONTRACT_NUMBER_005 "Корневой Договор Номер",

    --Каско Go на АВС е-гарант
    CASE
        WHEN PA."Атр ПРД Маркетинговое наименование продукта" = 'КАСКОGO' THEN 'B104'
    	ELSE ABC."Код OEBS АВС 2011"
    END "АВС",

    CFO."Код OEBS ЦФО 2011" "ЦФО",
    --Корр-ка канала, выделение агрегаторов и перенос на е-гарант
    CASE
        WHEN KP."Код OEBS КП 2011" = 'K402' AND (
            (ABC."Код OEBS АВС 2011" = 'B103' AND SUB.SUBJECT_NAME <> 'Горин Александр Эдуардович') OR
            (ABC."Код OEBS АВС 2011" = 'B104' AND SUB.SUBJECT_NAME <> 'Горин Александр Эдуардович') OR
            (PA."Атр ПРД Маркетинговое наименование продукта" = 'КАСКОGO')
        ) THEN 'K401'
        WHEN KP."Код OEBS КП 2011" = 'B104' AND
            (RZ.CONTRACT_TYPE_118 = '3' OR
            (KP."Код OEBS КП 2011" = 'K402' AND
            SUB.SUBJECT_NAME = 'Горин Александр Эдуардович')
        ) THEN 'K305'
    END "КП",

    --//Определение продукта OEBS
    CASE
    	--Каско
    	WHEN ABC."Код OEBS АВС 2011" = 'B101' THEN (
    		CASE
    		    WHEN RZ.PRODUCT_CODE_034 = '212' THEN 'B101003'
       			WHEN PA."Атр ПРД Маркетинговое наименование продукта" = 'КАСКОGO' THEN 'B104008'
       			WHEN RZ.CONTRACT_TYPE_092 = 'Пролонгированный' THEN 'B101002'
       	 		ELSE 'B101000'
    		END
    		)

    	--GAP
    	WHEN ABC."Код OEBS АВС 2011" = 'B102' THEN 'B102001'

    	----ОСАГО
        WHEN ABC."Код OEBS АВС 2011" = 'B103' THEN (
            CASE
                WHEN PA."Атр ПРД Наименование дисконтной программы" LIKE '%Переход из другой СК%' THEN 'B103005'
                WHEN PA."Атр ПРД Наименование дисконтной программы" LIKE '%ReBuy%' THEN 'B103006'
                WHEN RZ.INSURER_SUBJECT_TYPE_072 = 'ЮРИДИЧЕСКОЕ_ЛИЦО' AND RZ.CONTRACT_TYPE_092 = 'Пролонгированный' THEN 'B103004'
                WHEN RZ.INSURER_SUBJECT_TYPE_072 = 'ЮРИДИЧЕСКОЕ_ЛИЦО' AND RZ.CONTRACT_TYPE_092 != 'Пролонгированный' THEN 'B103002'
                WHEN RZ.CONTRACT_TYPE_092 = 'Пролонгированный' THEN 'B103003'
                WHEN RZ.CONTRACT_TYPE_092 != 'Пролонгированный' THEN 'B103001'
            END
            )

    	--е-гарант
        WHEN ABC."Код OEBS АВС 2011" = 'B104' THEN (
            CASE
            	WHEN 'Специальное условие' IS NOT NULL THEN 'B104006'
            	WHEN 'Атр ПРД Маркетинговое наименование продукта' = 'КАСКОGO' THEN 'B104008'
            	WHEN KP."Код OEBS КП 2011" <> 'K402' THEN 'B104003'
            	WHEN SUB.SUBJECT_NAME = 'Горин Александр Эдуардович' THEN 'B104004'
        		ELSE 'B104005'
    		END)

    	--ВЗР
        WHEN ABC."Код OEBS АВС 2011" = 'B302' THEN 'B302000'

    	--Грузы
    	WHEN ABC."Код OEBS АВС 2011" = 'B204' THEN (
        	CASE
            	WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%ЖД транспорт%' OR
                	RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Контейнер%' THEN 'B204001'
            	WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 = 'ГО перевозчика обязат/общий' AND
            		RZ.CONTRACT_TYPE_118 = 3 THEN 'B204005'
            	WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 = 'ГО перевозчика обязат/общий' AND
                		RZ.CONTRACT_TYPE_118 != 3 THEN 'B204003'
    			ELSE 'B101000'
    		END
    		)

    	--ДМС
    	WHEN ABC."Код OEBS АВС 2011" = 'B301' THEN (
    	    CASE
    	        WHEN RZ.PRODUCT_CODE_034 IN ('204', '238', '281', '282', '283', '459', '460') THEN 'B301001'
    	        WHEN RZ.CONTRACT_NUMBER_005 LIKE '%/240/%' AND NOT
    	         RZ.CONTRACT_NUMBER_005 LIKE '%/045/240/%' THEN 'B301009'
    	        WHEN RZ.CONTRACT_NUMBER_005 LIKE '%/431/%' AND NOT
    	         RZ.CONTRACT_NUMBER_005 LIKE '%/045/431/%' THEN 'B301010'
    	        ELSE 'B301000'
    	    END
    	    )

        --ИФЛ
        WHEN ABC."Код OEBS АВС 2011" = 'B106' THEN (
            CASE
                WHEN RZ.PRODUCT_CODE_034 = '363' OR RZ.PRODUCT_CODE_034 = '370' THEN 'B106002'
                WHEN RZ.PRODUCT_CODE_034 = '360' THEN 'B106003'
                WHEN UPPER(RZ.AGENT_012) LIKE '%ЭЛЬДОРАДО%' OR RZ.AGENT_012 LIKE '%MBM%' AND
                 CFO."Код OEBS ЦФО 2011" LIKE '%C408%' THEN 'B106004'
                WHEN UPPER(RZ.AGENT_012) LIKE '%РУССКАЯ ТЕЛEФОННАЯ КОМПАНИЯ%' THEN 'B106005'
                WHEN RZ.AGENT_012 LIKE '%Мегафон Ритейл%' THEN 'B106006'
                WHEN RZ.AGENT_012 LIKE '%М.видео Менеджмент%' OR RZ.AGENT_012 LIKE '%MBM%' AND NOT
                 CFO."Код OEBS ЦФО 2011" LIKE '%C408%' THEN 'B106007'
                WHEN RZ.AGENT_012 LIKE '%Вымпел-Коммуникации%' THEN 'B106008'
                WHEN RZ.AGENT_012 LIKE '%Сеть Связной%' THEN 'B106009'
                ELSE 'B106000'
            END
            )

        --Ответственность
        WHEN ABC."Код OEBS АВС 2011" = 'B202' THEN (
            CASE
                WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%ГО ОПО%' THEN
                    CASE
                        WHEN RZ.CONTRACT_TYPE_118 = 3 THEN 'B202015' ELSE 'B202014'
                    END
                WHEN RZ.CONTRACT_TYPE_118 = 3 THEN 'B202003'
                WHEN RZ.PRODUCT_CODE_034 = '963' OR
                    RZ.PRODUCT_CODE_034 = '788' OR
                    RZ.PRODUCT_CODE_034 = '850'
                    THEN 'B202001'
                WHEN RZ.PRODUCT_CODE_034 IN
                    ('929', '755', '779', '791', '924', '392', '401', '854', '889', '447', '435', '924') OR
                    (RZ.PRODUCT_CODE_034 IN ('318', '319') AND
                        RZ.INSURANCE_OBJECT_TYPE_NAME_040 = 'ГО за вред третьим лицам/общий') OR
                    (RZ.PRODUCT_CODE_034 = '319' AND RZ.INSURANCE_OBJECT_TYPE_NAME_040 IN
                        ('ГО загрязнение/общий', 'ГО работодателей/общий'))
                    THEN 'B202004'
                 WHEN RZ.PRODUCT_CODE_034 IN
                    ('759', '890', '907', '950', '757', '756', '775', '773', '434', '776', '774', '761', '432') OR
                    RZ.PRODUCT_CODE_034 = '319' AND RZ.INSURANCE_OBJECT_TYPE_NAME_040 = 'ПО/общий'
                    THEN 'B202005'
                 WHEN RZ.PRODUCT_CODE_034 IN ('780', '871') OR (RZ.PRODUCT_CODE_034 IN ('318', '319') AND
                     RZ.INSURANCE_OBJECT_TYPE_NAME_040 = 'ГО изготовителя/общий')
                     THEN 'B202006'
                 WHEN RZ.PRODUCT_CODE_034 = '875' THEN 'B202007'
                 WHEN RZ.PRODUCT_CODE_034 IN ('772', '356') THEN 'B202008'
                 WHEN RZ.PRODUCT_CODE_034 IN ('894', '906') THEN 'B202009'
                 WHEN RZ.PRODUCT_CODE_034 = '422' THEN 'B202010'
                 WHEN RZ.PRODUCT_CODE_034 = '447' THEN 'B202011'
                 WHEN PA."Атр ПРД Маркетинговое наименование продукта" LIKE '%Альфа%Выставка%' THEN 'B202013'
                 ELSE 'B202002'
            END
            )

        --ИЮЛ
        WHEN ABC."Код OEBS АВС 2011" = 'B201' THEN (
        CASE
            WHEN TRIM(INN_CODE.INN_CODE."Страхователь ИНН") IN ('6671156423', '7722851324', '5190001721') THEN 'B201004'

            WHEN INN_CODE."Страхователь ИНН" IN ('8401005730', '5191431170', '2457058356', '2457002628', '2460047153 ',
                '2457081355', '2457061920', '2457080792', '7701568891') THEN 'B201005'
            WHEN INN_CODE."Страхователь ИНН" IN ('7203162698', '233007263') THEN 'B201006'
            WHEN INN_CODE."Страхователь ИНН" IN ('7727547261', '7727576505', '7202116628', '8603166755', '5249051203',
                '7017075536', '1658087524', '1658008723', '1651000010') THEN 'B201008'
            WHEN INN_CODE."Страхователь ИНН" = '7713076301' THEN 'B201009'
            WHEN INN_CODE."Страхователь ИНН" = '7801463902' THEN 'B201010'
            WHEN INN_CODE."Страхователь ИНН" IN ('7724053916', '5038036968', '7715192455') THEN 'B201011'
            WHEN INN_CODE."Страхователь ИНН" = '4715026195' THEN 'B201013'
            WHEN INN_CODE."Страхователь ИНН" = '4707013516' THEN 'B201014'
            WHEN INN_CODE."Страхователь ИНН" = '4707029837' THEN 'B201015'
            WHEN INN_CODE."Страхователь ИНН" IN ('7702347870', '7734347200') THEN 'B201016'
            WHEN INN_CODE."Страхователь ИНН" = '7414003633' THEN 'B201020'
            WHEN INN_CODE."Страхователь ИНН" = '5262218620' THEN 'B201021'
            WHEN INN_CODE."Страхователь ИНН" IN ('2434000335', '3802008546', '1402046085',
                '4906000960', '3802010707') THEN 'B201021'
            WHEN INN_CODE."Страхователь ИНН" IN ('6102024555', '5406377536', '5017052856', '7726314458', '7841333459',
                '7715348014', '7820039657', '7728545877', '5021018946', '5031062221', '7705700195', '9909223191',
                 '5038042778', '5017091421', '7841357795', '7841357795', '5260200272') THEN 'B201022'
            WHEN INN_CODE."Страхователь ИНН" IN ('3435900186', '6612000551', '7449044694', '6626002291', '6154011797',
                '7449145822', '7449006730', '7449122840', '6623122216') THEN 'B201023'
            WHEN INN_CODE."Страхователь ИНН" IN ('7730211751', '5032277847', '5032178010', '5032249127', '7702807253',
                '7707073366', '7802402701', '5032231313') THEN 'B201024'
            WHEN INN_CODE."Страхователь ИНН" IN ('4707026057', '6316031581', '6330024410', '8903021599', '8911020197',
                '8911020768', '8904002359', '7728863750', '8901014564', '8904045666') THEN 'B201025'

            WHEN INN_CODE."Страхователь ИНН" = '1627005779' THEN 'B201027'
            WHEN INN_CODE."Страхователь ИНН" = '1651025328' THEN 'B201028'
            WHEN INN_CODE."Страхователь ИНН" = '7807311832' THEN 'B201030'
            WHEN INN_CODE."Страхователь ИНН" = '3528000597' THEN 'B201031'
            WHEN INN_CODE."Страхователь ИНН" = '7716222984' THEN 'B201033'
            WHEN INN_CODE."Страхователь ИНН" = '2903000446' THEN 'B201034'
            WHEN INN_CODE."Страхователь ИНН" = '4715019631' THEN 'B201035'
            WHEN INN_CODE."Страхователь ИНН" IN ('2983009410', '7825439514', '3015087458', '6164288981') THEN 'B201036'
            WHEN INN_CODE."Страхователь ИНН" IN ('3444070534', '3900004998') THEN 'B201037'
            WHEN INN_CODE."Страхователь ИНН" = '7606053324' THEN 'B201039'
            WHEN INN_CODE."Страхователь ИНН" = '7708503727' THEN 'B201041'
            WHEN INN_CODE."Страхователь ИНН" IN ('7840320023', '9703002181') THEN 'B201042'
            WHEN INN_CODE."Страхователь ИНН" IN ('2632082033', '2309001660', '7803002209', '2460069527', '6450925977',
                '7802312751', '8602060185', '6671163413', '5260200603', '3903007130', '6901067107') THEN 'B201043'
            WHEN INN_CODE."Страхователь ИНН" = '7728168971' THEN 'B201044'
            WHEN INN_CODE."Страхователь ИНН" IN ('7706199246', '7724621083', '7801413122', '9909373937', '7816215660',
                '9909380814', '9909309804', '9909362780', '9909378999') THEN 'B201045'
            WHEN INN_CODE."Страхователь ИНН" IN ('3109003728', '3109004961', '2625027560', '3906072585', '4623004836',
                '3109004337', '5720020715', '3115004381', '4623005325', '3115003525', '5009074197', '3115006491',
                '5009045076', '5714005846', '4619004632', '3115006100', '3115006318', '3110009570', '3109003598',
                '4619004640', '5009072150', '4017006738', '3906173463', '4620009025','7724420154', '7724522491',
                '3109003742', '3250521869', '3252005997', '3249004256', '3921799103') THEN 'B201046'
            WHEN INN_CODE."Страхователь ИНН" IN ('7813173683', '7805014746', '7805113497', '4707013562', '2508064833',
                '7818008549') THEN 'B201048'
            WHEN INN_CODE."Страхователь ИНН" = '6665002150' THEN 'B201049'
            WHEN INN_CODE."Страхователь ИНН" = '2536247123' THEN 'B201050'
            WHEN INN_CODE."Страхователь ИНН" = '4217102358' THEN 'B201051'
            WHEN INN_CODE."Страхователь ИНН" IN ('5250043567', '5905099475', '3448017919', '6451122250', '2624022320') THEN
                'B201052'
            WHEN INN_CODE."Страхователь ИНН" IN ('7705605953', '4003033040', '4823006703', '6646009256', '6604029211') THEN
                'B201053'
            WHEN INN_CODE."Страхователь ИНН" IN ('1646027182', '5246020905', '1646027023', '4715026815') THEN 'B201054'
            WHEN INN_CODE."Страхователь ИНН" = '7814148471' THEN 'B201055'
            WHEN INN_CODE."Страхователь ИНН" IN ('7825706086', '7728029110') THEN 'B201056'
            WHEN INN_CODE."Страхователь ИНН" IN ('7826705374', '3908604161') THEN 'B201057'
            WHEN INN_CODE."Страхователь ИНН" IN ('5047059383', '7715586594', '7810019725', '5047254063') THEN 'B201058'
            WHEN INN_CODE."Страхователь ИНН" IN ('245023615', '5011021227') THEN 'B201059'
            WHEN INN_CODE."Страхователь ИНН" = '1651044095' THEN 'B201060'
            WHEN INN_CODE."Страхователь ИНН" = '4246004891' THEN 'B201061'
            WHEN INN_CODE."Страхователь ИНН" = '4246003993' THEN 'B201062'
            ELSE 'B201000'
        END
        )

        --Финриски
        WHEN ABC."Код OEBS АВС 2011" = 'B208' THEN (
            CASE
                WHEN RZ.PRODUCT_CODE_034 IN ('333', '350', '845', '847', '869', '948') THEN 'B208001'
                WHEN RZ.CONTRACT_TYPE_118 = 3 THEN 'B208003'
              	WHEN RZ.PRODUCT_CODE_034 = '879' THEN 'B208004'
              	WHEN RZ.PRODUCT_CODE_034 = '888' AND (KP."Код OEBS КП 2011" = 'K201' OR KP."Код OEBS КП 2011" = 'K306') THEN 'B208005'
                WHEN RZ.PRODUCT_CODE_034 = '952' THEN 'B208006'
    			ELSE 'B208002'
            END
            )

        --Торговые кредиты
        WHEN ABC."Код OEBS АВС 2011" = 'B209' THEN 'B209001'

        --Море
        WHEN ABC."Код OEBS АВС 2011" = 'B205' THEN (
            CASE
                WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Водный транспорт комби/ГО%' OR
                     RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Водный транспорт комби/НС%' OR
                     RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Водный транспорт малого тоннажа/ГО%' OR
                     RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Водный транспорт/ГО%' OR
                     RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%ГО судовладельцев/общий%' THEN 'B205003'
                ELSE 'B205002'
            END
            )

        --НС
        WHEN ABC."Код OEBS АВС 2011" = 'B303' THEN (
            CASE
                WHEN RZ.PRODUCT_CODE_034 = '391' THEN 'B303001'
                WHEN RZ.PRODUCT_CODE_034 = '226' THEN (
                    CASE
                        WHEN DAYS_BETWEEN(RZ.CONTRACT_END_DATE_022, RZ.CONTRACT_BEGIN_DATE_021) < 547 THEN
                            'B303005'
                        WHEN DAYS_BETWEEN(RZ.CONTRACT_END_DATE_022, RZ.CONTRACT_BEGIN_DATE_021) < 915 THEN
                            'B303012'
                        ELSE 'B303013'
                    END
                    )
                WHEN RZ.PRODUCT_CODE_034 = '438' OR RZ.PRODUCT_CODE_034 = '439' OR RZ.PRODUCT_CODE_034 = '268' THEN 'B303006'
                WHEN RZ.PRODUCT_CODE_034 = '242' THEN 'B303007'
                WHEN RZ.PRODUCT_CODE_034 = '205' THEN 'B303008'
                WHEN RZ.PRODUCT_CODE_034 = '262' THEN 'B303009'
                WHEN RZ.PRODUCT_CODE_034 = '457' THEN 'B303010'
                WHEN RZ.PRODUCT_CODE_034 IN ('279', '286') THEN 'B303011'
                WHEN RZ.PRODUCT_CODE_034 = '497' THEN 'B303014'
                ELSE 'B303000'
            END
            )

        --Накопительное
        WHEN ABC."Код OEBS АВС 2011" = 'B501' THEN 'B501000'

        --техриски
        WHEN ABC."Код OEBS АВС 2011" = 'B203' THEN (
            CASE
                WHEN RZ.CONTRACT_NUMBER_005 IN ('Z691L/322/00001/21', 'Z691F/751/500001/22') THEN 'B203004'
                WHEN RZ.CONTRACT_NUMBER_005 LIKE '%Z691F/322/00001/19%' THEN 'B203005'
                WHEN RZ.CONTRACT_NUMBER_005 LIKE '%Z691F/751/0000004/22%' THEN 'B203006'
                WHEN RZ.CONTRACT_NUMBER_005 IN ('Z691D/933/0001276/22', 'Z691D/933/0002395/23', 'Z691D/933/0001427/22',
                    'Z691D/933/0002394/23', '0311F/933/0000002/22') THEN 'B203009'
                WHEN RZ.CONTRACT_NUMBER_005 LIKE '%Z691D/933/0002659/22%' THEN 'B203010'
                WHEN RZ.CONTRACT_NUMBER_005 LIKE '%Z691D/933/0001742/22%' THEN 'B203011'
                WHEN RZ.CONTRACT_TYPE_118 = 3 THEN 'B203003'
                WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Спецтехника%' THEN 'B203002'
                ELSE 'B203001'
            END
            )

        --ЗК
        WHEN ABC."Код OEBS АВС 2011" = 'B105' THEN 'B105000'

        --Ипотека
        WHEN ABC."Код OEBS АВС 2011" = 'B108' THEN (
            CASE
                WHEN PA."Атр ПРД Маркетинговое наименование продукта" LIKE '%кредит под залог недвижимости%' OR
                    (PA."Атр ПРД Банк/Лизинг" LIKE '%Альфа-Банк%' AND RZ.PRODUCT_CODE_034 = '482') THEN
                    CASE
                        WHEN DAYS_BETWEEN(RZ.CONTRACT_END_DATE_022, RZ.CONTRACT_BEGIN_DATE_021) < 428 THEN
                            'B108007'
                        WHEN DAYS_BETWEEN(RZ.CONTRACT_END_DATE_022, RZ.CONTRACT_BEGIN_DATE_021) < 1831 THEN
                            'B108008'
                        WHEN DAYS_BETWEEN(RZ.CONTRACT_END_DATE_022, RZ.CONTRACT_BEGIN_DATE_021) < 2563 THEN
                            'B108009'
                        ELSE 'B108010'
                    END
                WHEN PA."Атр ПРД Банк/Лизинг" LIKE '%Альфа-Банк%' THEN
                    CASE
                        WHEN RZ.CONTRACT_TYPE_092 = 'Пролонгированный' THEN 'B108004' ELSE 'B108003'
                    END
                WHEN PA."Атр ПРД Банк/Лизинг" LIKE '%Сбербанк ПАО%' THEN
                    CASE
                        WHEN RZ.CONTRACT_TYPE_092 = 'Пролонгированный' THEN 'B108006' ELSE 'B108005'
                    END
                WHEN RZ.CONTRACT_TYPE_092 = 'Пролонгированный' THEN 'B108002'
                ELSE 'B108001'
            END
            )

        --Авиация
        WHEN ABC."Код OEBS АВС 2011" = 'B401' THEN 'B401000'

        --Пассажиры
        WHEN ABC."Код OEBS АВС 2011" = 'B401' THEN (
            CASE
                WHEN RZ.PRODUCT_CODE_034  IN ('198', '247') THEN 'B402001'
                WHEN RZ.PRODUCT_CODE_034  IN ('368', '427') THEN 'B402002'
                WHEN RZ.PRODUCT_CODE_034  = '426' THEN 'B402003'
                WHEN RZ.PRODUCT_CODE_034  = '451' THEN 'B402004'
                WHEN RZ.PRODUCT_CODE_034  IN ('282', '480') THEN 'B402005'
                WHEN RZ.PRODUCT_CODE_034  = '452' THEN 'B402006'
                WHEN RZ.PRODUCT_CODE_034  = '453' THEN 'B402007'
                WHEN RZ.PRODUCT_CODE_034  = '454' THEN 'B402008'
                ELSE 'B402000'
            END
            )

        --Кредитное
        WHEN ABC."Код OEBS АВС 2011" = 'B502' THEN (
            CASE
                WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 IN ('Клиенты финорганизаций/финриски', 'Потеря дохода/общий',
                    'Финансовые риски/кредитное', 'Финансовые риски/общий') THEN 'B502008'
                WHEN RZ.INSURER_SUBJECT_TYPE_072 = 'ЮРИДИЧЕСКОЕ_ЛИЦО' OR
                    DAYS_BETWEEN(RZ.CONTRACT_END_DATE_022, RZ.CONTRACT_BEGIN_DATE_021) < 370 THEN 'B502007'
                ELSE 'B502006'
            END
            )

        --Закрыт с 2024
        WHEN ABC."Код OEBS АВС 2011" = 'B207' THEN (
            CASE
                WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Животные%' THEN 'B207003'
                WHEN RZ.INSURANCE_OBJECT_TYPE_NAME_040 LIKE '%Урожай%' THEN
                    CASE
                        WHEN RZ.CONTRACT_NUMBER_005 IN ('8791D/928/00561/22', '8791D/928/00562/22',
                            'S591D/983/00001/22', 'S591D/983/00002/22', 'S591D/983/00003/22', 'S591D/983/00004/22',
                            'Z691D/928/0000015/22', 'Z691D/928/0000016/21') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/928/0000016/22', 'Z691D/928/0000017/21',
                            'Z691D/928/0000017/22', 'Z691D/928/0000018/21', 'Z691D/928/0000018/22',
                            'Z691D/928/0000019/22', 'Z691D/928/0000020/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/928/0000021/22', '691D/928/0000022/22',
                            'Z691D/928/0000023/22', 'Z691D/928/0000024/22', 'Z691D/928/0000025/22',
                            'Z691D/983/0000007/22', 'Z691D/983/0000008/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/983/0000009/22', 'Z691D/983/0000010/22',
                            'Z691D/983/0000011/22', 'Z691D/983/0000012/22', 'Z691D/983/0000013/22',
                            'Z691D/983/0000014/22', 'Z691D/983/0000015/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/983/0000016/22', 'Z691D/983/0000017/22',
                            'Z691D/983/0000018/22', 'Z691D/983/0000019/22', 'Z691D/983/0000020/22',
                            '3642R/928/04310/22', '3642R/928/04311/22', '3642R/928/04363/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('3642R/928/04455/22', '3642R/928/04456/22',
                            '3642R/928/04462/22', '3642R/928/04501/22', '8012R/928/16171/22', '8012R/928/16172/22',
                            '8012R/928/16173/22', '8012R/928/16174/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('8012R/928/16175/22', '8012R/928/16176/22',
                            'S591R/928/000001/22', 'S591R/928/000002/22', 'S591R/928/000003/22',
                            'S591R/928/500001/22', 'S591R/928/500002/22', 'Z691D/928/0000027/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/928/0000028/22', 'Z691D/928/0000029/22',
                            'Z691D/928/0000030/22', 'Z691D/928/0000031/22', 'Z691D/983/0000021/22',
                            'Z691D/983/0000022/22', 'Z691D/983/0000024/22', 'Z691D/983/0000025/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/983/0000026/22', 'Z691D/983/0000027/22',
                            'Z691D/983/0000028/22', 'Z691D/983/0000029/22', 'Z691D/983/0000030/22',
                            'Z691D/983/0000031/22', 'Z691D/983/0000032/22', 'Z691D/983/0000033/22') OR
                        RZ.CONTRACT_NUMBER_005 IN ('3642R/928/04406/22', '3642R/928/04430/22',
                            '3642R/928/04483/22', 'Z691D/928/0000001/23', 'Z691D/928/0000002/23',
                            'Z691D/928/0000003/23', 'Z691D/928/0000004/23', 'Z691D/928/0000007/23') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/928/0000008/23', 'Z691D/928/0000009/23',
                            'Z691D/928/0000010/23', 'Z691D/928/0000011/23', 'Z691D/928/0000012/23',
                            'Z691D/928/0000013/23', 'Z691D/928/0000014/23') OR
                        RZ.CONTRACT_NUMBER_005 IN ('3642R/928/04385/22', 'S091D/983/00001/23',
                            'S091D/983/00002/23', 'S091D/983/00003/23', 'S091D/983/00004/23',
                            'S091D/983/00005/23', 'S091D/983/00006/23', 'Z691D/928/0000005/23') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/928/0000006/23', 'Z691D/928/0000015/23',
                            'Z691D/983/0000001/23', 'Z691D/983/0000002/23', 'Z691D/983/0000003/23',
                            'Z691D/983/0000004/23', 'Z691D/983/0000005/23', 'Z691D/983/0000006/23') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/983/0000007/23', 'Z691D/983/0000008/23',
                            'Z691D/983/0000009/23', 'Z691D/983/0000010/23', 'Z691D/983/0000011/23',
                            'Z691D/983/0000012/23', 'Z691D/983/0000013/23', 'Z691D/983/0000014/23') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/983/0000015/23', 'Z691D/983/0000016/23',
                            'Z691D/983/0000017/23', 'Z691D/983/0000018/23', 'Z691D/983/0000019/23',
                            'Z691D/983/0000020/23', 'Z691D/983/0000021/23', 'Z691D/983/0000022/23') OR
                        RZ.CONTRACT_NUMBER_005 IN ('Z691D/983/0000023/23', 'Z691D/983/0000034/22',
                            'Z691D/983/0000035/22', 'Z691D/983/0000036/22', 'Z691D/983/0000037/22')
                        THEN 'B207009' ELSE 'B207001'
                    END
                ELSE 'B207000'
            END
            )

        --Космические  риски
        WHEN ABC."Код OEBS АВС 2011" = 'B403' THEN 'B403000'

        --НС Физ лиц
        WHEN ABC."Код OEBS АВС 2011" = 'B107' THEN (
            CASE
                WHEN RZ.PRODUCT_CODE_034 = '454' THEN 'B107003'
                WHEN PA."Атр ПРД Маркетинговое наименование продукта" = 'Коронавирус.НЕТ' THEN 'B107002'
                ELSE 'B107000'
            END
            )
        ELSE 'B000000'
    END "Продукт OEBS",
    '2' "Год Договора OEBS",
    RZ.DEPARTMENT_CODE_009 "Код ПП",
    '0' "Эталон"
FROM LAST_POLICY LP
    LEFT JOIN STG_UNC.XX_ALFA_RZ_CONTRACT RZ ON RZ.POLICY_UNIQUE_ID_036 = LP.POLICY_UNIQUE_ID_036
        LEFT JOIN INN_CODE IC ON IC.SUBJECT_ID = RZ.INSURER_SUBJECT_ID_070
        LEFT JOIN STG_UNC.CONTRACT CON ON CON.CONTRACT_ID = RZ.ROOT_CONTRACT_ID_002
            LEFT JOIN STG_UNC.SUBJECT SUB ON SUB.SUBJECT_ID = CON.MANAGER_SUBJECT_ID
    	LEFT JOIN STG_FILES."017_справ_кодов_ЦФО" CFO ON CFO."код_подразделения" = RZ.DEPARTMENT_CODE_009 AND CFO."код_подразделения" IS NOT NULL
    	LEFT JOIN STG_FILES."014_справ_кодов_АВС" ABC ON ABC."Тос название Юникус" = RZ.INSURANCE_OBJECT_TYPE_NAME_040 AND ABC."Тос название Юникус" IS NOT NULL
    	LEFT JOIN STG_FILES."015_справ_кодов_КП" KP ON KP."КП название Юникус" = RZ.CHANNEL_SALE_014 AND KP."КП название Юникус" IS NOT NULL
    	LEFT JOIN PROD_ATTR PA ON PA.POLICY_ID_100 = RZ.POLICY_ID_100
;

--// Добавляем данные в таблицу UNC_UU_MAP_POLICY//--
INSERT INTO IDM_MGMT_MAP.UNC_UU_MAP_POLICY
SELECT DISTINCT
    "Корневой Полис ID",
    "Корневой Договор Номер",
    "АВС",
    "ЦФО",
    "КП",
    "Продукт OEBS",
    "Год Договора OEBS",
    "Код ПП",
    "Эталон"
FROM IDM_MGMT_MAP.UNC_UU_MAP_ADDON
;

--// Добавляем данные в таблицу UNC_UU_MAP_POLICY//--
INSERT INTO IDM_MGMT_MAP.UNC_UU_MAP_POLICY
SELECT
    "Корневой Полис ID",
    "Корневой Договор Номер",
    "АВС",
    "ЦФО",
    "КП",
    "Продукт OEBS",
    "Год Договора OEBS",
    "Код ПП",
    "Эталон"
FROM IDM_MGMT_MAP.UNC_UU_MAP_ETALON
;

--// Добавляем данные в таблицу UNC_UU_MAP_CONTRACT//--
INSERT INTO IDM_MGMT_MAP.UNC_UU_MAP_CONTRACT

WITH UNITED AS (
SELECT
    "Корневой Полис ID",
    "Корневой Договор Номер",
    "АВС",
    "ЦФО",
    "КП",
    "Продукт OEBS",
    "Год Договора OEBS",
    "Код ПП"
FROM IDM_MGMT_MAP.UNC_UU_MAP_ADDON

UNION

SELECT
    "Корневой Полис ID",
    "Корневой Договор Номер",
    "АВС",
    "ЦФО",
    "КП",
    "Продукт OEBS",
    "Год Договора OEBS",
    "Код ПП"
FROM IDM_MGMT_MAP.UNC_UU_MAP_ETALON
),

UNIC AS (
SELECT
    "Корневой Договор Номер",
    COUNT("Номер Корневого Договора", '_', "АВС", '_', "ЦФО", '_', "КП") "Счётчик"
FROM UNITED
GROUP BY "Корневой Договор Номер"
)

SELECT
    UN."Корневой Полис ID",
    UN."Корневой Договор Номер",
    UN."АВС",
    UN."ЦФО",
    UN."КП",
    UN."Продукт OEBS",
    UN."Год Договора OEBS",
    UN."Код ПП",
    CASE
        WHEN UC."Счётчик" > 1 THEN 'NU' ELSE 'U'
    END "Уникальный"
FROM UNITED UN
    JOIN UNIC UC ON UC."Корневой Договор Номер" = UN."Корневой Договор Номер"
;




