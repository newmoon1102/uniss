
--DROP PROCEDURE SP_SAVE_T_SHUKKO

CREATE PROCEDURE SP_SAVE_T_SHUKKO
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
      RESULT_SHUKKO_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --シーケンス
    DECLARE @SEQ AS INT
    --対象出庫No.
    DECLARE @SHUKKO_NO AS NVARCHAR(10)
    --対象在庫No.
    DECLARE @ZAIKO_NO AS NVARCHAR(10)
    --更新日時
    DECLARE @UPDATE_DATE AS NVARCHAR(50)

    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --新規登録処理
    IF @MODE = 1
      BEGIN

        --シーケンス取得
        SET @SEQ = NEXT VALUE FOR SEQ_NYUSHUKKO_NO
        --入庫No.生成
        SET @SHUKKO_NO  = ( SELECT CONCAT( 'N', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00' + CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --新規保存(ワークテーブル→テーブル)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT @SHUKKO_NO                          --NYUSHUKKO_NO
                       ,ZAIKO_NO                            --ZAIKO_NO
                       ,2                                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD                      --NYURYOKUSHA_CD
                       ,IRAI_NO                             --IRAI_NO
                       ,JURI_NO                             --JURI_NO
                       ,HOKAN_BASHO_KBN                     --HOKAN_BASHO_KBN
                       ,NULL                                --UKEIRE_DATE
                       ,NULL                                --KENSHU_DATE
                       ,NULL                                --NYUKO_SURYO
                       ,SHUKKO_DATE                         --SHUKKO_DATE
                       ,SHUKKO_SURYO                        --SHUKKO_SURYO
                       ,SHUKKO_JIYU                         --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_SHUKKO_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

            --在庫引き当て
            UPDATE T_ZAIKO
               SET ZAIKO_SURYO      = ZAIKO_SURYO - @SURYO
                  ,LAST_SHUKKO_DATE = W_SHUKKO_INPUT.SHUKKO_DATE
                  ,DBS_UPDATE_USER  = W_SHUKKO_INPUT.DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE  = W_SHUKKO_INPUT.DBS_UPDATE_DATE
              FROM T_ZAIKO
             INNER JOIN
                   W_SHUKKO_INPUT
                ON W_SHUKKO_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND W_ROW     = 1

      END

    --更新処理
    ELSE IF @MODE = 2
      BEGIN

        --出庫No.セット
        SET @SHUKKO_NO = @REF_NO

        --前回出庫数差分取得
        SET @SURYO = @SURYO - ( SELECT SHUKKO_SURYO
                                  FROM T_NYUSHUKKO
                                 WHERE NYUSHUKKO_NO = @SHUKKO_NO )

        --入出庫テーブル削除
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @SHUKKO_NO

        --更新(ワークテーブル→ヘッダテーブル)
        INSERT INTO
               T_NYUSHUKKO
                 SELECT @SHUKKO_NO                          --NYUSHUKKO_NO
                       ,ZAIKO_NO                            --ZAIKO_NO
                       ,2                                   --NYUSHUKKO_KBN
                       ,NYURYOKUSHA_CD                      --NYURYOKUSHA_CD
                       ,IRAI_NO                             --IRAI_NO
                       ,JURI_NO                             --JURI_NO
                       ,HOKAN_BASHO_KBN                     --HOKAN_BASHO_KBN
                       ,NULL                                --UKEIRE_DATE
                       ,NULL                                --KENSHU_DATE
                       ,NULL                                --NYUKO_SURYO
                       ,SHUKKO_DATE                         --SHUKKO_DATE
                       ,SHUKKO_SURYO                        --SHUKKO_SURYO
                       ,SHUKKO_JIYU                         --SHUKKO_JIYU
                       ,1
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_SHUKKO_INPUT
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

            --在庫数修正
            UPDATE T_ZAIKO
               SET ZAIKO_SURYO      = ZAIKO_SURYO - @SURYO
                  ,LAST_SHUKKO_DATE = W_SHUKKO_INPUT.SHUKKO_DATE
                  ,DBS_UPDATE_USER  = W_SHUKKO_INPUT.DBS_UPDATE_USER
                  ,DBS_UPDATE_DATE  = W_SHUKKO_INPUT.DBS_UPDATE_DATE
              FROM T_ZAIKO
             INNER JOIN
                   W_SHUKKO_INPUT
                ON W_SHUKKO_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND W_ROW     = 1

      END

    --削除処理
    ELSE IF @MODE = 3
      BEGIN

        --出庫No.セット
        SET @SHUKKO_NO = @REF_NO

        --前回出庫数差分取得
        SET @SURYO = ( SELECT SHUKKO_SURYO
                         FROM T_NYUSHUKKO
                        WHERE NYUSHUKKO_NO = @SHUKKO_NO )

        --在庫数修正
        UPDATE T_ZAIKO
           SET ZAIKO_SURYO      = ZAIKO_SURYO + @SURYO
              ,DBS_UPDATE_USER  = @USER_ID
              ,DBS_UPDATE_DATE  = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)
          FROM T_ZAIKO
         INNER JOIN
               T_NYUSHUKKO
            ON T_NYUSHUKKO.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @SHUKKO_NO

        --入出庫テーブル削除
        DELETE
          FROM T_NYUSHUKKO
         WHERE T_NYUSHUKKO.NYUSHUKKO_NO = @SHUKKO_NO

      END

    --その他処理
    ELSE
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_SHUKKO_INPUT
         WHERE W_SHUKKO_INPUT.W_USER_ID = @USER_ID

      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_SHUKKO_INPUT
     WHERE W_SHUKKO_INPUT.W_USER_ID = @USER_ID

    --正常終了
    INSERT INTO @TBL VALUES( @SHUKKO_NO, 0, NULL )

    --処理結果返却
    SELECT RESULT_SHUKKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    --トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_SHUKKO_INPUT
     WHERE W_SHUKKO_INPUT.W_USER_ID = @USER_ID

    --異常終了
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_SHUKKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END


