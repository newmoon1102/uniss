--DROP PROCEDURE SP_SAVE_T_BUN_JUCHU

CREATE PROCEDURE SP_SAVE_T_BUN_JUCHU
       @USER_ID  NVARCHAR(64)   --ユーザーID
      ,@SERIAL   NVARCHAR(50)   --シリアル
      ,@MODE     INT            --処理モード
      ,@REF_NO   NVARCHAR(10)   --参照No.(受理No./見積No.)
      ,@EDA      INT            --対象枝番
AS
--保存処理実行
--[モード] 0:読込 / 1:新規保存 / 2:更新 / 3:削除 / 4:枝番削除 / 5:見積接続 /
--         6:参照作成 / 7:ステータス変更 / 8:見積No.設定

BEGIN
    --戻り値用テーブル変数
    DECLARE @TBL TABLE (
      RESULT_JURI_NO NVARCHAR(10)
     ,RESULT_CD      int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --シーケンス
    DECLARE @SEQ AS INT

    --対象受理No.
    DECLARE @JURI_NO AS NVARCHAR(10)

    --対象見積No.
    DECLARE @MITSU_NO AS NVARCHAR(10)

    --更新ユーザー・更新日時
    DECLARE @UPDATE_USER AS NVARCHAR(max)
    DECLARE @UPDATE_DATE AS NVARCHAR(50)

    --ステータス履歴用変数
    DECLARE @CREATE_DATE AS NVARCHAR(50)
    DECLARE @BEFORE_STS  AS INT
    DECLARE @AFTER_STS   AS INT

    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --読込処理
    IF @MODE = 0
      BEGIN

        --DB状態取得（エラー判定）
        --DB修正状態設定
        
        --ワークテーブルクリア
        DELETE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID

        --読込(テーブル→ワークテーブル)
        INSERT INTO
               W_BUN_JUCHU
        SELECT
               @USER_ID
              ,@SERIAL
              ,CASE WHEN T_BUN_JUCHU_SHOSAI.JURI_EDA_NO IS NOT NULL THEN T_BUN_JUCHU_SHOSAI.JURI_EDA_NO
                    ELSE 1
               END
              ,CASE WHEN T_BUN_JUCHU_SHOSAI.GYO_NO IS NOT NULL THEN T_BUN_JUCHU_SHOSAI.GYO_NO
                    ELSE 1
               END
              ,1
              --ヘッダテーブル
              ,T_BUN_JUCHU_H.JURI_NO
              ,T_BUN_JUCHU_H.BUNSEKI_STS
              ,T_BUN_JUCHU_H.JUCHU_KBN
              ,T_BUN_JUCHU_H.BUSHO_CD
              ,T_BUN_JUCHU_H.NYURYOKU_DATETIME
              ,T_BUN_JUCHU_H.NYURYOKUSHA_CD
              ,T_BUN_JUCHU_H.REF_JURI_NO
              ,T_BUN_JUCHU_H.MITSU_NO
              ,T_BUN_JUCHU_H.ATENA_CD
              ,T_BUN_JUCHU_H.ATENA
              ,T_BUN_JUCHU_H.SEIKYU_CD
              ,T_BUN_JUCHU_H.BUNSEKI_HOHO_CD
              ,T_BUN_JUCHU_H.KEISHIKI_KBN
              ,T_BUN_JUCHU_H.NOHIN_HOHO
              ,T_BUN_JUCHU_H.KOSU
              ,T_BUN_JUCHU_H.EIGYO_TANTO_CD
              ,T_BUN_JUCHU_H.IRAI_DATE
              ,T_BUN_JUCHU_H.KANRYO_DATE
              ,T_BUN_JUCHU_H.KANSEI_DATE
              ,T_BUN_JUCHU_H.SOKUHO_KBN
              ,T_BUN_JUCHU_H.HAKKO_DATE
              ,T_BUN_JUCHU_H.NOHIN_DATE
              ,T_BUN_JUCHU_H.KENMEI
              ,T_BUN_JUCHU_H.MOKUTEKI
              ,T_BUN_JUCHU_H.KISAI_JIKO
              ,T_BUN_JUCHU_H.EDA_SHIRYO_FLG
              ,T_BUN_JUCHU_H.SAISHU_KAISHA_MEI
              ,T_BUN_JUCHU_H.SAISHU_SHA
              ,T_BUN_JUCHU_H.SAISHU_HOHO
              ,T_BUN_JUCHU_H.SAISHU_BASHO
              ,T_BUN_JUCHU_H.TENKO
              ,T_BUN_JUCHU_H.KION
              ,T_BUN_JUCHU_H.SUION
              ,T_BUN_JUCHU_H.SAISHU_DATE
              ,T_BUN_JUCHU_H.SAISHU_TIME
              ,T_BUN_JUCHU_H.SHOKEN_FLG
              ,T_BUN_JUCHU_H.GAISO_KBN
              ,T_BUN_JUCHU_H.YOKI
              ,T_BUN_JUCHU_H.HENKYAKU
              ,T_BUN_JUCHU_H.HOKOKU_HOHO_KBN
              ,T_BUN_JUCHU_H.BUSU
              ,T_BUN_JUCHU_H.CHUKAN_DATE_1
              ,T_BUN_JUCHU_H.CHUKAN_NAIYO_1
              ,T_BUN_JUCHU_H.CHUKAN_DATE_2
              ,T_BUN_JUCHU_H.CHUKAN_NAIYO_2
              ,T_BUN_JUCHU_H.CHUKAN_DATE_3
              ,T_BUN_JUCHU_H.CHUKAN_NAIYO_3
              ,T_BUN_JUCHU_H.BIKO
              ,T_BUN_JUCHU_H.FUYO_FLG
              ,T_BUN_JUCHU_H.NEW_FLG
              ,T_BUN_JUCHU_H.HENKO_FLG
              ,T_BUN_JUCHU_H.HOKOKU_CD_1
              ,T_BUN_JUCHU_H.HOKOKU_MEI_1
              ,T_BUN_JUCHU_H.BUSHO_1
              ,T_BUN_JUCHU_H.TANTO_1
              ,T_BUN_JUCHU_H.TEL_1
              ,T_BUN_JUCHU_H.FAX_1
              ,T_BUN_JUCHU_H.MAIL_1
              ,T_BUN_JUCHU_H.YUBIN_NO_1
              ,T_BUN_JUCHU_H.ADDRESS_1
              ,T_BUN_JUCHU_H.CHUKAN_SOFU_FLG_1
              ,T_BUN_JUCHU_H.SOKUHO_SOFU_FLG_1
              ,T_BUN_JUCHU_H.HOKOKUSHO_SOFU_FLG_1
              ,T_BUN_JUCHU_H.HOKOKU_CD_2
              ,T_BUN_JUCHU_H.HOKOKU_MEI_2
              ,T_BUN_JUCHU_H.BUSHO_2
              ,T_BUN_JUCHU_H.TANTO_2
              ,T_BUN_JUCHU_H.TEL_2
              ,T_BUN_JUCHU_H.FAX_2
              ,T_BUN_JUCHU_H.MAIL_2
              ,T_BUN_JUCHU_H.YUBIN_NO_2
              ,T_BUN_JUCHU_H.ADDRESS_2
              ,T_BUN_JUCHU_H.CHUKAN_SOFU_FLG_2
              ,T_BUN_JUCHU_H.SOKUHO_SOFU_FLG_2
              ,T_BUN_JUCHU_H.HOKOKUSHO_SOFU_FLG_2
              ,T_BUN_JUCHU_H.HOKOKU_CD_3
              ,T_BUN_JUCHU_H.HOKOKU_MEI_3
              ,T_BUN_JUCHU_H.BUSHO_3
              ,T_BUN_JUCHU_H.TANTO_3
              ,T_BUN_JUCHU_H.TEL_3
              ,T_BUN_JUCHU_H.FAX_3
              ,T_BUN_JUCHU_H.MAIL_3
              ,T_BUN_JUCHU_H.YUBIN_NO_3
              ,T_BUN_JUCHU_H.ADDRESS_3
              ,T_BUN_JUCHU_H.CHUKAN_SOFU_FLG_3
              ,T_BUN_JUCHU_H.SOKUHO_SOFU_FLG_3
              ,T_BUN_JUCHU_H.HOKOKUSHO_SOFU_FLG_3
              ,T_BUN_JUCHU_H.DEMPYO_HAKKO_KBN
              ,T_BUN_JUCHU_H.BUN_SORT_SEQ
              --ボディテーブル
              ,T_BUN_JUCHU_B.SAISHU_KAISHA_MEI
              ,T_BUN_JUCHU_B.SAISHU_SHA
              ,T_BUN_JUCHU_B.SAISHU_HOHO
              ,T_BUN_JUCHU_B.SAISHU_BASHO
              ,T_BUN_JUCHU_B.TENKO
              ,T_BUN_JUCHU_B.KION
              ,T_BUN_JUCHU_B.SUION
              ,T_BUN_JUCHU_B.SAISHU_DATE
              ,T_BUN_JUCHU_B.SAISHU_TIME
              ,T_BUN_JUCHU_B.SHIRYO_SHURUI
              ,T_BUN_JUCHU_B.SHIRYO_MEI
              ,T_BUN_JUCHU_B.IKKATSU_M
              ,T_BUN_JUCHU_B.IKKATSU_N
              ,T_BUN_JUCHU_B.BUNSEKI_GUN_CD
              ,T_BUN_JUCHU_B.EBIKO
              --詳細テーブル
              ,T_BUN_JUCHU_SHOSAI.SEQ
              ,T_BUN_JUCHU_SHOSAI.GYO_NO
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_CD
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_MEI
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_TANI
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_DATA
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_NO
              ,T_BUN_JUCHU_SHOSAI.URAGAKI_PRINT_FLG
              --DBS領域
              ,T_BUN_JUCHU_H.DBS_STATUS
              ,T_BUN_JUCHU_H.DBS_CREATE_USER
              ,T_BUN_JUCHU_H.DBS_CREATE_DATE
              ,T_BUN_JUCHU_H.DBS_UPDATE_USER
              ,T_BUN_JUCHU_H.DBS_UPDATE_DATE
          FROM T_BUN_JUCHU_H
          LEFT JOIN
               T_BUN_JUCHU_B
            ON T_BUN_JUCHU_B.JURI_NO = T_BUN_JUCHU_H.JURI_NO
          LEFT JOIN
               T_BUN_JUCHU_SHOSAI
            ON T_BUN_JUCHU_SHOSAI.JURI_NO = T_BUN_JUCHU_H.JURI_NO
           AND T_BUN_JUCHU_SHOSAI.JURI_EDA_NO = T_BUN_JUCHU_B.JURI_EDA_NO
         WHERE T_BUN_JUCHU_H.JURI_NO = @REF_NO

      END

    --新規登録処理
    ELSE IF @MODE = 1
      BEGIN
      
        SET @SEQ = NEXT VALUE FOR SEQ_JURI_NO

        --受理No.生成
        SET @JURI_NO = ( SELECT CONCAT( 'J', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --見積No.取得
        SET @MITSU_NO = ( SELECT MITSU_NO
                            FROM W_BUN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 
                          --最新の情報を採用する
                             AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT
                                                                        MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                                   FROM W_BUN_JUCHU
                                                                  WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                                    AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                                    AND W_BUN_JUCHU.W_ROW     = 1      ))

        --詳細テーブル用SEQ生成処理
        UPDATE W_BUN_JUCHU
           SET W_BUN_JUCHU.SEQ = WORK_TBL.SEQ
          FROM W_BUN_JUCHU
         INNER JOIN
               ( SELECT ROW_NUMBER() OVER ( PARTITION BY UPDATE_TBL.JURI_EDA_NO
                                                ORDER BY UPDATE_TBL.JURI_EDA_NO
                                                        ,UPDATE_TBL.SEQ ) AS SEQ
--                        ,UPDATE_TBL.JURI_NO
                       ,UPDATE_TBL.W_USER_ID
                       ,UPDATE_TBL.JURI_EDA_NO
                       ,UPDATE_TBL.W_ROW
                   FROM W_BUN_JUCHU AS UPDATE_TBL
                  WHERE UPDATE_TBL.W_USER_ID = @USER_ID
                    AND UPDATE_TBL.W_SERIAL  = @SERIAL
                    AND UPDATE_TBL.SEQ IS NULL
               ) AS WORK_TBL
--             ON WORK_TBL.JURI_NO     = W_BUN_JUCHU.JURI_NO
            ON WORK_TBL.W_USER_ID   = W_BUN_JUCHU.W_USER_ID
           AND WORK_TBL.JURI_EDA_NO = W_BUN_JUCHU.JURI_EDA_NO
           AND WORK_TBL.W_ROW       = W_BUN_JUCHU.W_ROW


        --新規保存ヘッダ(ワークテーブル→テーブル)
        INSERT INTO
               T_BUN_JUCHU_H
        SELECT DISTINCT
               @JURI_NO
              ,W_BUN_JUCHU.BUNSEKI_STS
              ,W_BUN_JUCHU.JUCHU_KBN
              ,W_BUN_JUCHU.BUSHO_CD
              ,W_BUN_JUCHU.NYURYOKU_DATETIME
              ,W_BUN_JUCHU.NYURYOKUSHA_CD
              ,W_BUN_JUCHU.REF_JURI_NO
              ,W_BUN_JUCHU.MITSU_NO
              ,W_BUN_JUCHU.ATENA_CD
              ,W_BUN_JUCHU.ATENA
              ,W_BUN_JUCHU.SEIKYU_CD
              ,W_BUN_JUCHU.BUNSEKI_HOHO_CD
              ,W_BUN_JUCHU.KEISHIKI_KBN
              ,W_BUN_JUCHU.NOHIN_HOHO
              ,W_BUN_JUCHU.KOSU
              ,W_BUN_JUCHU.EIGYO_TANTO_CD
              ,W_BUN_JUCHU.IRAI_DATE
              ,W_BUN_JUCHU.KANRYO_DATE
              ,W_BUN_JUCHU.KANSEI_DATE
              ,W_BUN_JUCHU.SOKUHO_KBN
              ,W_BUN_JUCHU.HAKKO_DATE
              ,W_BUN_JUCHU.NOHIN_DATE
              ,W_BUN_JUCHU.KENMEI
              ,W_BUN_JUCHU.MOKUTEKI
              ,W_BUN_JUCHU.KISAI_JIKO
              ,W_BUN_JUCHU.EDA_SHIRYO_FLG
              ,W_BUN_JUCHU.SAISHU_KAISHA_MEI
              ,W_BUN_JUCHU.SAISHU_SHA
              ,W_BUN_JUCHU.SAISHU_HOHO
              ,W_BUN_JUCHU.SAISHU_BASHO
              ,W_BUN_JUCHU.TENKO
              ,W_BUN_JUCHU.KION
              ,W_BUN_JUCHU.SUION
              ,W_BUN_JUCHU.SAISHU_DATE
              ,W_BUN_JUCHU.SAISHU_TIME
              ,W_BUN_JUCHU.SHOKEN_FLG
              ,W_BUN_JUCHU.GAISO_KBN
              ,W_BUN_JUCHU.YOKI
              ,W_BUN_JUCHU.HENKYAKU
              ,W_BUN_JUCHU.HOKOKU_HOHO_KBN
              ,W_BUN_JUCHU.BUSU
              ,W_BUN_JUCHU.CHUKAN_DATE_1
              ,W_BUN_JUCHU.CHUKAN_NAIYO_1
              ,W_BUN_JUCHU.CHUKAN_DATE_2
              ,W_BUN_JUCHU.CHUKAN_NAIYO_2
              ,W_BUN_JUCHU.CHUKAN_DATE_3
              ,W_BUN_JUCHU.CHUKAN_NAIYO_3
              ,W_BUN_JUCHU.BIKO
              ,W_BUN_JUCHU.FUYO_FLG
              ,W_BUN_JUCHU.NEW_FLG
              ,W_BUN_JUCHU.HENKO_FLG
              ,W_BUN_JUCHU.HOKOKU_CD_1
              ,W_BUN_JUCHU.HOKOKU_MEI_1
              ,W_BUN_JUCHU.BUSHO_1
              ,W_BUN_JUCHU.TANTO_1
              ,W_BUN_JUCHU.TEL_1
              ,W_BUN_JUCHU.FAX_1
              ,W_BUN_JUCHU.MAIL_1
              ,W_BUN_JUCHU.YUBIN_NO_1
              ,W_BUN_JUCHU.ADDRESS_1
              ,W_BUN_JUCHU.CHUKAN_SOFU_FLG_1
              ,W_BUN_JUCHU.SOKUHO_SOFU_FLG_1
              ,W_BUN_JUCHU.HOKOKUSHO_SOFU_FLG_1
              ,W_BUN_JUCHU.HOKOKU_CD_2
              ,W_BUN_JUCHU.HOKOKU_MEI_2
              ,W_BUN_JUCHU.BUSHO_2
              ,W_BUN_JUCHU.TANTO_2
              ,W_BUN_JUCHU.TEL_2
              ,W_BUN_JUCHU.FAX_2
              ,W_BUN_JUCHU.MAIL_2
              ,W_BUN_JUCHU.YUBIN_NO_2
              ,W_BUN_JUCHU.ADDRESS_2
              ,W_BUN_JUCHU.CHUKAN_SOFU_FLG_2
              ,W_BUN_JUCHU.SOKUHO_SOFU_FLG_2
              ,W_BUN_JUCHU.HOKOKUSHO_SOFU_FLG_2
              ,W_BUN_JUCHU.HOKOKU_CD_3
              ,W_BUN_JUCHU.HOKOKU_MEI_3
              ,W_BUN_JUCHU.BUSHO_3
              ,W_BUN_JUCHU.TANTO_3
              ,W_BUN_JUCHU.TEL_3
              ,W_BUN_JUCHU.FAX_3
              ,W_BUN_JUCHU.MAIL_3
              ,W_BUN_JUCHU.YUBIN_NO_3
              ,W_BUN_JUCHU.ADDRESS_3
              ,W_BUN_JUCHU.CHUKAN_SOFU_FLG_3
              ,W_BUN_JUCHU.SOKUHO_SOFU_FLG_3
              ,W_BUN_JUCHU.HOKOKUSHO_SOFU_FLG_3
              ,W_BUN_JUCHU.DEMPYO_HAKKO_KBN
              ,W_BUN_JUCHU.BUN_SORT_SEQ
              ,'False'
              ,W_BUN_JUCHU.DBS_STATUS
              ,W_BUN_JUCHU.DBS_CREATE_USER
              ,W_BUN_JUCHU.DBS_CREATE_DATE
              ,W_BUN_JUCHU.DBS_UPDATE_USER
              ,W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID   = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL    = @SERIAL
           AND W_BUN_JUCHU.W_ROW       = 1
           --最新の情報を採用する
           AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT
                                                      MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                 FROM W_BUN_JUCHU
                                                WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                  AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                  AND W_BUN_JUCHU.W_ROW     = 1      )

        --新規保存ボディ(ワークテーブル→テーブル)
        INSERT INTO
               T_BUN_JUCHU_B
        SELECT
               @JURI_NO
              ,W_BUN_JUCHU.JURI_EDA_NO
              ,W_BUN_JUCHU.SAISHU_KAISHA_MEI_B
              ,W_BUN_JUCHU.SAISHU_SHA_B
              ,W_BUN_JUCHU.SAISHU_HOHO_B
              ,W_BUN_JUCHU.SAISHU_BASHO_B
              ,W_BUN_JUCHU.TENKO_B
              ,W_BUN_JUCHU.KION_B
              ,W_BUN_JUCHU.SUION_B
              ,W_BUN_JUCHU.SAISHU_DATE_B
              ,W_BUN_JUCHU.SAISHU_TIME_B
              ,W_BUN_JUCHU.SHIRYO_SHURUI
              ,W_BUN_JUCHU.SHIRYO_MEI
              ,W_BUN_JUCHU.IKKATSU_M
              ,W_BUN_JUCHU.IKKATSU_N
              ,W_BUN_JUCHU.BUNSEKI_GUN_CD
              ,W_BUN_JUCHU.EBIKO
              ,'False'
              ,W_BUN_JUCHU.DBS_STATUS
              ,W_BUN_JUCHU.DBS_CREATE_USER
              ,W_BUN_JUCHU.DBS_CREATE_DATE
              ,W_BUN_JUCHU.DBS_UPDATE_USER
              ,W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
           AND W_BUN_JUCHU.W_ROW     = 1


        --新規保存分析項目リスト(ワークテーブル→テーブル)
        INSERT INTO
               T_BUN_JUCHU_SHOSAI
        SELECT
               @JURI_NO
              ,W_BUN_JUCHU.JURI_EDA_NO
              ,W_BUN_JUCHU.SEQ
              ,ROW_NUMBER() OVER(PARTITION BY JURI_NO,JURI_EDA_NO ORDER BY CASE WHEN M_BUN_SORT_B.SORT_NO IS NULL THEN 1 ELSE 0 END,M_BUN_SORT_B.SORT_NO,W_BUN_JUCHU.GYO_NO)
              ,W_BUN_JUCHU.BUNSEKI_CD
              ,W_BUN_JUCHU.BUNSEKI_MEI
              ,W_BUN_JUCHU.BUNSEKI_TANI
              ,W_BUN_JUCHU.BUNSEKI_DATA
              ,W_BUN_JUCHU.BUNSEKI_NO
              ,W_BUN_JUCHU.URAGAKI_PRINT_FLG
              ,'False'
              ,W_BUN_JUCHU.DBS_STATUS
              ,W_BUN_JUCHU.DBS_CREATE_USER
              ,W_BUN_JUCHU.DBS_CREATE_DATE
              ,W_BUN_JUCHU.DBS_UPDATE_USER
              ,W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
               LEFT JOIN M_BUN_SORT_B
                ON      M_BUN_SORT_B.BUNSEKI_HOHO_CD = ( SELECT BUNSEKI_HOHO_CD
                            FROM W_BUN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 
                          --最新の情報を採用する
                             AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT
                                                                        MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                                   FROM W_BUN_JUCHU
                                                                  WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                                    AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                                    AND W_BUN_JUCHU.W_ROW     = 1      ))
                    AND M_BUN_SORT_B.SEQ = ( SELECT BUN_SORT_SEQ
                            FROM W_BUN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 
                          --最新の情報を採用する
                             AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT
                                                                        MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                                   FROM W_BUN_JUCHU
                                                                  WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                                    AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                                    AND W_BUN_JUCHU.W_ROW     = 1      ))
                    AND M_BUN_SORT_B.BUNSEKI_CD = W_BUN_JUCHU.BUNSEKI_CD
		      
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
           AND W_BUN_JUCHU.GYO_NO IS NOT NULL

