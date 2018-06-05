-- 項目別サンプルサンプルリスト保存ストアド

-- DROP PROCEDURE SP_SAVE_T_KOMOKU_SAMPLE

CREATE PROCEDURE SP_SAVE_T_KOMOKU_SAMPLE
       @USER_ID  NVARCHAR(64)   --ユーザーID
      ,@SERIAL   NVARCHAR(50)   --シリアル
      ,@MODE     INT            --処理モード
      ,@JOKEN_W  NVARCHAR(MAX)  --読込時条件
AS
--保存処理実行
--[モード] 0:読込 / 1:保存 / 2:削除

BEGIN
    --戻り値用テーブル変数
    DECLARE @TBL TABLE (
      RESULT_CD       int NOT NULL
     ,RESULT_MESSAGE  NVARCHAR(max)
    )

    --読込処理 ワークテーブルＩＮＳＥＲＴ用
    DECLARE @INS_SQL AS NVARCHAR(MAX)

    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --読込処理
    IF @MODE = 0
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_KOMOKU_SAMPLE_LIST
         WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID

        --ワークテーブルＩＮＳＥＲＴ用ＳＱＬ組立
        SELECT @INS_SQL = 'INSERT INTO'
                        + '       W_BUN_KOMOKU_SAMPLE_LIST '
                        + 'SELECT '
                        + '       ''' + @USER_ID + '''' +                                             -- ユーザーID
                        + '      ,''' + @SERIAL  + '''' +                                             -- シリアル
                        + '      ,ROW_NUMBER() OVER (ORDER BY KANRYO_DATE,JURI_NO,JURI_EDA_NO,GYO_NO)  AS  W_ROW' -- 行番号
                        + '      ,0'                                                                  -- 処理モード
                        + '      ,''False'''                                                          -- 選択フラグ
