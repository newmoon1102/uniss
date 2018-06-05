
--DROP PROCEDURE SP_SAVE_T_CHUMON

CREATE PROCEDURE SP_SAVE_T_CHUMON
       @USER_ID     NVARCHAR(64)
      ,@SERIAL      NVARCHAR(50)
      ,@MODE        NVARCHAR(1)
      ,@SQL         NVARCHAR(max)
      ,@HATCHU_DATE NVARCHAR(10)
AS
--[モード] 0:読込 / 1:承認(保存) / ELSE:ワークテーブル削除
BEGIN

--変数定義
    DECLARE @strSQL NVARCHAR(max)

    --シーケンス
    DECLARE @SEQ AS INT

    --対象注文No.
    DECLARE @CHUMON_NO AS NVARCHAR(10)
    --対象依頼No.
    DECLARE @IRAI_NO AS NVARCHAR(10)
    --対象購買No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)
    --対象購買SEQ
    DECLARE @KOBAI_SEQ AS INT
    --対象仕入先CD
    DECLARE @SHIIRE_CD AS NVARCHAR(10)

    --承認日
    DECLARE @SHONIN_DATE AS NVARCHAR(10)

    --依頼テーブル保存用カーソル
    DECLARE IRAI_SAVE_CURSOR CURSOR
        FOR
     SELECT W_KOBAI_CHUMON_LIST.KOBAI_NO
           ,W_KOBAI_CHUMON_LIST.KOBAI_SEQ
       FROM W_KOBAI_CHUMON_LIST
      WHERE W_KOBAI_CHUMON_LIST.W_USER_ID          =  @USER_ID
        AND W_KOBAI_CHUMON_LIST.SELECT_FLG         =  'True'
        AND ISNULL(W_KOBAI_CHUMON_LIST.IRAI_NO,'') =  ''

    --注文テーブル保存用カーソル
    DECLARE CHUMON_SAVE_CURSOR CURSOR
        FOR
     SELECT W_KOBAI_CHUMON_LIST.SHIIRE_CD
       FROM W_KOBAI_CHUMON_LIST
      WHERE W_KOBAI_CHUMON_LIST.W_USER_ID            =  @USER_ID
        AND W_KOBAI_CHUMON_LIST.SELECT_FLG           =  'True'
        AND ISNULL(W_KOBAI_CHUMON_LIST.CHUMON_NO,'') =  ''
      GROUP BY
            W_KOBAI_CHUMON_LIST.SHIIRE_CD


--セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --読込処理
    IF @MODE = 0
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_KOBAI_CHUMON_LIST
         WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID

        --読込データをワークテーブルへ格納
        SET @strSQL = 'INSERT INTO '
                    + '  W_KOBAI_CHUMON_LIST '
                    + 'SELECT   '''+ @USER_ID +''''
                    + '        ,'''+ @SERIAL  +''''
                    + '        ,ROW_NUMBER() OVER (ORDER BY IRAI_NO) '
                    + '        ,'  + @MODE
                    + '        ,TBL1.*'
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

        --注文解除対象削除(注文テーブル)
        DELETE
          FROM T_CHUMON
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_CHUMON_LIST
                  WHERE W_KOBAI_CHUMON_LIST.W_USER_ID  = @USER_ID
                    AND W_KOBAI_CHUMON_LIST.SELECT_FLG = 'False'
                    AND W_KOBAI_CHUMON_LIST.IRAI_NO    = T_CHUMON.IRAI_NO )

        --ステータス変更履歴保存 201801追加
       INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
              ,TBL_A.KOBAI_STS
              ,2
              ,1
              ,TBL_A.DBS_CREATE_USER
              ,TBL_A.DBS_CREATE_DATE
              ,TBL_A.DBS_UPDATE_USER
              ,TBL_A.DBS_UPDATE_DATE
          FROM W_KOBAI_CHUMON_LIST AS TBL_A
                    LEFT JOIN T_KOBAI_B
                     ON TBL_A.KOBAI_NO   =  T_KOBAI_B.KOBAI_NO
                    AND TBL_A.KOBAI_SEQ  =  T_KOBAI_B.KOBAI_SEQ
                  WHERE TBL_A.W_USER_ID  =  @USER_ID
                    AND TBL_A.SELECT_FLG =  'False'
                    AND T_KOBAI_B.KOBAI_STS        NOT IN ( '1','2' )

       --注文解除ステータス更新
        UPDATE T_KOBAI_B
           SET T_KOBAI_B.KOBAI_STS = 2
         WHERE EXISTS
               ( SELECT 1 
                   FROM W_KOBAI_CHUMON_LIST
                  WHERE W_KOBAI_CHUMON_LIST.W_USER_ID  =  @USER_ID
                    AND W_KOBAI_CHUMON_LIST.SELECT_FLG =  'False'
                    AND W_KOBAI_CHUMON_LIST.KOBAI_NO   =  T_KOBAI_B.KOBAI_NO
                    AND W_KOBAI_CHUMON_LIST.KOBAI_SEQ  =  T_KOBAI_B.KOBAI_SEQ
                    AND T_KOBAI_B.KOBAI_STS        NOT IN ( '1','2' ) )

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
              FROM W_KOBAI_CHUMON_LIST
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND KOBAI_NO  = '' + @KOBAI_NO + ''
               AND KOBAI_SEQ = @KOBAI_SEQ

            FETCH NEXT FROM IRAI_SAVE_CURSOR INTO @KOBAI_NO, @KOBAI_SEQ
        END


        --注文対象追加(注文テーブル)
        --カーソルオープン
        OPEN CHUMON_SAVE_CURSOR

        FETCH NEXT FROM CHUMON_SAVE_CURSOR INTO @SHIIRE_CD
        WHILE @@FETCH_STATUS = 0
        BEGIN

            --シーケンス取得
            SET @SEQ = NEXT VALUE FOR SEQ_CHUMON_NO

            --依頼No.生成
            SET @CHUMON_NO = ( SELECT CONCAT( 'C', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                   ,'-' 
                                   ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                   ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )


            --注文テーブル追加処理
            INSERT INTO
                   T_CHUMON
            SELECT
                   @CHUMON_NO
                  ,ROW_NUMBER() OVER (ORDER BY W_ROW)
                  ,W_KOBAI_CHUMON_LIST.KOBAI_NO
                  ,W_KOBAI_CHUMON_LIST.KOBAI_SEQ
                  ,T_IRAI.IRAI_NO
                  ,@USER_ID
                  ,@HATCHU_DATE
                  ,'False'
                  ,1
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_USER
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_DATE
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_USER
                  ,W_KOBAI_CHUMON_LIST.DBS_UPDATE_DATE
              FROM W_KOBAI_CHUMON_LIST
              LEFT JOIN
                   T_IRAI
                ON T_IRAI.KOBAI_NO  = W_KOBAI_CHUMON_LIST.KOBAI_NO
               AND T_IRAI.KOBAI_SEQ = W_KOBAI_CHUMON_LIST.KOBAI_SEQ
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND SHIIRE_CD = '' + @SHIIRE_CD + ''
               AND SELECT_FLG           =  'True'
               AND ISNULL(CHUMON_NO,'') =  ''


            --注文済ステータス更新
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 3
              FROM T_KOBAI_B
             INNER JOIN
                   W_KOBAI_CHUMON_LIST
                ON W_KOBAI_CHUMON_LIST.KOBAI_NO   =  T_KOBAI_B.KOBAI_NO
               AND W_KOBAI_CHUMON_LIST.KOBAI_SEQ  =  T_KOBAI_B.KOBAI_SEQ
             WHERE W_KOBAI_CHUMON_LIST.W_USER_ID  =  @USER_ID
               AND W_KOBAI_CHUMON_LIST.W_SERIAL   =  @SERIAL
               AND W_KOBAI_CHUMON_LIST.SHIIRE_CD  =  '' + @SHIIRE_CD + ''
               AND W_KOBAI_CHUMON_LIST.SELECT_FLG =  'True'
               AND ISNULL(CHUMON_NO,'')           =  ''
               AND T_KOBAI_B.KOBAI_STS            IN ( '1','2' )


            --ステータス変更履歴保存(注文確定分)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,TBL_B.AFTER_STS
                  ,3
                  ,1
                  ,TBL_A.DBS_CREATE_USER
                  ,TBL_A.DBS_CREATE_DATE
                  ,TBL_A.DBS_UPDATE_USER
                  ,TBL_A.DBS_UPDATE_DATE
              FROM W_KOBAI_CHUMON_LIST AS TBL_A
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
               AND TBL_A.SHIIRE_CD  =  '' + @SHIIRE_CD + ''
               AND TBL_B.AFTER_STS  IN ( '1','2' )

            FETCH NEXT FROM CHUMON_SAVE_CURSOR INTO @SHIIRE_CD
        END




        CLOSE IRAI_SAVE_CURSOR
        CLOSE CHUMON_SAVE_CURSOR


        --発注日更新
        UPDATE T_CHUMON
           SET T_CHUMON.HATCHU_DATE = @HATCHU_DATE
          FROM T_CHUMON
         WHERE T_CHUMON.CHUMON_NO IN
               ( SELECT TBL_2.CHUMON_NO
                   FROM W_KOBAI_CHUMON_LIST AS TBL_1
                   LEFT JOIN
                        T_CHUMON AS TBL_2
                     ON TBL_2.KOBAI_NO   = TBL_1.KOBAI_NO
                    AND TBL_2.KOBAI_SEQ  = TBL_1.KOBAI_SEQ
                  WHERE TBL_1.W_USER_ID  = @USER_ID
                    AND TBL_1.W_SERIAL   = @SERIAL
                    AND TBL_1.SELECT_FLG = 'True'
               )

        --注文確定インフォメーション生成 201801追加

          BEGIN
           EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,6
          END


     END

    --ワークテーブル削除処理
    ELSE
     BEGIN
        --ワークテーブルクリア
        DELETE
          FROM W_KOBAI_CHUMON_LIST
         WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID
     END

    DEALLOCATE IRAI_SAVE_CURSOR
    DEALLOCATE CHUMON_SAVE_CURSOR


END TRY


--例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_KOBAI_CHUMON_LIST
     WHERE W_KOBAI_CHUMON_LIST.W_USER_ID = @USER_ID

    DEALLOCATE IRAI_SAVE_CURSOR
    DEALLOCATE CHUMON_SAVE_CURSOR

END CATCH

END