--         --新規保存項目別サンプルリスト(ワークテーブル→テーブル)
--         INSERT INTO
--                T_KOMOKU_SAMPLE
--         SELECT @JURI_NO
--               ,W_BUN_JUCHU.JURI_EDA_NO
--               ,W_BUN_JUCHU.SEQ
--               ,W_BUN_JUCHU.BUNSEKI_CD
--               ,NULL
--               ,'1'
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,'1'
--               ,W_BUN_JUCHU.DBS_CREATE_USER
--               ,W_BUN_JUCHU.DBS_CREATE_DATE
--               ,W_BUN_JUCHU.DBS_UPDATE_USER
--               ,W_BUN_JUCHU.DBS_UPDATE_DATE
--           FROM W_BUN_JUCHU
--          WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
--            AND W_BUN_JUCHU.W_SERIAL  = @SERIAL


        --ステータス変更履歴保存(新規作成)
        --変更日時はストアド上のシステム日時
        --ヘッダのステータス<>履歴のAFTER_STSの場合
        SET @CREATE_DATE = ( SELECT DISTINCT
                                    MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                               FROM W_BUN_JUCHU
                              WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                AND W_BUN_JUCHU.W_ROW     = 1
                           )


        SET @AFTER_STS  = ( SELECT DISTINCT
                                   W_BUN_JUCHU.BUNSEKI_STS
                              FROM W_BUN_JUCHU 
                              WHERE W_BUN_JUCHU.W_USER_ID       = @USER_ID
                                AND W_BUN_JUCHU.W_SERIAL        = @SERIAL
                                AND W_BUN_JUCHU.W_ROW           = 1
                                AND W_BUN_JUCHU.DBS_UPDATE_DATE = @CREATE_DATE
                          )


