
--DROP PROCEDURE SP_SAVE_T_IRAI

CREATE PROCEDURE SP_SAVE_T_IRAI
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     NVARCHAR(1)
      ,@SQL      NVARCHAR(max)
AS
--[モード] 0:読込 / 1:承認(保存) / ELSE:ワークテーブル削除
BEGIN

--変数定義
    DECLARE @strSQL NVARCHAR(max)

    --シーケンス
    DECLARE @SEQ AS INT

    --対象依頼No.
    DECLARE @IRAI_NO AS NVARCHAR(10)
    --対象購買No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)
    --対象購買SEQ
    DECLARE @KOBAI_SEQ AS INT

    --承認日
    DECLARE @SHONIN_DATE AS NVARCHAR(10)

    --保存用カーソル
    DECLARE IRAI_SAVE_CURSOR CURSOR
        FOR
     SELECT W_KOBAI_SHONIN_LIST.KOBAI_NO
           ,W_KOBAI_SHONIN_LIST.KOBAI_SEQ
       FROM W_KOBAI_SHONIN_LIST
      WHERE W_KOBAI_SHONIN_LIST.W_USER_ID          = @USER_ID
        AND W_KOBAI_SHONIN_LIST.SELECT_FLG         = 'True'
        AND ISNULL(W_KOBAI_SHONIN_LIST.IRAI_NO,'') = ''


--セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --読込処理
    IF @MODE = 0
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_KOBAI_SHONIN_LIST
         WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID

        --読込データをワークテーブルへ格納
        SET @strSQL = 'INSERT INTO '
                    + '  W_KOBAI_SHONIN_LIST '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY KOBAI_NO, KOBAI_SEQ) '
                    + '        ,'  + @MODE
                    + '        ,SHONIN_FLG '
                    + '        ,GYO_MOJI '
                    + '        ,WARNING '
                    + '        ,KOBAI_KBN_MEI'
                    + '        ,KOBAI_STS_MEI'
                    + '        ,SHINSEISHA_MEI'
                    + '        ,SHINSEI_DATETIME'
                    + '        ,KOBAIHIN_CD'
                    + '        ,KOBAIHIN_MEI'
                    + '        ,TANKA'
                    + '        ,IRISU'
                    + '        ,IRISU_TANI'
                    + '        ,SURYO'
                    + '        ,BARA_TANI'
                    + '        ,SOSU'
                    + '        ,TOTAL'
                    + '        ,NOKI'
                    + '        ,UKEIRE_DATE'
                    + '        ,KENSHU_DATE'
                    + '        ,HOKAN_BASHO_KBN_MEI'
                    + '        ,SHIIRE_CD'
                    + '        ,SHIIRE_MEI'
                    + '        ,MAKER_CD'
                    + '        ,MAKER_MEI'
                    + '        ,YOSAN_CD'
                    + '        ,JURI_NO'
                    + '        ,BIKO'
                    + '        ,KOBAI_NO'
                    + '        ,IRAI_NO'
                    + '        ,KOBAI_KBN'
                    + '        ,KOBAI_STS'
                    + '        ,SHINSEISHA_CD'
                    + '        ,FREEWD'
                    + '        ,KOBAI_SEQ'
                    + '        ,1 '
                    + '        ,'''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                    + '        , '''+ @USER_ID +''''
                    + '        ,''DT'' + ' + 'CONVERT(VARCHAR(24),GETDATE(),120) '
                     + '  FROM' + '(' + @SQL + ') TBL1'  
        EXEC(@strSQL)
      END

    --承認確定処理
    ELSE IF @MODE = 1
     BEGIN

        --承認日セット
        SET @SHONIN_DATE = CONVERT(VARCHAR(10), GETDATE(),111) 

        --承認解除対象削除(依頼テーブル)
        DELETE
          FROM T_IRAI
         WHERE EXISTS
               ( SELECT 1
                   FROM W_KOBAI_SHONIN_LIST
                  WHERE W_KOBAI_SHONIN_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_SHONIN_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_SHONIN_LIST.IRAI_NO    = T_IRAI.IRAI_NO )

        --承認解除対象削除(注文テーブル)
        DELETE
          FROM T_CHUMON
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_SHONIN_LIST
                  WHERE W_KOBAI_SHONIN_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_SHONIN_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_SHONIN_LIST.IRAI_NO    = T_CHUMON.IRAI_NO )

        --承認解除ステータス更新
        UPDATE T_KOBAI_B
           SET T_KOBAI_B.KOBAI_STS = 1
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_SHONIN_LIST
                  WHERE W_KOBAI_SHONIN_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_SHONIN_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_SHONIN_LIST.KOBAI_NO   = T_KOBAI_B.KOBAI_NO
                    AND W_KOBAI_SHONIN_LIST.KOBAI_SEQ  = T_KOBAI_B.KOBAI_SEQ )

        --ステータス変更履歴保存(承認解除分)
        INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
              ,TBL_B.AFTER_STS
              ,1
              ,1
              ,TBL_A.DBS_CREATE_USER
              ,TBL_A.DBS_CREATE_DATE
              ,TBL_A.DBS_UPDATE_USER
              ,TBL_A.DBS_UPDATE_DATE
          FROM W_KOBAI_SHONIN_LIST AS TBL_A
              ,(SELECT TBL_1.KOBAI_NO
                      ,TBL_1.KOBAI_SEQ
                      ,TBL_1.MOD_DATE_TIME
                      ,TBL_1.AFTER_STS
                  FROM T_KOBAI_STS_R AS TBL_1
                 WHERE TBL_1.MOD_DATE_TIME = ( SELECT MAX(TBL_2.MOD_DATE_TIME)
                                                 FROM T_KOBAI_STS_R AS TBL_2
                                                WHERE TBL_2.KOBAI_NO  = TBL_1.KOBAI_NO
                                                  AND TBL_2.KOBAI_SEQ = TBL_1.KOBAI_SEQ )
               ) AS TBL_B
         WHERE TBL_A.W_USER_ID  =  @USER_ID
           AND TBL_A.W_SERIAL   =  @SERIAL
           AND TBL_A.SELECT_FLG =  'False'
           AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
           AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
           AND TBL_B.AFTER_STS  <> 1

        --承認対象追加(依頼テーブル)
        --カーソルオープン
        OPEN IRAI_SAVE_CURSOR

        FETCH NEXT FROM IRAI_SAVE_CURSOR INTO @KOBAI_NO, @KOBAI_SEQ
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --シーケンス取得
            SET @SEQ = NEXT VALUE FOR SEQ_IRAI_NO

            --依頼No.生成
            SET @IRAI_NO = ( SELECT CONCAT( 'I', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                      ,'-' 
                                      ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                      ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

            --依頼テーブル追加処理
            INSERT INTO
                   T_IRAI
            SELECT @IRAI_NO
                  ,KOBAI_NO
                  ,KOBAI_SEQ
                  ,@USER_ID
                  ,@SHONIN_DATE
                  ,1
                  ,DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE
                  ,DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE
              FROM W_KOBAI_SHONIN_LIST
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND KOBAI_NO  = '' + @KOBAI_NO + ''
               AND KOBAI_SEQ = @KOBAI_SEQ

            --承認済ステータス更新
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 2
             WHERE T_KOBAI_B.KOBAI_NO  =  '' +  @KOBAI_NO + ''
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ
               AND T_KOBAI_B.KOBAI_STS < 2

            --ステータス変更履歴保存(承認分)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,TBL_B.AFTER_STS
                  ,2
                  ,1
                  ,TBL_A.DBS_CREATE_USER
                  ,TBL_A.DBS_CREATE_DATE
                  ,TBL_A.DBS_UPDATE_USER
                  ,TBL_A.DBS_UPDATE_DATE
              FROM W_KOBAI_SHONIN_LIST AS TBL_A
                  ,(SELECT TBL_1.KOBAI_NO
                          ,TBL_1.KOBAI_SEQ
                          ,TBL_1.MOD_DATE_TIME
                          ,TBL_1.AFTER_STS
                      FROM T_KOBAI_STS_R AS TBL_1
                     WHERE TBL_1.MOD_DATE_TIME = ( SELECT MAX(TBL_2.MOD_DATE_TIME)
                                                     FROM T_KOBAI_STS_R AS TBL_2
                                                    WHERE TBL_2.KOBAI_NO  = TBL_1.KOBAI_NO
                                                      AND TBL_2.KOBAI_SEQ = TBL_1.KOBAI_SEQ )
                   ) AS TBL_B
             WHERE TBL_A.W_USER_ID  =  @USER_ID
               AND TBL_A.W_SERIAL   =  @SERIAL
               AND TBL_A.SELECT_FLG =  'True'
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =   '' +  @KOBAI_NO + ''
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_B.AFTER_STS  <  2

            FETCH NEXT FROM IRAI_SAVE_CURSOR INTO @KOBAI_NO, @KOBAI_SEQ
        END

        CLOSE IRAI_SAVE_CURSOR

        --ワークテーブルクリア
        DELETE
          FROM W_KOBAI_SHONIN_LIST
         WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID

     END

    --ワークテーブル削除処理
    ELSE
     BEGIN
        --ワークテーブルクリア
        DELETE
          FROM W_KOBAI_SHONIN_LIST
         WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID
     END

    DEALLOCATE IRAI_SAVE_CURSOR

END TRY


 --例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_KOBAI_SHONIN_LIST
     WHERE W_KOBAI_SHONIN_LIST.W_USER_ID = @USER_ID

    DEALLOCATE IRAI_SAVE_CURSOR

END CATCH

END

