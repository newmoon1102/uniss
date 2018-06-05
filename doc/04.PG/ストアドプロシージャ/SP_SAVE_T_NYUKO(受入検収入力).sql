--DROP PROCEDURE SP_SAVE_T_NYUKO

CREATE PROCEDURE SP_SAVE_T_NYUKO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
      ,@REF_NO   NVARCHAR(10)
      ,@SURYO    INT
AS
--保存処理実行
BEGIN
    --戻り値用テーブル変数
    DECLARE @TBL TABLE (
      RESULT_NYUKO_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --シーケンス
    DECLARE @NYUKO_SEQ AS INT
    DECLARE @ZAIKO_SEQ AS INT
    --対象入庫No.
    DECLARE @NYUKO_NO AS NVARCHAR(10)
    --対象在庫No.
    DECLARE @ZAIKO_NO AS NVARCHAR(10)
    --対象購買No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)
    --対象購買SEQ
    DECLARE @KOBAI_SEQ AS INT
    --対象依頼No.
    DECLARE @IRAI_NO AS NVARCHAR(10)
    --対象購買ステータス
    DECLARE @KOBAI_STS AS NVARCHAR(9)
    --入庫数合計
    DECLARE @NYUKO_TOTAL AS NUMERIC(7,2)
    --注文数
    DECLARE @CHUMON_SURYO AS NUMERIC(7,2)
    --購買区分CD
    DECLARE @KOBAI_KBN AS NVARCHAR(9)

    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --新規登録処理
    IF @MODE = 1
      BEGIN

        --シーケンス取得
        SET @NYUKO_SEQ = NEXT VALUE FOR SEQ_NYUSHUKKO_NO
        --入庫No.生成
        SET @NYUKO_NO = ( SELECT CONCAT( 'N', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                ,'-' 
                                ,RIGHT('00' + CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                ,RIGHT('0000' + CAST(@NYUKO_SEQ AS NVARCHAR) ,4) ) )

        --シーケンス取得
        SET @ZAIKO_SEQ = NEXT VALUE FOR SEQ_ZAIKO_NO
        --在庫No.生成
        SET @ZAIKO_NO = ( SELECT CONCAT( 'Z', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                ,'-' 
                                ,RIGHT('00' + CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                ,RIGHT('0000' + CAST(@ZAIKO_SEQ AS NVARCHAR) ,4) ) )

        --購買申請No.＆SEQ取得
        SELECT @KOBAI_NO  = V_KOBAI_LIST.KOBAI_NO
              ,@KOBAI_SEQ = V_KOBAI_LIST.KOBAI_SEQ
              ,@KOBAI_KBN = V_KOBAI_LIST.KOBAI_KBN
          FROM W_UKEIRE_KENSHU_INPUT
          LEFT JOIN
               V_KOBAI_LIST
            ON V_KOBAI_LIST.IRAI_NO = W_UKEIRE_KENSHU_INPUT.IRAI_NO
         WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID
           AND W_UKEIRE_KENSHU_INPUT.W_SERIAL  = @SERIAL
           AND W_UKEIRE_KENSHU_INPUT.W_ROW     = 1


        --新規保存(ワークテーブル→ヘッダテーブル)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT @NYUKO_NO           --NYUSHUKKO_NO
                       ,@ZAIKO_NO           --ZAIKO_NO
                       ,1                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD      --NYURYOKUSHA_CD
                       ,IRAI_NO             --IRAI_NO
                       ,JURI_NO             --JURI_NO
                       ,HOKAN_BASHO_KBN     --HOKAN_BASHO_KBN
                       ,UKEIRE_DATE         --UKEIRE_DATE
                       ,KENSHU_DATE         --KENSHU_DATE
                       ,NYUKO_SURYO         --NYUKO_SURYO
                       ,NULL                --SHUKKO_DATE
                       ,NULL                --SHUKKO_SURYO
                       ,NULL                --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_UKEIRE_KENSHU_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1


        --検収日更新
        UPDATE T_NYUSHUKKO
           SET T_NYUSHUKKO.KENSHU_DATE = TBL_A.KENSHU_DATE
          FROM T_NYUSHUKKO
         INNER JOIN
               T_NYUSHUKKO AS TBL_A
            ON TBL_A.NYUSHUKKO_NO = @NYUKO_NO
           AND TBL_A.IRAI_NO      = T_NYUSHUKKO.IRAI_NO


        --新規保存(ワークテーブル→ボディテーブル)
        INSERT INTO
               T_ZAIKO
                 SELECT @ZAIKO_NO                           --ZAIKO_NO
                       ,KOBAIHIN_CD                         --KOBAIHIN_CD
                       ,HOKAN_BASHO_KBN                     --HOKAN_BASHO_KBN
                       ,SHIIRE_CD                           --SHIIRE_CD
                       ,MAKER_CD                            --MAKER_CD
                       ,TANKA                               --TANKA
                       ,IRISU                               --IRISU
                       ,IRISU_TANI                          --IRISU_TANI
                       ,NYUKO_SURYO                         --ZAIKO_SURYO
                       ,BARA_TANI                           --BARA_TANI
                       ,CONVERT(VARCHAR(10), GETDATE(),111) --LAST_NYUKO_DATE
                       ,NULL                                --LAST_SHUKKO_DATE
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_UKEIRE_KENSHU_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --入荷インフォメーション生成処理
        --販売商品の場合はインフォメーション生成対象外
        IF @KOBAI_KBN <> '5'
          BEGIN
            EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,4
          END

      END

    --更新処理
    ELSE IF @MODE = 2
      BEGIN

        --入庫No.セット
        SET @NYUKO_NO = @REF_NO

        --前回出庫数差分取得
        SET @SURYO = @SURYO - ( SELECT NYUKO_SURYO
                                  FROM T_NYUSHUKKO
                                 WHERE NYUSHUKKO_NO = @NYUKO_NO )

        --入出庫テーブル削除
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @NYUKO_NO

        --更新(ワークテーブル→ヘッダテーブル)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT NYUSHUKKO_NO        --NYUSHUKKO_NO
                       ,ZAIKO_NO            --ZAIKO_NO
                       ,1                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD      --NYURYOKUSHA_CD
                       ,IRAI_NO             --IRAI_NO
                       ,JURI_NO             --JURI_NO
                       ,HOKAN_BASHO_KBN     --HOKAN_BASHO_KBN
                       ,UKEIRE_DATE         --UKEIRE_DATE
                       ,KENSHU_DATE         --KENSHU_DATE
                       ,NYUKO_SURYO         --NYUKO_SURYO
                       ,NULL                --SHUKKO_DATE
                       ,NULL                --SHUKKO_SURYO
                       ,NULL                --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_UKEIRE_KENSHU_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --検収日更新
        UPDATE T_NYUSHUKKO
           SET T_NYUSHUKKO.KENSHU_DATE = TBL_A.KENSHU_DATE
          FROM T_NYUSHUKKO
         INNER JOIN
               T_NYUSHUKKO AS TBL_A
            ON TBL_A.NYUSHUKKO_NO = @NYUKO_NO
           AND TBL_A.IRAI_NO      = T_NYUSHUKKO.IRAI_NO

        --在庫数修正
        UPDATE T_ZAIKO
           SET ZAIKO_SURYO     = ZAIKO_SURYO + @SURYO
              ,LAST_NYUKO_DATE = W_UKEIRE_KENSHU_INPUT.UKEIRE_DATE
              ,DBS_UPDATE_USER = W_UKEIRE_KENSHU_INPUT.DBS_UPDATE_USER
              ,DBS_UPDATE_DATE = W_UKEIRE_KENSHU_INPUT.DBS_UPDATE_DATE
          FROM T_ZAIKO
         INNER JOIN
               W_UKEIRE_KENSHU_INPUT
            ON W_UKEIRE_KENSHU_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
         WHERE W_USER_ID = @USER_ID
           AND W_SERIAL  = @SERIAL
           AND W_ROW     = 1

      END


    --削除処理
    ELSE IF @MODE = 3
      BEGIN

        --入庫No.セット
        SET @NYUKO_NO = @REF_NO

        --前回入庫数差分取得
        SELECT @KOBAI_NO  = T_IRAI.KOBAI_NO
              ,@KOBAI_SEQ = T_IRAI.KOBAI_SEQ
              ,@IRAI_NO   = T_IRAI.IRAI_NO
              ,@SURYO     = T_NYUSHUKKO.NYUKO_SURYO
          FROM T_NYUSHUKKO
          LEFT JOIN
               T_IRAI
            ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
         WHERE NYUSHUKKO_NO = @NYUKO_NO

        --在庫数修正
        UPDATE T_ZAIKO
           SET ZAIKO_SURYO     = ZAIKO_SURYO - @SURYO
              ,DBS_UPDATE_USER = @USER_ID
              ,DBS_UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
          FROM T_ZAIKO
         INNER JOIN
               T_NYUSHUKKO
            ON T_NYUSHUKKO.ZAIKO_NO     = T_ZAIKO.ZAIKO_NO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @NYUKO_NO

        --入出庫テーブル削除
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @NYUKO_NO

        --入庫合計・注文数取得
        SET @NYUKO_TOTAL  = ( SELECT SUM(NYUKO_SURYO)
                                FROM T_NYUSHUKKO
                               WHERE T_NYUSHUKKO.IRAI_NO = @IRAI_NO )
        SET @CHUMON_SURYO = ( SELECT SURYO
                                FROM V_KOBAI_LIST
                               WHERE IRAI_NO = @IRAI_NO )

        --入庫数が0以下の場合、注文書発行済み
        IF ISNULL(@NYUKO_TOTAL,0) <= 0
          BEGIN
            SET @KOBAI_STS = 3
          END
        --入庫数が1以上で注文数以下の場合、一部入荷済み
        ELSE IF ISNULL(@NYUKO_TOTAL,0) < ISNULL(@CHUMON_SURYO,0)
          BEGIN
            SET @KOBAI_STS = 4
          END
        --上記以外の場合、変更しない
        ELSE
          BEGIN
            SET @KOBAI_STS = ( SELECT KOBAI_STS
                                 FROM V_KOBAI_LIST
                                WHERE IRAI_NO = @IRAI_NO )
          END

        --ステータス反映
        UPDATE T_KOBAI_B
           SET KOBAI_STS = @KOBAI_STS
--            SET KOBAI_STS = CASE ( SELECT COUNT(*)
--                                     FROM T_NYUSHUKKO
--                                    WHERE T_NYUSHUKKO.IRAI_NO = T_IRAI.IRAI_NO )
--                            WHEN 0 THEN 3
--                            ELSE KOBAI_STS
--                            END
          FROM T_KOBAI_B
         INNER JOIN
               T_IRAI
            ON T_IRAI.KOBAI_NO  = T_KOBAI_B.KOBAI_NO
           AND T_IRAI.KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
         WHERE T_IRAI.IRAI_NO   = @IRAI_NO

        --ステータス変更履歴保存(注文書発行済ステータスに戻す)
        INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.4'
              ,TBL_B.AFTER_STS
              ,TBL_A.KOBAI_STS
              ,1
              ,@USER_ID
              ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              ,@USER_ID
              ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
          FROM V_KOBAI_LIST AS TBL_A
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
         WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
           AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
           AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
           AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
           AND TBL_B.AFTER_STS  <> TBL_A.KOBAI_STS

      END

    --その他処理
    ELSE
      BEGIN

        DELETE
          FROM W_UKEIRE_KENSHU_INPUT
         WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID

      END

    --ステータス更新処理
    IF @MODE IN ( 1,2 )
      BEGIN

        SET @KOBAI_NO  = NULL
        SET @KOBAI_SEQ = NULL

        --購買申請データステータス更新
        --受入済(受入日入力済＆注文数>入荷数量)
        SELECT @KOBAI_NO  = T_KOBAI_B.KOBAI_NO
              ,@KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
          FROM T_KOBAI_B
         WHERE EXISTS
               ( SELECT 1 
                   FROM T_NYUSHUKKO
                   LEFT JOIN
                        T_IRAI
                     ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                  WHERE T_NYUSHUKKO.NYUSHUKKO_NO           =  @NYUKO_NO
                    AND T_NYUSHUKKO.NYUSHUKKO_KBN          =  1
                    AND ISNULL(T_NYUSHUKKO.UKEIRE_DATE,'') <> ''
--                    AND ISNULL(T_NYUSHUKKO.KENSHU_DATE,'') =  ''
                    AND T_KOBAI_B.SURYO                    >  ( SELECT SUM(NYUKO_SURYO)
                                                                  FROM T_NYUSHUKKO AS TBL_W
                                                                 WHERE TBL_W.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                                                                 GROUP BY
                                                                       IRAI_NO )
                    AND T_IRAI.KOBAI_NO                    =  T_KOBAI_B.KOBAI_NO
                    AND T_IRAI.KOBAI_SEQ                   =  T_KOBAI_B.KOBAI_SEQ )

        IF @KOBAI_NO IS NOT NULL
          BEGIN

            --受入済ステータスセット
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 4
             WHERE T_KOBAI_B.KOBAI_NO  = @KOBAI_NO
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ

            --ステータス変更履歴保存(受入済ステータス)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.1'
                  ,TBL_B.AFTER_STS
                  ,TBL_A.KOBAI_STS
                  ,1
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              FROM V_KOBAI_LIST AS TBL_A
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
             WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_B.AFTER_STS  IN ( '1','2','3' )

          END

        SET @KOBAI_NO  = NULL
        SET @KOBAI_SEQ = NULL

        --入荷完了(受入日入力済＆検収日未入力＆注文数<=入荷数量)
        SELECT @KOBAI_NO  = T_KOBAI_B.KOBAI_NO
              ,@KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
          FROM T_KOBAI_B
         WHERE EXISTS
               ( SELECT 1 
                   FROM T_NYUSHUKKO
                   LEFT JOIN
                        T_IRAI
                     ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                  WHERE T_NYUSHUKKO.NYUSHUKKO_NO           =  @NYUKO_NO
                    AND T_NYUSHUKKO.NYUSHUKKO_KBN          =  1
                    AND ISNULL(T_NYUSHUKKO.UKEIRE_DATE,'') <> ''
                    AND ISNULL(T_NYUSHUKKO.KENSHU_DATE,'') =  ''
                    AND T_KOBAI_B.SURYO                    <= ( SELECT SUM(NYUKO_SURYO)
                                                                  FROM T_NYUSHUKKO AS TBL_W
                                                                 WHERE TBL_W.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                                                                 GROUP BY
                                                                       IRAI_NO )
                    AND T_IRAI.KOBAI_NO                    =  T_KOBAI_B.KOBAI_NO
                    AND T_IRAI.KOBAI_SEQ                   =  T_KOBAI_B.KOBAI_SEQ )

        IF @KOBAI_NO IS NOT NULL
          BEGIN

            --入荷完了ステータスセット
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 5
             WHERE T_KOBAI_B.KOBAI_NO  = @KOBAI_NO
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ

            --ステータス変更履歴保存(入荷完了ステータス)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.2'
                  ,TBL_B.AFTER_STS
                  ,TBL_A.KOBAI_STS
                  ,1
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              FROM V_KOBAI_LIST AS TBL_A
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
             WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_B.AFTER_STS  IN ( '1','2','3','4' )

          END

        SET @KOBAI_NO  = NULL
        SET @KOBAI_SEQ = NULL

        --検収済(受入日入力済＆検収日入力済＆注文数<=入荷数量)
        SELECT @KOBAI_NO  = T_KOBAI_B.KOBAI_NO
              ,@KOBAI_SEQ = T_KOBAI_B.KOBAI_SEQ
          FROM T_KOBAI_B
         WHERE EXISTS
               ( SELECT 1 
                   FROM T_NYUSHUKKO
                   LEFT JOIN
                        T_IRAI
                     ON T_IRAI.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                  WHERE T_NYUSHUKKO.NYUSHUKKO_NO           =  @NYUKO_NO
                    AND T_NYUSHUKKO.NYUSHUKKO_KBN          =  1
                    AND ISNULL(T_NYUSHUKKO.UKEIRE_DATE,'') <> ''
                    AND ISNULL(T_NYUSHUKKO.KENSHU_DATE,'') <> ''
                    AND T_KOBAI_B.SURYO                    <= ( SELECT SUM(NYUKO_SURYO)
                                                                  FROM T_NYUSHUKKO AS TBL_W
                                                                 WHERE TBL_W.IRAI_NO = T_NYUSHUKKO.IRAI_NO
                                                                 GROUP BY
                                                                       IRAI_NO )
                    AND T_IRAI.KOBAI_NO                    =  T_KOBAI_B.KOBAI_NO
                    AND T_IRAI.KOBAI_SEQ                   =  T_KOBAI_B.KOBAI_SEQ )

        IF @KOBAI_NO IS NOT NULL
          BEGIN

            --検収済ステータスセット
            UPDATE T_KOBAI_B
               SET T_KOBAI_B.KOBAI_STS = 6
             WHERE T_KOBAI_B.KOBAI_NO  = @KOBAI_NO
               AND T_KOBAI_B.KOBAI_SEQ = @KOBAI_SEQ

            --ステータス変更履歴保存(検収済ステータス)
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   TBL_A.KOBAI_NO
                  ,TBL_A.KOBAI_SEQ
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114) + '.3'
                  ,TBL_B.AFTER_STS
                  ,TBL_A.KOBAI_STS
                  ,1
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
                  ,@USER_ID
                  ,'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
              FROM V_KOBAI_LIST AS TBL_A
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
             WHERE TBL_A.KOBAI_NO   =  @KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  @KOBAI_SEQ
               AND TBL_A.KOBAI_NO   =  TBL_B.KOBAI_NO
               AND TBL_A.KOBAI_SEQ  =  TBL_B.KOBAI_SEQ
               AND TBL_B.AFTER_STS  IN ( '1','2','3','4','5' )

            --投資検収インフォメーション生成処理
            --購買区分が投資の場合、通知を生成する
            IF ( SELECT V_KOBAI_LIST.KOBAI_KBN
                   FROM W_UKEIRE_KENSHU_INPUT
                   LEFT JOIN
                        V_KOBAI_LIST
                     ON V_KOBAI_LIST.IRAI_NO = W_UKEIRE_KENSHU_INPUT.IRAI_NO
                  WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID
                    AND W_UKEIRE_KENSHU_INPUT.W_SERIAL  = @SERIAL
                    AND W_UKEIRE_KENSHU_INPUT.W_ROW     = 1 ) = 4
            BEGIN
                EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,3
            END

          END
      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_UKEIRE_KENSHU_INPUT
     WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID

    --正常終了
    INSERT INTO @TBL VALUES( @NYUKO_NO, 0, NULL )

    --処理結果返却
    SELECT RESULT_NYUKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    --トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_UKEIRE_KENSHU_INPUT
     WHERE W_UKEIRE_KENSHU_INPUT.W_USER_ID = @USER_ID

    --異常終了
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_NYUKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END