--         SET @BEFORE_STS = NULL

        INSERT INTO
               T_BUN_STS_R
        SELECT DISTINCT
               @JURI_NO
              ,CONCAT( SUBSTRING( @CREATE_DATE ,3  ,4 ) ,'/'
                      ,SUBSTRING( @CREATE_DATE ,8  ,2 ) ,'/'
                      ,SUBSTRING( @CREATE_DATE ,11 ,2 ) ,' '
                      ,SUBSTRING( @CREATE_DATE ,14 ,2 ) ,':'
                      ,SUBSTRING( @CREATE_DATE ,17 ,2 ) ,':'
                      ,SUBSTRING( @CREATE_DATE ,20 ,2 ) )
              ,NULL
              ,@AFTER_STS
              ,1
              ,W_BUN_JUCHU.DBS_CREATE_USER
              ,W_BUN_JUCHU.DBS_CREATE_DATE
              ,W_BUN_JUCHU.DBS_UPDATE_USER
              ,W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID       = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL        = @SERIAL
           AND W_BUN_JUCHU.W_ROW           = 1
           AND W_BUN_JUCHU.DBS_UPDATE_DATE = @CREATE_DATE


        --対象見積のステータスを受注済に変更
        IF @MITSU_NO <> ''
          BEGIN
            UPDATE T_MITSU_H
               SET T_MITSU_H.MITSU_STS = '5'
              FROM T_MITSU_H
             WHERE T_MITSU_H.MITSU_NO = @MITSU_NO
          END


        --ワークテーブルクリア
        DELETE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL  = @SERIAL

      END

    --更新処理
    ELSE IF @MODE = 2
      BEGIN

         --受理No.セット
         SET @JURI_NO = @REF_NO

