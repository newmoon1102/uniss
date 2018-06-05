--DROP PROCEDURE SP_SAVE_T_HAN_JUCHU

CREATE PROCEDURE SP_SAVE_T_HAN_JUCHU
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
AS
--保存処理実行
BEGIN
    --戻り値用テーブル変数
    DECLARE @TBL TABLE (
      RESULT_JURI_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --シーケンス
    DECLARE @SEQ AS INT

    --対象受理No.
    DECLARE @JURI_NO AS NVARCHAR(10)
    
    --対象見積No.
    DECLARE @MITSU_NO AS NVARCHAR(10)

    --対象購買申請No.
    DECLARE @KOBAI_NO AS NVARCHAR(10)

    --更新ユーザー・更新日時
    DECLARE @UPDATE_USER AS NVARCHAR(max)
    DECLARE @UPDATE_DATE AS NVARCHAR(50)

    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --新規登録処理
    IF @MODE = 1
      BEGIN

        --シーケンス取得
        SET @SEQ = NEXT VALUE FOR SEQ_JURI_NO

        --受理No.生成
        SET @JURI_NO = ( SELECT CONCAT( 'J', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

        --見積No.取得
        SET @MITSU_NO = ( SELECT MITSU_NO
                            FROM W_HAN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 )

        --新規保存(ワークテーブル→ヘッダテーブル)
        INSERT INTO
               T_HAN_JUCHU_H
                 SELECT  @JURI_NO
                        ,HAMBAI_STS
                        ,HAMBAI_KBN
                        ,REF_JURI_NO
                        ,NYURYOKU_DATETIME
                        ,NYURYOKUSHA_CD
                        ,MITSU_NO
                        ,JUCHU_DATE
                        ,NOHIN_DATE
                        ,SEIKYU_CD
                        ,SEIKYU_TANTO_MEI
                        ,KENMEI
                        ,EIGYO_TANTO_CD
                        ,HASSO_CD
                        ,HASSO_MEI
                        ,HASSO_YUBIN_NO
                        ,HASSO_ADDRESS_1
                        ,HASSO_ADDRESS_2
                        ,HASSO_TEL
                        ,HASSO_FAX
                        ,HASSO_TANTO_MEI
                        ,MAKER_FLG
                        ,TAX_RATE
                        ,NUKI_TOTAL
                        ,TAX
                        ,KOMI_TOTAL
                        ,GENKA_TOTAL
                        ,ARARIEKI
                        ,ARARIRITSU
                        ,DEMPYO_HAKKO_KBN
                        ,DEL_FLG
                        ,DBS_STATUS
                        ,DBS_CREATE_USER
                        ,DBS_CREATE_DATE
                        ,DBS_UPDATE_USER
                        ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --新規保存(ワークテーブル→ボディテーブル)
        INSERT INTO
               T_HAN_JUCHU_B
                 SELECT @JURI_NO
                       ,GYO_NO
                       ,ROW_KBN
                       ,SHOHIN_CD
                       ,SHOHIN_MEI
                       ,JUCHU_SURYO
                       ,JUCHU_TANI
                       ,HAMBAI_TANKA
                       ,HAMBAI_KINGAKU
                       ,TEKIYO
                       ,GENTANKA
                       ,GENKA_SURYO
                       ,IRISU_TANI
                       ,TOTAL
                       ,BARA_TANI
                       ,GENKA_KINGAKU
                       ,ARARIRITSU
                       ,ARARIEKI
                       ,TEIKA
                       ,SHIIRE_CD
                       ,MAKER_CD
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL

        --対象見積のステータスを受注済に変更
        IF @MITSU_NO <> ''
          BEGIN
            UPDATE T_MITSU_H
               SET T_MITSU_H.MITSU_STS = '5'
              FROM T_MITSU_H
             WHERE T_MITSU_H.MITSU_NO = @MITSU_NO
          END



        --購買申請データ自動生成
        --購買品が1件以上ある場合実行
        IF ( SELECT COUNT(*)
               FROM W_HAN_JUCHU
               LEFT JOIN
                    M_SHOHIN
                 ON M_SHOHIN.SHOHIN_CD = W_HAN_JUCHU.SHOHIN_CD
              WHERE W_USER_ID             = @USER_ID
                AND W_SERIAL              = @SERIAL
                AND ROW_KBN               = 1
                AND M_SHOHIN.KOBAIHIN_FLG = 'True'
           ) >= 1
          BEGIN

            --シーケンス取得
            SET @SEQ = NEXT VALUE FOR SEQ_KOBAI_NO

            --購買申請No.生成
            SET @KOBAI_NO = ( SELECT CONCAT( 'K', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                    ,'-' 
                                    ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                    ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )

            --新規保存(ワークテーブル→ヘッダテーブル)
            INSERT INTO
                   T_KOBAI_H
                     SELECT
                            @KOBAI_NO
                           ,@USER_ID
                           ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                           ,@JURI_NO
                           ,5                   --KOBAI_KBN(販売商品)
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,'False'             --DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM W_HAN_JUCHU
                      WHERE W_USER_ID = @USER_ID
                        AND W_SERIAL  = @SERIAL
                        AND W_ROW     = 1

            --新規保存(ワークテーブル→ボディテーブル)
            INSERT INTO
                   T_KOBAI_B
                     SELECT
                            @KOBAI_NO
                           ,ROW_NUMBER() OVER (ORDER BY GYO_NO)
                           ,ROW_NUMBER() OVER (ORDER BY GYO_NO)
                           ,1                               --KOBAI_STS
                           ,'False'                         --JOGAI_FLG
                           ,W_HAN_JUCHU.SHOHIN_CD
                           ,W_HAN_JUCHU.SHOHIN_MEI
                           ,ISNULL(W_HAN_JUCHU.GENTANKA,0)
                           ,M_SHOHIN.SHIIRE_IRISU           --IRISU
                           ,M_SHOHIN.SHIIRE_IRISU_TANI
                           ,W_HAN_JUCHU.GENKA_SURYO
                           ,W_HAN_JUCHU.BARA_TANI
                           ,CASE ISNULL(M_SHOHIN.SHIIRE_IRISU,0)
                            WHEN 0 THEN W_HAN_JUCHU.GENKA_SURYO
                            ELSE CAST(M_SHOHIN.SHIIRE_IRISU * W_HAN_JUCHU.GENKA_SURYO AS NUMERIC(7, 2))
                            END                             --SOSU
                           ,CASE ISNULL(W_HAN_JUCHU.GENTANKA,0)
                            WHEN 0 THEN 0
                            ELSE CAST(W_HAN_JUCHU.GENTANKA * W_HAN_JUCHU.GENKA_SURYO AS NUMERIC(11, 2))
                            END                             --TOTAL
                           ,ISNULL(W_HAN_JUCHU.NOHIN_DATE,'') --NOKI
                           ,M_SHOHIN.HOKANBASHO_KBN         --HOKAN_BASHO_KBN
                           ,W_HAN_JUCHU.SHIIRE_CD
                           ,W_HAN_JUCHU.MAKER_CD
                           ,NULL                            --YOSAN_CD
                           ,@JURI_NO                        --JURI_NO
                           ,W_HAN_JUCHU.TEKIYO              --BIKO
                           ,'False'                         --DEL_FLG
                           ,W_HAN_JUCHU.DBS_STATUS
                           ,W_HAN_JUCHU.DBS_CREATE_USER
                           ,W_HAN_JUCHU.DBS_CREATE_DATE
                           ,W_HAN_JUCHU.DBS_UPDATE_USER
                           ,W_HAN_JUCHU.DBS_UPDATE_DATE
                       FROM W_HAN_JUCHU
                       LEFT JOIN
                            M_SHOHIN
                         ON M_SHOHIN.SHOHIN_CD = W_HAN_JUCHU.SHOHIN_CD
                      WHERE W_USER_ID             = @USER_ID
                        AND W_SERIAL              = @SERIAL
                        AND ROW_KBN               = 1
                        AND M_SHOHIN.KOBAIHIN_FLG = 'True'

            --ステータス変更履歴保存(新規作成)
            --変更日時はストアド上のシステム日時
            INSERT INTO
                   T_KOBAI_STS_R
            SELECT
                   @KOBAI_NO
                  ,ROW_NUMBER() OVER (ORDER BY GYO_NO)
                  ,CONVERT(VARCHAR(10),GETDATE(),111) + ' ' + CONVERT(VARCHAR(8),GETDATE(),114)
                  ,NULL
                  ,1
                  ,1
                  ,W_HAN_JUCHU.DBS_CREATE_USER
                  ,W_HAN_JUCHU.DBS_CREATE_DATE
                  ,W_HAN_JUCHU.DBS_UPDATE_USER
                  ,W_HAN_JUCHU.DBS_UPDATE_DATE
              FROM W_HAN_JUCHU
              LEFT JOIN
                   M_SHOHIN
                ON M_SHOHIN.SHOHIN_CD = W_HAN_JUCHU.SHOHIN_CD
             WHERE W_USER_ID             = @USER_ID
               AND W_SERIAL              = @SERIAL
               AND ROW_KBN               = 1
               AND M_SHOHIN.KOBAIHIN_FLG = 'True'

          END

      END

    --更新処理
    ELSE IF @MODE = 2
      BEGIN

         --受理No.セット
         SET @JURI_NO =  ( SELECT W_HAN_JUCHU.JURI_NO
                             FROM W_HAN_JUCHU
                            WHERE W_HAN_JUCHU.W_USER_ID   = @USER_ID
                              AND W_HAN_JUCHU.W_SERIAL    = @SERIAL
                              AND W_HAN_JUCHU.W_ROW       = 1 )

        --見積No.取得
        SET @MITSU_NO = ( SELECT MITSU_NO
                            FROM W_HAN_JUCHU
                           WHERE W_USER_ID = @USER_ID
                             AND W_SERIAL  = @SERIAL
                             AND W_ROW     = 1 )

        --ヘッダテーブル削除
        DELETE
          FROM T_HAN_JUCHU_H
         WHERE T_HAN_JUCHU_H.JURI_NO = @JURI_NO

        --ボディテーブル削除
        DELETE
          FROM T_HAN_JUCHU_B
         WHERE T_HAN_JUCHU_B.JURI_NO = @JURI_NO

        --更新(ワークテーブル→ヘッダテーブル)
        INSERT INTO
               T_HAN_JUCHU_H
                 SELECT  JURI_NO
                        ,HAMBAI_STS
                        ,HAMBAI_KBN
                        ,REF_JURI_NO
                        ,NYURYOKU_DATETIME
                        ,NYURYOKUSHA_CD
                        ,MITSU_NO
                        ,JUCHU_DATE
                        ,NOHIN_DATE
                        ,SEIKYU_CD
                        ,SEIKYU_TANTO_MEI
                        ,KENMEI
                        ,EIGYO_TANTO_CD
                        ,HASSO_CD
                        ,HASSO_MEI
                        ,HASSO_YUBIN_NO
                        ,HASSO_ADDRESS_1
                        ,HASSO_ADDRESS_2
                        ,HASSO_TEL
                        ,HASSO_FAX
                        ,HASSO_TANTO_MEI
                        ,MAKER_FLG
                        ,TAX_RATE
                        ,NUKI_TOTAL
                        ,TAX
                        ,KOMI_TOTAL
                        ,GENKA_TOTAL
                        ,ARARIEKI
                        ,ARARIRITSU
                        ,DEMPYO_HAKKO_KBN
                        ,DEL_FLG
                        ,DBS_STATUS
                        ,DBS_CREATE_USER
                        ,DBS_CREATE_DATE
                        ,DBS_UPDATE_USER
                        ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL
                    AND W_ROW     = 1

        --更新(ワークテーブル→ボディテーブル)
        INSERT INTO
               T_HAN_JUCHU_B
                 SELECT JURI_NO
                       ,GYO_NO
                       ,ROW_KBN
                       ,SHOHIN_CD
                       ,SHOHIN_MEI
                       ,JUCHU_SURYO
                       ,JUCHU_TANI
                       ,HAMBAI_TANKA
                       ,HAMBAI_KINGAKU
                       ,TEKIYO
                       ,GENTANKA
                       ,GENKA_SURYO
                       ,IRISU_TANI
                       ,TOTAL
                       ,BARA_TANI
                       ,GENKA_KINGAKU
                       ,ARARIRITSU
                       ,ARARIEKI
                       ,TEIKA
                       ,SHIIRE_CD
                       ,MAKER_CD
                       ,DEL_FLG
                       ,DBS_STATUS
                       ,DBS_CREATE_USER
                       ,DBS_CREATE_DATE
                       ,DBS_UPDATE_USER
                       ,DBS_UPDATE_DATE
                   FROM W_HAN_JUCHU
                  WHERE W_USER_ID = @USER_ID
                    AND W_SERIAL  = @SERIAL

        --対象見積のステータスを受注済に変更
        IF @MITSU_NO <> ''
          BEGIN
            UPDATE T_MITSU_H
               SET T_MITSU_H.MITSU_STS = '5'
              FROM T_MITSU_H
             WHERE T_MITSU_H.MITSU_NO = @MITSU_NO
          END

      END

    --削除処理
    ELSE
      BEGIN

         --受理No./更新ユーザー/更新日時セット
        SELECT @JURI_NO     = W_HAN_JUCHU.JURI_NO
              ,@UPDATE_USER = W_HAN_JUCHU.DBS_UPDATE_USER
              ,@UPDATE_DATE = W_HAN_JUCHU.DBS_UPDATE_DATE
          FROM W_HAN_JUCHU
         WHERE W_HAN_JUCHU.W_USER_ID   = @USER_ID
           AND W_HAN_JUCHU.W_SERIAL    = @SERIAL
           AND W_HAN_JUCHU.W_ROW       = 1


        --既存データ削除(ヘッダ)フラグTrue
        UPDATE T_HAN_JUCHU_H
           SET T_HAN_JUCHU_H.DEL_FLG = 'True'
              ,T_HAN_JUCHU_H.DBS_CREATE_USER = @UPDATE_USER
              ,T_HAN_JUCHU_H.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_HAN_JUCHU_H
         WHERE T_HAN_JUCHU_H.JURI_NO = @JURI_NO

        --既存データ削除(ボディ)フラグTrue
        UPDATE T_HAN_JUCHU_B
           SET T_HAN_JUCHU_B.DEL_FLG = 'True'
              ,T_HAN_JUCHU_B.DBS_UPDATE_USER = @UPDATE_USER
              ,T_HAN_JUCHU_B.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_HAN_JUCHU_B
         WHERE T_HAN_JUCHU_B.JURI_NO = @JURI_NO

      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_HAN_JUCHU
     WHERE W_HAN_JUCHU.W_USER_ID = @USER_ID
--       AND W_HAN_JUCHU.W_SERIAL  = @SERIAL

    --正常終了
    --購買申請No.返却
    INSERT INTO @TBL VALUES( @JURI_NO, 0, @KOBAI_NO )

    --処理結果返却
    SELECT RESULT_JURI_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_HAN_JUCHU
     WHERE W_HAN_JUCHU.W_USER_ID = @USER_ID
--       AND W_HAN_JUCHU.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_JURI_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END

