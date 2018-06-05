
--DROP PROCEDURE SP_SAVE_T_KOBAI

CREATE PROCEDURE SP_SAVE_T_KOBAI
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
      ,@REF_NO   NVARCHAR(10)
AS
--保存処理実行
--[モード] 1:新規保存 / 2:更新 / 3:削除 / ELSE:ワークテーブルクリア
BEGIN
    --戻り値用テーブル変数
    DECLARE @TBL TABLE (
      RESULT_KOBAI_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --シーケンス
    DECLARE @SEQ AS INT

    --対象購買申請No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)
    
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

    --新規登録処理
    IF @MODE = 1
      BEGIN

        --シーケンス取得
        SET @SEQ = NEXT VALUE FOR SEQ_KOBAI_NO

        --購買申請No.生成
        SET @KOBAI_NO = ( SELECT CONCAT( 'K', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                ,'-' 
                                ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --詳細テーブル用SEQ生成処理
        UPDATE W_KOBAI
           SET KOBAI_SEQ = KOBAI_GYO_NO
           ,KOBAI_NO = @KOBAI_NO             --201801追加
          FROM W_KOBAI
         WHERE W_USER_ID = @USER_ID
--           AND W_SERIAL  = @SERIAL

        --新規保存(ワークテーブル→ヘッダテーブル)
        INSERT INTO
               T_KOBAI_H
                 SELECT
                        @KOBAI_NO
                       ,SHINSEISHA_CD
                       ,SHINSEI_DATETIME
                       ,SHINSEI_GAIYO
                       ,KOBAI_KBN
                       ,TAX_RATE
                       ,NUKI_TOTAL
                       ,TAX
                       ,KOMI_TOTAL
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_KOBAI
                  WHERE W_USER_ID = @USER_ID
--                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1


        --新規保存(ワークテーブル→ボディテーブル)
        INSERT INTO
               T_KOBAI_B
                 SELECT
                        @KOBAI_NO
                       ,KOBAI_GYO_NO
                       ,KOBAI_GYO_NO
                       ,KOBAI_STS
                       ,JOGAI_FLG
                       ,KOBAIHIN_CD
                       ,KOBAIHIN_MEI
                       ,TANKA
                       ,IRISU
                       ,IRISU_TANI
                       ,SURYO
                       ,BARA_TANI
                       ,SOSU
                       ,TOTAL
                       ,NOKI
                       ,HOKAN_BASHO_KBN
                       ,SHIIRE_CD
                       ,MAKER_CD
                       ,YOSAN_CD
                       ,JURI_NO
                       ,BIKO
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_KOBAI
                  WHERE W_USER_ID = @USER_ID
--                    AND W_SERIAL  = @SERIAL


        --ステータス変更履歴保存(新規作成)
        --変更日時はストアド上のシステム日時
        INSERT INTO
               T_KOBAI_STS_R
        SELECT
               @KOBAI_NO
              ,W_KOBAI.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
              ,NULL
              ,W_KOBAI.KOBAI_STS
              ,1
              ,W_KOBAI.DBS_CREATE_USER
              ,W_KOBAI.DBS_CREATE_DATE
              ,W_KOBAI.DBS_UPDATE_USER
              ,W_KOBAI.DBS_UPDATE_DATE
          FROM W_KOBAI
         WHERE W_KOBAI.W_USER_ID = @USER_ID
--           AND W_KOBAI.W_SERIAL  = @SERIAL

      END

    --更新処理
    ELSE IF @MODE = 2
      BEGIN

        SET @KOBAI_NO = @REF_NO

        --作成日時継承
        UPDATE W_KOBAI
           SET W_KOBAI.DBS_CREATE_DATE = T_KOBAI_B.DBS_CREATE_DATE
          FROM W_KOBAI
          LEFT JOIN
               T_KOBAI_B
            ON T_KOBAI_B.KOBAI_NO  = W_KOBAI.KOBAI_NO
           AND T_KOBAI_B.KOBAI_SEQ = W_KOBAI.KOBAI_SEQ
         WHERE W_KOBAI.W_USER_ID   = @USER_ID
--           AND W_KOBAI.W_SERIAL    = @SERIAL
           AND W_KOBAI.KOBAI_SEQ IS NOT NULL

        --ヘッダテーブル削除
        DELETE
          FROM T_KOBAI_H
         WHERE T_KOBAI_H.KOBAI_NO = @KOBAI_NO

        --ボディテーブル削除
        DELETE
          FROM T_KOBAI_B
         WHERE T_KOBAI_B.KOBAI_NO = @KOBAI_NO

        --内容修正テーブルのSEQクリア
        UPDATE W_KOBAI
           SET W_KOBAI.KOBAI_SEQ = NULL
          FROM W_KOBAI
          LEFT JOIN
               T_KOBAI_B
            ON T_KOBAI_B.KOBAI_NO  = W_KOBAI.KOBAI_NO
           AND T_KOBAI_B.KOBAI_SEQ = W_KOBAI.KOBAI_SEQ
         WHERE W_KOBAI.W_USER_ID   = @USER_ID
--           AND W_KOBAI.W_SERIAL    = @SERIAL
           AND (
                     W_KOBAI.KOBAIHIN_CD <> T_KOBAI_B.KOBAIHIN_CD
                  OR W_KOBAI.TANKA       <> T_KOBAI_B.TANKA
                  OR W_KOBAI.SURYO       <> T_KOBAI_B.SURYO
                  OR W_KOBAI.SHIIRE_CD   <> T_KOBAI_B.SHIIRE_CD
                  OR W_KOBAI.MAKER_CD    <> T_KOBAI_B.MAKER_CD
               )
           AND W_KOBAI.KOBAI_SEQ IS NOT NULL

        --内容修正対象を依頼・注文テーブルから削除
        DELETE
          FROM T_IRAI
         WHERE NOT EXISTS (
                SELECT *
                  FROM W_KOBAI AS W_TBL
                 WHERE W_TBL.W_USER_ID = @USER_ID
--                   AND W_TBL.W_SERIAL  = @SERIAL
                   AND W_TBL.KOBAI_NO  = T_IRAI.KOBAI_NO
                   AND W_TBL.KOBAI_SEQ = T_IRAI.KOBAI_SEQ
        )
           AND T_IRAI.KOBAI_NO = @KOBAI_NO

        DELETE
          FROM T_CHUMON
         WHERE NOT EXISTS (
                SELECT *
                  FROM W_KOBAI AS W_TBL
                 WHERE W_TBL.W_USER_ID = @USER_ID
--                   AND W_TBL.W_SERIAL  = @SERIAL
                   AND W_TBL.KOBAI_NO  = T_CHUMON.KOBAI_NO
                   AND W_TBL.KOBAI_SEQ = T_CHUMON.KOBAI_SEQ
        )
           AND T_CHUMON.KOBAI_NO = @KOBAI_NO


        --詳細テーブル用SEQ生成処理
        UPDATE W_KOBAI
           SET W_KOBAI.KOBAI_SEQ = WORK_TBL.SEQ
              ,W_KOBAI.KOBAI_STS = '1'
          FROM W_KOBAI
         INNER JOIN
               ( SELECT
                        ( SELECT CASE WHEN MAX(T_TBL.KOBAI_SEQ) IS NULL
                                 THEN 0
                                 ELSE MAX(T_TBL.KOBAI_SEQ)
                                 END
                            FROM W_KOBAI AS T_TBL
                           WHERE T_TBL.KOBAI_NO     = UPDATE_TBL.KOBAI_NO
                        ) + ROW_NUMBER() OVER ( ORDER BY UPDATE_TBL.KOBAI_GYO_NO ) AS SEQ
                       ,UPDATE_TBL.KOBAI_NO
                       ,UPDATE_TBL.W_ROW
                       ,UPDATE_TBL.W_USER_ID
                   FROM W_KOBAI AS UPDATE_TBL
                  WHERE UPDATE_TBL.W_USER_ID = @USER_ID
--                    AND UPDATE_TBL.W_SERIAL  = @SERIAL
                    AND UPDATE_TBL.KOBAI_SEQ IS NULL
               ) AS WORK_TBL
            ON WORK_TBL.KOBAI_NO    = W_KOBAI.KOBAI_NO
           AND WORK_TBL.W_ROW       = W_KOBAI.W_ROW
           AND WORK_TBL.W_USER_ID   = W_KOBAI.W_USER_ID


        --更新(ワークテーブル→ヘッダテーブル)
        INSERT INTO
               T_KOBAI_H
                 SELECT
                        KOBAI_NO
                       ,SHINSEISHA_CD
                       ,SHINSEI_DATETIME
                       ,SHINSEI_GAIYO
                       ,KOBAI_KBN
                       ,TAX_RATE
                       ,NUKI_TOTAL
                       ,TAX
                       ,KOMI_TOTAL
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_KOBAI
                  WHERE W_USER_ID = @USER_ID
--                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1


        --新規保存(ワークテーブル→ボディテーブル)
        INSERT INTO
               T_KOBAI_B
                 SELECT
                        KOBAI_NO
                       ,KOBAI_SEQ
                       ,KOBAI_GYO_NO
                       ,KOBAI_STS
                       ,JOGAI_FLG
                       ,KOBAIHIN_CD
                       ,KOBAIHIN_MEI
                       ,TANKA
                       ,IRISU
                       ,IRISU_TANI
                       ,SURYO
                       ,BARA_TANI
                       ,SOSU
                       ,TOTAL
                       ,NOKI
                       ,HOKAN_BASHO_KBN
                       ,SHIIRE_CD
                       ,MAKER_CD
                       ,YOSAN_CD
                       ,JURI_NO
                       ,BIKO
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_KOBAI
                  WHERE W_USER_ID = @USER_ID
--                    AND W_SERIAL  = @SERIAL


        --ステータス変更履歴保存(更新分)
        INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
              ,TBL_B.AFTER_STS
              ,TBL_A.KOBAI_STS
              ,1
              ,TBL_A.DBS_CREATE_USER
              ,TBL_A.DBS_CREATE_DATE
              ,TBL_A.DBS_UPDATE_USER
              ,TBL_A.DBS_UPDATE_DATE
          FROM W_KOBAI AS TBL_A
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
         WHERE TBL_A.W_USER_ID =  @USER_ID
--           AND TBL_A.W_SERIAL  =  @SERIAL
           AND TBL_A.KOBAI_NO  =  TBL_B.KOBAI_NO
           AND TBL_A.KOBAI_SEQ =  TBL_B.KOBAI_SEQ
           AND TBL_A.KOBAI_STS <> TBL_B.AFTER_STS

        --ステータス変更履歴保存(新規追加分)
        INSERT INTO
               T_KOBAI_STS_R
        SELECT
               TBL_A.KOBAI_NO
              ,TBL_A.KOBAI_SEQ
              ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
              ,NULL
              ,TBL_A.KOBAI_STS
              ,1
              ,TBL_A.DBS_CREATE_USER
              ,TBL_A.DBS_CREATE_DATE
              ,TBL_A.DBS_UPDATE_USER
              ,TBL_A.DBS_UPDATE_DATE
          FROM W_KOBAI AS TBL_A
         WHERE TBL_A.W_USER_ID =  @USER_ID
--           AND TBL_A.W_SERIAL  =  @SERIAL
           AND NOT EXISTS
               ( SELECT *
                   FROM T_KOBAI_STS_R
                  WHERE TBL_A.KOBAI_NO  = T_KOBAI_STS_R.KOBAI_NO
                    AND TBL_A.KOBAI_SEQ = T_KOBAI_STS_R.KOBAI_SEQ
               )

      END


    --削除処理
    ELSE IF @MODE = 3
      BEGIN

        SET @KOBAI_NO    = @REF_NO
        SET @UPDATE_USER = @USER_ID
        SET @UPDATE_DATE = 'DT' + CONVERT(VARCHAR(24),GETDATE(),120)

        --既存データ削除(ヘッダ)フラグTrue
        UPDATE T_KOBAI_H
           SET T_KOBAI_H.DEL_FLG = 'True'
              ,T_KOBAI_H.DBS_CREATE_USER = @UPDATE_USER
              ,T_KOBAI_H.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_KOBAI_H
         WHERE T_KOBAI_H.KOBAI_NO = @KOBAI_NO

        --既存データ削除(ボディ)フラグTrue
        UPDATE T_KOBAI_B
           SET T_KOBAI_B.DEL_FLG = 'True'
              ,T_KOBAI_B.DBS_UPDATE_USER = @UPDATE_USER
              ,T_KOBAI_B.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_KOBAI_B
         WHERE T_KOBAI_B.KOBAI_NO = @KOBAI_NO

      END


    ELSE
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_KOBAI
         WHERE W_KOBAI.W_USER_ID = @USER_ID

      END

    --共通処理

    --注文確定インフォメーション生成 201801追加

    BEGIN
          EXEC SP_CREATE_INFO @USER_ID ,@SERIAL ,7
    END

    --ワークテーブルクリア
    DELETE
      FROM W_KOBAI
     WHERE W_KOBAI.W_USER_ID = @USER_ID

    --正常終了
    INSERT INTO @TBL VALUES( @KOBAI_NO, 0, NULL )

    --処理結果返却
    SELECT RESULT_KOBAI_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_KOBAI
     WHERE W_KOBAI.W_USER_ID = @USER_ID

    --異常終了
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_KOBAI_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END