--          SET @JURI_NO =  ( SELECT W_BUN_JUCHU.JURI_NO
--                              FROM W_BUN_JUCHU
--                             WHERE W_BUN_JUCHU.W_USER_ID   = @USER_ID
--                               AND W_BUN_JUCHU.W_SERIAL    = @SERIAL
--                               AND W_BUN_JUCHU.JURI_EDA_NO = 1
--                               AND W_BUN_JUCHU.W_ROW       = 1 )

        --見積No.取得
        SET @MITSU_NO = ( SELECT MITSU_NO
                            FROM W_BUN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 
                          --最新の情報を採用する
                             AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT
                                                                        MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                                   FROM W_BUN_JUCHU
                                                                  WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                                    AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                                    AND W_BUN_JUCHU.W_ROW     = 1      ))

        --詳細テーブル用SEQ生成処理
        UPDATE W_BUN_JUCHU
           SET W_BUN_JUCHU.SEQ = WORK_TBL.SEQ
          FROM W_BUN_JUCHU
         INNER JOIN
               ( SELECT
                        ( SELECT CASE WHEN MAX(T_TBL.SEQ) IS NULL
                                 THEN 0
                                 ELSE MAX(T_TBL.SEQ)
                                 END
                            FROM W_BUN_JUCHU AS T_TBL
                           WHERE T_TBL.JURI_NO     = UPDATE_TBL.JURI_NO
                             AND T_TBL.JURI_EDA_NO = UPDATE_TBL.JURI_EDA_NO
                        ) + ROW_NUMBER() OVER ( PARTITION BY UPDATE_TBL.JURI_EDA_NO
                                                    ORDER BY UPDATE_TBL.JURI_EDA_NO
                                                            ,UPDATE_TBL.SEQ ) AS SEQ
                       ,UPDATE_TBL.JURI_NO
                       ,UPDATE_TBL.JURI_EDA_NO
                       ,UPDATE_TBL.W_ROW
                       ,UPDATE_TBL.W_USER_ID
                   FROM W_BUN_JUCHU AS UPDATE_TBL
                  WHERE UPDATE_TBL.W_USER_ID = @USER_ID
                    AND UPDATE_TBL.W_SERIAL  = @SERIAL
                    AND UPDATE_TBL.SEQ IS NULL
               ) AS WORK_TBL
            ON WORK_TBL.JURI_NO     = W_BUN_JUCHU.JURI_NO
           AND WORK_TBL.JURI_EDA_NO = W_BUN_JUCHU.JURI_EDA_NO
           AND WORK_TBL.W_ROW       = W_BUN_JUCHU.W_ROW
           AND WORK_TBL.W_USER_ID   = W_BUN_JUCHU.W_USER_ID

        --既存データ削除（ヘッダ）
        DELETE
          FROM T_BUN_JUCHU_H
         WHERE T_BUN_JUCHU_H.JURI_NO = @JURI_NO

        --既存データ削除（ボディ）
        DELETE
          FROM T_BUN_JUCHU_B
         WHERE T_BUN_JUCHU_B.JURI_NO = @JURI_NO

        --既存データ削除（詳細）
        DELETE
          FROM T_BUN_JUCHU_SHOSAI
         WHERE T_BUN_JUCHU_SHOSAI.JURI_NO = @JURI_NO


        --更新ヘッダ(ワークテーブル→テーブル)
        INSERT INTO
               T_BUN_JUCHU_H
        SELECT DISTINCT
               W_BUN_JUCHU.JURI_NO
              ,W_BUN_JUCHU.BUNSEKI_STS
              ,W_BUN_JUCHU.JUCHU_KBN
              ,W_BUN_JUCHU.BUSHO_CD
              ,W_BUN_JUCHU.NYURYOKU_DATETIME
              ,W_BUN_JUCHU.NYURYOKUSHA_CD
              ,W_BUN_JUCHU.REF_JURI_NO
              ,W_BUN_JUCHU.MITSU_NO
              ,W_BUN_JUCHU.ATENA_CD
              ,W_BUN_JUCHU.ATENA
              ,W_BUN_JUCHU.SEIKYU_CD
              ,W_BUN_JUCHU.BUNSEKI_HOHO_CD
              ,W_BUN_JUCHU.KEISHIKI_KBN
              ,W_BUN_JUCHU.NOHIN_HOHO
              ,W_BUN_JUCHU.KOSU
              ,W_BUN_JUCHU.EIGYO_TANTO_CD
              ,W_BUN_JUCHU.IRAI_DATE
              ,W_BUN_JUCHU.KANRYO_DATE
              ,W_BUN_JUCHU.KANSEI_DATE
              ,W_BUN_JUCHU.SOKUHO_KBN
              ,W_BUN_JUCHU.HAKKO_DATE
              ,W_BUN_JUCHU.NOHIN_DATE
              ,W_BUN_JUCHU.KENMEI
              ,W_BUN_JUCHU.MOKUTEKI
              ,W_BUN_JUCHU.KISAI_JIKO
              ,W_BUN_JUCHU.EDA_SHIRYO_FLG
              ,W_BUN_JUCHU.SAISHU_KAISHA_MEI
              ,W_BUN_JUCHU.SAISHU_SHA
              ,W_BUN_JUCHU.SAISHU_HOHO
              ,W_BUN_JUCHU.SAISHU_BASHO
              ,W_BUN_JUCHU.TENKO
              ,W_BUN_JUCHU.KION
              ,W_BUN_JUCHU.SUION
              ,W_BUN_JUCHU.SAISHU_DATE
              ,W_BUN_JUCHU.SAISHU_TIME
              ,W_BUN_JUCHU.SHOKEN_FLG
              ,W_BUN_JUCHU.GAISO_KBN
              ,W_BUN_JUCHU.YOKI
              ,W_BUN_JUCHU.HENKYAKU
              ,W_BUN_JUCHU.HOKOKU_HOHO_KBN
              ,W_BUN_JUCHU.BUSU
              ,W_BUN_JUCHU.CHUKAN_DATE_1
              ,W_BUN_JUCHU.CHUKAN_NAIYO_1
              ,W_BUN_JUCHU.CHUKAN_DATE_2
              ,W_BUN_JUCHU.CHUKAN_NAIYO_2
              ,W_BUN_JUCHU.CHUKAN_DATE_3
              ,W_BUN_JUCHU.CHUKAN_NAIYO_3
              ,W_BUN_JUCHU.BIKO
              ,W_BUN_JUCHU.FUYO_FLG
              ,W_BUN_JUCHU.NEW_FLG
              ,W_BUN_JUCHU.HENKO_FLG
              ,W_BUN_JUCHU.HOKOKU_CD_1
              ,W_BUN_JUCHU.HOKOKU_MEI_1
              ,W_BUN_JUCHU.BUSHO_1
              ,W_BUN_JUCHU.TANTO_1
              ,W_BUN_JUCHU.TEL_1
              ,W_BUN_JUCHU.FAX_1
              ,W_BUN_JUCHU.MAIL_1
              ,W_BUN_JUCHU.YUBIN_NO_1
              ,W_BUN_JUCHU.ADDRESS_1
              ,W_BUN_JUCHU.CHUKAN_SOFU_FLG_1
              ,W_BUN_JUCHU.SOKUHO_SOFU_FLG_1
              ,W_BUN_JUCHU.HOKOKUSHO_SOFU_FLG_1
              ,W_BUN_JUCHU.HOKOKU_CD_2
              ,W_BUN_JUCHU.HOKOKU_MEI_2
              ,W_BUN_JUCHU.BUSHO_2
              ,W_BUN_JUCHU.TANTO_2
              ,W_BUN_JUCHU.TEL_2
              ,W_BUN_JUCHU.FAX_2
              ,W_BUN_JUCHU.MAIL_2
              ,W_BUN_JUCHU.YUBIN_NO_2
              ,W_BUN_JUCHU.ADDRESS_2
              ,W_BUN_JUCHU.CHUKAN_SOFU_FLG_2
              ,W_BUN_JUCHU.SOKUHO_SOFU_FLG_2
              ,W_BUN_JUCHU.HOKOKUSHO_SOFU_FLG_2
              ,W_BUN_JUCHU.HOKOKU_CD_3
              ,W_BUN_JUCHU.HOKOKU_MEI_3
              ,W_BUN_JUCHU.BUSHO_3
              ,W_BUN_JUCHU.TANTO_3
              ,W_BUN_JUCHU.TEL_3
              ,W_BUN_JUCHU.FAX_3
              ,W_BUN_JUCHU.MAIL_3
              ,W_BUN_JUCHU.YUBIN_NO_3
              ,W_BUN_JUCHU.ADDRESS_3
              ,W_BUN_JUCHU.CHUKAN_SOFU_FLG_3
              ,W_BUN_JUCHU.SOKUHO_SOFU_FLG_3
              ,W_BUN_JUCHU.HOKOKUSHO_SOFU_FLG_3
              ,W_BUN_JUCHU.DEMPYO_HAKKO_KBN
              ,W_BUN_JUCHU.BUN_SORT_SEQ
              ,'False'
              ,W_BUN_JUCHU.DBS_STATUS
              ,W_BUN_JUCHU.DBS_CREATE_USER
              ,W_BUN_JUCHU.DBS_CREATE_DATE
              ,W_BUN_JUCHU.DBS_UPDATE_USER
              ,W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID   = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL    = @SERIAL
           AND W_BUN_JUCHU.W_ROW       = 1
           --最新の情報を採用する
           AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT 
                                                      MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                 FROM W_BUN_JUCHU
                                                WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                  AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                  AND W_BUN_JUCHU.W_ROW       = 1      )


        --更新ボディ(ワークテーブル→テーブル)
        INSERT INTO
               T_BUN_JUCHU_B
        SELECT
               W_BUN_JUCHU.JURI_NO
              ,W_BUN_JUCHU.JURI_EDA_NO
              ,W_BUN_JUCHU.SAISHU_KAISHA_MEI_B
              ,W_BUN_JUCHU.SAISHU_SHA_B
              ,W_BUN_JUCHU.SAISHU_HOHO_B
              ,W_BUN_JUCHU.SAISHU_BASHO_B
              ,W_BUN_JUCHU.TENKO_B
              ,W_BUN_JUCHU.KION_B
              ,W_BUN_JUCHU.SUION_B
              ,W_BUN_JUCHU.SAISHU_DATE_B
              ,W_BUN_JUCHU.SAISHU_TIME_B
              ,W_BUN_JUCHU.SHIRYO_SHURUI
              ,W_BUN_JUCHU.SHIRYO_MEI
              ,W_BUN_JUCHU.IKKATSU_M
              ,W_BUN_JUCHU.IKKATSU_N
              ,W_BUN_JUCHU.BUNSEKI_GUN_CD
              ,W_BUN_JUCHU.EBIKO
              ,'False'
              ,W_BUN_JUCHU.DBS_STATUS
              ,W_BUN_JUCHU.DBS_CREATE_USER
              ,W_BUN_JUCHU.DBS_CREATE_DATE
              ,W_BUN_JUCHU.DBS_UPDATE_USER
              ,W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
           AND W_BUN_JUCHU.W_ROW     = 1


        --更新分析項目リスト(ワークテーブル→テーブル)
        INSERT INTO
               T_BUN_JUCHU_SHOSAI
        SELECT
               W_BUN_JUCHU.JURI_NO
              ,W_BUN_JUCHU.JURI_EDA_NO
              ,W_BUN_JUCHU.SEQ
              ,ROW_NUMBER() OVER(PARTITION BY JURI_NO,JURI_EDA_NO ORDER BY CASE WHEN M_BUN_SORT_B.SORT_NO IS NULL THEN 1 ELSE 0 END,M_BUN_SORT_B.SORT_NO,W_BUN_JUCHU.GYO_NO)
              ,W_BUN_JUCHU.BUNSEKI_CD
              ,W_BUN_JUCHU.BUNSEKI_MEI
              ,W_BUN_JUCHU.BUNSEKI_TANI
              ,W_BUN_JUCHU.BUNSEKI_DATA
              ,W_BUN_JUCHU.BUNSEKI_NO
              ,W_BUN_JUCHU.URAGAKI_PRINT_FLG
              ,'False'
              ,W_BUN_JUCHU.DBS_STATUS
              ,W_BUN_JUCHU.DBS_CREATE_USER
              ,W_BUN_JUCHU.DBS_CREATE_DATE
              ,W_BUN_JUCHU.DBS_UPDATE_USER
              ,W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
		      LEFT JOIN M_BUN_SORT_B
                ON      M_BUN_SORT_B.BUNSEKI_HOHO_CD = ( SELECT BUNSEKI_HOHO_CD
                            FROM W_BUN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 
                          --最新の情報を採用する
                             AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT
                                                                        MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                                   FROM W_BUN_JUCHU
                                                                  WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                                    AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                                    AND W_BUN_JUCHU.W_ROW     = 1      ))
                    AND M_BUN_SORT_B.SEQ = ( SELECT BUN_SORT_SEQ
                            FROM W_BUN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 
                          --最新の情報を採用する
                             AND W_BUN_JUCHU.DBS_UPDATE_DATE = ( SELECT DISTINCT
                                                                        MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                                                                   FROM W_BUN_JUCHU
                                                                  WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                                                    AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                                                    AND W_BUN_JUCHU.W_ROW     = 1      ))
                    AND M_BUN_SORT_B.BUNSEKI_CD = W_BUN_JUCHU.BUNSEKI_CD

         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
           AND W_BUN_JUCHU.GYO_NO IS NOT NULL

