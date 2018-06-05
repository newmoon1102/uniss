
--DROP PROCEDURE SP_SAVE_T_ZAIKO

CREATE PROCEDURE SP_SAVE_T_ZAIKO
       @USER_ID  NVARCHAR(64)
      ,@SERIAL   NVARCHAR(50)
      ,@MODE     INT
      ,@REF_NO   NVARCHAR(10)
AS
--保存処理実行
BEGIN
    --戻り値用テーブル変数
    DECLARE @TBL TABLE (
      RESULT_ZAIKO_NO NVARCHAR(10)
     ,RESULT_CD int NOT NULL
     ,RESULT_MESSAGE NVARCHAR(max)
    )

    --セーブポイント生成
    SAVE TRANSACTION SAVE1

BEGIN TRY

    --在庫調整処理
    IF @MODE IN ( 1,2 )
      BEGIN

            --在庫引き当て
            UPDATE T_ZAIKO
               SET T_ZAIKO.HOKAN_BASHO_KBN = W_ZAIKO_INPUT.HOKAN_BASHO_KBN
                  ,T_ZAIKO.KOBAIHIN_CD     = W_ZAIKO_INPUT.KOBAIHIN_CD
                  ,T_ZAIKO.TANKA           = W_ZAIKO_INPUT.TANKA
                  ,T_ZAIKO.ZAIKO_SURYO     = W_ZAIKO_INPUT.ZAIKO_SURYO
                  ,T_ZAIKO.BARA_TANI       = W_ZAIKO_INPUT.BARA_TANI
                  ,T_ZAIKO.IRISU           = W_ZAIKO_INPUT.IRISU
                  ,T_ZAIKO.IRISU_TANI      = W_ZAIKO_INPUT.IRISU_TANI
                  ,T_ZAIKO.SHIIRE_CD       = W_ZAIKO_INPUT.SHIIRE_CD
                  ,T_ZAIKO.MAKER_CD        = W_ZAIKO_INPUT.MAKER_CD
                  ,T_ZAIKO.DBS_UPDATE_USER = W_ZAIKO_INPUT.DBS_UPDATE_USER
                  ,T_ZAIKO.DBS_UPDATE_DATE = W_ZAIKO_INPUT.DBS_UPDATE_DATE
              FROM T_ZAIKO
             INNER JOIN
                   W_ZAIKO_INPUT
                ON W_ZAIKO_INPUT.ZAIKO_NO = T_ZAIKO.ZAIKO_NO
             WHERE W_USER_ID = @USER_ID
               AND W_SERIAL  = @SERIAL
               AND W_ROW     = 1

      END

    --削除処理
    ELSE IF @MODE = 3
      BEGIN

        --在庫テーブル削除
        DELETE
          FROM T_ZAIKO
         WHERE T_ZAIKO.ZAIKO_NO = @REF_NO

      END

    --その他処理
    ELSE
      BEGIN

        --ワークテーブルクリア
        DELETE
          FROM W_ZAIKO_INPUT
         WHERE W_ZAIKO_INPUT.W_USER_ID = @USER_ID

      END

    --共通処理
    --ワークテーブルクリア
    DELETE
      FROM W_ZAIKO_INPUT
     WHERE W_ZAIKO_INPUT.W_USER_ID = @USER_ID

    --正常終了
    INSERT INTO @TBL VALUES( @REF_NO, 0, NULL )

    --処理結果返却
    SELECT RESULT_ZAIKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END TRY

-- 例外処理
BEGIN CATCH

    --トランザクションをロールバック（キャンセル）
    ROLLBACK TRANSACTION SAVE1

    --ワークテーブルクリア
    DELETE
      FROM W_ZAIKO_INPUT
     WHERE W_ZAIKO_INPUT.W_USER_ID = @USER_ID

    --異常終了
    INSERT INTO @TBL VALUES( 0, ERROR_NUMBER(), ERROR_MESSAGE() )

    --処理結果返却
    SELECT RESULT_ZAIKO_NO, RESULT_CD, RESULT_MESSAGE FROM @TBL

END CATCH

END