--                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.*'                                         -- 項目別サンプルリストビュー
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.JURI_NO'                                   -- 受理No.
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_CD'                                  -- 部署CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_MEI'                                 -- 部署名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.NYURYOKU_DATETIME'                         -- 入力日時
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.ATENA_CD'                                  -- 宛名CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.ATENA'                                     -- 宛名名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SEIKYU_CD'                                 -- 請求先CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_HOHO_CD'                           -- 分析方法CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_HOHO'                              -- 分析方法名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.IRAI_DATE'                                 -- 依頼日
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.KANRYO_DATE'                               -- 完了日
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.KENMEI'                                    -- 件名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.MOKUTEKI'                                  -- 目的
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.KISAI_JIKO'                                -- 記載事項
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.CHUKAN_NAIYO_1'                            -- 中間報告日①
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.CHUKAN_NAIYO_2'                            -- 中間報告日②
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.CHUKAN_NAIYO_3'                            -- 中間報告日③
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.H_BIKO'                                    -- 備考
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.HOKOKU_MEI_1'                              -- 報告先１
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_1'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.TANTO_1'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.HOKOKU_MEI_2'                              -- 報告先２
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_2'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.TANTO_2'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.HOKOKU_MEI_3'                              -- 報告先３
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUSHO_3'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.TANTO_3'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO'                               -- 枝番
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHIRYO_SHURU'                              -- 試料種類
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHIRYO_MEI'                                -- 試料名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SEQ'                                       -- SEQ
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.GYO_NO'                                    -- 行番号
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_CD'                                -- 分析項目CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_TANI'                              -- 分析項目単位
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_DATA'                              -- データ
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.BUNSEKI_NO'                                -- 分析番号
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.STATE_KBN'                                 -- 状態CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.STATE_MEI'                                 -- 状態名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.K_BIKO'                                    -- 備考
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEI_DATE'                              -- 測定日
--                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_CD'                             -- 測定者CD
--                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_MEI'                            -- 測定者名
                        + '      ,CASE V_BUN_KOMOKU_SAMPLE_LIST.STATE_KBN'
                        + '            WHEN 1 THEN J_USER.SHAIN_CD'
                        + '            ELSE V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_CD'
                        + '       END'                                                                -- 測定者CD
                        + '      ,CASE V_BUN_KOMOKU_SAMPLE_LIST.STATE_KBN'
                        + '            WHEN 1 THEN J_USER.SHIMEI'
                        + '            ELSE V_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_MEI'
                        + '       END'                                                                -- 測定者名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_01'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_02'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_03'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_04'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_05'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_06'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_07'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_08'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_09'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_10'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_11'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_12'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_13'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_14'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_15'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_16'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_17'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_18'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_19'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_20'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_21'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_22'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_23'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_24'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_25'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.COLUMN_26'
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.FREEWD'                                    -- フリーワード
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHOHIN_BUNRUI'                             -- 商品分類CD
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.SHOHIN_BUNRUI_MEI'                         -- 商品分類名
                        + '      ,V_BUN_KOMOKU_SAMPLE_LIST.M_BIKO'                                    -- 商品備考(分析項目名)
                        + '      ,1 '                                                                 -- DBS領域 レコード状態
                        + '      ,''' + @USER_ID + ''''                                               -- DBS領域 作成ユーザＩＤ
                        + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'                   -- DBS領域 作成日時
                        + '      ,''' + @USER_ID + ''''                                               -- DBS領域 更新ユーザＩＤ
                        + '      ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120)'                   -- DBS領域 更新日時
                        + '  FROM V_BUN_KOMOKU_SAMPLE_LIST '
                        + '  LEFT JOIN M_SHAIN AS J_USER '
                        + '    ON J_USER.SHAIN_CD = ''' + @USER_ID + ''''
                        + @JOKEN_W

        --ワークテーブルＩＮＳＥＲＴ用ＳＱＬ実行
        EXEC(@INS_SQL)

      END

    --保存処理
    ELSE IF @MODE = 1
      BEGIN

        --既存データ削除（詳細）
--         DELETE
--           FROM T_KOMOKU_SAMPLE
--          WHERE EXISTS
--              ( SELECT 1
--                  FROM W_BUN_KOMOKU_SAMPLE_LIST
--                 WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID       = @USER_ID
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.W_SERIAL        = @SERIAL
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO         = T_KOMOKU_SAMPLE.JURI_NO
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO     = T_KOMOKU_SAMPLE.JURI_EDA_NO
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.SEQ             = T_KOMOKU_SAMPLE.SEQ
--                   AND W_BUN_KOMOKU_SAMPLE_LIST.DBS_UPDATE_DATE > T_KOMOKU_SAMPLE.DBS_UPDATE_DATE
--              )

        --既存データ削除(ワークテーブル作成日時＞テーブル更新日時)
        DELETE T_KOMOKU_SAMPLE
          FROM T_KOMOKU_SAMPLE
          LEFT OUTER JOIN W_BUN_KOMOKU_SAMPLE_LIST
            ON W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO = T_KOMOKU_SAMPLE.JURI_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO = T_KOMOKU_SAMPLE.JURI_EDA_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.SEQ = T_KOMOKU_SAMPLE.SEQ

         WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID       = @USER_ID
           AND W_BUN_KOMOKU_SAMPLE_LIST.W_SERIAL        = @SERIAL
           AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO         = T_KOMOKU_SAMPLE.JURI_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO     = T_KOMOKU_SAMPLE.JURI_EDA_NO
           AND W_BUN_KOMOKU_SAMPLE_LIST.SEQ             = T_KOMOKU_SAMPLE.SEQ
           AND W_BUN_KOMOKU_SAMPLE_LIST.DBS_CREATE_DATE > T_KOMOKU_SAMPLE.DBS_UPDATE_DATE
           AND NOT( 
                   ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.K_BIKO,'')        = ISNULL(T_KOMOKU_SAMPLE.BIKO,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.SOKUTEI_DATE,'')  = ISNULL(T_KOMOKU_SAMPLE.SOKUTEI_DATE,'')
--               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.SOKUTEISHA_CD,'') = ISNULL(T_KOMOKU_SAMPLE.SOKUTEISHA_CD,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_01,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_01,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_02,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_02,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_03,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_03,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_04,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_04,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_05,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_05,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_06,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_06,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_07,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_07,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_08,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_08,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_09,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_09,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_10,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_10,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_11,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_11,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_12,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_12,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_13,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_13,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_14,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_14,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_15,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_15,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_16,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_16,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_17,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_17,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_18,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_18,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_19,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_19,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_20,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_20,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_21,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_21,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_22,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_22,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_23,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_23,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_24,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_24,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_25,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_25,'')
               AND ISNULL(W_BUN_KOMOKU_SAMPLE_LIST.COLUMN_26,'')     = ISNULL(T_KOMOKU_SAMPLE.COLUMN_26,'')
               )

        --保存対象ワークテーブル作成日時更新
        --保存後再読込を行うことで不要となるが、要検討
        UPDATE W_BUN_KOMOKU_SAMPLE_LIST
           SET W_BUN_KOMOKU_SAMPLE_LIST.DBS_CREATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
         WHERE NOT EXISTS
               ( SELECT 1
                   FROM T_KOMOKU_SAMPLE
                  WHERE T_KOMOKU_SAMPLE.JURI_NO     = W_BUN_KOMOKU_SAMPLE_LIST.JURI_NO
                    AND T_KOMOKU_SAMPLE.JURI_EDA_NO = W_BUN_KOMOKU_SAMPLE_LIST.JURI_EDA_NO
                    AND T_KOMOKU_SAMPLE.SEQ         = W_BUN_KOMOKU_SAMPLE_LIST.SEQ
               )
           AND W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID
           AND W_BUN_KOMOKU_SAMPLE_LIST.W_SERIAL  = @SERIAL

        --項目別サンプルリスト(ワークテーブル→テーブル)
        INSERT INTO
               T_KOMOKU_SAMPLE
        SELECT 
               W_TBL.JURI_NO
              ,W_TBL.JURI_EDA_NO
              ,W_TBL.SEQ
              ,W_TBL.BUNSEKI_CD
              ,W_TBL.STATE_KBN
              ,W_TBL.K_BIKO
              ,W_TBL.SOKUTEI_DATE
              ,W_TBL.SOKUTEISHA_CD
              ,W_TBL.COLUMN_01
              ,W_TBL.COLUMN_02
              ,W_TBL.COLUMN_03
              ,W_TBL.COLUMN_04
              ,W_TBL.COLUMN_05
              ,W_TBL.COLUMN_06
              ,W_TBL.COLUMN_07
              ,W_TBL.COLUMN_08
              ,W_TBL.COLUMN_09
              ,W_TBL.COLUMN_10
              ,W_TBL.COLUMN_11
              ,W_TBL.COLUMN_12
              ,W_TBL.COLUMN_13
              ,W_TBL.COLUMN_14
              ,W_TBL.COLUMN_15
              ,W_TBL.COLUMN_16
              ,W_TBL.COLUMN_17
              ,W_TBL.COLUMN_18
              ,W_TBL.COLUMN_19
              ,W_TBL.COLUMN_20
              ,W_TBL.COLUMN_21
              ,W_TBL.COLUMN_22
              ,W_TBL.COLUMN_23
              ,W_TBL.COLUMN_24
              ,W_TBL.COLUMN_25
              ,W_TBL.COLUMN_26
              ,'1'
              ,W_TBL.DBS_CREATE_USER
              ,W_TBL.DBS_UPDATE_DATE
              ,W_TBL.DBS_UPDATE_USER
              ,W_TBL.DBS_UPDATE_DATE
          FROM W_BUN_KOMOKU_SAMPLE_LIST AS W_TBL
         WHERE NOT EXISTS
               (
               SELECT 1 
                 FROM T_KOMOKU_SAMPLE AS TBL
                WHERE TBL.JURI_NO     = W_TBL.JURI_NO
                  AND TBL.JURI_EDA_NO = W_TBL.JURI_EDA_NO
                  AND TBL.SEQ         = W_TBL.SEQ
               )
           AND W_TBL.W_USER_ID = @USER_ID
           AND W_TBL.W_SERIAL  = @SERIAL

--          WHERE NOT EXISTS
--                (
--                SELECT 1 
--                  FROM T_KOMOKU_SAMPLE AS TBL
--                 WHERE TBL.JURI_NO     = W_TBL.JURI_NO
--                   AND TBL.JURI_EDA_NO = W_TBL.JURI_EDA_NO
--                   AND TBL.SEQ         = W_TBL.SEQ
--                   AND W_TBL.W_USER_ID = @USER_ID
--                   AND W_TBL.W_SERIAL  = @SERIAL
--                )


      END

    --削除処理
    ELSE IF @MODE = 2
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_BUN_KOMOKU_SAMPLE_LIST
         WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID

      END


    --正常終了
    INSERT INTO @TBL VALUES( 0 ,NULL )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_BUN_KOMOKU_SAMPLE_LIST
     WHERE W_BUN_KOMOKU_SAMPLE_LIST.W_USER_ID = @USER_ID

    --異常終了
    INSERT INTO @TBL VALUES( ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