--         --項目別サンプルリスト反映
--         --不一致分削除
--         DELETE DEL_TBL
--           FROM T_KOMOKU_SAMPLE AS DEL_TBL
--           LEFT JOIN
--                W_BUN_JUCHU
--             ON W_BUN_JUCHU.JURI_NO     = DEL_TBL.JURI_NO
--            AND W_BUN_JUCHU.JURI_EDA_NO = DEL_TBL.JURI_EDA_NO
--            AND W_BUN_JUCHU.SEQ         = DEL_TBL.SEQ
--          WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
--            AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
--            AND (    W_BUN_JUCHU.JURI_NO IS NULL 
--                  OR DEL_TBL.BUNSEKI_CD <> W_BUN_JUCHU.BUNSEKI_CD )
-- 
--         --追加分挿入
--         INSERT INTO
--                T_KOMOKU_SAMPLE
--         SELECT 
--                W_BUN_JUCHU.JURI_NO
--               ,W_BUN_JUCHU.JURI_EDA_NO
--               ,W_BUN_JUCHU.SEQ
--               ,W_BUN_JUCHU.BUNSEKI_CD
--               ,NULL
--               ,'1'
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,NULL
--               ,'1'
--               ,W_BUN_JUCHU.DBS_CREATE_USER
--               ,W_BUN_JUCHU.DBS_CREATE_DATE
--               ,W_BUN_JUCHU.DBS_UPDATE_USER
--               ,W_BUN_JUCHU.DBS_UPDATE_DATE
--           FROM W_BUN_JUCHU
--           LEFT JOIN
--                T_KOMOKU_SAMPLE
--             ON T_KOMOKU_SAMPLE.JURI_NO     = W_BUN_JUCHU.JURI_NO
--            AND T_KOMOKU_SAMPLE.JURI_EDA_NO = W_BUN_JUCHU.JURI_EDA_NO
--            AND T_KOMOKU_SAMPLE.SEQ         = W_BUN_JUCHU.SEQ
--          WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
--            AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
--            AND T_KOMOKU_SAMPLE.JURI_NO IS NULL


        --ステータス変更履歴保存(更新)
        --変更日時はストアド上のシステム日時
        --ヘッダのステータス<>履歴のAFTER_STSの場合
        SET @CREATE_DATE = ( SELECT DISTINCT
                                    MAX(W_BUN_JUCHU.DBS_UPDATE_DATE)
                               FROM W_BUN_JUCHU
                              WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
                                AND W_BUN_JUCHU.W_SERIAL  = @SERIAL
                                AND W_BUN_JUCHU.W_ROW     = 1
                           )

        SET @AFTER_STS  = ( SELECT DISTINCT
                                   W_BUN_JUCHU.BUNSEKI_STS
                              FROM W_BUN_JUCHU 
                              WHERE W_BUN_JUCHU.W_USER_ID       = @USER_ID
                                AND W_BUN_JUCHU.W_SERIAL        = @SERIAL
                                AND W_BUN_JUCHU.W_ROW           = 1
                                AND W_BUN_JUCHU.DBS_UPDATE_DATE = @CREATE_DATE
                          )

        SET @BEFORE_STS = ( SELECT DISTINCT 
                                   T_BUN_STS_R.AFTER_STS
                              FROM T_BUN_STS_R
                             WHERE T_BUN_STS_R.JURI_NO       = @JURI_NO
                               AND T_BUN_STS_R.MOD_DATE_TIME = ( SELECT DISTINCT
                                                                        MAX(T_BUN_STS_R.MOD_DATE_TIME)
                                                                   FROM T_BUN_STS_R
                                                                  WHERE T_BUN_STS_R.JURI_NO = @JURI_NO )
                          )

        IF @AFTER_STS != @BEFORE_STS
          BEGIN

            INSERT INTO
                   T_BUN_STS_R
            SELECT DISTINCT
                   @JURI_NO
                  ,CONCAT( SUBSTRING( @CREATE_DATE ,3  ,4 ) ,'/'
                          ,SUBSTRING( @CREATE_DATE ,8  ,2 ) ,'/'
                          ,SUBSTRING( @CREATE_DATE ,11 ,2 ) ,' '
                          ,SUBSTRING( @CREATE_DATE ,14 ,2 ) ,':'
                          ,SUBSTRING( @CREATE_DATE ,17 ,2 ) ,':'
                          ,SUBSTRING( @CREATE_DATE ,20 ,2 ) )
                  ,@BEFORE_STS
                  ,@AFTER_STS
                  ,1
                  ,W_BUN_JUCHU.DBS_CREATE_USER
                  ,W_BUN_JUCHU.DBS_CREATE_DATE
                  ,W_BUN_JUCHU.DBS_UPDATE_USER
                  ,W_BUN_JUCHU.DBS_UPDATE_DATE
              FROM W_BUN_JUCHU
             WHERE W_BUN_JUCHU.W_USER_ID       = @USER_ID
               AND W_BUN_JUCHU.W_SERIAL        = @SERIAL
               AND W_BUN_JUCHU.W_ROW           = 1
               AND W_BUN_JUCHU.DBS_UPDATE_DATE = @CREATE_DATE

          END


        --対象見積のステータスを受注済に変更
        IF @MITSU_NO <> ''
          BEGIN
            UPDATE T_MITSU_H
               SET T_MITSU_H.MITSU_STS = '5'
              FROM T_MITSU_H
             WHERE T_MITSU_H.MITSU_NO = @MITSU_NO
          END


        --ワークテーブルクリア
        DELETE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL  = @SERIAL

      END

    --削除処理
    ELSE IF @MODE = 3
      BEGIN

         --受理No./更新ユーザー/更新日時セット
        SELECT @JURI_NO     = W_BUN_JUCHU.JURI_NO
              ,@UPDATE_USER = W_BUN_JUCHU.DBS_UPDATE_USER
              ,@UPDATE_DATE = W_BUN_JUCHU.DBS_UPDATE_DATE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID   = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL    = @SERIAL
           AND W_BUN_JUCHU.JURI_EDA_NO = 1
           AND W_BUN_JUCHU.W_ROW       = 1


        --削除フラグ設定（ヘッダ）
        UPDATE T_BUN_JUCHU_H
           SET T_BUN_JUCHU_H.DEL_FLG = 'True'
              ,T_BUN_JUCHU_H.DBS_CREATE_USER = @UPDATE_USER
              ,T_BUN_JUCHU_H.DBS_UPDATE_DATE = @UPDATE_DATE
         WHERE T_BUN_JUCHU_H.JURI_NO = @JURI_NO

        --削除フラグ設定（ボディ）
        UPDATE T_BUN_JUCHU_B
           SET T_BUN_JUCHU_B.DEL_FLG = 'True'
              ,T_BUN_JUCHU_B.DBS_CREATE_USER = @UPDATE_USER
              ,T_BUN_JUCHU_B.DBS_UPDATE_DATE = @UPDATE_DATE
         WHERE T_BUN_JUCHU_B.JURI_NO = @JURI_NO

        --削除フラグ設定（詳細）
        UPDATE T_BUN_JUCHU_SHOSAI
           SET T_BUN_JUCHU_SHOSAI.DEL_FLG = 'True'
              ,T_BUN_JUCHU_SHOSAI.DBS_CREATE_USER = @UPDATE_USER
              ,T_BUN_JUCHU_SHOSAI.DBS_UPDATE_DATE = @UPDATE_DATE
         WHERE T_BUN_JUCHU_SHOSAI.JURI_NO = @JURI_NO

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL  = @SERIAL

      END

    --枝番削除処理
    ELSE IF @MODE = 4
      BEGIN

