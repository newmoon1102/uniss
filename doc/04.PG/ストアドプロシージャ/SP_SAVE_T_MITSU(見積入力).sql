-- DROP PROCEDURE SP_SAVE_T_MITSU


CREATE PROCEDURE SP_SAVE_T_MITSU
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
AS
--保存処理実行
BEGIN
    --戻り値用テーブル変数
    DECLARE @TBL TABLE (
      RESULT_MITSU_NO NVARCHAR(10)
     ,RESULT_CD       int NOT NULL
     ,RESULT_MESSAGE  NVARCHAR(max)
    )

	--シーケンス
	DECLARE @SEQ AS INT

    --対象見積No.
    DECLARE @MITSU_NO AS NVARCHAR(10)

    --更新ユーザー・更新日時
    DECLARE @UPDATE_USER AS NVARCHAR(max)
    DECLARE @UPDATE_DATE AS NVARCHAR(50)

    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --新規登録処理
    IF @MODE = 1
      BEGIN
      
        SET @SEQ = NEXT VALUE FOR SEQ_MITSU_NO

        --見積No.生成
        SET @MITSU_NO = ( SELECT CONCAT( 'M', RIGHT('00'+CAST(YEAR(GETDATE()) AS NVARCHAR) ,2) 
                                  ,'-' 
                                  ,RIGHT('00'+CAST(MONTH(GETDATE()) AS NVARCHAR) ,2)
                                  ,RIGHT('0000' + CAST(@SEQ AS NVARCHAR) ,4) ) )


        --新規保存ヘッダ(ワークテーブル→テーブル)
        INSERT INTO
               T_MITSU_H(
                            MITSU_NO
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI
                           ,RIEKI_RATE
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT @MITSU_NO
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI_H
                           ,RIEKI_RATE
                           ,DEL_FLG_H
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM W_MITSU
                      WHERE W_MITSU.W_USER_ID = @USER_ID
                        AND W_MITSU.W_SERIAL  = @SERIAL
                        AND W_MITSU.W_ROW     = 1


        --新規保存ボディ(ワークテーブル→マスタ)
        INSERT INTO
               T_MITSU_B(
                            MITSU_NO
                           ,GYO_NO
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT @MITSU_NO
                           ,GYO_NO
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI_B
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG_B
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM W_MITSU
                      WHERE W_MITSU.W_USER_ID = @USER_ID
                        AND W_MITSU.W_SERIAL  = @SERIAL
      END

    --更新処理
    ELSE IF @MODE = 2
      BEGIN

         --見積No.セット
         SET @MITSU_NO = ( SELECT W_MITSU.MITSU_NO
                             FROM W_MITSU
                            WHERE W_MITSU.W_USER_ID = @USER_ID
                              AND W_MITSU.W_SERIAL  = @SERIAL
                              AND W_MITSU.W_ROW     = 1)

        --履歴ヘッダテーブルへ退避
        INSERT INTO
               T_MITSU_H_R(
                            MITSU_NO
                           ,RIREKI_NO
                           ,SHORI_KBN
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI
                           ,RIEKI_RATE
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT MITSU_NO
                            --履歴No.取得
                           ,( SELECT CASE
                                          WHEN WK_TBL.RIREKI_NO_MAX IS NULL THEN 1
                                          ELSE WK_TBL.RIREKI_NO_MAX + 1
                                     END
                                FROM (
                                     SELECT MAX(T_MITSU_H_R.RIREKI_NO) AS RIREKI_NO_MAX
                                       FROM T_MITSU_H_R
                                      WHERE T_MITSU_H_R.MITSU_NO = @MITSU_NO
                                     ) AS WK_TBL
                            )
                            --処理区分判定
                           ,( SELECT CASE
                                            WHEN COUNT(*) = 0 THEN '新規登録'
                                            ELSE CASE
                                                        WHEN ( SELECT T_MITSU_H.DEL_FLG
                                                                 FROM T_MITSU_H
                                                                WHERE T_MITSU_H.MITSU_NO = @MITSU_NO ) = 'True'
                                                        THEN '削除'
                                                 ELSE '修正'
                                                 END
                                     END
                                FROM T_MITSU_H_R
                               WHERE T_MITSU_H_R.MITSU_NO = @MITSU_NO
                            )
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI
                           ,RIEKI_RATE
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM T_MITSU_H
                      WHERE T_MITSU_H.MITSU_NO = @MITSU_NO


        --履歴ボディテーブルへ保存
        INSERT INTO
               T_MITSU_B_R(
                            MITSU_NO
                           ,GYO_NO
                           ,RIREKI_NO
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT MITSU_NO
                           ,GYO_NO
                           --履歴No.取得(ヘッダと同じ履歴No.)
                           ,( SELECT CASE
                                          WHEN WK_TBL.RIREKI_NO_MAX IS NULL THEN 1
                                          ELSE WK_TBL.RIREKI_NO_MAX
                                     END
                                FROM (
                                     SELECT MAX(T_MITSU_H_R.RIREKI_NO) AS RIREKI_NO_MAX
                                       FROM T_MITSU_H_R
                                      WHERE T_MITSU_H_R.MITSU_NO = @MITSU_NO
                                     ) AS WK_TBL
                            )
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM T_MITSU_B
                      WHERE T_MITSU_B.MITSU_NO = @MITSU_NO

        --既存データ削除（ヘッダ）
        DELETE
          FROM T_MITSU_H
         WHERE T_MITSU_H.MITSU_NO = @MITSU_NO

        --既存データ削除（ボディ）
        DELETE
          FROM T_MITSU_B
         WHERE T_MITSU_B.MITSU_NO = @MITSU_NO

        --新規保存ヘッダ(ワークテーブル→マスタ)
        INSERT INTO
               T_MITSU_H(
                            MITSU_NO
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI
                           ,RIEKI_RATE
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT MITSU_NO
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI_H
                           ,RIEKI_RATE
                           ,DEL_FLG_H
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM W_MITSU
                      WHERE W_MITSU.W_USER_ID = @USER_ID
                        AND W_MITSU.W_SERIAL  = @SERIAL
                        AND W_MITSU.W_ROW     = 1


        --新規保存ボディ(ワークテーブル→マスタ)
        INSERT INTO
               T_MITSU_B(
                            MITSU_NO
                           ,GYO_NO
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT MITSU_NO
                           ,GYO_NO
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI_B
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG_B
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM W_MITSU
                      WHERE W_MITSU.W_USER_ID = @USER_ID
                        AND W_MITSU.W_SERIAL  = @SERIAL
      END

    --削除処理
    ELSE
      BEGIN

         --見積No./更新ユーザー/更新日時セット
        SELECT @MITSU_NO    = W_MITSU.MITSU_NO
              ,@UPDATE_USER = W_MITSU.DBS_UPDATE_USER
              ,@UPDATE_DATE = W_MITSU.DBS_UPDATE_DATE
          FROM W_MITSU
         WHERE W_MITSU.W_USER_ID = @USER_ID
           AND W_MITSU.W_SERIAL  = @SERIAL
           AND W_MITSU.W_ROW     = 1

        --履歴ヘッダテーブルへ退避
        INSERT INTO
               T_MITSU_H_R(
                            MITSU_NO
                           ,RIREKI_NO
                           ,SHORI_KBN
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI
                           ,RIEKI_RATE
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT MITSU_NO
                            --履歴No.取得
                           ,( SELECT CASE
                                          WHEN WK_TBL.RIREKI_NO_MAX IS NULL THEN 1
                                          ELSE WK_TBL.RIREKI_NO_MAX + 1
                                     END
                                FROM (
                                     SELECT MAX(T_MITSU_H_R.RIREKI_NO) AS RIREKI_NO_MAX
                                       FROM T_MITSU_H_R
                                      WHERE T_MITSU_H_R.MITSU_NO = @MITSU_NO
                                     ) AS WK_TBL
                            )
                           ,'削除'
                           ,MODE_KBN
                           ,MITSU_DATE
                           ,MITSU_STS
                           ,NYURYOKUSHA_CD
                           ,TORIHIKI_BUNRUI
                           ,REF_MITSU_NO
                           ,KOYOMI_KBN
                           ,SEIKYU_CD
                           ,SEIKYU_MEI
                           ,SEMPO_TANTO_MEI
                           ,KEISHO
                           ,KENMEI
                           ,EIGYO_TANTO_CD
                           ,MEMO
                           ,UKE_KIJITSU
                           ,UKE_BASHO
                           ,TORI_JOKEN
                           ,YUKO_KIGEN
                           ,TANTO_MARK_FLG
                           ,DAIHYO_MEI_FLG
                           ,KAISHA_MARK_FLG
                           ,SHONIN_RAN_FLG
                           ,ZEIKOMI_PRINT_FLG
                           ,TAX_RATE
                           ,NUKI_TOTAL
                           ,TAX
                           ,KOMI_TOTAL
                           ,GENKA_TOTAL
                           ,ARARIEKI
                           ,RIEKI_RATE
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM T_MITSU_H
                      WHERE T_MITSU_H.MITSU_NO = @MITSU_NO


        --履歴ボディテーブルへ保存
        INSERT INTO
               T_MITSU_B_R(
                            MITSU_NO
                           ,GYO_NO
                           ,RIREKI_NO
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                          )
                     SELECT MITSU_NO
                           ,GYO_NO
                           --履歴No.取得(ヘッダと同じ履歴No.)
                           ,( SELECT CASE
                                          WHEN WK_TBL.RIREKI_NO_MAX IS NULL THEN 1
                                          ELSE WK_TBL.RIREKI_NO_MAX
                                     END
                                FROM (
                                     SELECT MAX(T_MITSU_H_R.RIREKI_NO) AS RIREKI_NO_MAX
                                       FROM T_MITSU_H_R
                                      WHERE T_MITSU_H_R.MITSU_NO = @MITSU_NO
                                     ) AS WK_TBL
                            )
                           ,ROW_KBN
                           ,SHOHIN_CD
                           ,SHOHIN_MEI
                           ,SURYO
                           ,TANI
                           ,TANKA
                           ,KINGAKU
                           ,TEKIYO
                           ,GENTANKA
                           ,GENKA
                           ,ARARIRITSU
                           ,ARARIEKI
                           ,TEIKA
                           ,SHIIRE_CD
                           ,NEBIKI_RITSU
                           ,DEL_FLG
                           ,DBS_STATUS
                           ,DBS_CREATE_USER
                           ,DBS_CREATE_DATE
                           ,DBS_UPDATE_USER
                           ,DBS_UPDATE_DATE
                       FROM T_MITSU_B
                      WHERE T_MITSU_B.MITSU_NO = @MITSU_NO

         --既存データ削除(ヘッダ)フラグTrue
        UPDATE T_MITSU_H
           SET T_MITSU_H.DEL_FLG = 'True'
              ,T_MITSU_H.DBS_UPDATE_USER = @UPDATE_USER
              ,T_MITSU_H.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_MITSU_H
         WHERE T_MITSU_H.MITSU_NO = @MITSU_NO

        --既存データ削除(ボディ)フラグTrue
        UPDATE T_MITSU_B
           SET T_MITSU_B.DEL_FLG = 'True'
              ,T_MITSU_B.DBS_UPDATE_USER = @UPDATE_USER
              ,T_MITSU_B.DBS_UPDATE_DATE = @UPDATE_DATE
          FROM T_MITSU_B
         WHERE T_MITSU_B.MITSU_NO = @MITSU_NO

      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_MITSU
     WHERE W_MITSU.W_USER_ID = @USER_ID
       AND W_MITSU.W_SERIAL  = @SERIAL

    --正常終了
    INSERT INTO @TBL VALUES( @MITSU_NO ,0 ,NULL )

    --処理結果返却
    SELECT RESULT_MITSU_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY


-- 例外処理
BEGIN CATCH

    -- トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_MITSU
     WHERE W_MITSU.W_USER_ID = @USER_ID
       AND W_MITSU.W_SERIAL  = @SERIAL

    --異常終了
    INSERT INTO @TBL VALUES( 0 ,ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_MITSU_NO ,RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END