--          --受理No.セット
--          SET @JURI_NO =  ( SELECT W_BUN_JUCHU.JURI_NO
--                              FROM W_BUN_JUCHU
--                             WHERE W_BUN_JUCHU.W_USER_ID   = @USER_ID
--                               AND W_BUN_JUCHU.W_SERIAL    = @SERIAL
--                               AND W_BUN_JUCHU.JURI_EDA_NO = 1
--                               AND W_BUN_JUCHU.W_ROW       = 1 )

        --対象枝番データ削除
        DELETE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID   = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL    = @SERIAL
           AND W_BUN_JUCHU.JURI_EDA_NO = @EDA

        --削除枝番以降の枝番デクリメント（詳細）
        UPDATE W_BUN_JUCHU
           SET W_BUN_JUCHU.JURI_EDA_NO = W_BUN_JUCHU.JURI_EDA_NO - 1
         WHERE W_BUN_JUCHU.W_USER_ID   = @USER_ID
           AND W_BUN_JUCHU.W_SERIAL    = @SERIAL
           AND W_BUN_JUCHU.JURI_EDA_NO > @EDA

      END

    --見積接続
    ELSE IF @MODE = 5
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID

        --見積データ読込(テーブル→ワークテーブル)
        INSERT INTO
               W_BUN_JUCHU
        SELECT
               @USER_ID
              ,@SERIAL
              ,1
              ,T_MITSU_B.GYO_NO
              ,1
              --ヘッダテーブル
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,@USER_ID
              ,NULL
              ,T_MITSU_H.MITSU_NO
              ,T_MITSU_H.SEIKYU_CD
              ,T_MITSU_H.SEIKYU_MEI
              ,T_MITSU_H.SEIKYU_CD
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,T_MITSU_H.EIGYO_TANTO_CD
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,T_MITSU_H.KENMEI
              ,NULL
              ,NULL
              ,'False'
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,'False'
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,'False'
              ,'False'
              ,'False'
              ,NULL
              ,M_AITESAKI.AITE_MEI
              ,M_AITESAKI.BUSHO_MEI
              ,M_AITESAKI.TANTO_MEI
              ,M_AITESAKI.TEL
              ,M_AITESAKI.FAX
              ,M_AITESAKI.MAIL
              ,M_AITESAKI.YUBIN_NO
              ,CONCAT(M_AITESAKI.ADDRESS_1,M_AITESAKI.ADDRESS_2)
              ,'False'
              ,'False'
              ,'False'
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,'False'
              ,'False'
              ,'False'
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,'False'
              ,'False'
              ,'False'
              ,'False'
			  ,NULL
              --ボディテーブル
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              --詳細テーブル
              ,T_MITSU_B.GYO_NO
              ,T_MITSU_B.GYO_NO
              ,T_MITSU_B.SHOHIN_CD
              ,T_MITSU_B.SHOHIN_MEI
              ,M_SHOHIN.BUNSEKI_TANI
              ,NULL
              ,M_SHOHIN.BUNSEKI_NO
              ,'False'
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
          FROM T_MITSU_H
          LEFT JOIN
               T_MITSU_B
            ON T_MITSU_B.MITSU_NO = T_MITSU_H.MITSU_NO
          LEFT JOIN
               M_AITESAKI
            ON M_AITESAKI.AITE_CD = T_MITSU_H.SEIKYU_CD
          LEFT JOIN
               M_SHOHIN
            ON M_SHOHIN.SHOHIN_CD = T_MITSU_B.SHOHIN_CD
         WHERE T_MITSU_H.MITSU_NO    =  @REF_NO
           AND M_SHOHIN.BUNSEKI_FLG  =  'True'
           AND M_SHOHIN.SHOKEIHI_FLG <> 'True'
           AND T_MITSU_B.ROW_KBN     =  1

      END

    --参照作成処理
    ELSE IF @MODE = 6
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_JUCHU
         WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID

        --読込(テーブル→ワークテーブル)
        INSERT INTO
               W_BUN_JUCHU
        SELECT
               @USER_ID
              ,@SERIAL
              ,T_BUN_JUCHU_SHOSAI.JURI_EDA_NO
              ,T_BUN_JUCHU_SHOSAI.GYO_NO
              ,1
              --ヘッダテーブル
              ,NULL
              ,1
              ,T_BUN_JUCHU_H.JUCHU_KBN
              ,NULL
              ,NULL
              ,@USER_ID
              ,NULL
              ,T_BUN_JUCHU_H.MITSU_NO
              ,J_ATENA.AITE_CD
              ,CASE ISNULL(J_ATENA.AITE_CD,'')
               WHEN '' THEN T_BUN_JUCHU_H.ATENA
               ELSE J_ATENA.AITE_MEI
               END
              ,J_SEIKYU.AITE_CD
              ,T_BUN_JUCHU_H.BUNSEKI_HOHO_CD
              ,T_BUN_JUCHU_H.KEISHIKI_KBN
              ,NULL
              ,NULL
              ,J_SEIKYU.EIGYO_TANTO_CD
              ,NULL
              ,NULL
              ,NULL
              ,T_BUN_JUCHU_H.SOKUHO_KBN
              ,NULL
              ,NULL
              ,T_BUN_JUCHU_H.KENMEI
              ,T_BUN_JUCHU_H.MOKUTEKI
              ,T_BUN_JUCHU_H.KISAI_JIKO
              ,T_BUN_JUCHU_H.EDA_SHIRYO_FLG
              ,T_BUN_JUCHU_H.SAISHU_KAISHA_MEI
              ,T_BUN_JUCHU_H.SAISHU_SHA
              ,T_BUN_JUCHU_H.SAISHU_HOHO
              ,T_BUN_JUCHU_H.SAISHU_BASHO
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,T_BUN_JUCHU_H.SHOKEN_FLG
              ,T_BUN_JUCHU_H.GAISO_KBN
              ,T_BUN_JUCHU_H.YOKI
              ,NULL
              ,T_BUN_JUCHU_H.HOKOKU_HOHO_KBN
              ,T_BUN_JUCHU_H.BUSU
              ,NULL
              ,T_BUN_JUCHU_H.CHUKAN_NAIYO_1
              ,NULL
              ,T_BUN_JUCHU_H.CHUKAN_NAIYO_2
              ,NULL
              ,T_BUN_JUCHU_H.CHUKAN_NAIYO_3
              ,T_BUN_JUCHU_H.BIKO
              ,T_BUN_JUCHU_H.FUYO_FLG
              ,'False'
              ,'False'
              ,T_BUN_JUCHU_H.HOKOKU_CD_1
              ,CASE ISNULL(J_ATENA.AITE_CD,'')
               WHEN '' THEN T_BUN_JUCHU_H.HOKOKU_MEI_1
               ELSE J_ATENA.AITE_MEI
               END
              ,T_BUN_JUCHU_H.BUSHO_1
              ,T_BUN_JUCHU_H.TANTO_1
              ,T_BUN_JUCHU_H.TEL_1
              ,T_BUN_JUCHU_H.FAX_1
              ,T_BUN_JUCHU_H.MAIL_1
              ,T_BUN_JUCHU_H.YUBIN_NO_1
              ,T_BUN_JUCHU_H.ADDRESS_1
              ,T_BUN_JUCHU_H.CHUKAN_SOFU_FLG_1
              ,T_BUN_JUCHU_H.SOKUHO_SOFU_FLG_1
              ,T_BUN_JUCHU_H.HOKOKUSHO_SOFU_FLG_1
              ,T_BUN_JUCHU_H.HOKOKU_CD_2
              ,T_BUN_JUCHU_H.HOKOKU_MEI_2
              ,T_BUN_JUCHU_H.BUSHO_2
              ,T_BUN_JUCHU_H.TANTO_2
              ,T_BUN_JUCHU_H.TEL_2
              ,T_BUN_JUCHU_H.FAX_2
              ,T_BUN_JUCHU_H.MAIL_2
              ,T_BUN_JUCHU_H.YUBIN_NO_2
              ,T_BUN_JUCHU_H.ADDRESS_2
              ,T_BUN_JUCHU_H.CHUKAN_SOFU_FLG_2
              ,T_BUN_JUCHU_H.SOKUHO_SOFU_FLG_2
              ,T_BUN_JUCHU_H.HOKOKUSHO_SOFU_FLG_2
              ,T_BUN_JUCHU_H.HOKOKU_CD_3
              ,T_BUN_JUCHU_H.HOKOKU_MEI_3
              ,T_BUN_JUCHU_H.BUSHO_3
              ,T_BUN_JUCHU_H.TANTO_3
              ,T_BUN_JUCHU_H.TEL_3
              ,T_BUN_JUCHU_H.FAX_3
              ,T_BUN_JUCHU_H.MAIL_3
              ,T_BUN_JUCHU_H.YUBIN_NO_3
              ,T_BUN_JUCHU_H.ADDRESS_3
              ,T_BUN_JUCHU_H.CHUKAN_SOFU_FLG_3
              ,T_BUN_JUCHU_H.SOKUHO_SOFU_FLG_3
              ,T_BUN_JUCHU_H.HOKOKUSHO_SOFU_FLG_3
              ,2
			  ,T_BUN_JUCHU_H.BUN_SORT_SEQ
              --ボディテーブル
              ,T_BUN_JUCHU_B.SAISHU_KAISHA_MEI
              ,T_BUN_JUCHU_B.SAISHU_SHA
              ,T_BUN_JUCHU_B.SAISHU_HOHO
              ,T_BUN_JUCHU_B.SAISHU_BASHO
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,NULL
              ,T_BUN_JUCHU_B.SHIRYO_SHURUI
              ,T_BUN_JUCHU_B.SHIRYO_MEI
              ,T_BUN_JUCHU_B.IKKATSU_M
              ,T_BUN_JUCHU_B.IKKATSU_N
              ,T_BUN_JUCHU_B.BUNSEKI_GUN_CD
              ,T_BUN_JUCHU_B.EBIKO
              --詳細テーブル
              ,NULL
              ,T_BUN_JUCHU_SHOSAI.GYO_NO
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_CD
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_MEI
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_TANI
              ,NULL
              ,T_BUN_JUCHU_SHOSAI.BUNSEKI_NO
              ,'False'
              ,T_BUN_JUCHU_SHOSAI.DBS_STATUS
              ,T_BUN_JUCHU_SHOSAI.DBS_CREATE_USER
              ,T_BUN_JUCHU_SHOSAI.DBS_CREATE_DATE
              ,T_BUN_JUCHU_SHOSAI.DBS_UPDATE_USER
              ,T_BUN_JUCHU_SHOSAI.DBS_UPDATE_DATE
          FROM T_BUN_JUCHU_H
          LEFT JOIN
               T_BUN_JUCHU_B
            ON T_BUN_JUCHU_B.JURI_NO = T_BUN_JUCHU_H.JURI_NO
          LEFT JOIN
               T_BUN_JUCHU_SHOSAI
            ON T_BUN_JUCHU_SHOSAI.JURI_NO     =  T_BUN_JUCHU_H.JURI_NO
           AND T_BUN_JUCHU_SHOSAI.JURI_EDA_NO =  T_BUN_JUCHU_B.JURI_EDA_NO
          LEFT JOIN
               M_AITESAKI                     AS J_SEIKYU
            ON J_SEIKYU.AITE_CD               =  T_BUN_JUCHU_H.SEIKYU_CD
           AND J_SEIKYU.MISHIYO_FLG           =  'False'
          LEFT JOIN
               M_AITESAKI                     AS J_ATENA
            ON J_ATENA.AITE_CD                =  T_BUN_JUCHU_H.ATENA_CD
           AND J_ATENA.MISHIYO_FLG            =  'False'
         WHERE T_BUN_JUCHU_H.JURI_NO          =  @REF_NO

      END

    --ステータス変更処理
    ELSE IF @MODE = 7
      BEGIN

        SET @CREATE_DATE = 'DT'+CONVERT(VARCHAR,GETDATE(),121)
        SET @AFTER_STS  = @SERIAL
        SET @BEFORE_STS = ( SELECT DISTINCT 
                                   T_BUN_STS_R.AFTER_STS
                              FROM T_BUN_STS_R
                             WHERE T_BUN_STS_R.JURI_NO       = @REF_NO
                               AND T_BUN_STS_R.MOD_DATE_TIME = ( SELECT DISTINCT
                                                                        MAX(T_BUN_STS_R.MOD_DATE_TIME)
                                                                   FROM T_BUN_STS_R
                                                                  WHERE T_BUN_STS_R.JURI_NO = @REF_NO )
                          )


        --ステータス変更
        UPDATE T_BUN_JUCHU_H
           SET T_BUN_JUCHU_H.BUNSEKI_STS = @SERIAL
              ,T_BUN_JUCHU_H.DBS_UPDATE_USER = @USER_ID
              ,T_BUN_JUCHU_H.DBS_UPDATE_DATE = @CREATE_DATE
         WHERE T_BUN_JUCHU_H.JURI_NO = @REF_NO

        --ステータス変更履歴保存(更新)
        --変更日時はストアド上のシステム日時
        --変更ステータス<>履歴のAFTER_STSの場合
        IF @AFTER_STS != @BEFORE_STS
          BEGIN

            INSERT INTO
                   T_BUN_STS_R
            SELECT
                   @REF_NO
                  ,Format(GETDATE(),'yyyy/MM/dd HH:mm:ss')
                  ,@BEFORE_STS
                  ,@AFTER_STS
                  ,1
                  ,@USER_ID
                  ,@CREATE_DATE
                  ,@USER_ID
                  ,@CREATE_DATE
          END

      END

    --見積No.設定処理
    ELSE IF @MODE = 8
      BEGIN

        SET @CREATE_DATE = 'DT'+CONVERT(VARCHAR,GETDATE(),121)
        SET @JURI_NO     = @REF_NO
        SET @MITSU_NO    = @SERIAL

        --ステータス変更
        UPDATE T_BUN_JUCHU_H
           SET T_BUN_JUCHU_H.MITSU_NO        = @MITSU_NO
              ,T_BUN_JUCHU_H.DBS_UPDATE_USER = @USER_ID
              ,T_BUN_JUCHU_H.DBS_UPDATE_DATE = @CREATE_DATE
         WHERE T_BUN_JUCHU_H.JURI_NO         = @REF_NO

      END


    --正常終了
    INSERT INTO @TBL VALUES( @JURI_NO ,0 ,NULL )

    --処理結果返却
    SELECT RESULT_JURI_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_BUN_JUCHU
     WHERE W_BUN_JUCHU.W_USER_ID = @USER_ID
       AND W_BUN_JUCHU.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( 0 ,ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_JURI_NO ,RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END


